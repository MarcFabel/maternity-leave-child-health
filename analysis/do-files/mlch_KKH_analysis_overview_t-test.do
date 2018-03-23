/*******************************************************************************
* File name: 	mlch_KKH_analysis_overview_ttests
* Author: 		Marc Fabel
* Date: 		21.11.2017
* Description:	t test of outcome variables 
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
	global first_year = 1995
	global last_year  = 2014
	global t_90		  = 1.645
	global t_95   	  = 1.960
	
	
	//Important globals
	* List of control groups
	global C2    = "(control == 2 | control == 4)"
	global C1_C2 = "control != 3"
	global C1_C3 = "reform == 1"
	
	* Bandwidths (sample selection)
	global M2 = "(Numx >= -2 & Numx <= 2)"
	global M4 = "(Numx >= -4 & Numx <= 4)"
	global M6 = "reform == 1"
	global MD = "(Numx != -1 & Numx != 1)"
// ***********************************************************************
	use "$temp\KKH_final_R1", clear

	rename NumX Numx
	rename NumX2 Numx2
	rename NumX3 Numx3
	
	
	*Vorzeichen umdrehen für t-tests
	gen after2 = -1*after

	
foreach 1 of varlist $list_vars_mandf_ratios_available   {
	// Panel 2 months: 
	*absolute numbers
	eststo clear
	*treat
	qui bys after: eststo, prefix(a): estpost sum `1' if treat == 1 & $M2
	qui eststo, prefix(a): estpost ttest `1' if treat == 1 & $M2 ,by(after2) 
	*control
	foreach j of numlist 1/3 {
		qui bys after: eststo, prefix(a):estpost sum `1' if control == `j' & $M2
		qui eststo, prefix(a): estpost ttest `1' if control == `j' & $M2, by(after2)
	}
	esttab a* using "$tables/ttest`1'2Ma", cells("mean(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2)) b(star pattern(0 0 1 0 0 1 0 0 1 0 0 1))" ///
	"sd(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2) par([ ])) se(pattern(0 0 1 0 0 1 0 0 1 0 0 1) par fmt(a2))") ///
	replace booktabs fragment ///
	coeflabels(`1' "Abs. numbers") ///
	se star(* 0.10 ** 0.05 *** 0.01) ///
	nomtitles nonumbers noobs nonote nogaps noline collabels(none)
	
	*ratio fertility 
	qui bys after: eststo, prefix(b): estpost sum r_fert_`1' if treat == 1 & $M2
	qui eststo, prefix(b): estpost ttest r_fert_`1' if treat == 1 & $M2 ,by(after2) 
	foreach j of numlist 1/3 {
		qui bys after: eststo, prefix(b):estpost sum r_fert_`1' if control == `j' & $M2
		qui eststo, prefix(b): estpost ttest r_fert_`1' if control == `j' & $M2, by(after2) 
	}
	esttab b* using "$tables/ttest`1'2Mb", cells("mean(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2)) b(star pattern(0 0 1 0 0 1 0 0 1 0 0 1))" ///
	"sd(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2) par([ ])) se(pattern(0 0 1 0 0 1 0 0 1 0 0 1) par fmt(a2))") ///
	replace booktabs fragment ///
	coeflabels(r_fert_`1' "Ratio fertility") ///
	se star(* 0.10 ** 0.05 *** 0.01) ///
	nomtitles nonumbers noobs nonote nogaps noline collabels(none)
	
	*Ratio population 
	qui bys after: eststo, prefix(c): estpost sum r_popf_`1' if treat == 1 & $M2
	qui eststo, prefix(c): estpost ttest r_popf_`1' if treat == 1 & $M2 ,by(after2) 
	foreach j of numlist 1/3 {
		qui bys after: eststo, prefix(c):estpost sum r_popf_`1' if control == `j' & $M2
		qui eststo, prefix(c): estpost ttest r_popf_`1' if control == `j' & $M2, by(after2) 
	}
	esttab c* using "$tables/ttest`1'2Mc", cells("mean(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2)) b(star pattern(0 0 1 0 0 1 0 0 1 0 0 1))" ///
	"sd(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2) par([ ])) se(pattern(0 0 1 0 0 1 0 0 1 0 0 1) par fmt(a2))") ///
	replace booktabs fragment ///
	coeflabels(r_popf_`1' "Ratio population") ///
	se star(* 0.10 ** 0.05 *** 0.01) ///
	nomtitles nonumbers noobs nonote nogaps noline collabels(none)
	
	
	//Panel 4 Months
	eststo clear
	*absolute numbers
	qui bys after: eststo, prefix(a): estpost sum `1' if treat == 1 & $M4
	qui eststo, prefix(a): estpost ttest `1' if treat == 1 & $M4 ,by(after2) 
	foreach j of numlist 1/3 {
		qui bys after: eststo, prefix(a):estpost sum `1' if control == `j' & $M4
		qui eststo, prefix(a): estpost ttest `1' if control == `j' & $M4, by(after2) 
	}
	esttab a* using "$tables/ttest`1'4Ma", cells("mean(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2)) b(star pattern(0 0 1 0 0 1 0 0 1 0 0 1))" ///
	"sd(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2) par([ ])) se(pattern(0 0 1 0 0 1 0 0 1 0 0 1) par fmt(a2))") ///
	replace booktabs fragment ///
	coeflabels(`1' "Abs. numbers") ///
	se star(* 0.10 ** 0.05 *** 0.01) ///
	nomtitles nonumbers noobs nonote nogaps noline collabels(none)
	
	*ratio fertility 
	qui bys after: eststo, prefix(b): estpost sum r_fert_`1' if treat == 1 & $M4
	qui eststo, prefix(b): estpost ttest r_fert_`1' if treat == 1 & $M4 ,by(after2) 
	foreach j of numlist 1/3 {
		qui bys after: eststo, prefix(b):estpost sum r_fert_`1' if control == `j' & $M4
		qui eststo, prefix(b): estpost ttest r_fert_`1' if control == `j' & $M4, by(after2) 
	}
	esttab b* using "$tables/ttest`1'4Mb", cells("mean(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2)) b(star pattern(0 0 1 0 0 1 0 0 1 0 0 1))" ///
	"sd(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2) par([ ])) se(pattern(0 0 1 0 0 1 0 0 1 0 0 1) par fmt(a2))") ///
	replace booktabs fragment ///
	coeflabels(r_fert_`1' "Ratio fertility") ///
	se star(* 0.10 ** 0.05 *** 0.01) ///
	nomtitles nonumbers noobs nonote nogaps noline collabels(none)
	
	*Ratio population 
	qui bys after: eststo, prefix(c): estpost sum r_popf_`1' if treat == 1 & $M4
	qui eststo, prefix(c): estpost ttest r_popf_`1' if treat == 1 & $M4 ,by(after2) 
	foreach j of numlist 1/3 {
		qui bys after: eststo, prefix(c):estpost sum r_popf_`1' if control == `j' & $M4
		qui eststo, prefix(c): estpost ttest r_popf_`1' if control == `j' & $M4, by(after2) 
	}
	esttab c* using "$tables/ttest`1'4Mc", cells("mean(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2)) b(star pattern(0 0 1 0 0 1 0 0 1 0 0 1))" ///
	"sd(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2) par([ ])) se(pattern(0 0 1 0 0 1 0 0 1 0 0 1) par fmt(a2))") ///
	replace booktabs fragment ///
	coeflabels(r_popf_`1' "Ratio population") ///
	se star(* 0.10 ** 0.05 *** 0.01) ///
	nomtitles nonumbers noobs nonote nogaps noline collabels(none)
	
	
	//Panel 6 Months
	eststo clear
	*absolute numbers
	qui bys after: eststo, prefix(a): estpost sum `1' if treat == 1 
	qui eststo, prefix(a): estpost ttest `1' if treat == 1   ,by(after2) 
	foreach j of numlist 1/3 {
		qui bys after: eststo, prefix(a):estpost sum `1' if control == `j' 
		qui eststo, prefix(a): estpost ttest `1' if control == `j' , by(after2) 
	}
	esttab a* using "$tables/ttest`1'6Ma", cells("mean(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2)) b(star pattern(0 0 1 0 0 1 0 0 1 0 0 1))" ///
	"sd(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2) par([ ])) se(pattern(0 0 1 0 0 1 0 0 1 0 0 1) par fmt(a2))") ///
	replace booktabs fragment ///
	coeflabels(`1' "Abs. numbers") ///
	se star(* 0.10 ** 0.05 *** 0.01) ///
	nomtitles nonumbers noobs nonote nogaps noline collabels(none)
	
	*ratio fertility 
	qui bys after: eststo, prefix(b): estpost sum r_fert_`1' if treat == 1 
	qui eststo, prefix(b): estpost ttest r_fert_`1' if treat == 1  ,by(after2) 
	foreach j of numlist 1/3 {
		qui bys after: eststo, prefix(b):estpost sum r_fert_`1' if control == `j' 
		qui eststo, prefix(b): estpost ttest r_fert_`1' if control == `j' , by(after2) 
	}
	esttab b* using "$tables/ttest`1'6Mb", cells("mean(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2)) b(star pattern(0 0 1 0 0 1 0 0 1 0 0 1))" ///
	"sd(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2) par([ ])) se(pattern(0 0 1 0 0 1 0 0 1 0 0 1) par fmt(a2))") ///
	replace booktabs fragment ///
	coeflabels(r_fert_`1' "Ratio fertility") ///
	se star(* 0.10 ** 0.05 *** 0.01) ///
	nomtitles nonumbers noobs nonote nogaps noline collabels(none)
	
	*Ratio population 
	qui bys after: eststo, prefix(c): estpost sum r_popf_`1' if treat == 1 
	qui eststo, prefix(c): estpost ttest r_popf_`1' if treat == 1  ,by(after2) 
	foreach j of numlist 1/3 {
		qui bys after: eststo, prefix(c):estpost sum r_popf_`1' if control == `j' 
		qui eststo, prefix(c): estpost ttest r_popf_`1' if control == `j' , by(after2) 
	}
	esttab c* using "$tables/ttest`1'6Mc", cells("mean(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2)) b(star pattern(0 0 1 0 0 1 0 0 1 0 0 1))" ///
	"sd(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2) par([ ])) se(pattern(0 0 1 0 0 1 0 0 1 0 0 1) par fmt(a2))") ///
	replace booktabs fragment ///
	coeflabels(r_popf_`1' "Ratio population") ///
	se star(* 0.10 ** 0.05 *** 0.01) ///
	nomtitles nonumbers noobs nonote nogaps noline collabels(none)
	
	
	//Panel: Donut
	eststo clear
	*absolute numbers
	qui bys after: eststo, prefix(a): estpost sum `1' if treat == 1 & $MD
	qui eststo, prefix(a): estpost ttest `1' if treat == 1 & $MD ,by(after2) 
	foreach j of numlist 1/3 {
		qui bys after: eststo, prefix(a):estpost sum `1' if control == `j' & $MD
		qui eststo, prefix(a): estpost ttest `1' if control == `j' & $MD, by(after2) 
	}
	esttab a* using "$tables/ttest`1'DMa", cells("mean(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2)) b(star pattern(0 0 1 0 0 1 0 0 1 0 0 1))" ///
	"sd(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2) par([ ])) se(pattern(0 0 1 0 0 1 0 0 1 0 0 1) par fmt(a2))") ///
	replace booktabs fragment ///
	coeflabels(`1' "Abs. numbers") ///
	se star(* 0.10 ** 0.05 *** 0.01) ///
	nomtitles nonumbers noobs nonote nogaps noline collabels(none)
	
	*ratio fertility 
	qui bys after: eststo, prefix(b): estpost sum r_fert_`1' if treat == 1 & $MD
	qui eststo, prefix(b): estpost ttest r_fert_`1' if treat == 1 & $MD ,by(after2) 
	foreach j of numlist 1/3 {
		qui bys after: eststo, prefix(b):estpost sum r_fert_`1' if control == `j' & $MD
		qui eststo, prefix(b): estpost ttest r_fert_`1' if control == `j' & $MD, by(after2) 
	}
	esttab b* using "$tables/ttest`1'DMb", cells("mean(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2)) b(star pattern(0 0 1 0 0 1 0 0 1 0 0 1))" ///
	"sd(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2) par([ ])) se(pattern(0 0 1 0 0 1 0 0 1 0 0 1) par fmt(a2))") ///
	replace booktabs fragment ///
	coeflabels(r_fert_`1' "Ratio fertility") ///
	se star(* 0.10 ** 0.05 *** 0.01) ///
	nomtitles nonumbers noobs nonote nogaps noline collabels(none)
	
	*Ratio population 
	qui bys after: eststo, prefix(c): estpost sum r_popf_`1' if treat == 1 & $MD
	qui eststo, prefix(c): estpost ttest r_popf_`1' if treat == 1 & $MD ,by(after2) 
	foreach j of numlist 1/3 {
		qui bys after: eststo, prefix(c):estpost sum r_popf_`1' if control == `j' & $MD
		qui eststo, prefix(c): estpost ttest r_popf_`1' if control == `j' & $MD, by(after2) 
	}
	esttab c* using "$tables/ttest`1'DMc", cells("mean(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2)) b(star pattern(0 0 1 0 0 1 0 0 1 0 0 1))" ///
	"sd(pattern(1 1 0 1 1 0 1 1 0 1 1 0) fmt(a2) par([ ])) se(pattern(0 0 1 0 0 1 0 0 1 0 0 1) par fmt(a2))") ///
	replace booktabs fragment ///
	coeflabels(r_popf_`1' "Ratio population") ///
	se star(* 0.10 ** 0.05 *** 0.01) ///
	nomtitles nonumbers noobs nonote nogaps noline collabels(none)
	
	// Panels zusammenfassen
esttab a* using "$tables/`1'_ttest_overview.tex", replace booktabs ///
		cells(none) nonote noobs ///
		mtitles( "$\mathbb{E}_{Pre}[Y]$" "$\mathbb{E}_{Post}[Y]$" "$\Delta$" "$\mathbb{E}_{Pre}[Y]$" "$\mathbb{E}_{Post}[Y]$" "$\Delta$" "$\mathbb{E}_{Pre}[Y]$" "$\mathbb{E}_{Post}[Y]$" "$\Delta$" "$\mathbb{E}_{Pre}[Y]$" "$\mathbb{E}_{Post}[Y]$" "$\Delta$" ) ///
		mgroups("Treatment (Nov78-Oct79)" "Control 1 (Nov76-Oct77)" "Control 2 (Nov77-Oct78)" "Control 3 (Nov79-Oct80)", pattern(1 0 0 1 0 0 1 0 0 1 0 0) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))  ///
		prehead( ///
		\begin{table}[H]  ///
			\begin{threeparttable} ///
			\centering  ///
			\caption{\texttt{DIFFERENCE-IN-MEANS TESTS}} ///
			{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
			\begin{tabular}{l*{@span}{c}} \toprule ///
			& \multicolumn{@M}{c}{Dependent variable: \textbf{$`1'}} \\ \cmidrule(lr){2-13}) ///
			prefoot( ///
				\multicolumn{@span}{l}{\emph{Panel A. 2 Month bandwidth}} \\ ///
				\input{ttest`1'2Ma} ///
				\input{ttest`1'2Mb} ///
				\input{ttest`1'2Mc} ///
				\midrule\multicolumn{@span}{l}{\emph{Panel B. 4 Month bandwidth}} \\ ///
				\input{ttest`1'4Ma} ///
				\input{ttest`1'4Mb} ///
				\input{ttest`1'4Mc} ///
				\midrule\multicolumn{@span}{l}{\emph{Panel C. 6 Month bandwidth}} \\ ///
				\input{ttest`1'6Ma} ///
				\input{ttest`1'6Mb} ///
				\input{ttest`1'6Mc} ///
				\midrule\multicolumn{@span}{l}{\emph{Panel D. Donut specification}} \\ ///
				\input{ttest`1'DMa} ///
				\input{ttest`1'DMb} ///
				\input{ttest`1'DMc} ///
				) ///
			postfoot(\bottomrule \end{tabular} } ///
			\begin{tablenotes} ///
			\item \scriptsize ///
			\emph{Notes:} .   ///
			\end{tablenotes} ///
			\end{threeparttable} ///
		\end{table} ///
		) ///
		substitute(\_ _)
}	
	
	
	*mtitle("No College" College Difference) collabels(none) ///
	
	
	
