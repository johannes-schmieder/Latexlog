
// Author: Johannes F. Schmieder
// Department of Economics, Boston University
// latexlog.ado


/*-------------------------------------------------------*/
/* Latex Log File  */
/*-------------------------------------------------------*/
capture program drop latexlog
program define latexlog

    // Parse arguments for name of logfile
    capt _on_colon_parse `0'
    if !_rc {
        local 0 `"`s(after)'"'
        local logfile `"`s(before)'"'
    }

    local logfile = ustrrtrim(`"`logfile'"')

    // Parse arguments for latexlog command
    syntax anything, *
    tokenize `"`anything'"'
    local command `1'
    local line `"`2'"'

    // Put remaining arguments back into local 0 in order to parse ///
    // it via syntax command later
    local 0 , `options'
    //   di `"`0'"'
    //   macro dir

    // File handle:
    tempname f

    // ---- Individual latexlog commands ----

    if "`command'" == "open" {
        syntax [, REPlace APPend Geometry(str) PREDOCOpen(str) POSTDOCOpen(str) ]
        if "`geometry'"=="" local geometry "lmargin=2.5cm,tmargin=2.5cm"

        if `"`append'"' == "" local replace replace
        file open `f' using `"`logfile'"', write `replace' `append'

        file write `f'  "%  `c(current_date)' `c(current_time)'" _n
        file write `f'  "\documentclass{article}" _n
        file write `f'  "\usepackage{geometry,booktabs,longtable,pdflscape,rotating,threeparttable,subcaption,graphicx,float,}" _n
		file write `f'  "\usepackage{tabularx,xcolor,colortbl,}" _n
        file write `f'  "\usepackage{hyperref}" _n
        file write `f'  "\hypersetup{                       "         
        file write `f'  "    colorlinks=true,               "                 
        file write `f'  "    linkcolor={blue!50!black},                "                
        file write `f'  "    filecolor={blue!50!black},             "                         
        file write `f'  "    urlcolor={blue!80!black},                 "               
        file write `f'  "    }                              "  
        file write `f'  "\date{}" _n
        file write `f'  "\geometry{verbose,letterpaper,`geometry'}" _n

        file write `f'  "`predocopen'" _n
        file write `f'  "\begin{document}" _n
        file write `f'  "`postdocopen'" _n

        file close `f'

    }

    if "`command'" == "close" {
        syntax [, PREDOCClose(str)]
        file open `f' using `"`logfile'"', write append

        file write `f'  "`predocclose'" _n
        file write `f'  "\end{document}" _n

        file close `f'
    }

    if "`command'" == "title" {
        file open `f' using `"`logfile'"', write append
        file write `f' `"\title{`line'}"' _n
        file write `f' `"\maketitle"' _n
        file close `f'
    }

    if "`command'" == "section" {
        file open `f' using `"`logfile'"', write append
        file write `f' `"\section{`line'}"' _n
        file close `f'
    }

    if "`command'" == "sections" {
        file open `f' using `"`logfile'"', write append
        file write `f' `"\section*{`line'}"' _n
        file close `f'
    }

    if "`command'" == "subsection" {
        file open `f' using `"`logfile'"', write append
        file write `f' `"\subsection{`line'}"' _n
        file close `f'
    }

    if "`command'" == "writeln" {
        file open `f' using `"`logfile'"', write append
        file write `f' `"`line'"' _n
        file close `f'
    }

    if "`command'" == "addfig" {
        syntax , FILEname(str) [float TITle(str) NOTES(str) notes_center WIdth(real 0.9) eol]
        splitpath "`logfile'"
        return list
        local path = r(path)
        di "`path'"
        splitpath "`filename'"
        local figpath = r(path)
        cap mkdir `path'`figpath'
        graph export `path'`filename', replace
        file open `f' using `"`logfile'"', write append

        if "`float'"=="" {
            if "`eol'"=="eol" local eol \\
            else local eol
            file write `f' `"\includegraphics[width = `width'\textwidth]{`filename'} `eol' "' _n
        }
        else {
            file write `f' `"\begin{figure}[H] "' _n
            if "`title'"!="" {
                file write `f' `"\centering "' _n
                file write `f' `"\begin{tabular}{p{6in}}"' _n
                file write `f' `"\caption{`title'} "' _n
                file write `f' `"\end{tabular}"' _n
            }
            file write `f' `"\includegraphics[width = `width'\textwidth]{`filename'} \\ "' _n
            if "`notes'"!="" {
                file write `f' `"\begin{tabular}{p{6in}}  "' _n
                file write `f' `"\footnotesize \vspace{2pt} "' _n
                // file write `f' `"\textbf{Notes}: `notes' "' _n
                if "`notes_center'"=="notes_center" ///
                    file write `f' `"  \centering \textbf{Notes:} `notes' "' _n
                else ///
                    file write `f' `"  \textbf{Notes:} `notes' "' _n
                file write `f' `"\end{tabular} "' _n
            }
            file write `f' `"\end{figure} "' _n
        }
        file close `f'
    }
	
	if "`command'" == "subfigure" {
        syntax ,  [open addfig close  FILEname(str) caption(str)  ///
			TITle(str) NOTES(str) notes_center WIdth(real 0.9) eol]
		file open `f' using `"`logfile'"', write append
			
		if "`open'"=="open" {
			file write `f' `"\begin{figure}[H] "' _n
            if "`title'"!=`""' {
                file write `f' `"\centering "' _n
                file write `f' `"\begin{tabular}{p{6in}}"' _n
                file write `f' `"  \caption{`title'} "' _n
                file write `f' `"\end{tabular}"' _n
            }
		}
		if "`addfig'"=="addfig" {
			splitpath "`logfile'"
			local path = r(path)
			di "`path'"
			splitpath "`filename'"
			local figpath = r(path)
			cap mkdir `path'`figpath'
			graph export `path'`filename', replace
			// file write `f' `"\subfigure[`caption']{"' _n			
			// // file write `f' `"\includegraphics[clip=true, trim=0 0 0 0, width = `width'\textwidth]{`filename'}  "' _n
			// file write `f' `"\includegraphics[width = `width'\textwidth]{`filename'}  "' _n
			// file write `f' `"}"' _n
            file write `f' `"\begin{subfigure}{`width'\textwidth}"' _n
            file write `f' `"  \includegraphics[width = 1.00\textwidth]{`filename'}  "' _n
            if "`caption'"!="" {
                file write `f' `"  \caption{`caption'}"' _n
            }
            file write `f' `"\end{subfigure}"' _n
		}
		if "`close'"=="close" {
			if "`notes'"!="" {
				file write `f' `"\begin{tabular}{p{6in}}  "' _n
				file write `f' `" \footnotesize \vspace{2pt} "' _n
				if "`notes_center'"=="notes_center" ///
					file write `f' `"  \centering \textbf{Notes:} `notes' "' _n
				else ///
					file write `f' `" \textbf{Notes:} `notes' "' _n
				file write `f' `"\end{tabular} "' _n
			}
			file write `f' `"\end{figure} "' _n
		}


    }

	if "`command'" == "collect" {
		syntax [,  ///
            TITle(str) ///
            NOTES(str) ///
            BOOKTabs ///
            NOVERTicallines ///
            THREEparttable ///
            FONTsize(str) ///
            LANDscape ///
            ]
		tempfile collectfile
		collect export `collectfile', tableonly replace  as(tex)

		di "`target'"
		di "`appendix'"

		tempname table

		file open `f' using `"`logfile'"', write append

        if "`landscape'"!="" {
            file write `f' `"\begin{landscape}"' _n
        }

		file write `f' `"\begin{table}[htbp] "' _n
		file write `f' `"\centering "' _n

		if "`threeparttable'"=="threeparttable" {
			file write `f' `"\begin{threeparttable} "' _n
		}


		if "`title'"!="" {
			file write `f' `"\caption{`title'} "' _n
		}
        if "`fontsize'"!="" {
            file write `f' `"\fontsize{`fontsize'}{`fontsize'}\selectfont "' _n
        }


        // Count how many vertical lines to determine when to use toprule, midrule and bottomrule
        if "`booktabs'"=="booktabs"{
                file open `table' using `collectfile', read
        		file read `table' line
        		local Ncline 0
        		while r(eof)==0 {
        			if strmatch("`line'","\cline*") local Ncline = `Ncline'+1
        			file read `table' line
        		}
        		file close `table'
        }
        // Write table to output file
        file open `table' using `collectfile', read
		file read `table' line
		local counter 1
		while r(eof)==0 {
            if strmatch("`line'","\begin{table}*") | strmatch("`line'","\end{table}") {
                    local line ""
            }
			if "`booktabs'"=="booktabs"{
				if strmatch("`line'","\cline*") {
					if `counter'==1                     local line "\toprule"
					if `counter'>1 & `counter'<`Ncline' local line "\midrule"
					if `counter'==`Ncline'              local line "\bottomrule"
					local counter = `counter'+1
				}
			}
			if "`noverticallines'"=="noverticallines" {
				local line = subinstr("`line'","|","",.)
			}

            file write `f'  "`line'" _n
			file read `table' line
		}
		file close `table'
		if `"`notes'"'!="" {
			if "`threeparttable'"=="" ///
				di in red "WARNING: 'notes' option should only be used together with 'threeparttable' "
                file write `f' `" \footnotesize  "' _n
                file write `f' `"\textbf{Notes:} `notes' "' _n
		}

		if "`threeparttable'"=="threeparttable" {
			file write `f' `"\end{threeparttable} "' _n
		}
		file write `f' `"\end{table}"' _n

        if "`landscape'"!="" {
            file write `f' `"\end{landscape}"' _n
        }

		file close `f'



    }


    if "`command'" == "pdf" {
        syntax [, view]
        splitpath "`logfile'"
        local path = r(path)
        local filestub = r(filestub)
        local fileend = r(fileend)
        local filename = r(filename)

        local pwd = c(pwd)
        cd `"`path'"'
        if "`=c(os)'"=="Windows" {
            shell pdflatex -shell-escape --src -interaction=nonstopmode `filename'
            local viewcommand start
        }
        if "`=c(os)'"=="MacOSX" {
            shell /Library/TeX/texbin/pdflatex -shell-escape --src -interaction=nonstopmode `filename'
            local viewcommand open
        }
        if "`=c(os)'"=="Unix" {
            shell /Library/TeX/texbin/pdflatex -shell-escape --src -interaction=nonstopmode `filename'
            local viewcommand open
        }
        cap erase "`path'`filestub'.aux"
        cap erase "`path'`filestub'.log"
        cap erase "`path'`filestub'.out"
        cap erase "`path'`filestub'.synctex.gz"
        cd `"`pwd'"'

        if "`view'"!="" shell `viewcommand' `path'`filestub'.pdf
    }

end // latexlog


/*-------------------------------------------------------*/
/* Unpack filepath into filename, fileending and path  */
/*-------------------------------------------------------*/
cap program drop splitpath
program define splitpath, rclass

    local fullpath `0'

    // di regexm("`fullpath'","^(([A-Z]:)?[\.]?[\\{1,2}/]?.*[\\{1,2}/])*(.+)\.(.+)")

    qui di regexm("`fullpath'","^(.*[\\/])*(.+)\.(.+)")
    cap noi local path = regexs(1)
    cap noi local filestub = regexs(2)
    cap noi local fileend  = regexs(3)
    di "Path: `path'"
    di "Filestub: `filestub'"
    di "Fileend: `fileend'"
    di "Filename: `filestub'.`fileend'"

    if "`path'"=="" return local path "./"
    else return local path "`path'"
    return local filestub "`filestub'"
    return local fileend "`fileend'"
    return local filename "`filestub'.`fileend'"

end // splitpath

