// ***************************** PREAMBLE********************************
	clear all
	set more off
	
	global path   "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis"	
	global temp   "$path/temp"
	global graphs "$path/graphs/KKH"
	global graph_paper "$path/graphs/paper" 

	global tables "$path/tables/KKH"
	global tables_paper "$path/tables/paper"
	global auxiliary "$path/do-files/auxiliary_files"
	
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
 use "$temp/KKH_final_R1", clear
run "$auxiliary/varlists_varnames_sample-spcifications"
keep if treat == 1

*t-test for hospital admission and mental and behavioral disorders


foreach 1 of varlist d5 hospital2 {
	foreach j in "" "_f" "_m"  { // columns:   
		eststo clear
		*overall 
		label var r_fert_`1'`j' "Overall (pooled)"
		qui bys after: eststo: estpost sum r_fert_`1'`j'
		*t-test:
		qui eststo diff: estpost ttest r_fert_`1'`j' ,by(after)
		qui esttab est1 est2 diff using"$tables_paper/include/ttest_`1'`j'.tex", ///
			booktabs fragment  replace ///
			cells(	"mean(pattern(1 1 0) fmt(a2)) b(star pattern(0 0 1))" ///
				"sd(pattern(1 1 0) fmt(a2) par([ ])) se(pattern(0 0 1) par fmt(a2))") ///
				label nomtitles nonumbers noobs nonote nogaps noline ///
				starlevels(* 0.10 ** 0.05 *** 0.01) collabels(none)
					
		*per year
		foreach year of numlist 1995(1)2014 {
			eststo clear
			label var r_fert_`1'`j' "\hspace{12pt}`year'"
			qui bys after: eststo: estpost sum r_fert_`1'`j' if year == `year'
			qui eststo diff: estpost ttest r_fert_`1'`j' if year == `year',by(after)
			
			esttab est1 est2 diff using"$tables_paper/include/ttest_`1'`j'.tex", ///
				booktabs fragment  append ///
				cells(	"mean(pattern(1 1 0) fmt(a2)) b(star pattern(0 0 1))" ///
					"sd(pattern(1 1 0) fmt(a2) par([ ])) se(pattern(0 0 1) par fmt(a2))") ///
				label nomtitles nonumbers noobs nonote nogaps noline ///
					starlevels(* 0.10 ** 0.05 *** 0.01) plain collabels(none)
		} // end: year 	
	
	} // end tfm
	
	
}		
		
