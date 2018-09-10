// create event style graphs  
	
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

	use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"
****************************************************************************
foreach X of numlist 1 (1) 12 {
	capture drop Dm`X'
	qui gen Dm`X' = cond(MOB==`X',1,0)
	qui gen T_`X' = Dm`X'*treat
}


foreach X of numlist 5 (1) 10 {
	qui gen 
	qui gen T_`X' = treat * 
}

*diese Estimates wurden genutzt
 reg  r_popf_d5 treat after  T_3 T_4  T_5 T_6 T_7 T_8 T_9 T_10  i.MOB i.year if $C2, vce(cluster MxY) 

 
 *mit before months 
 reg  r_popf_d5 treat after     T_3 T_4 T_5 T_6 T_7 T_8 T_9 T_10  i.MOB i.year if $C2, vce(cluster MxY)
 reg  r_popf_d5 after  i.treat##i.MOB  i.year if $C2, vce(cluster MxY)

**********************************************************************************************************
clear all
set obs 8
*3
qui gen mob  = 3 in 1
qui gen beta = 0.3103764 in 1
qui gen se   = 0.2814888 in 1
*4
qui replace mob = 4 in 2
qui replace beta =  -.2744756 in 2
qui replace se = .2814888 in 2
*5
qui replace mob =5 in 3
qui replace beta =  -.9666513	in 3
qui replace se = .2814888	in 3
*6
qui replace mob =6 in 4
qui replace beta = -.0998696	in 4
qui replace se = .2814888	in 4
*7
qui replace mob =7 in 5
qui replace beta = -1.058693 	in 5
qui replace se = .2814888	in 5
*8
qui replace mob =8 in 6
qui replace beta = -1.575648	in 6
qui replace se = .2814888	in 6
*9
qui replace mob =9 in 7
qui replace beta = -.5138587	in 7
qui replace se = .2814888	in 7
*10
qui replace mob =10 in 8
qui replace beta = -.7429691	in 8
qui replace se = .2814888	in 8


 

gen CI_low=beta-1.64*se
gen CI_high=beta+1.64*se
*label define grlab 0 "" 1 "all F diagnoses" 2 "drug abuse" 3 "shizophrenia" 4 "affective" 5 "neurosis" 6 "personality" 7 ""
*label values group grlab
*label var beta "ITT effect"

*save "bw_heterogeneity.dta", replace

eclplot beta CI_low CI_high mob, yline(0, lc(black)) ylabel(, nogrid) xlabel( 3 4 5 6 7 8 9 10, valuelabel angle(45)) ///
								   graphregion(color(white))   ///
								   xtitle("") yscale(r(-1.5 0.5)) /// 
								   xline(4.5) title(Event study style graph) ///
								   subtitle(d5 Mental and behavioral disorders) 
graph export "$graphs/d5_eventstudystyle.pdf", as(pdf) 	replace						   
