# Telecom Customer Churn Analysis - SQL ETL Pipeline

## 👀 Project Overview
This project demonstrates a SQL-based ETL pipeline for analyzing telecom customer churn. It includes: 

- **Database & Schemas Creation `CustomerChurn`**:  
    - **Bronze**: Stores raw CSV data.  
    - **Silver**: Cleans and standardizes the data.  
    - **Gold**: Produces a final dataset optimized for analytics.  

- **Data Cleaning**:  
  - Checks for errors and missing values.  
  - Enforces consistent data types.  
  - Validates data quality.  

- **Analytics Output**:  
  - Analysis ready dataset (`gold.customer_churn`).  
  - Ready for use in business intelligence tools like **Power BI**.  

**Project Target:**
- Create an ETL process in a database & a Power BI dashboard.

**SQL objectives:**
- Automate database and schema creation
- Create a three layer data pipeline (bronze, silver, gold)
- Load raw churn data into a 'bronze' layer
- Analyze data quality in 'silver' layer
- Create a view in 'gold' layer for reporting, analysis, & visualization.

## 🛢️ DBMS:
- Microsoft SQL Server
- SQL Server Management System


## 📁 Project Structure
```
└── CustomerChurn/            # database
    ├── init_database.sql     # create database and schemas
    ├── bronze_layer.sql      # 'bronze' schema: table creation & raw data ingestion
    ├── silver_layer.sql      # 'silver' schema: table creation (ETL, EDA) 
    └── gold_layer.sql        # 'gold' schema: view creation for analytics
```

## 🛢 SQL Scripts
Below I have described what each scripts does. Run them step-by-step or automate them in a CI/CD pipeline.

---
## 🔄 ETL Process
This project follows a three‑layer ETL (Extract, Transform, Load) pipeline:

- **Bronze Layer (Extract & Load):**
  - Raw data is extracted from the CSV file and loaded directly into the `bronze.Customer_Data` table using `BULK INSERT`.
- **Silver Layer (Transform & Load):**
  - Data from `bronze.Customer_Data` is transformed (NULL handling with `ISNULL`, data type enforcement) and loaded into `silver.Customer_Data`.
- **Gold Layer (Load):**
  - Analysis ready view `gold.customer_churn` is created for reporting and visualization.

## 🔍 Insights & Observations
- **Null Handling:** Used `ISNULL` to replace missing categorical values with defaults (`'No'`, `'None'`).
- **Performance:** Organizing data into separate schemas (raw → clean → analytics) for better performance and maintenance.
- **Reusability:** Scripts can be automated via stored procedures.

---

### 1. Database & Schema Creation (`init_database.sql`)
- Switch to `master` database
- Drop existing `CustomerChurn` database if it exists (with backup and single-user mode)
- Create new `CustomerChurn` database
- Create three schemas: `bronze`, `silver`, `gold`

```sql
USE MASTER;
GO
IF EXISTS(SELECT 1 FROM sys.databases WHERE NAME = 'CustomerChurn')
BEGIN
    BACKUP DATABASE CustomerChurn
      TO DISK = 'C:\SQL2022\backup\CustomerChurn_Backup.bak'
      WITH FORMAT, INIT, NAME = 'CustomerChurn-BACKUP';

    ALTER DATABASE CustomerChurn SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CustomerChurn;
END;
GO
CREATE DATABASE CustomerChurn;
GO
USE CustomerChurn;
GO
CREATE SCHEMA bronze; GO
CREATE SCHEMA silver; GO
CREATE SCHEMA gold; GO
```

---

### 2. Bronze Layer: Raw Data Ingestion (`bronze_layer.sql`)
- Drop `bronze.Customer_Data` table if it exists
- Create `bronze.Customer_Data` with original raw columns
- Truncate table and bulk load from CSV file

```sql
USE CustomerChurn; GO
IF OBJECT_ID('bronze.Customer_Data', 'U') IS NOT NULL
    DROP TABLE bronze.Customer_Data;
GO
CREATE TABLE bronze.Customer_Data ( ... );
GO
TRUNCATE TABLE bronze.Customer_Data;
BULK INSERT bronze.Customer_Data
    FROM 'C:\SQL2022\datasets\Data\Customer_Data.csv'
    WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
```

---

### 3. Silver Layer: Data Cleaning & EDA (`silver_layer.sql`)
- Drop and recreate `silver.Customer_Data` with primary key and constraints
- Truncate and populate from Bronze, applying `ISNULL` defaults for missing values

```sql
USE CustomerChurn; GO
IF OBJECT_ID('silver.Customer_Data', 'U') IS NOT NULL
    DROP TABLE silver.Customer_Data;
GO
CREATE TABLE silver.Customer_Data ( ... PRIMARY KEY (Customer_ID) );
GO
TRUNCATE TABLE silver.Customer_Data;
INSERT INTO silver.Customer_Data
SELECT
    Customer_ID, Gender, Age, ...,
    ISNULL(Value_Deal, 'None') AS Value_Deal,
    ...
FROM bronze.Customer_Data;
GO
-- checking for column that has null values to replace with defaults
SELECT SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END) AS Customer_ID
FROM bronze.Customer_Data;
GO
```

---

### 4. Gold Layer: Analysis Ready Data (`gold_layer.sql`)
- Drop existing `gold.customer_churn` view if it exists
- Create a view with user-friendly column names for reporting

```sql
USE CustomerChurn; GO
IF OBJECT_ID('gold.customer_churn', 'V') IS NOT NULL
    DROP VIEW gold.customer_churn;
GO
CREATE VIEW gold.customer_churn AS
SELECT
    Customer_ID AS customer_id,
    Gender AS gender,
    Age AS age,
    Married AS marital_status,
    State AS district,
    Total_Revenue AS total_revenue,
    Customer_Status AS customer_status,
    Churn_Category AS churn_category,
    Churn_Reason AS churn_reason,
    ...
FROM silver.Customer_Data;
GO
```
---
## ⏩ Next Steps
- Connect SQL server from Power BI to build reports/dashboard using `gold.customer_churn` view

## 🤝 Contributions
Contributions or any suggestion are welcome! 
