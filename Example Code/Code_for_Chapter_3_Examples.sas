/**
Written to accompany Fundamentals of Programming in SAS: A Case Studies Approach

This file contains all code necessary to produce every output in Chapter 3 and is
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
title;footnote;
ods exclude none;
ods listing close;
ods rtf file='Chapter 3 Tables and Graphs.rtf' 
        style=customsapphire 
        ;
ods listing image_dpi=300;
ods graphics / reset imagename='Output 3_3_1' width=4in imagefmt=tif;
/**Program 3.3.1**/
*title 'Output 3.3.1: Vertical Bar Chart for Counts on Each Level of Metro';
proc sgplot data=BookData.Ipums2005Basic;
  vbar metro;
run;

ods graphics / reset imagename='Output 3_3_2' width=4in imagefmt=tif;
/**Program 3.3.2**/
*title 'Output 3.3.2: Horizontal Bar Chart for Counts on Each Level of Metro';
proc sgplot data=BookData.Ipums2005Basic;
  hbar metro;
run;

/**Program 3.3.3**/
proc format;
   value Mort
     0='None'
     1-350="$350 and Below"
     351-1000="$351 to $1000"
     1001-1600="$1001 to $1600"
     1601-high="Over $1600"
    ;
run;

ods graphics / reset imagename='Output 3_3_3' width=4in imagefmt=tif;
*title 'Output 3.3.3: Formatting Mortgage Payment for Use as a Charting Variable';
proc sgplot data=BookData.Ipums2005Basic;
   hbar MortgagePayment;
   format MortgagePayment Mort.;
run;

/**Program 3.3.4**/
ods graphics / reset imagename='Output 3_3_4' width=4in imagefmt=tif;
*title 'Output 3.3.4: Percent as the Summary Statistic';
proc sgplot data=BookData.Ipums2005Basic;
   hbar MortgagePayment/stat=percent;
   format MortgagePayment Mort.;
run;

/**Program 3.3.5**/
ods graphics / reset imagename='Output 3_3_5' width=4in imagefmt=tif;
*title 'Mortgage Payment as the Response Across Metro Categories';
proc sgplot data=BookData.Ipums2005Basic;
   hbar metro/response=MortgagePayment;
run;

/**Program 3.3.6**/
ods graphics / reset imagename='Output 3_3_6' width=4in imagefmt=tif;
*title 'Output 3.3.6: Mortgage Payment Means Summarized Across Metro Categories';
proc sgplot data=BookData.Ipums2005Basic;
   hbar metro/response=MortgagePayment stat=mean;
run;

/**Program 3.3.7**/
ods graphics / reset imagename='Output 3_3_7' width=4in imagefmt=tif;
*title 'Output 3.3.7: Mortgage Payment Frequencies Split Across Metro Status';
proc sgplot data=BookData.Ipums2005Basic;
   hbar MortgagePayment/group=metro;
   format MortgagePayment Mort.;
run;

/**Program 3.3.8**/
proc format;
 value METRO
   0 = "Not Identifiable"
   1 = "Not in Metro Area"
   2 = "Metro, Inside City"
   3 = "Metro, Outside City"
   4 = "Metro, City Status Unknown"
  ;
run;
ods graphics / reset imagename='Output 3_3_8' width=4in imagefmt=tif;
*title 'Output 3.3.8: Group Bars Displayed Side-By-Side';
proc sgplot data=BookData.Ipums2005Basic;
 hbar MortgagePayment/group=metro groupdisplay=cluster
   response=HHIncome stat=mean;
 format MortgagePayment Mort. metro metro.;
 where metro between 2 and 4;
run;

/**Program 3.4.1**/
ods graphics / reset imagename='Output 3_4_1' width=4in imagefmt=tif;
*title 'Output 3.4.1 : Modifying Bar Fills and Outlines';
proc sgplot data=BookData.Ipums2005Basic;
   hbar MortgagePayment/stat=percent fillattrs=(color=cx36CF36) 
                          outlineattrs=(color=gray3F thickness=3pt);
   format MortgagePayment Mort.;
   where MortgagePayment gt 0;
