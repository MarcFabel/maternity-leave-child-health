// ***************************** PREAMBLE********************************
/*
	Generiert eine Matrix von RF Graphen über 4 Altersgruppen. 
	Erste und letze Reihe sind in extra Befehlen, da sie entweder bestimmte 
	header oder footer benoetigen

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
	run "$auxiliary/varlists_varnames_sample-spcifications"

keep if treat == 1
keep if GDR == 0
	
*****************************************
* 1) per age-group - no MA
*generate age group variable over which we can loop	
qui gen age_group = . 
qui replace age_group = 1 if year_treat >= 1996 & year_treat<=2000	// nicht sinnvoll, da keine Einträge in abhängigen Variablen
qui replace age_group = 2 if year_treat >= 2001 & year_treat<=2005	
qui replace age_group = 3 if year_treat >= 2006 & year_treat<=2010
qui replace age_group = 4 if year_treat >= 2011 & year_treat<=2014
label define AGE_GRP  1 "[1] 17-21 years" 2 "[2] 22-26 years" 3 "[3] 27-31 years" 4 "[4] 32-35 years" //
label val age_group AGE_GRP


global t_1 = "Age 17-21"
global t_2 = "Age 22-26"
global t_3 = "Age 27-31"
global t_4 = "Age 32-35"

foreach 1 of varlist hospital2 d5 { // d5
	foreach var in "r_fert_"{ // rows: 
		foreach grp of numlist 1 2 3 4 {
			local ylab "t_`grp'"
			foreach j in "" "_f" "_m"  { // columns:  
				capture drop AVRG`j' `j'_hat*  //
				qui bys Datum age_group: egen AVRG`j' = mean(r_fert_`1'`j') 
				qui reg r_fert_`1'`j' Numx Num_after after if treat == 1 & age_group == `grp'
				qui predict `j'_hat_r_fert__T_`grp'
			} // end: loop over columns (total, male, female)
				
			if `grp' == 1 { // include top titles for first row
				*total		
				twoway scatter AVRG MOB_altern if treat == 1 & age_group == `grp', color(black) || ///
					line _hat_r_fert__T_`grp' MOB_altern if after == 1, sort color(black%60) || ///
					line _hat_r_fert__T_`grp' MOB_altern if after == 0, sort color(black%60) ///
					scheme(s1mono )  ///
					xtitle("") ytitle("$`ylab'", box bexpand size(vhuge) margin(medsmall)) ///
					title("Total", box bexpand size(vhuge) margin(medsmall)) ///
					ylabel(#5,grid) ///
					xlabel(1(2)12, val) xmtick(2(2)12) ///
					legend(off) ///
					xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
					saving($graphs/`grp'_total_r_fert_, replace)
		
				*female 
				twoway scatter AVRG_f MOB_altern if treat == 1 & age_group == `grp', color(cranberry)  || ///
					line _f_hat_r_fert__T_`grp' MOB_altern if after == 1, sort color(cranberry%60) || ///
					line _f_hat_r_fert__T_`grp' MOB_altern if after == 0, sort color(cranberry%60) ///
					scheme(s1mono )  ///
					xtitle("") ytitle("") ///
					title("Female", box bexpand size(vhuge) margin(medsmall)) ///
					ylabel(#5,grid) ///
					xlabel(1(2)12, val) xmtick(2(2)12) ///
					legend(off) ///
					xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
					saving($graphs/`grp'_female_r_fert_, replace)
					
				*male	
				twoway scatter AVRG_m MOB_altern if treat == 1 & age_group == `grp', color(navy) || ///
					line _m_hat_r_fert__T_`grp' MOB_altern if after == 1, sort color(navy%60) || ///
					line _m_hat_r_fert__T_`grp' MOB_altern if after == 0, sort color(navy%60) ///
					scheme(s1mono )  ///
					xtitle("") ytitle("") ///
					title("Male", box bexpand size(vhuge) margin(medsmall)) ///
					ylabel(#5,grid) ///
					xlabel(1(2)12, val) xmtick(2(2)12) ///
					legend(off) ///
					xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
						saving($graphs/`grp'_male_r_fert_, replace)
				
			} // end first group
			
			else { // all other rows
				*total		
				twoway scatter AVRG MOB_altern if treat == 1 & age_group == `grp', color(black) || ///
					line _hat_r_fert__T_`grp' MOB_altern if after == 1, sort color(black%60) || ///
					line _hat_r_fert__T_`grp' MOB_altern if after == 0, sort color(black%60) ///
					scheme(s1mono )  ///
					xtitle("") ytitle("$`ylab'", box bexpand size(vhuge) margin(medsmall)) ///
					ylabel(#5,grid) ///
					xlabel(1(2)12, val) xmtick(2(2)12) ///
					legend(off) ///
					xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
					saving($graphs/`grp'_total_r_fert_, replace)
		
				*female 
				twoway scatter AVRG_f MOB_altern if treat == 1 & age_group == `grp', color(cranberry)  || ///
					line _f_hat_r_fert__T_`grp' MOB_altern if after == 1, sort color(cranberry%60) || ///
					line _f_hat_r_fert__T_`grp' MOB_altern if after == 0, sort color(cranberry%60) ///
					scheme(s1mono )  ///
					xtitle("") ytitle("") ///
					ylabel(#5,grid) ///
					xlabel(1(2)12, val) xmtick(2(2)12) ///
					legend(off) ///
					xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
					saving($graphs/`grp'_female_r_fert_, replace)
					
				*male	
				twoway scatter AVRG_m MOB_altern if treat == 1 & age_group == `grp', color(navy) || ///
					line _m_hat_r_fert__T_`grp' MOB_altern if after == 1, sort color(navy%60) || ///
					line _m_hat_r_fert__T_`grp' MOB_altern if after == 0, sort color(navy%60) ///
					scheme(s1mono )  ///
					xtitle("") ytitle("") ///
					ylabel(#5,grid) ///
					xlabel(1(2)12, val) xmtick(2(2)12) ///
					legend(off) ///
					xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
						saving($graphs/`grp'_male_r_fert_, replace)
			} // end else (not the first row)
		} // end: loop over age groups
	
		graph combine "$graphs/1_total_r_fert_.gph"	"$graphs/1_female_r_fert_.gph"	"$graphs/1_male_r_fert_.gph" ///
					"$graphs/2_total_r_fert_.gph"	"$graphs/2_female_r_fert_.gph"	"$graphs/2_male_r_fert_.gph" ///
					"$graphs/3_total_r_fert_.gph"	"$graphs/3_female_r_fert_.gph"	"$graphs/3_male_r_fert_.gph" ///
					"$graphs/4_total_r_fert_.gph"	"$graphs/4_female_r_fert_.gph"	"$graphs/4_male_r_fert_.gph" ///
					, altshrink ///
				  scheme(s1mono) col(3) imargin(zero) 
		graph export "$graph_paper/rd_r_fert_`1'_overview_agegroups.pdf", as(pdf) replace
	} // end: loop over var specification 
} //end: loop over variable list



/*
global  t_4 "Age 17-21"
foreach grp of numlist 4 {
local ylab "t_`grp'"
twoway scatter AVRG MOB_altern if treat == 1 & age_group == 4, color(black) || ///
				line _hat_r_fert__T_4 MOB_altern if after == 1, sort color(black%40) || ///
				line _hat_r_fert__T_4 MOB_altern if after == 0, sort color(black%40) ///
				scheme(s1mono )  ///
				xtitle("") ytitle("$`ylab'", box bexpand size(vlarge) margin(medium)) ///
				ylabel(#5,grid) ///
				xlabel(1(2)12, val) xmtick(2(2)12) ///
				legend(off) ///
				xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry))
} 



*Graph combin
graph combine "$graphs/1_total_r_fert_.gph"	"$graphs/1_female_r_fert_.gph"	"$graphs/1_male_r_fert_.gph" ///
					"$graphs/2_total_r_fert_.gph"	"$graphs/2_female_r_fert_.gph"	"$graphs/2_male_r_fert_.gph" ///
					"$graphs/3_total_r_fert_.gph"	"$graphs/3_female_r_fert_.gph"	"$graphs/3_male_r_fert_.gph" ///
					"$graphs/4_total_r_fert_.gph"	"$graphs/4_female_r_fert_.gph"	"$graphs/4_male_r_fert_.gph" ///
					, altshrink ///
				  scheme(s1mono) col(3) imargin(zero)  xsize(15) ysize(11.5)
graph export "$graph_paper/rd_r_fert_d5_overview_agegroups.pdf", as(pdf) replace
