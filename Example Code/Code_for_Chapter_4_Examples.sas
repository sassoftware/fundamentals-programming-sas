/**
Written to accompany Fundamentals of Programming in SAS: A Case Studies Approach

This file contains all code necessary to produce every output in Chapter 4 and is
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

ods path reset;
ods path (prepend) bookdata.template;

options papersize=letter orientation=portrait 
        leftmargin=1.25in rightmargin=1.25in 
        topmargin=1in bottommargin=1in
        nodate nonumber ls=200;
title;
footnote;
ods exclude none;
ods listing close;
ods rtf file='Chapter 4 Tables.rtf' 
        style=customsapphire 
        ;
/**Program 4.3.1**/
data Ipums0105Basic;
  set BookData.Ipums2001Basic(obs=3) 
      BookData.Ipums2005Basic(obs=3);
run;

ods rtf startpage=yes;
ods rtf startpage=now;
ods exclude none;
ods listing close;
title 'Output 4.3.1: A Simple Concatenation';
proc report data=Ipums0105Basic;
  column Serial HHIncome HomeValue State MortgageStatus Metro;
run;

/**Program 4.3.2**/
title;
proc report data=Ipums0105Basic;
  column Serial HHIncome HomeValue State MortgageStatus Metro;
run;

/**Program 4.3.3**/
title 'Output 4.3.3: Behavior of PROC REPORT with All Numeric Columns';
proc report data=Ipums0105Basic;
  column Serial MortgagePayment HHIncome HomeValue;
run;

/**Program 4.3.4**/
proc sort data = BookData.Ipums2001Basic out = Ipums2001Basic;
  by serial;
run;

proc sort data = BookData.Ipums2005Basic out = Ipums2005Basic;
  by serial;
run;

data Ipums0105Basic;
  set Ipums2001Basic Ipums2005Basic;
  by serial;
run;

title 'Output 4.3.4: A Simple Interleave';
proc report data=Ipums0105Basic(obs=5);
  column Serial MortgagePayment HHIncome HomeValue State MortgageStatus;
run;

/**Program 4.3.5**/
proc sort data = BookData.Ipums2001Basic out = Sort2001Basic;
  by HHIncome descending mortgagePayment;
  where HHIncome gt 84000 and state eq 'Vermont';
run;

proc sort data = BookData.Ipums2005Basic out = Sort2005Basic;
  by HHIncome descending mortgagePayment;
  where HHIncome gt 84000 and state eq 'Vermont';
run;

data Ipums0105Basic;
  set Sort2001Basic Sort2005Basic;
  by HHIncome descending mortgagePayment;
run;

title 'Output 4.3.5: Interleaving Using Two Variables';
proc report data=Ipums0105Basic(obs=8);
  column Serial HHIncome MortgagePayment HomeValue MortgageStatus;
run;

/**Program 4.4.1**/
data Ipums0105Basic;
  set BookData.Ipums2001Basic 
      BookData.Ipums2005Basic (drop= CountyFips Metro CityPop City);
run;

title 'Output 4.4.1: Selecting Variables with DROP=';
proc contents data=Ipums0105Basic;
  ods select variables;
run;

/**Program 4.4.2**/
data Ipums2005Basic;
  set BookData.Ipums2005Basic;
  keep Serial MortgagePayment HHIncome HomeValue State MortgageStatus
       Ownership;
run;

title 'Output 4.4.2: KEEP Statement';
proc contents data=Ipums2005Basic;
  ods select variables;
run;

/**Program 4.4.3**/
data Ipums2005Basic Serial2005Basic(keep = Serial);
  set BookData.Ipums2005Basic(keep = Serial MortgagePayment State Ownership obs = 5);
  keep Serial MortgagePayment State;
run;

title 'Output 4.4.3A: Contrasting the KEEP Statement and KEEP= SET Statement Option';
proc contents data=Ipums2005Basic;
  ods select variables;
run;

title 'Output 4.4.3B: Using the KEEP Statement, KEEP= SET Statement Option, and KEEP= DATA Statement Option';
proc contents data=Serial2005Basic;
  ods select variables;
run;

/**Program 4.4.4**/
data Ipums2005Basic Serial2005Basic (rename = (Id = IdNum));
  set BookData.Ipums2005Basic;
  rename Serial = Id MortgagePayment = MortPay;
run;

title 'Output 4.4.4: Demonstrating the RENAME= Option.';
proc contents data=Serial2005Basic varnum;
 ods select position;