run;

/**Program 3.4.2**/
ods graphics / reset imagename='Output 3_4_2' width=4in imagefmt=tif;
*title 'Output 3.4.2: Various Bar Chart Modifications';
proc sgplot data=BookData.Ipums2005Basic;
   hbar Metro/response=MortgagePayment stat=mean categoryorder=respasc
                          dataskin=gloss limits=upper limitstat=stderr;
   format Metro Metro.;
   where metro between 2 and 4 and HHIncome ge 500000;
run;

/**Program 3.4.3**/
ods graphics / reset imagename='Output 3_4_3' width=4in imagefmt=tif;
*title 'Output 3.4.3: Changing Various Axis Attributes';
proc sgplot data=BookData.Ipums2005Basic;
   hbar Metro/response=MortgagePayment stat=mean categoryorder=respasc
                          dataskin=gloss limits=upper limitstat=stderr;
   format Metro Metro.;
   where metro between 2 and 4 and HHIncome ge 500000;
   yaxis display=(nolabel) valueattrs=(family='Papyrus' size=8pt);
   xaxis values=(0 to 2500 by 250) offsetmax=0 valuesformat=comma5. 
         label='Avg. Mortgage Payment';
run;

/**Program 3.4.4**/
ods graphics / reset imagename='Output 3_4_4' width=4in imagefmt=tif;
*title 'Output 3.4.4: Changing Various Legend Attributes';
proc sgplot data=BookData.Ipums2005Basic;
 hbar MortgagePayment/group=metro groupdisplay=cluster
   response=HHIncome stat=mean;
 format MortgagePayment Mort. metro metro.;
 where metro between 2 and 4;
 keylegend / location=inside position=topright across=1 title='Metro Status'
             noborder valueattrs=(family='Georgia');
run;

/***Program and Output 3.5.1 and 3.5.2***/
proc means data=BookData.Ipums2005Basic noprint;
 class metro;
 var HHincome;
 output out=stats mean=avg median=median;
run;
ods graphics / reset imagename='Output 3_5_2' width=4in imagefmt=tif;
*title 'Output 3.5.2: Using Statistics in SGPLOT Generated by PROC MEANS';
proc sgplot data=stats;
 hbar metro/response=median fillattrs=(color=green) legendlabel='Median'
            barwidth=.9;
 hbar metro/response=avg fillattrs=(transparency=0.3 color=orange) 
             outlineattrs=(color=black) legendlabel='Mean' barwidth=.7;
 where metro between 2 and 4;
 format metro metro.;
 xaxis label='Household Income' valuesformat=dollar8.;
 yaxis display=(nolabel);
 keylegend / position=topright across=1 location=inside 
    valueattrs=(size=8pt) noborder;
run;

/***Program and Output 3.5.3***/
ods rtf exclude summary;
ods listing close;
proc means data=BookData.Ipums2005Basic;
 class metro;
 output out=two_stats q3(MortgagePayment HomeValue)=Mort_Q3 Value_Q3;
run;
ods listing image_dpi=300;
ods graphics / reset imagename='Output 3_5_3' width=4in imagefmt=tif;
*title 'Output 3.5.3: Chart of Two Custom Statistics, Staggered with Separate Axes';
proc sgplot data=two_stats;
 hbar metro/response=Mort_Q3 legendlabel='Mortgage' barwidth=.4 discreteoffset=.2 x2axis;
 hbar metro/response=Value_Q3 legendlabel='Value' barwidth=.4 discreteoffset=-.2;
 where metro between 2 and 4;
 format metro metro.;
 xaxis label='Value Q3' valuesformat=dollar12. fitpolicy=stagger;
 x2axis label='Mortgage Q3' valuesformat=dollar8.;
 yaxis display=(nolabel);
 keylegend / position=bottomright across=1 location=inside title=''
     valueattrs=(size=8pt) noborder;
run;
 
/***Program and Output 3.5.4--Duplicate of Output 3.5.2***/
ods rtf exclude summary;
ods listing close;
proc means data=BookData.Ipums2005Basic mean median;
 class metro;
 var HHincome;
 ods output summary=ods_stats;
