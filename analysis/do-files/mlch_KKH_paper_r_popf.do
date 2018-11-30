	use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"

keep if GDR == 0


capture program drop DDRD
	program define DDRD
		qui eststo `1': reg `2' treat after TxA  `3'  `4', vce(cluster MxY) 
	end
capture program drop DDRD_sclrs
	program define DDRD_sclrs
		qui eststo `1': reg `2' treat after TxA  `3'  `4', vce(cluster MxY) 
		qui estadd scalar Nn = e(N)
		qui sum `2' if e(sample) & treat== 1 & after == 0 
		qui estadd scalar mean = round(`r(mean)',.01)		// pre-reform mean for treated group
		qui estadd scalar sd = abs(round(_b[TxA]/`r(sd)'*100,.01))		
		capture drop Dinregression sum_num_diag*
		qui gen Dinregression = 1 if cond(e(sample),1,0)
		bys Dinregression: egen sum_num_diagnoses = total(`2')
		qui summ sum_num_diagnoses if e(sample)
		qui estadd scalar num_diag = `r(mean)'
	end		
	
	*reg r_popf_d5 treat after TxA  i.MOB i.year  if $C2 & $M6
	
	
	
foreach 1 of varlist hospital2 d5  { // hospital2 d5 
	foreach j in "" "_f" "_m" { // "" "_f" "_m" 
		eststo clear 	
		*overall effect
		DDRD_sclrs b1 r_popf_`1'`j'   "i.MOB i.year" "if $C2 & $M1 & year_treat >= 2006"
		DDRD_sclrs b2 r_popf_`1'`j'   "i.MOB i.year" "if $C2 & $M2 & year_treat >= 2006"
		DDRD_sclrs b3 r_popf_`1'`j'   "i.MOB i.year" "if $C2 & $M3 & year_treat >= 2006"
		DDRD_sclrs b4 r_popf_`1'`j'   "i.MOB i.year" "if $C2 & $M4 & year_treat >= 2006"
		DDRD_sclrs b5 r_popf_`1'`j'   "i.MOB i.year" "if $C2 & $M5 & year_treat >= 2006"
		DDRD_sclrs b6 r_popf_`1'`j'   "i.MOB i.year" "if $C2 & year_treat >= 2006" 
		DDRD_sclrs b7 r_popf_`1'`j'   "i.MOB i.year" "if $C2 & $MD & year_treat >= 2006"
		esttab b* using "$tables_paper/include/paper_r_popf_`1'`j'_DD_overall.tex", replace booktabs fragment ///
			keep(TxA) coeflabels(TxA "\hspace*{10pt}Overall") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			scalars(  "mean \midrule Dependent mean" "sd Effect in SDs [\%]" "Nn Observations")  
			

			
		* effect per age group
		foreach age_group in "$age_27_29" "$age_30_32" "$age_33_35"  { //
			if "`age_group'" == "$age_27_29" {
				local age_label = "Age 27-29"
				local age_outputname = "27-29"
			}
			if "`age_group'" == "$age_30_32" {
				local age_label = "Age 30-32"
				local age_outputname = "30-32"
			}
			if "`age_group'" == "$age_33_35" {
				local age_label = "Age 33-35"
				local age_outputname = "33-35"
			}
			eststo clear 
			DDRD b1 r_popf_`1'`j'   "i.MOB i.year" "if `age_group' & $C2 & $M1"
			DDRD b2 r_popf_`1'`j'   "i.MOB i.year" "if `age_group' & $C2 & $M2"
			DDRD b3 r_popf_`1'`j'   "i.MOB i.year" "if `age_group' & $C2 & $M3"
			DDRD b4 r_popf_`1'`j'   "i.MOB i.year" "if `age_group' & $C2 & $M4"
			DDRD b5 r_popf_`1'`j'   "i.MOB i.year" "if `age_group' & $C2 & $M5"
			DDRD b6 r_popf_`1'`j'   "i.MOB i.year" "if `age_group' & $C2"
			DDRD b7 r_popf_`1'`j'   "i.MOB i.year" "if `age_group' & $C2 & $MD"
			esttab b* using "$tables_paper/include/paper_r_popf_`1'`j'_DD_`age_outputname'.tex", replace booktabs fragment ///
				keep(TxA) coeflabels(TxA "\hspace*{10pt}`age_label'") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label nomtitles nonumbers noobs nonote nogaps noline  
		} // end: agegroup
	} // end: tfm
	// Panels zusammenfassen
} //end: varlist

