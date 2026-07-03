with grades as (
    select distinct grade
    from `bfsi-loan-analytics`.`bfsi_loans_intermediate`.`int_loans_enriched`
)

select
    ROW_NUMBER() OVER (ORDER BY grade)  as grade_id,
    grade
from grades
order by grade