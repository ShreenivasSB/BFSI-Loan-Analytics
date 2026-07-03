
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select grade_id
from `bfsi-loan-analytics`.`bfsi_loans`.`dim_grade`
where grade_id is null



  
  
      
    ) dbt_internal_test