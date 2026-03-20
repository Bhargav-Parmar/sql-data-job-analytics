/*What skills are associated with the 
Bottom 75% salary segment for Data Analyst 
and Data Scientist roles?

- Segment jobs into salary quartiles using 
  NTILE(4)
- Exclude the highest salary quartile 
  (Top 25%)
- Focus on the remaining 75% of roles to 
  represent the broader, non-premium job
  market
- Calculate demand_count, average salary, 
  and median salary per skill within this 
  segment
- Why? To understand which skills dominate 
  the mainstream market and how 
  compensation behaves outside the premium 
  compensation tier.
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
    ROUND(AVG(rj.salary_year_avg), 2) AS avg_salary,
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
    rj.salary_quartile > 1
GROUP BY 
    rj.job_title_short,
    skill_name
ORDER BY
    rj.job_title_short,
    demand_count DESC
