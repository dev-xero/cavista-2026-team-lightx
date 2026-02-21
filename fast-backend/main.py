from fastapi import FastAPI
from fastapi import FastAPI, HTTPException, UploadFile, File, Form, Depends
from pydantic import BaseModel
from typing import List, Optional
from datetime import date

import firebase_admin
from firebase_admin import credentials

cred = credentials.Certificate("/workspaces/cavista-2026-team-lightx/cavista-hackathon-ai-firebase-adminsdk-fbsvc-10c14cab91.json")
firebase_admin.initialize_app(cred)


app = FastAPI(
    title="FastAPI-Health",
    description="This is a backend API for handling the health application.",
)


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

# HELPER FUNCTIONS 
def calculate_bmi(weight: float, height_cm: float) -> float:
    height_m = height_cm / 100
    return round(weight / (height_m * height_m), 1)

def determine_hypertension_stage(systolic: int, diastolic: int) -> str:
    if systolic >= 180 or diastolic >= 120:
        return "Hypertensive Crisis"
    elif systolic >= 140 or diastolic >= 90:
        return "Stage 2 Hypertension"
    elif systolic >= 130 or diastolic >= 80:
        return "Stage 1 Hypertension"
    elif systolic >= 120 and diastolic < 80:
        return "Elevated"
    return "Normal"

def calculate_framingham_score(user: OnboardingData, vitals: SmartwatchData, retina_multiplier: float) -> float:
    score = 0
    # Age factor
    if user.gender.lower() == "male":
        score += (user.age - 30) * 0.2
    else:
        score += (user.age - 30) * 0.15
    
    # BP factor
    if vitals.systolic_bp > 120:
        score += (vitals.systolic_bp - 120) * 0.1
        
    # Smoking factor
    if user.smoking_status:
        score += 3.0

    # BMI factor
    bmi = calculate_bmi(user.weight_kg, user.height_cm)
    if bmi > 25:
        score += (bmi - 25) * 0.2

# API ENDPOINTS
@app.post("/smartwatch")
async def append_smartwatch_data(data: SmartwatchData):
    ["vitals"] = data.dict()
    return {"message": "Smartwatch data synced"}

@app.post("/analyze")
async def run_analysis(
    symptoms: str = Form(...)
):
    vitals_data = SmartwatchData(["vitals"])

    # 3. Calculate metrics
    ht_stage = determine_hypertension_stage(vitals_data.systolic_bp, vitals_data.diastolic_bp)
    risk_score = calculate_framingham_score( vitals_data, ml_results[""])

    # 4. Generate response
    response = {
        "hypertension_stage": ht_stage,
        "preventive_measures": [
            "Maintain a low-sodium diet.",
            "Schedule a routine check-up within 2 weeks." if "Stage 2" in ht_stage else "Exercise 30 mins daily."
        ],
        "ml_insights": ml_results
    }

    # Premium Gate
    if is_premium:
        response["progression_risk"] = {
            "X_year_risk_percent": risk_score,
            "chart_data_points": [10, 12, 15, risk_score]#dummy data
        }
    else:
        response["progression_risk"] = "Upgrade to Premium to view progression risk charts."
    return response

@app.get("/export")
async def export_medical_data():
    return {
        
        "latest_vitals": ["vitals"],
        "latest_analysis": ["analyses"][-1] if ["analyses"] else None
    }