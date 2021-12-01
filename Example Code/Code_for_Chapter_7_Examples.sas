/**
Written to accompany Fundamentals of Programming in SAS: A Case Studies Approach

This file contains all code necessary to produce every output in Chapter 7 and is
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
        nodate nonumber ls=200 validvarname=any;
title;
footnote;
ods exclude none;
ods listing close;

ods rtf file='Chapter 7 Tables.rtf' 
        style=customsapphire 
        ;
/**Program 7.3.1**/
data UtilityA2005v1;
  infile rawdata('Utility2005ComplexA.txt') missover ;
  input Serial 
        / cost : comma.
        / Utility : $11.;
  label Cost='Utility Cost' Utility='Utility Type';
  format cost dollar8.;
run;

title 'Output 7.3.1: Creating a Single SAS Observation From Three Raw Records';
proc print data = UtilityA2005v1(obs = 4) label noobs;
run;

/**Program 7.3.2**/
data UtilityA2005v2;
  infile rawdata('Utility2005ComplexA.txt') missover;
  input Serial 
        #3 Utility : $11.
        #2 cost : comma.;
  label Cost='Utility Cost' Utility='Utility Type';
  format cost dollar8.;
run;

title 'Output 7.3.2: Duplicate of Output 7.3.1';
proc print data = UtilityA2005v2(obs = 4) label noobs;
run;

/**Program 7.3.3**/
data UtilityA2005v3;
  infile rawdata('Utility2005ComplexA.txt') missover;
  input serial 
        #2 Electric : comma.
        #5 Gas : comma.
        #8 Water : comma. 
        #11 Fuel : comma.
        #12 ;
  label Serial = 'Serial'
        Electric = 'Electric Cost'
        Gas = 'Gas Cost'
        Water = 'Water Cost'
        Fuel = 'Fuel Cost'
        ;
  format Electric Gas Water Fuel dollar7.;
run;

title 'Output 7.3.3: Creating a Single SAS Observation From Twelve Raw Records';
proc print data = UtilityA2005v3(obs = 4) label noobs;
  var serial Electric Gas Water Fuel;
run;

/**Program 7.3.4**/
data UtilityB2005v1;
  infile rawdata('Utility2005ComplexB.txt') truncover;
  input serial 
        #2 @10 Utility $11. @1 cost comma7.;
run;

title 'Output 7.3.4: Duplicate of Output 7.3.1';
proc report data = UtilityA2005v1(obs = 4);
  column serial cost Utility;
  define serial / display  'Serial';
  define cost / display format= dollar7. 'Utility Cost';
  define Utility / display 'Utility Type';
run;

/**Program 7.3.5**/
data UtilityC2005;
  infile rawdata('Utility2005ComplexC.txt') dsd;
  input serial Utility : $11. cost : comma. @@;
run;

/**Program 7.3.6**/
data UtilityD2005v1;
  infile rawdata('Utility2005ComplexD.txt') dsd;
  input serial @;
  input Utility : $11. cost : comma. @;
  output;
  input Utility : $11. cost : comma. @;
  output;
  input Utility : $11. cost : comma. @;
  output;
  input Utility : $11. cost : comma. @;
  output;
run;

/**Program 7.3.7**/
data UtilityD2005v1(drop = i);
  infile rawdata('Utility2005ComplexD.txt') dsd;
  input serial @;
  do i = 1 to 4;
    input Utility : $11. cost : comma. @;
    output;
  end;
run;

/**Program 7.3.8**/
data UtilityD2005v2(drop = i Utility);
  infile rawdata('Utility2005ComplexD.txt') dsd;
  input serial @;
  array cost[4] Electric Gas Water Fuel;
  
  do i = 1 to 4;
    input Utility : $11. cost[i] : comma. @;
  end;
run;

/**Program 7.3.9**/
data UtilityE2005v1;
  infile rawdata('Utility2005ComplexE.txt') dsd missover;
  input serial Utility : $11. cost : comma. @;
  do while(not missing(cost));
    output;
    input Utility : $11. cost : comma. @;
  end;
run;

