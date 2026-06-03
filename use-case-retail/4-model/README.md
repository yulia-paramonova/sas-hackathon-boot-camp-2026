# Étape 4 : Modéliser

Dans cette étape, vous allez utiliser **SAS Model Studio** pour construire, comparer et évaluer des modèles de prédiction de l'attrition. SAS Model Studio propose une interface visuelle de pipeline, un **Copilot** intégré, des capacités **AutoML**, ainsi que des outils de construction de modèles personnalisés, le tout avec une évaluation de l'équité intégrée. À la fin, vous enregistrerez votre modèle champion dans **SAS Model Manager**.

---

## Prérequis

La table de base analytique (`RETAIL_ABT`) doit être disponible dans la bibliothèque CAS **Public**. Si vous avez suivi les étapes 2 et 3 avant celle-ci, vous aurez déjà une compréhension complète des données ; sinon, prenez un peu plus de temps pour parcourir les colonnes afin de bien comprendre les données.

---

## Ouvrir SAS Model Studio

1. Depuis la page d'accueil SAS Viya, ouvrez **SAS Model Studio** (dans _Build Models_ du menu principal)
2. Cliquez sur **New Project**
3. Configurez le projet :
    - **Name:** _ShopEase Customer Churn Prediction_
    - **Project Type:** _Data Mining and Machine Learning_
    - **Data Source:** Sélectionnez `RETAIL_ABT` depuis la caslib Public
    - Laissez **Template, Location & Description** avec les valeurs par défaut
    - **Target Variable:** `churned`
4. Cliquez sur **Save**
   ![image-20260529153600194](img/README/image-20260529153600194.png)
5. Une fois le projet SAS Model Studio ouvert sur l'onglet Data, sélectionnez la variable `churned` et définissez son rôle sur ´Target´
   ![image-20260529153658091](img/README/image-20260529153658091.png)
6. Sur ce même onglet, repérez la variable `tier_Basic` et activez la case `Assess this variable for bias`. Cela nous permettra de parler davantage des fonctionnalités d'IA de confiance de SAS Model Studio, puis cliquez sur l'onglet _Pipelines_ pour commencer.
   ![image-20260529153729615](img/README/image-20260529153729615.png)

Le projet est maintenant prêt pour commencer la modélisation.

---

## Utiliser le Copilot de SAS Model Studio

SAS Model Studio inclut un **Copilot** qui agit comme votre assistant de modélisation propulsé par l'IA. Accédez-y via l'icône Copilot dans la barre d'outils.

### Ce que le Copilot peut faire

- **Recommander des configurations de pipeline** — demandez-lui de suggérer la meilleure approche pour un problème de classification binaire avec des données déséquilibrées
- **Expliquer les résultats des modèles** — demandez-lui d'interpréter l'importance des variables, les métriques de comparaison des modèles ou les rapports d'équité
- **Générer des nœuds de pipeline** — décrivez ce que vous voulez et le Copilot peut ajouter des nœuds à votre pipeline
- **Répondre aux questions de méthodologie** — posez des questions comme "What is gradient boosting?" ou "How does SMOTE work?"

### Exemples de prompts Copilot

- _"Set up an AutoML pipeline for binary classification with class imbalance handling"_
- _"Add a variable selection node that removes features with importance below 1%"_
- _"Explain the difference between AUC-ROC and F1 score for this churn problem"_
- _"What does the misclassification rate tell me about my model?"_
- _"How should I handle the 69/31 class split in this dataset?"_

---

## Approche 1 : AutoML (point de départ recommandé)

AutoML entraîne et compare automatiquement plusieurs algorithmes, gère le prétraitement et sélectionne le meilleur modèle. C'est le moyen le plus rapide d'établir une base solide.

### Configurer AutoML

1. Dans le pipeline de votre projet, cliquez sur **New Pipeline** puis sélectionnez **Automatically generate the pipeline**
2. Configurez les paramètres AutoML :
    - **Maximum Time:** Définissez un budget de temps (par ex., 5 minutes pour le bootcamp)
3. Cliquez sur **Save**
4. Le pipeline va maintenant être construit pour vous.

### Ce que fait AutoML

AutoML va automatiquement :

- Tester plusieurs algorithmes (régression logistique, arbres de décision, forêts aléatoires, gradient boosting, réseaux de neurones, machines à vecteurs de support)
- Gérer le prétraitement des variables (imputation des valeurs manquantes, encodage)
- Ajuster les hyperparamètres
- Comparer les modèles sur l'ensemble de validation
- Classer les modèles selon la métrique d'optimisation choisie

### Revoir les résultats AutoML

Après l'exécution :

1. Ouvrez le nœud **Model Comparison** pour voir tous les modèles classés par AUC
2. Cliquez sur chaque modèle pour voir :
    - **Fit Statistics:** AUC, misclassification rate, coefficient de Gini, statistique KS
    - **ROC Chart:** Comparaison visuelle du pouvoir discriminant des modèles
    - **Variable Importance:** Les variables les plus importantes
    - **Score Rankings:** La capacité du modèle à séparer les clients à haut risque et à faible risque
