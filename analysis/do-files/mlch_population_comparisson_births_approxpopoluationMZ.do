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
	
	global path "F:\econ\m-l-c-h\analysis"
	global temp  "$path/temp"
	global graphs "$path/graphs/population"
	
// ***********************************************************************

use "$temp/bevoelkerung_final", clear
drop if GDR == 1



* generate variables for rcap graphs
foreach var of varlist bev bevf bevm {
	by YOB MOB: egen `var'_min = min(bev)
	by YOB MOB: egen `var'_max = max(bev)
} // end loop ov variables

foreach year of numlist 1976(1)1980 {
	twoway rcap bev_max bev_min MOB if YOB == `year' || ///
		scatter fert MOB if YOB == `year', sort color(red) ///
		legend(pos(`5') ring(1) col(2)) legend(size(small)) ///
		legend(label(1 "Approximations (Regionalstatistik & MZ weights)") ///
		label(2 "Number of births (Destatis)")) ///
		title("Year: `year'") xlabel(1(2)12) xtick(2(2)12) ///
		xtitle("Month of birth") ytitle("Population") 
	} //end loop year
	graph export "$graphs/comparison_population_`year'.pdf", as(pdf) replace
}