Title 'Output 7.3.9: Reading Raw Records When the Number of Variables is not Constant';
proc report data = UtilityE2005v1(obs = 4);
  columns serial Utility cost;
  define serial / display 'Serial';
  define Utility / display 'Utility Type';
  define cost / display format= dollar7. 'Utility Cost';
run;

/**Program 7.3.10**/
proc transpose data = UtilityE2005v1 
               out = UtilityE2005Wide(drop = _name_);
  by serial;
  id Utility;
  var cost;
run;

title 'Output 7.3.10: Applying PROC TRANSPOSE to the Results of Program 7.4.9';
proc report data = UtilityE2005Wide(obs = 4);
  columns serial Electric Gas Water Fuel;
  define serial   / display 'Serial';
  define Electric / display format= dollar7. 'Electric Cost';
  define Gas      / display format= dollar7. 'Gas Cost';
  define Water    / display format= dollar7. 'Water Cost';
  define Fuel     / display format= dollar7. 'Fuel Cost';
run;

/**Program 7.3.11**/
data UtilityE2005v2;
  infile rawdata('Utility2005ComplexE.txt') dsd missover;
  input serial Utility : $11. cost : dollar7. @;
  do while(not missing(cost));
    select(Utility);
      when('Electricity') electric = cost;
      when('Gas') gas = cost;
      when('Water') water = cost;
      when('Fuel') fuel = cost;
      otherwise putlog 'QCNOTE: Unknown value for Utility' Utility=;
    end;
    input Utility : $11. cost : dollar7. @;
  end;
  output;
  drop Utility cost;
run;

/**Program 7.4.1**/
data ipums2005Utility;
  infile RawData('Utility Cost 2005.txt') dlm='09'x dsd firstobs=4;
  input serial electric:comma. gas:comma. water:comma. fuel:comma.;
  format electric gas water fuel dollar.;
  if electric ge 9000 then electric=.;
  if gas ge 9000 then gas=.;
  if water ge 9000 then water=.;
  if fuel ge 9000 then fuel=.;
run;
 
proc transpose data=ipums2005Utility  out=Utility2005Vert(rename=(col1=Cost _name_=Utility));
  by serial;
  var electric--fuel;
run;

data Totals;
  set Utility2005Vert;
  Tot1 = Tot1 + Cost;
  Tot2 = sum(Tot2, Cost);
  retain Tot3 0;
  Tot3 = sum(Tot3, Cost);
run;

title 'Output 7.4.1: Comparing Running Total Variables from Program 7.4.1';
proc print data = Totals(obs = 5);
run;

/**Program 7.4.2**/
data WOCF;
  set Utility2005Vert;
  retain MaxCost 0 MaxUtility;

  if Cost ge MaxCost then do;
    MaxUtility = Utility;
    MaxCost = Cost;
  end;
run;

title 'Output 7.4.2: Carrying Forward the Highest Obseved Cost';
proc print data = WOCF(obs = 6);
run;

/**Program 7.4.3**/
data WOCFLast;
  set Utility2005Vert end = Last;
  retain MaxCost 0 MaxUtility;

  if Cost ge MaxCost then do;
    MaxUtility = Utility;
    MaxCost = Cost; 
    end;
  if Last = 1;
run;

title 'Output 7.4.3: Viewing the Maximum Value and Corresponding Utility for the Full Data Set';
proc report data = WOCFLast;
  columns MaxCost MaxUtility;
  define MaxCost    / display 'Highest Cost';
  define MaxUtility / display 'Utility';
run;

/**Program 7.4.4**/
data DataSum;
  set Utility2005Vert;
  Tot1 = Tot1 + Cost;
  Tot2 = sum(Tot2, Cost);
  retain Tot3 0;
  Tot3 = sum(Tot3, Cost);
  Tot4 + Cost;
run;

title 'Output 7.4.4: DATA Step Sum Statement versus Other Running Total Calculation Methods';
proc print data = DataSum(obs = 5);
run;

