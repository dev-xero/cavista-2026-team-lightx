import json
import joblib
from sklearn.utils import compute_sample_weight
from sklearn.metrics import classification_report, accuracy_score, roc_auc_score, confusion_matrix
import pandas as pd
import xgboost as xgb
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import logging
import os
import warnings

from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.impute import SimpleImputer

warnings.filterwarnings('ignore')
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

DATA_DIRECTORY="./NHANES_data"
OUTPUT_DIRECTORY="./output"
RANDOM_STATE=42
TEST_SIZE=0.2

FEATURES = [
    "age",
    "gender", 
    "smoking_status",
    "bmi",
    "heart_rate",
    "total_cholesterol",
    "hdl_cholesterol",
    "fasting_glucose",
    "creatinine",
    "chol_ratio",
    # "avg_sleep_hours",
    # "stress_level",
    # "breathing_rate",
]

STAGE_NAMES = {
    0: "Normal",
    1: "Elevated",
    2: "Stage 1 HTN",
    3: "Stage 2 HTN"
}


def make_output_dirs():
    """
    This creates the model output directory if it doesn't already exist.
    """
    logging.info(f"Creating output directory {OUTPUT_DIRECTORY}")
    os.makedirs(OUTPUT_DIRECTORY, exist_ok=True)
 
   
def load_xpt(filename):
    """
    This loads individual XPT files into a Pandas DataFrame. It will log
    an error when an invalid path is passed in.
    """
    path = os.path.join(DATA_DIRECTORY, filename)
    
    if not os.path.exists(path):
        logging.error(f"{path} is not a valid path, skipping")
        return pd.DataFrame()
        
    df = pd.read_sas(path, format='xport', encoding='utf-8')
    
    output_path = os.path.join(OUTPUT_DIRECTORY, filename.replace('.XPT', '.csv'))
    
    df.to_csv(output_path, index=False)
    logging.info(f"Saved CSV output to: {output_path}")
    
    return df
  
   
def load_xpt_files():
    """
    This attempts to load all NHANES XPT data files. We neatly return this
    data in a dictionary.
    """
    logging.info("Attempting to load all .xpt files")
    
    return {
        "bp": load_xpt("P_BPXO.XPT"), 
        "demo": load_xpt("P_DEMO.XPT"),
        "bmi": load_xpt("P_BMX.XPT"),
        "chol": load_xpt("P_TCHOL.XPT"),
        "hdl": load_xpt("P_HDL.XPT"),
        "glu": load_xpt("P_GLU.XPT"),
        "smoke": load_xpt("P_SMQ.XPT"),
        "kidney": load_xpt("P_BIOPRO.XPT")
    }


def extract_bp(xpt_files):
    """
    This extracts relevant features from the BP file.
    """
    logging.info("Extracting features from Blood Pressure data")
    
    bp = xpt_files["bp"]
    
    # We need to obtain the columns we're interested in, namely systolic
    # and diastolic bp.
    sys_cols = [c for c in ['BPXOSY1','BPXOSY2','BPXOSY3'] if c in bp.columns]
    dia_cols = [c for c in ['BPXODI1','BPXODI2','BPXODI3'] if c in bp.columns]

    # This will obtain average systolic and diastolic bp values for
    # each row.
    df = bp[['SEQN']].copy()
    df['systolic_bp']  = bp[sys_cols].mean(axis=1)
    df['diastolic_bp'] = bp[dia_cols].mean(axis=1)
    df['heart_rate']   = bp['BPXOPLS1'] if 'BPXOPLS1' in bp.columns else np.nan
    
    return df


def extract_demo(df, xpt_files):
    """
    This extracts relevant features from the DEMO file.
    """
    logging.info("Extracting features from Demographics data")
    
    demo = xpt_files['demo']
    if not demo.empty:
        df['age']    = demo.set_index('SEQN')['RIDAGEYR'].reindex(df['SEQN']).values
        df['gender'] = demo.set_index('SEQN')['RIAGENDR'].reindex(df['SEQN']).map({1:0, 2:1}).values

    return df
    
    
def extract_bmi(df, xpt_files):
    """
    This extracts relevant features from the BMI file.
    """
    logging.info("Extracting features from BMI data")
    
    bmi = xpt_files['bmi']
    if not bmi.empty and 'BMXBMI' in bmi.columns:
        df['bmi'] = bmi.set_index('SEQN')['BMXBMI'].reindex(df['SEQN']).values
    
    return df
    
    
def extract_total_chol(df, xpt_files):
    """
    This extracts relevant features from the TOTAL CHOL file.
    """
    logging.info("Extracting features from Total Cholesterol data")
    
    chol = xpt_files['chol']
    if not chol.empty and 'LBXTC' in chol.columns:
        df['total_cholesterol'] = chol.set_index('SEQN')['LBXTC'].reindex(df['SEQN']).values
    
    return df


