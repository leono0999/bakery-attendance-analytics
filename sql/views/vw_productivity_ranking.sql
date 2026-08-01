
create or replace view vw_productivity_ranking as
select "Nombre",sum("Total_Hours") total,
 rank() 
        over(order by sum("Total_Hours") desc) productivity_ranking
from employee_summary 
group by "Nombre";
