use "$temp\KKH_final_R1", clear
run "$auxiliary/varlists_varnames_sample-spcifications"

capture program drop DDRD
	program define DDRD
		qui eststo `1': reg `2' treat after TxA  `3'  `4', vce(cluster MxY) 
	end
	
	

foreach 1 of varlist hospital2 { // $list_vars_mandf_ratios_available
	foreach j in "" "_f" "_m" { // "_f" "_m"
		eststo clear 	
		*overall effect
		DDRD b2 r_fert_`1'`j'   "i.MOB i.year" "if $C2 & $M2"
		DDRD b4 r_fert_`1'`j'   "i.MOB i.year" "if $C2 & $M4"
		DDRD b6 r_fert_`1'`j'   "i.MOB i.year" "if $C2"
		DDRD b7 r_fert_`1'`j'   "i.MOB i.year" "if $C2 & $MD"
		esttab b* using "$tables/paper_`1'`j'_DD_overall.tex", replace booktabs fragment ///
			keep(TxA) coeflabels(TxA "Overall") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline 
			
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
			DDRD b2 r_fert_`1'`j'   "i.MOB" "if `age_group' & $C2 & $M2"
			DDRD b4 r_fert_`1'`j'   "i.MOB" "if `age_group' & $C2 & $M4"
			DDRD b6 r_fert_`1'`j'   "i.MOB" "if `age_group' & $C2"
			DDRD b7 r_fert_`1'`j'   "i.MOB" "if `age_group' & $C2 & $MD"
			esttab b* using "$tables/paper_`1'`j'_DD_`age_outputname'.tex", replace booktabs fragment ///
				keep(TxA) coeflabels(TxA "\hspace*{10pt}`age_label'") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label nomtitles nonumbers noobs nonote nogaps noline  
		} // end: agegroup
	} // end: tfm
	// Panels zusammenfassen
	esttab b* using "$tables/paper_`1'_DD_maintable.tex", replace booktabs ///
		cells(none) nonote noobs ///
		mtitles("2M" "4M" "6M" "Donut") ///
		prehead( ///
		\begin{table}[htbp]  ///
			\centering  ///
			\begin{threeparttable} ///
			\centering  ///
			\caption{Dep. variable: \textbf{$`1'}} ///
			{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
			\begin{tabular}{l*{@span}{c}} \toprule ///
			& \multicolumn{@M}{c}{Estimation window} \\ \cmidrule(lr){2-5}) ///
			prefoot( ///
				\multicolumn{@span}{l}{\emph{Panel A. Total}} \\ ///
				\input{KKH/paper_`1'_DD_overall} \input{KKH/paper_`1'_DD_17-21} ///
				\input{KKH/paper_`1'_DD_22-26} \input{KKH/paper_`1'_DD_27-31} /// 
				\input{KKH/paper_`1'_DD_32-35} ///
				\midrule\multicolumn{@span}{l}{\emph{Panel B. Women}} \\ ///
				\input{KKH/paper_`1'_f_DD_overall} \input{KKH/paper_`1'_f_DD_17-21} ///
				\input{KKH/paper_`1'_f_DD_22-26} \input{KKH/paper_`1'_f_DD_27-31} ///
				\input{KKH/paper_`1'_f_DD_32-35} ///
				\midrule\multicolumn{@span}{l}{\emph{Panel C. Men}} \\ ///
				\input{KKH/paper_`1'_m_DD_overall} \input{KKH/paper_`1'_m_DD_17-21} ///
				\input{KKH/paper_`1'_m_DD_22-26} \input{KKH/paper_`1'_m_DD_27-31} ///
				\input{KKH/paper_`1'_m_DD_32-35} ///
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
} //end: varlist
	
	
	
	