/**Program 7.4.5**/
data UtilityE2005v2;
  infile rawdata('Utility2005ComplexE.txt') dsd missover;
  input serial Utility : $11. cost : dollar7. @;
  do while(not missing(cost));
    select(Utility);
      when('Electricity') electric = cost;
      when('Gas') gas = cost;
      when('Water') water = cost;
      when('Fuel') fuel = cost;
      otherwise;
    end;
    UtilityCount + 1;
    input Utility : $11. cost : dollar7. @;
  end;
  output;
  call missing(UtilityCount);
  drop Utility cost;
run;

Title 'Output 7.4.5: ';
proc report data = UtilityE2005v2(obs = 4);
  columns serial Electric Gas Water Fuel UtilityCount;
  define serial   / display 'Serial';
  define Electric / display format= dollar7. 'Electric Cost';
  define Gas      / display format= dollar7. 'Gas Cost';
  define Water    / display format= dollar7. 'Water Cost';
  define Fuel     / display format= dollar7. 'Fuel Cost';
  define UtilityCount / display;
run;

/**Program 7.4.6**/
data Subtotals;
  set Utility2005Vert;
  by serial;

  if first.serial eq 1 then call missing(TotalCost);
  TotalCost + Cost;

  first = first.serial;
  last = last.serial;
run;

title 'Output 7.4.6: Displaying the Values of FIRST.Serial and LAST.Serial';
proc report data = subtotals(obs = 6);
  columns serial Utility cost totalcost first last;
  define serial     / display 'Serial';
  define Utility    / display 'Utility';
  define Cost       / display 'Cost';
  define TotalCost  / display 'Cumulative Expense';
  define first      / display 'FIRST.Serial';
  define last       / display 'LAST.Serial';
run;

/**Program 7.4.7**/
proc sort data=sashelp.cars out=cars;
 by make type drivetrain origin;
run;

data carsFirstLast;
 set cars;
 by make type drivetrain;

 FMake=first.make;
 LMake=last.make;
 FType=first.type;
 LType=last.type;
 FDrive=first.drivetrain;
 LDrive=last.drivetrain;

 keep make model type drivetrain FMake--LDrive;
 rename drivetrain=drive;
run;

options ls=200;
proc print data=cars(firstobs=24 obs=28);
run;

proc print data=cars(firstobs=217 obs=221);
run;

/**Program 7.4.8**/
proc sort data=bookdata.ipums2005basic out=Basic2005;
  by state metro mortgageStatus;
  where HomeValue lt 9999999;
run;

data HomeValueStats(drop = homeValue);
  set Basic2005;
  by state metro mortgageStatus;
  retain MaxValue .;

  if first.mortgageStatus then call missing(TotalValue, MaxValue);
  TotalValue+HomeValue;
  if HomeValue gt MaxValue then MaxValue = HomeValue;
  if last.mortgageStatus;
run;

title 'Output 7.4.8: Viewing the Within-Group Maximum and Total HouseValue Amounts.';
proc report data = HomeValueStats(obs = 6);
  columns state metro mortgageStatus MaxValue TotalValue;
  define state          / order 'State';
  define metro          / order 'Metro';
  define mortgageStatus / order 'Mortgage Status';
  define Maxvalue       / display 'Maximum Home Value' format=dollar10.;
  define Totalvalue     / display 'Total Home Value' format=dollar12.;
run;

/**Program 7.5.1**/
data ipums2005cost;
  merge BookData.ipums2005basic ipums2005Utility;
  by serial;
  if homevalue eq 9999999 then homevalue=.;
  if electric ge 9000 then electric=.;
  if gas ge 9000 then gas=.;
  if water ge 9000 then water=.;
  if fuel ge 9000 then fuel=.;
run;

proc format;
  value $Mort_Status
    'No'-'Nz'='No'
    'Yes'-'Yz'='Yes'
  ;
run;

title 'Output 7.5.1:  Adding Styles in the PROC REPORT Statement';
proc report data=ipums2005cost 
            style(header)=[fontfamily='Arial Black' 
                           backgroundcolor=gray55  
                           color=white]
            style(column)=[fontfamily='Georgia' backgroundcolor=grayDD fontsize=10pt] 
            style(summary)=[backgroundcolor=grayAA fontweight=bold fontstyle=italic];
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

