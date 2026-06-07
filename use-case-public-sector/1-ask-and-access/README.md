# Étape 1: Ask & Access

Bienvenue à **Metro City**, une municipalité fictive qui dessert 850 000 habitants répartis sur 12 quartiers. Dans cette étape, vous allez découvrir les enjeux actuels liés à la prestation de services, comprendre la valeur des données synthétiques dans le secteur public et importer vos données dans **SAS Data Maker** afin de générer une version synthétique du jeu de données.

---

## Contexte réglementaire

Les activités d’analytique dans le secteur public sont encadrées par des exigences de transparence, d’équité et de responsabilité. Les principales réglementations et politiques applicables à ce cas d’usage incluent :

| Réglementation / Politique | Exigence |
|--------------------|-----------------|
| **Public Records Act / FOIA** | Les données gouvernementales et les processus de décision algorithmique peuvent faire l’objet de demandes de divulgation publique |
| **ADA** (Americans with Disabilities Act) | Les services doivent être accessibles ; un tri automatisé ne doit pas désavantager les personnes en situation de handicap |
| **Politiques de responsabilité algorithmique** | De nombreuses collectivités exigent des évaluations d’impact pour les systèmes de décision automatisée affectant les services publics |
| **Titre VI du Civil Rights Act** | Interdit la discrimination dans les programmes financés par des fonds fédéraux ; s’applique à l’équité des services rendus |

Ces exigences impliquent que le modèle ne doit pas seulement être performant — il doit également être **transparent, auditable et démontrer son équité** sur l’ensemble des quartiers et des populations.

---

## La valeur des données synthétiques

Les données synthétiques sont des données générées artificiellement qui **reproduisent les propriétés statistiques, les patterns et la structure de données réelles — sans contenir aucun enregistrement issu du jeu de données original**. Elles sont produites à l’aide de modèles génératifs capables d’apprendre les distributions, les corrélations et les relations présentes dans les données réelles, puis de créer de nouveaux enregistrements entièrement originaux, **représentatifs sur le plan statistique mais impossibles à rattacher à un individu spécifique**. Dans le secteur public, où les données sont souvent soumises à des exigences réglementaires strictes, les données synthétiques sont devenues un levier essentiel pour innover de manière responsable.  

Dans un cas d’usage comme la priorisation des demandes de services citoyens à Metro City, les données synthétiques offrent plusieurs avantages concrets. Tout d’abord, elles permettent aux équipes de développer, tester et itérer sur les modèles **sans exposer les informations réelles des citoyens** — un point crucial lorsqu’il s’agit de données personnelles soumises au Public Records Act et aux réglementations sur la protection de la vie privée. Les adresses des citoyens, les détails des plaintes et les historiques d’interaction sont des données sensibles ; la génération de données synthétiques permet aux analystes, prestataires et partenaires inter-agences de travailler sur des données réalistes sans les contraintes liées aux accords d’accès aux données ou aux processus d’anonymisation.  

Ensuite, les données synthétiques facilitent l’évaluation de l’équité : en générant des scénarios avec différentes distributions par quartier, les équipes peuvent tester la robustesse et l’équité des modèles sur l’ensemble des zones avant leur déploiement sur des données réelles. Elles permettent également de simuler des situations qui ne sont pas encore présentes dans les données — par exemple un pic soudain de demandes d’urgence lors d’une catastrophe naturelle, ou l’impact de l’ajout de personnel dans un service en sous-effectif. Ces analyses « what-if » peuvent éclairer les décisions d’allocation des ressources et les choix de politiques publiques en amont.

Enfin, les données synthétiques rendent possibles des hackathons et des exercices de formation comme celui-ci : les participants peuvent explorer des jeux de données réalistes propres aux collectivités territoriales, sans aucun risque pour les citoyens réels.

---

## Travailler avec SAS Data Maker

