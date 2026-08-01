create or replace view vw_attendance_percentage as
with sub as(
select "Nombre",count(*)as atendance
from attendance_report
group by "Nombre"
)
select "Nombre",
round(
      100.0*
      (atendance::numeric/
      (select count(distinct "Fecha") from attendance_report)),2) percentage_attendance
from sub
order by percentage_attendance desc;

select * from vw_attendance_percentage

