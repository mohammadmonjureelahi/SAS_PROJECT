libname MMEELAHI "C:\Users\ruzdomain\Desktop\SAS_Project\MMEELAHI";


/*STEP 1*/
*Let us import the first data to SAS;
PROC IMPORT OUT= MMEELAHI.TRANSACTIONI
DATAFILE="C:\Users\ruzdomain\Desktop\SAS_Project\MohammadMonjurEElahi_SAS_Project\SAS_Project_Data_And_Script\transactionhistoryforcurrentcustomers.csv"
DBMS=CSV REPLACE; *DBMS = option tells SAS the type of file to read. 4. REPLACE is used to overwrite the existing SAS dataset (If any) mentioned in the OUT = option;
GETNAMES=YES; *GETNAMES= YES tells SAS to use the first row of data as variable names. By default, PROC IMPORT uses GETNAMES= YES. If you type GETNAMES= NO, SAS would not read variable names from first row of the sheet;
GUESSINGROWS=MAX;
DATAROW=2; *2 specifies the row number in the input file for the IMPORT procedure to start reading data;
RUN;



*Let us import the 2nd dataset to SAS;
PROC IMPORT OUT= MMEELAHI.LOCATION
DATAFILE="C:\Users\ruzdomain\Desktop\SAS_Project\MohammadMonjurEElahi_SAS_Project\SAS_Project_Data_And_Script\ec90_data.csv"
DBMS=CSV REPLACE;
GETNAMES=YES;
GUESSINGROWS=MAX;
DATAROW=2;
RUN;

TITLE 'Contents of transactionhistoryforcurrentcustomers.csv';
PROC CONTENTS DATA=MMEELAHI.TRANSACTIONI;
RUN;


TITLE 'Contents of ec90_data.csv';
PROC CONTENTS DATA=MMEELAHI.LOCATION;
RUN;





*TRANSACTIONI - TRANSACTIONAL DATA SET WITH VARIOUS DIFFERENT PRODUCTS;


PROC PRINT DATA = MMEELAHI.TRANSACTIONI (OBS = 30);
TITLE "TRANSACTIONI";
RUN;

*LOCATION - DATA WITH VARIUOUS RECORD ESPECIALLY LOCATION COLUMNS LIKE Province, City, Postal Codes etc;

PROC PRINT DATA = MMEELAHI.LOCATION (OBS = 30);
TITLE "LOCATION";
RUN;



*UNDERSTAND YOUR DATA AND ITS PROPERTIES;
TITLE "Contents TRANSACTIONI";
PROC CONTENTS DATA = MMEELAHI.TRANSACTIONI;
RUN;




TITLE "Contents LOCATION";
PROC CONTENTS DATA = MMEELAHI.LOCATION;
RUN;


* Converting the price column from categorical to numerocal one;

DATA MMEELAHI.TRANSACTIONS;
   SET MMEELAHI.TRANSACTIONI(RENAME = (price=old_price)); 	
   Price = input(old_price, COMMA10.2);
   drop old_price;
   format price DOLLAR10.2;
run;


* Convert the date to Year, Month, Quarter, Week, Day;

DATA MMEELAHI.TRANSACTIOND;
SET MMEELAHI.TRANSACTIONS(RENAME = (Order_Date=old_Order_Date));
Order_Date = datepart(old_Order_Date);
DROP old_Order_Date;
format Order_Date date9.;
RUN;



PROC PRINT DATA = MMEELAHI.TRANSACTIOND (OBS = 30);
TITLE "TRANSACTIOND";
RUN;



DATA MMEELAHI.TRANSACTION;
	SET MMEELAHI.TRANSACTIOND;
 
	Year = year(Order_Date);
	Quarter = qtr(Order_Date);
	Month = month(Order_Date);
	Week = week(Order_Date);
	Day = day(Order_Date);
	Week_Day=weekday(Order_Date);
	
