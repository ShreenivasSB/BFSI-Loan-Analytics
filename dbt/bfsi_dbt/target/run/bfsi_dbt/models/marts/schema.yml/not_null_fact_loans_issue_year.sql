
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select issue_year
from `bfsi-loan-analytics`.`bfsi_loans`.`fact_loans`
where issue_year is null



  
  
      
    ) dbt_internal_test