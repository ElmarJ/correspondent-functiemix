

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

rename Brin brin
replace brin = BRIN_NUMMER if brin == ""
replace BEVOEGD_GEZAG_NUMMER = OWBGNUMMER if BEVOEGD_GEZAG_NUMMER == ""
gen bevoegdgezag = real(BEVOEGD_GEZAG_NUMMER)
drop BEVOEGD_GEZAG_NUMMER
order year brin bevoegdgezag
save "merged.dta", replace
export excel using "03.-personele-bekostiging-bo- combined.xlsx", replace

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

rename Brin brin
replace brin = BRIN_NUMMER if brin == ""
replace BEVOEGD_GEZAG_NUMMER = OWBGNUMMER if BEVOEGD_GEZAG_NUMMER == ""
gen bevoegdgezag = real(BEVOEGD_GEZAG_NUMMER)
drop BEVOEGD_GEZAG_NUMMER
order year brin bevoegdgezag
drop BRIN_NUMMER

save "merged.dta", replace
export excel using "materiele-instandhouding-bo- combined.xlsx", replace


cd "C:\Users\Elmar\Google Drive\Hackathon 28_4\Datasets\6. Bekostiging primair onderwijs\"

merge 1:1 brin year using "03. Personele bekostiging van scholen voor basisonderwijs\merged.dta"
save "Merged bekostiging 2011-2017.dta", replace
export excel using "Merged bekostiging 2011-2017 per instelling.xlsx", replace

import delimited "C:\Users\Elmar\Google Drive\Hackathon 28_4\Datasets\1. Functie- _salarismix\functiemix-instellingen-po-12-17.csv", clear
rename jaar year
rename brin_nummer brin
rename bevoegd_gezagnummer bevoegdgezag
rename key instelling_key
gen bestuur_key = string(bevoegdgezag) + "-" + string(year)
order year brin bevoegdgezag instelling_key bestuur_key

merge 1:1 brin year using "C:\Users\Elmar\Google Drive\Hackathon 28_4\Datasets\6. Bekostiging primair onderwijs\Merged bekostiging 2011-2017.dta", nogenerate

ren BEVOEGD_GEZAG_NUMMER bevoegdgezag
replace bevoegdgezag = OWBGNUMMER if bevoegdgezag == ""
gen bestuur_key = bevoegdgezag + "-" + string(year)
gen aandeel_formatie_op_lb_num = real(aandeel_formatie_op_lb)
save "C:\Users\Elmar\Google Drive\Hackathon 28_4\Datasets\Merged instellingsdata.dta", replace
export delimited using "C:\Users\Elmar\Google Drive\Hackathon 28_4\Team 3\Instellingsdata merged (Elmar).csv", replace

import delimited "C:\Users\Elmar\Google Drive\Hackathon 28_4\Team 3\Input voor de lineare regressie-v5.csv", clear numericcols(5/68) 
rename jaar year
rename key bestuur_key
rename  bevoegd_gezagnummer bevoegdgezag
order year bevoegdgezag bestuur_key
save "C:\Users\Elmar\Google Drive\Hackathon 28_4\Team 1\Kenmerken Bestuursniveau.dta", replace

import delimited "C:\Users\Elmar\Google Drive\Hackathon 28_4\Team 3\Input voor de lineare regressie-financieel-v3.csv", clear numericcols(7/30) 
rename jaar year
rename key bestuur_key
order bevoegdgezag year bestuur_key
drop if groepering == "SBO"
drop if groepering == "SPEC"
drop if groepering == "SWV"
save "C:\Users\Elmar\Google Drive\Hackathon 28_4\Team 1\Financien Bestuursniveau.dta", replace

merge 1:1 bevoegdgezag year using "C:\Users\Elmar\Google Drive\Hackathon 28_4\Team 1\Kenmerken Bestuursniveau.dta", gen(merge_bestuurs_kenmerk_fin)
save "C:\Users\Elmar\Google Drive\Hackathon 28_4\Team 1\Merged Bestuursniveau.dta", replace
export delimited using "C:\Users\Elmar\Google Drive\Hackathon 28_4\Team 3\Bestuursniveau alles merged (Elmar).csv", replace
export excel using "C:\Users\Elmar\Google Drive\Hackathon 28_4\Team 3\Bestuursniveau alles merged (Elmar).xlsx", replace

