import joblib
import pandas as pd

model = joblib.load("best_model.pkl")
scaler = joblib.load("scaler.pkl")

def predict_glucose(input_dict):
    df = pd.DataFrame([input_dict])
    df = pd.get_dummies(df)
    
    # Align columns with training data
    training_columns = joblib.load("training_columns.pkl")
    df = df.reindex(columns=training_columns, fill_value=0)
    
    scaled = scaler.transform(df)
    return model.predict(scaled)[0]
