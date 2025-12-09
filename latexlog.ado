
// Author: Johannes F. Schmieder
// Department of Economics, Boston University
// latexlog.ado


/*-------------------------------------------------------*/
/* Latex Log File  */
/*-------------------------------------------------------*/
capture program drop latexlog
program define latexlog
    version 17

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
        file write `f'  "\usepackage{geometry,booktabs,longtable,pdflscape,rotating,threeparttable,subcaption,graphicx,float}" _n
		file write `f'  "\usepackage{tabularx,colortbl}" _n
        file write `f'  "\usepackage[table]{xcolor}" _n
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
    else if "`command'" == "close" {
        syntax [, PREDOCClose(str)]
        file open `f' using `"`logfile'"', write append

        file write `f'  "`predocclose'" _n
        file write `f'  "\end{document}" _n

        file close `f'
    }
    else if "`command'" == "title" {
        file open `f' using `"`logfile'"', write append
        file write `f' `"\title{`line'}"' _n
        file write `f' `"\maketitle"' _n
        file close `f'
    }
    else if "`command'" == "section" {
        file open `f' using `"`logfile'"', write append
        file write `f' `"\section{`line'}"' _n
        file close `f'
    }
    else if "`command'" == "sections" {
        file open `f' using `"`logfile'"', write append
        file write `f' `"\section*{`line'}"' _n
        file close `f'
    }
    else if "`command'" == "subsection" {
        file open `f' using `"`logfile'"', write append
        file write `f' `"\subsection{`line'}"' _n
        file close `f'
    }
    else if "`command'" == "writeln" {
        file open `f' using `"`logfile'"', write append
        file write `f' `"`line'"' _n
        file close `f'
    }
    else if "`command'" == "addfig" {
        syntax , FILEname(str) [float TITle(str asis) NOTES(str asis) WIdth(real 0.9) eol]

        // Parse title sub-options
        local title_in_tabular ""
        if `"`title'"' != "" {
            _parse comma title_text title_opts : title
            if `"`title_opts'"' != "" {
                local 0 `title_opts'
                syntax [, tabular]
                local title_in_tabular `tabular'
            }
            local title `title_text'
        }

        // Parse notes sub-options
        local notes_center ""
        if `"`notes'"' != "" {
            _parse comma notes_text notes_opts : notes
            if `"`notes_opts'"' != "" {
                local 0 `notes_opts'
                syntax [, center]
                local notes_center `center'
            }
            local notes `notes_text'
        }

        splitpath "`logfile'"
        local path = r(path)
        splitpath "`filename'"
        local figpath = r(path)
        // Strip leading ./ from figpath for Windows compatibility
        if substr("`figpath'", 1, 2) == "./" {
            local figpath = substr("`figpath'", 3, .)
        }
        cap mkdir `path'`figpath'
        mata: st_local("dir_exists", strofreal(direxists(st_local("path") + st_local("figpath"))))
        if !`dir_exists' {
            di as error "Error: Could not create directory `path'`figpath'"
            exit 693
        }
        capture noisily graph export `path'`filename', replace
        if _rc {
            di as error "Error: Could not export graph to `path'`filename'"
            if _rc == 198 {
                di as error "  No graph in memory. Create a graph before using addfig."
            }
            exit _rc
        }
        file open `f' using `"`logfile'"', write append

        if "`float'"=="" {
            if "`eol'"=="eol" local eol \\
            else local eol
            file write `f' `"\includegraphics[width = `width'\textwidth]{`filename'} `eol' "' _n
        }
        else {
            file write `f' `"\begin{figure}[H] "' _n
            if "`title'"!="" {
                if "`title_in_tabular'"=="tabular" {
                    file write `f' `"\centering "' _n
                    file write `f' `"\begin{tabular}{p{6in}}"' _n
                    file write `f' `"\caption{`title'} "' _n
                    file write `f' `"\end{tabular}"' _n
                }
                else {
                    file write `f' `"\centering "' _n
                    file write `f' `"\caption{`title'} "' _n
                }
            }
            file write `f' `"\includegraphics[width = `width'\textwidth]{`filename'} \\ "' _n
            if "`notes'"!="" {
                file write `f' `"\begin{tabular}{p{6in}}  "' _n
                file write `f' `"\footnotesize \vspace{2pt} "' _n
                if "`notes_center'"=="center" ///
                    file write `f' `"  \centering \textbf{Notes:} `notes' "' _n
                else ///
                    file write `f' `"  \textbf{Notes:} `notes' "' _n
                file write `f' `"\end{tabular} "' _n
            }
            file write `f' `"\end{figure} "' _n
        }
        file close `f'
    }
	else if "`command'" == "subfigure" {
        syntax ,  [open addfig close  FILEname(str) caption(str)  ///
			TITle(str asis) NOTES(str asis) WIdth(real 0.9) eol]

        // Parse title sub-options
        local title_in_tabular ""
        if `"`title'"' != "" {
            _parse comma title_text title_opts : title
            if `"`title_opts'"' != "" {
                local 0 `title_opts'
                syntax [, tabular]
                local title_in_tabular `tabular'
            }
            local title `title_text'
        }

        // Parse notes sub-options
        local notes_center ""
        if `"`notes'"' != "" {
            _parse comma notes_text notes_opts : notes
            if `"`notes_opts'"' != "" {
                local 0 `notes_opts'
                syntax [, center]
                local notes_center `center'
            }
            local notes `notes_text'
        }

		file open `f' using `"`logfile'"', write append

		if "`open'"=="open" {
			file write `f' `"\begin{figure}[H] "' _n
            if "`title'"!=`""' {
                file write `f' `"\centering "' _n
                if "`title_in_tabular'"=="tabular" {
                    file write `f' `"\begin{tabular}{p{6in}}"' _n
                    file write `f' `"  \caption{`title'} "' _n
                    file write `f' `"\end{tabular}"' _n
                }
                else {
                    file write `f' `"  \caption{`title'} "' _n
                }
            }
		}
		if "`addfig'"=="addfig" {
			splitpath "`logfile'"
			local path = r(path)
			splitpath "`filename'"
			local figpath = r(path)
			// Strip leading ./ from figpath for Windows compatibility
			if substr("`figpath'", 1, 2) == "./" {
				local figpath = substr("`figpath'", 3, .)
			}
			cap mkdir `path'`figpath'
			mata: st_local("dir_exists", strofreal(direxists(st_local("path") + st_local("figpath"))))
			if !`dir_exists' {
				di as error "Error: Could not create directory `path'`figpath'"
				exit 693
			}
			capture noisily graph export `path'`filename', replace
			if _rc {
				di as error "Error: Could not export graph to `path'`filename'"
				if _rc == 198 {
					di as error "  No graph in memory. Create a graph before using subfigure."
				}
				exit _rc
			}
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
				file write `f' `" \footnotesize "' _n
				if "`notes_center'"=="center" ///
					file write `f' `"  \centering \textbf{Notes:} `notes' "' _n
				else ///
					file write `f' `" \textbf{Notes:} `notes' "' _n
				file write `f' `"\end{tabular} "' _n
			}
			file write `f' `"\end{figure} "' _n
		}


    }
	else if "`command'" == "collect" {
		syntax [,  ///
            TITle(str) ///
            NOTES(str) ///
            BOOKTabs ///
            NOVERTicallines ///
            THREEparttable ///
            FONTsize(str) ///
            LANDscape ///
            TABularx(str asis) ///
            ]

        // Parse tabularx sub-options: tabularx(col_numbers, width(width_spec))
        local tabularx_width "\textwidth"
        local tabularx_cols ""
        if `"`tabularx'"' != "" {
            _parse comma tabularx_cols tabularx_opts : tabularx
            if `"`tabularx_opts'"' != "" {
                local 0 `tabularx_opts'
                syntax [, width(str)]
                if "`width'" != "" local tabularx_width "`width'"
            }
        }

		tempfile collectfile
		collect export `collectfile', tableonly replace  as(tex) 

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

            // Convert tabular to tabularx if option specified
            if `"`tabularx'"' != "" {
                // Replace \begin{tabular} with \begin{tabularx}{width}
                if strmatch("`line'", "*\begin{tabular}*") {
                    // Extract column spec from \begin{tabular}{colspec}
                    local colstart = strpos("`line'", "\begin{tabular}{") + 16
                    local colend = strpos(substr("`line'", `colstart', .), "}") - 1
                    local colspec = substr("`line'", `colstart', `colend')

                    // Build new column spec: replace l/c/r with X based on tabularx_cols
                    local newcolspec ""
                    local colnum 1
                    forvalues i = 1/`=strlen("`colspec'")' {
                        local ch = substr("`colspec'", `i', 1)
                        // Check if this is a column type character
                        if inlist("`ch'", "l", "c", "r") {
                            // Replace with X if tabularx_cols is empty or colnum is in tabularx_cols
                            local replace_col 0
                            if "`tabularx_cols'" == "" {
                                local replace_col 1
                            }
                            else {
                                foreach col of local tabularx_cols {
                                    if `col' == `colnum' {
                                        local replace_col 1
                                    }
                                }
                            }
                            if `replace_col' {
                                local newcolspec "`newcolspec'>{\centering\arraybackslash}X"
                            }
                            else {
                                local newcolspec "`newcolspec'`ch'"
                            }
                            local colnum = `colnum' + 1
                        }
                        else {
                            // Keep other characters (|, @{}, etc.) as-is
                            local newcolspec "`newcolspec'`ch'"
                        }
                    }

                    // Replace the tabular with tabularx and new column spec
                    local before = substr("`line'", 1, strpos("`line'", "\begin{tabular}") - 1)
                    local after = substr("`line'", `colstart' + `colend' + 1, .)
                    local line "`before'\begin{tabularx}{`tabularx_width'}{`newcolspec'}`after'"
                }
                // Replace \end{tabular} with \end{tabularx}
                if strmatch("`line'", "*\end{tabular}*") {
                    local line = subinstr("`line'", "\end{tabular}", "\end{tabularx}", .)
                }
                // Strip \multicolumn{1}{l/c/r}{content} wrappers, keeping just content
                // Need to handle nested braces in content (e.g., \hspace{1em})
                while strmatch(`"`line'"', `"*\multicolumn{1}{*"') {
                    local mcpos = strpos(`"`line'"', "\multicolumn{1}{")
                    local rest = substr(`"`line'"', `mcpos' + 16, .)
                    local alignend = strpos("`rest'", "}")
                    local rest2 = substr("`rest'", `alignend' + 1, .)
                    // Find matching } by counting brace depth
                    local depth 0
                    local clen 0
                    forvalues i = 1/`=strlen(`"`rest2'"')' {
                        local ch = substr(`"`rest2'"', `i', 1)
                        if "`ch'" == "{" local depth = `depth' + 1
                        if "`ch'" == "}" local depth = `depth' - 1
                        if `depth' == 0 {
                            local clen = `i'
                            continue, break
                        }
                    }
                    if `clen' > 0 {
                        local content = substr(`"`rest2'"', 2, `clen' - 2)
                        local before = substr(`"`line'"', 1, `mcpos' - 1)
                        local after = substr(`"`rest2'"', `clen' + 1, .)
                        local line `"`before'`content'`after'"'
                    }
                    else {
                        continue, break
                    }
                }
                // Preserve line break marker \\ before word processing
                local has_linebreak 0
                local linebreak_suffix ""
                if strmatch(`"`line'"', `"*\\"') {
                    local has_linebreak 1
                    local linebreak_suffix " \\"
                    // Remove trailing \\ (and preceding space if any)
                    local line = regexr(`"`line'"', `"[ ]*\\\\\\\\$"', "")
                    
                }
                
                // Auto-hyphenate long words (>10 chars) for better column wrapping
                // Process each word between spaces, ampersands, and slashes
                local newline ""
                local remaining `"`line'"'
                while `"`remaining'"' != "" {
                    // Find next delimiter (space, &, or /)
                    local spacepos = strpos(`"`remaining'"', " ")
                    local amppos = strpos(`"`remaining'"', "&")
                    local slashpos = strpos(`"`remaining'"', "/")
                    local delim_pos 0
                    local delim ""
                    // Find the earliest delimiter
                    foreach d in space amp slash {
                        if ``d'pos' > 0 & (`delim_pos' == 0 | ``d'pos' < `delim_pos') {
                            local delim_pos = ``d'pos'
                            if "`d'" == "space" local delim " "
                            else if "`d'" == "amp" local delim "&"
                            else if "`d'" == "slash" local delim "\slash "
                        }
                    }
                    if `delim_pos' > 0 {
                        local word = substr(`"`remaining'"', 1, `delim_pos' - 1)
                        local remaining = substr(`"`remaining'"', `delim_pos' + 1, .)
                    }
                    else {
                        local word `"`remaining'"'
                        local remaining ""
                        local delim ""
                    }
                    // Hyphenate long words (>10 chars) that don't contain backslash
                    local wordlen = strlen(`"`word'"')
                    if `wordlen' > 10 & strpos(`"`word'"', "\") == 0 {
                        local hyphenated ""
                        forvalues i = 1/`wordlen' {
                            local ch = substr(`"`word'"', `i', 1)
                            local hyphenated "`hyphenated'`ch'"
                            // Insert \- every 5 characters (but not at end)
                            if mod(`i', 5) == 0 & `i' < `wordlen' {
                                local hyphenated "`hyphenated'\-"
                            }
                        }
                        local word "`hyphenated'"
                    }
                    local newline `"`newline'`word'`delim'"'
                }
                local line `"`newline'`linebreak_suffix'"'
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
    else if "`command'" == "pdf" {
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
        else if "`c(os)'" == "MacOSX" | ( "`c(os)'" == "Unix" & strmatch("`c(machine_type)'", "Mac*") ) {
            shell /Library/TeX/texbin/pdflatex -shell-escape --src -interaction=nonstopmode `filename'
            local viewcommand open
        }
        else if "`=c(os)'"=="Unix" {
            shell pdflatex -shell-escape --src -interaction=nonstopmode `filename'
            local viewcommand xdg-open
        }
        cap erase "`path'`filestub'.aux"
        cap erase "`path'`filestub'.log"
        cap erase "`path'`filestub'.out"
        cap erase "`path'`filestub'.synctex.gz"
        cd `"`pwd'"'

        if "`view'"!="" shell `viewcommand' `path'`filestub'.pdf
    }
    else {
        di as error "Unknown latexlog subcommand: `command'"
        exit 198
    }

end // latexlog


/*-------------------------------------------------------*/
/* Unpack filepath into filename, fileending and path  */
/*-------------------------------------------------------*/
cap program drop splitpath
program define splitpath, rclass

    local fullpath `0'

    // di regexm("`fullpath'","^(([A-Z]:)?[\.]?[\\{1,2}/]?.*[\\{1,2}/])*(.+)\.(.+)")

    local matched = regexm("`fullpath'", "^(.*[\\/])*(.+)\.(.+)")
    if `matched' {
        local path = regexs(1)
        local filestub = regexs(2)
        local fileend = regexs(3)
    }

    if "`path'"=="" return local path "./"
    else return local path "`path'"
    return local filestub "`filestub'"
    return local fileend "`fileend'"
    return local filename "`filestub'.`fileend'"

end // splitpath

