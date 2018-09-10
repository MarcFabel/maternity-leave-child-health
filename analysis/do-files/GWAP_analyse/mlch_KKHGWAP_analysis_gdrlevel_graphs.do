// GDR Level graphs

clear all
version 14
set more off
/*
DDD
- lifecourse graph

DD
-placebo (fuer alle, da lokal keine so lange Zeitreihe vorhanden)

detailed variables: 
	-reduced form 
	-lifecourse

 
*/

*magic numbers
	global first_year = 1995
	global last_year  = 2014
	
	global t_90		  = 1.645
	global t_95   	  = 1.960
	global t_99		  = 2.576

********** The program
	capture program drop DDRD
	program define DDRD
		qui  reg `1' treat after TxA   `2'  `3', vce(cluster MxY) 
	end
	
	capture program drop DDRD_p
	program define DDRD_p
		qui reg `1' p_treat p_after p_TxA   `2'  `3', vce(cluster MxY) 
	end

	
	capture program drop DDD
	program define DDD
		qui reg `1'  treat after FRG TxA FxT FxA FxTxA `2' `3' , vce(cluster MxFRG) // NEUE CLUSTER VARIABLE
	end
***********
	use "$temp/KKH_final_gdr_level", clear
	qui gen MxYxFRG = MxY * FRG
	qui gen MxFRG = MOB * FRG
	run "auxiliary_varlists_varnames_sample-spcifications"

	
	
