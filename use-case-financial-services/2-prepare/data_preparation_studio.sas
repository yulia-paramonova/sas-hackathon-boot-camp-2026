/******************************************************************************
 * Step 2: Data Preparation (SAS)
 * =============================================================================
 * Load, profile, and join the four PremierBank datasets into an
 * Analytical Base Table (ABT) for loan default prediction.
 *
 * Run this program in a SAS session inside SAS Studio.
 *
 * Outputs:
 *   - data/financial_services_abt.csv
 *   - Log: data cards, summary statistics, default distribution
 ******************************************************************************/

/* -----------------------------------------------------------------------
   Configuration — adjust the path if your working directory differs
   ----------------------------------------------------------------------- */
%let datadir = &_USERHOME./sas-hackathon-boot-camp-2026/use-case-financial-services/data;

/* ========================================================================
   1. LOAD THE DATA
   ========================================================================
   The CSV files may have Windows line endings (CR+LF). We use TERMSTR=CRLF
   on the INFILE statement so SAS strips the carriage return properly.
   ======================================================================== */
title "Step 2: Data Preparation (SAS)";

/* --- loan_applications.csv ----------------------------------------------- */
data work.loan_applications;
    infile "&datadir./loan_applications.csv" delimiter=',' missover dsd
           lrecl=32767 firstobs=2 termstr=crlf;
    length loan_id $10 loan_purpose $25 property_type $20;
    informat application_date yymmdd10.;
    format application_date yymmdd10.;
    input loan_id $ application_date loan_amount loan_term_months
          interest_rate loan_purpose $ property_type $
          loan_to_value debt_to_income defaulted;
run;

/* --- credit_history.csv -------------------------------------------------- */
data work.credit_history;
    infile "&datadir./credit_history.csv" delimiter=',' missover dsd
           lrecl=32767 firstobs=2 termstr=crlf;
    length loan_id $10;
    input loan_id $ credit_score credit_accounts credit_utilization
          bankruptcies delinquencies_2yr inquiries_6mo
          oldest_account_years total_credit_limit;
run;

/* --- employment.csv ------------------------------------------------------ */
data work.employment;
    infile "&datadir./employment.csv" delimiter=',' missover dsd
           lrecl=32767 firstobs=2 termstr=crlf;
    length loan_id $10 employment_status $15 employer_type $15;
    input loan_id $ employment_status $ employer_type $
          years_employed annual_income monthly_debt
          employment_verified income_verified;
run;

/* --- payment_history.csv ------------------------------------------------- */
data work.payment_history;
    infile "&datadir./payment_history.csv" delimiter=',' missover dsd
           lrecl=32767 firstobs=2 termstr=crlf;
    length payment_id $10 loan_id $10 payment_status $15;
    informat payment_date yymmdd10.;
    format payment_date yymmdd10.;
    input payment_id $ loan_id $ payment_date amount_due amount_paid
          days_late payment_status $;
run;

/* Quick row-count check */
%macro rowcount(ds);
    %let dsid = %sysfunc(open(&ds));
    %let n    = %sysfunc(attrn(&dsid, nlobs));
    %let rc   = %sysfunc(close(&dsid));
    %put NOTE: &ds has &n observations.;
%mend;
%rowcount(work.loan_applications)
%rowcount(work.credit_history)
%rowcount(work.employment)
%rowcount(work.payment_history)

/* ========================================================================
   2. DATA CARD — contents and sample rows for each table
   ======================================================================== */
title "DATA CARD: loan_applications";
proc contents data=work.loan_applications; run;
proc print data=work.loan_applications(obs=5); run;

title "DATA CARD: credit_history";
proc contents data=work.credit_history; run;
proc print data=work.credit_history(obs=5); run;

title "DATA CARD: employment";
proc contents data=work.employment; run;
proc print data=work.employment(obs=5); run;

title "DATA CARD: payment_history";
proc contents data=work.payment_history; run;
proc print data=work.payment_history(obs=5); run;

/* Missing value summary */
title "Missing Values — loan_applications";
proc means data=work.loan_applications nmiss n; run;

title "Missing Values — credit_history";
proc means data=work.credit_history nmiss n; run;

title "Missing Values — employment";
proc means data=work.employment nmiss n; run;

title "Missing Values — payment_history";
proc means data=work.payment_history nmiss n; run;

/* ========================================================================
   3. BASIC SUMMARY STATISTICS
   ======================================================================== */
title "Summary Statistics — loan_applications";
proc means data=work.loan_applications n mean std min median max;
    var loan_amount loan_term_months interest_rate
        loan_to_value debt_to_income defaulted;
run;

title "Frequency — loan_applications (categorical)";
proc freq data=work.loan_applications;
    tables loan_purpose property_type / nocum;
run;

title "Summary Statistics — credit_history";
proc means data=work.credit_history n mean std min median max;
    var credit_score credit_accounts credit_utilization
        bankruptcies delinquencies_2yr inquiries_6mo
        oldest_account_years total_credit_limit;
run;

