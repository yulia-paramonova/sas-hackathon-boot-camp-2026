# Step 4: Model

Dans cette étape, vous utiliserez **SAS Model Studio** pour construire, comparer et évaluer des modèles de prédiction du risque de réadmission des patients. SAS Model Studio offre une interface visuelle de pipeline, un **Copilot** intégré, des capacités d’**AutoML**, ainsi que des outils pour le développement de modèles personnalisés — le tout avec une évaluation intégrée de l’équité. À la fin, vous enregistrerez votre modèle champion dans **SAS Model Manager**.

---

## Prerequisites

La table de base analytique (`LIFE_SCIENCES_ABT`) doit être disponible dans la bibliothèque CAS **Public**. Si vous avez déjà réalisé les étapes 2 et 3, vous avez une bonne compréhension des données ; sinon, prenez un peu de temps pour parcourir les colonnes afin de mieux les comprendre.

---

## Opening SAS Model Studio

1. Depuis la page d’accueil SAS Viya, ouvrez **SAS Model Studio** (dans *Build Models* du menu principal)
2.  Cliquez sur **New Project**
3. Configurez le projet :
   - **Name:** *MedCare Patient Readmission Prediction*
   - **Project Type:** *Data Mining and Machine Learning*
   - **Data Source:** sélectionnez `LIFE_SCIENCES_ABT` depuis la caslib Public
   - Laissez **Template, Location & Description** par défaut
   - **Target Variable** (variable cible/à expliquer) : `readmitted_30days`
4. Cliquez sur **Save**
    ![image-20260529144108273](img/README/image-20260529144108273.png)
5. Une fois le projet ouvert sur l’onglet Data, sélectionnez la variable `readmitted_30days` et définissez son rôle sur `Target` *(à expliquer)*  
    ![image-20260529144236588](img/README/image-20260529144236588.png)
6. Sur le même onglet, trouvez la variable `ins_Medicaid` et activez la case `Assess this variable for bias`. Cela permettra d’illustrer les fonctionnalités de Trustworthy AI dans SAS Model Studio. Passez ensuite à l’onglet *Pipelines* pour commencer.  
    ![image-20260529144314430](img/README/image-20260529144314430.png)

Le projet est maintenant prêt pour commencer la modélisation.

---

## Utilisation du Copilot de SAS Model Studio

SAS Model Studio inclut un **Copilot** qui agit comme un assistant de modélisation basé sur l’IA. Accédez-y via l’icône Copilot dans la barre d’outils.  

*Pour le moment, SAS Viya Copilot fonctionne uniquement en anglais. Nous vous recommandons donc de formuler vos requêtes (prompts) en anglais afin d’obtenir des résultats fiables et de qualité.*

### Ce que le Copilot peut faire

- **Recommander des configurations de pipeline** — demandez-lui de proposer la meilleure approche pour un problème de classification binaire avec des données déséquilibrées
- **Expliquer les résultats des modèles** — demandez-lui d’interpréter l’importance des variables, les métriques de comparaison des modèles
- **Générer des nœuds de pipeline** — décrivez votre besoin et le Copilot peut ajouter des nœuds
- **Répondre à des questions méthodologiques** — par exemple « Qu’est-ce que le gradient boosting ? » ou « Comment fonctionne l’oversampling ? »
   -      Suggest the best approach for a binary classification problem with imbalanced data
   -      Interpret feature importance, model comparison metrics
   -      What is gradient boosting?
   -      How does oversampling work for imbalanced clinical data?

### Example Copilot Prompts

- *"Set up an AutoML pipeline for binary classification targeting readmission with class imbalance handling"*
- *"Add a variable selection node that removes features with importance below 1%"*
- *"Explain the difference between AUC-ROC and sensitivity for this readmission problem"*
- *"Why is sensitivity more important than specificity for patient readmission?"*
- *"How should I handle the class imbalance in this dataset?"*

---

## Exigences en matière d'interprétabilité clinique

Contrairement à de nombreuses applications d'apprentissage automatique, les modèles prédictifs cliniques doivent être **interprétables** : les équipes soignantes doivent comprendre *pourquoi* un patient a été identifié comme présentant un risque élevé afin de pouvoir se fier à la recommandation et prendre les mesures appropriées. Cela a plusieurs implications pour le choix du modèle :

