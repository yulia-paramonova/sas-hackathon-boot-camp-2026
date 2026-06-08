# Étape 3: Explore

Dans cette étape, vous utiliserez **SAS Visual Analytics** et son **Copilot** intégré pour explorer visuellement l’Analytical Base Table (ABT) que vous avez créée à l’Étape 2. L’objectif est de comprendre les facteurs qui expliquent le défaut de paiement avant de construire un modèle prédictif.

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

## Exploration guidée

### Comprendre la variable cible

**Objectif :** Obtenir une compréhension de base de l'urgence dans le jeu de données.

- *"Quelle est la distribution des patients réadmis ?"*
- *"Quel est le pourcentage de patients réadmis dans les 30 jours ?"*

1. Faites glisser la variable cible `defaulted` sur l’espace de travail. La visualisation est sélectionnée automatiquement en fonction du type de variable. Ici, il s’agit d’une variable numérique (mesure).
2. Dupliquez cette variable (clic droit : *Dupliquer*), puis convertissez-la en catégorie (clic droit : *Convertir en catégorie*).
3. Faites-la glisser à droite du premier graphique. Vous constaterez que la visualisation change. Sans modifier les données d’entrée, vous pouvez ainsi adapter le type de variable et accéder à différents types de graphiques.
4. Examinez l’équilibre des classes — cela orientera votre stratégie de modélisation à l’Étape 4.
5. *Optionnel : Créez un **diagramme circulaire** de la variable `defaulted (1)`.*

   ![ER_FS_1](img/Exploration_rapide_FS/ER_FS_1.png)

### Relations avec d'autres variables

1. Faites glisser une autre variable de votre choix sur la même page.
2. Dans le menu de droite, cliquez sur la troisième icône (**Actions**) et cohez la case *Activer les actions automatiques*.
3. Cliquez ensuite sur une barre dans le deuxieme graphique. Observez comment l’ensemble des graphiques se met à jour. Grâce à cette interactivité, vous pouvez analyser les relations entre les variables ou construire des tableaux de bord interactifs.
4. *Optionnel : Tester d'autres variables. Observez comment leur distribution change en fonction de la catégorie séléctionnée. Vous pouvez explorer des segments précis comme  "prêts avec un DTI supérieur à 43 % et un score de crédit (`credit_socre`) inférieur à 650".*

   ![ER_FS_2](img/Exploration_rapide_FS/ER_FS_2.png)

### Matrice de correlation et la magie

**Objectif :** Identifier les facteurs qui influencent le plus la variable cible. Pour cela, utilisez la matrice de corrélation.  
1. Sélectionnez toutes les variables numériques (en maintenant la touche *Shift*), puis faites-les glisser sur le “+” à côté de la page 1. 
Cela ajoute une matrice de corrélation sur une nouvelle page. Vous pouvez agrandir (bouton en haut a droite à coté des 3 petits points) la vue pour mieux observer les relations.  
*Quelles variables sont les plus fortement corrélées à la variable cible `defaulted` ?* 
3. Dans le menu de droite, cliquez sur la deuxième icône (**Rôles**) et sélectionnez *Show correlations: Between two sets of measures*. Mettez la variable `defaulted` dans la section *Y axis*. Vous verrez alors plus clairement les variables les plus corrélées avec la cible. Cependant, ces relations ne sont pas toujours faciles à interpréter. Utilisons maintenant les capacités magiques d’analyse automatisée de la plateforme.
   ![ER_FS_3](img/Exploration_rapide_FS/ER_FS_3.png)
4. Dans le volet **Données** à gauche, sélectionnez la variable cible que vous avez convertie en catégorie `defaulted (1)`. Faites un clic droit, puis choisissez *Expliquer automatiquement sur une nouvelle page*.
5. Sur le nouvel objet, sélectionnez la cible = 1 (en haut à droite). Vous obtenez une analyse détaillée mettant en évidence les facteurs les plus influents.
6. Agrandissez la visualisation à l’aide de l’icône d’agrandissement (à côté des trois points en haut à droite). Parcourez les différents onglets, en particulier la section *screening*, qui indique pourquoi certaines variables ont été retenues ou écartées. Consultez également l’onglet des variables importantes.  
*C’est typiquement le type d’analyse qu’un data scientist réaliserait au début d’un projet. Réaliser cette étape en code prendrait plus de temps ; ici, vous pouvez vous concentrer sur l’interprétation des résultats et la prise de décision.*
8. Réduisez la vue, puis cliquez sur les trois points en haut à droite. Sélectionnez **Dupliquer sous Arbre de décision**. Faites glisser l’objet vers une nouvelle page pour disposer de plus d’espace.
   ![ER_FS_4](img/Exploration_rapide_FS/ER_FS_4.png)
