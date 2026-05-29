# =============================================================================
# Step 2: Data Preparation (R)
# =============================================================================
# Load, profile, and join the four PremierBank datasets into an
# Analytical Base Table (ABT) for loan default prediction.
#
# Run this script in an R session inside SAS Studio.
# Uses only base R — no external packages required.
#
# Outputs:
#   - data/financial_services_abt.csv
#   - Console: data cards, summary statistics, default distribution
# =============================================================================

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
data_dir    <- paste(symget("_USERHOME"), "sas-hackathon-boot-camp-2026/use-case-financial-services/data", sep="/")
output_path <- file.path(data_dir, "financial_services_abt.csv")

# ============================================================================
# 1. LOAD THE DATA
# ============================================================================
cat(strrep("=", 70), "\n")
cat("STEP 2: DATA PREPARATION  (R)\n")
cat(strrep("=", 70), "\n\n")

loan_applications <- read.csv(file.path(data_dir, "loan_applications.csv"), stringsAsFactors = FALSE)
credit_history    <- read.csv(file.path(data_dir, "credit_history.csv"),    stringsAsFactors = FALSE)
employment        <- read.csv(file.path(data_dir, "employment.csv"),        stringsAsFactors = FALSE)
payment_history   <- read.csv(file.path(data_dir, "payment_history.csv"),   stringsAsFactors = FALSE)

cat("--- Loaded Datasets ---\n")
cat(sprintf("  loan_applications: %6d rows x %d cols\n", nrow(loan_applications), ncol(loan_applications)))
cat(sprintf("  credit_history:    %6d rows x %d cols\n", nrow(credit_history),    ncol(credit_history)))
cat(sprintf("  employment:        %6d rows x %d cols\n", nrow(employment),        ncol(employment)))
cat(sprintf("  payment_history:   %6d rows x %d cols\n", nrow(payment_history),   ncol(payment_history)))

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

print_data_card("loan_applications.csv", loan_applications)
print_data_card("credit_history.csv",    credit_history)
print_data_card("employment.csv",        employment)
print_data_card("payment_history.csv",   payment_history)

# ============================================================================
# 3. BASIC SUMMARY STATISTICS
# ============================================================================
cat("\n", strrep("=", 70), "\n")
cat("SUMMARY STATISTICS\n")
cat(strrep("=", 70), "\n")

num_cols <- function(df) df[, sapply(df, is.numeric), drop = FALSE]

cat("\n--- loan_applications (numeric) ---\n")
print(summary(num_cols(loan_applications)))

cat("\n--- loan_applications (categorical) ---\n")
print(table(loan_applications$loan_purpose))
print(table(loan_applications$property_type))

cat("\n--- credit_history (numeric) ---\n")
print(summary(num_cols(credit_history)))

cat("\n--- employment (numeric) ---\n")
print(summary(num_cols(employment)))

cat("\n--- employment (categorical) ---\n")
print(table(employment$employment_status))
print(table(employment$employer_type))

cat("\n--- payment_history (numeric) ---\n")
print(summary(num_cols(payment_history)))

cat("\n--- payment_history (categorical) ---\n")
print(table(payment_history$payment_status))

# ============================================================================
# 4. CLEAN & PARSE DATES
# ============================================================================
cat("\n", strrep("=", 70), "\n")
cat("DATA CLEANING\n")
cat(strrep("=", 70), "\n")

loan_applications$application_date <- as.Date(loan_applications$application_date)
payment_history$payment_date       <- as.Date(payment_history$payment_date)

valid_ids       <- unique(loan_applications$loan_id)
credit_history  <- credit_history[credit_history$loan_id %in% valid_ids, ]
employment      <- employment[employment$loan_id %in% valid_ids, ]
payment_history <- payment_history[payment_history$loan_id %in% valid_ids, ]

cat("  Date columns parsed, IDs validated.\n")

# ============================================================================
# 5. FEATURE ENGINEERING
# ============================================================================
cat("\n", strrep("=", 70), "\n")
cat("FEATURE ENGINEERING\n")
cat(strrep("=", 70), "\n")