// 1) Life-course DDD
	* which observations are part of the regression
	qui gen Dinregression = 1 if cond($C2,1,0)
	
	foreach 1 of varlist $list_outcomes { 
		capture drop sum_num_diag*
		bys Dinregression year_treat: egen sum_num_diagnoses = total(`1')
		bys Dinregression year_treat: egen sum_num_diagnoses_f = total(`1'_f)
		bys Dinregression year_treat: egen sum_num_diagnoses_m = total(`1'_m)
		
		foreach var in "" "r_fert_" "r_popf_" {	// COLUMNS
			foreach j in "" "_f" "_m" { // rows
				capture drop b`j' CIL`j' CIR`j'
				qui gen b`j' =.
				qui gen CIL`j' =.
				qui gen CIR`j' =. 
				
				qui summ year_treat if !missing(`var'`1') & treat == 1
				local start = r(min) + 1
				local ende = r(max)
				
				forvalues X = `start' (1) `ende' {
					DDD `var'`1'`j'  "i.MOB " " if year_treat == `X' & $C2"
					qui replace b`j' = _b[FxTxA] if year_treat == `X'
					qui replace CIL`j' = (_b[FxTxA]- $t_90 *_se[FxTxA]) if year_treat == `X'
					qui replace CIR`j' = (_b[FxTxA]+ $t_90 *_se[FxTxA]) if year_treat == `X'
				} //end:loop over lifecycle
			} //end:loop t,f,m (ROWS)
			*total
			local start_mtick = `start' + 2 
			twoway line sum_num_diagnoses year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs13) lw(vthick) yaxis(2)  || ///
				scatter b year_treat, sort color(black) m(O) yaxis(1)  || ///	
				rcap CIL CIR year_treat, sort  color(black) yaxis(1)   ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black) axis(1))   ///
				legend(off) ///
				xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") ///
				xmtick(`start_mtick' (4) `ende') ///
				ytitle("ITT effect", axis(1)) ytitle("Number of diagnoses",axis(2)) ///
				yscale(alt axis(2)) yscale(alt axis(1)) nodraw ///
				saving($graphs/total_`var', replace)
			*female
			twoway line sum_num_diagnoses_f year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs13) lw(vthick) yaxis(2)  || ///
				scatter b_f year_treat, sort color(cranberry) m(O) yaxis(1)  || ///	
				rcap CIL_f CIR_f year_treat, sort  color(cranberry) yaxis(1)   ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black) axis(1))   ///
				legend(off) ///
				xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") ///
				xmtick(`start_mtick' (4) `ende') ///
				ytitle("ITT effect", axis(1)) ytitle("Number of diagnoses",axis(2)) ///
				yscale(alt axis(2)) yscale(alt axis(1)) nodraw ///
				saving($graphs/female_`var', replace)
			
			/*twoway rarea CIL_f CIR_f year_treat, sort  color(red%12) || ///
				line b_f year_treat, sort color(red) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/female_`var', replace)*/	
			*male
			twoway line sum_num_diagnoses_m year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs13) lw(vthick) yaxis(2)  || ///
				scatter b_m year_treat, sort color(navy) m(O) yaxis(1)  || ///	
				rcap CIL_m CIR_m year_treat, sort  color(navy) yaxis(1)   ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black) axis(1))   ///
				legend(off) ///
				xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") ///
				xmtick(`start_mtick' (4) `ende') ///
				ytitle("ITT effect", axis(1)) ytitle("Number of diagnoses",axis(2)) ///
				yscale(alt axis(2)) yscale(alt axis(1)) nodraw ///
				saving($graphs/male_`var', replace)
				/*
			twoway rarea CIL_m CIR_m year_treat, sort  color(blue%12) || ///
				line b_m year_treat, sort color(blue) ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") nodraw ///
				saving($graphs/male_`var', replace)	*/
			
				
		} //end: loop over variable specification (COLUMNS)
	graph combine "$graphs/total_.gph"			"$graphs/female_.gph"			"$graphs/male_.gph"  ///
				  "$graphs/total_r_fert_.gph"	"$graphs/female_r_fert_.gph"	"$graphs/male_r_fert_.gph" ///
				  "$graphs/total_r_popf_.gph"	"$graphs/female_r_popf_.gph"	"$graphs/male_r_popf_.gph", altshrink ///
				  title(LC: per gender) subtitle("$`1'")   ///
				  t1title("total              		female              		male") ///
				  l1title("Ratio_pop		Ratio_fert		Abs numbers") /// 
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/`1'_lifecourse_gdr_DDD.pdf", as(pdf) replace		
	} //end: loop over variables
	
********************************************************************************

// 2) DD Placebo graph
use "$temp/KKH_final_gdrlevel_extended", clear
qui gen MxYxFRG = MxY * FRG

run "auxiliary_varlists_varnames_sample-spcifications"
	*delete treatment cohort
	drop if TxA == 1 
	drop if control == 3	
	drop if GDR == 1


// loop from 1976m12 (203) - 1978m11 (226)

/*
IDEA: loop through time and assign different cohorts TxA=1, start with 12/76, which 
still enables half a year back. With each iteration you put the TxA (all with half a year) 
one month forward. 

iter		pre				post
1) 		06/76-11/76 |   12/76-05/77		12/76 corresponds to 203 in %tm format
2) 		07/76-12/76 |   01/77-06/77
.
.
.
24)		05/78-10/78 |	11/78-04/79
danach ist die reform 05/79
*/



foreach 1 of varlist $list_outcomes { //$list_outcomes
	use "$temp\KKH_final_gdrlevel_extended", clear
	*run "auxiliary_varlists_varnames_sample-spcifications"
	*delete treatment cohort
	drop if TxA == 1 
	drop if control == 3
	drop if GDR == 1

	//first observation -> set up dataset in which I save the estimates and standard errors
	qui gen p_threshold = 203 // 12/1976
	format p_threshold %tm
	local threshm 5
	local binw 6
	qui gen p_treat = cond((Datum>p_threshold-`binw'-1 & Datum<p_threshold + `binw' ),1,0)	
	*extract beginning and start month of after period
	qui gen temp = cond((Datum>=p_threshold & Datum<p_threshold + `binw' ),1,0)
	qui gen p_control2 = cond((Datum>p_threshold-`binw'-1-12 & Datum<p_threshold + `binw' -12),1,0)
	sort Datum year
	qui gen tempX = _n if temp == 1 
	qui sum tempX 
	local start = r(min)
	local ende = r(max) 
	qui gen month_start = MOB if tempX == `start'
	qui gen month_end = MOB if tempX == `ende'
	qui egen month_start2 = min(month_start)
	qui egen month_end2 = min(month_end)
	qui drop month_start month_end
	//case 1: flip in the after period over two calender years
	if month_start2 > month_end2 {
		qui gen p_after = cond((MOB>= month_start2 | MOB<=month_end2),1,0)
	}
	//case 2: no flip over the years
	if month_start2 < month_end2 { 
			qui gen p_after = cond((MOB>=month_start2 & MOB<=month_end2),1,0)
	}
	qui gen p_TxA = p_treat*p_after
	qui drop temp*
		
	foreach var in "" "r_fert_" "r_popf_" {	// ROWS				 
		foreach j in "" "_f" "_m" { //COLUMNS 			
			eststo clear
			DDRD_p `var'`1'`j'   "i.MOB" "if (p_treat == 1 | p_control == 1)"
			* save estimates as dataset
			esttab using "$temp/placebo/`var'`1'`j'_graph.csv", replace ///
				keep(p_TxA) nomtitles nonumbers noobs nonote nogaps noline nopar nostar se wide coeflabels(p_TxA "203")
		} // end:columns
	} // end:rows
