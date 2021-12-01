/**
Written to accompany Fundamentals of Programming in SAS: A Case Studies Approach

This file contains all code necessary to produce every output in Chapter 6 and is
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
options fmtsearch=(BookData) validvarname=v7;

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

ods rtf file='Chapter 6 Tables.rtf' 
        style=customsapphire 
        ;

ods rtf exclude sgplot(persist);
ods rtf exclude sgpanel(persist);

data ipums2005Utility;
  infile RawData('Utility Cost 2005.txt') dlm='09'x dsd firstobs=4;
  input serial electric:comma. gas:comma. water:comma. fuel:comma.;
  format electric gas water fuel dollar.;
run;
 
data ipums2005cost;
  merge BookData.ipums2005basic ipums2005Utility;
  by serial;
  if homevalue eq 9999999 then homevalue=.;
  if electric ge 9000 then electric=.;
  if gas ge 9000 then gas=.;
  if water ge 9000 then water=.;
  if fuel ge 9000 then fuel=.;
run;

/**Program 6.3.1**/
ods rtf exclude summary;
ods listing close;
proc means data=ipums2005Cost mean;
 class state;
 where state in ('North Carolina','South Carolina');
 var electric;
 ods output summary=means;
run;

data projections;
 set means;
 year=2005;
 cost=electric_mean;
 output;
 do j=1 to 10;
  year+1;
  cost=1.015*cost;
  output;
 end;
 keep state year cost;
run;

ods listing image_dpi=300;
ods graphics/reset width=4in imagename='Output 6_3_1' imagefmt=tif;
*title 'Output 6.3.1: Series Plot of Projections from DO Loop Calculations';
proc sgplot data=projections;
 series x=year y=cost / group=state lineattrs=(pattern=solid);
 yaxis label='Projected Cost';
 xaxis display=(nolabel) integer;
 keylegend / position=topleft location=inside title='' across=1;
run;

/**Program 6.3.2**/
data projections1;
  set means;
  do year=2005 to 2015 by 2;
    do rate=0.015,0.025;
      cost=electric_mean*(1+rate)**(year-2005);
      output;
     end;
  end;
  keep state year rate cost;
  format rate percent7.1;
  label rate='Growth Rate';
run;

ods graphics/reset width=4in imagename='Output 6_3_2' imagefmt=tif;
*title 'Output 6.3.2: Panel of Series Plot of Projections from Nested DO Loop Calculations';
proc sgpanel data=projections1;
 panelby rate;
 series x=year y=cost / group=state lineattrs=(pattern=solid);
 rowaxis label='Projected Cost';
 colaxis display=(nolabel) integer;
 keylegend / title='';
run;
 
/**Program 6.3.3**/
proc transpose data=means out=means2;
 var electric_mean;
 id state;
run;

data projections2;
 set means2;
 year=2005;
 output;
 do until(North_Carolina gt South_Carolina);
  year+1;
  North_Carolina=1.02*North_Carolina;
  South_Carolina=1.01*South_Carolina;
 output;
 end;
 keep year North_Carolina South_Carolina;
run;

ods graphics/reset width=4in imagename='Output 6_3_3' imagefmt=tif;
*title 'Ouput 6.3.3: Projecting Costs Conditionally Using a DO UNTIL Loop ';
proc sgplot data=projections2;
 series x=year y=North_Carolina / lineattrs=(pattern=solid);
 series x=year y=South_Carolina / lineattrs=(pattern=solid);
 yaxis label='Projected Cost';
 xaxis display=(nolabel) integer;
 keylegend / position=topleft location=inside title='' across=1;
run;

/**Program 6.3.4**/
data projections2B;
  set means2;
  year=2005;
  output;
  do while(North_Carolina le South_Carolina);
    year+1;
    North_Carolina=1.02*North_Carolina;
    South_Carolina=1.01*South_Carolina;
    output;
  end;
  keep year North_Carolina South_Carolina;
run;

/**Program 6.3.5**/
data projections3;
 set means2;
 year=2005;
 output;
 do j=1 to 15 until(North_Carolina gt South_Carolina);
  year+1;
  North_Carolina=1.016*North_Carolina;
  South_Carolina=1.012*South_Carolina;
 output;
 end;
 keep year North_Carolina South_Carolina;
