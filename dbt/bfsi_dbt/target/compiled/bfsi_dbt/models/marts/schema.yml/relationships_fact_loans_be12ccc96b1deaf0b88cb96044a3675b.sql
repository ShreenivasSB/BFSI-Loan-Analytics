
    
    

with child as (
    select income_band_id as from_field
    from `bfsi-loan-analytics`.`bfsi_loans`.`fact_loans`
    where income_band_id is not null
),

parent as (
    select income_band_id as to_field
    from `bfsi-loan-analytics`.`bfsi_loans`.`dim_income_band`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


