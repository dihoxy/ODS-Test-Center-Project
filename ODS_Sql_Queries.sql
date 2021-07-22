--Loading CSV With '/copy'
\copy public."ods_exams"("index", "subject","section","exam_date","proctor","room_number","start_time","end_time","actual_start","actual_end","first_entered","fileUploaded","received_as_paper_copy","rescheduled","breaks_during_exams","extra_time_1.50x","extra_time_2.00x","makeup_acoommodation","noScantronExam","readerforExams","allotted_time","actual_time","exam_cancelled","no_show","requested_in_advance","name_of_day") FROM 'C:\Users\amvanslambrouck.UA-NET\Desktop\ODS Project\ODS-Test-Center-Project-main\postgres_export_ods_v05.csv' DELIMITER ','CSV HEADER;



----Creating Tables and altering tables
CREATE TABLE public."ods_exams"
("index" BIGINT PRIMARY KEY, "subject" VARCHAR(10) NOT NULL,"section" varchar(5) NOT NULL,"exam_date" DATE NOT NULL,
 "proctor" VARCHAR(35) NOT NULL,"room_number" VARCHAR(50) NOT NULL,"start_time" TIMESTAMP NOT NULL,
 "end_time" TIMESTAMP NOT NULL,"actual_start" TIMESTAMP NOT NULL,"actual_end" TIMESTAMP NOT NULL,"first_entered" TIMESTAMP NOT NULL,
 "fileUploaded" BOOLEAN NOT NULL,"received_as_paper_copy" BOOLEAN NOT NULL,"rescheduled" BIGINT NOT NULL,
 "breaks_during_exams" BOOLEAN NOT NULL,"extra_time_1.50x" BOOLEAN NOT NULL,"extra_time_2.00x" BOOLEAN NOT NULL,
 "makeup_acoommodation" BOOLEAN NOT NULL,"noScantronExam" BOOLEAN NOT NULL,"readerforExams" BOOLEAN NOT NULL,
 "allotted_time" BIGINT NOT NULL,"actual_time" FLOAT,"exam_cancelled" BOOLEAN NOT NULL,"no_show" BOOLEAN NOT NULL,
 "requested_in_advance" BIGINT NOT NULL,"name_of_day" VARCHAR(10));


--Alter datatype of 'actual_time' to bigint to match datatype of 'allotted_time'
ALTER TABLE 
	ods_exams
ALTER COLUMN 
	actual_time
SET DATA TYPE 
	bigint;


--Delete Test Case
DELETE FROM 
	ods_exams
WHERE 
	"subject" = 'TEST';



----SQL Queries


--Group by date for exams that were past 4:45 p.m. and aggregate the mean for allotted and actual time
--Filter out any 0 values for actual_time
SELECT 
	exam_date, round(avg(allotted_time), 0) AS avg_allottment, round(avg(actual_time), 0) AS avg_actual
FROM 
	ods_exams
WHERE 
	(CAST(start_time AS TIME) > '14:45:00') AND (actual_time <> 0)
GROUP BY 
	exam_date
ORDER BY 
	exam_date ASC;



--Average amount of time used per subject
SELECT 
	subject, round(avg(actual_time)) AS avg_time_used
FROM 
	ods_exams
GROUP BY 
	subject
ORDER BY 
	avg(actual_time) DESC;




----Creating Views to Work with Business Objective

CREATE VIEW [semester_name] AS
	SELECT "index", "subject", "section", "proctor", "first_entered" AS "first_entered_on",
		"days_requested_submitted_in_advance" AS "number_of_days_entered_in_advance",
		("exam_date" + "start_time") AS "scheduled_start", ("exam_date" + "end_time") AS "scheduled_end", 
		("exam_date" + "actual_start") AS "actual_start", ("exam_date" + "actual_end") AS "actual_end",
		"name_of_day", "allotted_time", "actual_time", "exam_cancelled", "no_show", "breaks_during_exams", 
		"extra_time_1.50x", "extra_time_2.00x", "noScantronExam", "readerforExams"
	FROM public."Regular_Semester_Exams"
		WHERE ("exam_date" > 'date_range') AND ("exam_date" < 'date_range');


--Percentage of courses that were past 4:45 p.m. during Fall 2019
--I had to cast the result as a numeric and then round it to the nearest 2 places. Must be done with numeric data type. Can't be done
--with float
--Syntax shorthand: "select the number of exams, the count of all that meets the 'where' expression and then select the count of every item in the VIEW
--and round the resulting percentage to two places. Group by the course, and order by the count of subjects that meet the 'where'
--condition"
SELECT "subject", count("index") AS number_of_exams, round(count(*)*100/(SELECT count(*) FROM public."fall_19_regular")::numeric, 2)
	AS "% of total_exams"
FROM public."fall_19_regular" 
WHERE "scheduled_start"::time > '16:45'::time
GROUP BY "subject"
ORDER BY count("index") DESC;
