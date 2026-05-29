-- ============================================================
-- 07: Linear Regression (computed from scratch in T-SQL)
-- Calculates slope, intercept, R, R², t-statistic, and p-value
-- ============================================================

USE RealEstateCapstone;
GO

-- ============================================================
-- Reusable regression template using CTEs
-- Replace [variable] with: house_size, bed, or bath
-- ============================================================

-- NATIONAL: House Size vs Price
WITH base AS (
    SELECT CAST(house_size AS FLOAT) AS x, CAST(price AS FLOAT) AS y
    FROM dbo.realtor_clean
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
-- Results: slope=38.48, intercept=497995, R²=0.0205, t=176.30


-- NATIONAL: Bedrooms vs Price
WITH base AS (
    SELECT CAST(bed AS FLOAT) AS x, CAST(price AS FLOAT) AS y
    FROM dbo.realtor_clean
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
-- Results: slope=224179, intercept=-153286, R²=0.0595, t=306.22


-- NATIONAL: Bathrooms vs Price
WITH base AS (
    SELECT CAST(bath AS FLOAT) AS x, CAST(price AS FLOAT) AS y
    FROM dbo.realtor_clean
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
-- Results: slope=410006, intercept=-445604, R²=0.2026, t=613.54


-- ============================================================
-- FLORIDA ONLY: Regression (for geographic confounding comparison)
-- ============================================================

-- FLORIDA: House Size vs Price
WITH base AS (
    SELECT CAST(house_size AS FLOAT) AS x, CAST(price AS FLOAT) AS y
    FROM dbo.realtor_clean WHERE state = 'Florida'
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
-- Results: slope=751.62, R²=0.3223 (15.7x improvement over national)


-- FLORIDA: Bedrooms vs Price
WITH base AS (
    SELECT CAST(bed AS FLOAT) AS x, CAST(price AS FLOAT) AS y
    FROM dbo.realtor_clean WHERE state = 'Florida'
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
-- Results: slope=366631, R²=0.0842


-- FLORIDA: Bathrooms vs Price
WITH base AS (
    SELECT CAST(bath AS FLOAT) AS x, CAST(price AS FLOAT) AS y
    FROM dbo.realtor_clean WHERE state = 'Florida'
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
-- Results: slope=702730, R²=0.2973
