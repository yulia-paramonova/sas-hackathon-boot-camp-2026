# =============================================================================
# Step 2: Data Preparation (R)
# =============================================================================
# Load, profile, and join the four Metro City datasets into an
# Analytical Base Table (ABT) for service request urgency prediction.
#
# Run this script in an R session inside SAS Studio.
# Uses only base R — no external packages required.
#
# Outputs:
#   - data/public_sector_abt.csv
#   - Console: data cards, summary statistics, urgency distribution
# =============================================================================

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
data_dir = paste(symget("_USERHOME"), "sas-hackathon-boot-camp-2026/use-case-public-sector/data", sep="/")
output_path    <- file.path(data_dir, "public_sector_abt.csv")
reference_date <- as.Date("2024-12-31")

# Request types considered inherently urgent
urgent_request_types <- c(
  "Water Main Break", "Gas Leak", "Power Outage",
  "Sewer Backup", "Traffic Signal Malfunction",
  "Road Hazard", "Building Emergency"
)

# ============================================================================
# 1. LOAD THE DATA
# ============================================================================
cat(strrep("=", 70), "\n")
cat("STEP 2: DATA PREPARATION  (R)\n")
cat(strrep("=", 70), "\n\n")

service_requests <- read.csv(file.path(data_dir, "service_requests.csv"),    stringsAsFactors = FALSE)
citizens         <- read.csv(file.path(data_dir, "citizens.csv"),            stringsAsFactors = FALSE)
dept_perf        <- read.csv(file.path(data_dir, "department_performance.csv"), stringsAsFactors = FALSE)
request_history  <- read.csv(file.path(data_dir, "request_history.csv"),     stringsAsFactors = FALSE)

cat("--- Loaded Datasets ---\n")
cat(sprintf("  service_requests:       %6d rows x %d cols\n", nrow(service_requests), ncol(service_requests)))
cat(sprintf("  citizens:               %6d rows x %d cols\n", nrow(citizens),         ncol(citizens)))
cat(sprintf("  department_performance: %6d rows x %d cols\n", nrow(dept_perf),        ncol(dept_perf)))
cat(sprintf("  request_history:        %6d rows x %d cols\n", nrow(request_history),  ncol(request_history)))

# ============================================================================
# 2. DATA CARD
# ============================================================================
print_data_card <- function(name, df) {
  cat(sprintf("\n%s\nDATA CARD: %s\n%s\n", strrep("-", 70), name, strrep("-", 70)))
  cat(sprintf("  Rows: %s    Columns: %d\n\n", format(nrow(df), big.mark = ","), ncol(df)))
  cat(sprintf("  %-35s %-12s %8s\n", "Column", "Type", "Missing"))
  cat(sprintf("  %s %s %s\n", strrep("-", 35), strrep("-", 12), strrep("-", 8)))
  for (col in names(df)) {
    cat(sprintf("  %-35s %-12s %8d\n", col, class(df[[col]])[1], sum(is.na(df[[col]]))))
  }
  cat("\n  Sample rows (first 3):\n")
  print(head(df, 3))
}

cat("\n", strrep("=", 70), "\n")
cat("DATA CARDS\n")
cat(strrep("=", 70), "\n")

print_data_card("service_requests.csv",      service_requests)
print_data_card("citizens.csv",              citizens)
print_data_card("department_performance.csv", dept_perf)
print_data_card("request_history.csv",       request_history)

# ============================================================================
# 3. BASIC SUMMARY STATISTICS
# ============================================================================
cat("\n", strrep("=", 70), "\n")
cat("SUMMARY STATISTICS\n")
cat(strrep("=", 70), "\n")

num_cols <- function(df) df[, sapply(df, is.numeric), drop = FALSE]

cat("\n--- service_requests (numeric) ---\n")
print(summary(num_cols(service_requests)))

cat("\n--- service_requests (categorical) ---\n")
print(table(service_requests$request_type))
print(table(service_requests$department))
print(table(service_requests$priority_level))
print(table(service_requests$location_district))

cat("\n--- citizens (numeric) ---\n")
print(summary(num_cols(citizens)))

