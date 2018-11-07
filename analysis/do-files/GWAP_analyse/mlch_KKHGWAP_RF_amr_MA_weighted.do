/*
Dieses Do-File generiert drei Graphen, die die reltive Häufigkeit einer Krankenhaus-
einlieferung von Personen einer Geburtskohorte darstellt. Dies wird für alle Personen,
Frauen und Männer gemacht. 

Das besondere ist, dass die Darstellung ein moving average Verfahren mit 
einer Gewichtung (nach Bevölkerungsgröße) kombiniert. 
*/
 
********************************************************************************
use ${temp}/KKH_final_amr_level, clear
run "auxiliary_varlists_varnames_sample-spcifications"
sort amr_clean Datum year
*qui gen MxYxFRG = MxY * FRG


drop if GDR == 1
keep if treat == 1
order amr Datum year 
sort amr Datum year

********************************************************************************
	
// KOMBINIEREN VON 2 DO-FILES: WEIGHTING UND MA
// ************* Moving Averages ***********************************************
/* System: 

X_neu	  1		  2		  3		  4		|	  5		  6		  7		  8
MOB		111201	120102	010203	020304	|	050607	060708	070809	080910
MOB_a	010203	020304	...
			auf letzten Monat 					auf ersten Monat averages legen
			
	- die neue X variable ist nur ein hypotheitsches Konstrukt
	- es wird mit MOB_a erstellt
	Genereller approach
	qui gen num = . 
	//Beispiel erster Punkt: 
	/*
	qui gen temp = 1 if MOB_a == 1 | MOB_a == 2 | MOB_a == 3
	qui bys control temp: egen temp2 = total(Diag_5)
	qui replace num = temp2 if MOB_a == 3 
	*/
*/	



// All variables are now on a yearly basis	

