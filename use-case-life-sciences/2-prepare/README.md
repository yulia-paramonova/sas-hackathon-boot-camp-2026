# Step 2: Prepare

In this step you will work in **SAS Viya Workbench** to load the four MedCare datasets, profile them, and join them into a single **Analytical Base Table (ABT)** that is ready for exploration in SAS Visual Analytics and modeling in SAS Model Studio.

SAS Viya Workbench gives you the freedom to code in the language of your choice. We provide equivalent code in **SAS**, **Python**, and **R** — pick the one you are most comfortable with or try all three.

---

## Accessing the Data

The four CSV files are available in the same folder structure from Step 1:

```
SAS-Hackathon-Bootcamp-2026/use-case-life-sciences/data
├── patients.csv          (500 records)
├── admissions.csv        (500 records)
├── clinical_measures.csv (500 records)
└── medications.csv       (326 records)
```

---

## What You Will Do

### 1. Setup your Environment in SAS Viya Workbench

Once you are logged into SAS Viya Workbench you will first have to chose the programming environment that you want to use and which languages. Once you do that a second tab will open up and you will have to wait for moment until the programming environment shows up. ![image-20260527164013080](img/README/image-20260527164013080.png)

### 2. Load the Data & Use Cases

Now as the first step you will clone the GitHub repository to your SAS Viya Workbench environment by first opening up a terminal and running the git clone command below: 

```bash
git clone https://github.com/sascommunities/sas-hackathon-boot-camp-2026.git
```

If you are in Visual Studio Code you can try to either use the keyboard shortcut CTRL+´ or if that doesn't work for you follow the click path in the screenshot below:

![image-20260527164702224](img/README/image-20260527164702224.png)

After you have run the git clone command you should the following folder structure and from there just navigate to your use case and the 2-prepare to see the files.

![image-20260527170112447](img/README/image-20260527170112447.png)

### 3. Create a Data Card

A **data card** is a concise summary document that describes each dataset — its purpose, size, column names, data types, and any quality notes. Data cards are a best practice in responsible AI because they provide transparency about the data flowing into models. For each table you will produce:

- Number of rows and columns
- Column names with data types
- Count of missing values per column
- Sample rows

### 4. Get Basic Summary Statistics

For numeric columns, compute descriptive statistics (mean, median, standard deviation, min, max). For categorical columns, compute frequency counts. This gives you a first look at distributions and potential data quality issues before you begin feature engineering.

### 5. Engineer Features and Build the Analytical Base Table

The four datasets each capture a different dimension of the patient encounter. To build a predictive model we need to aggregate these into a single patient-level table where each row is one patient and each column is a feature. The key transformations are:

- **Medication features:** total medication count per patient, high-risk medication count, polypharmacy flag (5+ medications), unique medication classes
- **Clinical features:** BMI categories (underweight/normal/overweight/obese), blood pressure classification (normal/elevated/hypertension stage 1/hypertension stage 2), glucose level categories, clinical risk score
- **Admission features:** length of stay categories (short/medium/long), emergency admission flag, discharge disposition encoding
- **Patient features:** age, gender, insurance type, primary diagnosis category, comorbidity count

The final ABT will be saved as a CSV file that can then be promoted into CAS for use in SAS Visual Analytics and SAS Model Studio.

---

## Choose Your Language

Pick **one** language and run its script. You do not need to run all three — they each produce the same output. If you are unsure which to choose, pick the one you are most comfortable with.

| Language | File | How to Run |
|----------|------|------------|
| **SAS** | [`data_preparation.sas`](data_preparation.sas) | Open the file and click the **Run** button in the toolbar above the editor |
| **Python** | [`data_preparation.py`](data_preparation.py) | Open the file and click the **Run** button in the toolbar above the editor |
| **R** | [`data_preparation.R`](data_preparation.R) | R scripts do not have a toolbar Run button. Open a terminal (*Terminal > New Terminal*) and run: `Rscript data_preparation.R` |

All three scripts produce the same output: a file called **`life_sciences_abt.csv`** in the `data/` folder. After the script finishes, **refresh the Explorer pane** to see the new file.

---

## Output

After running any of the scripts you will have:

| File | Description |
|------|-------------|
| `data/life_sciences_abt.csv` | The joined, feature-engineered, patient-level dataset ready for modeling |
| Console output | Data card information, summary statistics, and readmission distribution for review |

---

## Next Steps

Proceed to **[Step 3: Explore](../3-explore/)** to visually explore the data in SAS Visual Analytics using its built-in Copilot.
