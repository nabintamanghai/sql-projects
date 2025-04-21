/**
===============================================
'silver' LAYER TABLE CREATION & DATA INGESTION
===============================================

Following query creates a table in the silver schema & also checks whether the same table exists or not
if it exists then it drops it.

The script also loads data into the silver layer table, before loading data
into the table the query first truncates the table. 
The script also does ETL (Extract, Transform, Load) process to populate the 'silver' schema tables 
from 'bronze' layer.

Actions Performed:
Extract: Retrieves raw data from the Bronze tables.
Transform: Cleanses, deduplicates, and structures the data for analytical use.
Load: Truncates existing 'silver' tables and inserts the transformed data.
This ensures that the 'silver' schema contains high-quality, structured data for further processing and analysis.

We can also create store procedure to automate the data ingestion task but since this project only 
contains one table so I am not doing that.

========
WARNING
========
Running follwing query will delete all the data within the table, so ensure you have backup before running following query.

**/

-- MAKING SURE WE'RE WORKING IN THE RIGHT DATABASE
USE CustomerChurn;
GO

-- CHECKS TABLE ALREADY EXISTS OR NOT IT YES THEN DROPS IT
IF OBJECT_ID ('silver.Customer_Data', 'U') IS NOT NULL
	DROP TABLE silver.Customer_Data;
GO

-- 'silver.Customer_Data' TABLE CREATION
CREATE TABLE silver.Customer_Data (
		Customer_ID VARCHAR(50) PRIMARY KEY,
		Gender VARCHAR(50),
		Age TINYINT,
		Married VARCHAR(50),
		State VARCHAR(50),
		Number_of_Referrals INT,
		Tenure_in_Months INT,
		Value_Deal VARCHAR(50),
		Phone_Service VARCHAR(50),
		Multiple_Lines VARCHAR(50),
		Internet_Service VARCHAR(50),
		Internet_Type VARCHAR(50),
		Online_Security VARCHAR(50),
		Online_Backup VARCHAR(50),
		Device_Protection_Plan VARCHAR(50),
		Premium_Support VARCHAR(50),
		Streaming_TV VARCHAR(50),
		Streaming_Movies VARCHAR(50),
		Streaming_Music VARCHAR(50),
		Unlimited_Data VARCHAR(50),
		Contract VARCHAR(50),
		Paperless_Billing VARCHAR(50),
		Payment_Method VARCHAR(50),
		Monthly_Charge FLOAT,
		Total_Charges FLOAT,
		Total_Refunds FLOAT,
		Total_Extra_Data_Charges INT,
		Total_Long_Distance_Charges FLOAT,
		Total_Revenue FLOAT,
		Customer_Status VARCHAR(50),
		Churn_Category VARCHAR(50),
		Churn_Reason VARCHAR(50)
);
GO

/**
==============================
'silver' LAYER DATA INGESTION
==============================
**/

-- DELETES ALL THE DATA FROM THE TABLE
TRUNCATE TABLE silver.Customer_Data;
GO

-- INSERTS DATA FROM 'bronze' LAYER INTO 'silver' LAYER
INSERT INTO silver.Customer_Data	
								   (Customer_ID,
									Gender,
									Age,
									Married,
									State,
									Number_of_Referrals,
									Tenure_in_Months,
									Value_Deal,
									Phone_Service,
									Multiple_Lines,
									Internet_Service,
									Internet_Type,
									Online_Security,
									Online_Backup,
									Device_Protection_Plan,
									Premium_Support,
									Streaming_TV,
									Streaming_Movies,
									Streaming_Music,
									Unlimited_Data,
									Contract,
									Paperless_Billing,
									Payment_Method,
									Monthly_Charge,
									Total_Charges,
									Total_Refunds,
									Total_Extra_Data_Charges,
									Total_Long_Distance_Charges,
									Total_Revenue,
									Customer_Status,
									Churn_Category,
									Churn_Reason)
SELECT
	Customer_Id,
	Gender,
	Age,
	Married,
	State,
	Number_of_Referrals,
	Tenure_in_Months,
	ISNULL(Value_Deal, 'None') AS Value_Deal,
	Phone_Service,
	ISNULL(Multiple_Lines, 'No') AS Multiple_Lines,
	Internet_Service,
	ISNULL(Internet_Type, 'None') AS Internet_Type,
	ISNULL(Online_Security, 'No') AS Online_Security,
	ISNULL(Online_Backup, 'No') AS Online_Backup,
	ISNULL(Device_Protection_Plan, 'No') AS Device_Protection_Plan,
	ISNULL(Premium_Support, 'No') AS Premium_Support,
	ISNULL(Streaming_TV, 'No') AS Streaming_TV,
	ISNULL(Streaming_Movies, 'No') AS Streaming_Movies,
	ISNULL(Streaming_Music, 'No') AS Streaming_Music,
	ISNULL(Unlimited_Data, 'No') AS Unlimited_Data,
	Contract,	
	Paperless_Billing,
	Payment_Method,
	Monthly_charge,
	Total_Charges,
	Total_Refunds,
	Total_Extra_Data_Charges,
	Total_Long_Distance_Charges,
	Total_Revenue,
	Customer_Status,
	ISNULL(Churn_Category, 'No Reason') AS Churn_Category,
	ISNULL(Churn_Reason, 'No Reason') AS Churn_Reason