RUN;



PROC PRINT DATA = MMEELAHI.TRANSACTION (OBS = 10);
TITLE "TRANSACTION";
RUN;



TITLE "Contents TRANSACTION";
PROC CONTENTS DATA = MMEELAHI.TRANSACTION;
RUN;



*DUPLICATES;
*COUNT COLS;
TITLE "Count of Distinct Customer IDs in TRANSACTION";
PROC SQL;
SELECT COUNT(Customer_ID)AS TOTAL_COUNT, COUNT(DISTINCT Customer_ID) AS
UNIQUE_COUNT
FROM MMEELAHI.TRANSACTION
;
QUIT;
*REMOVE DUPLICATE OBSERVATIONS and check count again;
PROC SORT DATA = MMEELAHI.TRANSACTION OUT = MMEELAHI.TRANSACTION_S dupout=MMEELAHI.TRANSACTION_aDup NODUPRECS;
BY _ALL_;
RUN;


PROC SORT DATA = MMEELAHI.LOCATION OUT = MMEELAHI.LOCATION_S dupout=MMEELAHI.LOCATION_aDup NODUPRECS;
BY _ALL_;
RUN;



*COUNT AGAIN;
TITLE 'Count of Customer IDs TRANSACTION_S';
PROC SQL;
SELECT COUNT(Customer_ID)AS TOTAL_COUNT, COUNT(DISTINCT Customer_ID) AS
UNIQUE_COUNT
FROM MMEELAHI.TRANSACTION_S
;
QUIT;



TITLE 'Count of Customer Number LOCATION';
PROC SQL;
SELECT COUNT(Customer_Number)AS TOTAL_COUNT, COUNT(DISTINCT Customer_Number) AS
UNIQUE_COUNT
FROM MMEELAHI.LOCATION_S
;
QUIT;






*UNDERSTAND YOUR DATA AND ITS PROPERTIES;

PROC format;
 value $missfmt ' '='Missing' other='Not Missing';
 value  missfmt  . ='Missing' other='Not Missing';
run;
 
PROC freq DATA=MMEELAHI.TRANSACTION_S; 
format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
tables _CHAR_ / missing missprint nocum nopercent;
format _NUMERIC_ missfmt.;
tables _NUMERIC_ / missing missprint nocum nopercent;
run;






PROC freq DATA=MMEELAHI.LOCATION_S; 
format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
tables _CHAR_ / missing missprint nocum nopercent;
format _NUMERIC_ missfmt.;
tables _NUMERIC_ / missing missprint nocum nopercent;
run;



*checking records for quantity = 0;

title 'checking records for quantity = 0';
PROC SQL;
SELECT * FROM MMEELAHI.TRANSACTION_S
WHERE Quantity = 0;
quit;


*checking records for price = .;
title 'Missing Price Record count';
PROC SQL;
SELECT count(*) FROM MMEELAHI.TRANSACTION_S
WHERE Price = .;
quit;
PROC SQL OUTOBS=10;
SELECT * FROM MMEELAHI.TRANSACTION_S
WHERE Price = .;
quit;


DATA MMEELAHI.TRANSACTION_T;
   SET MMEELAHI.TRANSACTION_S;
   IF quantity = 0 then delete;
run;

proc print data=MMEELAHI.TRANSACTION_T (OBS = 30);
   title 'Omitting a Zero Quantity Observation';
run;



title 'checking records for quantity = 0';
PROC SQL;
SELECT * FROM MMEELAHI.TRANSACTION_T
WHERE Quantity = 0;
quit;





PROC freq DATA=MMEELAHI.TRANSACTION_T; 
format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
tables _CHAR_ / missing missprint nocum nopercent;
format _NUMERIC_ missfmt.;
tables _NUMERIC_ / missing missprint nocum nopercent;
run;



