// Einlesen von life-koursen der unterkategorien
clear all
	set more off
	
	global path   "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis"	
	global temp   "$path/temp"
	global graphs "$path/graphs/KKH"
	
	
	
	global t_90		  = 1.645
	global t_95   	  = 1.960

	
/*	
* 	missing label für year
*	
*/

import delimited "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h\analysis\do-files\GWAP_analyse\D_Ergebnisse\TABLES\drug_abuse_lc_yrs_brckts.csv", ///
 varnames(1) clear

 qui gen temp = _n 
 qui drop if temp == 1
 order bandwidth
 qui destring, replace
 qui drop v1
 
 * Exemplarisch für bandwidth = 6 
 qui keep if bandwidth == 6
 
 foreach j in "" "_f" "_m" { // "_f" "_m" 	
	qui gen CIL95`j' = (beta`j'- $t_95 * se`j')
	qui gen CIR95`j' = (beta`j'+ $t_95 * se`j')
	qui gen CIL90`j' = (beta`j'- $t_90 * se`j')
	qui gen CIR90`j' = (beta`j'+ $t_90 * se`j')
} // end: tfm 	

keep if year > 1995 

* total
twoway line diagnoses year , sort color(gs14) lw(vthick) yaxis(2)  || ///
	rarea CIL95 CIR95 year, sort  color(black%12) yaxis(1) || ///
	rarea CIL90 CIR90 year, sort  color(black%25) yaxis(1) || ///
	line beta year, sort color(black) yaxis(1) ///
	yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
	scheme(s1mono) title("Total", box bexpand) ///
	ytitle("Drug", axis(1) box bexpand size(large)) /// 
	ytitle("", axis(2)) ///
	legend(off) ///
	xlabel(1996 (4) 2012 ,val angle(0)) xtitle("") ///
	xmtick(1998  (4) 2014) ///
	yscale(alt axis(2)) yscale(alt axis(1)) ///
	xscale(range(1995 2015)) /// 
	saving($graphs/lc_drugs,replace)
	
	
*female 
twoway line diagnoses_f year , sort color(gs14) lw(vthick) yaxis(2)  || ///
	rarea CIL95_f CIR95_f year, sort  color(cranberry%12) yaxis(1) || ///
	rarea CIL90_f CIR90_f year, sort  color(cranberry%25) yaxis(1) || ///
	line beta_f year, sort color(cranberry) yaxis(1) ///
	yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
	scheme(s1mono) title("Female", box bexpand) ///
	ytitle("", axis(1)) /// 
	ytitle("", axis(2)) ///
	legend(off) ///
	xlabel(1996 (4) 2012 ,val angle(0)) xtitle("") ///
	xmtick(1998  (4) 2014) ///
	yscale(alt axis(2)) yscale(alt axis(1)) ///
	xscale(range(1995 2015)) /// 
	saving($graphs/lc_drugs_f,replace)	
	
*male 
twoway line diagnoses_m year , sort color(gs14) lw(vthick) yaxis(2)  || ///
	rarea CIL95_m CIR95_m year, sort  color(navy%12) yaxis(1) || ///
	rarea CIL90_m CIR90_m year, sort  color(navy%25) yaxis(1) || ///
	line beta_m year, sort color(navy) yaxis(1) ///
	yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
	scheme(s1mono) title("Male", box bexpand) ///
	ytitle("", axis(1)) /// 
	ytitle("", axis(2)) ///
	legend(off) ///
	xlabel(1996 (4) 2012 ,val angle(0)) xtitle("") ///
	xmtick(1998  (4) 2014) ///
	yscale(alt axis(2)) yscale(alt axis(1)) ///
	xscale(range(1995 2015)) /// 
	saving($graphs/lc_drugs_m,replace)
	
graph combine "$graphs/lc_drugs" "$graphs/lc_drugs_f" "$graphs/lc_drugs_m" , row(1) xsize(9) ysize(3) imargin(zero)
