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

### Hypothèse 2: La durée de séjour reflète la gravité

**Objectif:** Déterminer si la durée de séjour permet de prédire la réadmission

- *"Montre-moi la distribution de la durée de séjour en fonction du statut de réadmission."*
-     Show me the distribution of length of stay by readmission status
- *"Quelle est la durée moyenne de séjour pour les patients réadmis par rapport à ceux non réadmis ?"*
-     What is the average length of stay for readmitted vs. non-readmitted patients?
- *"Existe-t-il une relation en forme de U entre la durée de séjour et la réadmission ?"*
-     Is there a U-shaped relationship between length of stay and readmission?

Créez un **histogramme** de `length_of_stay` coloré par `readmitted_30days`. Créez également un **diagramme en barres** utilisant les variables de catégorie de durée de séjour (`los_Short`, `los_Medium`, `los_Long`)  afin de comparer les taux de réadmission entre les différentes catégories.

> **À observer :** Les séjours très courts (potentiellement liés à une sortie prématurée) et les séjours très longs (patients très graves) peuvent tous deux être associés à un risque élevé, créant ainsi une forme en U.

### Hypothèse 3: Les admissions en urgence sont associées à un risque plus élevé

**Objectif:** Examiner si les admissions non planifiées permettent de prédire la réadmission.

- *"Quel est le taux de réadmission pour les admissions en urgence par rapport aux admissions programmées ?"*
-     What is the readmission rate for emergency vs. elective admissions?
- *"Montre-moi les taux de réadmission par type d’admission"*
-     Show me readmission rates by admission type

Créez un **diagramme en barres empilées** montrant les proportions de réadmission pour les admissions en urgence versus non urgentes en utilisant la variable `emergency_flag`.

> **À observer :** Les admissions en urgence devraient présenter un taux de réadmission significativement plus élevé que les admissions programmées, reflétant une planification de sortie moins maîtrisée.

### Hypothèse 4: La complexité médicamenteuse augmente le risque

**Objectif:** Tester si la polymédication et les médicaments à haut risque permettent de prédire la réadmission.

- *"Comparez le nombre de médicaments entre les patients réadmis et ceux non réadmis."*
-     Compare medication counts between readmitted and non-readmitted patients
- *"Quel est le taux de réadmission pour les patients en polymédication ?"*
-     What is the readmission rate for patients with polypharmacy?
- *"Montre-moi l’impact des médicaments à haut risque sur la réadmission."*
-     Show me the impact of high-risk medications on readmission

Créez des **box plots** de `medication_count` et `high_risk_med_count` regroupés par `readmitted_30days`. Créez également un **diagramme en barres** comparant les taux de réadmission pour `polypharmacy_flag` = 0 vs. 1.

> **À observer :** Les patients prenant davantage de médicaments — en particulier des médicaments à haut risque — devraient présenter des taux de réadmission plus élevés en raison des difficultés d’observance et des risques d’interactions médicamenteuses.

### Hypothèse 5: Les mesures cliniques anormales prédisent la réadmission

**Objectif:** Étudier si les signes vitaux et les résultats de laboratoire à l’admission permettent de prédire la réadmission.

- *"Montre-moi les taux de réadmission selon l’indicateur des résultats de laboratoire."*
-     Show me readmission rates by lab results flag
- *"Comparez les distributions de la pression artérielle entre les patients réadmis et non réadmis."*
-     Compare blood pressure distributions between readmitted and non-readmitted patients
- *"Quel est le taux de réadmission par catégorie d’IMC (BMI) ?"*
-     What is the readmission rate by BMI category?
- *"Comment le score de risque clinique est-il lié à la réadmission ?"*
-     How does clinical risk score relate to readmission ?

Créez des **box plots** de `blood_pressure_systolic`, `glucose_level`, et `bmi` regroupés par `readmitted_30days`. Créez également un **diagramme en barres** du taux de réadmission en fonction de `clinical_risk_score`.

> **À observer :** Les patients présentant des résultats de laboratoire anormaux, une hypertension, une glycémie de type diabétique ou des valeurs extrêmes d’IMC devraient montrer un risque de réadmission plus élevé. Le composite `clinical_risk_score` devrait présenter une relation dose-réponse claire avec la réadmission.

### Corrélation et exploration multi-variable

**Objectif:** Identifiez les interactions entre variables et les prédicteurs les plus forts.

- *"Quelles variables sont les plus corrélées avec la réadmission?"*
- *"Montrez-moi une matrice de corrélation des 10 principales variables numériques"*
- *"Créez un arbre de décision montrant quels facteurs distinguent les patients réadmis des patients non réadmis "*

-     Which features are most correlated with readmission?
-     Show me a correlation matrix of the top 10 numeric features
-     Create a decision tree to show which factors split readmitted from non-readmitted patientsCreate a decision tree with `is_urgent` as the target

Utilisez la fonctionnalité **d'analyse automatisée** du Copilot pour rechercher les relations les plus fortes.

> **À observer :** Le Copilot peut mettre en évidence des interactions que vous n’auriez pas examinées manuellement, comme par exemple : « les patients avec un nombre élevé de comorbidités ET une admission en urgence ET une polymédication ont une probabilité de réadmission supérieure à 60 % ».

---

## Considérations HIPAA pour les visualisations

Lors de la création de tableaux de bord et de rapports à partir de données patients, gardez ces principes à l’esprit :

- **Évitez les cellules de petite taille:** Si une combinaison de filtres aboutit à moins de 10 patients, masquez le résultat afin de prévenir toute ré-identification potentielle.
- **Agrégerez sans afficher les données individuelles:** Présentez des distributions et des moyennes, et non des données au niveau patient.
- **Contrôle d’accès basé sur les rôles:** Lors de la publication des rapports, assurez-vous que l’accès est restreint au personnel clinique et administratif autorisé.
- **Pistes d’audit:** SAS Visual Analytics enregistre tous les accès aux rapports et les requêtes de données — cela contribue à la conformité aux exigences HIPAA.
- **Désidentification:** Les données synthétiques issues de l’étape 1 éliminent entièrement ces préoccupations — un avantage clé du workflow SAS Data Maker.
---

## Construire votre rapport

Au fur et à mesure que vous progressez dans les questions ci-dessus, organisez vos résultats dans un rapport :

1. **Page d'ensemble:** : Distribution des réadmissions, principales statistiques descriptives
2. **Page profil clinique:** Comorbidités, mesures cliniques, résultats de laboratoire selon le statut de réadmission
3. **Page admission:** Durée de séjour, type d’admission, modes de sortie
4. **Page médicaments:** Nombre de médicaments, polymédication, médicaments à haut risque
5. **Page facteurs de risque:** Score de risque clinique, type d’assurance, distributions d’âge

Utilisez des **filtres** et des **interactions** entre les visualisations — le fait de cliquer sur une barre dans un graphique doit filtrer les autres. Cela vous permet d’explorer en détail des segments tels que « les patients Medicare avec 3+ comorbidités admis via le service des urgences ».

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
