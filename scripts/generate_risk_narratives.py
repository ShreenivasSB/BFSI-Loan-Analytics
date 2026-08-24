"""
Phase 7 - AI-generated risk narratives via local Ollama (llama3).

Queries BigQuery for the same default-rate aggregates already shown on the
Power BI dashboard (by grade, DTI band, risk tier, loan purpose), sends each
segment's real numbers to a local Ollama model to turn into a one-line,
dashboard-style narrative bullet, and writes the results to
bfsi_loans.risk_narrative_insights. The table is ready to be connected to
Power BI's Risk Intelligence page, replacing its hardcoded text box.

Runs entirely locally (BigQuery query + local Ollama inference) - no paid
LLM API, matches the zero-billing-risk pattern used throughout this project.

Run with:
  C:\\Users\\shree\\anaconda3\\envs\\bfsi-dbt\\python.exe scripts/generate_risk_narratives.py

Requires: Ollama running locally (`ollama serve`, usually auto-started) with
the llama3 model pulled (`ollama pull llama3`).
"""
import datetime
import json

import requests
from google.cloud import bigquery

PROJECT = "bfsi-loan-analytics"
DATASET = "bfsi_loans"
OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL = "llama3"
TABLE_ID = f"{PROJECT}.{DATASET}.risk_narrative_insights"

client = bigquery.Client(project=PROJECT)

# One query per dashboard segment - same joins fact_loans already uses via
# its dimension tables. Ordered so the LLM sees best-to-worst risk, which
# keeps its comparison direction (e.g. "X times higher than Y") consistent.
SEGMENT_QUERIES = {
    "grade": f"""
        SELECT g.grade AS segment, COUNT(*) AS total_loans,
               ROUND(AVG(f.loan_outcome) * 100, 2) AS default_rate_pct
        FROM `{PROJECT}.{DATASET}.fact_loans` f
        JOIN `{PROJECT}.{DATASET}.dim_grade` g ON f.grade_id = g.grade_id
        GROUP BY grade
        ORDER BY grade
    """,
    "dti_band": f"""
        SELECT d.dti_band AS segment, COUNT(*) AS total_loans,
               ROUND(AVG(f.loan_outcome) * 100, 2) AS default_rate_pct
        FROM `{PROJECT}.{DATASET}.fact_loans` f
        JOIN `{PROJECT}.{DATASET}.dim_dti_band` d ON f.dti_band_id = d.dti_band_id
        GROUP BY dti_band
        ORDER BY default_rate_pct
    """,
    "risk_tier": f"""
        SELECT r.risk_tier AS segment, COUNT(*) AS total_loans,
               ROUND(AVG(f.loan_outcome) * 100, 2) AS default_rate_pct
        FROM `{PROJECT}.{DATASET}.fact_loans` f
        JOIN `{PROJECT}.{DATASET}.dim_risk_tier` r ON f.risk_tier_id = r.risk_tier_id
        GROUP BY risk_tier
        ORDER BY default_rate_pct
    """,
    "purpose": f"""
        SELECT p.purpose AS segment, COUNT(*) AS total_loans,
               ROUND(AVG(f.loan_outcome) * 100, 2) AS default_rate_pct
        FROM `{PROJECT}.{DATASET}.fact_loans` f
        JOIN `{PROJECT}.{DATASET}.dim_purpose` p ON f.purpose_id = p.purpose_id
        GROUP BY purpose
        ORDER BY default_rate_pct DESC
    """,
}

# Style anchor pulled verbatim from README's existing "Key Findings" bullets,
# so the LLM matches the dashboard's established tone instead of inventing
# its own.
#
# Important lesson learned building this: llama3:8b is NOT reliable at
# picking the min/max row out of a list on its own - tested asking it to
# identify the highest/lowest-risk segment itself, and it picked the wrong
# segment for both `grade` (picked Grade F, 44.95%, instead of the actual
# highest Grade G at 49.5%) and `purpose` (picked debt_consolidation, 21.04%,
# instead of the actual highest small_business at 29.43% - not even close).
# Small local models are unreliable at this kind of numeric reasoning over a
# list. Fix: compute the highest/lowest segment and the exact multiplier in
# Python (deterministic, always correct - see `pick_extremes` below) and only
# ask Ollama to phrase the *already-selected* facts into one polished
# sentence. This is the right division of labor: SQL/Python for numbers,
# LLM for fluent natural-language phrasing.
PROMPT_TEMPLATE = """You are a business analyst writing a one-line risk insight for a loan portfolio dashboard.

These facts are already verified correct - do not change, recompute, or second-guess any of them:
- Highest-risk segment: "{high_segment}" at {high_rate}% default rate
- Lowest-risk segment: "{low_segment}" at {low_rate}% default rate
- Risk multiplier (highest rate / lowest rate): {multiplier}x

Write exactly ONE bullet point (one sentence, no more than 30 words) that reports these exact
facts in natural language, with markdown **bold** around the key numbers. Do NOT introduce any
other segment or number. Output ONLY the bullet text starting with "-", no preamble, no "Here is...".

Example of the exact tone to match: "- Grade G defaults at nearly **8.3x higher** than Grade A"

Your bullet:"""


