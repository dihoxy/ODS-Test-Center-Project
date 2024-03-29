--+--++--+

----+--Loading Data----+--
\copy public."ods_exams"("index", "subject","section","exam_date","proctor","room_number","start_time","end_time","actual_start","actual_end","first_entered","fileUploaded","received_as_paper_copy","rescheduled","breaks_during_exams","extra_time_1.50x","extra_time_2.00x","makeup_acoommodation","noScantronExam","readerforExams","allotted_time","actual_time","exam_cancelled","no_show","requested_in_advance","name_of_day") FROM 'C:\Users\musia\DataAnalysis\Projects\ODS Test Center\ODS-Test-Center-Project-main\postgres_export_ods_v06.csv' DELIMITER ','CSV HEADER;

----+----+------+------+


----+--Creating Tables and altering tables----+--
CREATE TABLE public."ods_exams"
("index" SERIAL PRIMARY KEY, "subject" VARCHAR(10) NOT NULL,"section" VARCHAR(5) NOT NULL,"exam_date" DATE NOT NULL,
 "proctor" VARCHAR(35) NOT NULL,"room_number" VARCHAR(50) NOT NULL,"start_time" TIMESTAMP NOT NULL,
 "end_time" TIMESTAMP NOT NULL,"actual_start" TIMESTAMP NOT NULL,"actual_end" TIMESTAMP NOT NULL,"first_entered" TIMESTAMP NOT NULL,
 "fileUploaded" VARCHAR(3),"received_as_paper_copy" VARCHAR(3) NOT NULL,"rescheduled" BIGINT NOT NULL,
 "breaks_during_exams" VARCHAR(3) NOT NULL,"extra_time_1.50x" VARCHAR(3) NOT NULL,"extra_time_2.00x" VARCHAR(3) NOT NULL,
 "makeup_acoommodation" VARCHAR(3) NOT NULL,"noScantronExam" VARCHAR(3) NOT NULL,"readerforExams" VARCHAR(3) NOT NULL,
 "allotted_time" BIGINT NOT NULL,"actual_time" FLOAT,"exam_cancelled" BOOLEAN NOT NULL,"no_show" BOOLEAN NOT NULL,
 "requested_in_advance" BIGINT NOT NULL,"name_of_day" VARCHAR(10));


----Alter datatype of 'actual_time' to bigint to match datatype of 'allotted_time'
ALTER TABLE ods_exams
ALTER COLUMN actual_time
SET DATA TYPE bigint;


----Delete Test Case
DELETE FROM ods_exams
WHERE "subject" = 'TEST';

-----Add percent used column
ALTER TABLE ods_exams
ADD COLUMN percent_time_used FLOAT;
UPDATE ods_exams
SET percent_time_used = CASE
    WHEN no_show = TRUE THEN 0.0
    WHEN exam_cancelled = TRUE THEN 0.0
    ELSE ROUND(actual_time*100/ods_exams.allotted_time, 2)
    END;

--Drop 'fileUploaded' since it is largely irrelevant to the business objective
ALTER TABLE ods_exams
	DROP COLUMN "fileUploaded"

----Create a new column to store final_exam boolean indicator
ALTER TABLE ods_exams
	ADD COLUMN final_exam
UPDATE ods_exams
	SET final_exam = 'f';
ALTER TABLE ods_exams
	ALTER COLUMN final_exam SET NOT NULL;
ALTER TABLE ods_exams
	ALTER COLUMN final_exam SET DEFAULT FALSE;

----Add a new column to indicate Fall, Spring, or summer
ALTER TABLE ods_exams
    ADD COLUMN semester CHAR(5);
UPDATE ods_exams
    SET semester = CASE
        WHEN (exam_date BETWEEN '2019-05-01' AND '2019-08-03') THEN 'SU 19'
        WHEN (exam_date BETWEEN '2019-08-05' AND '2019-12-20') THEN 'FA 19'
        WHEN (exam_date BETWEEN '2020-01-01' AND '2020-03-13') THEN 'SP 20'
        WHEN (exam_date BETWEEN '2020-08-01' AND '2020-12-20') THEN 'FA 20'
        WHEN (exam_date BETWEEN '2021-01-01' AND '2021-04-30') THEN 'SP 21'
    END;






