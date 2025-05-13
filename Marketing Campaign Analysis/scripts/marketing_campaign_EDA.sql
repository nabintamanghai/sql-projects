/*
Description:
Followging project measures how well marketing campaigns did using SQL.
It uses data stored in a table called 'marketing_campaign' which includes fields such as 
campaign id, campaign name, channel, region, cost, impressions, clicks, conversions, revenue, start date & end date.

Goal:
The goal is to analyze key marketing metrics to understand which campaigns, channels, 
or regions performed best. The key metrics are:
- ROI (Return on Investment)
- CTR (Click-Through Rate)
- CPC (Cost Per Click)
- Conversion Rate
- CPM (Cost Per Thousand Impressions)
- CPA (Cost Per Acquisition)
- ROAS (Return on Ad Spend)

By analyzing these metrics overall, by campaign, by channel, by region, and over time (monthly), we can identify:
- Which campaigns are most cost effective
- Which marketing channels are driving the best results
- Seasonal trends in impressions and conversions
- Opportunities to improve targeting and efficiency etc.

How the Queries Work:
- First, data integrity is checked for duplicates.
- Summary metrics such as total spend, revenue, impressions, clicks, and conversions are calculated.
- KPIs like ROI, CTR, CPC, etc are calculated at different group levels: campaign, region, channel, and month.
*/

-- making sure we're working in the right database
USE MarketingCampaignAnalysis;
GO

---------------------------------------------------------------
-- checks duplicate campaign IDs
SELECT	campaign_id, 
		COUNT(campaign_id) AS row_count
FROM marketing_campaign
GROUP BY campaign_id
HAVING COUNT(campaign_id) > 1;
GO

---------------------------------------------------------------
-- BASIC KPIs or METRICS
---------------------------------------------------------------
-- total amount spent across all campaigns
SELECT FORMAT(SUM(cost), 'C') AS total_spend
FROM marketing_campaign;
GO

-- total revenue generated from all campaigns
SELECT FORMAT(SUM(revenue), 'C') AS total_revenue
FROM marketing_campaign;
GO

-- total number of ad clicks
SELECT SUM(clicks) AS total_clicks
FROM marketing_campaign;
GO

-- total number of conversions (sales)
SELECT SUM(conversions) AS total_conversion
FROM marketing_campaign;
GO

-- total ad impressions (total number of times ad is shown to users, whether the viewer clicked it or not)
SELECT SUM(impressions) AS total_impressions
FROM marketing_campaign;
GO

-- time range of this marketing campaign dataset
SELECT MIN(start_date) AS start_date, MAX(start_date) AS end_date
FROM marketing_campaign;
GO

---------------------------------------------------------------
-- CAMPAIGN PEFORMANCE
---------------------------------------------------------------
-- each campaign performance
SELECT	campaign_id
		campaign_name,
		channel,
		region,
		impressions,
		clicks,
		conversions,
		CAST((clicks * 100.0) / impressions AS DECIMAL(4,2)) AS CTR,
		ROUND(cost / clicks, 2) AS CPC,
		CAST((conversions * 100.0) / clicks AS DECIMAL(6,2)) AS Conversion_Rate,
		ROUND((revenue - cost) * 100.0 / cost, 2) AS ROI
FROM marketing_campaign;
GO

-- key metrics by region
SELECT 
  region,
  CAST(SUM(clicks) * 100.0 / SUM(impressions) AS DECIMAL(4,2)) AS CTR,
  ROUND(SUM(cost) / SUM(clicks), 2) AS CPC,
  CAST(SUM(conversions) * 100.0 / SUM(clicks) AS DECIMAL(4,2)) AS conversion_rate,
  ROUND((SUM(revenue) - SUM(cost)) * 100.0 / SUM(cost), 2) AS ROI
FROM marketing_campaign
GROUP BY region;
GO

-- key metrics by marketing channel
SELECT 
  channel,
  CAST(SUM(clicks) * 100.0 / SUM(impressions) AS DECIMAL(4,2)) AS CTR,
  ROUND(SUM(cost) / SUM(clicks), 2) AS CPC,
  CAST(SUM(conversions) * 100.0 / SUM(clicks) AS DECIMAL(4,2)) AS conversion_rate,
  ROUND((SUM(revenue) - SUM(cost)) * 100.0 / SUM(cost), 2) AS ROI
FROM marketing_campaign
GROUP BY channel;
GO

---------------------------------------------------------------
--1) IMPRESSIONS: when an ad is shown to users, it counts even if customer don’t click or notice it.
---------------------------------------------------------------
-- campaign with highest impressions
SELECT  campaign_name, 
		SUM(impressions) AS total_impressions
