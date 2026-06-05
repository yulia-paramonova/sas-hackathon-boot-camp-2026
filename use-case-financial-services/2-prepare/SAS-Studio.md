# Étape 2: Prepare

Dans cette étape, vous allez travailler dans **SAS Studio** pour charger les quatre jeux de données PremierBank, les profiler et les joindre dans une **Analytical Base Table (ABT)** prête pour l’exploration dans SAS Visual Analytics et la modélisation dans SAS Model Studio.

SAS Viya Workbench vous offre la liberté de coder dans le langage de votre choix. Nous fournissons un code équivalent en **SAS**, **Python** et **R** — choisissez celui avec lequel vous êtes le plus à l’aise ou essayez les trois.

---

## Accès aux données

Les quatre fichiers CSV sont disponibles dans la même structure de dossiers que dans l’Étape 1 :

```
SAS-Hackathon-Bootcamp-2026/use-case-financial-services/data
├── loan_applications.csv    (500 records)
├── credit_history.csv       (500 records)
├── employment.csv           (500 records)
└── payment_history.csv      (500 records)
```

---

## Ce que vous allez faire
### 1. Charger les données et les cas d’usage

La première étape consiste à cloner le dépôt GitHub dans votre environnement SAS Studio en ouvrant d’abord un programme SAS et en exécutant le code ci‑dessous, qui clonera le dépôt dans le système de fichiers:

```SAS
data _null_;
    rc = git_clone('https://github.com/sascommunities/sas-hackathon-boot-camp-2026.git', "&_USERHOME./sas-hackathon-boot-camp-2026");
run;
```

Une fois cet extrait de code exécuté, accédez au panneau SAS Server, puis développez *SAS Server > Home > data > sas-hackathon-bootcamp-2026*. À partir de là, la structure familière de ce dépôt est disponible.

![image-20260528135335744](img/SAS-Studio/image-20260528135335744.png)

### 2. Créer une Data Card
Une **data card** est un document synthétique décrivant chaque jeu de données — son objectif, sa taille, les noms de colonnes, les types de données et toute remarque de qualité. Les data cards sont une bonne pratique en matière d’IA responsable, car elles apportent de la transparence sur les données utilisées dans les modèles. Pour chaque table, vous produirez :
- Nombre de lignes et de colonnes
- Noms des colonnes et types de données
- Nombre de valeurs manquantes par colonne
- Exemples de lignes

### 3. Obtenir des statistiques descriptives de base
Pour les colonnes numériques, calculez les statistiques descriptives (moyenne, médiane, écart-type, min, max). Pour les colonnes catégorielles, calculez les fréquences. Cela vous donne une première vue des distributions et des éventuels problèmes de qualité avant de commencer l’ingénierie des variables.

### 4. Créer des variables et construire l’Analytical Base Table
Les quatre jeux de données capturent chacun une dimension différente du risque de prêt. Pour construire un modèle prédictif, nous devons les agréger dans une table unique au niveau du prêt, où chaque ligne représente un prêt et chaque colonne une variable. Les transformations clés sont :

- **Variables de comportement de paiement** : taux de retard, indicateur de retard sévère (60+ jours), moyenne des jours de retard, ratio de paiement insuffisant
- **Variables de crédit** : bandes de score FICO, catégories d’utilisation du crédit, indicateurs de faillite et de délinquance, nombre d’enquêtes
- **Variables d’emploi** : bandes de revenu, ratio service de la dette, statut de vérification emploi/revenu, bandes d’années d’emploi
- **Variables de prêt** : ratio prêt/valeur, ratio dette/revenu, montant du prêt, durée, taux d’intérêt, objectif, type de propriété

L’ABT finale sera enregistrée en fichier CSV, puis pourra être promue dans CAS pour une utilisation dans SAS Visual Analytics et SAS Model Studio.


---

## Choisissez votre langage
Choisissez **un** langage et exécutez son script. Vous n’avez pas besoin d’exécuter les trois — ils produisent tous le même résultat. Si vous hésitez, prenez celui que vous maîtrisez le mieux.

| Language | Fichier |
|----------|------|
| ---------- | ------------------------------------------------------------ |
| **SAS**    | [`data_preparation_studio.sas`](data_preparation_studio.sas) |
| **Python** | [`data_preparation_studio.py`](data_preparation_studio.py)   |
| **R**      | [`data_preparation_studio.R`](data_preparation_studio.R)     |

Les trois scripts produisent le même fichier : **`financial_services_abt.csv`** dans le dossier `data/`. Après exécution, **rafraîchissez le panneau Explorer** pour voir le nouveau fichier.

---

## Résultat
Après avoir exécuté l’un des scripts, vous obtiendrez :

| Fichier | Description |
|------|-------------|
| `data/financial_services_abt.csv` | Le jeu de données joint, enrichi et prêt pour la modélisation |
| Sortie console | Informations de data card, statistiques descriptives et distribution des défauts |

---

## Prochaines étapes
Passez à  **[Étape 3: Explore](../3-explore/)** pour explorer visuellement les données dans SAS Visual Analytics grâce à son Copilot intégré.
