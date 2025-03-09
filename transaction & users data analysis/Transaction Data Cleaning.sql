-- selecting the right database
USE portfolio_projects;


-- ------------------------------------------------------------------------------------------------------------------
-- creating a staging table for "transactions" table to clean and analyze the data
-- ------------------------------------------------------------------------------------------------------------------
CREATE TABLE transactions_staging LIKE transactions;

-- checking the structure newly created staging table
DESC transactions_staging;

-- inserting all the data into new staging table from original transactions table
INSERT INTO transactions_staging
SELECT * FROM transactions;

-- checking for any rows in the original table that are not in newly create staging table
SELECT *
FROM
transactions AS t1
LEFT JOIN
transactions_staging AS t2 
ON t1.transaction_id = t2.transaction_id
WHERE t2.transaction_id IS NULL;


-- adding primary key constraint in 'transaction_id' column
-- could not make transaction_id primary key because of duplicates values so first we need to delete those duplicates values 
ALTER TABLE transactions_staging
MODIFY transaction_id INT NOT NULL,
ADD PRIMARY KEY(transaction_id);

-- checking if primary key was successfully added or not
-- looks like due to duplicates transaction_id we couldn't convert transaction_id to primary key 
-- so we will first delete those duplicates values
DESCRIBE transactions_staging;


-- converting user_id datatype to int and making sure it is not null
ALTER TABLE transactions_staging
modify column user_id int not null;

-- adding foreign key constraint to link (transactions_staging) to (users) table
ALTER TABLE transactions_staging
ADD CONSTRAINT foreign_key_user_id FOREIGN KEY (user_id) REFERENCES users_demo(user_id);

-- checking foreign key constraints
SELECT CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME 
FROM information_schema.KEY_COLUMN_USAGE 
WHERE TABLE_NAME = 'transactions_staging' 
AND CONSTRAINT_SCHEMA = 'portfolio_projects' 
AND REFERENCED_TABLE_NAME IS NOT NULL;


-- ------------------------------------------------------------------------------------------------------------------
-- identifying duplicates values and deleting duplicates values if possible
-- ------------------------------------------------------------------------------------------------------------------
-- this query checks if there's any duplicates values in 'transactions_staging' table
WITH duplicate_rows AS (
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY transaction_id, user_id, amount, transaction_type, `timestamp`, `status` ORDER BY transaction_id) AS row_num
	from transactions_staging
)
SELECT * FROM duplicate_rows
WHERE row_num > 1;

-- found 198 duplicates values in 'transactions_staging' table
-- adding unique identifier primary key to easily delete duplicates values from 'transactions_staging' table
ALTER TABLE transactions_staging
ADD COLUMN temp_id INT AUTO_INCREMENT PRIMARY KEY;


-- deleting duplicates values using self join on the basic of 'temp_id' column 
DELETE t1 
FROM transactions_staging AS t1
JOIN
transactions_staging AS t2 
	ON t1.transaction_id = t2.transaction_id
	AND t1.user_id = t2.user_id
	AND t1.amount = t2.amount
	AND t1.transaction_type = t2.transaction_type
	AND t1.`timestamp` = t2.`timestamp`
	AND t1.`status` = t2.`status` 
WHERE
    t1.temp_id > t2.temp_id;

-- deleting the column we added to delete duplicates values in the 'transactions_staging' table 
ALTER TABLE transactions_staging
DROP COLUMN temp_id;



-- ------------------------------------------------------------------------------------------------------------------
-- CLEANING 'transaction_type' column
-- ------------------------------------------------------------------------------------------------------------------
-- identifying any inconsitent values in 'transaction_type' column
SELECT DISTINCT transaction_type FROM transactions_staging;

				-- found these values -- 
					-- 'withdrawal'
					-- 'p@yment'
					-- 'dep0sit'
					-- 'deposit'
					-- 'payment'
					-- 'withdraal'

