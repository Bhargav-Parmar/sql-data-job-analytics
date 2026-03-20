CREATE OR REPLACE VIEW cleaned_geo_jobs AS

WITH extracted_location AS (
    SELECT
        job_id,
        company_id,
        job_title_short,
        salary_year_avg,
        job_work_from_home,
        job_schedule_type,
        TRIM(
            SPLIT_PART(
                job_location,
                ',',
                ARRAY_LENGTH(STRING_TO_ARRAY(job_location, ','), 1)
            )
        ) AS raw_country
    FROM job_postings_fact
    WHERE
        job_title_short IN ('Data Analyst', 'Data Scientist')
        AND salary_year_avg IS NOT NULL
),

cleaned_location AS (
    SELECT
        job_id,
        company_id,
        job_title_short,
        salary_year_avg,
        job_work_from_home,
        job_schedule_type,
        TRIM(
            SPLIT_PART(raw_country, '(', 1)
        ) AS cleaned_country
    FROM extracted_location
)

SELECT
    job_id,
    company_id,
    job_title_short,
    salary_year_avg,

    CASE
        WHEN job_work_from_home = TRUE THEN 'Remote'
        ELSE 'Onsite'
    END AS job_type,

    CASE
        WHEN job_work_from_home = TRUE THEN NULL
        WHEN cleaned_country IN (
            -- 2-letter US state codes
            'AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA',
            'HI','ID','IL','IN','IA','KS','KY','LA','ME','MD',
            'MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ',
            'NM','NY','NC','ND','OH','OK','OR','PA','RI','SC',
            'SD','TN','TX','UT','VT','VA','WA','WV','WI','WY','DC',

            -- Full US state names
            'Alabama','Alaska','Arizona','Arkansas','California',
            'Colorado','Connecticut','Delaware','Florida','Georgia',
            'Hawaii','Idaho','Illinois','Indiana','Iowa','Kansas',
            'Kentucky','Louisiana','Maine','Maryland','Massachusetts',
            'Michigan','Minnesota','Mississippi','Missouri','Montana',
            'Nebraska','Nevada','New Hampshire','New Jersey','New Mexico',
            'New York','North Carolina','North Dakota','Ohio','Oklahoma',
            'Oregon','Pennsylvania','Rhode Island','South Carolina',
            'South Dakota','Tennessee','Texas','Utah','Vermont',
            'Virginia','Washington','West Virginia','Wisconsin','Wyoming'
        )
        THEN 'United States'
        ELSE cleaned_country
    END AS normalized_country,

    job_schedule_type

FROM cleaned_location;

/*
Checks to see if view is working

SELECT COUNT(*) FROM cleaned_geo_jobs

SELECT job_type, COUNT(*) FROM
cleaned_geo_jobs GROUP BY job_type

SELECT normalized_country, COUNT(*)
FROM cleaned_geo_jobs
WHERE job_type = 'Onsite'
GROUP BY normalized_country
ORDER BY COUNT(*) DESC
LIMIT 5;

SELECT DISTINCT job_location
FROM job_postings_fact
WHERE job_id IN (
    SELECT job_id
    FROM cleaned_geo_jobs
    WHERE job_type = 'Onsite'
    AND normalized_country IS NULL
);
*/