"""
Step 2: Data Preparation (Python)
==================================
Load, profile, and join the four ShopEase datasets into an
Analytical Base Table (ABT) for churn prediction.

Run this script in a Python session inside SAS Studio.

Outputs:
  - data/retail_abt.csv
  - Console: data cards, summary statistics, churn distribution
"""

import pandas as pd
import numpy as np
import os

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
DATA_DIR = SAS.symget('_USERHOME') + '/sas-hackathon-boot-camp-2026/use-case-retail/data'
OUTPUT_PATH = os.path.join(DATA_DIR, 'retail_abt.csv')

# Reference date for recency calculations (end of observation period)
REFERENCE_DATE = pd.Timestamp('2023-12-31')

# ============================================================================
# 1. LOAD THE DATA
# ============================================================================
print("=" * 70)
print("STEP 2: DATA PREPARATION  (Python)")
print("=" * 70)

customers       = pd.read_csv(os.path.join(DATA_DIR, 'customers.csv'))
transactions    = pd.read_csv(os.path.join(DATA_DIR, 'transactions.csv'))
sessions        = pd.read_csv(os.path.join(DATA_DIR, 'sessions.csv'))
support_tickets = pd.read_csv(os.path.join(DATA_DIR, 'support_tickets.csv'))

print("\n--- Loaded Datasets ---")
print(f"  customers:       {customers.shape[0]:>6,} rows x {customers.shape[1]} cols")
print(f"  transactions:    {transactions.shape[0]:>6,} rows x {transactions.shape[1]} cols")
print(f"  sessions:        {sessions.shape[0]:>6,} rows x {sessions.shape[1]} cols")
print(f"  support_tickets: {support_tickets.shape[0]:>6,} rows x {support_tickets.shape[1]} cols")

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

print_data_card("customers.csv", customers)
print_data_card("transactions.csv", transactions)
print_data_card("sessions.csv", sessions)
print_data_card("support_tickets.csv", support_tickets)

# ============================================================================
# 3. BASIC SUMMARY STATISTICS
# ============================================================================
print("\n" + "=" * 70)
print("SUMMARY STATISTICS")
print("=" * 70)

for name, df in [("customers", customers), ("transactions", transactions),
                  ("sessions", sessions), ("support_tickets", support_tickets)]:
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

customers['signup_date'] = pd.to_datetime(customers['signup_date'])
transactions['transaction_date'] = pd.to_datetime(transactions['transaction_date'], errors='coerce')
sessions['session_date'] = pd.to_datetime(sessions['session_date'], errors='coerce')
support_tickets['ticket_date'] = pd.to_datetime(support_tickets['ticket_date'])

transactions.dropna(subset=['transaction_date'], inplace=True)
sessions.dropna(subset=['session_date'], inplace=True)

customers['churned'] = customers['churned'].astype(int)
customers['email_opt_in'] = customers['email_opt_in'].astype(int)

# Keep only transactions/sessions/tickets for valid customers
valid_ids = set(customers['customer_id'])
transactions = transactions[transactions['customer_id'].isin(valid_ids)]
sessions = sessions[sessions['customer_id'].isin(valid_ids)]
support_tickets = support_tickets[support_tickets['customer_id'].isin(valid_ids)]

print("  Date columns parsed, invalid rows removed, IDs validated.")

# ============================================================================
# 5. FEATURE ENGINEERING
# ============================================================================
print("\n" + "=" * 70)
print("FEATURE ENGINEERING")
print("=" * 70)

# --- Transaction features ---------------------------------------------------
txn = transactions.groupby('customer_id').agg(
    total_transactions=('transaction_id', 'count'),
    total_spend=('amount', 'sum'),
    avg_order_value=('amount', 'mean'),
    std_order_value=('amount', 'std'),
    max_order_value=('amount', 'max'),
    min_order_value=('amount', 'min'),
    last_transaction_date=('transaction_date', 'max'),
    first_transaction_date=('transaction_date', 'min'),
    avg_discount_rate=('discount_applied', 'mean'),
    unique_categories=('product_category', 'nunique')
).reset_index()

txn['days_since_last_purchase'] = (REFERENCE_DATE - txn['last_transaction_date']).dt.days
txn['customer_tenure_days'] = (txn['last_transaction_date'] - txn['first_transaction_date']).dt.days
txn['purchase_frequency'] = np.where(
    txn['customer_tenure_days'] > 0,
    txn['total_transactions'] / (txn['customer_tenure_days'] / 30),
    txn['total_transactions']
)
txn['std_order_value'] = txn['std_order_value'].fillna(0)
txn.drop(columns=['last_transaction_date', 'first_transaction_date'], inplace=True)
print(f"  Transaction features: {len(txn.columns) - 1}")

