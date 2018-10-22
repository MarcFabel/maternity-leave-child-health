

version 14 

*********************************************************************************************************
// Wie man am GWAP die Ergebnisse vom LC am besten ausgegebn lassen bekommt

capture program drop DDRD_lc
	program define DDRD_lc
		qui  reg `1' treat after TxA   `2'  `3', vce(cluster MxY) 
	end

	
	
	*use "$temp\KKH_final_R1", clear	
use ${temp}/KKH_final_gdr_level, clear
run "auxiliary_varlists_varnames_sample-spcifications"	
	
preserve 	
	keep if GDR == 0 		
			
	foreach 1 of varlist $fifth_chapter { // $fifth_chapter
		* initiate matrix
		mat A = J(1,23,.)
		esttab m(A) using "$tables/`1'_lc_yrs_brckts.csv", ///
			collabels(year beta se observations Rsq diagnoses mean pct_sd ///
				beta_f se_f observations_f Rsq_f diagnoses_f mean_f pct_sd_f ///
				beta_m se_m observations_m Rsq_m diagnoses_m mean_m pct_sd_m ///
				bandwidth) ///
			keep() nomtitles replace nomtitles 
		
		qui summ year_treat if !missing(r_fert_`1') & treat == 1
		local start = r(min) + 1	// to have both cohorts available at the same age
		local ende = r(max)
		local numberofrows = `ende' - `start' +1	// local that contains the number of years for the lifecourse -> set up matrix with right dimension
		
		foreach bandwidth in "$M2" "$M4" "$M6" "$MD" {
			*generate column vectors/scalars that contain the current BW
			if "`bandwidth'" == "$M2" {
				mat vBW = J(`numberofrows',1,2) // rows of lifecourse + 2 extra rows for different specifications of total 
				scalar sBW = 2
			}
			if "`bandwidth'" == "$M4" {
				mat vBW = J(`numberofrows',1,4) 
				scalar sBW = 4
			}
			if "`bandwidth'" == "$M6" {
				mat vBW = J(`numberofrows',1,6)
				scalar sBW = 6
			}
			if "`bandwidth'" == "$MD" {
				mat vBW = J(`numberofrows',1,99) // introduce label for donut 99
				scalar sBW = 99
			}
			****************************************************************************************
			*overall effects (for LC time frame) 
			mat A = J(1,22,.)
			DDRD_lc  r_fert_`1' "i.MOB i.year"  " if (year_treat >= `start' & year_treat <= `ende') & $C2 & `bandwidth'"
			matrix temp = e(b) 								// make copy of estimate vector (Row vector) 
			matrix tempV = e(V) 							// make copy of VC matrix 
			mat A[1,1] = -99								// introduce labels: overall (LC length)
			mat A[1,2] = round(temp[1,3],.00001) 			// copy point estimate to plotted matrix
			mat A[1,3] = round(sqrt(tempV[3,3]),.00001)		// copy se to plotted matrix 
			mat A[1,4] = e(N)								// transfer number of observations
			mat A[1,5] = round(e(r2_a),.00001)				// copy adjusted R-squared
			capture drop Dinregression sum_num_diagnoses
			qui gen Dinregression = 1 if cond(e(sample),1,0)
			bys Dinregression: egen sum_num_diagnoses = total(`1')
			qui summ sum_num_diagnoses if e(sample)
			qui estadd scalar num_diag = `r(mean)'
			mat A[1,6] = e(num_diag) 		// number of involved diagnoses
			qui sum r_fert_`1' if e(sample) & treat == 1 & after == 0	// mean and % standard deviation of pretreatment affected cohort
			mat A[1,7] = round(`r(mean)',.001)
			mat A[1,8] = abs(round(_b[TxA]/`r(sd)'*100,.001))			
			
			DDRD_lc  r_fert_`1'_f "i.MOB i.year"  " if (year_treat >= `start' & year_treat <= `ende') & $C2 & `bandwidth'"
			matrix temp = e(b) 								// make copy of estimate vector (Row vector) 
			matrix tempV = e(V) 							// make copy of VC matrix 
			mat A[1,9] = round(temp[1,3],.00001) 			// copy point estimate to plotted matrix
			mat A[1,10] = round(sqrt(tempV[3,3]),.00001)		// copy se to plotted matrix 
			mat A[1,11] = e(N)								// transfer number of observations
			mat A[1,12] = round(e(r2_a),.00001)				// copy adjusted R-squared
			capture drop Dinregression sum_num_diagnoses
			qui gen Dinregression = 1 if cond(e(sample),1,0)
			bys Dinregression: egen sum_num_diagnoses = total(`1'_f)
			qui summ sum_num_diagnoses if e(sample)
			qui estadd scalar num_diag = `r(mean)'
			mat A[1,13] = e(num_diag) 		// number of involved diagnoses
			qui sum r_fert_`1'_f if e(sample) & treat == 1 & after == 0
			mat A[1,14] = round(`r(mean)',.001)
			mat A[1,15] = abs(round(_b[TxA]/`r(sd)'*100,.001))
			
			DDRD_lc  r_fert_`1'_m "i.MOB i.year"  " if (year_treat >= `start' & year_treat <= `ende') & $C2 & `bandwidth'"
			matrix temp = e(b) 								// make copy of estimate vector (Row vector) 
			matrix tempV = e(V) 							// make copy of VC matrix 
			mat A[1,16] = round(temp[1,3],.00001) 			// copy point estimate to plotted matrix
			mat A[1,17] = round(sqrt(tempV[3,3]),.00001)	// copy se to plotted matrix 
			mat A[1,18] = e(N)								// transfer number of observations
			mat A[1,19] = round(e(r2_a),.00001)				// copy adjusted R-squared
			capture drop Dinregression sum_num_diagnoses
			qui gen Dinregression = 1 if cond(e(sample),1,0)
			bys Dinregression: egen sum_num_diagnoses = total(`1'_m)
			qui summ sum_num_diagnoses if e(sample)
			qui estadd scalar num_diag = `r(mean)'
			mat A[1,20] = e(num_diag) 		// number of involved diagnoses
			qui sum r_fert_`1'_m if e(sample) & treat == 1 & after == 0
			mat A[1,21] = round(`r(mean)',.001)
			mat A[1,22] = abs(round(_b[TxA]/`r(sd)'*100,.001))
			mat A = [A,sBW]									// add scalar of bandwidth
			esttab m(A) using "$tables/`1'_lc_yrs_brckts.csv", collabels(none)  plain append lz nomtitles 
			
			****************************************************************************************
			*overall effects (entire time frame
			mat A = J(1,22,.)
			
			DDRD_lc  r_fert_`1' "i.MOB i.year"  " if  $C2 & `bandwidth'"
			matrix temp = e(b) 								// make copy of estimate vector (Row vector) 
			matrix tempV = e(V) 							// make copy of VC matrix 
			mat A[1,1] = -98								// introduce labels: overall (all years)
			mat A[1,2] = round(temp[1,3],.00001) 			// copy point estimate to plotted matrix
			mat A[1,3] = round(sqrt(tempV[3,3]),.00001)		// copy se to plotted matrix 
			mat A[1,4] = e(N)								// transfer number of observations
			mat A[1,5] = round(e(r2_a),.00001)				// copy adjusted R-squared
			capture drop Dinregression sum_num_diagnoses
			qui gen Dinregression = 1 if cond(e(sample),1,0)
			bys Dinregression: egen sum_num_diagnoses = total(`1')
			qui summ sum_num_diagnoses if e(sample)
			qui estadd scalar num_diag = `r(mean)'
			mat A[1,6] = e(num_diag) 		// number of involved diagnoses
			qui sum r_fert_`1' if e(sample) & treat == 1 & after == 0	// mean and % standard deviation of pretreatment affected cohort
			mat A[1,7] = round(`r(mean)',.001)
			mat A[1,8] = abs(round(_b[TxA]/`r(sd)'*100,.001))
			
			DDRD_lc  r_fert_`1'_f "i.MOB i.year"  " if  $C2 & `bandwidth'"
			matrix temp = e(b) 								// make copy of estimate vector (Row vector) 
			matrix tempV = e(V) 							// make copy of VC matrix 
			mat A[1,9] = round(temp[1,3],.00001) 			// copy point estimate to plotted matrix
			mat A[1,10] = round(sqrt(tempV[3,3]),.00001)		// copy se to plotted matrix 
			mat A[1,11] = e(N)								// transfer number of observations
			mat A[1,12] = round(e(r2_a),.00001)				// copy adjusted R-squared
			capture drop Dinregression sum_num_diagnoses
			qui gen Dinregression = 1 if cond(e(sample),1,0)
			bys Dinregression: egen sum_num_diagnoses = total(`1'_f)
			qui summ sum_num_diagnoses if e(sample)
			qui estadd scalar num_diag = `r(mean)'
			mat A[1,13] = e(num_diag) 		// number of involved diagnoses
			qui sum r_fert_`1'_f if e(sample) & treat == 1 & after == 0
			mat A[1,14] = round(`r(mean)',.001)
			mat A[1,15] = abs(round(_b[TxA]/`r(sd)'*100,.001))
			
			DDRD_lc  r_fert_`1'_m "i.MOB i.year"  " if  $C2 & `bandwidth'"
			matrix temp = e(b) 								// make copy of estimate vector (Row vector) 
			matrix tempV = e(V) 							// make copy of VC matrix 
			mat A[1,16] = round(temp[1,3],.00001) 			// copy point estimate to plotted matrix
			mat A[1,17] = round(sqrt(tempV[3,3]),.00001)	// copy se to plotted matrix 
			mat A[1,18] = e(N)								// transfer number of observations
			mat A[1,19] = round(e(r2_a),.00001)				// copy adjusted R-squared
			capture drop Dinregression sum_num_diagnoses
			qui gen Dinregression = 1 if cond(e(sample),1,0)
			bys Dinregression: egen sum_num_diagnoses = total(`1'_m)
			qui summ sum_num_diagnoses if e(sample)
			qui estadd scalar num_diag = `r(mean)'
			mat A[1,20] = e(num_diag) 		// number of involved diagnoses
			qui sum r_fert_`1'_m if e(sample) & treat == 1 & after == 0
			mat A[1,21] = round(`r(mean)',.001)
			mat A[1,22] = abs(round(_b[TxA]/`r(sd)'*100,.001))
			mat A = [A,sBW]
			esttab m(A) using "$tables/`1'_lc_yrs_brckts.csv", collabels(none)  plain append lz nomtitles 
			
			****************************************************************************************
			* life-course 
			local iter = 1
			mat A = J(`numberofrows',22,.)	// empty matrix with the right dimensions
			
			foreach year of numlist `start' (1) `ende' { 
				*total
				DDRD_lc  r_fert_`1' "i.MOB "  " if year_treat == `year' & $C2 & `bandwidth'"
				matrix temp = e(b) 									// make copy of estimate vector (Row vector) 
				matrix tempV = e(V) 								// make copy of VC matrix 
				mat A[`iter',1] = `year'
				mat A[`iter',2] = round(temp[1,3],.00001) 			// copy point estimate to plotted matrix
				mat A[`iter',3] = round(sqrt(tempV[3,3]),.00001)	// copy se to plotted matrix 
				mat A[`iter',4] = e(N)								// transfer number of observations
				mat A[`iter',5] = round(e(r2_a),.00001)				// copy adjusted R-squared
				capture drop Dinregression sum_num_diagnoses
				qui gen Dinregression = 1 if cond(e(sample),1,0)
				bys Dinregression: egen sum_num_diagnoses = total(`1')
				qui summ sum_num_diagnoses if e(sample)
				qui estadd scalar num_diag = `r(mean)'
				mat A[`iter',6] = e(num_diag) 		// number of involved diagnoses
				qui sum r_fert_`1' if e(sample) & treat == 1 & after == 0	// mean and % standard deviation of pretreatment affected cohort
				mat A[`iter',7] = round(`r(mean)',.001)
				mat A[`iter',8] = abs(round(_b[TxA]/`r(sd)'*100,.001))
				
				*female 
				DDRD_lc  r_fert_`1'_f "i.MOB "  " if year_treat == `year' & $C2 & `bandwidth'"
				matrix temp = e(b) 									// make copy of estimate vector (Row vector) 
				matrix tempV = e(V) 								// make copy of VC matrix 
				mat A[`iter',9] = round(temp[1,3],.00001) 			// copy point estimate to plotted matrix
				mat A[`iter',10] = round(sqrt(tempV[3,3]),.00001)	// copy se to plotted matrix 
				mat A[`iter',11] = e(N)								// transfer number of observations
				mat A[`iter',12] = round(e(r2_a),.00001)			// copy adjusted R-squared
				capture drop Dinregression sum_num_diagnoses
				qui gen Dinregression = 1 if cond(e(sample),1,0)
				bys Dinregression: egen sum_num_diagnoses = total(`1'_f)
				qui summ sum_num_diagnoses if e(sample)
				qui estadd scalar num_diag = `r(mean)'
				mat A[`iter',13] = e(num_diag) 		// number of involved diagnoses
				qui sum r_fert_`1'_f if e(sample) & treat == 1 & after == 0
				mat A[`iter',14] = round(`r(mean)',.001)
				mat A[`iter',15] = abs(round(_b[TxA]/`r(sd)'*100,.001))
				
				*male 
				DDRD_lc  r_fert_`1'_m "i.MOB "  " if year_treat == `year' & $C2 & `bandwidth'"
				matrix temp = e(b) 									// make copy of estimate vector (Row vector) 
				matrix tempV = e(V) 								// make copy of VC matrix 
				mat A[`iter',16] = round(temp[1,3],.00001) 			// copy point estimate to plotted matrix
				mat A[`iter',17] = round(sqrt(tempV[3,3]),.00001)	// copy se to plotted matrix 
				mat A[`iter',18] = e(N)								// transfer number of observations
				mat A[`iter',19] = round(e(r2_a),.00001)			// copy adjusted R-squared
				capture drop Dinregression sum_num_diagnoses
				qui gen Dinregression = 1 if cond(e(sample),1,0)
				bys Dinregression: egen sum_num_diagnoses = total(`1'_m)
				qui summ sum_num_diagnoses if e(sample)
				qui estadd scalar num_diag = `r(mean)'
				mat A[`iter',20] = e(num_diag) 		// number of involved diagnoses
				qui sum r_fert_`1'_m if e(sample) & treat == 1 & after == 0
				mat A[`iter',21] = round(`r(mean)',.001)
				mat A[`iter',22] = abs(round(_b[TxA]/`r(sd)'*100,.001))
				local iter = `iter' + 1				// increase iteration by one unit
				****************************************************************************************
			} // end: years over lifecourse
			mat B = [A,vBW]											// add vector of bandwidth
			esttab m(B) using "$tables/`1'_lc_yrs_brckts.csv", collabels(none)  plain append lz nomtitles 
			*matrix list A
		} // end: liste von bandwiths
************************************************************************
	// LIFE COURSE FOR AGE BRACKTES
		local numberofrows = 4	// local that contains the number of years for the lifecourse -> set up matrix with right dimension
		foreach bandwidth in "$M2" "$M4" "$M6" "$MD" {
			*generate column vectors/scalars that contain the current BW
			if "`bandwidth'" == "$M2" {
				mat vBW = J(`numberofrows',1,2) // rows of lifecourse + 2 extra rows for different specifications of total 
				scalar sBW = 2
			}
			if "`bandwidth'" == "$M4" {
				mat vBW = J(`numberofrows',1,4) 
				scalar sBW = 4
			}
			if "`bandwidth'" == "$M6" {
				mat vBW = J(`numberofrows',1,6)
				scalar sBW = 6
			}
			if "`bandwidth'" == "$MD" {
				mat vBW = J(`numberofrows',1,99) // introduce label for donut 99
				scalar sBW = 99
			}
			****************************************************************************************
			* life-course - table format 
			local iter = 1
			mat A = J(`numberofrows',22,.)	// empty matrix with the right dimensions
			foreach age_bracket in "$age_17_21" "$age_22_26" "$age_27_31" "$age_32_35" {
				*total
				DDRD_lc  r_fert_`1' "i.MOB "  " if `age_bracket' & $C2 & `bandwidth'"
				matrix temp = e(b) 									// make copy of estimate vector (Row vector) 
				matrix tempV = e(V) 								// make copy of VC matrix 
				mat A[`iter',1] = `iter'
				mat A[`iter',2] = round(temp[1,3],.00001) 			// copy point estimate to plotted matrix
				mat A[`iter',3] = round(sqrt(tempV[3,3]),.00001)	// copy se to plotted matrix 
				mat A[`iter',4] = e(N)								// transfer number of observations
				mat A[`iter',5] = round(e(r2_a),.00001)				// copy adjusted R-squared
				capture drop Dinregression sum_num_diagnoses
				qui gen Dinregression = 1 if cond(e(sample),1,0)
				bys Dinregression: egen sum_num_diagnoses = total(`1')
				qui summ sum_num_diagnoses if e(sample)
				qui estadd scalar num_diag = `r(mean)'
				mat A[`iter',6] = e(num_diag) 		// number of involved diagnoses
				qui sum r_fert_`1' if e(sample) & treat == 1 & after == 0	// mean and % standard deviation of pretreatment affected cohort
				mat A[`iter',7] = round(`r(mean)',.001)
				mat A[`iter',8] = abs(round(_b[TxA]/`r(sd)'*100,.001))
				
				*female 
				DDRD_lc  r_fert_`1'_f "i.MOB "  " if `age_bracket' & $C2 & `bandwidth'"
				matrix temp = e(b) 									// make copy of estimate vector (Row vector) 
				matrix tempV = e(V) 								// make copy of VC matrix 
				mat A[`iter',9] = round(temp[1,3],.00001) 			// copy point estimate to plotted matrix
				mat A[`iter',10] = round(sqrt(tempV[3,3]),.00001)	// copy se to plotted matrix 
				mat A[`iter',11] = e(N)								// transfer number of observations
				mat A[`iter',12] = round(e(r2_a),.00001)			// copy adjusted R-squared
				capture drop Dinregression sum_num_diagnoses
				qui gen Dinregression = 1 if cond(e(sample),1,0)
				bys Dinregression: egen sum_num_diagnoses = total(`1'_f)
				qui summ sum_num_diagnoses if e(sample)
				qui estadd scalar num_diag = `r(mean)'
				mat A[`iter',13] = e(num_diag) 		// number of involved diagnoses
				qui sum r_fert_`1'_f if e(sample) & treat == 1 & after == 0
				mat A[`iter',14] = round(`r(mean)',.001)
				mat A[`iter',15] = abs(round(_b[TxA]/`r(sd)'*100,.001))
				
				*male 
				DDRD_lc  r_fert_`1'_m "i.MOB "  " if `age_bracket' & $C2 & `bandwidth'"
				matrix temp = e(b) 									// make copy of estimate vector (Row vector) 
				matrix tempV = e(V) 								// make copy of VC matrix 
				mat A[`iter',16] = round(temp[1,3],.00001) 			// copy point estimate to plotted matrix
				mat A[`iter',17] = round(sqrt(tempV[3,3]),.00001)	// copy se to plotted matrix 
				mat A[`iter',18] = e(N)								// transfer number of observations
				mat A[`iter',19] = round(e(r2_a),.00001)			// copy adjusted R-squared
				capture drop Dinregression sum_num_diagnoses
				qui gen Dinregression = 1 if cond(e(sample),1,0)
				bys Dinregression: egen sum_num_diagnoses = total(`1'_m)
				qui summ sum_num_diagnoses if e(sample)
				qui estadd scalar num_diag = `r(mean)'
				mat A[`iter',20] = e(num_diag) 		// number of involved diagnoses
				qui sum r_fert_`1'_m if e(sample) & treat == 1 & after == 0
				mat A[`iter',21] = round(`r(mean)',.001)
				mat A[`iter',22] = abs(round(_b[TxA]/`r(sd)'*100,.001))
				local iter = `iter' + 1				// increase iteration by one unit
				****************************************************************************************
			} // end: years over lifecourse: in that instance, end of age brackets
			mat B = [A,vBW]											// add vector of bandwidth
			esttab m(B) using "$tables/`1'_lc_yrs_brckts.csv", collabels(none)  plain append lz nomtitles 
			*matrix list A
		} // end: liste von bandwiths
		
		
		************************************************************************
	} // end": varlist 
restore // end: just FRG


*********************************************************************************************************************
/*
// in Stata importieren
	import delimited "$tables\d5_lc_yrs_brckts.csv", delimiter(comma) varnames(1) stripquote(yes) case(preserve) clear 
	drop v1					// delete column that just contains the rownumber
	qui gen temp = _n
	qui drop if temp == 1	// delete empty rowd
	qui drop temp 
	qui destring, replace
	order bandwidth
	*define labels
	label define YEAR -99 "start-end" -98 "all observations" 1 "17-21 years old" 2 "22-26 years old" 3 "27-31 years old" 4 "32-35 years old"
	label val year YEAR
	label define BANDWIDTH 99 "Donut specification (exclude 2 birth months)" 
	label val bandwidth BANDWIDTH
	qui save "$tables\d5_lc_yrs_brckts" ,replace
	
/*	
Notiz an Herrn Bergmann bezüglich des Outputs: 

		Das Datenset enthält die Regressionsergbenisse für verschiedene bandbreiten
		und jahre. Es werden neben den Punktschätzern und den Standardfehlern, die 
		Anzahl der Observationen, das adjusted R-squared, die involvierten diagnosen
		und Erwartungswert und standardabweichung von der abhängigen Variable der 
		Kontrolgruppe aufgeführt. Dies geschieht seperat für alle Fälle und nach
		Geschlechtern getrennt. 
		
		Die Ergebnisse können entweder in der csv Datei oder im Stata Format 
		betrachtet werden, wobei wahrscheinlich zweiteres besser sein dürfte, da 
		ich dort labels generiert habe, die zur Vertändigung beitragen sollen. 
		Leider kann ich aus irgendeinem Grund das nicht in ein loop packen, sodass 
		man es evtl einmal für ein outcome macht um zu erkennen was gemacht wird.
*/		
		