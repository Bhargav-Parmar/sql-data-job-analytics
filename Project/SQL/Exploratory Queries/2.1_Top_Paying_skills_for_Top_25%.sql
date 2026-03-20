/* 
What are the most valuable skills within 
the top 25% salary tier for Data Analyst 
and Software Engineer roles?

- Segment job postings into salary 
  quartiles using NTILE(4)
- Identify jobs within the highest salary 
  quartile (Top 25%)
- Join skill mapping tables to determine 
  required skills
- Calculate skill demand within the 
  premium salary tier
- Compute average salary per skill for 
  compensation impact analysis

Why?

To isolate high-income job segments and 
identify which skills are most strongly 
associated with premium compensation levels,
while maintaining role-wise separation to 
avoid skill contamination.
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

SELECT
    rj.job_title_short,
    COALESCE(sd.skills, 'Not Disclosed') AS skill_name,
    COUNT(sjd.job_id) AS demand_count,
    ROUND(AVG(rj.salary_year_avg)) AS avg_salary,
    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY rj.salary_year_avg)::numeric,
        2
    ) AS median_salary
FROM
    ranked_jobs AS rj
INNER JOIN skills_job_dim AS sjd
ON rj.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
ON sjd.skill_id = sd.skill_id
WHERE
    rj.salary_quartile = 1
GROUP BY 
    rj.job_title_short,
    skill_name
ORDER BY
    rj.job_title_short,
    demand_count DESC

