with dti_bands as (
    select distinct dti_band
    from {{ ref('int_loans_enriched') }}
)

select
    ROW_NUMBER() OVER (ORDER BY dti_band)  as dti_band_id,
    dti_band
from dti_bands
order by dti_band
