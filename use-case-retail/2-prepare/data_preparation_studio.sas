/******************************************************************************
 * Step 2: Data Preparation (SAS)
 * =============================================================================
 * Load, profile, and join the four ShopEase datasets into an
 * Analytical Base Table (ABT) for churn prediction.
 *
 * Run this program in a SAS session inside SAS Studio.
 *
 * Outputs:
 *   - data/retail_abt.csv
 *   - Log: data cards, summary statistics, churn distribution
 ******************************************************************************/

/* -----------------------------------------------------------------------
   Configuration — adjust the path if your working directory differs
   ----------------------------------------------------------------------- */
%let datadir = &_USERHOME./sas-hackathon-boot-camp-2026/use-case-retail/data;

/* ========================================================================
   1. LOAD THE DATA
   ========================================================================
   The CSV files may have Windows line endings (CR+LF). We use TERMSTR=CRLF
   on the INFILE statement so SAS strips the carriage return properly.
   ======================================================================== */
title "Step 2: Data Preparation (SAS)";

/* --- customers.csv ------------------------------------------------------ */
data work.customers;
    infile "&datadir./customers.csv" delimiter=',' missover dsd
           lrecl=32767 firstobs=2 termstr=crlf;
    length customer_id $5 gender $1 location $25 subscription_tier $8;
    informat signup_date yymmdd10.;
    format signup_date yymmdd10.;
    input customer_id $ signup_date age gender $ location $
          subscription_tier $ email_opt_in churned;
run;

/* --- transactions.csv --------------------------------------------------- */
data work.transactions;
    infile "&datadir./transactions.csv" delimiter=',' missover dsd
           lrecl=32767 firstobs=2 termstr=crlf;
    length transaction_id $5 customer_id $5 product_category $15 payment_method $15;
    informat transaction_date yymmdd10.;
    format transaction_date yymmdd10.;
    input transaction_id $ customer_id $ transaction_date
          amount product_category $ payment_method $ discount_applied;
run;

/* --- sessions.csv ------------------------------------------------------- */
data work.sessions;
    infile "&datadir./sessions.csv" delimiter=',' missover dsd
           lrecl=32767 firstobs=2 termstr=crlf;
    length session_id $5 customer_id $5 device_type $10 referral_source $15;
    informat session_date yymmdd10.;
    format session_date yymmdd10.;
    input session_id $ customer_id $ session_date
          duration_minutes pages_viewed device_type $
          referral_source $ cart_abandonment;
run;

/* --- support_tickets.csv ------------------------------------------------ */
data work.support_tickets;
    infile "&datadir./support_tickets.csv" delimiter=',' missover dsd
           lrecl=32767 firstobs=2 termstr=crlf;
    length ticket_id $5 customer_id $5 issue_category $20 priority $6;
    informat ticket_date yymmdd10.;
    format ticket_date yymmdd10.;
    input ticket_id $ customer_id $ ticket_date
          issue_category $ priority $ resolution_time_hours
          satisfaction_score resolved;
run;

/* Quick row-count check */
%macro rowcount(ds);
    %let dsid = %sysfunc(open(&ds));
    %let n    = %sysfunc(attrn(&dsid, nlobs));
    %let rc   = %sysfunc(close(&dsid));
    %put NOTE: &ds has &n observations.;
%mend;
%rowcount(work.customers)
%rowcount(work.transactions)
%rowcount(work.sessions)
%rowcount(work.support_tickets)

/* ========================================================================
   2. DATA CARD — contents and row counts for each table
   ======================================================================== */
title "DATA CARD: customers";
proc contents data=work.customers; run;
proc print data=work.customers(obs=5); run;

title "DATA CARD: transactions";
proc contents data=work.transactions; run;
proc print data=work.transactions(obs=5); run;

title "DATA CARD: sessions";
proc contents data=work.sessions; run;
proc print data=work.sessions(obs=5); run;

title "DATA CARD: support_tickets";
proc contents data=work.support_tickets; run;
proc print data=work.support_tickets(obs=5); run;