run;

ods graphics/reset width=4in imagename='Output 6_3_5' imagefmt=tif;
*title 'Output 6.3.5: Using an Iterative-Conditional Loop for Multiple Stopping Rules';
proc sgplot data=projections3;
 series x=year y=North_Carolina / lineattrs=(pattern=solid);
 series x=year y=South_Carolina / lineattrs=(pattern=solid);
 yaxis label='Projected Cost';
 xaxis display=(nolabel) integer;
 keylegend / position=topleft location=inside title='' across=1;
run;

/**Program 6.4.1**/
ods rtf exclude summary;
ods listing close;
proc means data=bookdata.ipums2005basic;
 class state mortgageStatus;
 where state in ('North Carolina','South Carolina');
 var homevalue hhincome mortgagepayment;
 output out=means mean=meanHV meanHHI meanMP;
run;/***get a summary data set***/

proc sort data=bookdata.ipums2005basic out=basic;
  by state mortgagestatus;
  where state in ('North Carolina','South Carolina') 
    and scan(mortgagestatus,1) eq 'Yes';
run;

proc sort data=means;
  by state mortgagestatus;
run;

data compare;
  merge basic(in=inBasic) means(in=inMeans);
  by state mortgagestatus;
  array ratios[3] HVratio HHIratio MPratio; 
  array diffs[3];
  array means[*] mean:;
  array vals[3] homevalue hhincome mortgagepayment;
  if inMeans and inBasic;
 
  do j=1 to dim(vals);
    diffs[j]=vals[j]-means[j];
    if means[j] ne 0 then ratios[j]=vals[j]/means[j];
      else ratios[j]=.;
  end;
run;

/**Program 6.4.2**/
ods rtf exclude summary;
proc means data=ipums2005Cost mean;
  class state;
  where state in ('North Carolina','South Carolina');
  var electric;
  ods output summary=means;
run;

data projections4;
  set means;
  array rates[3] _temporary_ (0.015 0.020 0.025);
  array proj[3];
  do year=2006 to 2010;
    do j=1 to dim(rates);
      proj(j)=electric_mean*(1+rates(j))**(year-2005);
     end;
     output;
  end;
  keep state year proj:;
  format rate percent8.1;
run;/***Add a plot?***/

ods listing image_dpi=300;
ods graphics/reset width=4in imagename='Output 6_4_2' imagefmt=tif;
*title 'Output 6.4.2: Using a Temporary Array with Initial Values';
proc sgpanel data=projections4;
 panelby state / novarname;
 series x=year y=proj1 / lineattrs=(pattern=solid) legendlabel='1.5%';
 series x=year y=proj2 / lineattrs=(pattern=solid) legendlabel='2.0%';
 series x=year y=proj3 /  lineattrs=(pattern=solid) legendlabel='2.5%';
 rowaxis label='Projected Cost';
 colaxis display=(nolabel) integer;
 keylegend / title='Growth Rate' down=1;
run;

/**Program 6.4.3**/
ods rtf exclude summary;
proc means data=ipums2005cost;
  class state mortgageStatus;
  where state in ('North Carolina','South Carolina');
  var electric gas water;
  output out=stats mean=meanE meanG meanW median= medianE medianG medianW;
run;

proc sort data=ipums2005cost out=sorted2005cost;
  by state mortgagestatus;
  where state in ('North Carolina','South Carolina')
        and scan(mortgagestatus,1) eq 'Yes';
run;

proc sort data=stats;
  by state mortgagestatus;
run;

data compare2(drop= i j);
 merge sorted2005cost(in=inCost) stats(in=inStats);
 by state mortgagestatus;

 array original[3] electric gas water;
 array stats[2,3] mean: median: ;
 array diffs[2,3] EmeanDiff GmeanDiff WmeanDiff 
                  EmedianDiff GmedianDiff WmedianDiff;
 
 if inCost and inStats;
 do i=1 to 3;
  do j=1 to 2;
  diffs[j,i]=original[i]-stats[j,i];
  end;
 end;
run;

