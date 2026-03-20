/*What are the top paying data analyst
and SE jobs?
- identify top 100 highest paying jobs that
  are availabe for both roles
- Exclude null salaries
- Why? Highlight the top paying 
  opportunities and offering insights
  into the global market
*/


WITH ranked_jobs AS(
    SELECT
        job_id,
        company_id,
        job_title_short,
        salary_year_avg,
        COALESCE(job_location, 'Not Disclosed') AS location,
        job_schedule_type,
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

SELECT * FROM ranked_jobs
WHERE rank_per_role <=100
ORDER BY job_title_short,
         salary_year_avg DESC