cat("\n--- citizens (categorical) ---\n")
print(table(citizens$age_group))
print(table(citizens$contact_preference))

cat("\n--- department_performance (numeric) ---\n")
print(summary(num_cols(dept_perf)))

cat("\n--- request_history (numeric) ---\n")
print(summary(num_cols(request_history)))

# ============================================================================
# 4. CLEAN & PARSE DATES
# ============================================================================
cat("\n", strrep("=", 70), "\n")
cat("DATA CLEANING\n")
cat(strrep("=", 70), "\n")

service_requests$submission_date  <- as.Date(service_requests$submission_date)
citizens$registration_date        <- as.Date(citizens$registration_date)

service_requests <- service_requests[!is.na(service_requests$submission_date), ]

cat("  Date columns parsed, invalid rows removed.\n")

# ============================================================================
# 5. FEATURE ENGINEERING
# ============================================================================
cat("\n", strrep("=", 70), "\n")
cat("FEATURE ENGINEERING\n")
cat(strrep("=", 70), "\n")

# --- Temporal features -----------------------------------------------------
sr <- service_requests
sr$day_of_week    <- as.integer(format(sr$submission_date, "%u"))  # 1=Monday, 7=Sunday
sr$is_weekend     <- as.integer(sr$day_of_week %in% c(6, 7))
sr$submit_month   <- as.integer(format(sr$submission_date, "%m"))
sr$submit_quarter <- ceiling(sr$submit_month / 3)
cat("  Temporal features: 4\n")

# --- Request characteristics -----------------------------------------------
sr$inherent_urgency <- as.integer(sr$request_type %in% urgent_request_types)

# --- Derive target variable ------------------------------------------------
sr$is_urgent <- as.integer(sr$priority_level %in% c("Critical", "High"))

# --- Convert resolved to numeric -------------------------------------------
sr$resolved_flag <- as.integer(tolower(trimws(as.character(sr$resolved))) == "true")
cat("  Request features: 3 (inherent_urgency, is_urgent target, resolved_flag)\n")

# --- Department average performance ----------------------------------------
dept_avg <- do.call(rbind, lapply(split(dept_perf, dept_perf$department), function(d) {
  data.frame(
    department                  = d$department[1],
    dept_avg_response_time      = mean(d$avg_response_time_hours, na.rm = TRUE),
    dept_avg_resolution_rate    = mean(d$resolution_rate, na.rm = TRUE),
    dept_avg_satisfaction       = mean(d$citizen_satisfaction_avg, na.rm = TRUE),
    dept_avg_staff_count        = mean(d$staff_count, na.rm = TRUE),
    dept_avg_budget_util        = mean(d$budget_utilization, na.rm = TRUE),
    dept_avg_requests_received  = mean(d$requests_received, na.rm = TRUE),
    dept_avg_overtime           = mean(d$overtime_hours, na.rm = TRUE),
    stringsAsFactors = FALSE
  )
}))
rownames(dept_avg) <- NULL
cat(sprintf("  Department features: %d\n", ncol(dept_avg) - 1))

# --- District features from request history --------------------------------
district_features <- do.call(rbind, lapply(split(request_history, request_history$district), function(d) {
  data.frame(
    location_district             = d$district[1],
    district_avg_request_count    = mean(d$request_count, na.rm = TRUE),
    district_avg_response_time    = mean(d$avg_response_time, na.rm = TRUE),
    district_avg_resolution_rate  = mean(d$resolution_rate, na.rm = TRUE),
    district_total_critical       = sum(d$priority_critical_count, na.rm = TRUE),
    district_total_high           = sum(d$priority_high_count, na.rm = TRUE),
    stringsAsFactors = FALSE
  )
}))
rownames(district_features) <- NULL
cat(sprintf("  District features: %d\n", ncol(district_features) - 1))

# --- Citizen features ------------------------------------------------------
cit <- citizens
cit$account_age_days  <- as.integer(reference_date - cit$registration_date)
cit$engagement_score  <- ifelse(cit$previous_requests > 0,
                                 cit$previous_requests * cit$satisfaction_history / 5,
                                 0)
