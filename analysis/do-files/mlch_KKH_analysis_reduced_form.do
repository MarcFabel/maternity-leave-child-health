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
// ***********************************************************************

* *************open data & define variables *************
use "$temp/KKH_final_R1", clear
drop if GDR == 1
qui gen     MOB_altern = 1  if MOB == 11
qui replace MOB_altern = 2  if MOB == 12
qui replace MOB_altern = 3  if MOB == 1
qui replace MOB_altern = 4  if MOB == 2
qui replace MOB_altern = 5  if MOB == 3
qui replace MOB_altern = 6  if MOB == 4
qui replace MOB_altern = 7  if MOB == 5
qui replace MOB_altern = 8  if MOB == 6
qui replace MOB_altern = 9  if MOB == 7
qui replace MOB_altern = 10 if MOB == 8
qui replace MOB_altern = 11 if MOB == 9
qui replace MOB_altern = 12 if MOB == 10

label define MOB_ALTERN 1 "11" 2 "12" 3 "01" 4 "02" 5 "03" 6 "04" 7 "05" 8 "06" ///
	9 "07" 10 "08" 11 "09" 12 "10"  
label values MOB_altern MOB_ALTERN
label var MOB_altern "Um TG & CG im selben graph darstellen zu können"
**********************************************************


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
	foreach year of numlist 2005 (1) 2013  {
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