DATA MMEELAHI.TRANSACTION_U;
   SET MMEELAHI.TRANSACTION_T;
   IF Item_Description = " " then delete;
   IF Category = " " then delete;
run;

proc print data=MMEELAHI.TRANSACTION_U (OBS = 30);
   title 'Omitting Missing values';
run;



PROC freq DATA=MMEELAHI.TRANSACTION_U; 
format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
tables _CHAR_ / missing missprint nocum nopercent;
format _NUMERIC_ missfmt.;
tables _NUMERIC_ / missing missprint nocum nopercent;
run;




DATA MMEELAHI.TRANSACTION_V;
    SET MMEELAHI.TRANSACTION_U;
    Sales=Quantity*Price;
run;


proc print data=MMEELAHI.TRANSACTION_V (OBS = 50);
   title 'Transaction Dataset with calculated Column Sales';
run;



TITLE 'Count of Top Sales';
PROC SQL  outobs = 20;
SELECT Sales
FROM MMEELAHI.TRANSACTION_V
ORDER BY Sales DESC

;
QUIT;






DATA MMEELAHI.LOCATION_T;
   SET MMEELAHI.LOCATION_S;
   IF Source  = " " then delete;
run;



PROC freq DATA=MMEELAHI.LOCATION_T; 
format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
tables _CHAR_ / missing missprint nocum nopercent;
format _NUMERIC_ missfmt.;
tables _NUMERIC_ / missing missprint nocum nopercent;
run;



proc print data=MMEELAHI.LOCATION_T (OBS = 20);
   title 'Location Dataset';
run;



* Left joining transaction and location datasets;
proc sql;
create table MMEELAHI.INFERENTIAL_P as
select x.*, y.City, y.Prov, y.Postal_Code
from MMEELAHI.TRANSACTION_V x left join MMEELAHI.LOCATION_T y
on x.customer_id=y.customer_number
;
quit;


proc print data=MMEELAHI.INFERENTIAL_P (OBS = 20);
   title 'Transaction Dataset';
run;



PROC freq DATA=MMEELAHI.INFERENTIAL_P ; 
format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
tables _CHAR_ / missing missprint nocum nopercent;
format _NUMERIC_ missfmt.;
tables _NUMERIC_ / missing missprint nocum nopercent;
run;


*REMOVE DUPLICATE OBSERVATIONS and check count again;
PROC SORT DATA = MMEELAHI.INFERENTIAL_P OUT = MMEELAHI.INFERENTIAL dupout=MMEELAHI.INFERENTIAL_P_aDup NODUPRECS;
BY _ALL_;
RUN;



PROC freq DATA=MMEELAHI.INFERENTIAL ; 
format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
tables _CHAR_ / missing missprint nocum nopercent;
format _NUMERIC_ missfmt.;
tables _NUMERIC_ / missing missprint nocum nopercent;
run;


proc contents data=MMEELAHI.INFERENTIAL;
   title 'Contents of the joint Dataset';
run;




DATA MMEELAHI.INFERENTIAL;
    SET MMEELAHI.INFERENTIAL;
    DROP Item_Code Item_Description City Postal_Code;
run;


DATA MMEELAHI.INFERENTIAL_Q;
    SET MMEELAHI.INFERENTIAL;
   run;



DATA MMEELAHI.INFERENTIALQ;
SET MMEELAHI.INFERENTIALQ;
IF Month = 1 THEN Month_Q = "JAN";
ELSE IF Month = 2 THEN Month_Q = "FEB";
ELSE IF Month = 3 THEN Month_Q = "MAR";
ELSE IF Month = 4 THEN Month_Q = "APR";
ELSE IF Month = 5 THEN Month_Q = "MAY";
ELSE IF Month = 6 THEN Month_Q = "JUN";
ELSE IF Month = 7 THEN Month_Q = "JUL";
ELSE IF Month = 8 THEN Month_Q = "AUG";
ELSE IF Month = 9 THEN Month_Q = "SEP";
ELSE IF Month = 10 THEN Month_Q = "OCT";
ELSE IF Month = 11 THEN Month_Q = "NOV";
ELSE IF Month = 12 THEN Month_Q = "DEC";
PROC PRINT DATA = MMEELAHI.INFERENTIALQ ( OBS = 20);
run; 





