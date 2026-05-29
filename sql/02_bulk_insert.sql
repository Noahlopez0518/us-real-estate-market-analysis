-- ============================================================
-- 02: Load CSV into Raw Table
-- ============================================================
-- Note: File must be on a local path (not OneDrive/cloud-synced)
-- Update the path below to match your local setup

USE RealEstateCapstone;
GO

BULK INSERT dbo.realtor_raw
FROM 'C:\SQLData\Dataset\realtor-data.csv'
WITH (
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',
    TABLOCK,
    MAXERRORS       = 1000
);

SELECT COUNT(*) AS total_raw FROM dbo.realtor_raw;
-- Expected: 2,226,382
