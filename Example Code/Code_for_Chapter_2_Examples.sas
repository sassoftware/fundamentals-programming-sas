/**
Written to accompany Fundamentals of Programming in SAS: A Case Studies Approach

This file contains all code necessary to produce every output in Chapter 2 and is
not intended for general distribution.

Before submitting the code, ensure the paths in the %LET statements are updated to
point to the locations designated.
**/

%let raw=--insert path to raw data folder (RawData fileref assignment in text)--;
%let SASdat=--insert path to SAS data folder (BookData libref assignment in text)--;
%let OutPath=--insert path for delivery of output tables and figures--;
libname BookData "&SASdat";
filename RawData "&raw";
x "cd &OutPath";
options fmtsearch=(BookData);

ods path (prepend) BookData.template;
ods path show;

options papersize=letter orientation=portrait 
        leftmargin=1.25in rightmargin=1.25in 
        topmargin=1in bottommargin=1in
        nodate nonumber ls=200;
title;
footnote;
ods exclude none;
ods listing close;
ods rtf file='Chapter 2 Tables.rtf' 
        style=customsapphire 
        ;
/**Program 2.3.1**/
title 'Output 2.3.1A: Using the CONTENTS Procedure to View Attributes';
proc contents data=bookdata.ipums2005mini;
  ods select variables;
run;

title 'Output 2.3.1B: Using the PRINT Procedure to View Data';
proc print data=bookdata.ipums2005mini(obs=5);
  var state MortgageStatus MortgagePayment HomeValue Metro;
run;

/**Program 2.3.2**/
title 'Output 2.3.2: Assigning Labels';
proc print data=bookdata.ipums2005mini(obs=5) noobs label;
  var state MortgageStatus MortgagePayment HomeValue Metro;
  label HomeValue='Value of Home ($)' state='State' MortgageStatus='Mortgage Status'
        MortgagePayment='Mortgage Payment';
run;

/**Program 2.3.3**/
title 'Output 2.3.3: Assigning Formats';
proc print data=bookdata.ipums2005mini(obs=5) noobs label;
  var state MortgageStatus MortgagePayment HomeValue Metro;
  label HomeValue='Value of Home' state='State';
  format HomeValue MortgagePayment dollar9. MortgageStatus $1.;
run;

/**Program 2.3.4**/
proc sort data=bookdata.ipums2005mini out=sorted;
  by HomeValue;
run;

title 'Output 2.3.4: Sorting Data with the SORT Procedure';
proc print data=sorted(obs=5) noobs label;
  var state MortgageStatus MortgagePayment HomeValue Metro;
  label HomeValue='Value of Home' state='State';
  format HomeValue MortgagePayment dollar9. MortgageStatus $1.;
run;

/**Program 2.3.5**/
title 'Output 2.3.5: Sorting on Mulitple Variables';
proc sort data=bookdata.ipums2005mini out=sorted;
  by MortgagePayment descending State descending HomeValue ;
run;

proc print data=sorted(obs=6) noobs label;
  var state MortgageStatus MortgagePayment HomeValue Metro;
  label HomeValue='Value of Home' state='State';
  format HomeValue MortgagePayment dollar9. MortgageStatus $1.;
run;

/**Program 2.3.6**/
title 'Output 2.3.6: BY Group Processing in PROC PRINT (First 2 of 6 Groups Shown)';
proc sort data=bookdata.ipums2005mini out=sorted;
  by MortgageStatus State descending HomeValue;
run;

proc print data=sorted noobs label;
  by MortgageStatus State;
  var MortgagePayment HomeValue Metro;
  label HomeValue='Value of Home' state='State';
  format HomeValue MortgagePayment dollar9. MortgageStatus $9.;
run;

/**Program 2.3.7**/
title 'Output 2.3.7: Using BY and ID Statements Together in PROC PRINT (First 2 of 6 Groups Shown)';
proc print data=sorted noobs label;
  by MortgageStatus State;
  id MortgageStatus State;
  var MortgagePayment HomeValue Metro;
  label HomeValue='Value of Home' state='State';
  format HomeValue MortgagePayment dollar9. MortgageStatus $9.;
