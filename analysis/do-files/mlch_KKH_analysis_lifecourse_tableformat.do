/*******************************************************************************
* File name: 	
* Author: 		Marc Fabel
* Date: 		21.11.2017
* Description:	Regression analysis - LC agegroups -> Table format 
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
		qui eststo: reg `1' after Numx Num_after `2' if treat ==1 `3', vce(cluster MxY) 		
	end

	capture program drop DDRD
	program define DDRD
		qui eststo `1': reg `2' treat after TxA   `3'  `4', vce(cluster MxY) 
	end
	
////////////////////////////////////////////////////////////////////////////////
						*** Regression Analysis ***
////////////////////////////////////////////////////////////////////////////////
	use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"




 ********************************************************************************	

 keep if control == 2 | control == 4
 
 
  
 // next steps: LC for different age groups
  	* globals for age range 5 years taken together (age refers to year in which TG is that old)
	global age_17_21 = "(year_treat >= 1996 & year_treat<=2000)"
	global age_22_26 = "(year_treat >= 2001 & year_treat<=2005)"
	global age_27_31 = "(year_treat >= 2006 & year_treat<=2010)"
	global age_32_35 = "(year_treat >= 2011 & year_treat<=2014)"
 
 
 foreach 1 of varlist $list_vars_mandf_ratios_available { //$list_vars_mandf_ratios_available
	foreach j in "" "_f" "_m"{ // 
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if $C2 & $age_17_21"
		DDRD a2 `1'`j'   	"i.MOB" "if $C2 & $age_22_26"
		DDRD a3 `1'`j'   	"i.MOB" "if $C2 & $age_27_31"
		DDRD a4 `1'`j'   	"i.MOB" "if $C2 & $age_32_35"
		esttab a* using "$tables/`1'_LC_agegroups_a`j'.tex", replace booktabs fragment ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline
 
		*ratio fertility
		DDRD b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_17_21"
		DDRD b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_22_26"
		DDRD b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_27_31"
		DDRD b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_32_35"
		esttab b* using "$tables/`1'_LC_agegroups_b`j'.tex", replace booktabs fragment ///
			keep(TxA) coeflabels(TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline
			
		*ratio population
		*DDRD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_17_21"
		DDRD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_22_26"
		DDRD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_27_31"
		DDRD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_32_35"
		esttab c* using "$tables/`1'_LC_agegroups_c`j'.tex", replace booktabs fragment ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline
 
		*cumulative numbers	
		DDRD e1 cum_`1'`j'   	"i.MOB" "if $C2 & $age_17_21"
		DDRD e2 cum_`1'`j'   	"i.MOB" "if $C2 & $age_22_26"
		DDRD e3 cum_`1'`j'  	"i.MOB" "if $C2 & $age_27_31"
		DDRD e4 cum_`1'`j'   	"i.MOB" "if $C2 & $age_32_35"
		esttab e* using "$tables/`1'_LC_agegroups_e`j'.tex", replace booktabs fragment ///
			keep(TxA) coeflabels(TxA "Cum. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline
			
		*cumulative ratio
		DDRD f1 r_cum_`1'`j'   	"i.MOB" "if $C2 & $age_17_21"
		DDRD f2 r_cum_`1'`j'   	"i.MOB" "if $C2 & $age_22_26"
		DDRD f3 r_cum_`1'`j'  	"i.MOB" "if $C2 & $age_27_31"
		DDRD f4 r_cum_`1'`j'   	"i.MOB" "if $C2 & $age_32_35"
		esttab f* using "$tables/`1'_LC_agegroups_f`j'.tex", replace booktabs fragment ///
			keep(TxA) coeflabels(TxA "Cum. ratio") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
	} //end: loop over t,f,m
 
	// Panels zusammenfassen
	esttab a* using "$tables/`1'_LC_agegroups.tex", replace booktabs ///
		cells(none) nonote noobs ///
		mtitles("Age 17-21" "Age 22-26" "Age 27-31" "Age 32-35" ) ///
		prehead( ///
		\begin{table}[H]  ///
			\centering  ///
			\begin{threeparttable} ///
			\caption{Life-course approach - Table format} ///
			{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
			\begin{tabular}{l*{@span}{c}} \toprule ///
			\multicolumn{@span}{l}{Dep. variable: \textbf{$`1'}} \\ ///
			& \multicolumn{@M}{c}{Estimation window} \\ \cmidrule(lr){2-5}) ///
			prefoot( ///
				\multicolumn{@span}{l}{\emph{Panel A. Average causal effects}} \\ ///
				\input{`1'_LC_agegroups_a} ///
				\input{`1'_LC_agegroups_b} ///
				\input{`1'_LC_agegroups_c} ///
				\input{`1'_LC_agegroups_e} ///
				\input{`1'_LC_agegroups_f} ///
				\midrule\multicolumn{@span}{l}{\emph{Panel B. Treatment effect heterogeneity - Women}} \\ ///
				\input{`1'_LC_agegroups_a_f} ///
				\input{`1'_LC_agegroups_b_f} ///
				\input{`1'_LC_agegroups_c_f} ///
				\input{`1'_LC_agegroups_e_f} ///
				\input{`1'_LC_agegroups_f_f} ///
				\midrule\multicolumn{@span}{l}{\emph{Panel C. Treatment effect heterogeneity - Men}} \\ ///
				\input{`1'_LC_agegroups_a_m} ///
				\input{`1'_LC_agegroups_b_m} ///
				\input{`1'_LC_agegroups_c_m} ///
				\input{`1'_LC_agegroups_e_m} ///
				\input{`1'_LC_agegroups_f_m} ///
				) ///
			postfoot(\bottomrule \end{tabular} } ///
			\begin{tablenotes} ///
			\item \scriptsize ///
			\emph{Notes:} Clustered standard errors in parentheses. All regression are run with CG2 (i.e. the cohort prior to the reform) and with month-of-birth FEs. Ratios indicate cases per thousand; either approximated population (with weights coming from the original fertility distribution) or original number of births. Raqtio population muss eins nach rechts gerückt werden   ///
			\end{tablenotes} ///
			\end{threeparttable} ///
		\end{table} ///
		) ///
		substitute(\_ _)
	
	
	
} //end: loop over variables
 
 
