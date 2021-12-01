/**
Written to accompany Fundamentals of Programming in SAS: A Case Studies Approach

This file contains all code necessary to produce every output in Chapter 5 and is
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
ods rtf file='Chapter 5 Tables.rtf' 
        style=customsapphire 
        ;
/**Program 5.3.1**/
data ipums2005Utility;
  infile RawData('Utility Cost 2005.txt') dlm='09'x dsd firstobs=4;
  input serial electric:comma. gas:comma. water:comma. fuel:comma.; 
  format electric gas water fuel dollar.;
run;

title 'Output 5.3.1: Reading Utility Cost Data from Utility Cost 2005.txt';
proc report data = ipums2005utility (obs = 5);
  columns serial electric gas water fuel;
  define Serial / display 'Serial';
  define Electric / display;
  define Gas / display;
  define Water / display;
  define Fuel / display;
run;

/**Input Data 5.3.2**/
title 'Input Data 5.3.2: Partial Listing of Ipums2005Basic (Only Five Variables for the 3rd through 6th Records)';
proc report data = BookData.Ipums2005Basic(firstobs = 3 obs = 6);
  columns Serial State Metro HHIncome;
run;

/**Program 5.3.2**/
data OneToOneMM;
  merge BookData.ipums2005basic(firstobs = 3 obs = 6) 
        ipums2005Utility(obs = 5); 
  by Serial;
run;

title 'Output 5.3.2: Carrying out a one-to-one match-merge using a single key variable';
proc print data = OneToOneMM;
  var serial state metro hhincome electric gas water fuel;
run;

/**Program 5.3.3**/
data OneToOneRead;
  set BookData.ipums2005basic(firstobs = 3 obs = 6);
  set ipums2005Utility(obs = 5); 
run;

title 'Output 5.3.3: Carrying out a one-to-one reading';
proc report data = OneToOneRead;
  columns serial state metro hhincome electric gas water fuel; 
run;

/**Program 5.3.4**/
data OneToOneMerge;
  merge BookData.ipums2005basic(firstobs = 3 obs = 6)
        ipums2005Utility(obs = 5); 
run;

title 'Output 5.3.4: Carrying out a one-to-one merge';
proc report data = OneToOneMerge;
  columns serial state metro hhincome electric gas water fuel; 
run;

/**Program 5.3.5**/
data ipums2005cost;
  merge BookData.ipums2005basic ipums2005Utility;
  by serial;
  if homevalue eq 9999999 then homevalue=.;
  if electric ge 9000 then electric=.;
  if gas ge 9000 then gas=.;
  if water ge 9000 then water=.;
  if fuel ge 9000 then fuel=.;
run;

ods rtf exclude summary;
proc means data=bookdata.ipums2005basic;
  where state in ('North Carolina','South Carolina') and mortgageStatus ne 'N/A';
  class state mortgageStatus; 
  var homevalue hhincome mortgagepayment;
  output out=means mean=HVmean HHImean MPmean; 
run;

proc format;
  value $MStatus
    'No'-'Nz'='No'
    'Yes, a'-'Yes, d'='Yes, Contract'
    'Yes, l'-'Yes, n'='Yes, Mortgaged'
  ;
run;

title 'Program 5.3.5: Data Cleaning and Generating Summary Statistics';
proc report data = means;
  columns State MortgageStatus _type_ _freq_ HVmean HHImean MPmean;
  define State / display;
  define MortgageStatus / display 'Mortgage Status' format=$MStatus.;
  define _type_ / display 'Group';
  define _freq_ / display 'Frequency';
  define hvmean / display format = dollar11.2 'Mean Home Value';
  define hhimean / display format = dollar10.2 'Mean Household Income';
  define mpmean / display format = dollar7.2 'Mean Mortgage Payment'; 
run;

/**Program 5.3.6**/
proc sort data=ipums2005cost out=cost;
  by state mortgagestatus;
  where state in ('North Carolina','South Carolina') and mortgageStatus ne 'N/A';
run;

proc sort data=means;
  by state mortgagestatus;
run;

