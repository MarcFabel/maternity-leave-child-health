clear all 


/*
	Dieses Do-file generiert einen Graphen der für eine Geburtskohorte dartsellt
	wie sich die Unterdiagnosegruppen von mentalen Krankheiten über die Zeit 
	entwickeln.
*/

use "$temp/KKH_final_gdr_level", clear
 
keep if GDR == 0 
keep if treat == 1 | control == 2

collapse (sum)  d5 organic drug_abuse shizophrenia affective neurosis ///
	phys_factors personality retardation development childhood , by(year control)


qui gen temp1 = organic + drug_abuse + shizophrenia + affective + neurosis + phys_factors ///
	+ personality + retardation + development + childhood
	

qui gen rest = d5 - drug - shizo - affect - neurosis - personality 
keep if control == 4	
	
	
keep if control == 4

	
* area graph 1
qui gen t1 = rest 
qui gen t2 = t1 + personality
qui gen t3 = t2 + neurosis 
qui gen t4 = t3 + affective 
qui gen t5 = t4 + shizo 
qui gen t6 = t5 + drug_abuse




* area graph 2
qui gen rest2 = d5 - drug - shizo - affect - neurosis - personality - childhood

qui gen s0 = rest2
qui gen s1 = s0 + childhood 
qui gen s2 = s1 + personality
qui gen s3 = s2 + neurosis 
qui gen s4 = s3 + affective 
qui gen s5 = s4 + shizo 
qui gen s6 = s5 + drug_abuse


*label
	#delim ;
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
	#delim cr
	label values year YEAR


twoway area t6 year, color(navy) || ///
	area t5  year, color(maroon) || ///
	area t4 year, color( forest_green) ||  ///
	area t3 year, color(dkorange) || ///
	area t2 year, color(emerald) || ///
	area t1 year, color(gs12) ///
	scheme(s1mono) plotregion(color(white)) ///
	ytitle("All mental and behavioral disorders") ///
	legend(c(3) lab(1 "psychoactive substances") lab(2 "schizophrenia") lab(3 "affective") ///
	lab(4 "neurosis") lab(5 "personality") lab(6 "other")) ///
	legend(size(small)) ///
	xlabel(1996 (4) 2014 ,val angle(0)) ///
	xmtick(1996 (2) 2014)  ///
	ylabel(, format(%9.0f)) ///
	saving($graphs/d5partition_top5_$date,replace)


	
	
* graph mit childhood noch im graph 
twoway area s6 year, color(navy) || ///
	area s5  year, color(maroon) || ///
	area s4 year, color( forest_green) ||  ///
	area s3 year, color(dkorange) || ///
	area s2 year, color(emerald) || ///
	area s1 year, color(cranberry) || ///
	area s0 year, color(gs12) ///
	scheme(s1mono) plotregion(color(white)) ///
	ytitle("All mental and behavioral disorders") ///
	legend(c(3) lab(1 "psychoactive substances") lab(2 "schizophrenia") lab(3 "affective") ///
	lab(4 "neurosis") lab(5 "personality") lab(6 "childhood") lab(7 "other")) ///
	legend(size(small)) ///
	xlabel(1996 (4) 2014 ,val angle(0)) ///
	xmtick(1996 (2) 2014)  ///
	ylabel(, format(%9.0f))	///
	saving($graphs/d5partition_top6_$date,replace)
	

	 