3. Le meilleur modèle est automatiquement sélectionné comme **champion**

> **À prévoir :** Pour ce jeu de données, les modèles de gradient boosting ou de forêt aléatoire atteignent généralement une AUC de 0.82 à 0.88. La régression logistique suit souvent de près avec 0.78 à 0.83.

---

## Approche 2 : Construction d'un pipeline personnalisé

Si vous voulez plus de contrôle, ou expérimenter des types de modèles spécifiques, construisez un pipeline personnalisé étape par étape.

### Nœuds de pipeline recommandés

Ajoutez ces nœuds dans l'ordre en cliquant sur **Add Node** dans le canevas du pipeline :

1. **Data** — Votre table d'entrée (déjà connectée)
2. **Imputation** — Gérer les valeurs manquantes restantes (moyenne pour les numériques, mode pour les catégorielles)
3. **Model Nodes** — Ajoutez un ou plusieurs des suivants :
    - **Logistic Regression** — Modèle de base interprétable
    - **Forest** — Ensemble de forêts aléatoires
    - **Gradient Boosting** — Souvent le meilleur performeur
4. **Model Comparison** — Compare automatiquement tous les nœuds de modèle et sélectionne le champion

### Configurer les modèles individuels

**Logistic Regression :**

- Selection-process stopping criterion: Significance level
- Entry significance level: 0.05
- Cela vous donne des coefficients interprétables pour chaque variable

**Forest (Random Forest) :**

- Number of trees: 200
- Maximum depth: 10
- Allez dans les Post-training Properties et activez _HyperSHAP_ dans la section Local Interpretability. Cela sert à expliquer les prédictions du modèle

**Gradient Boosting :**

- Number of trees: 150
- Learning rate: 0.1
- Maximum depth: 5
- Subsample rate: 0.8

### Exécuter le pipeline personnalisé

1. Vérifiez que tous les nœuds sont connectés dans le canevas du pipeline
2. Cliquez sur **Run Pipeline** (ou faites un clic droit sur le nœud Model Comparison puis sélectionnez _Run_)
3. Attendez que tous les modèles aient terminé l'entraînement

---

## Comparer les modèles

Une fois l'une ou les deux approches terminées, ouvrez les résultats de **Model Comparison** :

| Metric                     | Ce que cela indique                                                       | Cible  |
| -------------------------- | ------------------------------------------------------------------------- | ------ |
| **AUC-ROC**                | Capacité globale à distinguer les clients en attrition des clients actifs | ≥ 0.80 |
| **Misclassification Rate** | Pourcentage de prédictions incorrectes                                    | ≤ 0.20 |
| **KS Statistic**           | Séparation maximale entre distributions cumulées                          | ≥ 0.40 |
| **Gini Coefficient**       | 2 x AUC - 1 ; mesure le pouvoir discriminant                              | ≥ 0.60 |
| **F1 Score**               | Moyenne harmonique de la précision et du rappel                           | ≥ 0.70 |

Examinez le **ROC Overlay Chart** pour comparer visuellement la capacité de chaque modèle à séparer les deux classes. Le modèle le plus proche du coin supérieur gauche est le meilleur.

Examinez le graphique **Variable Importance** de votre modèle champion — les principaux prédicteurs doivent correspondre à ce que vous avez trouvé à l'étape 3 (probablement `days_since_last_purchase`, `total_sessions`, `avg_session_duration`, `total_spend`).

---

## Évaluation de l'équité

Une IA de confiance exige que les modèles ne discriminent pas injustement les groupes protégés. Dans ce cas d'usage, nous allons évaluer l'équité par rapport au **niveau d'abonnement** — en particulier si le modèle traite équitablement les clients du niveau Basic par rapport aux clients du niveau Premium.

### Pourquoi le niveau d'abonnement ?

Même si le niveau d'abonnement n'est pas une classe légalement protégée (comme la race ou le genre), il peut servir de **proxy du statut économique**. Si le modèle identifie systématiquement les clients Basic comme à haut risque d'attrition tout en épargnant les clients Premium, les campagnes de rétention qui en résultent pourraient :

- Surcibler les clients à faible dépense avec des remises agressives, ce qui érode les marges
- Sous-servir les clients à forte dépense qui se désengagent en silence
- Créer une prophétie autoréalisatrice où les clients Basic reçoivent des messages "nous pensons que vous allez partir" qui les poussent effectivement à partir

L'analyse de l'équité garantit que le modèle fonctionne **équitablement selon les segments** et que les actions métier basées sur les scores du modèle ne discriminent pas involontairement.

### Exécuter l'évaluation de l'équité

