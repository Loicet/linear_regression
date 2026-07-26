# WeCare — Fasting Glucose Prediction System

An end-to-end machine learning project that predicts fasting blood glucose levels based on a person's health and lifestyle data. It consists of three parts: a machine learning notebook, a FastAPI backend, and a Flutter mobile app.

## Problem Statement and Mission

Chronic diseases such as diabetes and hypertension continue to burden communities in Rwanda and across Africa due to limited awareness, late diagnosis, and inadequate access to preventive care. My mission is to leverage technology to develop accessible, data-driven digital health solutions that improve awareness, prevention, and disease management.

Public API Endpoint (Swagger UI) API URL: https://wecare-api-cjpl.onrender.com

YouTube Demo Video: https://youtu.be/cyKVJYASPJg

---

## What This Project Does

Given inputs like age, BMI, cholesterol levels, lifestyle habits, and medical history, the system predicts a person's **fasting glucose level (mg/dL)** and classifies it as Normal, Pre-Diabetic, or Diabetic range.

---

## Project Structure

```
linear_regression/
├── summative/
│   ├── linear_regression/
│   │   ├── multivariate.ipynb       # ML notebook (EDA, training, evaluation)
│   │   ├── best_model.pkl           # Saved best model (Linear Regression)
│   │   ├── model.pkl                # Linear Regression model
│   │   ├── scaler.pkl               # StandardScaler
│   │   └── training_columns.pkl     # Column names used during training
│   ├── API/
│   │   ├── main.py                  # FastAPI app
│   │   └── requirements.txt         # API dependencies
│   └── FlutterApp/
│       └── lib/
│           └── main.dart            # Flutter mobile app
└── README.md
```

---

## Dataset

- **Source**: [Health and Lifestyle Data for Diabetes Prediction](https://www.kaggle.com/datasets/alamshihab075/health-and-lifestyle-data-for-diabetes-prediction) via Kaggle
- **Target variable**: `glucose_fasting` (continuous, mg/dL)
- **Features**: 39 features after encoding — including age, BMI, cholesterol, HbA1c, lifestyle habits, and demographic info
- **Leakage columns removed**: `diagnosed_diabetes`, `diabetes_stage`, `diabetes_risk_score` — these directly reveal the target and would give unrealistically high accuracy

---

## Part 1 — Machine Learning Notebook

### What's in the notebook

1. Dataset loading and exploration
2. Target distribution and boxplot
3. Pairplot of top 5 correlated features
4. Categorical feature bar charts
5. Correlation heatmap
6. Feature engineering (drop leakage columns, handle missing values)
7. Encoding categorical columns with `pd.get_dummies`
8. Train/test split (80/20)
9. Feature scaling with `StandardScaler`
10. Training and evaluating 3 models
11. Saving the best model

### Models Compared

| Model | MAE | MSE | R² |
|---|---|---|---|
| Linear Regression | 7.01 | 77.53 | 0.5804 |
| Random Forest | 7.12 | 80.23 | 0.5658 |
| Decision Tree | 10.26 | 164.79 | 0.1081 |

**Linear Regression** was selected as the best model based on the highest R² and lowest MSE. Given the continuous nature of the target variable and the relatively linear relationships in the dataset, Linear Regression generalizes better than the tree-based models which tend to overfit.

### How to run the notebook

```bash
cd linear_regression
uv sync
uv run jupyter notebook summative/linear_regression/multivariate.ipynb
```

---

## Part 2 — FastAPI Backend

The API exposes a `/predict` endpoint that accepts all 39 features as JSON and returns the predicted fasting glucose value.

### Setup

```bash
cd summative/API
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --reload
```

### Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/` | Health check |
| POST | `/predict` | Returns predicted glucose (mg/dL) |

### Example request

```json
POST /predict
{
  "Age": 45,
  "bmi": 27.5,
  "hba1c": 5.7,
  "glucose_postprandial": 140,
  ...
}
```

### Example response

```json
{
  "predicted_glucose_fasting": 105.0
}
```

Interactive API docs available at: `http://127.0.0.1:8000/docs`

Live deployed API: https://wecare-api-cjpl.onrender.com
Swagger UI: https://wecare-api-cjpl.onrender.com/docs

---

## Part 3 — Flutter Mobile App

A clean mobile app built with Flutter that lets users input their health data and get an instant glucose prediction from the API.

### Features

- Home screen with app branding
- Prediction form split into 5 collapsible sections:
  - Personal Info
  - Lifestyle
  - Health History
  - Body Metrics
  - Lab Results
- All fields pre-filled with healthy adult defaults
- Result card with color-coded status:
  - 🟢 Normal — below 100 mg/dL
  - 🟠 Pre-Diabetic — 100–125 mg/dL
  - 🔴 Diabetic — 126+ mg/dL

### Setup

```bash
cd summative/FlutterApp
flutter pub get
flutter run
```

> Make sure the FastAPI server is running before making predictions.

---

## Dependencies

### Python (API + Notebook)
- `fastapi`, `uvicorn`
- `scikit-learn`, `pandas`, `numpy`
- `joblib`, `matplotlib`, `seaborn`, `kagglehub`

### Flutter
- `http: ^1.2.0`
- `flutter/material.dart`

---

Thank you!
