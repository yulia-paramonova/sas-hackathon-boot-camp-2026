# Étape 4: Model

Dans cette étape, vous utiliserez **SAS Model Studio** pour construire, comparer et évaluer des modèles de prédiction de l’urgence des demandes de service. SAS Model Studio offre une interface visuelle de pipeline, un **Copilot** intégré, des capacités d’**AutoML**, ainsi que des outils pour le développement de modèles personnalisés — le tout avec une évaluation intégrée de l’équité. À la fin, vous enregistrerez votre modèle champion dans **SAS Model Manager**.

---

## Prérequis

La table de base analytique (`FINANCIAL_SERVICES_ABT`) doit être disponible dans la bibliothèque CAS **Public**. Si vous avez déjà réalisé les étapes 2 et 3, vous avez une bonne compréhension des données ; sinon, prenez un peu de temps pour parcourir les colonnes afin de mieux les comprendre.

---

## Ouverture de SAS Model Studio

1. Depuis la page d’accueil SAS Viya, ouvrez **SAS Model Studio** (dans *Build Models* du menu principal)
2.  Cliquez sur **New Project**
3. Configurez le projet :
   - **Name:** *PremierBank Loan Default Prediction*
   - **Project Type:** *Data Mining and Machine Learning*
   - **Data Source:** sélectionnez `FINANCIAL_SERVICES_ABT` depuis le caslib Public
   - Laissez **Template, Location & Description** par défaut
   - **Target Variable** (variable cible/à expliquer) : `defaulted`
4. Cliquez sur **Save**## Opening SAS Model Studio
    ![image-20260529074341035](img/README/image-20260529074341035.png)
5. Une fois le projet ouvert sur l’onglet Data, sélectionnez la variable `is_urgent` et définissez son rôle sur `Target`
    ![image-20260529074433687](img/README/image-20260529074433687.png)
6. Sur le même onglet, trouvez la variable `inc_Low` et activez la case `Assess this variable for bias`. Cela permettra d’illustrer les fonctionnalités de Trustworthy AI dans SAS Model Studio. Passez ensuite à l’onglet *Pipelines* pour commencer. 
    ![image-20260529074547357](img/README/image-20260529074547357.png)

Le projet est maintenant prêt pour commencer la modélisation.

---

## Utilisation du Copilot de SAS Model Studio

SAS Model Studio inclut un **Copilot** qui agit comme un assistant de modélisation basé sur l’IA. Accédez-y via l’icône Copilot dans la barre d’outils.  

*Pour le moment, SAS Viya Copilot fonctionne uniquement en anglais. Nous vous recommandons donc de formuler vos requêtes (prompts) en anglais afin d’obtenir des résultats fiables et de qualité.*

### Ce que le Copilot peut faire

- **Recommander des configurations de pipeline** — demandez-lui de proposer la meilleure approche pour un problème de classification binaire avec un déséquilibre des classe.   
*Suggest the best approach for a binary classification problem with imbalanced data*
- **Expliquer les résultats des modèles** — demandez-lui d’interpréter l’importance des variables, les métriques de comparaison des modèles  
*Interpret feature importance, model comparison metrics*
- **Générer des nœuds de pipeline** — décrivez votre besoin et le Copilot peut ajouter des nœuds
- **Répondre à des questions méthodologiques** — par exemple « Qu’est-ce que le gradient boosting ? » ou « Pourquoi la régression logistique est-elle préférée pour les modèles réglementaires ? »  
*"What is gradient boosting?" or "Why is logistic regression preferred for regulatory models?"*

### Example Copilot Prompts

- *"Set up an AutoML pipeline for binary classification with moderate class imbalance"*
- *"Add a variable selection node that removes features with importance below 1%"*
- *"Explain the difference between AUC-ROC and Gini coefficient for this default prediction problem"*
- *"Why would a regulator prefer logistic regression over a neural network?"*
- *"How should I handle the 74/26 class split in this dataset?"*
- *"What are adverse action reason codes and how do I generate them from this model?"*

---

## Approche 1 : AutoML (Point de départ recommandé)

AutoML entraîne et compare automatiquement plusieurs algorithmes, gère le prétraitement et sélectionne le meilleur modèle. C’est la façon la plus rapide d’obtenir une baseline solide.

### Configuration d’AutoML

