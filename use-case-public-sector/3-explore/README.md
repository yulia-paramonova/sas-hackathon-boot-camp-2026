# Étape 3: Explore

Dans cette étape, vous utiliserez **SAS Visual Analytics** et son **Copilot** intégré pour explorer visuellement l’Analytical Base Table (ABT) que vous avez créée à l’Étape 2. L’objectif est de comprendre les schémas qui expliquent l’urgence des demandes de service et d’identifier les écarts d’équité entre quartiers avant de construire un modèle prédictif.

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
- **Ignorez les suggestions visant à reclasser des mesures numériques en catégories.** Copilot recommande parfois de transformer des colonnes numériques (e.g., `district_avg_request_count`) en catégories. Refusez ces suggestions — ce sont des mesures et elles doivent le rester.
- **Si un graphique ne répond pas à la question, reformulez.** Demandez à Copilot un type de graphique précis et des rôles de colonnes précis plutôt qu’une question ouverte (e.g., *"Crée un diagramme en barres avec `inherent_urgency` sur l'axe x et la moyenne de `is_urgent` sur l'axe y"*).
  
---

## Exploration guidée : Questions à poser

Travaillez sur les questions suivantes pour comprendre les schémas d'urgence des demandes de service. Pour chaque question, essayez de créer la visualisation manuellement **et/ou** via le Copilot.

### Comprendre la variable cible

**Objectif:** Obtenir une compréhension de base de l'urgence dans le jeu de données.

- *"Montre-moi la distribution des demandes de services urgents vs. non-urgents"*
- *"Quel pourcentage des demandes sont classifiés comme urgent ?"*

Créez un **diagramme en barres** ou **diagramme circulaire** de la variable `is_urgent`. Examinez l’équilibre des classes — cela orientera votre stratégie de modélisation à l’Étape 4.

### Hypothèse 1: L'urgence inhérente prédit l'ugence réelle

**Objectif:** Vérifier que l'indicateur `inherent_urgency` (dérivé du type de demande pendant le feature engineering) est un bon prédicteur du caractère réellement urgent de la demande.

- *"Affiche la moyenne de `is_urgent` regroupée par `inherent_urgency`"*
- *"Compare la distribution de `response_time_hours` pour `inherent_urgency`=1 vs `inherent_urgency`=0"*
- *"Quel pourcentage de la demande avec `inherent_urgency`=1 sont marquées`is_urgent`=1?"*

Créez un **diagramme en barres** de `is_urgent` (en tant que mesure, agrégée en moyenne) regroupé par `inherent_urgency`. La colonne brute `request_type` a été transformée en variables dérivées comme `inherent_urgency` lors de l’Étape 2, donc nous analysons directement ce signal construit.

> **À observer:** Les demandes signalées comme intrinsèquement urgentes (dangers pour la sécurité, ruptures de conduites d’eau) devraient présenter une moyenne de `is_urgent`  nettement plus élevée que les autres. Si l’écart est faible, cet indicateur n’apporte pas une contribution suffisante en tant que prédicteur.

### Hypothesis 2: a capacité des départements influence la rapidité de réponse

**Objectif:** Déterminer si la charge de travail et les effectifs des départements ont un impact sur les temps de réponse.

- *"Affiche la corrélation entre `dept_avg_staff_count` et `dept_avg_response_time`"*
- *"Affiche la corrélation entre `dept_avg_budget_util` et `dept_avg_resolution_rate`"*
- *"Affiche la distribution de `dept_avg_overtime` à travers les demandes"*

Créez un **nuage de points** de `dept_avg_staff_count` (x) vs. `dept_avg_response_time` (y). Créez un second scatter plot de `dept_avg_overtime` (x) vs. `dept_avg_resolution_rate` (y). La colonne brute `department` a été supprimée dans l’Étape 2 — the `dept_avg_*` aggregates are what carry forward into the model, so we analyze those directly.

> **À observer:** Une corrélation négative entre le nombre d’employés et le temps de réponse (plus d’effectifs = réponse plus rapide).
Les départements avec beaucoup d’heures supplémentaires et de faibles taux de résolution constituent les goulots d’étranglement.

### Hypothèse 3: Équité entre quartiers

**Objectif:** Identifier si certains quartiers reçoivent systématiquement un service plus lent ou de moins bonne qualité.

- *"Affiche la distribution de `district_avg_response_time` à travers les demandes"*
- *"Affiche la corrélation entre `district_avg_request_count` er `district_avg_response_time`"*
- *"Affiche la corrélation entre `district_avg_resolution_rate` et `response_time_hours`"*
- *"Affiche la somme de `district_total_critical` et `district_total_high` à travers l'ensemble des demandes"*

