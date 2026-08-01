-------------------------------------------------
--rank employees by worked hours
-------------------------------------------------
select "Nombre",sum("Total_Hours") total,
 rank() 
        over(order by sum("Total_Hours") desc) rk
from employee_summary 
group by "Nombre";
-----------------------------------------------
--Rank employees by total worked hours without skipping positions 
----------------------------------------------
select "Nombre",sum("Total_Hours") Total,
dense_rank()
            over (order by sum("Total_Hours") desc) Ranking
from employee_summary
group by "Nombre";
----------------------------------------------------
--rank employees by odd punches
---------------------------------------------

select "Nombre",sum(num_punches) total,
row_number() 
            over(order by sum(num_punches) desc)
from odd_punches 
group by "Nombre";
-----------------------------------------------
--rank emloyees within each month
-----------------------------------------------
select "Nombre",
       row_number()
       over
       (partition by "Month_Number" order by "Total_Hours"desc) rk
from employee_summary;
----------------------------------------------
--top attendance by month
---------------------------------------------
with sub as(
select "Nombre", count("Nombre") total,"Month_Number"
from attendance_report 
group by "Nombre","Month_Number"
order by total desc
)
select "Nombre",
       row_number() 
       over(partition by "Month_Number" order by total desc)
from sub ;
--------------------------------------------------------
--rank employees by average worked hours
--------------------------------------------------------
with sub as(
select "Nombre", avg("Average_Hours") avg
from employee_summary
group by "Nombre" 
)
select "Nombre", 
       row_number() 
       over(order by avg desc) as rank
from sub ;
--------------------------------------------------------
--rank employees by percentage of odd punches 
--------------------------------------------------------
with sub as (
select "Nombre",sum(num_punches) sum
from odd_punches 
group by "Nombre"
)
select "Nombre",
        rank()
        over(order by  100.0*(sum/(select sum(num_punches) from odd_punches)) desc)
from sub;
-------------------------------------------------------
--employees difference from previous month
-------------------------------------------------------
with sub as(
select "Nombre",
       "Total_Hours",
       lag("Total_Hours")
       over(partition by "Nombre" 
       order by "Nombre" ,"Month_Number") previous,
       "Total_Hours"-lag("Total_Hours")
       over(partition by "Nombre" 
       order by "Nombre" ,"Month_Number") difference
from employee_summary
)
select "Nombre",difference
from sub 
where difference is not null
order by difference desc;

-------------------------------------------------------
--month comparation with next month
-------------------------------------------------------
with sub as(
select "Month_Name",sum("Total_Hours") total,"Month_Number"
from employee_summary
group by "Month_Name" ,"Month_Number"
)
select "Month_Name",
       total-lead("total")
       over(order by "Month_Number") difference_nextmonth
from sub;
-------------------------------------------------------
--running company hours
-------------------------------------------------------
select distinct* 
from(select "Month_Name",
sum("Total_Hours")over(order by "Month_Number") total
from employee_summary)
;
----------------------------------------------------------
--running average of hours worked per employee
---------------------------------------------------------
select "Nombre","Month_Name",avg("Total_Hours")over 
(partition by "Nombre" 
 order by "Month_Number" 
 rows between unbounded preceding 
      and current row)
from employee_summary;
--------------------------------------------------------
--How does each employee's 2-month average workload evolve over time?
-----------------------------------------------------
select "Nombre", "Month_Name",
avg("Total_Hours")
over(partition by "Nombre" 
order by "Month_Number" 
rows between current row 
     and 1 following)
from employee_summary ;
------------------------------------------------------
--running average hours
------------------------------------------------------
select "Nombre",
avg("Average_Hours")
over(partition by "Nombre" 
order by "Month_Number"
rows between unbounded preceding 
        and current row )
from employee_summary;
-----------------------------------------------------
--first and last value of Total hours worked per employee
-----------------------------------------------------
select "Nombre",
first_value("Total_Hours")
over (partition by "Nombre" 
order by "Month_Number" 
),
last_value("Total_Hours")
over(partition by "Nombre" 
order by "Month_Number"
rows between unbounded preceding 
     and unbounded following)
from employee_summary;
--------------------------------------------------
--Divide employees into five productivity groups based on total worked hours.
--------------------------------------------------
select "Nombre",
sum("Total_Hours") total,
ntile(5)
over(order by sum("Total_Hours")desc)
from employee_summary 
group by "Nombre";
-------------------------------------------------
--Determine the cumulative distribution of employees according to their total worked hours.
---------------------------------------------------
select "Nombre",sum("Total_Hours")total,
cume_dist()
over(order by sum("Total_Hours"))
from employee_summary
group by "Nombre";
