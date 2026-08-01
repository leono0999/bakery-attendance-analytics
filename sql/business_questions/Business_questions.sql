---------------------------------------------------
--who employee worked more hours
---------------------------------------------------
select "Nombre",sum("Total_Hours")as Total_Hours 
from employee_summary 
group by "Nombre" 
order by Total_Hours desc
limit 1;
-------------------------------------------------- 
--Month with more hours worked 
---------------------------------------------------
select "Month_Name",sum("Total_Hours")as Total
from employee_summary
group by "Month_Name"
order by Total desc
limit 1;
--------------------------------------------------
--Employee who made more odd punches 
------------------------------------------------
select "Nombre",sum(num_punches) as total
from odd_punches
group by "Nombre"
order by total desc 
limit 1;
---------------------------------------------------
--employee who made less odd punches
--------------------------------------------------
select "Nombre",sum(num_punches) less
from odd_punches
group by "Nombre" 
order by Less 
limit 1;
------------------------------------------------
--which day had the highest average attendance 
-----------------------------------------------
select to_char("Fecha",'Day') as day, 
count(distinct "Nombre") num
from attendance_report
group by to_char("Fecha",'Day')
order by num desc 
limit 1;

------------------------------------------------------------
--which employee improved  most hours worked more from may to june
--------------------------------------------------------------
select m."Nombre",m."Total_Hours"-j."Total_Hours" hours_improved 
from employee_summary as m
inner join employee_summary as j
on m."Nombre"=j."Nombre" 
where m."Month_Number"=6 
and j."Month_Number"=5
order by hours_improved desc
limit 1
;
---------------------------------------------------------------
--which employee improved most the average worked hours from may to june
----------------------------------------------------------------

select m."Nombre",round((m."Average_Hours"-j."Average_Hours") ::numeric,2) improved
from employee_summary as m
inner join employee_summary as j 
on m."Nombre"=j."Nombre"
where m."Month_Number"=6 
and j."Month_Number"=5
order by improved desc
limit 1;
--------------------------------------------------------------------
--the odd punches improved or declined related to the previous month
----------------------------------------------------------------
with sub as(
select 
      "Month_Name","Month_Number",
      sum(num_punches) num_punches 
from odd_punches
group by "Month_Name","Month_Number"
)
select 
      m.num_punches as june,
      j.num_punches as may,
      m.num_punches-j.num_punches as difference,
      case
      	when m.num_punches>j.num_punches then 'declined'
      	when m.num_punches<j.num_punches then 'improved'
      	else 'no change'
      end as trend 
from sub m
join sub j
on m."Month_Number"=6 and j."Month_Number"=5;
--------------------------------------------------------------
--month with more odd punches----------------------------------
----------------------------------------------------------------
select "Month_Name",sum(num_punches) total_odd
from odd_punches  
group by "Month_Name" 
order by total_odd desc 
limit 1;
----------------------------------------------------
--the day when workers were absent the most , other than sunday---
-----------------------------------------------------
select to_char("Fecha",'Day')as day, count(*) numb
from attendance_report 
group by day 
order by numb asc 
limit 1;
-----------------------------------------------------
-- employees who worked more than 8 hours in mean 
------------------------------------------------------
select "Nombre",round(avg("Average_Hours")::numeric,2) as mean
from employee_summary
group by "Nombre"
having avg("Average_Hours") >=8.0
order by mean desc;
----------------------------------------------------
---employees who worked less than 8 hours in mean 
-----------------------------------------------------
select "Nombre",round(avg("Average_Hours")::numeric,2) average_jm
from employee_summary 
group by "Nombre" 
having avg("Average_Hours")<8
order by average_jm desc;
----------------------------------------------------------
--percentage of employees which worked more than 8 hours--
----------------------------------------------------------
with sub as(
select "Nombre" ,avg("Average_Hours") avg8
from employee_summary
group by "Nombre" 
having avg("Average_Hours")>8
)
select "Nombre",
       100.0*
             (avg8/
             (select sum(avg8) from sub)) percentage
from sub;

---------------------------------------------------------
---employees who have more than 173 hours worked per month
----------------------------------------------------------
select "Nombre","Month_Name","Total_Hours"
from employee_summary
where "Total_Hours">=173
order by "Nombre" ,"Month_Number";
----------------------------------------------------------
--employee with the highest average exit 
-------------------------------------------------------
select "Nombre","Month_Name",max("Average_Exit") as max
from employee_summary
group by "Nombre","Month_Name"
order by max desc
limit 1;
----------------------------------------------------
--employee with the lowest average entrance 
-------------------------------------------------------
select "Nombre", "Month_Name",min("Average_Entrance")as entrance
from employee_summary 
group by "Nombre" ,"Month_Name"
order by entrance asc 
limit 1;
------------------------------------------------------
--dates when employees worked less than 8 hours------
------------------------------------------------------
select "Nombre",
to_char("Fecha",'DD/mm/yyyy'),"Hours_Worked"
from attendance_report 
where "Hours_Worked"<8.0 and "Hours_Worked" <> 0;
--------------------------------------------------------
--Percentage of employees working an average of more than 8 hours
----------------------------------------------------------
with sub as(
select count("Average_Hours") avg
from employee_summary
where "Average_Hours">8
)
select 100.0*
       (avg::numeric/
       (select count("Total_Hours") from employee_summary)) percentage