/**Program 7.5.2**/
title 'Output 7.5.2:  Adding Styles in DEFINE, BREAK, or RBREAK Statements';
proc report data=ipums2005cost 
            style(header)=[fontfamily='Arial Black' backgroundcolor=gray55 color=white]
            style(column)=[fontfamily='Georgia' backgroundcolor=grayDD fontsize=10pt] 
            style(summary)=[backgroundcolor=grayAA fontweight=bold fontstyle=italic];
  where state in ('North Carolina','South Carolina');
  column state mortgageStatus electric,(n median mean std);
  define state / group 'State' style(header)=[fontsize=14pt]
                              style(column)=[fontfamily='Arial' backgroundcolor=white];
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define electric / '';
  define n / 'Number of Observations' format=comma8.;
  define median /  'Median Electricity Cost' format=dollar10.;
  define mean /  'Mean Electricity Cost' format=dollar10.;
  define std /  'Standard Deviation' format=dollar10.;
  break after state / summarize;
  rbreak after / summarize  style=[backgroundcolor=gray88];
run;

/**Program 7.5.3**/
title 'Output 7.5.3:  Changing Physical Sizes Using Style Options';
proc report data=ipums2005cost 
            style(header)=[fontfamily='Arial Black' backgroundcolor=gray55 color=white fontsize=10pt]
            style(column)=[fontfamily='Georgia' backgroundcolor=grayDD fontsize=10pt cellwidth=.90in] 
            style(summary)=[backgroundcolor=grayAA fontweight=bold fontstyle=italic];
  where state in ('North Carolina','South Carolina');
  column state mortgageStatus electric,(n median mean std);
  define state / group 'State' 
        style(column)=[cellwidth=1.2in];
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define electric / '';
  define n / 'Number of Observations' format=comma8.
        style(column)=[cellwidth=1.1in];
  define median /  'Median Electricity Cost' format=dollar10.;
  define mean /  'Mean Electricity Cost' format=dollar10.;
  define std /  'Standard Deviation' format=dollar10.;
  break after state / summarize;
  rbreak after / summarize style=[backgroundcolor=gray88];
run;

/**Program 7.5.4**/
proc format;
  value costR
    1500-high=cxFF0000
  ;
  value Rbold
    1500-high=bold
  ;
run;

title 'Output 7.5.4:  Setting Styles Conditionally Using Formats';
proc report data=ipums2005cost 
            style(header)=[fontfamily='Arial Black' backgroundcolor=gray55 color=white]
            style(column)=[fontfamily='Georgia' backgroundcolor=grayDD fontsize=10pt] 
            style(summary)=[backgroundcolor=grayAA fontweight=bold fontstyle=italic];
  where state in ('North Carolina','South Carolina');
  column state mortgageStatus electric,(n median mean std);
  define state / group 'State';
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define electric / '';
  define n / 'Number of Observations' format=comma8.;
  define median /  'Median Electricity Cost' format=dollar10.
               style(column)=[color=costR. fontweight=Rbold.];
  define mean /  'Mean Electricity Cost' format=dollar10.
               style(column)=[color=costR. fontweight=Rbold.];
  define std /  'Standard Deviation' format=dollar10.;
  break after state / summarize;
  rbreak after / summarize;
run;

proc template;
 list styles;
run;

/**Program 7.5.5**/
ods rtf style=journal;
title 'Output 7.5.5:  Using an Existing Style Template';
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

/**Program 7.5.6**/
ods rtf style=customsapphire;
title 'Output 7.5.6:  Computing a New Column in PROC REPORT';
proc report data=ipums2005cost;
  where state in ('North Carolina','South Carolina');
  column state mortgageStatus electric=num electric=mid electric=avg ratio electric=std ;
  define state / group 'State';
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define electric / '';
  define num / n 'Number of Observations' format=comma8.;
  define mid / median 'Median Electricity Cost' format=dollar10.;
  define avg / mean  'Mean Electricity Cost' format=dollar10.;
  define ratio / computed 'Mean to Median Ratio' format=percent9.2;
  define std / std 'Standard Deviation' format=dollar10.;
  break after state / summarize;
  rbreak after / summarize;
 
  compute ratio;
    ratio=avg/mid;
  endcomp;
