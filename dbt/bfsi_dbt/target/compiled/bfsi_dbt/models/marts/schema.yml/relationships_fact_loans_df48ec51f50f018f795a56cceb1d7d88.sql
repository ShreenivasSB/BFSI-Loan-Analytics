
    
    

with child as (
    select dti_band_id as from_field
    from `bfsi-loan-analytics`.`bfsi_loans`.`fact_loans`
    where dti_band_id is not null
),

parent as (
    select dti_band_id as to_field
    from `bfsi-loan-analytics`.`bfsi_loans`.`dim_dti_band`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


