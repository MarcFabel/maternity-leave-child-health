********************************************************************************
*			RF - z scores
********************************************************************************

//generate standardized variable
 sum d5 if control == 2
 qui gen z_d5 = (d5 - r(mean))/r(sd)
 
 sum r_fert_d5 if control == 2 
 qui gen z_r_fert_d5 = (r_fert_d5 - r(mean))



foreach 1 of varlist r_fert_d5 {
	foreach var in ""  { // rows: "r_fert_" "r_popf_" 
		foreach j in ""  { // columns:  "_f" "_m" 
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
			xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 
			
			////
			*saving($graphs/total_`var', replace)

		
	} // end: loop over rows (variable specification)
	
	
} //end: loop over variable list
