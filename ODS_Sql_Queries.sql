--Loading CSV With '/copy'
\copy public."Final_Exams"("index", "subject","section","exam_date","proctor","room_number","start_time","end_time","actual_start","actual_end","first_entered","fileUploaded","received_as_paper_copy","rescheduled","breaks_during_exams","extra_time_1.50x","extra_time_2.00x","makeup_acoommodation","noScantronExam","readerforExams","allotted_time","actual_time","exam_cancelled","no_show","days_requested_submitted_in_advance","name_of_day") FROM 'C:\Users\musia\DataAnalysis\Projects\ODS Test Center\Test-Center-Analysis-main\ODS-Test-Center-Project-main\ODS-Test-Center-Project-main\ODS-Test-Center-Project-main\PostgrExFinals071021.csv' DELIMITER ','CSV HEADER;

--Creating Tables
CREATE TABLE public."Final_Exams"
("index" FLOAT PRIMARY KEY, "subject" VARCHAR(10) NOT NULL,"section" FLOAT NOT NULL,"exam_date" DATE NOT NULL,
 "proctor" VARCHAR(35) NOT NULL,"room_number" VARCHAR(50) NOT NULL,"start_time" TIME NOT NULL,
 "end_time" TIME NOT NULL,"actual_start" TIME NOT NULL,"actual_end" TIME NOT NULL,"first_entered" DATE NOT NULL,
 "fileUploaded" BOOLEAN NOT NULL,"received_as_paper_copy" BOOLEAN NOT NULL,"rescheduled" FLOAT NOT NULL,
 "breaks_during_exams" BOOLEAN NOT NULL,"extra_time_1.50x" BOOLEAN NOT NULL,"extra_time_2.00x" BOOLEAN NOT NULL,
 "makeup_acoommodation" BOOLEAN NOT NULL,"noScantronExam" BOOLEAN NOT NULL,"readerforExams" BOOLEAN NOT NULL,
 "allotted_time" FLOAT NOT NULL,"actual_time" FLOAT,"exam_cancelled" BOOLEAN NOT NULL,"no_show" BOOLEAN NOT NULL,
 "days_requested_submitted_in_advance" FLOAT NOT NULL,"name_of_day" VARCHAR(10));




--SQL Queries
--Average amount of time used per subject
SELECT "subject", ROUND(AVG("actual_time")) AS "avg_time_used"
FROM public."Regular_Semester_Exams"
GROUP BY("subject")
ORDER BY count("allotted_time") DESC;

--Average Start Time and End Time for Evening Exams (Exams Past 4:45 p.m.)
SELECT "subject", count("index"), avg("start_time"), avg("end_time")
FROM public."Regular_Semester_Exams"
WHERE "start_time" > '16:45:00'
GROUP BY ("subject")
ORDER BY count("index") DESC;