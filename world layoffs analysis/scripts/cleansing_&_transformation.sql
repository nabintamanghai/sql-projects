-- MAKING SURE WE ARE ON THE RIGHT DATABASE
USE world_layoffs;

-- CREATING A NEW TABLE WITH THE SAME STRUCTURE AS THE ORIGINAL TABLE layoffs
CREATE TABLE layoffs_staging
LIKE layoffs;
-- COPYING ALL THE RAW DATA INTO NEW TABLE
INSERT INTO layoffs_staging
SELECT * FROM layoffs;

-- --------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------
-- HANDLING DUPLICATE DATA AND DELETING DUPLICATE DATA:

-- THIS QUERY RETRIVE DATA FROM layoffs_stagging TABLE ADDING NEW COLUMN NAMED row_num
-- WHICH IS GENERATED USING ROW_NUMBER() WINDOW FUNCTION
-- THIS QUERY CAN HELP IDENTIFY DUPLICATES IN THE DATA
-- WE CAN USE THIS DATA WITH SUBQUERY OR CTE TO FIND THE DUPLICATE ROWS IN THE TABLE
SELECT *,
ROW_NUMBER() 
OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- FINDING THE DUPLICATE ROWS USING SUBQUERY:
SELECT * FROM
(
	SELECT *,
	ROW_NUMBER() 
	OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging
) AS subquery
WHERE row_num > 1;

-- FINDING THE DUPLICATE ROWS USING CTE
WITH duplicate_cte AS
(
	SELECT *,
	ROW_NUMBER() 
	OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging
)
SELECT * FROM duplicate_cte
WHERE row_num > 1;


-- --------------------------------------------------------------------------------------------------------
-- METHOD 1 WITHOUT CREATING NEW TABLE TO DELETE DUPLICATE
-- ADDING TEMPORARY PRIMARY KEY COLUMN FOR EASY DELETION OF DUPLICATE ROWS
ALTER TABLE layoffs_staging ADD COLUMN temp_id INT AUTO_INCREMENT PRIMARY KEY;

-- DELETING DUPLICATE ROWS
WITH duplicate_cte AS (
    SELECT temp_id,
	ROW_NUMBER() OVER (
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
    FROM layoffs_staging
)
DELETE FROM layoffs_staging
WHERE temp_id IN (
    SELECT temp_id
    FROM duplicate_cte
    WHERE row_num > 1
);

-- DELETING THAT PRIMARY KEY COLUMN WE ADDED
ALTER TABLE layoffs_staging DROP COLUMN temp_id;

select count(*) from layoffs_staging;


-- --------------------------------------------------------------------------------------------------------
-- METHOD 2 CREATING NEW STAGGING TABLE TO DELETE DUPLICATE
-- CREATING NEW TABLE JUST LIKE ORIGINAL layoffs TABLE WITH EXTRA COLUMN row_num
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- INSERTING ORIGINAL layoffs DATA PLUS row_num COLUMN 
INSERT INTO layoffs_staging2
SELECT *,
	ROW_NUMBER() 
	OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging;

-- DELETING DUPLICATE ROWS
DELETE FROM layoffs_staging2
WHERE row_num > 2;

-- --------------------------------------------------------------------------------------------------------
-- ANOTHER WAY OF DOING BY CREATING NEW DISTINCT TABLE
CREATE TABLE new_layoffs_table
SELECT DISTINCT * FROM layoffs;

-- --------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------
-- STANDARDIZING DATA:

SELECT * FROM layoffs_staging ORDER BY 1;

-- CHECKING DATA THAT HAS WHITESPACES
SELECT COUNT(*)
FROM layoffs_staging
WHERE LENGTH(company) != LENGTH(TRIM(company));

-- CHECKING IF ANYTHING CHANGED
SELECT company, TRIM(company)
FROM layoffs_staging
ORDER BY 1;

-- UPDATING WHITESPACES REMOVED DATA INTO THE TABLE
UPDATE layoffs_staging
SET company = TRIM(company);

-- --------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------

-- selecting distinct industry to analyze the unique industry values to see 
-- if there are any inconsistencies in the industry column
SELECT DISTINCT industry
FROM layoffs_staging
ORDER BY 1;

-- found two values 'Crypto' & 'Crypto Currency' in the DISTINCT industry which seemed like should be 'Crypto' only
-- selecting industry column with the value that matches to 'Crypto' & ordering it b
SELECT * 
FROM layoffs_staging
WHERE industry LIKE '%Crypto%'
ORDER BY 1;

-- standardizing industry column values related to 'Crypto' for consistency
-- making it easier to group, filter, and analyze industries column in later queries
UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE '%Crypto%';

-- --------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------
--  HANDLING NULL OR EMPTY VALUES IN THE INDUSTRY COLUMN:

-- looking for NULL or EMPTY values in the industry column
SELECT * 
FROM layoffs_staging
WHERE industry IS NULL OR industry = ''
ORDER BY 1;

-- converting empty values in the industry column to NULL because SQL treats empty strings as valid values
-- which does not help update our empty values.
UPDATE layoffs_staging
SET industry = NULL
WHERE industry = '';

-- checking if ther's any empty values in the industry column after changing it to NULL values
SELECT count(industry) 
FROM layoffs_staging
WHERE industry = '';

-- checking for any alternative matching values in the same table using self join to populate 
-- missing values in the industry column based on company column
SELECT t1.company, t1.industry, t2.company, t2.industry
FROM layoffs_staging AS t1
	JOIN layoffs_stagging AS t2
		ON t1.company = t2.company
		WHERE t1.industry IS NULL
		AND t2.industry IS NOT NULL
ORDER BY 1;

-- updating found alternative matching values in the industry column
UPDATE layoffs_staging AS t1
	JOIN layoffs_staging AS t2
		ON t1.company = t2.company
SET t1.industry = t2.industry
		WHERE t1.industry IS NULL
		AND t2.industry IS NOT NULL;


-- deleting rows that have null values in these 3 columns which I really don't think will be usefull for
-- future analysis & since it's just 44 rows, I think it's better to delete these unnessecary rows.
SELECT *
FROM layoffs_staging
	WHERE total_laid_off IS NULL 
	AND percentage_laid_off IS NULL 
	AND funds_raised_millions IS NULL;

-- deleting and making sure deleting the right rows
DELETE FROM layoffs_staging 
WHERE
    total_laid_off IS NULL
    AND percentage_laid_off IS NULL
    AND funds_raised_millions IS NULL;
    
-- --------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------

-- CHANGING THE DATATYPES OF (date) & (percentage_laid_off) COLUMN

-- identifying current datatypes for these columns
EXPLAIN layoffs_staging;

-- identifying current date format in the date column
SELECT `date` FROM layoffs_staging2 LIMIT 10;

-- checking new formatted date to old date format
SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y') AS formatted_date
FROM layoffs_staging;

-- updating values in the date column with new formatted date
UPDATE layoffs_staging
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- changing the datatype of the date column to DATE FROM TEXT
ALTER TABLE layoffs_staging
MODIFY COLUMN `date` DATE;


-- --------------------------------------------------------------------------------------------------------

-- converting the data types of (percentage_laid_off) column

-- identifying the max and min values in the column for right datatype conversion 
SELECT MAX(percentage_laid_off), MIN(percentage_laid_off)
FROM layoffs_staging;

-- changing the datatype to DECIMAL(5,4) from TEXT datatype in percentage_laid_off column
ALTER TABLE layoffs_staging
MODIFY COLUMN percentage_laid_off DECIMAL(5,4);

-- lastly checking the data types of converted columns
EXPLAIN layoffs_staging;
