

cd "C:\Users\Elmar\Google Drive\Hackathon 28_4\Datasets\6. Bekostiging primair onderwijs\03. Personele bekostiging van scholen voor basisonderwijs\"

forvalues year = 2011/2017 {
	local year2 = `year' + 1
	display "importing `year'"
	import excel "03.-personele-bekostiging-bo-`year'-`year2'.xls", firstrow clear
	gen year = `year'
	save "`year'-`year2' personele bekostiging instelling.dta", replace
}


use "2011-2012 personele bekostiging instelling.dta", clear

forvalues year = 2012/2017 {
	display "merging `year'"
	local year2 = `year' + 1
	append using "`year'-`year2' personele bekostiging instelling.dta", generate(merge_`year')
}

replace BRIN_NUMMER = Brin if BRIN_NUMMER == ""
drop Brin

save "merged.dta", replace

export excel using "03.-personele-bekostiging-bo- combined.xlsx"
