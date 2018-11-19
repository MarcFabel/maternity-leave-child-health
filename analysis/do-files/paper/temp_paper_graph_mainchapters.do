// ***************************** PREAMBLE********************************
/*
	generate overview graph: wie viel trägt welches Diagnose hauptkapitel dazu 
	und wie ist die Verteilung, zusammen mit graph combine
		1) Generieren von file mit beta und se
		2) Aufamchen und graph erstellen
*/ 

	clear all
	set more off
	
	global path   "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis"	
	global temp   "$path/temp"
	global graphs "$path/graphs/KKH"
	global graph_paper "$path/graphs/paper" 
	global tables "$path/tables/KKH"
	global auxiliary "$path/do-files/auxiliary_files"

	*magic numbers
	global first_year = 1995
	global last_year  = 2014
	global t_90		  = 1.645
	global t_95   	  = 1.960
	
	*program
	capture program drop DDRD
	program define DDRD
		qui eststo `1': reg `2' treat after TxA  `3'  `4', vce(cluster MxY) 
	end
// ***********************************************************************
use "$temp\KKH_final_R1", clear
run "$auxiliary/varlists_varnames_sample-spcifications"


foreach j in "" "_f" "_m" {
	mat A = J(1,3,.)
	esttab m(A) using "$tables/comparisson_hospital_main_chapters`j'.csv", ///
		collabels(beta se diagnoses ) ///
		keep() nomtitles replace nomtitles 
	
	mat A = J(14,3,.)
	local iter = 1
	foreach 1 of varlist hospital2 d1 d2 d5 d6 d7 d8 d9 d10 d11 d12 d13 d17 d18 { 
		DDRD b1 r_fert_`1'`j'   "i.MOB i.year" "if $C2"
			matrix temp = e(b) 								// make copy of estimate vector (Row vector) 
			matrix tempV = e(V) 							// make copy of VC matrix 
			*mat A[`iter',1] = "$`1'"
			mat A[`iter',1] = round(temp[1,3],.00001) 			// copy point estimate to plotted matrix
			mat A[`iter',2] = round(sqrt(tempV[3,3]),.00001)		// copy se to plotted matrix 
			capture drop Dinregression sum_num_diagnoses
			qui gen Dinregression = 1 if cond(e(sample),1,0)
			bys Dinregression: egen sum_num_diagnoses = total(`1'`j')
			qui summ sum_num_diagnoses if e(sample)
			qui estadd scalar num_diag = `r(mean)'
			mat A[`iter',3] = e(num_diag) 		// number of involved diagnoses
			
			local iter = `iter' + 1
	} // end: Varlist 
	esttab m(A) using "$tables/comparisson_hospital_main_chapters`j'.csv", collabels(none)  plain append lz nomtitles 

} // end: loop over tfm

*********************************************

// Generate graphs 
*total 
	import delimited "$tables/comparisson_hospital_main_chapters.csv", varnames(1) clear
	qui gen temp = _n 
	qui drop if temp == 1
	qui drop temp 
	*label for graph
	qui gen label = substr(v1,2,2) 
	qui destring, replace
	qui gen temp = abs(label-15) 
	#delimit ;
	label define LABEL2
		14  "Hospital"
		13  "IP" 
		12  "Neo"
		11  "MBD"
		10  "NS" 
		9   "Sen"
		8   "Cir"
		7   "Res"
		6   "Dig"
		5  "SST"
		4  "MS" 
		3  "GS" 
		2  "Sym"
		1  "Ext";
	#delimit cr
	label values temp LABEL2
	
	gen CI_l90	= beta - ($t_90 *se)
	gen CI_h90	= beta + ($t_90 *se)
	gen CI_l95 	= beta - ($t_95 *se)
	gen CI_h95	= beta + ($t_95 *se)
	
	qui replace diagnoses = diagnoses /1000		
	
	*Graph 1	
	twoway rspike CI_h90 CI_l90  temp, horizontal yaxis(1) color(gs2%80) yscale(range(0.5 14.5) axis(1) lc(white))	|| ///
		rspike CI_h95 CI_l95 temp,  horizontal yaxis(1) color(gs10%80) yscale(range(0.5 14.5) axis(1) lc(white))	|| ///
		scatter temp beta, yaxis(2) color(gs2%80) yscale(range(0.5 14.5) axis(2))	///
		xline(0, lc(black%80) lp(dash)) ///
		ylabel(1(1)14, nogrid valuelabel angle(0) axis(2)) ///
		ylabel(none, axis(1)) ///
		graphregion(color(white))   ///
		xtitle("ITT effect") ///
		ysize(5.5) xsize(2.7) ///
		ytitle("", axis(1)) ytitle("", axis(2)) ///
		legend(off) graphregion(color(white))  ///
		saving($graphs/ITT_across_chapters,replace)
	
	*Graph 2
	twoway bar diagnoses temp if temp < 14, horizontal color(gs2%80) ///
		xtitle("Frequency [in thousand]") ytitle("") ylabel(none) ///
		ytick(1(1)14) ///
		ysize(5.5) xsize(2.7) graphregion(color(white)) ///
		yscale(r(0.5 14.5)) ///
		saving($graphs/frequency_across_chapters,replace)
		
		graph combine "$graphs/ITT_across_chapters" "$graphs/frequency_across_chapters", imargin(zero) scheme(s1mono)
		graph export "$graph_paper/effect_chapters_frequency.pdf", as(pdf) replace
	
*female 
	import delimited "$tables/comparisson_hospital_main_chapters_f.csv", varnames(1) clear
	qui gen temp = _n 
	qui drop if temp == 1
	qui drop temp 
	*label for graph
	qui gen label = substr(v1,2,2) 
	qui destring, replace
	qui gen temp = abs(label-15) 
	#delimit ;
	label define LABEL2
		14  "Hospital"
		13  "IP" 
		12  "Neo"
		11  "MBD"
		10  "NS" 
		9   "Sen"
		8   "Cir"
		7   "Res"
		6   "Dig"
		5  "SST"
		4  "MS" 
		3  "GS" 
		2  "Sym"
		1  "Ext";
	#delimit cr
	label values temp LABEL2
	
	gen CI_l90	= beta - ($t_90 *se)
	gen CI_h90	= beta + ($t_90 *se)
	gen CI_l95 	= beta - ($t_95 *se)
	gen CI_h95	= beta + ($t_95 *se)
	
	qui replace diagnoses = diagnoses /1000		
	
	*Graph 1	
	twoway rspike CI_h90 CI_l90  temp, horizontal yaxis(1) color(gs2%80) yscale(range(0.5 14.5) axis(1) lc(white))	|| ///
		rspike CI_h95 CI_l95 temp,  horizontal yaxis(1) color(gs10%80) yscale(range(0.5 14.5) axis(1) lc(white))	|| ///
		scatter temp beta, yaxis(2) color(cranberry%80) yscale(range(0.5 14.5) axis(2))	///
		xline(0, lc(black%80) lp(dash)) ///
		ylabel(1(1)14, nogrid valuelabel angle(0) axis(2)) ///
		ylabel(none, axis(1)) ///
		graphregion(color(white))   ///
		xtitle("ITT effect") ///
		ysize(5.5) xsize(2.7) ///
		ytitle("", axis(1)) ytitle("", axis(2)) ///
		legend(off) graphregion(color(white))  ///
		saving($graphs/ITT_across_chapters_f,replace)
	
	*Graph 2
	twoway bar diagnoses temp if temp < 14, horizontal color(cranberry%80) ///
		xtitle("Frequency [in thousand]") ytitle("") ylabel(none) ///
		ytick(1(1)14) ///
		ysize(5.5) xsize(2.7) graphregion(color(white)) ///
		yscale(r(0.5 14.5)) ///
		saving($graphs/frequency_across_chapters_f,replace)
		
		graph combine "$graphs/ITT_across_chapters_f" "$graphs/frequency_across_chapters_f", imargin(zero) scheme(s1mono)
		graph export "$graph_paper/effect_chapters_frequency_f.pdf", as(pdf) replace	
		
*male 
	import delimited "$tables/comparisson_hospital_main_chapters_m.csv", varnames(1) clear
	qui gen temp = _n 
	qui drop if temp == 1
	qui drop temp 
	*label for graph
	qui gen label = substr(v1,2,2) 
	qui destring, replace
	qui gen temp = abs(label-15) 
	#delimit ;
	label define LABEL2
		14  "Hospital"
		13  "IP" 
		12  "Neo"
		11  "MBD"
		10  "NS" 
		9   "Sen"
		8   "Cir"
		7   "Res"
		6   "Dig"
		5  "SST"
		4  "MS" 
		3  "GS" 
		2  "Sym"
		1  "Ext";
	#delimit cr
	label values temp LABEL2
	
	gen CI_l90	= beta - ($t_90 *se)
	gen CI_h90	= beta + ($t_90 *se)
	gen CI_l95 	= beta - ($t_95 *se)
	gen CI_h95	= beta + ($t_95 *se)
	
	qui replace diagnoses = diagnoses /1000		
	
	*Graph 1	
	twoway rspike CI_h90 CI_l90  temp, horizontal yaxis(1) color(gs2%80) yscale(range(0.5 14.5) axis(1) lc(white))	|| ///
		rspike CI_h95 CI_l95 temp,  horizontal yaxis(1) color(gs10%80) yscale(range(0.5 14.5) axis(1) lc(white))	|| ///
		scatter temp beta, yaxis(2) color(navy%80) yscale(range(0.5 14.5) axis(2))	///
		xline(0, lc(black%80) lp(dash)) ///
		ylabel(1(1)14, nogrid valuelabel angle(0) axis(2)) ///
		ylabel(none, axis(1)) ///
		graphregion(color(white))   ///
		xtitle("ITT effect") ///
		ysize(5.5) xsize(2.7) ///
		ytitle("", axis(1)) ytitle("", axis(2)) ///
		legend(off) graphregion(color(white))  ///
		saving($graphs/ITT_across_chapters_m,replace)
	
	*Graph 2
	twoway bar diagnoses temp if temp < 14, horizontal color(navy%80) ///
		xtitle("Frequency [in thousand]") ytitle("") ylabel(none) ///
		ytick(1(1)14) ///
		ysize(5.5) xsize(2.7) graphregion(color(white)) ///
		yscale(r(0.5 14.5)) ///
		saving($graphs/frequency_across_chapters_m,replace)
		
		graph combine "$graphs/ITT_across_chapters_m" "$graphs/frequency_across_chapters_m", imargin(zero) scheme(s1mono)
		graph export "$graph_paper/effect_chapters_frequency_m.pdf", as(pdf) replace			
	