* Converting Day of Week to String;
DATA MMEELAHI.INFERENTIALQ;
SET MMEELAHI.INFERENTIALQ;
IF Week_Day = 1 THEN Week_Day_Q = "MON";
ELSE IF Week_Day = 2 THEN Week_Day_Q = "TUE";
ELSE IF Week_Day = 3 THEN Week_Day_Q = "WED";
ELSE IF Week_Day = 4 THEN Week_Day_Q = "THU";
ELSE IF Week_Day = 5 THEN Week_Day_Q = "FRI";
ELSE IF Week_Day = 6 THEN Week_Day_Q = "SAT";
ELSE IF Week_Day = 7 THEN Week_Day_Q = "SUN";

PROC PRINT DATA = MMEELAHI.INFERENTIALQ ( OBS = 20);
run; 





DATA MMEELAHI.INFERENTIALQ;
SET MMEELAHI.INFERENTIALQ;
DROP Week_Q;
IF 1 <= DAY <= 7  THEN Day_Q = "Week01";
ELSE IF 8 <= DAY <= 14  THEN Day_Q = "Week02";
ELSE IF 15 <= DAY <= 21  THEN Day_Q = "Week03";
ELSE IF 22 <= DAY <= 31  THEN Day_Q = "Week04";

PROC PRINT DATA = MMEELAHI.INFERENTIALQ ( OBS = 20);
run; 

DATA MMEELAHI.INFERENTIALQ;
   SET MMEELAHI.INFERENTIALQ(RENAME = (Day_Q=Monthly_Week)); 	
run;

PROC PRINT DATA = MMEELAHI.INFERENTIALQ ( OBS = 20);
run; 




DATA MMEELAHI.INFERENTIALQ;
SET MMEELAHI.INFERENTIALQ;
IF Year = 2007 THEN Transaction_Year = "Y2007";
ELSE IF Year = 2008 THEN Transaction_Year = "Y2008";

PROC PRINT DATA = MMEELAHI.INFERENTIALQ ( OBS = 20);
run; 



DATA MMEELAHI.INFERENTIALQ;
SET MMEELAHI.INFERENTIALQ;
IF 1 <= Sales <= 150 THEN Sales_Q = "LOW";
ELSE IF 151 <= Sales <= 500 THEN Sales_Q = "MED";
ELSE IF Sales > 500 THEN Sales_Q = "HI";

PROC PRINT DATA = MMEELAHI.INFERENTIALQ ( OBS = 20);
run; 


*UNIVARIATE ANALYSIS;



title 'Distribution of Sales Segments';
PROC GCHART DATA = MMEELAHI.INFERENTIALQ;
vbar Sales_Q;
	
RUN;



title 'Distribution of Source';
PROC GCHART DATA = MMEELAHI.INFERENTIALQ;
vbar Source;
RUN;




title 'Distribution of Year';
PROC GCHART DATA = MMEELAHI.INFERENTIALQ;
PIE Transaction_Year;
RUN;


title 'Distribution of Year';
PROC GCHART DATA = MMEELAHI.INFERENTIALQ;
vbar Transaction_Year;
RUN;



title 'Distribution of Quarter';
PROC GCHART DATA = MMEELAHI.INFERENTIALQ;
vbar Quarter_Q;
RUN;



title 'Distribution of Month';
PROC GCHART DATA = MMEELAHI.INFERENTIALQ;
vbar Month_Q;
RUN;




title 'Distribution of Day of Week';
PROC GCHART DATA = MMEELAHI.INFERENTIALQ;
vbar Week_Day_Q;
RUN;





