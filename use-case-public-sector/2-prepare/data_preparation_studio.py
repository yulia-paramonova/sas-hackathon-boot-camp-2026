"""
Step 2: Data Preparation (Python)
==================================
Load, profile, and join the four Metro City datasets into an
Analytical Base Table (ABT) for service request urgency prediction.

Run this script in a Python session inside SAS Studio.

Outputs:
  - data/public_sector_abt.csv
  - Console: data cards, summary statistics, urgency distribution
"""

import pandas as pd
import numpy as np
import os

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
DATA_DIR = SAS.symget('_USERHOME') + '/sas-hackathon-boot-camp-2026/use-case-public-sector/data'
OUTPUT_PATH = os.path.join(DATA_DIR, 'public_sector_abt.csv')

# Reference date for recency calculations (end of observation period)
REFERENCE_DATE = pd.Timestamp('2024-12-31')

# Request types considered inherently urgent
URGENT_REQUEST_TYPES = [
    'Water Main Break', 'Gas Leak', 'Power Outage',
    'Sewer Backup', 'Traffic Signal Malfunction',
    'Road Hazard', 'Building Emergency'
]

# ============================================================================
# 1. LOAD THE DATA
# ============================================================================
print("=" * 70)
print("STEP 2: DATA PREPARATION  (Python)")
print("=" * 70)

service_requests = pd.read_csv(os.path.join(DATA_DIR, 'service_requests.csv'))
citizens         = pd.read_csv(os.path.join(DATA_DIR, 'citizens.csv'))
dept_perf        = pd.read_csv(os.path.join(DATA_DIR, 'department_performance.csv'))
request_history  = pd.read_csv(os.path.join(DATA_DIR, 'request_history.csv'))

print("\n--- Loaded Datasets ---")
print(f"  service_requests:      {service_requests.shape[0]:>6,} rows x {service_requests.shape[1]} cols")
print(f"  citizens:              {citizens.shape[0]:>6,} rows x {citizens.shape[1]} cols")
print(f"  department_performance:{dept_perf.shape[0]:>6,} rows x {dept_perf.shape[1]} cols")
print(f"  request_history:       {request_history.shape[0]:>6,} rows x {request_history.shape[1]} cols")

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

print_data_card("service_requests.csv", service_requests)
print_data_card("citizens.csv", citizens)
print_data_card("department_performance.csv", dept_perf)
print_data_card("request_history.csv", request_history)

# ============================================================================
# 3. BASIC SUMMARY STATISTICS
# ============================================================================
print("\n" + "=" * 70)
print("SUMMARY STATISTICS")
print("=" * 70)

for name, df in [("service_requests", service_requests), ("citizens", citizens),
                  ("department_performance", dept_perf), ("request_history", request_history)]:
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

service_requests['submission_date'] = pd.to_datetime(service_requests['submission_date'], errors='coerce')
citizens['registration_date']       = pd.to_datetime(citizens['registration_date'], errors='coerce')

service_requests.dropna(subset=['submission_date'], inplace=True)

# Validate citizen_ids
valid_citizen_ids = set(citizens['citizen_id'])
print(f"  Service requests with valid citizen_id: "
      f"{service_requests['citizen_id'].isin(valid_citizen_ids).sum()} / {len(service_requests)}")
print("  Date columns parsed, invalid rows removed.")

# ============================================================================
# 5. FEATURE ENGINEERING
# ============================================================================
print("\n" + "=" * 70)
print("FEATURE ENGINEERING")
print("=" * 70)

# --- Temporal features -----------------------------------------------------
sr = service_requests.copy()
sr['day_of_week']    = sr['submission_date'].dt.dayofweek  # 0=Monday, 6=Sunday
sr['is_weekend']     = sr['day_of_week'].isin([5, 6]).astype(int)
sr['submit_month']   = sr['submission_date'].dt.month
sr['submit_quarter'] = sr['submission_date'].dt.quarter
print(f"  Temporal features: 4")

# --- Request characteristics -----------------------------------------------
sr['inherent_urgency'] = sr['request_type'].isin(URGENT_REQUEST_TYPES).astype(int)

# --- Derive target variable ------------------------------------------------
sr['is_urgent'] = sr['priority_level'].isin(['Critical', 'High']).astype(int)

# --- Convert resolved to numeric -------------------------------------------
sr['resolved_flag'] = sr['resolved'].astype(str).str.strip().str.lower().eq('true').astype(int)
print(f"  Request features: 3 (inherent_urgency, is_urgent target, resolved_flag)")