/* Missing value summary */
title "Missing Values — customers";
proc means data=work.customers nmiss n; run;

title "Missing Values — transactions";
proc means data=work.transactions nmiss n; run;

title "Missing Values — sessions";
proc means data=work.sessions nmiss n; run;

title "Missing Values — support_tickets";
proc means data=work.support_tickets nmiss n; run;

/* ========================================================================
   3. BASIC SUMMARY STATISTICS
   ======================================================================== */
title "Summary Statistics — customers";
proc means data=work.customers n mean std min median max;
    var age churned email_opt_in;
run;

title "Frequency — customers (categorical)";
proc freq data=work.customers;
    tables gender subscription_tier location / nocum;
run;

title "Summary Statistics — transactions";
proc means data=work.transactions n mean std min median max;
    var amount discount_applied;
run;

title "Frequency — transactions (categorical)";
proc freq data=work.transactions;
    tables product_category payment_method / nocum;
run;

title "Summary Statistics — sessions";
proc means data=work.sessions n mean std min median max;
    var duration_minutes pages_viewed cart_abandonment;
run;

title "Frequency — sessions (categorical)";
proc freq data=work.sessions;
    tables device_type referral_source / nocum;
run;

title "Summary Statistics — support_tickets";
proc means data=work.support_tickets n mean std min median max;
    var resolution_time_hours satisfaction_score resolved;
run;

title "Frequency — support_tickets (categorical)";
proc freq data=work.support_tickets;
    tables issue_category priority / nocum;
run;

/* ========================================================================
   4. FEATURE ENGINEERING — Transactions
   ======================================================================== */
proc sql;
    create table work.txn_features as
    select
        customer_id,
        count(*)                           as total_transactions,
        sum(amount)                        as total_spend,
        mean(amount)                       as avg_order_value,
        std(amount)                        as std_order_value,
        max(amount)                        as max_order_value,
        min(amount)                        as min_order_value,
        intck('day', max(transaction_date), '31DEC2023'd) as days_since_last_purchase,
        intck('day', min(transaction_date), max(transaction_date)) as customer_tenure_days,
        mean(discount_applied)             as avg_discount_rate,
        count(distinct product_category)   as unique_categories
    from work.transactions
    group by customer_id;
quit;

data work.txn_features;
    set work.txn_features;
    if std_order_value = . then std_order_value = 0;
    if customer_tenure_days > 0 then
        purchase_frequency = total_transactions / (customer_tenure_days / 30);
    else
        purchase_frequency = total_transactions;
run;

/* ========================================================================
   5. FEATURE ENGINEERING — Sessions
   ======================================================================== */
proc sql;
    create table work.sess_features as
    select
        customer_id,
        count(*)                          as total_sessions,
        sum(duration_minutes)             as total_session_duration,
        mean(duration_minutes)            as avg_session_duration,
        max(duration_minutes)             as max_session_duration,
        sum(pages_viewed)                 as total_pages_viewed,
        mean(pages_viewed)                as avg_pages_per_session,
        max(pages_viewed)                 as max_pages_per_session,
        sum(cart_abandonment)             as total_cart_abandonments,
        mean(cart_abandonment)            as cart_abandonment_rate,
        mean(device_type = 'Mobile')      as mobile_session_rate,
        count(distinct referral_source)   as unique_referral_sources
    from work.sessions
    group by customer_id;
quit;

/* ========================================================================
   6. FEATURE ENGINEERING — Support Tickets
   ======================================================================== */
proc sql;
    create table work.sup_features as
    select
        customer_id,
        count(*)                          as total_tickets,
        sum(priority = 'High')            as high_priority_tickets,
        mean(resolution_time_hours)       as avg_resolution_time,
        max(resolution_time_hours)        as max_resolution_time,
        mean(satisfaction_score)          as avg_satisfaction_score,
        mean(resolved)                    as ticket_resolution_rate,
        count(distinct issue_category)    as unique_issue_types
    from work.support_tickets
    group by customer_id;
quit;

