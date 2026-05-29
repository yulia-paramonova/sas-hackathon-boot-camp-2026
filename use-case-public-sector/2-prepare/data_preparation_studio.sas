/******************************************************************************
 * Step 2: Data Preparation (SAS)
 * =============================================================================
 * Load, profile, and join the four Metro City datasets into an
 * Analytical Base Table (ABT) for service request urgency prediction.
 *
 * Run this program in a SAS session inside SAS Studio.
 *
 * Outputs:
 *   - data/public_sector_abt.csv
 *   - Log: data cards, summary statistics, urgency distribution
 ******************************************************************************/

/* -----------------------------------------------------------------------
   Configuration — adjust the path if your working directory differs
   ----------------------------------------------------------------------- */
%let datadir = &_USERHOME./sas-hackathon-boot-camp-2026/use-case-public-sector/data;

/* ========================================================================
   1. LOAD THE DATA
   ========================================================================
   The CSV files may have Windows line endings (CR+LF). We use TERMSTR=CRLF
   on the INFILE statement so SAS strips the carriage return properly.
   ======================================================================== */
title "Step 2: Data Preparation (SAS)";

/* --- service_requests.csv ------------------------------------------------ */
data work.service_requests;
    infile "&datadir./service_requests.csv" delimiter=',' missover dsd
           lrecl=32767 firstobs=2 termstr=crlf;
    length request_id $10 citizen_id $8 request_type $30
           department $25 priority_level $8 location_district $20 resolved $5;
    informat submission_date yymmdd10.;
    format submission_date yymmdd10.;
    input request_id $ citizen_id $ submission_date request_type $
          department $ priority_level $ location_district $
          response_time_hours citizen_satisfaction resolved $;
run;

/* --- citizens.csv -------------------------------------------------------- */
data work.citizens;
    infile "&datadir./citizens.csv" delimiter=',' missover dsd
           lrecl=32767 firstobs=2 termstr=crlf;
    length citizen_id $8 age_group $10 district $20 contact_preference $15;
    informat registration_date yymmdd10.;
    format registration_date yymmdd10.;
    input citizen_id $ registration_date age_group $ district $
          contact_preference $ previous_requests satisfaction_history;
run;

/* --- department_performance.csv ------------------------------------------ */
data work.dept_perf;
    infile "&datadir./department_performance.csv" delimiter=',' missover dsd
           lrecl=32767 firstobs=2 termstr=crlf;
    length department $25;
    input department $ month year avg_response_time_hours resolution_rate
          citizen_satisfaction_avg staff_count budget_utilization
          requests_received requests_completed overtime_hours;
run;

/* --- request_history.csv ------------------------------------------------- */
data work.request_history;
    infile "&datadir./request_history.csv" delimiter=',' missover dsd
           lrecl=32767 firstobs=2 termstr=crlf;
    length district $20 department $25;
    input year month district $ department $ request_count avg_response_time
          resolution_rate priority_critical_count priority_high_count
          priority_medium_count priority_low_count;
run;

/* Quick row-count check */
%macro rowcount(ds);
    %let dsid = %sysfunc(open(&ds));
    %let n    = %sysfunc(attrn(&dsid, nlobs));
    %let rc   = %sysfunc(close(&dsid));
    %put NOTE: &ds has &n observations.;
%mend;
%rowcount(work.service_requests)
%rowcount(work.citizens)
%rowcount(work.dept_perf)
%rowcount(work.request_history)

/* ========================================================================
   2. DATA CARD — contents and row counts for each table
   ======================================================================== */
title "DATA CARD: service_requests";
proc contents data=work.service_requests; run;
proc print data=work.service_requests(obs=5); run;

title "DATA CARD: citizens";
proc contents data=work.citizens; run;
proc print data=work.citizens(obs=5); run;

title "DATA CARD: department_performance";
proc contents data=work.dept_perf; run;
proc print data=work.dept_perf(obs=5); run;

title "DATA CARD: request_history";
proc contents data=work.request_history; run;
proc print data=work.request_history(obs=5); run;

