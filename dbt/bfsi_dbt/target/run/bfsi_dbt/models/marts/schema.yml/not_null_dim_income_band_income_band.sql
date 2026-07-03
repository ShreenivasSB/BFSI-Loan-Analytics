
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select income_band
from `bfsi-loan-analytics`.`bfsi_loans`.`dim_income_band`
where income_band is null



  
  
      
    ) dbt_internal_test