// ---- Test Code ----
program drop _all
run latexlog.ado

set trace on
set tracedepth 1

local log ./log/logtest.tex
cap mkdir ./log/

latexlog `log': open

latexlog `log': title "Illustrating the use of the latexlog package"
latexlog `log': writeln "A descriptive analysis of the nlsw88.dta data"
latexlog `log': section "Introduction"
latexlog `log': writeln "This file provides examples of the use of the latexlog package."
latexlog `log': writeln "The data used in this example is the nlsw88.dta data set, which is a sample data set provided with Stata."

latexlog `log': section "Summary Statistics"

sysuse nlsw88, clear

local var wage
scatter `var' ttl_exp
latexlog `log': addfig, file(./figures/scatter_`var'.pdf) ///
	float title(A scatterplot of `var' vs. experience using the addfig subcommand) notes(Based on the nlsw88.dta data) eol width(.8)

latexlog `log': subfigure , open ///
	title(Four Scatterplots of different variables vs. experience using the subfigure subcommand)
foreach var in wage hours tenure grade {
	scatter `var' ttl_exp , ylabel(,angle(vertical))
	local cap : variable label `var'
	latexlog `log': subfigure , addfig file(./figures/scatter_`var'.pdf) ///
		caption("`cap' vs. experience")   width(.45)
}
latexlog `log': subfigure , close notes(Based on the nlsw88.dta data)

latexlog `log': subfigure , open ///
	title(Four Scatterplots of different variables vs. experience using the subfigure subcommand)
levelsof industry, local(industries)
foreach ind of local industries {
    local ind_label : label (industry) `ind'
    scatter wage ttl_exp if industry == `ind', ylabel(,angle(vertical))
    latexlog `log': subfigure , addfig file(./figures/scatter_wage_ind`ind'.pdf) ///
        caption("Wage vs. Total Experience for `ind_label'")   width(.3)
}

latexlog `log': subfigure , close notes(Based on the nlsw88.dta data)

latexlog `log': writeln "\clearpage\pagebreak"	
	

latexlog `log': section "Saving Tables with latexlog"

latexlog `log': writeln "Since latexlog operates directly on a tex file, it is easy to save "
latexlog `log': writeln "tables created with the \textbf{esttab} command or other commands that "
latexlog `log': writeln "produce latex output that is appended to a file."

// Check if esttab command is available
capture which esttab
if _rc {
    latexlog `log': writeln "Note: The esttab command is not installed. The following example requires the estout package."
    latexlog `log': writeln "To install, run: ssc install estout"
    latexlog `log': writeln "Skipping the esttab example."
}
else {
	latexlog `log': writeln "Here is an example of saving a table created with the esttab command:"
	latexlog `log': writeln " "
	latexlog `log': writeln "\vspace{10pt}"
	g logwage = log(wage)
	label var logwage "Log Wage"
	eststo clear
	eststo: regress logwage ttl_exp
	esttab using `log', booktabs append float ///
		title(`"Table using Stata "esttab" command to directly append to the log file"')
	latexlog `log': writeln ""
	latexlog `log': writeln "\vspace{10pt}"
}

latexlog `log': writeln "Stata's table command is very flexible and powerful. "
latexlog `log': writeln "The following example creates a twoway table of the number workers in each occupation and union category "
latexlog `log': writeln "using Stata's \textbf{table} command. "
latexlog `log': writeln "This table is then saved to the log file using the \textbf{collect export} subcommand."

table occupation union, nototals

latexlog `log': collect export , ///
	title(Table using Stata "table" command and latexlog "collect export" subcommand) ///
	booktabs novert notes(Command: table occupation union, nototals) three

estimates clear
qui: regress logwage ttl_exp
estimates store model1
qui: regress logwage ttl_exp grade married
estimates store model2
etable, estimates(model1 model2) mstat(N) mstat(r2_a)
latexlog `log': collect export , ///
	title(Regression Table using Stata "etable" command and latexlog "collect export" subcommand) ///
	booktabs novert notes(Command: etable, estimates(model1 model2) mstat(N) mstat(r2\_a)) ///
	threeparttable

latexlog `log': close
latexlog `log': pdf, view

