/*
	generate overview graph: wie viel trägt welches Diagnose hauptkapitel dazu 
	und wie ist die Verteilung, zusammen mit graph combine
*/ 

clear all
	set more off
	
	global path   "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis"	
	global temp   "$path/temp"
	global graphs "$path/graphs/KKH"
	global graph_paper "$path/graphs/paper" 

	global tables "$path/tables/KKH"
	global auxiliary "$path/do-files/auxiliary_files"


/* 
1) Generieren von file mit beta und se
2) Aufamchen und graph erstellen
*/
capture program drop DDRD
	program define DDRD
		qui eststo `1': reg `2' treat after TxA  `3'  `4', vce(cluster MxY) 
	end

use "$temp\KKH_final_R1", clear
run "$auxiliary/varlists_varnames_sample-spcifications"



*initiate file
local iter = `iter' + 1


mat A = J(1,3,.)
esttab m(A) using "$tables/comparisson_hospital_main_chapters.csv", ///
	collabels(beta se diagnoses ) ///
	keep() nomtitles replace nomtitles 

mat A = J(14,3,.)
local iter = 1
foreach 1 of varlist hospital2 d1 d2 d5 d6 d7 d8 d9 d10 d11 d12 d13 d17 d18 { 
	DDRD b1 r_fert_`1'   "i.MOB i.year" "if $C2"
		matrix temp = e(b) 								// make copy of estimate vector (Row vector) 
		matrix tempV = e(V) 							// make copy of VC matrix 
		*mat A[`iter',1] = "$`1'"
		mat A[`iter',1] = round(temp[1,3],.00001) 			// copy point estimate to plotted matrix
		mat A[`iter',2] = round(sqrt(tempV[3,3]),.00001)		// copy se to plotted matrix 
		capture drop Dinregression sum_num_diagnoses
		qui gen Dinregression = 1 if cond(e(sample),1,0)
		bys Dinregression: egen sum_num_diagnoses = total(`1')
		qui summ sum_num_diagnoses if e(sample)
		qui estadd scalar num_diag = `r(mean)'
		mat A[`iter',3] = e(num_diag) 		// number of involved diagnoses
		
		local iter = `iter' + 1
} // end: Varlist 
esttab m(A) using "$tables/comparisson_hospital_main_chapters.csv", collabels(none)  plain append lz nomtitles 
*********************************************
import delimited "$tables/comparisson_hospital_main_chapters.csv", varnames(1) clear
qui gen temp = _n 
qui drop if temp == 1
qui drop temp 
*label for graph
qui gen label = substr(v1,2,2) 
qui destring, replace
#delimit ;
label define LABEL
	1   "Hospital"
	2   "IP" 
	3   "Neo"
	4   "MBD"
	5   "NS" 
	6   "Sen"
	7   "Cir"
	8   "Res"
	9   "Dig"
	10  "SST"
	11  "MS" 
	12  "GS" 
	13  "Sym"
	14  "Ext";
#delimit cr
label values label LABEL

gen CI_low=beta-1.64*se
gen CI_high=beta+1.64*se

label var beta "ITT effect"

*save "bw_heterogeneity.dta", replace
/*
eclplot beta CI_low CI_high label, xline(0, lc(black%80) lp(dash)) ylabel(, nogrid) ylabel(1(1)14, valuelabel) ///
								   graphregion(color(white)) yscale(range(1 14.5))   ///
								   xtitle("ITT effect") xscale(r(-1.5 0.5)) horizontal ysize(5.5) xsize(3) ///
								   ciopts(blcolor(gs8)) ciopts1(msize(zero)) ytitle("") 
								   
								   yaxis(1) || /// 
				eclplot beta CI_low CI_high label horizontal, yaxis(2) 
*/	
	

* different setup
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
	
qui replace diagnoses = diagnoses /1000		



*Graph 1	
twoway rspike CI_high CI_low  temp, horizontal yaxis(1) color(gs11) yscale(range(0.5 14.5) axis(1) lc(white))	|| ///
	scatter temp beta, yaxis(2) color(navy) yscale(range(0.5 14.5) axis(2))	///
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
twoway bar diagnoses temp if temp < 14, horizontal color(navy) ///
	xtitle("Frequency [in thousand]") ytitle("") ylabel(none) ///
	 ytick(1(1)14) ///
	ysize(5.5) xsize(2.7) graphregion(color(white)) ///
	yscale(r(0.5 14.5)) ///
	saving($graphs/frequency_across_chapters,replace)
	
	graph combine "$graphs/ITT_across_chapters" "$graphs/frequency_across_chapters", imargin(zero) 
	graph export "$graph_paper/effect_chapters_frequency.pdf", as(pdf) replace
	
	