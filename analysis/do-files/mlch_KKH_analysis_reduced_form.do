/*******************************************************************************
* File name: 	mlch_KKH_analysis_reduced form
* Author: 		Marc Fabel
* Date: 		26.09.2017
* Description:	Exploration of reduced from (different RD plots and co)
*				
*				
*				
*
* Inputs:  		$temp\KKH_final_R1
*				
* Outputs:		$temp\KKH_final_R1
*
* Updates:
*
* Notes: For the moment I do everything for Daignosis number 5
*				Variable MOB_altern muss in prepare geschoben werden
*******************************************************************************/

// ***************************** PREAMBLE********************************
	clear all
	set more off
	
	*global path  "F:\econ\m-l-c-h\analysis"					//Work
	global path  "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis"	//MAC
	
	global temp  "$path/temp"
	global KKH   "$path/source" 
	global graph "$path/graphs/KKH" 
	
	*magic numbers
	global first_year = 2005
	global last_year  = 2013
// ***********************************************************************

* *************open data  *************
use "$temp/KKH_final_R1", clear
drop if GDR == 1



// ************* Step 1: RD - pooled  ******************************************
*define program
capture program drop RD_pooled
capture drop *_hat_* AVRG*

program define RD_pooled
	qui bys Datum control: egen AVRG_`1' = mean (`1') 
	qui reg `1' NumX Num_after after if treat == 1
	qui predict `1'_hat_linear_T
	qui reg `1' NumX Num_after after if control == 2
	qui predict `1'_hat_linear_C
		
	scatter AVRG_`1' MOB_altern if treat == 1, color(gs4) || ///
		scatter AVRG_`1' MOB_altern if control == 2, color(gs13) msymbol(Dh) || ///
		line `1'_hat_linear_C MOB_altern if after == 1, sort lpattern(dash) color(gs13) || ///
		line `1'_hat_linear_C MOB_altern if after == 0, sort lpattern(dash) color(gs13) || ///
		line `1'_hat_linear_T MOB_altern if after == 1, sort color(black) || ///
		line `1'_hat_linear_T MOB_altern if after == 0, sort color(black) ///
		scheme(s1mono )  title(" Pooled ") ///
        xtitle("Birth month") ytitle(" `1' ") ///
        ylabel(#5,grid) ///
		xlabel(1(2)12, val) xmtick(2(2)12) ///
		legend(label(1 "Treatment") label(2 "Control ") label(3 "Linear fit") label(5 "Linear fit"))  legend(size(small)) ///
		legend( order(1 2)) legend(pos(5) ring(0) col(2)) ///
		xline(6.5, lw(medthick ) lpattern(solid))
	graph export "$graph/RD/R1_RD_pooled_CG_`1'.pdf", replace	
	drop `1'_hat* AVRG*
	
end //end: program

/*
Variable list
*/

*analysis
foreach var of varlist Diag_5 {
	RD_pooled `var'			//absolute numbers
	RD_pooled `var'_r		//ratio with approximations
	RD_pooled `var'_r2		//ratio with number of births
} //end: loop over variables

