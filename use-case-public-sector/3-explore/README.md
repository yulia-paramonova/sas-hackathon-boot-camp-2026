# Step 3: Explore

In this step you will use **SAS Visual Analytics** and its built-in **Copilot** to visually explore the Analytical Base Table (ABT) you created in Step 2. The goal is to understand the patterns behind service request urgency and identify equity gaps across districts before building a predictive model.

Dans cette étape, vous allez utiliser **SAS Visual Analytic**s et son **Copilot** intégré pour explorer visuellement l’Analytical Base Table (ABT) que vous avez créée à l’Étape 2. L’objectif est de comprendre les schémas liés au défaut de paiement avant de construire un modèle prédictif.

---

## Prérequis

L’analytical base table doit déjà être chargée dans la bibliothèque CAS **Public**. Si vous avez terminé l’Étape 2, les données ont été enregistrées sous `public_sector_abt.csv`. Votre environnement Bootcamp contient déjà cette table CAS préchargée sous le nom **`PUBLIC_SECTOR_ABT`** dans la caslib **Public** .

---

## Accéder aux données dans SAS Visual Analytics

1. Ouvrez **SAS Visual Analytics** depuis la page d’accueil SAS Viya (ou via le menu principal en haut à droite → *Explore and Visualize*)
2. Cliquez sur **New Report**
3. Dans le panneau de données, cliquez sur Add Data et sélectionnez **FINANCIAL_SERVICES_ABT**
    ![image-20260528142114059](img/README/image-20260528142114059.png)
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

![image-20260528142454478](img/README/image-20260528142454478.png)

### Conseils et mises en garde Copilot

Quelques comportements à garder à l’esprit lors de cette étape :

- **Référez‑vous aux colonnes par leur nom exact.** Les requêtes (prompts) de ce guide utilisent des noms de colonnes entourés d’accents graves  (e.g., `` `is_urgent` ``, `` `district_avg_response_time` ``). Copilot fonctionne mieux lorsque vous faites la même chose. Des termes vagues comme *"district"* ou *"request type"*  échouent souvent, car ces colonnes brutes n’existent pas dans l’ABT.
- **Les graphiques apparaissent parfois sur une autre page.** Si une visualisation générée apparaît sur une autre page du rapport, faites‑la glisser vers la page sur laquelle vous travaillez.
- Copilot fonctionne mieux lorsque vous faites de même — des termes vagues comme « district » ou « type de requête » échouent souvent, car ces colonnes brutes n’existent pas dans l’ABT.
- **Ignorez les suggestions visant à reclasser des mesures numériques en catégories.** Copilot recommande parfois de transformer des colonnes numériques (e.g., `district_avg_request_count`) en catégories. Refusez ces suggestions — ce sont des mesures et elles doivent le rester.
- **Si un graphique ne répond pas à la question, reformulez.** Demandez à Copilot un type de graphique précis et des rôles de colonnes précis plutôt qu’une question ouverte (e.g., *"Crée un diagramme en barres avec `inherent_urgency` sur l'axe x et la moyenne de `is_urgent` sur l'axe y"*).
  
---

## Exploration guidée : Questions à poser

Travaillez sur les questions suivantes pour comprendre les schémas d'urgence des demandes de service. Pour chaque question, essayez de créer la visualisation manuellement **et/ou** via le Copilot.

### Comprendre la variable cible

**Objectif:** Obtenir une compréhension de base de l'urgence dans le jeu de données.

- *"Montre-moi la distribution des demandes de services urgents vs. non-urgents"*
- *"Quel pourcentage des demandes sont classifiés comme urgent ?"*

Créez un **diagramme en barres** ou **pie chart** de la variable `is_urgent`. Examinez l’équilibre des classes — cela orientera votre stratégie de modélisation à l’Étape 4.

### Hypothèse 1: L'urgence inhérente prédit l'ugence réelle

**Objectif:** Vérifier que l'indicateur `inherent_urgency` (dérivé du type de demande pendant le feature engineering) est un bon prédicteur du caractère réellement urgent de la demande.

- *"Affiche la moyenne de `is_urgent` regroupée par `inherent_urgency`"*
- *"Compare la distribution de `response_time_hours` pour `inherent_urgency`=1 vs `inherent_urgency`=0"*
- *"Quel pourcentage de la demande avec `inherent_urgency`=1 sont marquées`is_urgent`=1?"*

