
    
    

with all_values as (

    select
        loan_outcome as value_field,
        count(*) as n_records

    from `bfsi-loan-analytics`.`bfsi_loans`.`fact_loans`
    group by loan_outcome

)

select *
from all_values
where value_field not in (
    '0','1'
)


