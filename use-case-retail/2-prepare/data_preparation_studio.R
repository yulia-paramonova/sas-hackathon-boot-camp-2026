# =============================================================================
# Step 2: Data Preparation (R)
# =============================================================================
# Load, profile, and join the four ShopEase datasets into an
# Analytical Base Table (ABT) for churn prediction.
#
# Run this script in an R session inside SAS Studio.
# Uses only base R — no external packages required.
#
# Outputs:
#   - data/retail_abt.csv
#   - Console: data cards, summary statistics, churn distribution
# =============================================================================

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
data_dir    <- paste(symget("_USERHOME"), "sas-hackathon-boot-camp-2026/use-case-retail/data", sep="/")
output_path    <- file.path(data_dir, "retail_abt.csv")
reference_date <- as.Date("2023-12-31")

# ============================================================================
# 1. LOAD THE DATA
# ============================================================================
cat(strrep("=", 70), "\n")
cat("STEP 2: DATA PREPARATION  (R)\n")
cat(strrep("=", 70), "\n\n")

customers       <- read.csv(file.path(data_dir, "customers.csv"),       stringsAsFactors = FALSE)
transactions    <- read.csv(file.path(data_dir, "transactions.csv"),    stringsAsFactors = FALSE)
sessions        <- read.csv(file.path(data_dir, "sessions.csv"),        stringsAsFactors = FALSE)
support_tickets <- read.csv(file.path(data_dir, "support_tickets.csv"), stringsAsFactors = FALSE)

cat("--- Loaded Datasets ---\n")
cat(sprintf("  customers:       %6d rows x %d cols\n", nrow(customers),       ncol(customers)))
cat(sprintf("  transactions:    %6d rows x %d cols\n", nrow(transactions),    ncol(transactions)))
cat(sprintf("  sessions:        %6d rows x %d cols\n", nrow(sessions),        ncol(sessions)))
cat(sprintf("  support_tickets: %6d rows x %d cols\n", nrow(support_tickets), ncol(support_tickets)))

# ============================================================================
# 2. DATA CARD
# ============================================================================
print_data_card <- function(name, df) {
  cat(sprintf("\n%s\nDATA CARD: %s\n%s\n", strrep("-", 70), name, strrep("-", 70)))
  cat(sprintf("  Rows: %s    Columns: %d\n\n", format(nrow(df), big.mark = ","), ncol(df)))
  cat(sprintf("  %-30s %-12s %8s\n", "Column", "Type", "Missing"))
  cat(sprintf("  %s %s %s\n", strrep("-", 30), strrep("-", 12), strrep("-", 8)))
  for (col in names(df)) {
    cat(sprintf("  %-30s %-12s %8d\n", col, class(df[[col]])[1], sum(is.na(df[[col]]))))
  }
  cat("\n  Sample rows (first 3):\n")
  print(head(df, 3))
}

cat("\n", strrep("=", 70), "\n")
cat("DATA CARDS\n")
cat(strrep("=", 70), "\n")

print_data_card("customers.csv",       customers)
print_data_card("transactions.csv",    transactions)
print_data_card("sessions.csv",        sessions)
print_data_card("support_tickets.csv", support_tickets)

# ============================================================================
# 3. BASIC SUMMARY STATISTICS
# ============================================================================
cat("\n", strrep("=", 70), "\n")
cat("SUMMARY STATISTICS\n")
cat(strrep("=", 70), "\n")

num_cols <- function(df) df[, sapply(df, is.numeric), drop = FALSE]

cat("\n--- customers (numeric) ---\n")
print(summary(num_cols(customers)))

cat("\n--- customers (categorical) ---\n")
print(table(customers$gender))
print(table(customers$subscription_tier))

cat("\n--- transactions (numeric) ---\n")
print(summary(num_cols(transactions)))

cat("\n--- sessions (numeric) ---\n")
print(summary(num_cols(sessions)))

cat("\n--- support_tickets (numeric) ---\n")
print(summary(num_cols(support_tickets)))

# ============================================================================
# 4. CLEAN & PARSE DATES
# ============================================================================
cat("\n", strrep("=", 70), "\n")
cat("DATA CLEANING\n")
cat(strrep("=", 70), "\n")

customers$signup_date         <- as.Date(customers$signup_date)
transactions$transaction_date <- as.Date(transactions$transaction_date)
sessions$session_date         <- as.Date(sessions$session_date)
support_tickets$ticket_date   <- as.Date(support_tickets$ticket_date)

transactions <- transactions[!is.na(transactions$transaction_date), ]
sessions     <- sessions[!is.na(sessions$session_date), ]

valid_ids       <- unique(customers$customer_id)
transactions    <- transactions[transactions$customer_id %in% valid_ids, ]
sessions        <- sessions[sessions$customer_id %in% valid_ids, ]
support_tickets <- support_tickets[support_tickets$customer_id %in% valid_ids, ]

cat("  Date columns parsed, invalid rows removed, IDs validated.\n")

# ============================================================================
# 5. FEATURE ENGINEERING
# ============================================================================
cat("\n", strrep("=", 70), "\n")
cat("FEATURE ENGINEERING\n")
cat(strrep("=", 70), "\n")

