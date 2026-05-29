# E-Commerce Customer Churn Prediction

While this use case has a structure to it, please feel free to explore left and right of the path! Try out your own ideas, ask new questions or skip things that aren't of interest to you!

First you will get a quick introduction to the use case, then an overview of the five steps you will take while going through this SAS Hackathon Bootcamp experience, then follow a structure of the repository, an overview of the data sets and the five topic areas that will be covered. After that there is a deeper dive into the business use case, feel free to explore that as you see fit.

## Retail Use Case — Data and AI Life Cycle

This use case walks you through the complete **Data and AI Life Cycle** using a realistic e-commerce customer churn prediction scenario, powered by SAS Viya technology.

## Business Context

**Company:** ShopEase (fictional online retail platform)
**Problem:** Monthly customer churn rate of 12% is significantly impacting revenue
**Goal:** Predict which customers are likely to churn, understand why, and automate retention actions

## The 5 Steps

| Step | What You Will Do | SAS Technology |
|------|-----------------|----------------|
| [**1. Ask & Access**](1-ask-and-access/) | Understand the business problem, explore available data, generate synthetic data | [SAS Data Maker](https://www.sas.com/en_us/software/data-maker.html) |
| [**2. Prepare**](2-prepare/) | Load, profile, and join data into an Analytical Base Table (SAS, Python, or R) | [SAS Viya Workbench](https://www.sas.com/en_us/23289/2323/workbench.html) |
| [**3. Explore**](3-explore/) | Visually explore churn patterns with AI-assisted analysis | [SAS Visual Analytics](https://www.sas.com/en_us/software/visual-analytics.html) + Copilot |
| [**4. Model**](4-model/) | Build models with AutoML, assess fairness, register to Model Manager | [SAS Model Studio](https://www.sas.com/en_us/software/model-manager.html) + Copilot |
| [**5. Deploy & Act**](5-deploy-act/) | Create automated decisions, explore agentic workflows | [SAS Intelligent Decisioning](https://www.sas.com/en_us/software/intelligent-decisioning.html) + Copilot |

## Project Structure

```
use-case-retail/
├── README.md                        # This file
├── data/                            # Raw datasets
│   ├── customers.csv                # Customer demographics (1,000 records)
│   ├── transactions.csv             # Purchase history (~5,000 records)
│   ├── sessions.csv                 # Website activity (~10,000 records)
│   └── support_tickets.csv          # Customer service records (~400 records)
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
└── 5-deploy-act/
    └── README.md                    # SAS Intelligent Decisioning guide
```

## Datasets

| Dataset | Records | Description |
|---------|---------|-------------|
| `customers.csv` | 1,000 | Customer profiles with demographics and churn labels |
| `transactions.csv` | ~5,000 | 12 months of purchase history |
| `sessions.csv` | ~10,000 | Website browsing behavior |
| `support_tickets.csv` | ~400 | Customer service interactions |

### Data Quality Notes

- Data covers January 2023 - December 2023 (12 months)
- Churn label available in customers.csv (`churned` column: 1 = churned, 0 = active)
- All datasets can be joined via `customer_id`

## Topic Areas Covered

- **Synthetic Data** — Generate privacy-safe data with SAS Data Maker
- **Developer Experience** — Code in SAS, Python, or R in SAS Viya Workbench
- **Copilots** — AI-assisted exploration, modeling, and decisioning
- **Trustworthy AI** — Fairness assessment and model governance
- **Agentic AI** — Decisions as tools for agents and autonomous decision workflows

## Business Understanding

### Company Background

**ShopEase** is an e-commerce platform serving 1,000+ active customers across the United States. The company offers products in Electronics, Clothing, Home & Garden, and Books categories through a web and mobile platform.

### Problem Statement

The company is experiencing a **12% monthly customer churn rate**, significantly impacting revenue and growth. Leadership wants to understand why customers are leaving and identify at-risk customers before they churn.

**What does this mean in practice?** Every month, roughly 120 out of every 1,000 customers stop purchasing. Acquiring a new customer costs 5-7x more than retaining an existing one, making this churn rate a direct threat to profitability. If ShopEase can predict which customers are about to leave, it can intervene with targeted retention offers, personalized outreach, or service improvements — turning potential losses into saved relationships.

### Business Objectives

1. **Primary Goal:** Reduce monthly churn rate from 12% to 8% within 6 months
2. **Secondary Goals:**
   - Identify top 5 factors driving customer churn
   - Create an early warning system for at-risk customers
   - Enable proactive retention campaigns

### Success Criteria

- Churn prediction model with **≥80% accuracy**
- Actionable insights for the retention team
- ROI-positive retention campaign within 3 months

### Initial Hypotheses

Based on domain knowledge and preliminary exploration, we hypothesize:

| # | Hypothesis | Metrics to Test |
|---|-----------|-----------------|
| H1 | **Engagement Drives Retention** — Customers with low engagement (fewer sessions, shorter durations) are more likely to churn | Average session duration, sessions per month, pages viewed per session |
| H2 | **Purchase Frequency Matters** — Customers who purchase less frequently or have decreasing transaction amounts are at higher churn risk | Number of transactions, average order value, days since last purchase |
| H3 | **Support Issues Indicate Risk** — Customers with multiple support tickets, especially unresolved or low-satisfaction ones, are more likely to churn | Number of support tickets, ticket priority distribution, average satisfaction score |
| H4 | **Subscription Tier Impacts Churn** — Basic tier customers churn at higher rates than Premium customers due to lower investment/commitment | Churn rate by subscription tier |
| H5 | **Email Opt-Out Signals Disengagement** — Customers who have opted out of marketing emails are less engaged and more likely to churn | Churn rate by email_opt_in status |

## Scope

### In Scope

- Customers active during the January–December 2023 observation period
- All four data sources (customers, transactions, sessions, support tickets)
- Binary classification: churned (1) vs. active (0)
- Fairness assessment on subscription tier

### Out of Scope

- Real-time fraud detection (separate initiative)
- Product recommendation engine
- External market or competitor data
- Pricing strategy optimization

## Stakeholder Alignment

Before building models, confirm alignment with key stakeholders:

| Stakeholder | What They Need |
|------------|---------------|
| **VP of Marketing** | Targeting criteria for retention campaigns, ROI projections for campaign spend |
| **Head of Customer Experience** | Root cause insights into churn drivers, service improvement recommendations |
| **Product Manager** | Feature-level engagement data to prioritize product roadmap decisions |
| **Data Science Lead** | Model performance targets, fairness requirements, deployment timeline |
| **CFO** | Revenue impact analysis, customer lifetime value preservation estimates |