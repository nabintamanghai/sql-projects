# **World Layoffs Analysis**

## **About The Project**
This project focuses on cleaning raw, messy data, performing data normalization & standardization, removing duplicates, filtering data, handling missing values, addressing unwanted spaces, and correcting datatype casting using SQL. 

The dataset used in this project contains inconsistencies, null values, incorrect formatting, and other data quality issues. The goal is to transform the data into a structured and usable format for further analysis.

## **Tools Used**
- **MySQL**

## **Dataset**
The dataset used in this project includes records of **2,361 layoffs** from various companies worldwide. It covers layoffs across different companies, countries, and industries during the **COVID-19 pandemic**.

## **World Layoffs Analysis**
In today's dynamic economic environment, layoffs have become a significant aspect of corporate decision-making. Organizations across industries often downsize their workforce due to financial constraints, technological advancements, mergers, or economic downturns. This project focuses on analyzing a dataset containing global layoff records to uncover key trends and insights.

## **Project Objectives**
The primary goal of this project is to perform **data cleaning** and **exploratory data analysis (EDA)** on global layoff data. The analysis aims to:

- Examine layoff trends across various industries and regions.
- Identify companies with the highest workforce reductions.
- Assess the economic and business factors influencing layoffs worldwide.
- Determine the state of companies that laid off **100%** of their employees.

By conducting this analysis, we aim to provide valuable insights into global layoff patterns and their broader impact on the workforce.

| **Field**                | **Type** | **Description**                                                                 |
|--------------------------|----------|---------------------------------------------------------------------------------|
| **company**              | text     | Name of the company that had layoffs.                                 |
| **location**             | text     | The city or specific location of company.               |
| **industry**             | text     | The sector or industry to which the company belongs.                            |
| **total_laid_off**       | int      | The total number of employees being laid off by the company.                    |
| **percentage_laid_off**  | tinyint    | The percentage of the company’s workforce that was laid off.                   |
| **date**                 | date    | The date when the layoffs occurred.                                             |
| **stage**                | text     | The stage of the company when they had layoffs.               |
| **country**              | text     | The country location of a company.                                    |
| **funds_raised_millions**| int      | The total amount of funds the company has raised (in millions of dollars).     |


# Global Layoffs Analysis

## Data Cleaning

| **Step**                   | **Details**                                                                                                      |
|----------------------------|------------------------------------------------------------------------------------------------------------------|
| **Removing Duplicates**    | - Created a staging table (`layoffs_staging`) to preserve raw data.<br>- Identified and removed duplicates using SQL window functions. |
| **Standardizing Fields**   | - Trimmed whitespace in `company`.<br>- Standardized inconsistent spellings/cases in `industry`.<br>- Corrected country names (e.g., removed trailing periods).<br>- Converted `date` from text to date format. |
| **Handling Missing Values**| - Removed rows with nulls in both `total_laid_off` and `percentage_laid_off`.<br>- Converted blank `industry` entries to nulls and filled them using company records where possible. |
| **Eliminating Columns**    | - Dropped temporary columns (e.g., `row_num`).<br>- Removed records missing critical data to maintain integrity. |

---

## Exploratory Data Analysis (EDA)

### Key Insights

| **Key Insight**                               | **Description**                                                                                                  |
|-----------------------------------------------|------------------------------------------------------------------------------------------------------------------|
| **Dataset Scope**                             | 1,628 companies across 30 industries, with Finance having the most companies. 91 companies categorized as "Other". |
| **Time Frame**                                | Covers layoffs from March 11, 2020, to March 6, 2023, including COVID-19 impacts.                                |
| **Top Sectors**                               | Consumer sector had the largest layoffs, followed by Retail.                                                     |
| **Major Contributors**                       | Amazon, Google, and Meta accounted for the highest layoffs.                                                      |
| **Company Stage**                            | Post-IPO companies saw the highest total layoffs.                                                                |
| **Layoff Trends**                             | Most layoffs occurred in 2022 and 2023.                                                                          |
| **Geographic Impact**                         | United States led in layoffs, followed by India, Netherlands, and Sweden.                                        |
| **Largest Single-Day Layoffs**               | Google (12,000), Meta (11,000), Amazon (10,000), Microsoft (10,000), Ericsson (8,500).                           |

### Conclusion  
The analysis of global layoffs from 2020 to 2023 shows that the **Consumer** and **Tech sectors** were hit hardest by the pandemic.  
- **Consumer Sector**: Struggled with shifts to online shopping and supply chain disruptions.  
- **Tech Sector**: Post-IPO companies faced layoffs due to pressures to prioritize profitability.  
- **Drivers**: Economic instability, market shifts, and operational restructuring drove workforce reductions.  

These insights can guide **businesses** and **policymakers** to implement strategies that support affected industries and mitigate future job losses.  
