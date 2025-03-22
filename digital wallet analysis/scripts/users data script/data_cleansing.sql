-- selecting the right data base
USE portfolio_projects;


-- ------------------------------------------------------------------------------------------------------------------
-- creating a staging table for "users" table to clean and analyze the data
-- ------------------------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS users_staging
LIKE users;

-- checking the structure of old & new table
DESC users;
DESC users_staging;

-- copying all the data from "users" table to new staging table "users_staging"
INSERT INTO users_staging
SELECT * FROM users;

-- checking if there's any data left in the original table
SELECT * FROM users AS t1
LEFT JOIN users_staging AS t2
ON t1.user_id = t2.user_id
WHERE t2.user_id IS NULL;

-- adding not null & primary key constraints to the 'user_id' column
ALTER TABLE users_staging
MODIFY COLUMN user_id INT NOT NULL,
ADD PRIMARY KEY(user_id);

-- changing the datatype of total_balance column to decimal(8,2) because the max amount any users can have is less than a lakh
ALTER TABLE users_staging
MODIFY COLUMN total_balance DECIMAL(8,2);


-- ------------------------------------------------------------------------------------------------------------------
-- DATA CLEANING
-- ------------------------------------------------------------------------------------------------------------------ 


-- identifyihng the values or data in the "users" table
SELECT * FROM users_staging LIMIT 50;


-- looking for any duplicate values or rows in the table
WITH duplicate_rows as (
	select *,
		row_number()
		over(partition by user_id, first_name, last_name, email, gender, age, contact_info, 
		location, total_balance,transaction_count, total_spent, account_age order by user_id) as `row_count`
	from users_staging
)
select * from duplicate_rows
where `row_count` > 1;


-- ------------------------------------------------------------------------------------------------------------------
-- identifying for any inconsistency, null or false values in the 'first_name' column
-- ------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT first_name FROM users_staging
ORDER BY 1;
SELECT first_name FROM users_staging
ORDER BY 1;

-- comparing inconsitent names with capitalized names
SELECT first_name, CONCAT(UCASE(LEFT(first_name, 1)), LCASE(SUBSTRING(first_name, 2))) AS capitalized_name
FROM users_staging
ORDER BY 1;

-- updating the 'fist_name' column where we capitalized all the first names
UPDATE users_staging
SET first_name = 
CONCAT(UCASE(LEFT(first_name, 1)), LCASE(SUBSTRING(first_name, 2)));

-- counting all the capitilized names to see if there's any inconsitent names(we should get 500 rows since that's our total rows in the table)
SELECT COUNT(*) FROM users_staging 
WHERE first_name = CONCAT(UCASE(LEFT(first_name, 1)), LCASE(SUBSTRING(first_name, 2)));


-- ------------------------------------------------------------------------------------------------------------------
-- looking for any inconsistency in last_name column
-- ------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT last_name FROM users_staging
ORDER BY 1;

SELECT COUNT(last_name)
FROM users_staging
WHERE last_name = CONCAT(UCASE(LEFT(last_name, 1)), LCASE(SUBSTRING(last_name, 2))); 

-- found nothing


-- ------------------------------------------------------------------------------------------------------------------
-- cleaning and standardizing 'email' column
-- ------------------------------------------------------------------------------------------------------------------
SELECT email FROM users_staging;

-- removing the first dots '.' in the email column since it looks cleaner and it also does not affect the email id of a user
SELECT email
FROM users_staging
WHERE email = INSERT(email, LOCATE('.', email), 1, '');

-- updating the users_staging table with our new formatted emails
UPDATE users_staging
SET email = INSERT(email, LOCATE('.', email), 1, '');

-- identifying others inconsistency in 'email' column
SELECT DISTINCT email FROM users_staging;

-- lowercasing the domain name in the email after '@'
SELECT email,
CONCAT(LEFT(email, LOCATE('@', email)),
LCASE(RIGHT(email, LENGTH(email) - LOCATE('@', email))))
FROM users_staging;

