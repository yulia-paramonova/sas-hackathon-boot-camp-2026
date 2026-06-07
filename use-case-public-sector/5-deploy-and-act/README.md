# Étape 5 : Deploy & Act

Dans cette étape finale, vous allez utiliser **SAS Intelligent Decisioning** pour opérationnaliser votre modèle de prédiction de l'urgence en l'intégrant dans un flux décisionnel automatisé de tri des demandes de service. Vous allez aussi explorer son **Copilot** et découvrir comment les décisions peuvent fonctionner comme des **outils dans des workflows agentiques**, ou devenir elles-mêmes des workflows agentiques.

---

## Prérequis

Votre modèle champion doit être enregistré dans **SAS Model Manager** depuis l'étape 4. SAS Intelligent Decisioning récupérera le modèle directement depuis le registre de Model Manager. Si vous n'avez pas enregistré le vôtre, ne vous inquiétez pas : un modèle par défaut est fourni.

---

## Qu'est-ce que SAS Intelligent Decisioning ?

SAS Intelligent Decisioning est le module permettant de créer, de gérer et d'exécuter des décisions métier qui combinent des modèles analytiques, des règles métier et une logique contextuelle au sein d'un flux décisionnel unique. Au lieu de se contenter d'évaluer une demande de service à l'aide d'un modèle, un flux décisionnel permet :

- d'évaluer la probabilité d'urgence de la demande
- de la classer dans un niveau d'urgence
- de la transmettre au service compétent
- d'allouer les ressources en fonction de la priorité et de la disponibilité
- de signaler les cas sensibles en matière d'équité pour qu'ils soient transmis à un niveau supérieur
- de fournir une recommandation complète de triage

Cela transforme une prédiction de modèle en une **décision de triage exploitable**.  

Si vous avez des questions concernant SAS Intelligent Decisioning, activez le copilote SAS Viya dans l'application via l'icône située dans le coin supérieur droit, à côté de votre profil, ou adressez-vous à l'un des mentors SAS présents sur place.  

---

## Création d'une décision de triage des demandes de service

### 1. Ouvrez SAS Intelligent Decisioning

1. Depuis le menu principal SAS Viya, allez dans **SAS Intelligent Decisioning** (sous **Build Decisions**)
2. Cliquez sur **New Decision**
3. Donnez-lui le nom : *Metro City Service Request Triage*
4. Laissez *Description*, *Location* et *Workflow* avec les valeurs par défaut puis cliquez sur OK
    ![image-20260529172317915](img/README/image-20260529172317915.png)
5. Allez dans l'onglet _Variables_, cliquez sur la liste déroulante _Add variable_ puis sélectionnez soit _Custom variable_ si vous voulez tout ajouter vous-même, soit _Decision_ pour copier depuis le template (c'est plus rapide). Les étapes manuelles sont décrites dans les sous-étapes 1 et 2 ci-dessous, tandis que la copie est décrite à l'étape 3 :
    ![image-20260529172529128](img/README/image-20260529172529128.png)
    1. Définissez les **variables d'entrée/input variables** (elles seront passées lors de l'appel de la décision) - La structure est : `name` (type de données) :
        1. `request_type` (character)
    2. Définissez les **variables de sortie/output variables** (ce que retourne la décision) - La structure est : `name` (type de données) - Explication (juste pour le contexte) :
        1. `urgency_tier` (character) - le niveau de priorité attribué
        2. `assigned_department` (character) - le service chargé de traiter la demande
        3. `resource_allocation` (character) - niveau de ressource à attribuer
        4. `escalation_flag` (character) - indique s'il faut escalader vers la direction
        5. `reason` (character) - raison pour laquelle cette décision de triage a été prise
        6. `target_response_hours` (decimal) - objectif SLA pour ce niveau de priorité
        7. Cliquez ensuite sur OK pour toutes les ajouter
            ![image-20260529173207540](img/README/image-20260529173207540.png)
    3. Copiez les **variables** depuis une décision template :
        1. Cliquez sur l'icône dossier dans le champ d'entrée _Decision_
        2. Naviguez vers *SAS Content > SAS Hackathon Bootcamp 2026 > Use Case Public Sector* sélectionnez *Metro City Service Request Triage* et cliquez sur OK
        3. Cliquez sur l'icône _Add all_ au milieu de la boîte de dialogue pour importer toutes les variables dans votre décision, puis cliquez sur le bouton Add