/* ========================================================================
   7. BUILD THE ANALYTICAL BASE TABLE
   ======================================================================== */
data work.cust_base;
    set work.customers;
    account_age_days = intck('day', signup_date, '31DEC2023'd);
    drop signup_date location;
run;

proc sql;
    create table work.abt_raw as
    select
        c.*,
        t.total_transactions,    t.total_spend,       t.avg_order_value,
        t.std_order_value,       t.max_order_value,    t.min_order_value,
        t.days_since_last_purchase, t.customer_tenure_days,
        t.purchase_frequency,    t.avg_discount_rate,  t.unique_categories,
        s.total_sessions,        s.total_session_duration,
        s.avg_session_duration,  s.max_session_duration,
        s.total_pages_viewed,    s.avg_pages_per_session,
        s.max_pages_per_session, s.total_cart_abandonments,
        s.cart_abandonment_rate, s.mobile_session_rate,
        s.unique_referral_sources,
        u.total_tickets,         u.high_priority_tickets,
        u.avg_resolution_time,   u.max_resolution_time,
        u.avg_satisfaction_score,u.ticket_resolution_rate,
        u.unique_issue_types
    from work.cust_base c
    left join work.txn_features  t on c.customer_id = t.customer_id
    left join work.sess_features s on c.customer_id = s.customer_id
    left join work.sup_features  u on c.customer_id = u.customer_id;
quit;

/* Fill missing values */
data work.abt;
    set work.abt_raw;

    /* Customers with no transactions */
    array txn_vars{*} total_transactions total_spend avg_order_value
        std_order_value max_order_value min_order_value
        days_since_last_purchase customer_tenure_days
        purchase_frequency avg_discount_rate unique_categories;
    do i = 1 to dim(txn_vars);
        if txn_vars{i} = . then txn_vars{i} = 0;
    end;

    /* Customers with no sessions */
    array sess_vars{*} total_sessions total_session_duration
        avg_session_duration max_session_duration
        total_pages_viewed avg_pages_per_session max_pages_per_session
        total_cart_abandonments cart_abandonment_rate
        mobile_session_rate unique_referral_sources;
    do j = 1 to dim(sess_vars);
        if sess_vars{j} = . then sess_vars{j} = 0;
    end;

    /* Customers with no support tickets */
    array sup_vars{*} total_tickets high_priority_tickets
        avg_resolution_time max_resolution_time
        unique_issue_types;
    do k = 1 to dim(sup_vars);
        if sup_vars{k} = . then sup_vars{k} = 0;
    end;
    if avg_satisfaction_score = . then avg_satisfaction_score = 5;
    if ticket_resolution_rate = . then ticket_resolution_rate = 1;

    /* One-hot encode subscription_tier */
    tier_Basic    = (subscription_tier = 'Basic');
    tier_Standard = (subscription_tier = 'Standard');
    tier_Premium  = (subscription_tier = 'Premium');

    /* One-hot encode gender */
    gender_F = (gender = 'F');
    gender_M = (gender = 'M');

    drop subscription_tier gender i j k;
run;

/* ========================================================================
   8. CHURN DISTRIBUTION
   ======================================================================== */
title "Churn Distribution in Analytical Base Table";
proc freq data=work.abt;
    tables churned / nocum;
run;

title "Churn Rate by Subscription Tier";
proc sql;
    select
        case
            when tier_Basic    = 1 then 'Basic'
            when tier_Standard = 1 then 'Standard'
            when tier_Premium  = 1 then 'Premium'
        end as tier,
        count(*) as n,
        mean(churned) as churn_rate format=percent8.1
    from work.abt
    group by calculated tier;
quit;

/* ========================================================================
   9. SAVE THE ABT
   ======================================================================== */
proc export data=work.abt
    outfile="&datadir./retail_abt.csv"
    dbms=csv replace;
run;

title "ABT Summary";
proc contents data=work.abt short; run;
proc means data=work.abt n nmiss mean std min max;
run;

title;
%put NOTE: Step 2 complete. Analytical Base Table saved to &datadir./retail_abt.csv;
