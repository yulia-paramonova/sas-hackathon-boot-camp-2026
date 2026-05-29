# =============================================================================
# Step 2: Data Preparation (R)
# =============================================================================
# Load, profile, and join the four MedCare datasets into an
# Analytical Base Table (ABT) for patient readmission prediction.
#
# Run this script in an R session inside SAS Studio.
# Uses only base R — no external packages required.
#
# Outputs:
#   - data/life_sciences_abt.csv
#   - Console: data cards, summary statistics, readmission distribution
# =============================================================================

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
DATA_DIR = SAS.symget('_USERHOME') + '/data/sas-hackathon-boot-camp-2026/use-case-financial-services/data'
output_path <- file.path(data_dir, "life_sciences_abt.csv")

# ============================================================================
# 1. LOAD THE DATA
# ============================================================================
cat(strrep("=", 70), "\n")
cat("STEP 2: DATA PREPARATION  (R)\n")
cat(strrep("=", 70), "\n\n")

patients          <- read.csv(file.path(data_dir, "patients.csv"),          stringsAsFactors = FALSE)
admissions        <- read.csv(file.path(data_dir, "admissions.csv"),        stringsAsFactors = FALSE)
clinical_measures <- read.csv(file.path(data_dir, "clinical_measures.csv"), stringsAsFactors = FALSE)
medications       <- read.csv(file.path(data_dir, "medications.csv"),       stringsAsFactors = FALSE)

cat("--- Loaded Datasets ---\n")
cat(sprintf("  patients:          %6d rows x %d cols\n", nrow(patients),          ncol(patients)))
cat(sprintf("  admissions:        %6d rows x %d cols\n", nrow(admissions),        ncol(admissions)))
cat(sprintf("  clinical_measures: %6d rows x %d cols\n", nrow(clinical_measures), ncol(clinical_measures)))
cat(sprintf("  medications:       %6d rows x %d cols\n", nrow(medications),       ncol(medications)))

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

print_data_card("patients.csv",          patients)
print_data_card("admissions.csv",        admissions)
print_data_card("clinical_measures.csv", clinical_measures)
print_data_card("medications.csv",       medications)

# ============================================================================
# 3. BASIC SUMMARY STATISTICS
# ============================================================================
cat("\n", strrep("=", 70), "\n")
cat("SUMMARY STATISTICS\n")
cat(strrep("=", 70), "\n")

num_cols <- function(df) df[, sapply(df, is.numeric), drop = FALSE]

cat("\n--- patients (numeric) ---\n")
print(summary(num_cols(patients)))

cat("\n--- patients (categorical) ---\n")
print(table(patients$gender))
print(table(patients$insurance_type))
print(table(patients$primary_diagnosis_category))

cat("\n--- admissions (numeric) ---\n")
print(summary(num_cols(admissions)))

cat("\n--- admissions (categorical) ---\n")
print(table(admissions$admission_type))
print(table(admissions$discharge_disposition))

cat("\n--- clinical_measures (numeric) ---\n")
print(summary(num_cols(clinical_measures)))

cat("\n--- clinical_measures (categorical) ---\n")
print(table(clinical_measures$lab_results_flag))

cat("\n--- medications (numeric) ---\n")
print(summary(num_cols(medications)))

cat("\n--- medications (categorical) ---\n")
print(table(medications$medication_class))

# ============================================================================
# 4. CLEAN & PARSE DATES
# ============================================================================
cat("\n", strrep("=", 70), "\n")
cat("DATA CLEANING\n")
cat(strrep("=", 70), "\n")

patients$admission_date    <- as.Date(patients$admission_date)
admissions$admission_date  <- as.Date(admissions$admission_date)
admissions$discharge_date  <- as.Date(admissions$discharge_date)
medications$start_date     <- as.Date(medications$start_date)
medications$end_date       <- as.Date(medications$end_date)

# Keep only records for valid patients
valid_ids         <- unique(patients$patient_id)
admissions        <- admissions[admissions$patient_id %in% valid_ids, ]
clinical_measures <- clinical_measures[clinical_measures$patient_id %in% valid_ids, ]
medications       <- medications[medications$patient_id %in% valid_ids, ]

