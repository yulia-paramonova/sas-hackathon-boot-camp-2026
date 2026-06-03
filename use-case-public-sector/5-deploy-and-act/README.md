# Étape 5: Deploy & Act

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

### 2. Add the Model Node

1. Switch to the *Decision Flow* tab.
2. In the decision flow canvas, you can either right click the *Start* node and from the context menu select *Add below > Model* or on the right hand side click on the icon that looks a little bit like a postcard and from that side bar drag & drop a model node onto the *Start* node.
    ![image-20260529173330775](img/README/image-20260529173330775.png)
3. Select your registered champion model from SAS Model Manager or the pre-registered champion model by navigating to *DM Repository > Metro City Service Request Urgency Prediction_1 > Version 1 > Gradient Boosting (SAS Automatically Generated Pipeline* and click OK.
    ![image-20260529173444298](img/README/image-20260529173444298.png)
4. Upon doing this you will see a little red error icon next to the model and that is because it is missing variable inputs and outputs - we will address this in the next steps.
5. There are a lot of variables missing for the model to run. We are going to be clicking the *More* menu up top and select *Add missing variables* this will add all of the required output variables to our decision - if you copied the variables using the template they are already present - in the dialogue please make sure to deselect them from the Output as we will create our own custom outputs. The Inputs should be left in place.
    ![image-20260529173747543](img/README/image-20260529173747543.png)


### 3. Add Business Rules

After the model scores the application, add **Rule Set** nodes to determine the lending decision. For this make first sure that you have clicked the save icon of your decision and than we will be adding Rule Sets to our decision.

There are two ways of adding **Rule Sets** to the decision:

1.    *The easy way*, where you use the pre build rule sets by clicking on the three vertical dots on the model node and selecting *Add > Rule Set*, then in the dialogue navigate to *SAS Content > SAS Hackathon Bootcamp 2026 > Use Case Public Sector* and add the rule set as specified below.
2.    *The learning way*, if you want to create them yourself you can go to the right hand side click on the *Objects* (postcard icon) and drag & drop a Rule Set onto the previous node. This will open up a dialogue where you should name your decision correspondingly, please leave the location as the default (*My Folder*) - then add the variables from the decision you created and start building the Rule Sets as described below - the required variables are noted either as the columns or in the **Rule Conditions**. The first rule set we will be building has notes and screenshots attached on how to do this.

We recommend you try to build at least one of these rule sets yourself to get an understanding of how it is done. If you have any questions around SAS Intelligent Decisioning activate the SAS Viya copilot within the application via the icon in the top right hand corner next to your profile or ask one of the onsite SAS Mentors.

**Rule Set: Urgency Tier Classification**

1.   From the *Objects* side panel drag and drop a *Rule Set* node onto the *Model* node you already have in your decision. Then enter the name from above and click *Save*
     ![image-20260529174004365](img/README/image-20260529174004365.png)
2.   Now on the right hand side you will see the *Properties* pane for this new *Rule Set* and there is a button *Open* that will take you to the *Rule set editor* so that you can build the decision so click on that button.
3.   A new UI opened up for you on the *Variables* tab for the *Rule Set*, under *Add variable* select, via the folder icon navigate to *My Folder* and select the *PremierBank Loan Approval Decision* that you have already created. Select the **P_is_urgent1, target_response_hours ** & **urgency_tier** variables and add it to the Rule Set - the **P_is_urgent1 ** variable is specified in the Rule Conditions column in the table below and the **urgency_tier** and **target_response_hours** variables have their own column as it gets assigned values.
     ![image-20260529174331866](img/README/image-20260529174331866.png)
4.   For the **P_is_urgent1 ** change it so that it is required as an input and then click on the save icon to add this change. The **risk_tier** & **target_response_hours** currently doesn't have any value from the decision so we can just leave it as an output.
     ![image-20260529174428872](img/README/image-20260529174428872.png)
5.   Navigate to the *Rule set* tab and click on the *Add rule* button
     ![image-20260529174505488](img/README/image-20260529174505488.png)
6.   Change the operator from the default of equal to greater than and then enter the comparison in the *IF* condition, in the THEN assignment change the variable to **risk_tier** and enter the corresponding value into the field enclosed in single quotes. Then as you are hovering over the THEN assignment there is a plus icon at the end of the row, click it to add an additional one, where you can assign the value for the **target_response_hours**
     ![image-20260529174608572](img/README/image-20260529174608572.png)
7.   Next click on *Add rule* and click on the *IF* statement dropdown and change it to an *ELSE* condition. This will combine the additional condition into one rule. From here continue to enter all the rest of the conditions and assignments as listed below and once you are done click on the save icon and then either use the little *x* icon in the right hand corner or click on *** Metro City Service Request Triage (1.0)* in the breadcrumb navigation up top to navigate back to the decision.
     ![image-20260529174819697](img/README/image-20260529174819697.png)

| Rule Conditions | urgency_tier | target_response_hours |
|-----------|-------------|-----------------|
| P_is_urgent1 >= 0.90 | Critical | 4 |
| P_is_urgent1 >= 0.70 | High | 12 |
| P_is_urgent1 >= 0.40 | Medium | 36 |
| P_is_urgent1 < 0.40 | Low | 72 |

**Rule Set: Department Routing**

| urgency_tier | Rule Conditions | assigned_department | resource_allocation |
|--------------|-----------------------|--------------------|---------------------|
| Critical | request_type contains 'water' OR 'sewer' OR 'gas' | Public Works (Emergency) | Emergency crew + supervisor |
| Critical | request_type contains 'traffic' OR 'road' | Transportation (Emergency) | Emergency crew + supervisor |
| Critical | request_type contains 'building' OR 'structural' | Building & Safety (Emergency) | Inspector + emergency crew |
| High | Any | Original department (priority queue) | Senior staff + overtime authorized |
| Medium | Any | Original department (standard queue) | Standard staffing |
| Low | Any | Original department (scheduled queue) | Standard staffing |

**Rule Set: Escalation Rules**

| Rule Conditions | escalation_flag |
|-----------|-----------|
| urgency_tier = 'Critical' | Immediate: notify department head and city operations center |
| urgency_tier = 'High' AND response_time_hours > 24 | Escalate: flag for equity review |
| urgency_tier = 'Medium' AND response_time_hours > 48 | Escalate: reassign or add resources |
| urgency_tier = 'Low' AND response_time_hours > 72 | Auto-escalate to Medium tier |
| Otherwise | No escalation |

**Rule Set: Reason Assignment**

These rules capture the dominant driver behind the triage decision and populate the `reason` variable used downstream by the LLM:

| Rule Conditions | reason |
|-----------|----------|
| urgency_tier = 'Critical' AND (request_type contains 'water' OR 'gas') | Imminent safety hazard |
| urgency_tier = 'Critical' AND request_type contains 'traffic' | Public safety risk on roadways |
| urgency_tier = 'Critical' | High-probability urgent request requiring immediate dispatch |
| urgency_tier = 'High' AND response_time_hours > 24 | Delayed response in an equity-sensitive district |
| urgency_tier = 'High' | Elevated urgency requiring priority handling |
| urgency_tier = 'Medium' | Standard service request within normal SLA |
| Otherwise | Routine request scheduled for next available slot |

### 4. Adding an LLM to the Mix

We are going to be adding a Large Language Model to our decision now. For this please open up the *Objects* side bar (postcard icon) and drag & drop a Call LLM node onto the *End* node. Then go ahead and add the missing variables like you did for the model node (do not make the prompt a required input for the decision) - and make sure to click on the save icon.

![image-20260529174850134](img/README/image-20260529174850134.png)

Now you can either add the *Prompt Assignment* Rule Set to the decision just like you added the other Rule Sets before or you can create it yourself. If you choose to create it yourself, please add the following variables from your decision as inputs to it:

-   assigned_department
-   escalation_flag
-   reason
-   resource_allocation
-   taret_response_hours
-   urgency_tier

And as output add the prompt variable (do not forget to click the save icon). Then switch to the *Rule set* tab, click on the *Add other* button, select the Rule type of *Assignment* and click *OK* - as we do not want to do a condition, but rather just fill in our prompt with a long value.

![image-20260529175037923](img/README/image-20260529175037923.png)

Next you are going to assign the prompt value by clicking on the pencil icon, in the *Expression Editor* removing all the values from the main editor and the copy and paste the value from below into it, then click the *Save* button, the save icon on the *Rule set* and return to the main decision.

```
prompt = CAT('You are a professional Metro City 311 citizen communications specialist. Using the service request triage data below, write a warm, respectful, and clearly structured long-form citizen notification (2 to 4 paragraphs) that the person who filed the request can read to understand how their request has been triaged and what to expect next. Do not expose internal codes or jargon verbatim — translate them into plain, everyday language. Do not commit to outcomes beyond the target response time specified, and do not make political or judgmental statements about the city or about other requests. Request and triage context: Urgency tier: ', urgency_tier, '. Assigned department: ', assigned_department, '. Target response time (hours): ', target_response_hours, '. Resource allocation: ', resource_allocation, '. Escalation flag: ', escalation_flag, '. Internal reason code: ', reason, '. Structure your response as follows. First, open with a respectful thank-you for filing the request and confirm that Metro City has received it and takes it seriously. Second, explain in plain language what the ', urgency_tier, ' urgency tier means for this request — translate it into everyday expectations rather than quoting the tier label verbatim. Third, describe which department (', assigned_department, ') will handle the request and, in a single sentence, what level of resources (', resource_allocation, ') has been assigned. Fourth, clearly communicate the target response window of ', target_response_hours, ' hours, what the citizen can expect during that window, and how they will be notified of progress or completion. If the escalation flag ', escalation_flag, ' indicates an immediate escalation, briefly note that senior city operations have also been notified. Translate the internal reason ', reason, ' into a brief, plain-language note about why this particular triage decision was made. Fifth, close with clear next steps — how the citizen can check status, how to reach 311 with questions, and a clear instruction to call 911 for any life-threatening emergency. Tone: warm, accountable, professional, and never dismissive or bureaucratic. Length: 200 to 350 words. Write in the second person (you, your request).')
```

![image-20260529175321189](img/README/image-20260529175321189.png)

This is a very simplistic approach to prompt engineering and also doesn't provide you with the ability to test and compare different large languages models. That is why SAS provides the [SAS Agentic AI Accelerator](https://github.com/sassoftware/sas-agentic-ai-accelerator) open-source project, which enables you to connect any LLM and do extensive prompt engineering & monitoring, but here we have a hard coded LLM (OpenAI GPT 5.4) available.

### 5. Test the Decision

1. In the decision click on the *Scoring* tab and then in there click on the *Scenarios* sub tab

2. Click on the *New test* button
    ![image-20260529175345494](img/README/image-20260529175345494.png)

3. Enter sample values:

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

4. Review the output by clicking on the Results icon once the *Status* as switched to a green check mark
    ![image-20260529181053235](img/README/image-20260529181053235.png)

5. Feel free to further test with different scenarios to validate the logic:
   - A low-priority park maintenance request should fall into the Low tier with scheduled queue
   - A high-urgency request from a district with known equity gaps should trigger the equity-review escalation
   - A medium request that has been open for more than 48 hours should be flagged for reassignment

### 6. Publish the Decision

1. Click the **Validate** button and then **Publish** to make the decision available as a callable service
2. Choose a **destination:**
   - **CAS** — for batch execution against your full request backlog
   - **MAS (Micro Analytic Service)** — for real-time, low-latency API calls from the 311 system - only one available here!
   - **Container** — for deployment in external systems
3. Please make sure to give it a unique name
4. Once published, the decision is available as a REST API endpoint

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
- *"What are the publishing options for deploying a decision as a REST endpoint?"*

The Copilot is a useful reference tool for quickly getting answers about the platform's capabilities while you are building your decision flows.

---

## Decisions as Tools in Agentic Workflows

A published SAS Intelligent Decisioning decision is exposed as a **REST API endpoint**. This means it can be called as a **tool** by any AI agent — including large language model (LLM) agents that use tool-calling capabilities.

### How This Works

```
┌──────────────┐     ┌─────────────────────────┐     ┌──────────────────┐
│  311 Chatbot │────>│  SAS Intelligent         │────>│  Triage          │
│  Agent       │     │  Decisioning API         │     │  Recommendation  │
│  (LLM)       │<────│  /decisions/serviceTriage │<────│                  │
└──────────────┘     └─────────────────────────┘     └──────────────────┘
```

**Example scenario:** A citizen calls the 311 hotline or uses the Metro City chatbot to report a problem. The chatbot agent (powered by an LLM) can:

1. Collect the request details from the citizen through conversation
2. **Call the SAS Intelligent Decisioning API** with the request data
3. Receive back: "Critical — deploy emergency crew to Water Main Break, 4-hour SLA"
4. Inform the citizen of the expected response time and confirm the request has been prioritized
5. Simultaneously trigger the department dispatch workflow

The decision becomes a **tool** in the agent's toolkit, just like a search function or a database query. This bridges the gap between analytical models and citizen-facing conversational AI.

### Why This Matters

- **Consistency:** Every 311 interaction uses the same triage logic — the rules and model scores are centralized, not hardcoded into chatbot prompts
- **Governance:** The decision is version-controlled and auditable in SAS Intelligent Decisioning, not buried in an LLM's system prompt
- **Separation of concerns:** Data scientists own the model, city operations staff own the rules, and the chatbot just calls the endpoint
- **Real-time execution:** MAS endpoints return in milliseconds, fast enough for conversational use
- **Public accountability:** Because the decision logic is documented and versioned, it can be reviewed under public records requests

---

## Decisions as Agentic Workflows

Beyond being called as tools, SAS Intelligent Decisioning can itself orchestrate **agentic workflows** — multi-step processes that autonomously execute a chain of decisions and actions.

### How a Decision Becomes an Agent

An agentic decision flow goes beyond simple "input -> rules -> output." It can:

1. **Observe:** Receive a new service request or detect that an existing request has exceeded its SLA
2. **Reason:** Score the request's urgency, check the department's current workload, review the district's equity status
3. **Decide:** Select the optimal triage action, department routing, and resource allocation
4. **Act:** Trigger downstream actions — dispatch a crew, send a citizen notification, create a work order, update the dashboard
5. **Monitor:** Track whether the request is resolved within the SLA and feed that outcome back into future decisions

### Example: Automated Request Routing and Escalation Agent

```
┌─────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  Event       │     │  Decision Flow   │     │  Actions         │
│  Trigger     │────>│                  │────>│                  │
│              │     │  1. Score model   │     │  - Dispatch crew  │
│  "New 311    │     │  2. Classify tier │     │  - Notify citizen │
│   request"   │     │  3. Route dept    │     │  - Create work    │
│   — or —     │     │  4. Allocate      │     │    order          │
│  "SLA breach │     │     resources     │     │  - Update         │
│   detected"  │     │  5. Check equity  │     │    dashboard      │
└─────────────┘     └──────────────────┘     └──────────────────┘
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

This is **agentic** because the system autonomously:
- Detects the trigger condition (new request or SLA breach)
- Makes decisions without human intervention
- Executes real-world actions (dispatching, notifications)
- Learns from outcomes to improve future triage

### Scaling Agentic Decisioning

In a production environment, this agentic workflow can process **15,000 requests per month** without manual intervention:

- **Real-time mode:** As each new 311 request arrives, score and triage it instantly
- **Batch mode:** Every morning, re-score the open request backlog, identify SLA risks, and re-prioritize
- **Event-driven mode:** When a request's SLA clock is about to expire, trigger automatic escalation
- **Multi-decision chaining:** The triage decision calls a "resource optimization" decision which calls a "citizen notification" decision — creating a fully automated service delivery pipeline

SAS Intelligent Decisioning provides the orchestration layer that turns individual models and rules into **enterprise-scale autonomous agents** for municipal service delivery.

---

## Summary

In this step you have:

1. **Created a decision flow** that combines your urgency model with business rules to produce actionable triage recommendations
2. **Added an LLM call** that turns the decision into a warm, citizen-friendly notification message
3. **Used the Copilot** to get answers about SAS Intelligent Decisioning, MAS, and Container Runtime documentation
4. **Published the decision** as a callable API endpoint
5. **Learned how decisions work as tools** for the 311 chatbot agent
6. **Explored agentic workflows** where decisions autonomously detect, reason, decide, and act on service requests

---

## Congratulations!

You have completed the full Data and AI Life Cycle for the Metro City citizen service request prioritization use case:

| Step | What You Did | SAS Technology |
|------|-------------|---------------|
| 1. Ask & Access | Understood the problem, generated synthetic data | SAS Data Maker |
| 2. Prepare | Loaded, profiled, and joined data into an ABT | SAS Viya Workbench |
| 3. Explore | Visually explored patterns with AI assistance | SAS Visual Analytics + Copilot |
| 4. Model | Built, compared, and fairness-tested models across districts | SAS Model Studio + Copilot |
| 5. Deploy & Act | Operationalized with automated triage decisions | SAS Intelligent Decisioning + Copilot |

If you have time remaining, explore another use case or dive deeper into any step. Talk to your bootcamp mentor for follow-up topics or to share feedback.
