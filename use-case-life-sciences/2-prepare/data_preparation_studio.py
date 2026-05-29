"""
Step 2: Data Preparation (Python)
==================================
Load, profile, and join the four MedCare datasets into an
Analytical Base Table (ABT) for patient readmission prediction.

Run this script in a Python session inside SAS Studio.

Outputs:
  - data/life_sciences_abt.csv
  - Console: data cards, summary statistics, readmission distribution
"""

import pandas as pd
import numpy as np
import os

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
DATA_DIR = SAS.symget('_USERHOME') + '/sas-hackathon-boot-camp-2026/use-case-life-sciences/data'
OUTPUT_PATH = os.path.join(DATA_DIR, 'life_sciences_abt.csv')

# ============================================================================
# 1. LOAD THE DATA
# ============================================================================
print("=" * 70)
print("STEP 2: DATA PREPARATION  (Python)")
print("=" * 70)

patients         = pd.read_csv(os.path.join(DATA_DIR, 'patients.csv'))
admissions       = pd.read_csv(os.path.join(DATA_DIR, 'admissions.csv'))
clinical_measures = pd.read_csv(os.path.join(DATA_DIR, 'clinical_measures.csv'))
medications      = pd.read_csv(os.path.join(DATA_DIR, 'medications.csv'))

print("\n--- Loaded Datasets ---")
print(f"  patients:          {patients.shape[0]:>6,} rows x {patients.shape[1]} cols")
print(f"  admissions:        {admissions.shape[0]:>6,} rows x {admissions.shape[1]} cols")
print(f"  clinical_measures: {clinical_measures.shape[0]:>6,} rows x {clinical_measures.shape[1]} cols")
print(f"  medications:       {medications.shape[0]:>6,} rows x {medications.shape[1]} cols")

# ============================================================================
# 2. DATA CARD — one per table
# ============================================================================
def print_data_card(name, df):
    """Print a concise data card for a DataFrame."""
    print(f"\n{'─' * 70}")
    print(f"DATA CARD: {name}")
    print(f"{'─' * 70}")
    print(f"  Rows: {len(df):,}    Columns: {len(df.columns)}")
    print(f"\n  {'Column':<35} {'Dtype':<12} {'Missing':>8}")
    print(f"  {'─'*35} {'─'*12} {'─'*8}")
    for col in df.columns:
        print(f"  {col:<35} {str(df[col].dtype):<12} {df[col].isna().sum():>8}")
    print(f"\n  Sample rows (first 3):")
    print(df.head(3).to_string(index=False, max_colwidth=20))

print("\n" + "=" * 70)
print("DATA CARDS")
print("=" * 70)

print_data_card("patients.csv", patients)
print_data_card("admissions.csv", admissions)
print_data_card("clinical_measures.csv", clinical_measures)
print_data_card("medications.csv", medications)

# ============================================================================
# 3. BASIC SUMMARY STATISTICS
# ============================================================================
print("\n" + "=" * 70)
print("SUMMARY STATISTICS")
print("=" * 70)

for name, df in [("patients", patients), ("admissions", admissions),
                  ("clinical_measures", clinical_measures), ("medications", medications)]:
    numeric_cols = df.select_dtypes(include='number').columns.tolist()
    if numeric_cols:
        print(f"\n--- {name} (numeric columns) ---")
        print(df[numeric_cols].describe().round(2).to_string())

    cat_cols = df.select_dtypes(include='object').columns.tolist()
    # Exclude ID and date columns from frequency counts
    cat_cols = [c for c in cat_cols if not c.endswith('_id') and 'date' not in c.lower()]
    if cat_cols:
        print(f"\n--- {name} (categorical frequencies) ---")
        for col in cat_cols:
            print(f"\n  {col}:")
            print(df[col].value_counts().head(10).to_string())

# ============================================================================
# 4. CLEAN & PARSE DATES
# ============================================================================
print("\n" + "=" * 70)
print("DATA CLEANING")
print("=" * 70)

patients['admission_date'] = pd.to_datetime(patients['admission_date'])
admissions['admission_date'] = pd.to_datetime(admissions['admission_date'])
admissions['discharge_date'] = pd.to_datetime(admissions['discharge_date'])
medications['start_date'] = pd.to_datetime(medications['start_date'], errors='coerce')
medications['end_date'] = pd.to_datetime(medications['end_date'], errors='coerce')

# Keep only records for valid patients
valid_ids = set(patients['patient_id'])
admissions = admissions[admissions['patient_id'].isin(valid_ids)]
clinical_measures = clinical_measures[clinical_measures['patient_id'].isin(valid_ids)]
medications = medications[medications['patient_id'].isin(valid_ids)]

print("  Date columns parsed, IDs validated.")

# ============================================================================
# 5. FEATURE ENGINEERING
# ============================================================================
print("\n" + "=" * 70)
print("FEATURE ENGINEERING")
print("=" * 70)

# --- Medication features ---------------------------------------------------
med = medications.groupby('patient_id').agg(
    medication_count=('medication_id', 'count'),
    high_risk_med_count=('high_risk_flag', 'sum'),
    unique_med_classes=('medication_class', 'nunique')
).reset_index()

med['polypharmacy_flag'] = (med['medication_count'] >= 5).astype(int)
print(f"  Medication features: {len(med.columns) - 1}")

# --- Clinical features -----------------------------------------------------
clin = clinical_measures.copy()

# BMI categories
clin['bmi_category'] = pd.cut(
    clin['bmi'],
    bins=[0, 18.5, 25, 30, 100],
    labels=['Underweight', 'Normal', 'Overweight', 'Obese'],
    right=False
)

