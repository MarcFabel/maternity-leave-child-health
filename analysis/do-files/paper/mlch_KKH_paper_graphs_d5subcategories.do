/*
	Do-File um Graphen für Subkategorien zu entwerfen.
	
*/

	clear all
	set more off
	
	global path   "F:\econ\m-l-c-h/analysis"	
	global temp   "$path/temp"
	global graphs "$path/graphs/KKH"
	global graph_paper "$path/graphs/paper" 

	global tables "$path/tables/KKH"
	global auxiliary "$path/do-files/auxiliary_files"
	
	*magic numbers
	global first_year = 1995
	global last_year  = 2014
	global t_90		  = 1.645
	global t_95   	  = 1.960
	
	
	//Important globals
	* List of control groups
	global C2    = "(control == 2 | control == 4)"
	global C1_C2 = "control != 3"
	global C1_C3 = "reform == 1"
	
	* Bandwidths (sample selection)
	global M2 = "(Numx >= -2 & Numx <= 2)"
	global M4 = "(Numx >= -4 & Numx <= 4)"
	global M6 = "reform == 1"
	global MD = "(Numx != -1 & Numx != 1)"
// ***********************************************************************
// READ IN SOURCE DATEIEN

*define variable that contains varname
local j = 1
foreach 1 in "d5" "organic" "drug_abuse" "shizophrenia" "affective" "neurosis" "phys_factors" "personality" "retardation" { //  "development" "childhood"
	use "$path/tables/LfStat_GWAP/lc_`1'_yrs_brckts", clear
	qui gen var = `j'
	qui gen var_string = "`1'"
	qui save "$temp/lc_`1'_yrs_brckts_ed", replace
	local j = `j'+1
} // end 1: varlist
*append
qui use  "$temp/lc_d5_yrs_brckts_ed",clear	
foreach 1 in "organic" "drug_abuse" "shizophrenia" "affective" "neurosis" "phys_factors" "personality" "retardation" { //  "development" "childhood"
	qui append using "$temp/lc_`1'_yrs_brckts_ed"
} // end 1: varlist


*restrict to top 5 only 
drop if var == 2 | var == 7 | var == 9	
 /* OLD LABEL
*define label for variable
#delim ;
label define VAR
	1  "d5"
	2  "organic"
	3  "psychoactive substances"
	4  "schizophrenia"
	5  "affective"
	6  "neurosis"
	7  "physical factors"
	8  "personality"
	9  "retardation"
	10 "development"
	11 "childhood";
#delimit cr
label val var VAR
*/
recode var (3=2) (4=3) (5=4) (6=5) (8=6) 

order var 
#delim ;
label define VAR
	1  "all MBD"
	2  "substances"
	3  "schizophrenia"
	4  "affective"
	5  "neurosis"
	6  "personality"
	;
#delimit cr
label val var VAR

foreach j in "" "_f" "_m" {
qui replace diagnoses`j' = diagnoses`j' /1000	

	gen CI_l90`j'	= beta`j' - ($t_90 *se`j')
	gen CI_h90`j'	= beta`j' + ($t_90 *se`j')
	gen CI_l95`j' 	= beta`j' - ($t_95 *se`j')
	gen CI_h95`j'	= beta`j' + ($t_95 *se`j')
}

qui save "$temp/d5_subcategories_results", replace
*/
***********************************************************************	
* Overview for BW = 6 months	
***********************************************************************	
use "$temp/d5_subcategories_results", clear
	
keep if bandwidth == 6	& year == -99 // al observations   // corrected for year == -99 (have $LC)

*total	
	twoway bar diagnoses var if var >= 2,  color(gs2%80) ///
		xtitle("") ytitle("Frequency" "[in thousand]") ylabel(50 100 150) xlabel(none) ///
		graphregion(color(white))  ///
		xscale(r(0.5 6.5) alt lc(white)) ///
		scheme(s1mono) ///
		fysize(25) /// 
		yscale(r(0 150)) ///	
		plotregion(margin(top)) plotregion(color(white)) ///
		saving($graphs/frequency_across_d5,replace)

	twoway rspike CI_h90 CI_l90 var, color(gs2%80)  || ///
		rspike CI_h95 CI_l95 var,  color(gs10%80) || ///
		scatter beta var, color(gs2%80) m(O) ///
		xlabel(1 2 3 4 5 6  , valuelabel angle(45) )		///
		xscale(r(0.5 6.5)) ///
		yline(0, lc(black%80) lp(dash)) ///
		legend(off) xtitle("") ytitle("ITT effect" " ") ///
		plotregion(color(white)) scheme(s1mono) ///
		saving($graphs/ITT_across_d5,replace)
	
	graph combine "$graphs/frequency_across_d5" "$graphs/ITT_across_d5", imargin(zero) scheme(s1mono) col(1)  xcommon
	graph export "$graph_paper/effect_d5_frequency.pdf", as(pdf) replace
	
