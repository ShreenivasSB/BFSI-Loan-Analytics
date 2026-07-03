with income_bands as (
    select distinct income_band
    from {{ ref('int_loans_enriched') }}
)

select
    ROW_NUMBER() OVER (ORDER BY income_band)  as income_band_id,
    income_band
from income_bands
order by income_band