-- updating new formatted domain name in the email column
UPDATE users_staging
SET email = CONCAT(LEFT(email, LOCATE('@', email)),
LCASE(RIGHT(email, LENGTH(email) - LOCATE('@', email))));


-- again checking for any false values in the email column
SELECT DISTINCT email FROM users_staging;

-- found there's a domain name like 'gmail.in' which should be 'gmail.com'
SELECT email FROM users_staging
WHERE email LIKE '%gmail.in';

-- replacing the '.in' values with '.com' using replace
SELECT email,
REPLACE(email, '.in', '.com')
FROM users_staging
WHERE email LIKE '%.in';

-- updating the new values in the users_staging table
UPDATE users_staging
SET email = REPLACE(email, '.in', '.com')
WHERE email LIKE '%.in';

-- checking if ther's any values left with '.in' domain name 
SELECT email FROM users_staging
WHERE email LIKE '%.in';

-- looking for any inconsistency values in the 'email' column
SELECT DISTINCT email FROM users_staging;

-- found there's extra 'o' in the yahoo domain name & formating it using substring_index with concat
SELECT email,
CONCAT(SUBSTRING_INDEX(email, '@', 1), '@yahoo.com') AS formatted_domain
FROM users_staging
WHERE email LIKE '%@yahoo%.com';

-- updating email column with new formatted domain name
UPDATE users_staging
SET email = CONCAT(SUBSTRING_INDEX(email, '@', 1), '@yahoo.com')
WHERE email LIKE '%@yahoo%.com';

-- checking if our query worked or not
SELECT email FROM users_staging
WHERE email LIKE '%yahoo.com%'
AND email != CONCAT(SUBSTRING_INDEX(email, '@', 1), '@yahoo.com');

-- identifying the numbers of empty values in 'email' column
SELECT count(email) FROM users_staging
WHERE email = '';

-- updating users_staging table with 'Unknown' value for empty values
UPDATE users_staging
SET email = 'Unknown'
WHERE email = '';

-- counting 'Unknown' values
SELECT COUNT(email) 
FROM users_staging
WHERE email = 'Unknown';


-- ------------------------------------------------------------------------------------------------------------------
-- looking for inconsistent values in 'gender' columns
-- ------------------------------------------------------------------------------------------------------------------
-- identifying gender column for inconsistent values
SELECT DISTINCT gender FROM users_staging;
-- found there's a 5 values (M, F, Male, Female, Other)


-- converting 'M' to Male and 'F' to 'Female' using case
SELECT gender,
	CASE
    WHEN gender = 'M' THEN 'Male'
    WHEN gender = 'F' THEN 'Female'
    ELSE gender
    END AS formatted_gender
FROM users_staging;

-- updating gender column with new formatted values
UPDATE users_staging
SET gender = CASE
			 WHEN gender = 'M' THEN 'Male'
             WHEN gender = 'F' THEN 'Female'
             ELSE gender
             END;
             
             
-- ------------------------------------------------------------------------------------------------------------------
-- identifying any inconsistency values in column 'location'
-- ------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT location FROM users_staging;

-- These are the messy values in the 'location' column
-- 'Pokhara123Chitwan'
-- 'Biratn@gar'
-- 'Kathm#$ndu'
-- 'Pokahara'
-- 'lalitpur4443'
-- 'Raasuwa'
-- 'Balen City'
-- 'P0khara'

-- formating all the messy values using case statement in the 'location' column
SELECT DISTINCT location,
	CASE
		WHEN location = 'Pokhara123Chitwan' THEN 'Chitwan'
        WHEN location = 'Biratn@gar' THEN 'Biratnagar'
        WHEN location = 'Kathm#$ndu' OR location = 'Balen City' THEN 'Kathmandu'
        WHEN location = 'Pokahara' OR location = 'P0khara' THEN 'Pokhara'
		WHEN location = 'lalitpur4443' THEN 'Lalitpur'
        WHEN location = 'Raasuwa' OR location = 'rasuwa' THEN 'Rasuwa'
        ELSE location
        END AS formatted_locations
