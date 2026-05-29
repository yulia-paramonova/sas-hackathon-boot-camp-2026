/******************************************************************************
 * Step 2: Data Preparation (SAS)
 * =============================================================================
 * Load, profile, and join the four MedCare datasets into an
 * Analytical Base Table (ABT) for patient readmission prediction.
 *
 * Run this program in a SAS session inside SAS Studio.
 *
 * Outputs:
 *   - data/life_sciences_abt.csv
 *   - Log: data cards, summary statistics, readmission distribution
 ******************************************************************************/

/* -----------------------------------------------------------------------
   Configuration — adjust the path if your working directory differs
   ----------------------------------------------------------------------- */
%let datadir = &_USERHOME./data/sas-hackathon-boot-camp-2026/use-case-financial-services/data;

/* ========================================================================
   1. LOAD THE DATA
   ========================================================================
   The CSV files may have Windows line endings (CR+LF). We use TERMSTR=CRLF
   on the INFILE statement so SAS strips the carriage return properly.
   ======================================================================== */
title "Step 2: Data Preparation (SAS)";

/* --- patients.csv -------------------------------------------------------- */
data work.patients;
    infile "&datadir./patients.csv" delimiter=',' missover dsd
           lrecl=32767 firstobs=2 termstr=crlf;
    length patient_id $5 gender $1 insurance_type $15
           primary_diagnosis_category $20;
    informat admission_date yymmdd10.;
    format admission_date yymmdd10.;
    input patient_id $ admission_date age gender $ insurance_type $
          primary_diagnosis_category $ comorbidity_count readmitted_30days;
run;

/* --- admissions.csv ------------------------------------------------------ */
data work.admissions;
    infile "&datadir./admissions.csv" delimiter=',' missover dsd
           lrecl=32767 firstobs=2 termstr=crlf;
    length admission_id $5 patient_id $5 admission_type $15
           discharge_disposition $30;
    informat admission_date yymmdd10. discharge_date yymmdd10.;
    format admission_date yymmdd10. discharge_date yymmdd10.;
    input admission_id $ patient_id $ admission_date discharge_date
          length_of_stay admission_type $ discharge_disposition $;
run;

/* --- clinical_measures.csv ----------------------------------------------- */
data work.clinical_measures;
    infile "&datadir./clinical_measures.csv" delimiter=',' missover dsd
           lrecl=32767 firstobs=2 termstr=crlf;
    length patient_id $5 lab_results_flag $10;
    input patient_id $ bmi blood_pressure_systolic blood_pressure_diastolic
          glucose_level lab_results_flag $;
run;

/* --- medications.csv ----------------------------------------------------- */
data work.medications;
    infile "&datadir./medications.csv" delimiter=',' missover dsd
           lrecl=32767 firstobs=2 termstr=crlf;
    length medication_id $5 patient_id $5 medication_name $30
           medication_class $25 dosage $10 frequency $20;
    informat start_date yymmdd10. end_date yymmdd10.;
    format start_date yymmdd10. end_date yymmdd10.;
    input medication_id $ patient_id $ medication_name $ medication_class $
          dosage $ frequency $ high_risk_flag start_date end_date;
run;

/* Quick row-count check */
%macro rowcount(ds);
    %let dsid = %sysfunc(open(&ds));
    %let n    = %sysfunc(attrn(&dsid, nlobs));
    %let rc   = %sysfunc(close(&dsid));
    %put NOTE: &ds has &n observations.;
%mend;
%rowcount(work.patients)
%rowcount(work.admissions)
%rowcount(work.clinical_measures)
%rowcount(work.medications)

/* ========================================================================
   2. DATA CARD — contents and row counts for each table
   ======================================================================== */
title "DATA CARD: patients";
proc contents data=work.patients; run;
proc print data=work.patients(obs=5); run;

title "DATA CARD: admissions";
proc contents data=work.admissions; run;
proc print data=work.admissions(obs=5); run;

title "DATA CARD: clinical_measures";
proc contents data=work.clinical_measures; run;
proc print data=work.clinical_measures(obs=5); run;

title "DATA CARD: medications";
proc contents data=work.medications; run;
proc print data=work.medications(obs=5); run;

/* Missing value summary */
title "Missing Values — patients";
proc means data=work.patients nmiss n; run;

title "Missing Values — admissions";
proc means data=work.admissions nmiss n; run;

title "Missing Values — clinical_measures";
proc means data=work.clinical_measures nmiss n; run;

title "Missing Values — medications";
proc means data=work.medications nmiss n; run;

