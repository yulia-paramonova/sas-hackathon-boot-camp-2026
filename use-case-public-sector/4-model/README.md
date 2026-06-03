# Étape 4: Model

Dans cette étape, vous utiliserez **SAS Model Studio** pour construire, comparer et évaluer des modèles de prédiction de l’urgence des demandes de service. SAS Model Studio offre une interface visuelle de pipeline, un **Copilot** intégré, des capacités d’**AutoML**, ainsi que des outils pour le développement de modèles personnalisés — le tout avec une évaluation intégrée de l’équité. À la fin, vous enregistrerez votre modèle champion dans **SAS Model Manager**.

---

## Prérequis

La table de base analytique (`PUBLIC_SECTOR_ABT`) doit être disponible dans la bibliothèque CAS **Public**. Si vous avez déjà réalisé les étapes 2 et 3, vous avez une bonne compréhension des données ; sinon, prenez un peu de temps pour parcourir les colonnes afin de mieux les comprendre.

---

## Ouverture de SAS Model Studio

1. Depuis la page d’accueil SAS Viya, ouvrez **SAS Model Studio** (dans *Build Models* du menu principal)
2.  Cliquez sur **New Project**
3. Configurez le projet :
   - **Name:** *Metro City Service Request Urgency Prediction*
   - **Project Type:** *Data Mining and Machine Learning*
   - **Data Source:** sélectionnez `PUBLIC_SECTOR_ABT` depuis le caslib Public
   - Laissez **Template, Location & Description** par défaut
   - **Target Variable** (variable cible/à expliquer) : `is_urgent`
4. Cliquez sur **Save**
    ![image-20260529152912346](img/README/image-20260529152912346.png)
5. Une fois le projet ouvert sur l’onglet Data, sélectionnez la variable `is_urgent` et définissez son rôle sur `Target`
    ![image-20260529153017456](img/README/image-20260529153017456.png)
6. Sur le même onglet, trouvez la variable `age_65+` et activez la case `Assess this variable for bias`. Cela permettra d’illustrer les fonctionnalités de Trustworthy AI dans SAS Model Studio. Passez ensuite à l’onglet *Pipelines* pour commencer. 
    ![image-20260529153035379](img/README/image-20260529153035379.png)

Le projet est maintenant prêt pour commencer la modélisation.

---

## Utilisation du Copilot de SAS Model Studio

SAS Model Studio inclut un **Copilot** qui agit comme un assistant de modélisation basé sur l’IA. Accédez-y via l’icône Copilot dans la barre d’outils.  

*Pour le moment, SAS Viya Copilot fonctionne uniquement en anglais. Nous vous recommandons donc de formuler vos requêtes (prompts) en anglais afin d’obtenir des résultats fiables et de qualité.*

### Ce que le Copilot peut faire

- **Recommander des configurations de pipeline** — demandez-lui de proposer la meilleure approche pour un problème de classification binaire où le recall de la classe positive est critique  
*Suggest the best approach for a binary classification problem where recall on the positive class is critical*
- **Expliquer les résultats des modèles** — demandez-lui d’interpréter l’importance des variables, les métriques de comparaison des modèles  
*Interpret feature importance, model comparison metrics*
- **Générer des nœuds de pipeline** — décrivez votre besoin et le Copilot peut ajouter des nœuds
- **Répondre à des questions méthodologiques** — par exemple « Qu’est-ce que le gradient boosting ? » ou « Comment fonctionne l’oversampling ? »  
*"What is gradient boosting?" or "How does oversampling work?"*

### Example Copilot Prompts

- *"Set up an AutoML pipeline for binary classification where we cannot afford to miss urgent requests"*
- *"Add a variable selection node that removes features with importance below 1%"*
- *"Explain the difference between precision and recall for this urgency prediction problem"*
- *"What does the F1 score tell me about my model's balance between precision and recall?"*
- *"How should I handle class imbalance if urgent requests are the minority class?"*

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
   - **Score Rankings :** dans quelle mesure le modèle distingue les demandes urgentes des demandes non urgentes  
3. Le meilleur modèle est automatiquement défini comme **champion**  

> **À quoi s'attendre :** pour cet ensemble de données, les modèles de gradient boosting ou de forêt aléatoire atteignent généralement un AUC compris entre 0,85 et 0,92. La métrique clé à surveiller est le rappel sur la classe « urgent » : l'objectif est supérieur à 90 %, ce qui signifie que le modèle doit détecter au moins 9 demandes véritablement urgentes sur 10.

