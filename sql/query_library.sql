-- =============================================================
-- BFSI Loan Risk & Portfolio Analytics System
-- SQL Query Library
-- Author: Shreeni
-- Database: bfsi_loans
-- =============================================================

USE bfsi_loans;
-- =============================================================
-- Query 1: Default Rate by Loan Grade
-- =============================================================
SELECT 
    g.grade,
    COUNT(*) AS total_loans,
    SUM(f.loan_outcome) AS total_defaults,
    ROUND(SUM(f.loan_outcome) * 100.0 / COUNT(*), 2) AS default_rate_pct
FROM fact_loans f
JOIN dim_grade g ON f.grade_id = g.grade_id
GROUP BY g.grade
ORDER BY g.grade;

-- =============================================================
-- Query 2: Percent Contribution of Each Grade to Total Defaults
-- (Window Function)
-- =============================================================
SELECT 
    g.grade,
    SUM(f.loan_outcome) AS grade_defaults,
    ROUND(SUM(f.loan_outcome) * 100.0 / SUM(SUM(f.loan_outcome)) OVER (), 2) AS pct_of_total_defaults
FROM fact_loans f
JOIN dim_grade g ON f.grade_id = g.grade_id
GROUP BY g.grade
ORDER BY g.grade;

-- =============================================================
-- Query 3: Risk Tier Default Summary
-- (CTE)
-- =============================================================
WITH risk_summary AS (
    SELECT 
        r.risk_tier,
        COUNT(*) AS total_loans,
        SUM(f.loan_outcome) AS total_defaults,
        ROUND(SUM(f.loan_outcome) * 100.0 / COUNT(*), 2) AS default_rate_pct
    FROM fact_loans f
    JOIN dim_risk_tier r ON f.risk_tier_id = r.risk_tier_id
    GROUP BY r.risk_tier
)
SELECT *
FROM risk_summary
ORDER BY default_rate_pct ASC;

-- =============================================================
-- Query 4: Year-over-Year Default Trend
-- (LAG Function)
-- =============================================================
WITH yearly AS (
    SELECT 
        issue_year,
        COUNT(*) AS total_loans,
        SUM(loan_outcome) AS total_defaults,
        ROUND(SUM(loan_outcome) * 100.0 / COUNT(*), 2) AS default_rate_pct
    FROM fact_loans
    GROUP BY issue_year
)
SELECT 
    issue_year,
    total_loans,
    total_defaults,
    default_rate_pct,
    LAG(default_rate_pct) OVER (ORDER BY issue_year) AS prev_year_rate,
    ROUND(default_rate_pct - LAG(default_rate_pct) OVER (ORDER BY issue_year), 2) AS yoy_change
FROM yearly
ORDER BY issue_year;

-- =============================================================
-- Query 5: Cohort Analysis — Default Rate by Income Band and DTI Band
-- =============================================================
SELECT 
    i.income_band,
    d.dti_band,
    COUNT(*) AS total_loans,
    SUM(f.loan_outcome) AS total_defaults,
    ROUND(SUM(f.loan_outcome) * 100.0 / COUNT(*), 2) AS default_rate_pct
FROM fact_loans f
JOIN dim_income_band i ON f.income_band_id = i.income_band_id
JOIN dim_dti_band d ON f.dti_band_id = d.dti_band_id
GROUP BY i.income_band, d.dti_band
ORDER BY i.income_band, d.dti_band;

-- =============================================================
-- Query 6: Rolling 3-Month Average Default Rate
-- =============================================================
WITH monthly AS (
    SELECT 
        issue_year,
        COUNT(*) AS total_loans,
        SUM(loan_outcome) AS total_defaults,
        ROUND(SUM(loan_outcome) * 100.0 / COUNT(*), 2) AS default_rate_pct
    FROM fact_loans
    GROUP BY issue_year
)
SELECT 
    issue_year,
    default_rate_pct,
    ROUND(AVG(default_rate_pct) OVER (
        ORDER BY issue_year 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_3yr_avg_default_rate
FROM monthly
ORDER BY issue_year;