1. Dans votre pipeline, cliquez sur **New Pipeline** puis sélectionnez **Automatically generate the pipeline**
2. Configurez :  
   - **Maximum Time :** définissez la durée (ex. 5 minutes pour le bootcamp) 
3. Cliquez sur **Save**
4. Le pipeline est ensuite généré automatiquement

### Ce que fait AutoML

AutoML va automatiquement :

- Tester plusieurs algorithmes (régression logistique, arbres, forêts aléatoires, gradient boosting, réseaux neuronaux, SVM)  
- Gérer le prétraitement (valeurs manquantes, encodage)  
- Optimiser les hyperparamètres  
- Comparer les modèles sur l’échantillon de validation  
- Classer les modèles selon la métrique choisie

### Analyse des résultats AutoML

Après exécution :  

1. Ouvrez le nœud **Model Comparison** pour voir le classement des modèles 
2. Cliquez sur un modèle pour voir :  
   - **Fit Statistics :** AUC, taux d’erreur, Gini, KS  
   - **ROC Chart :** comparaison visuelle de la capacité de discrimination du modèle  
   - **Variable Importance :** quelles sont les caractéristiques les plus importantes  
   - **Score Rankings :** dans quelle mesure le modèle distingue les prêts à haut risque des prêts et risque faible
3. Le meilleur modèle est automatiquement défini comme **champion**  

> **À quoi s'attendre :** pour cet ensemble de données, les modèles de gradient boosting ou de forêt aléatoire atteignent généralement un AUC compris entre 0,82 et 0,90. La régression logistique est généralement peu derrière avec un AUC entre 0,78 et 0,85.

---

## Approche 2 : Création d'un pipeline personnalisé

Si vous souhaitez disposer d'un plus grand contrôle — ou si vous souhaitez tester des types de modèles spécifiques —, créez un pipeline personnalisé étape par étape.

### Pourquoi la régression logistique est privilégiée par les régulateurs

Dans les services financiers, la **régression logistique** occupe un statut particulier :
- **Interprétabilité:** Chaque coefficient correspond directement à la contribution d'une caractéristique à la probabilité de défaut, ce qui facilite son explication aux régulateurs et aux demandeurs.
- **Génération des adverse action codes:** Les coefficients du modèle peuvent être classés par ordre de rang pour produire les principales raisons d'une décision de crédit (exigé par le FCRA/ECOA)
- **Familiarité réglementaire:** Les examinateurs ont de l'expérience avec la régression logistique et ses méthodes de validation
- **Conformité SR 11-7:** La gestion du risque lié aux modèles est simple lorsque le modèle est entièrement transparent

Cela ne veut pas dire que les modèles d’ensemble ne peuvent pas être utilisés, mais la régression logistique doit servir de référence.

### Nœuds de pipeline recommandés

Ajoutez ces nœuds dans l'ordre en cliquant sur **Add Node** dans l'espace de travail du pipeline :

1. **Data** —  Votre table d'entrée (déjà connectée)
3. **Imputation** — Traite les valeurs manquantes restantes (moyenne pour les valeurs numériques, mode pour les valeurs catégorielles)
5. **Model Nodes** —  Ajoutez un ou plusieurs des nœuds suivants :
   - **Logistic Regression** — Modèle de référence interprétable
   - **Forest** — Ensemble de forêts aléatoires
   - **Gradient Boosting** — Souvent le plus performant
6. **Model Comparison** — Compare automatiquement tous les nœuds de modèle et sélectionne le meilleur

### Configuration des modèles individuels

**Logistic Regression:**
- Critère d'arrêt du processus de sélection : niveau de significativité    
*Selection-process stopping criterion: Significance level*
- Niveau de significativité d'entrée : 0,05  
*Entry significance level: 0.05*
- Cela vous donne des coefficients interprétables pour chaque caractéristique

**Forest (Random Forest):**
- Nombre d'arbres (*Number of trees*) : 200
- Profondeur maximale (*Maximum depth*) : 10
- Accédez aux propriétés post-entraînement et activez *HyperSHAP* dans la section Interprétabilité locale. Cela sert à expliquer les prédictions du modèle  

**Gradient Boosting:**
- Nombre d'arbres (*Number of trees*) : 150
- Taux d'apprentissage (*Learning rate*) : 0.1
- Profondeur maximale (*Maximum depth*) : 5
- Taux de sous-échantillonnage (*Subsample rate*) : 0.8
### Exécution du pipeline personnalisé

