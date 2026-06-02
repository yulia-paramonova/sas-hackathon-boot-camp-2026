# Prédiction du risque de réadmission des patients

Bien que ce cas d’usage suive une structure définie, n’hésitez pas à explorer librement ! Testez vos propres idées, posez de nouvelles questions ou passez ce qui vous semble moins pertinent.  

Vous commencerez par une courte introduction au cas d’usage, suivie d’un aperçu des cinq étapes que vous allez parcourir durant cette expérience de SAS Hackathon Bootcamp. Vous découvrirez ensuite la structure du répertoire Git, une présentation des jeux de données ainsi que les cinq thèmes principaux abordés. Enfin, une analyse plus approfondie du contexte métier vous sera proposée — à vous de l’explorer selon vos besoins.


## Cas d’usage en sciences de la vie — Cycle de vie des données et de l’IA

Ce cas d’usage vous guide à travers l’ensemble du **cycle de vie des données et de l’IA** en utilisant un scénario réaliste de prédiction du risque de réadmission des patients, basé sur la technologie SAS Viya.

## Contexte métier

**Organisation:** MedCare Health System (réseau régional de santé fictif — 12 hôpitaux, plus de 2 millions de patients par an)

**Problème:** un taux de réadmission à 30 jours de 18,2 %, supérieur au benchmark national de 15,5 %, entraînant 12,4 M$ de pénalités annuelles du CMS

**Objectif:** prédire quels patients présentent un risque élevé de réadmission dans les 30 jours, comprendre les facteurs explicatifs et automatiser les interventions post‑sortie afin de réduire le taux à 14,5 % en 18 mois

## Les 5 étapes


