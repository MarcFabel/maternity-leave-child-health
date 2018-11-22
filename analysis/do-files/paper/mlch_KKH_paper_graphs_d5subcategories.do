/*
	Do-File um Graphen für Subkategorien zu entwerfen.
	
*/

	clear all
	set more off
	
	global path   "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis"	
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
	1  "d5"
	2  "psychoactive substances"
	3  "schizophrenia"
	4  "affective"
	5  "neurosis"
	6  "personality"
	;
#delimit cr
label val var VAR

qui save "$temp/d5_subcategories_results", replace
*/
***********************************************************************	
* Overview for BW = 6 months	
***********************************************************************	
use "$temp/d5_subcategories_results", clear
	
keep if bandwidth == 6	& year == -98 // al observations
qui replace diagnoses = diagnoses /1000	

	gen CI_l90	= beta - ($t_90 *se)
	gen CI_h90	= beta + ($t_90 *se)
	gen CI_l95 	= beta - ($t_95 *se)
	gen CI_h95	= beta + ($t_95 *se)
	

	
twoway rspike CI_h90 CI_l90 var, color(gs2%80)  || ///
		rspike CI_h95 CI_l95 var,  color(gs10%80) || ///
		scatter beta var, color(gs2%80)  ///
		xlabel(1 2 3 4 5 6  , valuelabel angle(45))		///
		yline(0, lc(black%80) lp(dash)) ///
		legend(off) xtitle("") ///
		saving($graphs/temp2,replace)

		

		
/* Ursprüngliches	
eclplot beta CI_low CI_high group, yline(0, lc(black)) ylabel(, nogrid) xlabel(1 2 3 4 5 6, valuelabel angle(45)) ///
								   graphregion(color(white)) xscale(range(0.5 6.5)) yscale(range(0 1)) ///
								   xtitle("") yscale(r(-1.5 0.5))

twoway rspike CI_h90 CI_l90  temp, horizontal yaxis(1) color(gs2%80) yscale(range(0.5 14.5) axis(1) lc(white))	|| ///
		rspike CI_h95 CI_l95 temp,  horizontal yaxis(1) color(gs10%80) yscale(range(0.5 14.5) axis(1) lc(white))	|| ///
		scatter temp beta, yaxis(2) color(cranberry%80) yscale(range(0.5 14.5) axis(2))	///
		xline(0, lc(black%80) lp(dash)) ///
		ylabel(1(1)14, nogrid valuelabel angle(0) axis(2)) ///
		ylabel(none, axis(1)) ///
		graphregion(color(white))   ///
		xtitle("ITT effect") ///
		ysize(5.5) xsize(2.7) ///
		ytitle("", axis(1)) ytitle("", axis(2)) ///
		legend(off) graphregion(color(white)) 	


twoway bar diagnoses var if var > 1, xlabel(val)
	