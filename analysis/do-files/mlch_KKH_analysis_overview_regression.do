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
	global auxiliary "$path/do-files/auxiliary_files"

	
	*magic numbers
	global first_year = 1995
	global last_year  = 2014
	
	*checkmark
	global check "\checkmark" // können auch andere Zeichen benutzt werden, eg Latex \checkmark
// ***********************************************************************

	
////////////////////////////////////////////////////////////////////////////////
						*** Regression Analysis ***
////////////////////////////////////////////////////////////////////////////////
	use "$temp\KKH_final_R1", clear
	
	run "$auxiliary/varlists_varnames_sample-spcifications"


	


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


/*
INSGESAMMT 6 PROGRAMME
*/


********************************************************************************	
/// Accumulated variables
rename fertm fert_m
rename fertf fert_f

*generate variable
foreach 1 of varlist $list_vars_mandf_ratios_available {
	capture drop cum_`1'* r_cum_`1'*
	foreach j in "" "_f" "_m"{
		sort Datum year
		by Datum: gen cum_`1'`j' = sum(`1'`j')
		gen r_cum_`1'`j' = cum_`1'`j'*1000 / fert`j'
		
		
	}
 }
	
********************************************************************************	
//graph for TG & CG
	sort year Datum
	*averages for cumulative numbers: 
	capture drop av_cum_d5
	bys year after control: egen av_cum_d5 = sum(cum_d5)
	*differences post- pre
	keep if control == 2 | control == 4
	sort year control after MOB_alt
	qui gen diff_av_cum_d5 = av_cum_d5[_n] - av_cum_d5[_n-1] if MOB[_n] == 5 
	foreach 1 of varlist d5 {
		twoway line av_cum_`1' year if control == 2 & after == 0, yaxis(1) lpattern(dash)  lcolor(cranberry%50) || ///
		line av_cum_`1' year if control == 2 & after == 1, yaxis(1) lpattern(solid) lcolor(cranberry%50) || ///
		line av_cum_`1' year if control == 4 & after == 0, yaxis(1) lpattern(dash) lcolor(black%80) || ///
		line av_cum_`1' year if control == 4 & after == 1, yaxis(1) lcolor(black%80) || ///
		line diff_av_cum_`1' year if control == 2, yaxis(2) lcolor(cranberry%20) || ///
		line diff_av_cum_`1' year if control == 4, yaxis(2) lcolor(black%20) ///
		scheme(s1mono) legend(label( 1 "CG pre") label(2 "CG post") label(3 "TG pre") label(4 "TG post") ///
		label(5 "Δ CG") label(6 "Δ TG")) ///
		legend(size(small)) legend(rows(1)) ///
		ytitle("accumulated numbers of diagnoses", axis(1)) ytitle("Differences: post-pre", axis(2)) 
	}

order diff_av Datum YOB MOB year after control fert d5 cum_d5 av_cum r_cum_d5 fert_m cum_d5_m r_cum_d5_m
********************************************************************************	
* Februarfälle - Tabelle 
/*	     MOB
--------------
year|*/

*keep just two relevant cohorts!
keep if control == 2 | control == 4 // crucial for sorting later on (step2)


//1) just treatmentgroup
mat A = J(20,12,.)

