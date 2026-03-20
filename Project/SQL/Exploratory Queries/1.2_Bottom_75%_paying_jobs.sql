/* What constitutes the Bottom 75% salary 
segment for Data Analyst and Data 
Scientist roles?

- Partition job postings by role
- Order salaries in descending order
- Apply NTILE(4) to divide jobs into four
  equal salary quartiles within each role
- Select quartiles 2–4 to represent the
  lower 75% of the compensation 
  distribution
- Why? To establish the broader market 
  salary layer for comparison against 
  upper and elite compensation tiers.
*/

WITH ranked_jobs AS(
    SELECT
        job_id,
        company_id,
        job_title_short,
        salary_year_avg,
        COALESCE(job_location, 'Not Disclosed') AS location,
        NTILE(4) OVER(
            PARTITION BY job_title_short
            ORDER BY salary_year_avg DESC
        ) AS salary_quartile
    FROM
        job_postings_fact
    WHERE
        job_title_short IN ('Data Analyst', 'Data Scientist') AND
        salary_year_avg IS NOT NULL
)
SELECT * FROM ranked_jobs
WHERE NOT salary_quartile = 1
ORDER BY job_title_short, salary_year_avg DESC