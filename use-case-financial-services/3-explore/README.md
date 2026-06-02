# Étape 3: Explore

Dans cette étape, vous allez utiliser **SAS Visual Analytic**s et son **Copilot** intégré pour explorer visuellement l’Analytical Base Table (ABT) que vous avez créée à l’Étape 2. L’objectif est de comprendre les schémas liés au défaut de paiement avant de construire un modèle prédictif.

---

## Prérequis
L’analytical base table doit déjà être chargée dans la bibliothèque CAS **Public**. Si vous avez terminé l’Étape 2, les données ont été enregistrées sous `financial_services_abt.csv`. Votre environnement Bootcamp contient déjà cette table CAS préchargée sous le nom **`FINANCIAL_SERVICES_ABT`** dans la caslib **Public** .

---

## Accéder aux données dans SAS Visual Analytics
1. Ouvrez **SAS Visual Analytics** depuis la page d’accueil SAS Viya (ou via le menu principal en haut à droite → *Explore and Visualize*)
2. Cliquez sur **New Report**
3. Dans le panneau de données, cliquez sur Add Data et sélectionnez **FINANCIAL_SERVICES_ABT**
    ![image-20260528142033207](img/README/image-20260528142033207.png)
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

![image-20260528142508361](img/README/image-20260528142508361.png)

---

## Exploration guidée : Questions à poser
Travaillez sur les questions suivantes pour comprendre les schémas de défaut. Pour chaque question, essayez de créer la visualisation manuellement **et/ou** via le Copilot.

### Comprendre la variable cible
**Objectif:** Obtenir une compréhension de base du défaut dans le jeu de données.

- *"Montre-moi la distribution des prêts en défaut"*
- *"Quel pourcentage des prêts sont en défaut ?"*

Créez un **diagramme en barres** ou un **diagramme circulaire** de la variable 'defaulted'.
Vous devriez observer environ 25–26 % de défauts et 74–75 % de prêts courants — indiquant un problème de classification modérément déséquilibré.

### Hypothèse 1 : Le score de crédit influence le défaut
**Objectif** : Vérifier si les scores FICO plus faibles sont associés à un taux de défaut plus élevé.
-*"Compare le score de crédit moyen entre prêts en défaut et prêts courants"*
-*"Montre-moi le taux de défaut par bande FICO"*
-*"Quelle est la distribution des scores de crédit selon le statut de défaut?"*

Créez des **boîtes à moustaches** de 'credit_score' groupé par 'defaulted'. Créez un **diagramme en barres** du taux de défaut par bande FICO (colonnes `fico_Excellent`, `fico_Good`, `fico_Fair`, `fico_Poor`, `fico_VeryPoor`).

> **À observer** : Les bandes Very Poor et Poor FICO devraient présenter des taux de défaut nettement plus élevés. Un seuil critique peut apparaître autour de 650.

### Hypothèse 2 : Le ratio dette/revenu influence le défaut
**Objectif** : Déterminer si la pression financière prédit le défaut.
-*"Montre-moi la distribution de debt_to_income selon le statut de défaut"*
-*"Compare le debt-to-income moyen entre prêts en défaut et prêts courants"*
-*"Existe-t-il une relation entre debt_service_ratio et le défaut ?"*

Créez un **histogramme** de debt_to_income coloré par `defaulted`. Créez un **nuage de points** debt_to_income vs credit_score coloré avec `defaulted` comme coleur.

> **À observer** : Les prêts en défaut ont souvent un DTI plus élevé. Un DTI > 43 % est un seuil réglementaire courant indiquant un risque accru.

### Hypothesis 3: Payment Behavior Predicts Future Default

**Goal:** Explore whether past payment patterns signal default risk.

- *"Show me the average late payment rate for defaulted vs. current loans"*
- *"How does the severe delinquency flag relate to default?"*
- *"What is the distribution of average days late by default status?"*

