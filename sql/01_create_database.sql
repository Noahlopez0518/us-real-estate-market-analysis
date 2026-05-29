-- ============================================================
-- 01: Create Database and Raw Import Table
-- ============================================================

CREATE DATABASE RealEstateCapstone;
GO
USE RealEstateCapstone;
GO

CREATE TABLE dbo.realtor_raw (
    brokered_by     NVARCHAR(255),
    status          NVARCHAR(50),
    price           FLOAT,
    bed             FLOAT,
    bath            FLOAT,
    acre_lot        FLOAT,
    street          NVARCHAR(255),
    city            NVARCHAR(100),
    state           NVARCHAR(100),
    zip_code        NVARCHAR(20),
    house_size      FLOAT,
    prev_sold_date  NVARCHAR(50)
);
