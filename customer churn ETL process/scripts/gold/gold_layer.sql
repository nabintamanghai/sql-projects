/**
============================
'gold' LAYER VIEW CREATIONS
============================

Following scripts creates a 'VIEW' inside 'gold' scheme & it also checks whether a same view exists or not, if the same view
already exists, then it drops it.

Purpose: Combines cleaned, analysis ready data from silver schema with user-friendly column names.

Usage: Can be use for analysis or visualization.
**/

-- MAKING SURE WE'RE CREATING VIEW IN THE RIGHT DATABASE
USE CustomerChurn;
GO

-- CHECKS IF THERE'S SAME VIEW EXISTS OR NOT IF TRUE THEN IT DROPS IT
IF OBJECT_ID('gold.customer_churn', 'V') IS NOT NULL
	DROP VIEW gold.customer_churn;
GO

-- CREATES VIEW INSIDE 'gold' SCHEMA
CREATE VIEW gold.customer_churn AS
	SELECT
		   Customer_ID AS customer_id,
		   Gender AS gender,
		   Age AS age,
		   Married AS marital_status,
		   State AS	district,
		   Total_Revenue AS total_revenue,
		   Customer_Status AS customer_status,
		   Churn_Category AS churn_category,
		   Churn_Reason AS churn_reason,
		   Value_Deal AS deal_value,
		   Phone_Service AS phone_service,
		   Multiple_Lines AS multiple_lines,
		   Internet_Service AS internet_service,
		   Internet_Type AS internet_type,
		   Online_Security AS online_security,
		   Online_Backup AS online_backup,
		   Device_Protection_Plan AS device_protection_plan,
		   Premium_Support AS premium_support,
		   Streaming_TV AS streaming_tv,
		   Streaming_Movies AS streaming_movies,
		   Streaming_Music AS streaming_music,
		   Unlimited_Data AS unlimited_data,
		   Contract AS contract_type,
		   Paperless_Billing AS paperless_billing,
		   Payment_Method AS payment_method,
		   Tenure_in_Months AS tenure_in_months,
		   Number_of_Referrals AS referrals,
		   Monthly_Charge AS monthly_charge,
		   Total_Charges AS total_charge,
		   Total_Refunds AS total_refunds,
		   Total_Extra_Data_Charges AS extra_data_charge,
		   Total_Long_Distance_Charges AS long_distance_charge
	FROM silver.Customer_Data;
GO
