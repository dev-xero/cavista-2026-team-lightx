import pandas as pd
import logging
import os
import warnings

warnings.filterwarnings('ignore')
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

DATA_DIRECTORY="./NHANES_data"
OUTPUT_DIRECTORY="./output"
RANDOM_STATE=42
TEST_SIZE=0.2


def make_output_dirs():
    logging.info("Creating output directory")
    os.makedirs(OUTPUT_DIRECTORY, exist_ok=True)
   
   
def load_xpt(filename):
    path = os.path.join(DATA_DIRECTORY, filename)
    
    if not os.path.exists(path):
        logging.error(f"{path} is not a valid path, skipping")
        return pd.DataFrame()
        
    df = pd.read_sas(path, format='xport', encoding='utf-8')
    return df
   
   
def load_dataset():
    logging.info("Attempting to load all .xpt files")
    
    bp    = load_xpt("P_BPXO.XPT")     # Blood pressure readings
    demo  = load_xpt("P_DEMO.XPT")     # Demographics
    bmi   = load_xpt("P_BMX.XPT")      # Body measures
    chol  = load_xpt("P_TCHOL.XPT")    # Total cholesterol
    hdl   = load_xpt("P_HDL.XPT")      # HDL cholesterol
    glu   = load_xpt("P_GLU.XPT")      # Blood glucose
    smoke = load_xpt("P_SMQ.XPT")      # Smoking
    kidney= load_xpt("P_BIOPRO.XPT")   # Kidney function
    
    logging.info("Loaded datasets")
    
    return bp, demo, bmi, chol, hdl, glu, smoke, kidney
    

def combine_datasets(bp, demo, bmi, chol, hdl, glu, smoke, kidney):
    logging.info("Attempting to combine all datasets")
    
    if not bp.empty:
        logging.info("Loading blood pressure")
        
        bp_cols_sys = [c for c in ['BPXSY1','BPXSY2','BPXSY3'] if c in bp.columns]
        bp_cols_dia = [c for c in ['BPXDI1','BPXDI2','BPXDI3'] if c in bp.columns]
        
        bp['SYSTOLIC']  = bp[bp_cols_sys].mean(axis=1)
        bp['DIASTOLIC'] = bp[bp_cols_dia].mean(axis=1)
        bp = bp[['SEQN', 'SYSTOLIC', 'DIASTOLIC']]
        
        print(demo, "\n\n")
    
    if not demo.empty:
        logging.info("Loading Demographic dataset")
        demo = demo[['SEQN', 'RIDAGEYR', 'RIAGENDR', 'RIDRETH3']].rename(columns={
            'RIDAGEYR': 'AGE',
            'RIAGENDR': 'GENDER',
            'RIDRETH3': 'ETHNICITY'
        })
        print(demo, "\n\n")
    
    if not bmi.empty:
        logging.info("Loading BMI dataset")
        bmi = bmi[['SEQN', 'BMXBMI', 'BMXWAIST']].rename(columns={
            'BMXBMI':   'BMI',
            'BMXWAIST': 'WAIST_CM'
        })
        print(bmi, "\n\n")
        
    if not chol.empty:
        logging.info("Loading Total Cholesterol dataset")
        chol = chol[['SEQN', 'LBXTC']].rename(columns={'LBXTC': 'TOTAL_CHOLESTEROL'})
        print(chol, "\n\n")

    if not hdl.empty:
        logging.info("Loading HDL Cholesterol dataset")
        hdl = hdl[['SEQN', 'LBDHDD']].rename(columns={'LBDHDD': 'HDL_CHOLESTEROL'})
        print(hdl, "\n\n")

    if not glu.empty:
        logging.info("Loading Glucose dataset")
        glu = glu[['SEQN', 'LBXGLU']].rename(columns={'LBXGLU': 'FASTING_GLUCOSE'})
        print( glu, "\n\n")

    if not smoke.empty and 'SMQ020' in smoke.columns:
        logging.info("Loading Smoking dataset")
        smoke = smoke[['SEQN', 'SMQ020']].rename(columns={'SMQ020': 'EVER_SMOKED'})
        # This just encodes smoking data, 1=YES, 2=NO
        smoke['EVER_SMOKED'] = smoke['EVER_SMOKED'].map({1: 1, 2: 0})
        print(smoke, "\n\n")

    if not kidney.empty and 'LBXSCR' in kidney.columns:
        logging.info("Loading Kidney dataset")
        kidney = kidney[['SEQN', 'LBXSCR']].rename(columns={'LBXSCR': 'CREATININE'})
        print(kidney, "\n\n")

    dfs = [df for df in [bp, demo, bmi, chol, hdl, glu, smoke, kidney] if not df.empty]
    
    merged = dfs[0]
    for df in dfs[1:]:
        merged = merged.merge(df, on='SEQN', how='left')
        
    logging.info("\n\nCombined all datasets")
    print(merged, "\n\n")
    
    return merged
    

def train():
   pass


def main():
    make_output_dirs()
    bp, demo, bmi, chol, hdl, glu, smoke, kidney = load_dataset()
    combine_datasets(bp, demo, bmi, chol, hdl, glu, smoke, kidney)


main()
