with purposes as (
    select distinct purpose
    from `bfsi-loan-analytics`.`bfsi_loans_intermediate`.`int_loans_enriched`
)

select
    ROW_NUMBER() OVER (ORDER BY purpose)  as purpose_id,
    purpose
from purposes
order by purpose