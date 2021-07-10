--Load into PostgreSQL
\copy public."Regular_Semester_Exams"("index", "subject","section","exam_date","proctor","room_number","start_time","end_time",
                                      "actual_start","actual_end","first_entered","fileUploaded","received_as_paper_copy",
                                      "rescheduled","breaks_during_exams","extra_time_1.50x","extra_time_2.00x","makeup_acoommodation",
                                      "noScantronExam","readerforExams","allotted_time","actual_time","exam_cancelled","no_show",
                                      "days_requested_submitted_in_advance","name_of_day") 
                                      FROM '?' 
                                      DELIMITER ','CSV HEADER;
	




--SQL Queries

--Average amount of time used per subject
SELECT "subject", ROUND(AVG("actual_time")) AS "avg_time_used"
FROM public."Regular_Semester_Exams"
GROUP BY("subject")
ORDER BY count("allotted_time") DESC;
