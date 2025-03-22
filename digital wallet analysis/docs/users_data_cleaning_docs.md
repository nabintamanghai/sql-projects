## Overview
 This document contains all the scripts written to clean the users data for visualization and analysis. It outlines each step in the data cleaning process, from selecting the appropriate database to validating financial columns, ensuring that every script is well-documented and its purpose clearly described.
  </p>
  <p>
    The scripts are designed to transform raw, messy data into a reliable and standardized dataset, which is crucial for generating accurate insights during Exploratory Data Analysis (EDA) and dashboard creation. Whether you are a developer, data analyst, or stakeholder, this documentation provides a transparent view into the data preparation process, ensuring consistency and integrity of the users data.
  </p>
  <p>
    In the following sections, you will find detailed explanations of each step, including the creation of a staging table, data integrity checks, standardization procedures, and cleaning operations for various columns such as names, email, gender, location, age, contact info, and financial fields.
  </p>
  
  <hr>
 <h1>Data Cleaning Process</h1>
  
  <h2>1. Selecting the Right Database</h2>
  <pre><code>USE portfolio_projects;</code></pre>
  <p>
    Sets the active database to <code>portfolio_projects</code>, ensuring all queries run within this database.
  </p>
  
  <h2>2. Creating a Staging Table</h2>
  <pre><code>CREATE TABLE IF NOT EXISTS users_staging LIKE users;</code></pre>
  <p>
    Creates a duplicate of the <code>users</code> table named <code>users_staging</code> to allow safe data cleaning without modifying the original data.
  </p>
  
  <h2>3. Checking Table Structure</h2>
  <pre><code>DESC users;
DESC users_staging;</code></pre>
  <p>
    Displays the structure of both tables to ensure they match.
  </p>
  
  <h2>4. Copying Data to Staging Table</h2>
  <pre><code>INSERT INTO users_staging
SELECT * FROM users;</code></pre>
  <p>
    Copies all data from <code>users</code> into <code>users_staging</code> for further cleaning and analysis.
  </p>
  
  <h2>5. Checking Data Integrity</h2>
  <pre><code>SELECT * FROM users AS t1
LEFT JOIN users_staging AS t2
ON t1.user_id = t2.user_id
WHERE t2.user_id IS NULL;</code></pre>
  <p>
    Checks that no data is missing in the staging table by identifying any records in <code>users</code> that are not present in <code>users_staging</code>.
  </p>
  
  <h2>6. Data Cleaning</h2>
  <h3>Adding Constraints to <code>user_id</code></h3>
  <pre><code>ALTER TABLE users_staging
MODIFY COLUMN user_id INT NOT NULL,
ADD PRIMARY KEY(user_id);</code></pre>
  <p>
    Ensures <code>user_id</code> is a unique identifier by making it a primary key and preventing <code>NULL</code> values.
  </p>
  
  <h3>Standardizing <code>total_balance</code> Column</h3>
  <pre><code>ALTER TABLE users_staging
MODIFY COLUMN total_balance DECIMAL(8,2);</code></pre>
  <p>
    Ensures financial accuracy by setting <code>total_balance</code> to <code>DECIMAL(8,2)</code>, preventing unrealistic values.
  </p>
  
  <h3>Identifying Duplicate Records</h3>
  <pre><code>WITH duplicate_rows AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY user_id, first_name, last_name, email, gender, age,
contact_info, location, total_balance, transaction_count, total_spent, account_age ORDER BY user_id) AS row_count
FROM users_staging)
SELECT * FROM duplicate_rows WHERE row_count > 1;</code></pre>
  <p>
    Identifies duplicate records based on all columns using Common Table Expressions (CTEs).
  </p>
  
  <h2>7. Cleaning <code>first_name</code> and <code>last_name</code> Column</h2>
  <pre><code>UPDATE users_staging
SET first_name = CONCAT(UCASE(LEFT(first_name, 1)), LCASE(SUBSTRING(first_name, 2)));</code></pre>
  <p>
    Standardizes capitalization in <code>first_name</code>.
  </p>
  <pre><code>SELECT COUNT(*) FROM users_staging
