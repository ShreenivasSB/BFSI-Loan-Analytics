
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select grade
from `bfsi-loan-analytics`.`bfsi_loans`.`dim_grade`
where grade is null



  
  
      
    ) dbt_internal_test