citizen_features <- cit[, c("citizen_id", "previous_requests", "satisfaction_history",
                             "age_group", "contact_preference",
                             "account_age_days", "engagement_score")]
names(citizen_features)[names(citizen_features) == "previous_requests"]    <- "citizen_previous_requests"
names(citizen_features)[names(citizen_features) == "satisfaction_history"] <- "citizen_satisfaction_history"
names(citizen_features)[names(citizen_features) == "account_age_days"]    <- "citizen_account_age_days"
names(citizen_features)[names(citizen_features) == "engagement_score"]    <- "citizen_engagement_score"
cat(sprintf("  Citizen features: %d\n", ncol(citizen_features) - 1))

# ============================================================================
# 6. BUILD THE ANALYTICAL BASE TABLE
# ============================================================================
cat("\n", strrep("=", 70), "\n")
cat("BUILDING ANALYTICAL BASE TABLE\n")
cat(strrep("=", 70), "\n")

abt <- sr

# Join citizen features
abt <- merge(abt, citizen_features, by = "citizen_id", all.x = TRUE)

# Join department features
abt <- merge(abt, dept_avg, by = "department", all.x = TRUE)

# Join district features
abt <- merge(abt, district_features, by = "location_district", all.x = TRUE)

# Fill missing values
abt$citizen_previous_requests[is.na(abt$citizen_previous_requests)]     <- 0
abt$citizen_satisfaction_history[is.na(abt$citizen_satisfaction_history)] <- 3.0
abt$citizen_account_age_days[is.na(abt$citizen_account_age_days)]       <- 365
abt$citizen_engagement_score[is.na(abt$citizen_engagement_score)]       <- 0

dept_fill <- grep("^dept_", names(abt), value = TRUE)
for (col in dept_fill) {
  abt[[col]][is.na(abt[[col]])] <- 0
}

dist_fill <- grep("^district_", names(abt), value = TRUE)
for (col in dist_fill) {
  abt[[col]][is.na(abt[[col]])] <- 0
}

# One-hot encode age_group
for (ag in unique(na.omit(abt$age_group))) {
  safe_name <- paste0("age_", gsub("[^A-Za-z0-9]", "_", ag))
  abt[[safe_name]] <- as.integer(abt$age_group == ag)
}

# One-hot encode contact_preference
for (cp in unique(na.omit(abt$contact_preference))) {
  safe_name <- paste0("contact_", gsub("[^A-Za-z0-9]", "_", cp))
  abt[[safe_name]] <- as.integer(abt$contact_preference == cp)
}

# Drop columns not needed for modeling
drop_cols <- c("request_id", "citizen_id", "submission_date", "request_type",
               "department", "priority_level", "location_district", "resolved",
               "age_group", "contact_preference")
abt <- abt[, !(names(abt) %in% drop_cols)]

cat(sprintf("  Final ABT shape: %s rows x %d columns\n",
            format(nrow(abt), big.mark = ","), ncol(abt)))
cat(sprintf("  Features: %d  (excluding is_urgent target)\n", ncol(abt) - 1))

# ============================================================================
# 7. URGENCY DISTRIBUTION
# ============================================================================
cat("\n", strrep("=", 70), "\n")
cat("URGENCY DISTRIBUTION IN ABT\n")
cat(strrep("=", 70), "\n")

urgency_tbl <- table(abt$is_urgent)
cat(sprintf("  Not Urgent (0): %5d  (%.1f%%)\n",
            urgency_tbl["0"], 100 * urgency_tbl["0"] / nrow(abt)))
cat(sprintf("  Urgent (1):     %5d  (%.1f%%)\n",
            urgency_tbl["1"], 100 * urgency_tbl["1"] / nrow(abt)))

# ============================================================================
# 8. SAVE
# ============================================================================
write.csv(abt, output_path, row.names = FALSE)
cat(sprintf("\nAnalytical Base Table saved to: %s\n", output_path))
cat(strrep("=", 70), "\n")
cat("STEP 2 COMPLETE\n")
cat(strrep("=", 70), "\n")
