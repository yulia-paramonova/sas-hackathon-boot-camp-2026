# Step 1: Ask & Access

Welcome to **MedCare Health System**, a fictional regional healthcare network. In this step you will gain insights into the current business challenges, learn about the value of synthetic data in healthcare, and pull your data into **SAS Data Maker** to generate a synthetic version of the dataset.

---

## Regulatory Context

Healthcare analytics operate under strict regulatory and ethical oversight. Key regulations that apply to this use case include:

| Regulation | What It Requires |
|-----------|-----------------|
| **HIPAA** (Health Insurance Portability and Accountability Act) | Protects patient health information; requires safeguards for PHI access, use, and disclosure |
| **HITECH Act** | Strengthens HIPAA enforcement; requires breach notification for unsecured PHI |
| **CMS HRRP** (Hospital Readmissions Reduction Program) | Penalizes hospitals with excess readmissions for specific conditions; directly motivates this use case |
| **Joint Commission Standards** | Requires evidence-based care transition processes and quality measurement |

These regulations mean that beyond building an accurate model, the analytics workflow must protect patient privacy, produce clinically interpretable outputs, and support the quality improvement documentation required by CMS and accreditation bodies.

---

## The Value of Synthetic Data

Synthetic data is artificially generated data that mirrors the statistical properties, patterns, and structure of real-world data — without containing any actual records from the original dataset. It is produced using generative models that learn the distributions, correlations, and relationships present in real data and then create entirely new records that are statistically representative but not traceable back to any individual. In recent years, synthetic data has become a critical tool across industries as organizations face growing pressure around data privacy, regulatory compliance, and the practical challenge of getting enough high-quality data for analytics and machine learning.

For a use case like patient readmission prediction at MedCare Health System, synthetic data offers several concrete benefits that are especially important in healthcare. First and foremost, it enables teams to develop, test, and iterate on models without exposing Protected Health Information (PHI) — a fundamental requirement under HIPAA. Real patient records containing diagnoses, medications, vital signs, and insurance information are among the most sensitive data categories that exist; synthetic generation eliminates re-identification risk entirely, allowing analysts, data scientists, and external collaborators to work freely without Business Associate Agreements or de-identification pipelines. Second, synthetic data can augment underrepresented clinical scenarios: if the dataset contains very few readmissions among patients with rare diagnosis categories or unusual comorbidity combinations, synthetic generation can produce additional realistic examples to improve model training for these edge cases. Third, it enables multi-site collaboration — hospitals across the MedCare network, external research partners, and technology vendors can all work with realistic clinical data without the legal and ethical overhead of sharing actual patient records. Finally, synthetic data supports clinical simulation: what if readmission rates doubled for cardiac patients? What if a new high-risk medication class entered formulary? These scenarios can be modeled synthetically before they materialize, enabling proactive care pathway design.

---

## Working with SAS Data Maker

