# Étape 3: Explore (Niveau avancé)

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

Créez un **diagramme en barres** ou un **diagramme circulaire** de la variable `defaulted`.
Vous devriez observer environ 25–26 % de défauts et 74–75 % de prêts courants — indiquant un problème de classification modérément déséquilibré.

### Hypothèse 1 : Le score de crédit influence le défaut
**Objectif** : Vérifier si les scores FICO plus faibles sont associés à un taux de défaut plus élevé.

- *"Compare le score de crédit moyen entre prêts en défaut et prêts courants"*
- *"Montre-moi le taux de défaut par bande FICO"*
- *"Quelle est la distribution des scores de crédit selon le statut de défaut?"*

Créez des **boîtes à moustaches** de 'credit_score' groupé par 'defaulted'. Créez un **diagramme en barres** du taux de défaut par bande FICO (colonnes `fico_Excellent`, `fico_Good`, `fico_Fair`, `fico_Poor`, `fico_VeryPoor`).

> **À observer** : Les bandes Very Poor et Poor FICO devraient présenter des taux de défaut nettement plus élevés. Un seuil critique peut apparaître autour de 650.

### Hypothèse 2 : Le ratio dette/revenu influence le défaut
**Objectif** : Déterminer si la pression financière prédit le défaut.
- *"Montre-moi la distribution de debt_to_income selon le statut de défaut"*
- *"Compare le debt-to-income moyen entre prêts en défaut et prêts courants"*
- *"Existe-t-il une relation entre debt_service_ratio et le défaut ?"*

Créez un **histogramme** de debt_to_income coloré par `defaulted`. Créez un **nuage de points** debt_to_income vs credit_score coloré avec `defaulted` comme coleur.

> **À observer** : Les prêts en défaut ont souvent un DTI plus élevé. Un DTI > 43 % est un seuil réglementaire courant indiquant un risque accru.

### Hypothèse 3 : Le comportement de paiement prédit le défaut futur

**Objectif:** Explorer si les comportements de paiements passés signalent un risque futur.
- *" Montre-moi le taux moyen de retard pour défaut vs courant "*
- *"Comment le severe_delinquency_flag est-il lié au défaut ? "*
- *"Quelle est la distribution de avg_days_late selon le statut de défaut ? "*

Créez une **heatmap** ou **crosstab** de `severe_delinquency_flag` par `defaulted`.
Créez une **boîte à moustaches** de `avg_days_late` par `defaulted`.

> **À observer:** Toute délinquance sévère (60+ jours) augmente fortement le risque de défaut. Le risque de paiement en retard est sûrement une des variables les plus importantes.

### Hypothèse 4 : La stabilité de l’emploi influence le risque
**Objectif:** Vérifier si les caractéristiques d’emploi affectent le défaut.
- *" Quel est le taux de défaut par bande de revenu ? "*
- *"Compare les taux de défaut pour emploi vérifié vs non vérifié "*
- *"Montre-moi le taux de défaut par bande d’années d’emploi "*

Créez des **diagrammes en barres empilées** pour les bandes de revenu et d’ancienneté. Créez un **diagramme en barres** pour `employment_verified` et `income_verified`. 

**À observer:** Les revenus faibles et l’ancienneté courte sont souvent associés à un risque plus élevé. Le revenu non vérifié peut ajouter un risque additionnel.

### Hypothèse 5 : Les caractéristiques du prêt influencent le risque
**Objectif:** Comprendre comment la structure du prêt affecte le défaut.
- *"Montre-moi le taux de défaut par loan-to-value ratio "*
- *"Compare les montants des prêts entre défaut et courant "*
- *"Quelle est la relation entre taux d’intérêt et défaut ? "*

Créez un **nuage de points** `loan_to_value` vs. `interest_rate` coloré pars `defaulted`. Créez un **histogramme** de `loan_amount` par statut de défaut.

> **À observer:** Les LTV élevés, les taux d’intérêt élevés et les durées longues sont souvent associés à plus de défauts. Le taux d'intérêt lui-même peut être un indicateur de l'évaluation initiale du risque.

### Corrélations et exploration multivariée
**Objectif:** Identifier les interactions et les prédicteurs les plus forts.

- *"Quelles variables sont les plus corrélées au défaut ?"*
- *"Montre-moi une matrice de corrélation des 10 principales variables numériques "*
- *"Crée un arbre de décision pour séparer défaut vs courant "*

Le Copilot peut **analyser automatiquement** les relations les plus fortes.

>**À observer:** Le Copilot peut révéler des interactions inattendues, par exemple : "`DTI` > 45 % ET `cerdit_score` < 620 → probabilité de défaut > 40 % ".

### Considérations réglementaires pour l'exploration
**Important:** Dans l’exploration de données de crédit, respectez les exigences de fair lending :

- **Ne visualisez pas les taux de défaut par classes protégées** (race, genre, âge, etc.) - même dans l'analyse exploratoire ceci comporte un risque de compliance.
- **Concentrez-vous sur les facteurs légitimes de crédit:** credit score, DTI, LTV, payment history, employment stability
- **Documentez votre exploration:** Notez quelles variables montre une séparation importante ou pas - ceci appuie la validation du modèle par SR 11-7
- Si une variable comme `income_band` montre des écarts extrêmes, gardez-le en tête pour l’évaluation d’équité à l’Étape 4

---

## Construire votre rapport
Organisez vos visualisations dans un rapport :
1. **Page d’ensemble:** distribution du défaut, statistiques clés
2. **Profil crédit:** bandes FICO, utilisation, historique de délinquance
3. **Pression financière:** DTI, ratio service de la dette, bandes de revenu
4. **Comportement de paiement:** retards, délinquance sévère, shortfall
5. **Caractéristiques du prêt:** LTV, montant, taux, durée

Utilisez les **filtres** et **interactions** entre graphiques pour explorer des segments spécifiques. Cela vous permet d'examiner des segments comme "prêts avec un DTI supérieur à 43 % et un score de crédit (`credit_socre`) inférieur à 650."

---

## Points clés à retenir

Avant de passer à l’Étape 4, résumez :
1. **Quelles hypothèses ont été confirmées ?** (sûrement toutes les 5, avec des concordance qui varient)
2. **Quelles variables séparent le mieux** défaut vs courant ?
3. **Y a-t-il des schémas inattendus** que Copilot a mis en avant?
4. **Quel est l’équilibre des classes ?** (important pour la modélisation - attendez-vous à un léger déséquilibre)
5. **Y a-t-il des variables proxy** à surveiller pour effectuer des test équitables?

Ces points auront un impact sur la création du modèle dans la prochaine étape.

Vous pouvez ensuite enregistrer votre rapport dans **My Folder**, pratique pour ne pas polluer les espaces partagés. Vous pouvez également renommer le rapport pour qu'il soit plus facile de s'en souvenir plus tard.

---

## Étapes suivantes

Passez à **[Étape 4: Model](../4-model/)** pour construire et comparer des modèles prédictifs dans SAS Model Studio.