// ************* Step 2: RD over time ******************************************
* Define program
capture program drop RD_over_time
program define RD_over_time
	capture drop `1'_hat_* 
	foreach year of numlist $first_year (1) $last_year  {
		* plain:without fits
		/*
		tw scatter `1' MOB_altern if year == `year' & treat == 1, scheme(s1mono) color(gs4) ///
			xlabel(1(2)12, val) xmtick(2(2)12) title(" `year' ") || ///
			scatter `1' MOB_altern if year == `year' & control ==2 , color(gs13) ///
			legend(label(1 "Treatment Cohort") label(2 "Control cohort")) legend(size(small)) ///
			title(" `year' ") xline(6.5, lw(medthick ) lpattern(solid)) ///
			xtitle("Birth month") ytitle(" `1' ") ///
			ylabel(#5,grid)	msymbol(Dh) // end: scatter graph
			
		graph export "$graph/RD/R1_RD_peryear_`1'_`year'_raw.pdf", replace
		*/
		
		* with fits
		qui reg `1' NumX Num_after after if year == `year' & treat == 1
		qui predict `1'_hat_linear_T
		qui reg `1' NumX Num_after after if year == `year' & control == 2
		qui predict `1'_hat_linear_C
		
		scatter `1' MOB_altern if year == `year' & treat == 1, color(gs4)  || ///
			scatter `1' MOB_altern if year == `year' & control == 2, color(gs13) msymbol(Dh) || ///
			line `1'_hat_linear_C MOB_altern if after == 1, sort lpattern(dash) color(gs13) || ///
			line `1'_hat_linear_C MOB_altern if after == 0, sort lpattern(dash) color(gs13) || ///
			line `1'_hat_linear_T MOB_altern if after == 1, sort color(black) || ///
			line `1'_hat_linear_T MOB_altern if after == 0, sort color(black) ///
			scheme(s1mono )  title(" `year' ") ///
			xline(6.5, lw(medthick ) lpattern(solid)) /// 
			xtitle("Birth month") ytitle(" `1' ") ///
            ylabel(#5,grid) xlabel(1(2)12, val) xmtick(2(2)12) ///
			legend(off)	//end: graph			
		drop `1'_hat_* 
			
		graph export "$graph/RD/R1_RD_peryear_`1'_`year'.pdf", as(pdf) replace			
	} //end: year loop	
end	//end: program



/*
LIST OF VARIABLES
-> To do this for all variables

*/

*analysis
foreach var of varlist Diag_5 {
	RD_over_time `var'			//absolute numbers
	RD_over_time `var'_r		//ratio with approximations
	RD_over_time `var'_r2		//ratio with number of births
} //end: loop over variables
// *****************************************************************************







// ************* Moving Averages ******************************************
*Ausgangsbasis: Code von RD_pooled
*program define RD_pooled
foreach 1 of varlist Diag_5_r2 {
	qui bys Datum control: egen AVRG_`1' = mean (`1') 
	qui reg `1' NumX Num_after after if treat == 1
	qui predict `1'_hat_linear_T
	*qui reg `1' NumX Num_after after if control == 2
	*qui predict `1'_hat_linear_C
		
	scatter AVRG_`1' MOB_altern if treat == 1, color(gs4) || ///
		line `1'_hat_linear_T MOB_altern if after == 1, sort color(black) || ///
		line `1'_hat_linear_T MOB_altern if after == 0, sort color(black) ///
		scheme(s1mono )  title(" Pooled ") ///
        xtitle("Birth month") ytitle(" `1' ") ///
        ylabel(#5,grid) ///
		xlabel(1(2)12, val) xmtick(2(2)12) ///
		legend(label(1 "Treatment") label(2 "Control ") label(3 "Linear fit") label(5 "Linear fit"))  legend(size(small)) ///
		legend( order(1 2)) legend(pos(5) ring(0) col(2)) ///
		xline(6.5, lw(medthick ) lpattern(solid))
	graph export "$graph/RD/R1_RD_pooled_CG_`1'.pdf", replace	
	drop `1'_hat* AVRG*
}
	
	//variable des MA konstruieren
	capture drop bev_avrg
	qui by Datum GDR: egen bev_summ = total(bev)
	qui by Datum GDR: egen fert_summ = total(fert)
	qui by Datum GDR: egen Diag_5_summ = total(Diag_5)
	
		
	
	bys Datum: gen temp = _n
	gen n = _n
	order temp
	
	
	summ temp
	global T = r(max)	
	gen temp2 = sum(Diag_5)
	
	qui gen temp3 = .
	qui replace temp3 = temp2 if ( n>=&T & n <= 2*$T)
	
	
	order n temp* Datum Diag_5 bev Diag_5_summ MOB_altern bev bev_summ fert fert_summ  

	
	
	
/*	NICT MEHR BENÖTIGT
	*hilfsvar MA(2month) & MA(3month)
	qui gen aux_ma2 = .
	qui replace aux_ma2 = 1 if (MOB_alt == 1 | MOB_alt == 2)
	qui replace aux_ma2 = 2 if (MOB_alt == 2 | MOB_alt == 3)
	qui replace aux_ma2 = 3 if (MOB_alt == 3 | MOB_alt == 4)
	qui replace aux_ma2 = 4 if (MOB_alt == 4 | MOB_alt == 5)
	qui replace aux_ma2 = 5 if (MOB_alt == 5 | MOB_alt == 6)
	qui replace aux_ma2 = 6 if (MOB_alt == 7 | MOB_alt == 8)
	qui replace aux_ma2 = 7 if (MOB_alt == 8 | MOB_alt == 9)
	qui replace aux_ma2 = 8 if (MOB_alt == 9 | MOB_alt == 10)
	qui replace aux_ma2 = 9 if (MOB_alt == 10 | MOB_alt == 11)
	qui replace aux_ma2 = 10 if (MOB_alt == 11 | MOB_alt == 12)

	*hilfsvar MA(3 month)
	qui gen aux_ma3 = .
	local j = 1
	while `j' <=4 { 
		qui replace aux_ma3 = `j' if (MOB_alt == `j' | MOB_alt == `j'+1 | MOB_alt == `j'+2)
		local j = `j' + 1
	}
	local j = 5
	while `j' <=8 {
		qui replace aux_ma3 = `j' if (MOB_alt == `j'+2 | MOB_alt == `j'+3 | MOB_alt == `j'+4)
		local j = `j' + 1
	}
*/	
	
//loop für generating MA (use MOB_altern) (zuerst mit fertility
foreach 1 of var list Diag_5 {	
	*2 month smoth
	qui gen `1'_
	*3 month smooth

}
	
