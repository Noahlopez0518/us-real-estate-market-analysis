-- ============================================================
-- 06: Analysis Queries (Q2a through Q2e)
-- ============================================================

USE RealEstateCapstone;
GO

-- Q2a: Median vs Average Price
SELECT AVG(CAST(price AS FLOAT)) AS avg_price, COUNT(*) AS total
FROM dbo.realtor_clean;

SELECT DISTINCT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) OVER() AS median_price
FROM dbo.realtor_clean;


-- Q2b: Price by State
SELECT state, COUNT(*) AS listings,
       CAST(AVG(CAST(price AS FLOAT)) AS INT) AS avg_price
FROM dbo.realtor_clean
GROUP BY state
ORDER BY avg_price DESC;


-- Q2c: Price Drivers
-- By bedrooms
SELECT bed, COUNT(*) AS listings,
       CAST(AVG(CAST(price AS FLOAT)) AS INT) AS avg_price
FROM dbo.realtor_clean GROUP BY bed ORDER BY bed;

-- By bathrooms
SELECT CAST(bath AS INT) AS bath, COUNT(*) AS listings,
       CAST(AVG(CAST(price AS FLOAT)) AS INT) AS avg_price
FROM dbo.realtor_clean GROUP BY CAST(bath AS INT) ORDER BY bath;

-- By house size bucket
SELECT
    CASE WHEN house_size < 1000 THEN 'Under 1,000'
         WHEN house_size < 2000 THEN '1,000-1,999'
         WHEN house_size < 3000 THEN '2,000-2,999'
         WHEN house_size < 5000 THEN '3,000-4,999'
         ELSE '5,000+' END AS size_bucket,
    COUNT(*) AS listings,
    CAST(AVG(CAST(price AS FLOAT)) AS INT) AS avg_price
FROM dbo.realtor_clean
GROUP BY
    CASE WHEN house_size < 1000 THEN 'Under 1,000'
         WHEN house_size < 2000 THEN '1,000-1,999'
         WHEN house_size < 3000 THEN '2,000-2,999'
         WHEN house_size < 5000 THEN '3,000-4,999'
         ELSE '5,000+' END
ORDER BY avg_price;


-- Q2d: Correlations
SELECT bed,
       CAST(AVG(CAST(bath AS FLOAT)) AS DECIMAL(5,2)) AS avg_bath,
       CAST(AVG(CAST(house_size AS FLOAT)) AS INT) AS avg_sqft,
       CAST(AVG(CAST(acre_lot AS FLOAT)) AS DECIMAL(8,2)) AS avg_acres,
       CAST(AVG(CAST(price AS FLOAT)) AS INT) AS avg_price,
       COUNT(*) AS listings
FROM dbo.realtor_clean
GROUP BY bed ORDER BY bed;


-- Q2e: Florida Deep Dive
-- Florida vs national
SELECT
    CASE WHEN state = 'Florida' THEN 'Florida' ELSE 'All Other States' END AS region,
    COUNT(*) AS listings,
    CAST(AVG(CAST(price AS FLOAT)) AS INT) AS avg_price,
    CAST(AVG(CAST(house_size AS FLOAT)) AS INT) AS avg_sqft,
    CAST(AVG(CAST(bed AS FLOAT)) AS DECIMAL(3,1)) AS avg_beds,
    CAST(AVG(CAST(bath AS FLOAT)) AS DECIMAL(3,1)) AS avg_baths
FROM dbo.realtor_clean
GROUP BY CASE WHEN state = 'Florida' THEN 'Florida' ELSE 'All Other States' END;

-- Top 15 Florida cities by volume
SELECT TOP 15 city, COUNT(*) AS listings,
       CAST(AVG(CAST(price AS FLOAT)) AS INT) AS avg_price,
       CAST(AVG(CAST(house_size AS FLOAT)) AS INT) AS avg_sqft
FROM dbo.realtor_clean WHERE state = 'Florida'
GROUP BY city ORDER BY listings DESC;

-- Top 10 Florida cities by price
SELECT TOP 10 city,
       CAST(AVG(CAST(price AS FLOAT)) AS INT) AS avg_price,
       COUNT(*) AS listings
FROM dbo.realtor_clean WHERE state = 'Florida'
GROUP BY city ORDER BY avg_price DESC;