from sub;
-------------------------------------------------------
--percentage of total hours worked per employee ------
------------------------------------------------------
select "Nombre",
round(100.0*(sum("Total_Hours")/
(select sum("Total_Hours")from employee_summary))::numeric,2)
percentage
from employee_summary
group by "Nombre"
order by percentage desc;
-----------------------------------------------------
--attendance percentage per employee 
-----------------------------------------------------
with sub as (
select 
      "Nombre",count(distinct "Fecha") cnt
from attendance_report
group by "Nombre" 
)
select 
      "Nombre",
      concat(round(100.0*cnt/
      (select count(distinct "Fecha")from attendance_report),2),'%')
as percentage
from sub 
order by percentage desc;
--------------------------------------------------------
--percentage of  odd punches per employee
------------------------------------------------------------
with sub as(
select 
      "Nombre",sum("num_punches")as total_punches
from odd_punches
group by "Nombre" 
)
select 
      "Nombre",concat(round(100.0*(total_punches/
      (select sum(num_punches)from odd_punches)),2),'%') 
      as odd
from sub
order by odd desc;
-------------------------------------------------------
--average attendance rate per month--------------
--------------------------------------------------
with sub as(
select "Month_Name",sum("Total_Hours") attendance_rate
from employee_summary
group by "Month_Name" 
)
select "Month_Name",
       concat(round(100.0*(attendance_rate/
       (select sum("Total_Hours")from employee_summary))::numeric,2),'%') 
       as month_rate
from sub
order by month_rate desc;

--------------------------------------------------
--standar desviation of worked hours 
----------------------------------------------
select 
round(stddev("Total_Hours")::numeric,2) as standar_desviation
from employee_summary ;
-----------------------------------------------
--company average hours of work 
----------------------------------------------
select avg("Total_Hours")as average
from employee_summary ;
---------------------------------------------
--difference between the company average and the average per employee
-----------------------------------------------
with sub as(
select "Nombre",
       round((avg("Total_Hours")-
       (select avg("Total_Hours")from employee_summary))::numeric,2) hours_difference
from employee_summary
group by "Nombre" 
)
select "Nombre",
       case
       	when hours_difference>0 then 
        concat('worked ',hours_difference,' hours more')
        else concat('worked ',hours_difference,' hours less')
        end final_trend
from sub
order by final_trend desc;

-------------------------------------------
--employees whit zero odd punches
------------------------------------------
select "Nombre",sum("Odd_Punches") total
from employee_summary
group by "Nombre"
having sum("Odd_Punches")=0;
------------------------------------------
--percentage of employees whit zero punches
------------------------------------------
with sub as(
select count("Odd_Punches") zero_punches
from employee_summary
where "Odd_Punches"=0
)
select 100.0*(zero_punches::numeric/
(select count("Odd_Punches")from employee_summary)) percentage
from sub ;
------------------------------------------
--clasified employees according to the odd punches where 0 is excellent
-- 1-5 is good 6-10 is ok 11-20 bad adn 20> very bad
--------------------------------------------
with sub as(
select 
      "Nombre",sum(num_punches) as num_punches
from odd_punches 
group by "Nombre"
)
select "Nombre",
case 
	when num_punches =0 then 'excelent'
	when num_punches between 1 and 5 then 'good' 
	when num_punches between 6 and 10 then 'ok' 
	when num_punches between 11 and 20 then'bad' 
	else 'very bad' end as performance_of_odd_punches
from sub
order by num_punches ;
--------------------------------------------------------
--month which has lowest average entrance --------------
--------------------------------------------------------
select 
"Month_Name",
to_char(timestamp '2022-01-01'+
avg(extract(epoch from "Average_Entrance"::time))
*interval '1 second' ,'HH24:MI:SS') as lowest
from employee_summary
group by "Month_Name" 
order by lowest 
limit 1;
---------------------------------------------------------
--month with the highest average exit---------------
--------------------------------------------------------
select "Month_Name",
to_char(timestamp '2020-01-01' +
avg(extract(epoch from "Average_Exit"::time))*interval '1 second','hh24:mi:ss')
highest
from employee_summary
group by "Month_Name" 
order by highest desc 
limit 1;
----------------------------------------------------------
--productivity trend-------------------------------------
---------------------------------------------------------
with sub as (
select 
       "Month_Name",
       "Month_Number",
       sum("Hours_Worked") "Hours_Worked"
from attendance_report
group by "Month_Name","Month_Number"
)
select 
      concat('+ ',round((j."Hours_Worked"-m."Hours_Worked")::numeric,2)) productivity,
concat(
       round(100.0*((j."Hours_Worked"-m."Hours_Worked")/j."Hours_Worked")::numeric,2),'%') percentage
from sub j
join sub m
on j."Month_Number"=6 and
   m."Month_Number"=5;
---------------------------------------------------------------
--histogram of how many times employess made odd_punches--------------
--------------------------------------------------------
with sub as(
select "Nombre",sum("Odd_Punches") total
from employee_summary
group by "Nombre"
order by total desc
)
select total as odd_punches,
count(total) number_of_workers
from sub 
group by odd_punches 
order by total ;


