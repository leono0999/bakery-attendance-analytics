-- Ranks employees by total hours worked across the full period.
create or replace view vw_productivity_ranking as
select
    "Nombre",
    sum("Total_Hours") as total_hours,
    rank() over (order by sum("Total_Hours") desc) as productivity_ranking
from employee_summary
group by "Nombre";
