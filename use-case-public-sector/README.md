# Citizen Service Request Prioritization

While this use case has a structure to it, please feel free to explore left and right of the path! Try out your own ideas, ask new questions or skip things that aren't of interest to you!

First you will get a quick introduction to the use case, then an overview of the five steps you will take while going through this SAS Hackathon Bootcamp experience, then follow a structure of the repository, an overview of the data sets and the five topic areas that will be covered. After that there is a deeper dive into the business use case, feel free to explore that as you see fit.

## Public Sector Use Case — Data and AI Life Cycle

This use case walks you through the complete **Data and AI Life Cycle** using a realistic citizen service request prioritization scenario, powered by SAS Viya technology.

## Business Context

**Organization:** Metro City (fictional municipality, population 850,000, 12 districts)
**Problem:** 15,000 service requests per month with 40% response time variance across districts and growing equity concerns
**Goal:** Predict which service requests are urgent, reduce average response time from 48.2 to 36 hours, and improve citizen satisfaction from 3.2 to 3.7 out of 5.0

## The 5 Steps

| Step | What You Will Do | SAS Technology |
|------|-----------------|----------------|
| [**1. Ask & Access**](1-ask-and-access/) | Understand the business problem, explore available data, generate synthetic data | [SAS Data Maker](https://www.sas.com/en_us/software/data-maker.html) |
| [**2. Prepare**](2-prepare/) | Load, profile, and join data into an Analytical Base Table (SAS, Python, or R) | [SAS Viya Workbench](https://www.sas.com/en_us/23289/2323/workbench.html) |
| [**3. Explore**](3-explore/) | Visually explore service request patterns with AI-assisted analysis | [SAS Visual Analytics](https://www.sas.com/en_us/software/visual-analytics.html) + Copilot |
| [**4. Model**](4-model/) | Build models with AutoML, assess fairness, register to Model Manager | [SAS Model Studio](https://www.sas.com/en_us/software/model-manager.html) + Copilot |
| [**5. Deploy & Act**](5-deploy-and-act/) | Create automated decisions, explore agentic workflows | [SAS Intelligent Decisioning](https://www.sas.com/en_us/software/intelligent-decisioning.html) + Copilot |

## Project Structure

```
use-case-public-sector/
├── README.md                        # This file
├── data/                            # Raw datasets
│   ├── service_requests.csv         # Service request records (500 records)
│   ├── citizens.csv                 # Citizen profiles (300 records)
│   ├── department_performance.csv   # Department monthly metrics (96 records)
│   └── request_history.csv          # Historical request volumes (~3,456 records)
│
├── 1-ask-and-access/
│   └── README.md                    # Business understanding + synthetic data + SAS Data Maker
│
├── 2-prepare/
│   ├── README.md                    # Guide for data preparation
│   ├── data_preparation.sas         # SAS code
│   ├── data_preparation.py          # Python code
│   └── data_preparation.R           # R code
│
├── 3-explore/
│   └── README.md                    # SAS Visual Analytics exploration guide
│
├── 4-model/
│   └── README.md                    # SAS Model Studio modeling guide
│
└── 5-deploy-and-act/
    └── README.md                    # SAS Intelligent Decisioning guide
```

## Datasets

| Dataset | Records | Description |
|---------|---------|-------------|
| `service_requests.csv` | 500 | Individual service request records with priority, response time, and satisfaction |
| `citizens.csv` | 300 | Citizen profiles with demographics, district, and service history |
| `department_performance.csv` | 96 | Monthly performance metrics by department |
| `request_history.csv` | ~3,456 | Historical request volumes by district, department, and priority |

### Data Quality Notes

- Service requests data covers 2024 (12 months)
- Target variable is derived: `is_urgent` = 1 if `priority_level` is Critical or High, 0 otherwise
- `citizen_id` links `service_requests` to `citizens`
- `department` links `service_requests` to `department_performance`
- `request_history` provides aggregate trends by district and department over multiple years

## Topic Areas Covered

- **Synthetic Data** — Generate privacy-safe data with SAS Data Maker
- **Developer Experience** — Code in SAS, Python, or R in SAS Viya Workbench
- **Copilots** — AI-assisted exploration, modeling, and decisioning
- **Trustworthy AI** — Fairness assessment and model governance
- **Agentic AI** — Decisions as tools for agents and autonomous decision workflows

## Business Understanding

### Organization Background

**Metro City** is a mid-sized municipality that processes approximately 15,000 citizen service requests per month across departments including Public Works, Parks & Recreation, Transportation, Building & Safety, and others. Requests range from pothole repairs and streetlight outages to permit inquiries and noise complaints. The city operates a 311 service center, an online portal, and a mobile app for request submission.

### Problem Statement

Metro City is experiencing a **40% variance in average response times across its 12 districts**, with the overall average sitting at **48.2 hours** — well above the 36-hour target. Citizen satisfaction has declined to **3.2 out of 5.0**, and there are growing concerns about **service equity**: are some neighborhoods consistently receiving slower responses than others? Are urgent requests being identified and escalated quickly enough?

**What does this mean in practice?** A water main break in one district might wait 60 hours while a cosmetic sidewalk complaint in another district gets resolved in 20 hours. Without a systematic way to assess request urgency and allocate resources, departments rely on first-come-first-served processing — which fails to account for the severity, safety implications, or equity dimensions of each request. If Metro City can predict which requests are truly urgent, it can triage them faster, route them to the right department with the right priority, and ensure all districts receive equitable service.

### Business Objectives

1. **Primary Goal:** Reduce average response time from 48.2 to 36 hours within 6 months
2. **Secondary Goals:**
   - Improve citizen satisfaction from 3.2 to 3.7 out of 5.0
   - Achieve less than 10% response time variance between districts
   - Ensure urgent requests (Critical and High priority) are identified with at least 90% recall
   - Comply with Public Records Act, ADA requirements, and algorithmic bias prevention policies

### Success Criteria

- Urgency prediction model with **accuracy greater than 85%**
- **Recall greater than 90%** for urgent requests (do not miss Critical or High priority requests)
- Equitable model performance across all 12 districts
- Actionable triage system that routes requests in real time

### Initial Hypotheses

Based on domain knowledge and preliminary exploration, we hypothesize:

| # | Hypothesis | Metrics to Test |
|---|-----------|-----------------|
| H1 | **Request Type Drives Urgency** — Certain request types (e.g., water main breaks, safety hazards) are inherently more urgent than others (e.g., cosmetic repairs, permit inquiries) | Urgency rate by request type, response time by request type |
| H2 | **Department Capacity Affects Response** — Departments with higher workloads, lower staff counts, or higher budget utilization have slower response times and lower resolution rates | Average response time vs. staff count, requests per staff member, budget utilization vs. resolution rate |
| H3 | **District Equity Matters** — Some districts consistently receive slower service, potentially correlated with request volume, district demographics, or resource allocation | Response time by district, satisfaction by district, resolution rate by district |
| H4 | **Seasonal Patterns Exist** — Request volumes and types vary by season (e.g., potholes spike after winter, park complaints rise in summer), affecting department workload and response times | Monthly request counts, seasonal response time trends, priority distribution by month |
| H5 | **Citizen History Predicts Engagement** — Citizens with more previous requests and higher historical satisfaction are more engaged and may submit higher-quality, more actionable requests | Previous requests vs. response time, satisfaction history vs. current satisfaction |

## Scope

### In Scope

- Service requests submitted during the 2024 observation period
- All four data sources (service requests, citizens, department performance, request history)
- Binary classification: urgent (1) vs. non-urgent (0), derived from priority_level
- Fairness assessment across districts (location_district)

### Out of Scope

- Budget allocation and financial planning
- Personnel management and staffing optimization
- External factors (weather events, population changes)
- Cross-jurisdiction service agreements

## Stakeholder Alignment

Before building models, confirm alignment with key stakeholders:

| Stakeholder | What They Need |
|------------|---------------|
| **City Manager** | Measurable improvement in response times and citizen satisfaction scores |
| **District Council Members** | Evidence of equitable service delivery across all 12 districts |
| **Department Heads** | Actionable triage recommendations, workload balancing insights |
| **IT Director** | Integration plan with 311 system, data governance compliance |
| **Equity & Inclusion Officer** | Fairness assessment across districts, bias mitigation evidence |