# Étape 1: Ask & Access

Bienvenue chez **PremierBank**, une banque régionale américaine fictive avec 2,1 milliards de dollars d’actifs et plus de 50 000 clients. Dans cette étape, vous allez obtenir des informations sur les défis commerciaux actuels, découvrir la valeur des données synthétiques dans les services financiers et importer vos données dans **SAS Data Maker** afin de générer une version synthétique de votre jeu de données. 

---

## Contexte Réglementaire

Les modèles utilisés dans les services financiers sont soumis à une surveillance réglementaire stricte. Les principales réglementations applicables à ce cas d’usage incluent: 

| Réglementation | Ce qu'elle exige |
|-----------|-----------------|
| **ECOA** (Equal Credit Opportunity Act) | Interdit la discrimination dans les décisions de crédit fondée sur la race, la couleur, la religion, l’origine nationale, le sexe, le statut marital, l’âge ou le statut d’assistance publique |
| **Fair Housing Act** | Interdit la discrimination dans les prêts liés au logement |
| **FCRA** (Fair Credit Reporting Act) | Exige des notifications d’action défavorable lorsque le crédit est refusé ou que les conditions sont modifiées sur la base d’informations de crédit |
| **SR 11-7** (Gestion du risque modèle OCC/Fed) | Exige la validation, la documentation et la surveillance continue des modèles utilisés dans les décisions bancaires |

Ces réglementations impliquent que, contrairement à de nombreux autres cas d’usage analytiques, le modèle que vous construisez ici doit non seulement être précis — il doit être **explicable, auditable et démontrablement équitable**.

---

## La Valeur des données synthétiques

Les données synthétiques sont des données générées artificiellement qui **reproduisent les propriétés statistiques, les patterns et la structure de données réelles — sans contenir aucun enregistrement issu du jeu de données original**. Elles sont produites à l’aide de modèles génératifs capables d’apprendre les distributions, les corrélations et les relations présentes dans les données réelles, puis de créer de nouveaux enregistrements entièrement originaux, **représentatifs sur le plan statistique mais impossibles à rattacher à un individu spécifique**. Dans les services financiers, où la sensibilité des données et la pression réglementaire sont particulièrement élevées, les données synthétiques sont devenues un outil essentiel pour un développement analytique responsable.

Pour un cas d’usage comme la prédiction de défaut de prêt chez PremierBank, les données synthétiques offrent des avantages considérables allant au-delà de la simple protection de la vie privée. Premièrement, les données de prêt sont parmi les plus sensibles détenues par une banque — elles incluent les revenus, l’emploi, les scores de crédit et les niveaux d’endettement, toutes des informations personnellement identifiables et réglementées par GLBA (Gramm-Leach-Bliley Act) et FCRA. Les données synthétiques permettent aux équipes analytiques, aux validateurs de modèles et aux partenaires externes de travailler avec des données réalistes sans exposer de véritables dossiers d’emprunteurs ni déclencher d’obligations de conformité liées au partage de données. 

Ensuite, les données synthétiques sont particulièrement utiles pour les **tests d’équité en matière de prêt** : les équipes peuvent générer des populations synthétiques avec des distributions démographiques contrôlées afin de tester si un modèle produit un impact disparate sur des classes protégées, même lorsque le jeu de données d’origine manque de représentation de certains groupes minoritaires. 

Enfin, les données synthétiques permettent le **stress testing et l’analyse de scénarios** — que se passe-t-il si le chômage double, si les taux d’intérêt augmentent de 200 points de base, ou si un nouveau produit de prêt est introduit ? Ces scénarios prospectifs peuvent être modélisés de manière synthétique avant qu’ils ne se produisent réellement, offrant au comité de crédit une vision anticipée de la résilience du portefeuille.

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
3. Donner un nom explicite, par exemple : *PremierBank Loan Default — Synthetic Generation*

![image-20260527132623936](img/README/image-20260527132623936.png)

#### 2. Importer les données sources

1. Dans votre plan de données, cliquer sur **Add Data Source**  

2. Naviguer vers le dossie `Bootcamp/use-case-public-sector/csv`  

3. Cela permettra d’importer les quatre fichiers CSV suivants :
   - `loan_applications.csv` — table principale
   - `credit_history.csv` — table associée via `loan_id`
   - `employment.csv` — table associée via `loan_id`
   - `payment_history.csv` — table enfant liée via `loan_id` (plusieurs paiements par prêt)
4. SAS Data Maker va analyser chaque table et afficher les types de colonnes, les distributions ainsi que des statistiques descriptives
![image-20260527133256774](img/README/image-20260527133256774.png)

Vous verrez ensuite une barre de chargement semblable à celle ci-dessous. Cette étape prend généralement moins de deux minutes — vous pouvez déjà commencer à consulter l’étape suivante pendant le chargement:

![image-20260527133421310](img/README/image-20260527133421310.png)

