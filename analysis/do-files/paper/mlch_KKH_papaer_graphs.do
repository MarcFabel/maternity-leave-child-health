// ***************************** PREAMBLE********************************
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

// LIFE-Course


*-------------------------------------------------------------------------------
* 1) GENDER AND RATIOS AVAILABLE ( VARIABLES OF MAIN INTEREST)
*-------------------------------------------------------------------------------
// THE PROGRAM
capture program drop DDRD
program define DDRD
		qui reg `1' treat after TxA i.MOB   `2'  , vce(cluster MxY) 
end
*************************
// PANEL 1.1: PLOTS FOR EACH GENDER SEPERATELY (WITH CG2!) 
capture drop Dinregression
qui gen Dinregression = 1 if cond($C2,1,0)

foreach 1 of varlist hospital2 { // $list_vars_mandf_ratios_available
	capture drop sum_num_diag*
	bys Dinregression year_treat: egen sum_num_diagnoses = total(`1')
	bys Dinregression year_treat: egen sum_num_diagnoses_f = total(`1'_f)
	bys Dinregression year_treat: egen sum_num_diagnoses_m = total(`1'_m)
	
	foreach var in "r_fert_"  {	// COLUMNS
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
			scheme(s1mono)    /// 
			yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
			legend(label(2 "95% CI") label(3 "90% CI")) ///
			legend(order(3 2)) legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
			legend(region(color(none))) legend(symx(5)) ///
			xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") ///
			xmtick(`start_mtick'  (4) `ende') ///
			ytitle("ITT effect", axis(1)) ytitle("Number of diagnoses",axis(2)) ///
			yscale(alt axis(2)) yscale(alt axis(1)) 
			graph export "$graph_paper/lc_`1'_total_gdr.pdf", as(pdf) replace	

		*female
		twoway line sum_num_diagnoses_f year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs14) lw(vthick) yaxis(2)  || ///
			rarea CIL95_f CIR95_f year_treat, sort  color(cranberry%12) yaxis(1) || ///
			rarea CIL90_f CIR90_f year_treat, sort  color(cranberry%25) yaxis(1) || ///
			line b_f year_treat, sort color(cranberry) yaxis(1) ///
			scheme(s1mono)  /// 
			yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
			legend(label(2 "95% CI") label(3 "90% CI")) ///
			legend(order(3 2)) legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
			legend(region(color(none))) legend(symx(5)) ///
			xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") ///
			xmtick(`start_mtick'  (4) `ende') ///
			ytitle("ITT effect", axis(1)) ytitle("Number of diagnoses",axis(2)) ///
			yscale(alt axis(2)) yscale(alt axis(1))
			graph export "$graph_paper/lc_`1'_female_gdr.pdf", as(pdf) replace		
		*male
		twoway line sum_num_diagnoses_m year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs14) lw(vthick) yaxis(2)  || ///
			rarea CIL95_m CIR95_m year_treat, sort  color(navy%12) yaxis(1) || ///
			rarea CIL90_m CIR90_m year_treat, sort  color(navy%25) yaxis(1) || ///
			line b_m year_treat, sort color(navy) yaxis(1) ///
			scheme(s1mono)  /// 
			yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
			legend(label(2 "95% CI") label(3 "90% CI")) ///
			legend(order(3 2)) legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
			legend(region(color(none))) legend(symx(5)) ///
			xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") ///
			xmtick(`start_mtick'  (4) `ende') ///
			ytitle("ITT effect", axis(1)) ytitle("Number of diagnoses",axis(2)) ///
			yscale(alt axis(2)) yscale(alt axis(1)) 
			graph export "$graph_paper/lc_`1'_male_gdr.pdf", as(pdf) replace	
		
			
	} //end: loop over variable specification (COLUMNS)
	
		
	} //end: loop over variables
