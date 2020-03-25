/*Question 1: *From the NhrAbstracts dataset, you will have to create a new dataset which 
contains only unique admissions (hraEncWID) with admit dates (hraAdmDtm) between January 1st, 2003 
 and December 31st, 2004: this is your spine dataset.*/

libname classdat"/folders/myfolders/class_data";

/*Step1: create a new dataset called diabetes_admissions from the nhrabstracts files between year 
January 1st, 2003 to December 31st, 2004*/
data classdat.diabetes_admissions;
	set classdat.nhrabstracts;
	if 2003 <= year(datepart(hraAdmDtm)) <= 2004 then output;
	keep hraEncWID hraAdmDtm;
	run;

/*Step2: make sure there are no duplicates in the encounter id*/
Proc sort data = classdat.diabetes_admissions out=classdat.unique nodupkey;
	By hraEncWid;
	run;

	
Question 2 /* From the NhrDiagnosis table you will need to determine if one or more diagnosis codes
(hdgcd) for diabetes (ICD9 starting with ‘250’ or ICD10 starting with ‘E11’ or ‘E10’) was 
present for each encounter  in the diagnosis table and create an indicator variable 
called DM (=0 for no diabetes codes, =1 for one or more diabetes codes). 


/*create a dataset with a flag from the diabetes diagnosis*/
data classdat.Q2;
	set classdat.nhrdiagnosis;
 	if hdgcd in:('250' 'E11' 'E10') then DM=1;
	else DM=0;
	run;
/*diabetes flag*/

/*make sure diagnosis table sorted by encwid*/
Proc sort data=classdat.nhrdiagnosis out=classdat.Q2;
	by hdghraencwid;
	run;


/*Question 3: You will need to flatten your diabetes diagnoses dataset with respect to 
encounter ID (hdgHraEncWID).*/


	
Proc means data=classdat.Q2 noprint;
	class hdghraencwid;
	types hdghraencwid;
	var DM;
	Output out=classdat.counts max(DM)=DM n(DM)=count sum(DM)=DM_count;
	run;

Proc sort data=classdat.count out=classdat.Q3 nodupkey;
	by hdghraencwid;
	run;
	
/*Question 4: You will need to link the spine dataset you generated from NhrAbstracts and the 
flattened diabetes diagnoses dataset you generated based on the NhrDiagnosis table 
using the encounter id’s  from each database (renaming as required).*/

/*creating a new dataset with the two files linked with patient id*/
data classdat.final;
	merge classdat.unique:(in=a) classdat.Q3:(in=b rename=(hdghraencwid=hraEncWID));
	by hraEncWID;
	if a;
	if DM=. then DM=0;
	if count=. then count=0;
	if dm_count=. then dm_count=0;
	run;


/*Question 5: Your final dataset should have the same # of observations (and include all encounter IDs) found in your the spine dataset and have an indicator variable, 
DM which is 1 if any diabetes code was present, and 0 otherwise.*/

proc freq data=classdat.final;
	tables DM count dm_count;
	run;

Frequecny tables: 

DM	Frequency	Percent	Cumulative  Cumulative
                        Frequency	Percent

0	2147		96.28	2147		96.28
1	83	    	3.72	2230		100.00



count	Frequency	Percent	Cumulative  Cumulative
                        	Frequency	Percent

0		249			11.17	249			11.17
1		588			26.37	837			37.53
2		392			17.58	1229		55.11
3		287			12.87	1516		67.98
4		236			10.58	1752		78.57
5		156			7.00	1908		85.56
6		107			4.80	2015		90.36
7		67			3.00	2082		93.36
8		39			1.75	2121		95.11
9		33			1.48	2154		96.59
10		22			0.99	2176		97.58
11		13			0.58	2189		98.16
12		15			0.67	2204		98.83
13		8			0.36	2212		99.19
14		3			0.13	2215		99.33
15		3			0.13	2218		99.46
16		1			0.04	2219		99.51
17		2			0.09	2221		99.60
18		4			0.18	2225		99.78
19		3			0.13	2228		99.91
20		1			0.04	2229		99.96
21		1			0.04	2230		100.00

count	Frequency	Percent	Cumulative  Cumulative
                        	Frequency	Percent
0		2147		96.28	2147		96.28
1		83			3.72	2230		100.00







