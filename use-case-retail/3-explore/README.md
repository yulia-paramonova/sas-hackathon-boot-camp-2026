# Étape 3: Explore

Dans cette étape, vous utilisez **SAS Visual Analytics** et son **Copilot** pour explorer visuellement l’ABT créée à l’étape 2.

---

## Prérequis

La table **RETAIL_ABT** doit être disponible dans la caslib **Public**.

---

## Accéder aux données dans SAS Visual Analytics

1. Ouvrir SAS Visual Analytics
2. Cliquer sur New Report
3. Ajouter la table RETAIL_ABT

![image-20260528142158439](img/README/image-20260528142158439.png)

---

## Utiliser le Copilot

Le Copilot peut :

- Suggérer des visualisations
- Répondre en langage naturel
- Générer des insights
- Construire des graphiques depuis un prompt

![image-20260528142501932](img/README/image-20260528142501932.png)

---

## Exploration guidée

### Cible churned

- Distribution de churned
- Pourcentage churnés vs actifs

### Hypothèse 1 : engagement

- avg_session_duration
- total_sessions
- avg_pages_per_session

### Hypothèse 2 : achats

- days_since_last_purchase
- total_spend
- purchase_frequency

### Hypothèse 3 : support

- avg_satisfaction_score
- high_priority_tickets
- total_tickets

### Hypothèse 4 : abonnement

- Churn par tier_Basic, tier_Standard, tier_Premium

### Hypothèse 5 : email

- Churn par email_opt_in

### Corrélations

- Variables les plus corrélées à churned
- Matrice de corrélation
- Arbre de séparation churnés/actifs

---

## Construire le rapport

1. Overview
2. Engagement
3. Purchase
4. Support
5. Demographics

---

## Points clés à retenir

1. Hypothèses confirmées
2. Variables les plus séparantes
3. Patterns inattendus
4. Équilibre des classes

---

## Prochaines étapes

Passez à **[Étape 4: Model](../4-model/)**.
