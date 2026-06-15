# 🏠 U.S. Real Estate Market Analysis

Comprehensive analysis of **2,226,382 U.S. real estate listings** from Realtor.com conducted as a BIS 470 capstone project at Southern Connecticut State University.

**Tools:** SQL Server Management Studio 20 · Microsoft Power BI Desktop · T-SQL

---

## 📊 Overview

| Item | Detail |
|---|---|
| Raw Records | 2,226,382 |
| Clean Records | 1,481,944 |
| Records Removed | 744,438 (33.4%) |
| States Covered | 50 + DC, Puerto Rico, Virgin Islands |
| National Median Price | $375,000 |
| National Average Price | $576,549 |

---

## 🔑 Key Findings

| Finding | Detail |
|---|---|
| National median price | $375,000 — $201K below mean, confirming right skew |
| Largest geographic spread | Hawaii ($1.41M) vs Ohio ($240K) — a 5.9× gap |
| Best predictive model | Multiple regression R² = 0.2229 — combining all three home features |
| Bedrooms paradox | Holding size constant, extra bedrooms slightly *reduce* value (−$27,133) |
| Florida premium | 12.6% above national average despite 11.4% smaller homes |

---

## 📁 Project Structure

```
├── sql/
│   ├── 01_create_database.sql        # Database and raw table setup
│   ├── 02_bulk_insert.sql            # CSV loading via BULK INSERT
│   ├── 03_cleaning_audit.sql         # Data quality audit
│   ├── 04_create_clean_table.sql     # Filtering, deduplication, type casting
│   ├── 05_statistical_profile.sql    # Descriptive stats, percentiles, IQR
│   ├── 06_analysis_queries.sql       # Q2a–Q2e analysis questions
│   ├── 07_regression.sql             # IQR table + single-variable regression
│   └── 08_multiple_regression.sql    # Multiple regression (all 3 variables)
├── dashboard/
│   └── Real_Estate_Capstone.pbix     # Power BI report (8 tabs)
├── docs/
│   ├── Report.md                     # Full written report
│   └── BIS470_Capstone_Report.docx   # Word version
├── assets/                           # Dashboard screenshots
└── data/
    └── README.md                     # Dataset source and download link
```

---

## 📈 Power BI Dashboard

8-tab interactive report with a dark navy theme.

### Tab 1 — Overview
![Overview](assets/tab1_overview.png)

### Tab 2 — Price by Location
![Price by Location](assets/tab2_location.png)

### Tab 3 — Price Drivers
![Price Drivers](assets/tab3_price_drivers.png)

### Tab 4 — Correlations
![Correlations](assets/tab4_correlations.png)

### Tab 5 — Florida Deep Dive
![Florida](assets/tab5_florida.png)

### Tab 6 — Regression Analysis
![Regression](assets/tab6_regression.png)

### Tab 7 — Predictive Modeling
![Predictive](assets/tab7_predictive.png)

### Tab 8 — Executive Summary
![Executive Summary](assets/tab8_executive.png)

---

## 🔢 Regression Analysis

Descriptive statistics use the full cleaned dataset (1,481,944 records). Regression uses a separate **IQR-filtered table** (1,297,370 records) so extreme outliers don't distort the model — the statistically correct approach.

### Single-Variable Regression (IQR-filtered, n = 1,297,370)

| Predictor | Slope | R² | T-Statistic |
|---|---|---|---|
| House Size | $138.95/sqft | 0.1843 | 541.35 |
| Bedrooms | $61,738/bed | 0.0586 | 284.21 |
| Bathrooms | $119,034/bath | 0.1845 | 541.75 |

### Multiple Regression (all three variables together)

| Predictor | Coefficient |
|---|---|
| House Size | $100.95/sqft |
| Bedrooms | −$27,132.74/bed |
| Bathrooms | $74,086.44/bath |
| Intercept | $120,933.24 |

**Model R² = 0.2229** · F = 124,066 · p < 0.001

```
Price = $120,933 + ($100.95 × sqft) − ($27,133 × beds) + ($74,086 × baths)
```

The multiple regression explains more variance (22.3%) than any single predictor, and corrects the omitted variable bias present in isolated models. Notably, the bedroom coefficient turns **negative** once square footage is held constant — adding bedrooms without adding space means smaller rooms, a well-documented real estate result.

---

## 🗄️ Dataset

**Source:** [USA Real Estate Dataset — Kaggle](https://www.kaggle.com/datasets/ahmedshahriarsakib/usa-real-estate-dataset)

The CSV (~170MB) is not included due to size. Download from Kaggle and place at `C:\SQLData\Dataset\realtor-data.csv`.

---

## ▶️ How to Reproduce

1. Install SQL Server Express and SQL Server Management Studio
2. Download `realtor-data.csv` from Kaggle
3. Place CSV at `C:\SQLData\Dataset\realtor-data.csv`
4. Run SQL scripts in order (`01` → `08`)
5. Open `Real_Estate_Capstone.pbix` in Power BI Desktop and connect to your SQL Server instance

---

## 👤 Author

**Noah Lopez** — Southern Connecticut State University, BIS 470 (Spring 2026)

📄 [Read the Full Report →](docs/Report.md)
