
global version = 1
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
save "C:\Users\Elmar\Google Drive\Hackathon 28_4\Datasets\samengebrachte_data_elmar\inst.bekostiging.personeel.v`version'.dta", replace
export delimited using "C:\Users\Elmar\Google Drive\Hackathon 28_4\Datasets\samengebrachte_data_elmar\inst.bekostiging.personeel.v`version'.csv", replace

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

save "C:\Users\Elmar\Google Drive\Hackathon 28_4\Datasets\samengebrachte_data_elmar\inst.bekostiging.materieel.v`version'.dta", replace
export delimited using "C:\Users\Elmar\Google Drive\Hackathon 28_4\Datasets\samengebrachte_data_elmar\inst.bekostiging.materieel.v`version'.csv", replace

cd "C:\Users\Elmar\Google Drive\Hackathon 28_4\Datasets\samengebrachte_data_elmar\"

merge 1:1 brin year using "inst.bekostiging.personeel.v`version'.dta"
gen bestuur_key = string(bevoegdgezag) + "-" + string(year)
gen instelling_key = brin + "-" + string(year)
save "inst.bekostiging.v`version'.dta", replace
export delimited using "inst.bekostiging.v`version'.csv", replace

import delimited "C:\Users\Elmar\Google Drive\Hackathon 28_4\Datasets\1. Functie- _salarismix\functiemix-instellingen-po-12-17.csv", clear numericcols(15/58)
rename jaar year
rename brin_nummer brin
rename bevoegd_gezagnummer bevoegdgezag
rename key instelling_key
gen bestuur_key = string(bevoegdgezag) + "-" + string(year)
save "inst.functiemix.v`version'.dta", replace
export delimited using "inst.functiemix.v`version'.csv", replace


/* 
 * importeren geprapereerde bestuurs-kenmerken-data door team 3
 */
 
import delimited "C:\Users\Elmar\Google Drive\Hackathon 28_4\Team 3\Input voor de lineare regressie-v5.csv", clear numericcols(5/68) 
rename jaar year
rename key bestuur_key
rename  bevoegd_gezagnummer bevoegdgezag
order year bevoegdgezag bestuur_key
save "best.kenmerken.v`version'.dta", replace
export delimited using "best.kenmerken.v`version'.csv", replace

/* 
 * importeren geprapereerde financien-data (bestuursniveau) door team 3
 */

 import delimited "C:\Users\Elmar\Google Drive\Hackathon 28_4\Team 3\Input voor de lineare regressie-financieel-v3.csv", clear numericcols(7/30) 
rename jaar year
rename key bestuur_key
order bevoegdgezag year bestuur_key
drop if groepering == "SBO"
drop if groepering == "SPEC"
drop if groepering == "SWV"
save "best.financien.v`version'.dta", replace
export delimited using "best.financien.v`version'.csv", replace




/* 
 * importeren en herstructureren personeelsdata, eerst instellingspecifieke data, en dan "bovenschools"
 */

import excel "C:\Users\Elmar\Google Drive\Hackathon 28_4\Datasets\8. Personeel in het primair onderwijs\01-onderwijspersoneel-po-in-personen.xlsx", sheet("per owtype-bestuur-brin") firstrow case(lower) clear

rename brinnummer brin
rename personenintijdelijkedienst20 personenintijdeldienst2011
rename s  personenintijdeldienst2012
rename t  personenintijdeldienst2013
rename u  personenintijdeldienst2014
rename v  personenintijdeldienst2015
rename w  personenintijdeldienst2016
rename x  personenintijdeldienst2017

preserve

drop if brin == "bovenschools"

reshape long personen personeninvastedienst vrouwen mannen geslachtonbekend personenintijdeldienst personenjongerdan15jaar personen1525jaar personen2535jaar personen3545jaar personen4555jaar personen5565jaar  personen65jaarenouder leeftijdonbekend personen005ftes personen0508ftes personenmeerdan08ftes gemiddeldeleeftijd gemiddeldeleeftijdvrouw gemiddeldeleeftijdman gemiddeldeftes, i(brin) j(year 2011 2012 2013 2014 2015 2016 2017)

destring personen-gemiddeldeftes, replace force

gen bestuur_key = string(bevoegdgezag) + "-" + string(year)
gen instelling_key = brin + "-" + string(year)
order year brin bevoegdgezag instelling_key bestuur_key

save "inst.personeel.v`version'.dta", replace
export delimited using "inst.personeel.v`version'.csv", replace

/*
 * Berekenen gemiddelden over instellingen (bestuursniveau)
 */

gen bao = onderwijstype == "BAO"
gen sbao = onderwijstype == "SBAO"
gen wec = onderwijstype == "WEC (so en vso)"

/*
 * nu nemen we ook de niet-BAO instellingen van het bestuur mee. Willen we dit?	
 */

// drop if onderwijstype != "BAO" 

collapse


/*
 * Importeren bovenschoolse data (bestuursniveau)
 */

restore

keep if brin == "bovenschools"
drop brin


reshape long personen personeninvastedienst vrouwen mannen geslachtonbekend personenintijdeldienst personenjongerdan15jaar personen1525jaar personen2535jaar personen3545jaar personen4555jaar personen5565jaar  personen65jaarenouder leeftijdonbekend personen005ftes personen0508ftes personenmeerdan08ftes gemiddeldeleeftijd gemiddeldeleeftijdvrouw gemiddeldeleeftijdman gemiddeldeftes, i(bevoegdgezag) j(year 2011 2012 2013 2014 2015 2016 2017)

destring personen-gemiddeldeftes, replace force

gen bestuur_key = string(bevoegdgezag) + "-" + string(year)
order year bevoegdgezag bestuur_key

save "best.personeel.bovenschools.v`version'.dta", replace
export delimited using "best.personeel.bovenschools.v`version'.csv", replace


/* 
 * samenvoegen instellings-bestanden
 */

use "inst.functiemix.v`version'.dta", clear 
merge 1:1 brin year using "inst.bekostiging.v`version'.dta", nogenerate
merge 1:1 brin year using "inst.personeel.v`version'.dta", nogenerate
order year brin bevoegdgezag instelling_key bestuur_key
save "inst.v`version'.dta", replace
export delimited using "inst.v`version'.csv", replace


/* 
 * samenvoegen bestuurs-bestanden
 */

use "best.personeel.bovenschools.v`version'.dta", clear
merge 1:1 bevoegdgezag year using "best.kenmerken.v`version'.dta", nogenerate
merge 1:1 bevoegdgezag year using "best.personeel.bovenschools.v`version'.dta", nogenerate
save "best.v`version'.dta", replace
export delimited using "best.v`version'.csv", replace