run;
ods listing image_dpi=300;
ods graphics / reset imagename='Output 3_5_4' width=4in imagefmt=tif;
*title 'Duplicate of Output 3.5.2';
proc sgplot data=ods_stats;
 hbar metro/response=HHincome_median fillattrs=(color=green) legendlabel='Median'
            barwidth=.9;
 hbar metro/response=HHincome_mean fillattrs=(transparency=0.3 color=orange) 
             outlineattrs=(color=black) legendlabel='Mean' barwidth=.7;
 where metro between 2 and 4;
 format metro metro.;
 xaxis label='Household Income' valuesformat=dollar8.;
 yaxis display=(nolabel);
 keylegend / position=topright across=1 location=inside;
run;


/***Program and Output 3.5.5***/
ods rtf exclude onewayfreqs;
ods listing close;
proc freq data=BookData.Ipums2005Basic;
 table MortgagePayment;
 format MortgagePayment Mort.;
 ods output OneWayFreqs=Freqs;
run;
ods listing image_dpi=300;
ods graphics / reset imagename='Output 3_5_5' width=4in imagefmt=tif;
*title 'Output 3.5.5: Chart of Cumulative Percentage Statistics from PROC FREQ';
proc sgplot data=Freqs noborder;
 vbar MortgagePayment / response=CumPercent barwidth=1;
 xaxis label='Mortgage Payment';
 yaxis label='Cumulative Percentage' offsetmax=0;
run;

/***Program and Output 3.5.6***/
proc format;
 value income
 low-<0='Negative'
 0-45000='$0 to $45K'
 45001-90000='$45K to $90K'
 90001-high='Above $90K'
 ;
run;
ods rtf exclude crosstabfreqs;
ods listing close;
proc freq data=BookData.Ipums2005Basic;
 table HHIncome*MortgagePayment;
 format HHIncome income. MortgagePayment mort.;
 where MortgagePayment gt 0 and HHIncome ge 0;
 ods output CrossTabFreqs=TwoWay;
run;
ods listing image_dpi=300;
ods graphics / reset imagename='Output 3_5_6' width=4in imagefmt=tif;
*title 'Output 3.5.6: Chart of Conditional Percentage Statistics from PROC FREQ';
proc sgplot data=TwoWay;
 hbar HHIncome / response=RowPercent group=MortgagePayment groupdisplay=cluster;
 xaxis label='Percent within Income Class' grid gridattrs=(color=gray66) values=(0 to 65 by 5) offsetmax=0;
 yaxis label='Household Income';
 keylegend / position=top title='Mortgage Payment';
 where HHIncome is not missing and MortgagePayment is not missing;
run;

/**Program 3.6.1***/
data ipums2005formatted;
 infile RawData("IPUMS2005formatted.txt");
 input Serial $7. State $25. City $40. CityPop comma6. 
       Metro 1. CountyFips 3. Ownership $6.
       MortgageStatus $40. MortgagePayment comma12. 
       HHIncome comma12. Homevalue comma12.;
run;
ods listing close;
title 'Output 3.6.1 Partial display of data set created by Program 3.6.1';
proc print data=ipums2005formatted(obs=5);
 var State CountyFips Ownership MortgageStatus HHIncome;
run;

data miss01;
   infile RawData('FlightsMiss01.txt') dsd;
   input FirstClass Destination $ EconClass;
run;

title 'Output 3.7.1: Results of Reading Input Data 3.7.1';
proc print data = miss01;
run;

data miss02;
   infile RawData('FlightsMiss02.txt') dsd;
   input FirstClass Destination $ EconClass;
run;

title 'Output 3.7.2: Results of Reading Input Data 3.7.2';
proc print data = miss02;
run;

data miss03a;
   infile RawData('FlightsMiss03.txt');
   input FirstClass 1-2 Destination $ 4-6 EconClass 8-10;
run;

title 'Output 3.7.3: Results of First Attempt at Reading Input Data 3.7.3';
proc print data = miss03a;
run;