1. Vérifiez que tous les nœuds sont connectés dans le canevas du pipeline
2. Cliquez sur **Run Pipeline** (ou cliquez avec le bouton droit sur le nœud Comparaison des modèles et sélectionnez *Run*)
3. Attendez que tous les modèles aient terminé leur apprentissage

---

## Comparaison des modèles

Une fois que les deux approches (ou l'une d'entre elles) ont été terminées, ouvrez les résultats du **Model Comparison** :

| Indicateur | Ce qu'il indique | Cible |
|------------|------------------|--------|
| **AUC-ROC** | Capacité globale à distinguer les demandes urgentes des non urgentes | >= 0.82 |
| **Misclassification Rate** - Taux de mauvaise de classification | Pourcentage de prédictions incorrectes | <= 0.15 |
| **F1 Score** | Moyenne harmonique de la précision et du rappel | >= 0.80 |
| **KS Statistic** | Séparation maximale entre les distributions cumulées | >= 0.45 |
| **Gini Coefficient** | 2 x AUC - 1; mesira le pouvoir de discrimination | >= 0.64 |

Consultez le **ROC Overlay Chart** (graphique de superposition ROC) pour comparer visuellement la capacité de chaque modèle à séparer les deux classes. Le modèle le plus proche du coin supérieur gauche est celui qui offre les meilleures performances.  

Consultez le graphique **Variable Importance** (Importance des variables) de votre modèle gagnant : les principaux prédicteurs devraient correspondre à ce que vous avez identifié à l'étape 3 (probablement `credit_score`, `late_payment_rate`, `debt_to_income`, `severe_delinquency_flag`, `loan_to_value`).

---

##  Évaluation de l'équité

Une IA digne de confiance exige que les modèles ne discriminent pas injustement certains groupes. Dans le domaine du crédit, il ne s’agit pas seulement d’une bonne pratique éthique — c’est une **obligation légale** au titre de l’ECOA et du Fair Housing Act. Dans ce cas d’usage, nous allons évaluer l’équité par rapport à la **tranche de revenu**, utilisée comme variable proxy. 

### Pourquoi la tranche de revenu ?

Bien que le revenu ne soit pas une classe légalement protégée en soi, il peut servir de **proxy pour des caractéristiques protégées** telles que la race et l’origine nationale. Les recherches montrent de manière constante que le revenu est corrélé à la race et à l’ethnicité aux États‑Unis. Si le modèle traite systématiquement les emprunteurs à faible revenu différemment d’une manière qui n’est pas justifiée par leur risque de crédit réel, cela pourrait constituer un **impact disparate** — une forme de discrimination illégale même lorsqu’elle est involontaire.

Les réglementations sur le crédit équitable exigent que les prêteurs :

1. **Testent l’impact disparate:** Les taux d’approbation ou les prix diffèrent‑ils entre les groupes définis par des caractéristiques protégées ou leurs proxys ?
2. **Justifient par une nécessité commerciale:** Si un impact disparate existe, est‑il dû à des facteurs légitimes de risque de crédit ?
3. **Cherchent des alternatives moins discriminatoires:** Même si l’impact est justifié, existe‑t‑il un modèle ou une politique permettant une prédiction du risque similaire avec moins de disparités ?

### Exécuter l’évaluation d’équité
1. En définissant la variable `inc_Low` comme variable à évaluer pour l’équité, nous obtenons cette évaluation pour chaque modèle.
2. Examiner les indicateurs d’équité (onglet `Fairness and Bias` dans les résultats de chaque modèle)::

| Indicateur | Ce qu'il mesure | Valeurs acceptables |
|--------|---------------|------------------|
| **Demographic Parity (Parité démographique)** | Les prédictions d'urgence sont-elles réparties de manière égale entre les tranches de revenus ? | Ratio > 0.80 |
| **Equal Opportunity (Égalité des chances)** | Le taux de vrais positifs(détection des défauts réels) est-il similaire pour toutes les tranches de revenu ? | Différence < 0.10 |
| **Predictive Parity (Parité prédictive)** | La précision est-elle similaire pour toutes les tranches de revenu ? | Différence < 0.10 |
| **Calibration (Calibrage)** | Une probabilité prédite de 20 % signifie-t-elle une urgence réelle de 70 % pour les deux groupes ? | Pente proche de 1.0 |

