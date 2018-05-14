

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


cd "C:\Users\Elmar\Google Drive\Hackathon 28_4\Datasets\6. Bekostiging primair onderwijs\01. Bekostiging materiële instandhouding van scholen voor basisonderwijs\"

forvalues year = 2011/2017 {
	display "importing `year'"
	import excel "01.-materiele-instandhouding-bo-`year'", firstrow clear
	gen year = `year'
	save "`year'-materiele-instandhouding-bo-.dta", replace
}


use "2011-materiele-instandhouding-bo-.dta", clear

forvalues year = 2012/2017 {
	display "merging `year'"
	append using "`year'-materiele-instandhouding-bo-.dta", generate(merge_`year')
	}
	
replace BRIN_NUMMER = Brin if BRIN_NUMMER == ""
drop Brin

save "merged.dta", replace
export excel using "materiele-instandhouding-bo- combined.xlsx"


cd "C:\Users\Elmar\Google Drive\Hackathon 28_4\Datasets\6. Bekostiging primair onderwijs\"

merge 1:1 BRIN_NUMMER year using "03. Personele bekostiging van scholen voor basisonderwijs\merged.dta"
save "Merged bekostiging 2011-2017.dta"
export excel using "Merged bekostiging 2011-2017 per instelling.xlsx"
