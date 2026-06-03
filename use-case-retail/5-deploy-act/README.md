# Étape 5: Deploy & Act

Dans cette étape finale, vous utilisez **SAS Intelligent Decisioning** pour opérationnaliser votre modèle de churn via un flux de décision automatisé.

---

## Prérequis

Le modèle champion doit être enregistré dans SAS Model Manager.

---

## Ouvrir SAS Intelligent Decisioning

1. Build Decisions
2. New Decision
3. Name : ShopEase Churn Retention Decision

![image-20260529181358511](img/README/image-20260529181358511.png)

Configurer les variables (manuellement ou via template).

![image-20260529181434924](img/README/image-20260529181434924.png)

---

## Ajouter le nœud modèle

Ajouter un nœud Model sous Start et sélectionner le modèle champion.

![image-20260529182110234](img/README/image-20260529182110234.png)

Ajouter les variables manquantes si nécessaire.

![image-20260529182344878](img/README/image-20260529182344878.png)

---

## Ajouter les Rule Sets

### Risk Tier Classification

| Conditions         | risk_tier |
| ------------------ | --------- |
| P_churned1 >= 0.80 | Critical  |
| P_churned1 >= 0.60 | High      |
| P_churned1 >= 0.40 | Moderate  |
| P_churned1 < 0.40  | Low       |

### Retention Action

| risk_tier | subscription_tier  | action                             | offer_value |
| --------- | ------------------ | ---------------------------------- | ----------- |
| Critical  | Basic              | Upgrade offer + personal call      | 50          |
| Critical  | Standard / Premium | Personal call from account manager | 25          |
| High      | Basic              | Targeted email with discount       | 20          |
| High      | Standard / Premium | Re-engagement email sequence       | 10          |
| Moderate  | Any                | Automated engagement nudge         | 0           |
| Low       | Any                | No action (continue monitoring)    | 0           |

### Channel Selection

| Conditions                     | channel             |
| ------------------------------ | ------------------- |
| days_since_last_purchase > 90  | Phone call          |
| days_since_last_purchase > 60  | Email + SMS         |
| days_since_last_purchase > 30  | Email               |
| days_since_last_purchase <= 30 | In-app notification |

### Priority Assignment

| Conditions                                                       | priority |
| ---------------------------------------------------------------- | -------- |
| risk_tier = Critical AND total_spend > 500                       | Urgent   |
| risk_tier = Critical OR (risk_tier = High AND total_spend > 300) | High     |
| risk_tier = High OR risk_tier = Moderate                         | Normal   |
| risk_tier = Low                                                  | None     |

### Reason Assignment

| Conditions                                       | reason                      |
| ------------------------------------------------ | --------------------------- |
| days_since_last_purchase > 90                    | Prolonged inactivity        |
| total_spend < 100 AND P_churned1 >= 0.60         | Low engagement and spend    |
| subscription_tier = Basic AND P_churned1 >= 0.60 | Tier-downgrade risk         |
| avg_session_duration < 60 AND total_sessions < 5 | Weak browsing engagement    |
| Otherwise                                        | Standard retention outreach |

---

## Ajouter un nœud LLM

Ajouter Call LLM avant End, puis mapper les variables requises.

![image-20260529183326445](img/README/image-20260529183326445.png)

---

## Tester la décision

1. Scoring
2. Scenarios
3. New test

![image-20260529183957319](img/README/image-20260529183957319.png)

4. Exécuter
5. Ouvrir Results

![image-20260529184658915](img/README/image-20260529184658915.png)

---

## Publier la décision

1. Validate
2. Publish
3. Destination : CAS, MAS ou Container
4. Nom unique

---

## Résumé

1. Flux de décision créé
2. Règles métier appliquées
3. LLM intégré
4. Tests effectués
5. Publication réalisée