# --- Department average performance ----------------------------------------
dept_avg = dept_perf.groupby('department').agg(
    dept_avg_response_time     = ('avg_response_time_hours', 'mean'),
    dept_avg_resolution_rate   = ('resolution_rate', 'mean'),
    dept_avg_satisfaction      = ('citizen_satisfaction_avg', 'mean'),
    dept_avg_staff_count       = ('staff_count', 'mean'),
    dept_avg_budget_util       = ('budget_utilization', 'mean'),
    dept_avg_requests_received = ('requests_received', 'mean'),
    dept_avg_overtime          = ('overtime_hours', 'mean')
).reset_index()
print(f"  Department features: {len(dept_avg.columns) - 1}")

# --- District features from request history --------------------------------
district_features = request_history.groupby('district').agg(
    district_avg_request_count    = ('request_count', 'mean'),
    district_avg_response_time    = ('avg_response_time', 'mean'),
    district_avg_resolution_rate  = ('resolution_rate', 'mean'),
    district_total_critical       = ('priority_critical_count', 'sum'),
    district_total_high           = ('priority_high_count', 'sum')
).reset_index()
district_features.rename(columns={'district': 'location_district'}, inplace=True)
print(f"  District features: {len(district_features.columns) - 1}")

# --- Citizen features ------------------------------------------------------
cit = citizens.copy()
cit['account_age_days'] = (REFERENCE_DATE - cit['registration_date']).dt.days
cit['engagement_score'] = np.where(
    cit['previous_requests'] > 0,
    cit['previous_requests'] * cit['satisfaction_history'] / 5,
    0
)
citizen_features = cit[['citizen_id', 'previous_requests', 'satisfaction_history',
                         'age_group', 'contact_preference',
                         'account_age_days', 'engagement_score']].copy()
citizen_features.rename(columns={
    'previous_requests':    'citizen_previous_requests',
    'satisfaction_history': 'citizen_satisfaction_history',
    'account_age_days':     'citizen_account_age_days',
    'engagement_score':     'citizen_engagement_score'
}, inplace=True)
print(f"  Citizen features: {len(citizen_features.columns) - 1}")

# ============================================================================
# 6. BUILD THE ANALYTICAL BASE TABLE
# ============================================================================
print("\n" + "=" * 70)
print("BUILDING ANALYTICAL BASE TABLE")
print("=" * 70)

abt = sr.copy()

# Join citizen features
abt = abt.merge(citizen_features, on='citizen_id', how='left')

# Join department features
abt = abt.merge(dept_avg, on='department', how='left')

# Join district features
abt = abt.merge(district_features, on='location_district', how='left')

# Fill missing values
abt['citizen_previous_requests']   = abt['citizen_previous_requests'].fillna(0)
abt['citizen_satisfaction_history'] = abt['citizen_satisfaction_history'].fillna(3.0)
abt['citizen_account_age_days']    = abt['citizen_account_age_days'].fillna(365)
abt['citizen_engagement_score']    = abt['citizen_engagement_score'].fillna(0)

dept_fill_cols = [c for c in abt.columns if c.startswith('dept_')]
for col in dept_fill_cols:
    abt[col] = abt[col].fillna(0)

dist_fill_cols = [c for c in abt.columns if c.startswith('district_')]
for col in dist_fill_cols:
    abt[col] = abt[col].fillna(0)

# One-hot encode categoricals
abt = pd.get_dummies(abt, columns=['age_group'], prefix='age')
abt = pd.get_dummies(abt, columns=['contact_preference'], prefix='contact')

# Drop columns not needed for modeling
drop_cols = ['request_id', 'citizen_id', 'submission_date', 'request_type',
             'department', 'priority_level', 'location_district', 'resolved']
abt.drop(columns=[c for c in drop_cols if c in abt.columns], inplace=True)

print(f"  Final ABT shape: {abt.shape[0]:,} rows x {abt.shape[1]} columns")
print(f"  Features: {abt.shape[1] - 1}  (excluding is_urgent target)")

# ============================================================================
# 7. URGENCY DISTRIBUTION
# ============================================================================
print("\n" + "=" * 70)
print("URGENCY DISTRIBUTION IN ABT")
print("=" * 70)

urgency_counts = abt['is_urgent'].value_counts()
urgency_pct    = abt['is_urgent'].value_counts(normalize=True) * 100
print(f"  Not Urgent (0): {urgency_counts.get(0, 0):>5,}  ({urgency_pct.get(0, 0):.1f}%)")
print(f"  Urgent (1):     {urgency_counts.get(1, 0):>5,}  ({urgency_pct.get(1, 0):.1f}%)")

# ============================================================================
# 8. SAVE
# ============================================================================
abt.to_csv(OUTPUT_PATH, index=False)
print(f"\nAnalytical Base Table saved to: {OUTPUT_PATH}")
print("=" * 70)
print("STEP 2 COMPLETE")
print("=" * 70)
