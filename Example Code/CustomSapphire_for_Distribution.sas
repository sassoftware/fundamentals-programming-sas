libname BookData "--insert path to SAS data sets/BookData library here if not already assigned--";

proc template;
 define style customSapphire/store=Bookdata.Template;
    parent = styles.sapphire;
 class Header / 
    backgroundcolor=CXdae4f3;
 class Footer / 
    backgroundcolor=CXdae4f3;
 class RowHeader / 
    backgroundcolor=CXdae4f3;
 class RowFooter / 
    backgroundcolor=CXdae4f3;
    class graph / attrpriority="none";
    
    class GraphColors /
       'gtext' = black
       'gtextt' = black
       'greferencelines'= cx808080
       'gborderlines' = cx000000
       'goutlines'= cx000000
       'ggrid'= CX797c7e
       'gaxis'= cx000000;

    style table from table /
    borderwidth=3px
    cellpadding=3pt
    borderspacing=.05pt
    frame=box
    bordercolor=cx919191
    bordercollapse=collapse;

    class GraphBorderLines / lineThickness=2px color=CX000000;
    class GraphAxisLines / lineThickness=2px color=CX000000;
    class GraphOutLines / lineThickness=2px color=cx000000;
    class GraphAnnoLines / lineThickness=2px color=cx000000;
    class GraphReference / lineThickness=2px color=cx000000;
    class GraphWalls / lineThickness=2px;
    class GraphDataDefault / lineThickness=2px;
    class GraphBoxWhisker / lineThickness=2px;
    class GraphBoxMedian / lineThickness=2px;
    class GraphOther / lineThickness=2px;
    class GraphConfidence / lineThickness=2px;
    class GraphAnnoShape / lineThickness=2px;
    class GraphDataNodeDefault /
       linethickness = 2px
       linestyle = 1;
    class GraphOutliers / linethickness=2px linestyle=1;
    class GraphGridLines / lineThickness=2px linestyle = 1 color=cx000000;
end;

run;
