# Step 2: Prepare

In this step you will work in **SAS Studio** to load the four PremierBank datasets, profile them, and join them into a single **Analytical Base Table (ABT)** that is ready for exploration in SAS Visual Analytics and modeling in SAS Model Studio.

SAS Studio gives you the freedom to code in the language of your choice or build a visual flow. We provide equivalent code in **SAS**, **Python**, and **R** — pick the one you are most comfortable with or try all three.

---

## Accessing the Data

The four CSV files are available in the same folder structure from Step 1:

```
SAS-Hackathon-Bootcamp-2026/use-case-retail/data
├── customers.csv          (1,000 records)
├── transactions.csv       (~5,000 records)
├── sessions.csv           (~10,000 records)
└── support_tickets.csv    (~400 records)
```

---

## What You Will Do

### 1. Load the Data & Use Cases

Now as the first step you will clone the GitHub repository to your SAS Studio environment by first opening up a SAS program and running the below code which will clone the repository to the file system:

```SAS
data _null_;
    rc = git_clone('https://github.com/sascommunities/sas-hackathon-boot-camp-2026.git', "&_USERHOME./sas-hackathon-boot-camp-2026");
run;
```

Once you have run this code snippet navigate to the SAS Server pane and the expand the *SAS Server > Home > data > sas-hackathon-bootcamp-2026* from here the familiar structure of this repository are available.

![image-20260528135335744](img/SAS-Studio/image-20260528135335744.png)

### 2. Create a Data Card

A **data card** is a concise summary document that describes each dataset — its purpose, size, column names, data types, and any quality notes. Data cards are a best practice in responsible AI because they provide transparency about the data flowing into models. For each table you will produce:

- Number of rows and columns
- Column names with data types
- Count of missing values per column
- Sample rows

### 3. Get Basic Summary Statistics

For numeric columns, compute descriptive statistics (mean, median, standard deviation, min, max). For categorical columns, compute frequency counts. This gives you a first look at distributions and potential data quality issues before you begin feature engineering.

### 4. Engineer Features and Build the Analytical Base Table

The four datasets each capture a different dimension of loan risk. To build a predictive model we need to aggregate these into a single loan-level table where each row is one loan and each column is a feature. The key transformations are:

- **Transaction features:** total spend, average order value, purchase frequency, days since last purchase, product category diversity
- **Session features:** total sessions, average session duration, pages viewed, cart abandonment rate, mobile usage rate
- **Support features:** total tickets, high-priority ticket count, average resolution time, satisfaction score
- **Customer features:** age, account age, subscription tier, email opt-in status

The final ABT will be saved as a CSV file that can then be promoted into CAS for use in SAS Visual Analytics and SAS Model Studio.

---

## Choose Your Language

Pick **one** language and run its script. You do not need to run all three — they each produce the same output. If you are unsure which to choose, pick the one you are most comfortable with.

| Language   | File                                                         |
| ---------- | ------------------------------------------------------------ |
| **SAS**    | [`data_preparation_studio.sas`](data_preparation_studio.sas) |
| **Python** | [`data_preparation_studio.py`](data_preparation_studio.py)   |
| **R**      | [`data_preparation_studio.R`](data_preparation_studio.R)     |

All three scripts produce the same output: a file called **`retail_abt.csv`** in the `data/` folder. After the script finishes, **refresh the Explorer pane** to see the new file.

---

## Output

After running any of the scripts you will have:

| File | Description |
|------|-------------|
| `data/retail_abt.csv` | The joined, feature-engineered, customer-level dataset ready for modeling |
| Console output | Data card information, summary statistics, and churn distribution for review |

---

## Next Steps

Proceed to **[Step 3: Explore](../3-explore/)** to visually explore the data in SAS Visual Analytics using its built-in Copilot.