def extract_high_chol(df, xpt_files):
    """
    This extracts relevant features from the HIGH CHOL file.
    """
    logging.info("Extracting features from High Cholesterol data")
    
    hdl = xpt_files['hdl']
    if not hdl.empty and 'LBDHDD' in hdl.columns:
        df['hdl_cholesterol'] = hdl.set_index('SEQN')['LBDHDD'].reindex(df['SEQN']).values
    
    return df
        
        
def extract_glucose(df, xpt_files):
    """
    This extracts relevant features from the Glucose file.
    """
    logging.info("Extracting features from Glucose data")
    
    glu = xpt_files['glu']
    if not glu.empty and 'LBXGLU' in glu.columns:
        df['fasting_glucose'] = glu.set_index('SEQN')['LBXGLU'].reindex(df['SEQN']).values
 
    return df 
    
    
def extract_smoking(df, xpt_files):
    """
    This extracts relevant features from the Smoking file.
    """
    logging.info("Extracting features from Smoking data")
   
    smoke = xpt_files['smoke']
    smoke = smoke.set_index('SEQN')
    
    def recode(row):
        ever = row.get('SMQ020', np.nan)
        now  = row.get('SMQ040', np.nan)
        if pd.isna(ever): return np.nan
        # Here we just encode smoking status
        # 0: Never smoked
        # 1: Current smoker
        # 2: Former smoker
        if ever == 2: return 0
        if now in [1, 2]: return 2
        return 1                 
        
    df['smoking_status'] = smoke.apply(recode, axis=1).reindex(df['SEQN']).values

    return df


def extract_kidney(df, xpt_files):
    """
    This extracts relevant features from the Kidney file.
    """
    logging.info("Extracting features from Kidney data")
    
    kidney = xpt_files['kidney']
    if not kidney.empty and 'LBXSCR' in kidney.columns:
        df['creatinine'] = kidney.set_index('SEQN')['LBXSCR'].reindex(df['SEQN']).values
        
    return df

   
def build_dataset(xpt_files):
    """
    This combines relevant features into a coherent dataset.
    """
    logging.info("")
    
    bp_df = extract_bp(xpt_files)
    
    demo_df = extract_demo(bp_df, xpt_files)
    bmi_df = extract_bmi(demo_df, xpt_files)
    total_chol_df = extract_total_chol(bmi_df, xpt_files)
    high_chol_df = extract_high_chol(total_chol_df, xpt_files)
    glucose_df = extract_glucose(high_chol_df, xpt_files)
    smoking_df = extract_smoking(glucose_df, xpt_files)
    kidney_df = extract_kidney(smoking_df, xpt_files)
    
    # We can compute derived features
    df = kidney_df
    
    df['pulse_pressure'] = df['systolic_bp'] - df['diastolic_bp']
    df['map']            = df['diastolic_bp'] + (df['pulse_pressure'] / 3)
    df['chol_ratio']     = df['total_cholesterol'] / df['hdl_cholesterol'].replace(0, np.nan) 
    
    logging.info("Finished building dataset")
    print("\n\n", df, "\n\n")
    
    return df
    
    
def label_hypertension_stages(df, save=False):
    """
    This adds a hypertension stage label to our dataset.
    
    For reference, ACC/AHA 2017 Guidelines:
        0 - Normal:   Systolic < 120
        1 - Elevated: Systolic 120-129
        2 - Stage 1:  Systolic 130-139
        3 - Stage 2:  Systolic > 140
    """
    logging.info("Labeling hypertension stages")
    
    def classify(row):
        systolic, diastolic = row['systolic_bp'], row['diastolic_bp']
        
        # This should not happen
        if pd.isna(systolic) or pd.isna(diastolic): 
            return np.nan
            
        if systolic >= 140 or diastolic >= 90:
            return 3
            
        if systolic >= 130 or diastolic >= 80:  
            return 2
            
        if 120 <= systolic < 130 and diastolic < 80: 
            return 1 
        
        return 0
          
    df['hypertension_stage'] = df.apply(classify, axis=1)
    df = df.dropna(subset=['hypertension_stage'])
    df['hypertension_stage'] = df['hypertension_stage'].astype(int)  
    
    if (save):
        path = f"{OUTPUT_DIRECTORY}/combined_dataset.csv"
        df.to_csv(path, index=False)
        logging.info(f"Dataset saved to: {path}")
        
    return df