# --- Session features -------------------------------------------------------
sess = sessions.groupby('customer_id').agg(
    total_sessions=('session_id', 'count'),
    total_session_duration=('duration_minutes', 'sum'),
    avg_session_duration=('duration_minutes', 'mean'),
    max_session_duration=('duration_minutes', 'max'),
    total_pages_viewed=('pages_viewed', 'sum'),
    avg_pages_per_session=('pages_viewed', 'mean'),
    max_pages_per_session=('pages_viewed', 'max'),
    total_cart_abandonments=('cart_abandonment', 'sum'),
    cart_abandonment_rate=('cart_abandonment', 'mean'),
).reset_index()

mobile_rate = sessions.groupby('customer_id')['device_type'].apply(lambda x: (x == 'Mobile').mean()).reset_index()
mobile_rate.columns = ['customer_id', 'mobile_session_rate']
sess = sess.merge(mobile_rate, on='customer_id', how='left')

referral_div = sessions.groupby('customer_id')['referral_source'].nunique().reset_index()
referral_div.columns = ['customer_id', 'unique_referral_sources']
sess = sess.merge(referral_div, on='customer_id', how='left')
print(f"  Session features:     {len(sess.columns) - 1}")

# --- Support features -------------------------------------------------------
sup = support_tickets.groupby('customer_id').agg(
    total_tickets=('ticket_id', 'count'),
    avg_resolution_time=('resolution_time_hours', 'mean'),
    max_resolution_time=('resolution_time_hours', 'max'),
    avg_satisfaction_score=('satisfaction_score', 'mean'),
    ticket_resolution_rate=('resolved', 'mean'),
    unique_issue_types=('issue_category', 'nunique')
).reset_index()

high_pri = support_tickets[support_tickets['priority'] == 'High'].groupby('customer_id').size().reset_index(name='high_priority_tickets')
sup = sup.merge(high_pri, on='customer_id', how='left')
sup['high_priority_tickets'] = sup['high_priority_tickets'].fillna(0).astype(int)
print(f"  Support features:     {len(sup.columns) - 1}")

# ============================================================================
# 6. BUILD THE ANALYTICAL BASE TABLE
# ============================================================================
print("\n" + "=" * 70)
print("BUILDING ANALYTICAL BASE TABLE")
print("=" * 70)

abt = customers.copy()
abt['account_age_days'] = (REFERENCE_DATE - abt['signup_date']).dt.days

abt = abt.merge(txn, on='customer_id', how='left')
abt = abt.merge(sess, on='customer_id', how='left')
abt = abt.merge(sup, on='customer_id', how='left')

# Fill missing values for customers with no activity in a sub-table
fill_zero_cols = [c for c in abt.columns if c not in customers.columns and c != 'account_age_days']
for col in fill_zero_cols:
    if col == 'avg_satisfaction_score':
        abt[col] = abt[col].fillna(5)      # No tickets → assume satisfied
    elif col == 'ticket_resolution_rate':
        abt[col] = abt[col].fillna(1)      # No tickets → 100 % resolved
    else:
        abt[col] = abt[col].fillna(0)

# One-hot encode categoricals
abt = pd.get_dummies(abt, columns=['subscription_tier', 'gender'], prefix=['tier', 'gender'])

# Drop columns not needed for modeling
abt.drop(columns=['signup_date', 'location'], inplace=True)

print(f"  Final ABT shape: {abt.shape[0]:,} rows x {abt.shape[1]} columns")
print(f"  Features: {abt.shape[1] - 2}  (excluding customer_id and churned)")

# ============================================================================
# 7. CHURN DISTRIBUTION
# ============================================================================
print("\n" + "=" * 70)
print("CHURN DISTRIBUTION IN ABT")
print("=" * 70)

churn_counts = abt['churned'].value_counts()
churn_pct = abt['churned'].value_counts(normalize=True) * 100
print(f"  Active (0):  {churn_counts[0]:>5,}  ({churn_pct[0]:.1f}%)")
print(f"  Churned (1): {churn_counts[1]:>5,}  ({churn_pct[1]:.1f}%)")

# ============================================================================
# 8. SAVE
# ============================================================================
abt.to_csv(OUTPUT_PATH, index=False)
print(f"\nAnalytical Base Table saved to: {OUTPUT_PATH}")
print("=" * 70)
print("STEP 2 COMPLETE")
print("=" * 70)