[SAS Data Maker](https://www.sas.com/en_us/software/data-maker.html) is the SAS platform for generating high-quality synthetic data. In this section you will pull the MedCare datasets into SAS Data Maker and create a synthetic version that preserves the statistical relationships across all four tables.

### Log into SAS Data Maker

The SAS Hackathon Bootcamp mentors will provide you with three links, a username and a password. Your username and password are consistent across all three environments. In order to access SAS Data Maker please enter the link that contains the word Data Maker. Here you will be asked to sign in using an Username/E-Mail and then enter a password - these are the once provided to you by the mentors. Please note if you have a SAS Communities profile do not log in using those credentials and if you see an error trying to log in, try to use an incognito browser tab, as you might still be logged into SAS somewhere.

### Generating Synthetic Data with SAS Data Maker

Follow these steps to create your synthetic dataset:

#### 1. Create a Project

1. Open **SAS Data Maker**
2. Click **New project** to start a new project
3. Give it a descriptive name, e.g., *MedCare Readmission — Synthetic Generation*
    ![image-20260529104507157](img/README/image-20260529104507157.png)

#### 2. Import Source Data

1. Within your data plan, click **Add Data Source**
2. Navigate to the `Bootcamp/use-case-life-sciences/data` folder
3. This will import all four CSV files:
   - `patients.csv` — this is your primary entity table
   - `admissions.csv` — related table linked by `patient_id`
   - `clinical_measures.csv` — related table linked by `patient_id`
   - `medications.csv` — child table linked by `patient_id` (multiple medications per patient)
4. SAS Data Maker will profile each table and display column types, distributions, and summary statistics

![image-20260529104609945](img/README/image-20260529104609945.png)

Next you will see a loading bar like the one below that, this should finish in less than two minutes - feel free to start reading the next step already while you wait for this to finish:

![image-20260529104639475](img/README/image-20260529104639475.png)

#### 3. Define Relationships

The job that ran to understand the tables also will try to resolve the relationships between the tables. Please review that the relationship is mapped correctly. Your goal is to map a relationship that looks like the one below, but initially it will not look like.

![image-20260529104744233](img/README/image-20260529104744233.png)

In order to connect the tables correctly please click on each table and then on the right hand side under *Foreign keys* change the *Key* and *Target* values as described below

1. For `patients` set `patient_id` as the Primary key
2. For `admissions` set `admission_id` as the Primary key and `patient_id` as the Foreign key mapping to `patients`
3. For `medications` set `medication_id` as the Primary key and `patient_id` as the Foreign key
4. For `clinical_measures` set `patient_id` as the Primary key
    ![image-20260529104949949](img/README/image-20260529104949949.png)
5. All tables are of the type Tabular
6. Review the key relationships between the tables:
   - `admissions.patient_id` -> `patients.patient_id`
   - `clinical_measures.patient_id` -> `patients.patient_id`
   - `medications.patient_id` -> `patients.patient_id`
7. Now switch to the *Columns* tab to adjust the *Semantic type* for the three columns in the `medications` table `medication_name`, `medication_class` & `dosage` to the type `Category`
    ![image-20260529105336594](img/README/image-20260529105336594.png)
8. These relationships ensure that the synthetic data maintains referential integrity — every synthetic admission will belong to a valid synthetic patient

#### 4. Training Settings

1.   **Random state**, is optional and can be set to a seed variable. Why not try a classic like 42?
2.   **Model type**, we can choose between `PrivBayes` and `SMOTE` , we will be using PrivBayes here to make use of the differential privacy feature
3.   **Use differential privacy**, this will help us to reduce the privacy impact on each individual in the data. Increasing the privacy is a great way to enhance your Trustworthy AI as it increases the trust in you as a data processor
4.   The rest of the values we can leave at the default values and click the Start training button. If you want to feel free to explore the options though in more detail there is inline hints, or reach out to one of the SAS Mentors on site.
5.   The training process will take a moment and once it is done and all the metrics are calculated we can move to the next step which is `Evaluation`

![image-20260529105403150](img/README/image-20260529105403150.png)

#### 5. Evaluation

On the Evaluation tab we get a lot of insights into our Synthetic Data Generation Model, how it compares to the input sources and not just on a per table basis but also across the different tables.

![image-20260529105834928](img/README/image-20260529105834928.png)

Please take your time and explore these results to gain an understanding of how closely the synthetic data will match the original data sources. Feel free to discuss these results in the group and also reach out to SAS Mentors on site if you have question or consult the [SAS Documentation](https://go.documentation.sas.com/doc/en/sdgcdc/v_001/sdgug/p0ki9glx7acxpyn1wttognicd7qi.htm).

#### 6. Generation

1. **Output destination**, select the path `datamakerdemodata:output` here and set the *Output format* to one that you prefer (for example *parquet*)
2. Leave all other options at default and click the Generate button
    ![image-20260529105918393](img/README/image-20260529105918393.png)
3. Now a generation job is triggered that will create the synthetic data for each table for us and make that 
4. Once the generation has finished we get a summary of everything, a note on where the data is stored and a sample of the synthetic data. The generated data is stored onto a blob storage, don't worry you will not have to download anything onto your laptop as we will provide the data already available in SAS Viya and SAS Viya Workbench so that you can get to work.

![image-20260529110103425](img/README/image-20260529110103425.png)

---

## Next Steps

Proceed to **[Step 2: Prepare](../2-prepare/)** to load, profile, and join the data into an analytical base table using SAS Viya Workbench.