/* Missing value summary */
title "Missing Values — service_requests";
proc means data=work.service_requests nmiss n; run;

title "Missing Values — citizens";
proc means data=work.citizens nmiss n; run;

title "Missing Values — department_performance";
proc means data=work.dept_perf nmiss n; run;

title "Missing Values — request_history";
proc means data=work.request_history nmiss n; run;

/* ========================================================================
   3. BASIC SUMMARY STATISTICS
   ======================================================================== */
title "Summary Statistics — service_requests";
proc means data=work.service_requests n mean std min median max;
    var response_time_hours citizen_satisfaction;
run;

title "Frequency — service_requests (categorical)";
proc freq data=work.service_requests;
    tables request_type department priority_level location_district resolved / nocum;
run;

title "Summary Statistics — citizens";
proc means data=work.citizens n mean std min median max;
    var previous_requests satisfaction_history;
run;

title "Frequency — citizens (categorical)";
proc freq data=work.citizens;
    tables age_group district contact_preference / nocum;
run;

title "Summary Statistics — department_performance";
proc means data=work.dept_perf n mean std min median max;
    var avg_response_time_hours resolution_rate citizen_satisfaction_avg
        staff_count budget_utilization requests_received requests_completed overtime_hours;
run;

title "Summary Statistics — request_history";
proc means data=work.request_history n mean std min median max;
    var request_count avg_response_time resolution_rate
        priority_critical_count priority_high_count
        priority_medium_count priority_low_count;
run;

/* ========================================================================
   4. FEATURE ENGINEERING — Temporal Features
   ======================================================================== */
data work.sr_features;
    set work.service_requests;

    /* Temporal features from submission_date */
    day_of_week = weekday(submission_date);  /* 1=Sunday, 7=Saturday */
    is_weekend  = (day_of_week in (1, 7));
    submit_month   = month(submission_date);
    submit_quarter = qtr(submission_date);

    /* Request type encoding — inherent urgency flag */
    if request_type in ('Water Main Break', 'Gas Leak', 'Power Outage',
                        'Sewer Backup', 'Traffic Signal Malfunction',
                        'Road Hazard', 'Building Emergency')
        then inherent_urgency = 1;
    else inherent_urgency = 0;

    /* Derive target variable: is_urgent */
    is_urgent = (priority_level in ('Critical', 'High'));

    /* Convert resolved to numeric */
    resolved_flag = (upcase(resolved) = 'TRUE');

    drop resolved;
run;

/* ========================================================================
   5. FEATURE ENGINEERING — Department Average Performance
   ======================================================================== */
proc sql;
    create table work.dept_avg as
    select
        department,
        mean(avg_response_time_hours)  as dept_avg_response_time,
        mean(resolution_rate)          as dept_avg_resolution_rate,
        mean(citizen_satisfaction_avg) as dept_avg_satisfaction,
        mean(staff_count)              as dept_avg_staff_count,
        mean(budget_utilization)       as dept_avg_budget_util,
        mean(requests_received)        as dept_avg_requests_received,
        mean(overtime_hours)           as dept_avg_overtime
    from work.dept_perf
    group by department;
quit;

/* ========================================================================
   6. FEATURE ENGINEERING — District Request Volume
   ======================================================================== */
proc sql;
    create table work.district_features as
    select
        district as location_district,
        mean(request_count)       as district_avg_request_count,
        mean(avg_response_time)   as district_avg_response_time,
        mean(resolution_rate)     as district_avg_resolution_rate,
        sum(priority_critical_count) as district_total_critical,
        sum(priority_high_count)     as district_total_high
    from work.request_history
    group by district;
quit;

/* ========================================================================
   7. FEATURE ENGINEERING — Citizen History
   ======================================================================== */
data work.citizen_features;
    set work.citizens;

    /* Account age in days from a reference date (end of 2024) */
    account_age_days = intck('day', registration_date, '31DEC2024'd);

    /* Engagement score: combination of previous requests and satisfaction */
    if previous_requests > 0 then
        engagement_score = previous_requests * satisfaction_history / 5;
    else
        engagement_score = 0;

    keep citizen_id previous_requests satisfaction_history
         age_group contact_preference account_age_days engagement_score;