* female 
	twoway bar diagnoses_f var if var >= 2,  color(cranberry%80) ///
		xtitle("") ytitle("Frequency" "[in thousand]") ylabel(50 100 150) xlabel(none) ///
		graphregion(color(white)) ///
		xscale(r(0.5 6.5) alt lc(white)) ///
		scheme(s1mono) ///
		fysize(25) /// 
		yscale(r(0 150)) ///	
		plotregion(margin(top)) plotregion(color(white)) ///
		saving($graphs/frequency_across_d5_f,replace)

	twoway rspike CI_h90_f CI_l90_f var, color(gs2%80)  || ///
		rspike CI_h95_f CI_l95_f var,  color(gs10%80) || ///
		scatter beta_f var, color(cranberry%80) m(O) ///
		xlabel(1 2 3 4 5 6  , valuelabel angle(45) )		///
		xscale(r(0.5 6.5)) ///
		yline(0, lc(black%80) lp(dash)) ///
		legend(off) xtitle("") ytitle("ITT effect" " ") ///
		plotregion(color(white)) scheme(s1mono) ///
		saving($graphs/ITT_across_d5_f,replace)

	graph combine "$graphs/frequency_across_d5_f" "$graphs/ITT_across_d5_f", imargin(zero) scheme(s1mono) col(1)  xcommon
	graph export "$graph_paper/effect_d5_frequency_f.pdf", as(pdf) replace
	
* male 
	twoway bar diagnoses_m var if var >= 2,  color(navy%80) ///
		xtitle("") ytitle("Frequency" "[in thousand]") ylabel(50 100 150) xlabel(none) ///
		graphregion(color(white)) ///
		xscale(r(0.5 6.5) alt lc(white)) ///
		scheme(s1mono) ///
		fysize(25) /// 
		yscale(r(0 150)) ///	
		plotregion(margin(top)) plotregion(color(white)) ///
		saving($graphs/frequency_across_d5_m,replace)

	twoway rspike CI_h90_m CI_l90_m var, color(gs2%80)  || ///
		rspike CI_h95_m CI_l95_m var,  color(gs10%80) || ///
		scatter beta_m var, color(navy%80) m(O) ///
		xlabel(1 2 3 4 5 6  , valuelabel angle(45) )		///
		xscale(r(0.5 6.5)) ///
		yline(0, lc(black%80) lp(dash)) ///
		legend(off) xtitle("") ytitle("ITT effect" " ") ///
		graphregion(color(white)) plotregion(color(white)) scheme(s1mono) ///
		saving($graphs/ITT_across_d5_m,replace)

	graph combine "$graphs/frequency_across_d5_m" "$graphs/ITT_across_d5_m", imargin(zero) scheme(s1mono) col(1)  xcommon
	graph export "$graph_paper/effect_d5_frequency_m.pdf", as(pdf) replace
		
/* Andere Variante von overview graph
*  ITT effects oben und bars unten (reversed)	
twoway rspike CI_h90 CI_l90 var, color(gs2%90)  || ///
		rspike CI_h95 CI_l95 var,  color(gs10%80) || ///
		scatter beta var, color(gs2%80) m(O) ///
		xlabel(none) xtitle("") ///
		xscale(r(0.5 6.5) alt) ///
		yline(0, lc(black%80) lp(dash)) ///
		legend(off) ytitle("ITT effect" " ") ///
		graphregion(color(white)) scheme(s1mono)  ///
		saving($graphs/tempB1,replace)	
	
	
	twoway bar diagnoses var if var >= 2,  color(gs2%80) ///
		xtitle("") ytitle("Frequency" "[in thousand]") ylabel(75 150, grid ) xlabel(1 2 3 4 5 6  , valuelabel angle(45)) ///
		graphregion(color(white)) ///
		xscale(r(0.5 6.5) lc(white)) ///
		scheme(s1mono) ///
		fysize(40) /// 
		yscale(r(0 150) reverse) plotregion(margin(bottom)) ///		
		saving($graphs/tempB2,replace)		
		
	graph combine "$graphs/tempB1" "$graphs/tempB2", imargin(zero) scheme(s1mono) col(1)  xcommon
*/

////////////////////////////////////////////////////////////////////////////////
*		Life-course matrix for top 5
////////////////////////////////////////////////////////////////////////////////

