// Erstellen von Graphiken für die Präsentation


/*******************************************************************************
* File name: 	mlch_KKH_analysis_regression_lifecourse
* Author: 		Marc Fabel
* Date: 		21.11.2017
* Description:	lifcourse
*				
*
* Inputs:  		$temp\KKH_final_R1
*				
* Outputs:		$graphs/
*				$tables/
*
* Updates:		
*

*******************************************************************************/


/*


Order of code: 

PANEL1 
		|Var1 Var2 Var3
total 
female
male


PANEL2
		|Var1 Var2 Var3
C2
C1+C2
C1-C3


PANEL3 & 4 wie 1 &2 aber mit 2 Jahren zusammengefasst
5 & 6 mit 4 Jahren zusammengefasst


*/






// ***************************** PREAMBLE********************************
	clear all
	set more off
	
	global path   "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis"	
	global temp   "$path/temp"
	global graphs "$path/graphs/KKH"
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
	use "$temp\KKH_final_R1", clear
run "$auxiliary/varlists_varnames_sample-spcifications"
	
	
		
	
********************************************************************************
// THE PROGRAM
capture program drop DDRD
program define DDRD
		qui reg `1' treat after TxA i.MOB   `2'  , vce(cluster MxY) 
end
********************************************************************************


*-------------------------------------------------------------------------------
* 1) GENDER AND RATIOS AVAILABLE ( VARIABLES OF MAIN INTEREST)
*-------------------------------------------------------------------------------
// PANEL 1.1: PLOTS FOR EACH GENDER SEPERATELY (WITH CG2!) 
capture drop Dinregression
qui gen Dinregression = 1 if cond($C2,1,0)

*br
*order Dinregression sum_num_diagnoses r_fert_d5
*drop sum_num_diagnoses_mtotal

* NOTE: DIFFERENCE Background line is in cases per thousand

foreach 1 of varlist d5 { // $list_vars_mandf_ratios_available
	capture drop sum_num_diag*
	bys Dinregression year_treat: egen sum_num_diagnoses = mean(r_fert_`1')
	bys Dinregression year_treat: egen sum_num_diagnoses_f = mean(r_fert_`1'_f)
	bys Dinregression year_treat: egen sum_num_diagnoses_m = mean(r_fert_`1'_m)
	
	foreach var in "r_fert_"    {	// COLUMNS "" "r_fert_"  "r_popf_"
		capture drop b* CIL* CIR*
		foreach j in "" "_f" "_m" { // rows
			
			qui gen b`j' =.
			qui gen CIL95`j' =.
			qui gen CIR95`j' =. 
			qui gen CIL90`j' =.
			qui gen CIR90`j' =. 
			
			qui summ year_treat if !missing(`var'`1') & treat == 1
			local start = r(min) + 1
			local ende = r(max)
			
			forvalues X = `start' (1) `ende' {
				DDRD `var'`1'`j'  " if year_treat == `X' & $C2"
				qui replace b`j' = _b[TxA] if year_treat == `X'
				qui replace CIL95`j' = (_b[TxA]- $t_95 *_se[TxA]) if year_treat == `X'
				qui replace CIR95`j' = (_b[TxA]+ $t_95 *_se[TxA]) if year_treat == `X'
				qui replace CIL90`j' = (_b[TxA]- $t_90 *_se[TxA]) if year_treat == `X'
				qui replace CIR90`j' = (_b[TxA]+ $t_90 *_se[TxA]) if year_treat == `X'
				
			} //end:loop over lifecycle
		} //end:loop t,f,m (ROWS)
		local start_mtick = `start' + 2 
		*total
		twoway line sum_num_diagnoses year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs14) lw(vthick) yaxis(2)  || ///
			rarea CIL95 CIR95 year_treat, sort  color(black%22) yaxis(1) || ///
			rarea CIL90 CIR90 year_treat, sort  color(black%45) yaxis(1) || ///
			line b year_treat, sort color(black) yaxis(1) ///
			scheme(s1mono)  /// 
			yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
			legend(label(2 "95% CI") label(3 "90% CI")) ///
			legend(order(3 2)) legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
			legend(region(color(none))) legend(symx(5)) ///
			xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") ///
			xmtick(`start_mtick'  (4) `ende') ///
			ytitle("ITT effect", axis(1)) ytitle("Number of diagnoses [per 1000 persons]",axis(2)) ///
			yscale(alt axis(2)) yscale(alt axis(1)) 
			graph export "$graphs/lc_`var'`1'total.pdf", as(pdf) replace	
				
		*female
		twoway line sum_num_diagnoses_f year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs14) lw(vthick) yaxis(2)  || ///
			rarea CIL95_f CIR95_f year_treat, sort  color(red%22) yaxis(1) || ///
			rarea CIL90_f CIR90_f year_treat, sort  color(red%45) yaxis(1) || ///
			line b_f year_treat, sort color(red) yaxis(1) ///
			scheme(s1mono)  /// 
			yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
			legend(label(2 "95% CI") label(3 "90% CI")) ///
			legend(order(3 2)) legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
			legend(region(color(none))) legend(symx(5)) ///
			xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") ///
			xmtick(`start_mtick'  (4) `ende') ///
			ytitle("ITT effect", axis(1)) ytitle("Number of diagnoses [per 1000 persons]",axis(2)) ///
			yscale(alt axis(2)) yscale(alt axis(1)) 
			graph export "$graphs/lc_`var'`1'female.pdf", as(pdf) replace		
		*male
		twoway line sum_num_diagnoses_m year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs14) lw(vthick) yaxis(2)  || ///
			rarea CIL95_m CIR95_m year_treat, sort  color(blue%22) yaxis(1) || ///
			rarea CIL90_m CIR90_m year_treat, sort  color(blue%45) yaxis(1) || ///
			line b_m year_treat, sort color(blue) yaxis(1) ///
			scheme(s1mono)  /// 
			yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
			legend(label(2 "95% CI") label(3 "90% CI")) ///
			legend(order(3 2)) legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
			legend(region(color(none))) legend(symx(5)) ///
			xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") ///
			xmtick(`start_mtick'  (4) `ende') ///
			ytitle("ITT effect", axis(1)) ytitle("Number of diagnoses [per 1000 persons]",axis(2)) ///
			yscale(alt axis(2)) yscale(alt axis(1)) 
			graph export "$graphs/lc_`var'`1'male.pdf", as(pdf) replace	
		
			
	} //end: loop over variable specification (COLUMNS)
		
	} //end: loop over variables
	
	