FROM marketing_campaign
GROUP BY campaign_name
ORDER BY 2 DESC;
GO
-- we can do same for 'region' & 'channel' by using GROUP BY

-- monthly impression trends
SELECT FORMAT(start_date, 'yyyy-MM') AS campaign_month,
       SUM(impressions) AS total_impressions
FROM marketing_campaign
GROUP BY FORMAT(start_date, 'yyyy-MM')
ORDER BY campaign_month;
GO

---------------------------------------------------------------
--2) CPM(Cost Per Thousand): price an advertiser pays for 1,000 ad views (even if no one clicks).
---------------------------------------------------------------
-- CPM by campaign
SELECT	campaign_name,
		SUM(cost) AS total_cost,
		SUM(impressions) AS total_impressions,
		ROUND(SUM(cost) / SUM(impressions) * 100, 2) AS CPM_percentage
FROM marketing_campaign
GROUP BY campaign_name
ORDER BY CPM_percentage DESC;
GO
-- we can do same for 'region' & 'channel'

-- monthly CPM trend
SELECT FORMAT(start_date, 'yyyy-MM') AS campaign_month,
	   SUM(cost) AS total_cost,
	   SUM(impressions) AS total_impression,
	   ROUND(SUM(cost) / SUM(impressions) * 100, 2) AS CPM_percentage
FROM marketing_campaign
GROUP BY FORMAT(start_date, 'yyyy-MM')
ORDER BY campaign_month;
GO

---------------------------------------------------------------
--3) CTR(Clickthrough Rate): percentage of people who clicked your ad out of those who saw it.
---------------------------------------------------------------
-- CTR by campaign
SELECT	campaign_name,
		SUM(clicks) AS total_clicks,
		SUM(impressions) AS total_impressions,
		CAST(SUM(clicks) * 100.0 / SUM(impressions) AS DECIMAL(4,2)) AS CTR_percentage
FROM marketing_campaign
GROUP BY campaign_name
ORDER BY CTR_percentage DESC;
GO
-- we can do same for 'region' & 'channel'

-- monthly CTR trend
SELECT	FORMAT(start_date, 'yyyy-MM') AS campaign_month,
		SUM(clicks) AS total_clicks,
		SUM(impressions) AS total_impression,
		CAST(SUM(clicks) * 100.0 / SUM(impressions) AS DECIMAL(4,2)) AS CTR_percentage
FROM marketing_campaign
GROUP BY FORMAT(start_date, 'yyyy-MM')
ORDER BY campaign_month;
GO

---------------------------------------------------------------
--4) Conversion Rate: percentages of people who completed a goal (like buying a product) after clicking the ad.
---------------------------------------------------------------
-- conversion rate by campaign
SELECT	campaign_name,
		SUM(clicks) AS total_clicks,
		SUM(conversions) AS total_conversions,
		CAST(SUM(conversions) * 100.0 / SUM(clicks) AS DECIMAL(4,2)) AS conversion_rate
FROM marketing_campaign
GROUP BY campaign_name
ORDER BY conversion_rate DESC;
GO
-- we can do same for 'region' & 'channel'

-- monthly conversion rate trend
SELECT FORMAT(start_date, 'yyyy-MM') AS campaign_month,
       SUM(clicks) AS total_clicks,
       SUM(conversions) AS total_conversions,
       CAST(SUM(conversions) * 100.0 / SUM(clicks) AS DECIMAL(4,2)) AS conversion_rate
FROM marketing_campaign
GROUP BY FORMAT(start_date, 'yyyy-MM')
ORDER BY campaign_month;
GO

---------------------------------------------------------------
--5) CPA (Cost per Acquisition): average amount spend to get one new customer.
---------------------------------------------------------------
-- CPA (Cost per Acquisition) by campaign
SELECT campaign_name,
       SUM(cost) AS total_cost,
       SUM(conversions) AS total_conversion,
       FORMAT(ROUND(SUM(cost) / SUM(conversions),2), 'C') AS CPA
FROM marketing_campaign
GROUP BY campaign_name
ORDER BY CPA DESC;
GO
-- we can do same for 'region' & 'channel'

-- monthly CPA trend
SELECT FORMAT(start_date, 'yyyy-MM') AS campaign_month,
       SUM(cost) AS total_cost,
       SUM(conversions) AS total_conversion,
       FORMAT(ROUND(SUM(cost) / SUM(conversions), 2), 'C') AS CPA
