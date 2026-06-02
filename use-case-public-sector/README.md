# Priorisation des demandes citoyens
Bien que ce cas d’usage suive une structure définie, n’hésitez pas à explorer librement ! Testez vos propres idées, posez de nouvelles questions ou passez ce qui vous semble moins pertinent.  

Vous commencerez par une courte introduction au cas d’usage, suivie d’un aperçu des cinq étapes que vous allez parcourir durant cette expérience de SAS Hackathon Bootcamp. Vous découvrirez ensuite la structure du répertoire Git, une présentation des jeux de données ainsi que les cinq thèmes principaux abordés. Enfin, une analyse plus approfondie du contexte métier vous sera proposée — à vous de l’explorer selon vos besoins.

## Cas d’usage secteur public — Cycle de vie Data & IA

Ce cas d’usage vous guide à travers l’ensemble du **cycle de vie des données et de l’IA**, à partir d’un scénario réaliste de priorisation des demandes de services citoyens, basé sur la technologie SAS Viya.

## Contexte métier

**Organisation :** Metro City (ville fictive, 850 000 habitants, 12 quartiers)  
**Problème :** 15 000 demandes de service par mois, avec un écart de 40 % dans les délais de réponse entre quartiers et des enjeux croissants d’équité  
**Objectif :** Prédire les demandes les plus urgentes, réduire le temps de réponse moyen de 48,2 à 36 heures et améliorer la satisfaction des citoyens de 3,2 à 3,7 sur 5,0  


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

## Jeux de données

| Jeu de données | Nombre de lignes | Description |
|---------|---------|-------------|
| `service_requests.csv` | 500 | Chaque ligne represente une demande de service avec priorité, délai de traitement et niveau de satisfaction |
| `citizens.csv` | 300 | Profils des citoyens avec données démographiques, quartier et historique de services |
| `department_performance.csv` | 96 | Indicateurs de performance mensuels par département |
| `request_history.csv` | ~3,456 | Historique des volumes de demandes par quartier, département et niveau de priorité |

### Notes sur la qualité des données
- Les données des demandes de service couvrent l’année 2024 (12 mois)  
- La variable cible (à expliquer) est dérivée : `is_urgent` = 1 si `priority_level` est *Critical* ou *High*, sinon 0  
- `citizen_id` permet de lier `service_requests` à `citizens`  
- `department` permet de lier `service_requests` à `department_performance`  
- `request_history` fournit des tendances agrégées par quartier et département sur plusieurs années  


## Les 5 thèmes clés du bootcamp
- **Données synthétiques** — Générer des données respectueuses de la confidentialité avec SAS Data Maker  
- **Expérience développeur** — Coder en SAS, Python ou R dans SAS Viya Workbench ou SAS Studio 
- **Copilotes** — Exploration, modélisation et prise de décision assistées par l’IA  
- **IA de confiance** — Évaluation de l’équité et gouvernance des modèles  
- **IA agentique** — Décisions exposées comme des capacités utilisables par les agents pour orchestrer des workflows autonomes  

## Compréhension métier

### Contexte 
**Metro City** est une municipalité de taille intermédiaire qui traite environ 15 000 demandes de service citoyen par mois, réparties entre différents services tels que les travaux publics, les parcs et loisirs, les transports, la sécurité des bâtiments, entre autres.  

Ces demandes vont de la réparation de nids-de-poule et des pannes d’éclairage public à des demandes de permis ou des plaintes pour nuisances sonores.  

La ville met à disposition un centre de service 311, un portail en ligne ainsi qu’une application mobile pour la soumission des demandes.


### Problématique

Metro City présente un **écart de 40 % dans les temps de réponse moyens entre ses 12 quartiers**, avec une moyenne globale de **48,2 heures**, bien au-dessus de l’objectif fixé à 36 heures. La satisfaction des citoyens a chuté à **3,2 sur 5,0**, et des préoccupations croissantes émergent autour de l’**équité du service** : certains quartiers sont-ils systématiquement moins bien servis que d’autres ? Les demandes urgentes sont-elles correctement identifiées et traitées en priorité ?


**Concrètement, qu’est-ce que cela signifie ?** Une rupture de canalisation dans un quartier peut attendre 60 heures avant intervention, alors qu’une demande à faible enjeu, comme une plainte esthétique concernant un trottoir, peut être traitée en seulement 20 heures dans un autre quartier. En l’absence d’un mécanisme structuré pour évaluer l’urgence des demandes et allouer les ressources en conséquence, les services fonctionnent selon une logique de traitement « premier arrivé, premier servi ». Cette approche ne prend pas en compte la gravité, les enjeux de sécurité ou les dimensions d’équité propres à chaque demande. Si Metro City est capable de prédire quelles demandes sont réellement urgentes, elle pourra les prioriser plus efficacement, les orienter vers les bons services avec le bon niveau de priorité, et garantir un service équitable à l’ensemble des quartiers.  

