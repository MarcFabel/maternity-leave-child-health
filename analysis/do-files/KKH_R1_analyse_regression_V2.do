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
		 eststo: reg `1' treat after TxA Dmon*  `2'  `3', vce(cluster MxY2) 
	end
	
	
	/////////////
	*cluster
	
	*alternativer cluster: YOB_MOB über strings
	qui tostring YOB, gen(temp1)
	qui tostring MOB, gen(temp2)
	qui gen MxY2 = temp1+temp2
	drop temp1 temp2
	destring MxY2, replace 
	
	DDRD hospital_r " " "if  control == 2 | control == 4"
	////////////
	
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
		
		twoway rarea CIL CIR year, sort color(gs14) lcolor(gray) lpattern(dash) || ///
			line b year, sort color(gray) ///
			legend(off) ytitle(ITT `1') scheme(s1mono) ///
			yline(0, lw(thin) lpattern(solid)) color(black) 
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



