data OneToManyMM;
  merge cost(in=inCost) means(in=inMeans);
  by state mortgagestatus;
  if inCost eq 1 and inMeans eq 1;
 
  HVdiff=homevalue-HVmean;
  HVratio=homevalue/HVmean;
  HHIdiff=hhincome-HHImean;
  HHIratio=hhincome/HHImean;
  MPdiff=mortgagepayment-MPmean;
  MPratio=mortgagepayment/MPmean;
run;

title 'Output 5.3.6A: One-to-Many Match-Merge';
proc report data = OneToManyMM(obs=4);
  where mortgageStatus contains 'owned';
  columns Serial State MortgageStatus HomeValue HVMean HVRatio;
  define Serial / display 'Serial';
  define State / display 'State';
  define MortgageStatus / display 'Mortgage Status';
  define HomeValue / display 'Home Value' ;
  define HVMean / display format = dollar11.2 'Mean Home Value';
  define HVRatio / display format = 4.2 'Ratio';
run; 

title 'Output 5.3.6B: One-to-Many Match-Merge';
proc print data = OneToManyMM(obs=4);
  where mortgageStatus contains 'contract';
  var Serial State MortgageStatus HomeValue HVMean HVRatio;
run; 

/**Program 5.3.7**/
ods rtf exclude summary;
proc means data=ipums2005cost(where = (state in ('North Carolina','South Carolina')));
  class state metro;
  var homevalue hhincome mortgagepayment;
  output out=medians median=HVmed HHImed MPmed;
run;

proc sort data = medians; 
  by state metro;
run;

data ManyToManyMM;
  merge means medians;
  by state;
run;

title 'Output 5.3.7: Many-to-Many Match-Merge';
proc report data = ManyToManyMM(firstobs=7);
  columns State MortgageStatus Metro _FREQ_ HVMean HVMed;
  define State / display;
  define MortgageStatus / display 'Mortgage Status';
  define Metro / display 'Metro Classification';
  define _freq_ / display 'Frequency';
  define HVMean / display format = dollar11.2 'Mean Home Value';
  define HVMed / display format = dollar11.2 'Median Home Value';
run;  

/**Program 5.4.1**/
data Investigate;
  merge BookData.Staff BookData.Clients;
  by DistrictNo;
run; 

title 'Output 5.4.1: Investigating a Match-Merge';
proc report data = Investigate;
  columns DistrictNo SalesPerson Client;
  define DistrictNo / Display;
  define SalesPerson / display;
  define Client / display;
run;

/**Program 5.4.2**/
data Investigate2;
  merge BookData.Staff(where=(salesperson ne 'Smith')) BookData.Clients;
  by DistrictNo;
run; 

title 'Output 5.4.2: Hypothetical Output—Observation 2 Removed from Staff Data';
proc report data = Investigate2;
  columns DistrictNo SalesPerson Client;
  define DistrictNo / Display;
  define SalesPerson / display;
  define Client / display;
run;

/**Program 5.5.1**/
data InnerJoin01;
  merge cost(in=inCost) means(in=inMeans);
  by State MortgageStatus;
  if (inCost eq 1) and inMeans;
run;

title 'Output 5.5.1: Using a Subsetting IF Statement to Carry Out an Inner Join';
proc report data = InnerJoin01(obs=8);
  columns Serial State MortgageStatus HomeValue HVMean;
  define Serial / display;
  define State / display;
  define MortgageStatus / display 'Mortgage Status';
  define HomeValue / display format = dollar11.2 'Home Value';
  define HVMean / display format = dollar11.2 'Mean Home Value';
run;

/**Program 5.5.2**/
data LeftJoin01 RightJoin01;
  merge cost(in=inCost) means(in=inMeans);
  by State MortgageStatus;
  if inCost eq 1 then output LeftJoin01;
  if inMeans eq 1 then output RightJoin01;
run;

title 'Output 5.5.2A: LeftJoin01 Data Set Created by Program 5.5.2';
proc report data = LeftJoin01(obs=8);
  columns Serial State MortgageStatus HomeValue HVMean;
  define Serial / display;
  define State / display;
  define MortgageStatus / display 'Mortgage Status';
  define HomeValue / display format = dollar11.2 'Home Value';
  define HVMean / display format = dollar11.2 'Mean Home Value';