Créez un **bar chart** de is_urgent (en tant que mesure, agrégée en moyenne) regroupé par `inherent_urgency`. La colonne brute `request_type` a été transformée en variables dérivées comme `inherent_urgency` lors de l’Étape 2, donc nous analysons directement ce signal construit.

> **À observer:** Les demandes signalées comme intrinsèquement urgentes (dangers pour la sécurité, ruptures de conduites d’eau) devraient présenter une moyenne de `is_urgent`  nettement plus élevée que les autres. Si l’écart est faible, cet indicateur n’apporte pas une contribution suffisante en tant que prédicteur.

### Hypothesis 2: a capacité des départements influence la rapidité de réponse

**Objectif:** Déterminer si la charge de travail et les effectifs des départements ont un impact sur les temps de réponse.

- *"Affiche la corrélation entre `dept_avg_staff_count` et `dept_avg_response_time`"*
- *"Affiche la corrélation entre `dept_avg_budget_util` et `dept_avg_resolution_rate`"*
- *"Affiche la distribution de `dept_avg_overtime` à travers les demandes"*

Créez un **scatter plot** de `dept_avg_staff_count` (x) vs. `dept_avg_response_time` (y). Créez un second scatter plot de `dept_avg_overtime` (x) vs. `dept_avg_resolution_rate` (y). La colonne brute `department` a été supprimée dans l’Étape 2 — the `dept_avg_*` aggregates are what carry forward into the model, so we analyze those directly.

> **À observer:** Une corrélation négative entre le nombre d’employés et le temps de réponse (plus d’effectifs = réponse plus rapide).
Les départements avec beaucoup d’heures supplémentaires et de faibles taux de résolution constituent les goulots d’étranglement.

### Hypothèse 3: Équité entre quartiers

**Objectif:** Identifier si certains quartiers reçoivent systématiquement un service plus lent ou de moins bonne qualité.

- *"Affiche la distribution de `district_avg_response_time` à travers les demandes"*
- *"Affiche la corrélation entre `district_avg_request_count` er `district_avg_response_time`"*
- *"Affiche la corrélation entre `district_avg_resolution_rate` et `response_time_hours`"*
- *"Affiche la somme de `district_total_critical` et `district_total_high` à travers l'ensemble des demandes"*

Créez un **histogram** de `district_avg_response_time` pour visualiser la dispersion de la rapidité de service au niveau des quartiers. Créez un **scatter plot** de `district_avg_request_count` (x) vs. `district_avg_response_time` (y) afin de vérifier si les quartiers à fort volume de demandes sont plus lents. Le label brut `location_district`a été supprimée à l’Étape 2 — chaque demande conserve toutefois les métriques agrégées du quartier d’origine, donc l’analyse d’équité entre quartiers se fait via ces agrégats.

> **À observer:** Une large dispersion de `district_avg_response_time` indique que le problème de variance de 40 % est réel. Une forte corrélation positive avec le volume de demandes suggère que la capacité, et non un biais, est le facteur déterminant ; une corrélation faible suggère une allocation inégale du service.

### Hypothèse 4: Schémas saisonniers

**Objectif:** Explore whether request volumes and urgency vary by season.

- *"Affiche le nombre de demandes regroupées par `submit_month`"*
- *"Affiche la moyenne de `is_urgent` regroupée par `submit_month`"*
- *"Affiche la moyenne de `response_time_hours` regroupée par `submit_quarter`"*

Créez un **line chart** avec `submit_month` sur l'axe x et le nombre de demandes sur l'axe y. Create a second chart with `submit_month` on the x-axis and average `is_urgent` as a secondary measure.

> **What to look for:** Monthly spikes in volume or urgency point to seasonal pressure on departments. Months with high average `response_time_hours` are the stressed periods.

### Hypothèse 5: Citizen Satisfaction Patterns

**Goal:** Understand what drives `citizen_satisfaction` and how it relates to urgency.

- *"Show the distribution of `citizen_satisfaction`"*
- *"Show the average of `citizen_satisfaction` grouped by `is_urgent`"*
- *"Show the correlation between `response_time_hours` and `citizen_satisfaction`"*
- *"Show the correlation between `citizen_previous_requests` and `citizen_satisfaction`"*

Create a **scatter plot** with `response_time_hours` on the x-axis and `citizen_satisfaction` on the y-axis. Create a **bar chart** of average `citizen_satisfaction` grouped by `is_urgent`.

> **What to look for:** A strong negative correlation between `response_time_hours` and `citizen_satisfaction` (faster = happier). `is_urgent`=1 requests resolved quickly should maintain satisfaction; slow urgent requests are the worst customer experience.

