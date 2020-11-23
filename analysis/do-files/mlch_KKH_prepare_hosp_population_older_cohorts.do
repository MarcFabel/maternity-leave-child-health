/*******************************************************************************
* File name: 	mlch_KKH_prepare_hosp
* Author: 		Marc Fabel
* Date: 		03.11.2020
* Description:	
* Inputs:  		
* Outputs:		KKH_final_R1_and_old_cohorts
*
* Updates:		
* Notes:		
*******************************************************************************/




// ***************************** PREAMBLE********************************
	clear all
	set more off
	
	global path  		"F:\econ\m-l-c-h/analysis"		//MAC at work
	global temp  		"$path/temp"
	global KKH   		"$path/source/KKH_FDZ" 
	global population 	"$path/source/population"
	
	global tables 		"$path/tables/KKH"
	global tables_paper "$path/tables/paper"
	
	global graphs "$path/graphs/KKH"
	global graph_paper "$path/graphs/paper" 
	
	global t_95   	  = 1.960

// ***********************************************************************
	
	
	
// Prepare births for older cohorts	just FRG
	*men
	import excel "$population\DESTATIS_ANFRAGE\BRD_Maenner_1946-1989.xls", ///
		sheet("1961 - 1974") cellrange(A7:N24) firstrow clear
	qui gen temp =_n
	qui drop B 
	qui drop if temp == 1 | temp ==2
	qui gen YOB = substr(Jahr,1,4)
	qui drop Jahr temp
	order YOB
	qui destring _all, replace
	*rename months for reshape (name them fertm0 - 0 für GDR ==0) 
	rename Januar fertm01
	rename Februar fertm02
	rename März fertm03
	rename April fertm04
	rename Mai fertm05
	rename Juni fertm06
	rename Juli fertm07
	rename August fertm08
	rename September fertm09
	rename Oktober fertm010
	rename November fertm011
	rename Dezember fertm012
	*reshape
	reshape long fertm0, i(YOB) j(MOB)
	qui save "$temp/geburten_prepare_1961_74", replace
	
	
	
	// 3) Weiblich - Frühere BRD
	import excel "$population\DESTATIS_ANFRAGE\BRD_Frauen_1946-1989.xls", ///
		sheet("1961 - 1974") cellrange(A7:N24) firstrow clear
	qui gen temp =_n
	qui drop B 
	qui drop if temp == 1 | temp ==2
	qui gen YOB = substr(Jahr,1,4)
	qui drop Jahr temp
	order YOB
	qui destring _all, replace
	*rename months for reshape (name them fertf0 - 0 für GDR ==0) 
	rename Januar fertf01
	rename Februar fertf02
	rename März fertf03
	rename April fertf04
	rename Mai fertf05
	rename Juni fertf06
	rename Juli fertf07
	rename August fertf08
	rename September fertf09
	rename Oktober fertf010
	rename November fertf011
	rename Dezember fertf012
	*reshape
	reshape long fertf0, i(YOB) j(MOB)
	qui merge 1:1 YOB MOB using "$temp/geburten_prepare_1961_74"
	drop _merge
	qui save "$temp/geburten_prepare_1961_74", replace
	
	
	
	
	* finish data set
	qui gen GDR = 0 
	qui rename fertf0 fertf
	qui rename fertm0 fertm
	*totals
	qui gen fert = fertm + fertf
	
	qui keep if YOB !=.

	
	* append younger cohorts
	qui append using "$temp/geburten_prepared_final"
	drop ratio*
	drop if GDR == 1
	
	
	
	
	
	qui save "$temp/geburten_prepared_final_1961_81_FRG", replace
	qui erase "$temp/geburten_prepare_1961_74.dta"
	
	
	
	
	
	