run; 

/**Program 7.5.7**/
title 'Output 7.5.7:  References to Summary Values Not Defined Via an Alias';
proc report data=ipums2005cost;
  where state in ('North Carolina','South Carolina');
  column state mortgageStatus electric,(n median mean std) ratio;
  define state / group 'State';
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define electric / '';
  define n / 'Number of Observations' format=comma8.;
  define median /  'Median Electricity Cost' format=dollar10.;
  define mean /  'Mean Electricity Cost' format=dollar10.;
  define std /  'Standard Deviation' format=dollar10.;
  define ratio / computed 'Mean to Median Ratio' format=percent9.2;
  break after state / summarize;
  rbreak after / summarize;

  compute ratio;
    ratio=electric.mean/electric.median;
  endcomp;
run; 

/**Program 7.5.8**/
proc format;
  value MetroStatus
    0 = "Unknown"
    1 = "Non-Metro"
    2-4 = "Metro"
  ;
run;

title 'Output 7.5.8:  Referencing Columns Implicitly Defined';
proc report data=ipums2005cost;
  where state in ('North Carolina','South Carolina') and metro ge 1;
  column mortgageStatus electric,state,metro NonMetroDiff MetroDiff;
  define state / across 'Mean Electricity Costs';
  define metro / across '' format=MetroStatus. order=internal;
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define electric / mean '' format=dollar10.;
  define NonMetroDiff / computed 'Non-Metro Diff (SC-NC)' format=dollar10.2; 
  define MetroDiff / computed 'Metro Diff (SC-NC)' format=dollar10.2; 

  compute NonMetroDiff;
    NonMetroDiff=_c4_-_c2_;
  endcomp;
  compute MetroDiff;
    MetroDiff=_c5_-_c3_;
  endcomp;
run;

/**Program 7.5.9**/
title 'Output 7.5.9:  Inserting Spanning Headers in the COLUMN Statement';
proc report data=ipums2005cost;
  where state in ('North Carolina','South Carolina') and metro ge 1;
  column mortgageStatus electric,state,metro ('Diff. (SC-NC)' ('' (NonMetroDiff MetroDiff)));
  define state / across 'Mean Electricity Costs';
  define metro / across '' format=MetroStatus. order=internal;
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define electric / mean '' format=dollar10.;
  define NonMetroDiff / computed 'Non-Metro' format=dollar10.2; 
  define MetroDiff / computed 'Metro' format=dollar10.2; 

  compute NonMetroDiff;
    NonMetroDiff=_c4_-_c2_;
  endcomp;
  compute MetroDiff;
    MetroDiff=_c5_-_c3_;
  endcomp;
run;

/**Program 7.5.10**/
proc format;
  value misspct
    .=' '
    other=[percent8.1]
  ;
run;

title 'Output 7.5.10:  Conditional Logic and Various Targets in Compute Blocks';
proc report data=ipums2005cost out=check style(column)=[backgroundcolor=grayF3];
  where state in ('North Carolina','South Carolina','Virginia');
  column state mortgageStatus electric=num pct electric=mid electric=avg  electric=std ;
  define state / group 'State';
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define electric / '';
  define num / n 'Number of Observations' format=comma8.;
  define pct / computed '% of Obs.' format=misspct.;
  define mid / median 'Median Electricity Cost' format=dollar10.;
  define avg / mean  'Mean Electricity Cost' format=dollar10.;
  define std / std 'Standard Deviation' format=dollar10.;
  break after state / summarize suppress style=[backgroundcolor=grayD3];
  rbreak after / summarize style=[backgroundcolor=grayB9];

  compute before;
    tot=num;
  endcomp;
  compute before state;
    grptot=num;
  endcomp;
  compute pct;
    if lowcase(_break_) eq 'state' then pct=num/tot;
      else if _break_ eq '' then pct=num/grptot;
        else pct=.;
  endcomp;
