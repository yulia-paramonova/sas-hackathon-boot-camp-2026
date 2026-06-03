# Étape 3 : Explorer

Dans cette étape, vous allez utiliser **SAS Visual Analytics** et son **Copilot** intégré pour explorer visuellement la table de base analytique (ABT) que vous avez créée à l'étape 2. L'objectif est de comprendre les schémas de l'attrition client avant de construire un modèle prédictif.

---

## Prérequis

La table de base analytique doit déjà être chargée dans la bibliothèque CAS **Public**. Si vous avez terminé l'étape 2, les données ont été enregistrées sous le nom `retail_abt.csv`. Votre environnement bootcamp contient déjà cette table CAS sous le nom **`RETAIL_ABT`** dans la caslib **Public**.

---

## Accéder aux données dans SAS Visual Analytics

1. Ouvrez **SAS Visual Analytics** depuis la page d'accueil SAS Viya (ou utilisez le menu principal en haut à droite puis cliquez sur _Explorer et visualiser_)
2. Cliquez sur **Nouveau rapport**
3. Dans le panneau de données, cliquez sur le bouton Add Data puis, parmi les tables disponibles, sélectionnez **RETAIL_ABT**
   ![image-20260528142158439](img/README/image-20260528142158439.png)
4. Ajoutez-la comme source de données — vous devriez voir toutes les variables de l'étape 2 listées dans le panneau des éléments de données à gauche

> **Astuce :** Si la table n'apparaît pas dans la caslib Public, demandez à votre mentor SAS de vous aider à la promouvoir. Vous pouvez aussi la charger directement en téléversant le CSV via l'interface **Manage Data**.

---

## Utiliser le Copilot de SAS Visual Analytics

SAS Visual Analytics inclut un **Copilot** — un assistant IA qui vous aide à explorer les données plus rapidement. Vous pouvez trouver l'icône Copilot en haut à droite. Le Copilot peut :

- **Suggérer des visualisations** en fonction des variables que vous sélectionnez
- **Répondre à des questions** sur vos données en langage naturel
- **Générer des insights** en recherchant automatiquement des schémas intéressants
- **Créer des graphiques** à partir d'instructions en langage naturel

### Comment utiliser le Copilot

1. Cliquez sur l'icône **Copilot** pour ouvrir le panneau de l'assistant
2. Saisissez une question ou une demande en langage naturel
3. Le Copilot suggérera ou créera une visualisation directement dans votre rapport
4. Vous pouvez affiner le résultat en ajoutant d'autres instructions
5. Vous pouvez faire un clic droit dans le panneau de discussion pour obtenir des suggestions d'instructions afin de vous aider.

![image-20260528142501932](img/README/image-20260528142501932.png)

---

## Exploration guidée : questions à poser

Parcourez les questions suivantes pour mieux comprendre les schémas d'attrition. Pour chaque question, essayez de créer la visualisation manuellement **et/ou** en demandant au Copilot.

### Comprendre la variable cible

**Objectif :** Obtenir une compréhension de base de l'attrition dans le jeu de données.

- _"Montre-moi la distribution des clients en attrition"_
- _"Quel pourcentage de clients est en attrition ?"_

Créez un **graphique en barres** ou un **camembert** de la variable `churned`. Vous devriez observer environ 30-31 % de clients en attrition et 69-70 % de clients actifs — ce qui confirme qu'il s'agit d'un problème de classification modérément déséquilibré.

### Hypothèse 1 : l'engagement favorise la rétention

**Objectif :** Vérifier si un faible engagement est corrélé à l'attrition.

- _"Compare la durée moyenne de session entre les clients en attrition et les clients actifs"_
- _"Montre-moi le nombre total de sessions par statut d'attrition"_
- _"Quelle est la moyenne de pages vues par session pour les clients en attrition vs. actifs ?"_

Créez des **boîtes à moustaches** de `avg_session_duration`, `total_sessions` et `avg_pages_per_session`, regroupées par `churned`. Recherchez une séparation nette entre les deux groupes.

> **À observer :** Les clients en attrition devraient avoir un nombre de sessions sensiblement plus faible et des durées de session plus courtes.

### Hypothèse 2 : la fréquence d'achat est importante

**Objectif :** Déterminer si le comportement d'achat prédit l'attrition.

- _"Montre-moi la distribution du nombre de jours depuis le dernier achat par statut d'attrition"_
- _"Compare la dépense totale entre les clients en attrition et les clients actifs"_
- _"Quelle est la fréquence d'achat moyenne pour chaque groupe ?"_

Créez un **histogramme** de `days_since_last_purchase` coloré par `churned`. Créez également un **nuage de points** de `total_spend` vs. `purchase_frequency` avec `churned` comme couleur.

