----+--Loading Data----+--
\copy public."ods_exams"("index", "subject","section","exam_date",
			 "proctor","room_number","start_time",
			 "end_time","actual_start","actual_end",
			 "first_entered","fileUploaded",
			 "received_as_paper_copy","rescheduled",
			 "breaks_during_exams","extra_time_1.50x",
			 "extra_time_2.00x","makeup_acoommodation","noScantronExam",
			 "readerforExams","allotted_time","actual_time","exam_cancelled",
			 "no_show","requested_in_advance","name_of_day") 
			 FROM 'C:\Users\musia\DataAnalysis\Projects\ODS Test Center\ODS-Test-Center-Project-main\postgres_export_ods_v05.csv' 
			 DELIMITER ','CSV HEADER;

----+----+------+------+


----+--Creating Tables and altering tables----+--
CREATE TABLE public."ods_exams"
("index" SERIAL PRIMARY KEY, "subject" VARCHAR(10) NOT NULL,"section" varchar(5) NOT NULL,"exam_date" DATE NOT NULL,
 "proctor" VARCHAR(35) NOT NULL,"room_number" VARCHAR(50) NOT NULL,"start_time" TIMESTAMP NOT NULL,
 "end_time" TIMESTAMP NOT NULL,"actual_start" TIMESTAMP NOT NULL,"actual_end" TIMESTAMP NOT NULL,"first_entered" TIMESTAMP NOT NULL,
 "fileUploaded" BOOLEAN NOT NULL,"received_as_paper_copy" BOOLEAN NOT NULL,"rescheduled" BIGINT NOT NULL,
 "breaks_during_exams" BOOLEAN NOT NULL,"extra_time_1.50x" BOOLEAN NOT NULL,"extra_time_2.00x" BOOLEAN NOT NULL,
 "makeup_acoommodation" BOOLEAN NOT NULL,"noScantronExam" BOOLEAN NOT NULL,"readerforExams" BOOLEAN NOT NULL,
 "allotted_time" BIGINT NOT NULL,"actual_time" FLOAT,"exam_cancelled" BOOLEAN NOT NULL,"no_show" BOOLEAN NOT NULL,
 "requested_in_advance" BIGINT NOT NULL,"name_of_day" VARCHAR(10));


----Alter datatype of 'actual_time' to bigint to match datatype of 'allotted_time'
ALTER TABLE ods_exams
ALTER COLUMN actual_time
SET DATA TYPE bigint;


----Delete Test Case
DELETE FROM ods_exams
WHERE "subject" = 'TEST';

----+------+------+----+

----+--Creating SQL VIEWS for analysis----+--
----Time Series
--Here I join two common table expressions(CTE) to query the number of exams for each 
--date for both day and night time testing respectively

--I wonder if there is a more efficient way to do this...

CREATE VIEW ods_time_series AS(
WITH nightExams AS (
	SELECT exam_date, COUNT(start_time) AS cnt_night_tests
	FROM ods_exams
	WHERE CAST(start_time AS TIME) > '16:45:00'
	GROUP BY exam_date),
dayExams AS (
	SELECT exam_date, COUNT(start_time) AS cnt_day_tests
	FROM ods_exams
	WHERE CAST(start_time AS TIME) < '16:45:00'
	GROUP BY exam_date)	
SELECT dayExams.exam_date, dayExams.cnt_day_tests, nightExams.cnt_night_tests,
	(dayExams.cnt_day_tests + nightExams.cnt_night_tests) AS tot_num_tests
FROM dayExams
INNER JOIN nightExams 
ON dayExams.exam_date = nightExams.exam_date
GROUP BY dayExams.exam_date, dayExams.cnt_day_tests, nightExams.cnt_night_tests
ORDER BY dayExams.exam_date ASC);


----+------+------+------+

----+--SQL Queries----+--
----Group by date for exams that were past 4:45 p.m. and aggregate the mean for allotted and actual time
----Filter out any 0 values for actual_time

SELECT exam_date, round(avg(allotted_time), 0) AS avg_allottment, round(avg(actual_time), 0) AS avg_actual
FROM ods_exams
WHERE (CAST(start_time AS TIME) > '14:45:00') AND (actual_time <> 0) --to filter out no shows and exam cancelled
GROUP BY exam_date
ORDER BY exam_date ASC;

----Average amount of time used per subject
--Plan on joining this with "ods_time_series" view
SELECT subject, round(avg(actual_time)) AS avg_time_used
FROM ods_exams
GROUP BY subject
ORDER BY avg(actual_time) DESC;

----Select Month, Day of Final Exams
--There is only data for FAll 19 exams, and Spring 21 exams in the dataset
SELECT EXTRACT (MONTH FROM exam_date) AS "month", 
		EXTRACT (DAY FROM exam_date) AS "day"
FROM ods_exams
WHERE (EXTRACT (MONTH FROM exam_date) = 12 --Fall '19 Finals Month
	   AND EXTRACT (DAY FROM exam_date) >= 9) --Fall '19 Finals Day
	   OR (EXTRACT (MONTH FROM exam_date) = 4 --Spring '21 Finals Month
		  AND EXTRACT (DAY FROM exam_date) >= 26) --Spring '21 Finals Day

----Select the percentage mins each instance took of the total number of minutes for that day

SELECT exam_date,
actual_time,
sum(actual_time) OVER (PARTITION BY exam_date) AS num_act_tot_exam_mins_per_day,
actual_time*100/sum(actual_time::FLOAT) OVER (PARTITION BY exam_date) AS percent_total_act_mins_day
FROM ods_exams
WHERE actual_time <>0; --Filters out no shows