### Interpréter les résultats
- Si la **parité démographique** *(Demographic Parity)* est inférieure à 0,80, le modèle signale de manière disproportionnée un groupe de revenu comme étant à haut risque.
- Si la **différence d’égalité des chances** *(Equal Opportunity difference)* dépasse 0,10, le modèle détecte mieux les défauts dans un groupe de revenu que dans l’autre.
- Examiner la **distribution des scores** *(Score Distribution)* par groupe — les deux groupes devraient présenter des courbes de forme similaire.
- Si vous trouvez des preuves d’impact disparate, envisagez:
   - de supprimer les variables proxy
   - de ré‑équilibrer les données d’entraînement
   - d’utiliser une approche d’optimisation contrainte
   - de passer à un modèle offrant une AUC similaire avec moins de disparités

### La valeur de l’évaluation d’équité dans le crédit
L’évaluation d’équité apporte à la fois conformité et valeur commerciale :

1. **Conformité réglementaire:** Les audits de crédit équitable recherchent spécifiquement l’impact disparate — une évaluation documentée est votre meilleure défense.
2. **Exactitude des motifs d’action défavorable:** Des modèles équitables produisent des motifs plus précis, réduisant la confusion et les réclamations des demandeurs.
3. **Réduction du risque juridique:** Identifier et atténuer proactivement les biais évite des actions coercitives coûteuses et des recours collectifs.
4. **Confiance communautaire:** Une équité démontrable renforce la réputation de la banque dans les communautés qu’elle sert.
5. **Meilleures décisions:** Un modèle performant de manière équitable entre segments produit des évaluations de risque plus fiables pour tous.

> **Astuce:** Demandez à Copilot *" Mon modèle est‑il équitable entre les tranches de revenu ? "* pour obtenir une interprétation en langage clair des métriques d’équité.

---

## Enregistrement dans SAS Model Manager

Une fois votre modèle champion sélectionné et son équité vérifiée, enregistrez‑le dans **SAS Model Manager** pour la gouvernance, le contrôle de version et le déploiement.

### Étapes d’enregistrement

1. Dans l’onglet Pipeline Comparison, identifiez votre *modèle champion* (celui avec le meilleur KS (Youden))
2. Faites un clic droit sur le modèle champion et sélectionnez **Register Model** (ou via le menu : *Actions* > *Register Model*)
    ![image-20260529075650887](img/README/image-20260529075650887.png)
3. Confirmez l’emplacement /Model Repositories/DM Repository puis cliquez sur OK
4. Attendez la fin de l’enregistrement dans la fenêtre contextuelle, puis fermez‑la. Faites ensuite un clic droit sur le modèle et sélectionnez **Manage Models**
5. Vous êtes maintenant redirigé vers SAS Model Manager où vous pouvez consulter la *Model Card* du modèle
6.Explorez la Model Card générée automatiquement au fur et à mesure du développement et de la gestion du modèle dans SAS Viya. L’onglet Overview fournit un résumé de haut niveau : précision d’entraînement, équité d’entraînement, généralisabilité et variables influentes.
    ![image-20260529075909381](img/README/image-20260529075909381.png)

### Ce que l’enregistrement apporte
Une fois enregistré dans SAS Model Manager, votre modèle bénéficie de :
- **Contrôle de version:** Suivi des modifications entre itérations
- **Surveillance des performances:** Mise en place d’un suivi automatisé dans le temps.
- **Gouvernance:** Traçabilité complète : auteur, données utilisées, contrôles d’équité effectués.
- **Préparation au déploiement:** Publication possible vers CAS, MAS (Micro Analytic Service) ou un conteneur pour le scoring.
- **Model Card:** Documentation auto‑générée incluant entrées, sorties, performances et lignage — essentielle pour la conformité SR 11‑7
> **Astuce:** Demandez à Copilot « Enregistre ce modèle dans Model Manager » pour être guidé pas à pas.

---

## Résumé
À ce stade, vous avez :
1. Construit des modèles via AutoML et/ou des pipelines personnalisés
2. Comparé les modèles selon l’AUC, le Gini, le KS et d’autres métriques
3. Évalué l’équité entre tranches de revenu pour la conformité au crédit équitable
4. Enregistré votre modèle champion dans SAS Model Manager
5. Consulté la Model Card dans SAS Model Manager

---

## Prochaines étapes 

Passez à l'**[Étape 5: Deploy & Act](../5-deploy-and-act/)** pour créer un flux de décision de prêt dans SAS Intelligent Decisioning et opérationnaliser votre modèle.
