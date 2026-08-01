from pathlib import Path

import pandas as pd


def create_attendance_report(
        
    raw_folder,attendance_output

):

    raw_folder = Path(

        raw_folder

    )

    attendance_output = Path(

        attendance_output

    )

    processed_folder = (

        attendance_output.parent

    )

    processed_folder.mkdir(

        parents=True,

        exist_ok=True

    )

    attendance_file = next(

        (

            file

            for file

            in raw_folder.iterdir()

            if file.name.lower().startswith(

                "attendance"

            )

            and file.suffix.lower()

            in [".xls", ".xlsx"]

        ),

        None

    )

    if attendance_file is None:

        raise FileNotFoundError(

            "No attendance file found."

        )

    print(

        f"Using {attendance_file.name}"

    )

    df = pd.read_excel(

        attendance_file

    )

    df = df.drop_duplicates()

    df["Tiempo"] = pd.to_datetime(

        df["Tiempo"],

        format="%d/%m/%Y %H:%M:%S"

    )

    df = df.drop(

        columns=[

            "Estado",

            "Tipo de Registro",

            "Dispositivos"

        ]

    )

    df["diff_sec"] = (

        df.groupby(

            "Número"

        )["Tiempo"]

        .diff()

        .dt.total_seconds()

    )

    df = df[

        (df["diff_sec"] > 600)

        |

        (df["diff_sec"].isna())

    ]

    df["Fecha"] = (

        df["Tiempo"]

        .dt.normalize()

    )

    pushes_per_day = (

        df.groupby(

            [

                "Número","Nombre","Fecha"

            ]

        )

        .size()

        .reset_index(

            name="num_punches"

        )

    )

    odd_punches = (

        pushes_per_day[

            pushes_per_day[

                "num_punches"

            ] % 2 != 0

        ]

    )

    odd_punches["Year"] = pd.to_datetime(odd_punches["Fecha"]).dt.year

    odd_punches["Month_Number"] = pd.to_datetime(odd_punches["Fecha"]).dt.month
    
    odd_punches["Month_Name"] = pd.to_datetime(odd_punches["Fecha"]).dt.strftime("%B")

    attendance_report = (

        df.groupby(

            ["Número", "Nombre","Fecha"]

        )

        .agg(

            Entrada=(

                "Tiempo","min"

            ),

            Salida=(

                "Tiempo","max"

            )

        )

        .reset_index()

    )
    attendance_report[
        
        'Hours_Worked'
        
        ]=((

            attendance_report['Salida']-attendance_report['Entrada']
            
            ).dt.total_seconds()/3600).round(2)
    
    attendance_report['Entrance_Seconds']=(

        attendance_report['Entrada'].dt.hour*3600+
        attendance_report['Entrada'].dt.minute*60+
        attendance_report['Entrada'].dt.second

    )
    
    attendance_report['Exit_Seconds']=(

        attendance_report['Salida'].dt.hour*3600+
        attendance_report['Salida'].dt.minute*60+
        attendance_report['Salida'].dt.second

    )

    attendance_report['Year'] = (
        
        attendance_report['Fecha'].dt.year
        
        )

    attendance_report['Month_Number'] = (
        
        attendance_report['Fecha'].dt.month
        
        )

    attendance_report['Month_Name']= (
        
        attendance_report['Fecha'].dt.strftime('%B')
        
        )


    employee_summary=(attendance_report.groupby([
        
        "Número",
        "Nombre",
        "Year",
        "Month_Number",
        "Month_Name"
        
        ]).agg(Days_Worked=('Fecha','count'),
            
    Total_Hours=(

        'Hours_Worked','sum'
        
        ),Average_Hours=(
            
            'Hours_Worked','mean'
            )
            
            ,Average_Entrance=(
                
                'Entrance_Seconds','mean'
                
                ),Average_Exit=(
                    
                    'Exit_Seconds','mean'
                    
                    )
                
                ).reset_index()
                
                )
    

    attendance_report = attendance_report.drop(
    columns=["Entrance_Seconds", "Exit_Seconds"]
)
    attendance_report = attendance_report[
    [
        "Número",
        "Nombre",
        "Fecha",
        "Year",
        "Month_Number",
        "Month_Name",
        "Entrada",
        "Salida",
        "Hours_Worked"
    ]
]
    
    odd_summary=(
        
        odd_punches.groupby(['Número','Nombre']).size().reset_index(name='Odd_Punches')
        
        )

    employee_summary=employee_summary.merge(
        
        odd_summary,on=['Número','Nombre'],how='left'
        
        )
    
    employee_summary['Odd_Punches']=(
        
        employee_summary['Odd_Punches'].fillna(0).astype(int)
        
        )

    attendance_report[

        "Entrada"

    ] = (

        attendance_report[

            "Entrada"

        ]

        .dt.time

    )

    attendance_report[

        "Salida"

    ] = (

        attendance_report[

            "Salida"

        ]

        .dt.time

    )

    employee_summary['Average_Entrance']= (
        
        pd.to_datetime(employee_summary['Average_Entrance'], unit='s').dt.round('s').dt.time
        
        )
        
        
    
    employee_summary['Average_Exit']=(
        
        pd.to_datetime(employee_summary['Average_Exit'], unit='s').dt.round('s').dt.time
        
        )


    attendance_report.to_excel(

        attendance_output,

        index=False

    )

    odd_punches.to_excel(

        processed_folder

        / "odd_punches.xlsx",

        index=False

    )

    employee_summary.to_excel(processed_folder / "employee_summary.xlsx", index=False)

    print(

        "\nAttendance report created."

    )