cat("  Date columns parsed, IDs validated.\n")

# ============================================================================
# 5. FEATURE ENGINEERING
# ============================================================================
cat("\n", strrep("=", 70), "\n")
cat("FEATURE ENGINEERING\n")
cat(strrep("=", 70), "\n")

# --- Medication features ---------------------------------------------------
med <- do.call(rbind, lapply(split(medications, medications$patient_id), function(d) {
  data.frame(
    patient_id          = d$patient_id[1],
    medication_count    = nrow(d),
    high_risk_med_count = sum(d$high_risk_flag, na.rm = TRUE),
    unique_med_classes  = length(unique(d$medication_class)),
    stringsAsFactors    = FALSE
  )
}))
med$polypharmacy_flag <- as.integer(med$medication_count >= 5)
rownames(med) <- NULL
cat(sprintf("  Medication features: %d\n", ncol(med) - 1))

# --- Clinical features -----------------------------------------------------
clin <- clinical_measures

# BMI categories
clin$bmi_category <- ifelse(clin$bmi < 18.5, "Underweight",
                     ifelse(clin$bmi < 25,   "Normal",
                     ifelse(clin$bmi < 30,   "Overweight", "Obese")))

# Blood pressure classification
clin$bp_classification <- ifelse(
  clin$blood_pressure_systolic < 120 & clin$blood_pressure_diastolic < 80, "Normal",
  ifelse(clin$blood_pressure_systolic < 130 & clin$blood_pressure_diastolic < 80, "Elevated",
  ifelse(clin$blood_pressure_systolic < 140 | clin$blood_pressure_diastolic < 90,
         "Hypertension_S1", "Hypertension_S2")))

# Glucose categories
clin$glucose_category <- ifelse(clin$glucose_level < 100, "Normal",
                         ifelse(clin$glucose_level < 126, "Prediabetic", "Diabetic"))

# Lab results as numeric
clin$lab_abnormal <- as.integer(clin$lab_results_flag == "Abnormal")

# Clinical risk score
clin$clinical_risk_score <-
  as.integer(clin$bmi >= 30 | clin$bmi < 18.5) +
  as.integer(clin$blood_pressure_systolic >= 140 | clin$blood_pressure_diastolic >= 90) +
  as.integer(clin$glucose_level >= 126) +
  clin$lab_abnormal

cat(sprintf("  Clinical features:   %d\n", ncol(clin) - ncol(clinical_measures)))

# --- Admission features ----------------------------------------------------
adm <- admissions

# LOS categories
adm$los_category <- ifelse(adm$length_of_stay <= 2, "Short",
                    ifelse(adm$length_of_stay <= 5, "Medium", "Long"))

# Emergency flag
adm$emergency_flag <- as.integer(adm$admission_type == "Emergency")

# Discharge disposition encoding
adm$discharged_home        <- as.integer(adm$discharge_disposition == "Home")
adm$discharged_snf         <- as.integer(adm$discharge_disposition == "SNF")
adm$discharged_home_health <- as.integer(adm$discharge_disposition == "Home Health")

adm_features <- adm[, c("patient_id", "length_of_stay", "los_category",
                         "emergency_flag", "discharged_home", "discharged_snf",
                         "discharged_home_health")]
cat(sprintf("  Admission features:  %d\n", ncol(adm_features) - 1))

# ============================================================================
# 6. BUILD THE ANALYTICAL BASE TABLE
# ============================================================================
cat("\n", strrep("=", 70), "\n")
cat("BUILDING ANALYTICAL BASE TABLE\n")
cat(strrep("=", 70), "\n")

abt <- patients

# Merge all feature tables
abt <- merge(abt, adm_features, by = "patient_id", all.x = TRUE)
abt <- merge(abt, clin[, c("patient_id", "bmi", "blood_pressure_systolic",
                             "blood_pressure_diastolic", "glucose_level",
                             "lab_abnormal", "bmi_category", "bp_classification",
                             "glucose_category", "clinical_risk_score")],
             by = "patient_id", all.x = TRUE)
