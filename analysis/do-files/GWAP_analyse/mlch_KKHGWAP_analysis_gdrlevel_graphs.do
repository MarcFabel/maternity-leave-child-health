// GDR Level graphs

clear all
set more off
/*
DDD
- lifecourse graph
- placebo graph
 
*/

*magic numbers
	global first_year = 1995
	global last_year  = 2014
	global t_90		  = 1.645
	global t_95   	  = 1.960

********** The program
	capture program drop DDD
	program define DDD
		qui reg `1'  treat after FRG TxA FxT FxA FxTxA `2' , vce(cluster MxFRG) // NEUE CLUSTER VARIABLE
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
					DDD `var'`1'`j'  " if year_treat == `X' & $C2"
					qui replace b`j' = _b[FxTxA] if year_treat == `X'
					qui replace CIL`j' = (_b[FxTxA]- $t_90 *_se[FxTxA]) if year_treat == `X'
					qui replace CIR`j' = (_b[FxTxA]+ $t_90 *_se[FxTxA]) if year_treat == `X'
				} //end:loop over lifecycle
			} //end:loop t,f,m (ROWS)
			*total
			twoway line sum_num_diagnoses year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs13) lw(vthick) yaxis(2)  || ///
				scatter b year_treat, sort color(black) m(O) yaxis(1)  || ///	
				rcap CIL CIR year_treat, sort  color(black) yaxis(1)   ///
				scheme(s1mono)  /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black) axis(1))   ///
				legend(off) ///
				xlabel(1995 (4) 2014 ,val angle(0)) xtitle("") ///
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
				xlabel(1995 (4) 2014 ,val angle(0)) xtitle("") ///
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
				xlabel(1995 (4) 2014 ,val angle(0)) xtitle("") ///
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
	
	/*
// 2) Placebo graph
	use "$temp/KKH_final_gdrlevel_extended", clear
	
	
	
	
