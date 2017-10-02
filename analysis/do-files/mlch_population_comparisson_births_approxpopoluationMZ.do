/*******************************************************************************
* File name: 	mlch_population_comparisson_births_approxpopoluationMZ
* Author: 		Marc Fabel
* Date: 		02.10.2017
* Description:	Comparison of populations, from
*				1) original number of births
*				2) approximated numnber (with MZ weigths)
*				3) accumulated over Kreise and directly from Regionalstatistik
*
* Inputs:  		$excel/Bevoelkerung_Altersjahre_Geschlecht `i'
*				$MZ/MOB_Distr_GDRFRG.csv
* Outputs:		$temp\bevoelkerung_final.dta
*
* Updates:
*
*******************************************************************************/



// ***************************** PREAMBLE********************************
	clear all
	set more off
	
	global path 		"F:\econ\m-l-c-h\analysis"
	global temp   		"$path/temp"
	global graphs		"$path/graphs/population"
	global regionaldata "G:\Projekte\Projekte_ab2016\EcUFam\Daten\Regionaldatenbank\Data\Final\output\"
// ***********************************************************************


	
// ***************drittes Konzept einfúgen *************************************
	// drittes Konzept: über die Kreise collapsen (aus dem Merge für Janisch rauskopiert
	use ${regionaldata}\exportfile_yearly_clean.dta, clear
	keep if year >= 2005 & year <= 2013
	keep year ags_clean _001_*

	*Geographie aus ags_clean erstellen:
	gen bula = round(ags_clean /1000)

	*Dummy Variable: Ost-West Deutschland
	qui gen GDR = cond(bula >= 11 & bula <= 16,1,0)
	label var GDR "Dummyvariable: Ostdeutschland"
	
	*reshape
	drop _001_ypop _001_ypop_m _001_ypop_f //drop total (für Gesamtbevölkerung)
	reshape long _001_ypop_m _001_ypop_f _001_ypop_ , i(bula  GDR year ags_clean) j(agegroup)

	*Geburtsjahr bestimmen: Geburtsjahr = Surveyjahr - Alter
	gen YOB = year - agegroup	
	
	*nur die relevanten Jahrgänge drinbehalten (Gegenstand der Analyse sind nur bestimmte Geburtskohorten)
	keep if YOB >= 1976 & YOB <=1980 | ///
		YOB >= 1985 & YOB <=1995 
		
	*unnötige Variablen werden rausgenommen
	drop bula  ags_clean	agegroup
	
	*der Datenset wird aggregiert: enthält Anzahl der Personen pro Geburtskohorte in einem bestimmten surveyjahr für Ost/West Deutschland
	collapse (sum) *ypop* , by(YOB year GDR)
	order year GDR YOB 
	
	*Variablenlabels
	label var YOB "Geburtsjahr"
	label var _001_ypop_ "Bevölkerung in Altersjahren"
	label var _001_ypop_m "Männliche Bevölkerung in Altersjahren"
	label var _001_ypop_f "Weibliche Bevölkerung in Altersjahren"

	merge 1:m  GDR YOB year using "$temp/bevoelkerung_final"
	drop _merge
	
	*approximationen (drittes Konzept):
	qui gen pop_3 = _001_ypop_ * ratio_GDR
// *****************************************************************************




drop if GDR == 1

* generate variables for rcap graphs
foreach var of varlist bev* pop_3 {
	bys YOB MOB: egen `var'_min = min(`var')
	by YOB MOB: egen `var'_max = max(`var')
} // end loop: variables

foreach year of numlist 1976(1)1980 1985(1)1995 { //
	twoway rcap pop_3_min pop_3_max MOB if YOB == `year', color(gs8) || ///
		rcap bev_max bev_min MOB if YOB == `year', color(blue) || ///
		scatter fert MOB if YOB == `year', sort color(red) ///
		legend(pos(`5') ring(1) col(1)) legend(size(small)) ///
		legend(label(1 "Approximations: Regionalstatistik & MZ weights; collapsed Kreise") ///
		label(2 "Approximations: Regionalstatistik & MZ weights; collapsed Länder") ///
		label(3 "Number of births (Destatis)")) ///
		title("Year: `year'") xlabel(1(2)12) xtick(2(2)12) ///
		xtitle("Month of birth") ytitle("Population") ///
		legend( order(2 1 3))
	graph export "$graphs/comparison_population_`year'.pdf", as(pdf) replace
	} //end loop: year
	
	
	
	
