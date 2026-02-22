# Fast-API-Backend 
This is the FastAPI backend for the Cavista Hackathon for PulseAid, the Hypertension tracking mobile application. 
It integrates a custom ML model for hypertension staging and leverages Google's Gemini AI for personalized, real time medical chat and symptom-based health tips.


## Core Features
* Hypertension Staging (ML):  Uses an XGBoost classifier to process user demographics and smartwatch vitals (BP, Heart Rate, SpO2, HRV) to predict hypertension stages.
* Framingham Risk Score:  Automatically calculates the user's cardiovascular risk score alongside model predictions.
* AI Health Suggestions And Tips: Generates actionable, symptom-specific health tips using Google Gemini 3-flash.
* Real-time AI Chat: Provides instant, context-aware conversational assistance streamed directly to the mobile app.
* Swagger docs: Documentation is auto-generated, with an interactive API documentation built-in.

## Tech-Stack
* Framework: [FastAPI](https://fastapi.tiangolo.com/)
* Machine Learning: XGBoost, Scikit-learn (Joblib), Pandas, NumPy
* LLM: Google Generative AI (`gemini-3-flash`)
* Data Validation: Pydantic
* Environment Management: `python-dotenv`

## Environment
* Gemini: The Gemini API key is in the .env file of the repository. 

## Documentation
The Swagger Docs can be found at the http://127.0.0.1:8000/docs.
