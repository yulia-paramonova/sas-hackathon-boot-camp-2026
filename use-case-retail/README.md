# Prédiction du churn en e-commerce

Bien que ce cas d’usage suive une structure définie, n’hésitez pas à explorer librement ! Testez vos propres idées, posez de nouvelles questions ou passez ce qui vous semble moins pertinent.  

Vous commencerez par une courte introduction au cas d’usage, suivie d’un aperçu des cinq étapes que vous allez parcourir durant cette expérience de SAS Hackathon Bootcamp. Vous découvrirez ensuite la structure du répertoire Git, une présentation des jeux de données ainsi que les cinq thèmes principaux abordés. Enfin, une analyse plus approfondie du contexte métier vous sera proposée — à vous de l’explorer selon vos besoins.

## Cas d’usage Retail — Cycle de vie Data & IA

Ce cas d’usage vous guide à travers l’ensemble du **cycle de vie des données et de l’IA**, à partir d’un scénario réaliste de prédiction du churn en e-commerce, grâce aux capacités de SAS Viya.

## Contexte métier

**Entreprise :** ShopEase (une plateforme e-commerce fictive)
**Problème :** Le taux de churn mensuel de 12 % a un impact significatif sur le chiffre d'affaires. 
**Objectif :** Identifiez les clients susceptibles de partir, comprenez pourquoi et automatisez les mesures de rétention

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

## Jeux de données

| Jeu de données | Nombre de lignes | Description |
|---------|---------|-------------|
| `customers.csv` | 1,000 | Profils clients avec données démographiques et indicateurs de churn |
| `transactions.csv` | ~5,000 | Historique des achats sur 12 mois |
| `sessions.csv` | ~10,000 | Comportement de navigation sur le site web |
| `support_tickets.csv` | ~400 | Interactions avec le service client |

### Notes sur la qualité des données

- Les données couvrent l’année 2023 (12 mois)  
- La variable cible(à expliquer) est disponible dans `customers.csv` (`churned` : 1 = churn, 0 = client actif)
- Tous les jeux de données peuvent être liés via la clé `customer_id`

## Les 5 thèmes clés du bootcamp

- **Données synthétiques** — Générer des données respectueuses de la confidentialité avec SAS Data Maker  
- **Expérience développeur** — Coder en SAS, Python ou R dans SAS Viya Workbench ou SAS Studio 
- **Copilotes** — Exploration, modélisation et prise de décision assistées par l’IA  
- **IA de confiance** — Évaluation de l’équité et gouvernance des modèles  
- **IA agentique** — Décisions exposées comme des capacités utilisables par les agents pour orchestrer des workflows autonomes  

## Compréhension métier

### Contexte 

**ShopEase** est une plateforme de e-commerce qui compte plus de 1 000 clients actifs à travers les États-Unis. L'entreprise propose des produits dans les catégories Électronique, Vêtements, Maison et jardin, et Livres via une plateforme web et une application mobile.

### Problématique

L'entreprise enregistre un **taux de churn mensuel de 12 %**, ce qui a un impact significatif sur son chiffre d'affaires et sa croissance. La direction souhaite comprendre pourquoi les clients partent et identifier les clients à risque avant qu'ils ne se décident à partir.  

**Qu'est-ce que cela signifie concrètement ?**  
Chaque mois, environ 120 clients sur 1 000 cessent d'acheter. Acquérir un nouveau client coûte 5 à 7 fois plus cher que de fidéliser un client existant, ce qui fait de ce taux de churn une menace directe pour la rentabilité. Si ShopEase parvient à prédire quels clients sont sur le point de partir, elle peut intervenir en proposant des offres de fidélisation ciblées, une communication personnalisée ou des améliorations de service, transformant ainsi des pertes potentielles en relations préservées.

### Objectifs métiers

1. **Objectif principal :** réduire le taux de churn mensuel de 12 % à 8 % en 6 mois
2. **Objectifs secondaires :**
   - Identifier les 5 principaux facteurs à l'origine du départ des clients
   - Créer un système d'alerte précoce pour les clients à risque
   - Mettre en place des campagnes de fidélisation proactives

### Critères de succès

- Modèle de prédiction du churn avec une **précision ≥ 80 %** (accuracy) 
- Insights actionnables pour les équipes de rétention  
- Campagne de fidélisation avec un ROI positif sous 3 mois


### Hypothèses initiales

Sur la base de notre connaissance du domaine et d'une analyse préliminaire, nous émettons les hypothèses suivantes :

| # | Hypothèse | Indicateurs à tester |
|---|-----------|-----------------|
| H1 | **L'engagement favorise la fidélisation** — Les clients peu engagés (moins de sessions, durée plus courte) sont plus susceptibles de partir | Durée moyenne des sessions, nombre de sessions par mois, nombre de pages consultées par session |
| H2 | **La fréquence d'achat est importante** — Les clients qui achètent moins fréquemment ou dont le montant des transactions diminue présentent un risque de churn plus élevé | Nombre de transactions, valeur moyenne des commandes, nombre de jours depuis le dernier achat |
| H3 | **Les problèmes d'assistance indiquent un risque** — Les clients ayant de nombreux tickets d'assistance, en particulier ceux non résolus ou ayant entraîné une faible satisfaction, sont plus susceptibles de partir | Nombre de tickets d'assistance, répartition des priorités des tickets, note de satisfaction moyenne |
| H4 | **Le programme de fidélité influe sur le taux de churn** — Les clients du niveau de base présentent des taux de churn plus élevés que les clients Premium en raison d'un investissement/engagement moindre | Taux de churn par niveau de fidélité |
| H5 | **Le désabonnement aux e-mails signale un désengagement** — Les clients qui se sont désabonnés des e-mails marketing sont moins engagés et plus susceptibles de partir | Taux de churn par statut d'inscription aux e-mails |


## Périmètre

### Inclus dans le périmètre

- Clients actifs pendant la période d'observation de janvier à décembre 2023
- Les quatre sources de données (clients, transactions, sessions, tickets d'assistance)
- Classification binaire : churn (1) vs actifs (0)
- Évaluation de l'équité du modèle au niveau des programmes de fidélité

### Hors périmètre

- Détection des fraudes en temps réel (initiative distincte)
- Moteur de recommandation de produits
- Données externes sur le marché ou la concurrence
- Optimisation de la stratégie tarifaire

## Alignement des parties prenantes

Avant de construire les modèles, il est essentiel de valider l’alignement avec les principales parties prenantes :

| Partie prenante | Besoins |
|------------|---------------|
| **Directeur marketing** | Critères de ciblage pour les campagnes de fidélisation, projections de retour sur investissement pour les dépenses publicitaires |
| **Responsable de l’expérience client** | Analyse des causes profondes des facteurs de churn, recommandations d’amélioration du service |
| **Chef de produit** | Données d’engagement au niveau des fonctionnalités pour hiérarchiser les décisions relatives à la feuille de route produit |
| **Data Science Lead** | Objectifs de performance des modèles, exigences en matière d’équité, calendrier de déploiement |
| **Directeur financier** | Analyse de l’impact sur le chiffre d’affaires, estimations de la préservation de la valeur vie client (customer lifetime value) |