abt <- merge(abt, med, by = "patient_id", all.x = TRUE)

# Fill missing values for patients with no medication records
for (col in c("medication_count", "high_risk_med_count", "unique_med_classes",
              "polypharmacy_flag")) {
  abt[[col]][is.na(abt[[col]])] <- 0
}

# Fill any other missing numerics
numeric_fill <- c("length_of_stay", "emergency_flag", "discharged_home",
                   "discharged_snf", "discharged_home_health", "bmi",
                   "blood_pressure_systolic", "blood_pressure_diastolic",
                   "glucose_level", "lab_abnormal", "clinical_risk_score")
for (col in numeric_fill) {
  if (col %in% names(abt)) {
    abt[[col]][is.na(abt[[col]])] <- 0
  }
}

# One-hot encode categoricals
abt$gender_M      <- as.integer(abt$gender == "M")
abt$gender_F      <- as.integer(abt$gender == "F")
abt$ins_Medicare   <- as.integer(abt$insurance_type == "Medicare")
abt$ins_Medicaid   <- as.integer(abt$insurance_type == "Medicaid")
abt$ins_Commercial <- as.integer(abt$insurance_type == "Commercial")
abt$ins_Uninsured  <- as.integer(abt$insurance_type == "Uninsured")
abt$los_Short      <- as.integer(abt$los_category == "Short")
abt$los_Medium     <- as.integer(abt$los_category == "Medium")
abt$los_Long       <- as.integer(abt$los_category == "Long")
abt$bmi_Underweight <- as.integer(abt$bmi_category == "Underweight")
abt$bmi_Normal      <- as.integer(abt$bmi_category == "Normal")
abt$bmi_Overweight  <- as.integer(abt$bmi_category == "Overweight")
abt$bmi_Obese       <- as.integer(abt$bmi_category == "Obese")
abt$bp_Normal          <- as.integer(abt$bp_classification == "Normal")
abt$bp_Elevated        <- as.integer(abt$bp_classification == "Elevated")
abt$bp_Hypertension_S1 <- as.integer(abt$bp_classification == "Hypertension_S1")
abt$bp_Hypertension_S2 <- as.integer(abt$bp_classification == "Hypertension_S2")
abt$gluc_Normal      <- as.integer(abt$glucose_category == "Normal")
abt$gluc_Prediabetic <- as.integer(abt$glucose_category == "Prediabetic")
abt$gluc_Diabetic    <- as.integer(abt$glucose_category == "Diabetic")

# Drop columns not needed for modeling
abt$gender                      <- NULL
abt$insurance_type              <- NULL
abt$primary_diagnosis_category  <- NULL
abt$admission_date              <- NULL
abt$los_category                <- NULL
abt$bmi_category                <- NULL
abt$bp_classification           <- NULL
abt$glucose_category            <- NULL

cat(sprintf("  Final ABT shape: %s rows x %d columns\n",
            format(nrow(abt), big.mark = ","), ncol(abt)))
cat(sprintf("  Features: %d  (excluding patient_id and readmitted_30days)\n", ncol(abt) - 2))

# ============================================================================
# 7. READMISSION DISTRIBUTION
# ============================================================================
cat("\n", strrep("=", 70), "\n")
cat("READMISSION DISTRIBUTION IN ABT\n")
cat(strrep("=", 70), "\n")

readmit_tbl <- table(abt$readmitted_30days)
cat(sprintf("  Not readmitted (0): %5d  (%.1f%%)\n",
            readmit_tbl["0"], 100 * readmit_tbl["0"] / nrow(abt)))
cat(sprintf("  Readmitted (1):     %5d  (%.1f%%)\n",
            readmit_tbl["1"], 100 * readmit_tbl["1"] / nrow(abt)))

# ============================================================================
# 8. SAVE
# ============================================================================
write.csv(abt, output_path, row.names = FALSE)
cat(sprintf("\nAnalytical Base Table saved to: %s\n", output_path))
cat(strrep("=", 70), "\n")
cat("STEP 2 COMPLETE\n")
cat(strrep("=", 70), "\n")
