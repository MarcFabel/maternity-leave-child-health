/*******************************************************************************
* File name: 	mlch_KKH_analysis_reduced form
* Author: 		Marc Fabel
* Date: 		26.09.2017
* Description:	Exploration of reduced from (different RD plots and co)
*				
*				
*				
*
* Inputs:  		$temp\KKH_final_R1
*				
* Outputs:		$temp\KKH_final_R1
*
* Updates:		14.11.2017 Raw format für Moving averages
*
* Notes: For the moment I do everything for Daignosis number 5
*				Variable MOB_altern muss in prepare geschoben werden
*******************************************************************************/

// ***************************** PREAMBLE********************************
	clear all
	set more off
	
	*global path  "F:\econ\m-l-c-h\analysis"					//Work
	global path  "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis"	//MAC
	
	global temp  "$path/temp"
	global KKH   "$path/source" 
	global graph "$path/graphs/KKH" 
	
	*magic numbers
	global first_year = 1995
	global last_year  = 2014
// ***********************************************************************

* *************open data  *************
use "$temp/KKH_final_R1", clear

********************************************************************************
// Liste erstellen; variablen die per gender sind und bei denen ratios existierenh
#delimit ;
global list_vars_mandf_ratios_available "
	summ_stay		
	hospital
	hospital2
	d1				
	d2				
	d5				
	d6 				
	d7 				
	d8 				
	d9 				
	d10 					
	d11 					
	d12 					
	d13 					
	d17 					
	d18
	
	metabolic_syndrome 
	respiratory_index 
	drug_abuse 
	heart
		
	injuries 			
	neurosis 			
	joints 				
	kidneys 				
	bile_pancreas";
#delimit cr
*not contained:


global list_vars_mandf_no_ratios "length_of_stay share_surgery"



#delimit ;
global list_vars_total_ratios_available "
	d14 					
	female_genital_tract	
	pregnancy			
	delivery 			
	
	stomach				
	symp_dig_system		
	mal_neoplasm			
	ben_neoplasm				
	depression			
	personality			
	lymphoma				
	symp_resp_system		
	calculi	";
#delimit cr