/**Program 6.5.1**/
data UtilityVertical;
  set ipums2005utility;

  array util[*] Electric -- Fuel;
  array names[4] $ _temporary_ ('electric' 'gas' 'water' 'fuel');

  do i = 1 to dim(util);
    utility = names[i];
    cost = util[i];
    output;
  end;

  format cost dollar.;
  drop electric -- fuel i;
run;

title 'Output 6.5.1: Reshaping IPUMS2005Utility with Arrays';
proc print data=UtilityVertical(obs=8) noobs;
run;

/**Input Data 6.5.2**/
proc means data = ipums2005cost noprint;
  class state;
  var electric water gas fuel;
  output out = utilityStats(where = (_type_ eq 0 or state in ('North Carolina' 'South Carolina'))) mean = Emean Wmean Gmean Fmean;
run;

data Horizontal2005UtilityStats(drop = _: i) ;
  set utilityStats;

  array statemeans[*] emean -- fmean;
  array national[*] NationalE NationalW NationalG NationalF (0 0 0 0);
  if missing(state) then do i = 1 to dim(statemeans);
      national[i] = statemeans[i];
    end;
  if not missing(state);
  label state = 'State'
        emean = 'Electric Mean' 
        gmean = 'Gas Mean' 
        wmean = 'Water mean' 
        fmean = 'Fuel Mean'
        nationale = 'National Electric Mean'
        nationalf = 'National Fuel Mean'
        nationalg = 'National Gas Mean'
        nationalw = 'National Water Mean'
  ;
run;

title 'Input Data 6.5.2: State and National Average Utility Costs';
proc print data = Horizontal2005UtilityStats noobs label;
  format Emean--NationalF dollar7.;
run;

/**Table 6.5.1 is the output from Program 6.5.4, generated below**/

/**Program 6.5.2**/
proc transpose data = horizontal2005utilitystats out = UtilityVertical;
  by State;
run;

title 'Output 6.5.2: Using BY-Processing on Input Data 6.5.2';
proc report data = UtilityVertical(obs = 5);
  columns State _Name_ Col1;
  define state / display;
  define _name_ / display 'Original Column Name';
  define Col1 / display 'Original Value';
run;

/**Program 6.5.3**/
data Utility2005Summary;
  set Horizontal2005UtilityStats;

  array StateMeans[*] Emean--Fmean;
  array national[*] NationalE -- NationalF;

  do Utility = 1 to dim(StateMeans);
    StateMean = StateMeans[Utility];
    NationalMean = National[Utility];
    Deviation = StateMean - NationalMean;
    output;
  end;
  
  keep State Utility StateMean NationalMean Deviation;
run;

title 'Output 6.5.3: Reshaping A Data Set with Arrays';
proc report data = Utility2005Summary split='*';
  columns State Utility StateMean NationalMean Deviation;
  define State / display;
  define Utility / display 'Utility';
  define StateMean / display 'State Average' format = dollar7.;
  define NationalMean / display 'National Average' format = dollar7.;
  define Deviation / display 'Difference*(State - National)' format = comma6.;
run;

/**Program 6.5.4**/
proc format;
  value util 1 = 'Electric'
             2 = 'Water'
             3 = 'Gas'
             4 = 'Fuel'
  ;
run;

data Utility2005SummaryNamed;
  set Horizontal2005UtilityStats;

  array StateMeans[*] Emean--Fmean;
  array national[*] NationalE -- NationalF;

  do i = 1 to dim(StateMeans);
    Utility = put(i, util.);
    StateMean = StateMeans[i];
    NationalMean = National[i];
    Deviation = StateMean - NationalMean;
    output;
  end;
  
  keep State Utility StateMean NationalMean Deviation;
run;

title 'Output 6.5.4: Using PROC FORMAT to Include Utility Names';
proc report data = Utility2005SummaryNamed split='*';
  columns State Utility StateMean NationalMean Deviation;
  define State / display;
  define Utility / display 'Utility';
  define StateMean / display 'State Average' format = dollar7.;
  define NationalMean / display 'National Average' format = dollar7.;
  define Deviation / display 'Difference*(State - National)' format = comma6.;
run;