----Update final_exams to indicate final_exam status
--I use the university's registra's office final exam schedule to set the parameters
UPDATE ods_exams
	SET final_exam = CASE
		WHEN (exam_date BETWEEN '2019-08-01' AND '2019-08-03') THEN true
		WHEN (exam_date BETWEEN '2019-12-09' AND '2019-12-13-') THEN true
		WHEN (exam_date BETWEEN '2021-04-26' AND '2021-04-30') THEN true
		WHEN (exam_date = '2019-11-22' AND subject = 'GBA') THEN true --Since GBAs finals are taken before final schedule. This happened only once in the dataset
		ELSE FALSE
	END;


----+------+------+----+

----+--Creating SQL VIEWS for analysis----+--
----Time Series
--Here I join two common table expressions(CTE) to query the number of exams for each 
--date for both day and night time testing respectively
--I wonder if there is a more efficient way to do this...
--Fixed issue with nulls by using case statements to input 0 where there weren't any night exams
CREATE VIEW ods_time_series_V03 AS(
WITH nightExams AS (
	SELECT exam_date, COUNT(start_time) AS cnt_night_tests
	FROM ods_exams
	WHERE CAST(start_time AS TIME) > '16:45:00' AND no_show = FALSE AND exam_cancelled = FALSE
	GROUP BY exam_date),
dayExams AS (
	SELECT exam_date, COUNT(start_time) AS cnt_day_tests
	FROM ods_exams
	WHERE CAST(start_time AS TIME) < '16:45:00' AND no_show = FALSE AND exam_cancelled = FALSE
	GROUP BY exam_date)
SELECT dayExams.exam_date, dayExams.cnt_day_tests AS cnt_day, CASE WHEN nightExams.cnt_night_tests IS NULL THEN 0 ELSE
                                                                                        nightExams.cnt_night_tests END AS cnt_night,
       CASE WHEN (dayExams.cnt_day_tests + cnt_night_tests) IS NOT NULL THEN (dayExams.cnt_day_tests + cnt_night_tests) ELSE dayExams.cnt_day_tests
        END AS tot_num_tests
FROM dayExams
FULL OUTER JOIN nightExams
ON dayExams.exam_date = nightExams.exam_date
GROUP BY dayExams.exam_date, dayExams.cnt_day_tests, nightExams.cnt_night_tests
ORDER BY dayExams.exam_date ASC);

----Creating View of summary data for each semester
--No shows and exam_cancelled instance filtered out
--Note here that I use brackets to indicate that I am using the same query to create multiple views(i.e., fall, spring, ect)
----Time data grouping by course
CREATE VIEW subject_time_data AS(
    SELECT subject, semester, ROUND(avg(allotted_time), 2) AS avg_allottment,
           ROUND(avg(actual_time), 2) AS avg_actual_time,
       MIN(actual_time) AS min_actual_time, MAX(actual_time) AS max_actual_time
FROM ods_exams
WHERE actual_time <> 0
GROUP BY subject, semester
ORDER BY semester)

----Final Exams View
CREATE VIEW final_exam AS (
	SELECT *
	FROM ods_exams
	WHERE final_exam = TRUE
	ORDER BY exam_date);

----Regular Semester View
CREATE VIEW reg_exams AS (
	SELECT *
	FROM ods_exams
	WHERE final_exam = False
	ORDER BY exam_date);



