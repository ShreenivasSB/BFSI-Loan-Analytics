with source as (
    select * from {{ source('raw', 'raw_loans') }}
),

renamed as (
    select
        -- loan sizing
        loan_amnt,
        funded_amnt,
        funded_amnt_inv,
        CAST(term AS INT64)                                          as term,
        int_rate,
        installment,

        -- borrower profile
        grade,
        sub_grade,
        emp_length,
        home_ownership,
        annual_inc,
        verification_status,
        application_type,

        -- loan metadata
        issue_d                                                      as issue_date,
        EXTRACT(YEAR FROM issue_d)                                   as issue_year,
        loan_status,
        purpose,
        addr_state,

        -- credit metrics
        dti,
        fico_range_low,
        fico_range_high,
        inq_last_6mths,
        open_acc,
        pub_rec,
        revol_bal,
        revol_util,
        total_acc,
        delinq_2yrs,

        -- payment performance
        out_prncp,
        total_pymnt,
        total_rec_prncp,
        total_rec_int,
        recoveries,
        last_pymnt_amnt,

        -- target variable (1 = default, 0 = non-default)
        CAST(loan_outcome AS INT64)                                  as loan_outcome,

        -- feature-engineered bands (lowercased from Python source)
        `DTIBand`      as dti_band,
        `IncomeBand`   as income_band,
        `LoanSizeBand` as loan_size_band,
        `RiskTier`     as risk_tier

    from source
)

select * from renamed
