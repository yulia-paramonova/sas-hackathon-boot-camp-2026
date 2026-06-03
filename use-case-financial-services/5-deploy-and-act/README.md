# Étape 5 : Déployer & Agir

Dans cette dernière étape, vous utiliserez **SAS Intelligent Decisioning** pour opérationnaliser votre modèle de prédiction de défaut de prêt en l’intégrant dans un flux décisionnel automatisé d’approbation de prêt. Vous explorerez également son **Copilot** et apprendrez comment les décisions peuvent fonctionner comme des **outils dans des workflows agentiques** — ou devenir elles-mêmes des workflows agentiques.

---

## Prérequis

Votre modèle champion doit être enregistré dans **SAS Model Manager** depuis l’étape 4. SAS Intelligent Decisioning récupérera directement le modèle à partir du registre Model Manager. Si vous n’avez pas enregistré le vôtre, ne vous inquiétez pas : un modèle par défaut est fourni.

---

## Qu’est-ce que SAS Intelligent Decisioning ?

SAS Intelligent Decisioning est une plateforme permettant de créer, gérer et exécuter des décisions métier qui combinent des modèles analytiques, des règles métier et une logique contextuelle dans un seul flux de décision. Au lieu de simplement scorer une demande de prêt avec un modèle, un flux décisionnel peut :

- Évaluer la probabilité de défaut de la demande
- La classer dans une catégorie de risque
- Appliquer des règles métier (ex : « ne jamais approuver si LTV > 95 % »)
- Déterminer l’action appropriée (approuver, examiner, refuser)
- Générer des codes de motifs de refus
- Retourner une recommandation complète de prêt

Cela transforme une prédiction de modèle en une **décision de prêt exploitable**.

Si vous avez des questions sur SAS Intelligent Decisioning, activez le Copilot SAS Viya dans l’application via l’icône en haut à droite, ou adressez-vous à un mentor SAS sur place.

---


## Création d’une décision d’approbation de prêt

### 1. Ouvrir SAS Intelligent Decisioning

1. Depuis le menu principal de SAS Viya, accédez à **SAS Intelligent Decisioning** (section *Build Decisions*)

2. Cliquez sur **New Decision**

3. Nommez-la : *PremierBank Loan Approval Decision*

4. Laissez Description, Emplacement et Workflow par défaut, puis cliquez sur OK

    ![image-20260529080155689](img/README/image-20260529080155689.png)

5. Allez dans l’onglet *Variables*, cliquez sur *Add variable* puis choisissez *Custom variable* pour les saisir manuellement *(étape 1 et 2)* ou *Decision* pour les copier depuis un modèle (plus rapide) *(étape 3)*. 

    ![image-20260529080338969](img/README/image-20260529080338969.png)
    
    1. Définissez les **variables d'entrée** (celles-ci seront transmises lorsque la décision sera prise) - La structure est: `nom` (type de donnée):
        1. `loan_id` (charactère)
        2. `credit_score` (décimal)
        3. `debt_to_income` (décimal)
        4. `loan_to_value` (décimal)
        5. `annual_income` (décimal)
        6. `income_verified` (décimal)
        7. `loan_amount` (décimal)
        
    2. Définissez les **variables de sortie** (celles-ci seront renvoyées par la décision)  - La structure est: `nom` (type de donnée) - Explication (juste pour nous pour le context):
        1. `decision` (charactère) - Approuver, Examiner, or Refuser
        2. `risk_tier` (charactère) - classification du risque
        3. `conditions` (charactère) - conditions associés
        4. `reason` (charactère) - motif de refus
        5. `rate_adjustment` (décimal) - ajustement du taux
        6. Cliquez OK pour ajouter toutes les variables
        
        ![image-20260529080742531](img/README/image-20260529080742531.png)
        
    3. Copiez les **variables** depuis un template de décision:
        1. Cliquez sur le fichier *Decision* 
        2. Naviguez vers *SAS Content > SAS Hackathon Bootcamp 2026 > Use Case Financial Services* sélectionnez *PremierBank Loan Approval Decision* et cliquez sur OK
        3. Cliquez sur *Add all* au milieu du dialogue pour impoter toutes les varibales dans votre décision puis appuyez sur le boutton *Add*

Une fois les variables ajoutées, pensez à cliquer sur l'icon *enregistrer* en haut à droite. Il est recommandé que vous enregistriez votre fichier dès que vous changez quelque chose en lien avec des variables.

