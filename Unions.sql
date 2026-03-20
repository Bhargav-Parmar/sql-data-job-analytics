SELECT
    job_title_short,
    company_id,
    job_location
FROM 
    jan_jobs

UNION -- Union removes duplicates--

SELECT
    job_title_short,
    company_id,
    job_location
FROM 
    feb_jobs

--UNION ALL doesn't remove dupliactes--