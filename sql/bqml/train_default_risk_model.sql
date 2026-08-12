-- Phase 6: BigQuery ML predictive default risk scoring
-- Data Analyst portfolio scope — plain BQML SQL (not Vertex AI / Python).
--
-- FEATURES: loan_amnt, term, int_rate, dti, annual_inc, fico_midpoint,
--   home_ownership, verification_status, application_type, addr_state,
--   revol_bal, revol_util, open_acc, pub_rec, delinq_2yrs
--
-- EXCLUDED — leakage (only known after loan matures):
--   total_pymnt, total_rec_prncp, total_rec_int, recoveries, out_prncp, loan_status
--
-- EXCLUDED — multicollinearity:
--   - installment: deterministic function of loan_amnt/int_rate/term (amortization formula)
--   - fico_range_low/fico_range_high: near-perfectly correlated, collapsed to fico_midpoint
--   - sub_grade: redundant with int_rate (same underlying LC risk assignment); kept int_rate,
--     dropped sub_grade specifically to keep later sanity-checks non-circular
--
-- KNOWN LIMITATION: int_rate still correlates with Lending Club's own risk pricing, so
-- the model blends known priced-risk signal with DTI/income/FICO into one score rather
-- than discovering new risk factors from scratch. Documented in README, not hidden.

CREATE OR REPLACE MODEL `bfsi-loan-analytics.bfsi_loans.model_default_risk`
OPTIONS(
  model_type = 'logistic_reg',
  input_label_cols = ['loan_outcome'],
  auto_class_weights = TRUE,
  data_split_method = 'SEQ',
  data_split_col = 'recency_rank',
  data_split_eval_fraction = 0.2
) AS
SELECT
  loan_outcome,
  -UNIX_DATE(issue_date) AS recency_rank,
  -- SEQ sends the smallest-sorted rows to eval. Negating UNIX_DATE flips the order so
  -- the MOST RECENT loans (largest UNIX_DATE) get the smallest recency_rank and land
  -- in eval — giving a genuine train-on-past/eval-on-future split. Using plain
  -- issue_date ascending here would be BACKWARDS (oldest loans in eval).
  loan_amnt, term, int_rate, dti, annual_inc,
  (fico_range_low + fico_range_high) / 2 AS fico_midpoint,
  home_ownership, verification_status, application_type, addr_state,
  revol_bal, revol_util, open_acc, pub_rec, delinq_2yrs
FROM `bfsi-loan-analytics.bfsi_loans.fact_loans`;