run;

/**Program 4.4.5**/
data Basic2005;
  infile RawData("IPUMS2005formatted.csv") dsd obs=10;
  input serial : 7. state : $25. city : $50. citypop : comma6. 
        metro : 1. countyfips : 3. ownership : $6. MortgageStatus : $50. 
        MortgagePayment : dollar12. HHIncome : dollar12. HomeValue : dollar12.;
run;

data Basic2010;
  infile RawData("IPUMS2010formatted.csv") dsd obs=10;
  input serial : 7. state : $25. city : $50. metro : 1. countyfips : 3. 
    citypop : comma6. ownership : $6. MortStat : $50. 
    MortPay : dollar12. HomeValue : dollar12. Inc : dollar12.;
run;

data Basic05And10;
  set basic2005 basic2010;
run;

title 'Output 4.4.5A: Variable Set from Concatenation with Mismatched Columns';
proc contents data=basic05And10 varnum;
  ods select position;
run;

title 'Output 4.4.5B: Data in Columns Mismatched During Concatenation';
proc print data=Basic05And10(obs=1) noobs;
  var MortgageStatus MortStat MortgagePayment MortPay HHIncome Inc;
run; 

proc print data=Basic05And10(firstobs=11 obs=11) noobs;
  var MortgageStatus MortStat MortgagePayment MortPay HHIncome Inc;
run; 

/**Program 4.4.6**/
data Basic05And10Try2;
  set basic2005 basic2010;
  rename MortStat=MortgageStatus MortPay=MortgagePayment Inc=HHIncome;
run;

/**Program 4.4.7**/
data Basic05And10Try3;
  set basic2005
      basic2010(rename=(MortStat=MortgageStatus MortPay=MortgagePayment Inc=HHIncome));
run;

title 'Output 4.4.7: Successfully Renaming Mismatched Variables During Concatenation';
proc contents data=basic05And10Try3 varnum;
  ods select position;
run;

/**Program 4.4.8**/
data Basic2010B;
  infile RawData("IPUMS2010formatted.csv") dsd obs=100;
  input serial : $7. state : $25. city : $50. metro : 1. countyfips : 3. 
    citypop : comma6. ownership : $6. MortStat : $50. 
    MortPay : dollar12. HomeValue : dollar12. Inc : dollar12.;
run;

data Basic05And10B;
  set basic2005
      basic2010B(rename=(MortStat=MortgageStatus MortPay=MortgagePayment Inc=HHIncome));
run;

/**Program 4.4.9**/
data Metro4(where=(metro eq 4)) AllMetro;
  set BookData.Ipums2001Basic(obs = 3)
      BookData.Ipums2005Basic(where=(countyfips eq 73) obs = 3);
run;

title 'Output 4.4.9A: WHERE= Option Applications to Input and Output Data Sets in a DATA Step';
proc report data = metro4;
  column Serial MortgagePayment HHIncome HomeValue State MortgageStatus;
run;

title 'Output 4.4.9B: WHERE= Option Applications to Input and Output Data Sets in a DATA Step';
proc report data = allmetro;
  column Serial MortgagePayment HHIncome HomeValue State MortgageStatus;
run;

/**Program 4.4.10**/
data Metro4(where=(metro eq 4)) AllMetro;
  set BookData.Ipums2001Basic(obs = 3)
      BookData.Ipums2005Basic(where=(countyfips eq 73) obs = 3);
  where MortgagePayment gt 0; 
run;

title 'Output 4.4.10A: Using the WHERE Statement and WHERE= Option Simultaneously';
proc report data = metro4;
 column Serial MortgagePayment HHIncome HomeValue State MortgageStatus;
run;

title 'Output 4.4.10B: Using the WHERE Statement and WHERE= Option Simultaneously';
proc report data = allmetro;
 column Serial MortgagePayment HHIncome HomeValue State MortgageStatus;
run;

/**Program 4.4.11**/
data Combined;
  set BookData.Ipums2001Basic BookData.Ipums2005Basic;
  Year = '2001 or 2005';
  where CityPop ne 0 and Year eq '2001 or 2005';
run;

/**Program 4.4.12**/
data SubIF;
  set BookData.Ipums2001Basic BookData.Ipums2005Basic;
  Year = '2001 or 2005';
  if CityPop ne 0 and Year eq '2001 or 2005';
run;