# --- Payment behavior features ---------------------------------------------
pmt <- do.call(rbind, lapply(split(payment_history, payment_history$loan_id), function(d) {
  shortfall_ratio <- ifelse(d$amount_due > 0,
                            (d$amount_due - d$amount_paid) / d$amount_due, 0)
  data.frame(
    loan_id                  = d$loan_id[1],
    total_payments           = nrow(d),
    late_payment_count       = sum(d$days_late > 0, na.rm = TRUE),
    severe_delinquency_count = sum(d$days_late >= 60, na.rm = TRUE),
    avg_days_late            = mean(d$days_late, na.rm = TRUE),
    max_days_late            = max(d$days_late, na.rm = TRUE),
    total_shortfall          = max(sum(d$amount_due - d$amount_paid, na.rm = TRUE), 0),
    avg_shortfall_ratio      = mean(shortfall_ratio, na.rm = TRUE),
    on_time_count            = sum(d$payment_status == "On Time", na.rm = TRUE),
    stringsAsFactors = FALSE
  )
}))
rownames(pmt) <- NULL

pmt$late_payment_rate       <- ifelse(pmt$total_payments > 0,
                                       pmt$late_payment_count / pmt$total_payments, 0)
pmt$on_time_rate            <- ifelse(pmt$total_payments > 0,
                                       pmt$on_time_count / pmt$total_payments, 0)
pmt$severe_delinquency_flag <- as.integer(pmt$severe_delinquency_count > 0)

cat(sprintf("  Payment behavior features: %d\n", ncol(pmt) - 1))

# --- Credit features -------------------------------------------------------
credit <- credit_history

credit$fico_band <- ifelse(credit$credit_score >= 750, "Excellent",
                    ifelse(credit$credit_score >= 700, "Good",
                    ifelse(credit$credit_score >= 650, "Fair",
                    ifelse(credit$credit_score >= 600, "Poor", "Very Poor"))))

credit$utilization_cat <- ifelse(credit$credit_utilization <= 0.30, "Low",
                          ifelse(credit$credit_utilization <= 0.50, "Moderate",
                          ifelse(credit$credit_utilization <= 0.75, "High", "Very High")))

credit$has_bankruptcy  <- as.integer(credit$bankruptcies > 0)
credit$has_delinquency <- as.integer(credit$delinquencies_2yr > 0)
credit$high_inquiries  <- as.integer(credit$inquiries_6mo >= 3)

cat(sprintf("  Credit features:           %d\n", ncol(credit) - 1))

# --- Employment features ---------------------------------------------------
emp <- employment

emp$debt_service_ratio <- ifelse(emp$annual_income > 0,
                                  (emp$monthly_debt * 12) / emp$annual_income, 0)

emp$income_band <- ifelse(emp$annual_income >= 100000, "High",
                   ifelse(emp$annual_income >= 60000,  "Middle",
                   ifelse(emp$annual_income >= 35000,  "Low-Middle", "Low")))

emp$tenure_band <- ifelse(emp$years_employed >= 10, "Veteran",
                   ifelse(emp$years_employed >= 5,  "Established",
                   ifelse(emp$years_employed >= 2,  "Developing", "New")))

cat(sprintf("  Employment features:       %d\n", ncol(emp) - 1))

# ============================================================================
# 6. BUILD THE ANALYTICAL BASE TABLE
# ============================================================================
cat("\n", strrep("=", 70), "\n")
cat("BUILDING ANALYTICAL BASE TABLE\n")
cat(strrep("=", 70), "\n")

abt <- loan_applications
abt$application_date <- NULL

abt <- merge(abt, credit, by = "loan_id", all.x = TRUE)
abt <- merge(abt, emp,    by = "loan_id", all.x = TRUE)
abt <- merge(abt, pmt,    by = "loan_id", all.x = TRUE)

