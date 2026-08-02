-- ============================================================
-- Business Questions
-- Ad-hoc analytical queries answering specific stakeholder
-- questions about attendance and productivity for May-June.
-- ============================================================

-- Which employee worked the most total hours?
select "Nombre", sum("Total_Hours") as total_hours
from employee_summary
group by "Nombre"
order by total_hours desc
limit 1;


-- Which month had the most total hours worked?
select "Month_Name", sum("Total_Hours") as total_hours
from employee_summary
group by "Month_Name"
order by total_hours desc
limit 1;


-- Which employee had the most odd (unpaired) punches?
-- An "odd punch" day is one with a missed clock-in or clock-out.
select "Nombre", sum(num_punches) as total_odd_punches
from odd_punches
group by "Nombre"
order by total_odd_punches desc
limit 1;


-- Which employee had the fewest odd punches?
select "Nombre", sum(num_punches) as total_odd_punches
from odd_punches
group by "Nombre"
order by total_odd_punches asc
limit 1;


-- Which day of the week has the highest average attendance?
select
    to_char("Fecha", 'Day') as day_of_week,
    count(distinct "Nombre") as employees_present
from attendance_report
group by day_of_week
order by employees_present desc
limit 1;


-- Which employee increased their total hours the most from May to June?
select
    m."Nombre",
    m."Total_Hours" - j."Total_Hours" as hours_improved
from employee_summary as m
inner join employee_summary as j
    on m."Nombre" = j."Nombre"
where m."Month_Number" = 6
  and j."Month_Number" = 5
order by hours_improved desc
limit 1;


-- Which employee improved their average daily hours the most from May to June?
select
    m."Nombre",
    round((m."Average_Hours" - j."Average_Hours")::numeric, 2) as avg_hours_improved
from employee_summary as m
inner join employee_summary as j
    on m."Nombre" = j."Nombre"
where m."Month_Number" = 6
  and j."Month_Number" = 5
order by avg_hours_improved desc
limit 1;


-- Did odd punches improve or decline company-wide from May to June?
with monthly_odd_punches as (
    select "Month_Name", "Month_Number", sum(num_punches) as num_punches
    from odd_punches
    group by "Month_Name", "Month_Number"
)
select
    j.num_punches as may_punches,
    m.num_punches as june_punches,
    m.num_punches - j.num_punches as difference,
    case
        when m.num_punches > j.num_punches then 'declined'
        when m.num_punches < j.num_punches then 'improved'
        else 'no change'
    end as trend
from monthly_odd_punches m
join monthly_odd_punches j
    on m."Month_Number" = 6 and j."Month_Number" = 5;


-- Which month had the most odd punches overall?
select "Month_Name", sum(num_punches) as total_odd_punches
from odd_punches
group by "Month_Name"
order by total_odd_punches desc
limit 1;


-- Which day (other than Sunday) had the fewest employees present?
select
    to_char("Fecha", 'Day') as day_of_week,
    count(*) as attendance_count
from attendance_report
group by day_of_week
order by attendance_count asc
limit 1;


-- Employees whose average daily hours are 8 or more
select "Nombre", round(avg("Average_Hours")::numeric, 2) as avg_hours
from employee_summary
group by "Nombre"
having avg("Average_Hours") >= 8.0
order by avg_hours desc;


-- Employees whose average daily hours are below 8
select "Nombre", round(avg("Average_Hours")::numeric, 2) as avg_hours
from employee_summary
group by "Nombre"
having avg("Average_Hours") < 8.0
order by avg_hours desc;


-- What percentage of employees average more than 8 hours a day?
with over_8_hours as (
    select "Nombre"
    from employee_summary
    group by "Nombre"
    having avg("Average_Hours") > 8.0
)
select
    round(
        100.0 * (select count(*) from over_8_hours)
        / (select count(distinct "Nombre") from employee_summary),
        2
    ) as pct_over_8_hours;


-- Employees who logged 173+ total hours in a single month
select "Nombre", "Month_Name", "Total_Hours"
from employee_summary
where "Total_Hours" >= 173
order by "Nombre", "Month_Number";


-- Employee/month with the latest average exit time
select "Nombre", "Month_Name", max("Average_Exit") as latest_exit
from employee_summary
group by "Nombre", "Month_Name"
order by latest_exit desc
limit 1;


-- Employee/month with the earliest average entrance time
select "Nombre", "Month_Name", min("Average_Entrance") as earliest_entrance
from employee_summary
group by "Nombre", "Month_Name"
order by earliest_entrance asc
limit 1;


-- Individual days where an employee worked fewer than 8 hours
-- (excludes 0-hour rows, which represent a single unmatched punch, not a real shift)
select
    "Nombre",
    to_char("Fecha", 'DD/MM/YYYY') as date,
    "Hours_Worked"
from attendance_report
where "Hours_Worked" < 8.0
  and "Hours_Worked" <> 0;


-- Percentage of total company hours contributed by each employee
select
    "Nombre",
    round(
        100.0 * (sum("Total_Hours")
        / (select sum("Total_Hours") from employee_summary))::numeric,
        2
    ) as pct_of_total_hours
