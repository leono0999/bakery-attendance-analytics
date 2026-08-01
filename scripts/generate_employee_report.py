from pathlib import Path
from openpyxl import load_workbook
import pandas as pd
from datetime import datetime
import shutil

def generate_employee_reports(

    attendance_path,

    templates_folder,

    reports_folder

):

    attendance_path = Path(
        attendance_path
    )

    templates_folder = Path(
        templates_folder
    )

    reports_folder = Path(
        reports_folder
    )

    reports_folder.mkdir(
        exist_ok=True
    )

    # Delete old reports

    for file in reports_folder.glob(
        '*.xlsx'
    ):

        file.unlink()

    # Load attendance report

    df = pd.read_excel(
        attendance_path
    )

    # First name

    df['FirstName'] = (

        df['Nombre']

        .str.split()

        .str[0]

        .str.upper()

    )

    # Process employees

    for employee, group in (

        df.groupby(
            'FirstName'
        )

    ):

        employee_file = next(

            (

                file

                for file

                in templates_folder.iterdir()

                if file.name.upper().startswith(
                    employee
                )

                and file.suffix.lower()

                == '.xlsx'

            ),

            None

        )

        if employee_file is None:

            print(

                f'File not found for {employee}'

            )

            continue

        output_path = (

            reports_folder

            / employee_file.name

        )

        print(

            f'\nProcessing {employee_file.name}'

        )

        shutil.copy2(

            employee_file,

            output_path

        )

        wb = load_workbook(
            output_path
        )

        calculo_sheet = None

        for sheet in wb.sheetnames:

            if (

                sheet.strip().upper()

                == 'CALCULO'

            ):

                calculo_sheet = sheet

                break

        if calculo_sheet is None:

            print(

                f'CALCULO sheet not found for {employee}'

            )

            continue

        ws = wb[
            calculo_sheet
        ]

        # Clear old data

        for row in range(

            8,

            45

        ):

            ws[f'B{row}'] = None

            ws[f'E{row}'] = None

            ws[f'F{row}'] = None

        group = group.sort_values(
            'Fecha'
        )

        start_row = 8

        for i, (

            _,

            attendance_row

        ) in enumerate(

            group.iterrows()

        ):

            row = start_row + i

            attendance_date = (

                pd.to_datetime(

                    attendance_row[
                        'Fecha'
                    ]

                )

            )

            ws[f'B{row}'] = (

                attendance_date

            )

            ws[
                f'B{row}'
            ].number_format = (

                'dd/mm/yyyy'

            )

            entrada = pd.to_datetime(

                attendance_row[
                    'Entrada'
                ]

            )

            salida = pd.to_datetime(

                attendance_row[
                    'Salida'
                ]

            )

            ws[f'E{row}'] = (

                datetime(

                    1899,

                    12,

                    30,

                    entrada.hour,

                    entrada.minute,

                    entrada.second

                )

            )

            ws[f'F{row}'] = (

                datetime(

                    1899,

                    12,

                    30,

                    salida.hour,

                    salida.minute,

                    salida.second

                )

            )

            ws[
                f'E{row}'
            ].number_format = (

                'hh:mm:ss'

            )

            ws[
                f'F{row}'
            ].number_format = (

                'hh:mm:ss'

            )

        wb.save(
            output_path
        )

        print(
            f'Created: {output_path}'
        )

    print('\nDone!')