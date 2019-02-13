/* Calling Library Training */
libname Training "/folders/myshortcuts/sharedfolder";
/* Importing file retail_analysis */
FILENAME REFFILE '/folders/myshortcuts/sharedfolder/Project 02_Ecommerce_Dataset.xlsx';

/* Importing the dataset */
PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=TRAINING.Ecommerce;
	GETNAMES=YES;
RUN;


proc sql data= Ecommerce;
	by Customer_Name;
	proc print data=Ecommerce(obs=10);
	title 'Sales by Customer';
	ID Customer_Name;
	var Order_ID Order_Date Salary;
run;

/* Creating table with the required variable */
Proc Sql;
Create table Cust_summary as
	Select Customer_Name,
	max(Order_Date) as Recency format=date9.,
	Count(*) as Frequency,
	Sum(Sales) as Monetary format=dollar12.2
	from Training.Ecommerce
	group by Customer_Name;
Quit;

/* Ranking the required variables */
Proc rank data=Work.cust_summary OUT=RFM ties=high groups=3;
	var Recency Frequency Monetary;
	Ranks R F M;
run;

/* Calculating the SUM of R,F,M */
Data RFM_Final;
	set RFM;
	R+1; F+1; M+1;
	RFM= Cats(R,F,M);
	RFM_Sum=Sum(R,F,M);
Run;

/* Sorting */
Proc Sort data= RFM_Final;
	by RFM_Sum;
run;

/* Report generation */
options linesize=80 pageno=1 nodate;

proc report data=RFM_Final nowindows;
	by RFM_Sum;
      title1 'Customer Segmentation by RFM model.'; 
run;
