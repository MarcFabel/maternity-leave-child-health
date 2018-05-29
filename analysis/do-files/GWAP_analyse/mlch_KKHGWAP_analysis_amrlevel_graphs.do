clear all 
set more off

/*
 Aufbau des Do-Files
 
  
 
 
 */
 
 
 *magic numbers
	global first_year = 1995
	global last_year  = 2014
	global t_90		  = 1.645
	global t_95   	  = 1.960
 
 ********************************************************************************
		*****  Own program  *****
********************************************************************************
capture program drop DDRD
	program define DDRD
		qui eststo `1': reg `2' treat after TxA   `3'  `4', vce(cluster MxY) 
	end
	
capture program drop DDalt
	program define DDalt
		qui eststo `1': reg `2' after FRG FxA   `3'  `4', vce(cluster MxYxFRG) 
	end
	
capture program drop DDxLFP
	program define DDxLFP
	qui  eststo `1': reg `2' treat after FLFP_2001 TxA TxFLFP AxFLFP TxAxFLFP `3'  `4', vce(cluster MxY) 
	end
	
capture program drop DDD
	program define DDD
		qui eststo `1': reg `2' treat after FRG TxA FxT FxA FxTxA `3' `4', vce(cluster MxYxFRG)
	end
********************************************************************************
use ${temp}/KKH_final_amr_level, clear
run "auxiliary_varlists_varnames_sample-spcifications"
sort amr_clean Datum year
qui gen MxYxFRG = MxY * FRG


drop if GDR == 1
********************************************************************************
	
