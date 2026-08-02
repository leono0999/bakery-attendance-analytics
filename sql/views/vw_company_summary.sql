-- Company-wide totals broken down by month.
create or replace view vw_company_summary as
with odd_punch_totals as (
    select
        "Month_Name",
        "Month_Number",
        sum(num_punches) as total_odd_punches,
        count(distinct "Nombre") as employees_with_odd_punches
    from odd_punches
    group by "Month_Name", "Month_Number"
)
select
    s."Month_Name",
    sum(s."Total_Hours") as total_hours,
    avg(s."Total_Hours") as avg_hours,
    to_char(
        timestamp '2020-01-01' + avg(extract(epoch from s."Average_Entrance"::time)) * interval '1 second',
        'HH24:MI:SS'
    ) as avg_entrance,
    to_char(
        timestamp '2020-01-01' + avg(extract(epoch from s."Average_Exit"::time)) * interval '1 second',
        'HH24:MI:SS'
    ) as avg_exit,
    count(distinct s."Nombre") as employees,
    p.total_odd_punches,
    p.employees_with_odd_punches
from employee_summary s
left join odd_punch_totals p
    on s."Month_Number" = p."Month_Number"
group by
    s."Month_Name", s."Month_Number",
    p.total_odd_punches, p.employees_with_odd_punches
order by s."Month_Number";

