WITH base_jobs AS(
    SELECT
        job_id,
        company_id,
        job_title_short,
        salary_year_avg
    FROM
        job_postings_fact
    WHERE
        job_title_short IN ('Data Analyst', 'Data Scientist')
        AND salary_year_avg IS NOT NULL
),

ranked_jobs AS(
    SELECT
        *,
        ROW_NUMBER() OVER(
            PARTITION BY job_title_short
            ORDER BY salary_year_avg DESC
        ) AS salary_rank,
        NTILE(4) OVER(
            PARTITION BY job_title_short
            ORDER BY salary_year_avg DESC
        ) as salary_quartile
    FROM base_jobs 
),

top_100 AS (
    SELECT
        rj.job_title_short,
        sd.skills AS skill_name,
        COUNT(sjd.job_id) AS demand_count,
        ROUND(AVG(rj.salary_year_avg), 2) AS avg_salary,
        ROUND(
            PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY rj.salary_year_avg)::numeric,
            2
        ) AS median_salary
    FROM 
        ranked_jobs AS rj
    JOIN skills_job_dim AS sjd
        ON rj.job_id = sjd.job_id
    JOIN skills_dim  AS sd
        ON sjd.skill_id = sd.skill_id
    WHERE 
        rj.salary_rank <= 100
    GROUP BY 
        rj.job_title_short, 
        sd.skills
),

top_25 AS (
    SELECT
        rj.job_title_short,
        sd.skills AS skill_name,
        COUNT(sjd.job_id) AS demand_count,
        ROUND(AVG(rj.salary_year_avg), 2) AS avg_salary,
        ROUND(
            PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY rj.salary_year_avg)::numeric,
            2
        ) AS median_salary
    FROM ranked_jobs AS rj
    JOIN skills_job_dim AS sjd
        ON rj.job_id = sjd.job_id
    JOIN skills_dim AS sd
        ON sjd.skill_id = sd.skill_id
    WHERE 
        rj.salary_quartile = 1
    GROUP BY 
        rj.job_title_short, 
        sd.skills
),

bottom_75 AS (
    SELECT
        rj.job_title_short,
        sd.skills AS skill_name,
        COUNT(sjd.job_id) AS demand_count,
        ROUND(AVG(rj.salary_year_avg), 2) AS avg_salary,
        ROUND(
            PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY rj.salary_year_avg)::numeric,
            2
        ) AS median_salary
    FROM ranked_jobs AS rj
    JOIN skills_job_dim AS sjd
        ON rj.job_id = sjd.job_id
    JOIN skills_dim AS sd
        ON sjd.skill_id = sd.skill_id
    WHERE 
        rj.salary_quartile > 1
    GROUP BY 
        rj.job_title_short, 
        sd.skills
)

SELECT 
    *
FROM
    (
        SELECT 
            *, 
            'Top 100' AS tier 
        FROM    
            top_100
        UNION ALL
        SELECT 
            *, 
            'Top 25%' AS tier 
        FROM 
            top_25
        UNION ALL
        SELECT 
            *, 
            'Bottom 75%' AS tier 
        FROM 
        bottom_75) AS final
ORDER BY 
    CASE tier
        WHEN 'Top 100' THEN 1
        WHEN 'Top 25%' THEN 2
        WHEN 'Bottom 75%' THEN 3
    END,
    job_title_short,
    demand_count DESC;