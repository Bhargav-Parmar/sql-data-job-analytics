/*What skills are associated with the top 25% highest paying
Data Analyst and Software Engineer roles?

- Segment jobs into salary quartiles using
 NTILE(4)
- Identify jobs that fall in the highest 
 salary quartile
- Analyze required skills for this premium 
 compensation tier
- Why? To understand which technical skills
 are most aligned with high-income 
 opportunities rather than just extreme 
 outliers.
*/


WITH ranked_jobs AS (
    SELECT
        job_id,
        company_id,
        job_title_short,
        salary_year_avg,
        COALESCE(job_location, 'Not Disclosed') AS location,
        job_schedule_type,
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
WHERE salary_quartile = 1
ORDER BY job_title_short, salary_year_avg DESC 