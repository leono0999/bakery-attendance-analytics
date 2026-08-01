create or replace view vw_company_summary as
with sub as(
select "Month_Name","Month_Number",
sum(num_punches) as Total_odd_punches ,
count(distinct "Nombre")as Employees_with_odd_punches
from odd_punches 
group by "Month_Name","Month_Number"
)
select 
s."Month_Name",
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
left join sub p 
on s."Month_Number"=p."Month_Number"
group by s."Month_Name",s."Month_Number",
p.Total_odd_punches,p.Employees_with_odd_punches
order by s."Month_Number";
