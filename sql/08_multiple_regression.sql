-- ============================================================
-- 08: Multiple Linear Regression (price ~ house_size + bed + bath)
-- ============================================================
-- Single-variable regressions suffer from omitted variable bias:
-- because larger homes tend to have more beds AND baths AND sqft,
-- each isolated model overstates its predictor's true effect.
--
-- Multiple regression solves all three coefficients simultaneously
-- so the variables "share" the price. This yields the true marginal
-- value of each feature, holding the others constant.
--
-- Computed from scratch in T-SQL via the normal equations
-- (mean-centered covariance matrix), then solved for coefficients.
-- Runs on the IQR-filtered table (dbo.realtor_iqr).
-- ============================================================

USE RealEstateCapstone;
GO

-- ------------------------------------------------------------
-- Step 1: Build the covariance/variance terms
-- ------------------------------------------------------------
WITH d AS (
    SELECT CAST(house_size AS FLOAT) AS x1,
           CAST(bed        AS FLOAT) AS x2,
           CAST(bath       AS FLOAT) AS x3,
           CAST(price      AS FLOAT) AS y
    FROM dbo.realtor_iqr
),
s AS (
    SELECT
        COUNT(*) AS n,
        SUM(x1) AS sx1, SUM(x2) AS sx2, SUM(x3) AS sx3, SUM(y) AS sy,
        SUM(x1*x1) AS sx1x1, SUM(x2*x2) AS sx2x2, SUM(x3*x3) AS sx3x3,
        SUM(x1*x2) AS sx1x2, SUM(x1*x3) AS sx1x3, SUM(x2*x3) AS sx2x3,
        SUM(x1*y)  AS sx1y,  SUM(x2*y)  AS sx2y,  SUM(x3*y)  AS sx3y,
        SUM(y*y)   AS syy
    FROM d
)
SELECT
    n,
    sx1x1 - sx1*sx1/n AS S11,
    sx2x2 - sx2*sx2/n AS S22,
    sx3x3 - sx3*sx3/n AS S33,
    sx1x2 - sx1*sx2/n AS S12,
    sx1x3 - sx1*sx3/n AS S13,
    sx2x3 - sx2*sx3/n AS S23,
    sx1y  - sx1*sy/n  AS S1y,
    sx2y  - sx2*sy/n  AS S2y,
    sx3y  - sx3*sy/n  AS S3y,
    syy   - sy*sy/n   AS Syy,
    sx1/n AS mx1, sx2/n AS mx2, sx3/n AS mx3, sy/n AS my
FROM s;

-- ------------------------------------------------------------
-- Step 2: Solve the 3x3 system (done in Python/Excel after
-- extracting the covariance terms above). The normal equations:
--
--   [S11 S12 S13] [b1]   [S1y]
--   [S12 S22 S23] [b2] = [S2y]
--   [S13 S23 S33] [b3]   [S3y]
--
-- Intercept b0 = my - (b1*mx1 + b2*mx2 + b3*mx3)
-- R² = (b1*S1y + b2*S2y + b3*S3y) / Syy
-- ------------------------------------------------------------

-- ============================================================
-- FINAL MODEL RESULTS (IQR-filtered, n = 1,297,370)
-- ------------------------------------------------------------
--   Predictor     Coefficient
--   House Size    $100.95 per sqft
--   Bedrooms     -$27,132.74 per bedroom
--   Bathrooms     $74,086.44 per bathroom
--   Intercept     $120,933.24
--
--   R²            0.2229  (explains 22.3% of price variance)
--   Adjusted R²   0.2229
--   F-statistic   124,066  (p < 0.001)
--
-- Prediction formula:
--   Price = 120,933 + (100.95 * sqft) - (27,133 * beds) + (74,086 * baths)
--
-- Interpretation:
--   - Square footage is the true primary price driver (~$101/sqft).
--   - Each additional bathroom adds ~$74K, holding size constant.
--   - Bedrooms show a NEGATIVE coefficient: adding a bedroom without
--     adding square footage means smaller rooms, slightly reducing
--     value. This is a well-documented real estate result and shows
--     the model is correctly isolating marginal effects.
--   - Combined R² (0.2229) exceeds every single-variable model,
--     confirming the predictors work better together than alone.
-- ============================================================
