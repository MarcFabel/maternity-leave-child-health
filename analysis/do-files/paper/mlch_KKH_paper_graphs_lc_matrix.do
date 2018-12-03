// ***************************** PREAMBLE********************************
/*
	Generiert eine Matrix von LC Graphen über alle wichtigen Chapter. 
	Erste und letze Reihe sind in extra Befehlen, da sie entweder bestimmte 
	header oder footer benoetigen

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
	use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"

	capture program drop DDRD
program define DDRD
		qui reg `1' treat after TxA i.MOB   `2'  , vce(cluster MxY) 
end


	*define short globals for variable labels in the table
	global hospital2 "Hospital"
	global d1  "Infectious & parasitic"
	global d2  "Neoplasms"
	global d5  "Mental & behavioral"
	global d6  "Nervous system"
	global d7  "Sense organs" 
	global d8  "Circulatory"
	global d9  "Respiratory"
	global d10 "Digestive"
	global d11 "Skin"
	global d12 "Musculoskeletal"
	global d13 "Genitourinary"
	global d17 "Symptoms"
	global d18 "External"
	


*hospital mit captions oben
capture drop Dinregression
qui gen Dinregression = 1 if cond($C2,1,0) 

	global min_itt = -15
	global max_itt = 10
	global min_diag = 0
	global max_diag = 160


foreach 1 of varlist hospital2 { // $list_vars_mandf_ratios_available
	capture drop sum_num_diag*
	bys Dinregression year_treat: egen sum_num_diagnoses = total(`1')
	bys Dinregression year_treat: egen sum_num_diagnoses_f = total(`1'_f)
	bys Dinregression year_treat: egen sum_num_diagnoses_m = total(`1'_m)
	
	
	
	foreach var in "r_fert_"  {	// COLUMNS
		capture drop b* CIL* CIR* mean*
		foreach j in "" "_f" "_m" { // rows
			qui replace sum_num_diagnoses`j'= sum_num_diagnoses`j'/1000
			qui gen b`j' =.
			qui gen CIL95`j' =.
			qui gen CIR95`j' =. 
			qui gen CIL90`j' =.
			qui gen CIR90`j' =. 
			qui gen mean`j' =.
			
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
				
				qui sum `var'`1'`j' if e(sample) & treat== 1 & after == 0 
				qui replace mean`j' = `r(mean)' if year_treat == `X'
				
				
			} //end:loop over lifecycle
		} //end:loop t,f,m (ROWS)
		local start_mtick = `start' + 2 
		*total
		twoway line mean year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs14) lw(vthick) yaxis(2)  || ///
			rarea CIL95 CIR95 year_treat, sort  color(gs2%12) yaxis(1) || ///
			rarea CIL90 CIR90 year_treat, sort  color(gs2%25) yaxis(1) || ///
			line b year_treat, sort color(gs2) yaxis(1) ///
			scheme(s1mono) plotregion(color(white))   /// 
			yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
			legend(off) ///
			xlabel(`start' (6) `ende', nolab) xtitle("") ///
			ytitle("", axis(1)) ytitle("",axis(2)) ///
			yscale(alt axis(2)) yscale(alt axis(1)) /// 
			ytitle("Hospital", axis(1) box bexpand size(large)) /// 
			title("Total", box bexpand) ///
			yscale(range($min_itt $max_itt ) axis(1)) ///
			yscale(range($min_diag $max_diag) axis(2)) ///
			ylabel(-15 0 10, nogrid axis(1)) ///
			ylabel(none, nogrid axis(2)) ///
			nodraw ///
			saving($graphs/lc_`1'_DD,replace)

		*female
		twoway line mean_f year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs14) lw(vthick) yaxis(2)  || ///
			rarea CIL95_f CIR95_f year_treat, sort  color(cranberry%12) yaxis(1) || ///
			rarea CIL90_f CIR90_f year_treat, sort  color(cranberry%25) yaxis(1) || ///
			line b_f year_treat, sort color(cranberry) yaxis(1) ///
			scheme(s1mono) plotregion(color(white)) /// 
			yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
			legend(off) ///
			xlabel(`start' (6) `ende', nolab) xtitle("") ///
			ytitle("", axis(1)) ytitle("",axis(2)) ///
			yscale(alt axis(2)) yscale(alt axis(1)) /// 
			title("Female", box bexpand) ///
			yscale(range($min_itt $max_itt ) axis(1)) ///
			yscale(range($min_diag $max_diag) axis(2)) ///
			ylabel(none, nogrid axis(1)) ///
			ylabel(none, nogrid axis(2)) ///
			nodraw ///
			saving($graphs/lc_`1'_DD_f,replace)
		*male
		twoway line mean_m year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs14) lw(vthick) yaxis(2)  || ///
			rarea CIL95_m CIR95_m year_treat, sort  color(navy%12) yaxis(1) || ///
			rarea CIL90_m CIR90_m year_treat, sort  color(navy%25) yaxis(1) || ///
			line b_m year_treat, sort color(navy) yaxis(1) ///
			scheme(s1mono) plotregion(color(white)) /// 
			yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
			legend(off) ///
			xlabel(`start' (6) `ende', nolab) xtitle("") ///
			ytitle("", axis(1)) ytitle("",axis(2)) ///
			yscale(alt axis(2)) yscale(alt axis(1)) /// 
			title("Male", box bexpand) ///
			yscale(range($min_itt $max_itt ) axis(1)) ///
			yscale(range($min_diag $max_diag) axis(2)) ///
			ylabel(none, nogrid axis(1)) ///
			ylabel(0 80 160, nogrid axis(2)) ///
			nodraw ///
			saving($graphs/lc_`1'_DD_m,replace)
		
			
	} //end: loop over variable specification (COLUMNS)
} //end: loop over variables
	
		graph combine "$graphs/lc_hospital2_DD" "$graphs/lc_hospital2_DD_f" "$graphs/lc_hospital2_DD_m", col(3) imargin(zero) 

	
	*im Zuge der Vergleichbarkeit: define min und max für Variablen	
	global min_itt_t = -4
	global max_itt_t = 4
	global min_itt_f = -8
	global max_itt_f = 4
	global min_itt_m = -8
	global max_itt_m = 4
	
	global min_diag_t = 0
	global max_diag_t = 40
	global min_diag_f = 0
	global max_diag_f = 25
	global min_diag_m = 0
	global max_diag_m = 25	
	
	global min_itt = -8
	global max_itt = 4
	global min_diag = 0
	global max_diag = 40
	
* setup für andere variablen 
	foreach 1 of varlist d1 d2 d5 d6 d7 d8 d9 d10 d11 d12 d13 d17 { // $list_vars_mandf_ratios_available
		capture drop sum_num_diag*
		bys Dinregression year_treat: egen sum_num_diagnoses = total(`1')
		bys Dinregression year_treat: egen sum_num_diagnoses_f = total(`1'_f)
		bys Dinregression year_treat: egen sum_num_diagnoses_m = total(`1'_m)
		
		foreach var in "r_fert_"  {	// COLUMNS
			capture drop b* CIL* CIR*
			foreach j in "" "_f" "_m" { // rows
				qui replace sum_num_diagnoses`j'= sum_num_diagnoses`j'/1000
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
					
					qui sum `var'`1'`j' if e(sample) & treat== 1 & after == 0 
					qui replace mean`j' = `r(mean)' if year_treat == `X'
					
				} //end:loop over lifecycle
			} //end:loop t,f,m (ROWS)
			local start_mtick = `start' + 2 
			*total
			twoway line mean year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs14) lw(vthick) yaxis(2)  || ///
				rarea CIL95 CIR95 year_treat, sort  color(gs2%12) yaxis(1) || ///
				rarea CIL90 CIR90 year_treat, sort  color(gs2%25) yaxis(1) || ///
				line b year_treat, sort color(gs2) yaxis(1) ///
				scheme(s1mono) plotregion(color(white))   /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (6) `ende', nolab) xtitle("") ///
				ytitle("", axis(1)) ytitle("",axis(2)) ///
				yscale(alt axis(2)) yscale(alt axis(1)) /// 
				ytitle("$`1'", axis(1) box bexpand size(large)) ///
				yscale(range($min_itt $max_itt ) axis(1)) ///
				yscale(range($min_diag $max_diag) axis(2)) ///
				ylabel(-5 0 5, nogrid axis(1)) ///
				ylabel(none, nogrid axis(2)) ///
				nodraw ///
				saving($graphs/lc_`1'_DD,replace)
	
			*female
			twoway line mean_f year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs14) lw(vthick) yaxis(2)  || ///
				rarea CIL95_f CIR95_f year_treat, sort  color(cranberry%12) yaxis(1) || ///
				rarea CIL90_f CIR90_f year_treat, sort  color(cranberry%25) yaxis(1) || ///
				line b_f year_treat, sort color(cranberry) yaxis(1) ///
				scheme(s1mono) plotregion(color(white)) /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (6) `ende', nolab) xtitle("") ///
				ytitle("", axis(1)) ytitle("",axis(2)) ///
				yscale(alt axis(2)) yscale(alt axis(1)) ///
				yscale(range($min_itt $max_itt ) axis(1)) ///
				yscale(range($min_diag $max_diag) axis(2)) ///
				ylabel(none, nogrid axis(1)) ///
				ylabel(none, nogrid axis(2)) ////
				nodraw ///
				saving($graphs/lc_`1'_DD_f,replace)
			*male
			twoway line mean_m year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs14) lw(vthick) yaxis(2)  || ///
				rarea CIL95_m CIR95_m year_treat, sort  color(navy%12) yaxis(1) || ///
				rarea CIL90_m CIR90_m year_treat, sort  color(navy%25) yaxis(1) || ///
				line b_m year_treat, sort color(navy) yaxis(1) ///
				scheme(s1mono) plotregion(color(white)) /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (6) `ende', nolab) xtitle("") ///
				ytitle("", axis(1)) ytitle("",axis(2)) ///
				yscale(alt axis(2)) yscale(alt axis(1)) /// 
				yscale(range($min_itt $max_itt) axis(1)) ///
				yscale(range($min_diag $max_diag) axis(2)) ///
				ylabel(none, nogrid axis(1)) ///
				ylabel(0 20 40, nogrid axis(2)) ///
				nodraw ///
				saving($graphs/lc_`1'_DD_m,replace)
			
				
		} //end: loop over variable specification (COLUMNS)
	} //end: loop over variables	
		
		
	
// Graph für bottom: 
	foreach 1 of varlist  d18 { // $list_vars_mandf_ratios_available
		capture drop sum_num_diag*
		bys Dinregression year_treat: egen sum_num_diagnoses = total(`1')
		bys Dinregression year_treat: egen sum_num_diagnoses_f = total(`1'_f)
		bys Dinregression year_treat: egen sum_num_diagnoses_m = total(`1'_m)
		
		
		
		foreach var in "r_fert_"  {	// COLUMNS
			capture drop b* CIL* CIR*
			foreach j in "" "_f" "_m" { // rows
				qui replace sum_num_diagnoses`j'= sum_num_diagnoses`j'/1000
				
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
					
					qui sum `var'`1'`j' if e(sample) & treat== 1 & after == 0 
					qui replace mean`j' = `r(mean)' if year_treat == `X'
					
				} //end:loop over lifecycle
			} //end:loop t,f,m (ROWS)
			local start_mtick = `start' + 2 
			*total
			twoway line mean year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs14) lw(vthick) yaxis(2)  || ///
				rarea CIL95 CIR95 year_treat, sort  color(gs2%12) yaxis(1) || ///
				rarea CIL90 CIR90 year_treat, sort  color(gs2%25) yaxis(1) || ///
				line b year_treat, sort color(gs2) yaxis(1) ///
				scheme(s1mono) plotregion(color(white))   /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (6) `ende' ,val angle(0)) xtitle("") ///
				ytitle("", axis(1)) ytitle("",axis(2)) ///
				yscale(alt axis(2)) yscale(alt axis(1)) /// 
				ytitle("$`1'", axis(1) box bexpand size(large)) /// 
				yscale(range($min_itt $max_itt ) axis(1)) ///
				yscale(range($min_diag $max_diag) axis(2)) ///
				ylabel(-5 0 5, nogrid axis(1)) ///
				ylabel(none, nogrid axis(2)) ///
				nodraw ///
				saving($graphs/lc_`1'_DD,replace)
	
			*female
			twoway line mean_f year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs14) lw(vthick) yaxis(2)  || ///
				rarea CIL95_f CIR95_f year_treat, sort  color(cranberry%12) yaxis(1) || ///
				rarea CIL90_f CIR90_f year_treat, sort  color(cranberry%25) yaxis(1) || ///
				line b_f year_treat, sort color(cranberry) yaxis(1) ///
				scheme(s1mono) plotregion(color(white)) /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (6) `ende' ,val angle(0)) xtitle("") ///
				ytitle("", axis(1)) ytitle("",axis(2)) ///
				yscale(alt axis(2)) yscale(alt axis(1)) ///
				yscale(range($min_itt $max_itt ) axis(1)) ///
				yscale(range($min_diag $max_diag) axis(2)) ///
				ylabel(none, nogrid axis(1)) ///
				ylabel(none, nogrid axis(2)) ///
				nodraw ///
				saving($graphs/lc_`1'_DD_f,replace)
			*male
			twoway line mean_m year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs14) lw(vthick) yaxis(2)  || ///
				rarea CIL95_m CIR95_m year_treat, sort  color(navy%12) yaxis(1) || ///
				rarea CIL90_m CIR90_m year_treat, sort  color(navy%25) yaxis(1) || ///
				line b_m year_treat, sort color(navy) yaxis(1) ///
				scheme(s1mono) plotregion(color(white)) /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(off) ///
				xlabel(`start' (6) `ende' ,val angle(0)) xtitle("") ///
				ytitle("", axis(1)) ytitle("",axis(2)) ///
				yscale(alt axis(2)) yscale(alt axis(1)) /// 
				yscale(range($min_itt $max_itt) axis(1)) ///
				yscale(range($min_diag $max_diag) axis(2)) ///
				ylabel(none, nogrid axis(1)) ///
				ylabel(0 20 40, nogrid axis(2)) ///
				nodraw ///
				saving($graphs/lc_`1'_DD_m,replace)
			
				
		} //end: loop over variable specification (COLUMNS)
	} //end: loop over variables
		
	

*graph combine "$graphs/lc_d18_DD" "$graphs/lc_d18_DD_f" "$graphs/lc_d18_DD_m" 
	
	
* graph halbieren
*Graph 1 
	graph combine "$graphs/lc_hospital2_DD" "$graphs/lc_hospital2_DD_f" "$graphs/lc_hospital2_DD_m" ///
		"$graphs/lc_d1_DD" "$graphs/lc_d1_DD_f" "$graphs/lc_d1_DD_m"	///
		"$graphs/lc_d2_DD" "$graphs/lc_d2_DD_f" "$graphs/lc_d2_DD_m"	///
		"$graphs/lc_d5_DD" "$graphs/lc_d5_DD_f" "$graphs/lc_d5_DD_m"	///
		"$graphs/lc_d6_DD" "$graphs/lc_d6_DD_f" "$graphs/lc_d6_DD_m"	///
		"$graphs/lc_d7_DD" "$graphs/lc_d7_DD_f" "$graphs/lc_d7_DD_m"	///
		"$graphs/lc_d8_DD" "$graphs/lc_d8_DD_f" "$graphs/lc_d8_DD_m"	///
	,row(7) xsize(11.5) ysize(15) imargin(zero) ///
	scheme(s1mono) 
	graph export "$graph_paper/lc_matrix_chapters_1.pdf", as(pdf) replace
	
*Graph 2 
	graph combine "$graphs/lc_d9_DD" "$graphs/lc_d9_DD_f" "$graphs/lc_d9_DD_m"	///
		"$graphs/lc_d10_DD" "$graphs/lc_d10_DD_f" "$graphs/lc_d10_DD_m"	///
		"$graphs/lc_d11_DD" "$graphs/lc_d11_DD_f" "$graphs/lc_d11_DD_m"	///
		"$graphs/lc_d12_DD" "$graphs/lc_d12_DD_f" "$graphs/lc_d12_DD_m"	///
		"$graphs/lc_d13_DD" "$graphs/lc_d13_DD_f" "$graphs/lc_d13_DD_m"	///
		"$graphs/lc_d17_DD" "$graphs/lc_d17_DD_f" "$graphs/lc_d17_DD_m"	///
		"$graphs/lc_d18_DD" "$graphs/lc_d18_DD_f" "$graphs/lc_d18_DD_m"	///
	,row(7) xsize(11.5) ysize(15) imargin(zero) ///
	scheme(s1mono) xcommon b2title("Year [age of treatment cohort]", size(vsmall) margin(top))
	graph export "$graph_paper/lc_matrix_chapters_2.pdf", as(pdf) replace

	
/* // alle chapter in einem Graphen
	graph combine "$graphs/lc_hospital2_DD" "$graphs/lc_hospital2_DD_f" "$graphs/lc_hospital2_DD_m" ///
		"$graphs/lc_d1_DD" "$graphs/lc_d1_DD_f" "$graphs/lc_d1_DD_m"	///
		"$graphs/lc_d2_DD" "$graphs/lc_d2_DD_f" "$graphs/lc_d2_DD_m"	///
		"$graphs/lc_d5_DD" "$graphs/lc_d5_DD_f" "$graphs/lc_d5_DD_m"	///
		"$graphs/lc_d6_DD" "$graphs/lc_d6_DD_f" "$graphs/lc_d6_DD_m"	///
		"$graphs/lc_d7_DD" "$graphs/lc_d7_DD_f" "$graphs/lc_d7_DD_m"	///
		"$graphs/lc_d8_DD" "$graphs/lc_d8_DD_f" "$graphs/lc_d8_DD_m"	///
		"$graphs/lc_d9_DD" "$graphs/lc_d9_DD_f" "$graphs/lc_d9_DD_m"	///
		"$graphs/lc_d10_DD" "$graphs/lc_d10_DD_f" "$graphs/lc_d10_DD_m"	///
		"$graphs/lc_d11_DD" "$graphs/lc_d11_DD_f" "$graphs/lc_d11_DD_m"	///
		"$graphs/lc_d12_DD" "$graphs/lc_d12_DD_f" "$graphs/lc_d12_DD_m"	///
		"$graphs/lc_d13_DD" "$graphs/lc_d13_DD_f" "$graphs/lc_d13_DD_m"	///
		"$graphs/lc_d17_DD" "$graphs/lc_d17_DD_f" "$graphs/lc_d17_DD_m"	///
		"$graphs/lc_d18_DD" "$graphs/lc_d18_DD_f" "$graphs/lc_d18_DD_m"	///
	,row(14) xsize(9) ysize(15) imargin(zero) ///
	scheme(s1mono) 
	graph export "$graphs/temp.pdf", as(pdf) replace
	*/	

	