use "C:\Users\Elmar\Google Drive\Hackathon 28_4\Team 1\Merged instellingsdata.dta", clear
merge m:1 bevoegdgezag year using "C:\Users\Elmar\Google Drive\Hackathon 28_4\Team 1\Merged Bestuursniveau.dta", keepusing(lastenpersoneelnietinloondienst lonenensalarissen-eenpitter) gen(merge_bestuur_instelling)

// encode bestuur_key, gen(bestuur_id)
// encode bevoegdgezag, gen(bevoegdgezag_num)
// encode BRIN_NUMMER, gen(brin_num)
// drop if bevoegdgezag == ""
tsset brin year

gen klein_dummy = aantal_leerlingen < 145
gen extra_klein_dummy = aantal_leerlingen < 25
gen klein_140_dummy = aantal_leerlingen < 140
gen klein_150_dummy = aantal_leerlingen < 150
gen kleinschool = KLEINE_SCHOLEN_TOESLAG > 0

recode aantal_leerlingen (1/24 = 1) (25/49 = 2) (50/74 = 3) (75/99 = 4) (100/124 = 5) (125/149 = 6) (150/max = 7), gen (leerling_groups)

scatter aandeel_formatie_op_lb_num aantal_leerlingen, msize(0.1)

xtmixed aandeel_formatie_op_lb_num || bevoegdgezag: || bestuur_id:
xtmixed aandeel_formatie_op_lb_num || bevoegdgezag:
xtmixed aandeel_formatie_op_lb_num aantal_leerlingen || bevoegdgezag: || bestuur_id:
xtmixed aandeel_formatie_op_lb_num aantal_leerlingen TOTAAL_AANTAL_LEERLINGEN || bevoegdgezag: || bestuur_id:
xtmixed aandeel_formatie_op_lb_num aantal_leerlingen || bevoegdgezag: || bestuur_id:  aantal_leerlingen
xtmixed aandeel_formatie_op_lb_num aantal_leerlingen klein_dummy || bevoegdgezag: || bestuur_id:  aantal_leerlingen
xtmixed aandeel_formatie_op_lb_num aantal_leerlingen klein_dummy klein_140_dummy klein_150_dummy || bevoegdgezag: || bestuur_id:  aantal_leerlingen
xtmixed aandeel_formatie_op_lb_num aantal_leerlingen KLEINE_SCHOLEN_TOESLAG || bevoegdgezag: || bestuur_id:  aantal_leerlingen
xtmixed aandeel_formatie_op_lb_num aantal_leerlingen KLEINE_SCHOLEN_TOESLAG ZEER_KLEINE_SCHOLEN_TOESLAG DIRECTIETOESLAG BESTRIJDING_ONDERWIJSACHTERSTAND DRIEVIERDE_OPSLAG_NEVENVESTIGING TOTAAL_PERSONELE_BEKOSTIGING IMPULSGEBIEDEN PERSONEELS_EN_ARBEIDSMARKTBELEID PRESTATIEBOX || bevoegdgezag: || bestuur_id:  aantal_leerlingen
xtmixed aandeel_formatie_op_lb_num i.leerling_groups || bevoegdgezag: || bestuur_id:  aantal_leerlingen
xtmixed aandeel_formatie_op_lb_num i.leerling_groups KLEINE_SCHOLEN_TOESLAG || bevoegdgezag: || bestuur_id:  aantal_leerlingen
xtmixed aandeel_formatie_op_lb_num i.leerling_groups kleinschool KLEINE_SCHOLEN_TOESLAG || bevoegdgezag: || bestuur_id:  aantal_leerlingen
xtmixed aandeel_formatie_op_lb_num i.leerling_groups kleinschool aantal_leerlingen || bevoegdgezag: || bestuur_id:
xtmixed aandeel_formatie_op_lb_num i.leerling_groups kleinschool aantal_leerlingen randstad || bevoegdgezag: || bestuur_id:
tab randstad

