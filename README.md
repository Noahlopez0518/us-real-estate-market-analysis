# U.S. Real Estate Market Analysis

**BIS 470 Capstone Project — Southern Connecticut State University**

End-to-end analysis of **2.2 million U.S. property listings** from Realtor.com, covering national pricing trends, geographic disparities, price drivers, and a Florida market deep dive — with linear regression modeling built entirely in T-SQL.

---

## Key Findings

| Finding | Detail |
|---------|--------|
| **National median price** | $375,000 — $201K below the mean, confirming heavy right skew |
| **Largest geographic spread** | Hawaii ($1.41M) vs Ohio ($240K) — a 5.9× price gap |
| **Strongest single predictor** | Bathrooms (R² = 0.20, p < 0.001) |
| **Geographic confounding proved** | House size R² jumps from 0.02 nationally → 0.32 in Florida alone (15.7× improvement) |
| **Florida premium** | 12.6% above national average despite 11.4% smaller homes |

---

## Project Structure

```
├── sql/
│   ├── 01_create_database.sql        # Database and raw table setup
│   ├── 02_bulk_insert.sql            # CSV loading via BULK INSERT
│   ├── 03_cleaning_audit.sql         # Data quality audit (counts per issue)
│   ├── 04_create_clean_table.sql     # Filtering, deduplication, type casting
│   ├── 05_statistical_profile.sql    # Descriptive stats, percentiles, IQR
│   ├── 06_analysis_queries.sql       # Q2a–Q2e: all five analysis questions
│   └── 07_regression.sql             # Linear regression with R², t-stat, p-value
├── dashboard/
│   └── Real_Estate_Capstone.pbix     # Power BI report (8 tabs)
├── docs/
│   └── BIS470_Capstone_Report.docx   # Final written report
├── data/
│   └── README.md                     # Dataset source and download instructions
└── assets/                           # Dashboard screenshots (see below)
```

---

## Tools & Stack

- **SQL Server Management Studio 20** — data storage, cleaning, statistical analysis, regression
- **Microsoft Power BI Desktop** — 8-tab interactive dashboard
- **T-SQL** — all analysis including linear regression computed from scratch (no Python/R)

---

## Data Pipeline

**2,226,382** raw records → cleaning → **1,481,944** clean records (33.4% removed)

Records were removed for: null/invalid prices, null or zero bedrooms/bathrooms, null house sizes, null states, extreme outliers (>$50M), unrealistic values (>20 beds/baths), and duplicates identified via `ROW_NUMBER()` window functions. A separate IQR-based outlier filter was applied for regression analysis only.

---

## Analysis Overview

### Q2a — Median vs Average Price
The $201,549 gap between median ($375K) and average ($576K) reveals a right-skewed distribution driven by luxury outliers. The median better represents the typical buyer's experience.

### Q2b — Price by State
Hawaii, the Virgin Islands, and California are the most expensive markets. Ohio, West Virginia, and Iowa are the most affordable. The Hawaii-to-Ohio spread is 5.9×.

### Q2c — Price Drivers & Regression
All three predictors (sqft, beds, baths) are statistically significant at p < 0.001. Bathrooms explain the most variance nationally (R² = 0.20). Low national R² values are caused by geographic confounding, not weak relationships — proven by Florida's 15.7× improvement when analyzed in isolation.

| Predictor | Slope | R² | T-Statistic | P-Value |
|-----------|-------|----|-------------|---------|
| House Size | $38.48/sqft | 0.0205 | 176.30 | < 0.001 |
| Bedrooms | $224,179/bed | 0.0595 | 306.22 | < 0.001 |
| Bathrooms | $410,006/bath | 0.2026 | 613.54 | < 0.001 |

### Q2d — Correlations
Bedrooms, bathrooms, and square footage are strongly correlated (multicollinearity). Acre lot size shows a surprising inverse relationship — 1-bed homes average 37.6 acres vs 10.4 for 3-bed homes, explained by rural agricultural parcels.

### Q2e — Florida Deep Dive
Florida commands a 12.6% price premium over national averages despite smaller homes. Internal variation is extreme: Jacksonville ($334K) to Miami Beach ($2.17M). Florida regression slopes are dramatically steeper ($751.62/sqft vs $38.48 nationally).

---

## Power BI Dashboard

8-tab report with a dark navy theme (`#0F1923` background, `#00C4CC`/`#FF6B6B`/`#FFD93D` accents).

| Tab | Name | Content |
|-----|------|---------|
| 1 | Overview | National KPIs, price distribution histogram |
| 2 | Price by Location | Bubble map, top/bottom state bar charts |
| 3 | Price Drivers | Column charts, combo charts, area chart |
| 4 | Correlations | Heatmap matrix, scatter plots, insight cards |
| 5 | Florida Analysis | City breakdowns, Florida vs national comparison |
| 6 | Regression Analysis | IQR-filtered scatter plots with R² annotations |
| 7 | Predictive Modeling | Price prediction guide and model accuracy |
| 8 | Executive Summary | Summary dashboard of all key findings |

<!-- 
Uncomment and add screenshot paths once exported:
![Overview](assets/tab1_overview.png)
![Regression](assets/tab6_regression.png)
-->

---

## Dataset

**Source:** [Realtor.com via Kaggle](https://www.kaggle.com/datasets/ahmedshahriarsakib/usa-real-estate-dataset) — `realtor-data.csv` (2,226,382 records, ~170MB)

The CSV is not included in this repository due to size. Download it from the link above and place it in the `data/` directory.

| Column | Type | Description |
|--------|------|-------------|
| price | float | Listing or sale price |
| bed | float | Number of bedrooms |
| bath | float | Number of bathrooms |
| house_size | float | Square footage |
| acre_lot | float | Lot size in acres |
| city | string | City name |
| state | string | State name |
| zip_code | string | ZIP code |
| status | string | Listing status (active/sold) |
| brokered_by | string | Brokerage identifier |
| street | string | Street address |
| prev_sold_date | string | Previous sale date |

---

## How to Reproduce

1. Install SQL Server (Express) and SQL Server Management Studio
2. Download `realtor-data.csv` from the Kaggle link above
3. Place the CSV at `C:\SQLData\Dataset\realtor-data.csv` (or update the path in `02_bulk_insert.sql`)
4. Run the SQL scripts in order (`01` → `07`)
5. Open `Real_Estate_Capstone.pbix` in Power BI Desktop and point the data source to your SQL Server instance

---

## Author

**Noah Lopez** — Southern Connecticut State University, BIS 470 (Spring 2026)
