{smcl}
{.-}
help for {cmd:latexlog} {right:(Johannes F. Schmieder)}
{.-}

 
{title:Title}
    Creates graphs similar to tables that are produced with tabstat. For example in a panel dataset on individual workers it could produce a graph of mean wages by year and gender.

{title:Syntax}

{phang}
{cmd:cellgraph} {it:varname} [{help if}] [{help in}] , {cmd:by(}{it:byvar1 byvar2}{cmd:)}
	{break}
  [ {cmdab:c:olors}{cmd:(}{it:color1 color2 color3 ...}{cmd:)}
  {break}
  {cmdab:n:ame}{cmd:(}{it:graphname}{cmd:)}
  {break}
	{cmdab:s:tat}{cmd:(}{it:stat}{cmd:)}
	{break}
  {cmd:noci} {cmd:nonotes} {cmd:nodate} {cmdab:li:st}
  {break}
  {cmdab:msy:mbol}{cmd:(}{it:symbol}{cmd:)}
  {break}
  {cmdab:o:ptions}{cmd:(}{it:options}{cmd:)} ]

{p}

{title:Description}

{p}

Data is collapsed to cell level, where cells are defined by one or two categorical variables (byvar1 and byvar2) and cell means (or other statistics) of a third variabla ({it:varname}) are graphed.

{title:Options}

{p 0 4}{cmd:colors(}{it:color1 color2 ...}{cmd:)}:
provide a list of colors to replace standard palette.

{p 0 4}{cmd:name(}{it:graphname}{cmd:)}:
provide a graph name (just like the name option in other graph commands).

{p 0 4}{cmd:stat(}{it:statistics}{cmd:)}:
the cell statistic to be used. If not specified "mean" is assumed. Other possibilities: min max and sum.

{p 0 4}{cmd:noci}:
don't display confidence intervals.

{p 0 4}{cmd:nonotes}:
don't display any notes in legend.

{p 0 4}{cmd:nodate}:
don't display date in notes.

{p 0 4}{cmd:list}:
list collapsed data

{p 0 4}{cmd:msymbol(}{it:symbol}{cmd:)}:
Change marker symbol where {it:symbol} is of {help symbolstyle}.

{p 0 4}{cmd:options(}{it:string}{cmd:)}:
provide any twoway options to pass through to the call of the twoway command
  see the example for why this might be useful. Can also be used to overwrite options that are given as standard,
  for example options(title(My Title)) would overwrite the standard title with "My Title"

{title:Examples}

{p 8 16}{inp:. sysuse nlsw88}{p_end}

{p 8 16}{inp:. cellgraph wage, by(grade) }{p_end}

{p 8 16}{inp:. cellgraph wage, by(grade union) }{p_end}

{p 8 16}{inp:. cellgraph wage, by(grade union) stat(max)}{p_end}

{p 8 16}{inp:. cellgraph wage if industry>2 & industry<10, by(grade industry) nonotes noci options(legend(col(2)))) }{p_end}


{title:Author}

{p}
Johannes F. Schmieder, Boston University, USA

{p}
Email: {browse "mailto:johannes@bu.edu":johannes@bu.edu}

Comments welcome!

{title:Also see}

{p 0 21}
On-line:  help for {help collapse}, {help tabstat}
{p_end}