FROM users_staging;

-- updating location column with formatted location names
UPDATE users_staging
SET location = 	CASE
		WHEN location = 'Pokhara123Chitwan' THEN 'Chitwan'
        WHEN location = 'Biratn@gar' THEN 'Biratnagar'
        WHEN location = 'Kathm#$ndu' OR location = 'Balen City' THEN 'Kathmandu'
        WHEN location = 'Pokahara' OR location = 'P0khara' THEN 'Pokhara'
		WHEN location = 'lalitpur4443' THEN 'Lalitpur'
        WHEN location = 'Raasuwa' OR location = 'rasuwa' THEN 'Rasuwa'
        ELSE location
        END;
	
-- checking our new formatted data was applied or not
SELECT DISTINCT location FROM users_staging;
SELECT location FROM users_staging;


-- ------------------------------------------------------------------------------------------------------------------
-- cleaning 'age' column
-- ------------------------------------------------------------------------------------------------------------------
-- looking for any messy values in the 'age' column
SELECT age FROM users_staging;
SELECT * FROM users_staging;

-- found there's negative value (-1) in the column
SELECT * FROM users_staging
WHERE age LIKE '-%';

-- deleting that negative values from the age column since this 'user' tables minimum age is 16 years old only
-- and also -1 does not make any sense.

DELETE FROM users_staging
WHERE age < 16;

-- adding a constraint in the 'age' column
ALTER TABLE users_staging
ADD CONSTRAINT age_check CHECK (age >= 16);


-- ------------------------------------------------------------------------------------------------------------------
-- cleaning 'contact_info' column
-- ------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT contact_info
FROM users_staging;

-- checking if there's any number that is less than or more than 10 digits since 10 digits is the standard length in nepal 
SELECT contact_info, CHAR_LENGTH(contact_info) AS tendigits
FROM users_staging
WHERE CHAR_LENGTH(contact_info) != 10;


-- ------------------------------------------------------------------------------------------------------------------
-- cleaning 'total_balance' column
-- ------------------------------------------------------------------------------------------------------------------
-- identifying if there's any inconsistent values in the 'total_balance' column and 
-- if there's any values that is less than 0 and more than 50000, (minimum & maximum balance)
SELECT DISTINCT total_balance
FROM users_staging
ORDER BY 1;


-- ------------------------------------------------------------------------------------------------------------------
-- cleaning 'transaction_count' column
-- ------------------------------------------------------------------------------------------------------------------
-- identifying messy values in column transaction_count
SELECT DISTINCT transaction_count
FROM users_staging
ORDER BY 1;


-- ------------------------------------------------------------------------------------------------------------------
-- cleaning 'total_spent' column
-- ------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT total_spent
FROM users_staging
ORDER BY 1;


-- ------------------------------------------------------------------------------------------------------------------
-- cleaning 'account_age' column
-- ------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT account_age_in_day
FROM users_staging;

-- changing column name to account_age_in_day since the values represents the number of days
ALTER TABLE users_staging
RENAME COLUMN account_age TO account_age_in_day;

-- identifying values that are less than 0
SELECT *
FROM users_staging
WHERE account_age_in_day <= 0;

-- checking the modified values, where negative values are converted to positive.
SELECT account_age_in_day,
	CASE
		WHEN account_age_in_day < 0 THEN account_age_in_day * - 1
		ELSE account_age_in_day
    END
FROM users_staging
ORDER BY 1;

-- uupdating modified values
UPDATE users_staging 
SET account_age_in_day = 
CASE
	WHEN account_age_in_day < 0 THEN account_age_in_day * - 1
	ELSE account_age_in_day
END;

-- checking if there's any negative values
SELECT account_age_in_day
FROM users_staging
WHERE account_age_in_day < 0
ORDER BY 1;
