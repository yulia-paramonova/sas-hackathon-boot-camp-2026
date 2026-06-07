# Étape 5 : Deploy & Act

Dans cette étape finale, vous allez utiliser **SAS Intelligent Decisioning** pour opérationnaliser votre modèle de prédiction de l'attrition en l'intégrant dans un flux de décision de rétention automatisé. Vous allez aussi explorer son **Copilot** et découvrir comment les décisions peuvent fonctionner comme des **outils dans des workflows agentiques**, ou devenir elles-mêmes des workflows agentiques.

---

## Prérequis

Votre modèle champion doit être enregistré dans **SAS Model Manager** depuis l'étape 4. SAS Intelligent Decisioning récupérera le modèle directement depuis le registre de Model Manager. Si vous n'avez pas enregistré le vôtre, ne vous inquiétez pas : un modèle par défaut est fourni.

---

## Qu'est-ce que SAS Intelligent Decisioning ?

SAS Intelligent Decisioning est la plateforme qui permet de créer, gérer et exécuter des décisions métier combinant modèles analytiques, règles métier et logique contextuelle dans un seul flux de décision. Au lieu de simplement scorer un client avec un modèle, un flux de décision peut :

- Calculer la probabilité d'attrition du client
- Le classer dans un niveau de risque
- Appliquer des règles métier (par ex. : "ne jamais proposer plus de 20 % de remise")
- Déterminer l'action de rétention appropriée (offre, relance, suivi)
- Sélectionner le meilleur canal de contact
- Retourner une recommandation complète de rétention

Cela transforme une prédiction de modèle en **décision de rétention actionnable**.

Si vous avez des questions sur SAS Intelligent Decisioning, activez le copilot SAS Viya dans l'application via l'icône en haut à droite à côté de votre profil, ou demandez à l'un des mentors SAS présents sur site.

---

## Créer une décision de rétention pour l'attrition

### 1. Ouvrir SAS Intelligent Decisioning

1. Depuis le menu principal SAS Viya, allez dans **SAS Intelligent Decisioning** (sous _Build Decisions_)

2. Cliquez sur **New Decision**

3. Donnez-lui le nom : _ShopEase Churn Retention Decision_

4. Laissez Description, Location et Workflow avec les valeurs par défaut puis cliquez sur OK
   ![image-20260529181358511](img/README/image-20260529181358511.png)

5. Allez dans l'onglet _Variables_, cliquez sur la liste déroulante _Add variable_ puis sélectionnez soit _Custom variable_ si vous voulez tout ajouter vous-même, soit _Decision_ pour copier depuis le template (c'est plus rapide). Les étapes manuelles sont décrites dans les sous-étapes 1 et 2 ci-dessous, tandis que la copie est décrite à l'étape 3 :
   ![image-20260529181434924](img/README/image-20260529181434924.png)
    1. Définissez les **variables d'entrée** (elles seront passées lors de l'appel de la décision) - La structure est : `name` (type de données) :
        1. `subscription_tier` (character)
        2. `total_spend` (decimal)
        3. `days_since_last_purchase` (decimal)

    2. Définissez les **variables de sortie** (ce que retourne la décision) - La structure est : `name` (type de données) - Explication (juste pour le contexte) :
        1. `offer_value` (decimal) - montant de la remise ou de l'incitation
        2. `action` (character) - action de rétention recommandée
        3. `risk_tier` (character) - classification du risque
        4. `channel` (character) - canal de communication préféré
        5. `priority` (character) - niveau d'urgence de la relance
        6. `reason` (character) - raison de la sélection de cette action de rétention
        7. Cliquez ensuite sur OK pour toutes les ajouter

        ![image-20260529181942098](img/README/image-20260529181942098.png)

    3. Copiez les **variables** depuis une décision template :
        1. Cliquez sur l'icône dossier dans le champ d'entrée _Decision_
        2. Naviguez vers _SAS Content > SAS Hackathon Bootcamp 2026 > Use Case Retail_, sélectionnez _ShopEase Churn Retention Decision_ puis cliquez sur OK
        3. Cliquez sur l'icône _Add all_ au milieu de la boîte de dialogue pour importer toutes les variables dans votre décision, puis cliquez sur le bouton Add

Une fois les variables ajoutées (quelle que soit la méthode), cliquez sur l'icône de sauvegarde en haut à droite. Il est recommandé de l'utiliser rapidement à chaque modification des variables avant de continuer.

