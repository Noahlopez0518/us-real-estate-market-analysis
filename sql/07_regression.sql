-- ============================================================
-- 07: IQR-Filtered Regression Table + Single-Variable Regression
-- ============================================================
-- Descriptive analysis (scripts 01-06) uses the FULL clean dataset
-- to represent the complete market, including luxury homes.
--
-- Regression uses a SEPARATE IQR-filtered table so extreme outliers
-- do not distort the slope. This is the statistically correct approach:
-- outliers belong in descriptive stats but bias linear models.
-- ============================================================

USE RealEstateCapstone;
GO

-- ------------------------------------------------------------
-- Create the IQR-filtered table (boundaries from script 05)
--   Price       <= 1,151,750
--   House Size  <= 4,064
--   Bedrooms    <= 5
--   Bathrooms   <= 4
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.realtor_iqr', 'U') IS NOT NULL
    DROP TABLE dbo.realtor_iqr;
GO

SELECT *
INTO dbo.realtor_iqr
FROM dbo.realtor_clean
WHERE price      <= 1151750
  AND house_size <= 4064
  AND bed        <= 5
  AND bath       <= 4;

SELECT COUNT(*) AS iqr_records FROM dbo.realtor_iqr;
-- Result: 1,297,370 (87.5% of clean data retained)


-- ============================================================
-- Single-Variable Regression on IQR-Filtered Data
-- ============================================================

-- IQR: House Size vs Price
WITH base AS (
    SELECT CAST(house_size AS FLOAT) AS x, CAST(price AS FLOAT) AS y
    FROM dbo.realtor_iqr
),
means AS (SELECT AVG(x) AS avg_x, AVG(y) AS avg_y, COUNT(*) AS n FROM base),
calcs AS (
    SELECT m.n, m.avg_x, m.avg_y,
           SUM((b.x - m.avg_x) * (b.y - m.avg_y)) AS ss_xy,
           SUM(POWER(b.x - m.avg_x, 2)) AS ss_xx,
           SUM(POWER(b.y - m.avg_y, 2)) AS ss_yy
    FROM base b CROSS JOIN means m
    GROUP BY m.n, m.avg_x, m.avg_y
),
results AS (
    SELECT n, ss_xy / NULLIF(ss_xx, 0) AS slope,
           avg_y - (ss_xy / NULLIF(ss_xx, 0)) * avg_x AS intercept,
           ss_xy / NULLIF(SQRT(ss_xx * ss_yy), 0) AS r_value,
           POWER(ss_xy / NULLIF(SQRT(ss_xx * ss_yy), 0), 2) AS r_squared
    FROM calcs
)
SELECT n,
       CAST(slope AS DECIMAL(10,2)) AS slope,
       CAST(intercept AS DECIMAL(10,2)) AS intercept,
       CAST(r_value AS DECIMAL(8,4)) AS r_value,
       CAST(r_squared AS DECIMAL(8,4)) AS r_squared,
       CAST(ABS(r_value) * SQRT(n - 2) / NULLIF(SQRT(1 - r_squared), 0) AS DECIMAL(10,2)) AS t_statistic,
       'p < 0.001' AS p_value
FROM results;
-- Results: slope=138.95, intercept=137683, R²=0.1843, t=541.35


-- IQR: Bedrooms vs Price
WITH base AS (
    SELECT CAST(bed AS FLOAT) AS x, CAST(price AS FLOAT) AS y
    FROM dbo.realtor_iqr
),
means AS (SELECT AVG(x) AS avg_x, AVG(y) AS avg_y, COUNT(*) AS n FROM base),
calcs AS (
    SELECT m.n, m.avg_x, m.avg_y,
           SUM((b.x - m.avg_x) * (b.y - m.avg_y)) AS ss_xy,
           SUM(POWER(b.x - m.avg_x, 2)) AS ss_xx,
           SUM(POWER(b.y - m.avg_y, 2)) AS ss_yy
    FROM base b CROSS JOIN means m
    GROUP BY m.n, m.avg_x, m.avg_y
),
results AS (
    SELECT n, ss_xy / NULLIF(ss_xx, 0) AS slope,
           avg_y - (ss_xy / NULLIF(ss_xx, 0)) * avg_x AS intercept,
           ss_xy / NULLIF(SQRT(ss_xx * ss_yy), 0) AS r_value,
           POWER(ss_xy / NULLIF(SQRT(ss_xx * ss_yy), 0), 2) AS r_squared
    FROM calcs
)
SELECT n,
       CAST(slope AS DECIMAL(10,2)) AS slope,
       CAST(intercept AS DECIMAL(10,2)) AS intercept,
       CAST(r_value AS DECIMAL(8,4)) AS r_value,
       CAST(r_squared AS DECIMAL(8,4)) AS r_squared,
       CAST(ABS(r_value) * SQRT(n - 2) / NULLIF(SQRT(1 - r_squared), 0) AS DECIMAL(10,2)) AS t_statistic,
       'p < 0.001' AS p_value
FROM results;
-- Results: slope=61738, intercept=193895, R²=0.0586, t=284.21


-- IQR: Bathrooms vs Price
WITH base AS (
    SELECT CAST(bath AS FLOAT) AS x, CAST(price AS FLOAT) AS y
    FROM dbo.realtor_iqr
),
means AS (SELECT AVG(x) AS avg_x, AVG(y) AS avg_y, COUNT(*) AS n FROM base),
calcs AS (
    SELECT m.n, m.avg_x, m.avg_y,
           SUM((b.x - m.avg_x) * (b.y - m.avg_y)) AS ss_xy,
           SUM(POWER(b.x - m.avg_x, 2)) AS ss_xx,
           SUM(POWER(b.y - m.avg_y, 2)) AS ss_yy
    FROM base b CROSS JOIN means m
    GROUP BY m.n, m.avg_x, m.avg_y
),
results AS (
    SELECT n, ss_xy / NULLIF(ss_xx, 0) AS slope,
           avg_y - (ss_xy / NULLIF(ss_xx, 0)) * avg_x AS intercept,
           ss_xy / NULLIF(SQRT(ss_xx * ss_yy), 0) AS r_value,
           POWER(ss_xy / NULLIF(SQRT(ss_xx * ss_yy), 0), 2) AS r_squared
    FROM calcs
)
SELECT n,
       CAST(slope AS DECIMAL(10,2)) AS slope,
       CAST(intercept AS DECIMAL(10,2)) AS intercept,
       CAST(r_value AS DECIMAL(8,4)) AS r_value,
       CAST(r_squared AS DECIMAL(8,4)) AS r_squared,
       CAST(ABS(r_value) * SQRT(n - 2) / NULLIF(SQRT(1 - r_squared), 0) AS DECIMAL(10,2)) AS t_statistic,
       'p < 0.001' AS p_value
FROM results;
-- Results: slope=119034, intercept=114675, R²=0.1845, t=541.75


-- ============================================================
-- Single-Variable Summary (IQR-filtered, n = 1,297,370)
-- ------------------------------------------------------------
--   Predictor    Slope          R²        t-stat
--   House Size   $138.95/sqft   0.1843    541.35
--   Bedrooms     $61,738/bed    0.0586    284.21
--   Bathrooms    $119,034/bath  0.1845    541.75
-- ============================================================
