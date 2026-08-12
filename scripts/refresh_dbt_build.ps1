# Refreshes every BigQuery table dbt builds (fact_loans, dim_*, fct_loan_predictions)
# AND retrains model_default_risk (it lives outside the dbt DAG, so dbt build alone
# never touches it).
#
# Why this exists: the bfsi-loan-analytics GCP project has no billing account
# attached, so BigQuery enforces a hard 60-day default table/model expiration that
# can't be removed or extended without enabling billing. Re-running dbt build
# recreates every table (CREATE OR REPLACE), and re-running the CREATE OR REPLACE
# MODEL statement recreates the model - both reset their own 60-day expiration
# clock. Run on a schedule (see Windows Task Scheduler task
# "BFSI_dbt_monthly_refresh", every 30 days) so nothing actually reaches its
# expiration date - keeps the public Power BI dashboard (which reads fact_loans)
# alive with zero billing risk.
#
# Depends on: conda env bfsi-dbt, and a valid "gcloud auth application-default
# login" on this machine (BigQuery ADC). If gcloud auth is ever reset, this script
# will start failing - check the log below periodically.

$ErrorActionPreference = "Stop"

$logDir = Join-Path $PSScriptRoot "logs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
}
$logFile = Join-Path $logDir "dbt_refresh.log"

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Starting dbt build refresh" | Out-File -FilePath $logFile -Append -Encoding utf8

try {
    # Step 1: retrain model_default_risk (CREATE OR REPLACE resets its expiration).
    # Uses the bare bq CLI, which doesn't need the conda env. bq reads the query
    # from stdin when none is given as an argument. Routed through cmd.exe's own
    # "<" file redirection rather than a PowerShell string pipe - piping a string to
    # a native process's stdin in Windows PowerShell 5.1 injects a UTF-8 BOM that
    # bq's parser rejects as an illegal input character. Stderr is merged to stdout
    # *inside* the cmd.exe command line (not via a trailing PowerShell "2>&1") -
    # under $ErrorActionPreference = "Stop", PowerShell's own 2>&1 wraps every
    # stderr line from a native command (including bq's normal "Waiting on
    # bqjob_..." progress text) as a terminating ErrorRecord, even on success.
    $modelOutput = cmd /c "bq query --use_legacy_sql=false --project_id=bfsi-loan-analytics < ""C:\BFSI_Loan_Analytics\sql\bqml\train_default_risk_model.sql"" 2>&1" | Out-String
    $modelExit = $LASTEXITCODE
    $modelOutput | Out-File -FilePath $logFile -Append -Encoding utf8

    if ($modelExit -eq 0) {
        "[$timestamp] Model retrain SUCCEEDED - model_default_risk expiration reset" | Out-File -FilePath $logFile -Append -Encoding utf8
    } else {
        "[$timestamp] Model retrain FAILED (exit $modelExit) - model may lapse if not fixed before the 60-day window closes" | Out-File -FilePath $logFile -Append -Encoding utf8
    }

    # Step 2: rebuild every dbt table (fact_loans, dims, fct_loan_predictions).
    & "$env:USERPROFILE\anaconda3\Scripts\conda.exe" "shell.powershell" "hook" | Out-String | Invoke-Expression
    conda activate bfsi-dbt

    Push-Location "C:\BFSI_Loan_Analytics\dbt\bfsi_dbt"
    $output = dbt build 2>&1 | Out-String
    Pop-Location

    $output | Out-File -FilePath $logFile -Append -Encoding utf8

    if ($LASTEXITCODE -eq 0) {
        "[$timestamp] dbt build SUCCEEDED - table expirations reset" | Out-File -FilePath $logFile -Append -Encoding utf8
    } else {
        "[$timestamp] dbt build FAILED (exit $LASTEXITCODE) - tables may lapse if not fixed before the 60-day window closes" | Out-File -FilePath $logFile -Append -Encoding utf8
    }
} catch {
    "[$timestamp] SCRIPT ERROR: $_" | Out-File -FilePath $logFile -Append -Encoding utf8
}
