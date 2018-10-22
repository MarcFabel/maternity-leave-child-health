// RD graphs 


	global path  "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis"	//MAC
	
	global temp  "$path/temp"
	global KKH   "$path/source" 
	global graphs "$path/graphs/KKH" 
	global tables "$path/tables/KKH"
	global auxiliary "$path/do-files/auxiliary_files"


* *************open data  *************
use "$temp/KKH_final_R1", clear
run "$auxiliary/varlists_varnames_sample-spcifications"

*just treatment cohort
*qui keep if treat == 1


******* Pooled [from other do-file: analysis_overview_reduced_form
foreach 1 of varlist hospital2 {
	foreach var in "r_fert_" "r_popf_" "r_popmz_" { // rows: 
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
	
	graph combine "$graphs/total_r_fert_.gph"	"$graphs/female_r_fert_.gph"	"$graphs/male_r_fert_.gph" ///
				  "$graphs/total_r_popf_.gph"	"$graphs/female_r_popf_.gph"	"$graphs/male_r_popf_.gph" ///
				  "$graphs/total_r_popmz_.gph"	"$graphs/female_r_popmz_.gph"	"$graphs/male_r_popmz_.gph" , altshrink ///
				  title(RD: per gender with CG2 comparisson) subtitle("$`1'")   ///
				  t1title("total              		female              		male") ///
				  l1title("R_pop(mz)	 	R_pop(fert)			Ratio_fert") /// 
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
	graph export "$graphs/rd_`1'_overview_pooled.pdf", as(pdf) replace
} //end: loop over variable list


*****************************************
* per year

foreach 1 of varlist hospital2 {
	foreach var in "r_fert_" "r_popf_" "r_popmz_" { // rows: 
		foreach j in "" "_f" "_m"  { // columns:  
			capture drop `j'_hat* AVRG`j'
			qui bys Datum control year: egen AVRG`j' = mean(`var'`1'`j') 
			qui reg `var'`1'`j' Numx Num_after after if treat == 1
			qui predict `j'_hat_linear_T
			qui reg `var'`1'`j' Numx Num_after after if control == 2
			qui predict `j'_hat_linear_C
		} // end: loop over columns (total, male, female)
		
		foreach year of numlist 2010(1)2014 {
		disp `year'
			*total		
			twoway scatter AVRG MOB_altern if treat == 1 & year == `year', color(black) || ///
				scatter AVRG MOB_altern if control == 2 & year == `year',  mcolor(black%1) msymbol(Dh) || ///
				line _hat_linear_C MOB_altern if after == 1 & year == `year', sort lpattern(dash) color(black%20) || ///
				line _hat_linear_C MOB_altern if after == 0 & year == `year', sort lpattern(dash) color(black%20) || ///
				line _hat_linear_T MOB_altern if after == 1 & year == `year', sort color(black) || ///
				line _hat_linear_T MOB_altern if after == 0 & year == `year', sort color(black) ///
				scheme(s1mono )  ///
				xtitle("")  ///
				ylabel(#5,grid) ///
				xlabel(1(2)12, val) xmtick(2(2)12) ///
				legend(label(1 "Treatment") label(2 "Control "))  legend(size(small)) ///
				legend( order(1 2)) legend(pos(5) ring(0) col(2)) ///
				xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
				saving($graphs/`year'_total_`var', replace)
	
			*female 
			twoway scatter AVRG_f MOB_altern if treat == 1 & year == `year', color(red) || ///
				scatter AVRG_f MOB_altern if control == 2 & year == `year',  mcolor(red%1) msymbol(Dh) || ///
				line _f_hat_linear_C MOB_altern if after == 1 & year == `year', sort lpattern(dash) color(red%20) || ///
				line _f_hat_linear_C MOB_altern if after == 0 & year == `year', sort lpattern(dash) color(red%20) || ///
				line _f_hat_linear_T MOB_altern if after == 1 & year == `year', sort color(red) || ///
				line _f_hat_linear_T MOB_altern if after == 0 & year == `year', sort color(red) ///
				scheme(s1mono )  ///
				xtitle("")  ///
				ylabel(#5,grid) ///
				xlabel(1(2)12, val) xmtick(2(2)12) ///
				legend(label(1 "Treatment") label(2 "Control "))  legend(size(small)) ///
				legend( order(1 2)) legend(pos(5) ring(0) col(2)) ///
				xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
				saving($graphs/`year'_female_`var', replace)
				
			*male	
			twoway scatter AVRG_m MOB_altern if treat == 1 & year == `year', color(blue) || ///
				scatter AVRG_m MOB_altern if control == 2 & year == `year',  mcolor(blue%1) msymbol(Dh) || ///
				line _m_hat_linear_C MOB_altern if after == 1 & year == `year', sort lpattern(dash) color(blue%20) || ///
				line _m_hat_linear_C MOB_altern if after == 0 & year == `year', sort lpattern(dash) color(blue%20) || ///
				line _m_hat_linear_T MOB_altern if after == 1 & year == `year', sort color(blue) || ///
				line _m_hat_linear_T MOB_altern if after == 0 & year == `year', sort color(blue) ///
				scheme(s1mono )  ///
				xtitle("")  ///
				ylabel(#5,grid) ///
				xlabel(1(2)12, val) xmtick(2(2)12) ///
				legend(label(1 "Treatment") label(2 "Control "))  legend(size(small)) ///
				legend( order(1 2)) legend(pos(5) ring(0) col(2)) ///
				xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
					saving($graphs/`year'_male_`var', replace)
		} // end: loop over years
	} // end: loop over rows (variable specification)
	
	foreach year of numlist 2010 (1) 2014 { 
		graph combine "$graphs/`year'_total_r_fert_.gph"	"$graphs/`year'_female_r_fert_.gph"	"$graphs/`year'_male_r_fert_.gph" ///
				  "$graphs/`year'_total_r_popf_.gph"	"$graphs/`year'_female_r_popf_.gph"	"$graphs/`year'_male_r_popf_.gph" ///
				  "$graphs/`year'_total_r_popmz_.gph"	"$graphs/`year'_female_r_popmz_.gph"	"$graphs/`year'_male_r_popmz_.gph" , altshrink ///
				  title(RD: per gender with CG2 comparisson) subtitle("$`1'")   ///
				  t1title("total              		female              		male") ///
				  l1title("R_pop(mz)	 	R_pop(fert)			Ratio_fert") /// 
				  scheme(s1mono)
				   *b1title("Year [Age of treatment cohort]") subtitle(Life-course perspective)
		graph export "$graphs/rd_`1'_overview_`year'.pdf", as(pdf) replace
	} // end: loop over years (2nd run, for graph combine)
} //end: loop over variable list






*average last four years 
qui gen temp = 1 if year >= 2010
	
	twoway scatter r_fert_d5 MOB_altern if treat == 1 & year == 2014, color(black) 
	
	
	|| ///
		r_fert_d5 r_fert_d5 MOB_altern if control == 2 & year == 2014,  mcolor(black%1) msymbol(Dh) || ///
		scheme(s1mono )  ///
		xtitle("")  ///
		ylabel(#5,grid) ///
		xlabel(1(2)12, val) xmtick(2(2)12) ///
		legend(label(1 "Treatment") label(2 "Control "))  legend(size(small)) ///
		legend( order(1 2)) legend(pos(5) ring(0) col(2)) ///
		xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 
		
		
		
		nodraw ///
		saving($graphs/`year'_total_`var', replace)
	






/*******************************************************************
Basic setup
qui gen temp = 1 if year >= 2010
foreach 1 of varlist r_fert_hospital2_m {
	capture drop AVRG_`1' `1'_hat_linear
	qui drop if `1' ==.
	qui bys Datum temp: egen AVRG_`1' = mean (`1')
	*qui sum `1'
	*scalar define `1'_nrobs=r(N)	
	*scalar define `1'_mean=r(mean)
	qui reg `1' Numx Num_after after
	qui predict `1'_hat_linear
	scatter AVRG_`1' Datum2 if treat == 1 &  temp == 1,  scheme(s1mono )  title(" temp ")  ///
        tline(01may1979, lw(medthick ) lpattern(solid)) ///
        xtitle("Birth month") ytitle(" `1' ")  ///
        ylabel(#5,grid) tlabel(15nov1978 (60) 15sep1979, format(%tdmy)) tmtick(15dec1978 (60) 15oct1979) ///
		ttext(4 01apr1979 "2 months", box) ttext(4 01jun1979 "6 months", box)  || ///
		line `1'_hat_linear    Datum2 if after == 1, sort color(black) lpattern(dash) || ///
		line `1'_hat_linear    Datum2 if after == 0, sort color(black) lpattern(dash)  /// 
		legend(off) //note("Notitz fuer die Geheimhaltungspruefung: Diese Graphik basiert auf `=`1'_nrobs' Beobachtungen.")
	*graph export "$graphs/R1_RD_`1'_fits.pdf", as(pdf) replace
}

