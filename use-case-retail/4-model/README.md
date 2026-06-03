# Étape 4: Model

Dans cette étape, vous utilisez **SAS Model Studio** pour construire, comparer et évaluer des modèles de churn.

---

## Prérequis

La table **RETAIL_ABT** doit être disponible dans la caslib Public.

---

## Ouvrir SAS Model Studio

1. Ouvrir SAS Model Studio
2. New Project
3. Configurer :

- Name : ShopEase Customer Churn Prediction
- Project Type : Data Mining and Machine Learning
- Data Source : RETAIL_ABT
- Target Variable : churned

![image-20260529153600194](img/README/image-20260529153600194.png)

Définir le rôle Target pour churned.

![image-20260529153658091](img/README/image-20260529153658091.png)

Activer Assess this variable for bias sur tier_Basic.

![image-20260529153729615](img/README/image-20260529153729615.png)

---

## Copilot dans Model Studio

Exemples de demandes :

- Pipeline AutoML pour classification binaire
- Explication AUC-ROC vs F1
- Gestion du split de classes

---

## Approche 1 : AutoML

1. New Pipeline
2. Automatically generate the pipeline
3. Maximum Time, puis Save

AutoML teste plusieurs algorithmes, fait le prétraitement et classe les modèles.

---

## Approche 2 : Pipeline personnalisé

Nœuds recommandés :

1. Data
2. Imputation
3. Logistic Regression
4. Forest
5. Gradient Boosting
6. Model Comparison

Paramètres usuels :

- Forest : 200 arbres, profondeur 10
- Gradient Boosting : 150 arbres, learning rate 0.1, profondeur 5, subsample 0.8

---

## Comparaison des modèles

| Métrique               | Interprétation             | Cible   |
| ---------------------- | -------------------------- | ------- |
| AUC-ROC                | Distinction churnés/actifs | >= 0.80 |
| Misclassification Rate | Erreur globale             | <= 0.20 |
| KS Statistic           | Séparation distributions   | >= 0.40 |
| Gini Coefficient       | 2 x AUC - 1                | >= 0.60 |
| F1 Score               | Équilibre précision/rappel | >= 0.70 |

---

## Évaluation de l’équité

Analyse d’équité avec tier_Basic :

| Métrique           | Interprétation                        | Plage               |
| ------------------ | ------------------------------------- | ------------------- |
| Demographic Parity | Répartition prédictions entre groupes | Ratio > 0.80        |
| Equal Opportunity  | Taux de vrais positifs comparable     | Différence < 0.10   |
| Predictive Parity  | Précision comparable                  | Différence < 0.10   |
| Calibration        | Cohérence score/probabilité réelle    | Pente proche de 1.0 |

---

## Enregistrement dans Model Manager

1. Identifier le modèle champion
2. Register Model

![image-20260529153859705](img/README/image-20260529153859705.png)

3. Ouvrir Manage Models
4. Consulter la Model Card

![image-20260529153940567](img/README/image-20260529153940567.png)

---

## Résumé

1. Modèles entraînés
2. Performances comparées
3. Équité évaluée
4. Champion enregistré

---

## Prochaines étapes

Passez à **[Étape 5: Deploy & Act](../5-deploy-act/)**.
