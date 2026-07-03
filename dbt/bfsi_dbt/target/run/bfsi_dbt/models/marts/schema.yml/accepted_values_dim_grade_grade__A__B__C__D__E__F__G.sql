
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        grade as value_field,
        count(*) as n_records

    from `bfsi-loan-analytics`.`bfsi_loans`.`dim_grade`
    group by grade

)

select *
from all_values
where value_field not in (
    'A','B','C','D','E','F','G'
)



  
  
      
    ) dbt_internal_test