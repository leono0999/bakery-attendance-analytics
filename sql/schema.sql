
CREATE TABLE public.attendance_report (
	"Número" int8 NULL,
	"Nombre" text NULL,
	"Fecha" timestamp NULL,
	"Year" int8 NULL,
	"Month_Number" int8 NULL,
	"Month_Name" text NULL,
	"Entrada" text NULL,
	"Salida" text NULL,
	"Hours_Worked" float8 NULL
);


CREATE TABLE public.employee_summary (
	"Número" int8 NULL,
	"Nombre" text NULL,
	"Year" int8 NULL,
	"Month_Number" int8 NULL,
	"Month_Name" text NULL,
	"Days_Worked" int8 NULL,
	"Total_Hours" float8 NULL,
	"Average_Hours" float8 NULL,
	"Average_Entrance" text NULL,
	"Average_Exit" text NULL,
	"Odd_Punches" int8 NULL
);


CREATE TABLE public.odd_punches (
	"Número" int8 NULL,
	"Nombre" text NULL,
	"Fecha" timestamp NULL,
	num_punches int8 NULL,
	"Year" int8 NULL,
	"Month_Number" int8 NULL,
	"Month_Name" text NULL
);
