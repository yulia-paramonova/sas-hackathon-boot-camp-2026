
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

### 4. Créer des variables et construire l’Analytical Base Table

Les quatre jeux de données capturent chacun une dimension différente de la prestation de services de Metro City. Pour construire un modèle prédictif, nous devons les combiner en une seule table au niveau des demandes, où chaque ligne correspond à une demande de service et chaque colonne à une caractéristique. Les transformations clés sont :

- **Variables liées aux médicaments:** nombre total de médicaments par patient, nombre de médicaments à haut risque, indicateur de polymédication (5+ médicaments), classes de médicaments uniques
- **Caractéristiques cliniques:** catégories d’IMC (insuffisance pondérale/normal/surpoids/obésité), classification de la pression artérielle (normale/élevée/hypertension stade 1/hypertension stade 2), catégories de niveau de glucose, score de risque clinique
- **Caractéristiques d’admission:** catégories de durée de séjour (court/moyen/long), indicateur d’admission en urgence, encodage du mode de sortie
- **Caractéristiques des patients:** âge, sexe, type d’assurance, catégorie de diagnostic principal, nombre de comorbidités

L’ABT finale sera enregistrée en fichier CSV, puis pourra être promue dans CAS pour une utilisation dans SAS Visual Analytics et SAS Model Studio.

---

## Choisissez votre langage

Choisissez **un** langage et exécutez son script. Vous n’avez pas besoin d’exécuter les trois — ils produisent tous le même résultat. Si vous hésitez, prenez celui que vous maîtrisez le mieux.

| Language   | Fichier                                                         |
| ---------- | ------------------------------------------------------------ |
| **SAS**    | [`data_preparation_studio.sas`](data_preparation_studio.sas) |
| **Python** | [`data_preparation_studio.py`](data_preparation_studio.py)   |
| **R**      | [`data_preparation_studio.R`](data_preparation_studio.R)     |

Les trois scripts produisent le même fichier :  **`life_sciences_abt.csv`** dans le dossier  `data/` . Après exécution, **rafraîchissez le panneau Explorer** pour voir le nouveau fichier.


---
## Résultat

Après avoir exécuté l’un des scripts, vous obtiendrez :

| Fichier | Description |
|------|-------------|
| `data/life_sciences_abt.csv` | Le jeu de données joint, enrichi et prêt pour la modélisation |
| Sortie console  | Informations de data card, statistiques descriptives des réadmissions pour révision |
---

## Prochaines étapes

Passez à  **[Step 3: Explore](../3-explore/)** pour explorer visuellement les données dans SAS Visual Analytics grâce à son Copilot intégré.
