# Étape 1 : Ask & Access

Bienvenue chez **ShopEase**, une plateforme e-commerce fictive. Dans cette étape, vous allez comprendre les défis métier actuels, découvrir la valeur des données synthétiques et importer vos données dans **SAS Data Maker** pour générer une version synthétique du jeu de données.

---

## La valeur des données synthétiques

Les données synthétiques sont des données générées artificiellement qui reproduisent les propriétés statistiques, les schémas et la structure de données réelles, sans contenir d’enregistrements issus du jeu de données d’origine. Elles sont produites à l’aide de modèles génératifs qui apprennent les distributions, corrélations et relations présentes dans les données réelles, puis créent de nouveaux enregistrements entièrement originaux, statistiquement représentatifs mais impossibles à rattacher à un individu précis. Ces dernières années, les données synthétiques sont devenues essentielles dans de nombreux secteurs face à la pression croissante liée à la confidentialité des données, à la conformité réglementaire et au besoin de disposer de données de qualité en quantité suffisante pour l’analytique et le machine learning.

Pour un cas d’usage comme la prédiction de churn client chez ShopEase, les données synthétiques offrent plusieurs avantages concrets. D’abord, elles permettent aux équipes de développer, tester et itérer sur les modèles dans des environnements hors production sans exposer de données clients réelles, ce qui est crucial lorsqu’on manipule des données personnelles (PII) comme les informations démographiques et les comportements d’achat. Ensuite, elles permettent d’enrichir des segments sous-représentés : si le jeu de données contient peu d’exemples de clients Premium ayant résilié, la génération synthétique peut créer des cas réalistes supplémentaires pour améliorer l’apprentissage des modèles. Elles facilitent aussi la collaboration transverse : marketing, ingénierie et partenaires externes peuvent travailler sur des données réalistes sans surcharge liée aux accords d’accès aux données ni aux pipelines d’anonymisation. Enfin, elles permettent le stress testing et la simulation : que se passe-t-il si le churn double ? Que se passe-t-il si une nouvelle catégorie de produits est introduite ? Ces scénarios peuvent être modélisés de façon synthétique avant de se produire dans la réalité.

---

## Travailler avec SAS Data Maker

