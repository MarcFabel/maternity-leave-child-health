/* Regression Analysis


*/



***********************************************
	*** PREAMBLE ***
***********************************************
	clear all
	set more off
	
	global path "F:\KKH_Diagnosedaten\analyse_local"
	global temp  "$path\temp"
	//ENTSPRECHEN MOMENTAN NUR DUMMYDATEN
	*global KKH "F:\KKH_Diagnosedaten\analyse_local\source" 
	global graphs "$path\graphs"
	global tables "$path\tables"
	
////////////////////////////////////////////////////////////////////////////////
						*** Regression Analysis ***
////////////////////////////////////////////////////////////////////////////////
	use "$temp\KKH_final_R1", clear
	drop if FRG == 0
	
	*rausgenommen: gender

	#delimit ;
	global controlvars 
		age
		agesq;
	#delimit cr
	
	foreach x of numlist 2005 (1) 2013 {
		capture drop Dy`x'
		qui gen Dy`x' = 1 if year == `x'
		qui replace Dy`x' = 0 if year != `x'
	}

	rename NumX Numx
	rename NumX2 Numx2
	rename NumX3 Numx3


********************************************************************************
		*****  Own program  *****
********************************************************************************
	capture program drop RD
	program define RD
		*capture drop panel`1'			//! ACHTUNG: HIER NICHT BENÖTIGT DA KEINE MISSINGS
		*qui gen panel`1' = 1
		*qui replace panel`1' = 0 if (`1'==. | `1'<0)
		qui eststo: reg `1' after Numx Num_after `2' if treat ==1 `3', vce(cluster MxY) 		
	end

	capture program drop DDRD
	program define DDRD
		qui eststo: reg `1' treat after TxA Dmon*  `2'  `3', vce(cluster MxY) 
	end
	
	capture program drop Analyse_Overview
	program define Analyse_Overview
		qui eststo `1'_plain: RD `1' " " " "
		qui eststo `1'_year: RD `1' "Dy*" " "
		qui eststo `1'_cov: RD `1' "Dy* $perscontrols "  " "
		esttab `1'* using ${tables}\R1_Overview_`1'.txt, replace  ///
							title("1) Regression Discontinuity (linear): Impact on `1'; ") ///
							se keep(after) noobs nodepvar nonotes nomtitles star(* 0.10 ** 0.05 *** 0.01) ///
							scalars( "N Observations"   ) coeflabels(after "RD")
							
						
	
		*DDRD - 3 Control groups
		eststo clear
		qui eststo health_plain: DDRD `1' " " " "
		qui eststo health_year: DDRD `1' "Dy*" " "	
		qui eststo health_cova: DDRD `1' "Dy* $perscontrols "  " "
		esttab health* using ${tables}\R1_Overview_`1'.txt, append  ///
							title("2.1) Difference-in-difference regression discontinuity (DDRD): Impact on `1', all control cohorts") ///
							se keep(TxA) noobs nodepvar nonotes nomtitles nonumber star(* 0.10 ** 0.05 *** 0.01) ///
							scalars( "N Observations") coeflabels(TxA "DDRD")
							
		*only one cohort prior to treatment cohort
		eststo clear
		qui eststo health_plain: DDRD `1' " " "if  control == 2 | control == 4"
		qui eststo health_year: DDRD `1' "Dy*" "if  control == 2| control == 4 "	
		qui eststo health_cova: DDRD `1' "Dy* $perscontrols "  "if  control == 2| control == 4 "
		esttab health* using ${tables}\R1_Overview_`1'.txt, append  ///
							title("2.2) DDRD: Impact on `1' - Just 1 Control Cohort (prior one)") ///
							se keep(TxA) noobs nodepvar nonotes nomtitles star(* 0.10 ** 0.05 *** 0.01) ///
							scalars( "N Observations" ) coeflabels(TxA "DDRD")
							
	
		*wihtout control cohort born after treatment cohort
		eststo clear
		qui eststo health_plain2: DDRD `1' " " "if  control != 3 "
		qui estadd local bm "X"
		
		qui eststo health_yeard: DDRD `1' "Dy*" "if   control != 3 "
		qui estadd local bm "X"
		qui estadd local year "X"
		
		qui eststo health_cova: DDRD `1' "Dy* $perscontrols "  "if  control != 3 "
		qui estadd local bm "X"
		qui estadd local year "X"
		qui estadd local cov "X"
		
		
		esttab health* using ${tables}\R1_Overview_`1'.txt, append  ///
							title("2.3) DDRD: Impact on `1' - without CG3") ///
							se keep(TxA) noobs nodepvar nonotes nomtitles star(* 0.10 ** 0.05 *** 0.01) ///
							scalars( "N Observations"  "bm Birthmonth FE" "year Time FE" ///
							"cov Pers covar" ) coeflabels(TxA "DDRD") gaps lines 
							
		*Heterogeneity Analysis:
		eststo clear
		qui eststo : DDRD `1'm " " "  " //males
		qui eststo : DDRD `1'f " " "  "	//females
		
		
		esttab  using ${tables}\R1_Overview_`1'.txt, append  ///
							title("3.1) DDRD: Heterogeneity Analysis for `1'") ///
							se keep(TxA) noobs nodepvar nonotes  star(* 0.10 ** 0.05 *** 0.01) ///
							scalars( "N Observations"   ) coeflabels(TxA "DDRD") ///
							mtitles("Men" "Women" )	nogaps
							
		
		*Heterogeneity Analysis with no CG3
		eststo clear
		qui eststo : DDRD `1'm " " "if  control != 3" //males
		qui eststo : DDRD `1'f " " "if  control != 3"	//females
		
		
		esttab  using ${tables}\R1_Overview_`1'.txt, append  ///
							title("3.2) DDRD: Heterogeneity Analysis for `1' - Without CG3") ///
							se keep(TxA) noobs nodepvar nonotes  star(* 0.10 ** 0.05 *** 0.01) ///
							scalars( "N Observations"   ) coeflabels(TxA "DDRD") ///
							mtitles("Men" "Women" )	nogaps
		
		*Heterogeneity Analysis with CG2 only					 
		eststo clear
		qui eststo : DDRD `1'm " " "if  control != 3 & ( control == 2 | control == 4)" //males
		qui eststo : DDRD `1'f " " "if  control != 3& ( control == 2 | control == 4)"	//females
		
		
		esttab  using ${tables}\R1_Overview_`1'.txt, append  ///
							title("3.3) DDRD: Heterogeneity Analysis for `1' - Just 1 Control Cohort") ///
							se keep(TxA) noobs nodepvar nonotes  star(* 0.10 ** 0.05 *** 0.01) ///
							scalars( "N Observations"   ) coeflabels(TxA "DDRD") ///
							mtitles("Men" "Women")	nogaps
		
		
		
	
	end

	
	
	
	Analyse_Overview  hospital_r
	
	

			
		
		
		
