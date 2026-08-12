-- Singular test: predicted_default_probability must be a valid probability (0-1
-- inclusive). Returns any offending rows; dbt fails the test if this returns rows.
-- dbt_utils isn't installed in this project, so this stands in for
-- dbt_utils.accepted_range.

select *
from {{ ref('fct_loan_predictions') }}
where predicted_default_probability < 0
   or predicted_default_probability > 1