title "Summary Statistics — employment";
proc means data=work.employment n mean std min median max;
    var years_employed annual_income monthly_debt
        employment_verified income_verified;
run;

title "Frequency — employment (categorical)";
proc freq data=work.employment;
    tables employment_status employer_type / nocum;
run;

title "Summary Statistics — payment_history";
proc means data=work.payment_history n mean std min median max;
    var amount_due amount_paid days_late;
run;

title "Frequency — payment_history (categorical)";
proc freq data=work.payment_history;
    tables payment_status / nocum;
run;

/* ========================================================================
   4. FEATURE ENGINEERING — Payment Behavior
   ======================================================================== */
proc sql;
    create table work.pmt_features as
    select
        loan_id,
        count(*)                                as total_payments,
        sum(days_late > 0)                      as late_payment_count,
        calculated late_payment_count / calculated total_payments
                                                as late_payment_rate,
        sum(days_late >= 60)                    as severe_delinquency_count,
        mean(days_late)                         as avg_days_late,
        max(days_late)                          as max_days_late,
        sum(amount_due - amount_paid)           as total_shortfall,
        mean(case when amount_due > 0
             then (amount_due - amount_paid) / amount_due
             else 0 end)                        as avg_shortfall_ratio,
        sum(payment_status = 'On Time')         as on_time_count,
        calculated on_time_count / calculated total_payments
                                                as on_time_rate
    from work.payment_history
    group by loan_id;
quit;

data work.pmt_features;
    set work.pmt_features;
    severe_delinquency_flag = (severe_delinquency_count > 0);
    if total_shortfall < 0 then total_shortfall = 0;
run;

/* ========================================================================
   5. FEATURE ENGINEERING — Credit Features
   ======================================================================== */
data work.credit_features;
    set work.credit_history;

    /* FICO score bands */
    length fico_band $12;
    if credit_score >= 750      then fico_band = 'Excellent';
    else if credit_score >= 700 then fico_band = 'Good';
    else if credit_score >= 650 then fico_band = 'Fair';
    else if credit_score >= 600 then fico_band = 'Poor';
    else                             fico_band = 'Very Poor';

    /* Credit utilization category */
    length utilization_cat $10;
    if credit_utilization <= 0.30      then utilization_cat = 'Low';
    else if credit_utilization <= 0.50 then utilization_cat = 'Moderate';
    else if credit_utilization <= 0.75 then utilization_cat = 'High';
    else                                    utilization_cat = 'Very High';

    /* Derived flags */
    has_bankruptcy    = (bankruptcies > 0);
    has_delinquency   = (delinquencies_2yr > 0);
    high_inquiries    = (inquiries_6mo >= 3);
run;

/* ========================================================================
   6. FEATURE ENGINEERING — Employment Features
   ======================================================================== */
data work.emp_features;
    set work.employment;

    /* Debt service ratio */
    if annual_income > 0 then
        debt_service_ratio = (monthly_debt * 12) / annual_income;
    else
        debt_service_ratio = .;

    /* Income bands */
    length income_band $15;
    if annual_income >= 100000      then income_band = 'High';
    else if annual_income >= 60000  then income_band = 'Middle';
    else if annual_income >= 35000  then income_band = 'Low-Middle';
    else                                 income_band = 'Low';

    /* Years employed bands */
    length tenure_band $10;
    if years_employed >= 10      then tenure_band = 'Veteran';
    else if years_employed >= 5  then tenure_band = 'Established';
    else if years_employed >= 2  then tenure_band = 'Developing';
    else                              tenure_band = 'New';

    /* Verification flags are already numeric (0/1) */
run;

/* ========================================================================
   7. BUILD THE ANALYTICAL BASE TABLE
   ======================================================================== */
proc sql;
    create table work.abt_raw as
    select
        a.loan_id,
        a.loan_amount,
        a.loan_term_months,
        a.interest_rate,
        a.loan_purpose,
        a.property_type,
        a.loan_to_value,
        a.debt_to_income,
        a.defaulted,

        /* Credit features */
        c.credit_score,
        c.credit_accounts,
        c.credit_utilization,
        c.bankruptcies,
        c.delinquencies_2yr,
        c.inquiries_6mo,
        c.oldest_account_years,
        c.total_credit_limit,
        c.fico_band,
        c.utilization_cat,
        c.has_bankruptcy,
        c.has_delinquency,
        c.high_inquiries,

        /* Employment features */
        e.employment_status,
        e.employer_type,
        e.years_employed,
        e.annual_income,
        e.monthly_debt,
        e.employment_verified,
        e.income_verified,
        e.debt_service_ratio,
        e.income_band,
        e.tenure_band,

        /* Payment behavior features */
        p.total_payments,
        p.late_payment_count,
        p.late_payment_rate,
        p.severe_delinquency_count,
        p.severe_delinquency_flag,
        p.avg_days_late,
        p.max_days_late,
        p.total_shortfall,
        p.avg_shortfall_ratio,
        p.on_time_count,
        p.on_time_rate

    from work.loan_applications a
    left join work.credit_features c on a.loan_id = c.loan_id
    left join work.emp_features    e on a.loan_id = e.loan_id
    left join work.pmt_features    p on a.loan_id = p.loan_id;
