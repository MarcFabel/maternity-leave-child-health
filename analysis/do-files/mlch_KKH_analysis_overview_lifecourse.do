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
// Variablen, die noch ins prepare do-file ausgelagert werden müssen
	*generate age_treat: age of the respective treatment cohort -> harmonisieren des Alters

	
	*generieren der Variablen um Jahre für den LC zusammenfassen - 2 & 4 steps
	qui gen year_treat_2 = . 
	qui gen year_treat_4 = .
	local j = 1
	qui summ year_treat if !missing(d5) & treat == 1
	local jahr = r(min)
	local ende = r(max)
	while `jahr' <= `ende'{
		qui replace year_treat_2 = `j' if year_treat == `jahr' | year_treat == `jahr'+1
		local jahr = `jahr' + 2
		local j = `j' + 1
	}
	local j = 1
	qui summ year_treat if !missing(d5) & treat == 1
	local jahr = r(min)
	local ende = r(max)
	while `jahr' <= `ende'{
		qui replace year_treat_4 = `j' if (year_treat >= `jahr' & year_treat <= `jahr'+4) 
		local jahr = `jahr' + 4
		local j = `j' + 1
	}  
	
	
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

foreach 1 of varlist $list_vars_mandf_ratios_available { // $list_vars_mandf_ratios_available
	capture drop sum_num_diag*
	bys Dinregression year_treat: egen sum_num_diagnoses = total(`1')
	bys Dinregression year_treat: egen sum_num_diagnoses_f = total(`1'_f)
	bys Dinregression year_treat: egen sum_num_diagnoses_m = total(`1'_m)
	
	foreach var in "" "r_fert_"  "r_popf_"  {	// COLUMNS
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
			rarea CIL95 CIR95 year_treat, sort  color(black%12) yaxis(1) || ///
			rarea CIL90 CIR90 year_treat, sort  color(black%25) yaxis(1) || ///
			line b year_treat, sort color(black) yaxis(1) ///
			scheme(s1mono)  /// 
			yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
			legend(label(2 "95% CI") label(3 "90% CI")) ///
			legend(order(3 2)) legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
			legend(region(color(none))) legend(symx(5)) ///
			xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") ///
			xmtick(`start_mtick'  (4) `ende') ///
			ytitle("ITT effect", axis(1)) ytitle("Number of diagnoses",axis(2)) ///
			yscale(alt axis(2)) yscale(alt axis(1)) nodraw ///
			saving($graphs/total_`var', replace)	
		*female
		twoway line sum_num_diagnoses_f year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs14) lw(vthick) yaxis(2)  || ///
			rarea CIL95_f CIR95_f year_treat, sort  color(red%12) yaxis(1) || ///
			rarea CIL90_f CIR90_f year_treat, sort  color(red%25) yaxis(1) || ///
			line b_f year_treat, sort color(red) yaxis(1) ///
			scheme(s1mono)  /// 
			yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
			legend(label(2 "95% CI") label(3 "90% CI")) ///
			legend(order(3 2)) legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
			legend(region(color(none))) legend(symx(5)) ///
			xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") ///
			xmtick(`start_mtick'  (4) `ende') ///
			ytitle("ITT effect", axis(1)) ytitle("Number of diagnoses",axis(2)) ///
			yscale(alt axis(2)) yscale(alt axis(1)) nodraw ///
			saving($graphs/female_`var', replace)	
		*male
		twoway line sum_num_diagnoses_m year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs14) lw(vthick) yaxis(2)  || ///
			rarea CIL95_m CIR95_m year_treat, sort  color(blue%12) yaxis(1) || ///
			rarea CIL90_m CIR90_m year_treat, sort  color(blue%25) yaxis(1) || ///
			line b_m year_treat, sort color(blue) yaxis(1) ///
			scheme(s1mono)  /// 
			yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
			legend(label(2 "95% CI") label(3 "90% CI")) ///
			legend(order(3 2)) legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
			legend(region(color(none))) legend(symx(5)) ///
			xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") ///
			xmtick(`start_mtick'  (4) `ende') ///
			ytitle("ITT effect", axis(1)) ytitle("Number of diagnoses",axis(2)) ///
			yscale(alt axis(2)) yscale(alt axis(1)) nodraw ///
			saving($graphs/male_`var', replace)	
		
			
	} //end: loop over variable specification (COLUMNS)
	graph combine "$graphs/total_.gph"			"$graphs/female_.gph"			"$graphs/male_.gph"  ///
				  "$graphs/total_r_fert_.gph"	"$graphs/female_r_fert_.gph"	"$graphs/male_r_fert_.gph" ///
				  "$graphs/total_r_popf_.gph"	"$graphs/female_r_popf_.gph"	"$graphs/male_r_popf_.gph", altshrink ///
				  title(LC: per gender) subtitle("$`1'")   ///
				  t1title("total              		female              		male") ///
				  l1title("Ratio_pop		Ratio_fert		Abs numbers") /// 
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/lc_`1'_overview_panel1.pdf", as(pdf) replace	
		
	} //end: loop over variables

/*
PREVIOUS VERSION OF PANEL !
	foreach 1 of varlist $list_vars_mandf_ratios_available { 
		foreach var in "" "r_fert_" "r_popf_" {	// COLUMNS
			foreach j in "" "_f" "_m" { // rows
				capture drop b`j' CIL`j' CIR`j'
				qui gen b`j' =.
				qui gen CIL`j' =.
				qui gen CIR`j' =. 
				
				qui summ year_treat if !missing(`var'`1') & treat == 1
				local start = r(min)
				local ende = r(max)
				
				forvalues X = `start' (1) `ende' {
					DDRD `var'`1'`j'  " if year_treat == `X' & $C2"
					qui replace b`j' = _b[TxA] if year_treat == `X'
					qui replace CIL`j' = (_b[TxA]- $t_90 *_se[TxA]) if year_treat == `X'
					qui replace CIR`j' = (_b[TxA]+ $t_90 *_se[TxA]) if year_treat == `X'
				} //end:loop over lifecycle
			} //end:loop t,f,m (ROWS)
			*total
			twoway rarea CIL CIR year_treat, sort  color(black%12) || ///
				line b year_treat, sort color(gray) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/total_`var', replace)
			*female
			twoway rarea CIL_f CIR_f year_treat, sort  color(red%12) || ///
				line b_f year_treat, sort color(red) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/female_`var', replace)	
			*male
			twoway rarea CIL_m CIR_m year_treat, sort  color(blue%12) || ///
				line b_m year_treat, sort color(blue) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/male_`var', replace)	
			
				
		} //end: loop over variable specification (COLUMNS)
	graph combine "$graphs/total_.gph"			"$graphs/female_.gph"			"$graphs/male_.gph"  ///
				  "$graphs/total_r_fert_.gph"	"$graphs/female_r_fert_.gph"	"$graphs/male_r_fert_.gph" ///
				  "$graphs/total_r_popf_.gph"	"$graphs/female_r_popf_.gph"	"$graphs/male_r_popf_.gph", altshrink ///
				  title(LC: per gender) subtitle("$`1'")   ///
				  t1title("total              		female              		male") ///
				  l1title("Ratio_pop		Ratio_fert		Abs numbers") /// 
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/lc_`1'_overview_panel1.pdf", as(pdf) replace	
		
	} //end: loop over variables
*/


********************************************************************************
// PANEL 1.2: CHOICE OF CONTROL GROUP
	foreach 1 of varlist $list_vars_mandf_ratios_available { 
		foreach control_group in "C2" "C1_C2" "C1_C3" { // Columns
			foreach var in "" "r_fert_" "r_popf_" {	// ROWS
				foreach j in "" "_f" "_m" {
					capture drop b`j' CIL`j' CIR`j'
					qui gen b`j' =.
					qui gen CIL`j' =.
					qui gen CIR`j' =. 
					
					qui summ year_treat if !missing(`var'`1') & treat == 1
					local start = r(min)
					local ende = r(max)
					
					forvalues X = `start' (1) `ende' {
						DDRD `var'`1'`j'  " if year_treat == `X' & $`control_group'"
						qui replace b`j' = _b[TxA] if year_treat == `X'
						qui replace CIL`j' = (_b[TxA]- $t_90 *_se[TxA]) if year_treat == `X'
						qui replace CIR`j' = (_b[TxA]+ $t_90 *_se[TxA]) if year_treat == `X'
					} //end:loop over lifecycle
				} //end:loop t,f,m
				twoway rarea CIL CIR year_treat, sort  color(black%12) || ///
					line b year_treat, sort color(gray) || ///
					rarea  CIL_f CIR_f year_treat, sort  color(red%10) || ///
					line b_f year_treat, sort color(red) || ///
					rarea  CIL_m CIR_m year_treat, sort  color(blue%8) || ///
					line b_m year_treat, sort color(blue) ///
					scheme(s1mono)  /// 
					yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
					legend(label(2 "total") label(4 "female") label(6 "male")) ///
					legend(order(2 4 6)) legend(pos(8) ring(0) col(3)) legend(size(small)) ///
					xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") nodraw ///
					saving($graphs/`control_group'_`var', replace)
					*	taken out: title($`1') ytitle(ITT estimate of `1')
					*	xtitle("Year [Age of treatment cohort]")   ///
					*	graph save "$graphs/`control_group'_`var'", replace
					
			} //end: loop over variable specification (ROWS)
		} //end: loop over control_groups (COLUMNS)
	graph combine "$graphs/C2_.gph"        "$graphs/C1_C2_.gph"			"$graphs/C1_C3_.gph" ///
				  "$graphs/C2_r_fert_.gph" "$graphs/C1_C2_r_fert_.gph"	"$graphs/C1_C3_r_fert_.gph" ///
				  "$graphs/C2_r_popf_.gph" "$graphs/C1_C2_r_popf_.gph"	"$graphs/C1_C3_r_popf_.gph", altshrink ///
				  title(LC: different Control groups) subtitle("$`1'")   ///
				  t1title("CG2             		  C1+C2             		  CG1-CG3") ///
				  l1title("Ratio_pop	   Ratio_fert	     Abs numbers") /// 
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/lc_`1'_overview_panel2.pdf", as(pdf) replace	
		
	} //end: loop over variables		
********************************************************************************
// PANEL 1.3: JAHRE ZUSAMMENNEHEMN UM POWER ZU ERHÖHEN
foreach 1 of varlist $list_vars_mandf_ratios_available { 
		foreach var in "" "r_fert_" "r_popf_" {	// COLUMNS
			foreach j in "" "_f" "_m" { // rows
				capture drop b`j' CIL`j' CIR`j'
				qui gen b`j' =.
				qui gen CIL`j' =.
				qui gen CIR`j' =. 
				
				qui summ year_treat_2 if !missing(`var'`1') & treat == 1
				local start = r(min)
				local ende = r(max)
				
				forvalues X = `start' (1) `ende' {
					DDRD `var'`1'`j'  " if year_treat_2 == `X' & $C2"
					qui replace b`j' = _b[TxA] if year_treat_2 == `X'
					qui replace CIL`j' = (_b[TxA]- $t_90 *_se[TxA]) if year_treat_2 == `X'
					qui replace CIR`j' = (_b[TxA]+ $t_90 *_se[TxA]) if year_treat_2 == `X'
				} //end:loop over lifecycle
			} //end:loop t,f,m (ROWS)
			*total
			twoway rarea CIL CIR year_treat_2, sort  color(black%12) || ///
				line b year_treat_2, sort color(gray) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (2) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/total_`var', replace)
			*female
			twoway rarea CIL_f CIR_f year_treat_2, sort  color(red%12) || ///
				line b_f year_treat_2, sort color(red) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (2) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/female_`var', replace)	
			*male
			twoway rarea CIL_m CIR_m year_treat_2, sort  color(blue%12) || ///
				line b_m year_treat_2, sort color(blue) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (2) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/male_`var', replace)	
			
				
		} //end: loop over variable specification (COLUMNS)
	graph combine "$graphs/total_.gph"			"$graphs/female_.gph"			"$graphs/male_.gph"  ///
				  "$graphs/total_r_fert_.gph"	"$graphs/female_r_fert_.gph"	"$graphs/male_r_fert_.gph" ///
				  "$graphs/total_r_popf_.gph"	"$graphs/female_r_popf_.gph"	"$graphs/male_r_popf_.gph", altshrink ///
				  title(LC: per gender - 2 Jahre zusammengefasst) subtitle("$`1'")   ///
				  t1title("total              		female              		male") ///
				  l1title("Ratio_pop		Ratio_fert		Abs numbers") /// 
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/lc_`1'_overview_panel3.pdf", as(pdf) replace	
		
	} //end: loop over variables
		
********************************************************************************
// PANEL 1.4: CHOICE OF CONTROL GROUP - 2 JAHRE ZUSAMMENGEFASST
	foreach 1 of varlist $list_vars_mandf_ratios_available { 
		foreach control_group in "C2" "C1_C2" "C1_C3" { // Columns
			foreach var in "" "r_fert_" "r_popf_" {	// ROWS
				foreach j in "" "_f" "_m" {
					capture drop b`j' CIL`j' CIR`j'
					qui gen b`j' =.
					qui gen CIL`j' =.
					qui gen CIR`j' =. 
					
					qui summ year_treat_2 if !missing(`var'`1') & treat == 1
					local start = r(min)
					local ende = r(max)
					
					forvalues X = `start' (1) `ende' {
						DDRD `var'`1'`j'  " if year_treat_2 == `X' & $`control_group'"
						qui replace b`j' = _b[TxA] if year_treat_2 == `X'
						qui replace CIL`j' = (_b[TxA]- $t_90 *_se[TxA]) if year_treat_2 == `X'
						qui replace CIR`j' = (_b[TxA]+ $t_90 *_se[TxA]) if year_treat_2 == `X'
					} //end:loop over lifecycle
				} //end:loop t,f,m
				twoway rarea CIL CIR year_treat_2, sort  color(black%12) || ///
					line b year_treat_2, sort color(gray) || ///
					rarea  CIL_f CIR_f year_treat_2, sort  color(red%10) || ///
					line b_f year_treat_2, sort color(red) || ///
					rarea  CIL_m CIR_m year_treat_2, sort  color(blue%8) || ///
					line b_m year_treat_2, sort color(blue) ///
					scheme(s1mono)  /// 
					yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
					legend(label(2 "total") label(4 "female") label(6 "male")) ///
					legend(order(2 4 6)) legend(pos(8) ring(0) col(3)) legend(size(small)) ///
					xlabel(`start' (2) `ende' ,val angle(0)) xtitle("") nodraw ///
					saving($graphs/`control_group'_`var', replace)
					*	taken out: title($`1') ytitle(ITT estimate of `1')
					*	xtitle("Year [Age of treatment cohort]")   ///
					*	graph save "$graphs/`control_group'_`var'", replace
					
			} //end: loop over variable specification (ROWS)
		} //end: loop over control_groups (COLUMNS)
	graph combine "$graphs/C2_.gph"        "$graphs/C1_C2_.gph"			"$graphs/C1_C3_.gph" ///
				  "$graphs/C2_r_fert_.gph" "$graphs/C1_C2_r_fert_.gph"	"$graphs/C1_C3_r_fert_.gph" ///
				  "$graphs/C2_r_popf_.gph" "$graphs/C1_C2_r_popf_.gph"	"$graphs/C1_C3_r_popf_.gph", altshrink ///
				  title(LC: different Control groups - 2 Jahre zusammengefasst) subtitle("$`1'")   ///
				  t1title("CG2             		  C1+C2             		  CG1-CG3") ///
				  l1title("Ratio_pop	   Ratio_fert	     Abs numbers") /// 
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/lc_`1'_overview_panel4.pdf", as(pdf) replace	
		
	} //end: loop over variables
********************************************************************************
// PANEL 1.5: JAHRE ZUSAMMENNEHEMN UM POWER ZU ERHÖHEN - 4 JAHRE ZUSAMMENGEFASST
foreach 1 of varlist $list_vars_mandf_ratios_available { 
		foreach var in "" "r_fert_" "r_popf_" {	// COLUMNS
			foreach j in "" "_f" "_m" { // rows
				capture drop b`j' CIL`j' CIR`j'
				qui gen b`j' =.
				qui gen CIL`j' =.
				qui gen CIR`j' =. 
				
				qui summ year_treat_4 if !missing(`var'`1') & treat == 1
				local start = r(min)
				local ende = r(max)
				
				forvalues X = `start' (1) `ende' {
					DDRD `var'`1'`j'  " if year_treat_4 == `X' & $C2"
					qui replace b`j' = _b[TxA] if year_treat_4 == `X'
					qui replace CIL`j' = (_b[TxA]- $t_90 *_se[TxA]) if year_treat_4 == `X'
					qui replace CIR`j' = (_b[TxA]+ $t_90 *_se[TxA]) if year_treat_4 == `X'
				} //end:loop over lifecycle
			} //end:loop t,f,m (ROWS)
			*total
			twoway rarea CIL CIR year_treat_4, sort  color(black%12) || ///
				line b year_treat_4, sort color(gray) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (1) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/total_`var', replace)
			*female
			twoway rarea CIL_f CIR_f year_treat_4, sort  color(red%12) || ///
				line b_f year_treat_4, sort color(red) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (1) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/female_`var', replace)	
			*male
			twoway rarea CIL_m CIR_m year_treat_4, sort  color(blue%12) || ///
				line b_m year_treat_4, sort color(blue) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (1) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/male_`var', replace)	
			
				
		} //end: loop over variable specification (COLUMNS)
	graph combine "$graphs/total_.gph"			"$graphs/female_.gph"			"$graphs/male_.gph"  ///
				  "$graphs/total_r_fert_.gph"	"$graphs/female_r_fert_.gph"	"$graphs/male_r_fert_.gph" ///
				  "$graphs/total_r_popf_.gph"	"$graphs/female_r_popf_.gph"	"$graphs/male_r_popf_.gph", altshrink ///
				  title(LC: per gender - 4 Jahre zusammengefasst) subtitle("$`1'")   ///
				  t1title("total              		female              		male") ///
				  l1title("Ratio_pop		Ratio_fert		Abs numbers") /// 
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/lc_`1'_overview_panel5.pdf", as(pdf) replace	
		
	} //end: loop over variables
		
********************************************************************************
// PANEL 1.6: CHOICE OF CONTROL GROUP - 4 JAHRE ZUSAMMENGEFASST
	foreach 1 of varlist $list_vars_mandf_ratios_available { 
		foreach control_group in "C2" "C1_C2" "C1_C3" { // Columns
			foreach var in "" "r_fert_" "r_popf_" {	// ROWS
				foreach j in "" "_f" "_m" {
					capture drop b`j' CIL`j' CIR`j'
					qui gen b`j' =.
					qui gen CIL`j' =.
					qui gen CIR`j' =. 
					
					qui summ year_treat_4 if !missing(`var'`1') & treat == 1
					local start = r(min)
					local ende = r(max)
					
					forvalues X = `start' (1) `ende' {
						DDRD `var'`1'`j'  " if year_treat_4 == `X' & $`control_group'"
						qui replace b`j' = _b[TxA] if year_treat_4 == `X'
						qui replace CIL`j' = (_b[TxA]- $t_90 *_se[TxA]) if year_treat_4 == `X'
						qui replace CIR`j' = (_b[TxA]+ $t_90 *_se[TxA]) if year_treat_4 == `X'
					} //end:loop over lifecycle
				} //end:loop t,f,m
				twoway rarea CIL CIR year_treat_4, sort  color(black%12) || ///
					line b year_treat_4, sort color(gray) || ///
					rarea  CIL_f CIR_f year_treat_4, sort  color(red%10) || ///
					line b_f year_treat_4, sort color(red) || ///
					rarea  CIL_m CIR_m year_treat_4, sort  color(blue%8) || ///
					line b_m year_treat_4, sort color(blue) ///
					scheme(s1mono)  /// 
					yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
					legend(label(2 "total") label(4 "female") label(6 "male")) ///
					legend(order(2 4 6)) legend(pos(8) ring(0) col(3)) legend(size(small)) ///
					xlabel(`start' (1) `ende' ,val angle(0)) xtitle("") nodraw ///
					saving($graphs/`control_group'_`var', replace)
					*	taken out: title($`1') ytitle(ITT estimate of `1')
					*	xtitle("Year [Age of treatment cohort]")   ///
					*	graph save "$graphs/`control_group'_`var'", replace
					
			} //end: loop over variable specification (ROWS)
		} //end: loop over control_groups (COLUMNS)
	graph combine "$graphs/C2_.gph"        "$graphs/C1_C2_.gph"			"$graphs/C1_C3_.gph" ///
				  "$graphs/C2_r_fert_.gph" "$graphs/C1_C2_r_fert_.gph"	"$graphs/C1_C3_r_fert_.gph" ///
				  "$graphs/C2_r_popf_.gph" "$graphs/C1_C2_r_popf_.gph"	"$graphs/C1_C3_r_popf_.gph", altshrink ///
				  title(LC: different Control groups - 4 Jahre zusammengefasst) subtitle("$`1'")   ///
				  t1title("CG2             		  C1+C2             		  CG1-CG3") ///
				  l1title("Ratio_pop	   Ratio_fert	     Abs numbers") /// 
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/lc_`1'_overview_panel6.pdf", as(pdf) replace	
		
	} //end: loop over variables



*-------------------------------------------------------------------------------
* 2) FÜR AVERAGES (NO RATIOS AVAILABLE
*-------------------------------------------------------------------------------
// PANEL 2.1: PLOTS FOR EACH GENDER SEPERATELY (WITH CG2!) 
	foreach 1 of varlist $list_vars_mandf_no_ratios { 
			foreach j in "" "_f" "_m" { // rows
				capture drop b`j' CIL`j' CIR`j'
				qui gen b`j' =.
				qui gen CIL`j' =.
				qui gen CIR`j' =. 
				
				qui summ year_treat if !missing(`var'`1') & treat == 1
				local start = r(min)
				local ende = r(max)
				
				forvalues X = `start' (1) `ende' {
					DDRD `var'`1'`j'  " if year_treat == `X' & $C2"
					qui replace b`j' = _b[TxA] if year_treat == `X'
					qui replace CIL`j' = (_b[TxA]- $t_90 *_se[TxA]) if year_treat == `X'
					qui replace CIR`j' = (_b[TxA]+ $t_90 *_se[TxA]) if year_treat == `X'
				} //end:loop over lifecycle
			} //end:loop t,f,m (ROWS)
			*total
			twoway rarea CIL CIR year_treat, sort  color(black%12) || ///
				line b year_treat, sort color(gray) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/total_`var', replace)
			*female
			twoway rarea CIL_f CIR_f year_treat, sort  color(red%12) || ///
				line b_f year_treat, sort color(red) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/female_`var', replace)	
			*male
			twoway rarea CIL_m CIR_m year_treat, sort  color(blue%12) || ///
				line b_m year_treat, sort color(blue) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/male_`var', replace)	
			
				
	graph combine "$graphs/total_.gph"			"$graphs/female_.gph"			"$graphs/male_.gph" , altshrink ///
				  title(LC: per gender) subtitle("$`1'")   ///
				  t1title("total              		female              		male") ///
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/lc_`1'_overview_panel1.pdf", as(pdf) replace	
		
	} //end: loop over variables

********************************************************************************
// PANEL 2.2: CHOICE OF CONTROL GROUP
	foreach 1 of varlist $list_vars_mandf_no_ratios { 
		foreach control_group in "C2" "C1_C2" "C1_C3" { // Columns
				foreach j in "" "_f" "_m" {
					capture drop b`j' CIL`j' CIR`j'
					qui gen b`j' =.
					qui gen CIL`j' =.
					qui gen CIR`j' =. 
					
					qui summ year_treat if !missing(`var'`1') & treat == 1
					local start = r(min)
					local ende = r(max)
					
					forvalues X = `start' (1) `ende' {
						DDRD `var'`1'`j'  " if year_treat == `X' & $`control_group'"
						qui replace b`j' = _b[TxA] if year_treat == `X'
						qui replace CIL`j' = (_b[TxA]- $t_90 *_se[TxA]) if year_treat == `X'
						qui replace CIR`j' = (_b[TxA]+ $t_90 *_se[TxA]) if year_treat == `X'
					} //end:loop over lifecycle
				} //end:loop t,f,m
				twoway rarea CIL CIR year_treat, sort  color(black%12) || ///
					line b year_treat, sort color(gray) || ///
					rarea  CIL_f CIR_f year_treat, sort  color(red%10) || ///
					line b_f year_treat, sort color(red) || ///
					rarea  CIL_m CIR_m year_treat, sort  color(blue%8) || ///
					line b_m year_treat, sort color(blue) ///
					scheme(s1mono)  /// 
					yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
					legend(label(2 "total") label(4 "female") label(6 "male")) ///
					legend(order(2 4 6)) legend(pos(8) ring(0) col(3)) legend(size(small)) ///
					xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") nodraw ///
					saving($graphs/`control_group'_`var', replace)
					*	taken out: title($`1') ytitle(ITT estimate of `1')
					*	xtitle("Year [Age of treatment cohort]")   ///
					*	graph save "$graphs/`control_group'_`var'", replace
					
		} //end: loop over control_groups (COLUMNS)
	graph combine "$graphs/C2_.gph"        "$graphs/C1_C2_.gph"			"$graphs/C1_C3_.gph", altshrink ///
				  title(LC: different Control groups) subtitle($`1')   ///
				  t1title("CG2             		  C1+C2             		  CG1-CG3") ///
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/lc_`1'_overview_panel2.pdf", as(pdf) replace	
		
	} //end: loop over variables		
********************************************************************************
// PANEL 2.3: JAHRE ZUSAMMENNEHEMN UM POWER ZU ERHÖHEN
foreach 1 of varlist $list_vars_mandf_no_ratios { 
			foreach j in "" "_f" "_m" { // rows
				capture drop b`j' CIL`j' CIR`j'
				qui gen b`j' =.
				qui gen CIL`j' =.
				qui gen CIR`j' =. 
				
				qui summ year_treat_2 if !missing(`var'`1') & treat == 1
				local start = r(min)
				local ende = r(max)
				
				forvalues X = `start' (1) `ende' {
					DDRD `var'`1'`j'  " if year_treat_2 == `X' & $C2"
					qui replace b`j' = _b[TxA] if year_treat_2 == `X'
					qui replace CIL`j' = (_b[TxA]- $t_90 *_se[TxA]) if year_treat_2 == `X'
					qui replace CIR`j' = (_b[TxA]+ $t_90 *_se[TxA]) if year_treat_2 == `X'
				} //end:loop over lifecycle
			} //end:loop t,f,m (ROWS)
			*total
			twoway rarea CIL CIR year_treat_2, sort  color(black%12) || ///
				line b year_treat_2, sort color(gray) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (2) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/total_`var', replace)
			*female
			twoway rarea CIL_f CIR_f year_treat_2, sort  color(red%12) || ///
				line b_f year_treat_2, sort color(red) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (2) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/female_`var', replace)	
			*male
			twoway rarea CIL_m CIR_m year_treat_2, sort  color(blue%12) || ///
				line b_m year_treat_2, sort color(blue) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (2) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/male_`var', replace)	
			
				
	graph combine "$graphs/total_.gph"			"$graphs/female_.gph"			"$graphs/male_.gph", altshrink ///
				  title(LC: per gender - 2 Jahre zusammengefasst) subtitle($`1')   ///
				  t1title("total              		female              		male") ///
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/lc_`1'_overview_panel3.pdf", as(pdf) replace	
		
	} //end: loop over variables
		
********************************************************************************
// PANEL 2.4: CHOICE OF CONTROL GROUP - 2 JAHRE ZUSAMMENGEFASST
	foreach 1 of varlist $list_vars_mandf_no_ratios { 
		foreach control_group in "C2" "C1_C2" "C1_C3" { // Columns
				foreach j in "" "_f" "_m" {
					capture drop b`j' CIL`j' CIR`j'
					qui gen b`j' =.
					qui gen CIL`j' =.
					qui gen CIR`j' =. 
					
					qui summ year_treat_2 if !missing(`var'`1') & treat == 1
					local start = r(min)
					local ende = r(max)
					
					forvalues X = `start' (1) `ende' {
						DDRD `var'`1'`j'  " if year_treat_2 == `X' & $`control_group'"
						qui replace b`j' = _b[TxA] if year_treat_2 == `X'
						qui replace CIL`j' = (_b[TxA]- $t_90 *_se[TxA]) if year_treat_2 == `X'
						qui replace CIR`j' = (_b[TxA]+ $t_90 *_se[TxA]) if year_treat_2 == `X'
					} //end:loop over lifecycle
				} //end:loop t,f,m
				twoway rarea CIL CIR year_treat_2, sort  color(black%12) || ///
					line b year_treat_2, sort color(gray) || ///
					rarea  CIL_f CIR_f year_treat_2, sort  color(red%10) || ///
					line b_f year_treat_2, sort color(red) || ///
					rarea  CIL_m CIR_m year_treat_2, sort  color(blue%8) || ///
					line b_m year_treat_2, sort color(blue) ///
					scheme(s1mono)  /// 
					yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
					legend(label(2 "total") label(4 "female") label(6 "male")) ///
					legend(order(2 4 6)) legend(pos(8) ring(0) col(3)) legend(size(small)) ///
					xlabel(`start' (2) `ende' ,val angle(0)) xtitle("") nodraw ///
					saving($graphs/`control_group'_`var', replace)
					*	taken out: title($`1') ytitle(ITT estimate of `1')
					*	xtitle("Year [Age of treatment cohort]")   ///
					*	graph save "$graphs/`control_group'_`var'", replace
					
		} //end: loop over control_groups (COLUMNS)
	graph combine "$graphs/C2_.gph"        "$graphs/C1_C2_.gph"			"$graphs/C1_C3_.gph" , altshrink ///
				  title(LC: different Control groups - 2 Jahre zusammengefasst) subtitle($`1')   ///
				  t1title("CG2             		  C1+C2             		  CG1-CG3") ///
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/lc_`1'_overview_panel4.pdf", as(pdf) replace	
		
	} //end: loop over variables
********************************************************************************
// PANEL 2.5: JAHRE ZUSAMMENNEHEMN UM POWER ZU ERHÖHEN - 4 JAHRE ZUSAMMENGEFASST
foreach 1 of varlist $list_vars_mandf_no_ratios { 
		foreach var in ""  {	// COLUMNS
			foreach j in "" "_f" "_m" { // rows
				capture drop b`j' CIL`j' CIR`j'
				qui gen b`j' =.
				qui gen CIL`j' =.
				qui gen CIR`j' =. 
				
				qui summ year_treat_4 if !missing(`var'`1') & treat == 1
				local start = r(min)
				local ende = r(max)
				
				forvalues X = `start' (1) `ende' {
					DDRD `var'`1'`j'  " if year_treat_4 == `X' & $C2"
					qui replace b`j' = _b[TxA] if year_treat_4 == `X'
					qui replace CIL`j' = (_b[TxA]- $t_90 *_se[TxA]) if year_treat_4 == `X'
					qui replace CIR`j' = (_b[TxA]+ $t_90 *_se[TxA]) if year_treat_4 == `X'
				} //end:loop over lifecycle
			} //end:loop t,f,m (ROWS)
			*total
			twoway rarea CIL CIR year_treat_4, sort  color(black%12) || ///
				line b year_treat_4, sort color(gray) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (1) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/total_`var', replace)
			*female
			twoway rarea CIL_f CIR_f year_treat_4, sort  color(red%12) || ///
				line b_f year_treat_4, sort color(red) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (1) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/female_`var', replace)	
			*male
			twoway rarea CIL_m CIR_m year_treat_4, sort  color(blue%12) || ///
				line b_m year_treat_4, sort color(blue) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (1) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/male_`var', replace)	
			
				
		} //end: loop over variable specification (COLUMNS)
	graph combine "$graphs/total_.gph"			"$graphs/female_.gph"			"$graphs/male_.gph" , altshrink ///
				  title(LC: per gender - 4 Jahre zusammengefasst) subtitle($`1')   ///
				  t1title("total              		female              		male") ///
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/lc_`1'_overview_panel5.pdf", as(pdf) replace	
		
	} //end: loop over variables
		
********************************************************************************
// PANEL 2.6: CHOICE OF CONTROL GROUP - 4 JAHRE ZUSAMMENGEFASST
	foreach 1 of varlist $list_vars_mandf_no_ratios { 
		foreach control_group in "C2" "C1_C2" "C1_C3" { // Columns
			foreach var in ""  {	// ROWS
				foreach j in "" "_f" "_m" {
					capture drop b`j' CIL`j' CIR`j'
					qui gen b`j' =.
					qui gen CIL`j' =.
					qui gen CIR`j' =. 
					
					qui summ year_treat_4 if !missing(`var'`1') & treat == 1
					local start = r(min)
					local ende = r(max)
					
					forvalues X = `start' (1) `ende' {
						DDRD `var'`1'`j'  " if year_treat_4 == `X' & $`control_group'"
						qui replace b`j' = _b[TxA] if year_treat_4 == `X'
						qui replace CIL`j' = (_b[TxA]- $t_90 *_se[TxA]) if year_treat_4 == `X'
						qui replace CIR`j' = (_b[TxA]+ $t_90 *_se[TxA]) if year_treat_4 == `X'
					} //end:loop over lifecycle
				} //end:loop t,f,m
				twoway rarea CIL CIR year_treat_4, sort  color(black%12) || ///
					line b year_treat_4, sort color(gray) || ///
					rarea  CIL_f CIR_f year_treat_4, sort  color(red%10) || ///
					line b_f year_treat_4, sort color(red) || ///
					rarea  CIL_m CIR_m year_treat_4, sort  color(blue%8) || ///
					line b_m year_treat_4, sort color(blue) ///
					scheme(s1mono)  /// 
					yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
					legend(label(2 "total") label(4 "female") label(6 "male")) ///
					legend(order(2 4 6)) legend(pos(8) ring(0) col(3)) legend(size(small)) ///
					xlabel(`start' (1) `ende' ,val angle(0)) xtitle("") nodraw ///
					saving($graphs/`control_group'_`var', replace)
					*	taken out: title($`1') ytitle(ITT estimate of `1')
					*	xtitle("Year [Age of treatment cohort]")   ///
					*	graph save "$graphs/`control_group'_`var'", replace
					
			} //end: loop over variable specification (ROWS)
		} //end: loop over control_groups (COLUMNS)
	graph combine "$graphs/C2_.gph"        "$graphs/C1_C2_.gph"			"$graphs/C1_C3_.gph" , altshrink ///
				  title(LC: different Control groups - 4 Jahre zusammengefasst) subtitle($`1')   ///
				  t1title("CG2             		  C1+C2             		  CG1-CG3") ///
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/lc_`1'_overview_panel6.pdf", as(pdf) replace	
		
	} //end: loop over variables








*-------------------------------------------------------------------------------
* 3) TOTAL AND RATIOS AVAILABLE 
*-------------------------------------------------------------------------------
// PANEL 3.1: PLOTS FOR EACH GENDER SEPERATELY (WITH CG2!) 
	foreach 1 of varlist $list_vars_total_ratios_available { 
		foreach var in "" "r_fert_" "r_popf_" {	// COLUMNS
			foreach j in ""  { // rows
				capture drop b`j' CIL`j' CIR`j'
				qui gen b`j' =.
				qui gen CIL`j' =.
				qui gen CIR`j' =. 
				
				qui summ year_treat if !missing(`var'`1') & treat == 1
				local start = r(min)
				local ende = r(max)
				
				forvalues X = `start' (1) `ende' {
					DDRD `var'`1'`j'  " if year_treat == `X' & $C2"
					qui replace b`j' = _b[TxA] if year_treat == `X'
					qui replace CIL`j' = (_b[TxA]- $t_90 *_se[TxA]) if year_treat == `X'
					qui replace CIR`j' = (_b[TxA]+ $t_90 *_se[TxA]) if year_treat == `X'
				} //end:loop over lifecycle
			} //end:loop t,f,m (ROWS)
			*total
			twoway rarea CIL CIR year_treat, sort  color(black%12) || ///
				line b year_treat, sort color(gray) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/total_`var', replace)
			
				
		} //end: loop over variable specification (COLUMNS)
	graph combine "$graphs/total_.gph"			///
				  "$graphs/total_r_fert_.gph"	 ///
				  "$graphs/total_r_popf_.gph"	, altshrink ///
				  title(LC: per gender) subtitle("$`1'")   ///
				  l1title("Ratio_pop		Ratio_fert		Abs numbers") /// 
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/lc_`1'_overview_panel1.pdf", as(pdf) replace	
		
	} //end: loop over variables

********************************************************************************
// PANEL 3.2: CHOICE OF CONTROL GROUP
	foreach 1 of varlist $list_vars_total_ratios_available { 
		foreach control_group in "C2" "C1_C2" "C1_C3" { // Columns
			foreach var in "" "r_fert_" "r_popf_" {	// ROWS
				foreach j in ""  {
					capture drop b`j' CIL`j' CIR`j'
					qui gen b`j' =.
					qui gen CIL`j' =.
					qui gen CIR`j' =. 
					
					qui summ year_treat if !missing(`var'`1') & treat == 1
					local start = r(min)
					local ende = r(max)
					
					forvalues X = `start' (1) `ende' {
						DDRD `var'`1'`j'  " if year_treat == `X' & $`control_group'"
						qui replace b`j' = _b[TxA] if year_treat == `X'
						qui replace CIL`j' = (_b[TxA]- $t_90 *_se[TxA]) if year_treat == `X'
						qui replace CIR`j' = (_b[TxA]+ $t_90 *_se[TxA]) if year_treat == `X'
					} //end:loop over lifecycle
				} //end:loop t,f,m
				twoway rarea CIL CIR year_treat, sort  color(black%12) || ///
					line b year_treat, sort color(gray) ///
					scheme(s1mono)  /// 
					yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
					legend(off) ///
					xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") nodraw ///
					saving($graphs/`control_group'_`var', replace)
					*	taken out: title($`1') ytitle(ITT estimate of `1')
					*	xtitle("Year [Age of treatment cohort]")   ///
					*	graph save "$graphs/`control_group'_`var'", replace
					
			} //end: loop over variable specification (ROWS)
		} //end: loop over control_groups (COLUMNS)
	graph combine "$graphs/C2_.gph"        "$graphs/C1_C2_.gph"			"$graphs/C1_C3_.gph" ///
				  "$graphs/C2_r_fert_.gph" "$graphs/C1_C2_r_fert_.gph"	"$graphs/C1_C3_r_fert_.gph" ///
				  "$graphs/C2_r_popf_.gph" "$graphs/C1_C2_r_popf_.gph"	"$graphs/C1_C3_r_popf_.gph", altshrink ///
				  title(LC: different Control groups) subtitle("$`1'")   ///
				  t1title("CG2             		  C1+C2             		  CG1-CG3") ///
				  l1title("Ratio_pop	   Ratio_fert	     Abs numbers") /// 
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/lc_`1'_overview_panel2.pdf", as(pdf) replace	
		
	} //end: loop over variables		
********************************************************************************
// PANEL 3.3: JAHRE ZUSAMMENNEHEMN UM POWER ZU ERHÖHEN
foreach 1 of varlist $list_vars_total_ratios_available { 
		foreach var in "" "r_fert_" "r_popf_" {	// COLUMNS
			foreach j in ""  { // rows
				capture drop b`j' CIL`j' CIR`j'
				qui gen b`j' =.
				qui gen CIL`j' =.
				qui gen CIR`j' =. 
				
				qui summ year_treat_2 if !missing(`var'`1') & treat == 1
				local start = r(min)
				local ende = r(max)
				
				forvalues X = `start' (1) `ende' {
					DDRD `var'`1'`j'  " if year_treat_2 == `X' & $C2"
					qui replace b`j' = _b[TxA] if year_treat_2 == `X'
					qui replace CIL`j' = (_b[TxA]- $t_90 *_se[TxA]) if year_treat_2 == `X'
					qui replace CIR`j' = (_b[TxA]+ $t_90 *_se[TxA]) if year_treat_2 == `X'
				} //end:loop over lifecycle
			} //end:loop t,f,m (ROWS)
			*total
			twoway rarea CIL CIR year_treat_2, sort  color(black%12) || ///
				line b year_treat_2, sort color(gray) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (2) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/total_`var', replace)
			
				
		} //end: loop over variable specification (COLUMNS)
	graph combine "$graphs/total_.gph"			///
				  "$graphs/total_r_fert_.gph"	 ///
				  "$graphs/total_r_popf_.gph"	, altshrink ///
				  title(LC: per gender - 2 Jahre zusammengefasst) subtitle("$`1'")   ///
				  l1title("Ratio_pop		Ratio_fert		Abs numbers") /// 
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/lc_`1'_overview_panel3.pdf", as(pdf) replace	
		
	} //end: loop over variables
		
********************************************************************************
// PANEL 3.4: CHOICE OF CONTROL GROUP - 2 JAHRE ZUSAMMENGEFASST
	foreach 1 of varlist $list_vars_total_ratios_available { 
		foreach control_group in "C2" "C1_C2" "C1_C3" { // Columns
			foreach var in "" "r_fert_" "r_popf_" {	// ROWS
				foreach j in ""  {
					capture drop b`j' CIL`j' CIR`j'
					qui gen b`j' =.
					qui gen CIL`j' =.
					qui gen CIR`j' =. 
					
					qui summ year_treat_2 if !missing(`var'`1') & treat == 1
					local start = r(min)
					local ende = r(max)
					
					forvalues X = `start' (1) `ende' {
						DDRD `var'`1'`j'  " if year_treat_2 == `X' & $`control_group'"
						qui replace b`j' = _b[TxA] if year_treat_2 == `X'
						qui replace CIL`j' = (_b[TxA]- $t_90 *_se[TxA]) if year_treat_2 == `X'
						qui replace CIR`j' = (_b[TxA]+ $t_90 *_se[TxA]) if year_treat_2 == `X'
					} //end:loop over lifecycle
				} //end:loop t,f,m
				twoway rarea CIL CIR year_treat_2, sort  color(black%12) || ///
					line b year_treat_2, sort color(gray)  ///
					scheme(s1mono)  /// 
					yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
					legend(off) ///
					xlabel(`start' (2) `ende' ,val angle(0)) xtitle("") nodraw ///
					saving($graphs/`control_group'_`var', replace)
					*	taken out: title($`1') ytitle(ITT estimate of `1')
					*	xtitle("Year [Age of treatment cohort]")   ///
					*	graph save "$graphs/`control_group'_`var'", replace
					
			} //end: loop over variable specification (ROWS)
		} //end: loop over control_groups (COLUMNS)
	graph combine "$graphs/C2_.gph"        "$graphs/C1_C2_.gph"			"$graphs/C1_C3_.gph" ///
				  "$graphs/C2_r_fert_.gph" "$graphs/C1_C2_r_fert_.gph"	"$graphs/C1_C3_r_fert_.gph" ///
				  "$graphs/C2_r_popf_.gph" "$graphs/C1_C2_r_popf_.gph"	"$graphs/C1_C3_r_popf_.gph", altshrink ///
				  title(LC: different Control groups - 2 Jahre zusammengefasst) subtitle("$`1'")   ///
				  t1title("CG2             		  C1+C2             		  CG1-CG3") ///
				  l1title("Ratio_pop	   Ratio_fert	     Abs numbers") /// 
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/lc_`1'_overview_panel4.pdf", as(pdf) replace	
		
	} //end: loop over variables
********************************************************************************
// PANEL 3.5: JAHRE ZUSAMMENNEHEMN UM POWER ZU ERHÖHEN - 4 JAHRE ZUSAMMENGEFASST
foreach 1 of varlist $list_vars_total_ratios_available { 
		foreach var in "" "r_fert_" "r_popf_" {	// COLUMNS
			foreach j in ""  { // rows
				capture drop b`j' CIL`j' CIR`j'
				qui gen b`j' =.
				qui gen CIL`j' =.
				qui gen CIR`j' =. 
				
				qui summ year_treat_4 if !missing(`var'`1') & treat == 1
				local start = r(min)
				local ende = r(max)
				
				forvalues X = `start' (1) `ende' {
					DDRD `var'`1'`j'  " if year_treat_4 == `X' & $C2"
					qui replace b`j' = _b[TxA] if year_treat_4 == `X'
					qui replace CIL`j' = (_b[TxA]- $t_90 *_se[TxA]) if year_treat_4 == `X'
					qui replace CIR`j' = (_b[TxA]+ $t_90 *_se[TxA]) if year_treat_4 == `X'
				} //end:loop over lifecycle
			} //end:loop t,f,m (ROWS)
			*total
			twoway rarea CIL CIR year_treat_4, sort  color(black%12) || ///
				line b year_treat_4, sort color(gray) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (1) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/total_`var', replace)
			
				
		} //end: loop over variable specification (COLUMNS)
	graph combine "$graphs/total_.gph"			///
				  "$graphs/total_r_fert_.gph"	 ///
				  "$graphs/total_r_popf_.gph"	, altshrink ///
				  title(LC: per gender - 4 Jahre zusammengefasst) subtitle("$`1'")   ///
				  l1title("Ratio_pop		Ratio_fert		Abs numbers") /// 
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/lc_`1'_overview_panel5.pdf", as(pdf) replace	
		
	} //end: loop over variables
		
********************************************************************************
// PANEL 3.6: CHOICE OF CONTROL GROUP - 4 JAHRE ZUSAMMENGEFASST
	foreach 1 of varlist $list_vars_total_ratios_available { 
		foreach control_group in "C2" "C1_C2" "C1_C3" { // Columns
			foreach var in "" "r_fert_" "r_popf_" {	// ROWS
				foreach j in ""  {
					capture drop b`j' CIL`j' CIR`j'
					qui gen b`j' =.
					qui gen CIL`j' =.
					qui gen CIR`j' =. 
					
					qui summ year_treat_4 if !missing(`var'`1') & treat == 1
					local start = r(min)
					local ende = r(max)
					
					forvalues X = `start' (1) `ende' {
						DDRD `var'`1'`j'  " if year_treat_4 == `X' & $`control_group'"
						qui replace b`j' = _b[TxA] if year_treat_4 == `X'
						qui replace CIL`j' = (_b[TxA]- $t_90 *_se[TxA]) if year_treat_4 == `X'
						qui replace CIR`j' = (_b[TxA]+ $t_90 *_se[TxA]) if year_treat_4 == `X'
					} //end:loop over lifecycle
				} //end:loop t,f,m
				twoway rarea CIL CIR year_treat_4, sort  color(black%12) || ///
					line b year_treat_4, sort color(gray)  ///
					scheme(s1mono)  /// 
					yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
					legend(off) ///
					xlabel(`start' (1) `ende' ,val angle(0)) xtitle("") nodraw ///
					saving($graphs/`control_group'_`var', replace)
					*	taken out: title($`1') ytitle(ITT estimate of `1')
					*	xtitle("Year [Age of treatment cohort]")   ///
					*	graph save "$graphs/`control_group'_`var'", replace
					
			} //end: loop over variable specification (ROWS)
		} //end: loop over control_groups (COLUMNS)
	graph combine "$graphs/C2_.gph"        "$graphs/C1_C2_.gph"			"$graphs/C1_C3_.gph" ///
				  "$graphs/C2_r_fert_.gph" "$graphs/C1_C2_r_fert_.gph"	"$graphs/C1_C3_r_fert_.gph" ///
				  "$graphs/C2_r_popf_.gph" "$graphs/C1_C2_r_popf_.gph"	"$graphs/C1_C3_r_popf_.gph", altshrink ///
				  title(LC: different Control groups - 4 Jahre zusammengefasst) subtitle("$`1'")   ///
				  t1title("CG2             		  C1+C2             		  CG1-CG3") ///
				  l1title("Ratio_pop	   Ratio_fert	     Abs numbers") /// 
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/lc_`1'_overview_panel6.pdf", as(pdf) replace	
		
	} //end: loop over variables




































/*
		
		//triple interactions:
		forvalues x = 2005 (1) 2014 { 
			qui gen TxA_`x' = 1 if year == `x'
			qui replace TxA_`x' = 0 if year != `x'
		} 
		
		eststo clear
		eststo temp1: reg d5 treat after TxA i.MOB TxA_*, vce(cluster MxY)
		eststo temp2: reg d5 treat after TxA i.MOB TxA#(i.year)   , vce(cluster MxY)
		
		esttab
********************************************************************************		
		
		
	
	
	
	

/* AUS DEM DO-FILE RAUSGNEOMMENE SACHEN:
	
		twoway line b age_treat,sort  xaxis(2)  color(white) ///
			legend(off)  xtitle("Age of treatment group", axis(2)) ||	 ///
		 rarea CIL CIR year, sort color(gs14) lcolor(gray) lpattern(dash) || ///
			line b year, sort color(gray) ///
			legend(off) ytitle(ITT `1') scheme(s1mono) ///
			yline(0, lw(thin) lpattern(solid)) color(black) ///
			xlabel(none, axis(1)) xtitle("", axis(1)) ///
			title(" `2' ")
			graph export "$graphs/R1_LC_`1'.pdf", as(pdf) replace
	
	
	*mit überschriften
	twoway rarea CIL CIR year, sort color(gs14) lcolor(gray) lpattern(dash) || ///
			line b year, sort color(gray) ///
			legend(off) ytitle(ITT Estimate) scheme(s1mono) ///
			yline(0, lw(thin) lpattern(solid)) color(black) ///
			title(" `2' ")
			graph export "$graphs/R1_LC_`1'.pdf", as(pdf) replace
*/			
	
	
	
	