title 'Distribution of Week of Month';
PROC GCHART DATA = MMEELAHI.INFERENTIALQ;
vbar Monthly_Week;
RUN;


title 'Distribution of Week of Year';
PROC GCHART DATA = MMEELAHI.INFERENTIALQ;
vbar Week_P;
RUN;



title 'Distribution of Week of Year';
PROC GCHART DATA = MMEELAHI.INFERENTIALQ;
vbar Week;
RUN;



title 'Distribution of Day of Month';
PROC GCHART DATA = MMEELAHI.INFERENTIALQ;
vbar Day;
RUN;






title 'Distribution of Province';
PROC GCHART DATA = MMEELAHI.INFERENTIALQ;
vbar Prov;
RUN;




title 'Distribution of Sales';
PROC UNIVARIATE DATA = MMEELAHI.INFERENTIAL;
var Sales;
histogram/normal;
RUN;




title 'Distribution of Category';
PROC GCHART DATA = MMEELAHI.INFERENTIALQ;
vbar Category;
RUN;



title 'Distribution of Price';
PROC UNIVARIATE DATA = MMEELAHI.INFERENTIAL;
var Price;
histogram/normal;
RUN;



title 'Distribution of Quantity';
PROC UNIVARIATE DATA = MMEELAHI.INFERENTIAL;
var Quantity;
histogram/normal;
RUN;


* Hypothesis testing;


*ANOVA : ANALYSIS OF VARIANCE;
title 'Anova Testing Between Sales and Source';
PROC ANOVA DATA = MMEELAHI.INFERENTIALQ;
 CLASS Source;
 MODEL Sales = Source;
 MEANS Source/SCHEFFE;
RUN;




PROC ANOVA DATA = MMEELAHI.INFERENTIALQ;
 CLASS Category;
 MODEL Sales = Category;
 MEANS Category/SCHEFFE;
RUN;



PROC ANOVA DATA = MMEELAHI.INFERENTIALQ;
 CLASS Prov;
 MODEL Sales = Prov;
 MEANS Prov/SCHEFFE;
RUN;




PROC ANOVA DATA = MMEELAHI.INFERENTIALQ;
 CLASS Quarter_Q;
 MODEL Sales = Quarter_Q;
 MEANS Quarter_Q/SCHEFFE;
RUN;





PROC ANOVA DATA = MMEELAHI.INFERENTIALQ;
 CLASS Month_Q;
 MODEL Sales = Month_Q;
 MEANS Month_Q/SCHEFFE;
RUN;



PROC ANOVA DATA = MMEELAHI.INFERENTIALQ;
 CLASS Week_Day_Q;
 MODEL Sales = Week_Day_Q;
 MEANS Week_Day_Q/SCHEFFE;
RUN;




PROC ANOVA DATA = MMEELAHI.INFERENTIALQ;
 CLASS Monthly_Week;
 MODEL Sales = Monthly_Week;
 MEANS Monthly_Week/SCHEFFE;
RUN;


* SPEARMAN CORRELATION;

*IF YOUR DATA IS NOT NL DISTRIBUTED : SPEARMAN CORRELATION;
title 'Correlation Testing Between Sales and Price & Quantity';
PROC CORR DATA = MMEELAHI.INFERENTIAL SPEARMAN;
  VAR Price Quantity;
  WITH Sales;
RUN;

* BIVARIATE ANALYSIS;




TITLE "Total Sales per Category"; 
PROC GCHART DATA = MMEELAHI.INFERENTIALQ;
format Sales dollar20.;
pie3d Category / sumvar=Sales
VALUE = INSIDE
explode="F";
run;
quit;



TITLE "Total Sales per Category"; 
 proc sgplot data=MMEELAHI.INFERENTIALQ;
   format Sales dollar20.;
   vbar Category/response=Sales stat=sum
            categoryorder=respdesc;
run; 