quit;

/* Fill missing values and one-hot encode */
data work.abt;
    set work.abt_raw;

    /* Fill missing payment features (loans with no payment history) */
    array pmt_vars{*} total_payments late_payment_count late_payment_rate
        severe_delinquency_count severe_delinquency_flag avg_days_late
        max_days_late total_shortfall avg_shortfall_ratio
        on_time_count on_time_rate;
    do i = 1 to dim(pmt_vars);
        if pmt_vars{i} = . then pmt_vars{i} = 0;
    end;

    /* Fill missing debt_service_ratio */
    if debt_service_ratio = . then debt_service_ratio = 0;

    /* One-hot encode loan_purpose */
    purpose_Purchase     = (loan_purpose = 'Purchase');
    purpose_Refinance    = (loan_purpose = 'Refinance');
    purpose_HomeEquity   = (loan_purpose = 'Home Equity');
    purpose_DebtConsol   = (loan_purpose = 'Debt Consolidation');
    purpose_Other        = (purpose_Purchase = 0 and purpose_Refinance = 0
                            and purpose_HomeEquity = 0 and purpose_DebtConsol = 0);

    /* One-hot encode property_type */
    prop_SingleFamily    = (property_type = 'Single Family');
    prop_Condo           = (property_type = 'Condo');
    prop_MultiFamily     = (property_type = 'Multi-Family');
    prop_Townhouse       = (property_type = 'Townhouse');

    /* One-hot encode employment_status */
    emp_FullTime         = (employment_status = 'Full-Time');
    emp_PartTime         = (employment_status = 'Part-Time');
    emp_SelfEmployed     = (employment_status = 'Self-Employed');
    emp_Retired          = (employment_status = 'Retired');

    /* One-hot encode employer_type */
    emplr_Private        = (employer_type = 'Private');
    emplr_Public         = (employer_type = 'Public');
    emplr_NonProfit      = (employer_type = 'Non-Profit');
    emplr_Self           = (employer_type = 'Self');

    /* One-hot encode fico_band */
    fico_Excellent       = (fico_band = 'Excellent');
    fico_Good            = (fico_band = 'Good');
    fico_Fair            = (fico_band = 'Fair');
    fico_Poor            = (fico_band = 'Poor');
    fico_VeryPoor        = (fico_band = 'Very Poor');

    /* One-hot encode utilization_cat */
    util_Low             = (utilization_cat = 'Low');
    util_Moderate        = (utilization_cat = 'Moderate');
    util_High            = (utilization_cat = 'High');
    util_VeryHigh        = (utilization_cat = 'Very High');

    /* One-hot encode income_band */
    inc_High             = (income_band = 'High');
    inc_Middle           = (income_band = 'Middle');
    inc_LowMiddle        = (income_band = 'Low-Middle');
    inc_Low              = (income_band = 'Low');

    /* One-hot encode tenure_band */
    ten_Veteran          = (tenure_band = 'Veteran');
    ten_Established      = (tenure_band = 'Established');
    ten_Developing       = (tenure_band = 'Developing');
    ten_New              = (tenure_band = 'New');

    drop loan_purpose property_type employment_status employer_type
         fico_band utilization_cat income_band tenure_band i;
run;

/* ========================================================================
   8. DEFAULT DISTRIBUTION
   ======================================================================== */
title "Default Distribution in Analytical Base Table";
proc freq data=work.abt;
    tables defaulted / nocum;
run;

title "Default Rate by FICO Band";
proc sql;
    select
        case
            when fico_Excellent = 1 then 'Excellent'
            when fico_Good      = 1 then 'Good'
            when fico_Fair      = 1 then 'Fair'
            when fico_Poor      = 1 then 'Poor'
            when fico_VeryPoor  = 1 then 'Very Poor'
        end as fico_band,
        count(*) as n,
        mean(defaulted) as default_rate format=percent8.1
    from work.abt
    group by calculated fico_band;
quit;

title "Default Rate by Income Band";
proc sql;
    select
        case
            when inc_High      = 1 then 'High'
            when inc_Middle    = 1 then 'Middle'
            when inc_LowMiddle = 1 then 'Low-Middle'
            when inc_Low       = 1 then 'Low'
        end as income_band,
        count(*) as n,
        mean(defaulted) as default_rate format=percent8.1
    from work.abt
    group by calculated income_band;
quit;

/* ========================================================================
   9. SAVE THE ABT
   ======================================================================== */
proc export data=work.abt
    outfile="&datadir./financial_services_abt.csv"
    dbms=csv replace;
run;

title "ABT Summary";
proc contents data=work.abt short; run;
proc means data=work.abt n nmiss mean std min max;
run;

title;
%put NOTE: Step 2 complete. Analytical Base Table saved to &datadir./financial_services_abt.csv;