> **À observer :** Les clients en attrition ont probablement un `days_since_last_purchase` plus élevé et une `purchase_frequency` plus faible. Il s'agit souvent du prédicteur le plus fort.

### Hypothèse 3 : les problèmes de support indiquent un risque

**Objectif :** Explorer si les interactions avec le support signalent un risque d'attrition.

- _"Montre-moi le score de satisfaction moyen pour les clients en attrition vs. actifs"_
- _"Combien de tickets haute priorité les clients en attrition ont-ils comparé aux clients actifs ?"_
- _"Existe-t-il une relation entre le temps de résolution et l'attrition ?"_

Créez une **carte de chaleur** ou un **tableau croisé** de `total_tickets` et `high_priority_tickets` par `churned`. Créez une **boîte à moustaches** de `avg_satisfaction_score` par `churned`.

> **À observer :** Des scores de satisfaction plus faibles et davantage de tickets haute priorité parmi les clients en attrition.

### Hypothèse 4 : le niveau d'abonnement influence l'attrition

**Objectif :** Vérifier si le niveau influence le taux d'attrition.

- _"Quel est le taux d'attrition par niveau d'abonnement ?"_
- _"Compare les taux d'attrition entre les niveaux Basic, Standard et Premium"_

Créez un **graphique en barres empilées** montrant les proportions d'attrition pour chaque niveau (utilisez les colonnes `tier_Basic`, `tier_Standard`, `tier_Premium`).

> **À observer :** Les clients du niveau Basic devraient présenter un taux d'attrition nettement plus élevé que les clients Premium.

### Hypothèse 5 : la désinscription des e-mails signale un désengagement

**Objectif :** Tester si la désinscription des e-mails prédit l'attrition.

- _"Montre-moi le taux d'attrition par statut d'inscription e-mail"_

Créez un **graphique en barres** du taux d'attrition par `email_opt_in`.

> **À observer :** Les clients qui se sont désinscrits des e-mails (email_opt_in = 0) devraient avoir une attrition plus élevée.

### Corrélation et exploration multi-variables

**Objectif :** Identifier les interactions entre variables et les prédicteurs les plus forts.

- _"Quelles variables sont les plus corrélées à l'attrition ?"_
- _"Montre-moi une matrice de corrélation des 10 principales variables numériques"_
- _"Crée un arbre de décision pour montrer quels facteurs séparent les clients en attrition des clients actifs"_

Utilisez la fonctionnalité d'**analyse automatisée** du Copilot pour le laisser détecter les relations les plus fortes.

> **À observer :** Le Copilot peut révéler des interactions que vous n'auriez pas vérifiées manuellement, par exemple : "les clients avec une faible durée de session ET un taux élevé d'abandon de panier ont une probabilité d'attrition de 90 %."

---

## Construire votre rapport

Au fur et à mesure que vous traitez les questions ci-dessus, organisez vos résultats dans un rapport :

1. **Page de vue d'ensemble :** Distribution de l'attrition, statistiques de synthèse clés
2. **Page d'engagement :** Sessions et comportement de navigation par statut d'attrition
3. **Page achats :** Schémas transactionnels, récence, fréquence
4. **Page support :** Indicateurs des tickets, scores de satisfaction
5. **Page démographie :** Niveau, inscription e-mail, distributions d'âge

Utilisez des **filtres** et des **interactions** entre les visualisations — cliquer sur une barre d'un graphique doit filtrer les autres. Cela vous permet d'explorer des segments comme "les clients niveau Basic qui n'ont pas acheté depuis plus de 60 jours".

---

## Enseignements clés à retenir

Avant de passer à l'étape 4, résumez ce que vous avez appris :

1. **Quelles hypothèses ont été confirmées ?** (probablement H1, H2 et H3)
2. **Quelles variables montrent la séparation la plus forte** entre clients en attrition et actifs ?
3. **Y a-t-il des schémas surprenants** révélés par le Copilot ?
4. **Quel est l'équilibre des classes ?** (important pour la stratégie d'entraînement du modèle)

Ces enseignements guideront directement l'approche de construction du modèle à l'étape suivante.

Enfin, n'hésitez pas à enregistrer le rapport ; l'emplacement par défaut est My Folder, ce qui est idéal ici pour éviter d'encombrer l'espace de travail de tout le monde. Vous pouvez aussi lui donner un nom pour retenir plus facilement l'objet du rapport.

---

## Étapes suivantes

Passez à **[Étape 4 : Modèle](../4-model/)** pour construire et comparer des modèles prédictifs dans SAS Model Studio.
