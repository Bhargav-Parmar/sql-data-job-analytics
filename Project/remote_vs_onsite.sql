/*/* 
Remote vs Onsite Salary Comparison

This query compares Remote and Onsite 
roles across key statistical measures to 
understand compensation differences 
between work types.

Metrics included:
- job_count: number of job postings in 
  each category (sample size context)
- avg_salary: mean annual salary
- salary_stddev: variability of salaries 
  within the group
- median_salary: 50th percentile 
  (robust central tendency measure)

Since this query operates on 
cleaned_geo_jobs (one row per job) and does
not involve joins, there is no risk of row 
duplication or aggregation bias from 
many-to-many relationships.
*/

*/

SELECT
    job_type,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_year_avg), 2) AS avg_salary,
    ROUND(STDDEV(salary_year_avg), 2) AS salary_stddev,
    ROUND(PERCENTILE_CONT(0.5)
        WITHIN GROUP(ORDER BY
                        salary_year_avg)::numeric, 2) AS median_salary
FROM
    cleaned_geo_jobs
GROUP BY
    job_type



