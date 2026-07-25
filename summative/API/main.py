from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import joblib
import pandas as pd

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

model = joblib.load("../linear_regression/best_model.pkl")
scaler = joblib.load("../linear_regression/scaler.pkl")
training_columns = joblib.load("../linear_regression/training_columns.pkl")

class PredictionInput(BaseModel):
    Age: float
    alcohol_consumption_per_week: float
    physical_activity_minutes_per_week: float
    diet_score: float
    sleep_hours_per_day: float
    screen_time_hours_per_day: float
    family_history_diabetes: int
    hypertension_history: int
    cardiovascular_history: int
    bmi: float
    waist_to_hip_ratio: float
    systolic_bp: float
    diastolic_bp: float
    heart_rate: float
    cholesterol_total: float
    hdl_cholesterol: float
    ldl_cholesterol: float
    triglycerides: float
    glucose_postprandial: float
    insulin_level: float
    hba1c: float
    gender_Male: int
    gender_Other: int
    ethnicity_Black: int
    ethnicity_Hispanic: int
    ethnicity_Other: int
    ethnicity_White: int
    education_level_Highschool: int
    education_level_No_formal: int
    education_level_Postgraduate: int
    income_level_Low: int
    income_level_Lower_Middle: int
    income_level_Middle: int
    income_level_Upper_Middle: int
    employment_status_Retired: int
    employment_status_Student: int
    employment_status_Unemployed: int
    smoking_status_Former: int
    smoking_status_Never: int

@app.get("/")
def root():
    return {"message": "Glucose prediction API"}

@app.post("/predict")
def predict(data: PredictionInput):
    df = pd.DataFrame([data.model_dump()])
    df.columns = training_columns
    scaled = scaler.transform(df)
    prediction = model.predict(scaled)[0]
    return {"predicted_glucose_fasting": round(float(prediction), 2)}
