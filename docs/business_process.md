# Bakery attendance etl project
## Current Process
Employees use a time clock several times 
The software exports attendance to excel 
Managment review the file manually
## Problems

- Duplicate records
- Missing exit and entry times
- Employees forget to clock out
- Repeated clicks
- Manual calculations take time

## Goal

Create an ETL pipeline that:

1. Reads attendance files automatically
2. Cleans invalid records
3. Calculates worked hours
4. Stores results in PostgreSQL
5. Generates reports

## Input

Excel file exported from attendance software.

## Output

Employee working hours per day.