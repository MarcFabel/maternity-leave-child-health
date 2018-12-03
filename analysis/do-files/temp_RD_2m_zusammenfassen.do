// Rumspielerei mit RD

	*1) 2m zusammenfassen
	use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"

	keep if GDR == 0
	keep if treat == 1
	
	qui gen MOB_auxiliary =.
	qui replace MOB_aux = 1 if MOB == 11 | MOB ==12 
	qui replace MOB_aux = 2 if MOB == 1 | MOB == 2 
	qui replace MOB_aux = 3 if MOB == 3 | MOB == 4 
	qui replace MOB_aux = 4 if MOB == 5 | MOB == 6 
	qui replace MOB_aux = 5 if MOB == 7 | MOB == 8 
	qui replace MOB_aux = 6 if MOB == 9 | MOB == 10 
	
	label define MOB_AUX 1 "11/12" 2 "01/02" 3 "03/04" 4 "05/06" 5 "07/08" 6 "09/10"
	label val MOB_aux MOB_AUX
	
foreach 1 of  varlist d5 { 
	foreach j in "" "_f" "_m"  { // columns:  
		capture drop AVRG`j'   //
		qui bys MOB_aux: egen AVRG`j' = mean(r_fert_`1'`j') 
	} // end: loop over columns (total, male, female)
} // end 1: varlist	
	
foreach 1 of varlist d5 {	
	local yscl = "17 21"	// define scale 
	local ylbl = "18(3)21"	// define label

	twoway scatter AVRG MOB_aux if treat == 1 , color(black) || ///
		lfitci AVRG MOB_aux if treat == 1 & after == 1, color(black%12) clp(dash) clc(black%75) level(95) ||  ///
		lfitci AVRG MOB_aux if treat == 1 & after == 0, color(black%12) clp(dash) clc(black%75) level(95) ||  ///
		lfitci AVRG MOB_aux if treat == 1 & after == 1, color(black%25) clp(dash) clc(black%75) level(90) ||   ///
		lfitci AVRG MOB_aux if treat == 1 & after == 0, color(black%25) clp(dash) clc(black%75) level(90)   ///					
		scheme(s1mono ) plotregion(color(white)) ///
		xtitle("") ytitle("") ///
		ylabel(#4,grid) yscale(r(`yscl')) ///
		xlabel(1 2 3 4 5 6, val) ///
		legend(label(2 "95% CI") label(6 "90% CI")) ///
		legend(order(6 2)) ///
		legend(pos(1) ring(0) col(1)) legend(size(vsmall)) ///
		legend(region(color(none))) legend(symx(5)) ///
		xline(3.5, lw(medthick ) lpattern(solid) lcolor(cranberry))
		graph export "$graph_paper/rd_`1'_total_pooled_2M.pdf", as(pdf) replace
}		
foreach 1 of varlist d5 {	
	local yscl = "14 18"	// define scale 
	local ylbl = "15(3)21"	// define label
		
	twoway scatter AVRG_f MOB_aux if treat == 1 , color(cranberry)  || ///
		lfitci AVRG_f MOB_aux if treat == 1 & after == 1, color(cranberry%12) clp(dash) clc(cranberry%75) level(95) ||  ///
		lfitci AVRG_f MOB_aux if treat == 1 & after == 0, color(cranberry%12) clp(dash) clc(cranberry%75) level(95) ||  ///
		lfitci AVRG_f MOB_aux if treat == 1 & after == 1, color(cranberry%25) clp(dash) clc(cranberry%75) level(90) ||   ///
		lfitci AVRG_f MOB_aux if treat == 1 & after == 0, color(cranberry%25) clp(dash) clc(cranberry%75) level(90)   ///
		scheme(s1mono ) plotregion(color(white)) ///
		xtitle("") ytitle("") ///
		ylabel(#5,grid) yscale(r(`yscl')) ///
		xlabel(1 2 3 4 5 6, val) ///
		legend(label(2 "95% CI") label(6 "90% CI")) ///
		legend(order(6 2)) ///
		legend(pos(1) ring(0) col(1)) legend(size(vsmall)) ///
		legend(region(color(none))) legend(symx(5)) ///
		xline(3.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 
		graph export "$graph_paper/rd_`1'_female_pooled_2M.pdf", as(pdf) replace
}

foreach 1 of varlist d5 {
	local yscl = "19 23"	// define scale 
	local ylbl = "18(3)24"	// define label


	twoway scatter AVRG_m MOB_aux if treat == 1 , color(navy) || ///
		lfitci AVRG_m MOB_aux if treat == 1 & after == 1, color(navy%12) clp(dash) clc(navy%75) level(95) ||  ///
		lfitci AVRG_m MOB_aux if treat == 1 & after == 0, color(navy%12) clp(dash) clc(navy%75) level(95) ||  ///
		lfitci AVRG_m MOB_aux if treat == 1 & after == 1, color(navy%25) clp(dash) clc(navy%75) level(90) ||   ///
		lfitci AVRG_m MOB_aux if treat == 1 & after == 0, color(navy%25) clp(dash) clc(navy%75) level(90)   ///
		scheme(s1mono ) plotregion(color(white)) ///
		xtitle("") ytitle("") ///
		ylabel(#5,grid) yscale(r(`yscl')) ///
		xlabel(1 2 3 4 5 6, val) ///
		legend(label(2 "95% CI") label(6 "90% CI")) ///
		legend(order(6 2)) ///
		legend(pos(1) ring(0) col(1)) legend(size(vsmall)) ///
		legend(region(color(none))) legend(symx(5)) ///
		xline(3.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 
		graph export "$graph_paper/rd_`1'_male_pooled_2M.pdf", as(pdf) replace
}
*********************************
* alle selbe y labels
foreach 1 of  varlist d5 { 
	foreach j in "" "_f" "_m"  { // columns:  
		capture drop AVRG`j'   //
		qui bys MOB_aux: egen AVRG`j' = mean(r_fert_`1'`j') 
	} // end: loop over columns (total, male, female)
} // end 1: varlist	
	
foreach 1 of varlist d5 {	
	local yscl = "15 23"	// define scale 
	local ylbl = "15(3)21"	// define label

	twoway scatter AVRG MOB_aux if treat == 1 , color(black) || ///
		lfitci AVRG MOB_aux if treat == 1 & after == 1, color(black%12) clp(dash) clc(black%75) level(95) ||  ///
		lfitci AVRG MOB_aux if treat == 1 & after == 0, color(black%12) clp(dash) clc(black%75) level(95) ||  ///
		lfitci AVRG MOB_aux if treat == 1 & after == 1, color(black%25) clp(dash) clc(black%75) level(90) ||   ///
		lfitci AVRG MOB_aux if treat == 1 & after == 0, color(black%25) clp(dash) clc(black%75) level(90)   ///					
		scheme(s1mono ) plotregion(color(white)) ///
		xtitle("") ytitle("") ///
		ylabel(`ylbl',grid) yscale(r(`yscl')) ///
		xlabel(1 2 3 4 5 6, val) ///
		legend(label(2 "95% CI") label(6 "90% CI")) ///
		legend(order(6 2)) ///
		legend(pos(1) ring(0) col(1)) legend(size(vsmall)) ///
		legend(region(color(none))) legend(symx(5)) ///
		xline(3.5, lw(medthick ) lpattern(solid) lcolor(cranberry))
		graph export "$graph_paper/rd_`1'_total_pooled_2M_sameylabel.pdf", as(pdf) replace
		
	twoway scatter AVRG_f MOB_aux if treat == 1 , color(cranberry)  || ///
		lfitci AVRG_f MOB_aux if treat == 1 & after == 1, color(cranberry%12) clp(dash) clc(cranberry%75) level(95) ||  ///
		lfitci AVRG_f MOB_aux if treat == 1 & after == 0, color(cranberry%12) clp(dash) clc(cranberry%75) level(95) ||  ///
		lfitci AVRG_f MOB_aux if treat == 1 & after == 1, color(cranberry%25) clp(dash) clc(cranberry%75) level(90) ||   ///
		lfitci AVRG_f MOB_aux if treat == 1 & after == 0, color(cranberry%25) clp(dash) clc(cranberry%75) level(90)   ///
		scheme(s1mono ) plotregion(color(white)) ///
		xtitle("") ytitle("") ///
		ylabel(`ylbl',grid) yscale(r(`yscl')) ///
		xlabel(1 2 3 4 5 6, val) ///
		legend(label(2 "95% CI") label(6 "90% CI")) ///
		legend(order(6 2)) ///
		legend(pos(1) ring(0) col(1)) legend(size(vsmall)) ///
		legend(region(color(none))) legend(symx(5)) ///
		xline(3.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 
		graph export "$graph_paper/rd_`1'_female_pooled_2M_sameylabel.pdf", as(pdf) replace


	twoway scatter AVRG_m MOB_aux if treat == 1 , color(navy) || ///
		lfitci AVRG_m MOB_aux if treat == 1 & after == 1, color(navy%12) clp(dash) clc(navy%75) level(95) ||  ///
		lfitci AVRG_m MOB_aux if treat == 1 & after == 0, color(navy%12) clp(dash) clc(navy%75) level(95) ||  ///
		lfitci AVRG_m MOB_aux if treat == 1 & after == 1, color(navy%25) clp(dash) clc(navy%75) level(90) ||   ///
		lfitci AVRG_m MOB_aux if treat == 1 & after == 0, color(navy%25) clp(dash) clc(navy%75) level(90)   ///
		scheme(s1mono ) plotregion(color(white)) ///
		xtitle("") ytitle("") ///
		ylabel(`ylbl',grid) yscale(r(`yscl')) ///
		xlabel(1 2 3 4 5 6, val) ///
		legend(label(2 "95% CI") label(6 "90% CI")) ///
		legend(order(6 2)) ///
		legend(pos(1) ring(0) col(1)) legend(size(vsmall)) ///
		legend(region(color(none))) legend(symx(5)) ///
		xline(3.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 
		graph export "$graph_paper/rd_`1'_male_pooled_2M_sameylabel.pdf", as(pdf) replace
}	


////////////////////////////////////////////////////////////////////////////
// 	HOSPITAL
////////////////////////////////////////////////////////////////////////////


foreach 1 of  varlist hospital2 { 
	foreach j in "" "_f" "_m"  { // columns:  
		capture drop AVRG`j'   //
		qui bys MOB_aux: egen AVRG`j' = mean(r_fert_`1'`j') 
	} // end: loop over columns (total, male, female)
} // end 1: varlist	
	
foreach 1 of varlist hospital2 {	
	local yscl = "110 130"	// define scale 
	local ylbl = "18(3)21"	// define label

	twoway scatter AVRG MOB_aux if treat == 1 , color(black) || ///
		lfitci AVRG MOB_aux if treat == 1 & after == 1, color(black%12) clp(dash) clc(black%75) level(95) ||  ///
		lfitci AVRG MOB_aux if treat == 1 & after == 0, color(black%12) clp(dash) clc(black%75) level(95) ||  ///
		lfitci AVRG MOB_aux if treat == 1 & after == 1, color(black%25) clp(dash) clc(black%75) level(90) ||   ///
		lfitci AVRG MOB_aux if treat == 1 & after == 0, color(black%25) clp(dash) clc(black%75) level(90)   ///					
		scheme(s1mono ) plotregion(color(white)) ///
		xtitle("") ytitle("") ///
		ylabel(#4,grid) yscale(r(`yscl')) ///
		xlabel(1 2 3 4 5 6, val) ///
		legend(label(2 "95% CI") label(6 "90% CI")) ///
		legend(order(6 2)) ///
		legend(pos(1) ring(0) col(1)) legend(size(vsmall)) ///
		legend(region(color(none))) legend(symx(5)) ///
		xline(3.5, lw(medthick ) lpattern(solid) lcolor(cranberry))
		graph export "$graph_paper/rd_`1'_total_pooled_2M.pdf", as(pdf) replace
}		
foreach 1 of varlist hospital2 {	
	local yscl = "110 130"	// define scale 
	local ylbl = "15(3)21"	// define label
		
	twoway scatter AVRG_f MOB_aux if treat == 1 , color(cranberry)  || ///
		lfitci AVRG_f MOB_aux if treat == 1 & after == 1, color(cranberry%12) clp(dash) clc(cranberry%75) level(95) ||  ///
		lfitci AVRG_f MOB_aux if treat == 1 & after == 0, color(cranberry%12) clp(dash) clc(cranberry%75) level(95) ||  ///
		lfitci AVRG_f MOB_aux if treat == 1 & after == 1, color(cranberry%25) clp(dash) clc(cranberry%75) level(90) ||   ///
		lfitci AVRG_f MOB_aux if treat == 1 & after == 0, color(cranberry%25) clp(dash) clc(cranberry%75) level(90)   ///
		scheme(s1mono ) plotregion(color(white)) ///
		xtitle("") ytitle("") ///
		ylabel(#5,grid) yscale(r(`yscl')) ///
		xlabel(1 2 3 4 5 6, val) ///
		legend(label(2 "95% CI") label(6 "90% CI")) ///
		legend(order(6 2)) ///
		legend(pos(1) ring(0) col(1)) legend(size(vsmall)) ///
		legend(region(color(none))) legend(symx(5)) ///
		xline(3.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 
		graph export "$graph_paper/rd_`1'_female_pooled_2M.pdf", as(pdf) replace
}

foreach 1 of varlist hospital2 {
	local yscl = "110 130"	// define scale 
	local ylbl = "18(3)24"	// define label


	twoway scatter AVRG_m MOB_aux if treat == 1 , color(navy) || ///
		lfitci AVRG_m MOB_aux if treat == 1 & after == 1, color(navy%12) clp(dash) clc(navy%75) level(95) ||  ///
		lfitci AVRG_m MOB_aux if treat == 1 & after == 0, color(navy%12) clp(dash) clc(navy%75) level(95) ||  ///
		lfitci AVRG_m MOB_aux if treat == 1 & after == 1, color(navy%25) clp(dash) clc(navy%75) level(90) ||   ///
		lfitci AVRG_m MOB_aux if treat == 1 & after == 0, color(navy%25) clp(dash) clc(navy%75) level(90)   ///
		scheme(s1mono ) plotregion(color(white)) ///
		xtitle("") ytitle("") ///
		ylabel(#5,grid) yscale(r(`yscl')) ///
		xlabel(1 2 3 4 5 6, val) ///
		legend(label(2 "95% CI") label(6 "90% CI")) ///
		legend(order(6 2)) ///
		legend(pos(1) ring(0) col(1)) legend(size(vsmall)) ///
		legend(region(color(none))) legend(symx(5)) ///
		xline(3.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 
		graph export "$graph_paper/rd_`1'_male_pooled_2M.pdf", as(pdf) replace
}
******************************************************
* Residuals
