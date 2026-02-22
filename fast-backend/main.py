import asyncio
import os
import datetime
import time
import json
import joblib
import xgboost as xgb
import numpy as np
import pandas as pd
import datetime as dt
import google.generativeai as genai

from fastapi.responses import StreamingResponse
from dotenv import load_dotenv
from pydantic.v1 import validator
from fastapi import FastAPI
from fastapi import FastAPI, HTTPException, UploadFile, File, Form, Depends
from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import date
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="Team LightX API", description="Swagger Open API Specification")

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
llm = genai.GenerativeModel('gemini-3-flash-preview')

vitals_model = xgb.XGBClassifier()

MODEL_DIRECTORY="./models/vitals"
vitals_model.load_model(f"{MODEL_DIRECTORY}/hypertension_model.json")
vitals_imputer = joblib.load(f"{MODEL_DIRECTORY}/imputer.pkl")
vitals_schema = json.load(open(f"{MODEL_DIRECTORY}/feature_schema.json"))

FEATURES = vitals_schema["features"]

STAGE_ADVICE = {
    0: "Blood pressure is healthy. You may maintain your current lifestyle. Be sure to check-in annually.",
    1: "Slightly elevated. Reduce sodium, increase and gradually increase exercise. Recheck in 3-6 months.",
    2: "Stage 1 Hypertension, we recommend consulting a physician. Lifestyle changes required at this stage.",
    3: "Stage 2 Hypertension, we recommend seeking medical attention promptly. Medication is likely needed."
}

STAGE_NAMES = {
    0: "Normal",
    1: "Elevated",
    2: "Stage 1 HTN",
    3: "Stage 2 HTN"
}


class SymptomsData(BaseModel):
    anxiety: bool = False
    headaches: bool = False
    chest_pain: bool = False
    nausea: bool = False
    shortness_of_breath: bool = False


class UserData(BaseModel):
    # These values are gotten from onboarding
    age:            int     = Field(..., ge=1,   le=120, description="Age in years")
    gender:         int     = Field(..., ge=0,   le=1,   description="0=Male, 1=Female")
    smoking_status: int     = Field(..., ge=0,   le=2,   description="0=Never, 1=Former, 2=Current")
    bmi:            float   = Field(..., gt=0,   lt=100, description="Body Mass Index")
    avg_sleep_hours:float   = Field(..., ge=0,   le=24,  description="Average sleep hours per night")
    stress_level:   int     = Field(..., ge=1,   le=10,  description="Self-reported stress level 1-10")
    diabetic:       int     = Field(..., ge=0,   le=1,  description="Self-reported diabetic status level 0-1")

    # These values are gotten from the smart watch
    systolic_bp:    float   = Field(..., gt=0,   description="Average systolic BP (mmHg)")
    diastolic_bp:   float   = Field(..., gt=0,   description="Average diastolic BP (mmHg)") 
    heart_rate:     float   = Field(..., gt=0,   description="Resting heart rate (BPM)")
    spo2:           float   = Field(..., ge=50,  le=100, description="Blood oxygen saturation (%)")
    breathing_rate: float   = Field(..., gt=0,   description="Breathing rate (breaths/min)") 
    hrv:            float   = Field(..., gt=0,   description="Heart rate variability (ms)")

    # These values are optional to include, default values provided
    total_cholesterol: float = Field(180.0, gt=0, description="Total cholesterol (mg/dL)")
    hdl_cholesterol:   float = Field(50.0,  gt=0, description="HDL cholesterol (mg/dL)")
    fasting_glucose:   float = Field(90.0,  gt=0, description="Fasting blood glucose (mg/dL)")
    creatinine:        float = Field(1.0,   gt=0, description="Serum creatinine (mg/dL)")

    @validator('systolic_bp')
    def systolic_must_exceed_diastolic(cls, v, values):
        if 'diastolic_bp' in values and v <= values['diastolic_bp']:
            raise ValueError("systolic_bp must be greater than diastolic_bp")
        return v


class PredictionResult(BaseModel):
    stage:          int
    stage_name:     str
    confidence:     float
    probabilities:  dict
    advice:         str
    derived:        dict
    

class ChatRequest(BaseModel):
    message: str
    context: Optional[str] = "No previous context found."
    
    
def calculate_bmi(weight: float, height_cm: float):
    """
    This helper function calculates the Body-Mass Index.
    """
    height_m = height_cm / 100
    return round(weight / (height_m * height_m), 1)


def calculate_framingham_score(data: UserData):
    """
    This helper function calculates framingham risk score based on onboarding and
    smart watch data.
    """
    age_factor = (data.age - 20) / 10
    chol_factor = (data.total_cholesterol - 160) / 40
    
    hdl = data.hdl_cholesterol
    hdl_factor = (hdl - (40 if data.gender == 0 else 50)) / 10
    
    sbp_factor = (data.systolic_bp - 120) / 10
    smoker_factor = 0 if data.smoking_status == 0 else 1
    diabetic_factor = data.diabetic
    
    return age_factor + chol_factor + hdl_factor + sbp_factor + smoker_factor + diabetic_factor


