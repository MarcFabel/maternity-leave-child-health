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
		qui eststo: reg `1' after Numx Num_after `2' if treat ==1 `3', vce(cluster MxY) 		
	end

	capture program drop DDRD
	program define DDRD
		qui eststo `1': reg `2' p_treat p_after p_TxA   `3'  `4', vce(cluster MxY) 
	end
	
////////////////////////////////////////////////////////////////////////////////
						*** Regression Analysis ***
////////////////////////////////////////////////////////////////////////////////
	use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"

*delete treatment cohort
drop if control == 4 

********************************************************************************
*********************	 CONTROL1 IS TREAT	  **********************************
********************************************************************************
// redefinition of treatment status 

*1) May 2 prior cohort is treat ==1 (CONTROL1 ist TREAT)
	qui gen p_threshold = monthly("1977m5", "YM")
	format p_threshold %tm
	local threshm 5
	local binw 6
	qui gen p_treat = cond((Datum>p_threshold-`binw'-1 & Datum<p_threshold + `binw' ),1,0)	
	qui gen p_after = cond((MOB>= `threshm' & MOB< `threshm'+`binw' ),1,0)		// Months after reform
	qui gen p_TxA = p_treat*p_after

	global control2 = "(control == 1 | control == 2)"
	global control3 = "(control == 1 | control == 3)"