### Equity-Focused Deep Dive

**Goal:** Specifically assess service equity across district aggregates and age groups.

- *"Show the scatter plot of `district_avg_response_time` vs `response_time_hours` filtered where `is_urgent`=1"*
- *"Show the correlation between `age_65+` and `citizen_satisfaction`"*
- *"Show the correlation between `age_18-24` and `citizen_satisfaction`"*
- *"Show the correlation between `district_avg_request_count` and `district_avg_resolution_rate`"*

Create a **scatter plot** of `district_avg_response_time` vs. the individual `response_time_hours`, filtered to `is_urgent`=1. Create a **bar chart** showing average `citizen_satisfaction` for each age-group dummy (`age_18-24` through `age_65+`, where the value is 1).

> **What to look for:** If districts with high `district_avg_response_time` also have high individual `response_time_hours` for urgent requests, the slowness is systemic. If certain age-group dummies have markedly lower average satisfaction, that is a demographic equity signal to carry into the fairness assessment in Step 4.

### Correlation and Multi-Variable Exploration

**Goal:** Find feature interactions and the strongest predictors of `is_urgent`.

- *"Show the correlation matrix for `is_urgent`, `inherent_urgency`, `response_time_hours`, `dept_avg_response_time`, `district_avg_response_time`, `citizen_satisfaction`"*
- *"Show the variable importance of all features for predicting `is_urgent`"*
- *"Create a decision tree with `is_urgent` as the target"*

Use the Copilot's **automated analysis** feature to scan for the strongest relationships.

> **What to look for:** `inherent_urgency` is likely the single strongest predictor. Watch for interactions — e.g., certain `submit_month` values combined with high `district_avg_request_count` may produce consistently slower response.

---

## Building Your Report

As you work through the questions above, organize your findings into a report:

1. **Overview Page:** `is_urgent` distribution, key summary stats
2. **Urgency Patterns Page:** `is_urgent` by `inherent_urgency`, temporal patterns from `day_of_week` / `submit_month`
3. **Department Performance Page:** `dept_avg_response_time`, `dept_avg_staff_count`, `dept_avg_overtime` relationships
4. **District Equity Page:** `district_avg_response_time`, `district_avg_resolution_rate`, `district_total_critical` / `district_total_high`
5. **Citizen Experience Page:** `citizen_satisfaction` drivers, age-group dummies, `citizen_engagement_score`

Use **filters** and **interactions** between visualizations — clicking a bar in one chart should filter the others. This lets you drill into segments like "urgent requests in the Downtown district during summer months."

---

## Key Takeaways to Carry Forward

Before moving on to Step 4, summarize what you have learned. Expected answers (if your exploration went well) are shown alongside each question — if your numbers differ substantially, revisit the relevant hypothesis before continuing.

1. **Which hypotheses were confirmed?** Expect **H1** (inherent urgency is the single strongest predictor), **H3** (wide spread in `district_avg_response_time`), and **H5** (strong negative correlation between `response_time_hours` and `citizen_satisfaction`). H2 and H4 tend to be weaker signals in this dataset.
2. **Which features show the strongest separation** between `is_urgent`=1 and `is_urgent`=0? Expect `inherent_urgency`, `response_time_hours`, `district_total_critical`, and `district_total_high` to separate the two classes most clearly.
3. **Which districts have the biggest equity gaps?** The highest values of `district_avg_response_time` combined with the lowest values of `district_avg_resolution_rate` mark the districts with the biggest service gap.
4. **What is the class balance?** Roughly **36% `is_urgent`=1** and **64% `is_urgent`=0** — moderately imbalanced, but not so skewed that you must rebalance before modeling.
5. **Are there any surprising patterns?** Common surprises: weekend submissions have longer response times; certain `submit_month` values show spiky urgency; high `citizen_engagement_score` does not always correlate with higher `citizen_satisfaction`.

If Copilot did not produce clear answers, the most common causes (in order) are: (a) your prompt did not reference exact column names, (b) the chart landed on another page — check all pages, or (c) the underlying ABT was not fully loaded in memory. Ask a SAS mentor if you are stuck.

These insights will directly inform the model building approach and fairness assessment in the next step.

Finally feel free to save the report, the default location is My Folder, which is ideal here as to not clutter up the workspace for everybody else. You can also give it a name so that it is easier to remember what this report is about.

---

## Next Steps

Proceed to **[Step 4: Model](../4-model/)** to build and compare predictive models in SAS Model Studio.
