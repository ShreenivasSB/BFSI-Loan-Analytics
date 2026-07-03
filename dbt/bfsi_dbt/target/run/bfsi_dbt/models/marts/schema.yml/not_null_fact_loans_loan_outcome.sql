
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select loan_outcome
from `bfsi-loan-analytics`.`bfsi_loans`.`fact_loans`
where loan_outcome is null



  
  
      
    ) dbt_internal_test