[SAS Data Maker](https://www.sas.com/en_us/software/data-maker.html) est la plateforme SAS dédiée à la génération de données synthétiques de haute qualité. Dans cette section, vous allez importer les jeux de données Metro City dans SAS Data Maker et créer une version synthétique qui préserve les relations statistiques entre les quatre tables.

### Se connecter à SAS Data Maker

Les mentors du SAS Hackathon Bootcamp vous fourniront trois liens, ainsi qu’un identifiant et un mot de passe. Ces identifiants sont identiques pour les trois environnements. Pour accéder à SAS Data Maker, utilisez le lien contenant la mention *Data Maker*. Une page de connexion vous demandera de saisir un identifiant (nom d’utilisateur ou adresse e-mail) puis un mot de passe — ceux qui vous ont été communiqués par les mentors.

Veuillez noter que si vous disposez déjà d’un compte SAS Communities, vous ne devez pas utiliser ces identifiants pour vous connecter. En cas d’erreur lors de la connexion, essayez d’ouvrir une fenêtre de navigation en mode privé (incognito), car vous pourriez déjà être connecté à un autre environnement SAS.

### Générer des données synthétiques avec SAS Data Maker

#### 1. Créer un projet

1. Ouvrir **SAS Data Maker**
2. Cliquer sur **New project** pour créer un nouveau projet
3. Donner un nom explicite, par exemple : *Metro City Service Requests — Synthetic Generation*  

![image-20260529135847400](img/README/image-20260529135847400.png)

#### 2. Importer les données sources

1. Dans votre plan de données, cliquer sur **Add Data Source**  

2. Naviguer vers le dossier `Bootcamp/use-case-public-sector/csv`  

3. Cela permettra d’importer les quatre fichiers CSV suivants :
   - `service_requests.csv` — table principale au niveau des demandes
   - `citizens.csv` — table associée via `citizen_id`
   - `department_performance.csv` — table de référence agrégée liée via `department`
   - `request_history.csv` — table de référence agrégée pour les tendances historiques

4. SAS Data Maker va analyser chaque table et afficher les types de colonnes, les distributions ainsi que des statistiques descriptives ![image-20260529135940784](img/README/image-20260529135940784.png)

    Vous verrez ensuite une barre de chargement semblable à celle ci-dessous. Cette étape prend généralement moins de deux minutes — vous pouvez déjà consulter l’étape suivante pendant le chargement:

    ![image-20260529140021786](img/README/image-20260529140021786.png)

    

5. Examiner l’onglet **Columns** pour chaque table. Pour `service_requests`, vous remarquerez que la colonne `request_type` n’a pas de type sémantique défini (indiqué comme *(Not set)* avec un marqueur rouge). Cliquez sur cette cellule et définissez son type sémantique sur **Category** — sinon, l’entraînement échouera avec l’erreur *"The semantic type must be set, or the column should be dropped."*

#### 3. Définir les relations

Le traitement exécuté pour analyser les tables tentera également de détecter les relations entre elles. Veuillez vérifier que ces relations sont correctement établies. Votre objectif est d’obtenir un schéma de relations similaire à celui présenté ci-dessous, même si ce ne sera pas le cas initialement.  

![image-20260529141405534](img/README/image-20260529141405534.png)

Pour connecter correctement les tables, cliquez sur chaque table puis, dans le panneau de droite sous *Foreign keys*, modifiez les valeurs *Key* et *Target* comme indiqué ci-dessous :

1. Pour `citizens`, définir `citizen_id` comme clé primaire (*Primary key*)  
2. Pour `service_requests`, définir `request_id` comme clé primaire (*Primary key*) et `citizen_id` comme clé étrangère (*Foreign key*)  
3. `department_performance` et `request_history` sont des tables de référence agrégées — modifier leur type en *Reference*  
    ![image-20260529141531993](img/README/image-20260529141531993.png)
4. Toutes les autres tables doivent être de type *Tabular*  
5. Revenir ensuite dans l’onglet *Columns* pour ajuster le *Semantic type* de la colonne `request_type` dans la table `service_requests` en `Category`  
   ![image-20260529141702643](img/README/image-20260529141702643.png)
6. Ces relations garantissent que les données synthétiques conservent une intégrité référentielle — chaque demande de service synthétique sera associée à un citoyen synthétique valide et fera référence à un département valide

#### 4. Paramétrage de l’entraînement (Training Settings)

1.   **Random state** : cette option est facultative et peut être définie à l'aide d'une variable de départ (seed). Pourquoi ne pas essayer un grand classique comme [42](https://medium.com/geekculture/the-story-behind-random-seed-42-in-machine-learning-b838c4ac290a) ?
2.   **Model type** : nous pouvons choisir entre `PrivBayes` et `SMOTE` ; nous utiliserons ici PrivBayes pour tirer parti de la fonctionnalité de confidentialité différentielle
3.   **Use differential privacy** : cette option permet de mieux protéger les données individuelles en limitant les risques liés à la confidentialité. Plus le niveau de protection est élevé, plus vos modèles d’IA seront perçus comme fiables et responsables, ce qui renforce la confiance dans votre utilisation des données.
4.   Les autres paramètres peuvent rester à leurs valeurs par défaut — vous pouvez ensuite cliquer sur le bouton **Start training**. N’hésitez pas à explorer les options plus en détail : des aides contextuelles sont disponibles directement dans l’outil, ou vous pouvez solliciter un mentor SAS sur place  
5.   Le processus d’entraînement prendra un certain temps ; une fois terminé et les métriques calculées, vous pourrez passer à l’étape suivante : **Evaluation**

![image-20260529141437724](img/README/image-20260529141437724.png)

#### 5. Évaluation

Dans l’onglet **Evaluation**, vous pouvez obtenir de nombreux insights sur votre modèle de génération de données synthétiques, notamment sur sa capacité à reproduire les caractéristiques des données sources, non seulement table par table, mais également dans les relations entre les différentes tables.

![image-20260529141727038](img/README/image-20260529141727038.png)

Prenez le temps d’explorer ces résultats afin de comprendre à quel point les données synthétiques reflètent fidèlement les données d’origine. N’hésitez pas à en discuter en groupe, à solliciter les mentors SAS présents sur place en cas de questions, ou à consulter la [Documentation SAS](https://go.documentation.sas.com/doc/en/sdgcdc/v_001/sdgug/p0ki9glx7acxpyn1wttognicd7qi.htm).

#### 6. Génération

1. **Output destination** : sélectionnez ici le chemin `datamakerdemodata:output` et définissez le *Format de sortie* selon votre préférence (par exemple *parquet*)
2. Laissez toutes les autres options par défaut et cliquez sur le bouton Générer  
    ![image-20260529141801238](img/README/image-20260529141801238.png)
3. Un travail de génération est alors déclenché ; il va créer pour nous les données synthétiques pour chaque table  
4. Une fois la génération terminée, nous obtenons un résumé de l'ensemble, une note indiquant où les données sont stockées et un échantillon des données synthétiques. Les données générées sont stockées dans un blob storage ; ne vous inquiétez pas, vous n'aurez rien à télécharger sur votre ordinateur portable, car nous mettrons les données à votre disposition dans SAS Viya et SAS Viya Workbench afin que vous puissiez continuer le travail.

![image-20260529141951073](img/README/image-20260529141951073.png)

---

## Étapes suivantes

Passez à l'**[Étape 2: Prepare](../2-prepare/)** pour charger, profiler et joindre les données dans une table de base analytique à l'aide de SAS Studio ou SAS Viya Workbench.
