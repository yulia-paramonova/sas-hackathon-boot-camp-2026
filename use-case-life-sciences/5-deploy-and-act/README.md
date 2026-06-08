# Step 5: Deploy & Act

In this final step you will use **SAS Intelligent Decisioning** to operationalize your readmission prediction model by embedding it in an automated discharge decision flow. You will also explore its **Copilot** and learn how decisions can function as **tools in agentic workflows** — or become agentic workflows themselves.

---

## Prerequisites

Your champion model should be registered in **SAS Model Manager** from Step 4. SAS Intelligent Decisioning will pull the model directly from the Model Manager registry. If you did not register your own do not worry a default one is provided.

---

## What is SAS Intelligent Decisioning?

SAS Intelligent Decisioning is the platform for creating, managing, and executing business decisions that combine analytical models, business rules, and contextual logic into a single decision flow. Instead of just scoring a patient with a model, a decision flow can:

- Score the patient's readmission probability
- Classify it into a risk tier
- Apply clinical rules (e.g., "always flag patients with 4+ comorbidities for care management review")
- Branch logic based on diagnosis category and discharge disposition
- Select the appropriate post-discharge care plan and intervention
- Return a complete discharge recommendation

This turns a model prediction into an **actionable clinical decision**.

If you have any questions around SAS Intelligent Decisioning activate the SAS Viya copilot within the application via the icon in the top right hand corner next to your profile or ask one of the onsite SAS Mentors.

---

## Creating a Discharge Readmission Risk Decision

### 1. Open SAS Intelligent Decisioning

1. From the SAS Viya main menu, navigate to **SAS Intelligent Decisioning** (under *Build Decisions*)
2. Click **New Decision**
3. Name it: *MedCare Discharge Readmission Risk Decision*
4. Leave the Description, Location and Workflow on default and click OK
    ![image-20260529155022595](img/README/image-20260529155022595.png)
5. Navigate to the *Variables* tab, click on the *Add variable* dropdown and either select *Custom variable* if you want to add them all yourself of *Decision* if you want to copy it from the template (this is faster). The manual steps are described in the below sub steps 1 & 2 while the copy is described in step 3:
    ![image-20260529160009592](img/README/image-20260529160009592.png)
    1. Define the **input variables** (these will be passed in when the decision is called) - The structure is: `name` (data type):
        1. `comorbidity_count` (decimal)
        2. `emergency_flag` (decimal)
        3. `polypharmacy_flag` (decimal)
        4. `clinical_risk_score` (decimal)
        5. `discharged_home` (decimal)
        6. `discharge_disposition` (character)
    2. Define the **output variables** (what the decision returns)  - The structure is: `name` (data type) - Explanation (this is just for us as context):
        1. `risk_tier` (character) - the patient's readmission risk level
        2. `care_plan` (character) - the recommended post-discharge care plan
        3. `intervention` (character) - specific intervention to execute
        4. `priority` (character) - urgency of care coordination
        5. `reason` (character) - why this care plan was selected
        6. `follow_up_days` (decimal) - when the first follow-up should occur
        7. Now click OK to add all of them
            ![image-20260529161044174](img/README/image-20260529161044174.png)
    3. Copy the **variables** from a template decision:
        1. Click on the folder icon in the *Decision* input field
        2. Navigate to *SAS Content > SAS Hackathon Bootcamp 2026 > Use Case Life Sciences* select *MedCare Discharge Readmission Risk Decision* and click OK
        3. Click on the *Add all* icon in the middle of the dialogue to bring all the variables into your decision and then click the Add button

Once you have added the variables (no matter which way you choose) please click on the save icon in the upper right hand corner. It is recommended that anytime you change something about the variables before you continue to quickly use this icon to save the changes.


From here you can also always activate the SAS Viya Copilot via the icon in the top right hand corner to ask questions about SAS Intelligent Decisioning to deepen your understanding of the application.

### 2. Add the Model Node