1. **L’explicabilité prime sur la performance brute :** un modèle de gradient boosting avec un AUC de 0,78 et une importance des variables claire peut être préféré à un réseau de neurones avec un AUC de 0,80 mais un raisonnement opaque  
2. **L’importance des variables doit être cohérente avec les connaissances cliniques :** si les principaux prédicteurs du modèle n’ont pas de sens d’un point de vue clinique, les parties prenantes ne l’adopteront pas  
3. **Des explications au niveau individuel :** les équipes soignantes doivent comprendre pourquoi *ce patient précis* a été identifié — pas seulement quels facteurs sont importants en moyenne. Privilégiez des modèles qui permettent d’expliquer les prédictions à l’échelle individuelle  
4. **Contexte réglementaire :** dans le cadre des exigences de reporting qualité du CMS, les hôpitaux doivent être capables d’expliquer leurs interventions d’amélioration de la qualité. Un modèle « boîte noire » est plus difficile à justifier  

> **Conseil :** Demandez au Copilot *« Quel type de modèle offre le meilleur équilibre entre précision et interprétabilité clinique pour la prédiction des réadmissions ? »*
-      `Which model type gives the best balance of accuracy and clinical interpretability for readmission prediction?`

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

> **À quoi s'attendre :** pour cet ensemble de données, les modèles de gradient boosting ou de forêt aléatoire atteignent généralement un AUC compris entre 0,75 et 0,82.
La régression logistique suit généralement de près, avec des valeurs comprises entre 0,72 et 0,78.

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
| **AUC-ROC** | Capacité globale à distinguer les patients réadmis des non-réadmis | >= 0.75 |
| **Misclassification Rate** - Taux de mauvaise classification | Pourcentage de prédictions incorrectes | <= 0.25 |
| **KS Statistic** | Séparation maximale entre les distributions cumulées | >= 0.30 |
| **Recall (Sensitivity)** - Rappel (Sensibilité) | Proportion des réadmissions réelles correctement identifiées | >= 0.80 |
| **Specificity** - Spécificité | Proportion des non-réadmissions correctement identifiées | >= 0.50 |

Examinez le **ROC Overlay Chart** pour comparer visuellement la capacité de chaque modèle à séparer les deux classes. Le modèle le plus proche du coin supérieur gauche est le plus performant.  

Examinez le graphique **Variable Importance** de votre modèle champion — les principaux prédicteurs doivent correspondre à ceux identifiés à l’étape 3 (probablement `comorbidity_count`, `emergency_flag`, `length_of_stay`, `clinical_risk_score`, `medication_count`).  

> **Remarque sur sensibilité vs spécificité :** pour la prédiction des réadmissions, **la sensibilité est prioritaire par rapport à la spécificité**. Ne pas identifier un patient à haut risque qui sera réadmis (faux négatif) a des conséquences bien plus graves — pénalités CMS, risque pour le patient — que signaler un patient qui ne sera finalement pas réadmis (faux positif). Le coût d’un faux positif se limite à un appel ou un suivi supplémentaire ; celui d’un faux négatif est une réadmission évitable.

---


## Évaluation de l’équité

Une IA de confiance exige que les modèles ne discriminent pas injustement certains groupes protégés. Dans ce cas d’usage, nous évaluons l’équité par rapport au **type d’assurance** — plus précisément si le modèle traite de manière équitable les patients Medicare, Medicaid, Commercial et non assurés.


### Pourquoi le type d’assurance ?

Le type d’assurance est une dimension clé de l’équité en santé pour plusieurs raisons :  

1. **Socioeconomic proxy:** Insurance type is strongly correlated with socioeconomic status, race, and ethnicity. Medicaid patients are disproportionately from lower-income and minority communities. If the model systematically assigns higher risk scores to Medicaid patients, it may be reinforcing existing health disparities rather than addressing them.

2. **Equity of care:** If the model's accuracy differs across insurance groups — for example, catching 90% of readmissions among Commercial patients but only 60% among Medicaid patients — then the resulting care coordination efforts will disproportionately benefit one population over another. This violates the principle of equitable care delivery.

