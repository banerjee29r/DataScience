/* Calling Library Training */
libname Training "/home/shangray20090/sas ashutosh/3March";
/* Importing file retail_analysis */
FILENAME REFFILE '/home/shangray20090/Project/Project 04_Retail Analysis_Dataset.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=TRAINING.Retail_Analysis;
	GETNAMES=YES;
RUN;

Title'Report of Retail Analysis Project';

/* Making the shipping cost variable according to the sas university version format by replacing space with _ */
Data training.retail_analysis (rename=('Shipping cost'n = Shipping_cost) );
set training.retail_analysis;
run;

/* Finding basic statistical values of Sales by quantity */
Proc means
data=training.retail_analysis (Drop= Order_ID);
var Sales Profit Discount Shipping_cost;
by Quantity;
run;

/* Making frequency table and plotting between quantity and sales */
Proc freq data=training.retail_analysis;
table quantity*sales quantity*profit/nocol nocum nopercent norow plots=freqplot(twoway=stacked);
run;

/* Univariate model to find some statistics of data set and also plot the normal distribution curve and check if the distribution is normal. */
Proc univariate normal plot
data=training.retail_analysis (drop= Order_ID);
histogram;
run;

/* Checking Analysis of variance to see if there is significant difference between the sales for each quantity or not */
Proc anova data=Training.retail_analysis;
class quantity;
model Sales = quantity;
run;

/* Making a data set with some more variable related to the previous variable to perform a complex model */
data training.Modified_Retail;
set training.retail_analysis;
/* Profit values */
Profit_log = log(profit);
Profit_exp = exp(profit);
Profit_sq = profit**2;
Profit_cube = profit**3;
/* Discount values */
Discount_log = log(discount);
Discount_exp = exp(discount);
Discount_sq = discount**2;
Discount_cube = discount**3;
/* shipping cost values */
Shipping_cost_log = log(Shipping_cost);
Shipping_cost_exp = exp(Shipping_cost);
Shipping_cost_sq = Shipping_cost**2;
Shipping_cost_cube = Shipping_cost**3;
run;

/* Droping unrelated ID variable */
Data training.Modified_Retail (drop= Order_ID);
set training.Modified_Retail;
run;

/* Sorting the data by quantity */
Proc sort data=training.Modified_Retail;
by quantity;
run;

/* Finding correlation */
Proc corr data=training.retail_analysis;
run;

/* Applying Multiple linear regression model with low complexity */
Proc reg data=training.Retail_analysis(drop=Order_ID);
model sales = Profit Discount Shipping_cost quantity/vif;
run;

/* Applying a complex Multiple Linear regression model and predicting sales value in a different variable with residual*/
proc reg data=training.Modified_Retail;
model sales= profit Profit_log Profit_exp Profit_sq Profit_cube Discount Discount_log Discount_exp Discount_sq Discount_cube
Shipping_cost Shipping_cost_log Shipping_cost_exp Shipping_cost_sq Shipping_cost_cube;
by Quantity;
Output out=training.Predictedsales predicted=Predicted_Sales residual=Error_in_Sales;
run;

/* Merging to bring the droped ID variable Order_ID */
Data training.Predictedsales;
merge training.retail_analysis training.Predictedsales;
run;

/* Retaining sequence of variable till Error_in_Sales*/
Data training.Predictedsales;
retain Order_ID Products Sales Predicted_Sales Error_in_Sales;
set training.Predictedsales;
run;

/* Printing the New Data set with Predicted values of sales */
Proc Print
Data=training.Predictedsales;
run;
