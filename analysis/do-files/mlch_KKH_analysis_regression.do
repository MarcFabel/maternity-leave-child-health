/*******************************************************************************
* File name: 	mlch_KKH_analysis_regression_long
* Author: 		Marc Fabel
* Date: 		21.11.2017
* Description:	Regression analysis 
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
	
	
	
	capture program drop Analyse_Overview
	program define Analyse_Overview
	//Linear RD
		qui eststo `1'_plain: RD `1' " " " "
		qui eststo `1'_year: RD `1' "Dy*" " "
		qui eststo `1'_cov: RD `1' "Dy* $perscontrols  "  " "
		esttab `1'* using ${tables}\R1_Overvw_`1'.tex, replace  ///
							se keep(after)  nodepvar   star(* 0.10 ** 0.05 *** 0.01) ///
							 coeflabels(after "RD Linear") ///
							 fragment noobs noeqlines booktabs nonotes label  nomti nogaps nonum nolines
	//Quadratic
		qui eststo `1'_plain: RD `1' " Numx2 Num2_after" " "
		qui eststo `1'_year: RD `1' "Dy* Numx2 Num2_after" " "
		qui eststo `1'_cov: RD `1' "Dy* $perscontrols Numx2 Num2_after"  " "
		esttab `1'* using ${tables}\R1_Overvw_`1'.tex, append  ///
							se keep(after)  nodepvar  star(* 0.10 ** 0.05 *** 0.01) ///
							 coeflabels(after "RD Quadratic") ///
							fragment nolines noobs  booktabs nonotes nomti nogaps label nonum
	//Cubic RD
		qui eststo `1'_plain: RD `1' " Numx2 Numx3 Num2_after Num3_after" " "
		qui eststo `1'_year: RD `1' "Dy* Numx2 Numx3 Num2_after Num3_after" " "
		qui eststo `1'_cov: RD `1' "Dy* $perscontrols Numx2 Numx3 Num2_after Num3_after "  " "
		esttab `1'* using ${tables}\R1_Overvw_`1'.tex, append  ///
							se keep(after)  nodepvar  star(* 0.10 ** 0.05 *** 0.01) ///
							 coeflabels(after "RD Cubic") ///
							fragment nolines noobs  booktabs nonotes nomti nogaps label nonum
	
	//Linear Donut RD
		qui eststo `1'_plain: RD `1' " " " &  Numx!=-1 & Numx!=1"
		qui eststo `1'_year: RD `1' "Dy*" " &  Numx!=-1 & Numx!=1"
		qui eststo `1'_cov: RD `1' "Dy* $perscontrols  "  " &  Numx!=-1 & Numx!=1"
		esttab `1'* using ${tables}\R1_Overvw_`1'.tex, append  ///
							se keep(after)  nodepvar  star(* 0.10 ** 0.05 *** 0.01) ///
							 coeflabels(after "RD Linear Donut") ///
							fragment nolines noobs  booktabs nonotes nomti nogaps label nonum
							
							

		*DDRD - 3 Control groups
		eststo clear
		qui eststo health_plain: DDRD `1' " " " "
		qui eststo health_year: DDRD `1' "Dy*" " "	
		qui eststo health_cova: DDRD `1' "Dy* $perscontrols "  " "
		qui eststo health_1m: DDRD `1' " " "if (Numx >= -1 & Numx <= 1)"
		qui eststo health_2m: DDRD `1' " " "if (Numx >= -2 & Numx <= 2)"
		qui eststo health_4m: DDRD `1' " " "if (Numx >= -4 & Numx <= 4)"
		qui eststo health_donut: DDRD `1' " " "if (Numx != -1 & Numx != 1)"
		
		esttab health* using ${tables}\R1_Overvw_`1'.tex, append  ///
							title("2.1) Difference-in-difference regression discontinuity (DDRD): Impact on `1', all control cohorts") ///
							se keep(TxA)  nodepvar   star(* 0.10 ** 0.05 *** 0.01) ///
							 coeflabels(TxA "DDRD: C1-C3") /// 
							fragment noobs  booktabs nonotes   nomti  nonum lines 
		
		*only one cohort prior to treatment cohort
		eststo clear
		qui eststo health_plain: DDRD `1' " " "if  control == 2 | control == 4"
		qui eststo health_year: DDRD `1' "Dy*" "if  control == 2| control == 4 "	
		qui eststo health_cova: DDRD `1' "Dy* $perscontrols "  "if  control == 2| control == 4 "
		qui eststo health_1m: DDRD `1' " " "if  (control == 2 | control == 4) & (Numx >= -1 & Numx <= 1)"
		qui eststo health_2m: DDRD `1' " " "if  (control == 2 | control == 4) & (Numx >= -2 & Numx <= 2)"
		qui eststo health_4m: DDRD `1' " " "if  (control == 2 | control == 4) & (Numx >= -4 & Numx <= 4)"
		qui eststo health_donut: DDRD `1' " " "if  (control == 2 | control == 4) & (Numx != -1 & Numx != 1)"
		esttab health* using ${tables}\R1_Overvw_`1'.tex, append  ///
							se keep(TxA) nodepvar  star(* 0.10 ** 0.05 *** 0.01) ///
							coeflabels(TxA "DDRD: C2") ///
							fragment nolines noobs  booktabs nonotes nomti nogaps label nonum
							
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
		
		qui eststo health_1m: DDRD `1' " " "if  control != 3 & (Numx >= -1 & Numx <= 1)"
		qui eststo health_2m: DDRD `1' " " "if  control != 3 & (Numx >= -2 & Numx <= 2)"
		qui eststo health_4m: DDRD `1' " " "if  control != 3 & (Numx >= -4 & Numx <= 4)"
		qui eststo health_donut: DDRD `1' " " "if  control != 3 & (Numx != -1 & Numx != 1)"
		
		esttab health* using ${tables}\R1_Overvw_`1'.tex, append  ///
							se keep(TxA) nodepvar  star(* 0.10 ** 0.05 *** 0.01) ///
							scalars( "bm Birthmonth FE" "year Time FE" ///
							"cov Pers covar" ) coeflabels(TxA "DDRD: C1+C2") ///
							fragment nolines noobs  booktabs nonotes nomti nogaps label nonum  noeqlines 
							
							
		*Heterogeneity Analysis:
		eststo clear
		qui eststo : DDRD `1'm " " "  " //males
		qui eststo : DDRD `1'f " " "  "	//females
		
		
		esttab  using ${tables}\R1_Overvw_`1'.tex, append  ///
							se keep(TxA) nodepvar   star(* 0.10 ** 0.05 *** 0.01) ///
							 coeflabels(TxA "DDRD: C1-C3") ///
							mtitles("Men" "Women" )fragment noobs  booktabs nonotes  nonum lines
							
		
		*Heterogeneity Analysis with no CG3
		eststo clear
		qui eststo : DDRD `1'm " " "if  control != 3" //males
		qui eststo : DDRD `1'f " " "if  control != 3"	//females
		
		
		esttab  using ${tables}\R1_Overvw_`1'.tex, append  ///
							se keep(TxA)  nodepvar   star(* 0.10 ** 0.05 *** 0.01) ///
							coeflabels(TxA "DDRD: C2") ///
								nogaps fragment nolines noobs  booktabs nonotes nomti nogaps label nonum
		
		*Heterogeneity Analysis with CG2 only					 
		eststo clear
		qui eststo : DDRD `1'm " " "if  control != 3 & ( control == 2 | control == 4)" //males
		qui eststo : DDRD `1'f " " "if  control != 3& ( control == 2 | control == 4)"	//females
		
		
		esttab  using ${tables}\R1_Overvw_`1'.tex, append  ///
							se keep(TxA)  nodepvar   star(* 0.10 ** 0.05 *** 0.01) ///
							 coeflabels(TxA "DDRD: C1+C2") ///
								nogaps fragment nolines noobs  booktabs nonotes nomti nogaps label nonum
							
	
		
		
		
		
	
	end

	
	
	//renames
	rename Diag_neurot_stoerung_r Neurosis
	rename Diag_neurot_stoerung_rf Neurosisf
	rename Diag_neurot_stoerung_rm Neurosism
	
	rename Diag_gelenkerkrankung_r Joints			
	rename Diag_gelenkerkrankung_rf Jointsf
	rename Diag_gelenkerkrankung_rm Jointsm
	
	rename Diag_nierenkrank_r Kidneys			
	rename Diag_nierenkrank_rf Kidneysf			
	rename Diag_nierenkrank_rm Kidneysm			
	
	rename Diag_galle_pankreas_r Bile_pancreas			
	rename Diag_galle_pankreas_rf Bile_pancreasf			
	rename Diag_galle_pankreas_rm Bile_pancreasm
	
	rename Share_OP_f Share_OPf
	rename Share_OP_m Share_OPm
	
	rename DurschnVerweildauer Length_of_Stay
	rename DurschnVerweildauer_f Length_of_Stayf
	rename DurschnVerweildauer_m Length_of_Staym
	
	
	
	// Für zwei gender möglich
	#delimit;
	global Analysis1 
	hospital_r
	Diag_1_r
	Diag_2_r
	Diag_5_r
	Diag_6_r
	Diag_7_r 
	Diag_8_r 
	Diag_9_r 
	Diag_10_r
	Diag_11_r
	Diag_12_r
	Diag_13_r
	Diag_17_r
	Diag_18_r
	Diag_verletzung_r
	Neurosis
	Joints
	Kidneys
	Bile_pancreas
	Share_OP
	Length_of_Stay
	;
	#delimit cr
	
	
	foreach var of varlist $Analysis1 {
		Analyse_Overview  `var'
	}
	
	
//////////////////////////////////////////////////////////////////////////////////
*ohne heterogeneity (also ohne Mann/Frau)



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
	
	capture program drop Analyse_Overview2
	program define Analyse_Overview2
	//Linear RD
		qui eststo `1'_plain: RD `1' " " " "
		qui eststo `1'_year: RD `1' "Dy*" " "
		qui eststo `1'_cov: RD `1' "Dy* $perscontrols  "  " "
		esttab `1'* using ${tables}\R1_Overvw_`1'.tex, replace  ///
							se keep(after)  nodepvar   star(* 0.10 ** 0.05 *** 0.01) ///
							 coeflabels(after "RD Linear") ///
							 fragment noobs noeqlines booktabs nonotes label  nomti nogaps nonum nolines
	//Quadratic
		qui eststo `1'_plain: RD `1' " Numx2 Num2_after" " "
		qui eststo `1'_year: RD `1' "Dy* Numx2 Num2_after" " "
		qui eststo `1'_cov: RD `1' "Dy* $perscontrols Numx2 Num2_after"  " "
		esttab `1'* using ${tables}\R1_Overvw_`1'.tex, append  ///
							se keep(after)  nodepvar  star(* 0.10 ** 0.05 *** 0.01) ///
							 coeflabels(after "RD Quadratic") ///
							fragment nolines noobs  booktabs nonotes nomti nogaps label nonum
	//Cubic RD
		qui eststo `1'_plain: RD `1' " Numx2 Numx3 Num2_after Num3_after" " "
		qui eststo `1'_year: RD `1' "Dy* Numx2 Numx3 Num2_after Num3_after" " "
		qui eststo `1'_cov: RD `1' "Dy* $perscontrols Numx2 Numx3 Num2_after Num3_after "  " "
		esttab `1'* using ${tables}\R1_Overvw_`1'.tex, append  ///
							se keep(after)  nodepvar  star(* 0.10 ** 0.05 *** 0.01) ///
							 coeflabels(after "RD Cubic") ///
							fragment nolines noobs  booktabs nonotes nomti nogaps label nonum
	
	//Linear Donut RD
		qui eststo `1'_plain: RD `1' " " " &  Numx!=-1 & Numx!=1"
		qui eststo `1'_year: RD `1' "Dy*" " &  Numx!=-1 & Numx!=1"
		qui eststo `1'_cov: RD `1' "Dy* $perscontrols  "  " &  Numx!=-1 & Numx!=1"
		esttab `1'* using ${tables}\R1_Overvw_`1'.tex, append  ///
							se keep(after)  nodepvar  star(* 0.10 ** 0.05 *** 0.01) ///
							 coeflabels(after "RD Linear Donut") ///
							fragment nolines noobs  booktabs nonotes nomti nogaps label nonum
							
							

		*DDRD - 3 Control groups
		eststo clear
		qui eststo health_plain: DDRD `1' " " " "
		qui eststo health_year: DDRD `1' "Dy*" " "	
		qui eststo health_cova: DDRD `1' "Dy* $perscontrols "  " "
		qui eststo health_1m: DDRD `1' " " "if (Numx >= -1 & Numx <= 1)"
		qui eststo health_2m: DDRD `1' " " "if (Numx >= -2 & Numx <= 2)"
		qui eststo health_4m: DDRD `1' " " "if (Numx >= -4 & Numx <= 4)"
		qui eststo health_donut: DDRD `1' " " "if (Numx != -1 & Numx != 1)"
		
		esttab health* using ${tables}\R1_Overvw_`1'.tex, append  ///
							title("2.1) Difference-in-difference regression discontinuity (DDRD): Impact on `1', all control cohorts") ///
							se keep(TxA)  nodepvar   star(* 0.10 ** 0.05 *** 0.01) ///
							 coeflabels(TxA "DDRD: C1-C3") /// 
							fragment noobs  booktabs nonotes   nomti  nonum lines 
		
		*only one cohort prior to treatment cohort
		eststo clear
		qui eststo health_plain: DDRD `1' " " "if  control == 2 | control == 4"
		qui eststo health_year: DDRD `1' "Dy*" "if  control == 2| control == 4 "	
		qui eststo health_cova: DDRD `1' "Dy* $perscontrols "  "if  control == 2| control == 4 "
		qui eststo health_1m: DDRD `1' " " "if  (control == 2 | control == 4) & (Numx >= -1 & Numx <= 1)"
		qui eststo health_2m: DDRD `1' " " "if  (control == 2 | control == 4) & (Numx >= -2 & Numx <= 2)"
		qui eststo health_4m: DDRD `1' " " "if  (control == 2 | control == 4) & (Numx >= -4 & Numx <= 4)"
		qui eststo health_donut: DDRD `1' " " "if  (control == 2 | control == 4) & (Numx != -1 & Numx != 1)"
		esttab health* using ${tables}\R1_Overvw_`1'.tex, append  ///
							se keep(TxA) nodepvar  star(* 0.10 ** 0.05 *** 0.01) ///
							coeflabels(TxA "DDRD: C2") ///
							fragment nolines noobs  booktabs nonotes nomti nogaps label nonum
							
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
		
		qui eststo health_1m: DDRD `1' " " "if  control != 3 & (Numx >= -1 & Numx <= 1)"
		qui eststo health_2m: DDRD `1' " " "if  control != 3 & (Numx >= -2 & Numx <= 2)"
		qui eststo health_4m: DDRD `1' " " "if  control != 3 & (Numx >= -4 & Numx <= 4)"
		qui eststo health_donut: DDRD `1' " " "if  control != 3 & (Numx != -1 & Numx != 1)"
		
		esttab health* using ${tables}\R1_Overvw_`1'.tex, append  ///
							se keep(TxA) nodepvar  star(* 0.10 ** 0.05 *** 0.01) ///
							scalars( "bm Birthmonth FE" "year Time FE" ///
							"cov Pers covar" ) coeflabels(TxA "DDRD: C1+C2") ///
							fragment nolines noobs  booktabs nonotes nomti nogaps label nonum  noeqlines 
							
		
	end
			
		
		
		
// Für ein gender möglich 

qui egen Delivery = rowtotal(Diag_betreuung_problem_r Diag_komplikation_wehen_r)
rename Diag_magen_krank_r Stomach
rename Diag_gutartg_krebs_r Benign_neoplasm
rename Diag_boesartg_neubild_r Malig_neoplasm
rename Diag_venen_lymph_r Lymphoma
rename Diag_depression_r  Depression
rename Diag_sonst_herzkrank_r  Heart
rename Diag_persoenlichk_stoerung_r Personality
rename Diag_kreislauf_atmung_r Symp_resp	
rename Diag_steine_r Calculi	
rename Diag_krank_schwanger_r Pregnancy
											


	#delimit;
	global Analysis2
	Diag_14_r 
	Diag_genital_w_r
	Pregnancy
	Delivery
	Stomach
	Diag_verdauung_r
	Benign_neoplasm
	Malig_neoplasm
	Lymphoma
	Depression
	Heart
	Personality
	Symp_resp
	Calculi
	;
	#delimit cr
	
	
	foreach var of varlist $Analysis2 {
		Analyse_Overview2  `var'
	}
////////////////////////////////////////////////////////////////////////////////

********************************************************************************
		*****  Life/course Perspective  *****
********************************************************************************
*Life Course ist jetzt nur mit CG2
//generate age_treat: age of the respective treatment cohort
	sort year  MOB control
	qui gen age_treat = .
	qui replace age_treat = age if control == 4 
	qui replace age_treat = age -1 if control == 2
	
	
	
	// Mit x Achse ist age of treatment group
	capture program drop LC
	program define LC
		eststo clear
		capture drop b CIL CIR
		qui gen b=.
		qui gen CIL =.
		qui gen CIR =. 
		
		forvalues X = 2005 (1) 2013 {
			DDRD `1' " " " if year == `X' & (control == 2 | control == 4)"
			qui replace b = _b[TxA] if year == `X'
			qui replace CIL = (_b[TxA]-1.645*_se[TxA]) if year == `X'
			qui replace CIR = (_b[TxA]+1.645*_se[TxA]) if year == `X'
		}
		
		
		twoway line b age_treat,sort  xaxis(2)  color(white) ///
			legend(off)  xtitle("Age of treatment group", axis(2)) ||	 ///
		 rarea CIL CIR year, sort color(gs14) lcolor(gray) lpattern(dash) || ///
			line b year, sort color(gray) ///
			legend(off) ytitle(ITT `1') scheme(s1mono) ///
			yline(0, lw(thin) lpattern(solid)) color(black) ///
			xlabel(none, axis(1)) xtitle("", axis(1)) ///
			title(" `2' ")
			graph export "$graphs/R1_LC_`1'.pdf", as(pdf) replace
	
	end
	
	
	

	
	


// Für zwei gender möglich
	#delimit;
	global Analysis1 
	hospital_r
	Diag_1_r
	Diag_2_r
	Diag_5_r
	Diag_6_r
	Diag_7_r 
	Diag_8_r 
	Diag_9_r 
	Diag_10_r
	Diag_11_r
	Diag_12_r
	Diag_13_r
	Diag_17_r
	Diag_18_r
	Diag_verletzung_r
	Neurosis
	Joints
	Kidneys
	Bile_pancreas
	Share_OP
	Length_of_Stay
	
	;
	#delimit cr
	
	
	foreach var of varlist $Analysis1 {
		LC  `var'
		LC `var'f
		LC `var'm
	}

	foreach var of varlist $Analysis2 {
		LC `var'
	}

	*mit überschriften
	capture program drop LC2
	program define LC2
		eststo clear
		capture drop b CIL CIR
		qui gen b=.
		qui gen CIL =.
		qui gen CIR =. 
		
		forvalues X = 2005 (1) 2013 {
			DDRD `1' " " " if year == `X' & (control == 2 | control == 4)"
			qui replace b = _b[TxA] if year == `X'
			qui replace CIL = (_b[TxA]-1.645*_se[TxA]) if year == `X'
			qui replace CIR = (_b[TxA]+1.645*_se[TxA]) if year == `X'
		}
		
		twoway rarea CIL CIR year, sort color(gs14) lcolor(gray) lpattern(dash) || ///
			line b year, sort color(gray) ///
			legend(off) ytitle(ITT Estimate) scheme(s1mono) ///
			yline(0, lw(thin) lpattern(solid)) color(black) ///
			title(" `2' ")
			graph export "$graphs/R1_LC_`1'.pdf", as(pdf) replace
	
	end
	
	LC2 Diag_5_r "Mental and behavioural disorders"
	LC2 Diag_14_r "Pregnancy, childbirth and the puerperium"
	LC2 Diag_verdauung_r "Symptoms of the digestive system"
	LC2	Heart "Non-ischemic heart disease"
	LC2 Bile_pancreas "Diseases of the bile and pancreas"

	
////////////// 07.10.2017: Alternative Spezifikation mit tripple interaction
	keep if control == 2 | control == 4
	foreach X of numlist 2005(1)2013 {
		gen TxA_`X' = TxA*`X'
	}
	
	reg Diag_5_r treat after TxA Dmon* TxA_2006 - TxA_2013 , vce(cluster MxY) 

	

////////////////////////////////////////////////////////
*Look at Control group

	rename Numx NumX
	rename Numx2 NumX2
	rename Numx3 NumX3


capture program drop RD_graphCG
	program define RD_graphCG
		preserve
		qui keep if control == 2 
		qui drop if `1' ==.
		
		qui bys Datum:egen AVRG_`1' = mean (`1')
		qui sum `1'
		scalar define `1'_nrobs=r(N)	
		scalar define `1'_mean=r(mean)
		qui reg `1' NumX Num_after after
		qui predict `1'_hat_linear
		qui reg `1' NumX NumX2 after Num_after Num2_after
		qui predict `1'_hat_quadratic
		qui reg `1' NumX NumX2 NumX3 after Num_after Num2_after Num3_after
		qui predict `1'_hat_cubic	
		qui reg `1'  NumX Num_after after if (NumX!=-1 & NumX!=1)
		qui predict `1'_donut_linear
		scatter AVRG_`1' Datum2,  scheme(s1mono )  title(" `4' ") ///
                 tline(01may1978, lw(medthick ) lpattern(dash)) ///
                xtitle("Birth month") ytitle(" `1' ") yscale(r(`2' `3')) ///
                ylabel(#5,grid) tlabel(15nov1977 (60) 15sep1978, format(%tdmy)) tmtick(15dec1977 (60) 15oct1978) ///
				legend(off)
				
		graph export "$graphs/R1_RD_`1'_CG2.pdf", as(pdf) replace
		restore
	end
	
	capture program drop RD_grapheCG
	program define RD_grapheCG
		preserve
		qui keep if control == 2 
		qui drop if `1' ==.
		
		qui bys Datum:egen AVRG_`1' = mean (`1')
		qui sum `1'
		scalar define `1'_nrobs=r(N)	
		scalar define `1'_mean=r(mean)
		qui reg `1' NumX Num_after after
		qui predict `1'_hat_linear
		qui reg `1' NumX NumX2 after Num_after Num2_after
		qui predict `1'_hat_quadratic
		qui reg `1' NumX NumX2 NumX3 after Num_after Num2_after Num3_after
		qui predict `1'_hat_cubic	
		qui reg `1'  NumX Num_after after if (NumX!=-1 & NumX!=1)
		qui predict `1'_donut_linear
		scatter AVRG_`1' Datum2,  scheme(s1mono )  title(" `4' ") `7' ///
                 tline(01may1978, lw(medthick ) lpattern(dash)) ///
                xtitle("Birth month") ytitle(" `1' ") yscale(r(`2' `3')) ///
                ylabel(#5,grid) tlabel(15nov1977 (60) 15sep1978, format(%tdmy)) tmtick(15dec1977 (60) 15oct1978) ///
				line `1'_hat_linear    Datum2 if after == 1, sort color(black) lpattern(dash) || ///
				line `1'_hat_linear    Datum2 if after == 0, sort color(black) lpattern(dash) || ///
				line `1'_hat_quadratic Datum2 if after == 1, sort color(black) || ///
				line `1'_hat_quadratic Datum2 if after == 0, sort color(black) || ///
				line `1'_hat_cubic     Datum2 if after == 1, sort color(black) lpattern(dot) || ///
				line `1'_hat_cubic     Datum2 if after == 0, sort color(black) lpattern(dot) || ///
				line `1'_donut_linear  Datum2 if (after == 1 & NumX!=1), sort color(gray) || ///
				line `1'_donut_linear  Datum2 if (after == 0 & NumX!=-1), sort color(gray) /// 
				legend(off) //note("Notitz fuer die Geheimhaltungspruefung: Diese Graphik basiert auf `=`1'_nrobs' Beobachtungen.")
		graph export "$graphs/R1_RD_`1'_CG2fits.pdf", as(pdf) replace
		restore
	end


RD_graphCG Diag_5_r  0 0.03 "Mental and behavioural disorders" 
RD_grapheCG Diag_5_r  0 0.03 "Mental and behavioural disorders" 






	
	********************
	// Table Outcomes
	#delimit;
	global outcome_table
	hospital_r 
	Share_OP
	Length_of_Stay
	Diag_5_r
	Diag_14_r
	Bile_pancreas
	Diag_verdauung_r
	Heart
	;
	#delimit cr
	
	foreach var of varlist $outcome_table {
		summ `var' if control == 2 | control == 4
		gen `var'_Diff = `var'[_n] - `var'[_n-1] if treat == 1
	}
	
	*number of outcomes
	keep if control ==2 | control == 4
	
	foreach var of varlist hospital Diag_5 Diag_14 Diag_galle_pankreas Diag_verdauung Diag_sonst_herzkrank {
		capture drop `var'_total
		qui egen `var'_total = total(`var')
		summ `var'_total
	}

	
	
	
	** generate monthly difference
*br GDR control year YOB MOB Diag_5_r* if control == 2 | control == 4
keep if (control == 2 | control == 4) & GDR == 0
sort MOB year YOB
gen Diag_5_Diff = Diag_5_r[_n] - Diag_5_r[_n-1] if treat == 1




capture program drop RD_graphD
	program define RD_graphD
		preserve
		qui keep if treat == 1 `5'
		qui drop if `1' ==.
		
		qui bys Datum:egen AVRG_`1' = mean (`1')
		qui sum `1'
		scalar define `1'_nrobs=r(N)	
		scalar define `1'_mean=r(mean)

		scatter AVRG_`1' Datum2,  scheme(s1mono )  title(" `4' ") ///
                 tline(01may1979, lw(medthick ) lpattern(dash)) ///
                xtitle("Birth month") ytitle(" `1' ") yscale(r(`2' `3')) ///
				ytitle("Difference treatment - control") ///
                ylabel(#5,grid) tlabel(15nov1978 (60) 15sep1979, format(%tdmy)) tmtick(15dec1978 (60) 15oct1979) ///
				legend(off)
				
		graph export "$graphs/R1_RD_`1'.pdf", as(pdf) replace
		restore
	end

	RD_graphD hospital_r_Diff  -0.05 0.05 "Hospital admission" //"& Numx >= -6 & Numx <= 6"
	RD_graphD Share_OP_Diff  -0.01 0.05 "Share surgery" 
	RD_graphD Length_of_Stay_Diff  -0.15 0.15 "Average length of stay" 
	RD_graphD Diag_5_r_Diff  -0.01 0.01 "Mental and behavioural disorders" 
		*RD_graphe Diag_5_Diff  -0.01 0.01 "Mental and behavioural disorders" 0.027
	RD_graphD Diag_14_r_Diff  -0.01 0.01 "Pregnancy, childbirth and the puerperium" 
	RD_graphD Bile_pancreas_Diff  -0.001 0.001 "Diseases of the bile and pancreas" 
	RD_graphD2  Diag_verdauung_r_Diff  -0.001 0.001 "Symptoms of the digestive system" 
	RD_graphD  Heart_Diff -0.001 0.001 "Non-ischemic heart diseasem"

	
	//Einzelne graphen mit BW 5 Monate
	*Hospital
	capture program drop RD_graphD2
	program define RD_graphD2
		preserve
		qui keep if treat == 1 & Numx > -6 & Numx < 6
		
		qui bys Datum:egen AVRG_`1' = mean (`1') 
		qui sum `1'

		scatter AVRG_`1' Datum2,  scheme(s1mono )  title(" `4' ") ///
                 tline(01may1979, lw(medthick ) lpattern(dash)) ///
                xtitle("Birth month") ytitle(" Difference treatment - control") yscale(r(`2' `3')) ///
                ylabel(#5,grid) tlabel(15dec1978 (60) 15sep1979, format(%tdmy)) tmtick(15jan1979 (60) 15sep1979) ///
				legend(off)
				
		graph export "$graphs/R1_RD_`1'.pdf", as(pdf) replace
		restore
	end
	
		RD_graphD2 hospital_r_Diff  -0.05 0.05 "Hospital admission" //"& Numx >= -6 & Numx <= 6"

	   
