from PIL.Image import logger
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
    logger.info("Creating output directory")
    os.makedirs(OUTPUT_DIRECTORY, exist_ok=True)
   
   
def load_xpt(filename):
    path = os.path.join(DATA_DIRECTORY, filename)
    
    if not os.path.exists(path):
        logging.error(f"{path} is not a valid path, skipping")
        return pd.DataFrame()
        
    df = pd.read_sas(path, format='xport', encoding='utf-8')
    return df
   
   
def load_dataset():
    logger.info("Attempting to load all .xpt files")
    
    bp    = load_xpt("P_BPXO.XPT")     # Blood pressure readings
    demo  = load_xpt("P_DEMO.XPT")     # Demographics
    bmi   = load_xpt("P_BMX.XPT")      # Body measures
    chol  = load_xpt("P_TCHOL.XPT")    # Total cholesterol
    hdl   = load_xpt("P_HDL.XPT")      # HDL cholesterol
    glu   = load_xpt("P_GLU.XPT")      # Blood glucose
    smoke = load_xpt("P_SMQ.XPT")      # Smoking
    kidney= load_xpt("P_BIOPRO.XPT")   # Kidney function
    
    logger.info("Loaded datasets")
    
    return bp, demo, bmi, chol, hdl, glu, smoke, kidney
    

def combine_datasets(bp, demo, bmi, chol, hdl, glu, smoke, kindey):
    logger.info("Attempting to combine all datasets")
    
    if not bp.empty:
        logger.info("Loading blood pressure")
        
        bp_cols_sys = [c for c in ['BPXSY1','BPXSY2','BPXSY3'] if c in bp.columns]
        bp_cols_dia = [c for c in ['BPXDI1','BPXDI2','BPXDI3'] if c in bp.columns]
        bp['SYSTOLIC']  = bp[bp_cols_sys].mean(axis=1)
        bp['DIASTOLIC'] = bp[bp_cols_dia].mean(axis=1)
        bp = bp[['SEQN', 'SYSTOLIC', 'DIASTOLIC']]
    
    if not demo.empty:
            logger.info("Loading demographic dataset")
            
            demo = demo[['SEQN', 'RIDAGEYR', 'RIAGENDR', 'RIDRETH3']].rename(columns={
                'RIDAGEYR': 'AGE',
                'RIAGENDR': 'GENDER',
                'RIDRETH3': 'ETHNICITY'
            })


def train():
   pass


def main():
    make_output_dirs()
    bp, demo, bmi, chol, hdl, glu, smoke, kidney = load_dataset()
    combine_datasets(bp, demo, bmi, chol, hdl, glu, smoke, kidney)


main()