// 1) DD - Life-course
	foreach 1 of varlist d5 { 
		foreach var in "" "r_popf_" {	// COLUMNS
			foreach j in "" "_f" "_m" { // rows
				capture drop b`j' CIL`j' CIR`j'
				qui gen b`j' =.
				qui gen CIL`j' =.
				qui gen CIR`j' =. 
				
				qui summ year_treat if !missing(`var'`1') & treat == 1
				local start = r(min)
				local ende = r(max)
				
				forvalues X = `start' (1) `ende' {
					DDRD x `var'`1'`j'  " if year_treat == `X' & $C2"
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
		graph combine "$graphs/total_.gph" "$graphs/total_r_popf_.gph" ///
		"$graphs/female_.gph" "$graphs/female_r_popf_.gph" ///
		"$graphs/male_.gph" "$graphs/male_r_popf_.gph", altshrink rows(3) ///
		 title(LC: per gender) subtitle("$`1'")   ///
		 l1title("male             	female              	total ") ///
		 t1title("Abs numbers		Ratio_pop") /// 
		 scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/lifecourse_amr_`1'.pdf", as(pdf) replace		
	} //end: loop over variables
	
	
********************************************************************************

	
	// 2) Reduced form
	foreach 1 of varlist $list_outcomes {
	foreach var in "" "r_popf_"  { // rows: 
		foreach j in "" "_f" "_m"  { // columns:  
			capture drop `j'_hat* AVRG`j'
			qui bys Datum control: egen AVRG`j' = mean(`var'`1'`j') 
			qui reg `var'`1'`j' Numx Num_after after if treat == 1
			qui predict `j'_hat_linear_T
			qui reg `var'`1'`j' Numx Num_after after if control == 2
			qui predict `j'_hat_linear_C
		} // end: loop over columns (total, male, female)

		*total		
		twoway scatter AVRG MOB_altern if treat == 1, color(black) || ///
			scatter AVRG MOB_altern if control == 2,  mcolor(black%1) msymbol(Dh) || ///
			line _hat_linear_C MOB_altern if after == 1, sort lpattern(dash) color(black%20) || ///
			line _hat_linear_C MOB_altern if after == 0, sort lpattern(dash) color(black%20) || ///
			line _hat_linear_T MOB_altern if after == 1, sort color(black) || ///
			line _hat_linear_T MOB_altern if after == 0, sort color(black) ///
			scheme(s1mono )  ///
			xtitle("")  ///
			ylabel(#5,grid) ///
			xlabel(1(2)12, val) xmtick(2(2)12) ///
			legend(off) ///
			xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
			saving($graphs/total_`var', replace)

		*female 
		twoway scatter AVRG_f MOB_altern if treat == 1, color(red) || ///
			scatter AVRG_f MOB_altern if control == 2,  mcolor(red%1) msymbol(Dh) || ///
			line _f_hat_linear_C MOB_altern if after == 1, sort lpattern(dash) color(red%20) || ///
			line _f_hat_linear_C MOB_altern if after == 0, sort lpattern(dash) color(red%20) || ///
			line _f_hat_linear_T MOB_altern if after == 1, sort color(red) || ///
			line _f_hat_linear_T MOB_altern if after == 0, sort color(red) ///
			scheme(s1mono )  ///
			xtitle("")  ///
			ylabel(#5,grid) ///
			xlabel(1(2)12, val) xmtick(2(2)12) ///
			legend(off) ///
			xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
			saving($graphs/female_`var', replace)
			
		*male	
		twoway scatter AVRG_m MOB_altern if treat == 1, color(blue) || ///
			scatter AVRG_m MOB_altern if control == 2,  mcolor(blue%1) msymbol(Dh) || ///
			line _m_hat_linear_C MOB_altern if after == 1, sort lpattern(dash) color(blue%20) || ///
			line _m_hat_linear_C MOB_altern if after == 0, sort lpattern(dash) color(blue%20) || ///
			line _m_hat_linear_T MOB_altern if after == 1, sort color(blue) || ///
			line _m_hat_linear_T MOB_altern if after == 0, sort color(blue) ///
			scheme(s1mono )  ///
			xtitle("")  ///
			ylabel(#5,grid) ///
			xlabel(1(2)12, val) xmtick(2(2)12) ///
			legend(off) ///
			xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
				saving($graphs/male_`var', replace)
					
	} // end: loop over rows (variable specification)
	
	graph combine "$graphs/total_.gph"	"$graphs/total_r_popf_.gph"		 ///
				  "$graphs/female_.gph"	"$graphs/female_r_popf_.gph"	 ///
				  "$graphs/male_.gph"	"$graphs/male_r_popf_.gph", altshrink rows(3) ///
				  title(RD: per gender with CG2 comparisson) subtitle("$`1'")   ///
				  l1title("male              	female              	total") ///
				  t1title("Abs numbers		Ratio_pop") /// 
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/rd_amr_`1'.pdf", as(pdf) replace
} //end: loop over variable list


********************************************************************************

// Code für Placebo Graph

/*


*delete treatment cohort
	drop if TxA == 1 
	drop if control == 3
********************************************************************************

	//first observation -> set up dataset in which I save the estimates and standard errors
	qui gen p_threshold = 208
	format p_threshold %tm
	local threshm 5
	local binw 6
	qui gen p_treat = cond((Datum>p_threshold-`binw'-1 & Datum<p_threshold + `binw' ),1,0)	
	*extract beginning and start month of after period
	qui gen temp = cond((Datum>=p_threshold & Datum<p_threshold + `binw' ),1,0)
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
			DDRD a1 `var'`1'`j'   "i.MOB" ""
			* save estimates as dataset
			esttab using "$temp/placebo/`var'`1'`j'_graph.csv", replace ///
				keep(p_TxA) nomtitles nonumbers noobs nonote nogaps noline nopar nostar se wide coeflabels(p_TxA "208")
		} // end:columns
	} // end:rows
********************************************************************************
	//loop over other months (Push TxA period one month forward)
	forval k = 209/226 {
		capture drop p_threshold p_treat p_after p_TxA month_start2 month_end2
		qui gen p_threshold = `k'
		format p_threshold %tm
		local threshm 5
		local binw 6
		qui gen p_treat = cond((Datum>p_threshold-`binw'-1 & Datum<p_threshold + `binw' ),1,0)	
		*extract beginning and start month of after period
		qui gen temp = cond((Datum>=p_threshold & Datum<p_threshold + `binw' ),1,0)
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
				DDRD a1 `var'`1'`j'   "i.MOB" ""
				* save estimates as dataset
				esttab using "$temp/placebo/`var'`1'`j'_graph.csv", append ///
					keep(p_TxA) nomtitles nonumbers noobs nonote nogaps noline nopar nostar se wide coeflabels(p_TxA "`k'")
			} // end:columns
		} // end:rows
	} // end: loop over months
	********************************************************************************		
	
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
		
		qui gen CI_low = b - 2* se 
		qui gen CI_up  = b + 2* se
		
		*total
		eclplot b CI_low CI_up k, yline(0, lc(black)) ///
			ylabel(, nogrid) xlabel(208(4) 226, valuelabel angle(45)) ///
			xtick(210(2)226) ///
			graphregion(color(white)) xscale(range(207 227)) ///
			xtitle("") ytitle("") estopts(color(black)) ciopts(color(black)) nodraw ///
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
		
		qui gen CI_low = b - 2* se 
		qui gen CI_up  = b + 2* se
		
		*total
		eclplot b CI_low CI_up k, yline(0, lc(black)) ///
			ylabel(, nogrid) xlabel(208(4) 226, valuelabel angle(45)) ///
			xtick(210(2)226) ///
			graphregion(color(white)) xscale(range(207 227)) ///
			xtitle("") ytitle("") estopts(color(red)) ciopts(color(red)) nodraw ///
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
		
		qui gen CI_low = b - 2* se 
		qui gen CI_up  = b + 2* se
		
		*total
		eclplot b CI_low CI_up k, yline(0, lc(black)) ///
			ylabel(, nogrid) xlabel(208(4) 226, valuelabel angle(45)) ///
			xtick(210(2)226) ///
			graphregion(color(white)) xscale(range(207 227))  ///
			xtitle("") ytitle("") estopts(color(blue)) ciopts(color(blue)) nodraw ///
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
		
	graph export "$graphs/placebo_graph_`1'.pdf", as(pdf) replace
	
	

	/*
	//erase building blocks
	foreach var in "" "r_fert_" "r_popf_" {	// ROWS				 
		foreach j in "" "_f" "_m" { //COLUMNS 	
			erase "$graphs/placebo_`var'`1'`j'" 
		}
	}
	*/
			
} //end: loop over vars; `1'
