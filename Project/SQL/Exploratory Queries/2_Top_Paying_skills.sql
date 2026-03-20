/*
Objective: Identify the key skills 
required for the Top 100 highest-paying 
Data Analyst and Data Scientist roles.

This query first selects the top 10 jobs 
based on highest average salary, then joins
the relevant skills tables to determine 
which technical competencies are associated
with these premium-level positions.

Purpose: To analyze which skills contribute
to extreme salary levels across both DA 
and DS roles.
*/


WITH ranked_jobs AS(
    SELECT
        job_id,
        company_id,
        job_title_short,
        salary_year_avg,
        COALESCE(job_location, 'Not Disclosed') AS location,
        ROW_NUMBER() OVER(
            PARTITION BY job_title_short
            ORDER BY salary_year_avg DESC
        ) AS rank_per_role
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
    ROUND(AVG(salary_year_avg), 2) AS avg_salary,
    ROUND(PERCENTILE_CONT(0.5)
        WITHIN GROUP(ORDER BY
                        rj.salary_year_avg)::numeric, 2) AS median_salary
FROM
    ranked_jobs AS rj
INNER JOIN skills_job_dim AS sjd
ON rj.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
ON sjd.skill_id = sd.skill_id
WHERE
    rj.rank_per_role <=100
GROUP BY
    rj.job_title_short,
    skill_name
HAVING
    COUNT(sjd.job_id) > 2
ORDER BY
    rj.job_title_short,
    demand_count DESC