use "$temp/d5_subcategories_results", clear
keep if bandwidth == 6
keep if year >= 1995
*drop if var == 1

*shorter labels for matrix
#delim ;
label define VAR2
	1  "all MBD"
	2  "psychoactive"
	3  "schizophrenia"
	4  "affective"
	5  "neurosis"
	6  "personality"
	;
#delimit cr
label val var VAR2	

*year label	
#delim ;
	label define YEAR_TREAT 
		1995 "1995 [16]"
		1996 "1996 [17]"
		1997 "1997 [18]"
		1998 "1998 [19]"
		1999 "1999 [20]"
		2000 "2000 [21]"
		2001 "2001 [22]"
		2002 "2002 [23]"
		2003 "2003 [24]"
		2004 "2004 [25]"
		2005 "2005 [26]"
		2006 "2006 [27]"
		2007 "2007 [28]"
		2008 "2008 [29]"
		2009 "2009 [30]"
		2010 "2010 [31]"
		2011 "2011 [32]"
		2012 "2012 [33]"
		2013 "2013 [34]"
		2014 "2014 [35]";
	#delim cr
	label values year YEAR_TREAT

	global min_itt_t = -4
	global max_itt_t = 4
	global min_itt_f = -8
	global max_itt_f = 4
	global min_itt_m = -8
	global max_itt_m = 4
	
	
	global min_diag_t = 0
	global max_diag_t = 35
	global min_diag_f = 0
	global max_diag_f = 25
	global min_diag_m = 0
	global max_diag_m = 25	
	
	global min_itt = -7.5
	global max_itt = 5
	global min_diag = 5
	global max_diag = 35

