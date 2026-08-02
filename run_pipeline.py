import sys
from pathlib import Path

from scripts.final import create_attendance_report
from scripts.generate_employee_report import generate_employee_reports

if __name__ == "__main__":

    if getattr(sys, "frozen", False):
        project_folder = Path(sys.executable).resolve().parent
    else:
        project_folder = Path(__file__).resolve().parent

    raw_folder = project_folder / "data" / "raw"
    attendance_path = project_folder / "data" / "processed" / "attendance_report.xlsx"
    templates_folder = project_folder / "data" / "templates"
    reports_folder = project_folder / "data" / "reports"

    print("Project folder:", project_folder)

    print("Step 1: Cleaning attendance file...")
    create_attendance_report(raw_folder, attendance_path)

    print("Step 2: Generating reports...")
    generate_employee_reports(attendance_path, templates_folder, reports_folder)

    print("\nDone!")