---

## Approche 2 : Création d'un pipeline personnalisé

Si vous souhaitez disposer d'un plus grand contrôle — ou si vous souhaitez tester des types de modèles spécifiques —, créez un pipeline personnalisé étape par étape.

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
| **Accuracy** - Précision | Pourcentage global de prédictions correctes  | > 85% |
| **Recall (Sensitivity)** - Rappel (Sensibilité) | Proportion de demandes urgentes réelles correctement identifiées | > 90% |
| **AUC-ROC** | Capacité globale à distinguer les demandes urgentes des non urgentes | >= 0.85 |
| **Misclassification Rate** - Taux de mauvaise de classification | Pourcentage de prédictions incorrectes | <= 0.15 |
| **F1 Score** | Moyenne harmonique de la précision et du rappel | >= 0.80 |
| **KS Statistic** | Séparation maximale entre les distributions cumulées | >= 0.50 |

Consultez le **ROC Overlay Chart** (graphique de superposition ROC) pour comparer visuellement la capacité de chaque modèle à séparer les deux classes. Le modèle le plus proche du coin supérieur gauche est celui qui offre les meilleures performances.  

Consultez le graphique **Variable Importance** (Importance des variables) de votre modèle gagnant : les principaux prédicteurs devraient correspondre à ce que vous avez identifié à l'étape 3 (probablement `inherent_urgency`, `response_time_hours`, `dept_avg_response_time`, `district_avg_response_time`, `district_total_critical`).  

**Remarque importante concernant le recall (taux de rappel) :** Dans ce cas d'utilisation, un faux négatif (ne pas détecter une demande réellement urgente) est bien plus grave qu'un faux positif (transmettre une demande non urgente). Si vous devez choisir entre un modèle présentant une précision de 95 % et un taux de rappel de 85 %, et un autre présentant une précision de 88 % et un taux de rappel de 93 %, privilégiez le second modèle. Passer à côté de demandes urgentes peut entraîner un retard dans la réponse à des risques pour la sécurité, des ruptures de conduites d'eau ou d'autres situations critiques.

---

##  Évaluation de l'équité

Une IA digne de confiance exige que les modèles ne discriminent pas injustement certains groupes. Dans ce cas, nous évaluerons l'équité par rapport à **`age_65+`** — la variable binaire de tranche d'âge indiquant si le citoyen qui soumet la demande est âgé de 65 ans ou plus.

### Pourquoi les plus de 65 ans ?