# Blood pressure classification (ACC/AHA)
def classify_bp(row):
    sbp = row['blood_pressure_systolic']
    dbp = row['blood_pressure_diastolic']
    if sbp < 120 and dbp < 80:
        return 'Normal'
    elif sbp < 130 and dbp < 80:
        return 'Elevated'
    elif sbp < 140 or dbp < 90:
        return 'Hypertension_S1'
    else:
        return 'Hypertension_S2'

clin['bp_classification'] = clin.apply(classify_bp, axis=1)

# Glucose categories
clin['glucose_category'] = pd.cut(
    clin['glucose_level'],
    bins=[0, 100, 126, 1000],
    labels=['Normal', 'Prediabetic', 'Diabetic'],
    right=False
)

# Lab results as numeric
clin['lab_abnormal'] = (clin['lab_results_flag'] == 'Abnormal').astype(int)

# Clinical risk score
clin['clinical_risk_score'] = (
    ((clin['bmi'] >= 30) | (clin['bmi'] < 18.5)).astype(int) +
    ((clin['blood_pressure_systolic'] >= 140) | (clin['blood_pressure_diastolic'] >= 90)).astype(int) +
    (clin['glucose_level'] >= 126).astype(int) +
    clin['lab_abnormal']
)
print(f"  Clinical features:   {len(clin.columns) - len(clinical_measures.columns)}")

# --- Admission features ----------------------------------------------------
adm = admissions.copy()

# LOS categories
adm['los_category'] = pd.cut(
    adm['length_of_stay'],
    bins=[0, 2, 5, 100],
    labels=['Short', 'Medium', 'Long'],
    right=True
)

# Emergency flag
adm['emergency_flag'] = (adm['admission_type'] == 'Emergency').astype(int)

# Discharge disposition encoding
adm['discharged_home'] = (adm['discharge_disposition'] == 'Home').astype(int)
adm['discharged_snf'] = (adm['discharge_disposition'] == 'SNF').astype(int)
adm['discharged_home_health'] = (adm['discharge_disposition'] == 'Home Health').astype(int)

adm_features = adm[['patient_id', 'length_of_stay', 'los_category',
                     'emergency_flag', 'discharged_home', 'discharged_snf',
                     'discharged_home_health']]
print(f"  Admission features:  {len(adm_features.columns) - 1}")

# ============================================================================
# 6. BUILD THE ANALYTICAL BASE TABLE
# ============================================================================
print("\n" + "=" * 70)
print("BUILDING ANALYTICAL BASE TABLE")
print("=" * 70)

abt = patients.copy()

# Merge all feature tables
abt = abt.merge(adm_features, on='patient_id', how='left')
abt = abt.merge(
    clin[['patient_id', 'bmi', 'blood_pressure_systolic', 'blood_pressure_diastolic',
          'glucose_level', 'lab_abnormal', 'bmi_category', 'bp_classification',
          'glucose_category', 'clinical_risk_score']],
    on='patient_id', how='left'
)
abt = abt.merge(med, on='patient_id', how='left')

# Fill missing values for patients with no medication records
for col in ['medication_count', 'high_risk_med_count', 'unique_med_classes', 'polypharmacy_flag']:
    abt[col] = abt[col].fillna(0).astype(int)

# Fill any other missing numerics
numeric_fill = ['length_of_stay', 'emergency_flag', 'discharged_home',
                'discharged_snf', 'discharged_home_health', 'bmi',
                'blood_pressure_systolic', 'blood_pressure_diastolic',
                'glucose_level', 'lab_abnormal', 'clinical_risk_score']
for col in numeric_fill:
    if col in abt.columns:
        abt[col] = abt[col].fillna(0)

# One-hot encode categoricals
abt = pd.get_dummies(abt, columns=['gender'], prefix=['gender'])
abt = pd.get_dummies(abt, columns=['insurance_type'], prefix=['ins'])
abt = pd.get_dummies(abt, columns=['los_category'], prefix=['los'])
abt = pd.get_dummies(abt, columns=['bmi_category'], prefix=['bmi'])
abt = pd.get_dummies(abt, columns=['bp_classification'], prefix=['bp'])
abt = pd.get_dummies(abt, columns=['glucose_category'], prefix=['gluc'])

# Drop columns not needed for modeling
abt.drop(columns=['admission_date', 'primary_diagnosis_category'], inplace=True)

print(f"  Final ABT shape: {abt.shape[0]:,} rows x {abt.shape[1]} columns")
print(f"  Features: {abt.shape[1] - 2}  (excluding patient_id and readmitted_30days)")

# ============================================================================
# 7. READMISSION DISTRIBUTION
# ============================================================================
print("\n" + "=" * 70)
print("READMISSION DISTRIBUTION IN ABT")
print("=" * 70)

readmit_counts = abt['readmitted_30days'].value_counts()
readmit_pct = abt['readmitted_30days'].value_counts(normalize=True) * 100
print(f"  Not readmitted (0): {readmit_counts[0]:>5,}  ({readmit_pct[0]:.1f}%)")
print(f"  Readmitted (1):     {readmit_counts[1]:>5,}  ({readmit_pct[1]:.1f}%)")

# ============================================================================
# 8. SAVE
# ============================================================================
abt.to_csv(OUTPUT_PATH, index=False)
print(f"\nAnalytical Base Table saved to: {OUTPUT_PATH}")
print("=" * 70)
print("STEP 2 COMPLETE")
print("=" * 70)
