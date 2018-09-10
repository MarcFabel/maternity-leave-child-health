
// Was noch am Landesamt gemacht werden muss 


version 14 

*********************************************************************************************************
// Wie man am GWAP die Ergebnisse vom LC am besten ausgegebn lassen bekommt

capture program drop DDRD_lc
	program define DDRD_lc
		qui  reg `1' treat after TxA   `2'  `3', vce(cluster MxY) 
	end

use ${temp}/KKH_final_amr_level, clear
run "auxiliary_varlists_varnames_sample-spcifications"	
	
preserve 	
	keep if GDR == 0 		
			
	foreach 1 of varlist $fifth_chapter { // $fifth_chapter
		* initiate matrix
		mat A = J(1,17,.)
		esttab m(A) using "$tables/`1'_amr_all_lc.csv", ///
			collabels(year beta se observations Rsq diagnoses beta_f se_f observations_f Rsq_f diagnoses_f beta_m se_m observations_m Rsq_m diagnoses_m bandwidth) ///
			keep() nomtitles replace nomtitles 
		
		qui summ year_treat if !missing(r_popf_`1') & treat == 1
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
			mat A = J(1,16,.)
			DDRD_lc  r_popf_`1' "i.MOB i.amr_clean"  " if (year_treat >= `start' & year_treat <= `ende') & $C2 & `bandwidth' [w = popweights]"
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
			
			DDRD_lc  r_popf_`1'_f "i.MOB i.amr_clean"  " if (year_treat >= `start' & year_treat <= `ende') & $C2 & `bandwidth' [w = popweights]"
			matrix temp = e(b) 								// make copy of estimate vector (Row vector) 
			matrix tempV = e(V) 							// make copy of VC matrix 
			mat A[1,7] = round(temp[1,3],.00001) 			// copy point estimate to plotted matrix
			mat A[1,8] = round(sqrt(tempV[3,3]),.00001)		// copy se to plotted matrix 
			mat A[1,9] = e(N)								// transfer number of observations
			mat A[1,10] = round(e(r2_a),.00001)				// copy adjusted R-squared
			capture drop Dinregression sum_num_diagnoses
			qui gen Dinregression = 1 if cond(e(sample),1,0)
			bys Dinregression: egen sum_num_diagnoses = total(`1'_f)
			qui summ sum_num_diagnoses if e(sample)
			qui estadd scalar num_diag = `r(mean)'
			mat A[1,11] = e(num_diag) 		// number of involved diagnoses
			
			DDRD_lc  r_popf_`1'_m "i.MOB i.amr_clean"  " if (year_treat >= `start' & year_treat <= `ende') & $C2 & `bandwidth' [w = popweights]"
			matrix temp = e(b) 								// make copy of estimate vector (Row vector) 
			matrix tempV = e(V) 							// make copy of VC matrix 
			mat A[1,12] = round(temp[1,3],.00001) 			// copy point estimate to plotted matrix
			mat A[1,13] = round(sqrt(tempV[3,3]),.00001)	// copy se to plotted matrix 
			mat A[1,14] = e(N)								// transfer number of observations
			mat A[1,15] = round(e(r2_a),.00001)				// copy adjusted R-squared
			capture drop Dinregression sum_num_diagnoses
			qui gen Dinregression = 1 if cond(e(sample),1,0)
			bys Dinregression: egen sum_num_diagnoses = total(`1'_m)
			qui summ sum_num_diagnoses if e(sample)
			qui estadd scalar num_diag = `r(mean)'
			mat A[1,16] = e(num_diag) 		// number of involved diagnoses
			mat A = [A,sBW]
			esttab m(A) using "$tables/`1'_amr_all_lc.csv", collabels(none)  plain append lz nomtitles 
			****************************************************************************************
			*overall effects (entire time frame
			mat A = J(1,16,.)
			
			DDRD_lc  r_popf_`1' "i.MOB i.amr_clean"  " if  $C2 & `bandwidth' [w = popweights]"
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
			
			DDRD_lc  r_popf_`1'_f "i.MOB i.amr_clean"  " if  $C2 & `bandwidth' [w = popweights]"
			matrix temp = e(b) 								// make copy of estimate vector (Row vector) 
			matrix tempV = e(V) 							// make copy of VC matrix 
			mat A[1,7] = round(temp[1,3],.00001) 			// copy point estimate to plotted matrix
			mat A[1,8] = round(sqrt(tempV[3,3]),.00001)		// copy se to plotted matrix 
			mat A[1,9] = e(N)								// transfer number of observations
			mat A[1,10] = round(e(r2_a),.00001)				// copy adjusted R-squared
			capture drop Dinregression sum_num_diagnoses
			qui gen Dinregression = 1 if cond(e(sample),1,0)
			bys Dinregression: egen sum_num_diagnoses = total(`1'_f)
			qui summ sum_num_diagnoses if e(sample)
			qui estadd scalar num_diag = `r(mean)'
			mat A[1,11] = e(num_diag) 		// number of involved diagnoses
			
			DDRD_lc  r_popf_`1'_m "i.MOB i.amr_clean"  " if  $C2 & `bandwidth' [w = popweights]"
			matrix temp = e(b) 								// make copy of estimate vector (Row vector) 
			matrix tempV = e(V) 							// make copy of VC matrix 
			mat A[1,12] = round(temp[1,3],.00001) 			// copy point estimate to plotted matrix
			mat A[1,13] = round(sqrt(tempV[3,3]),.00001)	// copy se to plotted matrix 
			mat A[1,14] = e(N)								// transfer number of observations
			mat A[1,15] = round(e(r2_a),.00001)				// copy adjusted R-squared
			capture drop Dinregression sum_num_diagnoses
			qui gen Dinregression = 1 if cond(e(sample),1,0)
			bys Dinregression: egen sum_num_diagnoses = total(`1'_m)
			qui summ sum_num_diagnoses if e(sample)
			qui estadd scalar num_diag = `r(mean)'
			mat A[1,16] = e(num_diag) 		// number of involved diagnoses
			mat A = [A,sBW]
			esttab m(A) using "$tables/`1'_amr_all_lc.csv", collabels(none)  plain append lz nomtitles 
			
			****************************************************************************************
			* life-course 
			local iter = 1
			mat A = J(`numberofrows',16,.)	// empty matrix with the right dimensions
			
			foreach year of numlist `start' (1) `ende' { 
				*total
				DDRD_lc  r_popf_`1' "i.MOB i.amr_clean"  " if year_treat == `year' & $C2 & `bandwidth' [w = popweights]"
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
				
				*female 
				DDRD_lc  r_popf_`1'_f "i.MOB i.amr_clean"  " if year_treat == `year' & $C2 & `bandwidth' [w = popweights]"
				matrix temp = e(b) 									// make copy of estimate vector (Row vector) 
				matrix tempV = e(V) 								// make copy of VC matrix 
				mat A[`iter',7] = round(temp[1,3],.00001) 			// copy point estimate to plotted matrix
				mat A[`iter',8] = round(sqrt(tempV[3,3]),.00001)	// copy se to plotted matrix 
				mat A[`iter',9] = e(N)								// transfer number of observations
				mat A[`iter',10] = round(e(r2_a),.00001)			// copy adjusted R-squared
				capture drop Dinregression sum_num_diagnoses
				qui gen Dinregression = 1 if cond(e(sample),1,0)
				bys Dinregression: egen sum_num_diagnoses = total(`1'_f)
				qui summ sum_num_diagnoses if e(sample)
				qui estadd scalar num_diag = `r(mean)'
				mat A[`iter',11] = e(num_diag) 		// number of involved diagnoses
				
				*male 
				DDRD_lc  r_popf_`1'_m "i.MOB i.amr_clean"  " if year_treat == `year' & $C2 & `bandwidth' [w = popweights]"
				matrix temp = e(b) 									// make copy of estimate vector (Row vector) 
				matrix tempV = e(V) 								// make copy of VC matrix 
				mat A[`iter',12] = round(temp[1,3],.00001) 			// copy point estimate to plotted matrix
				mat A[`iter',13] = round(sqrt(tempV[3,3]),.00001)	// copy se to plotted matrix 
				mat A[`iter',14] = e(N)								// transfer number of observations
				mat A[`iter',15] = round(e(r2_a),.00001)			// copy adjusted R-squared
				capture drop Dinregression sum_num_diagnoses
				qui gen Dinregression = 1 if cond(e(sample),1,0)
				bys Dinregression: egen sum_num_diagnoses = total(`1'_m)
				qui summ sum_num_diagnoses if e(sample)
				qui estadd scalar num_diag = `r(mean)'
				mat A[`iter',16] = e(num_diag) 		// number of involved diagnoses
				
				local iter = `iter' + 1				// increase iteration by one unit
				****************************************************************************************
			} // end: years over lifecourse
			mat B = [A,vBW]
			esttab m(B) using "$tables/`1'_amr_all_lc.csv", collabels(none)  plain append lz nomtitles 
			*matrix list A
		} // end: liste von bandwiths
	} // end": varlist 
restore // end: just FRG
	
*********************************************************************************************************************

// in Stata importieren
	
	import delimited "$tables\d5_amr_all_lc.csv", delimiter(comma) varnames(1) stripquote(yes) case(preserve) clear 
	drop v1					// delete column that just contains the rownumber
	qui gen temp = _n
	qui drop if temp == 1	// delete empty row
	qui drop temp 
	qui destring, replace
	
	
	
	