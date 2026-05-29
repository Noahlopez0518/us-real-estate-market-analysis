-- ============================================================
-- 04: Create Clean Table
-- Filters: price 1-50M, bed/bath 1-20, house_size > 0, state not null
-- Deduplication via ROW_NUMBER()
-- ============================================================

USE RealEstateCapstone;
GO

SELECT
    r.brokered_by,
    LTRIM(RTRIM(r.status))              AS status,
    CAST(r.price AS BIGINT)             AS price,
    CAST(r.bed AS INT)                  AS bed,
    CAST(r.bath AS DECIMAL(4,1))        AS bath,
    CAST(r.acre_lot AS DECIMAL(10,4))   AS acre_lot,
    r.street,
    LTRIM(RTRIM(r.city))                AS city,
    LTRIM(RTRIM(r.state))               AS state,
    LTRIM(RTRIM(r.zip_code))            AS zip_code,
    CAST(r.house_size AS INT)           AS house_size,
    TRY_CAST(r.prev_sold_date AS DATE)  AS prev_sold_date
INTO dbo.realtor_clean
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY brokered_by, price, bed, bath, house_size, city, state, zip_code
               ORDER BY (SELECT NULL)
           ) AS rn
    FROM dbo.realtor_raw
    WHERE price IS NOT NULL AND price > 0 AND price <= 50000000
      AND bed   IS NOT NULL AND bed   > 0 AND bed   <= 20
      AND bath  IS NOT NULL AND bath  > 0 AND bath  <= 20
      AND house_size IS NOT NULL AND house_size > 0
      AND state IS NOT NULL AND LTRIM(RTRIM(state)) <> ''
) r
WHERE r.rn = 1;

SELECT COUNT(*) AS total_clean FROM dbo.realtor_clean;
-- Expected: 1,481,944
