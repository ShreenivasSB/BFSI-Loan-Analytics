with risk_tiers as (
    select distinct risk_tier
    from {{ ref('int_loans_enriched') }}
)

select
    ROW_NUMBER() OVER (ORDER BY risk_tier)  as risk_tier_id,
    risk_tier
from risk_tiers
order by risk_tier