run; 

/**Program 7.5.11**/
title 'Output 7.5.11:  Erroneous Conditioning on the Values of a Group Variable';
proc report data=ipums2005cost out=check style(column)=[backgroundcolor=grayF3];
  where state in ('North Carolina','South Carolina');
  column state mortgageStatus electric=num electric=mid electric=avg projMed projAvg;
  define state / group 'State';
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define electric / '';
  define num / n 'Number of Observations' format=comma8.;
  define mid / median 'Median Electricity Cost' format=dollar10.;
  define avg / mean  'Mean Electricity Cost' format=dollar10.;
  define projMed / computed 'Projected Median' format=dollar12.2;
  define projAvg / computed 'Projected Mean' format=dollar12.2;
  break after state / summarize suppress style=[backgroundcolor=grayD3];
  rbreak after / summarize style=[backgroundcolor=grayB9];

  compute projAvg;
    if substr(state,1,1) eq 'N' then do; 
      projAvg=1.03*avg;
      projMed=1.03*mid;
    end;
    else do;
      projAvg=1.02*avg;
      projMed=1.02*mid;
    end;
  endcomp;
run; 

/**Program 7.5.12**/
title 'Output 7.5.12:  Setting an Intermediate Value to Condition on the Values of a Group Variable';
proc report data=ipums2005cost out=check style(column)=[backgroundcolor=grayF3];
  where state in ('North Carolina','South Carolina');
  column state mortgageStatus electric=num electric=mid electric=avg projMed projAvg;
  define state / group 'State';
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define electric / '';
  define num / n 'Number of Observations' format=comma8.;
  define mid / median 'Median Electricity Cost' format=dollar10.;
  define avg / mean  'Mean Electricity Cost' format=dollar10.;
  define projMed / computed 'Projected Median' format=dollar12.2;
  define projAvg / computed 'Projected Mean' format=dollar12.2;
  break after state / summarize suppress style=[backgroundcolor=grayD3];
  rbreak after / summarize style=[backgroundcolor=grayB9];

  compute before state;
    st=substr(state,1,1);
  endcomp;

  compute projAvg;
    if _break_ ne '_RBREAK_' then do;
      if st eq 'N' then do; 
        projAvg=1.03*avg;
        projMed=1.03*mid;
      end;
      else if st eq 'S' then do;
        projAvg=1.02*avg;
       projMed=1.02*mid;
      end;
        else do;
          projAvg=-1;
          projMed=-1;
        end;
    end;
      else do;
        projAvg=.;
        projMed=.;
      end;
  endcomp;
run; 

/**Program 7.5.13**/
title 'Output 7.5.13:  Inserting and Styling a Text Line with a Compute Block';
proc report data=ipums2005cost 
            style(header)=[fontfamily='Arial Black' backgroundcolor=gray55 color=white]
            style(column)=[fontfamily='Georgia' backgroundcolor=grayDD fontsize=10pt] 
            style(summary)=[backgroundcolor=grayAA fontweight=bold fontstyle=italic];
  where state in ('North Carolina','South Carolina');
  column state mortgageStatus electric,(n median mean std);
  define state / group 'State';
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define electric / '';
  define n / 'N' format=comma8.;
  define median /  'Median' format=dollar10.;
  define mean /  'Mean' format=dollar10.;
  define std /  'Std. Dev.' format=dollar10.;
  break after state / summarize;
  rbreak after / summarize;

  compute before _page_/
    style=[background=gray55 color=white fontfamily='Arial Black' fontsize=14pt textalign=left];
    line 'Electricity Costs';
  endcomp;
run;

