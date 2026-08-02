-- Per-employee, per-month summary.
create or replace view vw_employee_summary as
select
    "Nombre",
    "Month_Name",
    "Total_Hours",
    "Average_Hours",
    "Average_Entrance",
    "Average_Exit",
    "Odd_Punches"
from employee_summary;
