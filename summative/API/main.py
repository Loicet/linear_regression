from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import joblib
import pandas as pd
import io

app = FastAPI()

# CORS: allow all origins to support the Flutter mobile app and Swagger UI
# In production this should be restricted to the app's specific domain
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["POST", "GET"],
    allow_headers=["Content-Type"],
)

MODEL_PATH = "../linear_regression/best_model.pkl"
SCALER_PATH = "../linear_regression/scaler.pkl"
COLUMNS_PATH = "../linear_regression/training_columns.pkl"

model = joblib.load(MODEL_PATH)
scaler = joblib.load(SCALER_PATH)
training_columns = joblib.load(COLUMNS_PATH)

class PredictionInput(BaseModel):
    Age: float = Field(..., ge=0, le=120)
    alcohol_consumption_per_week: float = Field(..., ge=0, le=50)
    physical_activity_minutes_per_week: float = Field(..., ge=0, le=1440)
    diet_score: float = Field(..., ge=0, le=10)
    sleep_hours_per_day: float = Field(..., ge=0, le=24)
    screen_time_hours_per_day: float = Field(..., ge=0, le=24)
    family_history_diabetes: int = Field(..., ge=0, le=1)
    hypertension_history: int = Field(..., ge=0, le=1)
    cardiovascular_history: int = Field(..., ge=0, le=1)
    bmi: float = Field(..., ge=10, le=70)
    waist_to_hip_ratio: float = Field(..., ge=0.5, le=2.0)
    systolic_bp: float = Field(..., ge=70, le=250)
    diastolic_bp: float = Field(..., ge=40, le=150)
    heart_rate: float = Field(..., ge=30, le=220)
    cholesterol_total: float = Field(..., ge=50, le=500)
    hdl_cholesterol: float = Field(..., ge=10, le=150)
    ldl_cholesterol: float = Field(..., ge=10, le=300)
    triglycerides: float = Field(..., ge=20, le=1000)
    glucose_postprandial: float = Field(..., ge=50, le=500)
    insulin_level: float = Field(..., ge=0, le=300)
    hba1c: float = Field(..., ge=3.0, le=15.0)
    gender_Male: int = Field(..., ge=0, le=1)
    gender_Other: int = Field(..., ge=0, le=1)
    ethnicity_Black: int = Field(..., ge=0, le=1)
    ethnicity_Hispanic: int = Field(..., ge=0, le=1)
    ethnicity_Other: int = Field(..., ge=0, le=1)
    ethnicity_White: int = Field(..., ge=0, le=1)
    education_level_Highschool: int = Field(..., ge=0, le=1)
    education_level_No_formal: int = Field(..., ge=0, le=1)
    education_level_Postgraduate: int = Field(..., ge=0, le=1)
    income_level_Low: int = Field(..., ge=0, le=1)
    income_level_Lower_Middle: int = Field(..., ge=0, le=1)
    income_level_Middle: int = Field(..., ge=0, le=1)
    income_level_Upper_Middle: int = Field(..., ge=0, le=1)
    employment_status_Retired: int = Field(..., ge=0, le=1)
    employment_status_Student: int = Field(..., ge=0, le=1)
    employment_status_Unemployed: int = Field(..., ge=0, le=1)
    smoking_status_Former: int = Field(..., ge=0, le=1)
    smoking_status_Never: int = Field(..., ge=0, le=1)

@app.get("/")
def root():
    return {"message": "GlucoPredict API is running"}

@app.post("/predict")
def predict(data: PredictionInput):
    df = pd.DataFrame([data.model_dump()])
    df.columns = training_columns
    scaled = scaler.transform(df)
    prediction = model.predict(scaled)[0]
    return {"predicted_glucose_fasting": round(float(prediction), 2)}

@app.post("/retrain")
async def retrain(file: UploadFile = File(...)):
    global model, scaler

    contents = await file.read()
    new_df = pd.read_csv(io.BytesIO(contents))

    # Drop leakage columns if present
    new_df = new_df.drop(columns=["diagnosed_diabetes", "diabetes_stage", "diabetes_risk_score"], errors="ignore")
    new_df = new_df.dropna()

    # Encode categoricals
    cat_cols = ["gender", "ethnicity", "education_level", "income_level", "employment_status", "smoking_status"]
    new_df = pd.get_dummies(new_df, columns=[c for c in cat_cols if c in new_df.columns], drop_first=True)

    # Align columns
    new_df = new_df.reindex(columns=training_columns + ["glucose_fasting"], fill_value=0)

    X = new_df[training_columns]
    y = new_df["glucose_fasting"]

    from sklearn.preprocessing import StandardScaler
    from sklearn.linear_model import LinearRegression

    new_scaler = StandardScaler()
    X_scaled = new_scaler.fit_transform(X)

    new_model = LinearRegression()
    new_model.fit(X_scaled, y)

    joblib.dump(new_model, MODEL_PATH)
    joblib.dump(new_scaler, SCALER_PATH)

    model = new_model
    scaler = new_scaler

    return {"message": "Model retrained successfully"}
