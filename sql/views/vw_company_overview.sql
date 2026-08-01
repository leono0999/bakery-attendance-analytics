create or replace view vw_company_overview as
with sub as(
select 
sum(num_punches) as Total_odd_punches ,
count(distinct "Nombre")as Employees_with_odd_punches
from odd_punches 
)
select 
sum(s."Total_Hours") as Total_Hours,
avg(s."Total_Hours") as Avg_Hours,
to_char(
        timestamp '2020-01-01' 
        + avg(extract(epoch from s."Average_Entrance"::time))
        * interval '1 second','hh24:mi:ss') as Avg_Entrance,
to_char(
        timestamp '2020-01-01' 
        + avg(extract(epoch from s."Average_Exit"::time))
        * interval '1 second','hh24:mi:ss') as Avg_Exit,
count(distinct s."Nombre") as Employees,
p.Total_odd_punches,
p.Employees_with_odd_punches
from employee_summary s
cross join sub p 
group by p.Total_odd_punches,
p.Employees_with_odd_punches;

