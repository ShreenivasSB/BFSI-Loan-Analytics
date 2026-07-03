
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select purpose
from `bfsi-loan-analytics`.`bfsi_loans`.`dim_purpose`
where purpose is null



  
  
      
    ) dbt_internal_test