# 📢 Marketing Campaign Analysis

> A SQL project to evaluate and optimize marketing campaign performance using metrics like ROI, CTR, CPA, and more.

---

## 🎯 Objective

To analyze and evaluate the performance of multiple marketing campaigns across different channels, campaigns and regions using SQL. The project helps identify the most cost-effective campaigns, optimize ad spend, and uncover patterns in user engagement and conversions.

---

## 🧱 Dataset Overview

The dataset contains information about several marketing campaigns with key metrics such as impressions, clicks, conversions, cost, and revenue.

| Column Name     | Description                                 |
|-----------------|---------------------------------------------|
| campaign_id     | Unique campaign identifier                  |
| campaign_name   | Name/title of the campaign                  |
| channel         | Marketing channel used (Twitter, Instagram, etc.) |
| region          | Geographical region of the campaign         |
| impressions     | Number of times the ad was shown            |
| clicks          | Number of user clicks                       |
| conversions     | Number of successful conversions            |
| cost            | Total spend on the campaign                 |
| revenue         | Total revenue generated from the campaign   |
| start_date      | Campaign start date                         |
| end_date        | Campaign end date                           |

---

## 📈 Key Metrics Calculated (Using SQL)

| Metric        | Formula |
|---------------|---------|
| **Click-Through Rate (CTR)** | `(clicks / impressions) * 100` |
| **Cost Per Click (CPC)** | `cost / clicks` |
| **Cost Per Mille (CPM)** | `(cost / impressions) * 1000` |
| **Cost Per Acquisition (CPA)** | `cost / conversions` |
| **Conversion Rate** | `(conversions / clicks) * 100` |
| **Return on Investment (ROI)** | `((revenue - cost) / cost) * 100` |
| **Return on Ad Spend (ROAS)** | `revenue / cost` |

use `NULLIF()` in SQL if there's a null value in the column .

---

## 📱 Analysis Performed

### ✅ 1. Overall Performance
- Total impressions, clicks, conversions, revenue, and cost.
- Campaign wide CTR, CPA, ROI, etc.

### ✅ 2. Campaign wise Analysis
- Compared campaign KPIs side by side.

### ✅ 3. Region wise Analysis
- Evaluated which regions generate better returns.

### ✅ 4. Channel wise Insights
- Determined which marketing channel (Instagram, Twitter, etc.) performs better in terms of ROI and CTR.

### ✅ 5. Monthly Trends
- Tracked revenue, cost, and CTR over time.
- Calculated MoM growth using SQL `LAG()` window function.

---

## 💡 Key Insights

- Twitter delivered the highest ROI (199.25%), indicating it’s the most efficient channel for return on investment. <br>
- Instagram and Facebook also performed well, with ROIs of 197.37% and 190.97%, respectively. <br>
- Europe had lower conversion rates & may need optimization. However, it delivered the highest ROI 201.23%, meaning it generated more than double the revenue relative to its cost. <br>
- Facebook shows the best Conversion Rate 10% while maintaining competitive ROI. <br>
- On average, every $1 spent returned $2.93, meaning we nearly tripled our investment with a 193.08% ROI across all campaigns. <br>
- Fluctuating CTR (1.07% to 1.03% year-over-year) with no sustained growth suggests volatile, not consistently improving, user engagement. Investigate external factors like campaign changes, 
     seasonality and focus on strategies to stabilize and improve CTR consistently. <br>
- LinkedIn has the highest Click-Through Rate (CTR) of 3.17%. <br>

---

## 📝 Recommendations
- Put more money into Twitter ads <br>
  Twitter gave us the best return for every dollar spent. Spending more here will likely make us more profit.

- Keep using Instagram and Facebook ads and make them better <br>
  These platforms also gave good results, especially Facebook which helped more people buy. We can try making ads more attractive to get even better results.

- Improve ads in Europe <br>
  Europe made good money, but fewer people bought. We should make ads that better fit European customers to get more sales.

- Fix the inconsistent click rates <br>
  People’s clicking on ads is going up and down, which is not good. We should test different ads and see what works best so more people click regularly.

- Use LinkedIn to catch interested people <br>
  LinkedIn gets the most clicks, so we should use it to share useful info and bring more people closer to buying.

- Keep checking how ads are doing <br>
  We should always watch how each platform and place is doing, so we can spend money where it works best.

---

## 🔧 Technical Details

- **SQL Server** was used for analysis.
- SQL Features: `CTEs`, `Window Functions`, `NULLIF`, `GROUP BY`, `CASE WHEN`, `LAG()` etc.

---

## 📁 Repository Structure
```
Marketing Campaign Analysis/

├── dataset/
|          ├── marketing_campaign_data.csv
├── docs/
|        ├──
├── scripts/
|           ├── init_database.sql
|           ├── marketing_campaign_EDA.sql
├── README.md
```
