
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select risk_tier
from `bfsi-loan-analytics`.`bfsi_loans`.`dim_risk_tier`
where risk_tier is null



  
  
      
    ) dbt_internal_test