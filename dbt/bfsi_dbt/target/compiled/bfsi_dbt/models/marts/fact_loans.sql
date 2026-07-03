with loans as (
    select * from `bfsi-loan-analytics`.`bfsi_loans_intermediate`.`int_loans_enriched`
),
dim_grade      as (select * from `bfsi-loan-analytics`.`bfsi_loans`.`dim_grade`),
dim_purpose    as (select * from `bfsi-loan-analytics`.`bfsi_loans`.`dim_purpose`),
dim_income_band as (select * from `bfsi-loan-analytics`.`bfsi_loans`.`dim_income_band`),
dim_dti_band   as (select * from `bfsi-loan-analytics`.`bfsi_loans`.`dim_dti_band`),
dim_risk_tier  as (select * from `bfsi-loan-analytics`.`bfsi_loans`.`dim_risk_tier`)

select
    -- surrogate key
    l.loan_id,

    -- foreign keys to dimension tables
    g.grade_id,
    p.purpose_id,
    i.income_band_id,
    d.dti_band_id,
    r.risk_tier_id,

    -- loan sizing
    l.loan_amnt,
    l.funded_amnt,
    l.funded_amnt_inv,
    l.term,
    l.int_rate,
    l.installment,

    -- borrower profile
    l.annual_inc,
    l.dti,
    l.fico_range_low,
    l.fico_range_high,
    l.home_ownership,
    l.verification_status,
    l.application_type,
    l.sub_grade,
    l.addr_state,

    -- credit health
    l.revol_bal,
    l.revol_util,
    l.open_acc,
    l.pub_rec,
    l.delinq_2yrs,

    -- payment performance
    l.total_pymnt,
    l.total_rec_prncp,
    l.total_rec_int,
    l.recoveries,
    l.out_prncp,

    -- time
    l.issue_date,
    l.issue_year,

    -- target
    l.loan_outcome,
    l.loan_status

from loans l
left join dim_grade       g on l.grade       = g.grade
left join dim_purpose     p on l.purpose     = p.purpose
left join dim_income_band i on l.income_band = i.income_band
left join dim_dti_band    d on l.dti_band    = d.dti_band
left join dim_risk_tier   r on l.risk_tier   = r.risk_tier