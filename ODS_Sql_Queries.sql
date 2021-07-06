--SQL Queries

--Average amount of time used per subject
SELECT "subject", ROUND(AVG("actual_time")) AS "avg_time_used_per_exam"
  FROM public."Regular_Semester_Exams"
GROUP BY("subject")
ORDER BY AVG("actual_time") DESC;

--Number of no shows per subject
SELECT "subject", count("no_show") as "no show"
  FROM public."Regular_Semester_Exams"
    WHERE "no_show" = true		
GROUP BY("subject")
ORDER BY COUNT("no_show") DESC;

--Number of cancelled exams per subject
SELECT "subject", count("exam_cancelled") as "cancelled"
  FROM public."Regular_Semester_Exams"
	  WHERE "exam_cancelled" = true		
GROUP BY("subject")
ORDER BY COUNT("exam_cancelled") DESC;
