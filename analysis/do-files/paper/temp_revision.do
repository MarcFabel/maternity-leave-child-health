// ***************************** PREAMBLE********************************
/*
	

*/	
	clear all
	set more off
	
	global path   "F:\econ\m-l-c-h\analysis"	
	global temp   "$path/temp"
	global graphs "$path/graphs/KKH"
	global graph_paper "$path/graphs/paper" 
	global graph_temp "$path/graphs/temp"

	global tables "$path/tables/KKH"
	global tables_paper "$path/tables/paper"
	global auxiliary "$path/do-files/auxiliary_files"
	
	*magic numbers
	global first_year = 1995
	global last_year  = 2014
	global t_90		  = 1.645
	global t_95   	  = 1.960
	
	

// ***********************************************************************
* COMMON TRENDS HOSPITALIZATION
// ***********************************************************************

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
		line r_fert_hospital2 year if after == 0 &  treat == 1 & year <= `ende', lpattern(dash) || ///
		rarea CI_low CI_high year if after == 0 & treat == 0 & year >= `start'& year <= `ende' , color(gray%12) ///
		legend(label(1 "control") label(2 "treatment") label(3 "90% CI control")) ///
		ytitle("Average pre-threshold hospitalization") xtitle("Year [Age]") ///
		 legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
		 legend(region(color(none))) legend(symx(5)) ///
		 xlabel(`start' (4) `ende' ,val angle(0)) xtitle("Year [Age]") ///
		 xmtick(`start_mtick'  (4) `ende_mtick')  ///
		 scheme(s1mono) plotregion(color(white)) xscale(r(1995 2014))
	graph export "$graph_paper/mlch_parallel_trends_hospital2.pdf", as(pdf) replace
		 
		 
	// pre-threshold diagram female
	line r_fert_hospital2_f year if after == 0 & treat == 0 & year >= `start' & year <= `ende' , color(cranberry) || /// 
		line r_fert_hospital2_f year if after == 0 &  treat == 1 & year <= `ende', color(cranberry) lpattern(dash) || ///
		rarea CI_low_f CI_high_f year if after == 0 & treat == 0 & year >= `start'& year <= `ende' , color(cranberry%12) ///
		legend(label(1 "control") label(2 "treatment") label(3 "90% CI control")) ///
		ytitle("Average pre-threshold hospitalization") xtitle("Year [Age]") ///
		 legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
		 legend(region(color(none))) legend(symx(5)) ///
		 xlabel(`start' (4) `ende' ,val angle(0)) xtitle("Year [Age]") ///
		 xmtick(`start_mtick'  (4) `ende_mtick')  ///
		 scheme(s1mono) plotregion(color(white)) xscale(r(1995 2014))
	graph export "$graph_paper/mlch_parallel_trends_hospital2_f.pdf", as(pdf) replace
		
		
	// pre-threshold diagram male
	local start = 1996
	local ende = 2013
	local start_mtick = 1998
	local ende_mtick = 2014
	line r_fert_hospital2_m year if after == 0 & treat == 0 & year >= `start' & year <= `ende' , color(navy) || /// 
		line r_fert_hospital2_m year if after == 0 &  treat == 1 & year <= `ende', color(navy) lpattern(dash) || ///
		rarea CI_low_m CI_high_m year if after == 0 & treat == 0 & year >= `start'& year <= `ende' , color(navy%12) ///
		legend(label(1 "control") label(2 "treatment") label(3 "90% CI control")) ///
		ytitle("Average pre-threshold hospitalization") xtitle("Year [Age]") ///
		 legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
		 legend(region(color(none))) legend(symx(5)) ///
		 xlabel(`start' (4) `ende' ,val angle(0)) xtitle("Year [Age]") ///
		 xmtick(`start_mtick'  (4) `ende_mtick')  ///
		 scheme(s1mono) plotregion(color(white)) xscale(r(1995 2014))	
	graph export "$graph_paper/mlch_parallel_trends_hospital2_m.pdf", as(pdf) replace		
		
		
		
		
		
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
		line r_fert_d5 year if after == 0 &  treat == 1 & year <= `ende', lpattern(dash) || ///
		rarea CI_low CI_high year if after == 0 & treat == 0 & year >= `start'& year <= `ende' , color(gray%12) ///
		legend(label(1 "control") label(2 "treatment") label(3 "90% CI control")) ///
		ytitle("Average pre-threshold hospitalization") xtitle("Year [Age]") ///
		 legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
		 legend(region(color(none))) legend(symx(5)) ///
		 xlabel(`start' (4) `ende' ,val angle(0)) xtitle("Year [Age]") ///
		 xmtick(`start_mtick'  (4) `ende_mtick')  ///
		 scheme(s1mono) plotregion(color(white)) xscale(r(1995 2014))
	graph export "$graph_paper/mlch_parallel_trends_d5.pdf", as(pdf) replace
	
		 
	// pre-threshold diagram female
	line r_fert_d5_f year if after == 0 & treat == 0 & year >= `start' & year <= `ende' , color(cranberry) || /// 
		line r_fert_d5_f year if after == 0 &  treat == 1 & year <= `ende', color(cranberry) lpattern(dash) || ///
		rarea CI_low_f CI_high_f year if after == 0 & treat == 0 & year >= `start'& year <= `ende' , color(cranberry%12) ///
		legend(label(1 "control") label(2 "treatment") label(3 "90% CI control")) ///
		ytitle("Average pre-threshold hospitalization") xtitle("Year [Age]") ///
		 legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
		 legend(region(color(none))) legend(symx(5)) ///
		 xlabel(`start' (4) `ende' ,val angle(0)) xtitle("Year [Age]") ///
		 xmtick(`start_mtick'  (4) `ende_mtick')  ///
		 scheme(s1mono) plotregion(color(white)) xscale(r(1995 2014))	 
	graph export "$graph_paper/mlch_parallel_trends_d5_f.pdf", as(pdf) replace	
		
		
	// pre-threshold diagram male
	local start = 1996
	local ende = 2013
	local start_mtick = 1998
	local ende_mtick = 2014
	line r_fert_d5_m year if after == 0 & treat == 0 & year >= `start' & year <= `ende' , color(navy) || /// 
		line r_fert_d5_m year if after == 0 &  treat == 1 & year <= `ende', color(navy) lpattern(dash) || ///
		rarea CI_low_m CI_high_m year if after == 0 & treat == 0 & year >= `start'& year <= `ende' , color(navy%12) ///
		legend(label(1 "control") label(2 "treatment") label(3 "90% CI control")) ///
		ytitle("Average pre-threshold hospitalization") xtitle("Year [Age]") ///
		 legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
		 legend(region(color(none))) legend(symx(5)) ///
		 xlabel(`start' (4) `ende' ,val angle(0)) xtitle("Year [Age]") ///
		 xmtick(`start_mtick'  (4) `ende_mtick')  ///
		 scheme(s1mono) plotregion(color(white)) xscale(r(1995 2014))	
	graph export "$graph_paper/mlch_parallel_trends_d5_m.pdf", as(pdf) replace	
		
		
		
	
	
// ***********************************************************************
* Interactions with age range
// ***********************************************************************	
	
	
	use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"
	
	
	
capture program drop DDRD_sclrs_X
	program define DDRD_sclrs_X
		qui eststo `1': reg `2' treat after TxA_17_21  TxA_22_26 TxA_27_31 TxA_32_35  `3'  `4', vce(cluster MxY) 
		qui estadd scalar Nn = e(N)
		qui sum `2' if e(sample) & treat== 1 & after == 0 
		qui estadd scalar mean = round(`r(mean)',.01)		// pre-reform mean for treated group
	end		
	
	
	*baseline regression
	reg  r_fert_hospital2 treat after TxA  i.MOB i.year if $C2 & $all_age, vce(cluster MxY) 
	
	
	* interaction
	qui gen d_17_21 = cond((year_treat >= 1996 & year_treat<=2000),1,0)
	qui gen d_22_26 = cond((year_treat >= 2001 & year_treat<=2005),1,0)
	qui gen d_27_31 = cond((year_treat >= 2006 & year_treat<=2010),1,0)
	qui gen d_32_35 = cond((year_treat >= 2011 & year_treat<=2014),1,0)
	
	qui gen TxA_17_21 = TxA * d_17_21
	qui gen TxA_22_26 = TxA * d_22_26
	qui gen TxA_27_31 = TxA * d_27_31
	qui gen TxA_32_35 = TxA * d_32_35
	                          
	                          
	*interacted version       
	reg  r_fert_hospital2 treat after TxA_17_21  TxA_22_26 TxA_27_31 TxA_32_35  i.MOB i.year if $C2 & $all_age, vce(cluster MxY) 
	
	
	
	
// hospital 2	****************************************************************
	
	* total
	DDRD_sclrs_X a1 r_fert_hospital2 "i.MOB i.year" "if $C2 & $all_age"			//6 months BW
	DDRD_sclrs_X a2 r_fert_hospital2 "i.MOB i.year" "if $C2 & $all_age  & $M5"
	DDRD_sclrs_X a3 r_fert_hospital2 "i.MOB i.year" "if $C2 & $all_age  & $M4"
	DDRD_sclrs_X a4 r_fert_hospital2 "i.MOB i.year" "if $C2 & $all_age  & $M3"
	DDRD_sclrs_X a5 r_fert_hospital2 "i.MOB i.year" "if $C2 & $all_age  & $MD"
	esttab a* ,keep(TxA*) se star(* 0.10 ** 0.05 *** 0.01) ///
		coeflabels(TxA_17_21 "Treatment \times Age 17-21" TxA_22_26 "Treatment \times Age 22-26" ///
		TxA_27_31 "Treatment \times Age 27-31" TxA_32_35 "Treatment \times Age 32-35") ///
		scalars(  "mean \midrule Dependent mean" "Nn \(N\) (MOB $\times$ year)")
		
		
	esttab a* using "$tables_paper/include/paper_hospital2_DD_interaction_agegroups.tex", replace booktabs fragment ///
		keep(TxA*) ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		coeflabels(TxA_17_21 "Treatment $\times$ Age 17-21" TxA_22_26 "Treatment $\times$ Age 22-26" ///
		TxA_27_31 "Treatment $\times$ Age 27-31" TxA_32_35 "Treatment $\times$ Age 32-35") ///
		scalars(  "mean \midrule Dependent mean"  "Nn \(N\) (MOB $\times$ year)")
	
	
	* female
	DDRD_sclrs_X a1 r_fert_hospital2_f "i.MOB i.year" "if $C2 & $all_age"		//6 months BW
	DDRD_sclrs_X a2 r_fert_hospital2_f "i.MOB i.year" "if $C2 & $all_age  & $M5"
	DDRD_sclrs_X a3 r_fert_hospital2_f "i.MOB i.year" "if $C2 & $all_age  & $M4"
	DDRD_sclrs_X a4 r_fert_hospital2_f "i.MOB i.year" "if $C2 & $all_age  & $M3"
	DDRD_sclrs_X a5 r_fert_hospital2_f "i.MOB i.year" "if $C2 & $all_age  & $MD"
	esttab a* ,keep(TxA*) se star(* 0.10 ** 0.05 *** 0.01) ///
		scalars(  "mean \midrule Dependent mean" "Nn \(N\) (MOB $\times$ year)")
		
		
	esttab a* using "$tables_paper/include/paper_hospital2_f_DD_interaction_agegroups.tex", replace booktabs fragment ///
		keep(TxA*) ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		coeflabels(TxA_17_21 "Treatment $\times$ Age 17-21" TxA_22_26 "Treatment $\times$ Age 22-26" ///
		TxA_27_31 "Treatment $\times$ Age 27-31" TxA_32_35 "Treatment $\times$ Age 32-35") ///
		scalars(  "mean \midrule Dependent mean"  "Nn \(N\) (MOB $\times$ year)")
	
	
	* male
	DDRD_sclrs_X a1 r_fert_hospital2_m "i.MOB i.year" "if $C2 & $all_age"		//6 months BW
	DDRD_sclrs_X a2 r_fert_hospital2_m "i.MOB i.year" "if $C2 & $all_age  & $M5"
	DDRD_sclrs_X a3 r_fert_hospital2_m "i.MOB i.year" "if $C2 & $all_age  & $M4"
	DDRD_sclrs_X a4 r_fert_hospital2_m "i.MOB i.year" "if $C2 & $all_age  & $M3"
	DDRD_sclrs_X a5 r_fert_hospital2_m "i.MOB i.year" "if $C2 & $all_age  & $MD"
	esttab a* ,keep(TxA*) se star(* 0.10 ** 0.05 *** 0.01) ///
		scalars(  "mean \midrule Dependent mean" "Nn \(N\) (MOB $\times$ year)")
		
		
	esttab a* using "$tables_paper/include/paper_hospital2_m_DD_interaction_agegroups.tex", replace booktabs fragment ///
		keep(TxA*) ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		coeflabels(TxA_17_21 "Treatment $\times$ Age 17-21" TxA_22_26 "Treatment $\times$ Age 22-26" ///
		TxA_27_31 "Treatment $\times$ Age 27-31" TxA_32_35 "Treatment $\times$ Age 32-35") ///
		scalars(  "mean \midrule Dependent mean"  "Nn \(N\) (MOB $\times$ year)")
	
	

	
	
// d5	************************************************************************
	
	* total
	DDRD_sclrs_X a1 r_fert_d5 "i.MOB i.year" "if $C2 & $all_age"			//6 months BW
	DDRD_sclrs_X a2 r_fert_d5 "i.MOB i.year" "if $C2 & $all_age  & $M5"
	DDRD_sclrs_X a3 r_fert_d5 "i.MOB i.year" "if $C2 & $all_age  & $M4"
	DDRD_sclrs_X a4 r_fert_d5 "i.MOB i.year" "if $C2 & $all_age  & $M3"
	DDRD_sclrs_X a5 r_fert_d5 "i.MOB i.year" "if $C2 & $all_age  & $MD"
	esttab a* ,keep(TxA*) se star(* 0.10 ** 0.05 *** 0.01) ///
		scalars(  "mean \midrule Dependent mean" "Nn \(N\) (MOB $\times$ year)")
		
		
	esttab a* using "$tables_paper/include/paper_d5_DD_interaction_agegroups.tex", replace booktabs fragment ///
			keep(TxA*) ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			scalars(  "mean \midrule Dependent mean"  "Nn \(N\) (MOB $\times$ year)")
	
	
	* female
	DDRD_sclrs_X a1 r_fert_d5_f "i.MOB i.year" "if $C2 & $all_age"		//6 months BW
	DDRD_sclrs_X a2 r_fert_d5_f "i.MOB i.year" "if $C2 & $all_age  & $M5"
	DDRD_sclrs_X a3 r_fert_d5_f "i.MOB i.year" "if $C2 & $all_age  & $M4"
	DDRD_sclrs_X a4 r_fert_d5_f "i.MOB i.year" "if $C2 & $all_age  & $M3"
	DDRD_sclrs_X a5 r_fert_d5_f "i.MOB i.year" "if $C2 & $all_age  & $MD"
	esttab a* ,keep(TxA*) se star(* 0.10 ** 0.05 *** 0.01) ///
		scalars(  "mean \midrule Dependent mean" "Nn \(N\) (MOB $\times$ year)")
		
		
	esttab a* using "$tables_paper/include/paper_d5_f_DD_interaction_agegroups.tex", replace booktabs fragment ///
			keep(TxA*) ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			scalars(  "mean \midrule Dependent mean"  "Nn \(N\) (MOB $\times$ year)")
	
	
	* male
	DDRD_sclrs_X a1 r_fert_d5_m "i.MOB i.year" "if $C2 & $all_age"		//6 months BW
	DDRD_sclrs_X a2 r_fert_d5_m "i.MOB i.year" "if $C2 & $all_age  & $M5"
	DDRD_sclrs_X a3 r_fert_d5_m "i.MOB i.year" "if $C2 & $all_age  & $M4"
	DDRD_sclrs_X a4 r_fert_d5_m "i.MOB i.year" "if $C2 & $all_age  & $M3"
	DDRD_sclrs_X a5 r_fert_d5_m "i.MOB i.year" "if $C2 & $all_age  & $MD"
	esttab a* ,keep(TxA*) se star(* 0.10 ** 0.05 *** 0.01) ///
		scalars(  "mean \midrule Dependent mean" "Nn \(N\) (MOB $\times$ year)")
		
		
	esttab a* using "$tables_paper/include/paper_d5_m_DD_interaction_agegroups.tex", replace booktabs fragment ///
			keep(TxA*) ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			scalars(  "mean \midrule Dependent mean"  "Nn \(N\) (MOB $\times$ year)")	
			
			
			
			
			
			
		
			
			
// *****************************************************************************
* Difference in Regression Discontinuity
// *****************************************************************************				
		
		
		
		
		
* graphs difference in discontinuity *******************************************
	use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"
	keep if GDR == 0
	keep if $C2
	keep if $all_age		
			
	
	
	* reshape
	order treat
	keep MOB_al year_treat treat r_fert_hospital2* r_fert_d5*
	reshape wide r_fert_hospital2* r_fert_d5*, i(MOB_al year_treat) j(treat)
	
	
	
	* average over all years ***************************************************
	foreach var in "hospital2" "d5" {
		preserve
		capture drop delta*
		foreach j in "" "_f" "_m"  {
			* generate difference of different variable specifications
			qui gen delta`j' = r_fert_`var'`j'1 - r_fert_`var'`j'0
		} // end: loop gender
		
		collapse (mean) delta* , by(MOB_al)
		qui gen after = cond(MOB_al>6,1,0) 
			
		*total 
		scatter delta MOB_al, color(black) || ///
			lfitci delta MOB_altern if after == 1, color(black%12) || ///
			lfitci delta MOB_altern if after == 0, color(black%12) ///
			xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) ///
			scheme(s1mono) ///
			xlabel(1(2)12, val) xmtick(2(2)12) ///
			xtitle("") ytitle("") ///
			legend(off) plotregion(color(white))
		graph export "$graph_temp/diff_disc_`var'.pdf", as(pdf) replace
			
		* female
		scatter delta_f MOB_al, color(cranberry) || ///
			lfitci delta_f MOB_altern if after == 1, color(cranberry%12) || ///
			lfitci delta_f MOB_altern if after == 0, color(cranberry%12) ///
			xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) ///
			scheme(s1mono) ///
			xlabel(1(2)12, val) xmtick(2(2)12) ///
			xtitle("") ytitle("") ///
			legend(off) plotregion(color(white))
		graph export "$graph_temp/diff_disc_`var'_f.pdf", as(pdf) replace
		
		* male
		scatter delta_m MOB_al, color(navy) || ///
			lfitci delta_m MOB_altern if after == 1, color(navy%12) || ///
			lfitci delta_m MOB_altern if after == 0, color(navy%12) ///
			xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) ///
			scheme(s1mono) ///
			xlabel(1(2)12, val) xmtick(2(2)12) ///
			xtitle("") ytitle("") ///
			legend(off) plotregion(color(white))
		graph export "$graph_temp/diff_disc_`var'_m.pdf", as(pdf) replace
			
			
		restore	
	} // end: loops vars
	
	
	
********************************************************************************	
// Difference in Regression Discontinuity regression (at least for main specification)	
	use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"
	keep if $C2
	keep if $all_age		
			

	
	
	* variable definition
	qui gen TxA_int1 = Numx 
	qui replace TxA_int1 = 0 if TxA==0
	qui gen TxA_int2 = TxA_int1 * TxA_int1
	qui gen TxA_int3 = TxA_int2 * TxA_int1
	qui gen treat_int1 = Numx 
	qui replace treat_int1 = 0 if treat == 0 
	qui gen treat_int2 = treat_int1 * treat_int1
	qui gen treat_int3 = treat_int2 * treat_int1
	qui gen after_int1 = Numx
	qui replace after_int1 = 0 if after==0
	qui gen after_int2 = after_int1 * after_int1
	qui gen after_int3 = after_int2 * after_int1
	
	

	eststo clear 
	qui eststo a1: reg r_fert_hospital2 TxA Numx after after_int1 treat treat_int1 TxA_int1 , vce(cluster MxY)
	qui eststo a2: reg r_fert_hospital2 TxA Numx after after_int1 treat treat_int1 TxA_int1  if $age_17_21, vce(cluster MxY)
	qui eststo a3: reg r_fert_hospital2 TxA Numx after after_int1 treat treat_int1 TxA_int1  if $age_22_26, vce(cluster MxY)
	qui eststo a4: reg r_fert_hospital2 TxA Numx after after_int1 treat treat_int1 TxA_int1  if $age_27_31, vce(cluster MxY)
	qui eststo a5: reg r_fert_hospital2 TxA Numx after after_int1 treat treat_int1 TxA_int1  if $age_32_35, vce(cluster MxY)
	
	qui eststo b1: reg r_fert_hospital2 TxA Numx after after_int1 treat treat_int1 TxA_int1  if $M5 , vce(cluster MxY)
	qui eststo b2: reg r_fert_hospital2 TxA Numx after after_int1 treat treat_int1 TxA_int1  if $M5 & $age_17_21, vce(cluster MxY)
	qui eststo b3: reg r_fert_hospital2 TxA Numx after after_int1 treat treat_int1 TxA_int1  if $M5 & $age_22_26, vce(cluster MxY)
	qui eststo b4: reg r_fert_hospital2 TxA Numx after after_int1 treat treat_int1 TxA_int1  if $M5 & $age_27_31, vce(cluster MxY)
	qui eststo b5: reg r_fert_hospital2 TxA Numx after after_int1 treat treat_int1 TxA_int1  if $M5 & $age_32_35, vce(cluster MxY)
	
	qui eststo c1: reg r_fert_hospital2 TxA Numx after after_int1 treat treat_int1 TxA_int1  if $M4 , vce(cluster MxY)
	qui eststo c2: reg r_fert_hospital2 TxA Numx after after_int1 treat treat_int1 TxA_int1  if $M4 & $age_17_21, vce(cluster MxY)
	qui eststo c3: reg r_fert_hospital2 TxA Numx after after_int1 treat treat_int1 TxA_int1  if $M4 & $age_22_26, vce(cluster MxY)
	qui eststo c4: reg r_fert_hospital2 TxA Numx after after_int1 treat treat_int1 TxA_int1  if $M4 & $age_27_31, vce(cluster MxY)
	qui eststo c5: reg r_fert_hospital2 TxA Numx after after_int1 treat treat_int1 TxA_int1  if $M4 & $age_32_35, vce(cluster MxY)
	
	
	esttab a*, keep(TxA) se star(* 0.10 ** 0.05 *** 0.01)

	esttab b*, keep(TxA) se star(* 0.10 ** 0.05 *** 0.01)
	
	esttab c*, keep(TxA) se star(* 0.10 ** 0.05 *** 0.01)
	
********************************************************************************
* just RDD
********************************************************************************
	use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"
	keep if GDR == 0
	keep if $C2
	keep if $all_age		
	keep if treat == 1		
	
	
	
	reg r_fert_hospital2 after Numx Num_after if treat==1, vce(cluster MxY)
	* comment: the point estimates of the discontinuities are very similar to 
	* the ones from the Diff-in-Diff, but not significant
	
	
	* RD for different BWs and over age groups
	capture program drop RDD
	program define RDD
		qui eststo `1': reg `2' after Numx Num_after `3' `4', vce(cluster MxY)
	end
	
	
	
	* TODO: pooled, KERNEL WEIGHTING, AUTOMATIC BW choice, POLYNOMIAL on RUNNING VARIABLE
	
	
foreach 1 of varlist hospital2    { // hospital2 d5 
	foreach j in ""  { // "" "_f" "_m" 
		eststo clear 	
		*overall effect
		RDD b1 r_fert_`1'`j'   "" "if $C2 & $all_age"
		RDD b2 r_fert_`1'`j'   "" "if $C2 & $M5 & $all_age"
		RDD b3 r_fert_`1'`j'   "" "if $C2 & $M4 & $all_age"
		esttab b* using "$tables_paper/include/revision_`1'`j'_RDD_overall.tex", replace booktabs fragment ///
			keep(after) coeflabels(after "\hspace*{10pt}Overall") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline   
			
		* effect per age group
		foreach age_group in "$age_17_21" "$age_22_26" "$age_27_31" "$age_32_35" { //
			if "`age_group'" == "$age_17_21" {
				local age_label = "Age 17-21"
				local age_outputname = "17-21"
			}
			if "`age_group'" == "$age_22_26" {
				local age_label = "Age 22-26"
				local age_outputname = "22-26"
			}
			if "`age_group'" == "$age_27_31" {
				local age_label = "Age 27-31"
				local age_outputname = "27-31"
			}
			if "`age_group'" == "$age_32_35" {
				local age_label = "Age 32-35"
				local age_outputname = "32-35"
			}
			eststo clear 
			RDD b1 r_fert_`1'`j'   "" "if `age_group' & $C2"
			RDD b2 r_fert_`1'`j'   "" "if `age_group' & $C2 & $M5"
			RDD b3 r_fert_`1'`j'   "" "if `age_group' & $C2 & $M4"

			esttab b* using "$tables_paper/include/revision_`1'`j'_RDD_`age_outputname'.tex", replace booktabs fragment ///
				keep(after) coeflabels(after "\hspace*{10pt}`age_label'") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label nomtitles nonumbers noobs nonote nogaps noline  
		} // end: agegroup
	} // end: tfm
	// Panels zusammenfassen
	
} //end: varlist
	

	
	
	
	
////////////////////////////////
 // Have RDD and Diff-in-Disc in one Table 
 
	use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"
	keep if GDR == 0
	keep if $C2
	keep if $all_age		
	
	
	
	reg r_fert_hospital2 after Numx Num_after if treat==1, vce(cluster MxY)
	* comment: the point estimates of the discontinuities are very similar to 
	* the ones from the Diff-in-Diff, but not significant
	
	
	* RD for different BWs and over age groups
	capture program drop RDD
	program define RDD
		qui eststo `1': reg `2' after Numx Num_after `3' `4', vce(cluster MxY)
	end
	
	
	
	* variable definition
	qui gen TxA_int1 = Numx 
	qui replace TxA_int1 = 0 if TxA==0
	qui gen TxA_int2 = TxA_int1 * TxA_int1
	qui gen TxA_int3 = TxA_int2 * TxA_int1
	qui gen treat_int1 = Numx 
	qui replace treat_int1 = 0 if treat == 0 
	qui gen treat_int2 = treat_int1 * treat_int1
	qui gen treat_int3 = treat_int2 * treat_int1
	qui gen after_int1 = Numx
	qui replace after_int1 = 0 if after==0
	qui gen after_int2 = after_int1 * after_int1
	qui gen after_int3 = after_int2 * after_int1
	
	
	
foreach 1 of varlist hospital2    { // hospital2 d5 
	foreach j in ""  { // "" "_f" "_m" 
		eststo clear 	
		*overall effect
		RDD b1 r_fert_`1'`j'   "" "if treat == 1 & $all_age"
		
		local iter = 2
		* effect per age group
		foreach age_group in "$age_17_21" "$age_22_26" "$age_27_31" "$age_32_35" { //
			RDD b`iter' r_fert_`1'`j'   "" "if `age_group' & treat == 1"
			local iter = `iter' + 1
		} // end: agegroup		
		esttab b* using "$tables_paper/include/revision_`1'`j'_RDD_DiffDisc_1.tex", replace booktabs fragment ///
			keep(after) coeflabels(after "Estimates") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers nonote nogaps noline   
			
		
		
		eststo clear 
		qui eststo b1: reg r_fert_`1'`j' TxA Numx after after_int1 treat treat_int1 TxA_int1 , vce(cluster MxY)
		qui eststo b2: reg r_fert_`1'`j' TxA Numx after after_int1 treat treat_int1 TxA_int1  if $age_17_21, vce(cluster MxY)
		qui eststo b3: reg r_fert_`1'`j' TxA Numx after after_int1 treat treat_int1 TxA_int1  if $age_22_26, vce(cluster MxY)
		qui eststo b4: reg r_fert_`1'`j' TxA Numx after after_int1 treat treat_int1 TxA_int1  if $age_27_31, vce(cluster MxY)
		qui eststo b5: reg r_fert_`1'`j' TxA Numx after after_int1 treat treat_int1 TxA_int1  if $age_32_35, vce(cluster MxY)
			

			esttab b* using "$tables_paper/include/revision_`1'`j'_RDD_DiffDisc_2.tex", replace booktabs fragment ///
				keep(TxA) coeflabels(TxA "Estimates") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label nomtitles nonumbers nonote nogaps noline  

	} // end: tfm	
} //end: varlist
		
	
	
/*	
foreach 1 of varlist hospital2    { // hospital2 d5 
	foreach j in ""  { // "" "_f" "_m" 
		eststo clear 	
		*overall effect
		RDD b1 r_fert_`1'`j'   "" "if treat == 1 & $all_age"
		qui eststo b2: reg r_fert_`1'`j' TxA Numx after after_int1 treat treat_int1 TxA_int1 , vce(cluster MxY)

		
		esttab b* using "$tables_paper/include/revision_`1'`j'_RDD_Diff_in_Disc_overall.tex", replace booktabs fragment ///
			keep(after) coeflabels(after "\hspace*{10pt}Overall") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline   
			
		* effect per age group
		foreach age_group in "$age_17_21" "$age_22_26" "$age_27_31" "$age_32_35" { //
			if "`age_group'" == "$age_17_21" {
				local age_label = "Age 17-21"
				local age_outputname = "17-21"
			}
			if "`age_group'" == "$age_22_26" {
				local age_label = "Age 22-26"
				local age_outputname = "22-26"
			}
			if "`age_group'" == "$age_27_31" {
				local age_label = "Age 27-31"
				local age_outputname = "27-31"
			}
			if "`age_group'" == "$age_32_35" {
				local age_label = "Age 32-35"
				local age_outputname = "32-35"
			}
			eststo clear 
			RDD b1 r_fert_`1'`j'   "" "if `age_group' & treat == 1"
			qui eststo b2: reg r_fert_`1'`j' TxA Numx after after_int1 treat treat_int1 TxA_int1  if `age_group', vce(cluster MxY)
			

			esttab b* using "$tables_paper/include/revision_`1'`j'_RDD_Diff_in_Disc_`age_outputname'.tex", replace booktabs fragment ///
				keep(after) coeflabels(after "\hspace*{10pt}`age_label'") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label nomtitles nonumbers noobs nonote nogaps noline  
		} // end: agegroup
	} // end: tfm
	// Panels zusammenfassen
	
} //end: varlist
	*/
	
	
	
	
	
	
	
********************************************************************************
// School Entry Effects
********************************************************************************	

/*
NOT USED (just add column w/ M2 in the regular table)

* List of control groups
	global C2    = "(control == 2 | control == 4)"
	global C1_C2 = "control != 3"
	global C1_C3 = "reform == 1"
	
	* Bandwidths (sample selection)
	global M2 = "(Numx >= -2 & Numx <= 2)"
	global M4 = "(Numx >= -4 & Numx <= 4)"
	global M6 = "reform == 1"
	global MD = "(Numx != -1 & Numx != 1)"﻿	
	
use "$temp\KKH_final_R1", clear
run "$auxiliary/varlists_varnames_sample-spcifications"


*define new global for tables ( müssen extra abgespeichert werden) 


capture program drop DDRD
	program define DDRD
		qui eststo `1': reg `2' treat after TxA  `3'  `4', vce(cluster MxY) 
	end
capture program drop DDRD_sclrs
	program define DDRD_sclrs
		qui eststo `1': reg `2' treat after TxA  `3'  `4', vce(cluster MxY) 
		qui estadd scalar Nn = e(N)
		qui sum `2' if e(sample) & treat== 1 & after == 0 
		qui estadd scalar mean = round(`r(mean)',.01)		// pre-reform mean for treated group
		qui estadd scalar sd = abs(round(_b[TxA]/`r(sd)'*100,.01))		
		capture drop Dinregression sum_num_diag*
		qui gen Dinregression = 1 if cond(e(sample),1,0)
		bys Dinregression: egen sum_num_diagnoses = total(`2')
		qui summ sum_num_diagnoses if e(sample)
		qui estadd scalar num_diag = `r(mean)'
	end		
	
	

foreach 1 of varlist hospital2  d5  { // hospital2 d5 
	foreach j in "" "_f" "_m" { // "" "_f" "_m" 
		eststo clear 	
		*overall effect
		DDRD_sclrs b1 r_fert_`1'`j'   "i.MOB i.year" "if $C2 & $all_age"
		DDRD_sclrs b2 r_fert_`1'`j'   "i.MOB i.year" "if $C2 & $M5 & $all_age"
		DDRD_sclrs b3 r_fert_`1'`j'   "i.MOB i.year" "if $C2 & $M4 & $all_age"
		DDRD_sclrs b4 r_fert_`1'`j'   "i.MOB i.year" "if $C2 & $M3 & $all_age"
		DDRD_sclrs b5 r_fert_`1'`j'   "i.MOB i.year" "if $C2 & $M2 & $all_age"
		DDRD_sclrs b6 r_fert_`1'`j'   "i.MOB i.year" "if $C2 & $MD & $all_age"
		esttab b* using "$tables_paper/include/paper_`1'`j'_DD_overall_incl2m.tex", replace booktabs fragment ///
			keep(TxA) coeflabels(TxA "\hspace*{10pt}Overall") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			scalars(  "mean \midrule Dependent mean" "sd Effect in SDs [\%]" "Nn \(N\) (MOB $\times$ year)")  
			
		* effect per age group
		foreach age_group in "$age_17_21" "$age_22_26" "$age_27_31" "$age_32_35" { //
			if "`age_group'" == "$age_17_21" {
				local age_label = "Age 17-21"
				local age_outputname = "17-21"
			}
			if "`age_group'" == "$age_22_26" {
				local age_label = "Age 22-26"
				local age_outputname = "22-26"
			}
			if "`age_group'" == "$age_27_31" {
				local age_label = "Age 27-31"
				local age_outputname = "27-31"
			}
			if "`age_group'" == "$age_32_35" {
				local age_label = "Age 32-35"
				local age_outputname = "32-35"
			}
			eststo clear 
			DDRD b1 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & $C2"
			DDRD b2 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & $C2 & $M5"
			DDRD b3 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & $C2 & $M4"
			DDRD b4 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & $C2 & $M3"
			DDRD b5 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & $C2 & $M2"
			DDRD b6 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & $C2 & $MD"
			esttab b* using "$tables_paper/include/paper_`1'`j'_DD_`age_outputname'_incl2m.tex", replace booktabs fragment ///
				keep(TxA) coeflabels(TxA "\hspace*{10pt}`age_label'") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label nomtitles nonumbers noobs nonote nogaps noline  
		} // end: agegroup
	} // end: tfm
	// Panels zusammenfassen
	
} //end: varlist
*/	
	
	
	
	
	
********************************************************************************	
// Vary BW on the left and keep on the right constant	
	use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"	
	keep if $C2 & $all_age
	
	drop if MOB >= 7 & MOB <= 10
	
	
	capture program drop DDRD_sclrs
	program define DDRD_sclrs
		qui eststo `1': reg `2' treat after TxA  `3'  `4', vce(cluster MxY) 
		qui estadd scalar Nn = e(N)
	end	
	
	

foreach 1 of varlist hospital2   { // hospital2 d5 
	foreach j in "" "_f" "_m"  { // "" "_f" "_m" 
	
		eststo clear 	
			*overall effect
			DDRD_sclrs b1 r_fert_`1'`j'   "i.MOB i.year" "if $C2"
			DDRD_sclrs b2 r_fert_`1'`j'   "i.MOB i.year" "if $C2 & $M5"
			DDRD_sclrs b3 r_fert_`1'`j'   "i.MOB i.year" "if $C2 & $M4"
			DDRD_sclrs b4 r_fert_`1'`j'   "i.MOB i.year" "if $C2 & $M3"
			DDRD_sclrs b5 r_fert_`1'`j'   "i.MOB i.year" "if $C2 & $M2"
			
		esttab b* ,keep(TxA) coeflabels(TxA "Overall") star(* 0.10 ** 0.05 *** 0.01) se label 
				
				
		esttab b* using "$tables_paper/include/paper_`1'`j'_DD_overall_school_cutoffs.tex", /// 
				replace booktabs fragment ///
				keep(TxA) coeflabels(TxA "Overall") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label nomtitles nonumbers noobs nonote nogaps noline 
	
		foreach age_group in "$age_17_21" "$age_22_26" "$age_27_31" "$age_32_35" { //
			if "`age_group'" == "$age_17_21" {
				local age_label = "Age 17-21"
				local age_outputname = "17-21"
			}
			if "`age_group'" == "$age_22_26" {
				local age_label = "Age 22-26"
				local age_outputname = "22-26"
			}
			if "`age_group'" == "$age_27_31" {
				local age_label = "Age 27-31"
				local age_outputname = "27-31"
			}
			if "`age_group'" == "$age_32_35" {
				local age_label = "Age 32-35"
				local age_outputname = "32-35"
			}
			eststo clear 	
			*overall effect
			DDRD_sclrs b1 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & $C2"
			DDRD_sclrs b2 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & $C2 & $M5"
			DDRD_sclrs b3 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & $C2 & $M4"
			DDRD_sclrs b4 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & $C2 & $M3"
			DDRD_sclrs b5 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & $C2 & $M2"
			
			*esttab b* , ///
				keep(TxA) coeflabels(TxA "`age_label'") ///
				star(* 0.10 ** 0.05 *** 0.01) se ///
				label 
				
				
			esttab b* using "$tables_paper/include/paper_`1'`j'_DD_`age_outputname'_school_cutoffs.tex",replace booktabs fragment ///
				keep(TxA) coeflabels(TxA "\hspace*{10pt}`age_label'") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label nomtitles nonumbers noobs nonote nogaps noline  
		} // end: loop age group
	} // end: loop gender spec
} // end: lopp variable









* graphical representation
	use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"	
	keep if $C2 & $all_age

	qui gen d_drop_obs = cond( MOB >= 7 & MOB <= 10, 1,0)
		
	
	capture program drop DDRD_sclrs
	program define DDRD_sclrs
		qui eststo `1': reg `2' treat after TxA  `3'  `4', vce(cluster MxY) 
		qui estadd scalar Nn = e(N)
	end	



foreach 1 of varlist hospital2   { // hospital2 d5 
	foreach j in "" "_f" "_m"    { // "" "_f" "_m" 
	
		*generate empty table and append in other steps
		DDRD_sclrs b1 r_fert_`1'`j'   "i.MOB i.year" "if d_drop_obs == 0"
		DDRD_sclrs b2 r_fert_`1'`j'   "i.MOB i.year" "if d_drop_obs == 0 & $M5"
		DDRD_sclrs b3 r_fert_`1'`j'   "i.MOB i.year" "if d_drop_obs == 0 & $M4"
		DDRD_sclrs b4 r_fert_`1'`j'   "i.MOB i.year" "if d_drop_obs == 0 & $M3"
		DDRD_sclrs b5 r_fert_`1'`j'   "i.MOB i.year" "if d_drop_obs == 0 & $M2"
		DDRD_sclrs b6 r_fert_`1'`j'   "i.MOB i.year" ""		
		
		esttab b* using "$temp/school_entry_small_BW_`1'`j'.csv", replace ///
				keep(TxA) coeflabels(TxA "Pooled") ///
				nostar se ///
				label  wide nomtitles nonumbers noobs nonote nogaps noline noparen
	
		foreach age_group in "$age_17_21" "$age_22_26" "$age_27_31" "$age_32_35" { //
			if "`age_group'" == "$age_17_21" {
				local age_label = "Age 17-21"
				local age_outputname = "17-21"
			}
			if "`age_group'" == "$age_22_26" {
				local age_label = "Age 22-26"
				local age_outputname = "22-26"
			}
			if "`age_group'" == "$age_27_31" {
				local age_label = "Age 27-31"
				local age_outputname = "27-31"
			}
			if "`age_group'" == "$age_32_35" {
				local age_label = "Age 32-35"
				local age_outputname = "32-35"
			}
			eststo clear 	
			*overall effect
			DDRD_sclrs b1 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & d_drop_obs == 0"
			DDRD_sclrs b2 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & d_drop_obs == 0 & $M5"
			DDRD_sclrs b3 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & d_drop_obs == 0 & $M4"
			DDRD_sclrs b4 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & d_drop_obs == 0 & $M3"
			DDRD_sclrs b5 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & d_drop_obs == 0 & $M2"
			DDRD_sclrs b6 r_fert_`1'`j'   "i.MOB i.year" "if `age_group'"
			
				
			esttab b* using "$temp/school_entry_small_BW_`1'`j'.csv", append ///
				keep(TxA) coeflabels(TxA "`age_label'") ///
				nostar se ///
				label wide nomtitles nonumbers noobs nonote nogaps noline noparen	
			
		} // end: loop age group
	} // end: loop gender spec
} // end: lopp variable


* import total 
	import delimited "$temp/school_entry_small_BW_hospital2", varnames(nonames) stripquote(yes) encoding(Big5) clear
	
	rename v1  age
	rename v2  beta_6m
	rename v3  sterr_6m
	rename v4  beta_5m
	rename v5  sterr_5m
	rename v6  beta_4m
	rename v7  sterr_4m
	rename v8  beta_3m
	rename v9  sterr_3m
	rename v10 beta_2m
	rename v11 sterr_2m
	rename v12 beta_baseline
	rename v13 sterr_baseline
	
	* strip away equal sign
	foreach var of varlist age beta* sterr* {
			qui replace `var' = substr(`var',2,.)
		}
		
	qui destring *, replace	
	qui reshape long beta sterr, i(age) j(temp) str
		
	qui gen CI_l = beta - $t_95 * sterr
	qui gen CI_h = beta + $t_95 * sterr
	
	
	* categorical vars for bws
	qui gen bw = 0 if temp == "_baseline"
	qui replace bw = 1 if temp == "_6m"
	qui replace bw = 2 if temp == "_5m"
	qui replace bw = 3 if temp == "_4m"
	qui replace bw = 4 if temp == "_3m"
	qui replace bw = 5 if temp == "_2m"
	
	label define BW 0 "Baseline" 1 "Nov-Apr" 2 "Dec-Apr" 3 "Jan-Apr" 4 "Feb-Apr" 5 "Mar-Apr"
	label values bw BW
	drop temp
	

	foreach age_group in "17-21"  {	
		scatter beta bw if age == "Age `age_group'", color(black) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'", color(black) || ///
			scatter beta bw if age == "Age `age_group'" & bw == 0, color(forest_green) m(O) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'" & bw == 0, color(forest_green)  ///
			xscale(r(-1,6))  yline(0, lpattern(dash)) ///
			legend(off) ///
			scheme(s1mono) plotregion(color(white)) ///
			xlabel(,val angle(22.5)) ///
			xtitle("") ytitle("Total",box bexpand size(large)) title("Age `age_group'", box bexpand) nodraw /// 
			saving($graphs/hospital2_school_entry_small_bw_`age_group', replace)
		*graph export "$graph_paper/hospital2_school_entry_small_bw_`age_group'.pdf", as(pdf) replace
	}
		
	foreach age_group in "22-26" "27-31" "32-35" {	
		scatter beta bw if age == "Age `age_group'", color(black) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'", color(black) || ///
			scatter beta bw if age == "Age `age_group'" & bw == 0, color(forest_green) m(O) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'" & bw == 0, color(forest_green)  ///
			xscale(r(-1,6))  yline(0, lpattern(dash)) ///
			legend(off) ///
			scheme(s1mono) plotregion(color(white)) ///
			xlabel(,val angle(22.5)) ///
			xtitle("")  title("Age `age_group'", box bexpand) nodraw  /// 
			saving($graphs/hospital2_school_entry_small_bw_`age_group', replace)
		*graph export "$graph_paper/hospital2_school_entry_small_bw_`age_group'.pdf", as(pdf) replace
	}
	
	
	/*
	scatter beta bw if age == "Pooled", color(black) || ///
		rspike CI_h CI_l bw if age == "Pooled", color(black) || ///
		scatter beta bw if age == "Pooled" & bw == 0, color(forest_green) m(O) || ///
		rspike CI_h CI_l bw if age == "Pooled" & bw == 0, color(forest_green)  ///
		xscale(r(-1,6)) ylabel(-6 (2) 4) yscale(r(-8,6)) yline(0, lpattern(dash)) ///
		legend(off) ///
		scheme(s1mono) plotregion(color(white)) ///
		xlabel(,val) ///
		xtitle("") title("Pooled") 
	graph export "$graph_paper/hospital2_school_entry_small_bw_pooled.pdf", as(pdf) replace
	*/
	
	
	
	* female
	import delimited "$temp/school_entry_small_BW_hospital2_f", varnames(nonames) stripquote(yes) encoding(Big5) clear
	
	rename v1  age
	rename v2  beta_6m
	rename v3  sterr_6m
	rename v4  beta_5m
	rename v5  sterr_5m
	rename v6  beta_4m
	rename v7  sterr_4m
	rename v8  beta_3m
	rename v9  sterr_3m
	rename v10 beta_2m
	rename v11 sterr_2m
	rename v12 beta_baseline
	rename v13 sterr_baseline
	
	*drop if _n == 1
	* strip away equal sign
	foreach var of varlist age beta* sterr* {
			qui replace `var' = substr(`var',2,.)
		}
		
	qui destring *, replace	
	qui reshape long beta sterr, i(age) j(temp) str
		
	qui gen CI_l = beta - $t_95 * sterr
	qui gen CI_h = beta + $t_95 * sterr
	
	
	* categorical vars for bws
	qui gen bw = 0 if temp == "_baseline"
	qui replace bw = 1 if temp == "_6m"
	qui replace bw = 2 if temp == "_5m"
	qui replace bw = 3 if temp == "_4m"
	qui replace bw = 4 if temp == "_3m"
	qui replace bw = 5 if temp == "_2m"
	
	label define BW 0 "Baseline" 1 "Nov-Apr" 2 "Dec-Apr" 3 "Jan-Apr" 4 "Feb-Apr" 5 "Mar-Apr"
	label values bw BW
	drop temp
	
	foreach age_group in "17-21"  {	
		scatter beta bw if age == "Age `age_group'", color(cranberry) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'", color(cranberry) || ///
			scatter beta bw if age == "Age `age_group'" & bw == 0, color(forest_green) m(O) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'" & bw == 0, color(forest_green)  ///
			xscale(r(-1,6)) yline(0, lpattern(dash)) ///
			legend(off) ///
			scheme(s1mono) plotregion(color(white)) ///
			xlabel(,val angle(22.5)) ///
			xtitle("")  ytitle("Female",box bexpand size(large)) nodraw /// 
			saving($graphs/hospital2_f_school_entry_small_bw_`age_group', replace)
	}
	
	
	foreach age_group in  "22-26" "27-31" "32-35" {	
		scatter beta bw if age == "Age `age_group'", color(cranberry) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'", color(cranberry) || ///
			scatter beta bw if age == "Age `age_group'" & bw == 0, color(forest_green) m(O) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'" & bw == 0, color(forest_green)  ///
			xscale(r(-1,6)) yline(0, lpattern(dash)) ///
			legend(off) ///
			scheme(s1mono) plotregion(color(white)) ///
			xlabel(,val angle(22.5)) ///
			xtitle("") nodraw  /// 
			saving($graphs/hospital2_f_school_entry_small_bw_`age_group', replace)
	}
	
	
	
	* male
	import delimited "$temp/school_entry_small_BW_hospital2_m", varnames(nonames) stripquote(yes) encoding(Big5) clear
	
	rename v1  age
	rename v2  beta_6m
	rename v3  sterr_6m
	rename v4  beta_5m
	rename v5  sterr_5m
	rename v6  beta_4m
	rename v7  sterr_4m
	rename v8  beta_3m
	rename v9  sterr_3m
	rename v10 beta_2m
	rename v11 sterr_2m
	rename v12 beta_baseline
	rename v13 sterr_baseline
	
	drop if _n == 1
	* strip away equal sign
	foreach var of varlist age beta* sterr* {
			qui replace `var' = substr(`var',2,.)
		}
		
	qui destring *, replace	
	qui reshape long beta sterr, i(age) j(temp) str
		
	qui gen CI_l = beta - $t_95 * sterr
	qui gen CI_h = beta + $t_95 * sterr
	
	
	* categorical vars for bws
	qui gen bw = 0 if temp == "_baseline"
	qui replace bw = 1 if temp == "_6m"
	qui replace bw = 2 if temp == "_5m"
	qui replace bw = 3 if temp == "_4m"
	qui replace bw = 4 if temp == "_3m"
	qui replace bw = 5 if temp == "_2m"
	
	label define BW 0 "Baseline" 1 "Nov-Apr" 2 "Dec-Apr" 3 "Jan-Apr" 4 "Feb-Apr" 5 "Mar-Apr"
	label values bw BW
	drop temp
	
	foreach age_group in "17-21"  {	
		scatter beta bw if age == "Age `age_group'", color(navy) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'", color(navy) || ///
			scatter beta bw if age == "Age `age_group'" & bw == 0, color(forest_green) m(O) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'" & bw == 0, color(forest_green)  ///
			xscale(r(-1,6)) yline(0, lpattern(dash)) ///
			legend(off) ///
			scheme(s1mono) plotregion(color(white)) ///
			xlabel(,val angle(22.5)) ///
			xtitle("") ytitle("Male",box bexpand size(large)) nodraw /// 
			saving($graphs/hospital2_m_school_entry_small_bw_`age_group', replace)
	}
	
	foreach age_group in  "22-26" "27-31" "32-35" {	
		scatter beta bw if age == "Age `age_group'", color(navy) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'", color(navy) || ///
			scatter beta bw if age == "Age `age_group'" & bw == 0, color(forest_green) m(O) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'" & bw == 0, color(forest_green)  ///
			xscale(r(-1,6)) yline(0, lpattern(dash)) ///
			legend(off) ///
			scheme(s1mono) plotregion(color(white)) ///
			xlabel(,val angle(22.5)) ///
			xtitle("") nodraw  /// 
			saving($graphs/hospital2_m_school_entry_small_bw_`age_group', replace)
	}
		
		
	
	
	
	
	
	cd $graphs
	/*graph combine ///
		"$graphs/hospital2_school_entry_small_bw_17-21.gph" ///
		"$graphs/hospital2_school_entry_small_bw_22-26.gph" ///
		"$graphs/hospital2_school_entry_small_bw_27-31.gph" ///
		"$graphs/hospital2_school_entry_small_bw_32-35.gph", ///
		scheme(s1mono) plotregion(color(white)) xsize(11) ysize(8) col(2)
		*/
	
	
	graph combine ///
		"$graphs/hospital2_school_entry_small_bw_17-21.gph" ///
		"$graphs/hospital2_school_entry_small_bw_22-26.gph" ///
		"$graphs/hospital2_school_entry_small_bw_27-31.gph" ///
		"$graphs/hospital2_school_entry_small_bw_32-35.gph" ///
		///
		"$graphs/hospital2_f_school_entry_small_bw_17-21.gph" ///
		"$graphs/hospital2_f_school_entry_small_bw_22-26.gph" ///
		"$graphs/hospital2_f_school_entry_small_bw_27-31.gph" ///
		"$graphs/hospital2_f_school_entry_small_bw_32-35.gph" ///
		///
		"$graphs/hospital2_m_school_entry_small_bw_17-21.gph" ///
		"$graphs/hospital2_m_school_entry_small_bw_22-26.gph" ///
		"$graphs/hospital2_m_school_entry_small_bw_27-31.gph" ///
		"$graphs/hospital2_m_school_entry_small_bw_32-35.gph", ///
		scheme(s1mono) plotregion(color(white)) xsize(22) ysize(12) col(4) ///
		ycommon 
	graph export "$graph_paper/hospital2_school_entry_small_bw_overview.pdf", as(pdf) replace
	
	
	
	
********************************************************************************
// OTHER CONTROL GROUP, various bandwidths
********************************************************************************			
	
	
	use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"	
	global C1_C2 = "control != 3"
	keep if $C1_C2 & $all_age
	
	
	capture program drop DDRD_sclrs
	program define DDRD_sclrs
		qui eststo `1': reg `2' treat after TxA  `3'  `4', vce(cluster MxY) 
	end	

	
	
	eststo clear
	*total 
	DDRD_sclrs b1 r_fert_hospital2 "i.MOB i.year" ""
	DDRD_sclrs b2 r_fert_hospital2 "i.MOB i.year" "if $M5"
	DDRD_sclrs b3 r_fert_hospital2 "i.MOB i.year" "if $M4"
	DDRD_sclrs b4 r_fert_hospital2 "i.MOB i.year" "if $M3"
	DDRD_sclrs b5 r_fert_hospital2 "i.MOB i.year" "if $MD"
	
	esttab b*,	keep(TxA) star(* 0.10 ** 0.05 *** 0.01) se label 
	esttab b* using "$tables_paper/include/paper_hospital2_addcg_different_bws.tex",replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Overall") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline 
		
	
	*female 
	DDRD_sclrs c1 r_fert_hospital2_f "i.MOB i.year" ""
	DDRD_sclrs c2 r_fert_hospital2_f "i.MOB i.year" "if $M5"
	DDRD_sclrs c3 r_fert_hospital2_f "i.MOB i.year" "if $M4"
	DDRD_sclrs c4 r_fert_hospital2_f "i.MOB i.year" "if $M3"
	DDRD_sclrs c5 r_fert_hospital2_f "i.MOB i.year" "if $MD"
	
	esttab c* ,	keep(TxA) star(* 0.10 ** 0.05 *** 0.01) se label
	esttab c* using "$tables_paper/include/paper_hospital2_addcg_different_bws_female.tex",replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Overall") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	
	
	*female 
	DDRD_sclrs a1 r_fert_hospital2_m "i.MOB i.year" ""
	DDRD_sclrs a2 r_fert_hospital2_m "i.MOB i.year" "if $M5"
	DDRD_sclrs a3 r_fert_hospital2_m "i.MOB i.year" "if $M4"
	DDRD_sclrs a4 r_fert_hospital2_m "i.MOB i.year" "if $M3"
	DDRD_sclrs a5 r_fert_hospital2_m "i.MOB i.year" "if $MD"
	
	esttab a* ,	keep(TxA) star(* 0.10 ** 0.05 *** 0.01) se label
	esttab a* using "$tables_paper/include/paper_hospital2_addcg_different_bws_male.tex",replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Overall") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
				
				
				
	// Age bracktes: graphical representation
	
	foreach 1 of varlist hospital2   { // hospital2 d5 
		foreach j in  "" "_f" "_m"     { // "" "_f" "_m" 
		
			*generate empty table and append in other steps
			DDRD_sclrs b1 r_fert_`1'`j'   "i.MOB i.year" ""
			DDRD_sclrs b2 r_fert_`1'`j'   "i.MOB i.year" "if $M5"
			DDRD_sclrs b3 r_fert_`1'`j'   "i.MOB i.year" "if $M4"
			DDRD_sclrs b4 r_fert_`1'`j'   "i.MOB i.year" "if $M3"
			DDRD_sclrs b5 r_fert_`1'`j'   "i.MOB i.year" "if $MD"
			DDRD_sclrs b6 r_fert_`1'`j'   "i.MOB i.year" "if $C2"	
			
			esttab b* using "$temp/addcg_different_bws_`1'`j'.csv", replace ///
					keep(TxA) coeflabels(TxA "Pooled") ///
					nostar se ///
					label  wide nomtitles nonumbers noobs nonote nogaps noline noparen
		
			foreach age_group in "$age_17_21" "$age_22_26" "$age_27_31" "$age_32_35" { //
				if "`age_group'" == "$age_17_21" {
					local age_label = "Age 17-21"
					local age_outputname = "17-21"
				}
				if "`age_group'" == "$age_22_26" {
					local age_label = "Age 22-26"
					local age_outputname = "22-26"
				}
				if "`age_group'" == "$age_27_31" {
					local age_label = "Age 27-31"
					local age_outputname = "27-31"
				}
				if "`age_group'" == "$age_32_35" {
					local age_label = "Age 32-35"
					local age_outputname = "32-35"
				}
				eststo clear 	
				*overall effect
				DDRD_sclrs b1 r_fert_`1'`j'   "i.MOB i.year" "if `age_group'"
				DDRD_sclrs b2 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & $M5"
				DDRD_sclrs b3 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & $M4"
				DDRD_sclrs b4 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & $M3"
				DDRD_sclrs b5 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & $MD"
				DDRD_sclrs b6 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & $C2"
				
					
				esttab b* using "$temp/addcg_different_bws_`1'`j'.csv", append ///
					keep(TxA) coeflabels(TxA "`age_label'") ///
					nostar se ///
					label wide nomtitles nonumbers noobs nonote nogaps noline noparen	
				
			} // end: loop age group
		} // end: loop gender spec
	} // end: lopp variable
	

* import total 
	import delimited "$temp/addcg_different_bws_hospital2", varnames(nonames) stripquote(yes) encoding(Big5) clear
	
	rename v1  age
	rename v2  beta_6m
	rename v3  sterr_6m
	rename v4  beta_5m
	rename v5  sterr_5m
	rename v6  beta_4m
	rename v7  sterr_4m
	rename v8  beta_3m
	rename v9  sterr_3m
	rename v10 beta_donut
	rename v11 sterr_donut
	rename v12 beta_baseline
	rename v13 sterr_baseline
	
	* strip away equal sign
	foreach var of varlist age beta* sterr* {
			qui replace `var' = substr(`var',2,.)
		}
		
	qui destring *, replace	
	qui reshape long beta sterr, i(age) j(temp) str
		
	qui gen CI_l = beta - $t_95 * sterr
	qui gen CI_h = beta + $t_95 * sterr
	
	
	* categorical vars for bws
	qui gen bw = 0 if temp == "_baseline"
	qui replace bw = 1 if temp == "_6m"
	qui replace bw = 2 if temp == "_5m"
	qui replace bw = 3 if temp == "_4m"
	qui replace bw = 4 if temp == "_3m"
	qui replace bw = 5 if temp == "_donut"
	
	label define BW 0 "Baseline" 1 "6M" 2 "5M" 3 "4M" 4 "3M" 5 "Donut"
	label values bw BW
	drop temp
		
	foreach age_group in "17-21"  {	
		scatter beta bw if age == "Age `age_group'", color(black) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'", color(black) || ///
			scatter beta bw if age == "Age `age_group'" & bw == 0, color(forest_green) m(O) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'" & bw == 0, color(forest_green)  ///
			xscale(r(-1,6)) ylabel(-8 (4) 2) yscale(r(-13.1,6.7)) ymtick(-10 (4) 2) yline(0, lpattern(dash)) ///
			legend(off) ///
			scheme(s1mono) plotregion(color(white)) ///
			xlabel(,val) ///
			xtitle("") ytitle("Total",box bexpand size(large)) title("Age `age_group'", box bexpand)  /// 
			saving($graphs/hospital2_addcg_different_bws_`age_group', replace)
		*graph export "$graph_paper/hospital2_addcg_different_bws_`age_group'.pdf", as(pdf) replace
	}
	
	foreach age_group in  "22-26" "27-31" "32-35" {	
		scatter beta bw if age == "Age `age_group'", color(black) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'", color(black) || ///
			scatter beta bw if age == "Age `age_group'" & bw == 0, color(forest_green) m(O) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'" & bw == 0, color(forest_green)  ///
			xscale(r(-1,6)) ylabel(-8 (4) 2) yscale(r(-13.1,6.7)) ymtick(-10 (4) 2) yline(0, lpattern(dash)) ///
			legend(off) ///
			scheme(s1mono) plotregion(color(white)) ///
			xlabel(,val) ///
			xtitle("") title("Age `age_group'", box bexpand)  /// 
			saving($graphs/hospital2_addcg_different_bws_`age_group', replace)
		*graph export "$graph_paper/hospital2_addcg_different_bws_`age_group'.pdf", as(pdf) replace
	}	


	* import female 
	import delimited "$temp/addcg_different_bws_hospital2_f", varnames(nonames) stripquote(yes) encoding(Big5) clear
	
	rename v1  age
	rename v2  beta_6m
	rename v3  sterr_6m
	rename v4  beta_5m
	rename v5  sterr_5m
	rename v6  beta_4m
	rename v7  sterr_4m
	rename v8  beta_3m
	rename v9  sterr_3m
	rename v10 beta_donut
	rename v11 sterr_donut
	rename v12 beta_baseline
	rename v13 sterr_baseline
	
	* strip away equal sign
	foreach var of varlist age beta* sterr* {
			qui replace `var' = substr(`var',2,.)
		}
		
	qui destring *, replace	
	qui reshape long beta sterr, i(age) j(temp) str
		
	qui gen CI_l = beta - $t_95 * sterr
	qui gen CI_h = beta + $t_95 * sterr
	
	
	* categorical vars for bws
	qui gen bw = 0 if temp == "_baseline"
	qui replace bw = 1 if temp == "_6m"
	qui replace bw = 2 if temp == "_5m"
	qui replace bw = 3 if temp == "_4m"
	qui replace bw = 4 if temp == "_3m"
	qui replace bw = 5 if temp == "_donut"
	
	label define BW 0 "Baseline" 1 "6M" 2 "5M" 3 "4M" 4 "3M" 5 "Donut"
	label values bw BW
	drop temp
		
	foreach age_group in "17-21"  {	
		scatter beta bw if age == "Age `age_group'", color(cranberry) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'", color(cranberry) || ///
			scatter beta bw if age == "Age `age_group'" & bw == 0, color(forest_green) m(O) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'" & bw == 0, color(forest_green)  ///
			xscale(r(-1,6)) ylabel(-8 (4) 2) yscale(r(-13.1,6.7)) ymtick(-10 (4) 2) yline(0, lpattern(dash)) ///
			legend(off) ///
			scheme(s1mono) plotregion(color(white)) ///
			xlabel(,val) ///
			xtitle("") ytitle("Female",box bexpand size(large))  /// 
			saving($graphs/hospital2_f_addcg_different_bws_`age_group', replace)
	}	
	
	foreach age_group in  "22-26" "27-31" "32-35" {	
		scatter beta bw if age == "Age `age_group'", color(cranberry) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'", color(cranberry) || ///
			scatter beta bw if age == "Age `age_group'" & bw == 0, color(forest_green) m(O) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'" & bw == 0, color(forest_green)  ///
			xscale(r(-1,6)) ylabel(-8 (4) 2) yscale(r(-13.1,6.7)) ymtick(-10 (4) 2) yline(0, lpattern(dash)) ///
			legend(off) ///
			scheme(s1mono) plotregion(color(white)) ///
			xlabel(,val) ///
			xtitle("")  /// 
			saving($graphs/hospital2_f_addcg_different_bws_`age_group', replace)
		*graph export "$graph_paper/hospital2_f_addcg_different_bws_`age_group'.pdf", as(pdf) replace
	}	


	* import male 
	import delimited "$temp/addcg_different_bws_hospital2_m", varnames(nonames) stripquote(yes) encoding(Big5) clear
	
	rename v1  age
	rename v2  beta_6m
	rename v3  sterr_6m
	rename v4  beta_5m
	rename v5  sterr_5m
	rename v6  beta_4m
	rename v7  sterr_4m
	rename v8  beta_3m
	rename v9  sterr_3m
	rename v10 beta_donut
	rename v11 sterr_donut
	rename v12 beta_baseline
	rename v13 sterr_baseline
	
	* strip away equal sign
	foreach var of varlist age beta* sterr* {
			qui replace `var' = substr(`var',2,.)
		}
		
	qui destring *, replace	
	qui reshape long beta sterr, i(age) j(temp) str
		
	qui gen CI_l = beta - $t_95 * sterr
	qui gen CI_h = beta + $t_95 * sterr
	
	
	* categorical vars for bws
	qui gen bw = 0 if temp == "_baseline"
	qui replace bw = 1 if temp == "_6m"
	qui replace bw = 2 if temp == "_5m"
	qui replace bw = 3 if temp == "_4m"
	qui replace bw = 4 if temp == "_3m"
	qui replace bw = 5 if temp == "_donut"
	
	label define BW 0 "Baseline" 1 "6M" 2 "5M" 3 "4M" 4 "3M" 5 "Donut"
	label values bw BW
	drop temp
		
	foreach age_group in "17-21" {	
		scatter beta bw if age == "Age `age_group'", color(navy) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'", color(navy) || ///
			scatter beta bw if age == "Age `age_group'" & bw == 0, color(forest_green) m(O) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'" & bw == 0, color(forest_green)  ///
			xscale(r(-1,6)) ylabel(-8 (4) 2) yscale(r(-13.1,6.7)) ymtick(-10 (4) 2) yline(0, lpattern(dash)) ///
			legend(off) ///
			scheme(s1mono) plotregion(color(white)) ///
			xlabel(,val) ///
			xtitle("") ytitle("Male",box bexpand size(large))   /// 
			saving($graphs/hospital2_m_addcg_different_bws_`age_group', replace)
		*graph export "$graph_paper/hospital2_m_addcg_different_bws_`age_group'.pdf", as(pdf) replace
	}
	
	foreach age_group in  "22-26" "27-31" "32-35" {	
		scatter beta bw if age == "Age `age_group'", color(navy) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'", color(navy) || ///
			scatter beta bw if age == "Age `age_group'" & bw == 0, color(forest_green) m(O) || ///
			rspike CI_h CI_l bw if age == "Age `age_group'" & bw == 0, color(forest_green)  ///
			xscale(r(-1,6)) ylabel(-8 (4) 2) yscale(r(-13.1,6.7)) ymtick(-10 (4) 2) yline(0, lpattern(dash)) ///
			legend(off) ///
			scheme(s1mono) plotregion(color(white)) ///
			xlabel(,val) ///
			xtitle("")   /// 
			saving($graphs/hospital2_m_addcg_different_bws_`age_group', replace)
		*graph export "$graph_paper/hospital2_m_addcg_different_bws_`age_group'.pdf", as(pdf) replace
	}
			
			
	graph combine ///
		"$graphs/hospital2_addcg_different_bws_17-21.gph" ///
		"$graphs/hospital2_addcg_different_bws_22-26.gph" ///
		"$graphs/hospital2_addcg_different_bws_27-31.gph" ///
		"$graphs/hospital2_addcg_different_bws_32-35.gph" ///
		"$graphs/hospital2_f_addcg_different_bws_17-21.gph" ///
		"$graphs/hospital2_f_addcg_different_bws_22-26.gph" ///
		"$graphs/hospital2_f_addcg_different_bws_27-31.gph" ///
		"$graphs/hospital2_f_addcg_different_bws_32-35.gph" ///
		"$graphs/hospital2_m_addcg_different_bws_17-21.gph" ///
		"$graphs/hospital2_m_addcg_different_bws_22-26.gph" ///
		"$graphs/hospital2_m_addcg_different_bws_27-31.gph" ///
		"$graphs/hospital2_m_addcg_different_bws_32-35.gph", ///
		scheme(s1mono) plotregion(color(white)) xsize(22) ysize(12) col(4) ///
		ycommon  imargin(zero)
	graph export "$graph_paper/hospital2_addcg_different_bws_overview.pdf", as(pdf) replace
			
			
			
********************************************************************************
// level of aggregation
********************************************************************************		
			
* this is basically the life course approach - make it in Table format

	
	use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"	

capture program drop DDRD_sclrs
	program define DDRD_sclrs
		qui eststo `1': reg `2' treat after TxA  `3'  `4', vce(cluster MxY)
		qui estadd scalar Nn = e(N)
	end	

	
eststo clear
foreach 1 in "hospital2" "d5" {
	foreach j in "" "_f" "_m" {
		qui summ year_treat if !missing(r_fert_`1') & treat == 1
		local start = r(min) + 1
		local ende = r(max)
		
		local age = 16
		DDRD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if year_treat == `start' & $C2 "
			esttab  using "$tables_paper/include/revision_`1'`j'_lifecourse_table.tex",replace booktabs fragment ///
				keep(TxA)  se star(* 0.10 ** 0.05 *** 0.01) coeflabels(TxA "`start' [`age']") wide ///
				label nomtitles nonumbers  nonote nogaps noline noobs
		local start = `start' + 1
		local age = `age' + 1
		
		
		
		forvalues X = `start' (1) `ende' {
			DDRD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if year_treat == `X' & $C2 "
			esttab  using "$tables_paper/include/revision_`1'`j'_lifecourse_table.tex",append booktabs fragment ///
				keep(TxA)  se star(* 0.10 ** 0.05 *** 0.01) coeflabels(TxA "`X' [`age']") wide ///
				label nomtitles nonumbers  nonote nogaps noline noobs
			local age = `age' + 1
		} // end loop over years
	} // end loop over genders
} // end loop over vars
			