FROM bronze.Customer_Data;
GO





-- COUNT NUMBER OF NULL VALUE IN A COLUMN TO REPLACE NULL VALUES WITH DEFAULT VALUE (e.g: 'No', 'None')
SELECT
	SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END) AS Customer_ID,
	SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS Gender,
	SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS Age,
	SUM(CASE WHEN Married IS NULL THEN  1 ELSE 0 END) AS Married,
	SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS State,
	SUM(CASE WHEN Number_of_Referrals IS NULL THEN 1 ELSE 0 END) AS Number_Of_Referrals,
	SUM(CASE WHEN Tenure_in_Months IS NULL THEN 1 ELSE 0 END) AS Tenure_in_Months,
	SUM(CASE WHEN Value_Deal IS NULL THEN 1 ELSE 0 END) AS Value_Deal,
	SUM(CASE WHEN Phone_Service IS NULL THEN 1 ELSE 0 END) AS Phone_Service,
	SUM(CASE WHEN Multiple_Lines IS NULL THEN 1 ELSE 0 END) AS Multiple_Lines,
	SUM(CASE WHEN Internet_Service IS NULL THEN 1 ELSE 0 END) AS Internet_Service,
	SUM(CASE WHEN Internet_Type IS NULL THEN 1 ELSE 0 END) AS Internet_Type,
	SUM(CASE WHEN Online_Security IS NULL THEN 1 ELSE 0 END) AS Online_Security,
	SUM(CASE WHEN Online_Backup IS NULL THEN 1 ELSE 0 END) AS Online_Backup,
	SUM(CASE WHEN Device_Protection_Plan IS NULL THEN 1 ELSE 0 END) AS Device_protection_Plan,
	SUM(CASE WHEN Premium_Support IS NULL THEN 1 ELSE 0 END) AS Premium_Support,
	SUM(CASE WHEN Streaming_TV IS NULL THEN 1 ELSE 0 END) AS Streaming_TV,
	SUM(CASE WHEN Streaming_Movies IS NULL THEN 1 ELSE 0 END) AS Streaming_Movies,
	SUM(CASE WHEN Streaming_Music IS NULL THEN 1 ELSE 0 END) AS Streaming_Music,
	SUM(CASE WHEN Unlimited_Data IS NULL THEN 1 ELSE 0 END) AS Unlimited_Data,
	SUM(CASE WHEN Contract IS NULL THEN 1 ELSE 0 END) AS Contract,
	SUM(CASE WHEN Paperless_Billing IS NULL THEN 1 ELSE 0 END) AS Paperless_Billing,
	SUM(CASE WHEN Payment_Method IS NULL THEN 1 ELSE 0 END) AS Payment_Method,
	SUM(CASE WHEN Monthly_Charge IS NULL THEN 1 ELSE 0 END) AS Monthly_Charge,
	SUM(CASE WHEN Total_Charges IS NULL THEN 1 ELSE 0 END) AS Total_Charges,
	SUM(CASE WHEN Total_Refunds IS NULL THEN 1 ELSE 0 END) AS Total_Refunds,
	SUM(CASE WHEN Total_Extra_Data_Charges IS NULL THEN 1 ELSE 0 END) AS Total_Extra_Data_Charges,
	SUM(CASE WHEN Total_Long_Distance_Charges IS NULL THEN 1 ELSE 0 END) AS Total_Long_Distance_Charges,
	SUM(CASE WHEN Total_Revenue IS NULL THEN 1 ELSE 0 END) AS Total_Revenue,
	SUM(CASE WHEN Customer_Status IS NULL THEN 1 ELSE 0 END) AS Customer_Status,
	SUM(CASE WHEN Churn_Category IS NULL THEN 1 ELSE 0 END) AS Churn_Category,
	SUM(CASE WHEN Churn_Reason IS NULL THEN 1 ELSE 0 END) AS Churn_Reason
FROM bronze.Customer_Data;
GO