/**Program 4.4.13**/
data Ipums0105Basic;
  set Ipums2001Basic(in = a)
      Ipums2005Basic(in = b);
run;

/**Program 4.4.14**/
data InDemo1;
  set BookData.Ipums2001Basic(in = a obs = 3)
      BookData.Ipums2005Basic(in = b obs = 3);
  Y05=a;
  Y10=b;
  Year = 2001*a + 2005*b;
run;

title 'Output 4.4.14: Using the IN= Tracking to Compute an Identifying Variable';
proc report data = InDemo1;
  column Y05 Y10 Year Serial HHIncome HomeValue MortgageStatus;
run;

/**Program 4.4.15**/
data Base;
  length y $6;
  x=123456789;
  y=x;
  put _all_;
run;

data Subset1;
  set Base;
  where x = '123456789';
run;

data Subset2;
  set Base;
  if x = '123456789';
run;

/**Program 4.5.1**/
data IfThenDemo1;
  set BookData.Ipums2001Basic(in = in2001 obs = 3)
      BookData.Ipums2005Basic(in = in2005 obs = 3);
  if (in2001 eq 1) then year = 2001;
  if (in2005 eq 1) then year = 2005;
run;

/**Program 4.5.2**/
data IfThenDemo2;
  set BookData.Ipums2001Basic(in = in2001 obs = 3)
      BookData.Ipums2005Basic(in = in2005 obs = 3);
  length MetFlag $ 3;
  if in2001 eq 1 then year = 2001;
    else if in2005 eq 1 then year = 2005;
  if Metro in (1,2,3) then MetFlag = 'Yes';
    else if Metro eq 4 then MetFlag = 'No';
      else MetFlag = 'N/A';
run;

title 'Output 4.5.2: Using  IF-THEN/ELSE Statements to Create New Variables';
proc report data = IfThenDemo2;
  column Year MetFlag Serial HHIncome HomeValue State MortgageStatus;
run;

/**Program 4.5.3**/
data IfThenDemo3;
  set BookData.Ipums2001Basic(in = in2001 obs = 3)
      BookData.Ipums2005Basic(in = in2005 obs = 3);
  length FirstFlag $ 3;
  if in2001 eq 1 then do;
    year = 2001;
    FirstFlag = 'Yes';
  end;
    else if in2005 then year = 2005;
run;

title 'Output 4.5.3: Using Do Groups to Create Multiple Variables'; 
proc report data = IfThenDemo3;
  column Year FirstFlag Serial HHIncome HomeValue State MortgageStatus;
run;

/**Program 4.5.4**/
data OtherwiseNeeded;
  Metro = 5;
  select(Metro);
    when(Metro in (1,2,3)) MetFlag = 'Yes';
    when(Metro eq 4) MetFlag = 'No';
  end;
run;

/**Program 4.5.5**/
data work.one;
  set BookData.Ipums2005Basic;
  select(upcase(scan(MortgageStatus,1,',')));
    when('YES') MortFlag = 1;
    when('NO') MortFlag = 0;
    when('N/A') MortFlag = .;
  end;
run;

/**Program 4.5.6**/
data work.two;
  set BookData.Ipums2005Basic;
  select(upcase(substr(MortgageStatus,1,1)));
    when('Y') MortFlag = 1;
    when('N') MortFlag = 0;
  end;
run;

/**Program 4.5.7**/
data wrong;
  length MetFlag $ 3;
  Metro = 5;
  select(Metro);
    when(Metro in (1,2,3)) MetFlag = 'Yes';
    when(Metro eq 4) MetFlag = 'No';
    otherwise MetFlag = 'N/A';
  end;
run;

/**Program 4.6.1**/
data DatesDemo01;
  set BookData.Ipums2001Basic(in = in2001 obs = 3)
      BookData.Ipums2005Basic(in = in2005 obs = 3);
  if in2001 eq 1 then year = 2001;
    else if in2005 eq 1 then year = 2005;
  Date = mdy(12,31,year);
  DynamicDay = today();
  FixedDay = '14MAR2019'd;
  Diff1 = DynamicDay - Date;
  Diff2 = FixedDay - Date;
  Diff3 = Time() - '13:56't;
run;

title 'Program 4.6.1: Creating and Doing Arithmetic Operations on Dates';
proc report data = DatesDemo01;
  column Serial State Year Date DynamicDay FixedDay Diff1 Diff2 Diff3; 
  label Serial = 'Serial';
run;

