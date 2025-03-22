-- analyzing in the correct database
USE world_layoffs;

-- looking at first 20 records to understand table structure
SELECT * FROM layoffs_staging LIMIT 20;

-- identifying the time period covered in the dataset
SELECT MIN(`date`) AS start_date, MAX(`date`) AS end_date FROM layoffs_staging;

-- summary statistics for layoffs and funds raised
SELECT 
    MIN(total_laid_off) AS min_laid_off,
    MAX(total_laid_off) AS max_laid_off,
    AVG(total_laid_off) AS avg_laid_off,
    STDDEV(total_laid_off) AS stddev_laid_off,
    MIN(funds_raised_millions) AS min_funds,
    MAX(funds_raised_millions) AS max_funds,
    AVG(funds_raised_millions) AS avg_funds,
    STDDEV(funds_raised_millions) AS stddev_funds
FROM layoffs_staging;

-- identifying the companies with the highest single-day layoffs
SELECT company, MAX(total_laid_off) AS max_single_day_layoffs
FROM layoffs_staging
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;

-- identifying the top 10 companies with the most total layoffs
SELECT company, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- companies where 100% of employees were laid off
SELECT company, stage, percentage_laid_off
FROM layoffs_staging
WHERE percentage_laid_off = 1
ORDER BY 1;

-- companies with the highest funds raised before layoffs
SELECT company, stage, MAX(funds_raised_millions) AS funds_raised_in_millions
FROM layoffs_staging
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 20;

-- industries with the most layoffs
SELECT industry, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
GROUP BY industry
ORDER BY 2 DESC;

-- countries with the most layoffs
SELECT country, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
GROUP BY country
ORDER BY 2 DESC;

-- total layoffs per year
SELECT YEAR(`date`) AS year, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
WHERE YEAR(`date`) IS NOT NULL
GROUP BY 1
ORDER BY 1;

-- total layoffs by company stage
SELECT stage, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
GROUP BY stage
ORDER BY 2 DESC;

-- monthly layoffs trend
SELECT SUBSTRING(`date`, 1, 7) AS month, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
WHERE `date` IS NOT NULL
GROUP BY 1
ORDER BY 1;

-- rolling total of layoffs over time
WITH rolling_total AS (
    SELECT SUBSTRING(`date`, 1, 7) AS month, SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging
    WHERE `date` IS NOT NULL
    GROUP BY 1
    ORDER BY 1
)
SELECT month, total_layoffs, SUM(total_layoffs) OVER (ORDER BY month) AS rolling_total_layoffs
FROM rolling_total;

-- industry wise rolling total of layoffs
WITH rolling_total AS (
    SELECT industry, SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging
    GROUP BY industry
    ORDER BY 2 DESC
)
SELECT industry, total_layoffs,
       SUM(total_layoffs) OVER (ORDER BY total_layoffs DESC) AS rolling_total_layoffs
FROM rolling_total;

-- top 5 companies with the most layoffs per year
WITH ranking AS (
    SELECT company, YEAR(`date`) AS `year`, SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging
    GROUP BY company, `year`
), company_year_rank AS (
    SELECT *, DENSE_RANK() OVER (PARTITION BY `year` ORDER BY total_layoffs DESC) AS `rank`
    FROM ranking
    WHERE `year` IS NOT NULL
)
SELECT * FROM company_year_rank WHERE `rank` <= 5;

-- finding a median value in total_laid_off column
WITH ranked AS (
    SELECT total_laid_off, 
           ROW_NUMBER() OVER (ORDER BY total_laid_off) AS row_num,
           COUNT(*) OVER () AS total_rows
    FROM layoffs_staging
)
SELECT AVG(total_laid_off) AS median_layoffs
FROM ranked
WHERE row_num IN (FLOOR((total_rows + 1) / 2), CEIL((total_rows + 1) / 2));


-- looking for any corrleation between total_laid_off and funds_raised_millions
SELECT 
    (COUNT(*) * SUM(total_laid_off * funds_raised_millions) - SUM(total_laid_off) * SUM(funds_raised_millions)) /
    (SQRT((COUNT(*) * SUM(total_laid_off * total_laid_off) - POWER(SUM(total_laid_off), 2)) * 
    (COUNT(*) * SUM(funds_raised_millions * funds_raised_millions) - POWER(SUM(funds_raised_millions), 2))))
    AS correlation
FROM layoffs_staging
WHERE total_laid_off IS NOT NULL AND funds_raised_millions IS NOT NULL;
