# Step 1: Ask & Access

Welcome to **Metro City**, a fictional municipality serving 850,000 residents across 12 districts. In this step you will gain insights into the current service delivery challenges, learn about the value of synthetic data in the public sector, and pull your data into **SAS Data Maker** to generate a synthetic version of the dataset.

---

## Regulatory Context

Public sector analytics operate under transparency, equity, and accountability requirements. Key regulations and policies that apply to this use case include:

| Regulation / Policy | What It Requires |
|--------------------|-----------------|
| **Public Records Act / FOIA** | Government data and algorithmic decision-making processes may be subject to public disclosure requests |
| **ADA** (Americans with Disabilities Act) | Service delivery must be accessible; model-driven triage must not disadvantage residents with disabilities |
| **Algorithmic Accountability Policies** | Many municipalities require impact assessments for automated decision systems that affect public services |
| **Title VI of the Civil Rights Act** | Prohibits discrimination in programs receiving federal funding; applies to service delivery equity |

These requirements mean that the model must not only be accurate — it must be **transparent, auditable, and demonstrably equitable** across all districts and demographics.

---

## The Value of Synthetic Data

Synthetic data is artificially generated data that mirrors the statistical properties, patterns, and structure of real-world data — without containing any actual records from the original dataset. It is produced using generative models that learn the distributions, correlations, and relationships present in real data and then create entirely new records that are statistically representative but not traceable back to any individual. In the public sector, where data is often subject to stringent regulatory requirements, synthetic data has become an essential tool for responsible innovation.

For a use case like citizen service request prioritization at Metro City, synthetic data offers several concrete benefits. First, it enables teams to develop, test, and iterate on models without exposing real citizen information — a crucial consideration when dealing with personally identifiable information subject to the Public Records Act and privacy regulations. Citizen addresses, complaint details, and interaction histories are sensitive; synthetic generation allows analysts, contractors, and cross-agency partners to work with realistic data without the overhead of data access agreements or redaction pipelines. Second, synthetic data supports equity testing: by generating scenarios with varying district-level distributions, teams can stress-test whether models perform fairly across all neighborhoods before deploying them on real populations. Third, it enables simulation of scenarios that may not yet exist in the data — such as a sudden spike in emergency requests during a natural disaster, or the impact of adding staff to an understaffed department. These "what-if" analyses can inform resource allocation and policy decisions before they are needed. Finally, synthetic data makes hackathons and training exercises like this one possible: participants can explore realistic municipal data patterns without any risk to actual citizens.

---

## Working with SAS Data Maker