1. Switch to the *Decision Flow* tab.
2. In the decision flow canvas, you can either right click the *Start* node and from the context menu select *Add below > Model* or on the right hand side click on the icon that looks a little bit like a postcard and from that side bar drag & drop a model node onto the *Start* node.
    ![image-20260529161415141](img/README/image-20260529161415141.png)
3. Select your registered champion model from SAS Model Manager or the pre-registered champion model by navigating to *DM Repository > MedCare Patient Readmission Prediction_1 > Version 1 > GAM (SAS Automatically Generated Pipeline* and click OK.
    ![image-20260529161613719](img/README/image-20260529161613719.png)
4. Upon doing this you will see a little red error icon next to the model and that is because it is missing variable inputs and outputs - we will address this in the next steps.
5. Map the input variables to the model's expected features:
    1. For the inputs map `clinical_risk_score`, `discharge_disposition` and the `discharged_home` should be mapped automatically.
        ![image-20260529162205954](img/README/image-20260529162205954.png)
    2. For the outputs we are going to be clicking the *More* menu up top and select *Add missing variables* this will add all of the required output variables to our decision - if you copied the variables using the template they are already present - in the dialogue please make sure to deselect them from the Output as we will create our own custom outputs - and since we changed something about the variables remember to click the save icon (you will be asked to remove not used variables just select no, as we will be using those in the next steps).
        ![image-20260529162348798](img/README/image-20260529162348798.png)




### 3. Add Business Rules

After the model scores the application, add **Rule Set** nodes to determine the lending decision. For this make first sure that you have clicked the save icon of your decision and than we will be adding Rule Sets to our decision.

There are two ways of adding **Rule Sets** to the decision:

1.    *The easy way*, where you use the pre build rule sets by clicking on the three vertical dots on the model node and selecting *Add > Rule Set*, then in the dialogue navigate to *SAS Content > SAS Hackathon Bootcamp 2026 > Use Case Life Sciences* and add the rule set as specified below.
2.    *The learning way*, if you want to create them yourself you can go to the right hand side click on the *Objects* (postcard icon) and drag & drop a Rule Set onto the previous node. This will open up a dialogue where you should name your decision correspondingly, please leave the location as the default (*My Folder*) - then add the variables from the decision you created and start building the Rule Sets as described below - the required variables are noted either as the columns or in the **Rule Conditions**. The first rule set we will be building has notes and screenshots attached on how to do this.

We recommend you try to build at least one of these rule sets yourself to get an understanding of how it is done. If you have any questions around SAS Intelligent Decisioning activate the SAS Viya copilot within the application via the icon in the top right hand corner next to your profile or ask one of the onsite SAS Mentors.

**Rule Set: Risk Tier Classification**

1.   From the *Objects* side panel drag and drop a *Rule Set* node onto the *Model* node you already have in your decision. Then enter the name from above and click *Save*
     ![image-20260529163854583](img/README/image-20260529163854583.png)
2.   Now on the right hand side you will see the *Properties* pane for this new *Rule Set* and there is a button *Open* that will take you to the *Rule set editor* so that you can build the decision so click on that button.
3.   A new UI opened up for you on the *Variables* tab for the *Rule Set*, under *Add variable* select, via the folder icon navigate to *My Folder* and select the *MedCare Discharge Readmission Risk Decision* that you have already created. Select the **P_readmitted_30days1 ** & **risk_tier** variables and add it to the Rule Set - the **P_readmitted_30days1 ** variable is specified in the Rule Conditions column in the table below and the **risk_tier** variable has its own column as it gets assigned values.
     ![image-20260529164239556](img/README/image-20260529164239556.png)
4.   For the **P_readmitted_30days1 ** change it so that it is required as an input and then click on the save icon to add this change. The **risk_tier** currently doesn't have any value from the decision so we can just leave it as an output.
     ![image-20260529164320438](img/README/image-20260529164320438.png)
5.   Navigate to the *Rule set* tab and click on the *Add rule* button
     ![image-20260529164508583](img/README/image-20260529164508583.png)
6.   Change the operator from the default of equal to greater than and then enter the comparison in the *IF* condition, in the THEN assignment change the variable to **risk_tier** and enter the corresponding value into the field enclosed in single quotes.
     ![image-20260529164433028](img/README/image-20260529164433028.png)
7.   Next click on *Add rule* and click on the *IF* statement dropdown and change it to an *ELSE* condition. This will combine the additional condition into one rule. From here continue to enter all the rest of the conditions and assignments as listed below and once you are done click on the save icon and then either use the little *x* icon in the right hand corner or click on *** MedCare Discharge Readmission Risk Decision (1.0)* in the breadcrumb navigation up top to navigate back to the decision.
     ![image-20260529164659061](img/README/image-20260529164659061.png)

| Rule Conditions | risk_tier |
|-----------|-----------|
| P_readmitted_30days1 >= 0.80 | Critical |
| P_readmitted_30days1 >= 0.60 | High |
| P_readmitted_30days1 >= 0.40 | Moderate |
| P_readmitted_30days1 < 0.40 | Low |

**Rule Set: Care Plan Assignment**

| risk_tier | discharge_disposition | care_plan | follow_up_days |
|-----------|----------------------|-----------|----------------|
| Critical | Any | Intensive transitional care | 1 |
| High | Home | Home health referral + phone follow-up | 2 |
| High | SNF | SNF care coordination + pharmacy consult | 3 |
| High | Home Health | Enhanced home health with daily check-ins | 2 |
| Moderate | Any | Standard follow-up protocol | 5 |
| Low | Any | Routine discharge (continue monitoring) | 14 |

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

### 4. Ajouter un LLM

Nous allons maintenant ajouter un Large Language Model à notre décision. Pour cela, ouvrez le panneau latéral _Objects_ (icône carte postale) et glissez-déposez un nœud Call LLM sur le nœud _End_. Ajoutez ensuite les variables manquantes comme pour le nœud modèle (ne rendez pas le prompt obligatoire en entrée de la décision), puis cliquez sur l'icône de sauvegarde.

![image-20260529171156226](img/README/image-20260529171156226.png)

Vous pouvez maintenant soit ajouter le Rule Set _Prompt Assignment_ à la décision comme les autres Rule Sets, soit le créer vous-même. Si vous choisissez de le créer manuellement, ajoutez les variables suivantes de votre décision en entrée :

-   care_plan
-   follow_up_days
-   intervention
-   priority
-   reason
-   risk_tier

Et en sortie, ajoutez la variable prompt (n'oubliez pas de cliquer sur l'icône de sauvegarde). Passez ensuite à l'onglet _Rule set_, cliquez sur le bouton _Add other_, sélectionnez le type de règle _Assignment_ puis cliquez sur _OK_ : ici, nous ne voulons pas définir de condition, mais simplement renseigner notre prompt avec une valeur longue.
![image-20260529171254888](img/README/image-20260529171254888.png)

Ensuite, affectez la valeur du prompt en cliquant sur l'icône crayon. Dans l'_Expression Editor_, supprimez toutes les valeurs de l'éditeur principal puis copiez-collez la valeur ci-dessous. Cliquez sur le bouton _Save_, puis sur l'icône de sauvegarde du _Rule set_, et revenez à la décision principale.
```
prompt = CAT('You are a compassionate MedCare patient education specialist. Using the patient discharge data and care plan below, write a warm, respectful, and clearly structured long-form discharge summary (3 to 5 paragraphs) that a patient with no clinical background can read to understand their next steps after leaving the hospital. Do not expose clinical codes or jargon verbatim — translate them into plain, everyday language. Do not provide medical advice beyond what the care plan specifies, do not diagnose, and do not predict outcomes. Patient and care plan context: Assigned risk tier: ', risk_tier, '. Recommended care plan: ', care_plan, '. Specific intervention: ', intervention, '. First follow-up in (days): ', follow_up_days, '. Care coordination priority: ', priority, '. Internal reason code: ', reason, '. Structure your response as follows. First, open with a warm, personal acknowledgment that the patient is being discharged today and that MedCare is committed to supporting their recovery at home. Do not explicitly state the ', risk_tier, ' risk tier — instead, frame the care plan as tailored to their individual situation. Second, explain the recommended care plan ', care_plan, ' in plain language and describe what the patient can expect in the coming days. Third, explain the specific intervention ', intervention, ' — including who will reach out, what the purpose is, and why it matters for their recovery. Translate the internal reason ', reason, ' into an empathetic, plain-language explanation of why this extra level of support is being offered. Fourth, clearly communicate the follow-up timeline (within ', follow_up_days, ' days), what kind of follow-up it is, and what the patient needs to do to prepare. Reflect the ', priority, ' care coordination priority in the tone — more proactive and immediate for urgent priority, calmer and routine for standard priority. Fifth, close with clear guidance on warning signs that require immediate attention (calling 911 or going to the emergency room) and reassure the patient that their care team is available for questions. Tone: warm, respectful, reassuring, and never alarming or condescending. Length: 300 to 450 words. Write in the second person (you, your recovery). Always include a clear reminder to call 911 or go to the emergency room for any life-threatening symptoms.')
```

![image-20260529171608495](img/README/image-20260529171608495.png)

Il s'agit d'une approche très simplifiée du prompt engineering et elle ne vous permet pas de tester et comparer différents grands modèles de langage. C'est pourquoi SAS propose le projet open source [SAS Agentic AI Accelerator](https://github.com/sassoftware/sas-agentic-ai-accelerator), qui permet de connecter n'importe quel LLM et de faire du prompt engineering ainsi que du monitoring avancés. Ici, nous disposons d'un LLM codé en dur (OpenAI GPT 5.4).

### 5. Tester la décision

1. Dans la décision, cliquez sur l'onglet _Scoring_ puis sur le sous-onglet _Scenarios_

2. Cliquez sur le bouton _New test_
    ![image-20260529094624231](../../use-case-financial-services/5-deploy-and-act/img/README/image-20260529094624231.png)

3. Dans la fenêtre *New Scenario* laissez le nom par défualt, choisissez *My folder* comme emplacement et l'emplacement de a table dans votre *CASUSER*.

4. Saisissez des valeurs d'exemple :
   - clinical_risk_score: 3
   - comorbidity_count: 4
   - discharge_disposition: Home
   - discharged_home: 1
   - emergency_flag: 1
   - polypharmacy_flag: 1
   
   ![image-20260529171953925](img/README/image-20260529171953925.png)
   
5. Consultez la sortie en cliquant sur l'icône Results une fois que le _Status_ est passé à une coche verte

6.  N'hésitez pas à tester d'autres scénarios pour valider la logique :
   - Un patient à faible risque sortant à domicile devrait recevoir des instructions de sortie routinières
   - Un patient avec polypharmacie devrait déclencher une intervention de conciliation médicamenteuse
   - Un patient à risque critique avec 3+ comorbidités devrait être signalé comme priorité urgente avec des soins de transition intensifs

### 6. Publier la décision

1. Cliquez sur le boutton **Validate** puis sur **Publish** pour rendre la décision disponible par appel
2. Choisissez une **destination** :
   - **CAS** - pour le calcul par lots *(batch)* de l'ensemble du portefeuille de prêts
   - **MAS (Micro Analytic Service)** - pour les appels API en temps réel pendant le processus de demande de prêt - un seul est disponible ici !
   - **Container** -  pour déploiement dans le système d'octroi de prêts de la banque
3. Faites bien attention à lui attribuer un **nom unique**
4. Une fois publiée, la décision est disponible en tant qu'un point de terminaison *(endpoint)* de REST API

---

## Utilisation du Copilot de SAS Intelligent Decisioning 

Le Copilot de SAS Intelligent Decisioning est un assistant conversationnel qui peut répondre à des questions sur la documentation de **SAS Intelligent Decisioning**, **SAS Container Runtime**, et **SAS Micro Analytic Service**. Utilisez-le pour trouver rapidement des informations sur le fonctionnement de ces produits sans quitter l'application.

### Ce que le Copilot peut faire

- **Répondre à des questions de documentation** sur les fonctionnalités, concepts et workflows de SAS Intelligent Decisioning
- **Expliquer SAS Micro Analytic Service (MAS)**, ses options de déploiement, sa configuration et l'usage de ses API
- **Clarifier SAS Container Runtime** concernant la mise en place, la publication et la gestion
- **Vous aider à naviguer** dans les capacités du produit en décrivant le fonctionnement des fonctionnalités spécifiques
- **Fournir des conseils** sur les concepts de flux de décision, la configuration des rule sets et les options de publication basés sur la documentation officielle

### Exemples de prompts Copilot 

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
- *Quelles sont les options pour générer des codes d'action défavorable dans un flux de décision ?*
    - *"What are the options for generating adverse action codes in a decision flow?"*

Le Copilot est un outil de référence utile pour obtenir rapidement des réponses sur les capacités de la plateforme pendant que vous construisez vos flux de décision.

---

## Les décisions comme outils dans des workflows agentiques

Une décision SAS Intelligent Decisioning publiée est exposée via un **endpoint API REST**. Cela signifie qu'elle peut être appelée comme un **outil** par n'importe quel agent IA, y compris les agents basés sur des *large language models* (LLM) qui utilisent des capacités d'appel d'outils.

### Comment cela fonctionne

```
┌──────────────┐     ┌─────────────────────────┐     ┌────────────────┐
│   Agent IA   │────>│  SAS Intelligent        │────>│  Décision      │
│  (Loan       │     │  API de décision        │     │  de prêts      │
│   Officer    │     │  /decisions/loanApproval│     │  + Adverse     │
│   Agent)     │<────│                         │<────│  Action Codes  │
└──────────────┘     └─────────────────────────┘     └────────────────┘
```
**Exemple de scénario :** Un conseiller en prêts (titulaire d’un LLM) accompagne un demandeur tout au long du processus de demande en ligne. Le conseiller peut :

1. Recueillir les informations du demandeur via une interface conversationnelle.
2. **Appeler l'API SAS Intelligent Decisioning** avec les données de la demande.
3. Recevoir la réponse : " Refusé – AA01 : Score de crédit trop faible ; AA03 : Antécédents de retards de paiement ".
4. Communiquer la décision au demandeur en lui fournissant l'avis de refus requis.
5. Si la décision est « À examiner » *(Review)*, transmettre le dossier à un analyste de crédit avec l'évaluation complète des risques.

La décision devient un **outil** dans la boîte à outils de l'agent, comme une fonction de recherche de documents ou une recherche de clients. Cela crée un pont entre les modèles analytiques et l'IA conversationnelle dans une industrie fortement réglementée.

### Pourquoi c'est important

- **Cohérence :** Chaque interaction d'agent utilise la même logique de décision - aucune différence entre les agents de crédit ou les succursales
- **Gouvernance :** La décision est versionnée et auditable dans SAS Intelligent Decisioning, au lieu d'être enfouie dans le prompt système d'un LLM
- **Séparation des responsabilités :** Les data scientists pilotent le modèle, e risque de crédit définit les règles, la conformité définit les contraintes d'équité, et l'agent IA se contente d'appeler le point de terminaison *(endpoint)*.
- **Exécution en temps réel :** Les endpoints MAS répondent en millisecondes, suffisamment vite pour le traitement des applications en temps réel
---
## Les décisions comme workflows agentiques

Au-delà de leur rôle d'outils appelables, SAS Intelligent Decisioning peut lui-même orchestrer des **workflows agentiques** : des processus en plusieurs étapes qui exécutent de façon autonome une chaîne de décisions et d'actions.

### Comment une décision devient un agent

Un flux de décision agentique va au-delà d'un simple "entrée → règles → sortie". Il peut :

1. **Observer :** Recevoir un événement déclencheur (par ex. un patient a été sorti et aucun rendez-vous de suivi n’est programmé dans les 48 heures))
2. **Raisonner :** Évaluer le risque de réadmission du patient, vérifier son plan de soins, examiner le statut de la conciliation médicamenteuse
3. **Décider :** Sélectionner l’action d’escalade appropriée à partir des ensembles de règles
4. **Agir :** Déclencher des actions en aval — planifier un appel de suivi, alerter le gestionnaire de soins, envoyer un message via le portail patient, créer une tâche dans le dossier médical électronique (DME)
5. **Surveiller :** Suivre si le patient participe au suivi, renouvelle ses médicaments ou présente des signes de détérioration — et réinjecter ce résultat dans les décisions futures

