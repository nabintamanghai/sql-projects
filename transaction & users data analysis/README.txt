Overview on this project:
This repository contains a SQL scripts used for cleaning and analyzing data from a 'users' table. The main goal of this project is to demonstrate my skills to clean and format raw data to ensure consistency, integrity, and accuracy before analysis. The dataset used in this projects was generated using python libraries like numpy, pandas, datetime, random, string, I have also provided the original dataset with the python script.


Key Features of this projects:
Data Staging: Creates a staging table (users_staging) to work on data without affecting the original dataset.

Data Cleaning Operations:
Removing Duplicates: Identifies and removes duplicate rows from the dataset.

Standardizing Values: Capitalizes inconsistent first and last names, standardizes email addresses, and formats gender and location columns.

Handling Nulls and Inconsistencies: Checks for and handles NULL or inconsistent values in various columns like first_name, last_name, email, location, and age.

Data Constraints: Adds constraints (e.g., NOT NULL, PRIMARY KEY) to ensure data validity.

Handling Outliers: Removes unreasonable or negative values in age, contact_info, and other columns.

Script Breakdown:
Table Setup: Creates a clean staging table based on the original data structure.
Data Inspection: Executes SELECT queries to inspect and identify issues in data.
Data Transformation: Uses SQL functions like UPDATE, CASE, and REPLACE to standardize and correct inconsistent data.
Final Checks: Ensures all columns meet predefined constraints and data integrity standards.