run;

/**Program 2.3.8**/
title 'Output 2.3.8: Using the SUM Statement in PROC PRINT (Last of 6 Groups Shown)';
proc print data=sorted noobs label;
  by MortgageStatus State;
  id MortgageStatus State;
  var MortgagePayment HomeValue Metro;
  sum MortgagePayment HomeValue;
  label HomeValue='Value of Home' state='State';
  format HomeValue MortgagePayment dollar9. MortgageStatus $9.;
run;

/**Program 2.4.1**/
options nolabel;
title 'Output 2.4.1: PROC MEANS Without Additional Statements or Options';
proc means data=BookData.Ipums2005Basic;
run;

/**Program 2.4.2**/
title 'Output 2.4.2: Selecting Analysis Variables Using the VAR Statement in MEANS';
proc means data=BookData.Ipums2005Basic;
  var Citypop MortgagePayment HHIncome HomeValue;
run;

/**Program 2.4.3**/
title 'Output 2.4.3: Setting the Statistics to the Five-Number Summary in MEANS';
proc means data=BookData.Ipums2005Basic min q1 median q3 max;
  var Citypop MortgagePayment HHIncome HomeValue;
run;

/**Program 2.4.4**/
title 'Output 2.4.4: Using the ALPHA= Option to Modify Confidence Levels';
proc means data=BookData.Ipums2005Basic lclm mean uclm alpha=0.01;
  var Citypop MortgagePayment HHIncome HomeValue;
run;

/**Program 2.4.5**/
title 'Output 2.4.5: Using MAXDEC= to Control Precision of Results';
proc means data=BookData.Ipums2005Basic lclm mean uclm alpha=0.01 /*fw=20*/ maxdec=1;
  var Citypop MortgagePayment HHIncome HomeValue;
run;

/**Program 2.4.6**/
title 'Output 2.4.6: Setting a Class Variable in PROC MEANS';
proc means data=BookData.Ipums2005Basic;
  class MortgageStatus;
  var HHIncome ;
run;

/**Program 2.4.7**/
title 'Output 2.4.7: A Poor Choice for a Class Variable (Partial Table Shown)';
proc means data=BookData.Ipums2005Basic;
  class Serial;
  var HHIncome ;
  where serial le 5;/***where not included in book code**/
run;

/**Program 2.4.8**/
title 'Output 2.4.8A: Using Multiple Class Variables (Partial Listing)';
proc means data=BookData.Ipums2005Basic nonobs n mean std;
 class MortgageStatus Metro;
 var HHIncome ;
run;

title 'Output 2.4.8B: Effects of Order (Partial Listing)';
proc means data=BookData.Ipums2005Basic nonobs n mean std;
 class Metro MortgageStatus;
 var HHIncome ;
run;

/**Program 2.5.1**/
proc format;
  value METRO
    0 = "Not Identifiable"
    1 = "Not in Metro Area"
    2 = "Metro, Inside City"
    3 = "Metro, Outside City"
    4 = "Metro, City Status Unknown"
  ;
run;

/**Program 2.5.2**/
title 'Output 2.5.2: Using the Metro Format';
proc means data=BookData.Ipums2005Basic nonobs maxdec=0;
  class Metro;
  var HHIncome;
  format Metro Metro.;
run;

/**Program 2.5.3**/
proc format;
  value MetroB
    0 = "Not Identifiable"
    1 = "Not in Metro Area"
    2 = "In a Metro Area"
    3 = "In a Metro Area"
    4 = "In a Metro Area"
  ;
  value MetroC
    0 = "Not Identifiable"
    1 = "Not in Metro Area"
    2,3,4 = "In a Metro Area"
  ;
run;

title 'Output 2.5.3: Assigning Multiple Values to the Same Formatted Value';
proc means data=BookData.Ipums2005Basic nonobs maxdec=0;
  class Metro;
  var HHIncome;
  format Metro MetroC.;