def run_inference(data: UserData):
    pulse_pressure = data.systolic_bp - data.diastolic_bp
    map_value      = data.diastolic_bp + (pulse_pressure / 3)
    chol_ratio     = (
        data.total_cholesterol / data.hdl_cholesterol
        if data.total_cholesterol and data.hdl_cholesterol
        else np.nan
    )
    row = {
        "age":               data.age,
        "gender":            data.gender,
        "smoking_status":    data.smoking_status,
        "bmi":               data.bmi,
        "systolic_bp":       data.systolic_bp,
        "diastolic_bp":      data.diastolic_bp,
        "heart_rate":        data.heart_rate,
        "pulse_pressure":    pulse_pressure,
        "map":               map_value,
        "total_cholesterol": data.total_cholesterol if data.total_cholesterol else np.nan,
        "hdl_cholesterol":   data.hdl_cholesterol   if data.hdl_cholesterol   else np.nan,
        "fasting_glucose":   data.fasting_glucose   if data.fasting_glucose   else np.nan,
        "creatinine":        data.creatinine         if data.creatinine        else np.nan,
        "chol_ratio":        chol_ratio,
        "avg_sleep_hours":   data.avg_sleep_hours,
        "stress_level":      data.stress_level,
        "spo2":              data.spo2,
        "breathing_rate":    data.breathing_rate,
        "hrv":               data.hrv,
    }
    
    X = pd.DataFrame([row])[FEATURES]
    X_imp = vitals_imputer.transform(X)
    
    stage = int(vitals_model.predict(X_imp)[0])
    probs = vitals_model.predict_proba(X_imp)[0].tolist()
    
    return PredictionResult(
        stage = stage,
        stage_name = STAGE_NAMES[stage],
        confidence = round(max(probs) * 100, 1),
        probabilities = {STAGE_NAMES[i]: round(p * 100, 1) for i, p in enumerate(probs)},
        advice = STAGE_ADVICE[stage],
        derived = {
            "pulse_pressure": round(pulse_pressure, 1),
            "map":            round(map_value, 1),
            "chol_ratio":     round(chol_ratio, 2) if not np.isnan(chol_ratio) else None
        }
    )


@app.get("/", tags=["Health"])
async def base():
    """
    This is the base endpoint.
    """
    return {
        "data": None,
        "message": "API is healthy. Use /docs for swagger documentation",
        "timestamp": dt.datetime.now()
    }


@app.post("/analyse-vitals", tags=["Health"])
async def analyse_vitals(data: UserData):
    """
    This endpoint runs inference on the Machine Learning model using smartwatch and
    onboarding data.
    """
    try:
        result = run_inference(data)
        framingham_score = calculate_framingham_score(data)
        return {
            "data": {
                **result.dict(),
                "risk_score": framingham_score,
            },
            "message": "Prediction complete",
            "timestamp": dt.datetime.now()
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/suggest", tags=["Health"])
async def suggest_tips(symptoms: SymptomsData):
    """
    This endpoint suggests health tips based on current symptoms using Google Gemini AI.
    """
    try:
        #Extract only the symptoms that are True
        active_symptoms = [s.replace("_", " ") for s, has_symptom in symptoms.dict().items() if has_symptom]
        
        if not active_symptoms:
            return {
                "data": {"suggestions": "You're feeling well! Keep up the healthy diet, stay hydrated, and get regular exercise."},
                "message": "No active symptoms",
                "timestamp": dt.datetime.now()
            }

        prompt = f"""
        You are an empathetic medical assistant for a cardiovascular/hypertension detection health app. 
        The user is currently experiencing the following symptoms: {', '.join(active_symptoms)}. 
        Provide 3 short, actionable, and safe health tips for immediate relief or care. 
        Always include a brief disclaimer to seek medical attention if symptoms worsen.
        """
        
        response = llm.generate_content(prompt)
        
        return {
            "data": {"suggestions": response.text},
            "message": "Tips generated successfully",
            "timestamp": dt.datetime.now()
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"AI Service Error: {str(e)}")


async def chat_streamer(prompt: str):
    """Generator function to stream AI responses chunk-based"""
    try:
        response = llm.generate_content(prompt, stream=True)
        for chunk in response:
            if chunk.text:
                yield f"data: {chunk.text}\n\n"
    except Exception as e:
        yield f"data: [Error communicating with AI: {str(e)}]\n\n"


@app.post("/chat", tags=["Health"])
async def chat(req: ChatRequest):
    """
    This endpoint uses the LLM chat interface via Server-Sent Events (SSE)
    for instant streaming responses to the mobile app.
    """
    system_prompt = f"""
    You are a helpful medical assistant for a cardiovascular health app.
    Here is the user's recent health context: {req.context}

    User message: {req.message}
    """

    return StreamingResponse(
        chat_streamer(system_prompt),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",
        }
    )