Les personnes âgées constituent un groupe démographique sensible dans la prestation des services publics. Elles peuvent dépendre davantage des services municipaux, rencontrer des obstacles pour soumettre des demandes en ligne et être moins à même de tolérer des retards sur des questions liées à la sécurité (pannes de chauffage, dangers sur les trottoirs, problèmes d'eau). Si le modèle de prédiction de l'urgence sous-estime systématiquement l'urgence des demandes émanant de personnes âgées, les conséquences sont directes :

1. **Le modèle sous-estime l'urgence** des demandes pour lesquelles `age_65+`=1
2. Ces demandes sont **dépriorisées** dans la file d'attente de triage
3. Les délais de réponse pour les personnes âgées **augmentent**
4. La satisfaction des personnes âgées **diminue**
5. Les données futures reflètent de **pires résultats** pour ce groupe, renforçant ainsi le biais

Il ne s'agit pas d'une préoccupation hypothétique. Il a été démontré que les systèmes de décision automatisés produisent des impacts disparates sur les groupes démographiques protégés, et l'âge fait partie des catégories protégées dans la plupart des cadres municipaux de lutte contre la discrimination.

> **Note sur l’équité territoriale :** La colonne initiale `location_district` a été supprimée lors du feature engineering à l’étape 2 au profit d’agrégats au niveau du quartier (district_avg_response_time, district_avg_resolution_rate, etc.). L’équité territoriale reste présente dans le modèle via ces agrégats, et vous l’avez explorée à l’étape 3. Cependant, l’évaluation formelle de l’équité dans Model Studio nécessite une variable binaire ou catégorielle présente sur chaque ligne — c’est pourquoi nous utilisons ici la variable age_65+.

L'évaluation de l'équité permet de s'assurer que le modèle fonctionne de manière **équitable pour tous les groupes d'âge** et que les décisions de triage qui en découlent ne désavantagent pas systématiquement les personnes âgées.

### Réalisation de l'évaluation de l'équité

1. En définissant la variable `age_65+` comme variable à évaluer en termes d'équité, nous obtenons cette évaluation pour chaque modèle
2. Examinez les indicateurs d'équité (onglet `Fairness and Bias` dans les résultats de chaque modèle):

| Indicateur | Ce qu'il mesure | Valeurs acceptables |
|--------|---------------|------------------|
| **Demographic Parity (Parité démographique)** | Les prédictions d'urgence sont-elles réparties de manière égale entre les groupes d'âge ? | Ratio > 0.80 |
| **Equal Opportunity (Égalité des chances)** | Le taux de vrais positifs (recall/rappel pour les cas urgents) est-il similaire pour les 65 ans et plus et les moins de 65 ans ? | Différence < 0.10 |
| **Predictive Parity (Parité prédictive)** | La précision est-elle similaire pour les plus de 65 ans et les moins de 65 ans ? | Différence < 0.10 |
| **Calibration (Calibrage)** | Une probabilité prédite de 70 % signifie-t-elle une urgence réelle de 70 % pour les deux groupes ? | Pente proche de 1.0 |

### Interpreting Results

- If **Demographic Parity** is below 0.80, the model disproportionately flags one age group as urgent while under-flagging the other
- If **Equal Opportunity** difference exceeds 0.10, the model catches urgent requests for one age group better than the other — meaning one group gets worse triage
- Review the **Score Distribution** by group — both groups should have similarly shaped curves

### The Value of Fairness Assessment

Fairness assessment in public sector AI is not just an ethical consideration — it is a governance requirement with direct impact on citizens:

1. **Equitable service:** Every demographic group deserves the same quality of urgency prediction
2. **Public trust:** Citizens trust government algorithms more when there is documented evidence of fairness testing
3. **Legal compliance:** Algorithmic bias prevention is increasingly part of municipal AI governance frameworks and may be required under local ordinances
4. **Accountability:** Documented fairness assessment provides an audit trail for public records requests and oversight bodies
5. **Better outcomes:** A model that performs equitably across groups leads to more effective resource allocation citywide

> **Tip:** Ask the Copilot *"Is my model fair across age groups?"* to get a plain-language interpretation of the fairness metrics.

---

## Registering to SAS Model Manager

Once you have selected your champion model and reviewed its fairness, register it to **SAS Model Manager** for governance, version control, and deployment.

### Steps to Register

1. In the Pipeline Comparison tab, identify your overall **champion model** (the one with the best KS (Youden))
2. Right-click the champion model and select **Register Model** (or use the menu: *Actions* > *Register Model*)
    ![image-20260529153304379](img/README/image-20260529153304379.png)
3. Confirm the Location which is /Model Repositories/DM Repository and click OK
4. Wait for the registration to finish in this pop up, then you can close and right click the model again and select **Manage Models**
5. Now we will be navigated into SAS Model Manager where we can review the Model Card of this model
6. Explore the Model Card that is populated automatically as you develop and manage the model on SAS Viya. The Overview tab offers a high-level summary of the model, including an overview of the model's training accuracy, training fairness, generalizability, and influential variables.
    ![image-20260529153337755](img/README/image-20260529153337755.png)

### What Registration Provides

Once registered in SAS Model Manager, your model benefits from:

- **Version control:** Track changes across model iterations
- **Performance monitoring:** Set up automated performance tracking over time
- **Governance:** Maintain an audit trail of who built the model, what data was used, and what fairness checks were performed
- **Deployment readiness:** The model can be published to CAS, MAS (Micro Analytic Service), or a container for scoring
- **Model card:** Auto-generated documentation capturing inputs, outputs, performance, and lineage

> **Tip:** Ask the Copilot *"Register this model to Model Manager"* and it will walk you through the process.

---

## Summary

At this point you have:

1. Built models using AutoML and/or custom pipelines
2. Compared models on accuracy, recall, AUC, and other metrics
3. Assessed fairness across age groups (`age_65+`) to ensure equitable service for older citizens
4. Registered your champion model to SAS Model Manager
5. Viewed the Model Card in SAS Model Manager

---

## Next Steps

Proceed to **[Step 5: Deploy & Act](../5-deploy-and-act/)** to create a decision flow in SAS Intelligent Decisioning that operationalizes your model.