WHERE first_name = CONCAT(UCASE(LEFT(first_name, 1)), LCASE(SUBSTRING(first_name, 2)));</code></pre>
  <p>
    Verifies whether all names are properly formatted.
  </p>
  
  <h2>8. Standardizing Email Format</h2>
  <pre><code>UPDATE users_staging
SET email = INSERT(email, LOCATE('.', email), 1, '');</code></pre>
  <p>
    Removes unnecessary dots from emails.
  </p>
  <pre><code>UPDATE users_staging
SET email = CONCAT(LEFT(email, LOCATE('@', email)), LCASE(RIGHT(email, LENGTH(email) - LOCATE('@', email))));</code></pre>
  <p>
    Ensures email domains are in lowercase.
  </p>
  <pre><code>UPDATE users_staging
SET email = REPLACE(email, '.in', '.com')
WHERE email LIKE '%.in';</code></pre>
  <p>
    Corrects incorrect domain extensions.
  </p>
  
  <h2>9. Cleaning <code>gender</code> Column</h2>
  <pre><code>UPDATE users_staging
SET gender = CASE
 WHEN gender = 'M' THEN 'Male'
 WHEN gender = 'F' THEN 'Female'
 ELSE gender
END;</code></pre>
  <p>
    Standardizes gender values for consistency.
  </p>
  
  <h2>10. Cleaning <code>location</code> Column</h2>
  <pre><code>UPDATE users_staging
SET location = CASE
 WHEN location = 'Pokhara123Chitwan' THEN 'Chitwan'
 WHEN location = 'Biratn@gar' THEN 'Biratnagar'
 WHEN location = 'Kathm#$ndu' OR location = 'Balen City' THEN 'Kathmandu'
 WHEN location = 'Pokahara' OR location = 'P0khara' THEN 'Pokhara'
 WHEN location = 'lalitpur4443' THEN 'Lalitpur'
 WHEN location = 'Raasuwa' OR location = 'rasuwa' THEN 'Rasuwa'
 ELSE location
END;</code></pre>
  <p>
    Corrects misspelled and inconsistent location names.
  </p>
  
  <h2>11. Cleaning <code>age</code> Column</h2>
  <pre><code>DELETE FROM users_staging
WHERE age < 16;</code></pre>
  <p>
    Removes records where <code>age</code> is less than 16, ensuring valid data.
  </p>
  <pre><code>ALTER TABLE users_staging
ADD CONSTRAINT age_check CHECK (age >= 16);</code></pre>
  <p>
    Prevents future invalid age entries.
  </p>
  
  <h2>12. Cleaning <code>contact_info</code> Column</h2>
  <pre><code>SELECT contact_info, CHAR_LENGTH(contact_info) AS tendigits
FROM users_staging
WHERE CHAR_LENGTH(contact_info) != 10;</code></pre>
  <p>
    Identifies phone numbers that do not have exactly 10 digits.
  </p>
  
  <h2>13. Validating Financial Columns</h2>
  <pre><code>SELECT DISTINCT total_balance FROM users_staging ORDER BY 1;</code></pre>
  <p>
    Ensures all balance values are within expected limits.
  </p>
  <pre><code>SELECT DISTINCT transaction_count FROM users_staging ORDER BY 1;</code></pre>
  <p>
    Identifies anomalies in transaction counts.
  </p>
  
  <h2>14. Cleaning <code>account_age</code> Column</h2>
  <pre><code>UPDATE users_staging
SET account_age_in_day = CASE
 WHEN account_age_in_day < 0 THEN account_age_in_day * -1
 ELSE account_age_in_day
END;</code></pre>
  <p>
    Converts negative account age values to positive.
  </p>
  
  <hr>
  
  <h2>Conclusion</h2>
  <p>
    This project ensures a clean and standardized dataset for analysis by:
  </p>
  <ul>
    <li>Creating a staging table for safe data cleaning.</li>
    <li>Identifying and removing duplicate values.</li>
    <li>Standardizing name, email, and location formats.</li>
    <li>Validating numerical fields and financial constraints.</li>
    <li>Fixing inconsistencies in categorical columns such as gender and location.</li>
  </ul>
  <p>
    Now, this data is ready for <strong>Exploratory Data Analysis (EDA) and dashboard visualization</strong>.
  </p>
</body>
</html>
