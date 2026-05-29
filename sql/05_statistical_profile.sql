-- ============================================================
-- 05: Statistical Profile & IQR Outlier Boundaries
-- ============================================================

USE RealEstateCapstone;
GO

-- Price statistics
SELECT COUNT(*) AS n, MIN(price) AS min, MAX(price) AS max,
       AVG(CAST(price AS FLOAT)) AS mean, STDEV(CAST(price AS FLOAT)) AS std_dev
FROM dbo.realtor_clean;

-- Price percentiles
SELECT DISTINCT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY price) OVER() AS Q1,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY price) OVER() AS median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY price) OVER() AS Q3,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY price) OVER() AS P95,
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY price) OVER() AS P99
FROM dbo.realtor_clean;

-- House size statistics
SELECT COUNT(*) AS n, MIN(house_size) AS min, MAX(house_size) AS max,
       AVG(CAST(house_size AS FLOAT)) AS mean, STDEV(CAST(house_size AS FLOAT)) AS std_dev
FROM dbo.realtor_clean;

SELECT DISTINCT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY house_size) OVER() AS Q1,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY house_size) OVER() AS median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY house_size) OVER() AS Q3
FROM dbo.realtor_clean;

-- Bedroom statistics
SELECT COUNT(*) AS n, MIN(bed) AS min, MAX(bed) AS max,
       AVG(CAST(bed AS FLOAT)) AS mean, STDEV(CAST(bed AS FLOAT)) AS std_dev
FROM dbo.realtor_clean;

-- Bathroom statistics
SELECT COUNT(*) AS n, MIN(bath) AS min, MAX(bath) AS max,
       AVG(CAST(bath AS FLOAT)) AS mean, STDEV(CAST(bath AS FLOAT)) AS std_dev
FROM dbo.realtor_clean;

-- Date range
SELECT MIN(prev_sold_date) AS earliest, MAX(prev_sold_date) AS latest
FROM dbo.realtor_clean WHERE prev_sold_date IS NOT NULL;

-- IQR boundaries (used for regression outlier filtering)
-- Price:      Q1=232000, Q3=599900, IQR=367900, Upper Fence=1,151,750
-- House Size: Q1=1296,   Q3=2403,   IQR=1107,   Upper Fence=4,064
-- Bedrooms:   Q1=3,      Q3=4,      IQR=1,      Upper Fence=5
-- Bathrooms:  Q1=2,      Q3=3,      IQR=1,      Upper Fence=4