[SAS Data Maker](https://www.sas.com/en_us/software/data-maker.html) is the SAS platform for generating high-quality synthetic data. In this section you will pull the PremierBank datasets into SAS Data Maker and create a synthetic version that preserves the statistical relationships across all four tables.

### Log into SAS Data Maker

The SAS Hackathon Bootcamp mentors will provide you with three links, a username and a password. Your username and password are consistent across all three environments. In order to access SAS Data Maker please enter the link that contains the word Data Maker. Here you will be asked to sign in using an Username/E-Mail and then enter a password - these are the once provided to you by the mentors. Please note if you have a SAS Communities profile do not log in using those credentials and if you see an error trying to log in, try to use an incognito browser tab, as you might still be logged into SAS somewhere.

### Generating Synthetic Data with SAS Data Maker

#### 1. Create a Project

1. Open **SAS Data Maker**
2. Click **New project** to start a new project
3. Give it a descriptive name, e.g., *Metro City Service Requests — Synthetic Generation*

![image-20260529135847400](img/README/image-20260529135847400.png)

#### 2. Import Source Data

1. Within your data plan, click **Add Data Source**

2. Navigate to the `Bootcamp/use-case-public-sector/csv` folder

3. This will import all four CSV files:
   - `service_requests.csv` — this is your primary request-level table
   - `citizens.csv` — related table linked by `citizen_id`
   - `department_performance.csv` — aggregate reference table linked by `department`
   - `request_history.csv` — aggregate reference table for historical trends

4. SAS Data Maker will profile each table and display column types, distributions, and summary statistics![image-20260529135940784](img/README/image-20260529135940784.png)

    Next you will see a loading bar like the one below that, this should finish in less than two minutes - feel free to start reading the next step already while you wait for this to finish:

    ![image-20260529140021786](img/README/image-20260529140021786.png)

    

5. Review the **Columns** tab for each table. For `service_requests` you will notice that the `request_type` column has no semantic type set (shown as *(Not set)* with a red indicator). Click that cell and set its semantic type to **Category** — otherwise training will fail with the error *"The semantic type must be set, or the column should be dropped."*

#### 3. Define Relationships

The job that ran to understand the tables also will try to resolve the relationships between the tables. Please review that the relationship is mapped correctly. Your goal is to map a relationship that looks like the one below, but initially it will not look like.

![image-20260529141405534](img/README/image-20260529141405534.png)

In order to connect the tables correctly please click on each table and then on the right hand side under *Foreign keys* change the *Key* and *Target* values as described below

1. For `citizens` set `citizen_id` as the Primary key
2. For `service_requests` set `request_id` as the Primary key and `citizen_id` as the Foreign key
3. `department_performance` and `request_history` are aggregate reference tables - so change their table type to *Reference*
    ![image-20260529141531993](img/README/image-20260529141531993.png)
4. All other tables are of the type Tabular
5. Now switch to the *Columns* tab to adjust the *Semantic type* for one columns in the `service_requests` table `request_type` to `Category`
   ![image-20260529141702643](img/README/image-20260529141702643.png)
6. These relationships ensure that the synthetic data maintains referential integrity — every synthetic service request will belong to a valid synthetic citizen and reference a valid department

#### 4. Training Settings

1.   **Random state**, is optional and can be set to a seed variable. Why not try a classic like 42?
2.   **Model type**, we can choose between `PrivBayes` and `SMOTE` , we will be using PrivBayes here to make use of the differential privacy feature
3.   **Use differential privacy**, this will help us to reduce the privacy impact on each individual in the data. Increasing the privacy is a great way to enhance your Trustworthy AI as it increases the trust in you as a data processor
4.   The rest of the values we can leave at the default values and click the Start training button. If you want to feel free to explore the options though in more detail there is inline hints, or reach out to one of the SAS Mentors on site.
5.   The training process will take a moment and once it is done and all the metrics are calculated we can move to the next step which is `Evaluation`

![image-20260529141437724](img/README/image-20260529141437724.png)

#### 5. Evaluation

On the Evaluation tab we get a lot of insights into our Synthetic Data Generation Model, how it compares to the input sources and not just on a per table basis but also across the different tables.

![image-20260529141727038](img/README/image-20260529141727038.png)

Please take your time and explore these results to gain an understanding of how closely the synthetic data will match the original data sources. Feel free to discuss these results in the group and also reach out to SAS Mentors on site if you have question or consult the [SAS Documentation](https://go.documentation.sas.com/doc/en/sdgcdc/v_001/sdgug/p0ki9glx7acxpyn1wttognicd7qi.htm).

#### 6. Generation

1. **Output destination**, select the path `datamakerdemodata:output` here and set the *Output format* to one that you prefer (for example *parquet*)
2. Leave all other options at default and click the Generate button
    ![image-20260529141801238](img/README/image-20260529141801238.png)
3. Now a generation job is triggered that will create the synthetic data for each table for us and make that 
4. Once the generation has finished we get a summary of everything, a note on where the data is stored and a sample of the synthetic data. The generated data is stored onto a blob storage, don't worry you will not have to download anything onto your laptop as we will provide the data already available in SAS Viya and SAS Viya Workbench so that you can get to work.

![image-20260529141951073](img/README/image-20260529141951073.png)

---

## Next Steps

Proceed to **[Step 2: Prepare](../2-prepare/)** to load, profile, and join the data into an analytical base table using SAS Viya Workbench.
