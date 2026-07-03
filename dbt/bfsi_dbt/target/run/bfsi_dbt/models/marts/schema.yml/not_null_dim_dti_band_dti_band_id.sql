
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select dti_band_id
from `bfsi-loan-analytics`.`bfsi_loans`.`dim_dti_band`
where dti_band_id is null



  
  
      
    ) dbt_internal_test