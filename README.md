# 🏦 BFSI Loan Risk & Portfolio Analytics

![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow?logo=powerbi)
![Python](https://img.shields.io/badge/Python-3.12.4-blue?logo=python)
![MySQL](https://img.shields.io/badge/MySQL-Star%20Schema-orange?logo=mysql)
![BigQuery](https://img.shields.io/badge/BigQuery-Cloud%20Warehouse-blue?logo=googlebigquery)
![dbt](https://img.shields.io/badge/dbt-1.11-orange?logo=dbt)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

A comprehensive **Data Analytics project** built on 1.34 million real-world loan records from the Lending Club dataset. This project covers the full data analyst pipeline — from raw data cleaning to a 4-page interactive Power BI dashboard — with a focus on loan default risk, portfolio health, and actionable business recommendations for a BFSI (Banking, Financial Services & Insurance) context.

Extended with a **cloud data warehouse layer** using Google BigQuery and a **dbt transformation pipeline** (staging → intermediate → marts), with the Power BI dashboard reconnected to run live off the cloud layer.

---

## 🔗 Links

| Resource | Link |
|---|---|
| 📊 Live Dashboard (NovyPro) | [View Dashboard](https://novypro.com/project/bfsi-loan-risk--portfolio-analytics) |
| 💼 LinkedIn | [Shreenivas S B](https://www.linkedin.com/in/shreenivas-s-b-22b48a31a/) |
| 🐙 GitHub Profile | [ShreenivasSB](https://github.com/ShreenivasSB) |

---

## 📌 Project Objective

To analyze a large-scale BFSI loan dataset and identify key risk drivers behind loan defaults — across loan grades, DTI bands, income segments, and loan purposes — and present findings through a professional Power BI dashboard with clear business recommendations.

> ⚠️ This is a **Data Analyst** project. No machine learning or predictive modeling is used. All insights are derived from statistical analysis, SQL queries, and visual storytelling.

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| Python 3.12.4 | Data cleaning, feature engineering, EDA, statistical validation, BigQuery data load |
| MySQL | Local star schema design, SQL query library, query benchmarking |
| Google BigQuery | Cloud data warehouse — free tier (10 GB storage, 1 TB queries/month) |
| dbt 1.11 | 3-layer transformation pipeline: staging → intermediate → marts |
| Power BI Desktop | 4-page interactive dashboard — reconnected to BigQuery |
| VS Code | Python scripting and development environment |

---

## 📂 Project Structure

```
BFSI_Loan_Analytics/
│
├── assets/
│   └── screenshots/
│
├── data/
│   ├── raw/
│   │   ├── accepted_2007_to_2018Q4.csv.gz   # Original raw dataset
│   │   └── lending_club_loans.csv            # Raw CSV
│   └── processed/                            # Cleaned & engineered CSVs
│
├── notebooks/
│   ├── 01_data_quality_audit.ipynb           # Data cleaning (1,342,942 rows, 0 nulls)
│   ├── 02_feature_engineering.ipynb          # Feature engineering (91 columns)
│   ├── 03_eda.ipynb                          # Exploratory Data Analysis (6 charts)
│   ├── 04_statistical_validation.ipynb       # 4 statistical tests
│   └── 05_mysql_ingestion.ipynb              # MySQL star schema loading
│
├── sql/
│   ├── query_library.sql                     # 6 analytical SQL queries
│   └── explain_benchmarks.md                 # Query performance benchmarks
│
├── dbt/
│   └── bfsi_dbt/
│       ├── dbt_project.yml
│       └── models/
│           ├── sources.yml                   # BigQuery raw source definition
│           ├── staging/
│           │   └── stg_loans.sql             # Column renaming, type casting
│           ├── intermediate/
│           │   └── int_loans_enriched.sql    # Surrogate key generation
│           └── marts/
│               ├── fact_loans.sql            # 1,342,942 row fact table
│               ├── dim_grade.sql             # 7 rows
│               ├── dim_purpose.sql           # 14 rows
│               ├── dim_income_band.sql       # 4 rows
│               ├── dim_dti_band.sql          # 5 rows
│               ├── dim_risk_tier.sql         # 3 rows
│               └── schema.yml                # 37 data quality tests
│
├── scripts/
│   └── load_to_bigquery.py                   # CSV → BigQuery raw loader
│
├── powerbi/
│   └── BFSI_loan_dashboard.pbix              # 4-page Power BI dashboard (BigQuery)
│
├── .gitignore
└── README.md
```

---

## 📊 Dataset Overview

| Metric | Value |
|---|---|
| Total Loan Records | 1,342,942 |
| Total Defaults | 266,236 |
| Overall Default Rate | 19.82% |
| Total Loan Amount | $19,363,913,475 |
| Features after Engineering | 91 columns |
| Null Values after Cleaning | 0 |

---

## 🗄️ Star Schema (MySQL + BigQuery)

Designed a **star schema** with 6 tables — built first in MySQL, then replicated in Google BigQuery via dbt:

| Table | Rows | Description |
|---|---|---|
| fact_loans | 1,342,942 | Core loan fact table |
| dim_grade | 7 | Loan grades A through G |
| dim_purpose | 14 | Loan purpose categories |
| dim_income_band | 4 | Income segment buckets |
| dim_dti_band | 5 | DTI range buckets |
| dim_risk_tier | 3 | Low / Medium / High risk tiers |

---

## ☁️ Cloud + dbt Extension

### Architecture

```
lending_club_features.csv (local)
        ↓  [scripts/load_to_bigquery.py]
BigQuery: raw.raw_loans  (1,342,942 rows, 91 cols)
        ↓
dbt staging:      stg_loans             — column renaming, type casting (view)
        ↓
dbt intermediate: int_loans_enriched    — surrogate loan_id via ROW_NUMBER() (table)
        ↓
dbt marts:        fact_loans + 5 dims   — star schema rebuilt in BigQuery (tables)
        ↓
Power BI Dashboard (Import mode from bfsi_loans dataset)
```

### BigQuery Datasets

| Dataset | Contents |
|---|---|
| `raw` | `raw_loans` — source table loaded from CSV |
| `bfsi_loans_staging` | `stg_loans` view |
| `bfsi_loans_intermediate` | `int_loans_enriched` table |
| `bfsi_loans` | `fact_loans` + 5 dimension tables — Power BI connects here |

### dbt Data Quality Tests — 37/37 Passing

| Test Type | Count | What it checks |
|---|---|---|
| `not_null` | 16 | Key columns never empty |
| `unique` | 11 | Primary keys on all dimension tables |
| `relationships` | 5 | FK integrity — every fact row resolves to a valid dimension |
| `accepted_values` | 5 | `loan_outcome` ∈ {0,1}, `grade` ∈ {A–G} |

---

## 📈 Key Findings

### 1. Loan Grade Risk
| Grade | Default Rate |
|---|---|
| A | 5.97% |
| G | 49.50% |

- Grades E–G represent only **10% of the portfolio** but contribute **20.5% of all defaults**
- Grade G defaults at nearly **8.3x higher** than Grade A

### 2. DTI Band Risk
| DTI Band | Default Rate |
|---|---|
| DTI 0–10 | 14.66% |
| DTI 25+ | 26.64% |

- DTI above 25 carries a **1.82x default multiplier** vs DTI below 10

### 3. Risk Tier Analysis
| Risk Tier | Default Rate |
|---|---|
| Low Risk | 10.55% |
| Medium Risk | 25.03% |
| High Risk | 40.59% |

- High Risk borrowers default at **3.8x the rate** of Low Risk borrowers

### 4. Loan Purpose
| Purpose | Default Rate |
|---|---|
| Small Business | 29.43% (Highest) |
| Wedding | 11.66% (Lowest) |

### 5. Income vs Default
| Income Band | Default Rate |
|---|---|
| Low Income | 23.11% |
| Very High Income | 16.04% |

- Low income borrowers with DTI 25+ default at **28.03%** — the most vulnerable segment

### 6. Yearly Trend
- Peak default year: **2016 at 23.15%**

---

## 📋 Power BI Dashboard — 4 Pages

### Page 1: Portfolio Overview
![Page 1](assets/screenshots/page1_portfolio_overview.png)

- 4 KPI cards: Total Loans, Total Defaults, Default Rate %, Total Loan Amount
- Default Rate % by Loan Purpose (bar chart)
- Default Rate % by Income Band (bar chart)
- Loan Count by Risk Tier (bar chart)

---

### Page 2: Risk Intelligence
![Page 2](assets/screenshots/page2_risk_intelligence.png)

- Default Rate % by Risk Tier
- Default Rate % by Income Band × DTI Band (matrix)
- Key risk insights text box

---

### Page 3: Portfolio Health Deep Dive
![Page 3](assets/screenshots/page3_portfolio_health.png)

- Default Rate % by Grade (A: 5.97% → G: 49.50%)
- Default Rate % by Issue Year (peak 2016: 23.15%)
- Default Rate % by DTI Band (DTI 0–10: 14.66% vs DTI 25+: 26.64%)

---

### Page 4: Business Recommendations
![Page 4](assets/screenshots/page4_business_recommendations.png)

- 4 actionable recommendations backed by exact data findings

---

## 💼 Business Recommendations

1. **🚫 Restrict Grade E, F, G Lending** — Grade G defaults at 49.50% (8.3x Grade A). Cap Grade E–F and eliminate Grade G loans entirely.
2. **⚠️ Enforce DTI Cap at 25%** — DTI 25+ borrowers default at 26.64% vs 14.66% for DTI below 10 (1.82x multiplier). Reject or require collateral above DTI 25.
3. **🏦 Flag Small Business Loans** — 29.43% default rate (highest of all purposes). Require business plan verification and stronger income proof.
4. **📊 Monitor Low Income + High DTI Segment** — 28.03% default rate. Introduce income-based lending limits and mandatory financial counselling.

---

## 🔄 Project Pipeline

| Phase | Task | Output |
|---|---|---|
| 1 | Data Quality Audit & Cleaning | 1,342,942 rows, 0 nulls |
| 2 | Feature Engineering | 91 columns |
| 3 | Exploratory Data Analysis | 6 charts |
| 4 | Statistical Validation | 4 tests (Chi-Square, T-Test) |
| 5 | MySQL Star Schema & Ingestion | 6 tables loaded |
| 6 | SQL Query Library | 6 analytical queries + benchmarks |
| 7 | Power BI Dashboard | 4-page dashboard published on NovyPro |
| 8 | BigQuery + dbt Extension | 8 models, 37/37 tests passing, Power BI on cloud |

---

## 👤 About Me

**Shreenivas S B**
Final Year MCA Student — Data Science Specialization
Dayananda Sagar University, Bangalore

🎯 Actively seeking **Data Analyst / BI Analyst** opportunities.

📧 Connect with me on [LinkedIn](https://www.linkedin.com/in/shreenivas-s-b-22b48a31a/)

---

## ⭐ If you found this project useful, please star the repository!
