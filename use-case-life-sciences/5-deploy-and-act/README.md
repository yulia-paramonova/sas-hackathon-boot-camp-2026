# Étape 5: Deploy & Act

Dans cette dernière étape, vous utiliserez **SAS Intelligent Decisioning** pour opérationnaliser votre modèle de prédiction des réadmissions en l’intégrant dans un flux automatisé de décision de sortie.  
Vous explorerez également son **Copilot** et apprendrez comment les décisions peuvent fonctionner comme des **outils dans des workflows agentiques** — ou devenir elles-mêmes des workflows agentiques.

---

## Prérequis

Votre modèle champion doit être enregistré dans **SAS Model Manager** à l’étape 4.
SAS Intelligent Decisioning récupérera directement le modèle depuis le registre de Model Manager.
Si vous n’avez pas enregistré votre propre modèle, ne vous inquiétez pas : un modèle par défaut est fourni.

---

## Qu'est ce que SAS Intelligent Decisioning?

SAS Intelligent Decisioning est la plateforme permettant de créer, gérer et exécuter des décisions métier qui combinent des modèles analytiques, des règles métier et une logique contextuelle au sein d’un flux de décision unique.
Au lieu de simplement scorer un patient à l’aide d’un modèle, un flux de décision peut :

- Évaluer (scorer) la probabilité de réadmission du patient
- La classer dans une catégorie de risque
- Appliquer des règles cliniques (ex : « toujours signaler les patients ayant 4 comorbidités ou plus pour une revue de gestion des soins »)
- Appliquer une logique conditionnelle en fonction de la catégorie de diagnostic et du type de sortie
- Sélectionner le plan de soins post-sortie et l’intervention appropriés
- Fournir une recommandation complète de sortie

Cela transforme la prédiction d’un modèle en une **décision clinique actionable**.  

Si vous avez des questions concernant SAS Intelligent Decisioning, activez le copilot SAS Viya dans l’application via l’icône située en haut à droite, à côté de votre profil, ou adressez-vous à l’un des mentors SAS présents sur site.

---

## Création d’une décision de risque de réadmission à la sortie


### 1. Ouvrez SAS Intelligent Decisioning

1. Depuis le menu principal SAS Viya, allez dans **SAS Intelligent Decisioning** (sous **Build Decisions**)
2. Cliquez sur **New Decision**
3. Nommez-la : *MedCare Discharge Readmission Risk Decision*
4. Laissez Description, Emplacement et Workflow par défaut, puis cliquez sur OK
    ![image-20260529155022595](img/README/image-20260529155022595.png)
5. Allez dans l’onglet *Variables*, cliquez sur *Add variable* puis choisissez *Custom variable* pour les saisir manuellement *(étape 1 et 2)* ou *Decision* pour les copier depuis un modèle (plus rapide) *(étape 3)*. 
    ![image-20260529160009592](img/README/image-20260529160009592.png)
   
    1. Définissez les **variables d'entrée** (celles-ci seront transmises lorsque la décision sera prise) - La structure est: `nom` (type de donnée) - Explication (juste pour nous pour le contexte):
        1. `comorbidity_count` (décimal)
        2. `emergency_flag` (décimal)
        3. `polypharmacy_flag` (décimal)
        4. `clinical_risk_score` (décimal)
        5. `discharged_home` (décimal)
        6. `discharge_disposition` (caractère)
           
    2. Définissez les **variables de sortie** (celles-ci seront renvoyées par la décision) - La structure est: `nom` (type de donnée) - Explication (juste pour nous pour le contexte):
        1. `risk_tier` (caractère) - le niveau de risque de réadmission du patient
        2. `care_plan` (caractère) - le plan de soins recommandé après la sortie
        3. `intervention` (caractère) -  l’intervention spécifique à exécuter
        4. `priority` (caractère) - le niveau d’urgence de la coordination des soins
        5. `reason` (caractère) - la raison pour laquelle ce plan de soins a été sélectionné
        6. `follow_up_days` (décimal) - quand est-ce que le premier suivi doit avoir lieu
        7. Cliquez OK pour ajouter toutes les variables
            ![image-20260529161044174](img/README/image-20260529161044174.png)
           
    4. Copiez les **variables** depuis un template de décision:
        1. Cliquez sur le fichier *Decision*
        2. Naviguez vers *SAS Content > SAS Hackathon Bootcamp 2026 > Use Case Life Sciences* sélectionnez *MedCare Discharge Readmission Risk Decision* et cliquez sur OK
        3. Cliquez sur l'icône *Add all* au milieu du dialogue pour importer toutes les varibales dans votre décision puis appuyez sur le boutton *Add*