run;

title 'Output 5.5.2B: RightJoin01 Data Set Created by Program 5.5.2';
proc report data = RightJoin01(obs=8);
  columns Serial State MortgageStatus HomeValue HVMean;
  define Serial / display;
  define State / display;
  define MortgageStatus / display 'Mortgage Status';
  define HomeValue / display format = dollar11.2 'Home Value';
  define HVMean / display format = dollar11.2 'Mean Home Value';
run;

/**Program 5.6.1**/
title 'Output 5.6.1: Basic Summaries Generated by the CORR Procedure';
proc corr data=BookData.ipums2005basic;
  var CityPop MortgagePayment HHincome HomeValue;
  where HomeValue ne 9999999 and MortgageStatus contains 'Yes';
run;

/**Program 5.6.2**/
title 'Output 5.6.2: Using the WITH Statement in the CORR Procedure';
proc corr data=BookData.ipums2005basic;
  var HHincome HomeValue;
  with MortgagePayment;
  where HomeValue ne 9999999 and MortgageStatus contains 'Yes';
  ods exclude SimpleStats;
run;

/**Program 5.6.3**/
data ipums2005Utility;
  infile RawData('Utility Cost 2005.txt') dlm='09'x dsd firstobs=4;
  input serial electric:comma. gas:comma. water:comma. fuel:comma.;
  format electric gas water fuel dollar.;
run;
 
data ipums2005cost;
  merge BookData.ipums2005basic ipums2005Utility;
  by serial;
run;

title 'Output 5.6.3: Computing Further Correlations with Utility Costs';
proc corr data=ipums2005cost;
  var electric gas water fuel;
  with mortgagePayment hhincome homevalue;
  where homevalue ne 9999999 and mortgageStatus contains 'Yes';
  ods select PearsonCorr;
run;

/**Program 5.6.4**/
title 'Output 5.6.4: Computing Further Correlations with Utility Costs';
proc corr data=ipums2005cost;
  var electric;
  with mortgagePayment hhincome homevalue;
  where homevalue ne 9999999 and mortgageStatus contains 'Yes' and electric lt 9000;
  ods select PearsonCorr;
run;

/**Program 5.6.5**/
data ipums2005cost;
  merge BookData.ipums2005basic ipums2005Utility;
  by serial;
  if homevalue eq 9999999 then homevalue=.;
  if electric ge 9000 then electric=.;
  if gas ge 9000 then gas=.;
  if water ge 9000 then water=.;
  if fuel ge 9000 then fuel=.;
run;

title 'Output 5.6.5: Re-Computing Correlations for Missing Utility Costs ';
proc corr data=ipums2005cost;
  var electric gas water fuel;
  with mortgagePayment hhincome homevalue;
  where homevalue ne 9999999 and mortgageStatus contains 'Yes';
  ods select PearsonCorr;
run; 

/**Program 5.6.6**/
proc format;
  value HHInc
    low-40000='$40,000 and Below'
    40000-70000='$40,000 to $70,000'
    70000-100000='$70,000 to $100,000'
    100000-high='Above $100,000'
  ;
  value MPay
    low-500='$500 and Below'
    500-900='$500 to $900'
    900-1300='$900 to $1,300'
    1300-high='Above $1,300'
  ;
run;

title 'Output 5.6.6: Association Measures (Partial Listing) for Ordinal Categories';
proc freq data=BookData.ipums2005basic;
  table MortgagePayment*HHincome/measures norow nocol format=comma8.;
  where HomeValue ne 9999999 and MortgageStatus contains 'Yes';
  format HHincome HHInc. MortgagePayment MPay.;
run;

/**Program 5.6.7**/
data ipums2005Modified;
  set BookData.ipums2005basic;
  where HomeValue ne 9999999 and MortgageStatus contains 'Yes';
  MPay=put(MortgagePayment,MPay.);
  HHInc=put(HHIncome,HHInc.);
  keep MPay HHInc;
run;

title 'Output 5.6.7, Duplicate of Output 5.6.6';
proc freq data=ipums2005Modified;
  table MPay*HHInc/measures norow nocol format=comma8.;
