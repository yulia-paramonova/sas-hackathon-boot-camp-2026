"""
Step 2: Data Preparation (Python)
==================================
Load, profile, and join the four PremierBank datasets into an
Analytical Base Table (ABT) for loan default prediction.

Run this script in a Python session inside SAS Viya Workbench.

Outputs:
  - data/financial_services_abt.csv
  - Console: data cards, summary statistics, default distribution
"""

import pandas as pd
import numpy as np
import os

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
DATA_DIR = SAS.symget('_USERHOME') + '/sas-hackathon-boot-camp-2026/use-case-financial-services/data'
OUTPUT_PATH = os.path.join(DATA_DIR, 'financial_services_abt.csv')

# ============================================================================
# 1. LOAD THE DATA
# ============================================================================
print("=" * 70)
print("STEP 2: DATA PREPARATION  (Python)")
print("=" * 70)

loan_applications = pd.read_csv(os.path.join(DATA_DIR, 'loan_applications.csv'))
credit_history    = pd.read_csv(os.path.join(DATA_DIR, 'credit_history.csv'))
employment        = pd.read_csv(os.path.join(DATA_DIR, 'employment.csv'))
payment_history   = pd.read_csv(os.path.join(DATA_DIR, 'payment_history.csv'))

print("\n--- Loaded Datasets ---")
print(f"  loan_applications: {loan_applications.shape[0]:>6,} rows x {loan_applications.shape[1]} cols")
print(f"  credit_history:    {credit_history.shape[0]:>6,} rows x {credit_history.shape[1]} cols")
print(f"  employment:        {employment.shape[0]:>6,} rows x {employment.shape[1]} cols")
print(f"  payment_history:   {payment_history.shape[0]:>6,} rows x {payment_history.shape[1]} cols")

# ============================================================================
# 2. DATA CARD — one per table
# ============================================================================
def print_data_card(name, df):
    """Print a concise data card for a DataFrame."""
    print(f"\n{'─' * 70}")
    print(f"DATA CARD: {name}")
    print(f"{'─' * 70}")
    print(f"  Rows: {len(df):,}    Columns: {len(df.columns)}")
    print(f"\n  {'Column':<30} {'Dtype':<12} {'Missing':>8}")
    print(f"  {'─'*30} {'─'*12} {'─'*8}")
    for col in df.columns:
        print(f"  {col:<30} {str(df[col].dtype):<12} {df[col].isna().sum():>8}")
    print(f"\n  Sample rows (first 3):")
    print(df.head(3).to_string(index=False, max_colwidth=20))

print("\n" + "=" * 70)
print("DATA CARDS")
print("=" * 70)

print_data_card("loan_applications.csv", loan_applications)
print_data_card("credit_history.csv", credit_history)
print_data_card("employment.csv", employment)
print_data_card("payment_history.csv", payment_history)

# ============================================================================
# 3. BASIC SUMMARY STATISTICS
# ============================================================================
print("\n" + "=" * 70)
print("SUMMARY STATISTICS")
print("=" * 70)

for name, df in [("loan_applications", loan_applications),
                 ("credit_history", credit_history),
                 ("employment", employment),
                 ("payment_history", payment_history)]:
    numeric_cols = df.select_dtypes(include='number').columns.tolist()
    if numeric_cols:
        print(f"\n--- {name} (numeric columns) ---")
        print(df[numeric_cols].describe().round(2).to_string())

    cat_cols = df.select_dtypes(include='object').columns.tolist()
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

loan_applications['application_date'] = pd.to_datetime(
    loan_applications['application_date'], errors='coerce')
payment_history['payment_date'] = pd.to_datetime(
    payment_history['payment_date'], errors='coerce')

loan_applications['defaulted'] = loan_applications['defaulted'].astype(int)

# Validate loan_id consistency
valid_ids = set(loan_applications['loan_id'])
credit_history  = credit_history[credit_history['loan_id'].isin(valid_ids)]
employment      = employment[employment['loan_id'].isin(valid_ids)]
payment_history = payment_history[payment_history['loan_id'].isin(valid_ids)]

print("  Date columns parsed, IDs validated.")

# ============================================================================
# 5. FEATURE ENGINEERING
# ============================================================================
print("\n" + "=" * 70)
print("FEATURE ENGINEERING")
print("=" * 70)

# --- Payment behavior features ---------------------------------------------
pmt = payment_history.groupby('loan_id').agg(
    total_payments=('payment_id', 'count'),
    late_payment_count=('days_late', lambda x: (x > 0).sum()),
    severe_delinquency_count=('days_late', lambda x: (x >= 60).sum()),
    avg_days_late=('days_late', 'mean'),
    max_days_late=('days_late', 'max'),
    total_shortfall=('amount_due', lambda x: np.maximum(
        (x - payment_history.loc[x.index, 'amount_paid']).sum(), 0)),
).reset_index()

# Compute additional payment metrics
pmt_on_time = payment_history[payment_history['payment_status'] == 'On Time'].groupby(
    'loan_id').size().reset_index(name='on_time_count')
pmt = pmt.merge(pmt_on_time, on='loan_id', how='left')
pmt['on_time_count'] = pmt['on_time_count'].fillna(0).astype(int)