def train(df):
    """
    This trains an XGBoost classifier model on our dataset
    """
    logging.info("Beginning model training")
    
    X = df[FEATURES]
    y = df["hypertension_stage"]
    
    # Here, we split our dataset into train and test set, with stratified
    # sampling on hypertension.
    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=TEST_SIZE,
        random_state=RANDOM_STATE,
        stratify=y
    )
    
    # This imputer will replace missing values using median data.
    imputer = SimpleImputer(strategy='median')
    X_train_imp = imputer.fit_transform(X_train)
    X_test_imp  = imputer.transform(X_test)
    
    param_grid = {
        'n_estimators': [200, 300, 400],
        'max_depth': [4, 6, 8],
        'learning_rate': [0.01, 0.05, 0.1],
        'min_child_weight': [3, 5, 7],
        'subsample': [0.7, 0.8],
        'colsample_bytree': [0.7, 0.8],
    }
  
    # Extreme Gradient Boosting (XGBoost)
    # 
    # We are using decision trees as our base learners, then we combine
    # them sequentially to improve performance.
    # Each decision tree is trained on the mistakes of the previous learner trees.
    # 
    # We use multi-class soft-max as the objective function.
    # We are also predicting 4 hypertension classes.
    # Each decision tree may grow to a max depth of 6, with a learning rate at 0.05.
    # 
    # Each tree may only use 80% of samples and training rows, to prevent over-fitting.
    # 
    # Alpha (L1 / Lasso) and Lambda (L2 / Ridge) regularization are used to improve model accuracy.
    # L1 will push small weights towards 0, L2 will punish large weights.
    # 
    # Logarithmic loss as the performance metric.
    # 
    # Finally we set n_job to -1 to utilize all CPU cores.
    xgb_model = xgb.XGBClassifier(
        objective='multi:softprob',
        num_class=4,
        reg_alpha=0.1,
        reg_lambda=1.0,
        gamma=0.1,
        eval_metric='mlogloss',
        random_state=RANDOM_STATE,
        n_jobs=-1
    )
    
    grid_search = GridSearchCV(
        estimator=xgb_model,
        param_grid=param_grid,
        scoring='roc_auc_ovr_weighted',
        cv=5,
        verbose=2,
        n_jobs=-1
    )
    
    grid_search.fit(X_train_imp, y_train)
    
    logging.info(f"Best params: {grid_search.best_params_}")
    logging.info(f"Best CV AUC: {grid_search.best_score_:.4f}")
    
    xgb_model = grid_search.best_estimator_
    
    return xgb_model, imputer, X_test, y_test


def evaluate(model, X_test, y_test):
    """
    This evaluates the trained XGBoost model and prints performance results.
    """
    logging.info("Evaluating XGBoost model on test dataset")
    
    y_pred = model.predict(X_test)
    y_prob = model.predict_proba(X_test)
   
    # This is print classification report for the model
    print(classification_report(
        y_test, y_pred,
        target_names=[STAGE_NAMES[i] for i in range(4)]
    ))
    
    print(f"\nAccuracy: {accuracy_score(y_test, y_pred):.4f}")
    
    # This computes area under receiver operator characteristic
    # Plotting True Positive to False Positive rates
    auc = roc_auc_score(y_test, y_prob, multi_class='ovr', average='weighted')
    print(f"\nAUC: {auc:.4f}")
    
    output_path = f"{OUTPUT_DIRECTORY}/images"
    os.makedirs(output_path, exist_ok=True)
    
    cm = confusion_matrix(y_test, y_pred)
    plt.figure(figsize=(8, 6))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', xticklabels=STAGE_NAMES.values(), yticklabels=STAGE_NAMES.values())
    plt.title('Confusion Matrix')
    plt.ylabel('True'); plt.xlabel('Predicted')
    plt.tight_layout()
    plt.savefig(f"{output_path}/confusion_matrix.png", dpi=150)
    plt.close()

    importance = pd.Series(model.feature_importances_, index=model.get_booster().feature_names).sort_values(ascending=False)
    plt.figure(figsize=(10, 6))
    importance.plot(kind='bar', color='steelblue')
    plt.title('Feature Importances')
    plt.ylabel('Score')
    plt.xticks(rotation=45, ha='right')
    plt.tight_layout()
    plt.savefig(f"{output_path}/feature_importance.png", dpi=150)
    plt.close()

    print(f"\n  Plots saved to {OUTPUT_DIRECTORY}/images")
    
    
def save(model, imputer):
    logging.info("Saving model")
    
    FINAL_OUTPUT_DIRECTORY = f"{OUTPUT_DIRECTORY}/model"
    os.makedirs(FINAL_OUTPUT_DIRECTORY, exist_ok=True)

    model_path   = f"{FINAL_OUTPUT_DIRECTORY}/hypertension_model.json"
    imputer_path = f"{FINAL_OUTPUT_DIRECTORY}/imputer.pkl"
    schema_path  = f"{FINAL_OUTPUT_DIRECTORY}/feature_schema.json"

    model.save_model(model_path)
    joblib.dump(imputer, imputer_path)

    with open(schema_path, 'w') as f:
        json.dump({
            "features": FEATURES,
            "stages": STAGE_NAMES,
            "phase2_features": [
                "avg_sleep_hours",
                "stress_level",
                "breathing_rate",
            ],
            "notes": {
                "phase2_features": "NaN during Phase 1 training. Pass real values at inference.",
                "lab_features": "total_cholesterol, hdl_cholesterol, fasting_glucose, creatinine are optional, imputed if missing.",
                "bp": "systolic_bp and diastolic_bp should be averages over multiple readings."
            }
        }, f, indent=2)
    

def main():
    make_output_dirs()
    
    xpt_files = load_xpt_files()
    dataset = build_dataset(xpt_files)
    
    df = label_hypertension_stages(dataset, save=True)
    model, imputer, X_test, y_test = train(df)
    
    evaluate(model, X_test, y_test)
    save(model, imputer)


main()