////////////////////////////////////////////////////////////////////////////////////////
//1. Krankenhausdaten vorbereiten, gemeinsames Datenset konstruieren
////////////////////////////////////////////////////////////////////////////////////////



	// prepare older cohorts
	use "$KKH/Anfrage_Nov2018_data_final_collapsed_1946-1976.dta", clear
	qui gen j = "_f" if female == 1
	qui replace j = "_m" if female == 0
	drop female
	
	*rename variables
	rename Diag_5 d5
	
	*reshape 
	reshape wide hospital2 d5 , i(YOB MOB year) j(j) string
	
	* generate totals
	foreach var in hospital2 d5 {
		qui egen `var' = rowtotal(`var'_m `var'_f)
	}
	qui gen GDR = 0 /// the data covers only west-germany

	qui drop if YOB <= 1960
	
	
	* merge with fertility data
	merge m:1 YOB MOB GDR using "$temp/geburten_prepared_final_1961_81_FRG", 
	drop if _merge == 2
	
	
	qui drop _merge
	
	
	
	* generate outcome variables
	foreach var of varlist hospital2 d5 {
		qui generate r_fert_`var' = `var'*1000 / fert
		qui label var r_fert_`var' "Ratio using number of births (destatis); per thousand"
		qui generate r_fert_`var'_f = `var'_f*1000 / fertf
		qui label var r_fert_`var'_f "Ratio using number of births (destatis); per thousand"
		qui generate r_fert_`var'_m = `var'_m*1000 / fertm
		qui label var r_fert_`var'_m "Ratio using number of births (destatis); per thousand"
		
		}
	


	
// birth variable as monthly and daily (auxiliary variable for RD plots)
	qui tostring YOB, gen(temp1)
	qui tostring MOB, gen(temp2)
	qui gen temp3 = temp1+"m"+temp2
	qui gen Datum = monthly(temp3, "YM")
	format Datum %tm	
	qui gen temp4 = "15"
	qui gen temp5 = temp2+"/"+temp4+"/"+temp1
	qui gen Datum2 = daily(temp5, "MDY")
	format Datum2 %td
	qui drop temp*	
	
	
	
	
	
	

	//generate dummy variables for the regression:
	qui gen threshold = monthly("1979m5", "YM")
	format threshold %tm
	local threshm 5
	local binw 6
	qui gen treat = cond((Datum>threshold-`binw'-1 & Datum<threshold + `binw' ),1,0)	//Nov78-Oct79
	qui gen after = cond((MOB>= `threshm' & MOB< `threshm'+`binw' ),1,0)		// Months after reform
	qui gen TxA = treat*after
		 
	
	//generate cluster variable (for each month of each birth cohort, #clusters= #CGs+TG)*12 )
	qui gen MxY = YOB * MOB
		
		
	save "$temp\KKH_final_1961-1976_Oct", replace
	
	qui append using "$temp\KKH_final_R1"
	
	save "$temp\KKH_final_R1_and_old_cohorts"
	

	
	
	