/**Program 4.6.2**/
data DatesDemo02;
  set BookData.Ipums2001Basic(in = in2001 obs = 3)
      BookData.Ipums2005Basic(in = in2005 obs = 3);
  if in2001 eq 1 then year = 2001;
    else if in2005 eq 1 then year = 2005;
  Date = mdy(12,31,year);
  FixedDay = '14MAR2019'd;
  Years = yrdif(mdy(12,31,year), '14MAR2019'd, 'Actual');
  Int1 = intck('year', mdy(12,31,year), '14MAR2019'd,'continuous');
  Int2 = intck('month', mdy(12,31,year), '14MAR2019'd);
  Next1 = intnx('month', '14MAR2019'd, 3, 'beginning');
  Next2 = intnx('month', '14MAR2019'd, 3, 'sameday');
  Day1a = weekday(Next1);
  Day1b = weekday(Next2);
  Format Date date7. FixedDay yymmdd8. Day1b next2 downame. Next1 date7.;
run;

title 'Program 4.6.2: Using Date Functions';
proc print data = DatesDemo02 noobs;
  var Serial Date FixedDay Years Int1 Int2 Next1 Day1a Day1b Next2; 
run;

/**Program 4.7.1**/
data Ipums2001and2005;
  set BookData.Ipums2001Basic(in = in2001)
      BookData.Ipums2005Basic(in = in2005);
  if in2001 eq 1 then Year = 2001;
    else if in2005 eq 1 then Year = 2005;
run;

title 'Output 4.7.1: Default Output from PROC UNIVARIATE on a Single Variable';
proc univariate data=Ipums2001and2005;
  var MortgagePayment HomeValue Citypop;
run;

/**Program 4.7.2**/
proc univariate data=Ipums2001and2005;
  var MortgagePayment HomeValue Citypop;
  ods select Quantiles BasicMeasures;
run;

/**Program 4.7.3**/
title 'Output 4.7.3: Using a Class Variable in PROC UNIVARIATE';
ods noproctitle;
ods rtf startpage=now;
ods rtf startpage=no;
proc univariate data=Ipums2001and2005;
  class year;
  var HomeValue Citypop;
  ods select BasicMeasures;
run;

/**Program 4.7.4**/
title 'Output 4.7.4A: Where Subsetting (Partial Output, HomeValue for 2005)';
ods rtf startpage=now;
ods rtf startpage=no;
proc univariate data=Ipums2001and2005;
  class year;
  var HomeValue Citypop;
  ods select BasicMeasures;
  where HomeValue ne 9999999;
run;

title 'Output 4.7.4B and 4.7.5: Where Subsetting (Partial Output, CityPop for 2005)';
ods rtf startpage=now;
proc univariate data=Ipums2001and2005;
  class year;
  var CityPop;
  ods select BasicMeasures;
  where HomeValue ne 9999999;
run;

/**Program 4.7.5**/
proc univariate data= work.Ipums2001and2005;
  class year;
  var CityPop;
  ods select BasicMeasures;
  where HomeValue ne 9999999;
run;

/**Program 4.7.6**/
ods trace on;
ods listing image_dpi=300;
ods graphics/reset width=4in imagename='Output 4_7_6' imagefmt=tif;
ods rtf exclude all;
title;
proc univariate data=Ipums2001and2005;
  class year;
  var MortgagePayment;
  histogram MortgagePayment / normal(mu=est sigma=est);
  qqplot MortgagePayment / weibull(c=est sigma=est theta=est);
  where MortgagePayment gt 0;
run;
ods trace off;

/**Program 4.8.1**/
ods rtf exclude sgplot(persist);
ods rtf exclude sgpanel(persist);
ods graphics/reset width=4in imagename='Output 4_8_1' imagefmt=tif;
*title 'Output 4.8.1: Histogram of Mortgage Payments';
proc sgplot data=Ipums2001and2005;
  histogram MortgagePayment;
  where MortgagePayment gt 0;
run;

/**Program 4.8.2**/
ods graphics/reset width=4in imagename='Output 4_8_2' imagefmt=tif;
*title 'Output 4.8.2: Setting Options for a Histogram';
proc sgplot data=Ipums2001and2005;
  histogram MortgagePayment / binstart=250 binwidth=500 scale=proportion dataskin=gloss;
  xaxis label='Mortgage Payment' valuesformat=dollar8.;
  yaxis display=(nolabel) valuesformat=percent7.;
  where MortgagePayment gt 0;
