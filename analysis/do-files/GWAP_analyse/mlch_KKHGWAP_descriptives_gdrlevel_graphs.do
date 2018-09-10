********************************************************************************
// Composition of F Diagnoses

use "$temp/KKH_final_gdr_level", clear

run "auxiliary_varlists_varnames_sample-spcifications"

keep if GDR == 0 
keep if treat == 1 | control == 2

*generate totals per year for the two cohorts used in the standard DD regression
foreach var of varlist shizophrenia affective neurosis personality drug_abuse d5 {
	capture drop t_`var' 
	bys year: egen t_`var' = total(`var')
}

*graph
line t_d5 year, sort color(gs13) lw(vthick) yaxis(2) || ///
	line t_drug_abuse year, sort  yaxis(1) color(black) lpattern(longdash) || ///
	line t_shizophrenia year, sort yaxis(1) color(black) lpattern(shortdash) || ///
	line t_affective year, sort yaxis(1) color(black) lpattern(dash) || ///
	line t_neurosis year, sort yaxis(1) color(black) lpattern(dash_dot) || ///
	line t_personality year, sort yaxis(1) color(black) lpattern(solid) ///
	yscale(alt axis(2)) yscale(alt axis(1))  ///
	scheme(s1mono) ///
	ytitle("All mental and behavioral disorders", axis(2)) ///
	ytitle("Single diagnosis types", axis(1)) ///
	legend(c(3) lab(1 "All F diagnoses") lab(3 "Shizophrenia") lab(4 "Affective") ///
	lab(5 "Neurosis") 	lab(6 "Personality") lab(2 "Drug abuse")) ///
	legend(size(small))
	
graph export "$graphs/descriptives_d5_partition.pdf", as(pdf) replace	
********************************************************************************