////////////////////////////////////////////////////////////////////////////////////////
//	ANALYSIS
////////////////////////////////////////////////////////////////////////////////////////	
	
	use "$temp\KKH_final_R1_and_old_cohorts", clear
	
	
	capture program drop DDRD
	program define DDRD
		qui eststo `1': reg `2' treat after TxA  `3'  `4', vce(cluster MxY) 
	end
	
	
	foreach 1 in "hospital2" "d5" {
		local threshm 5
		local binw 6
		
		* first year
		local j = 1
		local month_past = `j' * 12
		qui gen control_x = cond((Datum>threshold-`binw'-1-`month_past' & Datum<threshold + `binw' -`month_past'),1,0)
		
		DDRD a1 r_fert_`1' "i.MOB i.year" "if treat == 1 | control_x == 1"
		DDRD a2 r_fert_`1'_f "i.MOB i.year" "if treat == 1 | control_x == 1"
		DDRD a3 r_fert_`1'_m "i.MOB i.year" "if treat == 1 | control_x == 1"
		
		esttab a* ,keep(TxA*) se star(* 0.10 ** 0.05 *** 0.01) ///
			coeflabels(TxA "`j'") noobs wide
			
		esttab a* using "$temp/mlch_sutva_older_cohorts_`1'.csv", replace wide ///
			keep(TxA*) se nostar ///
			coeflabels(TxA "`j'") ///
			nomtitles nonumbers noobs nonote nogaps noline noparen
		local j = `j' + 1
		qui drop control_x
		
		
		* other years
		while `j' < 5 {
			local month_past = `j' * 12
			qui gen control_x = cond((Datum>threshold-`binw'-1-`month_past' & Datum<threshold + `binw' -`month_past'),1,0)
		
			DDRD a1 r_fert_`1' "i.MOB i.year" "if treat == 1 | control_x == 1"
			DDRD a2 r_fert_`1'_f "i.MOB i.year" "if treat == 1 | control_x == 1"
			DDRD a3 r_fert_`1'_m "i.MOB i.year" "if treat == 1 | control_x == 1"
			
				
			esttab a* using "$temp/mlch_sutva_older_cohorts_`1'.csv", append wide ///
				keep(TxA*) se nostar ///
				coeflabels(TxA "`j'") ///
				nomtitles nonumbers noobs nonote nogaps noline noparen
			local j = `j' + 1
			qui drop control_x
		} // end: loop over control years
	}
	


		
		
// Visualization
		
		
		
		
		
		* import regression output
		import delimited "$temp/mlch_sutva_older_cohorts_hospital2.csv", varnames(nonames) stripquote(yes) encoding(Big5) clear 

		rename v1 control
		rename v2 beta
		rename v3 sterr
		rename v4 beta_f
		rename v5 sterr_f
		rename v6 beta_m
		rename v7 sterr_m
		
		* strip away equal sign
		foreach var of varlist control beta* sterr* {
			qui replace `var' = substr(`var',2,.)
		}
		
		qui destring *, replace
		
		
		* generate CI 
		foreach j in "" "_f" "_m" {
			qui gen CI_l`j' = beta`j' - $t_95 * sterr`j'
			qui gen CI_h`j' = beta`j' + $t_95 * sterr`j'
		}
		
		
		
		// plots hospital 		
		scatter beta control, color(black) || ///
			rspike CI_h CI_l control, color(black) ///
			yscale(r(-8,2)) ylabel(-6 (2) 0) yline(0, lpattern(dash)) ///
			xscale(r(0,5)) ///
			legend(off) xtitle("") ytitle("DiD estimate") ///
			xtitle("Control cohort [years before treatment cohort]") ///
			scheme(s1mono) plotregion(color(white)) /// 
			saving($graphs/hospital2_older_cohorts.gph, replace)
		graph export "$graph_paper/hospital2_older_control_cohorts.pdf", as(pdf) replace
		
		scatter beta_f control, color(cranberry) || ///
			rspike CI_h_f CI_l_f control, color(cranberry) ///
			yscale(r(-8,2)) ylabel(-6 (2) 0) yline(0, lpattern(dash)) ///
			xscale(r(0,5)) ///
			legend(off) xtitle("") ytitle("DiD estimate") ///
			xtitle("Control cohort [years before treatment cohort]") ///
			scheme(s1mono) plotregion(color(white)) /// 
			saving($graphs/hospital2_f_older_cohorts.gph, replace)
		graph export "$graph_paper/hospital2_f_older_control_cohorts.pdf", as(pdf) replace
			
			
		scatter beta_m control, color(navy) || ///
			rspike CI_h_m CI_l_m control, color(navy) ///
			yscale(r(-8,2)) ylabel(-6 (2) 0) yline(0, lpattern(dash)) ///
			xscale(r(0,5)) ///
			legend(off) xtitle("") ytitle("DiD estimate") ///
			xtitle("Control cohort [years before treatment cohort]") ///
			scheme(s1mono) plotregion(color(white)) /// 
			saving($graphs/hospital2_m_older_cohorts.gph, replace)
		graph export "$graph_paper/hospital2_m_older_control_cohorts.pdf", as(pdf) replace
		
	
			graph combine "$graphs/hospital2_older_cohorts.gph" "$graphs/hospital2_f_older_cohorts.gph" "$graphs/hospital2_m_older_cohorts.gph", col(3) xsize(15.5) ///
			scheme(s1mono) plotregion(color(white))
	
	
	
	
	* graphs for MBDs
	import delimited "$temp/mlch_sutva_older_cohorts_d5.csv", varnames(nonames) stripquote(yes) encoding(Big5) clear 

		rename v1 control
		rename v2 beta
		rename v3 sterr
		rename v4 beta_f
		rename v5 sterr_f
		rename v6 beta_m
		rename v7 sterr_m
		
		* strip away equal sign
		foreach var of varlist control beta* sterr* {
			qui replace `var' = substr(`var',2,.)
		}
		
		qui destring *, replace
		
		
		* generate CI 
		foreach j in "" "_f" "_m" {
			qui gen CI_l`j' = beta`j' - $t_95 * sterr`j'
			qui gen CI_h`j' = beta`j' + $t_95 * sterr`j'
		}
		
		
		
		
		scatter beta control, color(black) || ///
			rspike CI_h CI_l control, color(black)
		
		
		// plots 		
		scatter beta control, color(black) || ///
			rspike CI_h CI_l control, color(black) ///
			yscale(r(-2.2,1.2)) ylabel(-2 (1) 1) yline(0, lpattern(dash)) ///
			xscale(r(0,5)) ///
			legend(off) xtitle("") ytitle("DiD estimate") ///
			xtitle("Control cohort [years before treatment cohort]") ///
			scheme(s1mono) plotregion(color(white)) /// 
			saving($graphs/d5_older_cohorts.gph, replace)
		graph export "$graph_paper/d5_older_control_cohorts.pdf", as(pdf) replace
		
		scatter beta_f control, color(cranberry) || ///
			rspike CI_h_f CI_l_f control, color(cranberry) ///
			yscale(r(-2.2,1.2)) ylabel(-2 (1) 1) yline(0, lpattern(dash)) ///
			xscale(r(0,5)) ///
			legend(off) xtitle("") ytitle("DiD estimate") ///
			xtitle("Control cohort [years before treatment cohort]") ///
			scheme(s1mono) plotregion(color(white)) /// 
			saving($graphs/d5_f_older_cohorts.gph, replace)
		graph export "$graph_paper/d5_f_older_control_cohorts.pdf", as(pdf) replace
			
			
		scatter beta_m control, color(navy) || ///
			rspike CI_h_m CI_l_m control, color(navy) ///
			yscale(r(-2.2,1.2)) ylabel(-2 (1) 1) yline(0, lpattern(dash)) ///
			xscale(r(0,5)) ///
			legend(off) xtitle("") ytitle("DiD estimate") ///
			xtitle("Control cohort [years before treatment cohort]") ///
			scheme(s1mono) plotregion(color(white)) /// 
			saving($graphs/d5_m_older_cohorts.gph, replace)
		graph export "$graph_paper/d5_m_older_control_cohorts.pdf", as(pdf) replace
		
	
		
		
		graph combine "$graphs/hospital2_older_cohorts.gph" "$graphs/hospital2_f_older_cohorts.gph" "$graphs/hospital2_m_older_cohorts.gph" ///
		"$graphs/d5_older_cohorts.gph" "$graphs/d5_f_older_cohorts.gph" "$graphs/d5_m_older_cohorts.gph", col(3) xsize(15.5) ysize(8) ///
			scheme(s1mono) plotregion(color(white))
	
	
	/*
	* by option 
		import delimited "$temp/mlch_sutva_older_cohorts_d5.csv", varnames(nonames) stripquote(yes) encoding(Big5) clear 

		rename v1 control
		rename v2 beta_t
		rename v3 sterr_t
		rename v4 beta_f
		rename v5 sterr_f
		rename v6 beta_m
		rename v7 sterr_m
		
		* strip away equal sign
		foreach var of varlist control beta* sterr* {
			qui replace `var' = substr(`var',2,.)
		}
		
		qui destring *, replace
		drop if control > 4
		reshape long beta sterr , i(control) j(gender) string
		
		qui replace gender = "total" if gender == "_t"
		qui replace gender = "women" if gender == "_f"
		qui replace gender = "men"   if gender == "_m"
	

		qui gen CI_l = beta - $t_95 * sterr
		qui gen CI_h = beta + $t_95 * sterr
		
	
		scatter beta control, by(gender) color(black) 
		
		|| ///
			rspike CI_h CI_l control, by(gender) color(black) ///
			yscale(r(-6,2)) ylabel(-6 (2) 2, grid) yline(0, lpattern(dash)) ///
			xscale(r(0,5)) ///
			legend(off) xtitle("") ///
			scheme(s1mono) plotregion(color(white))
		
	