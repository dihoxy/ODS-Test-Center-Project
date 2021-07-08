***The main purpose of this project is to practice, and demonstrate knowledge of data cleaning, working with stakeholders to achieve a business objective, and data analytics***

## *Scope Overview*

1. Stakeholder wants to see trends in nighttime and daytime testing in respect to volume
2. Stakeholder wants to examine trends in subject and any correlation for the amount of time used on the exam
3. Stakeholder is seeking recommendations in staffing for student-workers


## *Limitations of the Data*

*While the data covers multiple semesters, it is important to understand that this data is limited by several factors*

1. Summer 2019 was the first semester that the ODS portal was used but transitioning from an older system
2. COVID 19 - Half of the semester for Spring '20 was cancelled due to the pandemic; no exams for Summer '20; UA operated at reduced capacity for both Fall '20 and Spring '21 semesters
3. Online Exams are no longer being administered as of Fall 20 at ODS
4. Indicators (i.e., student, instructor, course number) that might reveal additional insights are protected information and cannot be used in the analysis

## *Dealing with the Limitations*

1. There might not be enough data to evaluate semester to semester data, but there is enough data to evaluate trends in week-to-week data, or evening vs. day time testing, which is an objective that our stakeholder has indicated. It is a matter of putting the data in the right context
2. The scripts used in this project can be used to load in new, more complete data as UA returns to full operations

## *Constraints*

1. '*actual_time*' values should not be zero. *Instances of this are most likely due to testing coordinator error when processing the exam in the portal*
2. '*actual_times*' that go over the '*allotted_time*' by more than 5% should be dropped. *It is likely that the testing coordinator forgot to check the student out of the portal and since there is no way of knowing how long they actually took, the data can't be relied*
3. '*actual_times*' that exceeded the '*allotted_times*' but by not more than 5% should be replaced by the actual time. The '*actual_end*' should also relfect the correct time. *This is the stakeholder's preference. We are not concerned with the rate at which student's go over their allotted time, nor are we concerned with ODS process*
4. Outliers should be removed unless they can be verified
5. Night-Time testing is considered any exams that start after 16:45
6. Final and regular semester exams should be seperated considering the unique circumstances that ODS sees with final exams
7. We should not include data from Spring 20 semester that resulted in an exam scheduled but cancelled due to covid

## *Notes*

When the allotted_time *cannot be verified*, it means that the instructor did not specifiy it in the ods portal. When we went to verify times for allotted_time outliers, we tried to either use the time specified on the agreement, impute with another exam in the same subject, infer based off a similiar subject, or we dropped the exam due to lack of information
