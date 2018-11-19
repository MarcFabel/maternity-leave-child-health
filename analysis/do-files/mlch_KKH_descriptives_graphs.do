/*******************************************************************************
* File name: 	mlch_KKH_descriptive_graphs
* Author: 		Marc Fabel
* Date: 		20.11.2017
* Description:	twoway area
*				
*				
*				
*
* Inputs:  		$temp\KKH_final_R1_long
*				
* Outputs:		$graphs/
*				$tables/
*
* Updates:		
*

*******************************************************************************/

// ***************************** PREAMBLE********************************
	clear all
	set more off
	
	global path   "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis"	
	global temp   "$path/temp"
	global graphs "$path/graphs/KKH"
	global tables "$path/tables/KKH"
	
	*magic numbers
	global first_year = 2005
	global last_year  = 2013
	
// ***********************************************************************

use "$temp\KKH_final_R1_long", clear

	
//just for treated cohort
keep if treat == 1



//collapse over MOB , per each gender
collapse (sum) D_*     , by(year ) 

global Kapitel = "D_1 D_2 D_5 D_6 D_7 D_8 D_9 D_10 D_11 D_12 D_13 D_14 D_17 D_18"
local lngth = wordcount("$Kapitel")
disp `lngth'



local j = 1
qui gen temp0 = 0
foreach var of varlist $Kapitel { 
	local i = `j'-1
	qui gen temp`j' = temp`i' + `var'
	local j = `j' + 1 
}


//Display - NOT PERFECT THOUGH!
local j = 1
disp "twoway ///" 
while `j'< `lngth' {
	local i = `j'-1
	disp "		(rarea temp`i' temp`j' year, vertical) ///
	local j = `j' + 1
}

/*
twoway  (rarea temp0  temp1  year, vertical) ///
		(rarea temp1  temp2  year, vertical) ///
		(rarea temp2  temp3  year, vertical) ///
		(rarea temp3  temp4  year, vertical) ///
		(rarea temp4  temp5  year, vertical) ///
		(rarea temp5  temp6  year, vertical) ///
		(rarea temp6  temp7  year, vertical) ///
		(rarea temp7  temp8  year, vertical) ///
		(rarea temp8  temp9  year, vertical) ///
		(rarea temp9  temp10 year, vertical) ///
		(rarea temp10 temp11 year, vertical) ///
		(rarea temp11 temp12 year, vertical) ///
		(rarea temp12 temp13 year, vertical) ///
		(rarea temp13 temp14 year, vertical)
		
		
		// graph: area plot
		
		// alternative: spaghetti style
*/
// ***********************************************************************
		
/// PERENT HOPSITAL ADMISSION, PER GENDER
	clear all
	set more off
	set processors 4
	
	*global path  "F:\econ\m-l-c-h\analysis"					//Work
	global path  "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis"	//MAC
	
	global temp  		"$path/temp"
	global KKH   		"$path/source" 
	global graph 		"$path/graphs/KKH" 
	global landesamt	"$path/graphs/LfStat_Ausgabe"
	global tables 		"$path/tables/KKH"
	global graph_paper 	"$path/graphs/paper" 
	global auxiliary 	"$path/do-files/auxiliary_files"
	
	
	*magic numbers
	global first_year = 1995
	global last_year  = 2014
// ***********************************************************************

* *************open data  *************
use "$temp/KKH_final_R1", clear
run "$auxiliary/varlists_varnames_sample-spcifications"


/*
	Dieses Do-file generiert einen Graphen der für eine Geburtskohorte dartsellt
	wie sich die Unterdiagnosegruppen von mentalen Krankheiten über die Zeit 
	entwickeln.
*/


keep if GDR == 0 
keep if control == 4	


collapse (sum) hospital2 hospital2_m hospital2_f, by(year )

qui gen share_f = hospital2_f*100 / hospital2 
qui gen share_m = hospital2_m*100 / hospital2


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

* Version 1: just shares female male
line share_f year, color(cranberry) || ///
	line share_m year, color(navy) ///
	ytitle("hospital admission [percent]") ///
	legend(c(1) lab(1 "female") lab(2 "male") ) ///
	legend(size(vsmall)) legend(pos(2) ring(0) col(1)) ///
	xlabel(1996 (4) 2014 ,val angle(0)) ///
	xmtick(1996 (2) 2014)  ///
	ylabel(45 47.5 50 52.5 55, grid glc(gs12) glw(vthin))
	graph export "$graph_paper/hospitaladmission_genderpercent.pdf", as(pdf) replace

*Version 2: shares PLUS TOTAL NUMBER OF ADMISSIONS
qui replace hospital2 = hospital2 / 1000

line hospital2 year, sort color(gs13) yaxis(2) lw(vthick) || ///
	line share_f year, sort  color(cranberry) yaxis(1) || ///
	line share_m year, sort color(navy) yaxis(1) ///
	ytitle("hospital admission, per gender [percent]", axis(1)) ///
	ytitle("hospital admission [abs. numbers, in thousand]", axis(2)) ///
	xtitle("year [age of treatment cohort]") /// 
	legend(c(1) lab(2 "female [%]") lab(3 "male [%]") lab(1 "total")) ///
	legend(order(2 3 1)) /// 
	legend(size(vsmall)) legend(pos(5) ring(0) col(1)) ///
	xlabel(1996 (4) 2014 ,val angle(0)) ///
	xmtick(1996 (2) 2014)  ///
	ylabel(45 47.5 50 52.5 55, nogrid  axis(1)) ///
	scheme(s1mono) yscale(alt axis(2)) yscale(alt axis(1))
	graph export "$graph_paper/hospitaladmission_genderpercent_total.pdf", as(pdf) replace

 
 **********************************
 //Verweildauer & op
 use "$temp/KKH_final_R1", clear
run "$auxiliary/varlists_varnames_sample-spcifications"


/*
	Dieses Do-file generiert einen Graphen der für eine Geburtskohorte dartsellt
	wie sich die Unterdiagnosegruppen von mentalen Krankheiten über die Zeit 
	entwickeln.
*/


keep if GDR == 0 
keep if control == 4	


collapse (mean) length_of_stay length_of_stay_m length_of_stay_f ///
	share_surgery share_surgery_m share_surgery_f ///
	(sum) hospital2 hospital2_m hospital2_f, by(year )
 
 qui replace share_surgery = share_surgery *100
 *graph
 *line hospital2 year, sort color(gs13) yaxis(3) lw(vthick) || ///
 line share_surgery year, sort  color(forest_green) yaxis(1) || ///
	line length_of_stay year, sort color(dkorange) yaxis(2) ///
	ytitle("share surgery [percent]", axis(1)) ///
	ytitle("average length of stay [in days]", axis(2)) ///
	xtitle("year [age of treatment cohort]") /// 
	legend(lab(1 "surgery") lab(2 "length")) ///
	legend(size(small)) legend(pos(3) ring(0) col(1)) ///
	xlabel(1996 (4) 2014 ,val angle(0)) ///
	xmtick(1996 (2) 2014)  ///
	scheme(s1mono)
	graph export "$graph_paper/surgery_lengthofstay.pdf", as(pdf) replace

	
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//19.10.2018 Graph combine: description of variables in data set

* *************open data  *************
use "$temp/KKH_final_R1", clear
run "$auxiliary/varlists_varnames_sample-spcifications"

keep if GDR == 0 
keep if control == 4	

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

collapse (mean) length_of_stay length_of_stay_m length_of_stay_f ///
	share_surgery share_surgery_m share_surgery_f ///
	(sum) hospital2 hospital2_m hospital2_f, by(year )
 
qui replace share_surgery = share_surgery *100
qui gen share_f = hospital2_f*100 / hospital2 
qui gen share_m = hospital2_m*100 / hospital2
qui replace hospital2 = hospital2 / 1000

*Panel A: Hospital admission 
line hospital2 year, color(black) lw(medthick) || ///
	scatter hospital2 year, color(gs6) m(O) ///
	title("Panel A. Number of admissions",pos(11) span  size(vlarge)) ///
	ytitle(" Number of hospital admissions [in thousand]") subtitle(" ") ///
	xtitle("") ///
	legend(off) ///
	xlabel(1996 (4) 2014 ,val angle(0)) ///
	xmtick(1996 (2) 2014)  ///
	ylabel(, grid glc(gs12) glw(vthin)) /// 
	plotregion(color(white)) scheme(s1mono) ///
	saving($graph/descriptive_A_admission, replace) 
	
*Panel B: Relative frequency women 
line share_f year, color(black) lw(medthick) || ///
	scatter share_f year, color(gs6) m(O) ///
	title("Panel B. Share women",pos(11) span  size(vlarge)) ///
	ytitle("Share women [in percent]") subtitle(" ") ///
	xtitle("") /// 
	legend(off) ///
	xlabel(1996 (4) 2014 ,val angle(0)) ///
	xmtick(1996 (2) 2014)  ///
	ylabel(, grid glc(gs12) glw(vthin)) ///
	plotregion(color(white)) scheme(s1mono) ///
	saving($graph/descriptive_B_women, replace) 

	
* Panel C: Length of Stay 	
line length_of_stay year, sort color(black) lw(medthick) || ///
	scatter length_of_stay year, sort color(gs6) m(O) ///
	title("Panel C. Average length of stay",pos(11) span  size(vlarge)) subtitle(" ") ///
	ytitle("Average length of stay [in days]") ///
	xtitle("") /// 
	legend(off) ///
	xlabel(1996 (4) 2014 ,val angle(0)) ///
	xmtick(1996 (2) 2014)  ///
	ylabel(, grid glc(gs12) glw(vthin)) ///
	plotregion(color(white)) scheme(s1mono) ///
	saving($graph/descriptive_C_staylength, replace) 
	
	
*Panel D: Surgery
line share_surgery year, sort color(black) lw(medthick) || ///
	scatter share_surgery year, sort color(gs6) m(O) ///
	title("Panel D. Share surgery",pos(11) span  size(vlarge)) subtitle(" ") ///
	ytitle("Share surgery [in percent]") ///
	xtitle("") /// 
	legend(off) ///
	xlabel(1996 (4) 2014 ,val angle(0)) ///
	xmtick(1996 (2) 2014)  ///
	ylabel(, grid glc(gs12) glw(vthin)) ///
	plotregion(color(white)) scheme(s1mono) ///	
	saving($graph/descriptive_D_surgery, replace)  
		
	
	graph combine "$graph/descriptive_A_admission"			"$graph/descriptive_B_women.gph"			///
				  "$graph/descriptive_C_staylength.gph" 			  "$graph/descriptive_D_surgery.gph"	, altshrink ///
				  scheme(s1mono) plotregion(color(white))
	graph export "$graph_paper/descriptive_admission.pdf", as(pdf) replace

* mit deaths vom Landesamt
	graph combine "$graph/descriptive_A_admission"			"$graph/descriptive_B_women.gph"			///
				  "$graph/descriptive_C_staylength.gph" 			  "$graph/descriptive_D_surgery.gph" ///
				  "$landesamt/descriptive_E_death_22Oct18.gph", altshrink ///
				  scheme(s1mono) plotregion(color(white)) col(2) ysize(15) xsize(12)
	graph export "$graph_paper/descriptive_admission.pdf", as(pdf) replace
