# 📘 Data Catalog: Telecom Churn SQL ETL Project

This data catalog outlines the schema and description of the tables used in the ETL pipeline for telecom customer churn analysis.

---

## bronze.Customer\_Data
- **Purpose:** Stores customer details enriched with demographic, geographic, services & churn reason etc data.
- **Columns:**

| Column Name                    | Data Type | Description                                         |
| ------------------------------ | --------- | --------------------------------------------------- |
| Customer\_ID                   | VARCHAR(50)      | Unique identifier for each customer                 |
| Gender                         | VARCHAR(50)      | Customer's gender                                   |
| Age                            | TINYINT   | Customer's age in years                             |
| Married                        | VARCHAR(50)      | Marital status (Yes/No)                             |
| State                          | VARCHAR(50)      | Customer's state of residence                       |
| Number\_of\_Referrals          | INTEGER   | Number of referrals made by the customer            |
| Tenure\_in\_Months             | INTEGER   | Duration of customer relationship in months         |
| Value\_Deal                    | VARCHAR(50)      | Whether the customer has a value deal               |
| Phone\_Service                 | VARCHAR(50)      | Availability of phone service                       |
| Multiple\_Lines                | VARCHAR(50)      | Use of multiple lines                               |
| Internet\_Service              | VARCHAR(50)      | Internet service availability                       |
| Internet\_Type                 | VARCHAR(50)      | Type of internet (e.g., Fiber Optic, DSL)           |
| Online\_Security               | VARCHAR(50)      | Availability of online security                     |
| Online\_Backup                 | VARCHAR(50)      | Availability of online backup                       |
| Device\_Protection\_Plan       | VARCHAR(50)      | Use of device protection plan                       |
| Premium\_Support               | VARCHAR(50)      | Availability of premium support                     |
| Streaming\_TV                  | VARCHAR(50)      | Access to streaming TV                              |
| Streaming\_Movies              | VARCHAR(50)      | Access to streaming movies                          |
| Streaming\_Music               | VARCHAR(50)      | Access to streaming music                           |
| Unlimited\_Data                | VARCHAR(50)      | Unlimited data plan                                 |
| Contract                       | VARCHAR(50)      | Type of contract (e.g., Month-to-month, Two year)   |
| Paperless\_Billing             | VARCHAR(50)      | Whether billing is paperless                        |
| Payment\_Method                | VARCHAR(50)      | Method of payment                                   |
| Monthly\_Charge                | FLOAT     | Monthly charge in currency                          |
| Total\_Charges                 | FLOAT     | Total charges incurred                              |
| Total\_Refunds                 | FLOAT     | Total refunds issued                                |
| Total\_Extra\_Data\_Charges    | INTEGER     | Charges for extra data usage                        |
| Total\_Long\_Distance\_Charges | FLOAT     | Charges for long distance calls                     |
| Total\_Revenue                 | FLOAT     | Total revenue generated from customer               |
| Customer\_Status               | VARCHAR(50)      | Current status of customer (Joined, Churned, Stayed) |
| Churn\_Category                | VARCHAR(50)      | Broad category of churn reason                      |
| Churn\_Reason                  | VARCHAR(50)      | Specific reason for churn                           |

---

## silver.Customer\_Data

Structure is same as bronze.Customer\_Data, but with cleaned and standardized values for consistency.

---

## gold.customer\_churn
- **Purpose:** Stores customer details enriched with demographic, geographic, services & churn reason etc data.
- **Columns:**

| Column Name              | Data Type | Description                                |
| ------------------------ | --------- | ------------------------------------------ |
| customer\_id             | VARCHAR(50)      | Unique identifier for each customer        |
| gender                   | VARCHAR(50)      | Customer's gender                          |
| age                      | TINYINT     | Customer's age in years                    |
| marital\_status          | VARCHAR(50)      | Marital status (Yes/No)                          |
| district                 | VARCHAR(50)      | Customer's district (cleaned from 'state') |
| total\_revenue           | FLOAT     | Total revenue from the customer            |
| customer\_status         | VARCHAR(50)      | Current status of customer                 |
| churn\_category          | VARCHAR(50)      | Broad category of churn                    |
| churn\_reason            | VARCHAR(50)      | Specific reason for churn                  |
| deal\_value              | VARCHAR(50)      | Whether customer has a value deal          |
| phone\_service           | VARCHAR(50)      | Availability of phone service              |
| multiple\_lines          | VARCHAR(50)      | Whether customer uses multiple lines       |
| internet\_service        | VARCHAR(50)      | Availability of internet service           |
| internet\_type           | VARCHAR(50)      | Type of internet service                   |
| online\_security         | VARCHAR(50)      | Availability of online security            |
| online\_backup           | VARCHAR(50)      | Availability of online backup              |
| device\_protection\_plan | VARCHAR(50)      | Use of device protection plan              |
| premium\_support         | VARCHAR(50)      | Availability of premium support            |
| streaming\_tv            | VARCHAR(50)      | Access to streaming TV                     |
| streaming\_movies        | VARCHAR(50)      | Access to streaming movies                 |
| streaming\_music         | VARCHAR(50)      | Access to streaming music                  |
| unlimited\_data          | VARCHAR(50)      | Availability of unlimited data plan        |
| contract\_type           | VARCHAR(50)      | Type of customer contract                  |
| paperless\_billing       | VARCHAR(50)      | Whether billing is paperless               |
| payment\_method          | VARCHAR(50)      | Method of payment                          |
| tenure\_in\_months       | INTEGER   | Length of customer relationship in months  |
| referrals                | INTEGER   | Number of referrals made                   |
| monthly\_charge          | FLOAT     | Monthly billing amount                     |
| total\_charge            | FLOAT     | Total charges including services           |
| total\_refunds           | FLOAT     | Total amount refunded                      |
| extra\_data\_charge      | INTEGER     | Additional data usage charge               |
| long\_distance\_charge   | FLOAT     | Charges for long-distance usage            |

---

✅ **Note:** All columns in `silver.Customer_Data` are refined from `bronze.Customer_Data`. The `gold.customer_churn` table provides a final, ready-for-analysis dataset, ideal for reports or BI tools.