/**Program 7.5.14**/
title 'Output 7.5.14:  Inserting Replacement Values';
proc report data=ipums2005cost 
            style(header)=[fontfamily='Arial Black' backgroundcolor=gray55 color=white]
            style(column)=[fontfamily='Georgia' backgroundcolor=grayDD fontsize=10pt] 
            style(summary)=[backgroundcolor=grayAA color=black fontweight=bold fontstyle=italic];
  where state in ('North Carolina','South Carolina');
  column state mortgageStatus electric,(n median mean std);
  define state / group 'State' format=$25.;
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define electric / '';
  define n / 'N' format=comma8.;
  define median /  'Median' format=dollar10.;
  define mean /  'Mean' format=dollar10.;
  define std /  'Std. Dev.' format=dollar10.;
  break after state / summarize style=[backgroundcolor=gray77 color=grayEE];
  rbreak after / summarize;

  compute before _page_/ style=[background=gray55 color=white 
                                fontfamily='Arial Black' 
                                fontsize=14pt textalign=left];
    line 'Electricity Costs';
  endcomp;
  compute after state;
    if substr(state,1,1) eq 'N' then state='Overall: NC';
      else if substr(state,1,1) eq 'S' then state='Overall: SC';
  endcomp;
  compute after;
    state='All States';
  endcomp;
run;

/**Program 7.5.15**/
title 'Output 7.5.15:  Styling a Column Conditionally on Values in Another Column';
proc report data=ipums2005cost;
  where state in ('North Carolina','South Carolina');
  column state mortgageStatus electric,(n median mean std) ratio;
  define state / group 'State';
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define electric / '';
  define n / 'Number of Observations' format=comma8.;
  define median /  'Median Electricity Cost' format=dollar10.;
  define mean /  'Mean Electricity Cost' format=dollar10.;
  define std /  'Standard Deviation' format=dollar10.;
  define ratio / computed 'Mean to Median Ratio' format=percent9.2;
  break after state / summarize;
  rbreak after / summarize;

  compute ratio;
    ratio=electric.mean/electric.median;
    if ratio ge 1.16 then call define('_c4_','style','style=[color=cxFF3333]');
  endcomp;
run; 

/**Program 7.5.16**/
title 'Output 7.5.16:  Styling Columns and Rows Conditionally';
proc report data=ipums2005cost;
  where state in ('North Carolina','South Carolina');
  column state mortgageStatus electric,(n median mean std) ratio;
  define state / group 'State';
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define electric / '';
  define n / 'Number of Observations' format=comma8.;
  define median /  'Median Electricity Cost' format=dollar10.;
  define mean /  'Mean Electricity Cost' format=dollar10.;
  define std /  'Standard Deviation' format=dollar10.;
  define ratio / computed noprint;
  break after state / summarize;
  rbreak after / summarize;

  compute ratio;
    ratio=electric.mean/electric.median;
    if ratio ge 1.16 and _break_ eq '' then do;
      call define('_c4_','style','style=[color=cxFF3333]');
      call define('_c5_','style','style=[color=cxFF3333]');
      call define(_row_,'style','style=[backgroundcolor=grayEE]');
    end;
  endcomp;
  compute after / style=[color=cxFF3333 backgroundcolor=grayEE just=right];
    line 'Mean Exceeds Median by More than 16%';
  endcomp;
run; 

/**Program 7.5.17**/
title 'Output 7.5.17:  Changing a Format in Specific Table Cells Using CALL DEFINE';
proc report data=ipums2005cost out=check style(column)=[backgroundcolor=grayF3];
  where state in ('North Carolina','South Carolina','Virginia');
  column state mortgageStatus electric=num pct electric=mid electric=avg  electric=std ;
  define state / group 'State';
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define electric / '';
  define num / n 'Number of Observations' format=comma8.;
  define pct / computed '% of Obs.' format=misspct.;
  define mid / median 'Median Electricity Cost' format=dollar10.;
  define avg / mean  'Mean Electricity Cost' format=dollar10.;
  define std / std 'Standard Deviation' format=dollar10.;
  break after state / summarize suppress style=[backgroundcolor=grayD3];
  rbreak after / summarize style=[backgroundcolor=grayB9];

  compute before;
    tot=num;
  endcomp;
  compute before state;
    grptot=num;
  endcomp;
  compute pct;
    if lowcase(_break_) eq 'state' then do;
      pct=num/tot;
      call define('_c4_','format','percent9.2');
    end;
      else if _break_ eq '' then pct=num/grptot;
        else pct=.;
  endcomp;