run;

/**program 5.6.8**/
ods rtf exclude summary;
proc means data=ipums2005cost median;
  var gas electric fuel water;
  class homevalue;
  where state eq 'Vermont' and homevalue ne 9999999;
  ods output summary=medians;
run;

title;
ods rtf exclude sgplot(persist);
ods listing image_dpi=300;
ods graphics/reset width=4in imagename='Output 5_6_8' imagefmt=tif;
*title 'Output 5.6.8: Scatterplot for Utility Costs Versus Home Values';
proc sgplot data=medians;
  scatter y=gas_median x=homevalue;
  scatter y=electric_median x=homevalue; 
  scatter y=fuel_median x=homevalue;
  scatter y=water_median x=homevalue;
run;

/**program 5.6.9**/
ods graphics/reset width=4in imagename='Output 5_6_9' imagefmt=tif;
*title 'Output 5.6.9: Enhanced Scatterplots for Utility Costs Versus Home Values';
proc sgplot data=medians;
  scatter y=gas_median x=homevalue / 
   legendlabel='Gas' markerattrs=(color=red symbol=squarefilled);
  scatter y=electric_median x=homevalue / 
   legendlabel='Elec.' markerattrs=(color=blue symbol=square);
  scatter y=fuel_median x=homevalue / 
    legendlabel='Fuel' markerattrs=(color=green symbol=circlefilled);
  scatter y=water_median x=homevalue / 
    legendlabel='Water' markerattrs=(color=orange symbol=circle);
  yaxis label='Cost ($)' values=(0 to 1800 by 200);
  xaxis label='Value of Home' valuesformat=dollar12.;
  keylegend / position=topright;
run;

/**program 5.6.10**/
ods graphics/reset width=4in imagename='Output 5_6_10' imagefmt=tif;
*title 'Output 5.6.10: Fitted Curves for Utility Costs Versus Home Values';
proc sgplot data=medians;
  reg y=gas_median x=homevalue / degree=1 legendlabel='Gas'
     lineattrs=(color=red) markerattrs=(color=red symbol=squarefilled);
  reg y=electric_median x=homevalue / degree=5 legendlabel='Elec.'
     lineattrs=(color=blue) markerattrs=(color=blue symbol=square);
  loess y=fuel_median x=homevalue / legendlabel='Fuel' 
     lineattrs=(color=green) markerattrs=(color=green symbol=circlefilled);
  pbspline y=water_median x=homevalue / legendlabel='Water' 
     lineattrs=(color=orange) markerattrs=(color=orange symbol=circle);
  yaxis label='Cost ($)' values=(0 to 1800 by 200);
  xaxis label='Value of Home' valuesformat=dollar12.;
  keylegend / position=topright;
run;

/**program 5.6.11**/
ods graphics/reset width=4in imagename='Output 5_6_11' imagefmt=tif;
*title 'Output 5.6.11: SCATTER Using a Categorical Variable';
proc sgplot data=sashelp.cars;
  scatter x=origin y=mpg_highway / jitter jitterwidth=0.8;
run;

ods listing close;
/**Program 5.7.1**/
proc print data=sashelp.cars(keep=make model msrp mpg_city mpg_highway obs=6) noobs;
run;

proc transpose data=sashelp.cars(keep=make model msrp mpg_city mpg_highway obs=6) out=carsTrans;
run;

title 'Output 5.7.1: Transposing a Data Set';
proc print data=carsTrans noobs;
run;

/**Program 5.7.2**/
proc transpose data=ipums2005Utility out=Utility2;
  by serial;
  var electric--fuel;
run;

title 'Program 5.7.2: Transposing Portions of Records Using BY Group Processing';
proc print data=Utility2(obs=8) noobs;
run;

/**Program 5.7.3**/
proc transpose data=ipums2005Utility name=Utility prefix=Cost out=Utility2;
  by serial;
  var electric--fuel;
run;

proc transpose data=ipums2005Utility  out=Utility3(rename=(col1=Cost _name_=Utility));
  by serial;
  var electric--fuel;
run;