pmt['late_payment_rate'] = np.where(
    pmt['total_payments'] > 0,
    pmt['late_payment_count'] / pmt['total_payments'], 0)
pmt['on_time_rate'] = np.where(
    pmt['total_payments'] > 0,
    pmt['on_time_count'] / pmt['total_payments'], 0)
pmt['severe_delinquency_flag'] = (pmt['severe_delinquency_count'] > 0).astype(int)

# Average shortfall ratio per loan
shortfall = payment_history.copy()
shortfall['shortfall_ratio'] = np.where(
    shortfall['amount_due'] > 0,
    (shortfall['amount_due'] - shortfall['amount_paid']) / shortfall['amount_due'], 0)
avg_shortfall = shortfall.groupby('loan_id')['shortfall_ratio'].mean().reset_index(
    name='avg_shortfall_ratio')
pmt = pmt.merge(avg_shortfall, on='loan_id', how='left')
pmt['avg_shortfall_ratio'] = pmt['avg_shortfall_ratio'].fillna(0)

print(f"  Payment behavior features: {len(pmt.columns) - 1}")

# --- Credit features -------------------------------------------------------
credit = credit_history.copy()

# FICO score bands
credit['fico_band'] = pd.cut(
    credit['credit_score'],
    bins=[0, 599, 649, 699, 749, 850],
    labels=['Very Poor', 'Poor', 'Fair', 'Good', 'Excellent'])

# Credit utilization category
credit['utilization_cat'] = pd.cut(
    credit['credit_utilization'],
    bins=[-0.01, 0.30, 0.50, 0.75, 1.01],
    labels=['Low', 'Moderate', 'High', 'Very High'])

# Derived flags
credit['has_bankruptcy'] = (credit['bankruptcies'] > 0).astype(int)
credit['has_delinquency'] = (credit['delinquencies_2yr'] > 0).astype(int)
credit['high_inquiries'] = (credit['inquiries_6mo'] >= 3).astype(int)

print(f"  Credit features:           {len(credit.columns) - 1}")

# --- Employment features ---------------------------------------------------
emp = employment.copy()

# Debt service ratio
emp['debt_service_ratio'] = np.where(
    emp['annual_income'] > 0,
    (emp['monthly_debt'] * 12) / emp['annual_income'], 0)

# Income bands
emp['income_band'] = pd.cut(
    emp['annual_income'],
    bins=[0, 34999, 59999, 99999, float('inf')],
    labels=['Low', 'Low-Middle', 'Middle', 'High'])

# Years employed bands
emp['tenure_band'] = pd.cut(
    emp['years_employed'],
    bins=[-0.01, 1.99, 4.99, 9.99, float('inf')],
    labels=['New', 'Developing', 'Established', 'Veteran'])

print(f"  Employment features:       {len(emp.columns) - 1}")

# ============================================================================
# 6. BUILD THE ANALYTICAL BASE TABLE
# ============================================================================
print("\n" + "=" * 70)
print("BUILDING ANALYTICAL BASE TABLE")
print("=" * 70)

abt = loan_applications.copy()
abt.drop(columns=['application_date'], inplace=True)

abt = abt.merge(credit, on='loan_id', how='left')
abt = abt.merge(emp, on='loan_id', how='left')
abt = abt.merge(pmt, on='loan_id', how='left')

# Fill missing payment features
pmt_cols = [c for c in pmt.columns if c != 'loan_id']
for col in pmt_cols:
    abt[col] = abt[col].fillna(0)

# Fill missing debt_service_ratio
abt['debt_service_ratio'] = abt['debt_service_ratio'].fillna(0)

# One-hot encode categoricals
abt = pd.get_dummies(abt, columns=[
    'loan_purpose', 'property_type', 'employment_status', 'employer_type',
    'fico_band', 'utilization_cat', 'income_band', 'tenure_band'
], prefix=[
    'purpose', 'prop', 'emp', 'emplr',
    'fico', 'util', 'inc', 'ten'
])

# Convert boolean dummy columns to int
bool_cols = abt.select_dtypes(include='bool').columns
abt[bool_cols] = abt[bool_cols].astype(int)

print(f"  Final ABT shape: {abt.shape[0]:,} rows x {abt.shape[1]} columns")
print(f"  Features: {abt.shape[1] - 2}  (excluding loan_id and defaulted)")

# ============================================================================
# 7. DEFAULT DISTRIBUTION
# ============================================================================
print("\n" + "=" * 70)
print("DEFAULT DISTRIBUTION IN ABT")
print("=" * 70)

default_counts = abt['defaulted'].value_counts()
default_pct = abt['defaulted'].value_counts(normalize=True) * 100
print(f"  Current (0):   {default_counts[0]:>5,}  ({default_pct[0]:.1f}%)")
print(f"  Defaulted (1): {default_counts[1]:>5,}  ({default_pct[1]:.1f}%)")

# ============================================================================
# 8. SAVE
# ============================================================================
abt.to_csv(OUTPUT_PATH, index=False)
print(f"\nAnalytical Base Table saved to: {OUTPUT_PATH}")
print("=" * 70)
print("STEP 2 COMPLETE")
print("=" * 70)
