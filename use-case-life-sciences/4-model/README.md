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

1. **Proxy socio-économique :** le type d’assurance est fortement corrélé au statut socio-économique, à l’origine ethnique et à la race. Les patients Medicaid sont souvent issus de populations à revenus plus faibles ou minoritaires. Si le modèle attribue systématiquement des scores de risque plus élevés à ces patients, il peut renforcer les inégalités existantes au lieu de les réduire.  

2. **Équité des soins :** si la précision du modèle varie selon les groupes d’assurance — par exemple 90 % des réadmissions détectées chez les patients Commercial contre 60 % chez les patients Medicaid — les efforts de coordination des soins bénéficieront davantage à certains groupes, ce qui va à l’encontre du principe d’équité.   

3. **Allocation des ressources :** les patients identifiés à risque déclenchent des actions (suivi téléphonique, soins à domicile, coordination). Si le modèle sur-identifie un groupe, celui-ci peut consommer une part disproportionnée des ressources. À l’inverse, une sous-identification prive certains patients de services nécessaires.  

4. **Risque réglementaire et réputationnel :** les organismes comme le CMS surveillent les disparités de soins. Un modèle biaisé selon le type d’assurance peut exposer l’organisation à des risques réglementaires et d’image.  

### Exécution de l’évaluation de l’équité

1. En définissant la variable `ins_Medicaid` comme variable à évaluer en termes d’équité, vous obtenez ces analyses pour chaque modèle  
2. Examinez les métriques d’équité :

| Métrique | Ce qu’elle mesure | Intervalle acceptable |
|--------|-----------------|------------------|
| **Demographic Parity (Parité démographique)** | Les prédictions de réadmission sont-elles distribuées équitablement entre les types d’assurance ? | Ratio > 0.80 |
| **Equal Opportunity (Égalité des chances)** | La sensibilité est-elle similaire entre les groupes ? | Différence < 0.10 |
| **Predictive Parity (Parité prédictive)** | La précision est-elle similaire entre les groupes ? | Différence < 0.10 |
| **Calibration (Calibrage)** | Une probabilité de 70 % correspond-elle à 70 % de réadmissions pour tous les groupes ? | Pente proche de 1.0 |

### Interprétation des résultats


- Si la **Demographic Parity (Parité démographique)** est inférieure à 0,80, le modèle privilégie un groupe dans l’identification des risques  
- Si la différence d’**Equal Opportunity (Égalité des chances)** dépasse 0,10, le modèle détecte mieux les réadmissions pour un groupe que pour un autre  
- Examinez la **Score Distribution (distribution des scores)** par groupe — les courbes doivent être similaires  

### L'importance de l'évaluation de l'équité

L’évaluation de l’équité n’est pas qu’une exigence éthique — elle apporte une **valeur clinique et business directe** :

1. **Meilleurs résultats patients :** un modèle performant de manière homogène améliore la coordination des soins pour tous 
2. **Confiance :** les équipes médicales et les régulateurs font davantage confiance aux modèles avec des preuves documentées d’équité 
3. **Réduction des risques :** identifier les biais en amont évite des corrections coûteuses ultérieures  
4. **Équité en santé :** cela démontre l’engagement de MedCare envers un accès équitable aux soins

> **Conseil :** Demandez au Copilot *"Is my model fair across insurance types?"* pour obtenir une interprétation en langage clair des métriques d’équité.

---

## Enregistrement dans SAS Model Manager

Une fois que vous avez sélectionné votre modèle champion et vérifié son équité, enregistrez-le dans **SAS Model Manager** à des fins de gouvernance, de contrôle des versions et de déploiement.

### Steps to Register

1. Dans l'onglet « Pipeline Comparison », identifiez votre **modèle champion** global (celui qui présente le meilleur KS (Youden))
2. Faites un clic droit sur le modèle champion et sélectionnez **Enregistrer le modèle** (ou utilisez le menu : *Actions* > *Enregistrer le modèle*)
    ![image-20260529151408862](img/README/image-20260529151408862.png)
3. Confirmez l'emplacement, qui est `/Model Repositories/DM Repository`, puis cliquez sur OK
4. Attendez que l'enregistrement se termine dans cette fenêtre contextuelle, puis vous pouvez la fermer et cliquer à nouveau avec le bouton droit sur le modèle et sélectionner **Gérer les modèles**
5. Vous serez alors redirigé vers **SAS Model Manager**, où vous pourrez consulter la fiche de ce modèle
6. Explorez la fiche du modèle, qui est remplie automatiquement au fur et à mesure que vous développez et gérez le modèle sur SAS Viya. L'onglet Aperçu (Overview) offre un résumé général du modèle, y compris un aperçu de la précision d'apprentissage, de l'équité d'apprentissage, de la capacité de généralisation et des variables influentes du modèle.
    ![image-20260529151516744](img/README/image-20260529151516744.png)

### Avantages de l'enregistrement

Une fois enregistré dans SAS Model Manager, votre modèle bénéficie des avantages suivants :

- **Contrôle des versions :** suivez les modifications apportées au fil des itérations du modèle
- **Surveillance des performances :** configurez un suivi automatisé des performances au fil du temps
- **Gouvernance :** conservez une piste d'audit indiquant qui a créé le modèle, quelles données ont été utilisées et quels contrôles d'équité ont été effectués
- **Préparation au déploiement :** le modèle peut être publié sur CAS, MAS (Micro Analytic Service) ou dans un conteneur à des fins de scoring
- **Fiche de modèle :** documentation générée automatiquement qui répertorie les entrées, les sorties, les performances et la traçabilité — un élément essentiel pour la gouvernance de l'IA clinique

> **Astuce :** demandez au Copilot *« Enregistrer ce modèle dans Model Manager »* `Register this model to Model Manager` et il vous guidera tout au long du processus.

---

## Résumé

À ce stade, vous avez :

1. Construit des modèles avec AutoML et/ou des pipelines personnalisés  
2. Comparé les modèles sur l’AUC, la sensibilité et d’autres métriques en tenant compte de l’interprétabilité clinique  
3. Évalué l’équité selon les types d’assurance pour garantir une prise en charge équitable  
4. Enregistré votre modèle champion dans SAS Model Manager  
5. Consulté la fiche du modèle dans SAS Model Manager

---

##  Étapes suivantes

Passez à l'**[Étape 5 : Deploy & Act](../5-deploy-and-act/)** pour créer un flux décisionnel dans SAS Intelligent Decisioning qui permettra de mettre votre modèle en pratique.
