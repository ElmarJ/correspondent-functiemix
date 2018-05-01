use "C:\Users\elmar\Google Drive\Hackathon 28_4\Datasets\samengebrachte_data_elmar\inst.v1.dta", clear

// er lijkt inderdaad klein dipje te zitten in LB in 150-170 leerlingen
egen aantal_group = cut(TOTAAL_AANTAL_LEERLINGEN), at(0(5)200) label
graph bar (mean) aandeel_formatie_op_lb, over(aantal_group)

// maar geen verspringing in hoeveelheid geld
graph bar (mean) TOTAAL, over(aantal_group)

// en geen verspringing in hoeveelheid geld per leerling
gen perleerling = TOTAAL / TOTAAL_AANTAL_LEERLINGEN
graph bar (mean) perleerling, over(aantal_group)

// dus dat is toch wat onwaarschijnlijk

// ook meer formele discontinuity analysis vindt geen effect:
gen klein_school_toesl = KLEINE_SCHOLEN_TOESLAG > 0

rdrobust aandeel_formatie_op_lb TOTAAL_AANTAL_LEERLINGEN, c(145)
rdrobust aandeel_formatie_op_lb TOTAAL_AANTAL_LEERLINGEN, c(145) h(5 5)
rdrobust aandeel_formatie_op_lb TOTAAL_AANTAL_LEERLINGEN, c(145) fuzzy(klein_school_toesl) if TOTAAL_AANTAL_LEERLINGEN < 300
rdrobust aandeel_formatie_op_lb TOTAAL_AANTAL_LEERLINGEN, c(145) h(5 5) fuzzy(klein_school_toesl)

// behalve iets op 152 - dat is inderdaad het kleine dipje dat we al eerder
//   zagen, maar dus niet zoveel met grens op 145 te maken lijkt te hebben
rdrobust aandeel_formatie_op_lb TOTAAL_AANTAL_LEERLINGEN, c(152)

// en het is ook niet meer te vinden wanneer we kijken naar verandering
//   (differences ipv levels) in LB en ook niet als we een grotere tijds-
//   spanne tussen aantal-leerlingen en LB nemen:

gen diff_LB = d.aandeel_formatie_op_lb
gen l1_totaal = l1.TOTAAL_AANTAL_LEERLINGEN
gen l2_totaal = l2.TOTAAL_AANTAL_LEERLINGEN
gen l3_totaal = l3.TOTAAL_AANTAL_LEERLINGEN
gen klein_school_toesl = KLEINE_SCHOLEN_TOESLAG > 0

// allemaal varianten van zoeken naar discontiuteit, vind niets:
rdrobust aandeel_formatie_op_lb l2_totaal if TOTAAL_AANTAL_LEERLINGEN < 300, c(145) h(10 10)
rdrobust aandeel_formatie_op_lb l1_totaal if TOTAAL_AANTAL_LEERLINGEN < 300, c(145) h(10 10)
rdrobust aandeel_formatie_op_lb l3_totaal if TOTAAL_AANTAL_LEERLINGEN < 300, c(145) h(10 10)
rdrobust aandeel_formatie_op_lb l1_totaal if TOTAAL_AANTAL_LEERLINGEN < 300, c(145) h(5 5)
rdrobust aandeel_formatie_op_lb l1_totaal if TOTAAL_AANTAL_LEERLINGEN < 300 & year == 2015, c(145) h(5 5)
rdrobust aandeel_formatie_op_lb TOTAAL_AANTAL_LEERLINGEN if TOTAAL_AANTAL_LEERLINGEN < 300 & year == 2015, c(145) h(5 5)
rdrobust aandeel_formatie_op_lb l1_totaal if TOTAAL_AANTAL_LEERLINGEN < 300 & year == 2015, c(145) h(5 5)
rdrobust aandeel_formatie_op_lb l2_totaal if TOTAAL_AANTAL_LEERLINGEN < 300 & year == 2015, c(145) h(5 5)
