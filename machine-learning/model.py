from PIL.Image import logger
import pandas as pd
import logging
import os
import warnings

warnings.filterwarnings('ignore')

DATA_DIRECTORY="./NHANES_data"
OUTPUT_DIRECTORY="./output"
RANDOM_STATE=42
TEST_SIZE=0.2

def make_output_dirs():
    os.makedirs(OUTPUT_DIRECTORY, exist_ok=True)
   
   
def load_xpt(filename):
    path = os.path.join(DATA_DIRECTORY, filename)
    
    if not os.path.exists(path):
        logging.error(f"{path} is not a valid path, skipping")
        return pd.DataFrame()
        
    df = pd.read_sas(path, format='xport', encoding='utf-8')
   
   
def load_dataset():
    logger.info("Attempting to load all .xpt files")
    
    bp    = load_xpt("P_BPX.xpt")      # Blood pressure readings
    demo  = load_xpt("P_DEMO.xpt")     # Demographics
    bmi   = load_xpt("P_BMX.xpt")      # Body measures
    chol  = load_xpt("P_TCHOL.xpt")    # Total cholesterol
    hdl   = load_xpt("P_HDL.xpt")      # HDL cholesterol
    glu   = load_xpt("P_GLU.xpt")      # Blood glucose
    smoke = load_xpt("P_SMQ.xpt")      # Smoking
    kidney= load_xpt("P_BIOPRO.xpt")   # Kidney function
    
    logger.info("Loaded datasets")
    
    return bp, demo, bmi, chol, hdl, glu, smoke, kidney
    
    
def train():
   pass
