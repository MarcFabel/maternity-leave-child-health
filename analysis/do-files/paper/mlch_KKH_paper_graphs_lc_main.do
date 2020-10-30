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
capture drop Dinregression temp
qui gen Dinregression = 1 if cond($C2,1,0)
qui gen temp = 1 if treat == 1 & after == 0

foreach 1 of varlist hospital2 d5 { // hospital2 d5
	capture drop sum_num_diag*
	bys temp year_treat: egen sum_num_diagnoses = mean(r_fert_`1') if treat == 1 & after == 0
	bys temp year_treat: egen sum_num_diagnoses_f = mean(r_fert_`1'_f) if treat == 1 & after == 0
	bys temp year_treat: egen sum_num_diagnoses_m = mean(r_fert_`1'_m) if treat == 1 & after == 0
	
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
			rarea CIL95 CIR95 year_treat, sort  color(gs2%12) yaxis(1) || ///
			rarea CIL90 CIR90 year_treat, sort  color(gs2%25) yaxis(1) || ///
			line b year_treat, sort color(gs2) yaxis(1) ///
			scheme(s1mono)    /// 
			yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
			legend(label(2 "95% CI") label(3 "90% CI")) ///
			legend(order(3 2)) legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
			legend(region(color(none))) legend(symx(5)) ///
			xlabel(`start' (4) `ende' ,val angle(0)) xtitle("Year [Age]") ///
			xmtick(`start_mtick'  (4) `ende') ///
			ytitle("ITT effect", axis(1)) ytitle("Dependent mean",axis(2)) ///
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
			xlabel(`start' (4) `ende' ,val angle(0)) xtitle("Year [Age]") ///
			xmtick(`start_mtick'  (4) `ende') ///
			ytitle("ITT effect", axis(1)) ytitle("Dependent mean",axis(2)) ///
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
			xlabel(`start' (4) `ende' ,val angle(0)) xtitle("Year [Age]") ///
			xmtick(`start_mtick'  (4) `ende') ///
			ytitle("ITT effect", axis(1)) ytitle("Dependent mean",axis(2)) ///
			yscale(alt axis(2)) yscale(alt axis(1)) 
			graph export "$graph_paper/lc_`1'_male_gdr.pdf", as(pdf) replace	
		
			
	} //end: loop over variable specification (COLUMNS)
	} //end: loop over variables
	
	
	
	
	
	
	
	
	
	
	
	
*-------------------------------------------------------------------------------
* LC w/o dependent mean (to couple it with parallel trends)
*-------------------------------------------------------------------------------





	use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"

// THE PROGRAM
	capture program drop DDRD
	program define DDRD
			qui reg `1' treat after TxA i.MOB   `2'  , vce(cluster MxY) 
	end
*************************
// PANEL 1.1: PLOTS FOR EACH GENDER SEPERATELY (WITH CG2!) 
	capture drop Dinregression temp
	qui gen Dinregression = 1 if cond($C2,1,0)
	qui gen temp = 1 if treat == 1 & after == 0
	
	foreach 1 of varlist hospital2 d5 { // hospital2 d5
		foreach var in "r_fert_"  {	// COLUMNS
			capture drop b* CIL* CIR*
			foreach j in "" "_f" "_m"  { // rows 						
				
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
			twoway rarea CIL95 CIR95 year_treat, sort  color(gs2%12) yaxis(1) || ///
				rarea CIL90 CIR90 year_treat, sort  color(gs2%25) yaxis(1) || ///
				line b year_treat, sort color(gs2) yaxis(1) ///
				scheme(s1mono) plotregion(color(white))   /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(label(1 "95% CI") label(2 "90% CI")) ///
				legend(order(2 1)) legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
				legend(region(color(none))) legend(symx(5)) ///
				xlabel(`start' (4) `ende' ,val angle(0)) xtitle("Year [Age]") ///
				xmtick(`start_mtick'  (4) `ende') ///
				ytitle("ITT effect") ///
				title("B. Differentials",pos(11) span  size(vlarge)) ///
				saving($graphs/lc_`1'_wo_y, replace)
				*graph export "$graph_paper/lc_`1'_total_wo_y.pdf", as(pdf) replace	
	
			*female
			twoway rarea CIL95_f CIR95_f year_treat, sort  color(cranberry%12) yaxis(1) || ///
				rarea CIL90_f CIR90_f year_treat, sort  color(cranberry%25) yaxis(1) || ///
				line b_f year_treat, sort color(cranberry) yaxis(1) ///
				scheme(s1mono) plotregion(color(white))   /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(label(1 "95% CI") label(2 "90% CI")) ///
				legend(order(2 1)) legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
				legend(region(color(none))) legend(symx(5)) ///
				xlabel(`start' (4) `ende' ,val angle(0)) xtitle("Year [Age]") ///
				xmtick(`start_mtick'  (4) `ende') ///
				ytitle("ITT effect") ///
				title("B. Differentials",pos(11) span  size(vlarge)) ///
				saving($graphs/lc_`1'_f_wo_y, replace)	
				*graph export "$graph_paper/lc_`1'_female_wo_y.pdf", as(pdf) replace		
			
			*male
			twoway rarea CIL95_m CIR95_m year_treat, sort  color(navy%12) yaxis(1) || ///
				rarea CIL90_m CIR90_m year_treat, sort  color(navy%25) yaxis(1) || ///
				line b_m year_treat, sort color(navy) yaxis(1) ///
				scheme(s1mono) plotregion(color(white))   /// 
				yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
				legend(label(1 "95% CI") label(2 "90% CI")) ///
				legend(order(2 1)) legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
				legend(region(color(none))) legend(symx(5)) ///
				xlabel(`start' (4) `ende' ,val angle(0)) xtitle("Year [Age]") ///
				xmtick(`start_mtick'  (4) `ende') ///
				ytitle("ITT effect") ///
				title("B. Differentials",pos(11) span  size(vlarge)) ///
				saving($graphs/lc_`1'_m_wo_y, replace)
				*graph export "$graph_paper/lc_`1'_male_wo_y.pdf", as(pdf) replace	
			
				
		} //end: loop over variable specification (COLUMNS)
		} //end: loop over variables




// Panel A: Parallel Trends

	use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"
	keep if GDR == 0
	keep if $C2
	keep if $all_age
	
	
	collapse (mean) r_fert_hospital2 r_fert_hospital2_f r_fert_hospital2_m ///
		(sd) sd_hosp2 =  r_fert_hospital2  sd_hosp2_f =r_fert_hospital2_f sd_hosp2_m =r_fert_hospital2_m , by(treat after year)
	qui gen CI_low = r_fert_hospital2 - $t_95 * sd_hosp2
	qui gen CI_high = r_fert_hospital2 + $t_95 * sd_hosp2
	
	qui gen CI_low_f = r_fert_hospital2_f - $t_95 * sd_hosp2_f
	qui gen CI_high_f = r_fert_hospital2_f + $t_95 * sd_hosp2_f
	
	qui gen CI_low_m = r_fert_hospital2_m - $t_95 * sd_hosp2_m
	qui gen CI_high_m = r_fert_hospital2_m + $t_95 * sd_hosp2_m
	
	#delimit ;
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
	#delimit cr
	label val year YEAR
	
	local start = 1996
	local ende = 2013
	local start_mtick = 1998
	local ende_mtick = 2014
	
	
	// pre-threshold diagram total
	line r_fert_hospital2 year if after == 0 & treat == 0 & year >= `start' & year <= `ende' , color(gray) || /// 
		line r_fert_hospital2 year if after == 0 &  treat == 1 & year <= `ende', lpattern(dash)  ///
		legend(label(1 "control") label(2 "treatment") label(3 "90% CI control")) ///
		ytitle("Dependent mean") xtitle("Year [Age]") ///
		 legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
		 legend(region(color(none))) legend(symx(5)) ///
		 xlabel(`start' (4) `ende' ,val angle(0)) xtitle("Year [Age]") ///
		 xmtick(`start_mtick'  (4) `ende_mtick')  ///
		 scheme(s1mono) plotregion(color(white)) xscale(r(1995 2014)) ///
		 title("A. Pre-threshold means",pos(11) span  size(vlarge)) ///
		 saving($graphs/mlch_parallel_trends_hospital2,replace)
		 *		rarea CI_low CI_high year if after == 0 & treat == 0 & year >= `start'& year <= `ende' , color(gray%25) ///
	*graph export "$graph_paper/mlch_parallel_trends_hospital2.pdf", as(pdf) replace
		 
		 
	// pre-threshold diagram female
	line r_fert_hospital2_f year if after == 0 & treat == 0 & year >= `start' & year <= `ende' , color(cranberry) || /// 
		line r_fert_hospital2_f year if after == 0 &  treat == 1 & year <= `ende', color(cranberry) lpattern(dash)  ///
		legend(label(1 "control") label(2 "treatment") label(3 "90% CI control")) ///
		ytitle("Dependent mean") xtitle("Year [Age]") ///
		 legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
		 legend(region(color(none))) legend(symx(5)) ///
		 xlabel(`start' (4) `ende' ,val angle(0)) xtitle("Year [Age]") ///
		 xmtick(`start_mtick'  (4) `ende_mtick')  ///
		 scheme(s1mono) plotregion(color(white)) xscale(r(1995 2014)) ///
		 title("A. Pre-threshold means",pos(11) span  size(vlarge)) ///
		 saving($graphs/mlch_parallel_trends_hospital2_f,replace)
		 *rarea CI_low_f CI_high_f year if after == 0 & treat == 0 & year >= `start'& year <= `ende' , color(cranberry%25) ///
	*graph export "$graph_paper/mlch_parallel_trends_hospital2_f.pdf", as(pdf) replace
		
		
	// pre-threshold diagram male
	local start = 1996
	local ende = 2013
	local start_mtick = 1998
	local ende_mtick = 2014
	line r_fert_hospital2_m year if after == 0 & treat == 0 & year >= `start' & year <= `ende' , color(navy) || /// 
		line r_fert_hospital2_m year if after == 0 &  treat == 1 & year <= `ende', color(navy) lpattern(dash)  ///
		legend(label(1 "control") label(2 "treatment") label(3 "90% CI control")) ///
		ytitle("Dependent mean") xtitle("Year [Age]") ///
		 legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
		 legend(region(color(none))) legend(symx(5)) ///
		 xlabel(`start' (4) `ende' ,val angle(0)) xtitle("Year [Age]") ///
		 xmtick(`start_mtick'  (4) `ende_mtick')  ///
		 scheme(s1mono) plotregion(color(white)) xscale(r(1995 2014)) ///
		 title("A. Pre-threshold means",pos(11) span  size(vlarge)) ///
		 saving($graphs/mlch_parallel_trends_hospital2_m,replace)	
		 *		rarea CI_low_m CI_high_m year if after == 0 & treat == 0 & year >= `start'& year <= `ende' , color(navy%25) ///
	*graph export "$graph_paper/mlch_parallel_trends_hospital2_m.pdf", as(pdf) replace		
		
		
		
		
		
// ***********************************************************************
* COMMON TRENDS MBD
// ***********************************************************************		
		
		
		
		
	use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"
	keep if GDR == 0
	keep if $C2
	keep if $all_age
	
	
	collapse (mean) r_fert_d5 r_fert_d5_f r_fert_d5_m ///
		(sd) sd_d5 =  r_fert_d5  sd_d5_f =r_fert_d5_f sd_d5_m =r_fert_d5_m , by(treat after year)
	qui gen CI_low = r_fert_d5 - $t_95 * sd_d5
	qui gen CI_high = r_fert_d5 + $t_95 * sd_d5
	
	qui gen CI_low_f = r_fert_d5_f - $t_95 * sd_d5_f
	qui gen CI_high_f = r_fert_d5_f + $t_95 * sd_d5_f
	
	qui gen CI_low_m = r_fert_d5_m - $t_95 * sd_d5_m
	qui gen CI_high_m = r_fert_d5_m + $t_95 * sd_d5_m
	
	#delimit ;
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
	#delimit cr
	label val year YEAR
	
	local start = 1996
	local ende = 2013
	local start_mtick = 1998
	local ende_mtick = 2014
	
	
	// pre-threshold diagram total
	line r_fert_d5 year if after == 0 & treat == 0 & year >= `start' & year <= `ende' , color(gray) || /// 
		line r_fert_d5 year if after == 0 &  treat == 1 & year <= `ende', lpattern(dash)  ///
		legend(label(1 "control") label(2 "treatment") label(3 "90% CI control")) ///
		ytitle("Dependent mean") xtitle("Year [Age]") ///
		 legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
		 legend(region(color(none))) legend(symx(5)) ///
		 xlabel(`start' (4) `ende' ,val angle(0)) xtitle("Year [Age]") ///
		 xmtick(`start_mtick'  (4) `ende_mtick')  ///
		 scheme(s1mono) plotregion(color(white)) xscale(r(1995 2014)) ///
		 title("A. Pre-threshold means",pos(11) span  size(vlarge)) ///
		 saving($graphs/mlch_parallel_trends_d5,replace)
		 *rarea CI_low CI_high year if after == 0 & treat == 0 & year >= `start'& year <= `ende' , color(gray%12) ///
	*graph export "$graph_paper/mlch_parallel_trends_d5.pdf", as(pdf) replace
	
		 
	// pre-threshold diagram female
	line r_fert_d5_f year if after == 0 & treat == 0 & year >= `start' & year <= `ende' , color(cranberry) || /// 
		line r_fert_d5_f year if after == 0 &  treat == 1 & year <= `ende', color(cranberry) lpattern(dash)  ///
		legend(label(1 "control") label(2 "treatment") label(3 "90% CI control")) ///
		ytitle("Dependent mean") xtitle("Year [Age]") ///
		 legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
		 legend(region(color(none))) legend(symx(5)) ///
		 xlabel(`start' (4) `ende' ,val angle(0)) xtitle("Year [Age]") ///
		 xmtick(`start_mtick'  (4) `ende_mtick')  ///
		 scheme(s1mono) plotregion(color(white)) xscale(r(1995 2014))	 ///
		 title("A. Pre-threshold means",pos(11) span  size(vlarge)) ///
		 saving($graphs/mlch_parallel_trends_d5_f,replace) 
		 *rarea CI_low_f CI_high_f year if after == 0 & treat == 0 & year >= `start'& year <= `ende' , color(cranberry%12) ///
	*graph export "$graph_paper/mlch_parallel_trends_d5_f.pdf", as(pdf) replace	
		
		
	// pre-threshold diagram male
	local start = 1996
	local ende = 2013
	local start_mtick = 1998
	local ende_mtick = 2014
	line r_fert_d5_m year if after == 0 & treat == 0 & year >= `start' & year <= `ende' , color(navy) || /// 
		line r_fert_d5_m year if after == 0 &  treat == 1 & year <= `ende', color(navy) lpattern(dash)  ///
		legend(label(1 "control") label(2 "treatment") label(3 "90% CI control")) ///
		ytitle("Dependent mean") xtitle("Year [Age]") ///
		 legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
		 legend(region(color(none))) legend(symx(5)) ///
		 xlabel(`start' (4) `ende' ,val angle(0)) xtitle("Year [Age]") ///
		 xmtick(`start_mtick'  (4) `ende_mtick')  ///
		 scheme(s1mono) plotregion(color(white)) xscale(r(1995 2014))	 ///
		 title("A. Pre-threshold means",pos(11) span  size(vlarge)) ///
		 saving($graphs/mlch_parallel_trends_d5_m,replace)
		 *rarea CI_low_m CI_high_m year if after == 0 & treat == 0 & year >= `start'& year <= `ende' , color(navy%12) ///
	*graph export "$graph_paper/mlch_parallel_trends_d5_m.pdf", as(pdf) replace	
		

		
		
		
		
		
	* combine the dependent means with the lifecourse graphs
	foreach 1 in "hospital2" "d5" { // hospital2 d5
		foreach j in "" "_f" "_m"  { // rows 
			graph combine "$graphs/mlch_parallel_trends_`1'`j'" "$graphs/lc_`1'`j'_wo_y",  altshrink scheme(s1mono) plotregion(color(white)) col(2) xsize(11) xcommon
			graph export "$graph_paper/mlch_lc_trends_`1'`j'.pdf", as(pdf) replace
		}
	}
	
	
		
	* combine the dependent means with the lifecourse graphs - append vertically
	foreach 1 in "hospital2"  d5 { // hospital2 d5
		foreach j in "" "_f" "_m"  { // rows 
			graph combine "$graphs/mlch_parallel_trends_`1'`j'" "$graphs/lc_`1'`j'_wo_y",  altshrink scheme(s1mono) plotregion(color(white)) col(1) ysize(8) xcommon
			graph export "$graph_paper/mlch_lc_trends_`1'`j'.pdf", as(pdf) replace
		}
	}	
		
		