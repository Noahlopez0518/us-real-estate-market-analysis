-- ============================================================
-- 03: Data Quality Audit
-- Run each query and record counts for the report
-- ============================================================

USE RealEstateCapstone;
GO

SELECT COUNT(*) AS null_price       FROM dbo.realtor_raw WHERE price IS NULL;
SELECT COUNT(*) AS zero_neg_price   FROM dbo.realtor_raw WHERE price <= 0;
SELECT COUNT(*) AS price_over_50m   FROM dbo.realtor_raw WHERE price > 50000000;
SELECT COUNT(*) AS null_zero_bed    FROM dbo.realtor_raw WHERE bed IS NULL OR bed <= 0;
SELECT COUNT(*) AS null_zero_bath   FROM dbo.realtor_raw WHERE bath IS NULL OR bath <= 0;
SELECT COUNT(*) AS bed_over_20      FROM dbo.realtor_raw WHERE bed > 20;
SELECT COUNT(*) AS bath_over_20     FROM dbo.realtor_raw WHERE bath > 20;
SELECT COUNT(*) AS null_zero_size   FROM dbo.realtor_raw WHERE house_size IS NULL OR house_size <= 0;
SELECT COUNT(*) AS null_blank_state FROM dbo.realtor_raw WHERE state IS NULL OR LTRIM(RTRIM(state)) = '';

-- Duplicate count
SELECT COUNT(*) AS duplicate_groups FROM (
    SELECT brokered_by, price, bed, bath, house_size, city, state, zip_code
    FROM dbo.realtor_raw
    GROUP BY brokered_by, price, bed, bath, house_size, city, state, zip_code
    HAVING COUNT(*) > 1
) x;