[SAS Data Maker](https://www.sas.com/en_us/software/data-maker.html) est la plateforme SAS de génération de données synthétiques de haute qualité. Dans cette section, vous allez importer les jeux de données de ShopEase dans SAS Data Maker et créer une version synthétique qui préserve les relations statistiques entre les quatre tables.

### Se connecter à SAS Data Maker

Les mentors du SAS Hackathon Bootcamp vous fourniront trois liens, ainsi qu’un identifiant et un mot de passe. Votre identifiant et votre mot de passe sont identiques dans les trois environnements. Pour accéder à SAS Data Maker, utilisez le lien qui contient le mot Data Maker. Une page de connexion vous demandera un identifiant (nom d’utilisateur ou adresse e-mail), puis un mot de passe, fournis par les mentors.

Veuillez noter que si vous avez déjà un compte SAS Communities, vous ne devez pas utiliser ces identifiants. En cas d’erreur de connexion, essayez d’ouvrir une fenêtre de navigation privée (incognito), car vous êtes peut-être déjà connecté à un autre environnement SAS.

### Générer des données synthétiques avec SAS Data Maker

Suivez les étapes suivantes pour créer votre jeu de données synthétiques :

#### 1. Créer un projet

1. Ouvrez **SAS Data Maker**
2. Cliquez sur **New project** pour créer un nouveau projet
3. Donnez-lui un nom explicite, par exemple : _ShopEase Churn — Synthetic Generation_

![image-20260529142137672](img/README/image-20260529142137672.png)

#### 2. Importer les données sources

1. Dans votre plan de données, cliquez sur **Add Data Source**
2. Naviguez vers le dossier Bootcamp/use-case-retail/csv
3. Importez les quatre fichiers CSV suivants :
    - customers.csv — table entité principale
    - transactions.csv — table enfant liée via customer_id (plusieurs transactions par client)
    - sessions.csv — table enfant liée via customer_id (plusieurs sessions par client)
    - support_tickets.csv — table enfant liée via customer_id
4. SAS Data Maker analysera chaque table et affichera les types de colonnes, les distributions et les statistiques descriptives

![image-20260529142229808](img/README/image-20260529142229808.png)

Vous verrez ensuite une barre de chargement semblable à celle ci-dessous. Cette étape prend généralement moins de deux minutes. Vous pouvez déjà commencer à consulter l’étape suivante pendant le chargement :

![image-20260529142244679](img/README/image-20260529142244679.png)

#### 3. Définir les relations

Le traitement lancé pour analyser les tables tentera également de détecter les relations entre elles. Vérifiez que ces relations sont correctement établies. Votre objectif est d’obtenir un schéma similaire à celui présenté ci-dessous, même si ce ne sera pas le cas au départ.

![image-20260529142317563](img/README/image-20260529142317563.png)

1. Pour customers, définissez customer_id comme clé primaire
2. Pour transactions, définissez transaction_id comme clé primaire et customer_id comme clé étrangère
3. Pour sessions, définissez session_id comme clé primaire et customer_id comme clé étrangère
4. Pour support_tickets, définissez ticket_id comme clé primaire et customer_id comme clé étrangère
5. Toutes les tables sont de type Tabular
6. Vérifiez les relations clés suivantes :
    - transactions.customer_id -> customers.customer_id
    - sessions.customer_id -> customers.customer_id
    - support_tickets.customer_id -> customers.customer_id
7. Ces relations garantissent que les données synthétiques conservent une intégrité référentielle : chaque transaction synthétique sera associée à un client synthétique valide

#### 4. Paramètres d’entraînement

1. **Random state** : option facultative qui peut être définie avec une graine. Pourquoi ne pas essayer un classique comme 42 ?
2. **Model type** : vous pouvez choisir entre PrivBayes et SMOTE ; ici, nous utiliserons PrivBayes pour tirer parti de la confidentialité différentielle
3. **Use differential privacy** : cette option aide à réduire l’impact sur la vie privée de chaque individu présent dans les données. Renforcer la confidentialité est un excellent moyen d’améliorer la confiance dans votre IA responsable
4. Les autres paramètres peuvent rester à leurs valeurs par défaut, puis cliquez sur **Start training**. N’hésitez pas à explorer les options plus en détail : des aides contextuelles sont disponibles dans l’outil, ou vous pouvez solliciter un mentor SAS sur place
5. Le processus d’entraînement prendra un moment ; une fois terminé et les métriques calculées, vous pourrez passer à l’étape suivante : **Evaluation**

![image-20260529142348543](img/README/image-20260529142348543.png)

#### 5. Évaluation

Dans l’onglet **Evaluation**, vous obtenez de nombreux insights sur votre modèle de génération de données synthétiques, notamment sur sa capacité à reproduire les caractéristiques des données sources, non seulement table par table, mais aussi dans les relations entre les différentes tables.

![image-20260529142539885](img/README/image-20260529142539885.png)

Prenez le temps d’explorer ces résultats afin de comprendre à quel point les données synthétiques reflètent fidèlement les données d’origine. N’hésitez pas à en discuter en groupe, à solliciter les mentors SAS présents sur place en cas de questions, ou à consulter la [Documentation SAS](https://go.documentation.sas.com/doc/en/sdgcdc/v_001/sdgug/p0ki9glx7acxpyn1wttognicd7qi.htm).

#### 6. Génération

1. **Output destination** : sélectionnez le chemin datamakerdemodata:output et définissez le format de sortie selon votre préférence (par exemple parquet)
2. Laissez toutes les autres options par défaut et cliquez sur le bouton **Generate**

![image-20260529142602160](img/README/image-20260529142602160.png)

3. Un job de génération est alors déclenché ; il créera les données synthétiques pour chaque table
4. Une fois la génération terminée, vous obtenez un résumé global, une note indiquant où les données sont stockées, ainsi qu’un échantillon des données synthétiques. Les données générées sont stockées sur un blob storage ; vous n’aurez rien à télécharger sur votre ordinateur, car elles seront mises à disposition dans SAS Viya et SAS Viya Workbench pour la suite

![image-20260529142657242](img/README/image-20260529142657242.png)

---

## Étapes suivantes

Passez à **[Étape 2 : Prepare](../2-prepare/)** pour charger, profiler et joindre les données dans une table de base analytique à l'aide de SAS Studio ou SAS Viya Workbench.

