/*******************************************************************************
* File name: 	mlch_KKH_analysis_reduced form
* Author: 		Marc Fabel
* Date: 		26.09.2017
* Description:	Exploration of reduced from (different RD plots and co)
*				
*				
*				
*
* Inputs:  		$temp\KKH_final_R1
*				
* Outputs:		$temp\KKH_final_R1
*
* Updates:
*
* Notes: For the moment I do everything for Daignosis number 5
*******************************************************************************/

// ***************************** PREAMBLE********************************
	clear all
	set more off
	
	global path  "F:\econ\m-l-c-h\analysis"
	global excel "G:\Projekte\Projekte_ab2016\EcUFam\Daten\Regionaldatenbank\Data\Excel\Rohdaten"
	global MZ    "F:\KKH_Diagnosedaten\"
	global temp  "$path/temp"
	global KKH   "$path/source" 
	global graph "$path/graphs/KKH" 
// ***********************************************************************


use "$temp\KKH_final_R1", clear

// ******* Step 1: RD over time *******
capture program drop RD_over_time
	program define RD_over_time
		qui bys Datum:egen AVRG_`1' = mean (`1')

		/*qui reg `1' NumX Num_after after
		qui predict `1'_hat_linear
		qui reg `1' NumX NumX2 after Num_after Num2_after
		qui predict `1'_hat_quadratic
		qui reg `1' NumX NumX2 NumX3 after Num_after Num2_after Num3_after
		qui predict `1'_hat_cubic	
		qui reg `1'  NumX Num_after after if (NumX!=-1 & NumX!=1)
		qui predict `1'_donut_linear*/
		scatter AVRG_`1' temp,  scheme(s1mono )  title(" `4' ") ///
                 tline(01may1979, lw(medthick ) lpattern(solid)) ///
                xtitle("Birth month") ytitle(" `1' ") yscale(r(`2' `3')) ///
                ylabel(#5,grid) tlabel(15nov1978 (60) 15sep1979, format(%tdmy)) tmtick(15dec1978 (60) 15oct1979) ///
				ttext(`5' 01apr1979 "2 months", box) ttext(`5' 01jun1979 "6 months", box)  ///
				legend(off)
				
		*graph export "$graphs/R1_RD_`1'_plain.pdf", as(pdf) replace
	end		




// ******* Step : Treatment and control in one graph *******


*auxiliary variable for running variable (to have T & control in one window)
qui gen     temp = 1  if MOB == 11
qui replace temp = 2  if MOB == 12
qui replace temp = 3  if MOB == 1
qui replace temp = 4  if MOB == 2
qui replace temp = 5  if MOB == 3
qui replace temp = 6  if MOB == 4
qui replace temp = 7  if MOB == 5
qui replace temp = 8  if MOB == 6
qui replace temp = 9  if MOB == 7
qui replace temp = 10 if MOB == 8
qui replace temp = 11 if MOB == 9
qui replace temp = 12 if MOB == 10




*define Program
capture program drop RD_C_T
	program define RD_C_T
		qui bys Datum:egen AVRG_`1' = mean (`1')

		/*qui reg `1' NumX Num_after after
		qui predict `1'_hat_linear
		qui reg `1' NumX NumX2 after Num_after Num2_after
		qui predict `1'_hat_quadratic
		qui reg `1' NumX NumX2 NumX3 after Num_after Num2_after Num3_after
		qui predict `1'_hat_cubic	
		qui reg `1'  NumX Num_after after if (NumX!=-1 & NumX!=1)
		qui predict `1'_donut_linear*/
		scatter AVRG_`1' temp,  scheme(s1mono )  title(" `4' ") ///
                 tline(01may1979, lw(medthick ) lpattern(solid)) ///
                xtitle("Birth month") ytitle(" `1' ") yscale(r(`2' `3')) ///
                ylabel(#5,grid) tlabel(15nov1978 (60) 15sep1979, format(%tdmy)) tmtick(15dec1978 (60) 15oct1979) ///
				ttext(`5' 01apr1979 "2 months", box) ttext(`5' 01jun1979 "6 months", box)  ///
				legend(off)
				
		*graph export "$graphs/R1_RD_`1'_plain.pdf", as(pdf) replace
	end		

RD_C_T Diag_5
scatter AVRG_Diag_5 temp if control ==2 | control == 4


 Diag_5_f Diag_5_m

Diag_5_r Diag_5_rf Diag_5_rm