run; 

/**Program 7.5.18**/
title 'Output 7.5.18:  Striping Rows Using CALL DEFINE and Modular Arithmetic';
proc report data=ipums2005cost out=check style(column)=[backgroundcolor=grayF3];
  where state in ('North Carolina','South Carolina','Virginia');
  column state mortgageStatus electric=num pct electric=mid electric=avg  electric=std ;
  define state / group 'State';
  define mortgageStatus / group 'Mortgage Status' format=$Mort_Status.;
  define electric / '';
  define num / n 'Number of Observations' format=comma8.;
  define pct / computed '% of Obs.' format=misspct.;
  define mid / median 'Median Electricity Cost' format=dollar10.;
  define avg / mean  'Mean Electricity Cost' format=dollar10.;
  define std / std 'Standard Deviation' format=dollar10.;
  break after state / summarize suppress style=[backgroundcolor=grayD3];
  rbreak after / summarize style=[backgroundcolor=grayB9];

  compute before;
    tot=num;
  endcomp;
  compute before state;
    grptot=num;
  endcomp;
  compute pct;
    if lowcase(_break_) eq 'state' then do;
      c=0;
      pct=num/tot;
      call define('_c4_','format','percent9.2');
    end;
      else if _break_ eq '' then do;
        pct=num/grptot;
        c+1;
        if mod(c,2) eq 1 then call define(_row_,'style','style=[backgroundcolor=grayF7]');
          else call define(_row_,'style','style=[backgroundcolor=grayE7]');
      end;
        else pct=.;
  endcomp;
run; 

/**Program 7.6.1**/
libname RI xlsx "&raw\Rhode Island.xlsx"; 
proc contents data=RI._all_ nods;
  ods select members;
run;

/***program 7.6.2**/
data RI05_10_15;
  set RI.'Ipums 2005 Basic'n(in = in2005)
      RI.'Ipums 2010 Basic'n(in = in2010)
      RI.'Ipums 2015 Basic'n;
  if in2005 then Year = 2005;
    else if in2010 then Year = 2010;
      else year = 2015;
run;

title;
ods listing image_dpi=300;
ods graphics/reset width=4in imagename='Output 7_6_2' imagefmt=tif;
ods rtf exclude sgpanel(persist);
*Title 'Output 7.6.2: Using Native XLSX Data in SAS';
proc sgpanel data=RI05_10_15;
  panelby Year / rows=1 novarname headerattrs=(size=12pt);
  histogram MortgagePayment / binstart=250 binwidth=500 scale=proportion 
    fillattrs=(color=cx99FF99);
  colaxis label='Mortgage Payment' valuesformat=dollar8. values=(0 to 8000 by 2000)
    fitpolicy=stagger;
  rowaxis display=(nolabel) valuesformat=percent7.;
  where MortgagePayment gt 0;
run;
libname RI clear;

/**Program 7.6.3**/
ods listing close;
libname Vermont access "&raw\Vermont.accdb"; 
Title 'Output 7.6.3: Connecting to an Access Database and Viewing Metadata with PROC CONTENTS';
proc contents data=Vermont._all_ nods;
  ods select members;
run;

/**Program 7.6.4**/
Title 'Output 7.6.4: Inspecting the Variable Names in an Access Database Table';
proc contents data=Vermont.ipums2005utility varnum;
  ods select position;
run;

/**Program 7.6.5**/
data Vermont2005cost;
  merge vermont.ipums2005basic vermont.ipums2005Utility;
  by serial;
run;

Title 'Output 7.6.5: Using Access Data Natively in SAS';
proc report data=Vermont2005cost;
  column mortgageStatus ('electric cost'n 'gas cost'n),(mean median);
  define mortgageStatus / group 'Mortgage Status';
  define 'electric cost'n / 'Elec. Cost';
  define 'gas cost'n / 'Gas Cost';
  define mean / 'Mean' format=dollar10.2;
  define median / 'Median'  format=dollar10.2;
run;
libname Vermont clear;
ods rtf close;
