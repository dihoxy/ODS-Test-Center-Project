# Test-Center-Analysis

## Cleaning and Analyzing Test Center Data for the Office of Disability Services. 

Confidential information (i.e. CWID, Student name, Instructor name, and CRN) have been removed, and files (i.e. csv, pickled docs, workbooks) uploaded here will not contain that information. Certain information has been altered as well.

-In the first workbook, I read in the data from a csv file and begin to clean and process the data from Fall 2020. The only lib I am using is pandas. We remove needless columns, protected information, and correct the dtypes of the columns. This was particulary trick with the datetime columns. Thankfully pandas makes datetime conversion a breeze

-In the second workbook, we do more cleaning, but here we begin to explore the data a bit further using histograms, aggregate functions, and exploring basic statistics, such mean, median, mode, quartiles, standard deviation, etc.

06/11/2021
----

-Began working on basic viz, and other datasets. Using previous notebook to clean the dataset

----
06/14/2021
----
-Cleaned and combined datasets from FA19, SP20, FA20, SP21

-Basic summary analysis of the combined dataset
----
*06/29/2021 - Stakeholder meeting with ODS director clairified some questions about the data: For instances where student went over time limit, we should fix the time to match that of the allotted time. Director is not concerned with the number of students going over allotted time. Director would also like to see how normal semester data compares with that of finals. We should create a new dataframe for final exams. Outliers should be discarded in allotted and actual exam times, unless it has the time has been confirmed to be correct. A good example of this are for GBA Finals, which can get up to 480 mins (well outside the limits).* 

*ODS Director would like to see a comparison between nighttime testing data, and daytime testing data, particulary volume of requests, the timeframes and the days of the week to examine student worker staffing policy for the upcoming fall semester. She would also like to examine correlations between no-shows, exam times, and actual exam times with that of the course for the exam.*

----

