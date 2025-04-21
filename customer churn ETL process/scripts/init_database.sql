/**

==============================
DATABASE AND SCHEMA CREATION
==============================

Following scripts creates database name 'CustomerChurn' and also checks if the same named database exists or not
if the same database exists then first it backups the database then sets the mode to single-user to kill any other
active connections and then it drops it and lastly the query also create 3 schemas name as 'bronze', 'silver', 'gold'.

========
WARNING
========
Running following query will drop the entire database if it exists and also drops all the tables and data within it.
Make sure you have permission to run this query and have context.

**/

-- MAKING SURE WE'RE IN THE MASTER DATABASE
USE MASTER;
GO

-- CHECKS IF THE SAME NAMED DATABASE EXISTS OR NOT IF YES THEN DROPS IT
IF EXISTS(SELECT 1 FROM sys.databases WHERE NAME = 'CustomerChurn')
	BEGIN
		-- backups the database
		BACKUP DATABASE CustomerChurn
		TO DISK = 'C:\SQL2022\backup\CustomerChurn_Backup.bak'
		WITH FORMAT, INIT, NAME = 'CustomerChurn-BACKUP';

		-- sets mode to single-user to kill active connections
		ALTER DATABASE CustomerChurn SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

		-- drops the database
		DROP DATABASE CustomerChurn;
	END;
GO

-- CustomerChurn DATABASE CREATION
CREATE DATABASE CustomerChurn;
GO

-- MAKING SURE WE'RE WORKING IN THE RIGHT DATABASE
USE CustomerChurn;
GO

-- SCHEMA CREATION
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
