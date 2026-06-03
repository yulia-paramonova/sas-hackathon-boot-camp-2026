# Étape 2: Prepare

Dans cette étape, vous allez travailler dans **SAS Studio** pour charger les quatre jeux de données ShopEase, les profiler et les joindre dans une **Analytical Base Table (ABT)** prête pour l’exploration dans SAS Visual Analytics et la modélisation dans SAS Model Studio.

SAS Studio vous offre la liberté de coder dans le langage de votre choix ou de construire un flux visuel. Nous fournissons un code équivalent en **SAS**, **Python** et **R** — choisissez celui avec lequel vous êtes le plus à l’aise ou essayez les trois.

---

## Accès aux données

Les quatre fichiers CSV sont disponibles dans la même structure de dossiers que dans l’Étape 1 :

```text
SAS-Hackathon-Bootcamp-2026/use-case-retail/data
├── customers.csv          (1,000 records)
├── transactions.csv       (~5,000 records)
├── sessions.csv           (~10,000 records)
└── support_tickets.csv    (~400 records)
```

---

## Ce que vous allez faire

### 1. Charger les données et les cas d’usage

Dans un premier temps, clonez le dépôt GitHub dans votre environnement SAS Studio en ouvrant un programme SAS puis en exécutant le code ci-dessous, qui clone le dépôt dans le système de fichiers :

```SAS
data _null_;
    rc = git_clone('https://github.com/sascommunities/sas-hackathon-boot-camp-2026.git', "&_USERHOME./sas-hackathon-boot-camp-2026");
run;
```

Une fois ce code exécuté, allez dans le panneau SAS Server puis développez _SAS Server > Home > data > sas-hackathon-bootcamp-2026_. Vous y retrouverez la structure habituelle du dépôt.

![image-20260528135335744](img/SAS-Studio/image-20260528135335744.png)

### 2. Créer une Data Card

Une **data card** est un document synthétique qui décrit chaque jeu de données : son objectif, sa taille, les noms de colonnes, les types de données et les éventuelles notes de qualité. Les data cards sont une bonne pratique d’IA responsable car elles apportent de la transparence sur les données utilisées dans les modèles. Pour chaque table, vous produirez :

- Nombre de lignes et de colonnes
- Noms des colonnes avec types de données
- Nombre de valeurs manquantes par colonne
- Exemples de lignes

### 3. Obtenir des statistiques descriptives de base

Pour les colonnes numériques, calculez des statistiques descriptives (moyenne, médiane, écart-type, min, max). Pour les colonnes catégorielles, calculez les fréquences. Cela donne une première vue des distributions et des éventuels problèmes de qualité des données avant de commencer la feature engineering.

### 4. Faire de la feature engineering et construire l’Analytical Base Table

Les quatre jeux de données capturent chacun une dimension différente du comportement client. Pour construire un modèle prédictif, nous devons les agréger dans une table unique au niveau client, où chaque ligne représente un client et chaque colonne une variable. Les transformations clés sont :

- **Variables transactionnelles :** dépense totale, valeur moyenne de commande, fréquence d’achat, jours depuis le dernier achat, diversité des catégories produits
- **Variables de session :** nombre total de sessions, durée moyenne de session, pages vues, taux d’abandon panier, taux d’usage mobile
- **Variables de support :** nombre total de tickets, nombre de tickets haute priorité, temps moyen de résolution, score de satisfaction
- **Variables client :** âge, ancienneté du compte, niveau d’abonnement, statut d’opt-in e-mail

L’ABT finale sera enregistrée au format CSV, puis pourra être promue dans CAS pour une utilisation dans SAS Visual Analytics et SAS Model Studio.

---

## Choisissez votre langage

Choisissez **un** langage et exécutez son script. Vous n’avez pas besoin d’exécuter les trois — ils produisent tous la même sortie. Si vous hésitez, choisissez celui avec lequel vous êtes le plus à l’aise.

| Language   | File                                                         |
| ---------- | ------------------------------------------------------------ |
| **SAS**    | [`data_preparation_studio.sas`](data_preparation_studio.sas) |
| **Python** | [`data_preparation_studio.py`](data_preparation_studio.py)   |
| **R**      | [`data_preparation_studio.R`](data_preparation_studio.R)     |

Les trois scripts produisent la même sortie : un fichier appelé **`retail_abt.csv`** dans le dossier `data/`. Une fois le script terminé, **rafraîchissez le panneau Explorer** pour voir le nouveau fichier.

---

## Résultat

Après avoir exécuté l’un des scripts, vous obtiendrez :

| File                  | Description                                                                              |
| --------------------- | ---------------------------------------------------------------------------------------- |
| `data/retail_abt.csv` | Jeu de données joint, enrichi et au niveau client, prêt pour la modélisation             |
| Console output        | Informations de data card, statistiques descriptives et distribution du churn pour revue |

---

## Prochaines étapes

Passez à **[Étape 3: Explore](../3-explore/)** pour explorer visuellement les données dans SAS Visual Analytics avec son Copilot intégré.
