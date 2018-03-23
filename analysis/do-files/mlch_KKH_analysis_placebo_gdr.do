/*******************************************************************************
* File name: 	
* Author: 		Marc Fabel
* Date: 		21.11.2017
* Description:	Placebo reform 
*				 
*				 
*				
*
* Inputs:  		$temp\KKH_final_R1
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
	global auxiliary "$path/do-files/auxiliary_files"
	
	*magic numbers
	global first_year = 1995
	global last_year  = 2014
	
	*checkmark
	global check "\checkmark" // können auch andere Zeichen benutzt werden, eg Latex \checkmark
// ***********************************************************************


********************************************************************************
		*****  Own program  *****
********************************************************************************
	capture program drop RD
	program define RD
		*capture drop panel`1'			//! ACHTUNG: HIER NICHT BENÖTIGT DA KEINE MISSINGS
		*qui gen panel`1' = 1
		*qui replace panel`1' = 0 if (`1'==. | `1'<0)
		 eststo: reg `1' after Numx Num_after `2' if treat ==1 `3', vce(cluster MxY) 		
	end

	capture program drop DDRD
	program define DDRD
		qui eststo `1': reg `2' p_treat p_after p_TxA   `3'  `4', vce(cluster MxY) 
	end
	
////////////////////////////////////////////////////////////////////////////////
						*** Regression Analysis ***
////////////////////////////////////////////////////////////////////////////////
use "$temp\KKH_final_R1_GDR", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"
	*delete treatment cohort
	drop if TxA == 1 
	drop if control == 3
	
	
	// !!!!! ACHTUNG NICHT DERSELBE ZEITRAUM UND AUCH NICHT DIESSELBEN VARIABLEN VERFÜGBAR!!
	
foreach 1 of varlist D5 {

}	
