--SQL Queries

--Average amount of time used per subject
SELECT "subject", ROUND(AVG("actual_time")) AS "avg_time_used_per_exam"
FROM public."Regular_Semester_Exams"
GROUP BY("subject")
ORDER BY count("allotted_time") DESC;
