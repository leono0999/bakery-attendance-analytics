from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine, inspect, text

# PostgreSQL connection

engine = create_engine(
    "postgresql+psycopg2://postgres:1234@localhost:5432/bakery_db"
)

# Project folders

project_folder = (
    Path(__file__)
    .resolve()
    .parent
    .parent
)

processed_folder = (
    project_folder
    / "data"
    / "processed"
)

# Read Excel files

attendance_report = pd.read_excel(
    processed_folder / "attendance_report.xlsx"
)

odd_punches = pd.read_excel(
    processed_folder / "odd_punches.xlsx"
)

employee_summary = pd.read_excel(
    processed_folder / "employee_summary.xlsx"
)

# Export function

def export_table(df, table_name):

    inspector = inspect(engine)

    # Create table if it doesn't exist
    if not inspector.has_table(table_name):

        df.to_sql(
            table_name,
            engine,
            if_exists="append",
            index=False
        )

        print(f"✓ Created '{table_name}' ({len(df)} rows)")
        return

    # Delete only this month
    year = int(df["Year"].iloc[0])
    month = int(df["Month_Number"].iloc[0])

    with engine.begin() as conn:

        conn.execute(
            text(f"""
                DELETE FROM {table_name}
                WHERE "Year" = :year
                AND "Month_Number" = :month
            """),
            {
                "year": year,
                "month": month
            }
        )

    # Append new data
    df.to_sql(
        table_name,
        engine,
        if_exists="append",
        index=False
    )

    print(f"✓ Updated '{table_name}' ({len(df)} rows)")

# Export tables

export_table(
    attendance_report,
    "attendance_report"
)

export_table(
    odd_punches,
    "odd_punches"
)

export_table(
    employee_summary,
    "employee_summary"
)

print(" Export completed successfully!")