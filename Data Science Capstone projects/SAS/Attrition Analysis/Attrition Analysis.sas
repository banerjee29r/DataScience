FILENAME REFFILE '/folders/myshortcuts/sharedfolder/Project 03_Attrition Analysis_Datasets.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=training.Attrition_Analysis;
	GETNAMES=YES;
RUN;

proc freq data = Training.Attrition_Analysis;
table Retain_Indicator*Relocation_Indicator/out= temp plots = freqplot;
run;

/* In this case, the percentage of employee who has left the organization due to relocation 
as reason is 50% and the percentage of employee who left the organization but not because 
of relocation is 62%. From this result we can say that the relocation is not the reason for churn. */

proc freq data = Training.Attrition_Analysis;
table Retain_Indicator*Marital_status/out= temp plots = freqplot;
run;

/* Here, the percentage of employee who has left the organization but married is 62.07% 
and the percentage of employee who was unmarried and left is 47.62%. From this result 
we can say that the being married can be the factor for churn. */

proc freq data = Training.Attrition_Analysis;
table Retain_Indicator*Sex_Indicator/out= temp plots = freqplot;
run;

/* In this case, the percentage of employees who has left the organization and is male is 50.0%
and the percentage of employee who is female and left is 60.71%. From this result we can say that 
the females are more likely to churn. */

proc logistic data = Training.Attrition_Analysis;
class Marital_status(ref ='0' param=ref) Sex_Indicator(ref ='1' param=ref) Relocation_Indicator(ref ='0' param=ref) ;
model Retain_Indicator(event = '1') = Marital_status Sex_Indicator Relocation_Indicator/link=logit;
output out = _PredictedRetain_Indicator p=_ProbOfRetain_Indicator;
run;

/* The minimum probability of churn is 0.3605888973 maximum is 0.7234641537. 
Based on different probabilities value the cut off value I have taken as 0.52. */

data Final_attrition;
set _PredictedRetain_Indicator;
if _ProbOfRetain_Indicator > 0.52 then churn = "yes";
else churn = "No";
run;

/* Checking Accuracy */
proc freq data = Final_attrition;
table Retain_Indicator*churn/out= temp plots = freqplot;
run;

/* Accuracy of model is around 64% in predicting correct. Need improvement in the model. */

DATA FINAL_RESULT;
SET final_attrition(DROP=F G H I J K L _LEVEL_);
RUN;

Proc Print
data=fINal_result;
RUN;