Create a **heat map** or **crosstab** of `severe_delinquency_flag` by `defaulted`. Create a **box plot** of `avg_days_late` by `defaulted`.

> **What to look for:** Loans with any severe delinquency (60+ days late) should have dramatically higher default rates. Late payment rate is likely one of the strongest predictors.

### Hypothesis 4: Employment Stability Matters

**Goal:** Check if employment characteristics affect default risk.

- *"What is the default rate by income band?"*
- *"Compare default rates for verified vs. unverified employment"*
- *"Show me default rate by years employed band"*

Create **stacked bar charts** showing default proportions for each income band and tenure band. Create a **bar chart** comparing default rates by `employment_verified` and `income_verified`.

> **What to look for:** Lower income bands and shorter employment tenure should correlate with higher default. Unverified income may carry additional risk.

### Hypothesis 5: Loan Characteristics Affect Risk

**Goal:** Understand how loan structure relates to default.

- *"Show me default rate by loan-to-value ratio"*
- *"Compare loan amounts between defaulted and current loans"*
- *"What is the relationship between interest rate and default?"*

Create a **scatter plot** of `loan_to_value` vs. `interest_rate` with `defaulted` as the color. Create a **histogram** of `loan_amount` by default status.

> **What to look for:** Higher LTV ratios (less equity), higher interest rates, and longer loan terms should correlate with more defaults. Interest rate itself may be a proxy for the lender's initial risk assessment.

### Correlation and Multi-Variable Exploration

**Goal:** Find feature interactions and the strongest predictors.

- *"Which features are most correlated with default?"*
- *"Show me a correlation matrix of the top 10 numeric features"*
- *"Create a decision tree to show which factors split defaulted from current loans"*

Use the Copilot's **automated analysis** feature to let it scan for the strongest relationships.

> **What to look for:** The Copilot may surface interactions you wouldn't have checked manually, such as "loans with DTI above 45% AND credit score below 620 have a 40%+ default probability."

### Regulatory Considerations for Exploration

**Important:** When exploring lending data, be mindful of fair lending requirements:

- **Do not visualize default rates by protected classes** (race, ethnicity, gender, age, marital status, national origin) — even in exploratory analysis, this creates compliance risk
- **Focus on legitimate credit factors:** credit score, DTI, LTV, payment history, employment stability
- **Document your exploration:** Note which variables show strong separation and which do not — this documentation supports model validation per SR 11-7
- If you discover that a variable like `income_band` shows dramatically different default rates, flag it for the fairness assessment in Step 4, as income can serve as a proxy for protected characteristics

---

## Building Your Report

As you work through the questions above, organize your findings into a report:

1. **Overview Page:** Default distribution, key summary stats
2. **Credit Profile Page:** Credit score bands, utilization, delinquency history
3. **Financial Strain Page:** DTI, debt service ratio, income bands
4. **Payment Behavior Page:** Late payment rates, delinquency flags, shortfall ratios
5. **Loan Characteristics Page:** LTV, loan amount, interest rate, term

Use **filters** and **interactions** between visualizations — clicking a bar in one chart should filter the others. This lets you drill into segments like "loans with DTI above 43% and credit score below 650."

---

## Key Takeaways to Carry Forward

Before moving on to Step 4, summarize what you've learned:

1. **Which hypotheses were confirmed?** (likely all five, with varying strength)
2. **Which features show the strongest separation** between defaulted and current loans?
3. **Are there any surprising patterns** the Copilot surfaced?
4. **What is the class balance?** (important for model training strategy — expect moderate imbalance)
5. **Are there any proxy variable concerns** to flag for fairness testing?

These insights will directly inform the model building approach in the next step.

Finally feel free to save the report, the default location is My Folder, which is ideal here as to not clutter up the workspace for everybody else. You can also give it a name so that it is easier to remember what this report is about.

---

## Next Steps

Proceed to **[Step 4: Model](../4-model/)** to build and compare predictive models in SAS Model Studio.
