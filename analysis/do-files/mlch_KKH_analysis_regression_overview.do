/*******************************************************************************
* File name: 	mlch_KKH_analysis_regression_overview
* Author: 		Marc Fabel
* Date: 		21.11.2017
* Description:	Regression analysis (OVERVIEW 1
*				1) verschiedene X (i.MOB, i.year, $controlsvar) & gender heterogeneity
*				2) verschiedene CGs 
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
	
	*magic numbers
	global first_year = 2005
	global last_year  = 2013
	
	*checkmark
	global check "\checkmark" // können auch andere Zeichen benutzt werden, eg Latex \checkmark
// ***********************************************************************

	
////////////////////////////////////////////////////////////////////////////////
						*** Regression Analysis ***
////////////////////////////////////////////////////////////////////////////////
	use "$temp\KKH_final_R1", clear
	
	*rausgenommen: gender

	#delimit ;
	global controlvars 
		age
		agesq;
	#delimit cr
	

	rename NumX Numx
	rename NumX2 Numx2
	rename NumX3 Numx3
	
	//Important globals
	* List of control groups
	global C2    = "(control == 2 | control == 4)"
	global C1_C2 = "control != 3"
	
	* Bandwidths (sample selection)
	global M2 = "(Numx >= -2 & Numx <= 2)"
	global M4 = "(Numx >= -4 & Numx <= 4)"
	global MD = "(Numx != -1 & Numx != 1)"

	


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
		qui eststo `1': reg `2' treat after TxA   `3'  `4', vce(cluster MxY) 
	end
	/* OLD VERSION 
	program define DDRD
		qui eststo: reg `1' treat after TxA Dmon*  `2'  `3', vce(cluster MxY) 
	end
	*/
********************************************************************************	
	// globals definieren für überschrift in den Tabellen
	global length_of_stay	"Average length of stay"
	global sum_stay	
	global share_surgery		"Share with surgery"
	global hospital				"Hospital admission"
	global d1					"Certain infectious and parasitic diseases"
	global d2					"Neoplasms"
	global d5					"Mental and behavioral disorders"
	global d6 					"Diseases of the nervous system"
	global d7 					"Diseases of the eye and ear"
	global d8 					"Diseases of the circulatory system"
	global d9 					"Diseases of the respiratory system"
	global d10 					"Diseases of the digestive system"
	global d11 					"Diseases of the skin and subcutaneous tissue"
	global d12 					"Diseases of the musculoskeletal system and connective tissue"
	global d13 					"Diseases of the genitourinary system"
	global d17 					"Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified"
	global d18 					"External causes of morbidity and mortality"
		
	global injuries 			"Injuries"
	global neurosis 			"Neurosis"
	global joints 				"Disease of the joints"
	global kidneys 				"Diseases of the kidneys"
	global bile_pancreas		"Diseases of the bile and pancreas"
		
	global d14 					"Pregnancy, childbirth and the puerperium"
	global female_genital_tract	"Non-inflammatory diseases of the female genital tract"
	global pregnancy			"Diseases of the mother, associated with the pregnancy"
	global delivery 			"Obstructed labor & problems during delivery"
	
	global stomach				"Diseases of the stomach"
	global symp_dig_system		"Symptoms of the digestive system"
	global mal_neoplasm			"Malignant neoplasm"
	global ben_neoplasm			"Benign neoplasm"
	global heart				"Non-ischemic heart disease"
	global depression			"Depression"
	global personality			"Personality and behavioral disorder"
	global lymphoma				"Diseases of the blood & lymphatic vessels"
	global symp_resp_system		"Symptoms of the respiratory & circulatory system"
	global calculi				"Renal insufficiency (Calculi)"
********************************************************************************


********************************************************************************
		*****  ERSTES OVERVIEW PROGRAMM  *****
********************************************************************************	
	
	// Setup of new table - Beispiel with d5 hospital 