/* ========================================================================
   3. BASIC SUMMARY STATISTICS
   ======================================================================== */
title "Summary Statistics — patients";
proc means data=work.patients n mean std min median max;
    var age comorbidity_count readmitted_30days;
run;

title "Frequency — patients (categorical)";
proc freq data=work.patients;
    tables gender insurance_type primary_diagnosis_category / nocum;
run;

title "Summary Statistics — admissions";
proc means data=work.admissions n mean std min median max;
    var length_of_stay;
run;

title "Frequency — admissions (categorical)";
proc freq data=work.admissions;
    tables admission_type discharge_disposition / nocum;
run;

title "Summary Statistics — clinical_measures";
proc means data=work.clinical_measures n mean std min median max;
    var bmi blood_pressure_systolic blood_pressure_diastolic glucose_level;
run;

title "Frequency — clinical_measures (categorical)";
proc freq data=work.clinical_measures;
    tables lab_results_flag / nocum;
run;

title "Summary Statistics — medications";
proc means data=work.medications n mean std min median max;
    var high_risk_flag;
run;

title "Frequency — medications (categorical)";
proc freq data=work.medications;
    tables medication_class frequency / nocum;
run;

/* ========================================================================
   4. FEATURE ENGINEERING — Medications
   ======================================================================== */
proc sql;
    create table work.med_features as
    select
        patient_id,
        count(*)                         as medication_count,
        sum(high_risk_flag)              as high_risk_med_count,
        count(distinct medication_class) as unique_med_classes
    from work.medications
    group by patient_id;
quit;

data work.med_features;
    set work.med_features;
    /* Polypharmacy: 5 or more concurrent medications */
    polypharmacy_flag = (medication_count >= 5);
run;

/* ========================================================================
   5. FEATURE ENGINEERING — Clinical Measures
   ======================================================================== */
data work.clinical_features;
    set work.clinical_measures;

    /* BMI categories */
    if bmi < 18.5 then bmi_category = 'Underweight';
    else if bmi < 25 then bmi_category = 'Normal';
    else if bmi < 30 then bmi_category = 'Overweight';
    else bmi_category = 'Obese';

    /* Blood pressure classification (ACC/AHA guidelines) */
    if blood_pressure_systolic < 120 and blood_pressure_diastolic < 80 then
        bp_classification = 'Normal';
    else if blood_pressure_systolic < 130 and blood_pressure_diastolic < 80 then
        bp_classification = 'Elevated';
    else if blood_pressure_systolic < 140 or blood_pressure_diastolic < 90 then
        bp_classification = 'Hypertension_S1';
    else
        bp_classification = 'Hypertension_S2';

    /* Glucose level categories */
    if glucose_level < 100 then glucose_category = 'Normal';
    else if glucose_level < 126 then glucose_category = 'Prediabetic';
    else glucose_category = 'Diabetic';

    /* Lab results flag as numeric */
    lab_abnormal = (lab_results_flag = 'Abnormal');

    /* Clinical risk score: sum of abnormal indicators */
    clinical_risk_score = 0;
    if bmi >= 30 or bmi < 18.5 then clinical_risk_score + 1;
    if blood_pressure_systolic >= 140 or blood_pressure_diastolic >= 90 then
        clinical_risk_score + 1;
    if glucose_level >= 126 then clinical_risk_score + 1;
    if lab_abnormal = 1 then clinical_risk_score + 1;
run;

/* ========================================================================
   6. FEATURE ENGINEERING — Admissions
   ======================================================================== */
data work.admission_features;
    set work.admissions;

    /* LOS categories */
    if length_of_stay <= 2 then los_category = 'Short';
    else if length_of_stay <= 5 then los_category = 'Medium';
    else los_category = 'Long';

    /* Emergency admission flag */
    emergency_flag = (admission_type = 'Emergency');

    /* Discharge disposition encoding */
    discharged_home        = (discharge_disposition = 'Home');
    discharged_snf         = (discharge_disposition = 'SNF');
    discharged_home_health = (discharge_disposition = 'Home Health');

    keep patient_id length_of_stay los_category emergency_flag
         discharged_home discharged_snf discharged_home_health
         discharge_disposition;
run;

/* ========================================================================
   7. BUILD THE ANALYTICAL BASE TABLE
   ======================================================================== */
