// ---- Test Code ----
program drop _all

set trace on
set tracedepth 2

local log ./log/logtest.tex
cap mkdir ./log/

latexlog `log': open

latexlog `log': title "A descriptive analysis of the auto.dta data"
latexlog `log': section "Introduction"
latexlog `log': writeln "This file provides examples of the use of the latexlog package."
latexlog `log': writeln "The data used in this example is the auto.dta data set, which is a sample data set provided with Stata."

latexlog `log': section "Summary Statistics"

sysuse auto, clear

local var price
scatter `var' weight
latexlog `log': addfig, file(scatter_`var'.pdf) ///
	float title(A scatterplot of `var' vs. weight using the addfig subcommand) notes(Based on the auto.dta data) eol width(.8)

latexlog `log': subfigure , open title(Four Scatterplots of different variables vs. weight using the subfigure subcommand)
foreach var in price gear_ratio trunk displacement {
	scatter `var' weight
	local cap : variable label `var'
	latexlog `log': subfigure , addfig file(scatter_`var'.pdf) ///
		caption("`cap' vs. weight")   width(.4)
}
latexlog `log': subfigure , close notes(Based on the auto.dta data)

latexlog `log': writeln "\clearpage\pagebreak"	
	

latexlog `log': section "Saving Tables with latexlog"

latexlog `log': writeln "Since latexlog operates directly on a tex file, it is easy to save "
latexlog `log': writeln "tables created with the esttab command or other commands that "
latexlog `log': writeln "produce latex output that is appended to a file."
latexlog `log': writeln "Here is an example of saving a table created with the esttab command:"
latexlog `log': writeln " "
latexlog `log': writeln "\vspace{10pt}"
eststo clear
eststo: regress price mpg
esttab using `log', booktabs append
latexlog `log': writeln ""
latexlog `log': writeln "\vspace{10pt}"

latexlog `log': writeln "Stata's table command is very flexible and powerful. "
latexlog `log': writeln "The following example creates a table of the number of foreign and domestic cars "
latexlog `log': writeln "in each MPG category using Stata's table command. "
latexlog `log': writeln "This table is then saved to the log file using the collect export subcommand."

recode mpg ///
    (0/25 = 1 "Ineffcient") ///
    (25/35 = 2 "Moderate") ///
    (35/max = 3 "Efficient") ///
    , gen(mpgcat) label(mpgcat)

label var mpgcat "MPG category"

g heavy = weight>=3000
label var heavy "Weight >=3000 lbs"

table (foreign heavy) (mpgcat) , nototals


latexlog `log': collect export , title(Two Way Table using Stata "table" command and latexlog "collect export" subcommand) booktabs novert notes(more notes) three


quietly: regress price mpg weight
estimates store model1
quietly: regress price i.foreign 
estimates store model2
etable, estimates(model1 model2) mstat(N) mstat(r2_a)
latexlog `log': collect export , title(Regression Table using Stata "etable" command and latexlog "collect export" subcommand) booktabs novert

latexlog `log': close
latexlog `log': pdf, view

