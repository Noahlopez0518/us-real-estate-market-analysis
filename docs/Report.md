# U.S. Real Estate Market Analysis

**BIS 470 Capstone Project**

**Noah Lopez** — Southern Connecticut State University

Course: BIS 470 | Tools: SQL Server Management Studio 20 | Microsoft Power BI Desktop

Data Source: Realtor.com (realtor-data.csv)

---

## Table of Contents

- [Section 1: Introduction](#section-1-introduction)
- [Section 2: Data Cleaning](#section-2-data-cleaning)
- [Section 3: Data Analysis](#section-3-data-analysis)
- [Section 4: Power BI Dashboard](#section-4-power-bi-dashboard)
- [Section 5: Conclusion](#section-5-conclusion)
- [Appendix: SQL Queries](#appendix-sql-queries)

---

## Section 1: Introduction

This report presents a comprehensive analysis of the U.S. real estate market using a dataset of 2,226,382 property listings from Realtor.com. The analysis was conducted for BIS 470 using Microsoft SQL Server Management Studio 20 for data storage and cleaning, and Microsoft Power BI Desktop for visualization. The dataset was loaded into a local SQL Server database, cleaned using structured query language, and connected to Power BI for analysis across eight dashboard tabs.

The dataset includes both active listings and recently sold properties. Price figures reflect both listing prices and final sale prices as provided in the source data. The analysis covers all five required questions, including median vs average price, price by location, price drivers, correlations between characteristics, and a detailed Florida market analysis. Additional statistical analysis, including linear regression, IQR-based outlier detection, and predictive modeling, was performed to provide deeper analytical rigor.

---

## Section 2: Data Cleaning

### 2.1 Dataset Overview

The source dataset contains 2,226,382 records and 12 variables including price, bed, bath, acre_lot, house_size, city, state, zip_code, status, brokered_by, street, and prev_sold_date. Note that prev_sold_date represents the date the property was previously sold, not the current listing date.

### 2.2 Loading Method

The CSV file was moved from OneDrive to a local directory (`C:\SQLData\Dataset\`) to avoid SQL Server permission errors with synced cloud paths. The BULK INSERT command was used to load all records into a staging table named `dbo.realtor_raw`. Data types were set carefully — zip_code as NVARCHAR to preserve leading zeros, bed and bath as FLOAT to handle decimal and outlier values, and prev_sold_date as NVARCHAR(50) for inconsistent date formats.

### 2.3 Cleaning Audit

Each issue was identified and quantified before applying the final cleaning logic. Note that categories overlap; a single record may have multiple issues simultaneously, which is why individual counts cannot be summed to produce the total removed.

| Issue Identified | Records Affected |
|---|---|
| NULL price values | 1,541 |
| Zero or negative price | 280 |
| Price above $50,000,000 (initial outlier filter) | 130 |
| NULL or zero bedrooms | 481,317 |
| NULL or zero bathrooms | 511,771 |
| Bedrooms above 20 | 725 |
| Bathrooms above 20 | 401 |
| NULL or zero house size | 568,484 |
| NULL or blank state | 8 |
| Duplicate rows removed | 170,575 |
| **Total raw records** | **2,226,382** |
| **Total clean records** | **1,481,944** |
| **Net records removed** | **744,438 (33.4%)** |

The high counts for null bedrooms, bathrooms, and house size reflect land-only or ready-to-build listings with no constructed structure. These records are not useful for analyzing house price relationships and were correctly excluded.

Duplicate records were identified using a `ROW_NUMBER()` window function partitioned by brokered_by, price, bed, bath, house_size, city, state, and zip_code. Only the first occurrence of each group was retained.

### 2.4 IQR-Based Outlier Analysis

For regression and predictive modeling purposes, a more rigorous outlier removal method was applied using the Interquartile Range (IQR) method. The IQR upper fence is calculated as Q3 + 1.5 × IQR.

| Variable | Q1 | Q3 | IQR | Upper Fence |
|---|---|---|---|---|
| Price | $232,000 | $599,900 | $367,900 | $1,151,750 |
| House Size | 1,296 sqft | 2,403 sqft | 1,107 sqft | 4,064 sqft |
| Bedrooms | 3 | 4 | 1 | 5 |
| Bathrooms | 2 | 3 | 1 | 4 |

These IQR-based filters were applied exclusively to the Regression Analysis tab. The fully cleaned dataset of 1,481,944 records was retained for all descriptive analysis.

---

## Section 3: Data Analysis

### 3.1 Question 2a: Median vs Average Price

| Metric | Value | Total Records |
|---|---|---|
| Average Price | $576,549 | 1,481,944 |
| Median Price | $375,000 | 1,481,944 |
| Difference | $201,549 | — |

The $201,549 gap indicates a right-skewed distribution driven by luxury outliers. The median is the more accurate representation of what a typical buyer pays. Average price is used as the primary metric throughout the remainder of this analysis because it is required for linear regression modeling and is the standard metric for comparative market analysis.

### 3.2 Question 2b: Price by State

**Top 3 Most Expensive States**

| Rank | State | Avg Price | Median Price | Listings |
|---|---|---|---|---|
| 1 | Hawaii | $1,414,882 | $800,000 | 4,927 |
| 2 | Virgin Islands | $1,298,464 | $604,500 | 202 |
| 3 | California | $1,031,607 | $699,000 | 173,955 |

**Bottom 3 Most Affordable States**

| Rank | State | Avg Price | Median Price | Listings |
|---|---|---|---|---|
| 1 | Ohio | $240,279 | $179,900 | 42,951 |
| 2 | West Virginia | $252,245 | $199,900 | 7,491 |
| 3 | Iowa | $257,565 | $218,000 | 17,221 |

The Hawaii-to-Ohio spread represents a 5.9x price gap, the largest in the dataset. Florida ranks 15th at $649,020, which is 12.6% above the national average.

### 3.3 Question 2c: Price Drivers and Prediction

**Impact of House Characteristics on Price**

| House Size | Listings | Avg Price | Bedrooms | Listings | Avg Price |
|---|---|---|---|---|---|
| Under 1,000 sqft | 144,094 | $280,325 | 1 bedroom | 52,279 | $368,540 |
| 1,000–1,999 sqft | 763,148 | $388,869 | 2 bedrooms | 263,664 | $394,889 |
| 2,000–2,999 sqft | 375,403 | $608,172 | 3 bedrooms | 646,742 | $451,706 |
| 3,000–4,999 sqft | 164,829 | $1,080,052 | 4 bedrooms | 374,444 | $662,498 |
| 5,000+ sqft | 34,470 | $3,217,947 | 5 bedrooms | 102,814 | $1,086,413 |

**Linear Regression Results (n = 1,481,944)**

| Predictor | Slope | Intercept | R | R² | T-Statistic | P-Value |
|---|---|---|---|---|---|---|
| House Size | $38.48/sqft | $497,995 | 0.1433 | 0.0205 | 176.30 | p < 0.001 |
| Bedrooms | $224,179/bed | -$153,286 | 0.2439 | 0.0595 | 306.22 | p < 0.001 |
| Bathrooms | $410,006/bath | -$445,604 | 0.4501 | 0.2026 | 613.54 | p < 0.001 |

All three predictors are statistically significant at p < 0.001. Bathrooms are the strongest predictor with R² = 0.2026. The low national R² values reflect geographic confounding — when regression is run on Florida alone, house size R² jumps from 0.0205 to 0.3223, a 15.7x improvement.

**Price Prediction Reference Guide**

| Home Profile | Sqft | Beds | Baths | Expected National Price | Expected Florida Price |
|---|---|---|---|---|---|
| Small Starter | 900 | 2 | 1 | $280,325 | $236,098 |
| Average Home | 1,500 | 3 | 2 | $388,869 | $399,808 |
| Above Average | 2,500 | 4 | 3 | $608,172 | $760,654 |
| Large Home | 3,500 | 4 | 3 | $1,080,052 | $1,809,342 |
| Luxury Home | 5,000 | 5 | 4 | $3,217,947 | $6,719,148 |

### 3.4 Question 2d: Correlations Between Characteristics

| Bedrooms | Avg Bathrooms | Avg Sqft | Avg Acres | Avg Price | Listings |
|---|---|---|---|---|---|
| 1 | 1.18 | 931 | 37.59 | $368,540 | 52,279 |
| 2 | 1.80 | 1,288 | 18.83 | $394,889 | 263,664 |
| 3 | 2.25 | 1,755 | 10.43 | $451,706 | 646,742 |
| 4 | 2.94 | 2,518 | 9.53 | $662,498 | 374,444 |
| 5 | 3.81 | 3,509 | 16.10 | $1,086,413 | 102,814 |
| 6 | 4.48 | 4,297 | 27.52 | $1,659,027 | 26,139 |
| 7 | 5.36 | 5,174 | 42.49 | $2,428,933 | 6,350 |

Bedrooms, bathrooms, and square footage are strongly correlated (multicollinearity). Acre lot size shows a surprising inverse relationship — 1-bed homes average 37.59 acres vs 10.43 for 3-bed homes, explained by rural agricultural parcels with modest dwellings.

### 3.5 Question 2e: Florida Housing Market Deep Dive

**Florida vs National Comparison**

| Metric | Florida | National | Difference |
|---|---|---|---|
| Total Listings | 166,931 | 1,481,944 | 11.3% of all listings |
| Average Price | $649,020 | $576,549 | +$72,471 (+12.6%) |
| Median Price | $370,880 | $375,000 | -$4,120 (-1.1%) |
| Average House Size | 1,809 sqft | 2,041 sqft | -232 sqft (-11.4%) |
| Average Bedrooms | 3.0 | 3.3 | -0.3 bedrooms |
| Average Bathrooms | 2.4 | 2.5 | -0.1 bathrooms |

**Florida Cities by Listing Volume**

| City | Listings | Avg Price | Avg Sqft |
|---|---|---|---|
| Jacksonville | 7,982 | $334,260 | 1,724 |
| Miami | 7,836 | $844,746 | 1,584 |
| Orlando | 5,939 | $409,197 | 1,733 |
| Tampa | 5,013 | $547,774 | 1,801 |
| Naples | 4,524 | $1,416,967 | 2,129 |
| Saint Petersburg | 2,848 | $517,601 | 1,439 |
| Miami Beach | 2,360 | $2,170,059 | 1,547 |
| Sarasota | 1,968 | $1,111,002 | 1,965 |

**Florida Regression Analysis**

| Predictor | Florida Slope | Florida R² | National R² | Improvement |
|---|---|---|---|---|
| House Size | $751.62/sqft | 0.3223 | 0.0205 | 15.7x stronger |
| Bedrooms | $366,631/bed | 0.0842 | 0.0595 | 1.4x stronger |
| Bathrooms | $702,730/bath | 0.2973 | 0.2026 | 1.5x stronger |

---

## Section 4: Power BI Dashboard

The Power BI report was built across eight tabs using a consistent dark navy theme (`#0F1923` background, `#00C4CC`/`#FF6B6B`/`#FFD93D` accents).

| Tab | Name | Purpose | Assignment Question |
|---|---|---|---|
| 1 | Overview | National price summary, KPI cards, price distribution | Q2a |
| 2 | Price by Location | Bubble map and top/bottom state bar charts | Q2b |
| 3 | Price Drivers | Bedroom, bathroom, and size effects on price | Q2c |
| 4 | Correlations | Heatmap matrix, scatter plots, insight cards | Q2d |
| 5 | Florida Analysis | Florida deep dive with city breakdowns | Q2e |
| 6 | Regression Analysis | IQR-filtered scatter plots with R² and p-values | Q2c extended |
| 7 | Predictive Modeling | Price prediction guide and model accuracy | Q2c extended |
| 8 | Executive Summary | Summary dashboard of all key findings | All |

---

## Section 5: Conclusion

This analysis of 1,481,944 cleaned U.S. real estate listings produced several significant findings about the American housing market.

The national median home price of $375,000 is the most accurate representation of what a typical buyer pays. The $201,549 gap between median and average confirms a right-skewed distribution caused by luxury outliers. At the state level, Hawaii averages $1,414,882, nearly 6x more than Ohio at $240,279, demonstrating the extraordinary geographic range of housing costs.

All three house characteristics tested — bedrooms, bathrooms, and square footage — show statistically significant positive relationships with price (all p < 0.001). Bathrooms are the strongest single predictor nationally (R² = 0.2026). The low national R² values are explained by geographic confounding; when regression is run on Florida alone, house size R² improves 15.7x to 0.3223, confirming that location is the dominant price determinant.

Florida commands a 12.6% price premium despite offering homes 232 sqft smaller than the national average. Florida's internal variation is substantial, ranging from Jacksonville ($334,260) to Miami Beach ($2,170,059). The Florida house-size slope of $751.62/sqft vs $38.48 nationally quantifies exactly how much more Florida buyers pay per square foot.

---

## Appendix: SQL Queries

All SQL scripts are in the [`sql/`](sql/) directory, numbered in execution order:

| Script | Purpose |
|---|---|
| [`01_create_database.sql`](sql/01_create_database.sql) | Database and raw table setup |
| [`02_bulk_insert.sql`](sql/02_bulk_insert.sql) | CSV loading via BULK INSERT |
| [`03_cleaning_audit.sql`](sql/03_cleaning_audit.sql) | Data quality audit |
| [`04_create_clean_table.sql`](sql/04_create_clean_table.sql) | Filtering, deduplication, type casting |
| [`05_statistical_profile.sql`](sql/05_statistical_profile.sql) | Descriptive stats, percentiles, IQR |
| [`06_analysis_queries.sql`](sql/06_analysis_queries.sql) | Q2a–Q2e analysis queries |
| [`07_regression.sql`](sql/07_regression.sql) | Linear regression — national + Florida |