/* One-hot encode patient-level categoricals */
data work.patient_base;
    set work.patients;

    /* One-hot encode gender */
    gender_M = (gender = 'M');
    gender_F = (gender = 'F');

    /* One-hot encode insurance_type */
    ins_Medicare   = (insurance_type = 'Medicare');
    ins_Medicaid   = (insurance_type = 'Medicaid');
    ins_Commercial = (insurance_type = 'Commercial');
    ins_Uninsured  = (insurance_type = 'Uninsured');

    drop admission_date;
run;

proc sql;
    create table work.abt_raw as
    select
        p.*,
        a.length_of_stay,
        a.los_category,
        a.emergency_flag,
        a.discharged_home,
        a.discharged_snf,
        a.discharged_home_health,
        c.bmi,
        c.blood_pressure_systolic,
        c.blood_pressure_diastolic,
        c.glucose_level,
        c.lab_abnormal,
        c.bmi_category,
        c.bp_classification,
        c.glucose_category,
        c.clinical_risk_score,
        m.medication_count,
        m.high_risk_med_count,
        m.unique_med_classes,
        m.polypharmacy_flag
    from work.patient_base p
    left join work.admission_features  a on p.patient_id = a.patient_id
    left join work.clinical_features   c on p.patient_id = c.patient_id
    left join work.med_features        m on p.patient_id = m.patient_id;
quit;

/* Fill missing values */
data work.abt;
    set work.abt_raw;

    /* Patients with no medication records */
    array med_vars{*} medication_count high_risk_med_count
        unique_med_classes polypharmacy_flag;
    do i = 1 to dim(med_vars);
        if med_vars{i} = . then med_vars{i} = 0;
    end;

    /* Fill any remaining missing numeric values */
    if length_of_stay = . then length_of_stay = 0;
    if emergency_flag = . then emergency_flag = 0;
    if discharged_home = . then discharged_home = 0;
    if discharged_snf = . then discharged_snf = 0;
    if discharged_home_health = . then discharged_home_health = 0;
    if bmi = . then bmi = 0;
    if blood_pressure_systolic = . then blood_pressure_systolic = 0;
    if blood_pressure_diastolic = . then blood_pressure_diastolic = 0;
    if glucose_level = . then glucose_level = 0;
    if lab_abnormal = . then lab_abnormal = 0;
    if clinical_risk_score = . then clinical_risk_score = 0;

    /* One-hot encode LOS category */
    los_Short  = (los_category = 'Short');
    los_Medium = (los_category = 'Medium');
    los_Long   = (los_category = 'Long');

    /* One-hot encode BMI category */
    bmi_Underweight = (bmi_category = 'Underweight');
    bmi_Normal      = (bmi_category = 'Normal');
    bmi_Overweight  = (bmi_category = 'Overweight');
    bmi_Obese       = (bmi_category = 'Obese');

    /* One-hot encode BP classification */
    bp_Normal          = (bp_classification = 'Normal');
    bp_Elevated        = (bp_classification = 'Elevated');
    bp_Hypertension_S1 = (bp_classification = 'Hypertension_S1');
    bp_Hypertension_S2 = (bp_classification = 'Hypertension_S2');

    /* One-hot encode glucose category */
    gluc_Normal     = (glucose_category = 'Normal');
    gluc_Prediabetic = (glucose_category = 'Prediabetic');
    gluc_Diabetic   = (glucose_category = 'Diabetic');

    drop gender insurance_type primary_diagnosis_category
         los_category bmi_category bp_classification glucose_category
         discharge_disposition i;
run;

/* ========================================================================
   8. READMISSION DISTRIBUTION
   ======================================================================== */
title "Readmission Distribution in Analytical Base Table";
proc freq data=work.abt;
    tables readmitted_30days / nocum;
run;

title "Readmission Rate by Insurance Type";
proc sql;
    select
        case
            when ins_Medicare   = 1 then 'Medicare'
            when ins_Medicaid   = 1 then 'Medicaid'
            when ins_Commercial = 1 then 'Commercial'
            when ins_Uninsured  = 1 then 'Uninsured'
        end as insurance,
        count(*) as n,
        mean(readmitted_30days) as readmission_rate format=percent8.1
    from work.abt
    group by calculated insurance;
quit;

/* ========================================================================
   9. SAVE THE ABT
   ======================================================================== */
proc export data=work.abt
    outfile="&datadir./life_sciences_abt.csv"
    dbms=csv replace;
run;

title "ABT Summary";
proc contents data=work.abt short; run;
proc means data=work.abt n nmiss mean std min max;
run;

title;
%put NOTE: Step 2 complete. Analytical Base Table saved to &datadir./life_sciences_abt.csv;