Une fois les variables ajoutées (quelle que soit la méthode), cliquez sur l'icône de sauvegarde en haut à droite. Il est recommandé de l'utiliser rapidement à chaque modification des variables avant de continuer.

À partir d'ici, vous pouvez aussi activer à tout moment le Copilot SAS Viya via l'icône en haut à droite pour poser des questions sur SAS Intelligent Decisioning et approfondir votre compréhension de l'application.

### 2. Ajoutez le nœud Modèle

1. Passez à l’onglet *Decision Flow*.
2. Dans le canvas de flux de décision, vous pouvez soit faire un clic droit sur le nœud *Start* et dans le menu contextuel sélectionner *Add below > Model*, soit sur le côté droit cliquer sur l’icône qui ressemble un peu à une carte postale et depuis cette barre latérale glisser-déposer un nœud modèle sur le nœud *Start*.
    ![image-20260529173330775](img/README/image-20260529173330775.png)
3. Sélectionnez votre modèle champion enregistré depuis SAS Model Manager ou le modèle champion pré‑enregistré en naviguant vers *DM Repository > Metro City Service Request Urgency Prediction_1 > Version 1 > Gradient Boosting (SAS Automatically Generated Pipeline* puis cliquez sur OK.
    ![image-20260529173444298](img/README/image-20260529173444298.png)
4. Après cela, vous verrez une petite icône d’erreur rouge à côté du modèle, et cela est dû au fait qu’il manque des variables d’entrée et de sortie — nous allons corriger cela dans les étapes suivantes.
5. Il manque plusieurs variables pour que le modèle puisse s’exécuter. Nous allons cliquer sur le menu *More* en haut, puis sélectionner *Add missing variables*. Cette action ajoutera toutes les variables de sortie requises à notre décision. Si vous avez copié les variables à partir du template, elles sont déjà présentes. Dans ce cas, veillez à les désélectionner dans les sorties (Output), car nous allons créer nos propres sorties personnalisées.
Les entrées (Inputs) doivent être conservées telles quelles.  
    ![image-20260529173747543](img/README/image-20260529173747543.png)


### 3. Ajouter des règles métier

Après que le modèle ait évalué la demande, ajoutez des nœuds **Rule Set** pour déterminer le niveau d'urgence. Pour cela, assurez‑vous d’abord d’avoir cliqué sur l’icône de sauvegarde de votre décision, puis nous ajouterons des **Rule Sets** à notre décision.


Il existe deux façons d’ajouter des **Rule Sets** à la décision :

1.    _La méthode simple_, où vous utilisez les **Rule Sets** préconstruits en cliquant sur les trois points verticaux du nœud modèle puis en sélectionnant _Add > Rule Set_, ensuite dans la boîte de dialogue allez dans _SAS Content > SAS Hackathon Bootcamp 2026 > Use Case Public Sector_ et ajoutez le rule set comme indiqué ci-dessous.

3.    _La méthode pédagogique_, si vous voulez les créer vous-même, vous pouvez cliquer à droite sur _Objects_ (icône carte postale) puis glisser-déposer un Rule Set sur le nœud précédent. Cela ouvre une boîte de dialogue où vous devez nommer votre décision en conséquence ; laissez l'emplacement par défaut (_My Folder_), puis ajoutez les variables de la décision créée et commencez à construire les Rule Sets comme décrit ci-dessous. Les variables requises sont indiquées soit dans les colonnes, soit dans **Rule Conditions**. Le premier rule set à construire inclut des notes et des captures d'écran pour vous guider.

Nous vous recommandons d'essayer de construire au moins un de ces rule sets vous-même pour comprendre la démarche. Si vous avez des questions sur SAS Intelligent Decisioning, activez le copilot SAS Viya dans l'application via l'icône en haut à droite à côté de votre profil, ou demandez à l'un des mentors SAS présents sur site.

**Rule Set: Classification du niveau d'Urgence**

1.   Depuis le panneau latéral _Objects_, glissez-déposez un nœud _Rule Set_ sur le nœud _Model_ déjà présent dans votre décision. Saisissez ensuite le nom ci-dessus et cliquez sur _Save_.
     ![image-20260529174004365](img/README/image-20260529174004365.png)
2.   Sur la droite, vous verrez le panneau _Properties_ pour ce nouveau _Rule Set_ avec un bouton _Open_ qui vous amène au _Rule set editor_ afin de construire la logique de décision ; cliquez sur ce bouton.
3.   Une nouvelle interface s'ouvre sur l'onglet _Variables_ du _Rule Set_. Sous _Add variable_, utilisez l'icône dossier pour naviguer vers _My Folder_ et sélectionnez *Metro City Service Request Triage* que vous avez déjà créé.  Sélectionnez les variables **P_is_urgent1, target_response_hours** & **urgency_tier** puis ajoutez-les au Rule Set : **P_is_urgent1** est utilisée dans la colonne Rule Conditions du tableau ci-dessous, **urgency_tier** et **target_response_hours** ont leur propre colonne car elles reçoivent des valeurs.
     ![image-20260529174331866](img/README/image-20260529174331866.png)
4.   Pour **P_is_urgent1**, modifiez-la pour qu'elle soit requise en entrée puis cliquez sur l'icône de sauvegarde pour enregistrer ce changement. Les variables **urgency_tier** & **target_response_hours** n'ont pas encore de valeurs provenant de la décision, vous pouvez donc les laisser en sortie.
     ![image-20260529174428872](img/README/image-20260529174428872.png)
5.   Allez dans l'onglet _Rule set_ puis cliquez sur le bouton _Add rule_.
     ![image-20260529174505488](img/README/image-20260529174505488.png)
6.   Remplacez l'opérateur par défaut (égal) par plus grand que *greater than* puis saisissez la comparaison dans la condition _IF_. Dans l'affectation THEN, choisissez la variable **urgency_tier** et saisissez la valeur correspondante entre guillemets simples. Ensuite, lorsque vous survolez l’assignation dans le THEN, une icône `+` apparaît à la fin de la ligne. Cliquez dessus pour en ajouter une nouvelle, afin d’assigner la valeur de **target_response_hours**.
     ![image-20260529174608572](img/README/image-20260529174608572.png)
7.   Cliquez ensuite sur _Add rule_, puis dans la liste déroulante de l'instruction _IF_, passez à une condition _ELSE_. Cela permet de combiner les conditions supplémentaires dans une seule règle. Continuez ensuite à saisir le reste des conditions et affectations comme indiqué ci-dessous. Une fois terminé, cliquez sur l'icône de sauvegarde puis utilisez soit la petite croix _x_ en haut à droite, soit ***Metro City Service Request Triage (1.0)* dans le fil de navigation pour revenir à la décision.
     ![image-20260529174819697](img/README/image-20260529174819697.png)

| Conditions de règle | urgency_tier | target_response_hours |
|--------------------|-------------|----------------------|
| P_is_urgent1 >= 0.90 | Critical | 4 |
| P_is_urgent1 >= 0.70 | High | 12 |
| P_is_urgent1 >= 0.40 | Medium | 36 |
| P_is_urgent1 < 0.40 | Low | 72 |

**Rule Set: Affectation au service**

| urgency_tier | Conditions de règle | assigned_department | resource_allocation |
|--------------|-----------------------|--------------------|---------------------|
| Critical | request_type contains 'water' OR 'sewer' OR 'gas' | Public Works (Emergency) | Emergency crew + supervisor |
| Critical | request_type contains 'traffic' OR 'road' | Transportation (Emergency) | Emergency crew + supervisor |
| Critical | request_type contains 'building' OR 'structural' | Building & Safety (Emergency) | Inspector + emergency crew |
| High | Any | Original department (priority queue) | Senior staff + overtime authorized |
| Medium | Any | Original department (standard queue) | Standard staffing |
| Low | Any | Original department (scheduled queue) | Standard staffing |

**Rule Set: Gestion des cas urgents**

| Conditions de règle | escalation_flag |
|-----------|-----------|
| urgency_tier = 'Critical' | Immediate: notify department head and city operations center |
| urgency_tier = 'High' AND response_time_hours > 24 | Escalate: flag for equity review |
| urgency_tier = 'Medium' AND response_time_hours > 48 | Escalate: reassign or add resources |
| urgency_tier = 'Low' AND response_time_hours > 72 | Auto-escalate to Medium tier |
| Otherwise | No escalation |

**Rule Set: Attribution du motif**

These rules capture the dominant driver behind the triage decision and populate the `reason` variable used downstream by the LLM:

| Conditions de règle | reason *(motif)* |
|-----------|----------|
| urgency_tier = 'Critical' AND (request_type contains 'water' OR 'gas') | Imminent safety hazard |
| urgency_tier = 'Critical' AND request_type contains 'traffic' | Public safety risk on roadways |
| urgency_tier = 'Critical' | High-probability urgent request requiring immediate dispatch |
| urgency_tier = 'High' AND response_time_hours > 24 | Delayed response in an equity-sensitive district |
| urgency_tier = 'High' | Elevated urgency requiring priority handling |
| urgency_tier = 'Medium' | Standard service request within normal SLA |
| Otherwise | Routine request scheduled for next available slot |

### 4. Ajouter un LLM dans le flux

Nous allons maintenant ajouter un Large Language Model à notre décision. Pour cela, ouvrez le panneau latéral _Objects_ (icône carte postale) et glissez-déposez un nœud Call LLM sur le nœud _End_. Ajoutez ensuite les variables manquantes comme pour le nœud modèle (ne rendez pas le prompt obligatoire en entrée de la décision), puis cliquez sur l'icône de sauvegarde.

![image-20260529174850134](img/README/image-20260529174850134.png)

Vous pouvez maintenant soit ajouter le Rule Set _Prompt Assignment_ à la décision comme les autres Rule Sets, soit le créer vous-même. Si vous choisissez de le créer manuellement, ajoutez les variables suivantes de votre décision en entrée :

-   assigned_department
-   escalation_flag
-   reason
-   resource_allocation
-   target_response_hours
-   urgency_tier

Et en sortie, ajoutez la variable prompt (n'oubliez pas de cliquer sur l'icône de sauvegarde). Passez ensuite à l'onglet _Rule set_, cliquez sur le bouton _Add other_, sélectionnez le type de règle _Assignment_ puis cliquez sur _OK_ : ici, nous ne voulons pas définir de condition, mais simplement renseigner notre prompt avec une valeur longue.

![image-20260529175037923](img/README/image-20260529175037923.png)

Ensuite, affectez la valeur du prompt en cliquant sur l'icône crayon. Dans l'_Expression Editor_, supprimez toutes les valeurs de l'éditeur principal puis copiez-collez la valeur ci-dessous. Cliquez sur le bouton _Save_, puis sur l'icône de sauvegarde du _Rule set_, et revenez à la décision principale.  

```
prompt = CAT('You are a professional Metro City 311 citizen communications specialist. Using the service request triage data below, write a warm, respectful, and clearly structured long-form citizen notification (2 to 4 paragraphs) that the person who filed the request can read to understand how their request has been triaged and what to expect next. Do not expose internal codes or jargon verbatim — translate them into plain, everyday language. Do not commit to outcomes beyond the target response time specified, and do not make political or judgmental statements about the city or about other requests. Request and triage context: Urgency tier: ', urgency_tier, '. Assigned department: ', assigned_department, '. Target response time (hours): ', target_response_hours, '. Resource allocation: ', resource_allocation, '. Escalation flag: ', escalation_flag, '. Internal reason code: ', reason, '. Structure your response as follows. First, open with a respectful thank-you for filing the request and confirm that Metro City has received it and takes it seriously. Second, explain in plain language what the ', urgency_tier, ' urgency tier means for this request — translate it into everyday expectations rather than quoting the tier label verbatim. Third, describe which department (', assigned_department, ') will handle the request and, in a single sentence, what level of resources (', resource_allocation, ') has been assigned. Fourth, clearly communicate the target response window of ', target_response_hours, ' hours, what the citizen can expect during that window, and how they will be notified of progress or completion. If the escalation flag ', escalation_flag, ' indicates an immediate escalation, briefly note that senior city operations have also been notified. Translate the internal reason ', reason, ' into a brief, plain-language note about why this particular triage decision was made. Fifth, close with clear next steps — how the citizen can check status, how to reach 311 with questions, and a clear instruction to call 911 for any life-threatening emergency. Tone: warm, accountable, professional, and never dismissive or bureaucratic. Length: 200 to 350 words. Write in the second person (you, your request). Translate the answer in French.')
```

![image-20260529175321189](img/README/image-20260529175321189.png)

Il s’agit d’une approche très simplifiée de l’ingénierie de prompts (prompt engineering) et elle ne vous permet pas de tester et comparer différents grands modèles de langage. C'est pourquoi SAS propose le projet open source [SAS Agentic AI Accelerator](https://github.com/sassoftware/sas-agentic-ai-accelerator), qui permet de connecter n'importe quel LLM et de faire du prompt engineering ainsi que du monitoring avancés. Ici, nous disposons d'un LLM codé en dur (OpenAI GPT 5.4).

### 5. Tester la décision

1. Dans la décision, cliquez sur l'onglet _Scoring_ puis sur le sous-onglet _Scenarios_

2. Cliquez sur le bouton _New test_
    ![image-20260529175345494](img/README/image-20260529175345494.png)

3. Dans la fenêtre *New Scenario* laissez le nom par défaut, choisissez *My folder* comme emplacement et l'emplacement de la table dans votre *CASUSER*.

4. Saisissez des valeurs d'exemple :

   - citizen_account_age_days: 1921
   - citizen_engagement_score: 1.08
   - citizen_previous_requests: 2
   - citizen_satisfaction: 4.4
   - contact_SMS: True
   - day_of_week: 3
   - department: Public Works
   - dept_avg_budget_util: 0.8698333333
   - dept_avg_overtime: 82.916666667
   - dept_avg_requests_received: 170.91666667
   - dept_avg_resolution_rate: 0.7976666667
   - dept_avg_response_time: 55.775
   - dept_avg_satisfaction: 3.6416666667
   - dept_avg_staff_count: 31.916666667
   - district_avg_request_count: 18.402777778
   - district_avg_resolution_rate: 0.7860347222
   - district_avg_response_time: 59.110069444
   - district_total_critical: 726
   - district_total_high: 2451
   - location_district: Southside
   - request_id: REQ000501
   - request_type: Pothole Repair
   - response_time_hours: 48.0
   - submit_month: 11

   ![image-20260529181023982](img/README/image-20260529181023982.png)

4. Consultez la sortie en cliquant sur l'icône Results une fois que le _Status_ est passé à une coche verte
    ![image-20260529181053235](img/README/image-20260529181053235.png)

5. N'hésitez pas à tester d'autres scénarios pour valider la logique :
   - Une demande de maintenance de parc peu prioritaire doit être classée en niveau **Faible**
   - Une demande très urgente provenant d’un secteur présentant des enjeux d’équité doit déclencher une **escalade pour revue d’équité**
   - Une demande de niveau **Moyen** ouverte depuis plus de 48 heures doit être signalée pour **réaffectation**

### 6. Publier la décision

1. Cliquez sur **Validate**, puis sur **Publish** pour rendre la décision disponible sous forme de service appelable par d'autres outils
2. Choisissez une **destination :**
   - **CAS** — pour une exécution en batch sur l’ensemble de vos demandes  
   - **MAS (Micro Analytic Service)** — pour des appels API en temps réel, à faible latence (ex. depuis le système 311) — la seule option disponible ici
   - **Container** — pour un déploiement dans des systèmes externes 
3. Veillez à lui attribuer un **nom unique**  
4. Une fois publiée, la décision est accessible via un **endpoint API REST*

---

## Utilisation du Copilot de SAS Intelligent Decisioning 

Le Copilot de SAS Intelligent Decisioning est un assistant conversationnel qui peut répondre à des questions sur la documentation de **SAS Intelligent Decisioning**, **SAS Container Runtime**, et **SAS Micro Analytic Service**. Utilisez-le pour trouver rapidement des informations sur le fonctionnement de ces produits sans quitter l'application.

### Ce que le Copilot peut faire

- **Répondre à des questions de documentation** sur les fonctionnalités, concepts et workflows de SAS Intelligent Decisioning
- **Expliquer SAS Micro Analytic Service (MAS)**, ses options de déploiement, sa configuration et l'usage de ses API
- **Clarifier SAS Container Runtime** concernant la mise en place, la publication et la gestion
- **Vous aider à naviguer** dans les capacités du produit en décrivant le fonctionnement des fonctionnalités spécifiques
- **Fournir des conseils** sur les concepts de flux de décision, la configuration des rule sets et les options de publication basés sur la documentation officielle

### Example Copilot Prompts

- "Comment publier une décision dans le MAS?"
    - *"How do I publish a decision to MAS?"*
- "Quelle est la différence entre CAS et MAS lorsque je publie une décision?"
    - *"What is the difference between CAS and MAS as publishing destinations?"*
- "Comment SAS Container Runtime fonctionne-t-il pour le déploiement des décisions ?"
    - *"How does SAS Container Runtime work for deploying decisions?"*
- - *Quels types de nœuds puis-je ajouter à un flux de décision ?*
    - *"What types of nodes can I add to a decision flow?"*
- *Comment configurer les variables d'entrée et de sortie d'une décision ?*
    - *"How do I configure input and output variables for a decision?"*
- *"What are the publishing options for deploying a decision as a REST endpoint?"*

Le Copilot est un outil de référence utile pour obtenir rapidement des réponses sur les capacités de la plateforme pendant que vous construisez vos flux de décision.

---

## Les décisions comme outils dans des workflows agentiques

Une décision SAS Intelligent Decisioning publiée est exposée via un **endpoint API REST**. Cela signifie qu'elle peut être appelée comme un **outil** par n'importe quel agent IA, y compris les agents basés sur des grands modèles de langage (LLM) qui utilisent des capacités d'appel d'outils.

### Comment cela fonctionne

```
┌──────────────┐     ┌───────────────────────────┐     ┌──────────────────┐
│  311 Chatbot │────>│  SAS Intelligent          │────>│  Triage          │
│  Agent       │     │  Decisioning API          │     │  Recommendation  │
│  (LLM)       │<────│  /decisions/serviceTriage │<────│                  │
└──────────────┘     └───────────────────────────┘     └──────────────────┘
```

**Exemple de scénario :**  un citoyen contacte le service 311 ou utilise le chatbot de Metro City pour signaler un problème. L'agent conversationnel (alimenté par un LLM) peut :

1. Recueillir les informations de la demande au cours de la conversation.
2. **Appeler l'API SAS Intelligent Decisioning** avec les données de la demande.
3. Recevoir une réponse telle que : « Critique — déployer une équipe d'urgence pour une rupture de canalisation, SLA de 4 heures ».
4. Informer le citoyen du délai de traitement estimé et confirmer que sa demande a été priorisée.
5. Déclencher simultanément le workflow d'affectation de l'équipe concernée.

La décision devient un **outil** dans la boîte à outils de l'agent, comme une fonction de recherche ou une requête base de données. Cela crée un pont entre les modèles analytiques et l'IA conversationnelle.

### Pourquoi est-ce important ?

- **Cohérence :** chaque interaction avec le service 311 utilise la même logique de triage. Les règles et les scores des modèles sont centralisés et ne sont pas s en dur dans les prompts du chatbot.
- **Gouvernance :** la décision est versionnée et auditable dans SAS Intelligent Decisioning, au lieu d'être enfouie dans le prompt système d'un LLM.
- **Séparation des responsabilités :** les data scientists gèrent les modèles, les équipes opérationnelles définissent les règles métier, et le chatbot se contente d'appeler l'API.
- **Exécution en temps réel :** les endpoints MAS répondent en millisecondes, suffisamment vite pour un usage conversationnel.
- **Responsabilité publique :** la logique de décision étant documentée et versionnée, elle peut être examinée dans le cadre de demandes d'accès aux informations publiques.

---

## Les décisions comme workflows agentiques

Au-delà de leur rôle d'outils appelables, SAS Intelligent Decisioning peut lui-même orchestrer des **workflows agentiques** : des processus en plusieurs étapes qui exécutent de façon autonome une chaîne de décisions et d'actions.

### Comment une décision devient un agent

Un flux de décision agentique va au-delà d'un simple "entrée → règles → sortie". Il peut :

1. **Observer :** recevoir une nouvelle demande de service ou détecter qu'une demande existante a dépassé son délai d'intervention cible.
2. **Raisonner :** évaluer l'urgence de la demande, analyser la charge de travail actuelle du service concerné et vérifier les indicateurs d'équité du quartier.
3. **Décider :** sélectionner l'action de triage optimale, le routage vers le service approprié et l'allocation des ressources.
4. **Agir :** déclencher des actions en aval : envoyer une équipe sur le terrain, notifier le citoyen, créer un ordre de travail ou mettre à jour le tableau de bord.
5. **Surveiller :** suivre la résolution de la demande dans le respect de l'objectif de délai de traitement et réinjecter ce résultat dans les décisions futures.

### Exemple : agent automatisé de routage et d'escalade des demandes

```
┌──────────────┐     ┌───────────────────┐     ┌───────────────────┐
│  Event       │     │  Decision Flow    │     │  Actions          │
│  Trigger     │────>│                   │────>│                   │
│              │     │  1. Score model   │     │  - Dispatch crew  │
│  "New 311    │     │  2. Classify tier │     │  - Notify citizen │
│   request"   │     │  3. Route dept    │     │  - Create work    │
│   — or —     │     │  4. Allocate      │     │    order          │
│  "SLA breach │     │     resources     │     │  - Update         │
│   detected"  │     │  5. Check equity  │     │    dashboard      │
└──────────────┘     └───────────────────┘     └───────────────────┘
                              │
                              v
                    ┌──────────────────┐
                    │  Feedback Loop   │
                    │                  │
                    │  Was request     │
                    │  resolved within │
                    │  SLA? Update     │
                    │  model and rules.│
                    └──────────────────┘
```

Ce système est **agentique** parce qu'il :

- Détecte automatiquement les événements déclencheurs (nouvelle demande ou dépassement du délai d'intervention).
- Prend des décisions sans intervention humaine.
- Exécute des actions concrètes dans le monde réel (déploiement d'équipes, notifications, etc.).
- Apprend des résultats obtenus afin d'améliorer les décisions futures.

### Passage à l'échelle de la décision agentique

Dans un environnement de production, ce workflow agentique peut traiter **15 000 demandes par mois** sans intervention manuelle :

- **Mode temps réel (Real-time mode) :** chaque nouvelle demande 311 est évaluée et orientée instantanément dès sa réception.
- **Mode batch (Batch mode) :** chaque matin, les demandes en attente sont réévaluées afin d'identifier les risques de non-respect des SLA et de redéfinir les priorités.
- **Mode événementiel (Event-driven mode) :** lorsqu'une échéance SLA approche, une procédure d'escalade est automatiquement déclenchée.
- **Orchestration de décisions (Multi-decision chaining) :** la décision de triage peut appeler une décision d'optimisation des ressources, qui elle-même appelle une décision de notification des citoyens, créant ainsi une chaîne de traitement entièrement automatisée.

SAS Intelligent Decisioning fournit la couche d'orchestration qui transforme des modèles et des règles métier isolés en **agents autonomes à l'échelle de l'entreprise**, capables d'automatiser et d'optimiser la fourniture de services municipaux.

---

## Résumé

Dans cette étape, vous avez :

1. **Créé un flux de décision** combinant votre modèle d’urgence et des règles métiers pour produire des recommandations de triage actionnables
2. **Ajouté un appel à un LLM** pour transformer la décision en un message de notification clair et adapté aux citoyens  
3. **Utilisé SAS Viya Copilot** pour obtenir des informations sur SAS Intelligent Decisioning, MAS et Container Runtime 
4. **Publié la décision** sous forme d’endpoint API appelable  
5. **Compris le rôle des décisions comme outils** pour l’agent chatbot 311  
6. **Exploré des workflows agentiques** où les décisions détectent, analysent, décident et agissent de manière autonome sur les demandes

---

## Félicitations !

Vous avez terminé l'ensemble du cycle de vie Data & AI pour le cas d’usage de priorisation des demandes de services citoyens de Metro City  :

| Étape           | Ce que vous avez fait                                         | Technologie SAS                       |
| --------------- | ------------------------------------------------------------- | ------------------------------------- |
| 1. Ask & Access | Compréhension du problème, génération de données synthétiques | SAS Data Maker                        |
| 2. Prepare      | Chargement, profilage et jointure des données dans un ABT     | SAS Viya Workbench ou SAS Studio      |
| 3. Explore      | Exploration visuelle des schémas avec assistance IA           | SAS Visual Analytics + Copilot        |
| 4. Model        | Construction, comparaison et test d'équité des modèles        | SAS Model Studio + Copilot            |
| 5. Deploy & Act | Opérationnalisation via des décisions automatisées            | SAS Intelligent Decisioning + Copilot |

S'il vous reste du temps, explorez un autre cas d'usage ou approfondissez n'importe quelle étape. Échangez avec votre mentor bootcamp pour des sujets de suivi ou pour partager vos retours.