data miss03b;
   infile RawData('FlightsMiss03.txt') missover;
   input FirstClass 1-2 Destination $ 4-6 EconClass 8-10;
run;

title 'Output 3.7.4: Results of Reading Input Data 3.7.3 Using MISSOVER';
proc print data = miss03b;
run;

data miss03c;
   infile RawData('FlightsMiss03.txt') truncover;
   input FirstClass 1-2 Destination $ 4-6 EconClass 8-10;
run;

title 'Output 3.7.5: Results of Reading Input Data 3.7.3 Using TRUNCOVER';
proc print data = miss03c;
run;

filename rawCSV  "&raw\ipums2005basic.csv";

proc import file = rawCSV  dbms = csv  out = Import01 replace;
run;

title 'Output 3.8.1: Descirptor Portion of Imported CSV Data Set';
proc contents data = Import01 varnum; 
run;

filename rawTAB  "&raw\ipums2005basic.txt";

proc import file = rawTAB dbms = tab  out = Import02 replace;
  getnames = no;
  guessingrows = 250000;
run;

title 'Output 3.8.2A: Descirptor Portion of Imported CSV Data Set';
proc contents data = Import02;
run;

title 'Output 3.8.2B: Content Portion of Imported CSV Data Set (First Five Records)';
proc print data = Import02(obs = 5);
 var var1-var3 var9-var11;
run;

proc import file = rawTAB dbms = dlm  out = Import02 replace;
  getnames = no;
  guessingrows = 250000;
  delimiter = '09'x;
run; 

proc export outfile = "IpumsOut.csv"
            dbms = csv 
            data = Import01 
            replace;
run;

/**Section 3.9**/
data Dirty2005basic;
 infile RawData('IPUMS2005Dirtied.dat') dlm='09'x dsd;
 input Serial$ City_Pop:comma. Metro CountyFips Ownership:$50. MortgageStatus:$50. HHIncome:comma.
   HomeValue:comma. City:$50. MortgagePayment:comma.;

 format HHIncome HomeValue MortgagePayment dollar16.;
run;
*title 'Program and Output 3.9.2';
ods rtf exclude onewayfreqs;
proc freq data=Dirty2005basic;
 table city;
 ods output onewayfreqs=freqs;
run;

title 'Output 3.9.2A: Partial Listing of Categories for the City Variable';
proc print data=freqs(obs=10) label noobs;
 var city--cumPercent;
run;

title 'Output 3.9.2B: Listing of Categories for the Ownership Variable';
title2 'Output 3.9.2C: Listing of Categories for the Mortgage Status Variable';
proc freq data=Dirty2005basic;
 table ownership MortgageStatus;
run;

title 'Output 3.9.3: Statistics on Mortgage Payment from IPUMS2005basic';
proc means data=Dirty2005basic n nmiss min q1 median q3 max  maxdec=1;
 var MortgagePayment;
run;

title 'Output 3.9.4: Statistics on the Non-Zero Mortgage Payments in IPUMS2005basic';
proc means data=Dirty2005basic n nmiss min p5 p10 q1 median max maxdec=1;
 var MortgagePayment;
 where MortgageStatus contains 'Yes';
run;

data IPUMS05CleanA;
 infile RawData('IPUMS2005Dirtied.dat') dlm='09'x dsd;
 input Serial$ City_Pop:comma. Metro CountyFips Ownership:$50. MortgageStatus:$50. HHIncome:comma.
   HomeValue:comma. City:$50. MortgagePayment:comma.;
 City=compress(City);
 format HHIncome HomeValue MortgagePayment dollar16.;
run;
ods rtf exclude onewayfreqs;
proc freq data=IPUMS05CleanA;
 table city;
 ods output onewayfreqs=freqs;
run;

title 'Output 3.9.5: Summary of the Updated City Variable ';
proc print data=freqs(obs=10) label noobs;
 var city--cumPercent;
run;

data IPUMS05CleanB;
 infile RawData('IPUMS2005Dirtied.dat') dlm='09'x dsd;
 input Serial$ City_Pop:comma. Metro CountyFips Ownership:$50. MortgageStatus:$50. HHIncome:comma.
   HomeValue:comma. City:$50. MortgagePayment:comma.;
 City=compbl(City);
 format HHIncome HomeValue MortgagePayment dollar16.;