Créez un **histogramme** de `district_avg_response_time` pour visualiser la dispersion de la rapidité de service au niveau des quartiers. Créez un **nuage de points** de `district_avg_request_count` (x) vs. `district_avg_response_time` (y) afin de vérifier si les quartiers à fort volume de demandes sont plus lents. Le label brut `location_district`a été supprimée à l’Étape 2 — chaque demande conserve toutefois les métriques agrégées du quartier d’origine, donc l’analyse d’équité entre quartiers se fait via ces agrégats.

> **À observer:** Une large dispersion de `district_avg_response_time` indique que le problème de variance de 40 % est réel. Une forte corrélation positive avec le volume de demandes suggère que la capacité, et non un biais, est le facteur déterminant ; une corrélation faible suggère une allocation inégale du service.

### Hypothèse 4: Schémas saisonniers

**Objectif:** Explorer si les volumes de demandes et leur niveau d’urgence varient selon la saison.

- *"Affiche le nombre de demandes regroupées par `submit_month`"*
- *"Affiche la moyenne de `is_urgent` regroupée par `submit_month`"*
- *"Affiche la moyenne de `response_time_hours` regroupée par `submit_quarter`"*

Créez un **diagramme linéaire** avec `submit_month` sur l'axe x et le nombre de demandes sur l'axe y. Créez un second graphique avec `submit_month` sur l’axe x et la moyenne de `is_urgent` comme mesure secondaire.

**À observer:** Des pics mensuels de volume ou d’urgence indiquent une pression saisonnière sur les départements. Les mois présentant une moyenne élevée de `response_time_hours` correspondent aux périodes les plus sous tension.

### Hypothèse 5: Schémas de satisfaction des citoyens

**Objectif:** Comprendre ce qui influence `citizen_satisfaction` et comment cela se relie à l’urgence.

- *"Affiche la distribution de `citizen_satisfaction`"*
- *"Affiche la moyenne de `citizen_satisfaction` regroupée par `is_urgent`"*
- *"Affiche la corrélation entre `response_time_hours` et `citizen_satisfaction`"*
- *"Affiche la corrélation entre `citizen_previous_requests` et `citizen_satisfaction`"*

Créez un **nuage de points** avec un `response_time_hours` sur l’axe x et `citizen_satisfaction` sur l’axe y. Créez un **diagramme en barres** de la moyenne de `citizen_satisfaction` regroupée par `is_urgent`.

> **À observer:** Une forte corrélation négative entre `response_time_hours` et `citizen_satisfaction` (plus rapide = plus heureux). Les demandes `is_urgent`=1 résolues rapidement devraient maintenir un bon niveau de satisfaction ; les demandes urgentes traitées lentement offrent la pire expérience client.

### Analyse approfondie axée sur l’équité

**Objectif:** Évaluer spécifiquement l’équité du service entre les quartiers et selon les groupes d’âge.

- *"Affiche le nuage de points de `district_avg_response_time` vs `response_time_hours` filtré par `is_urgent`=1"*
- *"Affiche la corrélation entre `age_65+` et `citizen_satisfaction`"*
- *"Affiche la corrélation entre `age_18-24` et `citizen_satisfaction`"*
- *"Affiche la corrélation entre `district_avg_request_count` et `district_avg_resolution_rate`"*

Créez un **nuage de points** de `district_avg_response_time` vs. par rapport aux valeurs individuelles de `response_time_hours`, filtré sur `is_urgent`=1. Créez un **diagramme en barres** montrant la moyenne de `citizen_satisfaction`pour chaque variable indicatrice (dummy) de groupe d'âge (de `age_18-24` à `age_65+`, là où la valeur est égale à 1).

> **Ce qu'il faut chercher:** Si les quartiers ayant un `district_avg_response_time` élevé présentent également des valeurs individuelles de `response_time_hours` élevées pour les demandes urgentes, la lenteur est systémique. Si certaines variables indicatrices (dummies) de groupes d'âge affichent une satisfaction moyenne nettement inférieure, il s'agit d'un signal d'équité démographique à intégrer dans l'évaluation de l'équité à l'étape 4.

### Corrélation et exploration multi-variable

**Objectif:** Trouver les interactions entre les features et les prédicteurs les plus forts de `is_urgent`.