/////////////////////////////////////////////////////////////////////////////////
* Graph: wie teilt sich ITT auf Unterdiagnosen auf
/////////////////////////////////////////////////////////////////////////////////
clear all
set more off

global path   "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis"	
global temp   "$path/temp"
global graphs_presentation "$path/graphs/presentation"
global tables "$path/tables/KKH"
global auxiliary "$path/do-files/auxiliary_files"
		
	
	
clear all
set obs 6
//for total and BW 6 M

*gen str group = "overall" in 1
gen str group = "1" in 1
gen str beta = "-0.831" in 1
gen str SE = "0.229" in 1


*replace group = "drug abuse" in 2
replace group = "2" in 2
replace beta = "-0.616" in 2
replace SE = "0.116" in 2

*replace group = "shizophrenia" in 3
replace group = "3" in 3
replace beta = "-0.345" in 3
replace SE = "0.113" in 3

*replace group = "affective" in 4
replace group = "4" in 4
replace beta = "0.172" in 4
replace SE = "0.0474" in 4

*replace group = "neurosis" in 5
replace group = "5" in 5
replace beta = "0.0446" in 5
replace SE = "0.0375" in 5

*replace group = "personality" in 6
replace group = "6" in 6
replace beta = "-0.0435" in 6
replace SE = "0.0449" in 6



destring beta SE group, replace
gen CI_low=beta-1.64*SE
gen CI_high=beta+1.64*SE
label define grlab 0 "" 1 "all F diagnoses" 2 "drug abuse" 3 "shizophrenia" 4 "affective" 5 "neurosis" 6 "personality" 7 ""
label values group grlab
label var beta "ITT effect"

*save "bw_heterogeneity.dta", replace

eclplot beta CI_low CI_high group, yline(0, lc(black)) ylabel(, nogrid) xlabel(1 2 3 4 5 6, valuelabel angle(45)) ///
								   graphregion(color(white)) xscale(range(0.5 6.5)) yscale(range(0 1)) ///
								   xtitle("") yscale(r(-1.5 0.5))
								   
graph export "$graphs_presentation/itt_subcategories.pdf", as(pdf) replace									   
	
	
	
///////////////////////////////////////////////////////////////////////////////	
		global t_95   	  = 1.960
		import delimited "$temp/placebo/r_popf_d5_graph.csv", stripquote(yes) clear
		gen k = substr(v1,2,3)
		gen b = substr(v2,2,.)
		gen se = substr(v3,2,.)
		qui drop v*
		destring *, replace
		format k %tm
		
		qui gen CI_low = b - ($t_95 * se )
		qui gen CI_up  = b + ($t_95 * se)
		
		scatter b k, m(O) color(black) || ///
			rcap CI_low CI_up k, color(black) lw(thin) ///
			yline(0, lc(black)) ///
			ylabel(, nogrid) xlabel(220(2) 226, valuelabel angle(45)) ///
			xtick(221(2)226) ///
			graphregion(color(white)) xscale(range(220 227)) ///
			xtitle("Start of pseudo treatment cohort") ytitle("") legend(off) ///
			yscale(r(-0.5 1.5))
			
		graph export "$graphs_presentation/placebograph_d5.pdf" , as(pdf) replace
///////////////////////////////////////////////////////////////////////////////		
		
	clear all 
global path  "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis"		//MAC at work
global source   "$path/source/KKH_FDZ" 
global graphs_presentation "$path/graphs/presentation"

use "$temp\KKH_final_R1", clear
 
keep if GDR == 0 
keep if treat == 1 | control == 2

collapse (sum) drug_abuse d5, by(year control)

merge 1:1 year control using "$source/number_diagnoses_per_year.dta" 
drop _merge
qui gen temp = d5 - drug - shizo - affect - neurosis - personality

keep if control == 4

	
* area graph 
qui gen t1 = temp 
qui gen t2 = temp + personality
qui gen t3 = t2 + neurosis 
qui gen t4 = t3 + affective 
qui gen t5 = t4 + shizo 
qui gen t6 = t5 + drug_abuse

*label
	#delim ;
	label define YEAR 
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
	label values year YEAR


twoway area t6 year, color(navy) || ///
	area t5  year, color(maroon) || ///
	area t4 year, color( forest_green) ||  ///
	area t3 year, color(dkorange) || ///
	area t2 year, color(emerald) || ///
	area t1 year, ///
	scheme(s1mono) ///
	ytitle("All mental and behavioral disorders") ///
	legend(c(3) lab(1 "drug abuse") lab(2 "shizophrenia") lab(3 "affective") ///
	lab(4 "neurosis") lab(5 "personality") lab(6 "other")) ///
	legend(size(small)) ///
	xlabel(1996 (4) 2014 ,val angle(0)) ///
	xmtick(1996 (2) 2014)  ///
	ylabel(, format(%9.0f))

	 
graph export "$graphs_presentation/d5partition.pdf", as(pdf) replace	
	