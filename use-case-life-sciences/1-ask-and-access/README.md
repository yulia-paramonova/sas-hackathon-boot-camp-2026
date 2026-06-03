# Step 1: Ask & Access

Bienvenue chez **MedCare Health System**, un réseau régional de santé fictif. À cette étape, vous découvrirez les défis métier actuels, apprendrez la valeur des données synthétiques dans le domaine de la santé, et chargerez vos données dans **SAS Data Maker** afin de générer une version synthétique du jeu de données.

---

## Contexte réglementaire

L’analytique de santé est soumise à une supervision réglementaire et éthique stricte. Les principales réglementations applicables à ce cas d’usage incluent :

| Réglementation | Exigences |
|-----------|-----------------|
| **HIPAA** (Health Insurance Portability and Accountability Act) | Protège les informations de santé des patients ; impose des mesures de sécurité pour l’accès, l’utilisation et la divulgation des données de santé protégées (PHI) |
| **HITECH Act** |  Renforce l’application de la HIPAA ; impose la notification des violations en cas de données de santé non sécurisées |
| **CMS HRRP** (Hospital Readmissions Reduction Program) | Pénalise les hôpitaux présentant des taux de réadmission excessifs pour certaines pathologies ; constitue une motivation directe pour ce cas d’usage |
| **Joint Commission Standards** |  Exige des processus de transition des soins fondés sur des preuves et la mesure de la qualité |

Ces réglementations impliquent qu’au-delà de la construction d’un modèle précis, le workflow analytique doit protéger la confidentialité des patients, produire des résultats interprétables d’un point de vue clinique, et soutenir la documentation d’amélioration de la qualité exigée par le CMS et les organismes d’accréditation. 

---


## La valeur des données synthétiques

Les données synthétiques sont des données générées artificiellement qui **reproduisent les propriétés statistiques, les patterns et la structure de données réelles — sans contenir aucun enregistrement issu du jeu de données original**. Elles sont produites à l’aide de modèles génératifs capables d’apprendre les distributions, les corrélations et les relations présentes dans les données réelles, puis de créer de nouveaux enregistrements entièrement originaux, **représentatifs sur le plan statistique mais impossibles à rattacher à un individu spécifique**. Ces dernières années, les données synthétiques sont devenues un outil essentiel dans de nombreux secteurs, alors que les organisations font face à une pression croissante liée à la confidentialité des données, à la conformité réglementaire et au défi pratique d’obtenir des données de haute qualité en quantité suffisante pour l’analytique et le machine learning.

Pour un cas d’usage comme la prédiction des réadmissions de patients chez MedCare Health System, les données synthétiques offrent plusieurs avantages concrets particulièrement importants dans le secteur de la santé. Tout d’abord, elles permettent aux équipes de développer, tester et itérer sur des modèles sans exposer d’informations de santé protégées (PHI) — une exigence fondamentale dans le cadre de la HIPAA. Les dossiers réels des patients, contenant des diagnostics, des traitements, des signes vitaux et des informations d’assurance, font partie des catégories de données les plus sensibles qui existent ; la génération synthétique élimine totalement le risque de ré‑identification, permettant ainsi aux analystes, data scientists et collaborateurs externes de travailler librement, sans nécessiter d’accords de type Business Associate Agreements ni de processus de désidentification. Deuxièmement, les données synthétiques peuvent enrichir des scénarios cliniques sous‑représentés : si le jeu de données contient très peu de cas de réadmission pour des patients présentant des diagnostics rares ou des combinaisons inhabituelles de comorbidités, la génération synthétique peut produire des exemples supplémentaires réalistes afin d’améliorer l’entraînement des modèles sur ces cas limites. Troisièmement, les données synthétiques facilitent la collaboration multi‑sites — les hôpitaux du réseau MedCare, les partenaires de recherche externes et les fournisseurs de technologies peuvent travailler avec des données cliniques réalistes sans les contraintes juridiques et éthiques liées au partage de dossiers patients réels. Enfin, les données synthétiques permettent la simulation clinique : que se passerait‑il si les taux de réadmission doublaient pour les patients cardiaques ? Et si une nouvelle classe de médicaments à haut risque était introduite dans le formulaire thérapeutique ? Ces scénarios peuvent être modélisés de manière synthétique avant de se produire, permettant ainsi de concevoir de manière proactive des parcours de soins adaptés.

---

## Travailler avec SAS Data Maker

