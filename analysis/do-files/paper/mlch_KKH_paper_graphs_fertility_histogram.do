// ***************************** PREAMBLE********************************
/*
	Macht zwei feritllity histogramme von den DESTATIS DATEN;
	BENUTZT DABEI DEN NORMALEN DATENSATZ

*/	
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

keep if treat == 1 | control == 2
keep if GDR == 0
keep if year == 1995

keep YOB MOB Datum Datum2 fert fertf fertm control

* birth numbers in thousand
foreach var of varlist fert* {
	qui replace `var' = `var'/1000
}

* Histogram für control group
twoway bar fert Datum if control == 2, yscale(r(0 55)) xaxis(2) ///
	scheme(s1mono) plotregion(color(white)) ///
	fcolor(gs2%45) lc(gs1) lw(thin)  ///
	barw(1) ///
	tlabel(1977m11 (2) 1978m9, axis(2))  ///
	tmtick(1977m12 (2) 1978m10, axis(2)) ///
	xtitle("Month of birth", axis(2)) ///
	legend(off) ytitle("Number of births [in thousand]") ///	
	lcolor(black) lw(thin) ///
	|| ///
	bar fert Datum2 if control ==2, xaxis(1) barw(0) /// 
	tline(01may1978, lw(medthick) lpattern(dash) lstyle(foreground)) ///
	ylabel(#5,grid) tlabel(none, axis(1) format(%tdmy)) ///
	xtitle("", axis(1)) yscale(r(0 .15)) ///
	xscale( axis(1) lc(white)) ///
	ylabel(#5) ///
	saving($graphs/temp1, replace)
	graph export "$graph_paper/fertility_histogram_CG.pdf", as(pdf) replace
	

*histogram for treatment group
twoway bar fert Datum if control == 4, xaxis(2) ///
	scheme(s1mono) plotregion(color(white)) ///
	fcolor(gs2%45) lc(gs1) lw(thin)  ///	
	barw(1) ///
	tlabel(1978m11 (2) 1979m9, axis(2))  ///
	tmtick(1978m12 (2) 1979m10, axis(2)) ///
	xtitle("Month of birth", axis(2)) ///
	legend(off) ytitle("Number of births [in thousand]") ///	
	|| ///
	bar fert Datum2 if control ==4, xaxis(1) barw(0) /// 
	tline(01may1979, lw(medthick) lpattern(solid) lstyle(foreground) lcolor(cranberry)) ///
	ylabel(#5,grid) tlabel(none, axis(1) format(%tdmy)) ///
	xscale( axis(1) lc(white)) ///
	xtitle("", axis(1))  yscale(r(0 60))  ///
	ttext(57 01apr1979 "2 months", box margin(small)) ///
	ttext(57 01jun1979 "6 months", box margin(small))  ylabel(#5) ///
	saving($graphs/temp2, replace)
	
	graph export "$graph_paper/fertility_histogram_TG.pdf", as(pdf) replace
*	
	
*	
graph combine "$graphs/temp1" "$graphs/temp2", col(2) xsize(15) ysize(5)
	
	
********************************************************************************
//	Number of births per day

use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"

keep if treat == 1 | control == 2
keep if GDR == 0
keep if year == 1995

keep YOB MOB Datum Datum2 fert fertf fertm control
* days in month (keine Schaltjahre)
qui gen days = .
qui replace days = 31 if MOB == 1
qui replace days = 28 if MOB == 2
qui replace days = 31 if MOB == 3
qui replace days = 30 if MOB == 4
qui replace days = 31 if MOB == 5
qui replace days = 30 if MOB == 6
qui replace days = 31 if MOB == 7
qui replace days = 31 if MOB == 8
qui replace days = 30 if MOB == 9
qui replace days = 31 if MOB == 10
qui replace days = 30 if MOB == 11
qui replace days = 31 if MOB == 12

qui gen fert_perday = fert / days


twoway bar fert_perday Datum if control == 2, yscale(r(0 1700)) xaxis(2) ///
	scheme(s1mono) plotregion(color(white)) ///
	fcolor(gs2%45) lc(gs1) lw(thin)  ///
	barw(1) ///
	tlabel(1977m11 (2) 1978m9, axis(2))  ///
	tmtick(1977m12 (2) 1978m10, axis(2)) ///
	xtitle("Month of birth", axis(2)) ///
	legend(off) ytitle("Number of births per day") ///	
	lcolor(black) lw(thin) ///
	|| ///
	bar fert_perday Datum2 if control ==2, xaxis(1) barw(0) /// 
	tline(01may1978, lw(medthick) lpattern(dash) lstyle(foreground)) ///
	ylabel(0 (500) 2000,grid) tlabel(none, axis(1) format(%tdmy)) ///
	xtitle("", axis(1)) ///
	xscale( axis(1) lc(white)) ///
	ylabel(#5) ///
	saving($graphs/temp1, replace)
	graph export "$graph_paper/fertility_per_day_histogram_CG.pdf", as(pdf) replace
		
*histogram for treatment group
twoway bar fert_perday Datum if control == 4, xaxis(2) ///
	scheme(s1mono) plotregion(color(white)) ///
	fcolor(gs2%45) lc(gs1) lw(thin)  ///	
	barw(1) ///
	tlabel(1978m11 (2) 1979m9, axis(2))  ///
	tmtick(1978m12 (2) 1979m10, axis(2)) ///
	xtitle("Month of birth", axis(2)) ///
	legend(off) ytitle("Number of births per day") ///	
	|| ///
	bar fert_perday Datum2 if control ==4, xaxis(1) barw(0) /// 
	tline(01may1979, lw(medthick) lpattern(solid) lstyle(foreground) lcolor(cranberry)) ///
	ylabel(#5,grid) tlabel(none, axis(1) format(%tdmy)) ///
	xscale( axis(1) lc(white)) ///
	xtitle("", axis(1))  yscale(r(0 60))  ///
	ttext(1900 01apr1979 "2 months", box margin(small)) ///
	ttext(1900 01jun1979 "6 months", box margin(small))  ylabel(#5) ///
	saving($graphs/temp2, replace)
	
	graph export "$graph_paper/fertility_per_day_histogram_TG.pdf", as(pdf) replace
*	
	