TITLE "Total Quantity per Category"; 
PROC GCHART DATA = MMEELAHI.INFERENTIALQ;
pie3d Category / sumvar=Quantity
VALUE = INSIDE
explode="F";
run;
quit;




TITLE "Total Quantity per Category"; 
 proc sgplot data=MMEELAHI.INFERENTIALQ;
  vbar Category/response=Quantity stat=sum
            categoryorder=respdesc;
run; 





TITLE "Total Sales per Source"; 
PROC GCHART DATA = MMEELAHI.INFERENTIALQ;
format Sales dollar20.;
pie3d Source / sumvar=Sales
VALUE = INSIDE
explode="F";
run;
quit;




TITLE "Total Sales per Source"; 
 proc sgplot data=MMEELAHI.INFERENTIALQ;
   format Sales dollar20.;
   vbar Source/response=Sales stat=sum
            categoryorder=respdesc;
run; 




TITLE "Total Quantity per Source"; 
PROC GCHART DATA = MMEELAHI.INFERENTIALQ;
pie3d Source / sumvar=Quantity
VALUE = INSIDE
explode="F";
run;
quit;



TITLE "Total Quantity per Source"; 
 proc sgplot data=MMEELAHI.INFERENTIALQ;
   vbar Source/response=Quantity stat=sum
            categoryorder=respdesc;
run; 






TITLE "Total Sales per Province"; 
PROC GCHART DATA = MMEELAHI.INFERENTIALQ;
format Sales dollar20.;
pie3d Prov / sumvar=Sales
VALUE = INSIDE
explode="F";
run;
quit;



TITLE "Total Sales per Province"; 
 proc sgplot data=MMEELAHI.INFERENTIALQ;
   format Sales dollar20.;
   vbar Prov/response=Sales stat=sum
            categoryorder=respdesc;
run; 





TITLE "Total Quantity per Province"; 
PROC GCHART DATA = MMEELAHI.INFERENTIALQ;
pie3d Prov / sumvar=Quantity
VALUE = INSIDE
explode="F";
run;
quit;




TITLE "Total Quantity per Province"; 
 proc sgplot data=MMEELAHI.INFERENTIALQ;
   vbar Prov/response=Quantity stat=sum
            categoryorder=respdesc;
run; 


TITLE "Total Sales per Quarter"; 
PROC GCHART DATA = MMEELAHI.INFERENTIALQ;
format Sales dollar20.;
pie3d Quarter_Q / sumvar=Sales
VALUE = INSIDE
explode="F";
run;
quit;




TITLE "Total Sales per Quarter";  
 proc sgplot data=MMEELAHI.INFERENTIALQ;
   format Sales dollar20.;
   vbar Quarter_Q/response=Sales stat=sum
            categoryorder=respdesc;
run; 




TITLE "Total Quantity per Quarter"; 
PROC GCHART DATA = MMEELAHI.INFERENTIALQ;
pie3d Quarter_Q / sumvar=Quantity
VALUE = INSIDE
explode="F";
run;
quit;




TITLE "Total Quantity per Quarter"; 
 proc sgplot data=MMEELAHI.INFERENTIALQ;
   vbar Quarter_Q/response=Quantity stat=sum
            categoryorder=respdesc;
run; 




TITLE "Total Sales per Month"; 
proc gchart data=MMEELAHI.INFERENTIALQ;
 format Sales dollar20.;
 vbar Month_Q / noframe type=SUM sumvar=Sales ;
  format Month_Q ;
run; quit;



TITLE "Total Sales per Month"; 
 proc sgplot data=MMEELAHI.INFERENTIALQ;
   format Sales dollar20.;
   vbar Month_Q/response=Sales stat=sum
            categoryorder=respdesc;
run; 



TITLE "Total Quantity per Month"; 
proc gchart data=MMEELAHI.INFERENTIALQ;
 vbar Month_Q / noframe type=SUM sumvar=Quantity ;
  format Month_Q ;