//  Program 
foreach 1 of varlist $list_vars_mandf_ratios_available { // $list_vars_mandf_ratios_available
	foreach j in "" "_f" "_m"{ // 
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if $control2"
		DDRD a2 `1'`j'   	"i.MOB" "if $control3"
		DDRD a3 `1'`j'   	"i.MOB" ""
		esttab a* using "$tables/`1'_a`j'_placebo1.tex", replace booktabs fragment ///
			keep(p_TxA) coeflabels(p_TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline
				
		*ratio fertility
		DDRD b1 r_fert_`1'`j'   "i.MOB" "if $control2"
		DDRD b2 r_fert_`1'`j'   "i.MOB" "if $control3"
		DDRD b3 r_fert_`1'`j'   "i.MOB" ""
		esttab b* using "$tables/`1'_b`j'_placebo1.tex", replace booktabs fragment ///
			keep(p_TxA) coeflabels(p_TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
		*ratio population
		DDRD c1 r_popf_`1'`j'   "i.MOB" "if $control2"
		DDRD c2 r_popf_`1'`j'   "i.MOB" "if $control3"
		DDRD c3 r_popf_`1'`j'   "i.MOB" ""
		esttab c* using "$tables/`1'_c`j'_placebo1.tex", replace booktabs fragment ///
			keep(p_TxA) coeflabels(p_TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline
			
		*cumulative numbers	
		DDRD e1 cum_`1'`j'   	"i.MOB" "if $control2"
		DDRD e2 cum_`1'`j'   	"i.MOB" "if $control3"
		DDRD e3 cum_`1'`j'  	"i.MOB" ""
		esttab e* using "$tables/`1'_e`j'_placebo1.tex", replace booktabs fragment ///
			keep(p_TxA) coeflabels(p_TxA "Cum. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline
			
		*cumulative ratio
		DDRD f1 r_cum_`1'`j'   	"i.MOB" "if $control2"
		DDRD f2 r_cum_`1'`j'   	"i.MOB" "if $control3"
		DDRD f3 r_cum_`1'`j'  	"i.MOB" ""
		esttab f* using "$tables/`1'_f`j'_placebo1.tex", replace booktabs fragment ///
			keep(p_TxA) coeflabels(p_TxA "Cum. ratio") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
	} //end: loop over t,f,m
	
	// Panels zusammenfassen
	esttab a* using "$tables/`1'_placebo1.tex", replace booktabs ///
		cells(none) nonote noobs ///
		mtitles("C2" "C3" "C2+C3" ) ///
		prehead( ///
		\begin{table}[H]  ///
			\centering  ///
			\begin{threeparttable} ///
			\caption{Placebo 1 (CONTROL1 ist TREAT) } ///
			{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
			\begin{tabular}{l*{@span}{c}} \toprule ///
			\multicolumn{@span}{l}{Dep. variable: \textbf{$`1'}} \\ ///
			& \multicolumn{@M}{c}{Choice of control group} \\ \cmidrule(lr){2-4}) ///
			prefoot( ///
				\multicolumn{@span}{l}{\emph{Panel A. Average causal effects}} \\ ///
				\input{`1'_a_placebo1} ///
				\input{`1'_b_placebo1} ///
				\input{`1'_c_placebo1} ///
				\input{`1'_e_placebo1} ///
				\input{`1'_f_placebo1} ///
				\midrule\multicolumn{@span}{l}{\emph{Panel B. Treatment effect heterogeneity - Women}} \\ ///
				\input{`1'_a_f_placebo1} ///
				\input{`1'_b_f_placebo1} ///
				\input{`1'_c_f_placebo1} ///
				\input{`1'_e_f_placebo1} ///
				\input{`1'_f_f_placebo1} ///
				\midrule\multicolumn{@span}{l}{\emph{Panel C. Treatment effect heterogeneity - Men}} \\ ///
				\input{`1'_a_m_placebo1} ///
				\input{`1'_b_m_placebo1} ///
				\input{`1'_c_m_placebo1} ///
				\input{`1'_e_m_placebo1} ///
				\input{`1'_f_m_placebo1} ///
				) ///
			postfoot(\bottomrule \end{tabular} } ///
			\begin{tablenotes} ///
			\item \scriptsize ///
			\emph{Notes:} Clustered standard errors in parentheses. All regression are run with month-of-birth FEs and control cohort 2 is assigned with the treatment status. All regressions are carried out with a window width of half a year.   ///
			\end{tablenotes} ///
			\end{threeparttable} ///
		\end{table} ///
		) ///
		substitute(\_ _)
	
	
	
} //end: loop over variables	
********************************************************************************
*********************	 CONTROL2 IS TREAT	  **********************************
********************************************************************************
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
	global control3 = "(control == 2 | control == 3)"


//  Program 
foreach 1 of varlist $list_vars_mandf_ratios_available { // $list_vars_mandf_ratios_available
	foreach j in "" "_f" "_m"{ // 
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if $control2"
		DDRD a2 `1'`j'   	"i.MOB" "if $control3"
		DDRD a3 `1'`j'   	"i.MOB" ""
		esttab a* using "$tables/`1'_a`j'_placebo2.tex", replace booktabs fragment ///
			keep(p_TxA) coeflabels(p_TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline
				
		*ratio fertility
		DDRD b1 r_fert_`1'`j'   "i.MOB" "if $control2"
		DDRD b2 r_fert_`1'`j'   "i.MOB" "if $control3"
		DDRD b3 r_fert_`1'`j'   "i.MOB" ""
		esttab b* using "$tables/`1'_b`j'_placebo2.tex", replace booktabs fragment ///
			keep(p_TxA) coeflabels(p_TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
		*ratio population
		DDRD c1 r_popf_`1'`j'   "i.MOB" "if $control2"
		DDRD c2 r_popf_`1'`j'   "i.MOB" "if $control3"
		DDRD c3 r_popf_`1'`j'   "i.MOB" ""
		esttab c* using "$tables/`1'_c`j'_placebo2.tex", replace booktabs fragment ///
			keep(p_TxA) coeflabels(p_TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline
			
		*cumulative numbers	
		DDRD e1 cum_`1'`j'   	"i.MOB" "if $control2"
		DDRD e2 cum_`1'`j'   	"i.MOB" "if $control3"
		DDRD e3 cum_`1'`j'  	"i.MOB" ""
		esttab e* using "$tables/`1'_e`j'_placebo2.tex", replace booktabs fragment ///
			keep(p_TxA) coeflabels(p_TxA "Cum. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline
			
		*cumulative ratio
		DDRD f1 r_cum_`1'`j'   	"i.MOB" "if $control2"
		DDRD f2 r_cum_`1'`j'   	"i.MOB" "if $control3"
		DDRD f3 r_cum_`1'`j'  	"i.MOB" ""
		esttab f* using "$tables/`1'_f`j'_placebo2.tex", replace booktabs fragment ///
			keep(p_TxA) coeflabels(p_TxA "Cum. ratio") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
	} //end: loop over t,f,m
	
	// Panels zusammenfassen
	esttab a* using "$tables/`1'_placebo2.tex", replace booktabs ///
		cells(none) nonote noobs ///
		mtitles("C1" "C3" "C1+C3" ) ///
		prehead( ///
		\begin{table}[H]  ///
			\centering  ///
			\begin{threeparttable} ///
			\caption{Placebo 2 (CONTROL2 ist TREAT) } ///
			{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
			\begin{tabular}{l*{@span}{c}} \toprule ///
			\multicolumn{@span}{l}{Dep. variable: \textbf{$`1'}} \\ ///
			& \multicolumn{@M}{c}{Choice of control group} \\ \cmidrule(lr){2-4}) ///
			prefoot( ///
				\multicolumn{@span}{l}{\emph{Panel A. Average causal effects}} \\ ///
				\input{`1'_a_placebo2} ///
				\input{`1'_b_placebo2} ///
				\input{`1'_c_placebo2} ///
				\input{`1'_e_placebo2} ///
				\input{`1'_f_placebo2} ///
				\midrule\multicolumn{@span}{l}{\emph{Panel B. Treatment effect heterogeneity - Women}} \\ ///
				\input{`1'_a_f_placebo2} ///
				\input{`1'_b_f_placebo2} ///
				\input{`1'_c_f_placebo2} ///
				\input{`1'_e_f_placebo2} ///
				\input{`1'_f_f_placebo2} ///
				\midrule\multicolumn{@span}{l}{\emph{Panel C. Treatment effect heterogeneity - Men}} \\ ///
				\input{`1'_a_m_placebo2} ///
				\input{`1'_b_m_placebo2} ///
				\input{`1'_c_m_placebo2} ///
				\input{`1'_e_m_placebo2} ///
				\input{`1'_f_m_placebo2} ///
				) ///
			postfoot(\bottomrule \end{tabular} } ///
			\begin{tablenotes} ///
			\item \scriptsize ///
			\emph{Notes:} Clustered standard errors in parentheses. All regression are run with month-of-birth FEs and control cohort 2 is assigned with the treatment status. All regressions are carried out with a window width of half a year.   ///
			\end{tablenotes} ///
			\end{threeparttable} ///
		\end{table} ///
		) ///
		substitute(\_ _)
	
	
	
} //end: loop over variables	
********************************************************************************
*********************	 CONTROL3 IS TREAT	  **********************************
********************************************************************************
capture drop p_threshold p_treat p_after p_TxA

*3) May preceeding cohort is treat ==1 ()
	qui gen p_threshold = monthly("1980m5", "YM")
	format p_threshold %tm
	local threshm 5
	local binw 6
	qui gen p_treat = cond((Datum>p_threshold-`binw'-1 & Datum<p_threshold + `binw' ),1,0)	
	qui gen p_after = cond((MOB>= `threshm' & MOB< `threshm'+`binw' ),1,0)		// Months after reform
	qui gen p_TxA = p_treat*p_after

	global control2 = "(control == 3 | control == 1)"
	global control3 = "(control == 3 | control == 2)"


//  Program 
foreach 1 of varlist $list_vars_mandf_ratios_available { // $list_vars_mandf_ratios_available
	foreach j in "" "_f" "_m"{ // 
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if $control2"
		DDRD a2 `1'`j'   	"i.MOB" "if $control3"
		DDRD a3 `1'`j'   	"i.MOB" ""
		esttab a* using "$tables/`1'_a`j'_placebo3.tex", replace booktabs fragment ///
			keep(p_TxA) coeflabels(p_TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline
				
		*ratio fertility
		DDRD b1 r_fert_`1'`j'   "i.MOB" "if $control2"
		DDRD b2 r_fert_`1'`j'   "i.MOB" "if $control3"
		DDRD b3 r_fert_`1'`j'   "i.MOB" ""
		esttab b* using "$tables/`1'_b`j'_placebo3.tex", replace booktabs fragment ///
			keep(p_TxA) coeflabels(p_TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
		*ratio population
		DDRD c1 r_popf_`1'`j'   "i.MOB" "if $control2"
		DDRD c2 r_popf_`1'`j'   "i.MOB" "if $control3"
		DDRD c3 r_popf_`1'`j'   "i.MOB" ""
		esttab c* using "$tables/`1'_c`j'_placebo3.tex", replace booktabs fragment ///
			keep(p_TxA) coeflabels(p_TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline
			
		*cumulative numbers	
		DDRD e1 cum_`1'`j'   	"i.MOB" "if $control2"
		DDRD e2 cum_`1'`j'   	"i.MOB" "if $control3"
		DDRD e3 cum_`1'`j'  	"i.MOB" ""
		esttab e* using "$tables/`1'_e`j'_placebo3.tex", replace booktabs fragment ///
			keep(p_TxA) coeflabels(p_TxA "Cum. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline
			
		*cumulative ratio
		DDRD f1 r_cum_`1'`j'   	"i.MOB" "if $control2"
		DDRD f2 r_cum_`1'`j'   	"i.MOB" "if $control3"
		DDRD f3 r_cum_`1'`j'  	"i.MOB" ""
		esttab f* using "$tables/`1'_f`j'_placebo3.tex", replace booktabs fragment ///
			keep(p_TxA) coeflabels(p_TxA "Cum. ratio") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
	} //end: loop over t,f,m
	
	// Panels zusammenfassen
	esttab a* using "$tables/`1'_placebo3.tex", replace booktabs ///
		cells(none) nonote noobs ///
		mtitles("C1" "C2" "C1+C2" ) ///
		prehead( ///
		\begin{table}[H]  ///
			\centering  ///
			\begin{threeparttable} ///
			\caption{Placebo 3 (CONTROL3 ist TREAT) } ///
			{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
			\begin{tabular}{l*{@span}{c}} \toprule ///
			\multicolumn{@span}{l}{Dep. variable: \textbf{$`1'}} \\ ///
			& \multicolumn{@M}{c}{Choice of control group} \\ \cmidrule(lr){2-4}) ///
			prefoot( ///
				\multicolumn{@span}{l}{\emph{Panel A. Average causal effects}} \\ ///
				\input{`1'_a_placebo3} ///
				\input{`1'_b_placebo3} ///
				\input{`1'_c_placebo3} ///
				\input{`1'_e_placebo3} ///
				\input{`1'_f_placebo3} ///
				\midrule\multicolumn{@span}{l}{\emph{Panel B. Treatment effect heterogeneity - Women}} \\ ///
				\input{`1'_a_f_placebo3} ///
				\input{`1'_b_f_placebo3} ///
				\input{`1'_c_f_placebo3} ///
				\input{`1'_e_f_placebo3} ///
				\input{`1'_f_f_placebo3} ///
				\midrule\multicolumn{@span}{l}{\emph{Panel C. Treatment effect heterogeneity - Men}} \\ ///
				\input{`1'_a_m_placebo3} ///
				\input{`1'_b_m_placebo3} ///
				\input{`1'_c_m_placebo3} ///
				\input{`1'_e_m_placebo3} ///
				\input{`1'_f_m_placebo3} ///
				) ///
			postfoot(\bottomrule \end{tabular} } ///
			\begin{tablenotes} ///
			\item \scriptsize ///
			\emph{Notes:} Clustered standard errors in parentheses. All regression are run with month-of-birth FEs and control cohort 3 is assigned with the treatment status. All regressions are carried out with a window width of half a year.   ///
			\end{tablenotes} ///
			\end{threeparttable} ///
		\end{table} ///
		) ///
		substitute(\_ _)
	
	
	
} //end: loop over variables





********************************************************************************
/*
Alte Spezifikation (Columns were estimation windows)


//  Program 
foreach 1 of varlist d5 { // $list_vars_mandf_ratios_available
	foreach j in "" "_f" "_m"{ // 
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if $M1"
		DDRD a2 `1'`j'   	"i.MOB" "if $M2"
		DDRD a3 `1'`j'   	"i.MOB" "if $M3"
		DDRD a4 `1'`j'   	"i.MOB" "if $M4"
		DDRD a5 `1'`j'   	"i.MOB" "if $M5"
		DDRD a6 `1'`j'   	"i.MOB" ""
		DDRD a7 `1'`j'   	"i.MOB" "if $MD"
		esttab a* using "$tables/`1'_a`j'_placebo1.tex", replace booktabs fragment ///
			keep(p_TxA) coeflabels(p_TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline
				
		*ratio fertility
		DDRD b1 r_fert_`1'`j'   "i.MOB" "if $M1"
		DDRD b2 r_fert_`1'`j'   "i.MOB" "if $M2"
		DDRD b3 r_fert_`1'`j'   "i.MOB" "if $M3"
		DDRD b4 r_fert_`1'`j'   "i.MOB" "if $M4"
		DDRD b5 r_fert_`1'`j'   "i.MOB" "if $M5"
		DDRD b6 r_fert_`1'`j'   "i.MOB" ""
		DDRD b7 r_fert_`1'`j'   "i.MOB" "if $MD"
		esttab b* using "$tables/`1'_b`j'_placebo1.tex", replace booktabs fragment ///
			keep(p_TxA) coeflabels(p_TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
		*ratio population
		DDRD c1 r_popf_`1'`j'   "i.MOB" "if $M1"
		DDRD c2 r_popf_`1'`j'   "i.MOB" "if $M2"
		DDRD c3 r_popf_`1'`j'   "i.MOB" "if $M3"
		DDRD c4 r_popf_`1'`j'   "i.MOB" "if $M4"
		DDRD c5 r_popf_`1'`j'   "i.MOB" "if $M5"
		DDRD c6 r_popf_`1'`j'   "i.MOB" ""
		DDRD c7 r_popf_`1'`j'   "i.MOB" "if $MD"
		esttab c* using "$tables/`1'_c`j'_placebo1.tex", replace booktabs fragment ///
			keep(p_TxA) coeflabels(p_TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline
			
		*cumulative numbers	
		DDRD e1 cum_`1'`j'   	"i.MOB" "if $M1"
		DDRD e2 cum_`1'`j'   	"i.MOB" "if $M2"
		DDRD e3 cum_`1'`j'  	"i.MOB" "if $M3"
		DDRD e4 cum_`1'`j'   	"i.MOB" "if $M4"
		DDRD e5 cum_`1'`j'   	"i.MOB" "if $M5"
		DDRD e6 cum_`1'`j'   	"i.MOB" ""
		DDRD e7 cum_`1'`j'  	"i.MOB" "if $MD"
		esttab e* using "$tables/`1'_e`j'_placebo1.tex", replace booktabs fragment ///
			keep(p_TxA) coeflabels(p_TxA "Cum. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline
			
		*cumulative ratio
		DDRD f1 r_cum_`1'`j'   	"i.MOB" "if $M1"
		DDRD f2 r_cum_`1'`j'   	"i.MOB" "if $M2"
		DDRD f3 r_cum_`1'`j'  	"i.MOB" "if $M3"
		DDRD f4 r_cum_`1'`j'   	"i.MOB" "if $M4"
		DDRD f5 r_cum_`1'`j'   	"i.MOB" "if $M5"
		DDRD f6 r_cum_`1'`j'   	"i.MOB" ""
		DDRD f7 r_cum_`1'`j'  	"i.MOB" "if $MD"
		esttab f* using "$tables/`1'_f`j'_placebo1.tex", replace booktabs fragment ///
			keep(p_TxA) coeflabels(p_TxA "Cum. ratio") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
	} //end: loop over t,f,m
	
	// Panels zusammenfassen
	esttab a* using "$tables/`1'_placebo1.tex", replace booktabs ///
		cells(none) nonote noobs ///
		mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
		prehead( ///
		\begin{table}[H]  ///
			\centering  ///
			\begin{threeparttable} ///
			\caption{Placebo 1 - CG1 is assigned the value of the treatment group} ///
			{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
			\begin{tabular}{l*{@span}{c}} \toprule ///
			\multicolumn{@span}{l}{Dep. variable: \textbf{$`1'}} \\ ///
			& \multicolumn{@M}{c}{Estimation window} \\ \cmidrule(lr){2-8}) ///
			prefoot( ///
				\multicolumn{@span}{l}{\emph{Panel A. Average causal effects}} \\ ///
				\input{`1'_a_placebo1} ///
				\input{`1'_b_placebo1} ///
				\input{`1'_c_placebo1} ///
				\input{`1'_e_placebo1} ///
				\input{`1'_f_placebo1} ///
				\midrule\multicolumn{@span}{l}{\emph{Panel B. Treatment effect heterogeneity - Women}} \\ ///
				\input{`1'_a_f_placebo1} ///
				\input{`1'_b_f_placebo1} ///
				\input{`1'_c_f_placebo1} ///
				\input{`1'_e_f_placebo1} ///
				\input{`1'_f_f_placebo1} ///
				\midrule\multicolumn{@span}{l}{\emph{Panel C. Treatment effect heterogeneity - Men}} \\ ///
				\input{`1'_a_m_placebo1} ///
				\input{`1'_b_m_placebo1} ///
				\input{`1'_c_m_placebo1} ///
				\input{`1'_e_m_placebo1} ///
				\input{`1'_f_m_placebo1} ///
				) ///
			postfoot(\bottomrule \end{tabular} } ///
			\begin{tablenotes} ///
			\item \scriptsize ///
			\emph{Notes:} Clustered standard errors in parentheses. All regression are run with month-of-birth FEs and control cohort 1 is assigned with the treatment status. Ratios indicate cases per thousand; either approximated population (with weights coming from the original fertility distribution) or original number of births.   ///
			\end{tablenotes} ///
			\end{threeparttable} ///
		\end{table} ///
		) ///
		substitute(\_ _)
	
	
	
} //end: loop over variables	


















