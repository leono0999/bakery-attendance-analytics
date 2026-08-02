-- Percentage of all recorded days each employee was present.
-- Denominator is the total distinct dates the company recorded
-- attendance for (i.e. all working days in the period).
create or replace view vw_attendance_percentage as
with days_present as (
    select "Nombre", count(*) as days_present
    from attendance_report
    group by "Nombre"
)
select
    "Nombre",
    round(
        100.0 * days_present::numeric
        / (select count(distinct "Fecha") from attendance_report),
        2
    ) as percentage_attendance
from days_present
order by percentage_attendance desc;
