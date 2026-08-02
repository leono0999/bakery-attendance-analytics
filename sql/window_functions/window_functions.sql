-- ============================================================
-- Window Functions
-- Demonstrates ranking, running aggregates, and period-over-period
-- comparisons using PostgreSQL window functions.
-- ============================================================


-- Rank employees by total hours worked (ties share a rank, next rank skips)
select
    "Nombre",
    sum("Total_Hours") as total_hours,
    rank() over (order by sum("Total_Hours") desc) as rank_with_gaps
from employee_summary
group by "Nombre";


-- Same ranking, but ties don't cause a gap in the following rank
select
    "Nombre",
    sum("Total_Hours") as total_hours,
    dense_rank() over (order by sum("Total_Hours") desc) as rank_no_gaps
from employee_summary
group by "Nombre";


-- Rank employees by odd punches, giving every row a unique sequential rank
select
    "Nombre",
    sum(num_punches) as total_odd_punches,
    row_number() over (order by sum(num_punches) desc) as rank
from odd_punches
group by "Nombre";


-- Rank employees by hours worked, restarting the ranking within each month
select
    "Nombre",
    "Month_Number",
    row_number() over (partition by "Month_Number" order by "Total_Hours" desc) as rank_in_month
from employee_summary;


-- Top attendance (days present) per employee, ranked within each month
with monthly_attendance as (
    select "Nombre", "Month_Number", count("Nombre") as days_present
    from attendance_report
    group by "Nombre", "Month_Number"
)
select
    "Nombre",
    "Month_Number",
    row_number() over (partition by "Month_Number" order by days_present desc) as rank_in_month
from monthly_attendance;


-- Rank employees by their average hours worked across all months
with employee_avg as (
    select "Nombre", avg("Average_Hours") as avg_hours
    from employee_summary
    group by "Nombre"
)
select
    "Nombre",
    avg_hours,
    row_number() over (order by avg_hours desc) as rank
from employee_avg;


-- Rank employees by their share of total company odd punches
with employee_odd_punches as (
    select "Nombre", sum(num_punches) as total_punches
    from odd_punches
    group by "Nombre"
)
select
    "Nombre",
    total_punches,
    rank() over (
        order by 100.0 * total_punches / (select sum(num_punches) from odd_punches) desc
    ) as rank
from employee_odd_punches;


-- Each employee's change in total hours vs. their own previous month
with employee_monthly as (
    select
        "Nombre",
        "Month_Number",
        "Total_Hours",
        lag("Total_Hours") over (partition by "Nombre" order by "Month_Number") as previous_month_hours
    from employee_summary
)
select
    "Nombre",
    "Total_Hours" - previous_month_hours as difference_from_previous_month
from employee_monthly
where previous_month_hours is not null
order by difference_from_previous_month desc;


-- Each month's total hours compared to the following month
with monthly_totals as (
    select "Month_Name", "Month_Number", sum("Total_Hours") as total_hours
    from employee_summary
    group by "Month_Name", "Month_Number"
)
select
    "Month_Name",
    total_hours - lead(total_hours) over (order by "Month_Number") as difference_vs_next_month
from monthly_totals;


-- Running total of company-wide hours worked, month over month
select distinct *
from (
    select
        "Month_Name",
        sum("Total_Hours") over (order by "Month_Number") as running_total_hours
    from employee_summary
) as monthly_running_total;


-- Running average of each employee's hours worked, month over month
select
    "Nombre",
    "Month_Name",
    avg("Total_Hours") over (
        partition by "Nombre"
        order by "Month_Number"
        rows between unbounded preceding and current row
    ) as running_avg_hours
from employee_summary;


-- Each employee's 2-month rolling average workload (current + next month)
select
    "Nombre",
    "Month_Name",
    avg("Total_Hours") over (
        partition by "Nombre"
        order by "Month_Number"
        rows between current row and 1 following
    ) as two_month_avg_hours
from employee_summary;


-- Running average of each employee's *average daily* hours, month over month
select
    "Nombre",
    avg("Average_Hours") over (
        partition by "Nombre"
        order by "Month_Number"
        rows between unbounded preceding and current row
    ) as running_avg_daily_hours
from employee_summary;


-- First and last recorded monthly total for each employee
select
    "Nombre",
    first_value("Total_Hours") over (
        partition by "Nombre" order by "Month_Number"
    ) as first_month_hours,
    last_value("Total_Hours") over (
        partition by "Nombre"
        order by "Month_Number"
        rows between unbounded preceding and unbounded following
    ) as last_month_hours
from employee_summary;


-- Split employees into 5 equally-sized productivity tiers by total hours
select
    "Nombre",
    sum("Total_Hours") as total_hours,
    ntile(5) over (order by sum("Total_Hours") desc) as productivity_tier
from employee_summary
group by "Nombre";


-- Cumulative distribution of employees by total hours worked
-- (what fraction of employees worked this many hours or fewer)
select
    "Nombre",
    sum("Total_Hours") as total_hours,
    cume_dist() over (order by sum("Total_Hours")) as cumulative_distribution
from employee_summary
group by "Nombre";
