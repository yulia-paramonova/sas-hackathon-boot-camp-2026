# Prédiction du risque de défaut

Bien que ce cas d’usage suive une structure définie, n’hésitez pas à explorer librement ! Testez vos propres idées, posez de nouvelles questions ou passez ce qui vous semble moins pertinent.  

Vous commencerez par une courte introduction au cas d’usage, suivie d’un aperçu des cinq étapes que vous allez parcourir durant cette expérience de SAS Hackathon Bootcamp. Vous découvrirez ensuite la structure du répertoire Git, une présentation des jeux de données ainsi que les cinq thèmes principaux abordés. Enfin, une analyse plus approfondie du contexte métier vous sera proposée — à vous de l’explorer selon vos besoins.

## Cas d’usage services financiers — Cycle de vie Data & IA

Ce cas d’usage vous guide à travers l’ensemble du **cycle de vie des données et de l’IA**, à partir d’un scénario réaliste de prédiction du risque de défaut, basé sur la technologie SAS Viya.


## Contexte métier

**Organisation :** PremierBank (banque régionale américaine fictive, 2,1 milliards de dollars d’actifs, plus de 50 000 clients)  
**Problème :** Un taux de défaut de crédit de **8,5 %**, nettement supérieur à la moyenne du marché (5,2 %), entraînant **12,8 M$ de pertes annuelles**  
**Objectif :** Identifier en amont les crédits à risque, garantir la conformité aux règles de [fair lending](https://www.fdic.gov/banker-resource-center/fair-lending) et réduire le taux de défaut à **5,5 % sous 12 mois**

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
use-case-financial-services/
├── README.md                        # This file
├── data/                            # Raw datasets
│   ├── loan_applications.csv        # Loan application details (500 records)
│   ├── credit_history.csv           # Credit bureau data (500 records)
│   ├── employment.csv               # Employment and income data (500 records)
│   └── payment_history.csv          # Loan payment records (500 records)
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

| Jeu de données | Nombre de lignes | Description |
|---------|---------|-------------|
| `loan_applications.csv` | 500 | Détails des demandes de prêt (montant, durée, statut de défaut) |
| `credit_history.csv` | 500 | Données issues d’organismes de crédit (scores, taux d’utilisation du crédit et incidents de paiement |
| `employment.csv` | 500 | Informations sur l’emploi, les revenus et les indicateurs de vérification |
| `payment_history.csv` | 500 | Historique détaillé des paiements individuels (montants et retards de paiement) |

### Notes sur la qualité des données

- Tous les jeux de données peuvent être liés via la clé `loan_id`
- La variable cible(à expliquer) est disponible dans loan_applications.csv (`defaulted` : 1 = en défaut, 0 = en cours)
- L’historique des paiements est granulaire et devra être agrégé au niveau du prêt pour les analyses

## Les 5 thèmes clés du bootcamp

- **Données synthétiques** — Générer des données respectueuses de la confidentialité avec SAS Data Maker  
- **Expérience développeur** — Coder en SAS, Python ou R dans SAS Viya Workbench ou SAS Studio 
- **Copilotes** — Exploration, modélisation et prise de décision assistées par l’IA  
- **IA de confiance** — Évaluation de l’équité et gouvernance des modèles  
- **IA agentique** — Décisions exposées comme des capacités utilisables par les agents pour orchestrer des workflows autonomes  

## Compréhension métier

### Contexte 

**PremierBank** est une banque fictive régionale américaine multi-États, spécialisée dans le crédit à la consommation, les prêts automobiles et les financements adossés à la valeur immobilière.  

Son modèle de financement des communautés locales et de banque relationnelle est aujourd’hui fragilisé par une dégradation de la qualité du portefeuille, pesant sur sa rentabilité et ses ratios de solvabilité.  

### Problématique

La banque présente un taux de défaut de **8,5 %**, bien au-dessus de la moyenne du secteur **(5,2 %)**, ce qui représente environ **12,8 M$ de pertes annuelles** (défauts, coûts de recouvrement, pertes d’intérêts).  

**Concrètement, qu’est-ce que cela signifie ?**  
Sur 1 000 prêts accordés, environ 85 deviennent défaillants — c’est-à-dire que l’emprunteur cesse de rembourser pendant au moins 90 jours.
Chaque défaut génère une chaîne de coûts : intervention des équipes de recouvrement, procédures juridiques, récupération des garanties (le cas échéant), et finalement une perte comptabilisée dans les provisions. 
Si PremierBank est en mesure de prédire, dès l’octroi ou en début de vie du prêt, quels crédits présentent un risque de défaut, elle peut alors :
- renforcer ses critères d’octroi pour les emprunteurs les plus risqués  
- proposer des conditions adaptées aux profils à risque intermédiaire  
- et intervenir de manière proactive auprès des clients en difficulté, avant l’accumulation d’impayés


### Objectifs métiers

1. **Objectif principal :** Réduire le taux de défaut de **8,5 % à 5,5 % en 12 mois**
2. **Objectifs secondaires :**
    - Identifier les principaux facteurs expliquant les défauts
    - Mettre en place un système d’alerte précoce sur les crédits à risque
    - Garantir la conformité aux réglementations de [fair lending](https://www.fdic.gov/banker-resource-center/fair-lending)¹ (ECOA, Fair Housing Act, FCRA)
    - Documenter les modèles conformément aux exigences de gestion du risque de modèle et de gouvernance réglementaire (SR 11-7)²
  
¹*Il n’existe pas d’équivalent unique au “fair lending” américain en Europe. Cependant, ses principes sont couverts par les règles de non-discrimination (égalité d’accès au crédit), la réglementation de protection des consommateurs, les obligations de crédit responsable (analyse de solvabilité).*  

²*SR 11-7 est la guidance américaine de référence en matière de gestion du risque de modèle, couvrant l’ensemble du cycle de vie des modèles (développement, validation, gouvernance). En Europe, il n’existe pas d’équivalent unique, mais des cadres combinés (ECB Guide to Internal Models, directives EBA, CRR/Bâle) couvrent des exigences similaires en matière de validation, documentation et gouvernance des modèles.*

### Critères de succès

- Modèle de prédiction du défaut avec un **AUC-ROC >= 0.82**
- Attribution systématique de codes explicatifs (adverse actions) pour chaque décision
- Performance équitable du modèle sur les différentes catégories de revenus et variables proxy
- Réduction mesurable des pertes avec un ROI positif sous 6 mois après déploiement

### Hypothèses initiales

Sur la base des connaissances métier et des contraintes réglementaires, nous posons les hypothèses suivantes :

| # | Hypothèse  | Indicateurs à tester |
| ---- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| H1   | **Le score de crédit est déterminant**  — Les emprunteurs avec un score FICO faible présentent un risque de défaut plus élevé | Taux de défaut par tranche de score, score moyen des prêts en défaut vs actifs |
| H2   | **Le ratio dette/revenu (DTI) est clé** — Des ratios élevés traduisent une capacité de remboursement limitée | Taux de défaut par tranche de DTI, DTI moyen défaut vs actif |
| H3   | **Le comportement de paiement est prédictif** — Les emprunteurs ayant été en retard sur des paiements antérieurs présentent une probabilité plus élevée de défaut | Taux de retard de paiement, nombre de défauts sévères, nombre moyen de jours de retard |
| H4 | **La stabilité de l'emploi est déterminante** — Les emprunteurs avec une ancienneté courte, un emploi non vérifié ou des revenus plus faibles présentent un risque accru | Taux de défaut par ancienneté, statut de vérification de l’emploi, tranche de revenus |
| H5 | **Les caractéristiques du prêt influencent le risque** — Les montants élevés, les ratios LTV élevés et les maturités longues sont associés à un risque de défaut plus important | Taux de défaut par tranche de montant, tranche de LTV, durée du prêt |

## Périmètre

### Inclus dans le périmètre

- Les prêts accordés sur la période d’observation du dataset
- Les 4 sources de données (demandes, historique crédit, emploi, paiements)
- Classification binaire : défaut (1) vs actif (0)
- Analyse de l’équité sur les tranches de revenus et variables proxy

### Hors périmètre

- Détection des fraudes en temps réel (initiative distincte)  
- Exigences réglementaires spécifiques au crédit immobilier (TRID, QM)  
- Indicateurs macroéconomiques externes (taux de chômage, PIB)  
- Optimisation des activités de recouvrement (gestion post-défaut)

## Alignement des parties prenantes

Avant de lancer la modélisation, validez l’alignement avec les acteurs clés :

| Partie prenante | Besoins |
| ------------------------ | ------------------------------------------------------------ |
| **Chief Risk Officer**   | Réduction des taux de pertes, preuves de conformité réglementaire, documentation de validation des modèles |
| **Comité de crédit**      | Définitions claires des niveaux de risque, codes de motifs de refus, règles de dérogation |
| **Responsable Fair Lending** | Évaluation de l’équité entre les classes protégées et variables proxy, analyse des impacts discriminants |
| **Chargés de clientèle**  | Recommandations actionnables (accepter / revoir / refuser) avec justification transparente |
| **Audit interne**         | Traçabilité de la gouvernance des modèles conformément à SR 11-7, lignage des données, gestion des versions |
