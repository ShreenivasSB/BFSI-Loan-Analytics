
    
    

with dbt_test__target as (

  select dti_band as unique_field
  from `bfsi-loan-analytics`.`bfsi_loans`.`dim_dti_band`
  where dti_band is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


