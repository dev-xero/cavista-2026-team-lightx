# Machine Learning Module

This module implements a multi-class classifier using XGBoost with the National Health And Nutrition Examination survey (NHANES) dataset.

## Architecture



## Required Packages

- [xgboost](https://pypi.org/project/xgboost/): XGBoost Python Package.
- [Numpy](https://pypi.org/project/numpy/): Fundamental package for array computing in Python.
- [Pandas](https://pypi.org/project/pandas/): Powerful data structures for data analysis, time series, and statistics.
- [Scikit-Learn](https://pypi.org/project/scikit-learn/): A set of python modules for machine learning and data mining.
- [Matplotlib](https://pypi.org/project/matplotlib/): Python plotting package.
- [Seaborn](https://pypi.org/project/seaborn/): Statistical data visualization.
- [PyreadStat](https://pypi.org/project/pyreadstat/): Python package to read and write SAS, SPSS and Stata (dta) files from pandas and polars data frames.

## Downloading the Datasets

The National Health and Nutrition Examination Survey (NHANES) collects data about the health of adults and children. We can obtain the following data sources in XPT format:

| Dataset Name | Detail |
| :-          | :-     |
| Blood Pressure | Systolic and diastolic blood pressure |
| Demographics | Demographics data such as age and gender |
| Body Measures | Body measures such as Body Mass Index |
| Total Cholesterol | Total cholesterol levels |
| Blood Glucose | Respondent blood sugar levels |
| Diabetes | Respondent diabetes status (diabetic, not diabetic) |
| Smoking | Respondent smoking status (never smoked, previous smoker, current smoker) |
| Kidney Function | Creatine effects on kidney function |

This data is eventually combined into a single cohesive data set with computed/derived features.

## Local Setup

1. We use `uv` as our package manager, ensure `uv` is setup correctly. To install required packages, use the command below:
  ```sh
  uv add -r requirements.txt
  ```
2. On MacOS, OpenMP must be installed in order to use the `xgboost` library, run:
  ```sh
  brew install libomp on MacOS
  ```
3. Create and setup the Python virtual environment:
  ```sh
  python3 -m venv .venv
  source ./venv/bin/activate
  ```
4. Train the Multi-class XGBoost Classifier Model
  ```sh
  python3 train.py
  ```

## Fair Use Policy (NHANES)

(authorization)
