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


		