### Objectifs métiers

1. **Objectif principal :** Réduire le temps de réponse moyen de 48,2 à 36 heures dans un délai de 6 mois 
2. **Objectifs secondaires :**
   - Améliorer la satisfaction des citoyens de 3,2 à 3,7 sur 5,0  
   - Réduire l’écart de temps de réponse entre quartiers à moins de 10 %  
   - S’assurer que les demandes urgentes (priorités *Critical* et *High*) sont identifiées avec un **[recall](https://en.wikipedia.org/wiki/Precision_and_recall) d’au moins 90 %**  
   - Respecter les réglementations (Public Records Act, exigences ADA) et les politiques de prévention des biais algorithmiques


### Critères de succès
- Modèle de prédiction de l’urgence avec une **précision supérieure à 85 %**  
- **Recall supérieur à 90 %** pour les demandes urgentes (ne pas manquer les priorités *Critical* ou *High*)  
- Performance équitable du modèle sur l’ensemble des 12 quartiers  
- Système de priorisation opérationnel permettant d’orienter les demandes en temps réel  

### Hypothèses initiales

Sur la base des connaissances métier et d’une première exploration, nous formulons les hypothèses suivantes :  

| # | Hypothèse  | Indicateurs à tester |
|---|-----------|-----------------|
| H1 | **Le type de demande influence l’urgence** — Certains types de demandes (ex. : rupture de canalisation, problèmes de sécurité) sont intrinsèquement plus urgents que d’autres (ex. : réparations esthétiques, demandes de permis) | Taux d’urgence par type de demande, temps de réponse par type de demande |
| H2 | **La capacité des services impacte la réponse** — Les services ayant une charge de travail élevée, des effectifs réduits ou un budget fortement consommé présentent des délais de réponse plus longs et des taux de résolution plus faibles | Temps de réponse moyen vs effectifs, nombre de demandes par agent, utilisation du budget vs taux de résolution |
| H3 | **L’équité entre quartiers est un enjeu** — Certains quartiers peuvent être systématiquement moins bien servis, en lien avec le volume de demandes, les caractéristiques démographiques ou l’allocation des ressources | Temps de réponse par quartier, satisfaction par quartier, taux de résolution par quartier |
| H4 | **Des effets saisonniers existent** — Les volumes et les types de demandes varient selon les saisons (ex. : augmentation des nids-de-poule après l’hiver, hausse des plaintes liées aux parcs en été), ce qui influence la charge des services et les délais de traitement | Nombre de demandes mensuel, évolution des délais de réponse selon la saison, distribution des priorités par mois |
| H5 | **L’historique des citoyens influence l’engagement** — Les citoyens ayant fait plus de demandes par le passé et ayant un niveau de satisfaction élevé sont généralement plus engagés et peuvent soumettre des demandes de meilleure qualité et plus exploitables | Nombre de demandes précédentes vs temps de réponse, historique de satisfaction vs satisfaction actuelle |

## Périmètre

### Inclus dans le périmètre
- Les demandes de service soumises pendant la période d’observation 2024  
- Les quatre sources de données (`service_requests`, `citizens`, `department_performance`, `request_history`)  
- Classification binaire : urgent (1) vs non urgent (0), dérivée de `priority_level`  
- Analyse de l’équité entre quartiers (`location_district`)  


### Hors périmètre
- Allocation budgétaire et planification financière  
- Gestion du personnel et optimisation des effectifs  
- Facteurs externes (conditions météorologiques, évolutions de la population)  
- Accords de service inter-juridictionnels  


## Alignement des parties prenantes

Avant de construire les modèles, il est essentiel de valider l’alignement avec les principales parties prenantes :  

| Partie prenante | Besoins |
|------------|---------------|
| **Maire** | Amélioration mesurable des délais de réponse et de la satisfaction des citoyens |
| **Représentants des quartiers** | Preuve d’un service équitable dans l’ensemble des 12 quartiers |
| **Responsables de services** | Recommandations de priorisation exploitables et visibilité sur la répartition de la charge de travail |
| **Directeur informatique** | Plan d’intégration avec le système 311 et conformité aux règles de gouvernance des données |
| **Responsable Équité & Inclusion** | Évaluation de l’équité entre quartiers et mesures de réduction des biais |