from employee_summary
group by "Nombre"
order by pct_of_total_hours desc;


-- Attendance rate per employee: days present out of all days worked company-wide
with days_present as (
    select "Nombre", count(distinct "Fecha") as days_present
    from attendance_report
    group by "Nombre"
)
select
    "Nombre",
    concat(
        round(
            100.0 * days_present
            / (select count(distinct "Fecha") from attendance_report),
            2
        ),
        '%'
    ) as attendance_rate
from days_present
order by attendance_rate desc;


-- Share of all odd punches attributable to each employee

with employee_odd_punches as (
    select "Nombre", sum(num_punches) as total_punches
    from odd_punches
    group by "Nombre"
)
select
    "Nombre",
    concat(
        round(
            100.0 * total_punches
            / (select sum(num_punches) from odd_punches),
            2
        ),
        '%'
    ) as pct_of_odd_punches
from employee_odd_punches
order by pct_of_odd_punches desc;


-- Each month's share of total hours worked
with monthly_hours as (
    select "Month_Name", sum("Total_Hours") as month_hours
    from employee_summary
    group by "Month_Name"
)
select
    "Month_Name",
    concat(
        round(100.0 * (month_hours / (select sum("Total_Hours") from employee_summary))::numeric,2),
        '%'
    ) as pct_of_total_hours
from monthly_hours
order by pct_of_total_hours desc;


-- Standard deviation of total hours worked (spread of workload across employees)
select round(stddev("Total_Hours")::numeric, 2) as hours_stddev
from employee_summary;


-- Company-wide average hours worked
select avg("Total_Hours") as company_avg_hours
from employee_summary;


-- How each employee's average compares to the company average
with employee_avg as (
    select
        "Nombre",
        round(
            (avg("Total_Hours") - (select avg("Total_Hours") from employee_summary))::numeric,
            2
        ) as hours_difference
    from employee_summary
    group by "Nombre"
)
select
    "Nombre",
    case
        when hours_difference > 0 then concat('worked ', hours_difference, ' hours more')
        else concat('worked ', abs(hours_difference), ' hours less')
    end as vs_company_average
from employee_avg
order by hours_difference desc;


-- Employees with zero odd punches (perfect punch record)
select "Nombre", sum("Odd_Punches") as total_odd_punches
from employee_summary
group by "Nombre"
having sum("Odd_Punches") = 0;


-- What percentage of employees have zero odd punches?
with zero_punches_t as (
    select "Nombre", sum("Odd_Punches") as total_odd_punches
    from employee_summary
    group by "Nombre"
    having sum("Odd_Punches") = 0
),
zero_punches as(
    select count("Nombre") as employee_count from zero_punches_t
)
select
    round(
        100.0 * employee_count
        / (select count(distinct "Nombre") from employee_summary),
        2
    ) as pct_zero_punches
from zero_punches;


-- Classify employees by punch discipline
--   0            -> excellent
--   1-5          -> good
--   6-10         -> ok
--   11-20        -> bad
--   21+          -> very bad
with employee_odd_punches as (
    select "Nombre", sum(num_punches) as num_punches
    from odd_punches
    group by "Nombre"
)
select
    "Nombre",
    case
        when num_punches = 0 then 'excellent'
        when num_punches between 1 and 5 then 'good'
        when num_punches between 6 and 10 then 'ok'
        when num_punches between 11 and 20 then 'bad'
        else 'very bad'
    end as punch_rating
from employee_odd_punches
order by num_punches;


-- Month with the earliest average entrance time
select
    "Month_Name",
    to_char(
        timestamp '2020-01-01' + avg(extract(epoch from "Average_Entrance"::time)) * interval '1 second',
        'HH24:MI:SS'
    ) as earliest_avg_entrance
from employee_summary
group by "Month_Name"
order by earliest_avg_entrance
limit 1;


-- Month with the latest average exit time
select
    "Month_Name",
    to_char(
        timestamp '2020-01-01' + avg(extract(epoch from "Average_Exit"::time)) * interval '1 second',
        'HH24:MI:SS'
    ) as latest_avg_exit
from employee_summary
group by "Month_Name"
order by latest_avg_exit desc
limit 1;


-- Company productivity trend: change in total hours worked, May -> June
with monthly_hours as (
    select "Month_Name", "Month_Number", sum("Hours_Worked") as hours_worked
    from attendance_report
    group by "Month_Name", "Month_Number"
)
select
    concat('+ ', round((june."hours_worked" - may."hours_worked")::numeric, 2)) as hours_change,
    concat(
        round(100.0 * ((june."hours_worked" - may."hours_worked")/ may."hours_worked")::numeric, 2),
        '%'
    ) as pct_change
from monthly_hours june
join monthly_hours may
    on june."Month_Number" = 6 and may."Month_Number" = 5;


-- Distribution of odd-punch counts across employees
-- (e.g. "3 employees had exactly 2 odd punches this period")
with employee_totals as (
    select "Nombre", sum("Odd_Punches") as total_odd_punches
    from employee_summary
    group by "Nombre"
)
select
    total_odd_punches,
    count(*) as number_of_employees
from employee_totals
group by total_odd_punches
order by total_odd_punches;