/* Controlgruppe
scatter AVRG_`1' MOB_altern if control == 2, color(gs13) msymbol(Dh) || ///
		line `1'_hat_linear_C MOB_altern if after == 1, sort lpattern(dash) color(gs13) || ///
		line `1'_hat_linear_C MOB_altern if after == 0, sort lpattern(dash) color(gs13) || /// */






















/*LATEX OUTPUT
%%%%%%%%%%%%%%%%%%%%%%%%%	TEMPLATE	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\begin{figure}[h]
\centering
\caption{Pooled}
\begin{subfigure}[t]{0.31\textwidth}
		\centering
		\caption{Absolute numbers}
		\includegraphics[width=0.99\textwidth]{R1_RD_pooled_CG_Diag_5.pdf}	
\end{subfigure}
\begin{subfigure}[t]{0.31\textwidth}
		\centering
		\caption{Ratio (approx)}
		\includegraphics[width=0.99\textwidth]{R1_RD_pooled_CG_Diag_5_r.pdf}	
\end{subfigure}
\begin{subfigure}[t]{0.31\textwidth}
		\centering
		\caption{Ratio (births)}
		\includegraphics[width=0.99\textwidth]{R1_RD_pooled_CG_Diag_5_r2.pdf}	
\end{subfigure}
%%%%%% surveyjahr
\begin{subfigure}[t]{0.31\textwidth}
		\centering
		\includegraphics[width=0.99\textwidth]{R1_RD_peryear_Diag_5_2005.pdf}	
\end{subfigure}
\begin{subfigure}[t]{0.31\textwidth}
		\centering
		\includegraphics[width=0.99\textwidth]{R1_RD_peryear_Diag_5_r_2005.pdf}	
\end{subfigure}
\begin{subfigure}[t]{0.31\textwidth}
		\centering
		\includegraphics[width=0.99\textwidth]{R1_RD_peryear_Diag_5_r_2005.pdf}	
\end{subfigure}
\end{figure}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*/