FROM marketing_campaign
GROUP BY FORMAT(start_date, 'yyyy-MM')
ORDER BY campaign_month;
GO

---------------------------------------------------------------
--6) ROAS (Return on Ad Spend): how much revenue earned for every dollar spent on ads.
---------------------------------------------------------------
-- ROAS (Return on Ad Spend) by campaign
WITH ROAS AS (
SELECT campaign_name,
       FORMAT(SUM(revenue), 'C') AS total_revenue,
       FORMAT(SUM(cost), 'C') AS total_cost,
       ROUND(SUM(revenue) / SUM(cost), 2) AS return_on_ad_spend
FROM marketing_campaign
GROUP BY campaign_name
)
SELECT	*,
		CASE
			WHEN return_on_ad_spend = (SELECT MAX(return_on_ad_spend) FROM ROAS) THEN 'Best performer'
			WHEN return_on_ad_spend = (SELECT MIN(return_on_ad_spend) FROM ROAS) THEN 'Lowest (but still profitable)'
			ELSE ''
    END AS performance_insight
FROM ROAS
ORDER BY return_on_ad_spend DESC;
-- we can do same for 'region' & 'channel'
        
-- monthly ROAS trend
SELECT FORMAT(start_date, 'yyyy-MM') AS campaign_month,
       SUM(revenue) AS total_revenue,
       SUM(cost) AS total_cost,
       ROUND(SUM(revenue) / SUM(cost), 2) AS ROAS
FROM marketing_campaign
GROUP BY FORMAT(start_date, 'yyyy-MM')
ORDER BY campaign_month;
GO

---------------------------------------------------------------
--7) ROI (Return on Investment): how much profit made compared to what spent.
---------------------------------------------------------------
-- ROI by campaign
SELECT campaign_name,
       SUM(revenue) AS total_revenue,
       SUM(cost) AS total_cost,
	   SUM(revenue - cost) AS profit,
       ROUND((SUM(revenue) - SUM(cost)) / SUM(cost) * 100.0, 2) AS ROI
FROM marketing_campaign
GROUP BY campaign_name
ORDER BY ROI DESC;
GO
-- we can do same for 'region' & 'channel'

-- monthly ROI trend
SELECT FORMAT(start_date, 'yyyy-MM') AS campaign_month,
       SUM(revenue) AS total_revenue,
       SUM(cost) AS total_cost,
       ROUND((SUM(revenue) - SUM(cost)) / SUM(cost) * 100.0, 2) AS ROI
FROM marketing_campaign
GROUP BY FORMAT(start_date, 'yyyy-MM')
ORDER BY campaign_month;
GO

---------------------------------------------------------------
--8) CPC (Cost Per Click): how much money paid for each click.
---------------------------------------------------------------
-- CPC by campaign
SELECT campaign_name,
       SUM(cost) AS total_cost,
       SUM(clicks) AS total_clicks,
       ROUND(SUM(cost) / SUM(clicks), 2) AS CPC
FROM marketing_campaign
GROUP BY campaign_name
ORDER BY CPC DESC;
GO
-- we can do same for 'region' & 'channel'

-- monthly CPC trend
SELECT FORMAT(start_date, 'yyyy-MM') AS campaign_month,
       SUM(cost) AS total_cost,
       SUM(clicks) AS total_clicks,
       ROUND(SUM(cost) / SUM(clicks), 2) AS CPC
FROM marketing_campaign
GROUP BY FORMAT(start_date, 'yyyy-MM')
ORDER BY campaign_month;
GO

---------------------------------------------------------------
--9) Month-over-Month Growth Rates
---------------------------------------------------------------
-- monthly CTR Trends with Growth Rate
WITH MonthlyCTR AS (
  SELECT
    FORMAT(start_date, 'yyyy-MM') AS campaign_month,
    CAST(SUM(clicks) * 100.0 / NULLIF(SUM(impressions), 0) AS DECIMAL(5,2)) AS ctr
  FROM marketing_campaign
  GROUP BY FORMAT(start_date, 'yyyy-MM')
)
SELECT
  campaign_month,
  ctr,
  LAG(ctr) OVER (ORDER BY campaign_month) AS prev_month_ctr,
  COALESCE(ROUND((ctr - LAG(ctr) OVER (ORDER BY campaign_month)) 
    / LAG(ctr) OVER (ORDER BY campaign_month) * 100, 2), 0) AS ctr_growth_percentage
FROM MonthlyCTR
ORDER BY campaign_month;
-- we can do same for other metrics