- *"Affiche la matrice de corrélation pour `is_urgent`, `inherent_urgency`, `response_time_hours`, `dept_avg_response_time`, `district_avg_response_time`, `citizen_satisfaction`"*
- *"Affiche l'importance des variables de toutes les features pour la prédiction de `is_urgent`"*
- *"Crée un arbre de décision avec `is_urgent` comme cible"*

Utilisez la fonctionnalité **d'analyse automatisée** du Copilot pour rechercher les relations les plus fortes.

> **À observer:** `inherent_urgency` est probablement le prédicteur individuel le plus fort. Soyez attentif aux interactions — e.g., certaines valeurs de `submit_month` combinées à un `district_avg_request_count` élevé peuvent entraîner des réponses systématiquement plus lentes.

---

## Construire votre rapport

Organisez vos visualisations dans un rapport :

1. **Page d’ensemble:** distribution de `is_urgent`, statistiques descriptives clés
2. **Page des schémas d'urgence:** `is_urgent` par `inherent_urgency`, schémas temporels basés sur `day_of_week` / `submit_month`
3. **Page de performance des départements:** relations entre `dept_avg_response_time`, `dept_avg_staff_count`, `dept_avg_overtime`
4. **Page de l'équité par quartier:** `district_avg_response_time`, `district_avg_resolution_rate`, `district_total_critical` / `district_total_high`
5. **Page de l'expérience citoyenne:** facteurs déterminants de `citizen_satisfaction`, variables indicatrices de groupes d'âge, `citizen_engagement_score`

Utilisez les **filtres** et **interactions** entre les visualisations — cliquer sur une barre dans un graphique doit filtrer les autres. Cela vous permet d'explorer des segments précis comme "les demandes urgentes dans le quartier du centre-ville pendant les mois d'été".


---

## Points clés à retenir

Avant de passer à l'étape 4, résumez ce que vous avez appris. Les réponses attendues (si votre exploration s'est bien déroulée) sont indiquées à côté de chaque question — si vos chiffres diffèrent substantiellement, réexaminez l'hypothèse concernée avant de continuer.

1. **Quelles hypothèses ont été confirmées ?** Attendez-vous à voir **H1** (l'urgence intrinsèque est le prédicteur individuel le plus fort), **H3** (une large dispersion de `district_avg_response_time`), et **H5** (une forte corrélation négative entre `response_time_hours` et `citizen_satisfaction`). H2 et H4 ont tendance à être des signaux plus faibles dans ce jeu de données.
2. **Quels features montrent la séparation la plus nette** entre `is_urgent`=1 et `is_urgent`=0? Attendez-vous à ce que `inherent_urgency`, `response_time_hours`, `district_total_critical`, et `district_total_high` séparent le plus nettement les deux classes.
3. **Quels quartiers présentent les plus grands écarts d'équité ?** Les valeurs les plus élevées de `district_avg_response_time` combinées aux valeurs les plus basses de `district_avg_resolution_rate`signalent les districts ayant le plus grand déficit de service.
4. **Quel est l'équilibre des classes ?** Environ **36% de `is_urgent`=1** et **64% de `is_urgent`=0** — un déséquilibre modéré, mais pas au point de devoir rééquilibrer les classes avant la modélisation.
5. **Y a-t-il des schémas surprenants?** Surprises fréquentes: les soumissions le week-end ont des temps de réponse plus longs ; certaines valeurs de `submit_month` affichent des pics d'urgence ; un score d'engagement citoyen `citizen_engagement_score` élevé ne corrèle pas toujours avec une satisfaction citoyenne `citizen_satisfaction` plus élevée.

Si Copilot n'a pas produit de réponses claires, les causes les plus courantes (dans l'ordre) sont : (a) votre requête (prompt) ne faisait pas référence aux noms exacts des colonnes, (b) le graphique s'est retrouvé sur une autre page — vérifiez toutes les pages, ou (c) l'ABT sous-jacente n'était pas entièrement chargée en mémoire. Demandez de l'aide à un mentor SAS si vous êtes bloqué.

Ces informations éclaireront directement l'approche de construction du modèle et l'évaluation de l'équité à l'étape suivante.

Enfin, n'hésitez pas à enregistrer le rapport. L'emplacement par défaut est "Mon dossier" (My Folder), ce qui est idéal ici pour ne pas encombrer l'espace de travail des autres. Vous pouvez également lui donner un nom afin qu'il soit plus facile de vous rappeler le sujet de ce rapport.

---

## Étapes suivantes

Passez à **[Étape 4: Model](../4-model/)** pour construire et comparer des modèles prédictifs dans SAS Model Studio.
