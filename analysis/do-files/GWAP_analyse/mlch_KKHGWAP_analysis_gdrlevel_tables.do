clear all
version 14

********************************************************************************
		*****  Programs  *****
********************************************************************************
	capture program drop DDRD
	program define DDRD
		qui eststo `1': reg `2' treat after TxA   `3'  `4', vce(cluster MxY) 
	end
	
	capture program drop DDRD_sclrs
	program define DDRD_sclrs
		qui eststo `1': reg `2' treat after TxA  `3'  `4', vce(cluster MxY) 
		qui estadd scalar Nn = e(N)
		qui sum `2' if e(sample) & treat== 1 & after == 0 
		qui estadd scalar mean = round(`r(mean)',.01)
		qui estadd scalar sd = abs(round(_b[TxA]/`r(sd)'*100,.01))		
		capture drop Dinregression sum_num_diag*
		qui gen Dinregression = 1 if cond(e(sample),1,0)
		bys Dinregression: egen sum_num_diagnoses = total(`2')
		qui summ sum_num_diagnoses if e(sample)
		qui estadd scalar num_diag = `r(mean)'
	end	
	
	capture program drop DDalt
	program define DDalt
		qui eststo `1': reg `2' after FRG FxA   `3'  `4', vce(cluster MxYxFRG) 
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
	
	capture program drop DDD
	program define DDD
		qui eststo `1': reg `2' treat after FRG TxA FxT FxA FxTxA `3' `4', vce(cluster MxYxFRG)
	end
	
	capture program drop DDD_sclrs
	program define DDD_sclrs
		qui eststo `1': reg `2' treat after FRG TxA FxT FxA FxTxA `3' `4', vce(cluster MxYxFRG)
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

use "$temp/KKH_final_gdr_level", clear
qui gen MxYxFRG = MxY * FRG

run "auxiliary_varlists_varnames_sample-spcifications"
/*

Es gibt ein text file, in dem alle Ergebnisse reingeschrieben werden


Aufbau des Do-Files: 
1) DDD 
	- different bandwidths
	- choice of control group
	- life course table format
2) GDR (placebo)
	- different bandwidths
	- choice of control group
	
3) andere DD Spezifikation:  (FRG: X|X) vs (GDR: X| X)

*/

********************************************************************************

// 0) Overview for subcatgeories 	



preserve
keep if GDR == 0

*initiate file
	eststo clear 
	DDD a d5   	"i.MOB" "if $C2 & $M1"
	esttab a* using "$tables/gdr_level_tables_$date.txt", replace cells(none) nonumbers noobs nonote noline nogaps nomtitles ///
		prehead("START Document - GDR LEVEL"  "") 
		
foreach 1 of varlist $fifth_chapter { // $detailed $fifth_chapter
	foreach j in "" { // "_f" "_m"
	// TOTAL
		eststo clear 
		*absolute numbers
		DDRD_sclrs a1 `1'`j'   	"i.MOB" "if $C2 & $M1"
		DDRD_sclrs a2 `1'`j'   	"i.MOB" "if $C2 & $M2"
		DDRD_sclrs a3 `1'`j'   	"i.MOB" "if $C2 & $M3"
		DDRD_sclrs a4 `1'`j'   	"i.MOB" "if $C2 & $M4"
		DDRD_sclrs a5 `1'`j'   	"i.MOB" "if $C2 & $M5"
		DDRD_sclrs a6 `1'`j'   	"i.MOB" "if $C2"
		DDRD_sclrs a7 `1'`j'   	"i.MOB" "if $C2 & $MD"
		esttab a* using "$tables/gdr_level_tables_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps ///
			mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
			prehead("" "" "" "" "`1'" "DDRD - Overview for different bandwidths"  "") ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
			
		*ratio fertility
		DDRD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD_sclrs b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD_sclrs b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD_sclrs b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD_sclrs b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD_sclrs b6 r_fert_`1'`j'   "i.MOB" "if $C2"
		DDRD_sclrs b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab b* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   
			
		*ratio population
		DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD_sclrs c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD_sclrs c6 r_popf_`1'`j'   "i.MOB" "if $C2"
		DDRD_sclrs c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab c* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
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
		DDRD_sclrs a1 `1'`j'   	"i.MOB" "if $C2 & $M1"
		DDRD_sclrs a2 `1'`j'   	"i.MOB" "if $C2 & $M2"
		DDRD_sclrs a3 `1'`j'   	"i.MOB" "if $C2 & $M3"
		DDRD_sclrs a4 `1'`j'   	"i.MOB" "if $C2 & $M4"
		DDRD_sclrs a5 `1'`j'   	"i.MOB" "if $C2 & $M5"
		DDRD_sclrs a6 `1'`j'   	"i.MOB" "if $C2"
		DDRD_sclrs a7 `1'`j'   	"i.MOB" "if $C2 & $MD"
		esttab a* using "$tables/gdr_level_tables_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			title("WOMEN") nomtitles ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")  

			*mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") 
			
		*ratio fertility
		DDRD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD_sclrs b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD_sclrs b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD_sclrs b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD_sclrs b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD_sclrs b6 r_fert_`1'`j'   "i.MOB" "if $C2"
		DDRD_sclrs b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab b* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd") 
			
		*ratio population
		DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD_sclrs c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD_sclrs c6 r_popf_`1'`j'   "i.MOB" "if $C2"
		DDRD_sclrs c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab c* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
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
		DDRD_sclrs a1 `1'`j'   	"i.MOB" "if $C2 & $M1"
		DDRD_sclrs a2 `1'`j'   	"i.MOB" "if $C2 & $M2"
		DDRD_sclrs a3 `1'`j'   	"i.MOB" "if $C2 & $M3"
		DDRD_sclrs a4 `1'`j'   	"i.MOB" "if $C2 & $M4"
		DDRD_sclrs a5 `1'`j'   	"i.MOB" "if $C2 & $M5"
		DDRD_sclrs a6 `1'`j'   	"i.MOB" "if $C2"
		DDRD_sclrs a7 `1'`j'   	"i.MOB" "if $C2 & $MD"
		esttab a* using "$tables/gdr_level_tables_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline ///
			title("MEN") nomtitles nonumbers nogaps ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")  
			
		*ratio fertility
		DDRD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD_sclrs b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD_sclrs b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD_sclrs b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD_sclrs b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD_sclrs b6 r_fert_`1'`j'   "i.MOB" "if $C2"
		DDRD_sclrs b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab b* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd") 
			
		*ratio population
		DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD_sclrs c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD_sclrs c6 r_popf_`1'`j'   "i.MOB" "if $C2"
		DDRD_sclrs c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab c* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	} // end: men
} // end:varlist
restore


**************************************************************************************
//1) DDD



// 1.a) DDD - different bandwidths (month of birth)
foreach 1 of varlist $fifth_chapter { // $list_outcomes $fifth_chapter
	foreach j in "" { // "_f" "_m"
	// TOTAL
		eststo clear 
		*absolute numbers
		DDD_sclrs a1 `1'`j'   	"i.MOB" "if $C2 & $M1"
		DDD_sclrs a2 `1'`j'   	"i.MOB" "if $C2 & $M2"
		DDD_sclrs a3 `1'`j'   	"i.MOB" "if $C2 & $M3"
		DDD_sclrs a4 `1'`j'   	"i.MOB" "if $C2 & $M4"
		DDD_sclrs a5 `1'`j'   	"i.MOB" "if $C2 & $M5"
		DDD_sclrs a6 `1'`j'   	"i.MOB" "if $C2"
		DDD_sclrs a7 `1'`j'   	"i.MOB" "if $C2 & $MD"
		esttab a* using "$tables/gdr_level_tables_$date.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps ///
			mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
			prehead("" "" "START `1': $`1'" "DDD - Overview for different bandwidths"  "") ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
			
		*ratio fertility
		DDD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDD_sclrs b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDD_sclrs b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDD_sclrs b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDD_sclrs b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDD_sclrs b6 r_fert_`1'`j'   "i.MOB" "if $C2"
		DDD_sclrs b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab b* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline  ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   		
			
		*ratio population
		DDD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDD_sclrs c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDD_sclrs c6 r_popf_`1'`j'   "i.MOB" "if $C2"
		DDD_sclrs c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab c* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline  ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_f"{ //  "_m"
	// FEMALE
		eststo clear 
		*absolute numbers
		DDD_sclrs a1 `1'`j'   	"i.MOB" "if $C2 & $M1"
		DDD_sclrs a2 `1'`j'   	"i.MOB" "if $C2 & $M2"
		DDD_sclrs a3 `1'`j'   	"i.MOB" "if $C2 & $M3"
		DDD_sclrs a4 `1'`j'   	"i.MOB" "if $C2 & $M4"
		DDD_sclrs a5 `1'`j'   	"i.MOB" "if $C2 & $M5"
		DDD_sclrs a6 `1'`j'   	"i.MOB" "if $C2"
		DDD_sclrs a7 `1'`j'   	"i.MOB" "if $C2 & $MD"
		esttab a* using "$tables/gdr_level_tables_$date.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			title("WOMEN") nomtitles  ///
			scalars("Nn Observ" "mean mean" "sd % sd")   
			*mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") 
			
		*ratio fertility
		DDD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDD_sclrs b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDD_sclrs b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDD_sclrs b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDD_sclrs b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDD_sclrs b6 r_fert_`1'`j'   "i.MOB" "if $C2"
		DDD_sclrs b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab b* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline	 ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   	
			
		*ratio population
		DDD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDD_sclrs c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDD_sclrs c6 r_popf_`1'`j'   "i.MOB" "if $C2"
		DDD_sclrs c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab c* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline  ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_m" { // "" "_f" 
	// MEN
		eststo clear 
		*absolute numbers
		DDD_sclrs a1 `1'`j'   	"i.MOB" "if $C2 & $M1"
		DDD_sclrs a2 `1'`j'   	"i.MOB" "if $C2 & $M2"
		DDD_sclrs a3 `1'`j'   	"i.MOB" "if $C2 & $M3"
		DDD_sclrs a4 `1'`j'   	"i.MOB" "if $C2 & $M4"
		DDD_sclrs a5 `1'`j'   	"i.MOB" "if $C2 & $M5"
		DDD_sclrs a6 `1'`j'   	"i.MOB" "if $C2"
		DDD_sclrs a7 `1'`j'   	"i.MOB" "if $C2 & $MD"
		esttab a* using "$tables/gdr_level_tables_$date.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline ///
			title("MEN") nomtitles nonumbers nogaps ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   
			
		*ratio fertility
		DDD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDD_sclrs b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDD_sclrs b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDD_sclrs b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDD_sclrs b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDD_sclrs b6 r_fert_`1'`j'   "i.MOB" "if $C2"
		DDD_sclrs b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab b* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline	 ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   	
			
		*ratio population
		DDD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDD_sclrs c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDD_sclrs c6 r_popf_`1'`j'   "i.MOB" "if $C2"
		DDD_sclrs c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab c* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline  ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}





// 1.c) DDD - LIFECOURSE (table format)
	// TOTAL
	foreach j in "" { // "_f" "_m"
		eststo clear 
		*absolute numbers
		DDD_sclrs a1 `1'`j'   	"i.MOB" "if $C2 & $age_17_21"
		DDD_sclrs a2 `1'`j'   	"i.MOB" "if $C2 & $age_22_26"
		DDD_sclrs a3 `1'`j'   	"i.MOB" "if $C2 & $age_27_31"
		DDD_sclrs a4 `1'`j'   	"i.MOB" "if $C2 & $age_32_35"
		esttab a* using "$tables/gdr_level_tables_$date.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nonumbers noobs nonote nogaps noline ///
			mtitles("Age 17-21" "Age 22-26" "Age 27-31" "Age 32-35" ) ///
			prehead("" "" "" """`1'" "DDD_sclrs - life-course (table format)" "") ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			posthead("---------------------------------------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
		*ratio fertility
		DDD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_17_21"
		DDD_sclrs b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_22_26"
		DDD_sclrs b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_27_31"
		DDD_sclrs b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_32_35"
		esttab b* using "$tables/gdr_level_tables_$date.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")  ///
			label nomtitles nonumbers noobs nonote nogaps noline	
		*ratio population
		*DDD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_17_21"
		DDD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_22_26"
		DDD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_27_31"
		DDD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_32_35"
		esttab c* using "$tables/gdr_level_tables_$date.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")  ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)						
	} 
	// Women
	foreach j in "_f" { // "_f" "_m"
		eststo clear 
		*absolute numbers
		DDD_sclrs a1 `1'`j'   	"i.MOB" "if $C2 & $age_17_21"
		DDD_sclrs a2 `1'`j'   	"i.MOB" "if $C2 & $age_22_26"
		DDD_sclrs a3 `1'`j'   	"i.MOB" "if $C2 & $age_27_31"
		DDD_sclrs a4 `1'`j'   	"i.MOB" "if $C2 & $age_32_35"
		esttab a* using "$tables/gdr_level_tables_$date.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nonumbers noobs nonote nogaps noline ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			title("WOMEN") nomtitles
		*ratio fertility
		DDD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_17_21"
		DDD_sclrs b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_22_26"
		DDD_sclrs b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_27_31"
		DDD_sclrs b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_32_35"
		esttab b* using "$tables/gdr_level_tables_$date.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd") ///
			label nomtitles nonumbers noobs nonote nogaps noline	
		*ratio population
		*DDD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_17_21"
		DDD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_22_26"
		DDD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_27_31"
		DDD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_32_35"
		esttab c* using "$tables/gdr_level_tables_$date.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd") ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)					
	}
	// MEN
	foreach j in "_m" { // "_f" "_m"
		eststo clear 
		*absolute numbers
		DDD_sclrs a1 `1'`j'   	"i.MOB" "if $C2 & $age_17_21"
		DDD_sclrs a2 `1'`j'   	"i.MOB" "if $C2 & $age_22_26"
		DDD_sclrs a3 `1'`j'   	"i.MOB" "if $C2 & $age_27_31"
		DDD_sclrs a4 `1'`j'   	"i.MOB" "if $C2 & $age_32_35"
		esttab a* using "$tables/gdr_level_tables_$date.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nonumbers noobs nonote nogaps noline ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			title("MEN") nomtitles
		*ratio fertility
		DDD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_17_21"
		DDD_sclrs b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_22_26"
		DDD_sclrs b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_27_31"
		DDD_sclrs b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_32_35"
		esttab b* using "$tables/gdr_level_tables_$date.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd") ///
			label nomtitles nonumbers noobs nonote nogaps noline	
		*ratio population
		*DDD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_17_21"
		DDD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_22_26"
		DDD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_27_31"
		DDD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_32_35"
		esttab c* using "$tables/gdr_level_tables_$date.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd") ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)					
	}









//////////////////////////////////////////////////////////////////////////////
// 2) GDR PLACEBO

preserve
keep if GDR == 1			
********************************************************************************
// 2.a)  nach monaten
	foreach j in "" { // "_f" "_m"
	// TOTAL
		eststo clear 
		*absolute numbers
		DDRD_sclrs a1 `1'`j'   	"i.MOB" "if $C2 & $M1"
		DDRD_sclrs a2 `1'`j'   	"i.MOB" "if $C2 & $M2"
		DDRD_sclrs a3 `1'`j'   	"i.MOB" "if $C2 & $M3"
		DDRD_sclrs a4 `1'`j'   	"i.MOB" "if $C2 & $M4"
		DDRD_sclrs a5 `1'`j'   	"i.MOB" "if $C2 & $M5"
		DDRD_sclrs a6 `1'`j'   	"i.MOB" "if $C2"
		DDRD_sclrs a7 `1'`j'   	"i.MOB" "if $C2 & $MD"
		esttab a* using "$tables/gdr_level_tables_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps ///
			mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
			prehead("" "" "" "" "`1'" "DD - GDR placebo"  "") ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
			
		*ratio fertility
		DDRD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD_sclrs b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD_sclrs b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD_sclrs b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD_sclrs b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD_sclrs b6 r_fert_`1'`j'   "i.MOB" "if $C2"
		DDRD_sclrs b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab b* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
		*ratio population
		DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD_sclrs c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD_sclrs c6 r_popf_`1'`j'   "i.MOB" "if $C2"
		DDRD_sclrs c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab c* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
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
		DDRD_sclrs a1 `1'`j'   	"i.MOB" "if $C2 & $M1"
		DDRD_sclrs a2 `1'`j'   	"i.MOB" "if $C2 & $M2"
		DDRD_sclrs a3 `1'`j'   	"i.MOB" "if $C2 & $M3"
		DDRD_sclrs a4 `1'`j'   	"i.MOB" "if $C2 & $M4"
		DDRD_sclrs a5 `1'`j'   	"i.MOB" "if $C2 & $M5"
		DDRD_sclrs a6 `1'`j'   	"i.MOB" "if $C2"
		DDRD_sclrs a7 `1'`j'   	"i.MOB" "if $C2 & $MD"
		esttab a* using "$tables/gdr_level_tables_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			title("WOMEN") nomtitles 
			
		*ratio fertility
		DDRD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD_sclrs b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD_sclrs b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD_sclrs b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD_sclrs b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD_sclrs b6 r_fert_`1'`j'   "i.MOB" "if $C2"
		DDRD_sclrs b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab b* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
		*ratio population
		DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD_sclrs c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD_sclrs c6 r_popf_`1'`j'   "i.MOB" "if $C2"
		DDRD_sclrs c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab c* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
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
		DDRD_sclrs a1 `1'`j'   	"i.MOB" "if $C2 & $M1"
		DDRD_sclrs a2 `1'`j'   	"i.MOB" "if $C2 & $M2"
		DDRD_sclrs a3 `1'`j'   	"i.MOB" "if $C2 & $M3"
		DDRD_sclrs a4 `1'`j'   	"i.MOB" "if $C2 & $M4"
		DDRD_sclrs a5 `1'`j'   	"i.MOB" "if $C2 & $M5"
		DDRD_sclrs a6 `1'`j'   	"i.MOB" "if $C2"
		DDRD_sclrs a7 `1'`j'   	"i.MOB" "if $C2 & $MD"
		esttab a* using "$tables/gdr_level_tables_$date.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			title("MEN") nomtitles nonumbers nogaps
			
		*ratio fertility
		DDRD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD_sclrs b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD_sclrs b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD_sclrs b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD_sclrs b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD_sclrs b6 r_fert_`1'`j'   "i.MOB" "if $C2"
		DDRD_sclrs b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab b* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
		*ratio population
		DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD_sclrs c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD_sclrs c6 r_popf_`1'`j'   "i.MOB" "if $C2"
		DDRD_sclrs c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab c* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}

	
restore // end:only GDR		
		
		
********************************************************************************
preserve
keep if treat == 1 
// 3) alternative DD specification, overview bandwidth
	foreach j in "" { // "_f" "_m"
	// TOTAL
		eststo clear 
		*absolute numbers
		DDalt a1 `1'`j'   	"i.MOB" "if $M1"
		DDalt a2 `1'`j'   	"i.MOB" "if $M2"
		DDalt a3 `1'`j'   	"i.MOB" "if $M3"
		DDalt a4 `1'`j'   	"i.MOB" "if $M4"
		DDalt a5 `1'`j'   	"i.MOB" "if $M5"
		DDalt a6 `1'`j'   	"i.MOB" "	   "
		DDalt a7 `1'`j'   	"i.MOB" "if $MD"
		esttab a* using "$tables/gdr_level_tables_$date.txt", append  ///
			keep(FxA) coeflabels(FxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps ///
			mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
			prehead("" "" "" """`1'" "ALTERNATIVE DD (CG: same birth cohort in GDR) - Overview for different bandwidths (FRG+GDR)"  "") ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
		*ratio fertility
		DDalt b1 r_fert_`1'`j'   "i.MOB" "if  $M1"
		DDalt b2 r_fert_`1'`j'   "i.MOB" "if  $M2"
		DDalt b3 r_fert_`1'`j'   "i.MOB" "if  $M3"
		DDalt b4 r_fert_`1'`j'   "i.MOB" "if  $M4"
		DDalt b5 r_fert_`1'`j'   "i.MOB" "if  $M5"
		DDalt b6 r_fert_`1'`j'   "i.MOB" " 		 "
		DDalt b7 r_fert_`1'`j'   "i.MOB" "if  $MD"
		esttab b* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(FxA) coeflabels(FxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			label nomtitles nonumbers noobs nonote nogaps noline
		*ratio population
		DDalt c1 r_popf_`1'`j'   "i.MOB" "if  $M1"
		DDalt c2 r_popf_`1'`j'   "i.MOB" "if  $M2"
		DDalt c3 r_popf_`1'`j'   "i.MOB" "if  $M3"
		DDalt c4 r_popf_`1'`j'   "i.MOB" "if  $M4"
		DDalt c5 r_popf_`1'`j'   "i.MOB" "if  $M5"
		DDalt c6 r_popf_`1'`j'   "i.MOB" "  	 "
		DDalt c7 r_popf_`1'`j'   "i.MOB" "if  $MD"
		esttab c* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(FxA) coeflabels(FxA "Ratio population") ///
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
		DDalt a1 `1'`j'   	"i.MOB" "if $M1"
		DDalt a2 `1'`j'   	"i.MOB" "if $M2"
		DDalt a3 `1'`j'   	"i.MOB" "if $M3"
		DDalt a4 `1'`j'   	"i.MOB" "if $M4"
		DDalt a5 `1'`j'   	"i.MOB" "if $M5"
		DDalt a6 `1'`j'   	"i.MOB" "	   "
		DDalt a7 `1'`j'   	"i.MOB" "if $MD"
		esttab a* using "$tables/gdr_level_tables_$date.txt", append  ///
			keep(FxA) coeflabels(FxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			title("WOMEN") nomtitles 
			*mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") 
		*ratio fertility
		DDalt b1 r_fert_`1'`j'   "i.MOB" "if  $M1"
		DDalt b2 r_fert_`1'`j'   "i.MOB" "if  $M2"
		DDalt b3 r_fert_`1'`j'   "i.MOB" "if  $M3"
		DDalt b4 r_fert_`1'`j'   "i.MOB" "if  $M4"
		DDalt b5 r_fert_`1'`j'   "i.MOB" "if  $M5"
		DDalt b6 r_fert_`1'`j'   "i.MOB" " 		 "
		DDalt b7 r_fert_`1'`j'   "i.MOB" "if  $MD"
		esttab b* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(FxA) coeflabels(FxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			label nomtitles nonumbers noobs nonote nogaps noline	
		*ratio population
		DDalt c1 r_popf_`1'`j'   "i.MOB" "if $M1"
		DDalt c2 r_popf_`1'`j'   "i.MOB" "if $M2"
		DDalt c3 r_popf_`1'`j'   "i.MOB" "if $M3"
		DDalt c4 r_popf_`1'`j'   "i.MOB" "if $M4"
		DDalt c5 r_popf_`1'`j'   "i.MOB" "if $M5"
		DDalt c6 r_popf_`1'`j'   "i.MOB" "		"
		DDalt c7 r_popf_`1'`j'   "i.MOB" "if $MD"
		esttab c* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(FxA) coeflabels(FxA "Ratio population") ///
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
		DDalt a1 `1'`j'   	"i.MOB" "if $M1"
		DDalt a2 `1'`j'   	"i.MOB" "if $M2"
		DDalt a3 `1'`j'   	"i.MOB" "if $M3"
		DDalt a4 `1'`j'   	"i.MOB" "if $M4"
		DDalt a5 `1'`j'   	"i.MOB" "if $M5"
		DDalt a6 `1'`j'   	"i.MOB" "		"
		DDalt a7 `1'`j'   	"i.MOB" "if $MD"
		esttab a* using "$tables/gdr_level_tables_$date.txt", append  ///
			keep(FxA) coeflabels(FxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline ///
			scalars("Nn Observ" "mean mean" "sd % sd" "num_diag diagnoses")   ///
			title("MEN") nomtitles nonumbers nogaps
		*ratio fertility
		DDalt b1 r_fert_`1'`j'   "i.MOB" "if  $M1"
		DDalt b2 r_fert_`1'`j'   "i.MOB" "if  $M2"
		DDalt b3 r_fert_`1'`j'   "i.MOB" "if  $M3"
		DDalt b4 r_fert_`1'`j'   "i.MOB" "if  $M4"
		DDalt b5 r_fert_`1'`j'   "i.MOB" "if  $M5"
		DDalt b6 r_fert_`1'`j'   "i.MOB" " 		 "
		DDalt b7 r_fert_`1'`j'   "i.MOB" "if  $MD"
		esttab b* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(FxA) coeflabels(FxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			label nomtitles nonumbers noobs nonote nogaps noline	
		*ratio population
		DDalt c1 r_popf_`1'`j'   "i.MOB" "if $M1"
		DDalt c2 r_popf_`1'`j'   "i.MOB" "if $M2"
		DDalt c3 r_popf_`1'`j'   "i.MOB" "if $M3"
		DDalt c4 r_popf_`1'`j'   "i.MOB" "if $M4"
		DDalt c5 r_popf_`1'`j'   "i.MOB" "if $M5"
		DDalt c6 r_popf_`1'`j'   "i.MOB" "		"
		DDalt c7 r_popf_`1'`j'   "i.MOB" "if $MD"
		esttab c* using "$tables/gdr_level_tables_$date.txt", append ///
			keep(FxA) coeflabels(FxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes("--------------------------------------------------------------------------------------------------------------------------------------")
			
	}
	//Observations
	esttab c* using "$tables/gdr_level_tables_$date.txt", append  ///
			cells(none) nonote  noobs noline nomtitles nonumbers nogaps  ///
			addnotes("" "" "END: `1'" "MWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMW")				
restore	// end:restore just treat == 1		
********************************************************************************		
		
		
		
		
} // end: varlist



********************************************************************************	
************************		UNUSED		************************************	
********************************************************************************	
/*
// 1.b) DDD - choice of control group
	// PANEL: 2 MONTHS 
	*absolute numbers
	eststo clear
	DDD a1 `1'   "i.MOB" "if $C2    & $M2"
	DDD a2 `1'   "i.MOB" "if $C1_C2 & $M2" 
	DDD a3 `1'   "i.MOB" "if          $M2"
	DDD a4 `1'_f "i.MOB" "if $C2    & $M2"
	DDD a5 `1'_f "i.MOB" "if $C1_C2 & $M2" 
	DDD a6 `1'_f "i.MOB" "if          $M2"
	DDD a7 `1'_m "i.MOB" "if $C2    & $M2"
	DDD a8 `1'_m "i.MOB" "if $C1_C2 & $M2" 
	DDD a9 `1'_m "i.MOB" "if          $M2"
	esttab a* using "$tables/gdr_level_tables_$date.txt", append ///
		keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label  noobs nonote nogaps noline	 ///
		mtitles("T_C2" "T_C1+2" "T_C1-3" "F_C2" "F_C1+2" "F_C1-3" "M_C2" "M_C1+2" "M_C1-3") ///
		prehead("" "" "" """`1'" "DDD - overview - choice of control group" "") ///
		posthead("---------------------------------------------------------------------------------------------------------------------------------------------------------------------" "2 MONTHS")
	*Ratio fertility
	DDD c1 r_fert_`1'   "i.MOB" "if $C2    & $M2"
	DDD c2 r_fert_`1'   "i.MOB" "if $C1_C2 & $M2" 
	DDD c3 r_fert_`1'   "i.MOB" "if          $M2"
	DDD c4 r_fert_`1'_f "i.MOB" "if $C2    & $M2"
	DDD c5 r_fert_`1'_f "i.MOB" "if $C1_C2 & $M2" 
	DDD c6 r_fert_`1'_f "i.MOB" "if          $M2"
	DDD c7 r_fert_`1'_m "i.MOB" "if $C2    & $M2"
	DDD c8 r_fert_`1'_m "i.MOB" "if $C1_C2 & $M2" 
	DDD c9 r_fert_`1'_m "i.MOB" "if          $M2"
	esttab c* using "$tables/gdr_level_tables_$date.txt", append keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	*Ratio population
	DDD b1 r_popf_`1'   "i.MOB" "if $C2    & $M2"
	DDD b2 r_popf_`1'   "i.MOB" "if $C1_C2 & $M2" 
	DDD b3 r_popf_`1'   "i.MOB" "if          $M2"
	DDD b4 r_popf_`1'_f "i.MOB" "if $C2    & $M2"
	DDD b5 r_popf_`1'_f "i.MOB" "if $C1_C2 & $M2" 
	DDD b6 r_popf_`1'_f "i.MOB" "if          $M2"
	DDD b7 r_popf_`1'_m "i.MOB" "if $C2    & $M2"
	DDD b8 r_popf_`1'_m "i.MOB" "if $C1_C2 & $M2" 
	DDD b9 r_popf_`1'_m "i.MOB" "if          $M2"
	esttab b* using "$tables/gdr_level_tables_$date.txt", append keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		addnotes(---------------------------------------------------------------------------------------------------------------------------------------------------------------------)				


	// PANEL: 4 MONTHS 
	*absolute numbers
	eststo clear
	DDD a1 `1'   "i.MOB" "if $C2    & $M4"
	DDD a2 `1'   "i.MOB" "if $C1_C2 & $M4" 
	DDD a3 `1'   "i.MOB" "if          $M4"
	DDD a4 `1'_f "i.MOB" "if $C2    & $M4"
	DDD a5 `1'_f "i.MOB" "if $C1_C2 & $M4" 
	DDD a6 `1'_f "i.MOB" "if          $M4"
	DDD a7 `1'_m "i.MOB" "if $C2    & $M4"
	DDD a8 `1'_m "i.MOB" "if $C1_C2 & $M4" 
	DDD a9 `1'_m "i.MOB" "if          $M4"
	esttab a* using "$tables/gdr_level_tables_$date.txt", append keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		title("4 MONTHS")	
	*Ratio fertility
	DDD c1 r_fert_`1'   "i.MOB" "if $C2    & $M4"
	DDD c2 r_fert_`1'   "i.MOB" "if $C1_C2 & $M4" 
	DDD c3 r_fert_`1'   "i.MOB" "if          $M4"
	DDD c4 r_fert_`1'_f "i.MOB" "if $C2    & $M4"
	DDD c5 r_fert_`1'_f "i.MOB" "if $C1_C2 & $M4" 
	DDD c6 r_fert_`1'_f "i.MOB" "if          $M4"
	DDD c7 r_fert_`1'_m "i.MOB" "if $C2    & $M4"
	DDD c8 r_fert_`1'_m "i.MOB" "if $C1_C2 & $M4" 
	DDD c9 r_fert_`1'_m "i.MOB" "if          $M4"
	esttab c* using "$tables/gdr_level_tables_$date.txt", append keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	*Ratio population
	DDD b1 r_popf_`1'   "i.MOB" "if $C2    & $M4"
	DDD b2 r_popf_`1'   "i.MOB" "if $C1_C2 & $M4" 
	DDD b3 r_popf_`1'   "i.MOB" "if          $M4"
	DDD b4 r_popf_`1'_f "i.MOB" "if $C2    & $M4"
	DDD b5 r_popf_`1'_f "i.MOB" "if $C1_C2 & $M4" 
	DDD b6 r_popf_`1'_f "i.MOB" "if          $M4"
	DDD b7 r_popf_`1'_m "i.MOB" "if $C2    & $M4"
	DDD b8 r_popf_`1'_m "i.MOB" "if $C1_C2 & $M4" 
	DDD b9 r_popf_`1'_m "i.MOB" "if          $M4"
	esttab b* using "$tables/gdr_level_tables_$date.txt", append keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		addnotes(---------------------------------------------------------------------------------------------------------------------------------------------------------------------)					
	
	// PANEL: 6 MONTHS 
	*absolute numbers
	eststo clear
	DDD a1 `1'   "i.MOB" "if $C2   "
	DDD a2 `1'   "i.MOB" "if $C1_C2" 
	DDD a3 `1'   "i.MOB" "         "
	DDD a4 `1'_f "i.MOB" "if $C2   "
	DDD a5 `1'_f "i.MOB" "if $C1_C2" 
	DDD a6 `1'_f "i.MOB" "         "
	DDD a7 `1'_m "i.MOB" "if $C2   "
	DDD a8 `1'_m "i.MOB" "if $C1_C2" 
	DDD a9 `1'_m "i.MOB" "         "
	esttab a* using "$tables/gdr_level_tables_$date.txt", append keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		title("6 MONTHS")	
	
	*Ratio fertility
	DDD c1 r_fert_`1'   "i.MOB" "if $C2   "
	DDD c2 r_fert_`1'   "i.MOB" "if $C1_C2" 
	DDD c3 r_fert_`1'   "i.MOB" "         "
	DDD c4 r_fert_`1'_f "i.MOB" "if $C2   "
	DDD c5 r_fert_`1'_f "i.MOB" "if $C1_C2" 
	DDD c6 r_fert_`1'_f "i.MOB" "         "
	DDD c7 r_fert_`1'_m "i.MOB" "if $C2   "
	DDD c8 r_fert_`1'_m "i.MOB" "if $C1_C2" 
	DDD c9 r_fert_`1'_m "i.MOB" "          "
	esttab c* using "$tables/gdr_level_tables_$date.txt", append keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	*Ratio population
	DDD b1 r_popf_`1'   "i.MOB" "if $C2   "
	DDD b2 r_popf_`1'   "i.MOB" "if $C1_C2" 
	DDD b3 r_popf_`1'   "i.MOB" "         "
	DDD b4 r_popf_`1'_f "i.MOB" "if $C2   "
	DDD b5 r_popf_`1'_f "i.MOB" "if $C1_C2" 
	DDD b6 r_popf_`1'_f "i.MOB" "         "
	DDD b7 r_popf_`1'_m "i.MOB" "if $C2   "
	DDD b8 r_popf_`1'_m "i.MOB" "if $C1_C2" 
	DDD b9 r_popf_`1'_m "i.MOB" "         "
	esttab b* using "$tables/gdr_level_tables_$date.txt", append keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		addnotes(---------------------------------------------------------------------------------------------------------------------------------------------------------------------)					

	// PANEL: DONUT 
	*absolute numbers
	eststo clear
	DDD a1 `1'   "i.MOB" "if $C2    & $MD"
	DDD a2 `1'   "i.MOB" "if $C1_C2 & $MD" 
	DDD a3 `1'   "i.MOB" "if          $MD"
	DDD a4 `1'_f "i.MOB" "if $C2    & $MD"
	DDD a5 `1'_f "i.MOB" "if $C1_C2 & $MD" 
	DDD a6 `1'_f "i.MOB" "if          $MD"
	DDD a7 `1'_m "i.MOB" "if $C2    & $MD"
	DDD a8 `1'_m "i.MOB" "if $C1_C2 & $MD" 
	DDD a9 `1'_m "i.MOB" "if          $MD"
	esttab a* using "$tables/gdr_level_tables_$date.txt", append keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	///
		title("Donut")
	
	*Ratio fertility
	DDD c1 r_fert_`1'   "i.MOB" "if $C2    & $MD"
	DDD c2 r_fert_`1'   "i.MOB" "if $C1_C2 & $MD" 
	DDD c3 r_fert_`1'   "i.MOB" "if          $MD"
	DDD c4 r_fert_`1'_f "i.MOB" "if $C2    & $MD"
	DDD c5 r_fert_`1'_f "i.MOB" "if $C1_C2 & $MD" 
	DDD c6 r_fert_`1'_f "i.MOB" "if          $MD"
	DDD c7 r_fert_`1'_m "i.MOB" "if $C2    & $MD"
	DDD c8 r_fert_`1'_m "i.MOB" "if $C1_C2 & $MD" 
	DDD c9 r_fert_`1'_m "i.MOB" "if          $MD"
	esttab c* using "$tables/gdr_level_tables_$date.txt", append  ///
		keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline

	*Ratio population
	DDD b1 r_popf_`1'   "i.MOB" "if $C2    & $MD"
	DDD b2 r_popf_`1'   "i.MOB" "if $C1_C2 & $MD" 
	DDD b3 r_popf_`1'   "i.MOB" "if          $MD"
	DDD b4 r_popf_`1'_f "i.MOB" "if $C2    & $MD"
	DDD b5 r_popf_`1'_f "i.MOB" "if $C1_C2 & $MD" 
	DDD b6 r_popf_`1'_f "i.MOB" "if          $MD"
	DDD b7 r_popf_`1'_m "i.MOB" "if $C2    & $MD"
	DDD b8 r_popf_`1'_m "i.MOB" "if $C1_C2 & $MD" 
	DDD b9 r_popf_`1'_m "i.MOB" "if          $MD"
	esttab b* using "$tables/gdr_level_tables_$date.txt", append keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		addnotes(---------------------------------------------------------------------------------------------------------------------------------------------------------------------)
*/






/*
********************************************************************************
// 2.b) CHOICE OF CG	
	// PANEL: 2 MONTHS 
	*absolute numbers
	eststo clear
	DDRD a1 `1'   "i.MOB" "if $C2    & $M2"
	DDRD a2 `1'   "i.MOB" "if $C1_C2 & $M2" 
	DDRD a3 `1'   "i.MOB" "if          $M2"
	DDRD a4 `1'_f "i.MOB" "if $C2    & $M2"
	DDRD a5 `1'_f "i.MOB" "if $C1_C2 & $M2" 
	DDRD a6 `1'_f "i.MOB" "if          $M2"
	DDRD a7 `1'_m "i.MOB" "if $C2    & $M2"
	DDRD a8 `1'_m "i.MOB" "if $C1_C2 & $M2" 
	DDRD a9 `1'_m "i.MOB" "if          $M2"
	esttab a* using "$tables/gdr_level_tables_$date.txt", append ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label  noobs nonote nogaps noline	 ///
		mtitles("T_C2" "T_C1+2" "T_C1-3" "F_C2" "F_C1+2" "F_C1-3" "M_C2" "M_C1+2" "M_C1-3") ///
		prehead("" "" "" """`1'" "DD - GDR placebo - choice of control group" "") ///
		posthead("---------------------------------------------------------------------------------------------------------------------------------------------------------------------" "2 MONTHS")
	*Ratio fertility
	DDRD c1 r_fert_`1'   "i.MOB" "if $C2    & $M2"
	DDRD c2 r_fert_`1'   "i.MOB" "if $C1_C2 & $M2" 
	DDRD c3 r_fert_`1'   "i.MOB" "if          $M2"
	DDRD c4 r_fert_`1'_f "i.MOB" "if $C2    & $M2"
	DDRD c5 r_fert_`1'_f "i.MOB" "if $C1_C2 & $M2" 
	DDRD c6 r_fert_`1'_f "i.MOB" "if          $M2"
	DDRD c7 r_fert_`1'_m "i.MOB" "if $C2    & $M2"
	DDRD c8 r_fert_`1'_m "i.MOB" "if $C1_C2 & $M2" 
	DDRD c9 r_fert_`1'_m "i.MOB" "if          $M2"
	esttab c* using "$tables/gdr_level_tables_$date.txt", append keep(TxA) coeflabels(TxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	*Ratio population
	DDRD b1 r_popf_`1'   "i.MOB" "if $C2    & $M2"
	DDRD b2 r_popf_`1'   "i.MOB" "if $C1_C2 & $M2" 
	DDRD b3 r_popf_`1'   "i.MOB" "if          $M2"
	DDRD b4 r_popf_`1'_f "i.MOB" "if $C2    & $M2"
	DDRD b5 r_popf_`1'_f "i.MOB" "if $C1_C2 & $M2" 
	DDRD b6 r_popf_`1'_f "i.MOB" "if          $M2"
	DDRD b7 r_popf_`1'_m "i.MOB" "if $C2    & $M2"
	DDRD b8 r_popf_`1'_m "i.MOB" "if $C1_C2 & $M2" 
	DDRD b9 r_popf_`1'_m "i.MOB" "if          $M2"
	esttab b* using "$tables/gdr_level_tables_$date.txt", append keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		addnotes(---------------------------------------------------------------------------------------------------------------------------------------------------------------------)				


	// PANEL: 4 MONTHS 
	*absolute numbers
	eststo clear
	DDRD a1 `1'   "i.MOB" "if $C2    & $M4"
	DDRD a2 `1'   "i.MOB" "if $C1_C2 & $M4" 
	DDRD a3 `1'   "i.MOB" "if          $M4"
	DDRD a4 `1'_f "i.MOB" "if $C2    & $M4"
	DDRD a5 `1'_f "i.MOB" "if $C1_C2 & $M4" 
	DDRD a6 `1'_f "i.MOB" "if          $M4"
	DDRD a7 `1'_m "i.MOB" "if $C2    & $M4"
	DDRD a8 `1'_m "i.MOB" "if $C1_C2 & $M4" 
	DDRD a9 `1'_m "i.MOB" "if          $M4"
	esttab a* using "$tables/gdr_level_tables_$date.txt", append keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		title("4 MONTHS")	
	*Ratio fertility
	DDRD c1 r_fert_`1'   "i.MOB" "if $C2    & $M4"
	DDRD c2 r_fert_`1'   "i.MOB" "if $C1_C2 & $M4" 
	DDRD c3 r_fert_`1'   "i.MOB" "if          $M4"
	DDRD c4 r_fert_`1'_f "i.MOB" "if $C2    & $M4"
	DDRD c5 r_fert_`1'_f "i.MOB" "if $C1_C2 & $M4" 
	DDRD c6 r_fert_`1'_f "i.MOB" "if          $M4"
	DDRD c7 r_fert_`1'_m "i.MOB" "if $C2    & $M4"
	DDRD c8 r_fert_`1'_m "i.MOB" "if $C1_C2 & $M4" 
	DDRD c9 r_fert_`1'_m "i.MOB" "if          $M4"
	esttab c* using "$tables/gdr_level_tables_$date.txt", append keep(TxA) coeflabels(TxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	*Ratio population
	DDRD b1 r_popf_`1'   "i.MOB" "if $C2    & $M4"
	DDRD b2 r_popf_`1'   "i.MOB" "if $C1_C2 & $M4" 
	DDRD b3 r_popf_`1'   "i.MOB" "if          $M4"
	DDRD b4 r_popf_`1'_f "i.MOB" "if $C2    & $M4"
	DDRD b5 r_popf_`1'_f "i.MOB" "if $C1_C2 & $M4" 
	DDRD b6 r_popf_`1'_f "i.MOB" "if          $M4"
	DDRD b7 r_popf_`1'_m "i.MOB" "if $C2    & $M4"
	DDRD b8 r_popf_`1'_m "i.MOB" "if $C1_C2 & $M4" 
	DDRD b9 r_popf_`1'_m "i.MOB" "if          $M4"
	esttab b* using "$tables/gdr_level_tables_$date.txt", append keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		addnotes(---------------------------------------------------------------------------------------------------------------------------------------------------------------------)					
	
	// PANEL: 6 MONTHS 
	*absolute numbers
	eststo clear
	DDRD a1 `1'   "i.MOB" "if $C2   "
	DDRD a2 `1'   "i.MOB" "if $C1_C2" 
	DDRD a3 `1'   "i.MOB" "         "
	DDRD a4 `1'_f "i.MOB" "if $C2   "
	DDRD a5 `1'_f "i.MOB" "if $C1_C2" 
	DDRD a6 `1'_f "i.MOB" "         "
	DDRD a7 `1'_m "i.MOB" "if $C2   "
	DDRD a8 `1'_m "i.MOB" "if $C1_C2" 
	DDRD a9 `1'_m "i.MOB" "         "
	esttab a* using "$tables/gdr_level_tables_$date.txt", append keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		title("6 MONTHS")	
	
	*Ratio fertility
	DDRD c1 r_fert_`1'   "i.MOB" "if $C2   "
	DDRD c2 r_fert_`1'   "i.MOB" "if $C1_C2" 
	DDRD c3 r_fert_`1'   "i.MOB" "         "
	DDRD c4 r_fert_`1'_f "i.MOB" "if $C2   "
	DDRD c5 r_fert_`1'_f "i.MOB" "if $C1_C2" 
	DDRD c6 r_fert_`1'_f "i.MOB" "         "
	DDRD c7 r_fert_`1'_m "i.MOB" "if $C2   "
	DDRD c8 r_fert_`1'_m "i.MOB" "if $C1_C2" 
	DDRD c9 r_fert_`1'_m "i.MOB" "          "
	esttab c* using "$tables/gdr_level_tables_$date.txt", append keep(TxA) coeflabels(TxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline
	*Ratio population
	DDRD b1 r_popf_`1'   "i.MOB" "if $C2   "
	DDRD b2 r_popf_`1'   "i.MOB" "if $C1_C2" 
	DDRD b3 r_popf_`1'   "i.MOB" "         "
	DDRD b4 r_popf_`1'_f "i.MOB" "if $C2   "
	DDRD b5 r_popf_`1'_f "i.MOB" "if $C1_C2" 
	DDRD b6 r_popf_`1'_f "i.MOB" "         "
	DDRD b7 r_popf_`1'_m "i.MOB" "if $C2   "
	DDRD b8 r_popf_`1'_m "i.MOB" "if $C1_C2" 
	DDRD b9 r_popf_`1'_m "i.MOB" "         "
	esttab b* using "$tables/gdr_level_tables_$date.txt", append keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		addnotes(---------------------------------------------------------------------------------------------------------------------------------------------------------------------)					

	// PANEL: DONUT 
	*absolute numbers
	eststo clear
	DDRD a1 `1'   "i.MOB" "if $C2    & $MD"
	DDRD a2 `1'   "i.MOB" "if $C1_C2 & $MD" 
	DDRD a3 `1'   "i.MOB" "if          $MD"
	DDRD a4 `1'_f "i.MOB" "if $C2    & $MD"
	DDRD a5 `1'_f "i.MOB" "if $C1_C2 & $MD" 
	DDRD a6 `1'_f "i.MOB" "if          $MD"
	DDRD a7 `1'_m "i.MOB" "if $C2    & $MD"
	DDRD a8 `1'_m "i.MOB" "if $C1_C2 & $MD" 
	DDRD a9 `1'_m "i.MOB" "if          $MD"
	esttab a* using "$tables/gdr_level_tables_$date.txt", append keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	///
		title("Donut")
	
	*Ratio fertility
	DDRD c1 r_fert_`1'   "i.MOB" "if $C2    & $MD"
	DDRD c2 r_fert_`1'   "i.MOB" "if $C1_C2 & $MD" 
	DDRD c3 r_fert_`1'   "i.MOB" "if          $MD"
	DDRD c4 r_fert_`1'_f "i.MOB" "if $C2    & $MD"
	DDRD c5 r_fert_`1'_f "i.MOB" "if $C1_C2 & $MD" 
	DDRD c6 r_fert_`1'_f "i.MOB" "if          $MD"
	DDRD c7 r_fert_`1'_m "i.MOB" "if $C2    & $MD"
	DDRD c8 r_fert_`1'_m "i.MOB" "if $C1_C2 & $MD" 
	DDRD c9 r_fert_`1'_m "i.MOB" "if          $MD"
	esttab c* using "$tables/gdr_level_tables_$date.txt", append  ///
		keep(TxA) coeflabels(TxA "Ratio fertility") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline

	*Ratio population
	DDRD b1 r_popf_`1'   "i.MOB" "if $C2    & $MD"
	DDRD b2 r_popf_`1'   "i.MOB" "if $C1_C2 & $MD" 
	DDRD b3 r_popf_`1'   "i.MOB" "if          $MD"
	DDRD b4 r_popf_`1'_f "i.MOB" "if $C2    & $MD"
	DDRD b5 r_popf_`1'_f "i.MOB" "if $C1_C2 & $MD" 
	DDRD b6 r_popf_`1'_f "i.MOB" "if          $MD"
	DDRD b7 r_popf_`1'_m "i.MOB" "if $C2    & $MD"
	DDRD b8 r_popf_`1'_m "i.MOB" "if $C1_C2 & $MD" 
	DDRD b9 r_popf_`1'_m "i.MOB" "if          $MD"
	esttab b* using "$tables/gdr_level_tables_$date.txt", append keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		addnotes("---------------------------------------------------------------------------------------------------------------------------------------------------------------------")
*/	
