# Étape 3 : Explore

Dans cette étape, vous utiliserez **SAS Visual Analytics** et son **Copilot** intégré pour explorer visuellement l’Analytical Base Table (ABT) que vous avez créée à l’Étape 2. L’objectif est de comprendre les schémas qui expliquent les réadmissions des patients avant de construire un modèle prédictif.

---


## Prérequis

L’Analytical Base Table (ABT) doit déjà être chargée dans la bibliothèque CAS **Public**. Si vous avez terminé l’Étape 2, les données ont été enregistrées sous `life_sciences_abt.csv`. Votre environnement Bootcamp contient déjà cette table CAS préchargée sous le nom **`LIFE_SCIENCES_ABT`** dans la caslib **Public** .

---


## Accéder aux données dans SAS Visual Analytics

1. Ouvrez **SAS Visual Analytics** depuis la page d’accueil SAS Viya (ou via le menu principal en haut à droite → *Explore and Visualize*)
2. Cliquez sur **New Report**
3. Dans le panneau de données, cliquez sur *Add Data* et sélectionnez **LIFE_SCIENCES_ABT**
    ![image-20260528142056258](img/README/image-20260528142056258.png)
4. Ajoutez-la comme source de données — vous devriez voir toutes les variables créées à l’Étape 2 dans le panneau de gauche

> **Astuce:** Si la table n’apparaît pas dans la caslib Public, demandez à un mentor SAS de vous aider à la promouvoir.
Vous pouvez aussi la charger directement en important le CSV via **Manage Data**.
---

## Utiliser le Copilot de SAS Visual Analytics

SAS Visual Analytics inclut un **Copilot** - un assistant IA qui accélère l’exploration des données. L’icône du Copilot se trouve en haut à droite. Il peut :

- **Suggérer des visualisations** selon les variables sélectionnées
- **Répondre à des questions** sur vos données en langage naturel
- **Générer des insights** en détectant automatiquement des schémas intéressants
- **Créer des graphiques** à partir de requêtes en langage courant 


### Comment utiliser le Copilot

1. Cliquez sur l’icône **Copilot** pour ouvrir le panneau
2. Tapez une question ou une demande en langage naturel
3. Le Copilot suggère ou crée une visualisation dans votre rapport
4. Vous pouvez affiner le résultat avec des requêtes supplémentaires
5. Un clic droit dans le panneau de chat vous propose des suggestions de prompts pour vous aider.

![image-20260528142442820](img/README/image-20260528142442820.png)

---

## Exploration guidée : Questions à poser

Travaillez sur les questions suivantes pour comprendre les schémas de réadmission. Pour chaque question, essayez de créer la visualisation manuellement **et/ou** via le Copilot.


### Comprendre la variable cible

**Objectif :** Obtenir une compréhension de base de la réadmission dans le jeu de données.

- *"Montre-moi la distribution des patients réadmis"*
-     Show me the distribution of readmitted patients
- *"Quel pourcentage de patients ont été réadmis dans les 30 jours ?"*
-     What percentage of patients were readmitted within 30 days?