run;

/**Program 4.8.3**/
ods graphics/reset width=4in imagename='Output 4_8_3' imagefmt=tif;
*title 'Output 4.8.3: Multi-Panel Histogram';
proc sgpanel data=Ipums2001and2005;
  panelby Year;
  histogram MortgagePayment / binstart=250 binwidth=500 scale=proportion dataskin=gloss;
  colaxis label='Mortgage Payment' valuesformat=dollar8.;
  rowaxis display=(nolabel) valuesformat=percent7.;
  where MortgagePayment gt 0;
run;

/**Program 4.8.4**/
ods graphics/reset width=4in imagename='Output 4_8_4' imagefmt=tif;
*title 'Output 4.8.4: Altering Panel Structure with PANELBY Statement Options';
proc sgpanel data=Ipums2001and2005;
  panelby Year / columns=1 novarname headerattrs=(family='Georgia');
  histogram MortgagePayment / binstart=250 binwidth=500 scale=proportion dataskin=gloss;
  colaxis label='Mortgage Payment' valuesformat=dollar8.;
  rowaxis display=(nolabel) valuesformat=percent7.;
  where MortgagePayment gt 0;
run;

/**Program 4.8.5**/
ods graphics/reset width=4in imagename='Output 4_8_5' imagefmt=tif;
*title 'Output 4.8.5: Grouped Boxplot';
proc sgplot data=Ipums2001and2005;
  vbox MortgagePayment / group=year groupdisplay=cluster;
  where MortgagePayment gt 0;
run;

/**Program 4.8.6**/
ods graphics/reset width=4in imagename='Output 4_8_6' imagefmt=tif;
*title 'Output 4.8.6: Boxplot Modifications';
proc sgplot data=Ipums2001and2005;
  vbox MortgagePayment / group=year groupdisplay=cluster extreme whiskerattrs=(color=red);
  keylegend / across=1 position=topright location=inside title='';
  yaxis display=(nolabel) valuesformat=dollar8.;
  where MortgagePayment gt 0;
run;

/**Program 4.8.7**/
ods listing close;
ods rtf exclude summary;
proc means data=Ipums2001and2005 min p10 p25 median p75 p90 max;
  class year;
  var MortgagePayment;
  where MortgagePayment gt 0;
  ods output summary=MPQuantiles;
run;

ods listing image_dpi=300;
ods graphics/reset width=4in imagename='Output 4_8_7' imagefmt=tif;
*title 'Output 4.8.7: High-Low Plot';
proc sgplot data=MPQuantiles;
  highlow x=year low=MortgagePayment_p25 high=MortgagePayment_P75;
run;

/**Program 4.8.8**/
ods graphics/reset width=4in imagename='Output 4_8_8' imagefmt=tif;
*title 'Output 4.8.8: High-Low Plot Modifications';
proc sgplot data=MPQuantiles;
  highlow x=year low=MortgagePayment_P25 high=MortgagePayment_P75
   / type=bar fillattrs=(color=cx99FF99) dataskin=sheen;
  xaxis values=(2001 2005) display=(nolabel);
  yaxis label='Mortgage Payment' valuesformat=dollar8.;
run;

/**Program 4.8.9**/
ods graphics/reset width=4in imagename='Output 4_8_9' imagefmt=tif;
*title 'Output 4.8.9: Custom Boxplot Created from Multiple High-Low Plots';
proc sgplot data=MPQuantiles;
  highlow x=year low=MortgagePayment_Min high=MortgagePayment_Max/
   legendlabel='Minimum to Maximum' lineattrs=(color=red) name='Line'; 
  highlow x=year low=MortgagePayment_P10 high=MortgagePayment_P90/
   legendlabel='10th to 90th Percentile' type=bar barwidth=.3 fillattrs=(color=cx006D2C) name='Box1';
  highlow x=year low=MortgagePayment_P25 high=MortgagePayment_P75
   / type=bar legendlabel='Inter-Quartile Range'  barwidth=.5  fillattrs=(color=cx74C476) name='Box2';
  xaxis values=(2001 2005) display=(nolabel);
  yaxis label='Mortgage Payment' valuesformat=dollar8. values=(0 to 9000 by 1000);
  keylegend 'Line' / position=topright location=inside noborder valueattrs=(size=8pt);
  keylegend 'Box1' 'Box2' / across=1 position=topleft location=inside noborder valueattrs=(size=8pt);
run;
ods rtf close;
