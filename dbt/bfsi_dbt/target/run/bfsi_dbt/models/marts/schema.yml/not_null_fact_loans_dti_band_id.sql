
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select dti_band_id
from `bfsi-loan-analytics`.`bfsi_loans`.`fact_loans`
where dti_band_id is null



  
  
      
    ) dbt_internal_test