-- standardizing 'transaction_type' values
SELECT DISTINCT transaction_type,
	CASE
		WHEN transaction_type = 'withdrawal' OR transaction_type = 'withdraal' THEN 'Withdraw'
        WHEN transaction_type = 'p@yment' THEN 'Payment'
        WHEN transaction_type = 'dep0sit' THEN 'Deposit'
        ELSE transaction_type
        END AS formatted_transaction_type
FROM transactions_staging;

-- updating standardized values in 'transaction_type' column
UPDATE transactions_staging
SET transaction_type = CASE
		WHEN transaction_type = 'withdrawal' OR transaction_type = 'withdraal' THEN 'Withdraw'
        WHEN transaction_type = 'p@yment' THEN 'Payment'
        WHEN transaction_type = 'dep0sit' THEN 'Deposit'
        ELSE transaction_type
        END;
        
-- capitalizing all the values in 'transaction_type' column
SELECT transaction_type,
CONCAT(UCASE(LEFT(transaction_type, 1)), SUBSTRING(transaction_type, 2))
FROM transactions_staging;

-- updating transactions_staging table with capitalized values
UPDATE transactions_staging
SET transaction_type = CONCAT(UCASE(LEFT(transaction_type, 1)), SUBSTRING(transaction_type, 2));

-- checking if there's any values left
SELECT transaction_type
FROM transactions_staging
WHERE transaction_type != CONCAT(UCASE(LEFT(transaction_type, 1)), SUBSTRING(transaction_type, 2));



-- ------------------------------------------------------------------------------------------------------------------
-- CLEANING 'amount' column
-- ------------------------------------------------------------------------------------------------------------------
-- identifying minimum and maximum value in the 'amount' column 
SELECT MIN(amount), MAX(amount) FROM transactions_staging;

-- checking for inconsistencies values in 'amount' column
SELECT DISTINCT amount 
FROM transactions_staging
ORDER BY 1;



-- ------------------------------------------------------------------------------------------------------------------
-- CLEANING 'status' column
-- ------------------------------------------------------------------------------------------------------------------
-- checking for inconsistencies values in status column
SELECT DISTINCT `status` 
FROM transactions_staging;

					-- found these values -- 
						-- 'success'
						-- 'pending'
						-- 'f@iled'
						-- 'failed'
						-- 'succes'
						-- 'pendng'
                        
-- standardizing 'status' column's values
SELECT DISTINCT `status`,
	CASE
		WHEN `status` = 'success' OR `status` = 'succes' THEN 'Success'
		WHEN `status` = 'pending' OR `status` = 'pendng' THEN 'Pending'
        WHEN `status` = 'f@iled' OR `status` = 'failed' THEN 'Failed'
        ELSE `status`
        END AS formatted_status
FROM transactions_staging;

-- updating standardized 'status' column's values
UPDATE transactions_staging
SET `status` = 	
	CASE
		WHEN `status` = 'success' OR `status` = 'succes' THEN 'Success'
		WHEN `status` = 'pending' OR `status` = 'pendng' THEN 'Pending'
        WHEN `status` = 'f@iled' OR `status` = 'failed' THEN 'Failed'
        ELSE `status`
        END;
        
-- checking for any inconsistencies values left in 'status' column
SELECT DISTINCT `status` FROM transactions_staging;



-- ------------------------------------------------------------------------------------------------------------------
-- CLEANING 'timestamp' column
-- ------------------------------------------------------------------------------------------------------------------
-- looking for any inconsistency in date format or any messy values in 'timestamp' column 
SELECT DISTINCT `timestamp` FROM transactions_staging ORDER BY 1;

-- identifying the time period of this table
SELECT MIN(`timestamp`), MAX(`timestamp`) FROM transactions_staging;

-- identifying data type of this column 'timestamp'
DESC transactions_staging;

-- changing data type to DATETIME for `timestamp` column
ALTER TABLE transactions_staging
MODIFY `timestamp` DATETIME;
 
-- converting empty values to NULL values so we can change 'timestamp' datatype
UPDATE transactions_staging
SET `timestamp` = NULL
WHERE `timestamp` = '';





