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
*qui gen MxYxFRG = MxY * FRG


drop if GDR == 1
********************************************************************************
/* 
ACHTUNG: HIER IST EIN FEHLER NOCH DRINNEN: 
	DIE NENNER MÜSTTEN AUCH NACH GESCHLECHT SEIN
*/	
********************************************************************************

	
	// 2) Reduced form
	keep if treat == 1
	
	//A) WEIGHTED 
	/*
	[sum (var * weight)]/[sum weight]
	
	with weight = bev_fert
	*/
	*generate denominator (WEIGHTS ARE bev_fert, as there is no other population measure in the amr lebel analysis)
	bys Datum: egen denominator = total(bev_fert)
	bys Datum year: egen denominatoryear = total(bev_fert)

	
	foreach 1 of varlist hospital2 d5 { //  $list_outcomes
	capture drop W_AVRG* nominator*
	foreach var in  "r_popf_"  { // rows: 
		foreach j in "" "_f" "_m"  { // columns:  
			capture drop `j'_hat* 
			*average over all years
			bys Datum: egen nominator`j' = total(`var'`1'`j' * bev_fert)
			qui gen W_AVRG`j' = nominator`j'/denominator
			*average for different years
			bys Datum year: egen nominatoryear`j' = total(`var'`1'`j' * bev_fert)
			qui gen W_AVRGyear`j' = nominatoryear`j'/denominatoryear			
		} // end: loop over columns (total, male, female)

		*total		
		twoway scatter W_AVRG MOB_altern if treat == 1, color(black) ///
			scheme(s1mono )  ///
			xtitle("")  ///
			ylabel(#5,grid) ///
			xlabel(1(2)12, val) xmtick(2(2)12) ///
			legend(off) ///
			xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 
			graph export "$graphs/AMR_wghtd`1'_total_$date.png", replace
			*nodraw ///
			*saving($graphs/AMRtotal_`var', replace)

		*female 
		twoway scatter W_AVRG_f MOB_altern if treat == 1, color(red)  ///
			scheme(s1mono )  ///
			xtitle("")  ///
			ylabel(#5,grid) ///
			xlabel(1(2)12, val) xmtick(2(2)12) ///
			legend(off) ///
			xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 
			graph export "$graphs/AMR_wghtd`1'_female_$date.png", replace
			*nodraw ///
			*saving($graphs/AMRfemale_`var', replace)
			
		*male	
		twoway scatter W_AVRG_m MOB_altern if treat == 1, color(blue)  ///
			scheme(s1mono )  ///
			xtitle("")  ///
			ylabel(#5,grid) ///
			xlabel(1(2)12, val) xmtick(2(2)12) ///
			legend(off) ///
			xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 
			graph export "$graphs/AMR_wghtd`1'_male_$date.png", replace
			*nodraw ///
			*	saving($graphs/AMRmale_`var', replace)
				
				
		foreach X of numlist 2003(1)2014 {				
		// for single years		
			*total		
			twoway scatter W_AVRGyear MOB_altern if treat == 1  & year == `X', color(black)  ///
				scheme(s1mono )  ///
				xtitle("")  ///
				ylabel(#5,grid) ///
				xlabel(1(2)12, val) xmtick(2(2)12) ///
				legend(off) ///
				xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry))
				graph export "$graphs/AMR_wghtd`1'_total_`X'_$date.png", replace
				*nodraw ///
				*saving($graphs/AMRtotal_`var'`X', replace)
	
			*female 
			twoway scatter W_AVRGyear_f MOB_altern if treat == 1& year == `X', color(red)  ///
				scheme(s1mono )  ///
				xtitle("")  ///
				ylabel(#5,grid) ///
				xlabel(1(2)12, val) xmtick(2(2)12) ///
				legend(off) ///
				xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry))
				graph export "$graphs/AMR_wghtd`1'_female_`X'_$date.png", replace
				*nodraw ///
				*saving($graphs/AMRfemale_`var'`X', replace)
				
			*male	
			twoway scatter W_AVRGyear_m MOB_altern if treat == 1 & year == `X', color(blue)  ///
				scheme(s1mono )  ///
				xtitle("")  ///
				ylabel(#5,grid) ///
				xlabel(1(2)12, val) xmtick(2(2)12) ///
				legend(off) ///
				xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 
				graph export "$graphs/AMR_wghtd`1'_male_`X'_$date.png", replace
				*nodraw ///
				*saving($graphs/AMRmale_`var'`X', replace)
		} // end: list 2003 and 2014					
	} // end: loop over rows (variable specification)

	
	graph combine   "$graphs/AMRtotal_r_popf_.gph"	"$graphs/AMRfemale_r_popf_.gph"	"$graphs/AMRmale_r_popf_.gph" ///
				"$graphs/AMRtotal_r_popf_2003.gph"	"$graphs/AMRfemale_r_popf_2003.gph"	"$graphs/AMRmale_r_popf_2003.gph" ///
				"$graphs/AMRtotal_r_popf_2014.gph"	"$graphs/AMRfemale_r_popf_2014.gph"	"$graphs/AMRmale_r_popf_2014.gph", altshrink ///
				  title(LC: per gender) subtitle("$`1'")   ///
				  t1title("total              		female              		male") ///
				  l1title("2014			2003		All years") /// 
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/`1'_rf_amr_wghtd.pdf", as(pdf) replace
} //end: loop over variable list
	

	****************************************
	
// B) unweighted 
	foreach 1 of varlist hospital2 d5 { //$list_outcomes
	foreach var in  "r_popf_"  { // rows: 
		foreach j in "" "_f" "_m"  { // columns:  
			capture drop `j'_hat* AVRG`j' AVRGyear`j' 
			*average over all years
			qui bys Datum control: egen AVRG`j' = mean(`var'`1'`j') 
			*average for different years
			qui bys Datum year: egen AVRGyear`j' = mean(`var'`1'`j')
			
			qui reg `var'`1'`j' Numx Num_after after if treat == 1
			qui predict `j'_hat_linear_T
			
			qui reg `var'`1'`j' Numx Num_after after if treat == 1 & year == 2003 
			qui predict `j'_hat_linear_T_2003
			qui reg `var'`1'`j' Numx Num_after after if treat == 1 & year == 2014 
			qui predict `j'_hat_linear_T_2014
			
			
		} // end: loop over columns (total, male, female)

		*total		
		twoway scatter AVRG MOB_altern if treat == 1, color(black) || ///
			line _hat_linear_T MOB_altern if after == 1, sort color(black) || ///
			line _hat_linear_T MOB_altern if after == 0, sort color(black) ///
			scheme(s1mono )  ///
			xtitle("")  ///
			ylabel(#5,grid) ///
			xlabel(1(2)12, val) xmtick(2(2)12) ///
			legend(off) ///
			xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 
			graph export "$graphs/AMR_nwghtd`1'_total_$date.png", replace
			*nodraw ///
			*saving($graphs/AMRtotal_`var', replace)

		*female 
		twoway scatter AVRG_f MOB_altern if treat == 1, color(red) || ///
			line _f_hat_linear_T MOB_altern if after == 1, sort color(red) || ///
			line _f_hat_linear_T MOB_altern if after == 0, sort color(red) ///
			scheme(s1mono )  ///
			xtitle("")  ///
			ylabel(#5,grid) ///
			xlabel(1(2)12, val) xmtick(2(2)12) ///
			legend(off) ///
			xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 
			graph export "$graphs/AMR_nwghtd`1'_female_$date.png", replace
			*nodraw ///
			*saving($graphs/AMRfemale_`var', replace)
			
		*male	
		twoway scatter AVRG_m MOB_altern if treat == 1, color(blue) || ///
			line _m_hat_linear_T MOB_altern if after == 1, sort color(blue) || ///
			line _m_hat_linear_T MOB_altern if after == 0, sort color(blue) ///
			scheme(s1mono )  ///
			xtitle("")  ///
			ylabel(#5,grid) ///
			xlabel(1(2)12, val) xmtick(2(2)12) ///
			legend(off) ///
			xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 
			graph export "$graphs/AMR_nwghtd`1'_male_$date.png", replace
			*nodraw ///
			*saving($graphs/AMRmale_`var', replace)
				
				
		foreach X of numlist 2003(1)2014 {				
		// for single years		
			*total		
			twoway scatter AVRGyear MOB_altern if treat == 1  & year == `X', color(black) || ///
				line _hat_linear_T_`X' MOB_altern if after == 1  & year == `X', sort color(black) || ///
				line _hat_linear_T_`X' MOB_altern if after == 0  & year == `X', sort color(black) ///
				scheme(s1mono )  ///
				xtitle("")  ///
				ylabel(#5,grid) ///
				xlabel(1(2)12, val) xmtick(2(2)12) ///
				legend(off) ///
				xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 
				graph export "$graphs/AMR_nwghtd`1'_total_`X'_$date.png", replace
				*nodraw ///
				*saving($graphs/AMRtotal_`var'`X', replace)
	
			*female 
			twoway scatter AVRGyear_f MOB_altern if treat == 1& year == `X', color(red) || ///
				line _f_hat_linear_T_`X' MOB_altern if after == 1& year == `X', sort color(red) || ///
				line _f_hat_linear_T_`X' MOB_altern if after == 0& year == `X', sort color(red) ///
				scheme(s1mono )  ///
				xtitle("")  ///
				ylabel(#5,grid) ///
				xlabel(1(2)12, val) xmtick(2(2)12) ///
				legend(off) ///
				xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 
				graph export "$graphs/AMR_nwghtd`1'_female_`X'_$date.png", replace
				*nodraw ///
				*saving($graphs/AMRfemale_`var'`X', replace)
				
			*male	
			twoway scatter AVRGyear_m MOB_altern if treat == 1 & year == `X', color(blue) || ///
				line _m_hat_linear_T_`X' MOB_altern if after == 1 & year == `X', sort color(blue) || ///
				line _m_hat_linear_T_`X' MOB_altern if after == 0 & year == `X', sort color(blue) ///
				scheme(s1mono )  ///
				xtitle("")  ///
				ylabel(#5,grid) ///
				xlabel(1(2)12, val) xmtick(2(2)12) ///
				legend(off) ///
				xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 
				graph export "$graphs/AMR_nwghtd`1'_male_`X'_$date.png", replace
				*nodraw ///
				*saving($graphs/AMRmale_`var'`X', replace)
		} // end: list 2003 and 2014					
	} // end: loop over rows (variable specification)

	
	graph combine   "$graphs/AMRtotal_r_popf_.gph"	"$graphs/AMRfemale_r_popf_.gph"	"$graphs/AMRmale_r_popf_.gph" ///
				"$graphs/AMRtotal_r_popf_2003.gph"	"$graphs/AMRfemale_r_popf_2003.gph"	"$graphs/AMRmale_r_popf_2003.gph" ///
				"$graphs/AMRtotal_r_popf_2014.gph"	"$graphs/AMRfemale_r_popf_2014.gph"	"$graphs/AMRmale_r_popf_2014.gph", altshrink ///
				  title(LC: per gender) subtitle("$`1'")   ///
				  t1title("total              		female              		male") ///
				  l1title("2014			2003		All years") /// 
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/`1'_rf_amr_unwghtd.pdf", as(pdf) replace
} //end: loop over variable list

********************************************************************************
/*	
WHATS WIHT WEIGHTS???? 

// 1) DD - Life-course
	foreach 1 of varlist $list_outcomes { 
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
					DDRD x `var'`1'`j' "i.MOB"  " if year_treat == `X' & $C2"
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
