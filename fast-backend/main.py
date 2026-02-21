from fastapi import FastAPI
from fastapi import FastAPI, HTTPException, UploadFile, File, Form, Depends
from pydantic import BaseModel
from typing import List, Optional
from datetime import date

import xgboost as xgb


app = FastAPI(title="Health-AI-API", description="Backend for Hypertension Tracking Application")

# PYDANTIC MODELS 
class OnboardingData(BaseModel):
    age: int
    gender: str 
    weight_kg: float
    height_cm: float
    avg_sleep_hours: float
    stress_level: int # 1-10
    smoking_status: bool
    diabetic_status: bool
    is_premium: bool = False

class SmartwatchData(BaseModel):
    systolic_bp: int
    diastolic_bp: int
    blood_oxygen_percent: float
    heart_rate_bpm: int
    breathing_rate_rpm: int

class SymptomsData(BaseModel):
    anxiety: bool = False
    headaches: bool = False
    chest_pain: bool = False
    nausea: bool = False
    shortness_of_breath: bool = False

class ExportData(BaseModel):
    latest_vitals: dict
    latest_analysis: dict


def calculate_bmi(weight: float, height_cm: float):
    """
    This helper function calculates the Body-Mass Index.
    """
    height_m = height_cm / 100
    return round(weight / (height_m * height_m), 1)


def calculate_framingham_score(onboarding: OnboardingData, vitals: SmartwatchData):
    """
    This helper function calculates framingham risk score based on onboarding and
    smart watch data.
    """
    score = 0
    
    if onboarding.gender.lower() == "male":
        score += (onboarding.age - 30) * 0.2
    else:
        score += (onboarding.age - 30) * 0.15
    
    if vitals.systolic_bp > 120:
        score += (vitals.systolic_bp - 120) * 0.1
        
    if onboarding.smoking_status:
        score += 3.0
        
    if onboarding.diabetic_status:
        score += 3.0
    
    return score


@app.post("/analyze-vitals")
async def run_analysis(onboarding: OnboardingData, vitals: SmartwatchData):
    """
    This endpoint runs inference on the Machine Learning model using smartwatch and
    onboarding data.
    """

    # TODO Use model here
    # TODO Implement FR risk scoring
    
    response = {
        "hypertension_stage_num": 0,
        "framingham_risk_score:": 0,
        "model_confidence": 0
    }
    
    return response


@app.post("/suggest-tips")
async def suggest_tips(symptoms: SymptomsData):
    """
    This endpoint will suggest health tips based on previous health data and current
    symptoms.
    """
    pass
    

@app.post("/chat")
async def llm_chat():
    """
    This endpoint uses the LLM chat interface.
    """
    pass