### Exemple : Agent de surveillance automatisée de portefeuille
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

C'est **agentique** parce que le système, de manière autonome :
- Détecte la condition de déclenchement (fenêtre de suivi manquée)
- Prend des décisions sans intervention humaine
- Exécute des actions dans le monde réel
- Apprend à partir des résultats 

### Passage à l'échelle de la décision agentique

En environnement de production, ce workflow agentique peut traiter **des centaines de sorties par jour** sans intervention manuelle :

- **Mode batch:** Chaque matin, évaluer tous les patients sortis au cours des dernières 24 heures, identifier ceux à haut risque, déclencher des actions de coordination des soins
- **Mode événementiel:** Dès qu’un patient est sorti, déclencher le flux en temps réel à partir de l’événement de sortie du DSE
- **Chaînage multi-décisions :**  Un flux de décision en déclenche un autre: par exemple, la décision sur le risque de réadmission appelle une décision de "priorité de conciliation médicamenteuse", qui appelle une décision d’"optimisation de la planification du suivi ".
- 
Copilot said: SAS Intelligent Decisioning fournit la couche d’orchestration qui transforme des modèles et des règles individuels en **agents cliniques autonomes à l’échelle de l’entreprise**.

---

## Résumé

Dans cette étape, vous avez :
1. **Créé un flux de décision** qui combine votre modèle de réadmission avec des règles cliniques pour produire des recommandations de plan de soins exploitables à la sortie  
2. **Ajouté un appel à un LLM** qui transforme la décision en un résumé de sortie compréhensible pour le patient  
3. **Utilisé le Copilot** pour obtenir des réponses sur SAS Intelligent Decisioning, MAS et la documentation Container Runtime  
4. **Publié la décision** comme un endpoint API appelable  
5. **Appris comment les décisions fonctionnent comme des outils** pour des agents de support à la décision clinique alimentés par LLM  
6. **Exploré des workflows agentiques** où les décisions détectent, raisonnent, décident et agissent de manière autonome dans le suivi post-sortie

---

## Félicitations !

Vous avez terminé l'ensemble du cycle de vie Data & IA pour le cas d'usage service financier :

| Étape           | Ce que vous avez fait                                         | Technologie SAS                       |
| --------------- | ------------------------------------------------------------- | ------------------------------------- |
| 1. Ask & Access | Compréhension du problème, génération de données synthétiques | SAS Data Maker                        |
| 2. Prepare      | Chargement, profilage et jointure des données dans un ABT     | SAS Viya Workbench                    |
| 3. Explore      | Exploration visuelle des schémas avec assistance IA           | SAS Visual Analytics + Copilot        |
| 4. Model        | Construction, comparaison et test d'équité des modèles        | SAS Model Studio + Copilot            |
| 5. Deploy & Act | Opérationnalisation via des décisions automatisées            | SAS Intelligent Decisioning + Copilot |

S'il vous reste du temps, explorez un autre cas d'usage ou approfondissez n'importe quelle étape. Échangez avec votre mentor bootcamp pour des sujets de suivi ou pour partager vos retours.