// First row in matrix (contains header boxes - tfm) 
foreach 1 in 1 {
	twoway line mean year if var == `1', sort color(gs14) lw(vthick) yaxis(2)  || ///
		rarea CI_h95 CI_l95 year if var == `1', sort  color(gs2%12) yaxis(1) || ///
		rarea CI_h90 CI_l90 year if var == `1', sort  color(gs2%25) yaxis(1) || ///
		line beta year if var == `1', sort color(gs2) yaxis(1) ///
		scheme(s1mono) plotregion(color(white))   /// 
		yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
		legend(off) ///
		xlabel(1996 (8)2012, nolab) xtitle("") ///
		ytitle("",axis(2)) ///
		yscale(alt axis(2)) yscale(alt axis(1)) /// 
		ytitle("all MBD" "", axis(1) box bexpand size(large)) /// 
		title("Total", box bexpand) ///
		yscale(range($min_itt $max_itt ) axis(1)) ///
		yscale(range($min_diag $max_diag) axis(2)) ///
		ylabel(-7.5 -5 -2.5 0 2.5, nogrid axis(1)) ///
		ylabel(none, nogrid axis(2))  ///
		nodraw ///
		saving($graphs/d5_subcateg_lc_`1',replace)
		
	twoway line mean_f year if var == `1', sort color(gs14) lw(vthick) yaxis(2)  || ///
		rarea CI_h95_f CI_l95_f year if var == `1', sort  color(cranberry%12) yaxis(1) || ///
		rarea CI_h90_f CI_l90_f year if var == `1', sort  color(cranberry%25) yaxis(1) || ///
		line beta_f year if var == `1', sort color(cranberry) yaxis(1) ///
		scheme(s1mono) plotregion(color(white))   /// 
		yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
		legend(off) ///
		xlabel(1996 (8)2012, nolab) xtitle("") ///
		ytitle("", axis(1)) ytitle("",axis(2)) ///
		yscale(alt axis(2)) yscale(alt axis(1)) /// 
		title("Female", box bexpand) ///
		yscale(range($min_itt $max_itt ) axis(1)) ///
		yscale(range($min_diag $max_diag) axis(2)) ///
		ylabel(none, nogrid axis(1)) ///
		ylabel(none, nogrid axis(2)) ///
		nodraw ///
		saving($graphs/d5_subcateg_lc_`1'_f,replace)
		
	twoway line mean_m year if var == `1', sort color(gs14) lw(vthick) yaxis(2)  || ///
		rarea CI_h95_m CI_l95_m year if var == `1', sort  color(navy%12) yaxis(1) || ///
		rarea CI_h90_m CI_l90_m year if var == `1', sort  color(navy%25) yaxis(1) || ///
		line beta_m year if var == `1', sort color(navy) yaxis(1) ///
		scheme(s1mono) plotregion(color(white))   /// 
		yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
		legend(off) ///
		xlabel(1996 (8)2012, nolab) xtitle("") ///
		ytitle("", axis(1)) ytitle("",axis(2)) ///
		yscale(alt axis(2)) yscale(alt axis(1)) /// 
		title("Male", box bexpand) ///
		yscale(range($min_itt $max_itt ) axis(1)) ///
		yscale(range($min_diag $max_diag) axis(2)) ///
		ylabel(none, nogrid axis(1)) ///
		ylabel(0 10 20 30, nogrid axis(2)) ///
		nodraw ///
		saving($graphs/d5_subcateg_lc_`1'_m,replace)
}


// Row 2 - 6 (Top 5) 
global t_2 "psychoactive"
global t_3 "schizophrenia"
global t_4 "affective"
global t_5 "neurosis" 
global t_6 "personality"


foreach 1 of numlist 2(1)6 {
	local ylab "t_`1'"
	disp `1'
}
* loop through top 5
foreach 1 of numlist 2(1)5 { // 6 is in its own, because it contains labels for the x value
	local ylab "t_`1'"
	
	twoway line mean year if var_string == "`1'", sort color(gs14) lw(vthick) yaxis(2)  || ///
		rarea CI_h95 CI_l95 year if var == `1', sort  color(gs2%12) yaxis(1) || ///
		rarea CI_h90 CI_l90 year if var == `1', sort  color(gs2%25) yaxis(1) || ///
		line beta year if var == `1', sort color(gs2) yaxis(1) ///
		scheme(s1mono) plotregion(color(white))   /// 
		yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
		legend(off) ///
		xlabel(1996 (8)2012, nolab) xtitle("") ///
		ytitle("",axis(2)) ///
		yscale(alt axis(2)) yscale(alt axis(1)) /// 
		ytitle("$`ylab'" "", axis(1) box bexpand size(large)) /// 
		yscale(range($min_itt $max_itt ) axis(1)) ///
		yscale(range($min_diag $max_diag) axis(2)) ///
		ylabel(-7.5 -5 -2.5 0 2.5, nogrid axis(1)) ///
		ylabel(none, nogrid axis(2))  ///
		nodraw ///
		saving($graphs/d5_subcateg_lc_`1',replace)
		
	twoway line mean_f year if var == `1', sort color(gs14) lw(vthick) yaxis(2)  || ///
		rarea CI_h95_f CI_l95_f year if var == `1', sort  color(cranberry%12) yaxis(1) || ///
		rarea CI_h90_f CI_l90_f year if var == `1', sort  color(cranberry%25) yaxis(1) || ///
		line beta_f year if var == `1', sort color(cranberry) yaxis(1) ///
		scheme(s1mono) plotregion(color(white))   /// 
		yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
		legend(off) ///
		xlabel(1996 (8)2012, nolab) xtitle("") ///
		ytitle("", axis(1)) ytitle("",axis(2)) ///
		yscale(alt axis(2)) yscale(alt axis(1)) /// 
		yscale(range($min_itt $max_itt ) axis(1)) ///
		yscale(range($min_diag $max_diag) axis(2)) ///
		ylabel(none, nogrid axis(1)) ///
		ylabel(none, nogrid axis(2)) ///
		nodraw ///
		saving($graphs/d5_subcateg_lc_`1'_f,replace)
		
	twoway line mean_m year if var == `1', sort color(gs14) lw(vthick) yaxis(2)  || ///
		rarea CI_h95_m CI_l95_m year if var == `1', sort  color(navy%12) yaxis(1) || ///
		rarea CI_h90_m CI_l90_m year if var == `1', sort  color(navy%25) yaxis(1) || ///
		line beta_m year if var == `1', sort color(navy) yaxis(1) ///
		scheme(s1mono) plotregion(color(white))   /// 
		yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
		legend(off) ///
		xlabel(1996 (8)2012, nolab) xtitle("") ///
		ytitle("", axis(1)) ytitle("",axis(2)) ///
		yscale(alt axis(2)) yscale(alt axis(1)) /// 
		yscale(range($min_itt $max_itt ) axis(1)) ///
		yscale(range($min_diag $max_diag) axis(2)) ///
		ylabel(none, nogrid axis(1)) ///
		ylabel(0 10 20 30, nogrid axis(2)) ///
		nodraw ///
		saving($graphs/d5_subcateg_lc_`1'_m,replace)
} // end 1: loop through top 5 subcategories

// personality (bottom)
foreach 1 of numlist 6 { // 6 contains the xlabel
	local ylab "t_`1'"
	
	twoway line mean year if var_string == "`1'", sort color(gs14) lw(vthick) yaxis(2)  || ///
		rarea CI_h95 CI_l95 year if var == `1', sort  color(gs2%12) yaxis(1) || ///
		rarea CI_h90 CI_l90 year if var == `1', sort  color(gs2%25) yaxis(1) || ///
		line beta year if var == `1', sort color(gs2) yaxis(1) ///
		scheme(s1mono) plotregion(color(white))   /// 
		yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
		legend(off) ///
		xlabel(1996 (8)2012, val angle(0)) xtitle("") ///
		ytitle("",axis(2)) ///
		yscale(alt axis(2)) yscale(alt axis(1)) /// 
		ytitle("$`ylab'" "", axis(1) box bexpand size(large)) /// 
		yscale(range($min_itt $max_itt ) axis(1)) ///
		yscale(range($min_diag $max_diag) axis(2)) ///
		ylabel(-7.5 -5 -2.5 0 2.5, nogrid axis(1)) ///
		ylabel(none, nogrid axis(2))  ///
		nodraw ///
		saving($graphs/d5_subcateg_lc_`1',replace)
		
	twoway line mean_f year if var == `1', sort color(gs14) lw(vthick) yaxis(2)  || ///
		rarea CI_h95_f CI_l95_f year if var == `1', sort  color(cranberry%12) yaxis(1) || ///
		rarea CI_h90_f CI_l90_f year if var == `1', sort  color(cranberry%25) yaxis(1) || ///
		line beta_f year if var == `1', sort color(cranberry) yaxis(1) ///
		scheme(s1mono) plotregion(color(white))   /// 
		yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
		legend(off) ///
		xlabel(1996 (8)2012, val angle(0)) xtitle("") ///
		ytitle("", axis(1)) ytitle("",axis(2)) ///
		yscale(alt axis(2)) yscale(alt axis(1)) /// 
		yscale(range($min_itt $max_itt ) axis(1)) ///
		yscale(range($min_diag $max_diag) axis(2)) ///
		ylabel(none, nogrid axis(1)) ///
		ylabel(none, nogrid axis(2)) ///
		nodraw ///
		saving($graphs/d5_subcateg_lc_`1'_f,replace)
		
	twoway line mean_m year if var == `1', sort color(gs14) lw(vthick) yaxis(2)  || ///
		rarea CI_h95_m CI_l95_m year if var == `1', sort  color(navy%12) yaxis(1) || ///
		rarea CI_h90_m CI_l90_m year if var == `1', sort  color(navy%25) yaxis(1) || ///
		line beta_m year if var == `1', sort color(navy) yaxis(1) ///
		scheme(s1mono) plotregion(color(white))   /// 
		yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
		legend(off) ///
		xlabel(1996 (8)2012, val angle(0)) xtitle("") ///
		ytitle("", axis(1)) ytitle("",axis(2)) ///
		yscale(alt axis(2)) yscale(alt axis(1)) /// 
		yscale(range($min_itt $max_itt ) axis(1)) ///
		yscale(range($min_diag $max_diag) axis(2)) ///
		ylabel(none, nogrid axis(1)) ///
		ylabel(0 10 20 30, nogrid axis(2)) ///
		nodraw ///
		saving($graphs/d5_subcateg_lc_`1'_m,replace)
} // end 1: loop through bottom (personality)

// LC matrix zusammenfügen
	graph combine  ///
		"$graphs/d5_subcateg_lc_1" "$graphs/d5_subcateg_lc_1_f" "$graphs/d5_subcateg_lc_1_m"	///
		"$graphs/d5_subcateg_lc_2" "$graphs/d5_subcateg_lc_2_f" "$graphs/d5_subcateg_lc_2_m"	///
		"$graphs/d5_subcateg_lc_3" "$graphs/d5_subcateg_lc_3_f" "$graphs/d5_subcateg_lc_3_m"	///
		"$graphs/d5_subcateg_lc_4" "$graphs/d5_subcateg_lc_4_f" "$graphs/d5_subcateg_lc_4_m"	///
		"$graphs/d5_subcateg_lc_5" "$graphs/d5_subcateg_lc_5_f" "$graphs/d5_subcateg_lc_5_m"	///
		"$graphs/d5_subcateg_lc_6" "$graphs/d5_subcateg_lc_6_f" "$graphs/d5_subcateg_lc_6_m"	///
	,row(6) xsize(11.5) ysize(15) imargin(zero) ///
	scheme(s1mono) b2title("Year [age of treatment cohort]", size(vsmall) margin(small))
	
	graph export "$graph_paper/lc_matrix_d5subcategories.pdf", as(pdf) replace
			