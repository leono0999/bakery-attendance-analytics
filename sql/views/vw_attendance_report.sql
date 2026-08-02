-- Simplified attendance report for Power BI: one row per employee per day.
create or replace view vw_attendance_report as
select
    "Nombre",
    "Fecha",
    "Hours_Worked",
    "Entrada",
    "Salida"
from attendance_report;
