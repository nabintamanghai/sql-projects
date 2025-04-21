/**
===============================================
BRONZE LAYER TABLE CREATION AND DATA INGESTION
===============================================

Following query creates a new table in the bronze schema and also check wether the same name table exists or not
if it exists then it drops it and lastly the scripts also load data into the bronze layer table before loading data
into the table the query first truncates the table. We can also create
store procudre to data ingestion to automate the task but since this project only contains one table so I am not 
doing that.

========
WARNING
========
Running follwing query will delete all the data within the table, so ensure you have backup before running following query.

**/

-- MAKING SURE WORKING IN THE RIGHT DATABASE
USE CustomerChurn;
GO

-- CHECK WEATHER TABLE EXISTS OR NOT IF YES THEN DROPS IT
IF OBJECT_ID('bronze.Customer_Data', 'U') IS NOT NULL
	DROP TABLE bronze.Customer_Data;
GO

-- 'Customer_Data' TABLE CREATION IN 'bronze' LAYER
CREATE TABLE bronze.Customer_Data (
		Customer_ID VARCHAR(50),
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
===================================
'bronze' LAYER DATA INGESTION
==================================
**/

TRUNCATE TABLE bronze.Customer_Data;

BULK INSERT bronze.Customer_Data
FROM 'C:\SQL2022\datasets\Data\Customer_Data.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