Créez un **diagramme en barres** ou **diagramme circulaire** de la variable `readmitted_30days`. Examiner le taux de réadmission — cela permet d’établir l’équilibre des classes et la référence (baseline) que votre modèle (de l'étape 4) devra dépasser .

### Hypothèse 1: Le poids des comorbidités influence la réadmission

**Objectif:** Vérifier si les patients présentant davantage de comorbidités sont réadmis à des taux plus élevés.

- *"Compare le nombre moyen de comorbidités entre les patients réadmis et ceux non réadmis`"*
-     Compare the average comorbidity count between readmitted and non-readmitted patients
- *"Montrez-moi le taux de réadmission en fonction du nombre de comorbidités*
-     Show me readmission rate by number of comorbiditie
- *"Existe-t-il un seuil du nombre de comorbidités à partir duquel le risque de réadmission augmente fortement ?"*
-      Is there a threshold of comorbidity count where readmission risk increases sharply?

Créez des **box plots** de `comorbidity_count` regroupés par `readmitted_30days`. Créez également un **diagramme en barres** montrant le taux de réadmission pour chaque niveau de comorbidité.

> **À observer :** Les patients réadmis devraient présenter un nombre moyen de comorbidités plus élevé. Recherchez un effet de seuil — le risque peut s’accélérer au-delà d’un certain nombre de pathologies.

### Hypothesis 2: Length of Stay Signals Severity

**Goal:** Determine whether length of stay predicts readmission.

- *"Show me the distribution of length of stay by readmission status"*
- *"What is the average length of stay for readmitted vs. non-readmitted patients?"*
- *"Is there a U-shaped relationship between length of stay and readmission?"*

Create a **histogram** of `length_of_stay` colored by `readmitted_30days`. Also create a **bar chart** using the LOS category variables (`los_Short`, `los_Medium`, `los_Long`) to compare readmission rates across categories.

> **What to look for:** Very short stays (potential premature discharge) and very long stays (very sick patients) may both carry elevated risk, creating a U-shaped pattern.

### Hypothesis 3: Emergency Admissions Carry Higher Risk

**Goal:** Explore whether unplanned admissions predict readmission.

- *"What is the readmission rate for emergency vs. elective admissions?"*
- *"Show me readmission rates by admission type"*

Create a **stacked bar chart** showing readmission proportions for emergency vs. non-emergency admissions using the `emergency_flag` variable.

> **What to look for:** Emergency admissions should have a meaningfully higher readmission rate than elective admissions, reflecting less controlled discharge planning.

### Hypothesis 4: Medication Complexity Increases Risk

**Goal:** Test whether polypharmacy and high-risk medications predict readmission.

- *"Compare medication counts between readmitted and non-readmitted patients"*
- *"What is the readmission rate for patients with polypharmacy?"*
- *"Show me the impact of high-risk medications on readmission"*

Create **box plots** of `medication_count` and `high_risk_med_count` grouped by `readmitted_30days`. Create a **bar chart** comparing readmission rates for `polypharmacy_flag` = 0 vs. 1.

> **What to look for:** Patients on more medications — especially high-risk medications — should have higher readmission rates due to adherence challenges and drug interaction risks.

### Hypothesis 5: Abnormal Clinical Measures Predict Readmission

**Goal:** Investigate whether vital signs and lab results at admission predict readmission.

- *"Show me readmission rates by lab results flag"*
- *"Compare blood pressure distributions between readmitted and non-readmitted patients"*
- *"What is the readmission rate by BMI category?"*
- *"How does clinical risk score relate to readmission?"*

Create **box plots** of `blood_pressure_systolic`, `glucose_level`, and `bmi` grouped by `readmitted_30days`. Create a **bar chart** of readmission rate by `clinical_risk_score`.

> **What to look for:** Patients with abnormal lab results, hypertension, diabetic-range glucose, or extreme BMI values should show elevated readmission risk. The composite `clinical_risk_score` should show a clear dose-response relationship with readmission.

### Correlation and Multi-Variable Exploration

**Goal:** Find feature interactions and the strongest predictors.

- *"Which features are most correlated with readmission?"*
- *"Show me a correlation matrix of the top 10 numeric features"*
- *"Create a decision tree to show which factors split readmitted from non-readmitted patients"*

Use the Copilot's **automated analysis** feature to let it scan for the strongest relationships.

> **What to look for:** The Copilot may surface interactions you wouldn't have checked manually, such as "patients with high comorbidity count AND emergency admission AND polypharmacy have a readmission probability above 60%."

---

## HIPAA Considerations for Visualizations

When building dashboards and reports from patient data, keep these principles in mind:

- **Avoid small cell sizes:** If a filter combination results in fewer than 10 patients, suppress the result to prevent potential re-identification
- **Aggregate, do not display individual records:** Show distributions and averages, not patient-level detail
- **Role-based access:** When publishing reports, ensure access is restricted to authorized clinical and administrative staff
- **Audit trails:** SAS Visual Analytics logs all report access and data queries — this supports HIPAA compliance requirements
- **De-identification:** The synthetic data from Step 1 eliminates these concerns entirely — a key benefit of the SAS Data Maker workflow

---

## Building Your Report

As you work through the questions above, organize your findings into a report:

1. **Overview Page:** Readmission distribution, key summary stats
2. **Clinical Profile Page:** Comorbidities, clinical measures, lab results by readmission status
3. **Admission Page:** Length of stay, admission type, discharge disposition patterns
4. **Medication Page:** Medication count, polypharmacy, high-risk medications
5. **Risk Factors Page:** Clinical risk score, insurance type, age distributions

Use **filters** and **interactions** between visualizations — clicking a bar in one chart should filter the others. This lets you drill into segments like "Medicare patients with 3+ comorbidities admitted through the emergency department."

---

## Key Takeaways to Carry Forward

Before moving on to Step 4, summarize what you have learned:

1. **Which hypotheses were confirmed?** (likely H1, H3, and H4)
2. **Which features show the strongest separation** between readmitted and non-readmitted patients?
3. **Are there any surprising patterns** the Copilot surfaced?
4. **What is the class balance?** (important for model training strategy)

These insights will directly inform the model building approach in the next step.

Finally feel free to save the report, the default location is My Folder, which is ideal here as to not clutter up the workspace for everybody else. You can also give it a name so that it is easier to remember what this report is about.

---

## Next Steps

Proceed to **[Step 4: Model](../4-model/)** to build and compare predictive models in SAS Model Studio.
