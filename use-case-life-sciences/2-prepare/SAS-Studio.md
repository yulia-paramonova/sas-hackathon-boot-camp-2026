
# Étape 2: Prepare

Dans cette étape, vous allez travailler dans **SAS Studio** pour charger les quatre jeux de données MedCare, les profiler et les joindre dans une **Analytical Base Table (ABT)** prête pour l’exploration dans SAS Visual Analytics et la modélisation dans SAS Model Studio.

SAS Studio vous offre la liberté de coder dans le langage de votre choix. Nous fournissons un code équivalent en **SAS**, **Python**, et **R** — choisissez celui avec lequel vous êtes le plus à l’aise ou essayez les trois.

---

## Accès aux données

Les quatre fichiers CSV sont disponibles dans la même structure de dossiers que dans l’Étape 1 :  

```
SAS-Hackathon-Bootcamp-2026/use-case-life-sciences/data
├── patients.csv          (500 records)
├── admissions.csv        (500 records)
├── clinical_measures.csv (500 records)
└── medications.csv       (326 records)
```

---

## Ce que vous allez faire

### 1. Charger les données et les cas d’usage

La première étape consiste à cloner le dépôt GitHub dans votre environnement SAS Studio en ouvrant un terminal et en exécutant la commande suivante :  


```SAS
data _null_;
    rc = git_clone('https://github.com/sascommunities/sas-hackathon-boot-camp-2026.git', "&_USERHOME./sas-hackathon-boot-camp-2026");
run;
```

Une fois cet extrait de code exécuté, accédez au panneau SAS Server, puis développez *SAS Server > Home > data > sas-hackathon-bootcamp-2026*. À partir de là, la structure familière de ce dépôt est disponible.


![image-20260528135335744](img/SAS-Studio/image-20260528135335744.png)

### 2. Créer une Data Card

Une **data card** est un document synthétique décrivant chaque jeu de données — — son objectif, sa taille, les noms de colonnes, les types de données et toute remarque de qualité. Les data cards sont une bonne pratique en matière d’IA responsable, car elles apportent de la transparence sur les données utilisées dans les modèles. Pour chaque table, vous produirez :

- Nombre de lignes et de colonnes
- Noms des colonnes et types de données
- Nombre de valeurs manquantes par colonne
- Exemples de lignes
- 
### 3. Obtenir des statistiques descriptives de base

Pour les colonnes numériques, calculez les statistiques descriptives (moyenne, médiane, écart-type, min, max). Pour les colonnes catégorielles, calculez les fréquences. Cela vous donne une première vue des distributions et des éventuels problèmes de qualité avant de commencer la création de variables *(feature engineering)*.

### 4. 4. Créer les variables et construire la table analytique (Analytical Base Table)

Les quatre jeux de données capturent chacun une dimension différente du parcours du patient. To build a predictive model we need to aggregate these into a single patient-level table where each row is one patient and each column is a feature. The key transformations are:

- **Medication features:** total medication count per patient, high-risk medication count, polypharmacy flag (5+ medications), unique medication classes
- **Clinical features:** BMI categories (underweight/normal/overweight/obese), blood pressure classification (normal/elevated/hypertension stage 1/hypertension stage 2), glucose level categories, clinical risk score
- **Admission features:** length of stay categories (short/medium/long), emergency admission flag, discharge disposition encoding
- **Patient features:** age, gender, insurance type, primary diagnosis category, comorbidity count

The final ABT will be saved as a CSV file that can then be promoted into CAS for use in SAS Visual Analytics and SAS Model Studio.

---

## Choose Your Language

Pick **one** language and run its script. You do not need to run all three — they each produce the same output. If you are unsure which to choose, pick the one you are most comfortable with.

| Language   | File                                                         |
| ---------- | ------------------------------------------------------------ |
| **SAS**    | [`data_preparation_studio.sas`](data_preparation_studio.sas) |
| **Python** | [`data_preparation_studio.py`](data_preparation_studio.py)   |
| **R**      | [`data_preparation_studio.R`](data_preparation_studio.R)     |

All three scripts produce the same output: a file called **`life_sciences_abt.csv`** in the `data/` folder. After the script finishes, **refresh the Explorer pane** to see the new file.

---

## Output

After running any of the scripts you will have:

| File | Description |
|------|-------------|
| `data/life_sciences_abt.csv` | The joined, feature-engineered, patient-level dataset ready for modeling |
| Console output | Data card information, summary statistics, and readmission distribution for review |

---

## Next Steps

Proceed to **[Step 3: Explore](../3-explore/)** to visually explore the data in SAS Visual Analytics using its built-in Copilot.
