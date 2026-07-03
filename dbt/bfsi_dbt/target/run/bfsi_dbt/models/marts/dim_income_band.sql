
  
    

    create or replace table `bfsi-loan-analytics`.`bfsi_loans`.`dim_income_band`
      
    
    

    
    OPTIONS()
    as (
      with income_bands as (
    select distinct income_band
    from `bfsi-loan-analytics`.`bfsi_loans_intermediate`.`int_loans_enriched`
)

select
    ROW_NUMBER() OVER (ORDER BY income_band)  as income_band_id,
    income_band
from income_bands
order by income_band
    );
  