**********************************
	//loop over other months (Push TxA period one month forward)
	forval k = 204/226 {	// 226 = 1978m11
		capture drop p_threshold p_treat p_after p_TxA month_start2 month_end2 p_control
		qui gen p_threshold = `k'
		format p_threshold %tm
		local threshm 5
		local binw 6
		qui gen p_treat = cond((Datum>p_threshold-`binw'-1 & Datum<p_threshold + `binw' ),1,0)	
		*extract beginning and start month of after period
		qui gen temp = cond((Datum>=p_threshold & Datum<p_threshold + `binw' ),1,0)
		qui gen p_control = cond((Datum>p_threshold-`binw'-1-12 & Datum<p_threshold + `binw' -12),1,0)
		qui sort Datum year
		qui gen tempX = _n if temp == 1 
		qui sum tempX 
		local start = r(min)
		local ende = r(max) 
		qui gen month_start = MOB if tempX == `start'
		qui gen month_end = MOB if tempX == `ende'
		qui egen month_start2 = min(month_start)
		qui egen month_end2 = min(month_end)
		qui drop month_start month_end
		//case 1: flip in the after period over two calender years
		if month_start2 > month_end2 {
			qui gen p_after = cond((MOB>= month_start2 | MOB<=month_end2),1,0)
		}
		//case 2: no flip over the years
		if month_start2 < month_end2 { 
				qui gen p_after = cond((MOB>=month_start2 & MOB<=month_end2),1,0)
		}
		qui gen p_TxA = p_treat*p_after
		qui drop temp*
		
		
		foreach var in "" "r_fert_" "r_popf_" {	// ROWS				 
			foreach j in ""  "_f" "_m" { //COLUMNS 			
				eststo clear
				DDRD_p  `var'`1'`j'   "i.MOB" "if (p_treat == 1 | p_control == 1)"
				* save estimates as dataset
				esttab using "$temp/placebo/`var'`1'`j'_graph.csv", append ///
					keep(p_TxA) nomtitles nonumbers noobs nonote nogaps noline nopar nostar se wide coeflabels(p_TxA "`k'")
			} // end:columns
		} // end:rows
	} // end: loop over months
	*************************************		
	
	*open datasets 
	*1) TOTALS
	foreach var in "" "r_fert_" "r_popf_" { 
		import delimited "$temp/placebo/`var'`1'_graph.csv", stripquote(yes) clear
		gen k = substr(v1,2,3)
		gen b = substr(v2,2,.)
		gen se = substr(v3,2,.)
		qui drop v*
		destring *, replace
		format k %tm
		
		qui gen CI_low = b - $t_95* se 
		qui gen CI_up  = b + $t_95 * se
		
		scatter b k, m(O) color(black) || ///
			rcap CI_low CI_up k, color(black) lw(thin) ///
			yline(0, lc(black)) ///
			ylabel(, nogrid) xlabel(203(4) 226, valuelabel angle(45)) ///
			xtick(203(2)226) ///
			graphregion(color(white)) xscale(range(203 227)) ///
			xtitle("") ytitle("") legend(off) nodraw ///
			saving($graphs/placebo_`var'`1', replace)
	} // end: variable specification (ROWS)
	
	*2) Women
	foreach var in "" "r_fert_" "r_popf_" { 
		import delimited "$temp/placebo/`var'`1'_f_graph.csv", stripquote(yes) clear
		gen k = substr(v1,2,3)
		gen b = substr(v2,2,.)
		gen se = substr(v3,2,.)
		qui drop v*
		destring *, replace
		format k %tm
		
		qui gen CI_low = b - $t_95* se 
		qui gen CI_up  = b + $t_95* se

		scatter b k, m(O) color(cranberry) || ///
			rcap CI_low CI_up k, color(cranberry) lw(thin) ///
			yline(0, lc(black)) ///
			ylabel(, nogrid) xlabel(203(4) 226, valuelabel angle(45)) ///
			xtick(203(2)226) ///
			graphregion(color(white)) xscale(range(203 227)) ///
			xtitle("") ytitle("") legend(off) nodraw ///
			saving($graphs/placebo_`var'`1'_f, replace)
	} // end: variable specification (ROWS)
	
	*3) Men
	foreach var in "" "r_fert_" "r_popf_" { 
		import delimited "$temp/placebo/`var'`1'_m_graph.csv", stripquote(yes) clear
		gen k = substr(v1,2,3)
		gen b = substr(v2,2,.)
		gen se = substr(v3,2,.)
		qui drop v*
		destring *, replace
		format k %tm
		
		qui gen CI_low = b - $t_95* se 
		qui gen CI_up  = b + $t_95* se
		
		scatter b k, m(O) color(navy) || ///
			rcap CI_low CI_up k, color(navy) lw(thin) ///
			yline(0, lc(black)) ///
			ylabel(, nogrid) xlabel(203(4) 226, valuelabel angle(45)) ///
			xtick(203(2)226) ///
			graphregion(color(white)) xscale(range(203 227)) ///
			xtitle("") ytitle("") legend(off) nodraw ///
			saving($graphs/placebo_`var'`1'_m, replace)
	} // end: variable specification (ROWS)
								   
	//GRAPH COMBINE	
	graph combine "$graphs/placebo_`1'" "$graphs/placebo_`1'_f" "$graphs/placebo_`1'_m"	///
		"$graphs/placebo_r_fert_`1'" "$graphs/placebo_r_fert_`1'_f" "$graphs/placebo_r_fert_`1'_m" ///
		"$graphs/placebo_r_popf_`1'" "$graphs/placebo_r_popf_`1'_f" "$graphs/placebo_r_popf_`1'_m" , altshrink ///
		 title(Placebo: per gender) subtitle("$`1'")   ///
				  t1title("total              		female              		male") ///
				  l1title("Ratio_pop		Ratio_fert		Abs numbers") /// 
				  scheme(s1mono)
		
	graph export "$graphs/`1'_placebo_gdr_DD.pdf", as(pdf) replace
	
	//erase building blocks
	foreach var in "" "r_fert_" "r_popf_" {	// ROWS				 
		foreach j in "" "_f" "_m" { //COLUMNS 	
			erase "$graphs/placebo_`var'`1'`j'.gph" 
		}
	}
	
			
} //end: loop over vars; `1'	
	
