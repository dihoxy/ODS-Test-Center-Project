\copy public."Regular_Semester_Exams"("index", "subject","section","exam_date","proctor","room_number","start_time","end_time","actual_start","actual_end","first_entered","fileUploaded","received_as_paper_copy","rescheduled","breaks_during_exams","extra_time_1.50x","extra_time_2.00x","makeup_acoommodation","noScantronExam","readerforExams","allotted_time","actual_time","exam_cancelled","no_show","days_requested_submitted_in_advance","name_of_day") FROM 'C:\Users\musia\OneDrive\Desktop\ods_export_to_postgres.csv' DELIMITER ','CSV HEADER;
	