foreach 1 of varlist $list_vars_mandf_ratios_available {
	local j = 1
	foreach y of numlist 1995/2014 {
		foreach m of numlist 1/12 {
			qui summ `1' if control == 2 & MOB_altern == `m' & year == `y'
			mat A[`j',`m'] = r(mean)
		} //end:loop over months
		local j = `j' + 1
	} // end:loopover years
	matrix rownames A = 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014	
	esttab m(A) using "$tables/`1'_TG_cases_per_MOB_year.tex",collabels(11 12 1 2 3 4 5 6 7 8 9 10 ) plain nomtitles replace ///
		prehead( ///
			\begin{table}[H]  ///
				\begin{threeparttable} ///
				\centering  ///
				\caption{Dep. variable: \textbf{$`1'}} ///
				{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
				\begin{tabular}{l*{@span}{c}} \toprule ///
				year & \multicolumn{12}{c}{Month of birth} \\ \cmidrule(lr){2-13} ///
		) ///
		postfoot( \bottomrule \end{tabular} } ///
			\begin{tablenotes} ///
			\item \scriptsize ///
			\emph{Notes:} Number of cases per year and MOB in treatment cohort.   ///
			\end{tablenotes} ///
			\end{threeparttable} ///
			\end{table} ///
		)
} // end:loop varlist

//2) difference control - treatment
	sort year MOB control
foreach 1 of varlist $list_vars_mandf_ratios_available {	
	qui gen diff_TC_`1' = `1'[_n-1] - `1'[_n]   if control[_n] ==  4	// eingetragen bei der treatment gruppe
}
	
foreach 1 of varlist $list_vars_mandf_ratios_available {
	local j = 1
	foreach y of numlist 1995/2014 {
		foreach m of numlist 1/12 {
			qui summ diff_TC_`1' if control == 4 & MOB_altern == `m' & year == `y'
			mat A[`j',`m'] = r(mean)
		} //end:loop over months
		local j = `j' + 1
	} // end:loopover years
	matrix rownames A = 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014	
	esttab m(A) using "$tables/`1'_differenced_cases_per_MOB_year.tex",collabels(11 12 1 2 3 4 5 6 7 8 9 10 ) plain nomtitles replace ///
		prehead( ///
			\begin{table}[H]  ///
				\begin{threeparttable} ///
				\centering  ///
				\caption{Dep. variable: \textbf{$`1'}} ///
				{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
				\begin{tabular}{l*{@span}{c}} \toprule ///
				year & \multicolumn{12}{c}{Month of birth} \\ \cmidrule(lr){2-13} ///
		) ///
		postfoot( \bottomrule \end{tabular} } ///
			\begin{tablenotes} ///
			\item \scriptsize ///
			\emph{Notes:} Difference of cases (control - treatment) per year and MOB in treatment cohort.   ///
			\end{tablenotes} ///
			\end{threeparttable} ///
			\end{table} ///
		)
} // end:loop varlist

********************************************************************************	
// neues Program 
foreach 1 of varlist $list_vars_mandf_ratios_available {
	foreach j in "" "_f" "_m"{ // 
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if $C2 & $M1"
		DDRD a2 `1'`j'   	"i.MOB" "if $C2 & $M2"
		DDRD a3 `1'`j'   	"i.MOB" "if $C2 & $M3"
		DDRD a4 `1'`j'   	"i.MOB" "if $C2 & $M4"
		DDRD a5 `1'`j'   	"i.MOB" "if $C2 & $M5"
		DDRD a6 `1'`j'   	"i.MOB" "if $C2"
		DDRD a7 `1'`j'   	"i.MOB" "if $C2 & $MD"
		esttab a* using "$tables/`1'_a`j'.tex", replace booktabs fragment ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline
				
		*ratio fertility
		DDRD b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD b6 r_fert_`1'`j'   "i.MOB" "if $C2"
		DDRD b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab b* using "$tables/`1'_b`j'.tex", replace booktabs fragment ///
			keep(TxA) coeflabels(TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
		*ratio population
		DDRD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD c6 r_popf_`1'`j'   "i.MOB" "if $C2"
		DDRD c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab c* using "$tables/`1'_c`j'.tex", replace booktabs fragment ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline
			
		*ratio fertility für 2003-2014
		DDRD d1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1 & (year>=2003 & year<=2014)"
		DDRD d2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2 & (year>=2003 & year<=2014)"
		DDRD d3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3 & (year>=2003 & year<=2014)"
		DDRD d4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4 & (year>=2003 & year<=2014)"
		DDRD d5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5 & (year>=2003 & year<=2014)"
		DDRD d6 r_fert_`1'`j'   "i.MOB" "if $C2 & (year>=2003 & year<=2014)"
		DDRD d7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD & (year>=2003 & year<=2014)"
		esttab d* using "$tables/`1'_d`j'.tex", replace booktabs fragment ///
			keep(TxA) coeflabels(TxA "Ratio fert(03-14)") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline
			
		*cumulative numbers	
		DDRD e1 cum_`1'`j'   	"i.MOB" "if $C2 & $M1"
		DDRD e2 cum_`1'`j'   	"i.MOB" "if $C2 & $M2"
		DDRD e3 cum_`1'`j'  	"i.MOB" "if $C2 & $M3"
		DDRD e4 cum_`1'`j'   	"i.MOB" "if $C2 & $M4"
		DDRD e5 cum_`1'`j'   	"i.MOB" "if $C2 & $M5"
		DDRD e6 cum_`1'`j'   	"i.MOB" "if $C2"
		DDRD e7 cum_`1'`j'  	"i.MOB" "if $C2 & $MD"
		esttab e* using "$tables/`1'_e`j'.tex", replace booktabs fragment ///
			keep(TxA) coeflabels(TxA "Cum. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline
			
		*cumulative ratio
		DDRD f1 r_cum_`1'`j'   	"i.MOB" "if $C2 & $M1"
		DDRD f2 r_cum_`1'`j'   	"i.MOB" "if $C2 & $M2"
		DDRD f3 r_cum_`1'`j'  	"i.MOB" "if $C2 & $M3"
		DDRD f4 r_cum_`1'`j'   	"i.MOB" "if $C2 & $M4"
		DDRD f5 r_cum_`1'`j'   	"i.MOB" "if $C2 & $M5"
		DDRD f6 r_cum_`1'`j'   	"i.MOB" "if $C2"
		DDRD f7 r_cum_`1'`j'  	"i.MOB" "if $C2 & $MD"
		esttab f* using "$tables/`1'_f`j'.tex", replace booktabs fragment ///
			keep(TxA) coeflabels(TxA "Cum. ratio") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
	} //end: loop over t,f,m
	
	// Panels zusammenfassen
	esttab a* using "$tables/`1'_DDRD_overview_tfm.tex", replace booktabs ///
		cells(none) nonote noobs ///
		mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
		prehead( ///
		\begin{table}[H]  ///
			\begin{threeparttable} ///
			\centering  ///
			\caption{Dep. variable: \textbf{$`1'}} ///
			{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
			\begin{tabular}{l*{@span}{c}} \toprule ///
			& \multicolumn{@M}{c}{Estimation window} \\ \cmidrule(lr){2-8}) ///
			prefoot( ///
				\multicolumn{@span}{l}{\emph{Panel A. Average causal effects}} \\ ///
				\input{`1'_a} ///
				\input{`1'_b} ///
				\input{`1'_c} ///
				\input{`1'_d} ///
				\input{`1'_e} ///
				\input{`1'_f} ///
				\midrule\multicolumn{@span}{l}{\emph{Panel B. Treatment effect heterogeneity - Women}} \\ ///
				\input{`1'_a_f} ///
				\input{`1'_b_f} ///
				\input{`1'_c_f} ///
				\input{`1'_d_f} ///
				\input{`1'_e_f} ///
				\input{`1'_f_f} ///
				\midrule\multicolumn{@span}{l}{\emph{Panel C. Treatment effect heterogeneity - Men}} \\ ///
				\input{`1'_a_m} ///
				\input{`1'_b_m} ///
				\input{`1'_c_m} ///
				\input{`1'_d_m} ///
				\input{`1'_e_m} ///
				\input{`1'_f_m} ///
				) ///
			postfoot(\bottomrule \end{tabular} } ///
			\begin{tablenotes} ///
			\item \scriptsize ///
			\emph{Notes:} Clustered standard errors in parentheses. All regression are run with CG2 (i.e. the cohort prior to the reform) and with month-of-birth FEs. Ratios indicate cases per thousand; either approximated population (with weights coming from the original fertility distribution) or original number of births.   ///
			\end{tablenotes} ///
			\end{threeparttable} ///
		\end{table} ///
		) ///
		substitute(\_ _)
	
	
	
} //end: loop over variables
		
		

/*


////////////////////////////////////////////////////////////////////////////////
					*** FÜR 2 GENDER & RATIOS AVAILABLE ***
////////////////////////////////////////////////////////////////////////////////
//  OVERVIEW 1 : CONTROLS
foreach 1 of varlist $list_vars_mandf_ratios_available  { 
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
	DDRD b1 r_popf_`1'   "						  " "if $C2 & $M2" 
	DDRD b2 r_popf_`1'   "i.MOB 				      " "if $C2 & $M2"
	DDRD b3 r_popf_`1'   "i.MOB i.year 			  " "if $C2 & $M2" 
	DDRD b4 r_popf_`1'   "i.MOB i.year $controlvars" "if $C2 & $M2"
	DDRD b5 r_popf_`1'_f "i.MOB 					  " "if $C2 & $M2"
	DDRD b6 r_popf_`1'_m "i.MOB 					  " "if $C2 & $M2"
	esttab b* using "$tables/`1'2Mc.tex", replace booktabs fragment ///
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
	
	esttab c* using "$tables/`1'2Mb.tex", replace booktabs fragment ///
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
	DDRD b1 r_popf_`1'	"						  " "if $C2 & $M4" 
	DDRD b2 r_popf_`1'	"i.MOB 				      " "if $C2 & $M4"
	DDRD b3 r_popf_`1'	"i.MOB i.year 			  " "if $C2 & $M4" 
	DDRD b4 r_popf_`1'	"i.MOB i.year $controlvars" "if $C2 & $M4"
	DDRD b5 r_popf_`1'_f "i.MOB 					  " "if $C2 & $M4"
	DDRD b6 r_popf_`1'_m "i.MOB 					  " "if $C2 & $M4"
	esttab b* using "$tables/`1'4Mc.tex", replace booktabs fragment ///
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
	esttab c* using "$tables/`1'4Mb.tex", replace booktabs fragment ///
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
	DDRD b1 r_popf_`1'   "						  " "if $C2 " 
	DDRD b2 r_popf_`1'   "i.MOB 				      " "if $C2 "
	DDRD b3 r_popf_`1'   "i.MOB i.year 			  " "if $C2 " 
	DDRD b4 r_popf_`1'   "i.MOB i.year $controlvars" "if $C2 "
	DDRD b5 r_popf_`1'_f "i.MOB 					  " "if $C2 "
	DDRD b6 r_popf_`1'_m "i.MOB 					  " "if $C2 "
	esttab b* using "$tables/`1'6Mc.tex", replace booktabs fragment ///
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
	esttab c* using "$tables/`1'6Mb.tex", replace booktabs fragment ///
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
	DDRD b1 r_popf_`1'   "						  " "if $C2 & $MD" 
	DDRD b2 r_popf_`1'   "i.MOB 				      " "if $C2 & $MD"
	DDRD b3 r_popf_`1'   "i.MOB i.year 			  " "if $C2 & $MD" 
	DDRD b4 r_popf_`1'   "i.MOB i.year $controlvars" "if $C2 & $MD"
	DDRD b5 r_popf_`1'_f "i.MOB 					  " "if $C2 & $MD"
	DDRD b6 r_popf_`1'_m "i.MOB 					  " "if $C2 & $MD"
	esttab b* using "$tables/`1'DMc.tex", replace booktabs fragment ///
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
	esttab c* using "$tables/`1'DMb.tex", replace booktabs fragment ///
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
esttab a* using "$tables/`1'_DDRD_overview_covars.tex", replace booktabs ///
		cells(none) nonote noobs ///
		mtitles( "" "" "" "" "Women" "Men") ///
		mgroups("Average Causal Effects" "Heterogeneous Causal Effects", pattern(1 0 0 0 1 0) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))  ///
		prehead( ///
		\begin{table}[H]  ///
			\begin{threeparttable} ///
			\centering  ///
			\caption{Robustness with respect to the inclusion of \texttt{fixed effects} and \texttt{covariates}} ///
			{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
			\begin{tabular}{l*{@span}{c}} \toprule ///
			& \multicolumn{@M}{c}{Dependent variable: \textbf{$`1'}} \\ \cmidrule(lr){2-7}) ///
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
			\begin{tablenotes} ///
			\item \scriptsize ///
			\emph{Notes:} Clustered standard errors in parentheses. Personal covariates contain age and age squared. All regression are run with CG2 (i.e. the cohort prior to the reform). Ratios indicate cases per thousand; either approximated population (with weights coming from the original fertility distribution) or original number of births.   ///
			\end{tablenotes} ///
			\end{threeparttable} ///
		\end{table} ///
		) ///
		substitute(\_ _)
		
		
}

********************************************************************************
// OVERVIEW 2: CHOICE OF CG	
foreach 1 of varlist $list_vars_mandf_ratios_available {
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
	esttab a* using "$tables/`1'2Ma_cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	
	*Ratio population
	DDRD b1 r_popf_`1'   "i.MOB" "if $C2    & $M2"
	DDRD b2 r_popf_`1'   "i.MOB" "if $C1_C2 & $M2" 
	DDRD b3 r_popf_`1'   "i.MOB" "if          $M2"
	DDRD b4 r_popf_`1'_f "i.MOB" "if $C2    & $M2"
	DDRD b5 r_popf_`1'_f "i.MOB" "if $C1_C2 & $M2" 
	DDRD b6 r_popf_`1'_f "i.MOB" "if          $M2"
	DDRD b7 r_popf_`1'_m "i.MOB" "if $C2    & $M2"
	DDRD b8 r_popf_`1'_m "i.MOB" "if $C1_C2 & $M2" 
	DDRD b9 r_popf_`1'_m "i.MOB" "if          $M2"
	esttab b* using "$tables/`1'2Mc_cg.tex", replace booktabs fragment ///
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
	esttab c* using "$tables/`1'2Mb_cg.tex", replace booktabs fragment ///
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
	esttab a* using "$tables/`1'4Ma_cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	
	*Ratio population
	DDRD b1 r_popf_`1'   "i.MOB" "if $C2    & $M4"
	DDRD b2 r_popf_`1'   "i.MOB" "if $C1_C2 & $M4" 
	DDRD b3 r_popf_`1'   "i.MOB" "if          $M4"
	DDRD b4 r_popf_`1'_f "i.MOB" "if $C2    & $M4"
	DDRD b5 r_popf_`1'_f "i.MOB" "if $C1_C2 & $M4" 
	DDRD b6 r_popf_`1'_f "i.MOB" "if          $M4"
	DDRD b7 r_popf_`1'_m "i.MOB" "if $C2    & $M4"
	DDRD b8 r_popf_`1'_m "i.MOB" "if $C1_C2 & $M4" 
	DDRD b9 r_popf_`1'_m "i.MOB" "if          $M4"
	esttab b* using "$tables/`1'4Mc_cg.tex", replace booktabs fragment ///
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
	esttab c* using "$tables/`1'4Mb_cg.tex", replace booktabs fragment ///
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
	esttab a* using "$tables/`1'6Ma_cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	
	*Ratio population
	DDRD b1 r_popf_`1'   "i.MOB" "if $C2   "
	DDRD b2 r_popf_`1'   "i.MOB" "if $C1_C2" 
	DDRD b3 r_popf_`1'   "i.MOB" "         "
	DDRD b4 r_popf_`1'_f "i.MOB" "if $C2   "
	DDRD b5 r_popf_`1'_f "i.MOB" "if $C1_C2" 
	DDRD b6 r_popf_`1'_f "i.MOB" "         "
	DDRD b7 r_popf_`1'_m "i.MOB" "if $C2   "
	DDRD b8 r_popf_`1'_m "i.MOB" "if $C1_C2" 
	DDRD b9 r_popf_`1'_m "i.MOB" "         "
	esttab b* using "$tables/`1'6Mc_cg.tex", replace booktabs fragment ///
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
	esttab c* using "$tables/`1'6Mb_cg.tex", replace booktabs fragment ///
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
	esttab a* using "$tables/`1'DMa_cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	
	*Ratio population
	DDRD b1 r_popf_`1'   "i.MOB" "if $C2    & $MD"
	DDRD b2 r_popf_`1'   "i.MOB" "if $C1_C2 & $MD" 
	DDRD b3 r_popf_`1'   "i.MOB" "if          $MD"
	DDRD b4 r_popf_`1'_f "i.MOB" "if $C2    & $MD"
	DDRD b5 r_popf_`1'_f "i.MOB" "if $C1_C2 & $MD" 
	DDRD b6 r_popf_`1'_f "i.MOB" "if          $MD"
	DDRD b7 r_popf_`1'_m "i.MOB" "if $C2    & $MD"
	DDRD b8 r_popf_`1'_m "i.MOB" "if $C1_C2 & $MD" 
	DDRD b9 r_popf_`1'_m "i.MOB" "if          $MD"
	esttab b* using "$tables/`1'DMc_cg.tex", replace booktabs fragment ///
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
	esttab c* using "$tables/`1'DMb_cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
		
		
	// Panels zusammenfassen
esttab a* using "$tables/`1'_DDRD_overview_cg.tex", replace booktabs ///
		cells(none) nonote noobs ///
		mtitles( "C2" "C1+C2" "C1-C3" "C2" "C1+C2" "C1-C3" "C2" "C1+C2" "C1-C3") ///
		mgroups("Average Causal Effects" "Women" "Men", pattern(1 0 0  1 0 0 1 0 0) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))  ///
		prehead( ///
			\begin{table}[H]  ///
			\begin{threeparttable} ///
			\centering  ///
			\caption{Robustness with respect to the choice of \texttt{control group}} ///
			{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
			\begin{tabular}{l*{@span}{c}} \toprule ///
			& \multicolumn{@M}{c}{Dependent variable: \textbf{$`1'}} \\ \cmidrule(lr){2-10}) ///		
		prefoot( ///
			\multicolumn{@span}{l}{\emph{Panel A. 2 Month bandwidth}} \\ ///
			\input{`1'2Ma_cg} ///
			\input{`1'2Mb_cg} ///
			\input{`1'2Mc_cg} ///
			\midrule\multicolumn{@span}{l}{\emph{Panel B. 4 Month bandwidth}} \\ ///
			\input{`1'4Ma_cg} ///
			\input{`1'4Mb_cg} ///
			\input{`1'4Mc_cg} ///
			\midrule\multicolumn{@span}{l}{\emph{Panel C. 6 Month bandwidth}} \\ ///
			\input{`1'6Ma_cg} ///
			\input{`1'6Mb_cg} ///
			\input{`1'6Mc_cg} ///
			\midrule\multicolumn{@span}{l}{\emph{Panel D. Donut specification}} \\ ///
			\input{`1'DMa_cg} ///
			\input{`1'DMb_cg} ///
			\input{`1'DMc_cg} ///
		) ///
		postfoot(\bottomrule \end{tabular} } ///
			\begin{tablenotes} ///
			\item \scriptsize ///
			\emph{Notes:} Clustered standard errors in parentheses. All regressions contain Birthmonth FE. Ratios indicate cases per thousand; either approximated population (with weights coming from the original fertility distribution) or original number of births.  ///
			\end{tablenotes} ///
			\end{threeparttable} ///
		\end{table} ///
		)		///
		substitute(\_ _)
}

////////////////////////////////////////////////////////////////////////////////
					*** NUR TOTALS & RATIOS AVAILABLE ***
////////////////////////////////////////////////////////////////////////////////
//  OVERVIEW 1 : CONTROLS	
foreach 1 of varlist  $list_vars_total_ratios_available  { //$list_vars_1gender_ratios_available
	// PANEL: 2 MONTHS 
	*absolute numbers
	eststo clear
	DDRD a1 `1'   "						 	" "if $C2 & $M2" 
	DDRD a2 `1'   "i.MOB 				    " "if $C2 & $M2"
	DDRD a3 `1'   "i.MOB i.year 			" "if $C2 & $M2" 
	DDRD a4 `1'   "i.MOB i.year $controlvars" "if $C2 & $M2"
	esttab a* using "$tables/`1'2Ma.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	
	*Ratio population
	DDRD b1 r_popf_`1'   "						  " "if $C2 & $M2" 
	DDRD b2 r_popf_`1'   "i.MOB 				      " "if $C2 & $M2"
	DDRD b3 r_popf_`1'   "i.MOB i.year 			  " "if $C2 & $M2" 
	DDRD b4 r_popf_`1'   "i.MOB i.year $controlvars" "if $C2 & $M2"
	esttab b* using "$tables/`1'2Mc.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	*Ratio fertility 
	DDRD c1 r_fert_`1'   "						   " "if $C2 & $M2" 
	DDRD c2 r_fert_`1'   "i.MOB 				   " "if $C2 & $M2"
	DDRD c3 r_fert_`1'   "i.MOB i.year 			   " "if $C2 & $M2" 
	DDRD c4 r_fert_`1'   "i.MOB i.year $controlvars" "if $C2 & $M2"
	esttab c* using "$tables/`1'2Mb.tex", replace booktabs fragment ///
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
	esttab a* using "$tables/`1'4Ma.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	
	*Ratio population
	DDRD b1 r_popf_`1'	"						  " "if $C2 & $M4" 
	DDRD b2 r_popf_`1'	"i.MOB 				      " "if $C2 & $M4"
	DDRD b3 r_popf_`1'	"i.MOB i.year 			  " "if $C2 & $M4" 
	DDRD b4 r_popf_`1'	"i.MOB i.year $controlvars" "if $C2 & $M4"
	esttab b* using "$tables/`1'4Mc.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	*Ratio fertility 
	DDRD c1 r_fert_`1'	 "						   " "if $C2 & $M4" 
	DDRD c2 r_fert_`1'	 "i.MOB 				   " "if $C2 & $M4"
	DDRD c3 r_fert_`1'	 "i.MOB i.year 			   " "if $C2 & $M4" 
	DDRD c4 r_fert_`1'	 "i.MOB i.year $controlvars" "if $C2 & $M4"
	esttab c* using "$tables/`1'4Mb.tex", replace booktabs fragment ///
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
	esttab a* using "$tables/`1'6Ma.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	
	*Ratio population
	DDRD b1 r_popf_`1'   "						  " "if $C2 " 
	DDRD b2 r_popf_`1'   "i.MOB 				      " "if $C2 "
	DDRD b3 r_popf_`1'   "i.MOB i.year 			  " "if $C2 " 
	DDRD b4 r_popf_`1'   "i.MOB i.year $controlvars" "if $C2 "
	esttab b* using "$tables/`1'6Mc.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	*Ratio fertility 
	DDRD c1 r_fert_`1'   "						   " "if $C2 " 
	DDRD c2 r_fert_`1'   "i.MOB 				   " "if $C2 "
	DDRD c3 r_fert_`1'   "i.MOB i.year 			   " "if $C2 " 
	DDRD c4 r_fert_`1'   "i.MOB i.year $controlvars" "if $C2 "
	esttab c* using "$tables/`1'6Mb.tex", replace booktabs fragment ///
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
	esttab a* using "$tables/`1'DMa.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	
	*Ratio population
	DDRD b1 r_popf_`1'   "						  " "if $C2 & $MD" 
	DDRD b2 r_popf_`1'   "i.MOB 				      " "if $C2 & $MD"
	DDRD b3 r_popf_`1'   "i.MOB i.year 			  " "if $C2 & $MD" 
	DDRD b4 r_popf_`1'   "i.MOB i.year $controlvars" "if $C2 & $MD"
	esttab b* using "$tables/`1'DMc.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	*Ratio fertility 
	DDRD c1 r_fert_`1'   "						   " "if $C2 & $MD" 
	DDRD c2 r_fert_`1'   "i.MOB 				   " "if $C2 & $MD"
	DDRD c3 r_fert_`1'   "i.MOB i.year 			   " "if $C2 & $MD" 
	DDRD c4 r_fert_`1'   "i.MOB i.year $controlvars" "if $C2 & $MD"
	esttab c* using "$tables/`1'DMb.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
		
	*FFOR BOTTOM: 
	DDRD c1 r_fert_`1'   "						   " "if $C2 & $MD" 
	DDRD c2 r_fert_`1'   "i.MOB 				   " "if $C2 & $MD"
	DDRD c3 r_fert_`1'   "i.MOB i.year 			   " "if $C2 & $MD" 
	DDRD c4 r_fert_`1'   "i.MOB i.year $controlvars" "if $C2 & $MD"
	esttab c* using "$tables/`1'checks.tex", replace booktabs fragment ///
		keep( ) coeflabels(TxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		indicate("Birthmonth FE = *MOB" "Year FE = *year" ///
		"Covariates = $controlvars", label("$check" ""))  ///
		label nomtitles nonumbers noobs nonote nogaps noline	
		
		// Panels zusammenfassen
esttab a* using "$tables/`1'_DDRD_overview_covars.tex", replace booktabs ///
		cells(none) nonote noobs ///
		nomtitles ///
		prehead( ///
		\begin{table}[H]  ///
			\begin{threeparttable} ///
			\centering  ///
			\caption{Robustness with respect to the inclusion of \texttt{fixed effects} and \texttt{covariates}} ///
			{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
			\begin{tabular}{l*{@span}{c}} \toprule ///
			\multicolumn{@span}{c}{Dependent variable: \textbf{$`1'}} \\ \cmidrule(lr){2-5}) ///
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
			\begin{tablenotes} ///
			\item \scriptsize ///
			\emph{Notes:} Clustered standard errors in parentheses. Personal covariates contain age and age squared.  All regression are run with CG2 (i.e. the cohort prior to the reform).Ratios indicate cases per thousand; either approximated population (with weights coming from the original fertility distribution) or original number of births.  ///
			\end{tablenotes} ///
			\end{threeparttable} ///
		\end{table} ///
		) ///
		substitute(\_ _)
		
		
}

********************************************************************************
// OVERVIEW 2: CHOICE OF CG	
foreach 1 of varlist $list_vars_total_ratios_available  { //$vars_1gender_ratios_available
	// PANEL: 2 MONTHS 
	*absolute numbers
	eststo clear
	DDRD a1 `1'   "i.MOB" "if $C2    & $M2"
	DDRD a2 `1'   "i.MOB" "if $C1_C2 & $M2" 
	DDRD a3 `1'   "i.MOB" "if          $M2"
	esttab a* using "$tables/`1'2Ma_cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	
	*Ratio population
	DDRD b1 r_popf_`1'   "i.MOB" "if $C2    & $M2"
	DDRD b2 r_popf_`1'   "i.MOB" "if $C1_C2 & $M2" 
	DDRD b3 r_popf_`1'   "i.MOB" "if          $M2"
	esttab b* using "$tables/`1'2Mc_cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	*Ratio fertility
	DDRD c1 r_fert_`1'   "i.MOB" "if $C2    & $M2"
	DDRD c2 r_fert_`1'   "i.MOB" "if $C1_C2 & $M2" 
	DDRD c3 r_fert_`1'   "i.MOB" "if          $M2"
	esttab c* using "$tables/`1'2Mb_cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline

	// PANEL: 4 MONTHS 
	*absolute numbers
	eststo clear
	DDRD a1 `1'   "i.MOB" "if $C2    & $M4"
	DDRD a2 `1'   "i.MOB" "if $C1_C2 & $M4" 
	DDRD a3 `1'   "i.MOB" "if          $M4"
	esttab a* using "$tables/`1'4Ma_cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	
	*Ratio population
	DDRD b1 r_popf_`1'   "i.MOB" "if $C2    & $M4"
	DDRD b2 r_popf_`1'   "i.MOB" "if $C1_C2 & $M4" 
	DDRD b3 r_popf_`1'   "i.MOB" "if          $M4"
	esttab b* using "$tables/`1'4Mc_cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	*Ratio fertility
	DDRD c1 r_fert_`1'   "i.MOB" "if $C2    & $M4"
	DDRD c2 r_fert_`1'   "i.MOB" "if $C1_C2 & $M4" 
	DDRD c3 r_fert_`1'   "i.MOB" "if          $M4"
	esttab c* using "$tables/`1'4Mb_cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	
	// PANEL: 6 MONTHS 
	*absolute numbers
	eststo clear
	DDRD a1 `1'   "i.MOB" "if $C2   "
	DDRD a2 `1'   "i.MOB" "if $C1_C2" 
	DDRD a3 `1'   "i.MOB" "         "
	esttab a* using "$tables/`1'6Ma_cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	
	*Ratio population
	DDRD b1 r_popf_`1'   "i.MOB" "if $C2   "
	DDRD b2 r_popf_`1'   "i.MOB" "if $C1_C2" 
	DDRD b3 r_popf_`1'   "i.MOB" "         "
	esttab b* using "$tables/`1'6Mc_cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	*Ratio fertility
	DDRD c1 r_fert_`1'   "i.MOB" "if $C2   "
	DDRD c2 r_fert_`1'   "i.MOB" "if $C1_C2" 
	DDRD c3 r_fert_`1'   "i.MOB" "         "
	esttab c* using "$tables/`1'6Mb_cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
		
	// PANEL: DONUT 
	*absolute numbers
	eststo clear
	DDRD a1 `1'   "i.MOB" "if $C2    & $MD"
	DDRD a2 `1'   "i.MOB" "if $C1_C2 & $MD" 
	DDRD a3 `1'   "i.MOB" "if          $MD"
	esttab a* using "$tables/`1'DMa_cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	
	*Ratio population
	DDRD b1 r_popf_`1'   "i.MOB" "if $C2    & $MD"
	DDRD b2 r_popf_`1'   "i.MOB" "if $C1_C2 & $MD" 
	DDRD b3 r_popf_`1'   "i.MOB" "if          $MD"
	esttab b* using "$tables/`1'DMc_cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	*Ratio fertility
	DDRD c1 r_fert_`1'   "i.MOB" "if $C2    & $MD"
	DDRD c2 r_fert_`1'   "i.MOB" "if $C1_C2 & $MD" 
	DDRD c3 r_fert_`1'   "i.MOB" "if          $MD"
	esttab c* using "$tables/`1'DMb_cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
		
		
	// Panels zusammenfassen
esttab a* using "$tables/`1'_DDRD_overview_cg.tex", replace booktabs ///
		cells(none) nonote noobs ///
		mtitles( "C2" "C1+C2" "C1-C3" ) ///
		prehead( ///
			\begin{table}[H]  ///
			\begin{threeparttable} ///
			\centering  ///
			\caption{Robustness with respect to the choice of \texttt{control group}} ///
			{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
			\begin{tabular}{l*{@span}{c}} \toprule ///
			 \multicolumn{@span}{c}{Dependent variable: \textbf{$`1'}} \\ \cmidrule(lr){2-4}) ///		
		prefoot( ///
			\multicolumn{@span}{l}{\emph{Panel A. 2 Month bandwidth}} \\ ///
			\input{`1'2Ma_cg} ///
			\input{`1'2Mb_cg} ///
			\input{`1'2Mc_cg} ///
			\midrule\multicolumn{@span}{l}{\emph{Panel B. 4 Month bandwidth}} \\ ///
			\input{`1'4Ma_cg} ///
			\input{`1'4Mb_cg} ///
			\input{`1'4Mc_cg} ///
			\midrule\multicolumn{@span}{l}{\emph{Panel C. 6 Month bandwidth}} \\ ///
			\input{`1'6Ma_cg} ///
			\input{`1'6Mb_cg} ///
			\input{`1'6Mc_cg} ///
			\midrule\multicolumn{@span}{l}{\emph{Panel D. Donut specification}} \\ ///
			\input{`1'DMa_cg} ///
			\input{`1'DMb_cg} ///
			\input{`1'DMc_cg} ///
		) ///
		postfoot(\bottomrule \end{tabular} } ///
			\begin{tablenotes} ///
			\item \scriptsize ///
			\emph{Notes:} Clustered standard errors in parentheses. All regressions contain Birthmonth FE. Ratios indicate cases per thousand; either approximated population (with weights coming from the original fertility distribution) or original number of births.  ///
			\end{tablenotes} ///
			\end{threeparttable} ///
		\end{table} ///
		)		///
		substitute(\_ _)
}



////////////////////////////////////////////////////////////////////////////////
					*** FÜR 2 GENDER & RATIOS UNAVAILABLE ***
////////////////////////////////////////////////////////////////////////////////
//  OVERVIEW 1 : CONTROLS
foreach 1 of varlist $list_vars_mandf_no_ratios  { 
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
	
		
	*FFOR BOTTOM: 
	DDRD c1 `1'   "						   " "if $C2 & $MD" 
	DDRD c2 `1'   "i.MOB 				   " "if $C2 & $MD"
	DDRD c3 `1'   "i.MOB i.year 			   " "if $C2 & $MD" 
	DDRD c4 `1'   "i.MOB i.year $controlvars" "if $C2 & $MD"
	DDRD c5 `1'_f "i.MOB					   " "if $C2 & $MD"
	DDRD c6 `1'_m "i.MOB					   " "if $C2 & $MD"
	esttab c* using "$tables/`1'checks.tex", replace booktabs fragment ///
		keep( ) coeflabels(TxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		indicate("Birthmonth FE = *MOB" "Year FE = *year" ///
		"Covariates = $controlvars", label("$check" ""))  ///
		label nomtitles nonumbers noobs nonote nogaps noline	
		
		// Panels zusammenfassen
esttab a* using "$tables/`1'_DDRD_overview_covars.tex", replace booktabs ///
		cells(none) nonote noobs ///
		mtitles( "" "" "" "" "Women" "Men") ///
		mgroups("Average Causal Effects" "Heterogeneous Causal Effects", pattern(1 0 0 0 1 0) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))  ///
		prehead( ///
		\begin{table}[H]  ///
			\begin{threeparttable} ///
			\centering  ///
			\caption{Robustness with respect to the inclusion of \texttt{fixed effects} and \texttt{covariates}} ///
			{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
			\begin{tabular}{l*{@span}{c}} \toprule ///
			& \multicolumn{@M}{c}{Dependent variable: \textbf{$`1'}} \\ \cmidrule(lr){2-7}) ///
			prefoot( ///
				\multicolumn{@span}{l}{\emph{Panel A. 2 Month bandwidth}} \\ ///
				\input{`1'2Ma} ///
				\midrule\multicolumn{@span}{l}{\emph{Panel B. 4 Month bandwidth}} \\ ///
				\input{`1'4Ma} ///
				\midrule\multicolumn{@span}{l}{\emph{Panel C. 6 Month bandwidth}} \\ ///
				\input{`1'6Ma} ///
				\midrule\multicolumn{@span}{l}{\emph{Panel D. Donut specification}} \\ ///
				\input{`1'DMa} ///
				\midrule \input{`1'checks} ///
				) ///
			postfoot(\bottomrule \end{tabular} } ///
			\begin{tablenotes} ///
			\item \scriptsize ///
			\emph{Notes:} Clustered standard errors in parentheses. Personal covariates contain age and age squared. All regression are run with CG2 (i.e. the cohort prior to the reform). Ratios indicate cases per thousand; either approximated population (with weights coming from the original fertility distribution) or original number of births.   ///
			\end{tablenotes} ///
			\end{threeparttable} ///
		\end{table} ///
		) ///
		substitute(\_ _)
		
		
}

********************************************************************************
// OVERVIEW 2: CHOICE OF CG	
foreach 1 of varlist $list_vars_mandf_no_ratios {
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
	esttab a* using "$tables/`1'2Ma_cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
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
	esttab a* using "$tables/`1'4Ma_cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
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
	esttab a* using "$tables/`1'6Ma_cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
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
	esttab a* using "$tables/`1'DMa_cg.tex", replace booktabs fragment ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	
	
		
		
	// Panels zusammenfassen
esttab a* using "$tables/`1'_DDRD_overview_cg.tex", replace booktabs ///
		cells(none) nonote noobs ///
		mtitles( "C2" "C1+C2" "C1-C3" "C2" "C1+C2" "C1-C3" "C2" "C1+C2" "C1-C3") ///
		mgroups("Average Causal Effects" "Women" "Men", pattern(1 0 0  1 0 0 1 0 0) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))  ///
		prehead( ///
			\begin{table}[H]  ///
			\begin{threeparttable} ///
			\centering  ///
			\caption{Robustness with respect to the choice of \texttt{control group}} ///
			{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
			\begin{tabular}{l*{@span}{c}} \toprule ///
			& \multicolumn{@M}{c}{Dependent variable: \textbf{$`1'}} \\ \cmidrule(lr){2-10}) ///		
		prefoot( ///
			\multicolumn{@span}{l}{\emph{Panel A. 2 Month bandwidth}} \\ ///
			\input{`1'2Ma_cg} ///
			\midrule\multicolumn{@span}{l}{\emph{Panel B. 4 Month bandwidth}} \\ ///
			\input{`1'4Ma_cg} ///
			\midrule\multicolumn{@span}{l}{\emph{Panel C. 6 Month bandwidth}} \\ ///
			\input{`1'6Ma_cg} ///
			\midrule\multicolumn{@span}{l}{\emph{Panel D. Donut specification}} \\ ///
			\input{`1'DMa_cg} ///
		) ///
		postfoot(\bottomrule \end{tabular} } ///
			\begin{tablenotes} ///
			\item \scriptsize ///
			\emph{Notes:} Clustered standard errors in parentheses. All regressions contain Birthmonth FE. Ratios indicate cases per thousand; either approximated populatio (with weights coming from the original fertility distribution)n or original number of births.  ///
			\end{tablenotes} ///
			\end{threeparttable} ///
		\end{table} ///
		)		///
		substitute(\_ _)
}

























/* 
//Effect in sds		
	qui summ r_popf_D_5
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
	*qui summ r_popf_D_5
	*estadd scalar effct_sd = _b[TxA ]/r(sd)
	
/////