| Étape | Ce que vous allez faire | Technologie SAS |
|------|------------------------|----------------|
| [**1. Ask & Access**](1-ask-and-access/) | Comprendre le problème métier, identifier les sources de données et générer des données synthétiques | [SAS Data Maker](https://www.sas.com/en_us/software/data-maker.html) |
| [**2. Prepare**](2-prepare/) | Charger, explorer et joindre les données dans une table de base analytique (ABT) (SAS, Python ou R) | [SAS Viya Workbench](https://www.sas.com/en_us/23289/2323/workbench.html) ou [SAS Studio](https://www.sas.com/en_us/software/studio.html) |
| [**3. Explore**](3-explore/) | Explorer visuellement les patterns des demandes de service avec des analyses assistées par l’IA | [SAS Visual Analytics](https://www.sas.com/en_us/software/visual-analytics.html) + [SAS Viya Copilot](https://www.sas.com/en_us/software/viya/copilot.html) |
| [**4. Model**](4-model/) | Construire des modèles avec AutoML, évaluer l’équité et enregistrer les modèles dans Model Manager | [SAS Model Studio](https://www.sas.com/en_us/software/model-manager.html) + [SAS Viya Copilot](https://www.sas.com/en_us/software/viya/copilot.html)  |
| [**5. Deploy & Act**](5-deploy-and-act/) | Mettre en place des décisions automatisées et explorer des workflows agentiques | [SAS Intelligent Decisioning](https://www.sas.com/en_us/software/intelligent-decisioning.html) + [SAS Viya Copilot](https://www.sas.com/en_us/software/viya/copilot.html)  |


## Project Structure

```
use-case-life-sciences/
├── README.md                        # This file
├── data/                            # Raw datasets
│   ├── patients.csv                 # Patient demographics (500 records)
│   ├── admissions.csv               # Admission records (500 records)
│   ├── clinical_measures.csv        # Clinical measurements (500 records)
│   └── medications.csv              # Medication records (326 records)
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

## Jeux de données

| Jeu de données | Nombre de lignes | Description |
|---------|---------|-------------|
| `patients.csv` | 500 | Données démographiques des patients avec étiquettes de réadmission |
| `admissions.csv` | 500 | Détails d’admission et de sortie |
| `clinical_measures.csv` | 500 | Signes vitaux et résultats de laboratoire |
| `medications.csv` | 326 | Prescriptions médicamenteuses et indicateurs de risques |

### Notes sur la qualité des données

- Les données couvrent les admissions de patients en 2025
- L’étiquette de réadmission est disponible dans patients.csv (colonne `readmitted_30days` : 1 = réadmis, 0 = non réadmis)
-Tous les jeux de données peuvent être joints via `patient_id`
-Tous les patients ne disposent pas de dossiers de médication (326 enregistrements de médication pour 500 patients)
-Les mesures cliniques correspondent à un enregistrement par patient au moment de l’admission

## Topic Areas Covered

- **Synthetic Data** — Generate privacy-safe data with SAS Data Maker
- **Developer Experience** — Code in SAS, Python, or R in SAS Viya Workbench
- **Copilots** — AI-assisted exploration, modeling, and decisioning
- **Trustworthy AI** — Fairness assessment and model governance
- **Agentic AI** — Decisions as tools for agents and autonomous decision workflows

## Business Understanding

### Organization Background

**MedCare Health System** is a regional healthcare network operating 12 hospitals and 45 outpatient facilities, serving over 2 million patients annually across medical, surgical, and cardiac service lines. MedCare's mission is to deliver high-quality, patient-centered care while maintaining operational efficiency.

### Problem Statement

MedCare is experiencing a **18.2% 30-day readmission rate**, significantly exceeding the national benchmark of 15.5%. This gap is costing the organization an estimated **$12.4 million per year** in Centers for Medicare & Medicaid Services (CMS) penalties under the Hospital Readmissions Reduction Program (HRRP).

**What does this mean in practice?** For every 1,000 discharged patients, roughly 182 return to the hospital within 30 days — many of these readmissions are preventable with the right post-discharge support. Beyond the financial penalties, readmissions signal gaps in care transitions: patients may be discharged without adequate medication reconciliation, follow-up appointments, or understanding of their self-care instructions. If MedCare can identify high-risk patients before they leave the hospital, care teams can intervene with targeted discharge planning, follow-up calls, home health referrals, and medication management — reducing both costs and patient suffering.

### Business Objectives

1. **Primary Goal:** Reduce the 30-day readmission rate from 18.2% to 14.5% within 18 months
2. **Secondary Goals:**
    - Identify the top clinical and operational drivers of readmission
    - Create an at-discharge risk scoring system for care teams
    - Enable proactive care coordination for high-risk patients
    - Reduce CMS penalties from $12.4M to $7.5M annually

### Success Criteria

- Readmission prediction model with **AUC-ROC >= 0.75**
- High-risk patient identification with **sensitivity >= 0.80** (catch at least 80% of patients who will be readmitted)
- Clinically interpretable model outputs that care teams can trust and act on
- All analytics compliant with HIPAA regulations

### Initial Hypotheses

Based on clinical domain knowledge and preliminary exploration, we hypothesize:

| #    | Hypothesis                                                   | Metrics to Test                                              |
| ---- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| H1   | **Comorbidity Burden Drives Readmission** — Patients with higher comorbidity counts are more likely to be readmitted due to complex care needs | Readmission rate by comorbidity_count, comorbidity distribution |
| H2   | **Length of Stay Signals Severity** — Patients with very short stays (premature discharge) or very long stays (severe illness) are at higher risk | Readmission rate by length_of_stay categories, average LOS by readmission status |
| H3   | **Emergency Admissions Carry Higher Risk** — Emergency admissions, reflecting acute or unplanned events, are associated with higher readmission rates than elective admissions | Readmission rate by admission_type                           |
| H4   | **Medication Complexity Increases Risk** — Patients on more medications, especially high-risk medications, face higher readmission rates due to adherence challenges and drug interactions | Medication count per patient, high-risk medication count, readmission rate by polypharmacy status |
| H5   | **Abnormal Clinical Measures Predict Readmission** — Patients with abnormal lab results, elevated blood pressure, high glucose, or extreme BMI are at higher readmission risk | Readmission rate by lab_results_flag, BP classification, glucose level, BMI category |

## Scope

### In Scope

- Patient admissions during the 2025 observation period
- All four data sources (patients, admissions, clinical measures, medications)
- Binary classification: readmitted within 30 days (1) vs. not readmitted (0)
- Fairness assessment on insurance type
- HIPAA-compliant analytics workflow

### Out of Scope

- Clinical trial data and research protocols
- Real-time patient monitoring and alerting
- Outpatient-only encounters (no inpatient admission)
- Specific physician performance evaluation

## Stakeholder Alignment

Before building models, confirm alignment with key stakeholders:

| Stakeholder                         | What They Need                                               |
| ----------------------------------- | ------------------------------------------------------------ |
| **Chief Medical Officer**           | Clinical validity of the model, patient safety assurance, clinician trust |
| **Director of Quality Improvement** | Measurable readmission rate reduction, CMS HRRP compliance evidence |
| **VP of Data Analytics**            | Model performance targets, scalability to production, HIPAA-compliant workflow |
| **Director of Care Transitions**    | Actionable risk scores at discharge, clear intervention recommendations |
| **Chief Information Officer**       | EHR integration plan, data governance compliance, HIPAA audit trail |