1. Comme nous avons défini la variable `tier_Basic` pour l'évaluation d'équité, nous obtenons ces évaluations avec chaque modèle
2. Examinez les métriques d'équité :

| Metric                 | Ce que cela mesure                                                                              | Plage acceptable   |
| ---------------------- | ----------------------------------------------------------------------------------------------- | ------------------ |
| **Demographic Parity** | Les prédictions d'attrition sont-elles réparties de façon équivalente entre les niveaux ?       | Ratio > 0.80       |
| **Equal Opportunity**  | Le taux de vrais positifs est-il similaire entre les niveaux ?                                  | Difference < 0.10  |
| **Predictive Parity**  | La précision est-elle similaire entre les niveaux ?                                             | Difference < 0.10  |
| **Calibration**        | Une probabilité prédite de 70 % signifie-t-elle 70 % d'attrition réelle pour les deux groupes ? | Slope close to 1.0 |

### Interpréter les résultats

- Si **Demographic Parity** est inférieur à 0.80, le modèle signale de manière disproportionnée un niveau comme à haut risque
- Si la différence d'**Equal Opportunity** dépasse 0.10, le modèle détecte mieux les churners dans un niveau que dans l'autre
- Examinez la **Score Distribution** par groupe — les courbes des deux groupes doivent avoir des formes similaires

### La valeur de l'évaluation de l'équité

L'évaluation de l'équité n'est pas seulement une case éthique à cocher — elle apporte une **valeur métier directe** :

1. **De meilleures décisions :** Un modèle qui fonctionne aussi bien sur tous les segments permet des campagnes de rétention plus efficaces pour tous
2. **Confiance :** Les parties prenantes (marketing, customer success, finance) font davantage confiance aux modèles quand elles voient des preuves d'équité
3. **Réduction du risque :** Identifier les biais de manière proactive évite des corrections coûteuses plus tard
4. **Préparation réglementaire :** Avec l'extension des réglementations sur l'IA, une évaluation d'équité documentée devient une exigence de conformité

> **Astuce :** Demandez au Copilot _"Is my model fair across subscription tiers?"_ pour obtenir une interprétation en langage naturel des métriques d'équité.

---

## Enregistrer dans SAS Model Manager

Une fois votre modèle champion sélectionné et son équité vérifiée, enregistrez-le dans **SAS Model Manager** pour la gouvernance, le contrôle de version et le déploiement.

### Étapes d'enregistrement

1. Dans l'onglet Pipeline Comparison, identifiez votre **modèle champion** global (celui avec le meilleur KS (Youden))
2. Faites un clic droit sur le modèle champion et sélectionnez **Register Model** (ou utilisez le menu : _Actions_ > _Register Model_)
   ![image-20260529153859705](img/README/image-20260529153859705.png)
3. Confirmez l'emplacement /Model Repositories/DM Repository puis cliquez sur OK
4. Attendez la fin de l'enregistrement dans la fenêtre pop-up, puis fermez-la, faites de nouveau un clic droit sur le modèle et sélectionnez **Manage Models**
5. Vous serez maintenant redirigé vers SAS Model Manager où vous pourrez consulter la Model Card de ce modèle
6. Explorez la Model Card qui se renseigne automatiquement à mesure que vous développez et gérez le modèle dans SAS Viya. L'onglet Overview fournit un résumé global du modèle, incluant la précision d'entraînement, l'équité d'entraînement, la généralisabilité et les variables influentes.

![image-20260529153940567](img/README/image-20260529153940567.png)

### Ce que l'enregistrement apporte

Une fois enregistré dans SAS Model Manager, votre modèle bénéficie de :

- **Contrôle de version :** Suivi des changements à travers les itérations du modèle
- **Suivi des performances :** Mise en place d'un suivi automatisé des performances dans le temps
- **Gouvernance :** Maintien d'une piste d'audit indiquant qui a construit le modèle, quelles données ont été utilisées et quels contrôles d'équité ont été effectués
- **Prêt pour le déploiement :** Le modèle peut être publié vers CAS, MAS (Micro Analytic Service) ou un conteneur pour le scoring
- **Model card :** Documentation auto-générée capturant les entrées, sorties, performances et la traçabilité

> **Astuce :** Demandez au Copilot _"Register this model to Model Manager"_ et il vous guidera dans le processus.

---

## Résumé

À ce stade, vous avez :

1. Construit des modèles avec AutoML et/ou des pipelines personnalisés
2. Comparé les modèles sur l'AUC, le misclassification rate et d'autres métriques
3. Évalué l'équité entre les niveaux d'abonnement
4. Enregistré votre modèle champion dans SAS Model Manager
5. Consulté la Model Card dans SAS Model Manager

---

## Prochaines étapes

Passez à **[Étape 5 : Déployer & agir](../5-deploy-act/)** pour créer un flux de décision dans SAS Intelligent Decisioning qui opérationnalise votre modèle.