********************************************************************************
// 3) Detailed variables 

*3.1) DD: reduced form for detailed list

	use "$temp/KKH_final_gdr_level", clear
	qui gen MxYxFRG = MxY * FRG
	qui gen MxFRG = MOB * FRG
	run "auxiliary_varlists_varnames_sample-spcifications"
	

	keep if GDR == 0 

foreach 1 of varlist $detailed {
	foreach var in "" "r_fert_" "r_popf_"  { // rows: 
		foreach j in "" "_f" "_m"  { // columns:  
			capture drop `j'_hat* AVRG`j'
			qui bys Datum control: egen AVRG`j' = mean(`var'`1'`j') 
			qui reg `var'`1'`j' Numx Num_after after if treat == 1
			qui predict `j'_hat_linear_T
		} // end: loop over columns (total, male, female)

		*total		
		twoway scatter AVRG MOB_altern if treat == 1, color(black) || ///
			line _hat_linear_T MOB_altern if after == 1, sort color(black) || ///
			line _hat_linear_T MOB_altern if after == 0, sort color(black) ///
			scheme(s1mono )  ///
			xtitle("")  ///
			ylabel(#5,grid) ///
			xlabel(1(2)12, val) xmtick(2(2)12) ///
			legend(off)  ///
			xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
			saving($graphs/total_`var', replace)

		*female 
		twoway scatter AVRG_f MOB_altern if treat == 1, color(cranberry) || ///
			line _f_hat_linear_T MOB_altern if after == 1, sort color(cranberry) || ///
			line _f_hat_linear_T MOB_altern if after == 0, sort color(cranberry) ///
			scheme(s1mono )  ///
			xtitle("")  ///
			ylabel(#5,grid) ///
			xlabel(1(2)12, val) xmtick(2(2)12) ///
			legend(off) ///
			xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
			saving($graphs/female_`var', replace)
			
		*male	
		twoway scatter AVRG_m MOB_altern if treat == 1, color(navy) || ///
			line _m_hat_linear_T MOB_altern if after == 1, sort color(navy) || ///
			line _m_hat_linear_T MOB_altern if after == 0, sort color(navy) ///
			scheme(s1mono )  ///
			xtitle("")  ///
			ylabel(#5,grid) ///
			xlabel(1(2)12, val) xmtick(2(2)12) ///
			legend(off) ///
			xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
				saving($graphs/male_`var', replace)
			
		*graph export "$graph/RD/R1_RD_pooled_CG_`1'.pdf", replace	
		
	} // end: loop over rows (variable specification)
	
	graph combine "$graphs/total_.gph"			"$graphs/female_.gph"			"$graphs/male_.gph"  ///
				  "$graphs/total_r_fert_.gph"	"$graphs/female_r_fert_.gph"	"$graphs/male_r_fert_.gph" ///
				  "$graphs/total_r_popf_.gph"	"$graphs/female_r_popf_.gph"	"$graphs/male_r_popf_.gph", altshrink ///
				  title(RD: per gender with CG2 comparisson) subtitle("$`1'")   ///
				  t1title("total              		female              		male") ///
				  l1title("Ratio_pop		Ratio_fert		Abs numbers") /// 
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/`1'_reducedform_gdr.pdf", as(pdf) replace
} //end: loop over variable list


********************************************************************************
// 3.2) DD: Life-course for $detailed list

capture drop Dinregression
qui gen Dinregression = 1 if cond($C2,1,0)
	
	foreach 1 of varlist $detailed { 
		capture drop sum_num_diag*
		bys Dinregression year_treat: egen sum_num_diagnoses = total(`1')
		bys Dinregression year_treat: egen sum_num_diagnoses_f = total(`1'_f)
		bys Dinregression year_treat: egen sum_num_diagnoses_m = total(`1'_m)
		
		foreach var in "" "r_fert_" "r_popf_" {	// COLUMNS
			foreach j in "" "_f" "_m" { // rows
				capture drop b`j' CIL`j' CIR`j'
				qui gen b`j' =.
				qui gen CIL`j' =.
				qui gen CIR`j' =. 
				
				qui summ year_treat if !missing(`var'`1') & treat == 1
				local start = r(min) + 1
				local ende = r(max)
				
				forvalues X = `start' (1) `ende' {
					DDRD `var'`1'`j' "i.MOB"  " if year_treat == `X' & $C2"
					qui replace b`j' = _b[TxA] if year_treat == `X'
					qui replace CIL`j' = (_b[TxA]- $t_90 *_se[TxA]) if year_treat == `X'
					qui replace CIR`j' = (_b[TxA]+ $t_90 *_se[TxA]) if year_treat == `X'
				} //end:loop over lifecycle
			} //end:loop t,f,m (ROWS)
			local start_mtick = `start' + 2 
			*total
			twoway line sum_num_diagnoses year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs13) lw(vthick) yaxis(2)  || ///
				scatter b year_treat, sort color(black) m(O) yaxis(1)  || ///	
				rcap CIL CIR year_treat, sort  color(black) yaxis(1) lw(thin)  ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black) axis(1))   ///
				legend(off) ///
				xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") ///
				xmtick(`start_mtick' (4) `ende') ///
				ytitle("ITT effect", axis(1)) ytitle("Number of diagnoses",axis(2)) ///
				yscale(alt axis(2)) yscale(alt axis(1)) nodraw ///
				saving($graphs/total_`var', replace)
			*female
			twoway line sum_num_diagnoses_f year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs13) lw(vthick) yaxis(2)  || ///
				scatter b_f year_treat, sort color(cranberry) m(O) yaxis(1)  || ///	
				rcap CIL_f CIR_f year_treat, sort  color(cranberry) yaxis(1) lw(thin)  ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black) axis(1))   ///
				legend(off) ///
				xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") ///
				xmtick(`start_mtick'  (4) `ende') ///
				ytitle("ITT effect", axis(1)) ytitle("Number of diagnoses",axis(2)) ///
				yscale(alt axis(2)) yscale(alt axis(1)) nodraw ///
				saving($graphs/female_`var', replace)
			
			*male
			twoway line sum_num_diagnoses_m year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs13) lw(vthick) yaxis(2)  || ///
				scatter b_m year_treat, sort color(navy) m(O) yaxis(1)  || ///	
				rcap CIL_m CIR_m year_treat, sort  color(navy) yaxis(1) lw(thin)  ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black) axis(1))   ///
				legend(off) ///
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
	graph export "$graphs/`1'_lifecourse_gdr_DD.pdf", as(pdf) replace		
	} //end: loop over variables
	
