
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with child as (
    select grade_id as from_field
    from `bfsi-loan-analytics`.`bfsi_loans`.`fact_loans`
    where grade_id is not null
),

parent as (
    select grade_id as to_field
    from `bfsi-loan-analytics`.`bfsi_loans`.`dim_grade`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



  
  
      
    ) dbt_internal_test