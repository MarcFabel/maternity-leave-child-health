// ***************************** PREAMBLE********************************
	clear all 
	set more off
	
	*paths
	global path   	   	"G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis"	
	global temp   	   	"$path/temp"
	global graphs      	"$path/graphs/KKH"
	global graph_paper 	"$path/graphs/paper"
	global tables 		"$path/tables/KKH"
	global tables_paper "$path/tables/paper"
	global auxiliary 	"$path/do-files/auxiliary_files"
	
	*magic numbers
	global first_year = 1995
	global last_year  = 2014
	global t_90		  = 1.645
	global t_95   	  = 1.960
	
	* List of control groups
	global C2    = "(control == 2 | control == 4)"
	global C1_C2 = "control != 3"
	global C1_C3 = "reform == 1"
	
	* Bandwidths (sample selection)
	global M2 = "(Numx >= -2 & Numx <= 2)"
	global M4 = "(Numx >= -4 & Numx <= 4)"
	global M6 = "reform == 1"
	global MD = "(Numx != -1 & Numx != 1)"﻿

// ***********************************************************************

use "$temp\KKH_final_R1", clear
run "$auxiliary/varlists_varnames_sample-spcifications"


*define new global for tables ( müssen extra abgespeichert werden) 


capture program drop DDRD
	program define DDRD
		qui eststo `1': reg `2' treat after TxA  `3'  `4', vce(cluster MxY) 
	end
capture program drop DDRD_sclrs
	program define DDRD_sclrs
		qui eststo `1': reg `2' treat after TxA  `3'  `4', vce(cluster MxY) 
		qui estadd scalar Nn = e(N)
		qui sum `2' if e(sample) & treat== 1 & after == 0 
		qui estadd scalar mean = round(`r(mean)',.01)		// pre-reform mean for treated group
		qui estadd scalar sd = abs(round(_b[TxA]/`r(sd)'*100,.01))		
		capture drop Dinregression sum_num_diag*
		qui gen Dinregression = 1 if cond(e(sample),1,0)
		bys Dinregression: egen sum_num_diagnoses = total(`2')
		qui summ sum_num_diagnoses if e(sample)
		qui estadd scalar num_diag = `r(mean)'
	end		
	
	

foreach 1 of varlist hospital2  d5  { // hospital2 d5 
	foreach j in "" "_f" "_m" { // "" "_f" "_m" 
		eststo clear 	
		*overall effect
		DDRD_sclrs b2 r_fert_`1'`j'   "i.MOB i.year" "if $C2 & $M3 & $all_age"
		DDRD_sclrs b4 r_fert_`1'`j'   "i.MOB i.year" "if $C2 & $M4 & $all_age"
		DDRD_sclrs b5 r_fert_`1'`j'   "i.MOB i.year" "if $C2 & $M5 & $all_age"
		DDRD_sclrs b6 r_fert_`1'`j'   "i.MOB i.year" "if $C2 & $all_age"
		DDRD_sclrs b7 r_fert_`1'`j'   "i.MOB i.year" "if $C2 & $MD & $all_age"
		esttab b* using "$tables_paper/include/paper_`1'`j'_DD_overall.tex", replace booktabs fragment ///
			keep(TxA) coeflabels(TxA "\hspace*{10pt}Overall") ///
			se star(+ 0.15 * 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			scalars(  "mean \midrule Dependent mean" "sd Effect in SDs [\%]" "Nn \(N\) (MOB $\times$ year)")  
			
		* effect per age group
		foreach age_group in "$age_17_21" "$age_22_26" "$age_27_31" "$age_32_35" { //
			if "`age_group'" == "$age_17_21" {
				local age_label = "Age 17-21"
				local age_outputname = "17-21"
			}
			if "`age_group'" == "$age_22_26" {
				local age_label = "Age 22-26"
				local age_outputname = "22-26"
			}
			if "`age_group'" == "$age_27_31" {
				local age_label = "Age 27-31"
				local age_outputname = "27-31"
			}
			if "`age_group'" == "$age_32_35" {
				local age_label = "Age 32-35"
				local age_outputname = "32-35"
			}
			eststo clear 
			DDRD b2 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & $C2 & $M3"
			DDRD b4 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & $C2 & $M4"
			DDRD b5 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & $C2 & $M5"
			DDRD b6 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & $C2"
			DDRD b7 r_fert_`1'`j'   "i.MOB i.year" "if `age_group' & $C2 & $MD"
			esttab b* using "$tables_paper/include/paper_`1'`j'_DD_`age_outputname'.tex", replace booktabs fragment ///
				keep(TxA) coeflabels(TxA "\hspace*{10pt}`age_label'") ///
				se star(+ 0.15 * 0.10 ** 0.05 *** 0.01) ///
				label nomtitles nonumbers noobs nonote nogaps noline  
		} // end: agegroup
	} // end: tfm
	// Panels zusammenfassen
	
} //end: varlist
	

	
////////////////////////////////////////////////////////////////////////////////
// Tabelle: Verteilung der ITT Effekte über die Hauptdiagnosen
use "$temp\KKH_final_R1", clear
run "$auxiliary/varlists_varnames_sample-spcifications"

*define short globals for variable labels in the table
global hospital2 "Hospital"
global d1  "IPD"
global d2  "Neo"
global d5  "MBD"
global d6  "Ner"
global d7  "Sen" 
global d8  "Cir"
global d9  "Res"
global d10 "Dig"
global d11 "SST"
global d12 "Mus"
global d13 "Gen"
global d17 "Sym"
global d18 "Ext"


foreach j in "" "_f" "_m" { // "" "_f" "_m"
	*initiate filewith hospitalization	
	foreach 1 of varlist hospital2  { 
		*overall effect
		eststo clear 	
		DDRD b0 r_fert_`1'`j'   "i.MOB i.year" "if $C2 & $all_age"
		local iter = 1
		foreach age_group in "$age_17_21" "$age_22_26" "$age_27_31" "$age_32_35" { //
			DDRD b_`iter' r_fert_`1'`j'  "i.MOB i.year" "if `age_group' & $C2"
			local iter = `iter' + 1 
		} // end: age group
		esttab b* using "$tables_paper/paper_ITTacrosschapters`j'.tex", replace booktabs fragment ///
			keep(TxA) coeflabels(TxA "$`1'") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nonumbers nomtitles noobs nonote nogaps noline  
	} // end: varlist		
	
	* continue with the main chapters		
	foreach 1 of varlist d1 d2 d5 d6 d7 d8 d9 d10 d11 d12 d13 d17 d18  { //  
		*overall effect
		eststo clear 	
		DDRD b0 r_fert_`1'`j'   "i.MOB i.year" "if $C2 & $all_age"
		local iter = 1
		foreach age_group in "$age_17_21" "$age_22_26" "$age_27_31" "$age_32_35" { //
			DDRD b_`iter' r_fert_`1'`j'  "i.MOB i.year" "if `age_group' & $C2"
			local iter = `iter' + 1 
		} // end: age group
		esttab b* using "$tables_paper/paper_ITTacrosschapters`j'.tex", append booktabs fragment ///
			keep(TxA) coeflabels(TxA "$`1'") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline 
	} // end: varlist
} // end: tfm


********************************************************************************

*Robustness 
*current population
	DDRD_sclrs b1 r_popf_hospital2   "i.MOB i.year" "if $C2"
	DDRD_sclrs b2 r_popf_hospital2_f   "i.MOB i.year" "if $C2"
	DDRD_sclrs b3 r_popf_hospital2_m   "i.MOB i.year" "if $C2"
	esttab b* ,  ///
		keep(TxA) ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		scalars(  "mean \midrule Dependent mean" "sd Effect in SDs [\%]" "Nn Observations")  

		
* temporal placebo
capture program drop DDRD
	program define DDRD
		qui eststo `1': reg `2' p_treat p_after p_TxA   `3'  `4', vce(cluster MxY)
		qui estadd scalar Nn = e(N)
		qui sum `2' if e(sample) & p_treat== 1 & p_after == 0 
		qui estadd scalar mean = round(`r(mean)',.01)		// pre-reform mean for treated group
		qui estadd scalar sd = abs(round(_b[p_TxA]/`r(sd)'*100,.01))		
	end	
	
	use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"

*delete treatment cohort
drop if control == 4 	


capture drop p_threshold p_treat p_after p_TxA
*2) May prior cohort is treat ==1 (CONTROL2 IS TREAT)
	qui gen p_threshold = monthly("1978m5", "YM")
	format p_threshold %tm
	local threshm 5
	local binw 6
	qui gen p_treat = cond((Datum>p_threshold-`binw'-1 & Datum<p_threshold + `binw' ),1,0)	
	qui gen p_after = cond((MOB>= `threshm' & MOB< `threshm'+`binw' ),1,0)		// Months after reform
	qui gen p_TxA = p_treat*p_after

	global control2 = "(control == 2 | control == 1)"

	
foreach 1 of varlist hospital2 d5 {	
	eststo clear
	DDRD b1 r_fert_`1'   "i.MOB i.year" "if $control2"
	DDRD b2 r_fert_`1'_f   "i.MOB i.year" "if $control2"
	DDRD b3 r_fert_`1'_m   "i.MOB i.year" "if $control2"
	
	esttab b* ,  ///
			keep(p_TxA)  ///
			se star(* 0.10 ** 0.05 *** 0.01) /// 
					scalars(  "mean \midrule Dependent mean" "sd Effect in SDs [\%]" "Nn Observations")  

}