run;

/**Program 2.5.4**/
proc format;
  value MetroD
    0 = "Not Identifiable"
    1 = "Not in Metro Area"
    2-4 = "In a Metro Area"
  ;
run;

/**Program 2.5.5**/
proc format;
  value MetroE
    0 = "Not Identifiable"
    1 = "Not in Metro Area"
    other = "In a Metro Area"
  ;
run;

/**Program 2.5.6**/
proc format;
  value Mort
    0='None'
    1-350="$350 and Below"
    351-1000="$351 to $1000"
    1001-1600="$1001 to $1600"
    1601-high="Over $1600"
  ;
  value MortB
    0='None'
    1-350="$350 and Below"
    350<-1000="Over $350, up to $1000"
    1000<-1600="Over $1000, up to $1600"
    1600<-high="Over $1600"
  ;
run;

title 'Output 2.5.6A: Binning a Quantitative Variable Using the Mort Format';
proc means data=BookData.Ipums2005Basic nonobs maxdec=0;
  class MortgagePayment;
  var HHIncome;
  format MortgagePayment Mort.;
run;

title 'Output 2.5.6B: Binning a Quantitative Variable Using the MortB Format';
proc means data=BookData.Ipums2005Basic nonobs maxdec=0;
  class MortgagePayment;
  var HHIncome;
  format MortgagePayment MortB.;
run;

/**Program 2.5.7**/
proc format library=sasuser;
  value Mort
    0='None'
    1-350="$350 and Below"
    351-1000="$351 to $1000"
    1001-1600="$1001 to $1600"
    1601-high="Over $1600"
  ;
  value MortB
    0='None'
    1-350="$350 and Below"
    350<-1000="Over $350, up to $1000"
    1000<-1600="Over $1000, up to $1600"
    1600<-high="Over $1600"
  ;
run;

title 'Output 2.5.7: Modifying Program 2.5.6 with LIBRARY= and FMTLIB Options.';
proc format fmtlib library=sasuser;
run;

/**Code following Table 2.6.2**/
/*proc means data=BookData.Ipums2005Basic nonobs maxdec=0;*/
/*  class Metro;*/
/*  var HHIncome;*/
/*  format Metro Metro.;*/
/*  where Metro eq 2 or Metro eq 3 or Metro eq 4;*/
/*  *where Metro ge 2 and Metro le 4;*/
/*  *where Metro in (2,3,4);*/
/*  *where Metro between 2 and 4;*/
/*  *where Metro not in (0,1);*/
/*run;*/

/**Program 2.6.1**/
Title 'Output 2.6.1: Conditioning on a Variable Not Utilized in the Analysis';
proc means data=BookData.Ipums2005Basic nonobs maxdec=0;
  class Metro;
  var HHIncome;
  format Metro Metro.;
  where Metro in (2,3,4) 
         and 
        MortgageStatus in 
         ('Yes, contract to purchase',
          'Yes, mortgaged/ deed of trust or similar debt');
run;

/**Program 2.6.2**/
proc means data=BookData.Ipums2005Basic nonobs maxdec=0;
  class Metro;
  var HHIncome;
  format Metro Metro.;
  where Metro in (2,3,4) and MortgageStatus contains 'Yes'; 
run;

proc means data=BookData.Ipums2005Basic nonobs maxdec=0;
  class Metro;
  var HHIncome;
  format Metro Metro.;
  where Metro in (2,3,4) and MortgageStatus like '%Yes%'; 
run;

/**Program 2.7.1**/
title 'Output 2.7.1: PROC FREQ with Variables Listed Individually in the TABLE Statement';
options label;
proc freq data=BookData.Ipums2005Basic;
  table metro MortgageStatus;
run;

/**Program 2.7.2**/
proc freq data=BookData.Ipums2005Basic;
  table metro MortgageStatus / nocum;
run;

/**Program 2.7.3**/
proc format;
  value Mort
    0='None'
    1-350="$350 and Below"
    351-1000="$351 to $1000"
    1001-1600="$1001 to $1600"
    1601-high="Over $1600"
  ;