#### 3. Définir les relations

Le traitement exécuté pour analyser les tables tentera également de détecter les relations entre elles. Veuillez vérifier que ces relations sont correctement établies. Votre objectif est d’obtenir un schéma de relations similaire à celui présenté ci-dessous, même si ce ne sera pas le cas au départ.

![](./img/fin-services-ideal-map.png)

Pour connecter correctement les tables, cliquez sur chaque table puis, dans le panneau de droite sous *Foreign keys*, modifiez les valeurs *Key* et *Target* comme indiqué ci-dessous :

1. Pour `loan_applications`, définir `loan_id` comme clé primaire (*Primary key*)  
2. Pour `payment_history` définir `payment_id` comme clé primaire (*Primary key*) et `loan_id` comme clé étrangère (*Foreign key*) vers `loan_applications`
3. Pour `credit_history` et `employment`, définissez `loan_id` comme clé étrangère (*Foreign key*) vers `loan_applications` - ces deux tables utilisent `loan_id` comme clé étrangère (*Foreign key*) et clé primaire (*Primary key*).
    ![image-20260527134221055](img/README/image-20260527134221055.png)
4. Toutes les autres tables doivent être de type *Tabular*  
5. Verifiez les relations clés suivantes entre les tables:
   - `credit_history.loan_id` -> `loan_applications.loan_id`
   - `employment.loan_id` -> `loan_applications.loan_id`
   - `payment_history.loan_id` -> `loan_applications.loan_id`
6. Ces relations garantissent que les données synthétiques conservent une intégrité référentielle — chaque demande de paiement synthétique sera associée à un prêt synthétique valide

#### 4. Paramétrage de l’entraînement (Training Settings)

1.   **Random state** : cette option est facultative et peut être définie à l'aide d'une variable de départ (seed). Pourquoi ne pas essayer un grand classique comme [42](https://medium.com/geekculture/the-story-behind-random-seed-42-in-machine-learning-b838c4ac290a) ?
2.   **Model type** : nous pouvons choisir entre `PrivBayes` et `SMOTE` ; nous utiliserons ici PrivBayes pour tirer parti de la fonctionnalité de confidentialité différentielle
3.   **Use differential privacy** : cette option permet de mieux protéger les données individuelles en limitant les risques liés à la confidentialité. Plus le niveau de protection est élevé, plus vos modèles d’IA seront perçus comme fiables et responsables, ce qui renforce la confiance dans votre utilisation des données.
4.   Les autres paramètres peuvent rester à leurs valeurs par défaut — vous pouvez ensuite cliquer sur le bouton **Start training**. N’hésitez pas à explorer les options plus en détail : des aides contextuelles sont disponibles directement dans l’outil, ou vous pouvez solliciter un mentor SAS sur place  
5.   Le processus d’entraînement prendra un certain temps ; une fois terminé et les métriques calculées, vous pourrez passer à l’étape suivante : **Evaluation**

![image-20260527134338675](img/README/image-20260527134338675.png)

#### 5. Évaluation

Dans l’onglet **Evaluation**, vous pouvez obtenir de nombreux insights sur votre modèle de génération de données synthétiques, notamment sur sa capacité à reproduire les caractéristiques des données sources, non seulement table par table, mais également dans les relations entre les différentes tables.

![image-20260527134942404](img/README/image-20260527134942404.png)

Prenez le temps d’explorer ces résultats afin de comprendre à quel point les données synthétiques reflètent fidèlement les données d’origine. N’hésitez pas à en discuter en groupe, à solliciter les mentors SAS présents sur place en cas de questions, ou à consulter la [Documentation SAS](https://go.documentation.sas.com/doc/en/sdgcdc/v_001/sdgug/p0ki9glx7acxpyn1wttognicd7qi.htm).

#### 6. Génération

1. **Output destination** : sélectionnez ici le chemin `datamakerdemodata:output` et définissez le *Format de sortie* selon votre préférence (par exemple *parquet*)
2. Laissez toutes les autres options par défaut et cliquez sur le bouton Générer
    ![image-20260527135147097](img/README/image-20260527135147097.png)
3. Un travail de génération est alors déclenché ; il va créer pour nous les données synthétiques pour chaque table  
4. Une fois la génération terminée, nous obtenons un résumé de l'ensemble, une note indiquant où les données sont stockées et un échantillon des données synthétiques. Les données générées sont stockées dans un blob storage ; ne vous inquiétez pas, vous n'aurez rien à télécharger sur votre ordinateur portable, car nous mettrons les données à votre disposition dans SAS Viya et SAS Viya Workbench afin que vous puissiez continuer le travail.

![image-20260527135257125](img/README/image-20260527135257125.png)

---

## Étapes suivantes

Passez à l'**[Étape 2: Prepare](../2-prepare/)** pour charger, profiler et joindre les données dans une table de base analytique à l'aide de SAS Studio ou SAS Viya Workbench.