********************************************************************************
// Setup of MA variables fertility and bev
foreach 1 of varlist  bev_fert bev_mz  { // old:fert bev_fert
	foreach j in "" "f" "m"  { // columns:
		qui gen ma_`1'`j' = . 
		//erster Punkt: 
		/*
		qui gen temp = 1 if MOB_a == 1 | MOB_a == 2 | MOB_a == 3
		qui bys control temp: egen temp2 = total(Diag_5)
		qui replace num = temp2 if MOB_a == 3 
		*/
		
		//General Problem:
		*Pre-treatment
		local k = 1
		while `k' <= 4 {
			capture drop temp*
			qui gen temp = 1 if MOB_a == `k' | MOB_a == `k'+1 | MOB_a == `k'+2
			qui bys control amr_clean year temp: egen temp2 = total(`1'`j')
			qui replace ma_`1'`j' = temp2 if MOB_a == `k'+2 
			local k =`k'+1
		}
		*Post-treatment
		local k = 5
		while `k' <= 8 {
			capture drop temp*
			qui gen temp = 1 if MOB_a == `k' | MOB_a == `k'+1 | MOB_a == `k'+2
			qui bys control amr_clean year temp: egen temp2 = total(`1'`j')
			qui replace ma_`1'`j' = temp2 if MOB_a == `k'+2 
			local k =`k'+1
		}
	sort Datum year
	} // end: loop over t f m
} // end: loop over variables
drop temp*
********************************************************************************
// setup of ma variables for the outcomes: 
*male & female
foreach 1 of varlist  hospital2 d5 {
	foreach j in "" "_f" "_m"  { // columns:
		qui gen mat_`1'`j' = .  //cummulative cases (just used to build ratios)
		qui gen ma_`1'`j' = .  // average numbers -> to be depicted in scatters
		*Pre-treatment
		local k = 1
		while `k' <= 4 {
			capture drop temp*
			qui gen temp = 1 if MOB_a == `k' | MOB_a == `k'+1 | MOB_a == `k'+2
			qui bys control amr_clean year temp: egen temp2 = total(`1'`j')
			*qui bys control amr_clean year temp: egen tempX = mean(`1'`j')
			qui replace mat_`1'`j' = temp2 if MOB_a == `k'+2 
			*qui replace ma_`1'`j' = tempX  if MOB_a == `k'+2
			local k =`k'+1
		}
		*Post-treatment
		local k = 5
		while `k' <= 8 {
			capture drop temp*
			qui gen temp = 1 if MOB_a == `k' | MOB_a == `k'+1 | MOB_a == `k'+2
			qui bys control amr_clean year temp: egen temp2 = total(`1'`j')
			*qui bys control amr_clean year temp: egen tempX = mean(`1'`j')
			qui replace mat_`1'`j' = temp2 if MOB_a == `k'+2 
			*qui replace ma_`1'`j' = tempX  if MOB_a == `k'+2
			local k =`k'+1
		}
	} // end: loop over t f m
	* generate ratios 
	qui gen ma_r_popf_`1'   = mat_`1'*1000 / ma_bev_fert		// total
	qui gen ma_r_popf_`1'_f = mat_`1'_f*1000 / ma_bev_fertf		// female
	qui gen ma_r_popf_`1'_m = mat_`1'_m*1000 / ma_bev_fertm		// male
} // end: loop over variables
drop temp*
********************************************************************************
*weighting: aggregate across regional level


bys Datum year: egen denominatoryear = total(ma_bev_fert)
bys Datum year: egen denominatoryear_f = total(ma_bev_fertf)
bys Datum year: egen denominatoryear_m = total(ma_bev_fertm)

foreach 1 of varlist hospital2 {
	*total
	bys Datum year: egen nominatoryear = total(ma_r_popf_`1' * ma_bev_fert)
	bys Datum year: egen nominatoryear_f = total(ma_r_popf_`1'_f * ma_bev_fertf)
	bys Datum year: egen nominatoryear_m = total(ma_r_popf_`1'_f * ma_bev_fertm)
	foreach j in "" "_f" "_m"  { // columns:
		qui gen W_AVRGyear`j' = nominatoryear`j'/denominatoryear`j'
	} // end: gender		
	foreach X  of numlist 2003(1)2014  {				
		// for single years		
			*total		
			twoway scatter W_AVRGyear MOB_ma if treat == 1  & year == `X'& MOB_ma>=2 & MOB_ma<=11, color(black)  ///
				scheme(s1mono )  ///
				xtitle("")  ytitle("") ///
				ylabel(#5,grid) ///
				xlabel(3(2)9, val) xmtick(4(2)10) ///
				legend(off) ///
				xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) ///
				title("`X'")
				graph export "$graphs/AMR_MA_wghtd`1'_total_`X'_$date.png", replace
				*nodraw ///
				*saving($graphs/AMR_`1'_total_`X'_$date, replace)
				*saving($graphs/AMRtotal_`var'`X', replace)
	
			*female 
			twoway scatter W_AVRGyear_f MOB_ma if treat == 1& year == `X'& MOB_ma>=2 & MOB_ma<=11, color(cranberry)  ///
				scheme(s1mono )  ///
				xtitle("")  ytitle("") ///
				ylabel(#5,grid) ///
				xlabel(3(2)9, val) xmtick(4(2)10) ///
				legend(off) ///
				xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry))  ///
				title("`X'")
				graph export "$graphs/AMR_MA_wghtd`1'_female_`X'_$date.png", replace
				*nodraw ///
				*saving($graphs/AMR_`1'_female_`X'_$date, replace)
				*saving($graphs/AMRfemale_`var'`X', replace)
				
			*male	
			twoway scatter W_AVRGyear_m MOB_ma if treat == 1 & year == `X'& MOB_ma>=2 & MOB_ma<=11, color(navy)  ///
				scheme(s1mono )  ///
				xtitle("")  ytitle("") ///
				ylabel(#5,grid) ///
				xlabel(3(2)9, val) xmtick(4(2)10) ///
				legend(off) ///
				xline(6.5, lw(medthick ) lpattern(solid) lcolor(cranberry)) ///
				title("`X'")
				graph export "$graphs/AMR_MA_wghtd`1'_male_`X'_$date.png", replace
				*nodraw ///
				*saving($graphs/AMR_`1'_male_`X'_$date, replace)
				*	saving($graphs/AMRmale_`var'`X', replace)
		} // end: list 2003 and 2014
		/*graph combine   "$graphs/AMRtotal_r_popf_2014.gph"	"$graphs/AMRfemale_r_popf_2014.gph"	"$graphs/AMRmale_r_popf_2014.gph", altshrink ///
				  title(LC: per gender) subtitle("$`1'")   ///
				  t1title("total              		female              		male") ///
				  scheme(s1mono)*/
} // end: varlist
********************************************************

 