run; quit;



TITLE "Total Quantity per Month";
 proc sgplot data=MMEELAHI.INFERENTIALQ;
   vbar Month_Q/response=Quantity stat=sum
            categoryorder=respdesc;
run; 



TITLE "Total Sales per Day of Week"; 
proc gchart data=MMEELAHI.INFERENTIALQ;
 format Sales dollar20.;
 vbar Week_Day_Q / noframe type=SUM sumvar=Sales ;
  
run; quit;



TITLE "Total Sales per Day of Week"; 
 proc sgplot data=MMEELAHI.INFERENTIALQ;
   format Sales dollar20.;
   vbar Week_Day_Q/response=Sales stat=sum
            categoryorder=respdesc;
run; 



TITLE "Total Quantity per Day of Week"; 
proc gchart data=MMEELAHI.INFERENTIALQ;
 vbar Week_Day_Q / noframe type=SUM sumvar=Quantity ;
  
run; quit;



TITLE "Total Quantity per Day of Week"; 
 proc sgplot data=MMEELAHI.INFERENTIALQ;
   vbar Week_Day_Q/response=Quantity stat=sum
            categoryorder=respdesc;
run; 




TITLE "Mean Sales per Week of Month"; 
proc gchart data=MMEELAHI.INFERENTIALQ;
 format Sales dollar20.;
 vbar Monthly_Week / noframe type=MEAN sumvar=Sales ;
  
run; quit;



TITLE "Mean Sales per Week of Month"; 
 proc sgplot data=MMEELAHI.INFERENTIALQ;
   format Sales dollar20.;
   vbar Monthly_Week/response=Sales stat=sum
            categoryorder=respdesc;
run; 



TITLE "Mean Quantity per Week of Month"; 
proc gchart data=MMEELAHI.INFERENTIALQ;
 vbar Monthly_Week / noframe type=MEAN sumvar=Quantity ;
  
run; quit;




TITLE "Mean Quantity per Week of Month"; 
 proc sgplot data=MMEELAHI.INFERENTIALQ;
   vbar Monthly_Week/response=Quantity stat=sum
            categoryorder=respdesc;
run; 



TITLE "Top 10 Customers Based On Sales Volume"; 
PROC SQL outobs = 10;
SELECT Customer_ID, SUM(Sales) format dollar13.2 AS Total_Per_Customer
FROM MMEELAHI.INFERENTIALQ
GROUP BY Customer_ID
ORDER BY Total_Per_Customer DESC
;
quit;




* MODEL BUILDING;


PROC STANDARD DATA = MMEELAHI.INFERENTIAL MEAN = 0 STD = 1 OUT = MMEELAHI.INFERENTIAL_MODEL;
	VAR Price Sales Quantity;
	title 'Price, Sales and Quantity are Standardized for Linear Regression';
	RUN;



PROC UNIVARIATE DATA = MMEELAHI.INFERENTIAL_MODEL NORMAL;
var Sales;
histogram/normal;
title 'Sales Standardized for Linear Regression';
RUN;



PROC UNIVARIATE DATA = MMEELAHI.INFERENTIAL_MODEL NORMAL;
var Quantity;
histogram/normal;
title 'Quantity Standardized for Linear Regression';
RUN;



PROC UNIVARIATE DATA = MMEELAHI.INFERENTIAL_MODEL NORMAL;
var Price;
histogram/normal;
title 'Price Standardized for Linear Regression';
RUN;



TITLE "Linear Regression Model"; 
ODS GRAPHICS ON;
PROC GLMSELECT DATA = MMEELAHI.INFERENTIAL_MODEL PLOTS = ALL;
	CLASS Prov Source Category;
	MODEL Sales = Quantity Price Prov Source Category / DETAILS = ALL STATS = ALL;
ODS GRAPHICS OFF;
RUN;