# --- Transaction features ---------------------------------------------------
txn <- do.call(rbind, lapply(split(transactions, transactions$customer_id), function(d) {
  data.frame(
    customer_id             = d$customer_id[1],
    total_transactions      = nrow(d),
    total_spend             = sum(d$amount, na.rm = TRUE),
    avg_order_value         = mean(d$amount, na.rm = TRUE),
    std_order_value         = ifelse(nrow(d) > 1, sd(d$amount, na.rm = TRUE), 0),
    max_order_value         = max(d$amount, na.rm = TRUE),
    min_order_value         = min(d$amount, na.rm = TRUE),
    days_since_last_purchase = as.integer(reference_date - max(d$transaction_date)),
    customer_tenure_days    = as.integer(max(d$transaction_date) - min(d$transaction_date)),
    avg_discount_rate       = mean(d$discount_applied, na.rm = TRUE),
    unique_categories       = length(unique(d$product_category)),
    stringsAsFactors = FALSE
  )
}))
txn$purchase_frequency <- ifelse(txn$customer_tenure_days > 0,
                                  txn$total_transactions / (txn$customer_tenure_days / 30),
                                  txn$total_transactions)
rownames(txn) <- NULL
cat(sprintf("  Transaction features: %d\n", ncol(txn) - 1))

# --- Session features -------------------------------------------------------
sess <- do.call(rbind, lapply(split(sessions, sessions$customer_id), function(d) {
  data.frame(
    customer_id            = d$customer_id[1],
    total_sessions         = nrow(d),
    total_session_duration = sum(d$duration_minutes, na.rm = TRUE),
    avg_session_duration   = mean(d$duration_minutes, na.rm = TRUE),
    max_session_duration   = max(d$duration_minutes, na.rm = TRUE),
    total_pages_viewed     = sum(d$pages_viewed, na.rm = TRUE),
    avg_pages_per_session  = mean(d$pages_viewed, na.rm = TRUE),
    max_pages_per_session  = max(d$pages_viewed, na.rm = TRUE),
    total_cart_abandonments = sum(d$cart_abandonment, na.rm = TRUE),
    cart_abandonment_rate  = mean(d$cart_abandonment, na.rm = TRUE),
    mobile_session_rate    = mean(d$device_type == "Mobile", na.rm = TRUE),
    unique_referral_sources = length(unique(d$referral_source)),
    stringsAsFactors = FALSE
  )
}))
rownames(sess) <- NULL
cat(sprintf("  Session features:     %d\n", ncol(sess) - 1))

# --- Support features -------------------------------------------------------
sup <- do.call(rbind, lapply(split(support_tickets, support_tickets$customer_id), function(d) {
  data.frame(
    customer_id            = d$customer_id[1],
    total_tickets          = nrow(d),
    high_priority_tickets  = sum(d$priority == "High", na.rm = TRUE),
    avg_resolution_time    = mean(d$resolution_time_hours, na.rm = TRUE),
    max_resolution_time    = max(d$resolution_time_hours, na.rm = TRUE),
    avg_satisfaction_score = mean(d$satisfaction_score, na.rm = TRUE),
    ticket_resolution_rate = mean(d$resolved, na.rm = TRUE),
    unique_issue_types     = length(unique(d$issue_category)),
    stringsAsFactors = FALSE
  )
}))
rownames(sup) <- NULL
cat(sprintf("  Support features:     %d\n", ncol(sup) - 1))

# ============================================================================
# 6. BUILD THE ANALYTICAL BASE TABLE
# ============================================================================
cat("\n", strrep("=", 70), "\n")
cat("BUILDING ANALYTICAL BASE TABLE\n")
cat(strrep("=", 70), "\n")

abt <- customers
abt$account_age_days <- as.integer(reference_date - abt$signup_date)

abt <- merge(abt, txn,  by = "customer_id", all.x = TRUE)
abt <- merge(abt, sess, by = "customer_id", all.x = TRUE)
abt <- merge(abt, sup,  by = "customer_id", all.x = TRUE)

# Fill missing values
fill_zero <- setdiff(names(abt), c(names(customers), "account_age_days"))
for (col in fill_zero) {
  if (col == "avg_satisfaction_score") {
    abt[[col]][is.na(abt[[col]])] <- 5
  } else if (col == "ticket_resolution_rate") {
    abt[[col]][is.na(abt[[col]])] <- 1
  } else {
    abt[[col]][is.na(abt[[col]])] <- 0
  }
}

# One-hot encode categoricals
abt$tier_Basic    <- as.integer(abt$subscription_tier == "Basic")
abt$tier_Standard <- as.integer(abt$subscription_tier == "Standard")
abt$tier_Premium  <- as.integer(abt$subscription_tier == "Premium")
abt$gender_F      <- as.integer(abt$gender == "F")
abt$gender_M      <- as.integer(abt$gender == "M")

# Drop columns not needed for modeling
abt$subscription_tier <- NULL
abt$gender            <- NULL
abt$signup_date       <- NULL
abt$location          <- NULL

cat(sprintf("  Final ABT shape: %s rows x %d columns\n",
            format(nrow(abt), big.mark = ","), ncol(abt)))
cat(sprintf("  Features: %d  (excluding customer_id and churned)\n", ncol(abt) - 2))

# ============================================================================
# 7. CHURN DISTRIBUTION
# ============================================================================
cat("\n", strrep("=", 70), "\n")
cat("CHURN DISTRIBUTION IN ABT\n")
cat(strrep("=", 70), "\n")

churn_tbl <- table(abt$churned)
cat(sprintf("  Active (0):  %5d  (%.1f%%)\n",
            churn_tbl["0"], 100 * churn_tbl["0"] / nrow(abt)))
cat(sprintf("  Churned (1): %5d  (%.1f%%)\n",
            churn_tbl["1"], 100 * churn_tbl["1"] / nrow(abt)))

# ============================================================================
# 8. SAVE
# ============================================================================
write.csv(abt, output_path, row.names = FALSE)
cat(sprintf("\nAnalytical Base Table saved to: %s\n", output_path))
cat(strrep("=", 70), "\n")
cat("STEP 2 COMPLETE\n")
cat(strrep("=", 70), "\n")
