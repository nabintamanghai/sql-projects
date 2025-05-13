/*
DESCRIPTION:
Following SQL script sets up a database and imports marketing campaign data from a CSV file.
It includes:
- Creating a new database (MarketingCampaignAnalysis)
- Creating a structured table for campaign data
- Also checks whether there's already same table exists or not
- Importing cleaned data from a local CSV file for analysis
*/

-- CREATES A NEW DATABASE CALLED 'MarketingCampaignAnalysis'
CREATE DATABASE MarketingCampaignAnalysis;
GO

-- SWITCH TO THE 'MarketingCampaignAnalysis' DATABASE
USE MarketingCampaignAnalysis;
GO

-- CHECKS IF THERE'S ALREADY SAME TABLE OR NOT IF YES THEN DROPS IT
IF OBJECT_ID('marketing_campaign', 'U') IS NOT NULL
    DROP TABLE marketing_campaign;
GO
-- CREATES A TABLE NAMED 'marketing_campaign' WITH RELEVANT COLUMNS & DATATYPES
CREATE TABLE marketing_campaign (
    campaign_id     INT PRIMARY KEY,        -- Unique campaign ID
    campaign_name   VARCHAR(30),            -- Name of the campaign
    channel         VARCHAR(30),            -- Marketing channel (e.g Linked, Instagram, Twitter etc)
    region          VARCHAR(30),            -- Target region (e.g Asia, Australia, South America etc)
    impressions     INT,                    -- Number of impressions (ads shown)
    clicks          INT,                    -- Number of clicks (users interacted)
    conversions     INT,                    -- Number of successful actions taken by users (like signing up or buying)
    cost            FLOAT,                  -- Amount spent on the campaign
    revenue         FLOAT,                  -- Revenue generated from the campaign
    start_date      DATE,                   -- Campaign start date
    end_date        DATE                    -- Campaign end date
);
GO

-- DELETES ALL THE DATA IN THE TABLE BEFORE INSERTING NEW DATA
-- Useful for resetting the table before fresh data is inserted
TRUNCATE TABLE marketing_campaign;
GO

-- INSERTS DATA INTO THE TABLE FROM A LOCAL CSV FILE USING 'BULK INSERT'
-- ADJUST THE FILE PATH ACCORDING TO YOUR FILE LOCATION
BULK INSERT marketing_campaign
FROM 'C:\\Power BI Projects\\Marketing Campaign Analysis\\dataset\\marketing_campaign_data.csv'
WITH (
    FIRSTROW = 2,           -- Skip the header row in CSV
    FIELDTERMINATOR = ',',  -- Values are comma seperated
    TABLOCK                 -- Improves performance for large inserts
);
GO
