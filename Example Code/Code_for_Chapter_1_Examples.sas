/**
Written to accompany Fundamentals of Programming in SAS: A Case Studies Approach

This file contains all code necessary to produce every output in Chapter 1 and is
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
ods rtf file='Chapter 1 Tables.rtf' 
        style=customsapphire 
        ;

ods rtf exclude all;
/**Program 1.3.1**/
options ps=100 ls=90 number pageno=1 nodate;
data work.cars;
  set sashelp.cars;

  mpg_combo=0.6*mpg_city+0.4*mpg_highway;

  select(type);
    when('Sedan','Wagon') typeB='Sedan/Wagon';
    when('SUV','Truck') typeB='SUV/Truck';
    otherwise typeB=type;
  end;
  
  label mpg_combo='Combined MPG' typeB='Simplified Type';
run;

title 'Combined MPG Means';
proc sgplot data=work.cars;
  hbar typeB / response=mpg_combo stat=mean limits=upper;
  where typeB ne 'Hybrid';
run;

title 'MPG Five-Number Summary';
title2 'Across Types';
proc means data=cars min q1 median q3 max maxdec=1;
  class typeB;
  var mpg:;
run;

/**Program 1.4.1**/
options ps=100 ls=90 number pageno=1 nodate;
data work.cars;
  set sashelp.cars;

  mpg_combo=0.6*mpg_city+0.4*mpg_highway;

  select(type);
    when('Sedan','Wagon') typeB='Sedan/Wagon';
    when('SUV','Truck') typeB='SUV/Truck';
    otherwise typeB=type;
  end;
  
  label mpg_combo='Combined MPG' typeB='Simplified Type';
run;

title 'Combined MPG Means';
proc sgplot data=work.cars;
  hbar typeB / response=mpg_combo stat=mean limits=upper;
  where typeB ne 'Hybrid';
run;

title 'MPG Five-Number Summary';
title2 'Across Types';
proc means data=cars min q1 median q3 max maxdec=1;
  class typeB;
  var mpg:;
run;

/**Program 1.4.2**/
title 'Combined MPG Means';
proc sgplot data=work.cars;
  hbar typeB / response=mpg_combo stat=mean limits=upper;
  where typeB ne 'Hybrid';


title 'MPG Five-Number Summary';
title2 'Across Types';
proc means data=cars min q1 median q3 max maxdec=1;
  class typeB;
  var mpg:;
run;

/**Program 1.4.3**/
data work.cars;
  set sashelp.cars;

  mpg_combo=0.6*mpg_city+0.4*mpg_highway;

  select(type);
    when('Sedan','Wagon') typeB='Sedan/Wagon';
    when('SUV','Truck') typeB='SUV/Truck';
    otherwise typeB=type;
  end;
  
  label mpg_combo='Combined MPG' type2='Simplified Type';
run;

ods rtf select all;
/**Program 1.4.4**/
title 'Output 1.4.4A: Output from PROC CONTENTS for Sashelp.Cars';
proc contents data=sashelp.cars;
run;

title 'Output 1.4.4B: Output from PROC PRINT (First 10 Rows) for Sashelp.Cars';
proc print data=sashelp.cars(obs=10) label;
  var make model msrp mpg_city mpg_highway;
run;

ods rtf exclude all;
/**Program 1.4.5**/
title 'Combined MPG Means';
proc sgplot daat=work.cars;
  hbar typeB / response=mpg_combo stat=mean limits=upper;
  where typeB ne 'Hybrid';
run;

title 'MPG Five-Number Summary';
titletwo 'Across Types';
proc means data=car min q1 median q3 max maxdec=1;
  class typeB;
  var mpg:;
run;

/**Program 1.5.1**/
ods trace on;
proc contents data=sashelp.cars;
run;

proc contents data=sashelp.cars varnum;
run;

/**Program 1.5.2**/
ods rtf select all;
title 'Output 1.5.2:  Using ODS SELECT to Subset Output';
proc contents data=sashelp.cars;
  ods select Variables;
run;

proc contents data=sashelp.cars varnum;
  ods select Position;
run;

ods rtf exclude sgplot(persist);
/**Program 1.5.3***/
title;
ods listing image_dpi = 300;
ods graphics/reset width=4in imagename='Output 1_5_3' imagefmt=png;
*title 'Output 1.5.3A&B:  Graph Delivered to PDF and PNG Destinations';
*x 'cd C:\Output';
*ods _ALL_ CLOSE;
*ods listing;
ods pdf file='Output 1-5-3.pdf';
proc sgplot data=sashelp.cars;
  styleattrs datasymbols=(square circle triangle);
  scatter y=mpg_city x=horsepower/group=type;
  where type in ('Sedan','Wagon','Sports');
run;
ods pdf close;
ods listing close;

ods  rtf select all;
/***Program 1.5.4***/
ods rtf /*file='RTF Output.rtf'*/ style=journal;
ods pdf file='PDF Output 1-5-4.pdf';
proc corr data=sashelp.cars;
  var mpg_city;
  with mpg_highway;
  ods select pearsoncorr;
run;

ods rtf exclude onewayfreqs;
proc freq data=sashelp.cars;
  table type;
run;

ods pdf exclude summary;
proc means data=sashelp.cars;
  class origin;
  var mpg_city;
run;
*ods rtf close;
ods pdf close;
ods rtf close;


 

