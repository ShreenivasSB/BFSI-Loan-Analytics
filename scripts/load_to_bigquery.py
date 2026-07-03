"""
Load lending_club_features.csv into BigQuery raw.raw_loans.
Run with: C:\\Users\\shree\\anaconda3\\envs\\bfsi-dbt\\python.exe scripts/load_to_bigquery.py
"""
import os
from google.cloud import bigquery

PROJECT = "bfsi-loan-analytics"
CSV_PATH = os.path.join(os.path.dirname(__file__), "..", "data", "processed", "lending_club_features.csv")

client = bigquery.Client(project=PROJECT)

# Create datasets if they don't exist
for dataset_id in ["raw", "bfsi_loans"]:
    dataset = bigquery.Dataset(f"{PROJECT}.{dataset_id}")
    dataset.location = "US"
    client.create_dataset(dataset, exists_ok=True)
    print(f"  Dataset '{dataset_id}': ready")

# Load CSV directly into raw.raw_loans
table_id = f"{PROJECT}.raw.raw_loans"

job_config = bigquery.LoadJobConfig(
    source_format=bigquery.SourceFormat.CSV,
    skip_leading_rows=1,
    autodetect=True,
    write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
)

print(f"\nUploading {os.path.abspath(CSV_PATH)} ...")
print("This will take a few minutes for a 704 MB file — please wait.\n")

with open(CSV_PATH, "rb") as f:
    job = client.load_table_from_file(f, table_id, job_config=job_config)

job.result()  # blocks until the load job completes

table = client.get_table(table_id)
print(f"Done! Loaded {table.num_rows:,} rows, {len(table.schema)} columns")
print(f"Table: {table.project}.{table.dataset_id}.{table.table_id}")
