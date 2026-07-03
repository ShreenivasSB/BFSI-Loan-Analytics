with grades as (
    select distinct grade
    from {{ ref('int_loans_enriched') }}
)

select
    ROW_NUMBER() OVER (ORDER BY grade)  as grade_id,
    grade
from grades
order by grade