********************************************************************************
// RF

	use "$temp\KKH_final_R1", clear
	run "$auxiliary/varlists_varnames_sample-spcifications"

	keep if treat == 1
	keep if GDR == 0
		
	*****************************************
	* 1) per age-group - no MA
	*generate age group variable over which we can loop	
	qui gen age_group = . 
	qui replace age_group = 1 if year_treat >= 2006 & year_treat<=2008	// nicht sinnvoll, da keine Einträge in abhängigen Variablen
	qui replace age_group = 2 if year_treat >= 2009 & year_treat<=2011	
	qui replace age_group = 3 if year_treat >= 2012 & year_treat<=2014
	label define AGE_GRP  1 "[1] 27-29 years" 2 "[2] 30-32 years" 3 "[3] 33-35 years"  //
	label val age_group AGE_GRP
	

	
	global t_1 = "Age 27-29"
	global t_2 = "Age 30-32"
	global t_3 = "Age 33-35"
	
	label define MOB_alt2 1 "11/78" 3 "01/79" 5 "03/79" 7 "05/79" 9 "07/79" 11 "09/79"
	label val MOB_altern MOB_alt2	
	
//	 a) HOSPITAL2
foreach 1 of varlist hospital2 { // d5
	local yscl = "80 130"	// define scale 
	local ylbl = "90(10)130"	// define label
	
	foreach var in "r_popf_"{ // rows: 
		foreach grp of numlist 1 2 3  {
			local ylab "t_`grp'"
			foreach j in "" "_f" "_m"  { // columns:  
				capture drop AVRG`j' `j'_hat*  //
				qui bys Datum age_group: egen AVRG`j' = mean(r_popf_`1'`j') 
				qui reg r_popf_`1'`j' Numx Num_after after if treat == 1 & age_group == `grp'
				qui predict `j'_hat_r_popf__T_`grp'
			} // end: loop over columns (total, male, female)
				
			if `grp' == 1 { // include top titles for first row
				*total		
				twoway scatter AVRG MOB_altern if treat == 1 & age_group == `grp', color(black) || ///
					lfitci AVRG MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(black%12) clp(dash) clc(black%75) level(95) ||  ///
					lfitci AVRG MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(black%12) clp(dash) clc(black%75) level(95) ||  ///
					lfitci AVRG MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(black%25) clp(dash) clc(black%75) level(90) ||   ///
					lfitci AVRG MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(black%25) clp(dash) clc(black%75) level(90)   ///					
					scheme(s1mono )  ///
					xtitle("") ytitle("$`ylab'", box bexpand size(vhuge) margin(medsmall) bmargin(right)) ///
					title("Total", box bexpand size(vhuge) margin(medsmall)) ///
					ylabel(`ylbl',grid) yscale(r(`yscl')) ///
					xlabel(1(2)12, val) xmtick(2(2)12) ///
					legend(off) ///
					xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
					saving($graphs/`grp'_total_r_popf_, replace)
		
				*female 
				twoway scatter AVRG_f MOB_altern if treat == 1 & age_group == `grp', color(cranberry)  || ///
					lfitci AVRG_f MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(cranberry%12) clp(dash) clc(cranberry%75) level(95) ||  ///
					lfitci AVRG_f MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(cranberry%12) clp(dash) clc(cranberry%75) level(95) ||  ///
					lfitci AVRG_f MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(cranberry%25) clp(dash) clc(cranberry%75) level(90) ||   ///
					lfitci AVRG_f MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(cranberry%25) clp(dash) clc(cranberry%75) level(90)   ///
					scheme(s1mono )  ///
					xtitle("") ytitle("") ///
					title("Female", box bexpand size(vhuge) margin(medsmall)) ///
					ylabel(`ylbl',grid) yscale(r(`yscl')) ///
					xlabel(1(2)12, val) xmtick(2(2)12) ///
					legend(off) ///
					xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
					saving($graphs/`grp'_female_r_popf_, replace)
					
				*male	
				twoway scatter AVRG_m MOB_altern if treat == 1 & age_group == `grp', color(navy) || ///
					lfitci AVRG_m MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(navy%12) clp(dash) clc(navy%75) level(95) ||  ///
					lfitci AVRG_m MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(navy%12) clp(dash) clc(navy%75) level(95) ||  ///
					lfitci AVRG_m MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(navy%25) clp(dash) clc(navy%75) level(90) ||   ///
					lfitci AVRG_m MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(navy%25) clp(dash) clc(navy%75) level(90)   ///
					scheme(s1mono )  ///
					xtitle("") ytitle("") ///
					title("Male", box bexpand size(vhuge) margin(medsmall)) ///
					ylabel(`ylbl',grid) yscale(r(`yscl')) ///
					xlabel(1(2)12, val) xmtick(2(2)12) ///
					legend(off) ///
					xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
						saving($graphs/`grp'_male_r_popf_, replace)
				
			} // end first group
			
			else { // all other rows
				*total		
				twoway scatter AVRG MOB_altern if treat == 1 & age_group == `grp', color(black) || ///
					lfitci AVRG MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(black%12) clp(dash) clc(black%75) level(95) ||  ///
					lfitci AVRG MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(black%12) clp(dash) clc(black%75) level(95) ||  ///
					lfitci AVRG MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(black%25) clp(dash) clc(black%75) level(90) ||   ///
					lfitci AVRG MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(black%25) clp(dash) clc(black%75) level(90)   ///
					scheme(s1mono )  ///
					xtitle("") ytitle("$`ylab'", box bexpand size(vhuge) margin(medsmall) bmargin(right)) ///
					ylabel(`ylbl',grid) yscale(r(`yscl')) /// ///
					xlabel(1(2)12, val) xmtick(2(2)12) ///
					legend(off) ///
					xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
					saving($graphs/`grp'_total_r_popf_, replace)
		
				*female 
				twoway scatter AVRG_f MOB_altern if treat == 1 & age_group == `grp', color(cranberry)  || ///
					lfitci AVRG_f MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(cranberry%12) clp(dash) clc(cranberry%75) level(95) ||  ///
					lfitci AVRG_f MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(cranberry%12) clp(dash) clc(cranberry%75) level(95) ||  ///
					lfitci AVRG_f MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(cranberry%25) clp(dash) clc(cranberry%75) level(90) ||   ///
					lfitci AVRG_f MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(cranberry%25) clp(dash) clc(cranberry%75) level(90)   ///
					scheme(s1mono )  ///
					xtitle("") ytitle("") ///
					ylabel(`ylbl',grid) yscale(r(`yscl')) /// ///
					xlabel(1(2)12, val) xmtick(2(2)12) ///
					legend(off) ///
					xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
					saving($graphs/`grp'_female_r_popf_, replace)
					
				*male	
				twoway scatter AVRG_m MOB_altern if treat == 1 & age_group == `grp', color(navy) || ///
					lfitci AVRG_m MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(navy%12) clp(dash) clc(navy%75) level(95) ||  ///
					lfitci AVRG_m MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(navy%12) clp(dash) clc(navy%75) level(95) ||  ///
					lfitci AVRG_m MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(navy%25) clp(dash) clc(navy%75) level(90) ||   ///
					lfitci AVRG_m MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(navy%25) clp(dash) clc(navy%75) level(90)   ///
					scheme(s1mono )  ///
					xtitle("") ytitle("") ///
					ylabel(`ylbl',grid) yscale(r(`yscl')) /// ///
					xlabel(1(2)12, val) xmtick(2(2)12) ///
					legend(off) ///
					xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
						saving($graphs/`grp'_male_r_popf_, replace)
			} // end else (not the first row)
		} // end: loop over age groups
	
		graph combine "$graphs/1_total_r_popf_.gph"	"$graphs/1_female_r_popf_.gph"	"$graphs/1_male_r_popf_.gph" ///
					"$graphs/2_total_r_popf_.gph"	"$graphs/2_female_r_popf_.gph"	"$graphs/2_male_r_popf_.gph" ///
					"$graphs/3_total_r_popf_.gph"	"$graphs/3_female_r_popf_.gph"	"$graphs/3_male_r_popf_.gph" ///
					, altshrink ///
				  scheme(s1mono) col(3) imargin(zero) 
		graph export "$graph_paper/rd_r_popf_`1'_overview_agegroups_CIfits.pdf", as(pdf) replace
	} // end: loop over var specification 
} //end: loop over variable list

foreach 1 of varlist d5 { // d5
	local yscl = "11 34"	// define scale 
	local ylbl = "15(5)30"	// define label
	
	foreach var in "r_popf_"{ // rows: 
		foreach grp of numlist 1 2 3  {
			local ylab "t_`grp'"
			foreach j in "" "_f" "_m"  { // columns:  
				capture drop AVRG`j' `j'_hat*  //
				qui bys Datum age_group: egen AVRG`j' = mean(r_popf_`1'`j') 
				qui reg r_popf_`1'`j' Numx Num_after after if treat == 1 & age_group == `grp'
				qui predict `j'_hat_r_popf__T_`grp'
			} // end: loop over columns (total, male, female)
				
			if `grp' == 1 { // include top titles for first row
				*total		
				twoway scatter AVRG MOB_altern if treat == 1 & age_group == `grp', color(black) || ///
					lfitci AVRG MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(black%12) clp(dash) clc(black%75) level(95) ||  ///
					lfitci AVRG MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(black%12) clp(dash) clc(black%75) level(95) ||  ///
					lfitci AVRG MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(black%25) clp(dash) clc(black%75) level(90) ||   ///
					lfitci AVRG MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(black%25) clp(dash) clc(black%75) level(90)   ///					
					scheme(s1mono )  ///
					xtitle("") ytitle("$`ylab'", box bexpand size(vhuge) margin(medsmall) bmargin(right)) ///
					title("Total", box bexpand size(vhuge) margin(medsmall)) ///
					ylabel(`ylbl',grid) yscale(r(`yscl')) ///
					xlabel(1(2)12, val) xmtick(2(2)12) ///
					legend(off) ///
					xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
					saving($graphs/`grp'_total_r_popf_, replace)
		
				*female 
				twoway scatter AVRG_f MOB_altern if treat == 1 & age_group == `grp', color(cranberry)  || ///
					lfitci AVRG_f MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(cranberry%12) clp(dash) clc(cranberry%75) level(95) ||  ///
					lfitci AVRG_f MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(cranberry%12) clp(dash) clc(cranberry%75) level(95) ||  ///
					lfitci AVRG_f MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(cranberry%25) clp(dash) clc(cranberry%75) level(90) ||   ///
					lfitci AVRG_f MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(cranberry%25) clp(dash) clc(cranberry%75) level(90)   ///
					scheme(s1mono )  ///
					xtitle("") ytitle("") ///
					title("Female", box bexpand size(vhuge) margin(medsmall)) ///
					ylabel(`ylbl',grid) yscale(r(`yscl')) ///
					xlabel(1(2)12, val) xmtick(2(2)12) ///
					legend(off) ///
					xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
					saving($graphs/`grp'_female_r_popf_, replace)
					
				*male	
				twoway scatter AVRG_m MOB_altern if treat == 1 & age_group == `grp', color(navy) || ///
					lfitci AVRG_m MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(navy%12) clp(dash) clc(navy%75) level(95) ||  ///
					lfitci AVRG_m MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(navy%12) clp(dash) clc(navy%75) level(95) ||  ///
					lfitci AVRG_m MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(navy%25) clp(dash) clc(navy%75) level(90) ||   ///
					lfitci AVRG_m MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(navy%25) clp(dash) clc(navy%75) level(90)   ///
					scheme(s1mono )  ///
					xtitle("") ytitle("") ///
					title("Male", box bexpand size(vhuge) margin(medsmall)) ///
					ylabel(`ylbl',grid) yscale(r(`yscl')) ///
					xlabel(1(2)12, val) xmtick(2(2)12) ///
					legend(off) ///
					xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
						saving($graphs/`grp'_male_r_popf_, replace)
				
			} // end first group
			
			else { // all other rows
				*total		
				twoway scatter AVRG MOB_altern if treat == 1 & age_group == `grp', color(black) || ///
					lfitci AVRG MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(black%12) clp(dash) clc(black%75) level(95) ||  ///
					lfitci AVRG MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(black%12) clp(dash) clc(black%75) level(95) ||  ///
					lfitci AVRG MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(black%25) clp(dash) clc(black%75) level(90) ||   ///
					lfitci AVRG MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(black%25) clp(dash) clc(black%75) level(90)   ///
					scheme(s1mono )  ///
					xtitle("") ytitle("$`ylab'", box bexpand size(vhuge) margin(medsmall) bmargin(right)) ///
					ylabel(`ylbl',grid) yscale(r(`yscl')) /// ///
					xlabel(1(2)12, val) xmtick(2(2)12) ///
					legend(off) ///
					xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
					saving($graphs/`grp'_total_r_popf_, replace)
		
				*female 
				twoway scatter AVRG_f MOB_altern if treat == 1 & age_group == `grp', color(cranberry)  || ///
					lfitci AVRG_f MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(cranberry%12) clp(dash) clc(cranberry%75) level(95) ||  ///
					lfitci AVRG_f MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(cranberry%12) clp(dash) clc(cranberry%75) level(95) ||  ///
					lfitci AVRG_f MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(cranberry%25) clp(dash) clc(cranberry%75) level(90) ||   ///
					lfitci AVRG_f MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(cranberry%25) clp(dash) clc(cranberry%75) level(90)   ///
					scheme(s1mono )  ///
					xtitle("") ytitle("") ///
					ylabel(`ylbl',grid) yscale(r(`yscl')) /// ///
					xlabel(1(2)12, val) xmtick(2(2)12) ///
					legend(off) ///
					xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
					saving($graphs/`grp'_female_r_popf_, replace)
					
				*male	
				twoway scatter AVRG_m MOB_altern if treat == 1 & age_group == `grp', color(navy) || ///
					lfitci AVRG_m MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(navy%12) clp(dash) clc(navy%75) level(95) ||  ///
					lfitci AVRG_m MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(navy%12) clp(dash) clc(navy%75) level(95) ||  ///
					lfitci AVRG_m MOB_altern if treat == 1 & age_group == `grp' & after == 1, color(navy%25) clp(dash) clc(navy%75) level(90) ||   ///
					lfitci AVRG_m MOB_altern if treat == 1 & age_group == `grp' & after == 0, color(navy%25) clp(dash) clc(navy%75) level(90)   ///
					scheme(s1mono )  ///
					xtitle("") ytitle("") ///
					ylabel(`ylbl',grid) yscale(r(`yscl')) /// ///
					xlabel(1(2)12, val) xmtick(2(2)12) ///
					legend(off) ///
					xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) nodraw ///
						saving($graphs/`grp'_male_r_popf_, replace)
			} // end else (not the first row)
		} // end: loop over age groups
	
		graph combine "$graphs/1_total_r_popf_.gph"	"$graphs/1_female_r_popf_.gph"	"$graphs/1_male_r_popf_.gph" ///
					"$graphs/2_total_r_popf_.gph"	"$graphs/2_female_r_popf_.gph"	"$graphs/2_male_r_popf_.gph" ///
					"$graphs/3_total_r_popf_.gph"	"$graphs/3_female_r_popf_.gph"	"$graphs/3_male_r_popf_.gph" ///
					, altshrink ///
				  scheme(s1mono) col(3) imargin(zero) 
		graph export "$graph_paper/rd_r_popf_`1'_overview_agegroups_CIfits.pdf", as(pdf) replace
	} // end: loop over var specification 
} //end: loop over variable list	
	

* A ) D5 POOLED
foreach 1 of  varlist d5 { 
	foreach j in "" "_f" "_m"  { // columns:  
		capture drop AVRG`j'   //
		qui bys Datum: egen AVRG`j' = mean(r_popf_`1'`j') 
	} // end: loop over columns (total, male, female)
	
	local yscl = "14 24"	// define scale 
	local ylbl = "15(3)24"	// define label

	twoway scatter AVRG MOB_altern if treat == 1 , color(black) || ///
		lfitci AVRG MOB_altern if treat == 1 & after == 1, color(black%12) clp(dash) clc(black%75) level(95) ||  ///
		lfitci AVRG MOB_altern if treat == 1 & after == 0, color(black%12) clp(dash) clc(black%75) level(95) ||  ///
		lfitci AVRG MOB_altern if treat == 1 & after == 1, color(black%25) clp(dash) clc(black%75) level(90) ||   ///
		lfitci AVRG MOB_altern if treat == 1 & after == 0, color(black%25) clp(dash) clc(black%75) level(90)   ///					
		scheme(s1mono ) plotregion(color(white)) ///
		xtitle("") ytitle("") ///
		ylabel(`ylbl',grid) yscale(r(`yscl')) ///
		xlabel(1(2)12, val) xmtick(2(2)12) ///
		legend(label(2 "95% CI") label(6 "90% CI")) ///
		legend(order(6 2)) ///
		legend(pos(1) ring(0) col(1)) legend(size(vsmall)) ///
		legend(region(color(none))) legend(symx(5)) ///
		xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry))
		graph export "$graph_paper/rd_r_popf_`1'_total_pooled.pdf", as(pdf) replace
			
	twoway scatter AVRG_f MOB_altern if treat == 1 , color(cranberry)  || ///
		lfitci AVRG_f MOB_altern if treat == 1 & after == 1, color(cranberry%12) clp(dash) clc(cranberry%75) level(95) ||  ///
		lfitci AVRG_f MOB_altern if treat == 1 & after == 0, color(cranberry%12) clp(dash) clc(cranberry%75) level(95) ||  ///
		lfitci AVRG_f MOB_altern if treat == 1 & after == 1, color(cranberry%25) clp(dash) clc(cranberry%75) level(90) ||   ///
		lfitci AVRG_f MOB_altern if treat == 1 & after == 0, color(cranberry%25) clp(dash) clc(cranberry%75) level(90)   ///
		scheme(s1mono ) plotregion(color(white)) ///
		xtitle("") ytitle("") ///
		ylabel(`ylbl',grid) yscale(r(`yscl')) ///
		xlabel(1(2)12, val) xmtick(2(2)12) ///
		legend(label(2 "95% CI") label(6 "90% CI")) ///
		legend(order(6 2)) ///
		legend(pos(1) ring(0) col(1)) legend(size(vsmall)) ///
		legend(region(color(none))) legend(symx(5)) ///
		xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 
		graph export "$graph_paper/rd_r_popf_`1'_female_pooled.pdf", as(pdf) replace

	twoway scatter AVRG_m MOB_altern if treat == 1 , color(navy) || ///
		lfitci AVRG_m MOB_altern if treat == 1 & after == 1, color(navy%12) clp(dash) clc(navy%75) level(95) ||  ///
		lfitci AVRG_m MOB_altern if treat == 1 & after == 0, color(navy%12) clp(dash) clc(navy%75) level(95) ||  ///
		lfitci AVRG_m MOB_altern if treat == 1 & after == 1, color(navy%25) clp(dash) clc(navy%75) level(90) ||   ///
		lfitci AVRG_m MOB_altern if treat == 1 & after == 0, color(navy%25) clp(dash) clc(navy%75) level(90)   ///
		scheme(s1mono ) plotregion(color(white)) ///
		xtitle("") ytitle("") ///
		ylabel(`ylbl',grid) yscale(r(`yscl')) ///
		xlabel(1(2)12, val) xmtick(2(2)12) ///
		legend(label(2 "95% CI") label(6 "90% CI")) ///
		legend(order(6 2)) ///
		legend(pos(1) ring(0) col(1)) legend(size(vsmall)) ///
		legend(region(color(none))) legend(symx(5)) ///
		xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 
		graph export "$graph_paper/rd_r_popf_`1'_male_pooled.pdf", as(pdf) replace
	}
// B) HOSPITAL2 pooled
foreach 1 of  varlist hospital2 { 
	foreach j in "" "_f" "_m"  { // columns:  
		capture drop AVRG`j'   //
		qui bys Datum: egen AVRG`j' = mean(r_popf_`1'`j') 
	} // end: loop over columns (total, male, female)
	
	local yscl = "85 120"	// define scale 
	local ylbl = "90(10)120"	// define label

	twoway scatter AVRG MOB_altern if treat == 1 , color(black) || ///
		lfitci AVRG MOB_altern if treat == 1 & after == 1, color(black%12) clp(dash) clc(black%75) level(95) ||  ///
		lfitci AVRG MOB_altern if treat == 1 & after == 0, color(black%12) clp(dash) clc(black%75) level(95) ||  ///
		lfitci AVRG MOB_altern if treat == 1 & after == 1, color(black%25) clp(dash) clc(black%75) level(90) ||   ///
		lfitci AVRG MOB_altern if treat == 1 & after == 0, color(black%25) clp(dash) clc(black%75) level(90)   ///					
		scheme(s1mono ) plotregion(color(white)) ///
		xtitle("") ytitle("") ///
		ylabel(`ylbl',grid) yscale(r(`yscl')) ///
		xlabel(1(2)12, val) xmtick(2(2)12) ///
		legend(label(2 "95% CI") label(6 "90% CI")) ///
		legend(order(6 2)) ///
		legend(pos(1) ring(0) col(1)) legend(size(vsmall)) ///
		legend(region(color(none))) legend(symx(5)) ///
		xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry))
		graph export "$graph_paper/rd_r_popf_`1'_total_pooled.pdf", as(pdf) replace
			
	twoway scatter AVRG_f MOB_altern if treat == 1 , color(cranberry)  || ///
		lfitci AVRG_f MOB_altern if treat == 1 & after == 1, color(cranberry%12) clp(dash) clc(cranberry%75) level(95) ||  ///
		lfitci AVRG_f MOB_altern if treat == 1 & after == 0, color(cranberry%12) clp(dash) clc(cranberry%75) level(95) ||  ///
		lfitci AVRG_f MOB_altern if treat == 1 & after == 1, color(cranberry%25) clp(dash) clc(cranberry%75) level(90) ||   ///
		lfitci AVRG_f MOB_altern if treat == 1 & after == 0, color(cranberry%25) clp(dash) clc(cranberry%75) level(90)   ///
		scheme(s1mono ) plotregion(color(white)) ///
		xtitle("") ytitle("") ///
		ylabel(`ylbl',grid) yscale(r(`yscl')) ///
		xlabel(1(2)12, val) xmtick(2(2)12) ///
		legend(label(2 "95% CI") label(6 "90% CI")) ///
		legend(order(6 2)) ///
		legend(pos(1) ring(0) col(1)) legend(size(vsmall)) ///
		legend(region(color(none))) legend(symx(5)) ///
		xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 
		graph export "$graph_paper/rd_r_popf_`1'_female_pooled.pdf", as(pdf) replace

	twoway scatter AVRG_m MOB_altern if treat == 1 , color(navy) || ///
		lfitci AVRG_m MOB_altern if treat == 1 & after == 1, color(navy%12) clp(dash) clc(navy%75) level(95) ||  ///
		lfitci AVRG_m MOB_altern if treat == 1 & after == 0, color(navy%12) clp(dash) clc(navy%75) level(95) ||  ///
		lfitci AVRG_m MOB_altern if treat == 1 & after == 1, color(navy%25) clp(dash) clc(navy%75) level(90) ||   ///
		lfitci AVRG_m MOB_altern if treat == 1 & after == 0, color(navy%25) clp(dash) clc(navy%75) level(90)   ///
		scheme(s1mono ) plotregion(color(white)) ///
		xtitle("") ytitle("") ///
		ylabel(`ylbl',grid) yscale(r(`yscl')) ///
		xlabel(1(2)12, val) xmtick(2(2)12) ///
		legend(label(2 "95% CI") label(6 "90% CI")) ///
		legend(order(6 2)) ///
		legend(pos(1) ring(0) col(1)) legend(size(vsmall)) ///
		legend(region(color(none))) legend(symx(5)) ///
		xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 
		graph export "$graph_paper/rd_r_popf_`1'_male_pooled.pdf", as(pdf) replace
}
*******************************************************************************
// LC`
********************************************************************************
	use "$temp\KKH_final_R1", clear
run "$auxiliary/varlists_varnames_sample-spcifications"
// THE PROGRAM
capture program drop DDRD
program define DDRD
		qui reg `1' treat after TxA i.MOB   `2'  , vce(cluster MxY) 
end
*************************
// PANEL 1.1: PLOTS FOR EACH GENDER SEPERATELY (WITH CG2!) 
capture drop Dinregression temp
qui gen Dinregression = 1 if cond($C2,1,0)
qui gen temp = 1 if treat == 1 & after == 0

foreach 1 of varlist hospital2 d5 { // hospital2 d5
	capture drop sum_num_diag*
	bys temp year_treat: egen sum_num_diagnoses = mean(r_popf_`1') if treat == 1 & after == 0
	bys temp year_treat: egen sum_num_diagnoses_f = mean(r_popf_`1'_f) if treat == 1 & after == 0
	bys temp year_treat: egen sum_num_diagnoses_m = mean(r_popf_`1'_m) if treat == 1 & after == 0
	
	foreach var in "r_popf_"  {	// COLUMNS
		capture drop b* CIL* CIR*
		foreach j in "" "_f" "_m" { // rows
			
			qui gen b`j' =.
			qui gen CIL95`j' =.
			qui gen CIR95`j' =. 
			qui gen CIL90`j' =.
			qui gen CIR90`j' =. 
			
			qui summ year_treat if !missing(`var'`1') & treat == 1
			local start = r(min) + 1
			local ende = r(max)
			
			forvalues X = `start' (1) `ende' {
				DDRD `var'`1'`j'  " if year_treat == `X' & $C2"
				qui replace b`j' = _b[TxA] if year_treat == `X'
				qui replace CIL95`j' = (_b[TxA]- $t_95 *_se[TxA]) if year_treat == `X'
				qui replace CIR95`j' = (_b[TxA]+ $t_95 *_se[TxA]) if year_treat == `X'
				qui replace CIL90`j' = (_b[TxA]- $t_90 *_se[TxA]) if year_treat == `X'
				qui replace CIR90`j' = (_b[TxA]+ $t_90 *_se[TxA]) if year_treat == `X'
				
			} //end:loop over lifecycle
		} //end:loop t,f,m (ROWS)
		local start_mtick = `start' + 2 
		*total
		twoway line sum_num_diagnoses year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs14) lw(vthick) yaxis(2)  || ///
			rarea CIL95 CIR95 year_treat, sort  color(gs2%12) yaxis(1) || ///
			rarea CIL90 CIR90 year_treat, sort  color(gs2%25) yaxis(1) || ///
			line b year_treat, sort color(gs2) yaxis(1) ///
			scheme(s1mono)    /// 
			yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
			legend(label(2 "95% CI") label(3 "90% CI")) ///
			legend(order(3 2)) legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
			legend(region(color(none))) legend(symx(5)) ///
			xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") ///
			xmtick(`start_mtick'  (4) `ende') ///
			ytitle("ITT effect", axis(1)) ytitle("Dependent mean",axis(2)) ///
			yscale(alt axis(2)) yscale(alt axis(1)) 
			graph export "$graph_paper/lc_r_popf_`1'_total_gdr.pdf", as(pdf) replace	

		*female
		twoway line sum_num_diagnoses_f year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs14) lw(vthick) yaxis(2)  || ///
			rarea CIL95_f CIR95_f year_treat, sort  color(cranberry%12) yaxis(1) || ///
			rarea CIL90_f CIR90_f year_treat, sort  color(cranberry%25) yaxis(1) || ///
			line b_f year_treat, sort color(cranberry) yaxis(1) ///
			scheme(s1mono)  /// 
			yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
			legend(label(2 "95% CI") label(3 "90% CI")) ///
			legend(order(3 2)) legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
			legend(region(color(none))) legend(symx(5)) ///
			xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") ///
			xmtick(`start_mtick'  (4) `ende') ///
			ytitle("ITT effect", axis(1)) ytitle("Dependent mean",axis(2)) ///
			yscale(alt axis(2)) yscale(alt axis(1))
			graph export "$graph_paper/lc_r_popf_`1'_female_gdr.pdf", as(pdf) replace		
		*male
		twoway line sum_num_diagnoses_m year_treat if Dinregression == 1 & year_treat >= `start' & year_treat <= `ende', sort color(gs14) lw(vthick) yaxis(2)  || ///
			rarea CIL95_m CIR95_m year_treat, sort  color(navy%12) yaxis(1) || ///
			rarea CIL90_m CIR90_m year_treat, sort  color(navy%25) yaxis(1) || ///
			line b_m year_treat, sort color(navy) yaxis(1) ///
			scheme(s1mono)  /// 
			yline(0, lw(thin) lpattern(dash) lcolor(black))   ///
			legend(label(2 "95% CI") label(3 "90% CI")) ///
			legend(order(3 2)) legend(pos(11) ring(0) col(1)) legend(size(vsmall)) ///
			legend(region(color(none))) legend(symx(5)) ///
			xlabel(`start' (4) `ende' ,val angle(0)) xtitle("") ///
			xmtick(`start_mtick'  (4) `ende') ///
			ytitle("ITT effect", axis(1)) ytitle("Dependent mean",axis(2)) ///
			yscale(alt axis(2)) yscale(alt axis(1)) 
			graph export "$graph_paper/lc_r_popf_`1'_male_gdr.pdf", as(pdf) replace	
		
			
	} //end: loop over variable specification (COLUMNS)
	} //end: loop over variables
	
*******************************************************************************	
/*	
use "$temp\KKH_final_R1", clear
run "$auxiliary/varlists_varnames_sample-spcifications"	

keep if year == 2014

foreach 1 of  varlist hospital2 { 
	foreach j in "" "_f" "_m"  { // columns:  
		capture drop AVRG`j'   //
		qui bys Datum: egen AVRG`j' = mean(r_fert_`1'`j') if treat!=1
		quigen Delta = AVRG`j' - 
	} // end: loop over columns (total, male, female)


reg r_fert_d5 i.MOB i.YOB if treat!=1
qui predict hat if treat == 1
qui gen delta = r_fert_d5 - hat

qui bys Datum: egen AVRG = mean(delta)

scatter AVRG MOB_altern if treat == 1, ///
	xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 

/*
twoway scatter AVRG_m MOB_altern if treat == 1 , color(navy) || ///
		lfitci AVRG_m MOB_altern if treat == 1 & after == 1, color(navy%12) clp(dash) clc(navy%75) level(95) ||  ///
		lfitci AVRG_m MOB_altern if treat == 1 & after == 0, color(navy%12) clp(dash) clc(navy%75) level(95) ||  ///
		lfitci AVRG_m MOB_altern if treat == 1 & after == 1, color(navy%25) clp(dash) clc(navy%75) level(90) ||   ///
		lfitci AVRG_m MOB_altern if treat == 1 & after == 0, color(navy%25) clp(dash) clc(navy%75) level(90)   ///
		scheme(s1mono ) plotregion(color(white)) ///
		xtitle("") ytitle("") ///
		ylabel(`ylbl',grid) yscale(r(`yscl')) ///
		xlabel(1(2)12, val) xmtick(2(2)12) ///
		legend(label(2 "95% CI") label(6 "90% CI")) ///
		legend(order(6 2)) ///
		legend(pos(1) ring(0) col(1)) legend(size(vsmall)) ///
		legend(region(color(none))) legend(symx(5)) ///
		xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) 



