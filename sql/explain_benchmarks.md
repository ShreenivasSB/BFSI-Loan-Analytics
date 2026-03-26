# EXPLAIN ANALYZE Benchmarks

## Query: Default Rate by Loan Grade

| Run | Actual Time | Notes |
|-----|-------------|-------|
| With idx_grade_id | 59,953ms | Index active |
| Without idx_grade_id (IGNORE INDEX) | 4,862ms | Full table scan |

## Query: Risk Tier Default Summary

| Run | Actual Time | Notes |
|-----|-------------|-------|
| With idx_risk_tier_id | 3,169ms | Index active |
| Without idx_risk_tier_id (IGNORE INDEX) | 3,144ms | Full table scan |

## Observation
For full GROUP BY aggregation queries on 1,342,942 rows, MySQL optimizer
preferred full table scan over index lookup in both cases. This is expected
behaviour — indexes are most beneficial for selective WHERE clause lookups,
not full aggregations across all rows.