----Creating View of percentage actual time used by date
CREATE VIEW Percent_used AS (
WITH percent_used_2_0 AS(
    SELECT a.exam_date, round(a.actual_time * 100/a.allotted_time,2)  AS percent_used
FROM ods_exams AS a
WHERE "extra_time_2.00x" = 'Yes' AND exam_cancelled = False and no_show = FALSE),

percent_used_1_5 AS(
    SELECT b.exam_date, round(b.actual_time * 100/b.allotted_time,2)  AS percent_used
FROM ods_exams AS b
WHERE "extra_time_1.50x" = 'Yes' AND exam_cancelled = False and no_show = FALSE)

SELECT ods_exams.exam_date, ROUND(avg(percent_used_1_5.percent_used),2) AS avg_percent_used_for_1_5x,
       ROUND(avg(percent_used_2_0.percent_used),2) AS avg_percent_used_for_2_0x
FROM ods_exams
JOIN percent_used_2_0 ON
ods_exams.exam_date = percent_used_2_0.exam_date
JOIN percent_used_1_5 ON
percent_used_2_0.exam_date = percent_used_1_5.exam_date
GROUP BY ods_exams.exam_date
ORDER BY ods_exams.exam_date
------------------
CREATE VIEW Percent_used_subject AS (
WITH percent_used_2_0 AS(
    SELECT a.subject, round(a.actual_time * 100/a.allotted_time,2)  AS percent_used
FROM ods_exams AS a
WHERE "extra_time_2.00x" = 'Yes' AND exam_cancelled = False and no_show = FALSE),

percent_used_1_5 AS(
    SELECT b.subject, round(b.actual_time * 100/b.allotted_time,2)  AS percent_used
FROM ods_exams AS b
WHERE "extra_time_1.50x" = 'Yes' AND exam_cancelled = False and no_show = FALSE)

SELECT ods_exams.subject, ROUND(avg(percent_used_1_5.percent_used),2) AS avg_percent_used_for_1_5x,
       ROUND(avg(percent_used_2_0.percent_used),2) AS avg_percent_used_for_2_0x
FROM ods_exams
JOIN percent_used_2_0 ON
ods_exams.subject = percent_used_2_0.subject
JOIN percent_used_1_5 ON
percent_used_2_0.subject = percent_used_1_5.subject
GROUP BY ods_exams.subject
ORDER BY ods_exams.subject)

----+------+------+------+

----+--SQL Queries----+--
----Group by date for exams that were past 4:45 p.m. and aggregate the mean for allotted and actual time
----Filter out any 0 values for actual_time

SELECT exam_date, ROUND(AVG(allotted_time), 0) AS avg_allottment, ROUND(AVG(actual_time), 0) AS avg_actual
FROM ods_exams
WHERE (CAST(start_time AS TIME) > '14:45:00') AND (actual_time <> 0) --to filter out no shows and exam cancelled
GROUP BY exam_date
ORDER BY exam_date ASC;

----Average amount of time used per subject
--Plan on joining this with "ods_time_series" view
SELECT subject, ROUND(AVG((actual_time)) AS avg_time_used
FROM ods_exams
GROUP BY subject
ORDER BY AVG(actual_time) DESC;

----Select Month, Day of Final Exams
--There is only data for FAll 19 exams, and Spring 21 exams in the dataset

SELECT EXTRACT (MONTH FROM exam_date) AS "month", 
		EXTRACT (DAY FROM exam_date) AS "day"
FROM ods_exams
WHERE (EXTRACT (MONTH FROM exam_date) = 12 --Fall '19 Finals Month
	   AND EXTRACT (DAY FROM exam_date) >= 9) --Fall '19 Finals Day
	   OR (EXTRACT (MONTH FROM exam_date) = 4 --Spring '21 Finals Month
		  AND EXTRACT (DAY FROM exam_date) >= 26) --Spring '21 Finals Day




----Summary data for regular semester exams grouped by semester
SELECT semester, COUNT(*) total_num_of_reg_exams, SUM(allotted_time) as total_allotment_minutes_for_month,
       ROUND(AVG((allotted_time),2) as avg_allotment, SUM(actual_time) as total_actual_minutes_for_month,
           ROUND(AVG(actual_time),2) as avg_actual_time
FROM ods_exams
WHERE actual_time <> 0 AND final_exam = FALSE --Filter for regular semester exams and filter out no_shows, and cancelled
GROUP BY semester

----Summary data for regular semester exams grouped by semester
SELECT semester, COUNT(*) total_num_of_reg_exams, SUM(allotted_time) as total_allotment_minutes_for_month,
           ROUND(AVG(allotted_time),2) as avg_allotment,
           SUM(actual_time) as total_actual_minutes_for_month, ROUND(AVG(actual_time),2) as avg_actual_time
FROM ods_exams
WHERE actual_time <> 0 AND final_exam = True --Filter for finals and filter out no_shows, and cancelled
GROUP BY semester


----percent change in fields across semesters
SELECT sp_20.month, sp_20.total_num_of_reg_exams AS sp_num_exams, sp_21.total_num_of_reg_exams AS sp_21_exams,
       ROUND((sp_20.total_num_of_reg_exams - sp_21.total_num_of_reg_exams)::NUMERIC / sp_21.total_num_of_reg_exams, 2) *100 AS percent_change
---add in differences between allottment and time columns
FROM sp_20
JOIN sp_21 ON
sp_20.month = sp_21.month

