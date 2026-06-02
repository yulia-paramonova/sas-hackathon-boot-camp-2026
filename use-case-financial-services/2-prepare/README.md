# Étape 2: Prepare

Dans cette étape, vous allez travailler dans **SAS Viya Workbench** pour charger les quatre jeux de données PremierBank, les profiler et les joindre dans une **Analytical Base Table (ABT)** prête pour l’exploration dans SAS Visual Analytics et la modélisation dans SAS Model Studio.

SAS Viya Workbench vous offre la liberté de coder dans le langage de votre choix. Nous fournissons un code équivalent en **SAS**, **Python** et **R** — choisissez celui avec lequel vous êtes le plus à l’aise ou essayez les trois.

---

## Accès aux données

Les quatre fichiers CSV sont disponibles dans la même structure de dossiers que dans l’Étape 1 :
```
SAS-Hackathon-Bootcamp-2026/use-case-financial-services/data
├── loan_applications.csv    (500 enregistrements)
├── credit_history.csv       (500 enregistrements)
├── employment.csv           (500 enregistrements)
└── payment_history.csv      (500 enregistrements)
```

---

## Ce que vous allez faire

### 1. Configurer votre environnement dans SAS Viya Workbench
Une fois connecté à SAS Viya Workbench, vous devrez d’abord choisir l’environnement de programmation et les langages que vous souhaitez utiliser. Une fois cela fait, un second onglet s’ouvrira et vous devrez patienter un moment jusqu’à ce que l’environnement s'affiche.

![image-20260527164013080](img/README/image-20260527164013080.png)

### 2. Charger les données et les cas d’usage

La première étape consiste à cloner le dépôt GitHub dans votre environnement SAS Viya Workbench en ouvrant un terminal et en exécutant la commande suivante :

```bash
git clone https://github.com/sascommunities/sas-hackathon-boot-camp-2026.git
```

Si vous êtes dans Visual Studio Code, vous pouvez utiliser le raccourci clavier CTRL+´, ou suivre le chemin indiqué dans la capture ci-dessous :

![image-20260527164702224](img/README/image-20260527164702224.png)

Après avoir exécuté la commande git clone, vous devriez voir la structure de dossiers suivante. Naviguez ensuite vers votre cas d’usage et le dossier 2-prepare pour accéder aux fichiers.

![image-20260527170112447](img/README/image-20260527170112447.png)

### 3. Créer une Data Card
Une **data card** est un document synthétique décrivant chaque jeu de données — son objectif, sa taille, les noms de colonnes, les types de données et toute remarque de qualité. Les data cards sont une bonne pratique en matière d’IA responsable, car elles apportent de la transparence sur les données utilisées dans les modèles. Pour chaque table, vous produirez :
- Nombre de lignes et de colonnes
- Noms des colonnes et types de données
- Nombre de valeurs manquantes par colonne
- Exemples de lignes

### 4. Obtenir des statistiques descriptives de base
Pour les colonnes numériques, calculez les statistiques descriptives (moyenne, médiane, écart-type, min, max). Pour les colonnes catégorielles, calculez les fréquences. Cela vous donne une première vue des distributions et des éventuels problèmes de qualité avant de commencer l’ingénierie des variables.

### 5. Créer des variables et construire l’Analytical Base Table
Les quatre jeux de données capturent chacun une dimension différente du risque de prêt. Pour construire un modèle prédictif, nous devons les agréger dans une table unique au niveau du prêt, où chaque ligne représente un prêt et chaque colonne une variable. Les transformations clés sont :

- **Variables de comportement de paiement** : taux de retard, indicateur de retard sévère (60+ jours), moyenne des jours de retard, ratio de paiement insuffisant
- **Variables de crédit** : bandes de score FICO, catégories d’utilisation du crédit, indicateurs de faillite et de délinquance, nombre d’enquêtes
- **Variables d’emploi** : bandes de revenu, ratio service de la dette, statut de vérification emploi/revenu, bandes d’années d’emploi
- **Variables de prêt** : ratio prêt/valeur, ratio dette/revenu, montant du prêt, durée, taux d’intérêt, objectif, type de propriété

L’ABT finale sera enregistrée en fichier CSV, puis pourra être promue dans CAS pour une utilisation dans SAS Visual Analytics et SAS Model Studio.

---

## Choisissez votre langage
Choisissez **un** langage et exécutez son script. Vous n’avez pas besoin d’exécuter les trois — ils produisent tous le même résultat. Si vous hésitez, prenez celui que vous maîtrisez le mieux.

| Language | Fichier | Comment exécuter |
|----------|------|------------|
| **SAS** | [`data_preparation.sas`](data_preparation.sas) |Ouvrez le fichier et cliquez sur **Run** dans la barre d’outils |
| **Python** | [`data_preparation.py`](data_preparation.py) | Ouvrez le fichier et cliquez sur **Run** dans la barre d’outils |
| **R** | [`data_preparation.R`](data_preparation.R) |Les scripts R n’ont pas de bouton Run. Ouvrez un terminal (*Terminal > New Terminal*) et exécutez: `Rscript data_preparation.R` |

Les trois scripts produisent le même fichier : **`financial_services_abt.csv`** dans le dossier `data/`.
Après exécution, **rafraîchissez le panneau Explorer** pour voir le nouveau fichier.

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