run;
ods rtf exclude onewayfreqs;
proc freq data=IPUMS05CleanB;
 table city;
 ods output onewayfreqs=freqs;
run;

title 'Output 3.9.6: Summary of a Better Update to the City Variable';
proc print data=freqs(obs=10) label noobs;
 var city--cumPercent;
run;

data IPUMS05CleanC;
 infile RawData('IPUMS2005Dirtied.dat') dlm='09'x dsd;
 input Serial$ City_Pop:comma. Metro CountyFips Ownership:$50. MortgageStatus:$50. HHIncome:comma.
   HomeValue:comma. City:$50. MortgagePayment:comma.;
 City=compbl(City);
 Ownership=propcase(Ownership);
 format HHIncome HomeValue MortgagePayment dollar16.;
run;
title 'Output 3.9.7: Summary of the Modified Ownership Variable';
proc freq data=IPUMS05CleanC;
 table ownership;
run;

data IPUMS05CleanD;
 infile RawData('IPUMS2005Dirtied.dat') dlm='09'x dsd;
 input Serial$ City_Pop:comma. Metro CountyFips Ownership:$50. MortgageStatus:$50. HHIncome:comma.
   HomeValue:comma. City:$50. MortgagePayment:comma.;
 City=compbl(City);
 Ownership=propcase(Ownership);
 MortgageStatus=tranwrd(tranwrd(MortgageStatus,'\','/'),'-','/ ');
 format HHIncome HomeValue MortgagePayment dollar16.;
run;
title 'Output 3.9.8: Summary of the Modified Mortgage Status Variable';
proc freq data=IPUMS05CleanD;
 table MortgageStatus;
run;

data IPUMS05CleanE;
 infile RawData('IPUMS2005Dirtied.dat') dlm='09'x dsd;
 input Serial$ City_Pop:comma. Metro CountyFips Ownership:$50. MortgageStatus:$50. HHIncome:comma.
   HomeValue:comma. City:$50.  MortgagePayment_C$;
 City=compbl(City);
 Ownership=propcase(Ownership);
 MortgageStatus=tranwrd(tranwrd(MortgageStatus,'\','/'),'-','/ ');
 MortgagePayment=input(MortgagePayment_C,dollar20.);
 format HHIncome HomeValue MortgagePayment dollar16.;
run;
title 'Output 3.9.9: Mortgage Payment Character Values that Fail to Convert to Numeric';
proc print data=IPUMS05CleanE(obs=12);
 var MortgagePayment_C;
 where MortgagePayment eq .;
run;

data IPUMS05CleanF;
 infile RawData('IPUMS2005Dirtied.dat') dlm='09'x dsd;
 input Serial$ City_Pop:comma. Metro CountyFips Ownership:$50. MortgageStatus:$50. HHIncome:comma.
   HomeValue:comma. City:$50. MortgagePayment_C$;
 City=compbl(City);
 Ownership=propcase(Ownership);
 MortgageStatus=tranwrd(tranwrd(MortgageStatus,'\','/'),'-','/ ');
 MortgagePayment_C=tranwrd(MortgagePayment_C,'O','0');
 MortgagePayment=abs(input(MortgagePayment_C,dollar20.));
 format HHIncome HomeValue MortgagePayment dollar16.;
run;
title 'Program 3.9.10: Fixing Invalid and Negative Values for Mortgage Payment';
proc means data=IPUMS05CleanF n nmiss min median max maxdec=1;
 var MortgagePayment;
run;

proc sort data=Dirty2005basic  out=OwnerVals nodupkey;
 by ownership;
run;

proc sort data=Dirty2005basic  out=MortStatVals nodupkey;
 by MortgageStatus;
run;

title 'Output 3.9.11: Using NODUPKEY in PROC SORT for Diagnostics';
proc print data=OwnerVals;
 var ownership;
run;

proc print data=MortStatVals;
 var MortgageStatus;
run;
ods rtf close;
