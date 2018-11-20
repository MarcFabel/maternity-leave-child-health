/*******************************************************************************
* File name: 	
* Author: 		Marc Fabel
* Date: 		21.11.2017
* Description:	Placebo reform 
*				 
*				 
*				
*
* Inputs:  		$temp\KKH_final_R1
*				
* Outputs:		$graphs/
*				$tables/
*
* Updates:		
*				7 Juni: 2. placebo graph entsprechend der KKHGWAP Version eingefuegt (difference: nur die Kohorte davor ist Control group nicht der "rest") 
 
*******************************************************************************/

// ***************************** PREAMBLE********************************
	clear all
	set more off
	set processors 4

	
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
	global t_99		  = 2.576
	
	*checkmark
	global check "\checkmark" // können auch andere Zeichen benutzt werden, eg Latex \checkmark
// ***********************************************************************


********************************************************************************
		*****  Own program  *****
********************************************************************************
	capture program drop RD
	program define RD
		*capture drop panel`1'			//! ACHTUNG: HIER NICHT BENÖTIGT DA KEINE MISSINGS
		*qui gen panel`1' = 1
		*qui replace panel`1' = 0 if (`1'==. | `1'<0)
		 eststo: reg `1' after Numx Num_after `2' if treat ==1 `3', vce(cluster MxY) 		
	end

	capture program drop DDRD
	program define DDRD
		qui eststo `1': reg `2' p_treat p_after p_TxA   `3'  `4', vce(cluster MxY) 
	end
	
	capture program drop DDRD_p
	program define DDRD_p
		qui reg `1' p_treat p_after p_TxA   `2'  `3', vce(cluster MxY) 
	end
	
////////////////////////////////////////////////////////////////////////////////
						*** Regression Analysis ***
////////////////////////////////////////////////////////////////////////////////
use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"
	*delete treatment cohort
	drop if TxA == 1 
	drop if control == 3


// loop from 1977m5 (208) - 1978m11 (226)
/*IDEA: loop through time and assign different cohorts TxA=1, start with 5/77, which 
still enables half a year back. With each iteration you put the TxA (all with half a year) 
one month forward. 

iter		pre				post
1)		11/76-04/77	|	05/77-10/77		05/77 corresponds to 208 in %tm format
2)		12/76-05/77	|	06/77-11/77
.
.
.
19)		05/78-10/78 |	11/78-04/79
danach ist die reform 05/79, früher keine Daten lokal


*/

foreach 1 of varlist $list_vars_mandf_ratios_available { 
********************************************************************************
	use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"
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



	
********************************************************************************
//  2) DD Placebo graph, according to KKHGWAP ( just prevcious cohort is control, not just rest), implies less data points (only 7) as we cannot reach so far in the past
use "$temp\KKH_final_R1", clear

run "$auxiliary/varlists_varnames_sample-spcifications"
	*delete treatment cohort
	drop if TxA == 1 
	drop if control == 3	


	
	// NOTE: ERSTER DATENPUNKT ENTSPRICHT: control2 == treat und control1 == control -> extra Tabelle
	
// loop from 1977m5 (220) - 1978m11 (226)
/*IDEA: loop through time and assign different cohorts TxA=1, start with 5/77, which 
still enables half a year back. With each iteration you put the TxA (all with half a year) 
one month forward. 

iter		pre				post
1)		11/77-04/78	|	05/78-10/78		05/77 corresponds to 208 in %tm format
2)		12/77-05/78	|	06/78-11/78
.
.
.
7)		05/78-10/78 |	11/78-04/79
danach ist die reform 05/79, früher keine Daten lokal
*/


foreach 1 of varlist d5 hospital2 { //$list_vars_mandf_ratios_available
	use "$temp\KKH_final_R1", clear
	*run "auxiliary_varlists_varnames_sample-spcifications"
	*delete treatment cohort
	drop if TxA == 1 
	drop if control == 3

	//first observation -> set up dataset in which I save the estimates and standard errors
	qui gen p_threshold = 220 // 05/1976
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
			DDRD_p `var'`1'`j'   "i.MOB i.year" "if (p_treat == 1 | p_control == 1)"
			* save estimates as dataset
			esttab using "$temp/placebo/`var'`1'`j'_graph.csv", replace ///
				keep(p_TxA) nomtitles nonumbers noobs nonote nogaps noline nopar nostar se wide coeflabels(p_TxA "220")
		} // end:columns
	} // end:rows
**********************************
	//loop over other months (Push TxA period one month forward)
	forval k = 221/226 {	// 226 = 1978m11
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
				DDRD_p  `var'`1'`j'   "i.MOB i.year" "if (p_treat == 1 | p_control == 1)"
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
			ylabel(, nogrid) xlabel(220(2) 226, valuelabel angle(45)) ///
			xtick(221(2)226) ///
			graphregion(color(white)) xscale(range(220 227)) ///
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
			ylabel(, nogrid) xlabel(220(2) 226, valuelabel angle(45)) ///
			xtick(221(2)226) ///
			graphregion(color(white)) xscale(range(220 227)) ///
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
			ylabel(, nogrid) xlabel(220(2) 226, valuelabel angle(45)) ///
			xtick(221(2)226)  ///
			graphregion(color(white)) xscale(range(220 227)) ///
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