[SAS Data Maker](https://www.sas.com/en_us/software/data-maker.html) est la plateforme SAS dédiée à la génération de données synthétiques de haute qualité. Dans cette section, vous allez importer les jeux de données MedCare dans SAS Data Maker et créer une version synthétique qui préserve les relations statistiques entre les quatre tables.

### Se connecter à SAS Data Maker

Les mentors du SAS Hackathon Bootcamp vous fourniront trois liens, ainsi qu’un identifiant et un mot de passe. Ces identifiants sont identiques pour les trois environnements. Pour accéder à SAS Data Maker, utilisez le lien contenant la mention *Data Maker*. Une page de connexion vous demandera de saisir un identifiant (nom d’utilisateur ou adresse e-mail) puis un mot de passe — ceux qui vous ont été communiqués par les mentors.

Veuillez noter que si vous disposez déjà d’un compte SAS Communities, vous ne devez pas utiliser ces identifiants pour vous connecter. En cas d’erreur lors de la connexion, essayez d’ouvrir une fenêtre de navigation en mode privé (incognito), car vous pourriez déjà être connecté à un autre environnement SAS.

### Générer des données synthétiques avec SAS Data Maker

Suivez les étapes suivantes pour créer votre jeu de données synthétique:

#### 1. Créer un projet

1. Ouvrir **SAS Data Maker**
2. Cliquer sur **New project** pour créer un nouveau projet
3. Donner un nom explicite, par exemple : *MedCare Readmission — Synthetic Generation*
    ![image-20260529104507157](img/README/image-20260529104507157.png)
   
#### 2. Importer les données sources

1. Dans votre plan de données, cliquer sur **Add Data Source**  
2. Naviguer vers le dossier `Bootcamp/use-case-life-sciences/csv` 
3. Cela permettra d’importer les quatre fichiers CSV suivants :
   
- `patients.csv` — table principale (entité primaire)  
- `admissions.csv` — table liée via `patient_id`  
- `clinical_measures.csv` — table liée via `patient_id`  
- `medications.csv` — table enfant liée via `patient_id` (plusieurs médicaments par patient)


4. SAS Data Maker va analyser chaque table et afficher les types de colonnes, les distributions ainsi que des statistiques descriptives

![image-20260529104609945](img/README/image-20260529104609945.png)

 Vous verrez ensuite une barre de chargement semblable à celle ci-dessous. Cette étape prend généralement moins de deux minutes — vous pouvez déjà commencer à consulter l’étape suivante pendant le chargement:


![image-20260529104639475](img/README/image-20260529104639475.png)

#### 3. Définir les relations

Le traitement exécuté pour analyser les tables tentera également de détecter les relations entre elles. Veuillez vérifier que ces relations sont correctement établies. Votre objectif est d’obtenir un schéma de relations similaire à celui présenté ci-dessous, même si ce ne sera pas le cas au départ.

![image-20260529104744233](img/README/image-20260529104744233.png)

Pour connecter correctement les tables, cliquez sur chaque table puis, dans le panneau de droite sous *Foreign keys*, modifiez les valeurs *Key* et *Target* comme indiqué ci-dessous :

1. Pour `patients`, définir `patient_id` comme clé primaire (*Primary key*) 
2. Pour `admissions`, définir `admission_id` comme clé primaire et `patient_id` comme clé étrangère référencée vers  `patients`
3. Pour `medications`, définir `medication_id` comme clé primaire et `patient_id` comme clé étrangère
4. Pour `clinical_measures`, définir `patient_id` comme clé primaire
    ![image-20260529104949949](img/README/image-20260529104949949.png)
5. Toutes les tables doivent être de type *Tabular* 
6. Examinez les principales relations entre les tables :
   - `admissions.patient_id` -> `patients.patient_id`
   - `clinical_measures.patient_id` -> `patients.patient_id`
   - `medications.patient_id` -> `patients.patient_id`
7. Revenir ensuite dans l’onglet *Columns* pour ajuster le *Semantic type* des trois colonnes de la table `medications` :  `medication_name`, `medication_class` & `dosage` au type `Category`
    ![image-20260529105336594](img/README/image-20260529105336594.png)
8. Ces relations garantissent que les données synthétiques conservent une intégrité référentielle — Chaque admission synthétique sera associée à un patient synthétique valide

#### 4. Training Settings

1.   **Random state** : cette option est facultative et peut être définie à une valeur initiale du nombre aléatoire (seed). Pourquoi ne pas essayer un grand classique comme 42 ?
2.   **Model type** :  nous pouvons choisir entre `PrivBayes` et `SMOTE`; nous utiliserons ici PrivBayes pour tirer parti de la fonctionnalité de confidentialité différentielle
3. **Use differential privacy**: cette option permet de mieux protéger les données individuelles en limitant les risques liés à la confidentialité. Plus le niveau de protection est élevé, plus vos modèles d’IA seront perçus comme fiables et responsables, ce qui renforce la confiance dans votre utilisation des données.
4.   Les autres paramètres peuvent rester à leurs valeurs par défaut — vous pouvez ensuite cliquer sur le bouton **Start training**. N’hésitez pas à explorer les options plus en détail : des aides contextuelles sont disponibles directement dans l’outil, ou vous pouvez solliciter un mentor SAS sur place  
5.   Le processus d’entraînement prendra un certain temps ; une fois terminé et les métriques calculées, vous pourrez passer à l’étape suivante : **Evaluation**

![image-20260529105403150](img/README/image-20260529105403150.png)


#### 5. Évaluation

Dans l’onglet **Evaluation**, vous pouvez obtenir de nombreux insights sur votre modèle de génération de données synthétiques, notamment sur sa capacité à reproduire les caractéristiques des données sources, non seulement table par table, mais également dans les relations entre les différentes tables.

![image-20260529105834928](img/README/image-20260529105834928.png)

Prenez le temps d’explorer ces résultats afin de comprendre à quel point les données synthétiques reflètent fidèlement les données d’origine. N’hésitez pas à en discuter en groupe, à solliciter les mentors SAS présents sur place en cas de questions, ou à consulter la [Documentation SAS](https://go.documentation.sas.com/doc/en/sdgcdc/v_001/sdgug/p0ki9glx7acxpyn1wttognicd7qi.htm).


#### 6. Generation

1. **Output destination**, select the path `datamakerdemodata:output` here and set the *Output format* to one that you prefer (for example *parquet*)
2. Leave all other options at default and click the Generate button
    ![image-20260529105918393](img/README/image-20260529105918393.png)
3. Now a generation job is triggered that will create the synthetic data for each table for us and make that 
4. Once the generation has finished we get a summary of everything, a note on where the data is stored and a sample of the synthetic data. The generated data is stored onto a blob storage, don't worry you will not have to download anything onto your laptop as we will provide the data already available in SAS Viya and SAS Viya Workbench so that you can get to work.

![image-20260529110103425](img/README/image-20260529110103425.png)

---

## Next Steps

Proceed to **[Step 2: Prepare](../2-prepare/)** to load, profile, and join the data into an analytical base table using SAS Viya Workbench.