run;

/* ========================================================================
   8. BUILD THE ANALYTICAL BASE TABLE
   ======================================================================== */
proc sql;
    create table work.abt_raw as
    select
        sr.*,

        /* Citizen features */
        cf.previous_requests   as citizen_previous_requests,
        cf.satisfaction_history as citizen_satisfaction_history,
        cf.account_age_days    as citizen_account_age_days,
        cf.engagement_score    as citizen_engagement_score,
        cf.age_group,
        cf.contact_preference,

        /* Department features */
        da.dept_avg_response_time,
        da.dept_avg_resolution_rate,
        da.dept_avg_satisfaction,
        da.dept_avg_staff_count,
        da.dept_avg_budget_util,
        da.dept_avg_requests_received,
        da.dept_avg_overtime,

        /* District features */
        df.district_avg_request_count,
        df.district_avg_response_time,
        df.district_avg_resolution_rate,
        df.district_total_critical,
        df.district_total_high

    from work.sr_features sr
    left join work.citizen_features cf on sr.citizen_id = cf.citizen_id
    left join work.dept_avg         da on sr.department = da.department
    left join work.district_features df on sr.location_district = df.location_district;
quit;

/* Fill missing values and encode categoricals */
data work.abt;
    set work.abt_raw;

    /* Fill missing citizen features (unmatched citizen_ids) */
    if citizen_previous_requests     = . then citizen_previous_requests     = 0;
    if citizen_satisfaction_history   = . then citizen_satisfaction_history   = 3.0;
    if citizen_account_age_days      = . then citizen_account_age_days      = 365;
    if citizen_engagement_score      = . then citizen_engagement_score      = 0;

    /* Fill missing department features */
    array dept_vars{*} dept_avg_response_time dept_avg_resolution_rate
        dept_avg_satisfaction dept_avg_staff_count dept_avg_budget_util
        dept_avg_requests_received dept_avg_overtime;
    do i = 1 to dim(dept_vars);
        if dept_vars{i} = . then dept_vars{i} = 0;
    end;

    /* Fill missing district features */
    array dist_vars{*} district_avg_request_count district_avg_response_time
        district_avg_resolution_rate district_total_critical district_total_high;
    do j = 1 to dim(dist_vars);
        if dist_vars{j} = . then dist_vars{j} = 0;
    end;

    /* One-hot encode age_group */
    age_18_24 = (age_group = '18-24');
    age_25_34 = (age_group = '25-34');
    age_35_44 = (age_group = '35-44');
    age_45_54 = (age_group = '45-54');
    age_55_64 = (age_group = '55-64');
    age_65p   = (age_group = '65+');

    /* One-hot encode contact_preference */
    contact_phone  = (contact_preference = 'Phone');
    contact_email  = (contact_preference = 'Email');
    contact_sms    = (contact_preference = 'SMS');
    contact_app    = (contact_preference = 'Mobile App');
    contact_portal = (contact_preference = 'Web Portal');

    drop age_group contact_preference i j citizen_id request_id
         submission_date request_type department priority_level location_district;
run;

/* ========================================================================
   9. URGENCY DISTRIBUTION
   ======================================================================== */
title "Urgency Distribution in Analytical Base Table";
proc freq data=work.abt;
    tables is_urgent / nocum;
run;

title "Urgency Rate by Priority Level (before drop)";
proc sql;
    select
        priority_level,
        count(*) as n,
        mean(is_urgent) as urgency_rate format=percent8.1
    from work.abt_raw
    group by priority_level;
quit;

/* ========================================================================
   10. SAVE THE ABT
   ======================================================================== */
proc export data=work.abt
    outfile="&datadir./public_sector_abt.csv"
    dbms=csv replace;
run;

title "ABT Summary";
proc contents data=work.abt short; run;
proc means data=work.abt n nmiss mean std min max;
run;

title;
%put NOTE: Step 2 complete. Analytical Base Table saved to &datadir./public_sector_abt.csv;