/**program 5.7.4**/
proc transpose data=Utility3 out=Revert;
  by serial;
  var Cost;
run;

title 'Output 5.7.4: Transposing Multiple Records Into a Set of Variables';
proc print data=Revert(obs=5) noobs;
run;

/**Program 5.7.5**/
proc transpose data=Utility3 out=Revert2(drop=_name_);
  by serial;
  id Utility;
  var Cost;
run;

title 'Output 5.7.5: Transposing Multiple Records Into a Set of Variables';
proc print data=Revert2(obs=5) noobs;
run;

/**Program 5.7.6**/
data ipums2005cost2;
  merge BookData.ipums2005basic Utility3;
  by serial;
  utility=propcase(utility);
  label utility='Utility';
run;

proc sort data=ipums2005cost2;
  by utility;
run;

ods rtf startpage=no;
ods rtf startpage=now;
ods exclude none;
ods proctitle off;
title 'Output 5.7.6: Correlations Using Transposed Data (Partial Output)';
proc corr data=ipums2005cost2;
  by utility;
  var cost;
  with mortgagePayment hhincome homevalue;
  where homevalue ne 9999999 and mortgageStatus contains 'Yes' and cost lt 9000;
  ods select PearsonCorr; 
run;

/**Program 5.7.7**/
ods rtf exclude summary;
proc means data=ipums2005cost2 median;
  var cost;
  class homevalue utility;
  where state eq 'Vermont' and homevalue ne 9999999 and cost lt 9000;
  ods output summary=medians2;
run;

title;
ods rtf exclude sgplot(persist);
ods listing image_dpi=300;/**put in dpi stuff***/
ods graphics/reset width=4in imagename='Output 5_7_7' imagefmt=tif;
*title 'Output 5.7.7: Scatterplots Based on Transposed Utility Data';
proc sgplot data=medians2;
  scatter y=cost_median x=homevalue / group=utility;
  yaxis label='Cost ($)' values=(0 to 1800 by 200);
  xaxis label='Value of Home' valuesformat=dollar12.;
  keylegend / position=topright;
run;

/**Program 5.7.8**/
ods graphics/reset width=4in imagename='Output 5_7_8' imagefmt=tif;
*title 'Output 5.7.8: Setting Attributes for Markers in Grouped Scatter Plots';
proc sgplot data=medians2;
  scatter y=cost_median x=homevalue / group=utility markerattrs=(symbol=square);
  yaxis label='Cost ($)' values=(0 to 1800 by 200);
  xaxis label='Value of Home' valuesformat=dollar12.;
  keylegend / position=topright;
run;

/**Program 5.7.9**/
ods graphics/reset width=4in imagename='Output 5_7_9' imagefmt=tif;
*title 'Output 5.7.9: Using the STYLEATTRS Statement to Set Attributes in Grouped Plots';
proc sgplot data=medians2;
  styleattrs datacontrastcolors=(red blue green orange) 
            datasymbols=(circle square triangle diamond)
            datalinepatterns=(solid);
  pbspline y=cost_median x=homevalue / group=utility;
  yaxis label='Cost ($)' values=(0 to 1800 by 200);
  xaxis label='Value of Home' valuesformat=dollar12.;
  keylegend / position=topright;
run;

/**Program 5.9.1**/
data ipums2005UtilityB;
  infile RawData('Utility Cost 2005.txt') dlm='09'x dsd firstobs=4;
  input serial electric:comma. gas:comma. water:comma. fuel:comma.; 
  format electric gas water fuel dollar.;
  if electric eq 9993 then electric=.A;
    else if electric eq 9997 then electric=.B;
run;

title 'Output 5.9.1A: Using Special Missing Values';
proc freq data=ipums2005UtilityB;
  table electric / missing;
  where electric in (.A,.B);
run;

proc format;
  value elecmiss
    .A='No Charge or None Used'
    .B='Included in Rent or Condo Fee'
  ;
run;

title 'Output 5.9.1B: Applying a Format to Special Missing Values';
proc freq data = ipums2005UtilityB;
  table electric / missing;
  where electric in (.A,.B);
  format electric elecmiss.;
run;
ods rtf close;