À partir d'ici, vous pouvez aussi activer à tout moment le Copilot SAS Viya via l'icône en haut à droite pour poser des questions sur SAS Intelligent Decisioning et approfondir votre compréhension de l'application.

### 2. Ajouter le nœud modèle

1. Passez à l'onglet _Decision Flow_.
2. Dans le canevas de décision, vous pouvez soit faire un clic droit sur le nœud _Start_ puis choisir _Add below > Model_ dans le menu contextuel, soit cliquer à droite sur l'icône en forme de carte postale puis glisser-déposer un nœud modèle sur le nœud _Start_.
   ![image-20260529182110234](img/README/image-20260529182110234.png)
3. Sélectionnez votre modèle champion enregistré dans SAS Model Manager ou le modèle champion préenregistré en naviguant vers _DM Repository > ShopEase Customer Churn Prediction > Version 1 > Gradient Boosting (1) (SAS Automatically Generated Pipeline_ puis cliquez sur OK.
   ![image-20260529182231044](img/README/image-20260529182231044.png)
4. Après cela, vous verrez une petite icône d'erreur rouge à côté du modèle, car des variables d'entrée et de sortie sont manquantes ; nous allons corriger cela dans les étapes suivantes.
5. Il manque de nombreuses variables pour exécuter le modèle. Cliquez sur le menu _More_ en haut, puis sélectionnez _Add missing variables_ : cela ajoutera toutes les variables de sortie requises à notre décision. Si vous avez copié les variables via le template, elles sont déjà présentes. Dans la boîte de dialogue, veillez à les désélectionner côté Output car nous allons créer nos propres sorties personnalisées. Les Inputs doivent rester en place.
   ![image-20260529182344878](img/README/image-20260529182344878.png)

### 3. Ajouter des règles métier

Après que le modèle a scoré la demande, ajoutez des nœuds **Rule Set** pour déterminer la décision métier. Assurez-vous d'abord d'avoir cliqué sur l'icône de sauvegarde de votre décision, puis nous allons ajouter des Rule Sets à cette décision.

Il existe deux façons d'ajouter des **Rule Sets** à la décision :

1.  _La méthode simple_, où vous utilisez les rule sets préconstruits en cliquant sur les trois points verticaux du nœud modèle puis en sélectionnant _Add > Rule Set_, ensuite dans la boîte de dialogue allez dans _SAS Content > SAS Hackathon Bootcamp 2026 > Use Case Retail_ et ajoutez le rule set comme indiqué ci-dessous.
2.  _La méthode pédagogique_, si vous voulez les créer vous-même, vous pouvez cliquer à droite sur _Objects_ (icône carte postale) puis glisser-déposer un Rule Set sur le nœud précédent. Cela ouvre une boîte de dialogue où vous devez nommer votre décision en conséquence ; laissez l'emplacement par défaut (_My Folder_), puis ajoutez les variables de la décision créée et commencez à construire les Rule Sets comme décrit ci-dessous. Les variables requises sont indiquées soit dans les colonnes, soit dans **Rule Conditions**. Le premier rule set à construire inclut des notes et des captures d'écran pour vous guider.

Nous vous recommandons d'essayer de construire au moins un de ces rule sets vous-même pour comprendre la démarche. Si vous avez des questions sur SAS Intelligent Decisioning, activez le copilot SAS Viya dans l'application via l'icône en haut à droite à côté de votre profil, ou demandez à l'un des mentors SAS présents sur site.

**Rule Set : Classification du niveau de risque**

1.  Depuis le panneau latéral _Objects_, glissez-déposez un nœud _Rule Set_ sur le nœud _Model_ déjà présent dans votre décision. Saisissez ensuite le nom ci-dessus et cliquez sur _Save_.
    ![image-20260529182523411](img/README/image-20260529182523411.png)
2.  Sur la droite, vous verrez le panneau _Properties_ pour ce nouveau _Rule Set_ avec un bouton _Open_ qui vous amène au _Rule set editor_ afin de construire la logique de décision ; cliquez sur ce bouton.
3.  Une nouvelle interface s'ouvre sur l'onglet _Variables_ du _Rule Set_. Sous _Add variable_, utilisez l'icône dossier pour naviguer vers _My Folder_ et sélectionnez _ShopEase Churn Retention Decision_ que vous avez déjà créé. Sélectionnez les variables **P_churned1** et **risk_tier** puis ajoutez-les au Rule Set : **P_churned1** est utilisée dans la colonne Rule Conditions du tableau ci-dessous, et **risk_tier** a sa propre colonne car elle reçoit des valeurs.
    ![image-20260529182736552](img/README/image-20260529182736552.png)
4.  Pour **P_churned1**, modifiez-la pour qu'elle soit requise en entrée puis cliquez sur l'icône de sauvegarde pour enregistrer ce changement. La variable **risk_tier** n'a pas encore de valeur provenant de la décision, vous pouvez donc la laisser en sortie.
    ![image-20260529182819653](img/README/image-20260529182819653.png)
5.  Allez dans l'onglet _Rule set_ puis cliquez sur le bouton _Add rule_.
    ![image-20260529182844859](img/README/image-20260529182844859.png)
6.  Remplacez l'opérateur par défaut (equal) par greater than puis saisissez la comparaison dans la condition _IF_. Dans l'affectation THEN, choisissez la variable **risk_tier** et saisissez la valeur correspondante entre guillemets simples.
    ![image-20260529182941876](img/README/image-20260529182941876.png)
7.  Cliquez ensuite sur _Add rule_, puis dans la liste déroulante de l'instruction _IF_, passez à une condition _ELSE_. Cela permet de combiner les conditions supplémentaires dans une seule règle. Continuez ensuite à saisir le reste des conditions et affectations comme indiqué ci-dessous. Une fois terminé, cliquez sur l'icône de sauvegarde puis utilisez soit la petite croix _x_ en haut à droite, soit _\*\* ShopEase Churn Retention Decision (1.0)_ dans le fil d'Ariane en haut, pour revenir à la décision.
    ![image-20260529183309136](img/README/image-20260529183309136.png)

| Rule Conditions    | risk_tier |
| ------------------ | --------- |
| P_churned1 >= 0.80 | Critical  |
| P_churned1 >= 0.60 | High      |
| P_churned1 >= 0.40 | Moderate  |
| P_churned1 < 0.40  | Low       |

**Rule Set : Action de rétention**

| risk_tier | subscription_tier  | action                             | offer_value |
| --------- | ------------------ | ---------------------------------- | ----------- |
| Critical  | Basic              | Upgrade offer + personal call      | 50          |
| Critical  | Standard / Premium | Personal call from account manager | 25          |
| High      | Basic              | Targeted email with discount       | 20          |
| High      | Standard / Premium | Re-engagement email sequence       | 10          |
| Moderate  | Any                | Automated engagement nudge         | 0           |
| Low       | Any                | No action (continue monitoring)    | 0           |

**Rule Set : Sélection du canal**

| Rule Conditions                | channel             |
| ------------------------------ | ------------------- |
| days_since_last_purchase > 90  | Phone call          |
| days_since_last_purchase > 60  | Email + SMS         |
| days_since_last_purchase > 30  | Email               |
| days_since_last_purchase <= 30 | In-app notification |

**Rule Set : Attribution de la priorité**

| Rule Conditions                                                      | priority |
| -------------------------------------------------------------------- | -------- |
| risk_tier = 'Critical' AND total_spend > 500                         | Urgent   |
| risk_tier = 'Critical' OR (risk_tier = 'High' AND total_spend > 300) | High     |
| risk_tier = 'High' OR risk_tier = 'Moderate'                         | Normal   |
| risk_tier = 'Low'                                                    | None     |

**Rule Set : Attribution de la raison**

Ces règles capturent le principal facteur qui motive l'action de rétention et alimentent la variable `reason` utilisée en aval par le LLM :

| Rule Conditions                                    | reason                      |
| -------------------------------------------------- | --------------------------- |
| days_since_last_purchase > 90                      | Prolonged inactivity        |
| total_spend < 100 AND P_churned1 >= 0.60           | Low engagement and spend    |
| subscription_tier = 'Basic' AND P_churned1 >= 0.60 | Tier-downgrade risk         |
| avg_session_duration < 60 AND total_sessions < 5   | Weak browsing engagement    |
| Otherwise                                          | Standard retention outreach |

### 4. Ajouter un LLM dans le flux

Nous allons maintenant ajouter un Large Language Model à notre décision. Pour cela, ouvrez le panneau latéral _Objects_ (icône carte postale) et glissez-déposez un nœud Call LLM sur le nœud _End_. Ajoutez ensuite les variables manquantes comme pour le nœud modèle (ne rendez pas le prompt obligatoire en entrée de la décision), puis cliquez sur l'icône de sauvegarde.

![image-20260529183326445](img/README/image-20260529183326445.png)

Vous pouvez maintenant soit ajouter le Rule Set _Prompt Assignment_ à la décision comme les autres Rule Sets, soit le créer vous-même. Si vous choisissez de le créer manuellement, ajoutez les variables suivantes de votre décision en entrée :

- subscription_tier
- total_spend
- risk_tier
- action
- offer_value
- channel
- priority
- reason

Et en sortie, ajoutez la variable prompt (n'oubliez pas de cliquer sur l'icône de sauvegarde). Passez ensuite à l'onglet _Rule set_, cliquez sur le bouton _Add other_, sélectionnez le type de règle _Assignment_ puis cliquez sur _OK_ : ici, nous ne voulons pas définir de condition, mais simplement renseigner notre prompt avec une valeur longue.

![image-20260529183622628](img/README/image-20260529183622628.png)

Ensuite, affectez la valeur du prompt en cliquant sur l'icône crayon. Dans l'_Expression Editor_, supprimez toutes les valeurs de l'éditeur principal puis copiez-collez la valeur ci-dessous. Cliquez sur le bouton _Save_, puis sur l'icône de sauvegarde du _Rule set_, et revenez à la décision principale.

```
prompt = CAT('You are a helpful ShopEase customer retention specialist. Using the customer profile and retention decision data below, write a warm, personalized, and clearly structured long-form outreach message (3 to 5 paragraphs) that a human account manager can review and send through their preferred channel. Do not reference internal codes or jargon verbatim — translate them into plain customer-friendly language. Do not promise outcomes beyond the specified offer, and do not disclose the underlying model score or risk tier to the customer. Customer profile and decision context: Subscription tier: ', subscription_tier, '. Total spend to date: $', total_spend, '. Assigned risk tier: ', risk_tier, '. Recommended action: ',  action, '. Offer value: $', offer_value, '. Outreach channel: ', channel, '. Outreach priority: ', priority, '. Internal reason code: ', reason, '. Structure your response as follows. First, open with a warm, sincere thank-you that acknowledges the customer as a ', subscription_tier, ' member and references their $', total_spend, ' of lifetime spend in a natural, non-transactional way. Second, acknowledge — without explicitly revealing the ', risk_tier, ' risk tier — that ShopEase has noticed it has been a while and that we value their continued relationship. Translate the internal reason ', reason, ' into an empathetic, plain-language acknowledgment of what might have driven the drop in engagement. Third, present the recommended action ', action, ' as a thoughtful offer rather than a retention tactic, explaining the concrete $', offer_value, ' benefit in clear terms (how and when it can be redeemed). Fourth, adapt the tone to the ', channel, ' channel (concise and scannable for email or SMS, warmer and conversational for a phone script) and to the ', priority, ' outreach priority (immediate urgency vs gentle reminder). Fifth, close with a clear, low-friction next step — a single link, a reply, or a brief call — and invite the customer to share feedback about their recent experience. Tone: warm, appreciative, human, and never guilt-tripping or salesy. Length: 250 to 400 words. Write in the second person (you, your account). Translate the answer in French.')
```

Il s'agit d'une approche très simplifiée du prompt engineering et elle ne vous permet pas de tester et comparer différents grands modèles de langage. C'est pourquoi SAS propose le projet open source [SAS Agentic AI Accelerator](https://github.com/sassoftware/sas-agentic-ai-accelerator), qui permet de connecter n'importe quel LLM et de faire du prompt engineering ainsi que du monitoring avancés. Ici, nous disposons d'un LLM codé en dur (OpenAI GPT 5.4).

### 5. Tester la décision

1. Dans la décision, cliquez sur l'onglet _Scoring_ puis sur le sous-onglet _Scenarios_

2. Cliquez sur le bouton _New test_
   ![image-20260529183957319](img/README/image-20260529183957319.png)

3. Saisissez des valeurs d'exemple :
    - account_age_days: 294
    - age: 23
    - avg_session_duration: 45
    - customer_id: C501
    - customer_tenure_days: 500
    - days_since_last_purchase: 75
    - email_opt_in: 1
    - gender_F: False
    - high_priority_tickets: 3
    - max_order_value: 123
    - max_resolution_time: 6
    - min_order_value: 7
    - std_order_value: 54
    - subscription_tier: Basic
    - tier_Basic: True
    - total_sessions: 8
    - total_spend: 250
    - unique_categories: 1

    ![image-20260529184621969](img/README/image-20260529184621969.png)

4. Consultez la sortie en cliquant sur l'icône Results une fois que le _Status_ est passé à une coche verte
   ![image-20260529184658915](img/README/image-20260529184658915.png)

5. N'hésitez pas à tester d'autres scénarios pour valider la logique :
    - Un client fortement engagé (faible probabilité d'attrition, dépenses élevées, activité récente) doit être classé en Low risk sans action
    - Un client borderline doit recevoir une relance d'engagement automatisée
    - Un client Basic en risque Critical doit être signalé pour un appel personnalisé avec priorité Urgent

### 6. Publier la décision

1. Cliquez sur le bouton **Validate** puis sur **Publish** pour rendre la décision disponible en tant que service appelable
2. Choisissez une **destination :**
    - **CAS** — pour une exécution batch sur l'ensemble de votre base clients
    - **MAS (Micro Analytic Service)** — pour des appels API temps réel à faible latence - un seul est disponible ici
    - **Container** — pour un déploiement dans des systèmes externes
3. Assurez-vous de lui donner un nom unique
4. Une fois publiée, la décision est disponible via un endpoint API REST

---

## Utiliser le Copilot de SAS Intelligent Decisioning

Le Copilot de SAS Intelligent Decisioning est un assistant conversationnel capable de répondre à des questions sur la documentation de **SAS Intelligent Decisioning**, **SAS Container Runtime** et **SAS Micro Analytic Service**. Utilisez-le pour trouver rapidement des informations sur le fonctionnement de ces produits sans quitter l'application.

### Ce que le Copilot peut faire

- **Répondre à des questions de documentation** sur les fonctionnalités, concepts et workflows de SAS Intelligent Decisioning
- **Expliquer SAS Micro Analytic Service (MAS)**, ses options de déploiement, sa configuration et l'usage de ses API
- **Clarifier SAS Container Runtime** concernant la mise en place, la publication et la gestion
- **Vous aider à naviguer** dans les capacités du produit en décrivant le fonctionnement des fonctionnalités spécifiques
- **Fournir des conseils** sur les concepts de flux de décision, la configuration des rule sets et les options de publication basés sur la documentation officielle

### Exemples de prompts Copilot

- _"How do I publish a decision to MAS?"_
- _"What is the difference between CAS and MAS as publishing destinations?"_
- _"How does SAS Container Runtime work for deploying decisions?"_
- _"What types of nodes can I add to a decision flow?"_
- _"How do I configure input and output variables for a decision?"_
- _"What are rule sets and how do I create them?"_

Le Copilot est un outil de référence utile pour obtenir rapidement des réponses sur les capacités de la plateforme pendant que vous construisez vos flux de décision.

---

## Les décisions comme outils dans des workflows agentiques

Une décision SAS Intelligent Decisioning publiée est exposée via un **endpoint API REST**. Cela signifie qu'elle peut être appelée comme un **outil** par n'importe quel agent IA, y compris les agents basés sur des grands modèles de langage (LLM) qui utilisent des capacités d'appel d'outils.

### Comment cela fonctionne

```
┌──────────────┐       ┌────────────────────────────┐      ┌──────────────────┐
│   AI Agent   │─────▶│  SAS Intelligent            │────▶│  Retention       │
│  (e.g. LLM)  │       │  Decisioning API           │      │  Action          │
│              │◀─────│  /decisions/churnRetention  │◀────│  Recommendation  │
└──────────────┘       └────────────────────────────┘      └──────────────────┘
```

**Exemple de scénario :** Un agent de service client (piloté par un LLM) échange avec un client qui semble frustré. L'agent peut :

1. Rechercher le profil du client
2. **Appeler l'API SAS Intelligent Decisioning** avec les données du client
3. Recevoir en retour : "Critical risk — offer $50 credit + personal follow-up"
4. Adapter sa réponse en conséquence, en proposant de manière proactive l'incitation de rétention

La décision devient un **outil** dans la boîte à outils de l'agent, comme une fonction de recherche ou une requête base de données. Cela crée un pont entre les modèles analytiques et l'IA conversationnelle.

### Pourquoi c'est important

- **Cohérence :** Chaque interaction d'agent utilise la même logique de décision ; les règles et scores de modèle sont centralisés, pas codés en dur dans des prompts
- **Gouvernance :** La décision est versionnée et auditable dans SAS Intelligent Decisioning, au lieu d'être enfouie dans le prompt système d'un LLM
- **Séparation des responsabilités :** Les data scientists pilotent le modèle, les analystes métier pilotent les règles, et l'agent IA se contente d'appeler l'endpoint
- **Exécution en temps réel :** Les endpoints MAS répondent en millisecondes, suffisamment vite pour un usage conversationnel

---

## Les décisions comme workflows agentiques

Au-delà de leur rôle d'outils appelables, SAS Intelligent Decisioning peut lui-même orchestrer des **workflows agentiques** : des processus en plusieurs étapes qui exécutent de façon autonome une chaîne de décisions et d'actions.

### Comment une décision devient un agent

Un flux de décision agentique va au-delà d'un simple "entrée → règles → sortie". Il peut :

1. **Observer :** Recevoir un événement déclencheur (par ex. un client ne s'est pas connecté depuis 30 jours)
2. **Raisonner :** Scorer le risque d'attrition du client, vérifier son segment, revoir son historique d'interactions
3. **Décider :** Sélectionner l'action de rétention optimale à partir des rule sets
4. **Agir :** Déclencher des actions aval : envoyer un e-mail, créer une tâche CRM, planifier un rappel, ajuster une campagne publicitaire
5. **Surveiller :** Suivre si le client se réengage et réinjecter ce résultat dans les décisions futures

### Exemple : agent automatisé de prévention de l'attrition

```
┌─────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  Event       │     │  Decision Flow   │     │  Actions         │
│  Trigger     │────▶│                  │────▶│                  │
│              │     │  1. Score model   │     │  • Send email    │
│  "Customer   │     │  2. Apply rules   │     │  • Create CRM    │
│   inactive   │     │  3. Select action │     │    task          │
│   30 days"   │     │  4. Choose channel│     │  • Schedule call │
│              │     │  5. Set priority   │     │  • Adjust offer  │
└─────────────┘     └──────────────────┘     └──────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Feedback Loop   │
                    │                  │
                    │  Did customer    │
                    │  re-engage?      │
                    │  Update model.   │
                    └──────────────────┘
```

C'est **agentique** parce que le système, de manière autonome :

- Détecte la condition de déclenchement
- Prend des décisions sans intervention humaine
- Exécute des actions dans le monde réel
- Apprend à partir des résultats

### Passage à l'échelle de la décision agentique

En environnement de production, ce workflow agentique peut traiter **des milliers de clients par jour** sans intervention manuelle :

- **Mode batch :** Chaque lundi, scorer plus de 1 000 clients, identifier ceux à risque, puis déclencher les actions
- **Mode événementiel :** Dès que l'inactivité d'un client dépasse un seuil, déclencher le flux en temps réel
- **Chaînage multi-décisions :** Un flux de décision en appelle un autre, par ex. la décision d'attrition appelle une décision "next best offer" qui appelle ensuite une décision "channel optimization"

SAS Intelligent Decisioning fournit la couche d'orchestration qui transforme des modèles et règles individuels en **agents autonomes à l'échelle de l'entreprise**.

---

## Résumé

Dans cette étape, vous avez :

1. **Créé un flux de décision** qui combine votre modèle d'attrition avec des règles métier pour produire des recommandations de rétention actionnables
2. **Ajouté un appel LLM** qui transforme la décision en message de relance client personnalisé et chaleureux
3. **Utilisé le Copilot** pour obtenir des réponses sur la documentation SAS Intelligent Decisioning, MAS et Container Runtime
4. **Publié la décision** en tant qu'endpoint API appelable
5. **Compris comment les décisions servent d'outils** pour des agents pilotés par LLM
6. **Exploré des workflows agentiques** où les décisions détectent, raisonnent, décident et agissent de façon autonome

---

## Félicitations !

Vous avez terminé l'ensemble du cycle de vie Data & IA pour le cas d'usage d'attrition client ShopEase :

| Étape           | Ce que vous avez fait                                         | Technologie SAS                       |
| --------------- | ------------------------------------------------------------- | ------------------------------------- |
| 1. Ask & Access | Compréhension du problème, génération de données synthétiques | SAS Data Maker                        |
| 2. Prepare      | Chargement, profilage et jointure des données dans un ABT     | SAS Viya Workbench                    |
| 3. Explore      | Exploration visuelle des schémas avec assistance IA           | SAS Visual Analytics + Copilot        |
| 4. Model        | Construction, comparaison et test d'équité des modèles        | SAS Model Studio + Copilot            |
| 5. Deploy & Act | Opérationnalisation via des décisions automatisées            | SAS Intelligent Decisioning + Copilot |

S'il vous reste du temps, explorez un autre cas d'usage ou approfondissez n'importe quelle étape. Échangez avec votre mentor bootcamp pour des sujets de suivi ou pour partager vos retours.