Une fois les variables ajoutées, pensez à cliquer sur l'icône *enregistrer* en haut à droite. Il est recommandé que vous enregistriez votre fichier dès que vous changez quelque chose en lien avec des variables.

Vous pouvez également activer le Copilot SAS Viya à travers l'icône en haut à droite pour poser des questions sur SAS Intelligent Decisioning pour approfondir votre compréhension de l'application.

### 2. Ajoutez le nœud Modèle

1. Passez à l’onglet *Decision Flow*.
2. Dans le canvas de flux de décision, vous pouvez soit faire un clic droit sur le nœud *Start* et dans le menu contextuel sélectionner *Add below > Model*, soit sur le côté droit cliquer sur l’icône qui ressemble un peu à une carte postale et depuis cette barre latérale glisser-déposer un nœud modèle sur le nœud *Start*.
    ![image-20260529161415141](img/README/image-20260529161415141.png)
3. Sélectionnez votre modèle champion enregistré depuis SAS Model Manager ou le modèle champion pré-enregistré en naviguant vers *DM Repository > MedCare Patient Readmission Prediction_1 > Version 1 > GAM (SAS Automatically Generated Pipeline* puis cliquez sur OK.
    ![image-20260529161613719](img/README/image-20260529161613719.png)
4. Après cela, vous verrez une petite icône d’erreur rouge à côté du modèle, et cela est dû au fait qu’il manque des variables d’entrée et de sortie — nous allons corriger cela dans les étapes suivantes.
5. Associez les variables d’entrée aux caractéristiques attendues du modèle :
    1.  Pour les entrées, `clinical_risk_score`, `discharge_disposition` et `discharged_home` devraient être automatiquement mappées.
        ![image-20260529162205954](img/README/image-20260529162205954.png)
    2. Pour les sorties, nous allons cliquer sur le menu *More* en haut puis sélectionner *Add missing variables*. Cela ajoutera toutes les variables de sortie requises à notre décision — si vous avez copié les variables en utilisant le modèle, elles sont déjà présentes — dans la boîte de dialogue, assurez‑vous de les désélectionner de la sortie car nous allons créer nos propres sorties personnalisées — et comme nous avons modifié quelque chose concernant les variables, n’oubliez pas de cliquer sur l’icône de sauvegarde (il vous sera demandé de supprimer les variables non utilisées, sélectionnez simplement non, car nous les utiliserons dans les étapes suivantes).
        ![image-20260529162348798](img/README/image-20260529162348798.png)


### 3. Ajouter des règles métier

Après que le modèle ait évalué la demande, ajoutez des nœuds **Rule Set** pour déterminer la décision de prêt. Pour cela, assurez‑vous d’abord d’avoir cliqué sur l’icône de sauvegarde de votre décision, puis nous ajouterons des Rule Sets à notre décision.

Il existe deux façons d’ajouter des **Rule Sets** à la décision :

1.    *La méthode simple*, utilisez les ensembles de règles (rule sets) préconstruits en cliquant sur les trois points verticaux du nœud du modèle, puis en sélectionnant *Add > Rule Set*, ensuite, dans la boîte de dialogue, naviguez vers *SAS Content > SAS Hackathon Bootcamp 2026 > Use Case Life Sciences* et ajoutez l’ensemble de règles comme indiqué ci-dessous.
2.    *La méthode d'apprentissage*, si vous souhaitez les créer vous-même, allez sur le côté droit, cliquez sur *Objects* icône en forme de carte postale) puis faites glisser-déposer un Rule Set sur le nœud précédent. Cela ouvrira une boîte de dialogue dans laquelle vous devrez nommer votre décision de manière appropriée. Laissez l’emplacement par défaut (*My Folder*) - Ensuite, ajoutez les variables de la décision que vous avez créée et commencez à construire les ensembles de règles comme décrit ci-dessous. Les variables requises sont indiquées soit dans les colonnes, soit dans les **Rule Conditions**. Le premier ensemble de règles que nous allons construire comporte des notes et des captures d’écran expliquant comment procéder.

Nous vous recommandons d’essayer de créer au moins un de ces ensembles de règles vous-même afin de comprendre comment cela fonctionne. Si vous avez des questions concernant SAS Intelligent Decisioning, activez le copilote SAS Viya dans l’application via l’icône en haut à droite à côté de votre profil, ou demandez à l’un des mentors SAS sur place.

**Rule Set: Classification du niveau de risque**

1.   Depuis le panneau latéral *Objects* glissez-déposez un nœud *Rule Set* sur le nœud *Model* déjà présent dans votre décision. Saisissez ensuite le nom ci-dessus et cliquez sur *Save*. 
     ![image-20260529163854583](img/README/image-20260529163854583.png)
2.  Sur la droite, vous verrez le panneau *Properties* pour ce nouveau *Rule Set* avec un bouton *Open* qui vous amène au *Rule set editor* afin de construire la logique de décision ; cliquez sur ce bouton.
3.  Une nouvelle interface s'ouvre sur l'onglet *Variables* du *Rule Set*. Sous *Add variable*, utilisez l'icône dossier pour naviguer vers *My Folder* et sélectionnez *MedCare Discharge Readmission Risk Decision* que vous avez déjà créé. Sélectionnez les variables **P_readmitted_30days1** & **risk_tier** puis ajoutez-les au Rule Set : - la variable **P_readmitted_30days1** est utilisée dans la colonne Rule Conditions du tableau ci-dessous, et **risk_tier** a sa propre colonne car elle reçoit des valeurs.
     ![image-20260529164239556](img/README/image-20260529164239556.png)
4.   Pour **P_readmitted_30days1** modifiez-la pour qu'elle soit requise en entrée puis cliquez sur l'icône de sauvegarde pour enregistrer ce changement. La variable **risk_tier** n'a pas encore de valeur provenant de la décision, vous pouvez donc la laisser en sortie.
     ![image-20260529164320438](img/README/image-20260529164320438.png)
5.    Allez dans l'onglet *Rule set* puis cliquez sur le bouton *Add rule*.
     ![image-20260529164508583](img/README/image-20260529164508583.png)
6.   Remplacez l'opérateur par défaut (égal) par **plus grand que** puis saisissez la comparaison dans la condition *IF*. Dans l'affectation THEN, choisissez la variable **risk_tier** et saisissez la valeur correspondante entre guillemets simples. 
     ![image-20260529164433028](img/README/image-20260529164433028.png)
7.   Cliquez ensuite sur *Add rule* puis dans la liste déroulante de l'instruction *IF* assez à une condition *ELSE*. Cela permet de combiner les conditions supplémentaires dans une seule règle. Continuez ensuite à saisir le reste des conditions et affectations comme indiqué ci-dessous. Une fois terminé, cliquez sur l'icône de sauvegarde puis utilisez soit la petite croix *x* en haut à droite, soit *** MedCare Discharge Readmission Risk Decision (1.0)* dans le fil d'Ariane en haut, pour revenir à la décision.
     ![image-20260529164659061](img/README/image-20260529164659061.png)

| Rule Conditions | risk_tier |
|-----------|-----------|
| P_readmitted_30days1 >= 0.80 | Très élevé |
| P_readmitted_30days1 >= 0.60 | Élevé |
| P_readmitted_30days1 >= 0.40 | Modéré |
| P_readmitted_30days1 < 0.40 | Faible |

**Rule Set: Care Plan Assignment**

| risk_tier | discharge_disposition | care_plan | follow_up_days |
|-----------|----------------------|-----------|----------------|
| Très élevé | Any | Intensive transitional care | 1 |
| Élevé | Home | Home health referral + phone follow-up | 2 |
| Élevé | SNF | SNF care coordination + pharmacy consult | 3 |
| Élevé | Home Health | Enhanced home health with daily check-ins | 2 |
| Modéré | Any | Standard follow-up protocol | 5 |
| Faible | Any | Routine discharge (continue monitoring) | 14 |

**Rule Set: Intervention Assignment**

| Rule Conditions | intervention |
|-----------|-------------|
| polypharmacy_flag = 1 | Medication reconciliation by clinical pharmacist |
| clinical_risk_score >= 3 | Urgent PCP follow-up within 48 hours |
| emergency_flag = 1 AND comorbidity_count >= 3 | Care manager assignment + social work consult |
| comorbidity_count >= 4 | Chronic disease management enrollment |
| Otherwise | Automated discharge instructions + patient portal reminder |

**Rule Set: Priority Assignment**

| Rule Conditions | priority |
|-----------|----------|
| risk_tier = 'Critical' AND comorbidity_count >= 3 | Urgent |
| risk_tier = 'Critical' OR (risk_tier = 'High' AND polypharmacy_flag = 1) | High |
| risk_tier = 'High' OR risk_tier = 'Moderate' | Normal |
| risk_tier = 'Low' | Routine |

**Rule Set: Reason Assignment**

These rules capture the dominant driver behind the care plan and populate the `reason` variable used downstream by the LLM:

| Rule Conditions | reason |
|-----------|----------|
| emergency_flag = 1 AND comorbidity_count >= 3 | Multiple chronic conditions with emergency admission |
| polypharmacy_flag = 1 AND clinical_risk_score >= 3 | Complex medication regimen with elevated clinical risk |
| comorbidity_count >= 4 | Multiple concurrent chronic conditions |
| clinical_risk_score >= 3 | Elevated clinical risk score at discharge |
| polypharmacy_flag = 1 | Complex medication regimen |
| Otherwise | Standard discharge with routine monitoring |

### 4. Adding an LLM to the Mix

We are going to be adding a Large Language Model to our decision now. For this please open up the *Objects* side bar (postcard icon) and drag & drop a Call LLM node onto the *End* node. Then go ahead and add the missing variables like you did for the model node (do not make the prompt a required input for the decision) - and make sure to click on the save icon.

![image-20260529171156226](img/README/image-20260529171156226.png)

Now you can either add the *Prompt Assignment* Rule Set to the decision just like you added the other Rule Sets before or you can create it yourself. If you choose to create it yourself, please add the following variables from your decision as inputs to it:

-   care_plan
-   follow_up_days
-   intervention
-   priority
-   reason
-   risk_tier

And as output add the prompt variable (do not forget to click the save icon). Then switch to the *Rule set* tab, click on the *Add other* button, select the Rule type of *Assignment* and click *OK* - as we do not want to do a condition, but rather just fill in our prompt with a long value.

![image-20260529171254888](img/README/image-20260529171254888.png)

Next you are going to assign the prompt value by clicking on the pencil icon, in the *Expression Editor* removing all the values from the main editor and the copy and paste the value from below into it, then click the *Save* button, the save icon on the *Rule set* and return to the main decision.

```
prompt = CAT('You are a compassionate MedCare patient education specialist. Using the patient discharge data and care plan below, write a warm, respectful, and clearly structured long-form discharge summary (3 to 5 paragraphs) that a patient with no clinical background can read to understand their next steps after leaving the hospital. Do not expose clinical codes or jargon verbatim — translate them into plain, everyday language. Do not provide medical advice beyond what the care plan specifies, do not diagnose, and do not predict outcomes. Patient and care plan context: Assigned risk tier: ', risk_tier, '. Recommended care plan: ', care_plan, '. Specific intervention: ', intervention, '. First follow-up in (days): ', follow_up_days, '. Care coordination priority: ', priority, '. Internal reason code: ', reason, '. Structure your response as follows. First, open with a warm, personal acknowledgment that the patient is being discharged today and that MedCare is committed to supporting their recovery at home. Do not explicitly state the ', risk_tier, ' risk tier — instead, frame the care plan as tailored to their individual situation. Second, explain the recommended care plan ', care_plan, ' in plain language and describe what the patient can expect in the coming days. Third, explain the specific intervention ', intervention, ' — including who will reach out, what the purpose is, and why it matters for their recovery. Translate the internal reason ', reason, ' into an empathetic, plain-language explanation of why this extra level of support is being offered. Fourth, clearly communicate the follow-up timeline (within ', follow_up_days, ' days), what kind of follow-up it is, and what the patient needs to do to prepare. Reflect the ', priority, ' care coordination priority in the tone — more proactive and immediate for urgent priority, calmer and routine for standard priority. Fifth, close with clear guidance on warning signs that require immediate attention (calling 911 or going to the emergency room) and reassure the patient that their care team is available for questions. Tone: warm, respectful, reassuring, and never alarming or condescending. Length: 300 to 450 words. Write in the second person (you, your recovery). Always include a clear reminder to call 911 or go to the emergency room for any life-threatening symptoms.')
```

![image-20260529171608495](img/README/image-20260529171608495.png)

This is a very simplistic approach to prompt engineering and also doesn't provide you with the ability to test and compare different large languages models. That is why SAS provides the [SAS Agentic AI Accelerator](https://github.com/sassoftware/sas-agentic-ai-accelerator) open-source project, which enables you to connect any LLM and do extensive prompt engineering & monitoring, but here we have a hard coded LLM (OpenAI GPT 5.4) available.

### 5. Test the Decision

1. In the decision click on the *Scoring* tab and then in there click on the *Scenarios* sub tab

2. Click on the *New test* button
    ![image-20260529094624231](../../use-case-financial-services/5-deploy-and-act/img/README/image-20260529094624231.png)

3. In the *New Scenario* window leave the name on the provided default, set the location to *My Folder* and the output table location to your *CASUSER* - see screenshot below

4. Enter sample values:
   - clinical_risk_score: 3
   - comorbidity_count: 4
   - discharge_disposition: Home
   - discharged_home: 1
   - emergency_flag: 1
   - polypharmacy_flag: 1
   
   ![image-20260529171953925](img/README/image-20260529171953925.png)
   
5. Review the output

6. Feel free to further test with different scenarios to validate the logic:
   - A low-risk patient being discharged home should receive routine discharge instructions
   - A patient with polypharmacy should trigger a medication reconciliation intervention
   - A Critical-risk patient with 3+ comorbidities should be flagged as Urgent priority with intensive transitional care

### 6. Publish the Decision

1. Click the **Validate** button and then **Publish** to make the decision available as a callable service
2. Choose a **destination:**
   - **CAS** — for batch execution against your full patient population at discharge
   - **MAS (Micro Analytic Service)** — for real-time, low-latency API calls during the discharge workflow - only one available here!
   - **Container** — for deployment in external systems (e.g., integration with Epic EHR)
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
- *"How do I integrate a decision with an external EHR system via REST API?"*

The Copilot is a useful reference tool for quickly getting answers about the platform's capabilities while you are building your decision flows.

---

## Decisions as Tools in Agentic Workflows

A published SAS Intelligent Decisioning decision is exposed as a **REST API endpoint**. This means it can be called as a **tool** by any AI agent — including large language model (LLM) agents that use tool-calling capabilities.

### How This Works

```
┌──────────────┐     ┌─────────────────────────┐     ┌──────────────────┐
│   AI Agent   │────>│  SAS Intelligent         │────>│  Care Plan       │
│  (e.g. LLM)  │     │  Decisioning API         │     │  Recommendation  │
│              │<────│  /decisions/readmitRisk   │<────│                  │
└──────────────┘     └─────────────────────────┘     └──────────────────┘
```

**Example scenario:** A clinical decision support agent (powered by an LLM) is assisting a care team during the discharge planning process. The agent can:

1. Pull the patient's clinical data from the EHR
2. **Call the SAS Intelligent Decisioning API** with the patient's features
3. Receive back: "High risk — home health referral + medication reconciliation, follow-up in 2 days"
4. Present this recommendation to the discharging physician with clinical rationale, enabling a more informed discharge plan

The decision becomes a **tool** in the agent's toolkit, just like a medication interaction checker or a lab result lookup. This bridges the gap between analytical models and clinical workflow.

### Why This Matters

- **Consistency:** Every discharge uses the same evidence-based decision logic — the rules and model scores are centralized, not dependent on individual clinician memory
- **Governance:** The decision is version-controlled and auditable in SAS Intelligent Decisioning, not buried in an LLM's system prompt
- **Separation of concerns:** Data scientists own the model, clinical leaders own the rules, and the AI agent just calls the endpoint
- **Real-time execution:** MAS endpoints return in milliseconds, fast enough for use during the discharge conversation

---

## Decisions as Agentic Workflows

Beyond being called as tools, SAS Intelligent Decisioning can itself orchestrate **agentic workflows** — multi-step processes that autonomously execute a chain of decisions and actions.

### How a Decision Becomes an Agent

An agentic decision flow goes beyond simple "input -> rules -> output." It can:

1. **Observe:** Receive a trigger event (e.g., a patient has been discharged and no follow-up appointment is scheduled within 48 hours)
2. **Reason:** Score the patient's readmission risk, check their care plan, review medication reconciliation status
3. **Decide:** Select the appropriate escalation action from the rule sets
4. **Act:** Trigger downstream actions — schedule a follow-up call, alert the care manager, send a patient portal message, create an EHR task
5. **Monitor:** Track whether the patient attends follow-up, refills medications, or shows signs of deterioration — and feed that outcome back into future decisions

### Example: Automated Post-Discharge Monitoring Agent

```
┌─────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  Event       │     │  Decision Flow   │     │  Actions         │
│  Trigger     │────>│                  │────>│                  │
│              │     │  1. Score model   │     │  • Schedule call │
│  "Patient    │     │  2. Apply rules   │     │  • Alert care    │
│   discharged │     │  3. Assign care   │     │    manager       │
│   48 hrs ago,│     │     plan          │     │  • Send portal   │
│   no follow- │     │  4. Set priority  │     │    message       │
│   up booked" │     │  5. Select        │     │  • Create EHR    │
│              │     │     intervention  │     │    task           │
└─────────────┘     └──────────────────┘     └──────────────────┘
                              │
                              v
                    ┌──────────────────┐
                    │  Feedback Loop   │
                    │                  │
                    │  Did patient     │
                    │  attend follow-  │
                    │  up? Readmitted? │
                    │  Update model.   │
                    └──────────────────┘
```

This is **agentic** because the system autonomously:
- Detects the trigger condition (missed follow-up window)
- Makes decisions without human intervention
- Executes real-world clinical actions
- Learns from outcomes to improve future predictions

### Scaling Agentic Decisioning

In a production environment, this agentic workflow can process **hundreds of discharges per day** without manual intervention:

- **Batch mode:** Every morning, score all patients discharged in the past 24 hours, identify high-risk ones, trigger care coordination actions
- **Event-driven mode:** As soon as a patient is discharged, trigger the flow in real time from the EHR discharge event
- **Multi-decision chaining:** One decision flow calls another — e.g., the readmission risk decision calls a "medication reconciliation priority" decision which calls a "follow-up scheduling optimization" decision

SAS Intelligent Decisioning provides the orchestration layer that turns individual models and rules into **enterprise-scale autonomous clinical agents**.

---

## Summary

In this step you have:

1. **Created a decision flow** that combines your readmission model with clinical rules to produce actionable care plan recommendations at discharge
2. **Added an LLM call** that turns the decision into a warm, patient-friendly discharge summary
3. **Used the Copilot** to get answers about SAS Intelligent Decisioning, MAS, and Container Runtime documentation
4. **Published the decision** as a callable API endpoint
5. **Learned how decisions work as tools** for LLM-powered clinical decision support agents
6. **Explored agentic workflows** where decisions autonomously detect, reason, decide, and act in post-discharge monitoring

---

## Congratulations!

You have completed the full Data and AI Life Cycle for the MedCare patient readmission use case:

| Step | What You Did | SAS Technology |
|------|-------------|---------------|
| 1. Ask & Access | Understood the problem, generated synthetic data | SAS Data Maker |
| 2. Prepare | Loaded, profiled, and joined data into an ABT | SAS Viya Workbench |
| 3. Explore | Visually explored patterns with AI assistance | SAS Visual Analytics + Copilot |
| 4. Model | Built, compared, and fairness-tested models | SAS Model Studio + Copilot |
| 5. Deploy & Act | Operationalized with automated clinical decisions | SAS Intelligent Decisioning + Copilot |

If you have time remaining, explore another use case or dive deeper into any step. Talk to your bootcamp mentor for follow-up topics or to share feedback.