foreach 1 of varlist hospital d5 {
	// PANEL: 2 MONTHS 
	*absolute numbers
	eststo clear
	DDRD a1 `1'   "						 	" "if $C2 & $M2" 
	DDRD a2 `1'   "i.MOB 				    " "if $C2 & $M2"
	DDRD a3 `1'   "i.MOB i.year 			" "if $C2 & $M2" 
	DDRD a4 `1'   "i.MOB i.year $controlvars" "if $C2 & $M2"
	DDRD a5 `1'_f "i.MOB 					" "if $C2 & $M2"
	DDRD a6 `1'_m "i.MOB 					" "if $C2 & $M2"
	esttab a* using "$tables/`1'2Ma.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	
	*Ratio population
	DDRD b1 r_pop_`1'   "						  " "if $C2 & $M2" 
	DDRD b2 r_pop_`1'   "i.MOB 				      " "if $C2 & $M2"
	DDRD b3 r_pop_`1'   "i.MOB i.year 			  " "if $C2 & $M2" 
	DDRD b4 r_pop_`1'   "i.MOB i.year $controlvars" "if $C2 & $M2"
	DDRD b5 r_pop_`1'_f "i.MOB 					  " "if $C2 & $M2"
	DDRD b6 r_pop_`1'_m "i.MOB 					  " "if $C2 & $M2"
	esttab b* using "$tables/`1'2Mb.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	*Ratio fertility 
	DDRD c1 r_fert_`1'   "						   " "if $C2 & $M2" 
	DDRD c2 r_fert_`1'   "i.MOB 				   " "if $C2 & $M2"
	DDRD c3 r_fert_`1'   "i.MOB i.year 			   " "if $C2 & $M2" 
	DDRD c4 r_fert_`1'   "i.MOB i.year $controlvars" "if $C2 & $M2"
	DDRD c5 r_fert_`1'_f "i.MOB 				   " "if $C2 & $M2"
	DDRD c6 r_fert_`1'_m "i.MOB 				   " "if $C2 & $M2"
	
	esttab c* using "$tables/`1'2Mc.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	
	
	// PANEL: 4 MONTHS 
	*absolute numbers
	eststo clear
	DDRD a1 `1'	  "						      " "if $C2 & $M4" 
	DDRD a2 `1'	  "i.MOB 				      " "if $C2 & $M4"
	DDRD a3 `1'	  "i.MOB i.year 			  " "if $C2 & $M4" 
	DDRD a4 `1'	  "i.MOB i.year $controlvars  " "if $C2 & $M4"
	DDRD a5 `1'_f "i.MOB 					  " "if $C2 & $M4"
	DDRD a6 `1'_m "i.MOB 					  " "if $C2 & $M4"
	esttab a* using "$tables/`1'4Ma.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	
	*Ratio population
	DDRD b1 r_pop_`1'	"						  " "if $C2 & $M4" 
	DDRD b2 r_pop_`1'	"i.MOB 				      " "if $C2 & $M4"
	DDRD b3 r_pop_`1'	"i.MOB i.year 			  " "if $C2 & $M4" 
	DDRD b4 r_pop_`1'	"i.MOB i.year $controlvars" "if $C2 & $M4"
	DDRD b5 r_pop_`1'_f "i.MOB 					  " "if $C2 & $M4"
	DDRD b6 r_pop_`1'_m "i.MOB 					  " "if $C2 & $M4"
	esttab b* using "$tables/`1'4Mb.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	*Ratio fertility 
	DDRD c1 r_fert_`1'	 "						   " "if $C2 & $M4" 
	DDRD c2 r_fert_`1'	 "i.MOB 				   " "if $C2 & $M4"
	DDRD c3 r_fert_`1'	 "i.MOB i.year 			   " "if $C2 & $M4" 
	DDRD c4 r_fert_`1'	 "i.MOB i.year $controlvars" "if $C2 & $M4"
	DDRD c5 r_fert_`1'_f "i.MOB 				   " "if $C2 & $M4"
	DDRD c6 r_fert_`1'_m "i.MOB 				   " "if $C2 & $M4"
	esttab c* using "$tables/`1'4Mc.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	
	// PANEL: 6 MONTHS 
	*absolute numbers
	eststo clear
	DDRD a1 `1'   "						    " "if $C2" 
	DDRD a2 `1'   "i.MOB 				    " "if $C2"
	DDRD a3 `1'   "i.MOB i.year 			" "if $C2" 
	DDRD a4 `1'   "i.MOB i.year $controlvars" "if $C2"
	DDRD a5 `1'_f "i.MOB 	  				" "if $C2"
	DDRD a6 `1'_m "i.MOB 	  				" "if $C2"
	esttab a* using "$tables/`1'6Ma.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	
	*Ratio population
	DDRD b1 r_pop_`1'   "						  " "if $C2 " 
	DDRD b2 r_pop_`1'   "i.MOB 				      " "if $C2 "
	DDRD b3 r_pop_`1'   "i.MOB i.year 			  " "if $C2 " 
	DDRD b4 r_pop_`1'   "i.MOB i.year $controlvars" "if $C2 "
	DDRD b5 r_pop_`1'_f "i.MOB 					  " "if $C2 "
	DDRD b6 r_pop_`1'_m "i.MOB 					  " "if $C2 "
	esttab b* using "$tables/`1'6Mb.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	*Ratio fertility 
	DDRD c1 r_fert_`1'   "						   " "if $C2 " 
	DDRD c2 r_fert_`1'   "i.MOB 				   " "if $C2 "
	DDRD c3 r_fert_`1'   "i.MOB i.year 			   " "if $C2 " 
	DDRD c4 r_fert_`1'   "i.MOB i.year $controlvars" "if $C2 "
	DDRD c5 r_fert_`1'_f "i.MOB 				   " "if $C2 "
	DDRD c6 r_fert_`1'_m "i.MOB 				   " "if $C2 "
	esttab c* using "$tables/`1'6Mc.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
		
	// PANEL: DONUT 
	*absolute numbers
	eststo clear
	DDRD a1 `1'   "						      " "if $C2 & $MD" 
	DDRD a2 `1'   "i.MOB 				      " "if $C2 & $MD"
	DDRD a3 `1'   "i.MOB i.year 			  " "if $C2 & $MD" 
	DDRD a4 `1'   "i.MOB i.year $controlvars" "if $C2 & $MD"
	DDRD a5 `1'_f "i.MOB 	                " "if $C2 & $MD"
	DDRD a6 `1'_m "i.MOB 	                " "if $C2 & $MD"
	esttab a* using "$tables/`1'DMa.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	
	*Ratio population
	DDRD b1 r_pop_`1'   "						  " "if $C2 & $MD" 
	DDRD b2 r_pop_`1'   "i.MOB 				      " "if $C2 & $MD"
	DDRD b3 r_pop_`1'   "i.MOB i.year 			  " "if $C2 & $MD" 
	DDRD b4 r_pop_`1'   "i.MOB i.year $controlvars" "if $C2 & $MD"
	DDRD b5 r_pop_`1'_f "i.MOB 					  " "if $C2 & $MD"
	DDRD b6 r_pop_`1'_m "i.MOB 					  " "if $C2 & $MD"
	esttab b* using "$tables/`1'DMb.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	*Ratio fertility 
	DDRD c1 r_fert_`1'   "						   " "if $C2 & $MD" 
	DDRD c2 r_fert_`1'   "i.MOB 				   " "if $C2 & $MD"
	DDRD c3 r_fert_`1'   "i.MOB i.year 			   " "if $C2 & $MD" 
	DDRD c4 r_fert_`1'   "i.MOB i.year $controlvars" "if $C2 & $MD"
	DDRD c5 r_fert_`1'_f "i.MOB 				   " "if $C2 & $MD"
	DDRD c6 r_fert_`1'_m "i.MOB 				   " "if $C2 & $MD"
	esttab c* using "$tables/`1'DMc.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
		
	*FFOR BOTTOM: 
	DDRD c1 r_fert_`1'   "						   " "if $C2 & $MD" 
	DDRD c2 r_fert_`1'   "i.MOB 				   " "if $C2 & $MD"
	DDRD c3 r_fert_`1'   "i.MOB i.year 			   " "if $C2 & $MD" 
	DDRD c4 r_fert_`1'   "i.MOB i.year $controlvars" "if $C2 & $MD"
	DDRD c5 r_fert_`1'_f "i.MOB					   " "if $C2 & $MD"
	DDRD c6 r_fert_`1'_m "i.MOB					   " "if $C2 & $MD"
	esttab c* using "$tables/`1'checks.tex", replace booktabs fragment ///
		keep( ) coeflabels(TxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		indicate("Birthmonth FE = *MOB" "Year FE = *year" ///
		"Covariates = $controlvars", label("$check" ""))  ///
		label nomtitles nonumbers noobs nonote nogaps noline	
		
		// Panels zusammenfassen
esttab a* using "$tables/`1'.tex", replace booktabs ///
		cells(none) nonote noobs ///
		mtitles( "" "" "" "" "Women" "Men") ///
		mgroups("Average Causal Effects" "Heterogeneous Causal Effects", pattern(1 0 0 0 1 0) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))  ///
		prehead({\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
		\begin{tabular}{l*{@span}{c}} \toprule ///
		& \multicolumn{@M}{c}{Dependent variable: $`1'} \\ \cmidrule(lr){2-7}) ///
		prefoot( ///
		\multicolumn{@span}{l}{\emph{Panel A. 2 Month bandwidth}} \\ ///
		\input{`1'2Ma} ///
		\input{`1'2Mb} ///
		\input{`1'2Mc} ///
		\midrule\multicolumn{@span}{l}{\emph{Panel B. 4 Month bandwidth}} \\ ///
		\input{`1'4Ma} ///
		\input{`1'4Mb} ///
		\input{`1'4Mc} ///
		\midrule\multicolumn{@span}{l}{\emph{Panel C. 6 Month bandwidth}} \\ ///
		\input{`1'6Ma} ///
		\input{`1'6Mb} ///
		\input{`1'6Mc} ///
		\midrule\multicolumn{@span}{l}{\emph{Panel D. Donut specification}} \\ ///
		\input{`1'DMa} ///
		\input{`1'DMb} ///
		\input{`1'DMc} ///
		\midrule \input{`1'checks} ///
		) ///
		postfoot(\bottomrule \end{tabular} } ///
		)
		
		
}

	
********************************************************************************
		*****  ZWEITES OVERVIEW PROGRAM  *****
********************************************************************************	
	
	* Numbers refer to columns a1,a2,...
foreach 1 of varlist d5 {
	// PANEL: 2 MONTHS 
	*absolute numbers
	eststo clear
	DDRD a1 `1'   "i.MOB" "if $C2    & $M2"
	DDRD a2 `1'   "i.MOB" "if $C1_C2 & $M2" 
	DDRD a3 `1'   "i.MOB" "if          $M2"
	DDRD a4 `1'_f "i.MOB" "if $C2    & $M2"
	DDRD a5 `1'_f "i.MOB" "if $C1_C2 & $M2" 
	DDRD a6 `1'_f "i.MOB" "if          $M2"
	DDRD a7 `1'_m "i.MOB" "if $C2    & $M2"
	DDRD a8 `1'_m "i.MOB" "if $C1_C2 & $M2" 
	DDRD a9 `1'_m "i.MOB" "if          $M2"
	esttab a* using "$tables/`1'2Ma-cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	
	*Ratio population
	DDRD b1 r_pop_`1'   "i.MOB" "if $C2    & $M2"
	DDRD b2 r_pop_`1'   "i.MOB" "if $C1_C2 & $M2" 
	DDRD b3 r_pop_`1'   "i.MOB" "if          $M2"
	DDRD b4 r_pop_`1'_f "i.MOB" "if $C2    & $M2"
	DDRD b5 r_pop_`1'_f "i.MOB" "if $C1_C2 & $M2" 
	DDRD b6 r_pop_`1'_f "i.MOB" "if          $M2"
	DDRD b7 r_pop_`1'_m "i.MOB" "if $C2    & $M2"
	DDRD b8 r_pop_`1'_m "i.MOB" "if $C1_C2 & $M2" 
	DDRD b9 r_pop_`1'_m "i.MOB" "if          $M2"
	esttab b* using "$tables/`1'2Mb-cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	*Ratio fertility
	DDRD c1 r_fert_`1'   "i.MOB" "if $C2    & $M2"
	DDRD c2 r_fert_`1'   "i.MOB" "if $C1_C2 & $M2" 
	DDRD c3 r_fert_`1'   "i.MOB" "if          $M2"
	DDRD c4 r_fert_`1'_f "i.MOB" "if $C2    & $M2"
	DDRD c5 r_fert_`1'_f "i.MOB" "if $C1_C2 & $M2" 
	DDRD c6 r_fert_`1'_f "i.MOB" "if          $M2"
	DDRD c7 r_fert_`1'_m "i.MOB" "if $C2    & $M2"
	DDRD c8 r_fert_`1'_m "i.MOB" "if $C1_C2 & $M2" 
	DDRD c9 r_fert_`1'_m "i.MOB" "if          $M2"
	esttab c* using "$tables/`1'2Mc-cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline

	// PANEL: 4 MONTHS 
	*absolute numbers
	eststo clear
	DDRD a1 `1'   "i.MOB" "if $C2    & $M4"
	DDRD a2 `1'   "i.MOB" "if $C1_C2 & $M4" 
	DDRD a3 `1'   "i.MOB" "if          $M4"
	DDRD a4 `1'_f "i.MOB" "if $C2    & $M4"
	DDRD a5 `1'_f "i.MOB" "if $C1_C2 & $M4" 
	DDRD a6 `1'_f "i.MOB" "if          $M4"
	DDRD a7 `1'_m "i.MOB" "if $C2    & $M4"
	DDRD a8 `1'_m "i.MOB" "if $C1_C2 & $M4" 
	DDRD a9 `1'_m "i.MOB" "if          $M4"
	esttab a* using "$tables/`1'4Ma-cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	
	*Ratio population
	DDRD b1 r_pop_`1'   "i.MOB" "if $C2    & $M4"
	DDRD b2 r_pop_`1'   "i.MOB" "if $C1_C2 & $M4" 
	DDRD b3 r_pop_`1'   "i.MOB" "if          $M4"
	DDRD b4 r_pop_`1'_f "i.MOB" "if $C2    & $M4"
	DDRD b5 r_pop_`1'_f "i.MOB" "if $C1_C2 & $M4" 
	DDRD b6 r_pop_`1'_f "i.MOB" "if          $M4"
	DDRD b7 r_pop_`1'_m "i.MOB" "if $C2    & $M4"
	DDRD b8 r_pop_`1'_m "i.MOB" "if $C1_C2 & $M4" 
	DDRD b9 r_pop_`1'_m "i.MOB" "if          $M4"
	esttab b* using "$tables/`1'4Mb-cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	*Ratio fertility
	DDRD c1 r_fert_`1'   "i.MOB" "if $C2    & $M4"
	DDRD c2 r_fert_`1'   "i.MOB" "if $C1_C2 & $M4" 
	DDRD c3 r_fert_`1'   "i.MOB" "if          $M4"
	DDRD c4 r_fert_`1'_f "i.MOB" "if $C2    & $M4"
	DDRD c5 r_fert_`1'_f "i.MOB" "if $C1_C2 & $M4" 
	DDRD c6 r_fert_`1'_f "i.MOB" "if          $M4"
	DDRD c7 r_fert_`1'_m "i.MOB" "if $C2    & $M4"
	DDRD c8 r_fert_`1'_m "i.MOB" "if $C1_C2 & $M4" 
	DDRD c9 r_fert_`1'_m "i.MOB" "if          $M4"
	esttab c* using "$tables/`1'4Mc-cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	
	// PANEL: 6 MONTHS 
	*absolute numbers
	eststo clear
	DDRD a1 `1'   "i.MOB" "if $C2   "
	DDRD a2 `1'   "i.MOB" "if $C1_C2" 
	DDRD a3 `1'   "i.MOB" "         "
	DDRD a4 `1'_f "i.MOB" "if $C2   "
	DDRD a5 `1'_f "i.MOB" "if $C1_C2" 
	DDRD a6 `1'_f "i.MOB" "         "
	DDRD a7 `1'_m "i.MOB" "if $C2   "
	DDRD a8 `1'_m "i.MOB" "if $C1_C2" 
	DDRD a9 `1'_m "i.MOB" "         "
	esttab a* using "$tables/`1'6Ma-cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	
	*Ratio population
	DDRD b1 r_pop_`1'   "i.MOB" "if $C2   "
	DDRD b2 r_pop_`1'   "i.MOB" "if $C1_C2" 
	DDRD b3 r_pop_`1'   "i.MOB" "         "
	DDRD b4 r_pop_`1'_f "i.MOB" "if $C2   "
	DDRD b5 r_pop_`1'_f "i.MOB" "if $C1_C2" 
	DDRD b6 r_pop_`1'_f "i.MOB" "         "
	DDRD b7 r_pop_`1'_m "i.MOB" "if $C2   "
	DDRD b8 r_pop_`1'_m "i.MOB" "if $C1_C2" 
	DDRD b9 r_pop_`1'_m "i.MOB" "         "
	esttab b* using "$tables/`1'6Mb-cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	*Ratio fertility
	DDRD c1 r_fert_`1'   "i.MOB" "if $C2   "
	DDRD c2 r_fert_`1'   "i.MOB" "if $C1_C2" 
	DDRD c3 r_fert_`1'   "i.MOB" "         "
	DDRD c4 r_fert_`1'_f "i.MOB" "if $C2   "
	DDRD c5 r_fert_`1'_f "i.MOB" "if $C1_C2" 
	DDRD c6 r_fert_`1'_f "i.MOB" "         "
	DDRD c7 r_fert_`1'_m "i.MOB" "if $C2   "
	DDRD c8 r_fert_`1'_m "i.MOB" "if $C1_C2" 
	DDRD c9 r_fert_`1'_m "i.MOB" "          "
	esttab c* using "$tables/`1'6Mc-cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
		
	// PANEL: DONUT 
	*absolute numbers
	eststo clear
	DDRD a1 `1'   "i.MOB" "if $C2    & $MD"
	DDRD a2 `1'   "i.MOB" "if $C1_C2 & $MD" 
	DDRD a3 `1'   "i.MOB" "if          $MD"
	DDRD a4 `1'_f "i.MOB" "if $C2    & $MD"
	DDRD a5 `1'_f "i.MOB" "if $C1_C2 & $MD" 
	DDRD a6 `1'_f "i.MOB" "if          $MD"
	DDRD a7 `1'_m "i.MOB" "if $C2    & $MD"
	DDRD a8 `1'_m "i.MOB" "if $C1_C2 & $MD" 
	DDRD a9 `1'_m "i.MOB" "if          $MD"
	esttab a* using "$tables/`1'DMa-cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	
	*Ratio population
	DDRD b1 r_pop_`1'   "i.MOB" "if $C2    & $MD"
	DDRD b2 r_pop_`1'   "i.MOB" "if $C1_C2 & $MD" 
	DDRD b3 r_pop_`1'   "i.MOB" "if          $MD"
	DDRD b4 r_pop_`1'_f "i.MOB" "if $C2    & $MD"
	DDRD b5 r_pop_`1'_f "i.MOB" "if $C1_C2 & $MD" 
	DDRD b6 r_pop_`1'_f "i.MOB" "if          $MD"
	DDRD b7 r_pop_`1'_m "i.MOB" "if $C2    & $MD"
	DDRD b8 r_pop_`1'_m "i.MOB" "if $C1_C2 & $MD" 
	DDRD b9 r_pop_`1'_m "i.MOB" "if          $MD"
	esttab b* using "$tables/`1'DMb-cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	*Ratio fertility
	DDRD c1 r_fert_`1'   "i.MOB" "if $C2    & $MD"
	DDRD c2 r_fert_`1'   "i.MOB" "if $C1_C2 & $MD" 
	DDRD c3 r_fert_`1'   "i.MOB" "if          $MD"
	DDRD c4 r_fert_`1'_f "i.MOB" "if $C2    & $MD"
	DDRD c5 r_fert_`1'_f "i.MOB" "if $C1_C2 & $MD" 
	DDRD c6 r_fert_`1'_f "i.MOB" "if          $MD"
	DDRD c7 r_fert_`1'_m "i.MOB" "if $C2    & $MD"
	DDRD c8 r_fert_`1'_m "i.MOB" "if $C1_C2 & $MD" 
	DDRD c9 r_fert_`1'_m "i.MOB" "if          $MD"
	esttab c* using "$tables/`1'DMc-cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
		
		
	// Panels zusammenfassen
esttab a* using "$tables/`1'-cg.tex", replace booktabs ///
		cells(none) nonote noobs ///
		mtitles( "C2" "C1+C2" "C1-C3" "C2" "C1+C2" "C1-C3" "C2" "C1+C2" "C1-C3") ///
		mgroups("Average Causal Effects" "Women" "Men", pattern(1 0 0  1 0 0 1 0 0) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))  ///
		prehead({\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
		\begin{tabular}{l*{@span}{c}} \toprule ///
		& \multicolumn{@M}{c}{Dependent variable: $`1'} \\ \cmidrule(lr){2-10}) ///
		prefoot( ///
		\multicolumn{@span}{l}{\emph{Panel A. 2 Month bandwidth}} \\ ///
		\input{`1'2Ma-cg} ///
		\input{`1'2Mb-cg} ///
		\input{`1'2Mc-cg} ///
		\midrule\multicolumn{@span}{l}{\emph{Panel B. 4 Month bandwidth}} \\ ///
		\input{`1'4Ma-cg} ///
		\input{`1'4Mb-cg} ///
		\input{`1'4Mc-cg} ///
		\midrule\multicolumn{@span}{l}{\emph{Panel C. 6 Month bandwidth}} \\ ///
		\input{`1'6Ma-cg} ///
		\input{`1'6Mb-cg} ///
		\input{`1'6Mc-cg} ///
		\midrule\multicolumn{@span}{l}{\emph{Panel D. Donut specification}} \\ ///
		\input{`1'DMa-cg} ///
		\input{`1'DMb-cg} ///
		\input{`1'DMc-cg} ///
		) ///
		postfoot(\bottomrule \end{tabular} } ///
		)	
}





/* 
//Effect in sds		
	qui summ r_pop_D_5
	estadd scalar effct_sd = _b[TxA ]/r(sd)
//interaction treatment with female
	i.TxA#(c.(female))
*/



/*
VERSUCHE MEAN UND STD IN LETZE SPALTE NOCH ZU BEKOMMEN
/////
	// mean und sd einfuegen in letzter Spalte erste Tabelle
	
	
	mat r = J(1, 3, .)	// matrix (1 x #var) of missing values
	mat rownames r = "TxA"
	mat colnames r = a9:b a9:se a9:p 
	
	
	
	*trial mit absoluten Zahlen
	// PANEL: 2 MONTHS 
	*absolute numbers
	summ  D_5  if $M2 & control == 2
	mat r[1,1] = r(mean)
	mat r[1,2] = r(sd)
	mat r[1,3] = 99

	estadd scalar beta = r(mean)		
	estadd scalar std = r(sd)		
			
	estadd matrix r
	matrix list r
	
	matrix A = r
	matrix list A
	*estadd scalar sd = r(sd)
	eststo clear
	DDRD a1 D_5 "						  " "if $C2 & $M2" 
	DDRD a2 D_5 "i.MOB 				      " "if $C2 & $M2"
	eststo: estpost sum  D_5  if $M2 & control == 2

	/*DDRD a3 `1' "i.MOB i.year 			  " "if $C2 & $M2" 
	DDRD a4 `1' "i.MOB i.year $controlvars" "if $C2 & $M2"
	DDRD a5 `1' "i.MOB i.year $controlvars" "if $C2 & $M2 & female == 1"
	DDRD a6 `1' "i.MOB i.year $controlvars" "if $C2 & $M2 & female == 0"*/
	// nur ertsen 2 Gleichungen
	esttab a*  ,  	se   star(* 0.10 ** 0.05 *** 0.01)	 ///
		keep(TxA) ///
		cells("b(star pattern(1 1 )) " ///
		"se(pattern(1 1 ) par fmt(a2))    ")
		
	// get row and colnmames
	local temp1 : colfullnames r(coefs)
	disp "`temp1'"
	
	//estpost summ, namen stimmen nicht!
	esttab  ,  	se   star(* 0.10 ** 0.05 *** 0.01)	 ///
		cells("b(star pattern(1 1 0)) mean(pattern(0 0 1) fmt(a2))" ///
		"se(pattern(1 1 0) par fmt(a2))    sd(pattern(0 0 1) fmt(a2) par([ ]))") ///
		coeflabels(TxA "Abs. numbers") 
	
	//matrix version - mit r
	esttab ,  	se   star(* 0.10 ** 0.05 *** 0.01)	///
		cells("b(star pattern(1 1 0)) r[1,1](pattern(0 0 1) fmt(a2))" ///
		"se(pattern(1 1 0) par fmt(a2))    r[1,2](pattern(0 0 1) fmt(a2) par([ ]))")	
	
	
	matrix A = r(coefs)
	matrix list A
	
	cells(huhu)
	coeflabels(TxA "Abs. numbers") 
	/// 
	
	///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		cells(huhu) ///
		se
		
		///

	
	
	
	*formasahce: "huhu fmt(a2) par([ ])"
	*qui summ r_pop_D_5
	*estadd scalar effct_sd = _b[TxA ]/r(sd)
	
/////