9. Félicitations, vous venez d’entraîner votre premier modèle de machine learning dans SAS Viya !  
Vous pouvez demander au SAS Viya Copilot d’interpréter les résultats :  
-     Interpret the results of the decision tree.
-     Interpret the results of the Page 3
-     What are the key drivers of loan default `defaulted (1)`?

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

### Conseils et mises en garde Copilot

Quelques comportements à garder à l’esprit lors de cette étape :

- **Référez‑vous aux colonnes par leur nom exact.** Les requêtes (prompts) de ce guide utilisent des noms de colonnes entourés d’accents graves  (e.g., `` `defaulted` ``, `` `avg_days_late` ``). Copilot fonctionne mieux lorsque vous faites la même chose. 
- **Les graphiques apparaissent parfois sur une autre page.** Si une visualisation générée apparaît sur une autre page du rapport, faites‑la glisser vers la page sur laquelle vous travaillez.
- **Les suggestions visant à reclasser des mesures numériques en catégories.** Copilot recommande parfois de transformer des colonnes numériques (e.g., `credit_score`) en catégories. Dupliquez ces variables et convertissez les variables dupliquées en catégories.
- **Si un graphique ne répond pas à la question, reformulez.** Demandez à Copilot un type de graphique précis et des rôles de colonnes précis plutôt qu’une question ouverte (e.g., *"Crée un diagramme en barres avec `credit_score` sur l'axe x et la moyenne de `defaulted` sur l'axe y"*).

---

## Optionnel : Exploration en autonomie
Vous pouvez désormais explorer les données par vous‑même. Essayez de créer des visualisations manuellement **et/ou** via le Copilot. 
Voici quelques pistes d’analyse :  
- Les bandes Very Poor et Poor FICO devraient présenter des taux de défaut nettement plus élevés. Un seuil critique peut apparaître autour de 650. `credit_score` `defaulted`
- Les prêts en défaut ont souvent un DTI plus élevé. Un DTI > 43 % est un seuil réglementaire courant indiquant un risque accru. `debt_to_income` `credit_score` `defaulted`
- Toute délinquance sévère (60+ jours) augmente fortement le risque de défaut. Le risque de paiement en retard est sûrement une des variables les plus importantes. `severe_delinquency_flag` `avg_days_late` `defaulted`
- Les revenus faibles et l’ancienneté courte sont souvent associés à un risque plus élevé. Le revenu non vérifié peut ajouter un risque additionnel. `employment_verified` `income_verified` `defaulted`
- Les LTV `loan_to_value` élevés, les taux d’intérêt `interest_rate` élevés et les durées longues sont souvent associés à plus de défauts. Le taux d'intérêt lui-même peut être un indicateur de l'évaluation initiale du risque.
- Le Copilot peut révéler des interactions inattendues, par exemple : "`DTI` > 45 % ET `cerdit_score` < 620 → probabilité de défaut > 40 % ".

---

### Considérations réglementaires pour l'exploration
**Important:** Dans l’exploration de données de crédit, respectez les exigences de fair lending :

- **Ne visualisez pas les taux de défaut par classes protégées** (race, genre, âge, etc.) - même dans l'analyse exploratoire ceci comporte un risque de compliance.
- **Concentrez-vous sur les facteurs légitimes de crédit:** credit score, DTI, LTV, payment history, employment stability
- **Documentez votre exploration:** Notez quelles variables montre une séparation importante ou pas - ceci appuie la validation du modèle par SR 11-7
- Si une variable comme `income_band` montre des écarts extrêmes, gardez-le en tête pour l’évaluation d’équité à l’Étape 4
  
---

N'hésitez pas à enregistrer le rapport. L'emplacement par défaut est "Mon dossier" (My Folder), ce qui est idéal ici pour ne pas encombrer l'espace de travail des autres. Vous pouvez également lui donner un nom afin qu'il soit plus facile de vous rappeler le sujet de ce rapport.

---

## Étapes suivantes

Passez à **[Étape 4: Model](../4-model/)** pour construire des modèles prédictifs de manière plus industrielle, en intégrant le prétraitement des données et la comparaison de plusieurs modèles dans **SAS Model Studio**.
