clear all
version 14

/*

Update: 12.06.2018 Population weights beziehen sich jetzt nur auf die jeweilige
	Altergruppe und nicht mehr auf die komplette Bevoelkerung in einem AMR
*/


********************************************************************************
		*****  Own program  *****
********************************************************************************
capture program drop DDRD
	program define DDRD
		qui eststo `1': reg `2' treat after TxA   `3'  `4', vce(cluster MxYxbula) 
	end
	
capture program drop DDRD_sclrs
	program define DDRD_sclrs
		qui eststo `1': reg `2' treat after TxA  `3'  `4', vce(cluster MxYxbula) //MxYxAMR
		qui estadd scalar Nn = e(N)
		qui sum `2' if e(sample) & treat== 1 & after == 0 
		qui estadd scalar mean = round(`r(mean)',.01)
		qui estadd scalar sd = abs(round(_b[TxA]/`r(sd)'*100,.01))
		capture drop Dinregression  sum_num_diag*
		qui gen Dinregression = 1 if cond(e(sample),1,0)
		bys Dinregression: egen sum_num_diagnoses = total(`2')
		qui summ sum_num_diagnoses if e(sample)
		qui estadd scalar num_diag = `r(mean)'
	end
	
capture program drop DDRD_p
	program define DDRD_p
		qui eststo `1': reg `2' p_treat p_after p_TxA   `3'  `4', vce(cluster MxYxbula) 
		qui estadd scalar Nn = e(N)
		qui sum `2' if e(sample) & p_treat== 1 & p_after == 0 
		qui estadd scalar mean = round(`r(mean)',.01)
		qui estadd scalar sd = abs(round(_b[p_TxA]/`r(sd)'*100,.01))
		capture drop Dinregression  sum_num_diag*
		qui gen Dinregression = 1 if cond(e(sample),1,0)
		bys Dinregression: egen sum_num_diagnoses = total(`2')
		qui summ sum_num_diagnoses if e(sample)
		qui estadd scalar num_diag = `r(mean)'
	end	
	
capture program drop DDalt
	program define DDalt
		qui eststo `1': reg `2' after FRG FxA   `3'  `4', vce(cluster MxYxbula)
		qui estadd scalar Nn = e(N)
		qui sum `2' if e(sample) & treat == 1 & after == 0
		qui estadd scalar mean = round(`r(mean)',.01)
		qui estadd scalar sd = abs(round(_b[FxA]/`r(sd)'*100,.01))		
		capture drop Dinregression sum_num_diag*
		qui gen Dinregression = 1 if cond(e(sample),1,0)
		bys Dinregression: egen sum_num_diagnoses = total(`2')
		qui summ sum_num_diagnoses if e(sample)
		qui estadd scalar num_diag = `r(mean)'
	end
	
capture program drop DDxLFP
	program define DDxLFP
	qui  eststo `1': reg `2' treat after FLFP_2001 TxA TxFLFP AxFLFP TxAxFLFP `3'  `4', vce(cluster MxYxbula) 
	end
	
capture program drop DDD
	program define DDD
		qui eststo `1': reg `2' treat after FRG TxA FxT FxA FxTxA `3' `4', vce(cluster MxYxbula)
	end
	
	

capture program drop DDD_sclrs
	program define DDD_sclrs
		qui eststo `1': reg `2' treat after FRG TxA FxT FxA FxTxA `3' `4', vce(cluster MxYxbula)
		qui estadd scalar Nn = e(N)
		qui sum `2' if e(sample) & treat == 1 & after == 0
		qui estadd scalar mean = round(`r(mean)',.01)
		qui estadd scalar sd = abs(round(_b[FxTxA]/`r(sd)'*100,.01))
		capture drop Dinregression sum_num_diag*
		qui gen Dinregression = 1 if cond(e(sample),1,0)
		bys Dinregression: egen sum_num_diagnoses = total(`2')
		qui summ sum_num_diagnoses if e(sample)
		qui estadd scalar num_diag = `r(mean)'
	end	
********************************************************************************

/* Aufbau des Do-Files
1) DD
	- 1.a) normal overview - choice of bandwidth		
	- 1.b) Placebo Version (temporally - shift entire DD setting one cohort more in the past)
	- 1.d) sample splits für heterogeneity analysis - rural/urban
	- 1.e) life course table format
	- 1.f) andere DD Spezifikation:  (FRG: X|X) vs (GDR: X| X)
	- 1.g)  DD Placebo for GDR (overview for different bandwidths)
	
2) DDD
	- overview for different bandwidths
	

	
To Discuss: 
	- level of clustering, e.g. MxYxbula -> setzt voraus dass AMR nicht Lanederuebergriefend sind, ist das der Fall?
	- all specifications are now weighted with respect to the population
	- viele 0er -> andere Schaetzverfahren
	
	
possible extensions:	
	- all weighted vs. nonweighted
	- choice of control group
	- 	
*/

********************************************************************************


	
use ${temp}/KKH_final_amr_level, clear
run "auxiliary_varlists_varnames_sample-spcifications"
sort amr_clean Datum year

*initiate file
	eststo clear 
	DDD a d5   	"i.MOB i.amr_clean" "if $C2 & $M1"
	esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", replace cells(none) nonumbers noobs nonote noline nogaps nomtitles ///
		prehead("START Document - AMR LEVEL"  "") 

********************************************************************************
* ONLY FRG!!!!!!!!!!!!
foreach 1 of varlist $fifth_chapter { // $fifth_chapter
preserve
keep if GDR == 0


// 1.a) DDRD - different bandwidths (month of birth)
	foreach j in "" { // "_f" "_m"
	// TOTAL
		eststo clear 
		*absolute numbers
		DDRD_sclrs a1 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_sclrs a2 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_sclrs a3 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_sclrs a4 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_sclrs a5 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_sclrs a6 `1'`j'   	"i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_sclrs a7 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps ///
			mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
			prehead("" "" "START `1': $`1'" "DDRD_sclrs - Overview for different bandwidths (FRG only)"  "") ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
		*ratio mz
		DDRD_sclrs c1 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_sclrs c2 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_sclrs c3 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_sclrs c4 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_sclrs c5 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_sclrs c6 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_sclrs c7 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio popul - mz") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")  
		*ratio population
		DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_sclrs c5 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_sclrs c6 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_sclrs c7 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio popul-fert") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_f"{ //  "_m"
	// FEMALE
		eststo clear 
		*absolute numbers
		DDRD_sclrs a1 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_sclrs a2 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_sclrs a3 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_sclrs a4 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_sclrs a5 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_sclrs a6 `1'`j'   	"i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_sclrs a7 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			title("WOMEN") nomtitles ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")  
		*ratio population mz
		DDRD_sclrs c1 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_sclrs c2 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_sclrs c3 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_sclrs c4 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_sclrs c5 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_sclrs c6 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_sclrs c7 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio popul - mz") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")
			
		*ratio population
		DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_sclrs c5 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_sclrs c6 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_sclrs c7 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio popul-fert") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_m" { // "" "_f" 
	// MEN
		eststo clear 
		*absolute numbers
		DDRD_sclrs a1 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_sclrs a2 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_sclrs a3 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_sclrs a4 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_sclrs a5 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_sclrs a6 `1'`j'   	"i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_sclrs a7 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline ///
			title("MEN") nomtitles nonumbers nogaps ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")  
		*ratio population MZ
		DDRD_sclrs c1 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_sclrs c2 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_sclrs c3 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_sclrs c4 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_sclrs c5 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_sclrs c6 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_sclrs c7 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio popul-mz") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")
		*ratio population
		DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_sclrs c5 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_sclrs c6 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_sclrs c7 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio popul-fert") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}

********************************************************************************	

// 1.b) DDRD PLACEBO (TEMPORAL)
	foreach j in "" { // "_f" "_m"
	// TOTAL
		eststo clear 
		*absolute numbers
		DDRD_p a1 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_p a2 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_p a3 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_p a4 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_p a5 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_p a6 `1'`j'   	"i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_p a7 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(p_TxA) coeflabels(p_TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps ///
			mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
			prehead("" "" "START `1': $`1'" "DDRD_p - PLACEBO (one cohort earlier) (FRG only)"  "") ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
		*ratio mz
		DDRD_p c1 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_p c2 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_p c3 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_p c4 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_p c5 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_p c6 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_p c7 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(p_TxA) coeflabels(p_TxA "Ratio popul - mz") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")  
		*ratio population
		DDRD_p c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_p c2 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_p c3 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_p c4 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_p c5 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_p c6 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_p c7 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(p_TxA) coeflabels(p_TxA "Ratio popul-fert") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_f"{ //  "_m"
	// FEMALE
		eststo clear 
		*absolute numbers
		DDRD_p a1 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_p a2 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_p a3 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_p a4 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_p a5 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_p a6 `1'`j'   	"i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_p a7 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(p_TxA) coeflabels(p_TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			title("WOMEN") nomtitles ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")  
		*ratio population mz
		DDRD_p c1 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_p c2 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_p c3 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_p c4 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_p c5 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_p c6 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_p c7 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(p_TxA) coeflabels(p_TxA "Ratio popul - mz") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")
			
		*ratio population
		DDRD_p c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_p c2 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_p c3 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_p c4 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_p c5 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_p c6 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_p c7 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(p_TxA) coeflabels(p_TxA "Ratio popul-fert") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_m" { // "" "_f" 
	// MEN
		eststo clear 
		*absolute numbers
		DDRD_p a1 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_p a2 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_p a3 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_p a4 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_p a5 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_p a6 `1'`j'   	"i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_p a7 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(p_TxA) coeflabels(p_TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline ///
			title("MEN") nomtitles nonumbers nogaps ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")  
		*ratio population MZ
		DDRD_p c1 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_p c2 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_p c3 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_p c4 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_p c5 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_p c6 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_p c7 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(p_TxA) coeflabels(p_TxA "Ratio popul-mz") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")
		*ratio population
		DDRD_p c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_p c2 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_p c3 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_p c4 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_p c5 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_p c6 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_p c7 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(p_TxA) coeflabels(p_TxA "Ratio popul-fert") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
				

********************************************************************************
//1.c) DD - sample split according to rural/urban
	foreach j in "" { // "_f" "_m"
	// TOTAL
		eststo clear 
		*absolute numbers
		DDRD_sclrs a1 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs a2 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M4  [w = popweights]"
		DDRD_sclrs a3 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2  [w = popweights]"
		DDRD_sclrs a4 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $MD [w = popweights]"
		DDRD_sclrs a5 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs a6 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs a7 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 [w = popweights]"
		DDRD_sclrs a8 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $MD [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote nogaps noline ///
			mtitles("2M" "4M" "6M" "Donut" "2M" "4M" "6M" "Donut") ///
			mgroups("Rural" "Urban", pattern(1 0 0 0 1 0 0 0)) /// 
			prehead("" "" "" "`1'"  "DD - HETEROGENEITY analysis (RURAL vs. URBAN) (FRG only)"  "") ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
		*ratio population MZ
		DDRD_sclrs c1 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs c2 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs c3 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 [w = popweights]"
		DDRD_sclrs c4 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $MD [w = popweights]"
		DDRD_sclrs c5 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs c6 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs c7 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 [w = popweights]"
		DDRD_sclrs c8 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio popul-mz") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")
		*ratio population 
		DDRD_sclrs c1 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs c2 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs c3 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 [w = popweights]"
		DDRD_sclrs c4 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $MD [w = popweights]"
		DDRD_sclrs c5 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs c6 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs c7 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 [w = popweights]"
		DDRD_sclrs c8 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio popul-fert") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------------------------)				
	} // end: total
	foreach j in "_f" { // "_f" "_m"
	// FEMALE
		eststo clear 
		*absolute numbers
		DDRD_sclrs a1 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs a2 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs a3 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 [w = popweights]"
		DDRD_sclrs a4 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $MD [w = popweights]"
		DDRD_sclrs a5 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs a6 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs a7 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 [w = popweights]"
		DDRD_sclrs a8 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $MD [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			title("WOMEN") nomtitles			
		*ratio population MZ
		DDRD_sclrs c1 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs c2 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs c3 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 [w = popweights]"
		DDRD_sclrs c4 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $MD [w = popweights]"
		DDRD_sclrs c5 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs c6 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs c7 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 [w = popweights]"
		DDRD_sclrs c8 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio popul-mz") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")	
		*ratio population 
		DDRD_sclrs c1 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs c2 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs c3 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 [w = popweights]"
		DDRD_sclrs c4 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $MD [w = popweights]"
		DDRD_sclrs c5 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs c6 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs c7 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 [w = popweights]"
		DDRD_sclrs c8 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio popul-fert") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------------------------)				
	} // end: female
	foreach j in "_m" { // "_f" "_m"
	// MALE
		eststo clear 
		*absolute numbers
		DDRD_sclrs a1 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs a2 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs a3 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 [w = popweights]"
		DDRD_sclrs a4 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $MD [w = popweights]"
		DDRD_sclrs a5 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs a6 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs a7 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 [w = popweights]"
		DDRD_sclrs a8 `1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $MD [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			title("MEN") nomtitles			
		*ratio population MZ
		DDRD_sclrs c1 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs c2 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs c3 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 [w = popweights]"
		DDRD_sclrs c4 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $MD [w = popweights]"
		DDRD_sclrs c5 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs c6 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs c7 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 [w = popweights]"
		DDRD_sclrs c8 r_popmz_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio popul-mz") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")	
		*ratio population 
		DDRD_sclrs c1 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs c2 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs c3 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 [w = popweights]"
		DDRD_sclrs c4 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $MD [w = popweights]"
		DDRD_sclrs c5 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs c6 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs c7 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 [w = popweights]"
		DDRD_sclrs c8 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio popul-fert") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------------------------)				
	} // end: men
	
	
********************************************************************************

//  1.e) life-course table format
	foreach j in "" { // "_f" "_m"
		eststo clear 
		*absolute numbers
		DDRD_sclrs a1 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $age_17_21 [w = popweights]"
		DDRD_sclrs a2 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $age_22_26 [w = popweights]"
		DDRD_sclrs a3 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $age_27_31 [w = popweights]"
		DDRD_sclrs a4 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $age_32_35 [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nonumbers noobs nonote nogaps noline ///
			mtitles("Age 17-21" "Age 22-26" "Age 27-31" "Age 32-35" ) ///
			prehead("" "" "" """`1'" "DD - life-course (FRG only)" "") ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			posthead("--------------------------------------------------------------------------------------" "TOTAL")
		*ratio population MZ
		*DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_17_21 [w = popweights]"
		DDRD_sclrs c2 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_22_26 [w = popweights]"
		DDRD_sclrs c3 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_27_31 [w = popweights]"
		DDRD_sclrs c4 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_32_35 [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Ratio popul-mz") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")
		*ratio population
		*DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_17_21 [w = popweights]"
		DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_22_26 [w = popweights]"
		DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_27_31 [w = popweights]"
		DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_32_35 [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Ratio popul-fert") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------)						
	} 
	// Women
	foreach j in "_f" { // "_f" "_m"
		eststo clear 
		*absolute numbers
		DDRD_sclrs a1 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $age_17_21 [w = popweights]"
		DDRD_sclrs a2 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $age_22_26 [w = popweights]"
		DDRD_sclrs a3 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $age_27_31 [w = popweights]"
		DDRD_sclrs a4 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $age_32_35 [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nonumbers noobs nonote nogaps noline ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			title("WOMEN") nomtitles
		*ratio population
		*DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_17_21 [w = popweights]"
		DDRD_sclrs c2 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_22_26 [w = popweights]"
		DDRD_sclrs c3 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_27_31 [w = popweights]"
		DDRD_sclrs c4 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_32_35 [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Ratio popul-mz") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")	
		*ratio population
		*DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_17_21 [w = popweights]"
		DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_22_26 [w = popweights]"
		DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_27_31 [w = popweights]"
		DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_32_35 [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Ratio popul-fert") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------)					
	}
	// MEN
	foreach j in "_m" { // "_f" "_m"
		eststo clear 
		*absolute numbers
		DDRD_sclrs a1 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $age_17_21 [w = popweights]"
		DDRD_sclrs a2 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $age_22_26 [w = popweights]"
		DDRD_sclrs a3 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $age_27_31 [w = popweights]"
		DDRD_sclrs a4 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $age_32_35 [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nonumbers noobs nonote nogaps noline ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			title("MEN") nomtitles
		*ratio population MZ
		*DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_17_21 [w = popweights]"
		DDRD_sclrs c2 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_22_26 [w = popweights]"
		DDRD_sclrs c3 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_27_31 [w = popweights]"
		DDRD_sclrs c4 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_32_35 [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Ratio popul-mz") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd") 
		*ratio population
		*DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_17_21 [w = popweights]"
		DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_22_26 [w = popweights]"
		DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_27_31 [w = popweights]"
		DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $age_32_35 [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Ratio popul-fert") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------)					
	}


				
restore // end: keep only FRG


********************************************************************************

preserve
keep if treat == 1 
// 1.f) alternative DD specification, overview bandwidth
	foreach j in "" { // "_f" "_m"
	// TOTAL
		eststo clear 
		*absolute numbers
		DDalt a1 `1'`j'   	"i.MOB i.amr_clean" "if $M1 [w = popweights]"
		DDalt a2 `1'`j'   	"i.MOB i.amr_clean" "if $M2 [w = popweights]"
		DDalt a3 `1'`j'   	"i.MOB i.amr_clean" "if $M3 [w = popweights]"
		DDalt a4 `1'`j'   	"i.MOB i.amr_clean" "if $M4 [w = popweights]"
		DDalt a5 `1'`j'   	"i.MOB i.amr_clean" "if $M5 [w = popweights]"
		DDalt a6 `1'`j'   	"i.MOB i.amr_clean" "	    [w = popweights]"
		DDalt a7 `1'`j'   	"i.MOB i.amr_clean" "if $MD [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(FxA) coeflabels(FxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps ///
			mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
			prehead("" "" "" """`1'" "ALTERNATIVE DD (CG: same birth cohort in GDR) - Overview for different bandwidths (FRG+GDR)"  "") ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
		*ratio population MZ
		DDalt c1 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if  $M1 [w = popweights]"
		DDalt c2 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if  $M2 [w = popweights]"
		DDalt c3 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if  $M3 [w = popweights]"
		DDalt c4 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if  $M4 [w = popweights]"
		DDalt c5 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if  $M5 [w = popweights]"
		DDalt c6 r_popmz_`1'`j'   "i.MOB i.amr_clean" "  	  [w = popweights]"
		DDalt c7 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if  $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(FxA) coeflabels(FxA "Ratio popul-mz") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")	
		*ratio population
		DDalt c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if  $M1 [w = popweights]"
		DDalt c2 r_popf_`1'`j'   "i.MOB i.amr_clean" "if  $M2 [w = popweights]"
		DDalt c3 r_popf_`1'`j'   "i.MOB i.amr_clean" "if  $M3 [w = popweights]"
		DDalt c4 r_popf_`1'`j'   "i.MOB i.amr_clean" "if  $M4 [w = popweights]"
		DDalt c5 r_popf_`1'`j'   "i.MOB i.amr_clean" "if  $M5 [w = popweights]"
		DDalt c6 r_popf_`1'`j'   "i.MOB i.amr_clean" "  	  [w = popweights]"
		DDalt c7 r_popf_`1'`j'   "i.MOB i.amr_clean" "if  $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(FxA) coeflabels(FxA "Ratio popul-fert") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_f"{ //  "_m"
	// FEMALE
		eststo clear 
		*absolute numbers
		DDalt a1 `1'`j'   	"i.MOB i.amr_clean" "if $M1 [w = popweights]"
		DDalt a2 `1'`j'   	"i.MOB i.amr_clean" "if $M2 [w = popweights]"
		DDalt a3 `1'`j'   	"i.MOB i.amr_clean" "if $M3 [w = popweights]"
		DDalt a4 `1'`j'   	"i.MOB i.amr_clean" "if $M4 [w = popweights]"
		DDalt a5 `1'`j'   	"i.MOB i.amr_clean" "if $M5 [w = popweights]"
		DDalt a6 `1'`j'   	"i.MOB i.amr_clean" "		[w = popweights]"
		DDalt a7 `1'`j'   	"i.MOB i.amr_clean" "if $MD [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(FxA) coeflabels(FxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			title("WOMEN") nomtitles 
			*mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") 
		*ratio population MZ
		DDalt c1 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $M1 [w = popweights]"
		DDalt c2 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $M2 [w = popweights]"
		DDalt c3 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $M3 [w = popweights]"
		DDalt c4 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $M4 [w = popweights]"
		DDalt c5 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $M5 [w = popweights]"
		DDalt c6 r_popmz_`1'`j'   "i.MOB i.amr_clean" "		 [w = popweights]"
		DDalt c7 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(FxA) coeflabels(FxA "Ratio popul-mz") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd") 	
		*ratio population
		DDalt c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $M1 [w = popweights]"
		DDalt c2 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $M2 [w = popweights]"
		DDalt c3 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $M3 [w = popweights]"
		DDalt c4 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $M4 [w = popweights]"
		DDalt c5 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $M5 [w = popweights]"
		DDalt c6 r_popf_`1'`j'   "i.MOB i.amr_clean" "		 [w = popweights]"
		DDalt c7 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(FxA) coeflabels(FxA "Ratio popul-fert") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_m" { // "" "_f" 
	// MEN
		eststo clear 
		*absolute numbers
		DDalt a1 `1'`j'   	"i.MOB i.amr_clean" "if $M1 [w = popweights]"
		DDalt a2 `1'`j'   	"i.MOB i.amr_clean" "if $M2 [w = popweights]"
		DDalt a3 `1'`j'   	"i.MOB i.amr_clean" "if $M3 [w = popweights]"
		DDalt a4 `1'`j'   	"i.MOB i.amr_clean" "if $M4 [w = popweights]"
		DDalt a5 `1'`j'   	"i.MOB i.amr_clean" "if $M5 [w = popweights]"
		DDalt a6 `1'`j'   	"i.MOB i.amr_clean" "		[w = popweights]"
		DDalt a7 `1'`j'   	"i.MOB i.amr_clean" "if $MD [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(FxA) coeflabels(FxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			title("MEN") nomtitles nonumbers nogaps
		*ratio population MZ
		DDalt c1 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $M1 [w = popweights]"
		DDalt c2 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $M2 [w = popweights]"
		DDalt c3 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $M3 [w = popweights]"
		DDalt c4 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $M4 [w = popweights]"
		DDalt c5 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $M5 [w = popweights]"
		DDalt c6 r_popmz_`1'`j'   "i.MOB i.amr_clean" "		[w = popweights]"
		DDalt c7 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(FxA) coeflabels(FxA "Ratio popul-mz") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")	
		*ratio population
		DDalt c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $M1 [w = popweights]"
		DDalt c2 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $M2 [w = popweights]"
		DDalt c3 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $M3 [w = popweights]"
		DDalt c4 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $M4 [w = popweights]"
		DDalt c5 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $M5 [w = popweights]"
		DDalt c6 r_popf_`1'`j'   "i.MOB i.amr_clean" "		[w = popweights]"
		DDalt c7 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(FxA) coeflabels(FxA "Ratio popul-fert") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}				
restore	// end:restore just treat == 1



********************************************************************************
// 1.g) GDR Placebo			
preserve
keep if GDR == 1

	foreach j in "" { // "_f" "_m"
	// TOTAL
		eststo clear 
		*absolute numbers
		DDRD_sclrs a1 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_sclrs a2 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_sclrs a3 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_sclrs a4 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_sclrs a5 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_sclrs a6 `1'`j'   	"i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_sclrs a7 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps ///
			mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
			prehead("" "" "" "" "`1'" "DD - GDR placebo"  "") ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")	
		*ratio population MZ
		DDRD_sclrs c1 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_sclrs c2 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_sclrs c3 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_sclrs c4 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_sclrs c5 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_sclrs c6 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_sclrs c7 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio popul-mz") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")	
		*ratio population
		DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_sclrs c5 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_sclrs c6 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_sclrs c7 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio popul-fert") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_f"{ //  "_m"
	// FEMALE
		eststo clear 
		*absolute numbers
		DDRD_sclrs a1 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_sclrs a2 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_sclrs a3 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_sclrs a4 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_sclrs a5 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_sclrs a6 `1'`j'   	"i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_sclrs a7 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			title("WOMEN") nomtitles 
			*mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") 
		*ratio population MZ
		DDRD_sclrs c1 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_sclrs c2 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_sclrs c3 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_sclrs c4 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_sclrs c5 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_sclrs c6 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_sclrs c7 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio popul-mz") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")		
		*ratio population
		DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_sclrs c5 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_sclrs c6 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_sclrs c7 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio popul-fert") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_m" { // "" "_f" 
	// MEN
		eststo clear 
		*absolute numbers
		DDRD_sclrs a1 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_sclrs a2 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_sclrs a3 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_sclrs a4 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_sclrs a5 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_sclrs a6 `1'`j'   	"i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_sclrs a7 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			title("MEN") nomtitles nonumbers nogaps	
		*ratio population MZ
		DDRD_sclrs c1 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_sclrs c2 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_sclrs c3 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_sclrs c4 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_sclrs c5 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_sclrs c6 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_sclrs c7 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio popul-mz") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")	
		*ratio population
		DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDRD_sclrs c5 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDRD_sclrs c6 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDRD_sclrs c7 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio popul-fert") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	
					
restore // end: keep only GDR



********************************************************************************
// 2) triple diff
	foreach j in "" { // "_f" "_m"
	// TOTAL
		eststo clear 
		*absolute numbers
		DDD_sclrs a1 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDD_sclrs a2 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDD_sclrs a3 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDD_sclrs a4 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDD_sclrs a5 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDD_sclrs a6 `1'`j'   	"i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDD_sclrs a7 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps ///
			mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
			prehead("" "" "" """`1'" "DDD - Overview for different bandwidths (FRG+GDR)"  "") ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
		*ratio population MZ
		DDD_sclrs c1 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDD_sclrs c2 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDD_sclrs c3 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDD_sclrs c4 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDD_sclrs c5 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDD_sclrs c6 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDD_sclrs c7 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(FxTxA) coeflabels(FxTxA "Ratio popul-mz") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")	
	
		*ratio population
		DDD_sclrs c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDD_sclrs c2 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDD_sclrs c3 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDD_sclrs c4 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDD_sclrs c5 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDD_sclrs c6 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDD_sclrs c7 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(FxTxA) coeflabels(FxTxA "Ratio popul-fert") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd") ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_f"{ //  "_m"
	// FEMALE
		eststo clear 
		*absolute numbers
		DDD_sclrs a1 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDD_sclrs a2 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDD_sclrs a3 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDD_sclrs a4 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDD_sclrs a5 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDD_sclrs a6 `1'`j'   	"i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDD_sclrs a7 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			title("WOMEN") nomtitles 
			*mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") 	
		*ratio population MZ
		DDD_sclrs c1 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDD_sclrs c2 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDD_sclrs c3 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDD_sclrs c4 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDD_sclrs c5 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDD_sclrs c6 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDD_sclrs c7 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(FxTxA) coeflabels(FxTxA "Ratio popul-mz") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")
		*ratio population
		DDD_sclrs c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDD_sclrs c2 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDD_sclrs c3 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDD_sclrs c4 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDD_sclrs c5 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDD_sclrs c6 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDD_sclrs c7 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(FxTxA) coeflabels(FxTxA "Ratio popul-fert") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd") ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_m" { // "" "_f" 
	// MEN
		eststo clear 
		*absolute numbers
		DDD_sclrs a1 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDD_sclrs a2 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDD_sclrs a3 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDD_sclrs a4 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDD_sclrs a5 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDD_sclrs a6 `1'`j'   	"i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDD_sclrs a7 `1'`j'   	"i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			title("MEN") nomtitles nonumbers nogaps
		*ratio population MZ
		DDD_sclrs c1 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDD_sclrs c2 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDD_sclrs c3 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDD_sclrs c4 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDD_sclrs c5 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDD_sclrs c6 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDD_sclrs c7 r_popmz_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(FxTxA) coeflabels(FxTxA "Ratio popul-mz") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")
		*ratio population
		DDD_sclrs c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
		DDD_sclrs c2 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
		DDD_sclrs c3 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
		DDD_sclrs c4 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
		DDD_sclrs c5 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
		DDD_sclrs c6 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
		DDD_sclrs c7 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(FxTxA) coeflabels(FxTxA "Ratio popul-fert") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd") ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	//Observations
	esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			cells(none) nonote  noobs noline nomtitles nonumbers nogaps  ///
			addnotes("" "" "END: `1'" "MWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMW")									
	
} // end: varlist
********************************************************************************

	
	
	
/*
//Rumprobieren, weighting und clustering 

qui gen AMRxMxY = amr_clean * MxY
qui gen AMRXafter = amr_clean * after


eststo clear	
	qui eststo c1: reg r_popf_d5_m treat after TxA i.MOB i.amr_clean if high_FLFP == 1 & $C2 				 , vce(cluster MxY)
	qui eststo c2: reg r_popf_d5_m treat after TxA i.MOB i.amr_clean if high_FLFP == 1 & $C2  [w = popweights] , vce(cluster MxY)
	qui eststo c3: reg r_popf_d5_m treat after TxA i.MOB i.amr_clean if high_FLFP == 1 & $C2  [w = popweights] , vce(cluster AMRXafter)	
esttab c*, keep(TxA) se star(* 0.10 ** 0.05 *** 0.01)
		


		
		
		
		
	GELOESCHT	
		
		
********************************************************************************
			
//1.d) DD - sample split according to FLFP
	foreach j in "" { // "_f" "_m"
	// TOTAL
		eststo clear 
		*absolute numbers
		DDRD_sclrs a1 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs a2 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs a3 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 [w = popweights]"
		DDRD_sclrs a4 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 & $MD [w = popweights]"
		DDRD_sclrs a5 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs a6 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs a7 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 [w = popweights]"
		DDRD_sclrs a8 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 & $MD [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote nogaps noline ///
			mtitles("2M" "4M" "6M" "Donut" "2M" "4M" "6M" "Donut") ///
			mgroups("low FLFP" "high FLFP", pattern(1 0 0 0 1 0 0 0)) /// 
			prehead("" "" "" "`1'"  "DD - HETEROGENEITY analysis: FLFP (FRG only)"  "") ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
		*ratio population 
		DDRD_sclrs c1 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs c2 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs c3 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 [w = popweights]"
		DDRD_sclrs c4 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 & $MD [w = popweights]"
		DDRD_sclrs c5 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs c6 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs c7 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 [w = popweights]"
		DDRD_sclrs c8 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------------------------)				
	} // end: total
	foreach j in "_f" { // "_f" "_m"
	// FEMALE
		eststo clear 
		*absolute numbers
		DDRD_sclrs a1 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs a2 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs a3 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 [w = popweights]"
		DDRD_sclrs a4 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 & $MD [w = popweights]"
		DDRD_sclrs a5 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs a6 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs a7 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 [w = popweights]"
		DDRD_sclrs a8 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 & $MD [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			title("WOMEN") nomtitles			
			
		*ratio population 
		DDRD_sclrs c1 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs c2 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs c3 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 [w = popweights]"
		DDRD_sclrs c4 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 & $MD [w = popweights]"
		DDRD_sclrs c5 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs c6 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs c7 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 [w = popweights]"
		DDRD_sclrs c8 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------------------------)				
	} // end: female
	foreach j in "_m" { // "_f" "_m"
	// MALE
		eststo clear 
		*absolute numbers
		DDRD_sclrs a1 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs a2 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs a3 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 [w = popweights]"
		DDRD_sclrs a4 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 & $MD [w = popweights]"
		DDRD_sclrs a5 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs a6 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs a7 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 [w = popweights]"
		DDRD_sclrs a8 `1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 & $MD [w = popweights]"
		esttab a* using "$tables/amr_level_tables_clusterbula_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			title("MEN") nomtitles			
			
		*ratio population 
		DDRD_sclrs c1 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs c2 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs c3 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 [w = popweights]"
		DDRD_sclrs c4 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 0 & $C2 & $MD [w = popweights]"
		DDRD_sclrs c5 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 & $M2 [w = popweights]"
		DDRD_sclrs c6 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 & $M4 [w = popweights]"
		DDRD_sclrs c7 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 [w = popweights]"
		DDRD_sclrs c8 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_FLFP == 1 & $C2 & $MD [w = popweights]"
		esttab c* using "$tables/amr_level_tables_clusterbula_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------------------------)				
	} // end: men
		