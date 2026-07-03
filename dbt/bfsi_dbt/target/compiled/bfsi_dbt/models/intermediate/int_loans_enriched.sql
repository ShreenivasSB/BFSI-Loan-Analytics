-- Adds a stable integer surrogate key (loan_id) to every staging row.
-- Materialised as a table so all six mart models scan this once, not six times.
with staged as (
    select * from `bfsi-loan-analytics`.`bfsi_loans_staging`.`stg_loans`
)

select
    ROW_NUMBER() OVER ()  as loan_id,
    *
from staged