/**Program 6.6.1**/
data work.ipums2005Utility;
  infile RawData('Utility Cost 2005.txt') dlm='09'x dsd firstobs=4;
  input serial electric:comma. gas:comma. water:comma. fuel:comma.;
  format electric gas water fuel dollar.;
run;
 
data work.ipums2005cost;
  merge BookData.ipums2005basic work.ipums2005Utility;
  by serial;
  if electric ge 9000 then electric=.;
  if gas ge 9000 then gas=.;
  if water ge 9000 then water=.;
  if fuel ge 9000 then fuel=.;
  total=sum(electric,gas,water,fuel);
  combustion=sum(gas,fuel);
run;

title 'Output 6.6.1: Generating a Summary Report with the GROUP Option';
proc report data=ipums2005cost;
  column mortgageStatus hhincome electric gas water fuel;
  define mortgageStatus / group;
run;

/**Program 6.6.2**/
title 'Output 6.6.2: Setting Statistics in a Summary Report';
proc report data=ipums2005cost out=test;
  column mortgageStatus hhincome electric gas water fuel;
  define mortgageStatus / group 'Mortgage Status';
  define hhincome / mean 'Avg. Household Income' format=dollar10.;
  define electric / mean 'Avg. Electricity Cost' format=dollar10.;
  define gas / mean 'Avg. Gas Cost' format=dollar10.;
  define water / mean 'Avg. Water Cost' format=dollar10.;
  define fuel / mean 'Avg. Fuel Cost' format=dollar10.;
run;

/**Program 6.6.3**/
title 'Output 6.6.3: Producing Multiple Statistics on a Single Variable Using Aliases';
proc report data=ipums2005cost;
  column mortgageStatus electric=num electric=middle electric=mean electric=sd;
  define mortgageStatus / group 'Mortgage Status';
  define num / n 'Number of Observations' format=comma8.;
  define middle / median 'Median Electricity Cost' format=dollar10.;
  define mean / mean 'Mean Electricity Cost' format=dollar10.;
  define sd / std 'Standard Deviation' format=dollar10.;
run;

/**Program 6.6.4**/
title 'Output 6.6.4A: Producing Multiple Statistics on a Single Variable by Nesting Keywords in a Variable';
proc report data=ipums2005cost;
  column mortgageStatus electric,(n median mean std);
  define mortgageStatus / group 'Mortgage Status';
  define electric / 'Electricity Cost';
  define n / 'N. Obs.' format=comma8.;
  define median / 'Median' format=dollar10.;
  define mean / 'Mean' format=dollar10.;
  define std / 'Std. Dev.' format=dollar10.;
run;

title 'Output 6.6.4B: Producing Multiple Statistics on a Single Variable by Nesting a Variable in Keywords';
proc report data=ipums2005cost;
  column mortgageStatus (n median mean std),electric;
  define mortgageStatus / group 'Mortgage Status';
  define electric / 'Electricity';
  define n / 'N. Obs.' format=comma8.;
  define median / 'Median Cost' format=dollar10.;
  define mean / 'Mean Cost' format=dollar10.;
  define std / 'Std. Dev.' format=dollar10.;
run;

/**Program 6.6.5**/
title 'Output 6.6.5:  Removing Header Labels in Nested Column Structures';
proc report data=ipums2005cost;
  column mortgageStatus electric,(n median mean std);
  define mortgageStatus / group 'Mortgage Status';
  define electric / ' ';
  define n / 'Number of Observations' format=comma8.;
  define median / 'Median Electricity Cost' format=dollar10.;
  define mean / 'Mean Electricity Cost' format=dollar10.;
  define std / 'Standard Deviation' format=dollar10.;
run;

/**Program 6.6.6**/
title 'Output 6.6.6A: Producing Multiple Statistics on Multiple Variables by Nesting Keywords in Variables';
proc report data=ipums2005cost;
  column mortgageStatus (electric gas),(mean median);
  define mortgageStatus / group 'Mortgage Status';
  define electric / 'Elec. Cost';
  define gas / 'Gas Cost';
  define mean / 'Mean';
  define median / 'Median';
run;