Vous pouvez également activer le Copilot SAS Viya à travers l'icon en haut à droite pour poser des questions sur SAS Intelligent Decisioning pour approfondir votre compréhension de l'application.

### 2. Ajoutez le nœud Modèle

1. Passez à l’onglet *Decision Flow*.
2. Dans le canvas de flux de décision, vous pouvez soit faire un clic droit sur le nœud *Star*t et dans le menu contextuel sélectionner *Add below > Model*, soit sur le côté droit cliquer sur l’icône qui ressemble un peu à une carte postale et depuis cette barre latérale glisser-déposer un nœud modèle sur le nœud *Start*.
    ![image-20260529081910125](img/README/image-20260529081910125.png)
3. Sélectionnez votre modèle champion enregistré depuis SAS Model Manager ou le modèle champion pré‑enregistré en naviguant vers *DM Repository > PremierBank Loan Default Prediction > Version 1 > Gradient Boosting (1) (SAS Automatically Generated Pipeline* puis cliquez sur OK.
    ![image-20260529082551202](img/README/image-20260529082551202.png)
4. Après cela, vous verrez une petite icône d’erreur rouge à côté du modèle, et cela est dû au fait qu’il manque des variables d’entrée et de sortie — nous allons corriger cela dans les étapes suivantes.
5. Associez les variables d’entrée aux caractéristiques attendues du modèle :
    1. Pour les entrées, `income_verified` et `loan_id` devraient être associés automatiquement.
        ![image-20260529093617886](img/README/image-20260529093617886.png)
    2. Pour les sorties, nous allons cliquer sur le menu *More* en haut puis sélectionner *Add missing variables*. Cela ajoutera toutes les variables de sortie requises à notre décision — si vous avez copié les variables en utilisant le modèle, elles sont déjà présentes — dans la boîte de dialogue, assurez‑vous de les désélectionner de la sortie car nous allons créer nos propres sorties personnalisées — et comme nous avons modifié quelque chose concernant les variables, n’oubliez pas de cliquer sur l’icône de sauvegarde (il vous sera demandé de supprimer les variables non utilisées, sélectionnez simplement non, car nous les utiliserons dans les étapes suivantes).
        ![image-20260529082952817](img/README/image-20260529082952817.png)


### 3.  Ajouter des règles métier
Après que le modèle ait évalué la demande, ajoutez des nœuds **Rule Set** pour déterminer la décision de prêt. Pour cela, assurez‑vous d’abord d’avoir cliqué sur l’icône de sauvegarde de votre décision, puis nous ajouterons des Rule Sets à notre décision.

Il existe deux façons d’ajouter des **Rule Sets** à la décision :

1. _La méthode simple_, où vous utilisez les rule sets préconstruits en cliquant sur les trois points verticaux du nœud modèle puis en sélectionnant _Add > Rule Set_, ensuite dans la boîte de dialogue allez dans _SAS Content > SAS Hackathon Bootcamp 2026 > Use Case Financial Services_ et ajoutez le rule set comme indiqué ci-dessous.
2.    _La méthode pédagogique_, si vous voulez les créer vous-même, vous pouvez cliquer à droite sur _Objects_ (icône carte postale) puis glisser-déposer un Rule Set sur le nœud précédent. Cela ouvre une boîte de dialogue où vous devez nommer votre décision en conséquence ; laissez l'emplacement par défaut (_My Folder_), puis ajoutez les variables de la décision créée et commencez à construire les Rule Sets comme décrit ci-dessous. Les variables requises sont indiquées soit dans les colonnes, soit dans **Rule Conditions**. Le premier rule set à construire inclut des notes et des captures d'écran pour vous guider.

Nous vous recommandons d'essayer de construire au moins un de ces rule sets vous-même pour comprendre la démarche. Si vous avez des questions sur SAS Intelligent Decisioning, activez le copilot SAS Viya dans l'application via l'icône en haut à droite à côté de votre profil, ou demandez à l'un des mentors SAS présents sur site.

**Rule Set: Classification du niveau de risque**

1.   Depuis le panneau latéral _Objects_, glissez-déposez un nœud _Rule Set_ sur le nœud _Model_ déjà présent dans votre décision. Saisissez ensuite le nom ci-dessus et cliquez sur _Save_.
     ![image-20260529084455924](img/README/image-20260529084455924.png)

2.   Sur la droite, vous verrez le panneau _Properties_ pour ce nouveau _Rule Set_ avec un bouton _Open_ qui vous amène au _Rule set editor_ afin de construire la logique de décision ; cliquez sur ce bouton.

3.   Une nouvelle interface s'ouvre sur l'onglet _Variables_ du _Rule Set_. Sous _Add variable_, utilisez l'icône dossier pour naviguer vers _My Folder_ et sélectionnez *PremierBank Loan Approval Decision* que vous avez déjà créé. Sélectionnez les variables **P_defaulted1** & **risk_tier** puis ajoutez-les au Rule Set : - the **P_defaulted1** est utilisée dans la colonne Rule Conditions du tableau ci-dessous, et **risk_tier** a sa propre colonne car elle reçoit des valeurs.

     ![image-20260529085521013](img/README/image-20260529085521013.png)

4.   Pour **P_defaulted1**, modifiez-la pour qu'elle soit requise en entrée puis cliquez sur l'icône de sauvegarde pour enregistrer ce changement. La variable **risk_tier** n'a pas encore de valeur provenant de la décision, vous pouvez donc la laisser en sortie.
     ![image-20260529085655407](img/README/image-20260529085655407.png)

5.   Allez dans l'onglet _Rule set_ puis cliquez sur le bouton _Add rule_.
     ![image-20260529085113436](img/README/image-20260529085113436.png)

6.   Remplacez l'opérateur par défaut (égal) par plus grand que *greater than* puis saisissez la comparaison dans la condition _IF_. Dans l'affectation THEN, choisissez la variable **risk_tier** et saisissez la valeur correspondante entre guillemets simples. 
     ![image-20260529085835981](img/README/image-20260529085835981.png)

7. Cliquez ensuite sur _Add rule_, puis dans la liste déroulante de l'instruction _IF_, passez à une condition _ELSE_. Cela permet de combiner les conditions supplémentaires dans une seule règle. Continuez ensuite à saisir le reste des conditions et affectations comme indiqué ci-dessous. Une fois terminé, cliquez sur l'icône de sauvegarde puis utilisez soit la petite croix _x_ en haut à droite, soit *** PremierBank Loan Approval Decision (1.0)* dans le fil d'Ariane en haut, pour revenir à la décision.
     ![image-20260529090304262](img/README/image-20260529090304262.png)

| Rule Conditions | risk_tier |
|-----------|-----------|
| P_defaulted1 >= 0.40 | Très élevé |
| P_defaulted1 >= 0.25 | Élevé  |
| P_defaulted1 >= 0.15 | Modéré |
| P_defaulted1 >= 0.08 | Faible |
| P_defaulted1 < 0.08 | Très faible |

**Rule Set: Décision de prêt**

| risk_tier | credit_score | décision | conditions |
|-----------|-------------|----------|------------|
| Très élevé | Tous | Refuser | Codes de refus |
| Élevé | < 620 | Refuser | Codes de refus |
| Élevé | >= 620 | Examiner | Revue manuelle |
| Modéré | Tous | Examiner | Vérifier revenus |
| Faible | Tous | Approuver | Conditions standard |
| Très faible | Tous | Approuver | Taux préférentiel |


**Rule Set: Ajustement du taux (Risk-Based Pricing)**

La période pour le *rate_adjustment* où le *risk_tier_ est *Très élevé* indique la présence de valeurs manquauntes.

| risk_tier | rate_adjustment |
|-----------|-----------------------|
| Très élevé | . |
| Élevé | 200 |
| Modéré | 100 |
| Faible | 0 |
| Très faible | -25 |


**Rule Set: Règles de coupure stricte**

Ces règles prévalent sur la décision basée sur le modèle, quel que soit le score :

|Condition | Décision | Motif |
|----------|----------|-------|
| loan_to_value > 0.95 | Refuser | Fonds propres insuffisants |
| debt_to_income > 0.50 | Refuser | Endettement excessif |
| credit_score < 500 | Refuser | Score trop faible |
| loan_amount < 10 × revenu | Refuser |Prêt dépasse le multiple du revenu |

### 4. Ajouter un LLM

Nous allons maintenant ajouter un Large Language Model à notre décision. Pour cela, ouvrez le panneau latéral _Objects_ (icône carte postale) et glissez-déposez un nœud Call LLM sur le nœud _End_. Ajoutez ensuite les variables manquantes comme pour le nœud modèle (ne rendez pas le prompt obligatoire en entrée de la décision), puis cliquez sur l'icône de sauvegarde.

![image-20260529093914801](img/README/image-20260529093914801.png)

Vous pouvez maintenant soit ajouter le Rule Set _Prompt Assignment_ à la décision comme les autres Rule Sets, soit le créer vous-même. Si vous choisissez de le créer manuellement, ajoutez les variables suivantes de votre décision en entrée :

-   annual_income
-   conditions
-   credit_score
-   decision
-   reason
-   risk_tier
-   
Et en sortie, ajoutez la variable prompt (n'oubliez pas de cliquer sur l'icône de sauvegarde). Passez ensuite à l'onglet _Rule set_, cliquez sur le bouton _Add other_, sélectionnez le type de règle _Assignment_ puis cliquez sur _OK_ : ici, nous ne voulons pas définir de condition, mais simplement renseigner notre prompt avec une valeur longue.

![image-20260529095501952](img/README/image-20260529095501952.png)

Ensuite, affectez la valeur du prompt en cliquant sur l'icône crayon. Dans l'_Expression Editor_, supprimez toutes les valeurs de l'éditeur principal puis copiez-collez la valeur ci-dessous. Cliquez sur le bouton _Save_, puis sur l'icône de sauvegarde du _Rule set_, et revenez à la décision principale.


```
prompt = CAT('You are a professional PremierBank loan advisor. Using the loan application data below, write a warm, respectful, and clearly structured long-form explanation (3 to 5 paragraphs) that an applicant with no financial background can read to understand the outcome of their application and what it means for them. Do not expose internal codes or jargon verbatim — translate them into plain consumer-friendly language. Do not promise that the decision can be overturned, and do not provide legal or regulatory advice. Application and decision context: Annual income: $', annual_income, '. Credit score: ', credit_score, '. Assigned risk tier: ', risk_tier, '. Final decision: ', decision, '. Internal reason code: ', reason, '. Conditions attached to this decision: ', conditions, '. Structure your response as follows. First, open with a personal respectful acknowledgment that PremierBank has reached a decision of ', decision, ' on the application, and thank the applicant for choosing PremierBank Second, explain in plain language what a risk tier of ', risk_tier, ' means in the context of a credit score of ', credit_score, ' and a reported annual income of $', annual_income, '. Describe how these two indicators, combined with the overall profile, shape how PremierBank assesses repayment capacity. Third, expand the internal reason ', reason, ' into a clear, empathetic explanation of why the decision came out the way it did. Avoid financial jargon — translate terms such as debt-to-income, loan-to-value, or adverse action codes into everyday language. Fourth, describe the conditions attached to this decision — ', conditions, ' — and explain exactly what the applicant needs to do (documents to provide, verifications to complete underwriter steps) for those conditions to be satisfied. If no conditions apply, briefly say so. Fifth, close with constructive, forward-looking next steps tailored to the decision ', decision, '. If declined, suggest 2 to 3 concrete, realistic actions the applicant can take over the next 6 to 12 months to strengthen a future application (for example, improving credit score, reducing debt obligations, or increasing documented income). If approved or sent to review, outline what the applicant should expect next and how they will be contacted. Tone: warm, professional, encouraging, and never condescending Length: 350 to 500 words. Write in the second person (you, your application).')
```

![image-20260529100009632](img/README/image-20260529100009632.png)

Il s'agit d'une approche très simplifiée du prompt engineering et elle ne vous permet pas de tester et comparer différents grands modèles de langage. C'est pourquoi SAS propose le projet open source [SAS Agentic AI Accelerator](https://github.com/sassoftware/sas-agentic-ai-accelerator), qui permet de connecter n'importe quel LLM et de faire du prompt engineering ainsi que du monitoring avancés. Ici, nous disposons d'un LLM codé en dur (OpenAI GPT 5.4).

### 5. Tester la décision

1. Dans la décision, cliquez sur l'onglet _Scoring_ puis sur le sous-onglet _Scenarios_

2. Cliquez sur le bouton _New test_
    ![image-20260529094624231](img/README/image-20260529094624231.png)

3. Dans la fenêtre *New Scenario* laissez le nom par défualt, choisissez *My folder* comme emplacement et l'emplacement de a table dans votre *CASUSER*.

4. Saisissez des valeurs d'exemple :

   - annual_income: 55000
   - credit_score: 610
   - debt_to_income: 0.42
   - income_verified: 1
   - loan_amount: 180000
   - loan_id: L0042
   - loan_to_value: 0.85

   ![image-20260529094455401](img/README/image-20260529094455401.png)

5. Consultez la sortie en cliquant sur l'icône Results une fois que le _Status_ est passé à une coche verte
    ![image-20260529101227029](img/README/image-20260529101227029.png)

6.  N'hésitez pas à tester d'autres scénarios pour valider la logique :
- Un candidat solide (score élevé, DTI faible, LTV faible) devrait être approuvé au taux préférentiel.
- Un candidat limite devrait être soumis à un examen approfondi.
- Un candidat à haut risque devrait être refusé avec des motifs clairs.

### 6. Publish the Decision

1. Click the **Validate** button and then **Publish** to make the decision available as a callable service
2. Choose a **destination:**
   - **CAS** — for batch scoring of the entire loan portfolio
   - **MAS (Micro Analytic Service)** — for real-time API calls during the loan application process - only one available here!
   - **Container** — for deployment in the bank's loan origination system
3. Please make sure to give it a unique name
3. Once published, the decision is available as a REST API endpoint

---

## Using the SAS Intelligent Decisioning Copilot

The Copilot in SAS Intelligent Decisioning is a conversational assistant that can answer questions about the documentation for **SAS Intelligent Decisioning**, **SAS Container Runtime**, and **SAS Micro Analytic Service**. Use it to quickly find information about how these products work without leaving the application.

### What the Copilot Can Do

- **Answer documentation questions** about SAS Intelligent Decisioning features, concepts, and workflows
- **Explain SAS Micro Analytic Service (MAS)** deployment options, configuration, and API usage
- **Clarify SAS Container Runtime** setup, publishing, and management
- **Help you navigate** product capabilities by describing how specific features work
- **Provide guidance** on decision flow concepts, rule set configuration, and publishing options based on the official documentation

### Example Copilot Prompts

- *"How do I publish a decision to MAS?"*
- *"What is the difference between CAS and MAS as publishing destinations?"*
- *"How does SAS Container Runtime work for deploying decisions?"*
- *"What types of nodes can I add to a decision flow?"*
- *"How do I configure input and output variables for a decision?"*
- *"What are the options for generating adverse action codes in a decision flow?"*

The Copilot is a useful reference tool for quickly getting answers about the platform's capabilities while you are building your decision flows.

---

## Decisions as Tools in Agentic Workflows

A published SAS Intelligent Decisioning decision is exposed as a **REST API endpoint**. This means it can be called as a **tool** by any AI agent — including large language model (LLM) agents that use tool-calling capabilities.

### How This Works

```
┌──────────────┐     ┌─────────────────────────┐     ┌──────────────────┐
│   AI Agent   │────>│  SAS Intelligent         │────>│  Lending         │
│  (Loan       │     │  Decisioning API         │     │  Decision        │
│   Officer    │     │  /decisions/loanApproval  │     │  + Adverse       │
│   Agent)     │<────│                          │<────│  Action Codes    │
└──────────────┘     └─────────────────────────┘     └──────────────────┘
```

**Example scenario:** A loan officer agent (powered by an LLM) is assisting an applicant through the digital application process. The agent can:

1. Collect the applicant's information through a conversational interface
2. **Call the SAS Intelligent Decisioning API** with the application data
3. Receive back: "Decline — AA01: Credit score too low; AA03: History of late payments"
4. Communicate the decision to the applicant with the required adverse action notice
5. If the decision is "Review," escalate to a human underwriter with the full risk assessment

The decision becomes a **tool** in the agent's toolkit, just like a document retrieval function or a customer lookup. This bridges the gap between analytical models and conversational AI in a heavily regulated industry.

### Why This Matters for Financial Services

- **Consistency:** Every application receives the same decision logic — no variance between loan officers or branches
- **Governance:** The decision is version-controlled and auditable in SAS Intelligent Decisioning, not buried in an LLM's system prompt
- **Regulatory compliance:** The decision flow enforces adverse action notice generation, hard cutoff rules, and fairness guardrails — the LLM agent cannot override these
- **Separation of concerns:** Data scientists own the model, credit risk owns the rules, compliance owns the fairness constraints, and the AI agent just calls the endpoint
- **Real-time execution:** MAS endpoints return in milliseconds, fast enough for real-time application processing

---

## Decisions as Agentic Workflows

Beyond being called as tools, SAS Intelligent Decisioning can itself orchestrate **agentic workflows** — multi-step processes that autonomously execute a chain of decisions and actions.

### How a Decision Becomes an Agent

An agentic decision flow goes beyond simple "input -> rules -> output." It can:

1. **Observe:** Receive a trigger event (e.g., a borrower has missed their second consecutive payment)
2. **Reason:** Score the borrower's updated default probability, check their current risk tier, review their payment history trend
3. **Decide:** Select the optimal intervention — modify terms, offer forbearance, escalate to collections, or continue monitoring
4. **Act:** Trigger downstream actions — send a letter, create a workout case, adjust the loan's risk rating, notify the loan officer
5. **Monitor:** Track whether the borrower resumes payments and feed that outcome back into future decisions

### Example: Automated Portfolio Monitoring Agent

```
┌─────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  Event       │     │  Decision Flow   │     │  Actions         │
│  Trigger     │────>│                  │────>│                  │
│              │     │  1. Score model   │     │  • Send notice   │
│  "Borrower   │     │  2. Apply rules   │     │  • Modify terms  │
│   missed     │     │  3. Select action │     │  • Create case   │
│   payment"   │     │  4. Set priority  │     │  • Update rating │
│              │     │  5. Generate codes │     │  • Alert officer │
└─────────────┘     └──────────────────┘     └──────────────────┘
                              │
                              v
                    ┌──────────────────┐
                    │  Feedback Loop   │
                    │                  │
                    │  Did borrower    │
                    │  resume payments?│
                    │  Update model.   │
                    └──────────────────┘
```

This is **agentic** because the system autonomously:
- Detects the trigger condition (missed payment event)
- Makes decisions without human intervention
- Executes real-world actions (notices, case creation, rating changes)
- Learns from outcomes (did the intervention work?)

### Scaling Agentic Decisioning

In a production environment, this agentic workflow can process **thousands of loans per day** without manual intervention:

- **Batch mode:** Every week, re-score the entire loan portfolio, identify deteriorating loans, trigger interventions
- **Event-driven mode:** As soon as a payment is missed or a credit bureau alert fires, trigger the flow in real time
- **Multi-decision chaining:** One decision flow calls another — e.g., the default risk decision calls a "loss mitigation strategy" decision which calls a "channel and timing optimization" decision
- **Regulatory reporting:** Automatically generate the data needed for Call Report filings, CECL calculations, and fair lending reports

SAS Intelligent Decisioning provides the orchestration layer that turns individual models and rules into **enterprise-scale autonomous agents** — while maintaining the governance, auditability, and compliance controls that financial services demands.

---

## Summary

In this step you have:

1. **Created a loan approval decision flow** that combines your default model with underwriting rules to produce actionable lending decisions
2. **Implemented adverse action notice generation** to comply with FCRA/ECOA requirements
3. **Used the Copilot** to get answers about SAS Intelligent Decisioning, MAS, and Container Runtime documentation
4. **Published the decision** as a callable API endpoint
5. **Learned how decisions work as tools** for LLM-powered loan officer agents
6. **Explored agentic workflows** where decisions autonomously monitor the portfolio, detect risk, and trigger interventions

---

## Congratulations!

You have completed the full Data and AI Life Cycle for the PremierBank loan default use case:

| Step | What You Did | SAS Technology |
|------|-------------|---------------|
| 1. Ask & Access | Understood the problem, generated synthetic data | SAS Data Maker |
| 2. Prepare | Loaded, profiled, and joined data into an ABT | SAS Viya Workbench |
| 3. Explore | Visually explored patterns with AI assistance | SAS Visual Analytics + Copilot |
| 4. Model | Built, compared, and fairness-tested models | SAS Model Studio + Copilot |
| 5. Deploy & Act | Operationalized with automated lending decisions | SAS Intelligent Decisioning + Copilot |

If you have time remaining, explore another use case or dive deeper into any step. Talk to your bootcamp mentor for follow-up topics or to share feedback.