def format_data_table(rows):
    lines = [f"{r['segment']}: {r['default_rate_pct']}% default rate ({r['total_loans']:,} loans)" for r in rows]
    return "\n".join(lines)


def pick_extremes(rows):
    """Deterministically find the highest- and lowest-risk segment in Python
    - see the note above PROMPT_TEMPLATE for why this can't be left to the LLM."""
    highest = max(rows, key=lambda r: r["default_rate_pct"])
    lowest = min(rows, key=lambda r: r["default_rate_pct"])
    multiplier = round(highest["default_rate_pct"] / lowest["default_rate_pct"], 2)
    return highest, lowest, multiplier


def call_ollama(prompt: str) -> str:
    resp = requests.post(
        OLLAMA_URL,
        json={"model": MODEL, "prompt": prompt, "stream": False, "options": {"temperature": 0.2}},
        timeout=120,
    )
    resp.raise_for_status()
    text = resp.json()["response"].strip()
    # Keep only the bullet line in case the model adds stray text anyway.
    for line in text.splitlines():
        line = line.strip()
        if line.startswith("-") or line.startswith("*"):
            return "- " + line.lstrip("-* ").strip()
    return text


def build_fallback(category, highest, lowest, multiplier):
    """Deterministic sentence used if the LLM output fails validation (see
    below) - guarantees the dashboard never shows a number the LLM altered."""
    return (f"- {highest['segment']} defaults at **{highest['default_rate_pct']}%**, "
            f"**{multiplier}x higher** than {lowest['segment']} at **{lowest['default_rate_pct']}%** "
            f"(by {category.replace('_', ' ')}).")


def validate_narrative(narrative, highest, lowest, multiplier):
    """Even with a constrained prompt, an 8B local model can still drop or
    subtly alter a number. Require the exact rate strings to appear verbatim
    before trusting the LLM's phrasing - if not, the caller falls back to a
    deterministic sentence instead of shipping an unverified number."""
    required = [str(highest["default_rate_pct"]), str(lowest["default_rate_pct"]), str(multiplier)]
    return all(token in narrative for token in required)


def main():
    generated_at = datetime.datetime.now(datetime.timezone.utc).isoformat()
    results = []

    for category, sql in SEGMENT_QUERIES.items():
        print(f"Querying BigQuery for segment: {category} ...")
        rows = [dict(row) for row in client.query(sql).result()]
        data_table = format_data_table(rows)
        print(f"  {len(rows)} rows:\n{data_table}\n")

        highest, lowest, multiplier = pick_extremes(rows)
        print(f"  Extremes (computed in Python): highest={highest['segment']} ({highest['default_rate_pct']}%), "
              f"lowest={lowest['segment']} ({lowest['default_rate_pct']}%), multiplier={multiplier}x")

        prompt = PROMPT_TEMPLATE.format(
            high_segment=highest["segment"], high_rate=highest["default_rate_pct"],
            low_segment=lowest["segment"], low_rate=lowest["default_rate_pct"],
            multiplier=multiplier,
        )
        print(f"  Calling Ollama ({MODEL}) ...")
        narrative = call_ollama(prompt)

        if not validate_narrative(narrative, highest, lowest, multiplier):
            print(f"  ! LLM output failed number-validation, using deterministic fallback: {narrative!r}")
            narrative = build_fallback(category, highest, lowest, multiplier)

        print(f"  -> {narrative}\n")

        results.append({
            "category": category,
            "narrative_text": narrative,
            "generated_at": generated_at,
        })

    schema = [
        bigquery.SchemaField("category", "STRING", mode="REQUIRED"),
        bigquery.SchemaField("narrative_text", "STRING", mode="REQUIRED"),
        bigquery.SchemaField("generated_at", "TIMESTAMP", mode="REQUIRED"),
    ]
    job_config = bigquery.LoadJobConfig(
        schema=schema,
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
        source_format=bigquery.SourceFormat.NEWLINE_DELIMITED_JSON,
    )
    json_rows = [json.dumps(r) for r in results]
    load_source = "\n".join(json_rows).encode("utf-8")

    import io
    job = client.load_table_from_file(
        io.BytesIO(load_source), TABLE_ID, job_config=job_config,
        job_id_prefix="risk_narratives_", rewind=True,
    )
    job.result()

    table = client.get_table(TABLE_ID)
    print(f"Done. Wrote {table.num_rows} rows to {TABLE_ID}")


if __name__ == "__main__":
    main()
