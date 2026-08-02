import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, inspect, text

# Load environment variables from .env (see .env.example)
load_dotenv()

DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "bakery_db")

if not DB_USER or not DB_PASSWORD:
    raise EnvironmentError("DB_USER and DB_PASSWORD must be set (see .env.example).")

# PostgreSQL connection
engine = create_engine(
    f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

# Project folders
project_folder = Path(__file__).resolve().parent.parent
processed_folder = project_folder / "data" / "processed"

# Read Excel files
attendance_report = pd.read_excel(processed_folder / "attendance_report.xlsx")
odd_punches = pd.read_excel(processed_folder / "odd_punches.xlsx")
employee_summary = pd.read_excel(processed_folder / "employee_summary.xlsx")


def export_table(df: pd.DataFrame, table_name: str) -> None:
    """Create or incrementally update a table for the current month's data.

    If the table does not exist yet, it is created from `df`. Otherwise,
    rows matching the year/month present in `df` are deleted and replaced,
    so re-running the pipeline for the same month is idempotent.
    """
    inspector = inspect(engine)

    if not inspector.has_table(table_name):
        df.to_sql(table_name, engine, if_exists="append", index=False)
        print(f"✓ Created '{table_name}' ({len(df)} rows)")
        return

    year = int(df["Year"].iloc[0])
    month = int(df["Month_Number"].iloc[0])

    with engine.begin() as conn:
        conn.execute(
            text(f"""
                DELETE FROM {table_name}
                WHERE "Year" = :year
                AND "Month_Number" = :month
                """),
            {"year": year, "month": month},
        )

    df.to_sql(table_name, engine, if_exists="append", index=False)
    print(f"✓ Updated '{table_name}' ({len(df)} rows)")


if __name__ == "__main__":
    export_table(attendance_report, "attendance_report")
    export_table(odd_punches, "odd_punches")
    export_table(employee_summary, "employee_summary")
    print("Export completed successfully!")
