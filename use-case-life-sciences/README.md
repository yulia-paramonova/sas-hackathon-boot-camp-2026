# Prédiction du risque de réadmission des patients

Bien que ce cas d’usage suive une structure définie, n’hésitez pas à explorer librement ! Testez vos propres idées, posez de nouvelles questions ou passez ce qui vous semble moins pertinent.  

Vous commencerez par une courte introduction au cas d’usage, suivie d’un aperçu des cinq étapes que vous allez parcourir durant cette expérience de SAS Hackathon Bootcamp. Vous découvrirez ensuite la structure du répertoire Git, une présentation des jeux de données ainsi que les cinq thèmes principaux abordés. Enfin, une analyse plus approfondie du contexte métier vous sera proposée — à vous de l’explorer selon vos besoins.


## Cas d’usage en sciences de la vie — Cycle de vie Data et IA

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


## Structure du projet

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
- Tous les jeux de données peuvent être joints via `patient_id`
- Tous les patients ne disposent pas de dossiers de médication (326 enregistrements de médication pour 500 patients)
- Les mesures cliniques correspondent à un enregistrement par patient au moment de l’admission

## Les 5 thèmes clés du bootcamp
- **Données synthétiques** — Générer des données respectueuses de la confidentialité avec SAS Data Maker  
- **Expérience développeur** — Coder en SAS, Python ou R dans SAS Viya Workbench ou SAS Studio 
- **Copilotes** — Exploration, modélisation et prise de décision assistées par l’IA  
- **IA de confiance** — Évaluation de l’équité et gouvernance des modèles  
- **IA agentique** — Décisions exposées comme des capacités utilisables par les agents pour orchestrer des workflows autonomes  


## Compréhension métier


### Contexte de l’organisation

**MedCare Health System** est un réseau régional de santé exploitant 12 hôpitaux et 45 établissements de soins ambulatoires, desservant plus de 2 millions de patients par an dans les domaines médicaux, chirurgicaux et cardiologiques. La mission de MedCare est de fournir des soins de haute qualité centrés sur le patient, tout en maintenant une efficacité opérationnelle.

### Problématique

MedCare connaît un **taux de réadmission à 30 jours de 18,2 %**, dépassant significativement le benchmark national de 15,5 %. Cet écart coûte à l’organisation environ **12,4 millions de dollars par an** en pénalités imposées par les Centers for Medicare & Medicaid Services (CMS) dans le cadre du Hospital Readmissions Reduction Program (HRRP).

**Concrètement, qu’est-ce que cela signifie ?**  Pour 1 000 patients sortis de l’hôpital, environ 182 y retournent dans les 30 jours — et nombre de ces réadmissions pourraient être évitées avec un accompagnement post‑sortie adéquat. Au‑delà des pénalités financières, les réadmissions révèlent des lacunes dans la continuité des soins : les patients peuvent sortir sans une conciliation médicamenteuse appropriée, sans rendez‑vous de suivi, ou sans bien comprendre les consignes d’autosoins. Si MedCare est capable d’identifier les patients à haut risque avant leur sortie de l’hôpital, les équipes de soins peuvent intervenir via une planification de sortie ciblée, des appels de suivi, des orientations vers des soins à domicile et une meilleure gestion des traitements — réduisant ainsi à la fois les coûts et la souffrance des patients.

### Objectifs métiers

1. **Objectif principal:** Réduire le taux de réadmission à 30 jours de 18,2 % à 14,5 % en 18 mois
2. **Objectifs secondaires**
    
- Identifier les principaux facteurs cliniques et opérationnels de réadmission  
- Créer un système de scoring du risque au moment de la sortie pour les équipes de soins  
- Permettre une coordination proactive des soins pour les patients à haut risque  
- Réduire les pénalités CMS de 12,4 M$ à 7,5 M$ par an

### Critères de succès

- Modèle de prédiction de réadmission avec un **AUC-ROC >= 0,75**  
- Identification des patients à haut risque avec une **sensibilité >= 0,80** (identifier au moins 80 % des patients qui seront réadmis)  
- Résultats de modèle interprétables cliniquement, auxquels les équipes de soins peuvent faire confiance et sur lesquels elles peuvent agir  
- Toutes les analyses conformes aux réglementations HIPAA


### Hypothèses initiales

Sur la base des connaissances métier et d’une première exploration, nous formulons les hypothèses suivantes :  

| #    | Hypothèse                                                   | Indicateurs à tester                                              |
| ---- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| H1   | **Le fardeau des comorbidités entraîne les réadmissions** — Les patients présentant un nombre élevé de comorbidités sont plus susceptibles d’être réadmis en raison de besoins de soins complexes | Taux de réadmission selon `comorbidity_count`, distribution des comorbidités |
| H2   | **La durée de séjour indique la gravité** — Les patients avec des séjours très courts (sortie prématurée) ou très longs (maladie sévère) présentent un risque plus élevé | Taux de réadmission par catégories de `length_of_stay`, durée moyenne de séjour selon le statut de réadmission |
| H3   | **Les admissions en urgence présentent un risque plus élevé** — Les admissions en urgence, reflétant des événements aigus ou non planifiés, sont associées à des taux de réadmission plus élevés que les admissions programmées | Taux de réadmission par `admission_type` |                           |
| H4   | **La complexité des traitements médicamenteux augmente le risque** — Les patients prenant un plus grand nombre de médicaments, en particulier des médicaments à haut risque, présentent des taux de réadmission plus élevés en raison des difficultés d’observance et des interactions médicamenteuses | Nombre de médicaments par patient, nombre de médicaments à haut risque, taux de réadmission selon le statut de polymédication |
| H5   | **Les mesures cliniques anormales prédisent la réadmission** — Les patients présentant des résultats de laboratoire anormaux, une pression artérielle élevée, une glycémie élevée ou un IMC extrême ont un risque de réadmission plus élevé | Taux de réadmission selon `lab_results_flag`, classification de la pression artérielle, niveau de glucose, catégorie d’IMC |

## Périmètre

### Inclus dans le périmètre

- Admissions de patients pendant la période d’observation de 2025  
- Les quatre sources de données (patients, admissions, mesures cliniques, médicaments)  
- Classification binaire : réadmis dans les 30 jours (1) vs non réadmis (0)  
- Évaluation de l’équité selon le type d’assurance  
- Workflow d’analytique conforme à la réglementation HIPAA


### Hors périmètre

- Données d’essais cliniques et protocoles de recherche  
- Suivi des patients en temps réel et systèmes d’alerte  
- Consultations exclusivement ambulatoires (sans admission en hospitalisation)  
- Évaluation spécifique de la performance des médecins

## Alignement des parties prenantes

Avant de construire les modèles, il est essentiel de valider l’alignement avec les principales parties prenantes :  

| Partie prenante | Besoins |
|------------|---------------|
| **Directeur médical (Chief Medical Officer)**   | Validité clinique du modèle, garantie de la sécurité des patients, confiance des cliniciens |
| **Directeur de l’amélioration de la qualité** | Objectifs de performance du modèle, passage à l’échelle en production, workflow conforme HIPAA |
| **Vice-président de l’analytique des données(VP Data Analytics)** | Recommandations de priorisation exploitables et visibilité sur la répartition de la charge de travail |
| **Directeur des transitions de soins** | Scores de risque exploitables à la sortie, recommandations d’intervention claires |
| **Directeur des systèmes d’information (CIO)** | Plan d’intégration au dossier médical électronique (EHR), conformité à la gouvernance des données, traçabilité HIPAA |

