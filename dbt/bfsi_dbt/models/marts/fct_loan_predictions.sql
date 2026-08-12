-- Phase 6: BQML predictive default risk scoring.
-- Scores every loan in fact_loans against model_default_risk (logistic_reg, trained
-- via sql/bqml/train_default_risk_model.sql) using the same feature set the model was
-- trained on. loan_id passes through ML.PREDICT untouched since it isn't a feature.
--
-- The model itself lives outside the dbt DAG (trained directly in BigQuery via bq
-- query, not dbt) — referenced here by fully-qualified name rather than dbt's ref().

with source as (
    select * from {{ ref('fact_loans') }}
),

predictions as (
    select
        loan_id,
        predicted_loan_outcome,
        (
            select prob
            from unnest(predicted_loan_outcome_probs)
            where label = 1
        ) as predicted_default_probability
    from ML.PREDICT(
        MODEL `bfsi-loan-analytics.bfsi_loans.model_default_risk`,
        (
            select
                loan_id,
                loan_amnt, term, int_rate, dti, annual_inc,
                (fico_range_low + fico_range_high) / 2 as fico_midpoint,
                home_ownership, verification_status, application_type, addr_state,
                revol_bal, revol_util, open_acc, pub_rec, delinq_2yrs
            from source
        )
    )
)

select
    loan_id,
    predicted_loan_outcome,
    predicted_default_probability
from predictions
