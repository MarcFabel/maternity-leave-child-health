	clear all
	set more off
	
	global path   "F:\econ\m-l-c-h/analysis"	
	global temp   "$path/temp"
	global graphs "$path/graphs/KKH"
	global tables "$path/tables/KKH"
	global graph_paper 	"$path/graphs/paper"
	global auxiliary 	"$path/do-files/auxiliary_files"
	
	*magic numbers
	global first_year = 2005
	global last_year  = 2013
	
	
	
	
	
// TREATMENT & control group(OHNE ALTERSVERSCHIEBUNG!!!!)
use "$temp/KKH_final_R1", clear
run "$auxiliary/varlists_varnames_sample-spcifications"

keep if GDR == 0 
keep if control == 2 | control == 4
keep if after == 0
keep if year >= 1996


*label
	#delim ;
	label define YEAR 
		1995 "16"
		1996 "17"
		1997 "18"
		1998 "19"
		1999 "20"
		2000 "21"
		2001 "22"
		2002 "23"
		2003 "24"
		2004 "25"
		2005 "26"
		2006 "27"
		2007 "28"
		2008 "29"
		2009 "30"
		2010 "31"
		2011 "32"
		2012 "33"
		2013 "34"
		2014 "35";
	#delim cr
	label values year YEAR

collapse (mean) length_of_stay length_of_stay_m length_of_stay_f ///
	share_surgery share_surgery_m share_surgery_f ///
	(sum) hospital2 hospital2_m hospital2_f, by(year control)
 
qui replace share_surgery = share_surgery *100
qui gen share_f = hospital2_f*100 / hospital2 
qui gen share_m = hospital2_m*100 / hospital2
qui replace hospital2 = hospital2 / 1000

*Panel A: Hospital admission 
line hospital2 year if control == 4, color(black) lw(medthick) || ///
	scatter hospital2 year  if control == 4, color(gs6) m(O) || ///
	line hospital2 year if control == 2, color(black%20) lw(medthick) lp(dash) || ///
	scatter hospital2 year  if control == 2, color(gs6%20) m(O)  ///
	title("Panel A. Number of admissions",pos(11) span  size(vlarge)) ///
	ytitle(" Number of hospital admissions [in thousand]") subtitle(" ") ///
	xtitle("Age") ///
	legend(off) ///
	xlabel(1996 (3) 2014 ,val angle(0)) ///
	xmtick(1996 (1) 2014)  ///
	ylabel(#4) /// 
	plotregion(color(white)) scheme(s1mono) ///
	saving($graphs/descriptive_A_admission_TCG, replace) 
	
*Panel B: Relative frequency women 
line share_f year if control == 4, color(black) lw(medthick) || ///
	scatter share_f year if control == 4, color(gs6) m(O) || ///
	line share_f year if control == 2, color(black%20) lw(medthick) lp(dash) || ///
	scatter share_f year if control == 2, color(gs6%20) m(O)  ///
	title("Panel B. Share women",pos(11) span  size(vlarge)) ///
	ytitle("Share women [in percent]") subtitle(" ") ///
	xtitle("Age") /// 
	xlabel(1996 (3) 2014 ,val angle(0)) ///
	xmtick(1996 (1) 2014)  ///
	plotregion(color(white)) scheme(s1mono) ///
	legend(label(1 "treatment") label(3 "control") ///
	order(1 3) col(1)  pos(1) ring(0) size(medium)	) ///
	saving($graphs/descriptive_B_women_TCG, replace) 

	
* Panel C: Length of Stay 	
line length_of_stay year if control == 4, sort color(black) lw(medthick) || ///
	scatter length_of_stay year if control == 4, sort color(gs6) m(O) || ///
	line length_of_stay year if control == 2, sort color(black%20) lw(medthick) lp(dash) || ///
	scatter length_of_stay year if control == 2, sort color(gs6%20) m(O) ///
	title("Panel C. Average length of stay",pos(11) span  size(vlarge)) subtitle(" ") ///
	ytitle("Average length of stay [in days]") ///
	xtitle("Age") /// 
	legend(off) ///
	xlabel(1996 (3) 2014 ,val angle(0)) ///
	xmtick(1996 (1) 2014)  ///
	plotregion(color(white)) scheme(s1mono) ///
	saving($graphs/descriptive_C_staylength_TCG, replace) 
	
	
*Panel D: Surgery
line share_surgery year if control == 4, sort color(black) lw(medthick) || ///
	scatter share_surgery year if control == 4, sort color(gs6) m(O) || ///
	line share_surgery year if control == 2, sort color(black%20) lw(medthick) lp(dash) || ///
	scatter share_surgery year if control == 2, sort color(gs6%20) m(O)  ///
	title("Panel D. Share surgery",pos(11) span  size(vlarge)) subtitle(" ") ///
	ytitle("Share surgery [in percent]") ///
	xtitle("Age") /// 
	legend(off) ///
	xlabel(1996 (3) 2014 ,val angle(0)) ///
	xmtick(1996 (1) 2014)  ///
	plotregion(color(white)) scheme(s1mono) ///	
	saving($graphs/descriptive_D_surgery_TCG, replace)  
	
	graph combine "$graphs/descriptive_A_admission_TCG"		"$graphs/descriptive_B_women_TCG.gph"			///
				  "$graphs/descriptive_C_staylength_TCG.gph" 			  "$graphs/descriptive_D_surgery_TCG.gph"	, altshrink ///
				  scheme(s1mono) plotregion(color(white)) col(2)
graph export "$graph_paper/descriptive_admission_TCG.pdf", as(pdf) replace		