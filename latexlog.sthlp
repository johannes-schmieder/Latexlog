{smcl}
{.-}
help for {cmd:latexlog} {right:(Johannes F. Schmieder)}
{.-}
 
{title:Title}

    {cmd:latexlog:} Flexible command to build latex log files from within Stata.

{title:Syntax}

{phang}
{cmd:latexlog} {it:filename} : {cmd:subcommand} [{cmd:, }{it:options}]

    where {it:filename} is the path and name of the log file and {it:subcommand} is one of the following:

    {it:subcommand}{col 34}description
    {hline 70}
    {help latexlog##main:Main}
    {cmd:open }[, {it:options}]           {col 34}Write the preamble of the latex file.
    {cmd:close }                         {col 34}Write the closing commands of the latex file.
    {cmd:pdf }[, {it:options}]            {col 34}Compile the latex file to a PDF and optionally view it.

    {help latexlog##text:Adding sections and text}
    {cmd:title "}{it:str}{cmd:"}         {col 34}Write the "{it:str}" as the title of the latex file.
    {cmd:section "}{it:str}{cmd:"}       {col 34}Write the "{it:str}" as a section heading into the latex file.
    {cmd:sections "}{it:str}{cmd:"}      {col 34}Write the "{it:str}" as an unnumbered section heading (\section*).
    {cmd:subsection "}{it:str}{cmd:"}    {col 34}Write the "{it:str}" as a subsection heading into the latex file.
    {cmd:writeln "}{it:str}{cmd:"}       {col 34}Write the "{it:str}" as a line of text into the latex file.
   

    {help latexlog##figures:Figures}
    {cmd:addfig }[, {it:options}]          {col 34}Add a figure to the latex file.
    {cmd:subfigure }[, {it:options}]       {col 34}Add a figure with subfigures to the latex file.

    {help latexlog##tables:Tables}
    {cmd:collect }[, {it:options}]         {col 34}Export a table to the latex file.

{title:Description}

    The {cmd:latexlog} command is used to build latex log files from within Stata. 
    The command is flexible and allows for a variety of different latex objects to be added to the log file.
    The command uses different subcommands to add different types of objects to the log file.
    If pdflatex is installed, the {cmd:pdf} subcommand can be used to automaticallly 
    compile the latex file to a PDF and optionally view it. 

{marker subcommands}
{title:Subcommands and Options}

{marker main}
{dlgtab:Main}

    {cmd:open }[, {it:options}] {col 34}This writes the preamble into the latex file. 
    {col 34}It uses the document class article and various standard packages.
        {it:options} are:
        {cmd:replace} {col 34}Overwrite the latex file if it already exists.
        {cmd:append} {col 34}Append to the latex file if it already exists.
        {cmd:geometry(}{it:str}{cmd:)} {col 34}Specify the geometry of the latex file. The default is a letter paper with 2.5cm margins.
        {cmd:predocopen(}{it:str}{cmd:)} {col 34}Specify additional commands to be added to the preamble of the latex file.
        {cmd:postdocopen(}{it:str}{cmd:)} {col 34}Specify additional commands to be added after the \begin{document} command.

    {cmd:close }[, {it:options}] {col 34}This writes the closing commands of the latex file.
        {it:options} are:
        {cmd:predocclose(}{it:str}{cmd:)} {col 34}Specify additional commands to be added before the \end{document} command.

    {cmd:pdf }[, {it:options}] {col 34}Compile the latex file to a PDF and optionally view it.
        {it:options} are:
        {cmd:view} {col 34}View the PDF file after it is compiled.

{marker text}
{dlgtab:Adding sections and text}

    {cmd:title "}{it:str}{cmd:"} {col 34}Write the {it:str} as the title of the latex file.
    {cmd:section "}{it:str}{cmd:"} {col 34}Write the {it:str} as a section heading into the latex file.
    {cmd:sections "}{it:str}{cmd:"} {col 34}Write the {it:str} as an unnumbered section heading (\section*) into the latex file.
    {cmd:subsection "}{it:str}{cmd:"} {col 34}Write the {it:str} as a subsection heading into the latex file.
    {cmd:writeln "}{it:str}{cmd:"} {col 34}Write the {it:str} as a line of text into the latex file. 

{marker figures}
{dlgtab:Figures}

    {cmd:addfig, filename(}{it:str}{cmd:)} [{it:options}] {col 34}Add the current graph as a figure to the latex file.
        {col 34}{it:str} is the path and name of the figure to be added. 
        {col 34}The path is relative to the log file.
        {col 34}E.g. if the log file is in ./log/ and the "{it:str}" is in "./figures/myfigure.pdf" 
        {col 34}then the figure will be stored in ./log/figures/myfigure.pdf

        {it:options} are:
        {cmd:filename(}{it:str}{cmd:)} {col 34}Specify the file name of the figure to be added.
        {cmd:float} {col 34}Float the figure to the width of the column.
        {cmd:title(}{it:str}[{cmd:, tabular}]{cmd:)} {col 34}Specify the title of the figure. Use {cmd:tabular} sub-option to wrap title in tabular for better formatting.
        {cmd:notes(}{it:str}[{cmd:, center}]{cmd:)} {col 34}Specify the notes of the figure. Use {cmd:center} sub-option to center the notes.
        {cmd:eol} {col 34}End of line -- Adds a \\ after the figure.
        {cmd:width(}{it:real}{cmd:)} {col 34}Specify the width of the figure. The default is 0.9.

    {cmd:subfigure, }{it:options} {col 34}Add a figure with subfigures to the latex file.
        {it:options} are:
        {cmd:open} {col 34}Open a subfigure environment.
        {cmd:title(}{it:str}[{cmd:, tabular}]{cmd:)} {col 34}Specify the title of the figure, to be used with {cmd:open}. Use {cmd:tabular} sub-option to wrap title in tabular.
        {cmd:close} {col 34}Close a subfigure environment.
        {cmd:notes(}{it:str}[{cmd:, center}]{cmd:)} {col 34}Specify the notes of the figure, to be used with {cmd:close}. Use {cmd:center} sub-option to center the notes.
        {cmd:addfig filename(}{it:str}{cmd:)} {col 34}Add the current graph as subfigure to the latex file.
        {col 34}{it:str} is the path and name of the figure to be added. 
        {col 34}The path is relative to the log file.
        {col 34}E.g. if the log file is in ./log/ and the "{it:str}" is in "./figures/myfigure.pdf" 
        {col 34}then the figure will be stored in ./log/figures/myfigure.pdf
        {cmd:caption(}{it:str}{cmd:)} {col 34}Specify the caption of the subfigure.
        {cmd:width(}{it:real}{cmd:)} {col 34}Specify the width of the subfigure. The default is 0.9.
        {col 34}E.g. for 2x1 subfigures (2 rows, 1 column), a good width might be 0.9.
        {col 34}For 2x2 subfigures (2 rows, 2 columns), a good width might be 0.45.
        {cmd:eol} {col 34}End of line -- Adds a \\ after the figure.

{marker tables}
{dlgtab:Tables}

    {cmd:collect }[, {it:options}] {col 34}Exports a table (i.e. a Stata collection) to the latex file.
        {col 34}The command uses the {cmd:collect export} command to export the table, but adds some 
        {col 34}additional latex code to put the table in a float environment, to add a title and notes.
        {it:options} are:
        {cmd:title(}{it:str}{cmd:)} {col 34}Specify the title of the table.
        {cmd:notes(}{it:str}{cmd:)} {col 34}Specify the notes of the table.
        {cmd:booktabs} {col 34}Use booktabs style for the table.
        {cmd:novert} {col 34}Do not draw vertical lines in the table.
        {cmd:threeparttable} {col 34}Use threeparttable style for the table.
        {cmd:fontsize(}{it:float}{cmd:)} {col 34}Specify the fontsize of the table. E.g. {cmd:fontsize(10.5)} will set the fontsize to 10.5pt.
        {cmd:landscape} {col 34}Use landscape mode for the table.
        {cmd:tabularx(}{it:col_nums}[{cmd:, width(}{it:width}{cmd:)}]{cmd:)} {col 34}Convert table to tabularx format for better column wrapping.
        {col 34}{it:col_nums} specifies which columns to make flexible (X columns).
        {col 34}E.g. {cmd:tabularx(2 3)} makes columns 2 and 3 flexible.
        {col 34}Use {cmd:width()} sub-option to set table width (default: \textwidth).

{marker examples}
{title:Example}

{space 4}{hline 10} {it:Example : Latexfile with Figures and Table} {hline 26}
{space 4}{bf:Note:} This will create a subfolder called "./log/" in your working directory 
           and save the log file there.
{space 4}{hline 80} 

{cmd}{...}
{* example_start - ex1}{...}
    local log ./log/logtest.tex
    cap mkdir ./log/
    latexlog `log': open

    latexlog `log': title "Illustrating the use of the latexlog package"
    latexlog `log': writeln "A descriptive analysis of the nlsw88.dta data"
    latexlog `log': section "Introduction"
    latexlog `log': writeln "This file provides examples of the use of the latexlog package."

    latexlog `log': section "Saving Figures"

    sysuse nlsw88, clear
    local var wage
    scatter `var' ttl_exp
    latexlog `log': addfig, filename(./figures/scatter_`var'.pdf) ///
      float ///
      title(A scatterplot of `var' vs. experience using the addfig subcommand) ///
      notes(Based on the nlsw88.dta data) eol width(.8)

    latexlog `log': subfigure , open ///
      title(Four Scatterplots of different variables vs. experience using the subfigure subcommand)
    foreach var in wage hours tenure grade {
      scatter `var' ttl_exp , ylabel(,angle(vertical))
      local cap : variable label `var'
      latexlog `log': subfigure , addfig filename(./figures/scatter_`var'.pdf) ///
        caption("`cap' vs. experience")   width(.45)
    }
    latexlog `log': subfigure , close notes(Based on the nlsw88.dta data)
    latexlog `log': writeln "\clearpage\pagebreak"	

    latexlog `log': section "Saving Tables with latexlog"
    latexlog `log': subsection "Example of a twoway table:"
    latexlog `log': writeln "The following example creates a twoway table using Stata's \textbf{table} command. "
    latexlog `log': writeln "This table is then saved to the log file using the \textbf{collect export} subcommand."

    table occupation union, nototals
    latexlog `log': collect export , ///
      title(Table using Stata "table" command and latexlog "collect export" subcommand) ///
      booktabs novert notes(Command: table occupation union, nototals) three

    latexlog `log': subsection "Example of a regression table:"
    g logwage = log(wage)
    estimates clear
    qui: regress logwage ttl_exp
    estimates store model1
    qui: regress logwage ttl_exp grade married
    estimates store model2
    etable, estimates(model1 model2) mstat(N) mstat(r2_a)
    latexlog `log': collect export , ///
      title(Regression Table using Stata "etable" command and latexlog "collect export" subcommand) ///
      notes(Command: etable, estimates(model1 model2) mstat(N) mstat(r2\_a)) ///
      threeparttable booktabs novert

    latexlog `log': close
    latexlog `log': pdf, view
{* example_end}{...}
{txt}{...}
{space 4}{hline 80}
{space 4}{it:({stata latexlog_run ex1 using latexlog.sthlp, preserve:click to run})}


{title:Author}

{p}
Johannes F. Schmieder, Boston University, USA

{p}
Email: {browse "mailto:johannes@bu.edu":johannes@bu.edu}

Comments welcome!

{title:Also see}

{p 0 21}
On-line:  help for {help table}, {help collect export}, {help graph export}
{p_end}