// ************* Step 1: RD - pooled  ******************************************
foreach 1 of varlist $list_vars_mandf_ratios_available {
	foreach var in "" "r_fert_" "r_popf_"  { // rows: 
		foreach j in "" "_f" "_m"  { // columns:  
			capture drop `j'_hat* AVRG`j'
			qui bys Datum control: egen AVRG`j' = mean(`var'`1'`j') 
			qui reg `var'`1'`j' NumX Num_after after if treat == 1
			qui predict `j'_hat_linear_T
			qui reg `var'`1'`j' NumX Num_after after if control == 2
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
			legend(label(1 "Treatment") label(2 "Control "))  legend(size(small)) ///
			legend( order(1 2)) legend(pos(5) ring(0) col(2)) ///
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
			legend(label(1 "Treatment") label(2 "Control "))  legend(size(small)) ///
			legend( order(1 2)) legend(pos(5) ring(0) col(2)) ///
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
			legend(label(1 "Treatment") label(2 "Control "))  legend(size(small)) ///
			legend( order(1 2)) legend(pos(5) ring(0) col(2)) ///
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
	graph export "$graphs/rd_`1'_overview_panel1.pdf", as(pdf) replace
} //end: loop over variable list

foreach 1 of varlist $list_vars_mandf_no_ratios {
	foreach var in ""   { // rows: 
		foreach j in "" "_f" "_m"  { // columns:  
			capture drop `j'_hat* AVRG`j'
			qui bys Datum control: egen AVRG`j' = mean(`var'`1'`j') 
			qui reg `var'`1'`j' NumX Num_after after if treat == 1
			qui predict `j'_hat_linear_T
			qui reg `var'`1'`j' NumX Num_after after if control == 2
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
			legend(label(1 "Treatment") label(2 "Control "))  legend(size(small)) ///
			legend( order(1 2)) legend(pos(5) ring(0) col(2)) ///
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
			legend(label(1 "Treatment") label(2 "Control "))  legend(size(small)) ///
			legend( order(1 2)) legend(pos(5) ring(0) col(2)) ///
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
			legend(label(1 "Treatment") label(2 "Control "))  legend(size(small)) ///
			legend( order(1 2)) legend(pos(5) ring(0) col(2)) ///
			xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
				saving($graphs/male_`var', replace)
			
		*graph export "$graph/RD/R1_RD_pooled_CG_`1'.pdf", replace	
		
	} // end: loop over rows (variable specification)
	
	graph combine "$graphs/total_.gph"			"$graphs/female_.gph"			"$graphs/male_.gph"  , altshrink ///
				  title(RD: per gender with CG2 comparisson) subtitle("$`1'")   ///
				  t1title("total              		female              		male") ///
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/rd_`1'_overview_panel1.pdf", as(pdf) replace
} //end: loop over variable list

foreach 1 of varlist $list_vars_total_ratios_available {
	foreach var in "" "r_fert_" "r_popf_"  { // rows: 
		foreach j in ""   { // columns:  
			capture drop `j'_hat* AVRG`j'
			qui bys Datum control: egen AVRG`j' = mean(`var'`1'`j') 
			qui reg `var'`1'`j' NumX Num_after after if treat == 1
			qui predict `j'_hat_linear_T
			qui reg `var'`1'`j' NumX Num_after after if control == 2
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
			legend(label(1 "Treatment") label(2 "Control "))  legend(size(small)) ///
			legend( order(1 2)) legend(pos(5) ring(0) col(2)) ///
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
			legend(label(1 "Treatment") label(2 "Control "))  legend(size(small)) ///
			legend( order(1 2)) legend(pos(5) ring(0) col(2)) ///
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
			legend(label(1 "Treatment") label(2 "Control "))  legend(size(small)) ///
			legend( order(1 2)) legend(pos(5) ring(0) col(2)) ///
			xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
				saving($graphs/male_`var', replace)
			
		*graph export "$graph/RD/R1_RD_pooled_CG_`1'.pdf", replace	
		
	} // end: loop over rows (variable specification)
	
	graph combine "$graphs/total_.gph"		///	
				  "$graphs/total_r_fert_.gph"	 ///
				  "$graphs/total_r_popf_.gph"	, altshrink ///
				  title(RD: per gender with CG2 comparisson) subtitle("$`1'")   ///
				  l1title("Ratio_pop		Ratio_fert		Abs numbers") /// 
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/rd_`1'_overview_panel1.pdf", as(pdf) replace
} //end: loop over variable list



// ************* Moving Averages ***********************************************
/* System: 

X_neu	  1		  2		  3		  4		|	  5		  6		  7		  8
MOB		111201	120102	010203	020304	|	050607	060708	070809	080910
MOB_a	010203	020304	...
			auf letzten Monat 					auf ersten Monat averages legen
			
	- die neue X variable ist nur ein hypotheitsches Konstrukt
	- es wird mit MOB_a erstellt
	Genereller approach
	qui gen num = . 
	//Beispiel erster Punkt: 
	/*
	qui gen temp = 1 if MOB_a == 1 | MOB_a == 2 | MOB_a == 3
	qui bys control temp: egen temp2 = total(Diag_5)
	qui replace num = temp2 if MOB_a == 3 
	*/
*/	

	
use "$temp/KKH_final_R1", clear


// Setup of MA variables fertility and bev
foreach 1 of varlist  fert bev_fert  {
	foreach j in "" "f" "m"  { // columns:
		qui gen ma_`1'`j' = . 
		//erster Punkt: 
		/*
		qui gen temp = 1 if MOB_a == 1 | MOB_a == 2 | MOB_a == 3
		qui bys control temp: egen temp2 = total(Diag_5)
		qui replace num = temp2 if MOB_a == 3 
		*/
		
		//General Problem:
		*Pre-treatment
		local k = 1
		while `k' <= 4 {
			capture drop temp*
			qui gen temp = 1 if MOB_a == `k' | MOB_a == `k'+1 | MOB_a == `k'+2
			qui bys control temp: egen temp2 = total(`1'`j')
			qui replace ma_`1'`j' = temp2 if MOB_a == `k'+2 
			local k =`k'+1
		}
		*Post-treatment
		local k = 5
		while `k' <= 8 {
			capture drop temp*
			qui gen temp = 1 if MOB_a == `k' | MOB_a == `k'+1 | MOB_a == `k'+2
			qui bys control temp: egen temp2 = total(`1'`j')
			qui replace ma_`1'`j' = temp2 if MOB_a == `k'+2 
			local k =`k'+1
		}
	sort Datum year
	} // end: loop over t f m
} // end: loop over variables
drop temp*

// setup of ma variables for the outcomes: 
*male & female
foreach 1 of varlist  $list_vars_mandf_ratios_available $list_vars_mandf_no_ratios  {
	foreach j in "" "_f" "_m"  { // columns:
		qui gen mat_`1'`j' = .  //cummulative cases (just used to build ratios)
		qui gen ma_`1'`j' = .  // average numbers -> to be depicted in scatters
		*Pre-treatment
		local k = 1
		while `k' <= 4 {
			capture drop temp*
			qui gen temp = 1 if MOB_a == `k' | MOB_a == `k'+1 | MOB_a == `k'+2
			qui bys control temp: egen temp2 = total(`1'`j')
			qui bys control temp: egen tempX = mean(`1'`j')
			qui replace mat_`1'`j' = temp2 if MOB_a == `k'+2 
			qui replace ma_`1'`j' = tempX  if MOB_a == `k'+2
			local k =`k'+1
		}
		*Post-treatment
		local k = 5
		while `k' <= 8 {
			capture drop temp*
			qui gen temp = 1 if MOB_a == `k' | MOB_a == `k'+1 | MOB_a == `k'+2
			qui bys control temp: egen temp2 = total(`1'`j')
			qui bys control temp: egen tempX = mean(`1'`j')
			qui replace mat_`1'`j' = temp2 if MOB_a == `k'+2 
			qui replace ma_`1'`j' = tempX  if MOB_a == `k'+2
			local k =`k'+1
		}
	sort Datum year
	
	
	
	} // end: loop over t f m
} // end: loop over variables
drop temp*

*only totals
foreach 1 of varlist  $list_vars_total_ratios_available  {
	foreach j in ""  { // columns:
		qui gen mat_`1'`j' = .  //cummulative cases (just used to build ratios)
		qui gen ma_`1'`j' = .  // average numbers -> to be depicted in scatters
		*Pre-treatment
		local k = 1
		while `k' <= 4 {
			capture drop temp*
			qui gen temp = 1 if MOB_a == `k' | MOB_a == `k'+1 | MOB_a == `k'+2
			qui bys control temp: egen temp2 = total(`1'`j')
			qui bys control temp: egen tempX = mean(`1'`j')
			qui replace mat_`1'`j' = temp2 if MOB_a == `k'+2 
			qui replace ma_`1'`j' = tempX  if MOB_a == `k'+2
			local k =`k'+1
		}
		*Post-treatment
		local k = 5
		while `k' <= 8 {
			capture drop temp*
			qui gen temp = 1 if MOB_a == `k' | MOB_a == `k'+1 | MOB_a == `k'+2
			qui bys control temp: egen temp2 = total(`1'`j')
			qui bys control temp: egen tempX = mean(`1'`j')
			qui replace mat_`1'`j' = temp2 if MOB_a == `k'+2 
			qui replace ma_`1'`j' = tempX  if MOB_a == `k'+2
			local k =`k'+1
		}
	sort Datum year	
	} // end: loop over t f m
} // end: loop over variables
drop temp*

// Ratios bilden
foreach 1 of varlist  $list_vars_mandf_ratios_available {
	*total
	qui gen ma_r_popf_`1' = mat_`1'*1000 / ma_bev_fert
	qui gen ma_r_fert_`1' = mat_`1'*1000 / ma_fert
	*female
	qui gen ma_r_popf_`1'_f = mat_`1'_f*1000 / ma_bev_fertf
	qui gen ma_r_fert_`1'_f = mat_`1'_f*1000 / ma_fertf
	*male
	qui gen ma_r_popf_`1'_m = mat_`1'_m*1000 / ma_bev_fertm
	qui gen ma_r_fert_`1'_m = mat_`1'_m*1000 / ma_fertm
	*drop unnecessary totals
	*qui drop mat_`1'*
} 
foreach 1 of varlist  $list_vars_total_ratios_available {
	*total
	qui gen ma_r_popf_`1' = mat_`1'*1000 / ma_bev_fert
	qui gen ma_r_fert_`1' = mat_`1'*1000 / ma_fert
} 	




*Ausgangsbasis: Code von RD_pooled
*program define RD_pooled
foreach 1 of varlist $list_vars_mandf_ratios_available  {
	foreach var in "" "r_fert_" "r_popf_"  { // rows: 
		foreach j in "" "_f" "_m" { // rows total female male
			capture drop AVRG`j' `j'_hat_linear_T
			qui bys MOB_ma control: egen AVRG`j' = mean(ma_`var'`1'`j') 
			qui reg `var'`1'`j' NumX Num_after after if treat == 1
			qui predict `j'_hat_linear_T
		} // end: total female male (row)
			
		*total 
		scatter AVRG MOB_ma if treat == 1, color(black)  ///
			scheme(s1mono )  title("") ///
			xtitle("") ytitle("") ///
			ylabel(#5,grid) ///
			xlabel(3(2)9, val) xmtick(4(2)10) ///
			legend(off) ///
			xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
			saving($graphs/total_`var', replace)
				
		*female 
		scatter AVRG_f MOB_ma if treat == 1, color(red)  ///
			scheme(s1mono )  title("") ///
			xtitle("") ytitle("") ///
			ylabel(#5,grid) ///
			xlabel(3(2)9, val) xmtick(4(2)10) ///
			legend(off) ///
			xline(6.5, lw(medthick ) lpattern(solid)) nodraw ///
			saving($graphs/female_`var', replace)
			
		*male 	
		scatter AVRG_m MOB_ma if treat == 1, color(blue)  ///
			scheme(s1mono )  title("") ///
			xtitle("") ytitle("") ///
			ylabel(#5,grid) ///
			xlabel(3(2)9, val) xmtick(4(2)10) ///
			legend(off) ///
			xline(6.5, lw(medthick ) lpattern(solid)) nodraw ///
				saving($graphs/male_`var', replace)		
	} // end: loop variable specification (columns)	
	graph combine "$graphs/total_.gph"			"$graphs/female_.gph"			"$graphs/male_.gph"  ///
				  "$graphs/total_r_fert_.gph"	"$graphs/female_r_fert_.gph"	"$graphs/male_r_fert_.gph" ///
				  "$graphs/total_r_popf_.gph"	"$graphs/female_r_popf_.gph"	"$graphs/male_r_popf_.gph", altshrink ///
				  title("RD: MOVING AVERAGE (3M)") subtitle("$`1'")   ///
				  t1title("total              		female              		male") ///
				  l1title("Ratio_pop		Ratio_fert		Abs numbers") /// 
				  scheme(s1mono)
	graph export "$graphs/rd_`1'_overview_panel2.pdf", as(pdf) replace
} // end: loop variables
// *****************************************************************************
	

	
	
	
	* -> benutzt man da das richtige?? 
foreach 1 of varlist $list_vars_mandf_no_ratios  {
	foreach var in ""   { // rows: 
		foreach j in "" "_f" "_m" { // rows total female male
			capture drop AVRG`j' `j'_hat_linear_T
			qui bys MOB_ma control: egen AVRG`j' = mean(ma_`var'`1'`j') 
			qui reg `var'`1'`j' NumX Num_after after if treat == 1
			qui predict `j'_hat_linear_T
		} // end: total female male (row)
			
		*total 
		scatter AVRG MOB_ma if treat == 1, color(black)  ///
			scheme(s1mono )  title("") ///
			xtitle("") ytitle("") ///
			ylabel(#5,grid) ///
			xlabel(3(2)9, val) xmtick(4(2)10) ///
			legend(off) ///
			xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
			saving($graphs/total_`var', replace)
				
		*female 
		scatter AVRG_f MOB_ma if treat == 1, color(red)  ///
			scheme(s1mono )  title("") ///
			xtitle("") ytitle("") ///
			ylabel(#5,grid) ///
			xlabel(3(2)9, val) xmtick(4(2)10) ///
			legend(off) ///
			xline(6.5, lw(medthick ) lpattern(solid)) nodraw ///
			saving($graphs/female_`var', replace)
			
		*male 	
		scatter AVRG_m MOB_ma if treat == 1, color(blue)  ///
			scheme(s1mono )  title("") ///
			xtitle("") ytitle("") ///
			ylabel(#5,grid) ///
			xlabel(3(2)9, val) xmtick(4(2)10) ///
			legend(off) ///
			xline(6.5, lw(medthick ) lpattern(solid)) nodraw ///
				saving($graphs/male_`var', replace)		
	} // end: loop variable specification (columns)	
	graph combine "$graphs/total_.gph"			"$graphs/female_.gph"			"$graphs/male_.gph"  , altshrink ///
				  title("RD: MOVING AVERAGE (3M)") subtitle("$`1'")   ///
				  t1title("total              		female              		male") ///
				  scheme(s1mono)
	graph export "$graphs/rd_`1'_overview_panel2.pdf", as(pdf) replace
} // end: loop variables	
	
	
foreach 1 of varlist $list_vars_total_ratios_available  {
	foreach var in "" "r_fert_" "r_popf_"  { // rows: 
		foreach j in ""  { // rows total female male
			capture drop AVRG`j' `j'_hat_linear_T
			qui bys MOB_ma control: egen AVRG`j' = mean(ma_`var'`1'`j') 
			qui reg `var'`1'`j' NumX Num_after after if treat == 1
			qui predict `j'_hat_linear_T
		} // end: total female male (row)
			
		*total 
		scatter AVRG MOB_ma if treat == 1, color(black)  ///
			scheme(s1mono )  title("") ///
			xtitle("") ytitle("") ///
			ylabel(#5,grid) ///
			xlabel(3(2)9, val) xmtick(4(2)10) ///
			legend(off) ///
			xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
			saving($graphs/total_`var', replace)
				
				
	} // end: loop variable specification (columns)	
	graph combine "$graphs/total_.gph"			///
				  "$graphs/total_r_fert_.gph" ///
				  "$graphs/total_r_popf_.gph", altshrink ///
				  title("RD: MOVING AVERAGE (3M)") subtitle("$`1'")   ///
				  l1title("Ratio_pop		Ratio_fert		Abs numbers") /// 
				  scheme(s1mono)
	graph export "$graphs/rd_`1'_overview_panel2.pdf", as(pdf) replace
} // end: loop variables
	




/*LATEX OUTPUT
%%%%%%%%%%%%%%%%%%%%%%%%%	TEMPLATE	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\begin{figure}[h]
\centering
\caption{Pooled}
\begin{subfigure}[t]{0.31\textwidth}
		\centering
		\caption{Absolute numbers}
		\includegraphics[width=0.99\textwidth]{R1_RD_pooled_CG_Diag_5.pdf}	
\end{subfigure}
\begin{subfigure}[t]{0.31\textwidth}
		\centering
		\caption{Ratio (approx)}
		\includegraphics[width=0.99\textwidth]{R1_RD_pooled_CG_Diag_5_r.pdf}	
\end{subfigure}
\begin{subfigure}[t]{0.31\textwidth}
		\centering
		\caption{Ratio (births)}
		\includegraphics[width=0.99\textwidth]{R1_RD_pooled_CG_Diag_5_r2.pdf}	
\end{subfigure}
%%%%%% surveyjahr
\begin{subfigure}[t]{0.31\textwidth}
		\centering
		\includegraphics[width=0.99\textwidth]{R1_RD_peryear_Diag_5_2005.pdf}	
\end{subfigure}
\begin{subfigure}[t]{0.31\textwidth}
		\centering
		\includegraphics[width=0.99\textwidth]{R1_RD_peryear_Diag_5_r_2005.pdf}	
\end{subfigure}
\begin{subfigure}[t]{0.31\textwidth}
		\centering
		\includegraphics[width=0.99\textwidth]{R1_RD_peryear_Diag_5_r_2005.pdf}	
\end{subfigure}
\end{figure}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



















// ************* Step 2: RD over time ******************************************
* Define program
capture program drop RD_over_time
program define RD_over_time
	capture drop `1'_hat_* 
	foreach year of numlist $first_year (1) $last_year  {
		* plain:without fits
		/*
		tw scatter `1' MOB_altern if year == `year' & treat == 1, scheme(s1mono) color(gs4) ///
			xlabel(1(2)12, val) xmtick(2(2)12) title(" `year' ") || ///
			scatter `1' MOB_altern if year == `year' & control ==2 , color(gs13) ///
			legend(label(1 "Treatment Cohort") label(2 "Control cohort")) legend(size(small)) ///
			title(" `year' ") xline(6.5, lw(medthick ) lpattern(solid)) ///
			xtitle("Birth month") ytitle(" `1' ") ///
			ylabel(#5,grid)	msymbol(Dh) // end: scatter graph
			
		graph export "$graph/RD/R1_RD_peryear_`1'_`year'_raw.pdf", replace
		*/
		
		* with fits
		qui reg `1' NumX Num_after after if year == `year' & treat == 1
		qui predict `1'_hat_linear_T
		qui reg `1' NumX Num_after after if year == `year' & control == 2
		qui predict `1'_hat_linear_C
		
		scatter `1' MOB_altern if year == `year' & treat == 1, color(gs4)  || ///
			scatter `1' MOB_altern if year == `year' & control == 2, color(gs13) msymbol(Dh) || ///
			line `1'_hat_linear_C MOB_altern if after == 1, sort lpattern(dash) color(gs13) || ///
			line `1'_hat_linear_C MOB_altern if after == 0, sort lpattern(dash) color(gs13) || ///
			line `1'_hat_linear_T MOB_altern if after == 1, sort color(black) || ///
			line `1'_hat_linear_T MOB_altern if after == 0, sort color(black) ///
			scheme(s1mono )  title(" `year' ") ///
			xline(6.5, lw(medthick ) lpattern(solid)) /// 
			xtitle("Birth month") ytitle(" `1' ") ///
            ylabel(#5,grid) xlabel(1(2)12, val) xmtick(2(2)12) ///
			legend(off)	//end: graph			
		drop `1'_hat_* 
			
		graph export "$graph/RD/R1_RD_peryear_`1'_`year'.pdf", as(pdf) replace			
	} //end: year loop	
end	//end: program



/*
LIST OF VARIABLES
-> To do this for all variables

*/

*analysis
foreach var of varlist Diag_5 {
	RD_over_time `var'			//absolute numbers
	RD_over_time `var'_r		//ratio with approximations
	RD_over_time `var'_r2		//ratio with number of births
} //end: loop over variables
// *****************************************************************************


















*/




