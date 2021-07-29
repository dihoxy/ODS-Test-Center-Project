***The main purpose of this project is to practice, and demonstrate knowledge of data cleaning, working with stakeholders to achieve a business objective, and data analytics***

## *Scope Overview*

1. Stakeholder wants to see trends in nighttime and daytime testing in respect to volume
2. Stakeholder wants to examine trends in subject and any correlation for the amount of time used on the exam
3. Stakeholder is seeking recommendations in staffing for student-workers


## *Limitations of the Data*

*While the data covers multiple semesters, it is important to understand that this data is limited by several factors*

1. Summer 2019 was the first semester that the ODS portal was used but transitioning from an older system
2. COVID 19 - Half of the semester for Spring '20 was cancelled due to the pandemic; no exams for Summer '20; UA operated at reduced capacity for both Fall '20 and Spring '21 semesters
3. There is only one semester that contains relevant final exam data; this is due to Covid-19 and university restrictions at the time.
4. Online Exams are no longer being administered as of Fall 20 at ODS
5. Indicators (i.e., student, instructor, course number) that might reveal additional insights are protected information and cannot be used in the analysis
6. The check-in and check-out process is not automated. There will be instances where the student was simply marked as completed (i.e., no 'actual_time' recorded), not checked-in/out properly, etc. 

## *Dealing with the Limitations*

1. There might not be enough data to evaluate semester to semester data, but there is enough data to evaluate trends in week-to-week data, or evening vs. day time testing, which is an objective that our stakeholder has indicated. It is a matter of putting the data in the right context
2. The scripts used in this project can be used to load in new, more complete data as UA returns to full operations
3. ShareDrive should eventually give us access to more data from previous semesters once access is granted
4. When dealing with the anomalies, it's important to identify those exams in which data might be imputed. Since some of the data used to do this is protected, this process may not be reflected in this project. I will do my best to detail my thought process that went into deciding when something should be imputed or dropped

## *Constraints*

1. '*actual_time*' values should not be zero. *Instances of this are most likely due to testing coordinator error when processing the exam in the portal*. There should be a value greater than zero or null. All else will be removed from the dataset
2. '*actual_times*' that go over the '*allotted_time*' by more than 10 mins should be dropped. *It is likely that the testing coordinator forgot to check the student out of the portal and since there is no way of knowing how long they actually took, the data can't be relied*
3. '*actual_times*' that exceeded the '*allotted_times*' but by not more than 10 mins should be replaced by the allotted time. The '*actual_end*' should also relfect the correct time. *This is the stakeholder's preference. We are not concerned with the rate at which student's go over their allotted time, nor are we concerned with ODS process*
4. Outliers should be removed unless they can be verified
5. Night-Time testing is considered any exams that start after 16:45
6. Final and regular semester exams should be seperated considering the unique circumstances that ODS sees with final exams (in seperate Views within Postgres)
8. We should not include data from Spring 20 semester that resulted in an exam scheduled but cancelled due to covid in Spring 2020

## *Notes*

1. When the allotted_time *cannot be verified*, it means that the instructor did not specifiy it in the ods portal. When we went to verify times for allotted_time outliers, we tried to either use the time specified on the agreement, impute with another exam in the same subject, infer based off a similiar subject, or we dropped the exam due to lack of information
2. Null values in 'actual_time' correspond to an exam that was cancelled or the student did not show. I plan on creating views in PostgreSQL without these records to give the stakeholder a clearer view of testing activity without these rows.
4. I originally planned on creating two seperate dataframes that seperates final exams from regular exams, but I am now thinking that is probably more efficient to keep it as one dataframe and create seperate views for final exams and regular exams in PostgreSQL. I will remove obvious outliers (i.e., the exams with 5070 minute allottments) in Jupyter, then process the remaining outliers in PostgreSQL. By using Views, we can keep the orginally dataset (sans extreme and obvious outliers) intact. That way, should the stakeholder want to analyze data not contained within the original scope, we can still access that data.

## Changelog
*07/20/2021*
1. In 'Handling Outliers' notebook - Accessed and set values with zero *actual_time* to *start_time*
2. Dropped indices 1001, 2896, 9314 because their check-out came before their *start_time* and *end_time* (likely due to TC error)
3. Noticed about 120 rows where the times don't make sense. Like I stated above, this is likely due to testing coordinator error (checking the student and out at check in); however, because some exams are only as little as 8 mins in length, we need to be careful which exams we drop. I believe setting threshold is the appropriate course of action
***
*07/21/2021*
1. In 'Handling Ouliers' researched and replaced 4 values (at indices: 3279, 4172, 7229, 8854) with correct values from the ODS portal; dropped 7237 because it had no reference in the portal
2. Dropped 1668 instances of scheduled exams that never took place due to the onset of COVID-19
3. Expanded scope of the filter in 'Handling outliers' to include all exams under 8 minutes. Used a groupby object to compare actual_times to that of aggregated averages of times in the same subject/section. Dropped necessary rows (**Note this fixes the issue from number 3 on 07/20/2021**)
4. Created new version of 'Handling outliers'(v02) and removed v01
5. Discovered 80 rows where there no recorded 'actual_time' and the instance was not a no show and not cancelled. ***These need to be dropped***
***
*07/22/2021*
1. Rows where actual_time was null and exam was not a no_show, and not cancelled were dropped (80 rows)
2. Converted dytpes of columns to appropriate dtypes
3. Filled all actual_time nulls with 0
4. Converted actual_time column to 'int64'

***
07/24/2021
1. Created PostgreSQL View for time series data, grouping by date and aggregating the sums for day and night exams
***
07/27/2021
1. Created Views for finals and regular exams
2. Connected local server to Tableau for visualizations
***
07/29/2021
1. Started new Jupyter notebook 'ODS Project Analysis' for further analysis in Python
