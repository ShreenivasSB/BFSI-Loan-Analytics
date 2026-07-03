
    
    

with dbt_test__target as (

  select risk_tier_id as unique_field
  from `bfsi-loan-analytics`.`bfsi_loans`.`dim_risk_tier`
  where risk_tier_id is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