run;

title 'Output 2.7.3: Using a Format to Control Categories for a Variable in the TABLE Statement';
proc freq data=BookData.Ipums2005Basic;
  table MortgagePayment;
  format MortgagePayment Mort.;
run;

/**Program 2.7.4**/
proc format;
  value METRO
    0 = "Not Identifiable"
    1 = "Not in Metro Area"
    2 = "Metro, Inside City"
    3 = "Metro, Outside City"
    4 = "Metro, City Status Unknown"
  ;
  value Mort
    0='None'
    1-350="$350 and Below"
    351-1000="$351 to $1000"
    1001-1600="$1001 to $1600"
    1601-high="Over $1600"
  ;
run;

title 'Output 2.7.4: Using the * Operator to Create a Cross-Tabular Summary with PROC FREQ';
proc freq data=BookData.Ipums2005Basic;
  table Metro*MortgagePayment;
  format Metro Metro. MortgagePayment Mort.;
run;

/**Program 2.7.5**/
title 'Output 2.7.5: Using Options in the TABLE Statement.';
proc freq data=BookData.Ipums2005Basic;
   table Metro*MortgagePayment/nocol nopercent format=comma10.;
   format Metro Metro. MortgagePayment Mort.;
run;

/**Program 2.7.6**/
proc format;
  value MetroB
    0 = "Not Identifiable"
    1 = "Not in Metro Area"
    other = "In a Metro Area"
  ;
  value $Mort_Status
    'No'-'Nz'='No'
    'Yes'-'Yz'='Yes'
    ;
  value Hvalue
    0-65000='$65,000 and Below'
    65000<-110000='$65,001 to $110,000'
    110000<-225000='$110,001 to $225,000'
    225000<-500000='$225,001 to $500,000'
    500000-high='Above $500,000'
    ;
run;

title 'Output 2.7.6: A Three-Way Table in PROC FREQ';
proc freq data=BookData.Ipums2005Basic;
  table MortgageStatus*Metro*HomeValue/nocol nopercent format=comma10.;
  format  MortgageStatus $Mort_Status. Metro MetroB. HomeValue Hvalue.;
  where MortgageStatus ne 'N/A';
run;

/**Program 2.7.7**/
title 'Output 2.7.7: Using the WEIGHT Statement to Summarize a Quantitative Value';
proc freq data=BookData.Ipums2005Basic;
  table HomeValue*Metro/nocol nopercent format=dollar15.;
  weight MortgagePayment;
  format Metro MetroB. HomeValue Hvalue.;
run;

/**Program 2.8.1**/
data Utility2001;
  infile "&raw\Utility 2001.prn";
  input Serial$ Electric Gas Water Fuel;
run;

title 'Output 2.8.1: Reading the Utility 2001 Data (Partial Listing)';
proc print data = Utility2001(obs=5);
run;

/**Program 2.8.2**/
filename Util2001 "&raw\Utility 2001.prn";

data Utility2001A;
  infile Util2001;
  input Serial$ Electric Gas Water Fuel;
run;

/**Program 2.8.3**/
filename RawData "&raw";

data Utility2001B;
  infile RawData("Utility 2001.prn");
  input Serial$ Electric Gas Water Fuel;
run;

/**Program 2.8.4**/
data IPUMS2005Basic;
   infile RawData("IPUMS2005basic.csv") dsd;
   input Serial State $ City $ CityPop Metro
         CountyFIPS Ownership $ MortgageStatus $
         MortgagePayment HHIncome HomeValue;
run;

title 'Output 2.8.4: Reading the 2005 Basic IPUMS CPS Data (Partial Listing)';
proc print data = Ipums2005Basic(obs=5);
run;

/**Program 2.8.5**/
data Ipums2005Basic;
  length state $ 20 City$ 25 MortgageStatus$50;
  infile "&raw\IPUMS2005basic.csv" dsd;
  input Serial State City CityPop Metro 
        CountyFIPS Ownership $ MortgageStatus$ 
        MortgagePayment HHIncome HomeValue;