title 'Output 6.6.6B: Producing Multiple Statistics on Multiple Variables by Nesting Variables in Keywords';
proc report data=ipums2005cost;
  column mortgageStatus (mean median),(electric gas);
  define mortgageStatus / group 'Mortgage Status';
  define electric / 'Elec.';
  define gas / 'Gas';
  define mean / 'Mean Cost';
  define median / 'Median Cost';
run;

/**Program 6.6.7**/
title 'Output 6.6.7:  Using Aliases to Allow for Individual Column Headings';
proc report data=ipums2005cost;
  column mortgageStatus electric=midEl electric=meanEl gas=midGas gas=meanGas;
  define mortgageStatus / group 'Mortgage Status';
  define midEl / median 'Median Elec. Cost' format=dollar10.;
  define meanEl / mean 'Mean Elec. Cost' format=dollar10.;
  define midGas / median 'Median Gas Cost' format=dollar10.;
  define meanGas / mean 'Mean Gas Cost' format=dollar10.;
run;

/**Program 6.6.8**/
title 'Output 6.6.8:  Adding a Whole-Report Summary Using the RBREAK Statement';
proc report data=ipums2005cost;
  column mortgageStatus electric,(n median mean std);
  define mortgageStatus / group 'Mortgage Status';
  define electric / ' ';
  define n / 'Number of Observations' format=comma8.;
  define median / 'Median Electricity Cost' format=dollar10.;
  define mean / 'Mean Electricity Cost' format=dollar10.;
  define std / 'Standard Deviation' format=dollar10.;
  rbreak after / summarize;
run;

/**Program 6.6.9**/
proc format;
  value $Mort_Status
    'No'-'Nz'='No'
    'Yes'-'Yz'='Yes'
  ;
run;

title 'Output 6.6.9A:  Adding Summaries Using the BREAK Statement—Without the SUPPRESS Option';
proc report data=ipums2005cost;
  where state in ('North Carolina','South Carolina');
  column state mortgageStatus electric,(n median mean std);
  define state / group 'State';
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define electric / '';
  define n / 'Number of Observations' format=comma8.;
  define median /  'Median Electricity Cost' format=dollar10.;
  define mean /  'Mean Electricity Cost' format=dollar10.;
  define std /  'Standard Deviation' format=dollar10.;
  break after state / summarize;
  rbreak after / summarize;
run;

title 'Output 6.6.9B:  Adding Summaries Using the BREAK Statement—With the SUPPRESS Option';
proc report data=ipums2005cost;
  where state in ('North Carolina','South Carolina');
  column state mortgageStatus electric,(n median mean std);
  define state / group 'State';
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define electric / '';
  define n / 'Number of Observations' format=comma8.;
  define median /  'Median Electricity Cost' format=dollar10.;
  define mean /  'Mean Electricity Cost' format=dollar10.;
  define std /  'Standard Deviation' format=dollar10.;
  break after state / summarize suppress;
  rbreak after / summarize;
run;

/**Program 6.6.10**/
title 'Output 6.6.10: Using an ACROSS Variable';
proc report data=ipums2005cost;
  where state in ('North Carolina','South Carolina');
  column mortgageStatus state,(electric=num electric=middle electric=mean electric=sd);
  define state / across 'State Electricity Costs';
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define num / n 'N' format=comma8.;
  define middle / median 'Median' format=dollar10.;
  define mean / mean 'Mean' format=dollar10.;
  define sd / std 'Std. Dev.' format=dollar10.;
  rbreak after / summarize;
run;

/**both this and the previous REPORT generate the same table**/
title 'Output 6.6.10: Using an ACROSS Variable';
proc report data=ipums2005cost;
  where state in ('North Carolina','South Carolina');
  column mortgageStatus state,electric,(n median mean std);
  define state / across 'State Electricity Costs';
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define electric / '';
  define n / 'N' format=comma8.;
  define median /  'Median' format=dollar10.;
  define mean /  'Mean' format=dollar10.;
  define std /  'Std. Dev.' format=dollar10.;
  rbreak after / summarize;
run;

/**Program 6.6.11**/
proc format;
  value MetroStatus
    0 = "Unknown"
    1 = "Non-Metro"
    2-4 = "Metro"
  ;
