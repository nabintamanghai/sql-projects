 <h1>Transactions Data Cleaning Process</h1>
  
  <h2>Overview</h2>
  <p>
    This document contains all the scripts written to clean the <strong>transactions</strong> data for analysis and visualization. Each script is accompanied by an explanation of its purpose, ensuring that every step from setting the correct database to standardizing column values is clearly documented.
  </p>
  <p>
    The scripts aim to transform raw, inconsistent data into a clean and standardized dataset. This process includes creating staging tables, verifying data integrity, removing duplicates, and standardizing values for columns like <code>transaction_type</code>, <code>amount</code>, <code>status</code>, and <code>timestamp</code>. This thorough cleaning ensures that the data is consistent, accurate, and ready for further analysis.
  </p>
  
  <hr>
  <h1>Data Cleaning Process</h1>
  <h2>1. Selecting the Right Database</h2>
  <pre><code>USE portfolio_projects;</code></pre>
  <p>
    • Selects the database where the project will be executed.<br>
    • Ensures you are working in the correct database to avoid accidentally modifying the wrong data.
  </p>
  
  <h2>2. Creating a Staging Table</h2>
  <pre><code>CREATE TABLE transactions_staging LIKE transactions;</code></pre>
  <p>
    • Creates a staging table named <code>transactions_staging</code> with the same structure as the original <code>transactions</code> table using the LIKE function.<br>
    • Staging tables are used to clean and transform data without affecting the original dataset.
  </p>
  
  <h2>3. Checking the Structure of the Staging Table</h2>
  <pre><code>DESC transactions_staging;</code></pre>
  <p>
    • Displays the structure of the <code>transactions_staging</code> table. The <code>DESC</code> (or <code>DESCRIBE</code>) command lists all columns with their data types and constraints.
  </p>
  
  <h2>4. Inserting Data into the Staging Table</h2>
  <pre><code>INSERT INTO transactions_staging
SELECT * FROM transactions;</code></pre>
  <p>
    • Copies all data from the <code>transactions</code> table into the <code>transactions_staging</code> table.<br>
    • Uses the <code>INSERT INTO ... SELECT</code> statement to select all rows from the original table and insert them into the staging table.
  </p>
  
  <h2>5. Verifying Data Consistency</h2>
  <pre><code>SELECT *
FROM transactions AS t1
LEFT JOIN transactions_staging AS t2
ON t1.transaction_id = t2.transaction_id
WHERE t2.transaction_id IS NULL;</code></pre>
  <p>
    • Checks if any rows in the original <code>transactions</code> table are missing in the <code>transactions_staging</code> table.<br>
    • Ensures that no data was lost during the copying process.
  </p>
  
  <h2>6. Attempting to Add a Primary Key</h2>
  <pre><code>ALTER TABLE transactions_staging
MODIFY transaction_id INT NOT NULL,
ADD PRIMARY KEY(transaction_id);</code></pre>
  <p>
    • Attempts to add a primary key constraint to the <code>transaction_id</code> column.<br>
    • The <code>MODIFY</code> clause ensures the column is not nullable, and the <code>ADD PRIMARY KEY</code> clause sets it as the primary key.<br>
    • This query may fail initially if there are duplicate values in the <code>transaction_id</code> column; duplicates must be removed first.
  </p>
  
  <h2>7. Checking for Duplicate Rows</h2>
  <pre><code>WITH duplicate_rows AS (
  SELECT *,
         ROW_NUMBER() OVER(PARTITION BY transaction_id, user_id, amount, transaction_type, 
                           timestamp, status ORDER BY transaction_id) AS row_num
  FROM transactions_staging
)
SELECT * FROM duplicate_rows
WHERE row_num > 1;</code></pre>
  <p>
    • Checks for duplicate rows in the <code>transactions_staging</code> table using Common Table Expressions (CTEs).<br>
    • The <code>ROW_NUMBER()</code> window function assigns a unique number to each row within groups of duplicates. Rows with <code>row_num &gt; 1</code> are identified as duplicates.
  </p>
  
  <h2>8. Adding a Temporary ID Column</h2>
  <pre><code>ALTER TABLE transactions_staging
ADD COLUMN temp_id INT AUTO_INCREMENT PRIMARY KEY;</code></pre>
  <p>
    • Adds a temporary unique identifier (<code>temp_id</code>) to help delete duplicate rows.<br>
    • The <code>AUTO_INCREMENT</code> property ensures each row gets a unique value, and the <code>PRIMARY KEY</code> constraint enforces uniqueness.
  </p>
  
  <h2>9. Deleting Duplicate Rows</h2>
  <pre><code>DELETE t1
FROM transactions_staging AS t1
JOIN transactions_staging AS t2
  ON t1.transaction_id = t2.transaction_id
  AND t1.user_id = t2.user_id
  AND t1.amount = t2.amount
  AND t1.transaction_type = t2.transaction_type
  AND t1.timestamp = t2.timestamp
  AND t1.status = t2.status
WHERE t1.temp_id > t2.temp_id;</code></pre>
  <p>
    • Deletes duplicate rows from the <code>transactions_staging</code> table using a self-join.<br>
    • Compares rows based on key columns and deletes the row with the higher <code>temp_id</code>, ensuring only the first occurrence is retained.
  </p>
  
  <h2>10. Removing the Temporary ID Column</h2>
  <pre><code>ALTER TABLE transactions_staging