run;

title 'Output 2.8.5: Using the LENGTH Statement (Partial Listing)';
proc print data = Ipums2005Basic(obs = 5);
run;

/**Program 2.8.6**/
data Ipums2005Basic;
  infile RawData("IPUMS2005basic.csv") dsd;
  input Serial State $ City $ CityPop Metro 
        CountyFIPS Ownership $ MortgageStatus $ 
        MortgagePayment HHIncome HomeValue;
  length state $20 City $25 MortgageStatus $50; 
run;

/**Program 2.8.7**/
data Ipums2005Basic;
  length state $ 20 City $ 25 MortgageStatus $ 50;
  infile RawData ('ipums2005basic.txt') dlm = '09'x;
  input Serial State $ City $ CityPop Metro 
        CountyFIPS Ownership $ MortgageStatus $
        MortgagePayment HHIncome HomeValue;
run;

/**Program 2.8.8**/
data ipums2005basicFPa;
  infile RawData('ipums2005basic.dat');
  input serial 1-8 state $ 10-29 city $ 31-70 cityPop 72-76
        metro 78-80 countyFips 82-84 ownership $ 86-91
        mortgageStatus $ 93-137 mortgagePayment 139-142
        HHIncome 144-150 homeValue 152-158;
run;

/**Program 2.8.9**/
data ipums2005basicFPb;
  infile RawData('ipums2005basic.dat');
  input serial 1-8 hhIncome 144-150 homeValue 152-158 
        ownership $ 86-91 ownershipCoded $ 86
        state $ 10-29 city $ 31-70 cityPop 72-76 
        metro 78-80 countyFips 82-84 
        mortgageStatus $ 93-137 mortgagePayment 139-142;
run;

title 'Output 2.8.9: Ordering the input variables differently than column order';
proc print data = ipums2005basicFPb(obs = 5);
 var serial--state;
run;

/**Program 2.9.1**/;
data flights;
   infile RawData('flights.prn');
   input FlightNum Date $ Destination $ FirstClass EconClass;
run;

/**Program 2.9.2**/
data flights;
  infile RawData('flights.prn');
  input FlightNum Date $ Destination $ FirstClass EconClass;
  list;
run;

/**Program 2.9.3**/
data flights;
  infile RawData('flights.txt') dlm = '09'x;
  input FlightNum Date $ Destination $ FirstClass EconClass;
  list;
run;

/**Program 2.9.4**/
data flights;
  infile RawData('flights.prn');
  input FlightNum Date $ Destination $ FirstClass EconClass;
  putlog 'NOTE: It is easy to write the PDV to the log';
  putlog _all_;
  putlog 'NOTE: Selecting individual variables is also easy';
  putlog 'NOTE: '  FlightNum=  Date ; 
  putlog 'WARNING: Without the equals sign variable names are omitted';
run;

/**Program 2.10.1**/
title 'Output 2.10.1: Comparing the Contents of Two Data Sets';
ods exclude comparedifferences;
proc compare base = sashelp.fish compare = sashelp.heart;
run;

/**Program 2.10.2**/
data ipums2005basicSubset;
   set ipums2005basicFPa;
   where homeValue ne 9999999;
run;

ods listing close;
proc compare noprint base = BookData.ipums2005basic
             compare = ipums2005basicSubset
             out = diff
             outbase outcompare
             outdif outnoequal
             method = absolute
             criterion = 1E-9;
run;

Title 'Output  2.10.2A: Comparing IPUMS 2005 Basic Data Generated from Different Sources';
proc print data = diff(obs=6);
  var _type_ _obs_ serial countyfips metro
    citypop homevalue;
run;

Title 'Output 2.10.2B: Results of Additional Options in Program 2.10.2';
proc print data = diff(obs=6);
  var _type_ _obs_ city ownership;
run;

/**Program 2.12.1**/
proc setinit;
run;
ods rtf close;