run;

title 'Output 6.6.11:  Using Multiple ACROSS Variables';
proc report data=ipums2005cost;
  where state in ('North Carolina','South Carolina');
  column mortgageStatus state,metro,electric;
  define state / across 'State';
  define metro / across 'Metro Status' format=MetroStatus.;
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define electric / mean 'Avg. Elec. Cost' format=dollar10.;
run;

/**Program 6.6.12**/
title 'Output 6.6.12:  Improving Header Structure when Using Multiple ACROSS Variables';
proc report data=ipums2005cost;
  where state in ('North Carolina','South Carolina');
  column mortgageStatus electric,state,metro;
  define state / across 'Mean Electricity Costs';
  define metro / across '' format=MetroStatus. order=internal;
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define electric / mean '' format=dollar10.;
run;

/**Program 6.6.13**/
proc transpose data=ipums2005utility  out=Utility(rename=(col1=Cost _name_=Utility));
  by serial;
  var electric--fuel;
run;

data ipums2005cost2;
  merge BookData.ipums2005basic Utility;
  by serial;
  utility=propcase(utility);
run;

title 'Output 6.6.13:  Working with the Transposed Utility Data';
proc report data=ipums2005cost2;
  column mortgageStatus cost,Utility;
  define mortgageStatus / group 'Mortgage Status';
  define Utility / across 'Average Utility Cost';
  define cost / mean '';
  where cost lt 9000;
run;

/**Program 6.6.14**/
ods rtf exclude report;
proc report data=ipums2005cost out=reportData;
  where state in ('North Carolina','South Carolina');
  column state mortgageStatus electric,(n median mean std);
  define state / group 'State';
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define electric / '';
  define n / 'Number of Observations' format=comma8.;
  define median /  'Median Electricity Cost' format=dollar10.;
  define mean /  'Mean Electricity Cost' format=dollar10.;
  define std /  'Standard Deviation' format=dollar10.;
  break after state / summarize;
  rbreak after / summarize;
run;

title 'Output 6.6.14:  Generating an Output Data Set with PROC REPORT';
proc print data=reportData noobs label;
run;

/**Program 6.6.15**/
title;
ods listing image_dpi=300;
ods graphics/reset width=4in imagename='Output 6_6_15' imagefmt=tif;
*title 'Output 6.6.15:  Using the OUT= Data Set from PROC REPORT';
proc sgpanel data=reportData;
  panelby state / novarname;
  format mortgageStatus $Mort_Status.;
  vbar mortgageStatus / response=_c4_ legendlabel='Mean' discreteoffset=-0.2 barwidth=0.4;
  vbar mortgageStatus / response=_c5_ legendlabel='Median' discreteoffset=0.2 barwidth=0.4;
  rowaxis label='Electricity Cost';
  colaxis label='Mortgage Status' labelpos=left;
run;

/**Program 6.8.1**/
title 'Program 6.8.1: Using a Macro Variable in an Array Definition';
%let MyDim = 4;
data work.UtilityVertical;
  set work.ipums2005utility;

  array util[&MyDim] Electric -- Fuel;
  array names[&MyDim] $ _temporary_ ('electric' 'gas' 'water' 'fuel');

  do i = 1 to &MyDim;
    utility = names[i];
    cost = util[i];
    output;
  end;

  format cost dollar.;
  drop electric -- fuel i;
run;

/**Program 6.8.2**/
title 'Program 6.8.2: Formats in FORMAT Statements vs PUT Functions';
proc format;
  value util 1 = 'Electric'
             2 = 'Water'
             3 = 'Gas'
             4 = 'Fuel'
  ;
run;

data Work.Utility2005SummaryNamed;
  set BookData.Horizontal2005UtilityStats;

  array StateMeans[*] Emean -- Fmean;
  array national[*] NationalE -- NationalF;

  do Utility = 1 to dim(StateMeans);
    StateMean = StateMeans[Utility];
    NationalMean = National[Utility];
    Deviation = StateMean - NationalMean;
    output;
  end;
  format Utility Util.;
  keep State Utility StateMean NationalMean Deviation;
run;
ods rtf close;