# Fill missing payment features
pmt_fill_cols <- setdiff(names(pmt), "loan_id")
for (col in pmt_fill_cols) {
  abt[[col]][is.na(abt[[col]])] <- 0
}
abt$debt_service_ratio[is.na(abt$debt_service_ratio)] <- 0

# One-hot encode categoricals
# loan_purpose
purposes <- unique(abt$loan_purpose[!is.na(abt$loan_purpose)])
for (p in purposes) {
  col_name <- paste0("purpose_", gsub("[^A-Za-z]", "", p))
  abt[[col_name]] <- as.integer(abt$loan_purpose == p)
}
abt$loan_purpose <- NULL

# property_type
props <- unique(abt$property_type[!is.na(abt$property_type)])
for (p in props) {
  col_name <- paste0("prop_", gsub("[^A-Za-z]", "", p))
  abt[[col_name]] <- as.integer(abt$property_type == p)
}
abt$property_type <- NULL

# employment_status
emp_statuses <- unique(abt$employment_status[!is.na(abt$employment_status)])
for (s in emp_statuses) {
  col_name <- paste0("emp_", gsub("[^A-Za-z]", "", s))
  abt[[col_name]] <- as.integer(abt$employment_status == s)
}
abt$employment_status <- NULL

# employer_type
emp_types <- unique(abt$employer_type[!is.na(abt$employer_type)])
for (t in emp_types) {
  col_name <- paste0("emplr_", gsub("[^A-Za-z]", "", t))
  abt[[col_name]] <- as.integer(abt$employer_type == t)
}
abt$employer_type <- NULL

# fico_band
fico_bands <- unique(abt$fico_band[!is.na(abt$fico_band)])
for (b in fico_bands) {
  col_name <- paste0("fico_", gsub("[^A-Za-z]", "", b))
  abt[[col_name]] <- as.integer(abt$fico_band == b)
}
abt$fico_band <- NULL

# utilization_cat
util_cats <- unique(abt$utilization_cat[!is.na(abt$utilization_cat)])
for (u in util_cats) {
  col_name <- paste0("util_", gsub("[^A-Za-z]", "", u))
  abt[[col_name]] <- as.integer(abt$utilization_cat == u)
}
abt$utilization_cat <- NULL

# income_band
inc_bands <- unique(abt$income_band[!is.na(abt$income_band)])
for (b in inc_bands) {
  col_name <- paste0("inc_", gsub("[^A-Za-z]", "", b))
  abt[[col_name]] <- as.integer(abt$income_band == b)
}
abt$income_band <- NULL

# tenure_band
ten_bands <- unique(abt$tenure_band[!is.na(abt$tenure_band)])
for (b in ten_bands) {
  col_name <- paste0("ten_", gsub("[^A-Za-z]", "", b))
  abt[[col_name]] <- as.integer(abt$tenure_band == b)
}
abt$tenure_band <- NULL

cat(sprintf("  Final ABT shape: %s rows x %d columns\n",
            format(nrow(abt), big.mark = ","), ncol(abt)))
cat(sprintf("  Features: %d  (excluding loan_id and defaulted)\n", ncol(abt) - 2))

# ============================================================================
# 7. DEFAULT DISTRIBUTION
# ============================================================================
cat("\n", strrep("=", 70), "\n")
cat("DEFAULT DISTRIBUTION IN ABT\n")
cat(strrep("=", 70), "\n")

default_tbl <- table(abt$defaulted)
cat(sprintf("  Current (0):   %5d  (%.1f%%)\n",
            default_tbl["0"], 100 * default_tbl["0"] / nrow(abt)))
cat(sprintf("  Defaulted (1): %5d  (%.1f%%)\n",
            default_tbl["1"], 100 * default_tbl["1"] / nrow(abt)))

# ============================================================================
# 8. SAVE
# ============================================================================
write.csv(abt, output_path, row.names = FALSE)
cat(sprintf("\nAnalytical Base Table saved to: %s\n", output_path))
cat(strrep("=", 70), "\n")
cat("STEP 2 COMPLETE\n")
cat(strrep("=", 70), "\n")