DROP COLUMN temp_id;</code></pre>
  <p>
    • Removes the temporary <code>temp_id</code> column after duplicates have been deleted.
  </p>
  
  <h2>11. Cleaning the <code>transaction_type</code> Column</h2>
  <pre><code>SELECT DISTINCT transaction_type FROM transactions_staging;</code></pre>
  <p>
    • Identifies inconsistent values in the <code>transaction_type</code> column by listing all unique values.
  </p>
  <h3>Standardizing <code>transaction_type</code> Values</h3>
  <pre><code>UPDATE transactions_staging
SET transaction_type = CASE
  WHEN transaction_type = 'withdrawal' OR transaction_type = 'withdraal' THEN 'Withdraw'
  WHEN transaction_type = 'p@yment' THEN 'Payment'
  WHEN transaction_type = 'dep0sit' THEN 'Deposit'
  ELSE transaction_type
END;</code></pre>
  <p>
    • Standardizes inconsistent values in the <code>transaction_type</code> column using a <code>CASE</code> statement.<br>
    • Converts various incorrect spellings and formats to standardized forms.
  </p>
  <h3>Formatting Transaction Types</h3>
  <pre><code>SELECT transaction_type,
CONCAT(UCASE(LEFT(transaction_type, 1)), SUBSTRING(transaction_type, 2))
FROM transactions_staging;</code></pre>
  <p>
    • Applies capitalization formatting so that transaction types start with an uppercase letter.
  </p>
  <pre><code>UPDATE transactions_staging
SET transaction_type = CONCAT(UCASE(LEFT(transaction_type, 1)), SUBSTRING(transaction_type, 2));</code></pre>
  <p>
    • Updates the transaction types to ensure proper capitalization.
  </p>
  <pre><code>SELECT transaction_type 
FROM transactions_staging 
WHERE transaction_type != CONCAT(UCASE(LEFT(transaction_type, 1)), SUBSTRING(transaction_type, 2));</code></pre>
  <p>
    • Checks if any values still need fixing after the update.
  </p>
  
  <h2>12. Cleaning the <code>amount</code> Column</h2>
  <pre><code>SELECT MIN(amount), MAX(amount) FROM transactions_staging;</code></pre>
  <p>
    • Identifies the range of values in the <code>amount</code> column to check for any outliers or incorrect values.
  </p>
  <pre><code>SELECT DISTINCT amount FROM transactions_staging ORDER BY 1;</code></pre>
  <p>
    • Lists all unique values in the <code>amount</code> column to further inspect for inconsistencies.
  </p>
  
  <h2>13. Cleaning the <code>status</code> Column</h2>
  <pre><code>SELECT DISTINCT `status` FROM transactions_staging;</code></pre>
  <p>
    • Identifies inconsistent values in the <code>status</code> column.
  </p>
  <pre><code>SELECT DISTINCT `status`,
  CASE
    WHEN `status` = 'success' OR `status` = 'succes' THEN 'Success'
    WHEN `status` = 'pending' OR `status` = 'pendng' THEN 'Pending'
    WHEN `status` = 'f@iled' OR `status` = 'failed' THEN 'Failed'
    ELSE `status`
  END AS formatted_status
FROM transactions_staging;</code></pre>
  <p>
    • Checks if inconsistent data in the <code>status</code> column is formatted correctly before updating.
  </p>
  <pre><code>UPDATE transactions_staging
SET `status` =
  CASE
    WHEN `status` = 'success' OR `status` = 'succes' THEN 'Success'
    WHEN `status` = 'pending' OR `status` = 'pendng' THEN 'Pending'
    WHEN `status` = 'f@iled' OR `status` = 'failed' THEN 'Failed'
    ELSE `status`
  END;</code></pre>
  <p>
    • Updates the <code>status</code> column to standardize its values.
  </p>
  <pre><code>SELECT DISTINCT status FROM transactions_staging;</code></pre>
  <p>
    • Verifies that all <code>status</code> values are now standardized.
  </p>
  
  <h2>14. Cleaning the <code>timestamp</code> Column</h2>
  <pre><code>SELECT DISTINCT `timestamp` FROM transactions_staging ORDER BY 1;</code></pre>
  <p>
    • Checks for any inconsistent date formats or missing values in the <code>timestamp</code> column.
  </p>
  <pre><code>SELECT MIN(`timestamp`), MAX(`timestamp`) FROM transactions_staging;</code></pre>
  <p>
    • Identifies the earliest and latest transaction timestamps.
  </p>
  <pre><code>DESC transactions_staging;</code></pre>
  <p>
    • Checks the data type of the <code>timestamp</code> column to ensure it is correctly formatted.
  </p>
  <pre><code>ALTER TABLE transactions_staging MODIFY `timestamp` DATETIME;</code></pre>
  <p>
    • Updates the <code>timestamp</code> column to the <code>DATETIME</code> format.
  </p>
  <pre><code>UPDATE transactions_staging 
SET `timestamp` = NULL 
WHERE `timestamp` = ' ';</code></pre>
  <p>
    • Updates empty values with <code>NULL</code> to ensure correct data conversion.
  </p>
  
  <hr>
  
  <h2>Summary</h2>
  <p>
    This documentation outlines the step-by-step process of cleaning and preparing the <code>transactions</code> table for analysis. Each query serves a specific purpose, from creating a staging table and verifying data integrity to standardizing values and removing duplicates. By following this process, the data is made consistent, accurate, and ready for further analysis.
  </p>
</body>
</html>