3. **Resource allocation:** High-risk flags trigger interventions such as follow-up calls, home health referrals, and care manager assignments. If the model over-flags one insurance group, those patients may consume a disproportionate share of limited care management resources — or conversely, if it under-flags a group, those patients miss out on services they need.

4. **Regulatory and reputational risk:** CMS and the Office for Civil Rights monitor for disparities in care delivery. A model that systematically disadvantages patients by payer type could expose MedCare to regulatory scrutiny and reputational harm.

### Running the Fairness Assessment

1. As we set the `ins_Medicaid` variable to be assess for fairness we get this assessments with every model
4. Review the fairness metrics:

| Metric | What It Measures | Acceptable Range |
|--------|-----------------|------------------|
| **Demographic Parity** | Are readmission predictions distributed equally across insurance types? | Ratio > 0.80 |
| **Equal Opportunity** | Is the sensitivity (true positive rate) similar across insurance types? | Difference < 0.10 |
| **Predictive Parity** | Is the precision similar across insurance types? | Difference < 0.10 |
| **Calibration** | Does a 70% predicted probability mean 70% actual readmission for all groups? | Slope close to 1.0 |

### Interpreting Results

- If **Demographic Parity** is below 0.80, the model disproportionately flags one insurance group as high-risk
- If **Equal Opportunity** difference exceeds 0.10, the model catches readmissions in one group better than another
- Review the **Score Distribution** by group — both groups should have similarly shaped curves

### The Value of Fairness Assessment

Fairness assessment is not just an ethical checkbox — it provides **direct clinical and business value**:

1. **Better patient outcomes:** A model that performs equally well across insurance groups leads to more effective care coordination for everyone
2. **Trust:** Clinical staff, hospital leadership, and regulators trust models more when they can see documented fairness evidence
3. **Risk reduction:** Proactively identifying bias prevents costly remediation and regulatory issues later
4. **Health equity:** Documented fairness assessment demonstrates MedCare's commitment to equitable care regardless of payer status

> **Tip:** Ask the Copilot *"Is my model fair across insurance types?"* to get a plain-language interpretation of the fairness metrics.

---

## Registering to SAS Model Manager

Once you have selected your champion model and reviewed its fairness, register it to **SAS Model Manager** for governance, version control, and deployment.

### Steps to Register

1. In the Pipeline Comparison tab, identify your overall **champion model** (the one with the best KS (Youden))
2. Right-click the champion model and select **Register Model** (or use the menu: *Actions* > *Register Model*)
    ![image-20260529151408862](img/README/image-20260529151408862.png)
3. Confirm the Location which is /Model Repositories/DM Repository and click OK
4. Wait for the registration to finish in this pop up, then you can close and right click the model again and select **Manage Models**
5. Now we will be navigated into SAS Model Manager where we can review the Model Card of this model
6. Explore the Model Card that is populated automatically as you develop and manage the model on SAS Viya. The Overview tab offers a high-level summary of the model, including an overview of the model's training accuracy, training fairness, generalizability, and influential variables.
    ![image-20260529151516744](img/README/image-20260529151516744.png)

### What Registration Provides

Once registered in SAS Model Manager, your model benefits from:

- **Version control:** Track changes across model iterations
- **Performance monitoring:** Set up automated performance tracking over time — critical for clinical models where patient populations shift
- **Governance:** Maintain an audit trail of who built the model, what data was used, and what fairness checks were performed
- **Deployment readiness:** The model can be published to CAS, MAS (Micro Analytic Service), or a container for scoring
- **Model card:** Auto-generated documentation capturing inputs, outputs, performance, and lineage — essential for clinical AI governance

> **Tip:** Ask the Copilot *"Register this model to Model Manager"* and it will walk you through the process.

---

## Summary

At this point you have:

1. Built models using AutoML and/or custom pipelines
2. Compared models on AUC, sensitivity, and other metrics with clinical interpretability in mind
3. Assessed fairness across insurance types to ensure equitable care delivery
4. Registered your champion model to SAS Model Manager
5. Viewed the Model Card in SAS Model Manager

---

## Next Steps

Proceed to **[Step 5: Deploy & Act](../5-deploy-and-act/)** to create a decision flow in SAS Intelligent Decisioning that operationalizes your model.
