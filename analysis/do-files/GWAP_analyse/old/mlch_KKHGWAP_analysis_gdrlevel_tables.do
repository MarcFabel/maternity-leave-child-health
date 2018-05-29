clear all

********************************************************************************
		*****  Own program  *****
********************************************************************************
	capture program drop DDRD
	program define DDRD
		qui eststo `1': reg `2' treat after TxA   `3'  `4', vce(cluster MxY) 
	end
	
	capture program drop DDalt
	program define DDalt
		qui eststo `1': reg `2' after FRG FxA   `3'  `4', vce(cluster MxYxFRG) 
	end
	
	capture program drop DDD
	program define DDD
		qui eststo `1': reg `2' treat after FRG TxA FxT FxA FxTxA `3' `4', vce(cluster MxYxFRG)
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
*initiate file
	eststo clear 
	DDD a d5   	"i.MOB" "if $C2 & $M1"
	esttab a* using "$tables/gdr_level_tables.txt", replace cells(none) nonumbers noobs nonote noline nogaps nomtitles ///
		prehead("START Document - GDR LEVEL"  "") 

********************************************************************************

// 0) Overview for subcatgeories 	
#delimit ;
global detailed "	
	diabetis 
	hypertension
	ischemic 
	adipositas
	lung_infect
	pneumonia
	lung_chron 
	asthma 
	intestine_infec
	leukemia 
	shizophrenia 
	affective
	neurosis 
	personality 
	childhood 
	ear
	otitis_media
	
	symp_circ_resp
	symp_digest";
#delimit cr


preserve
keep if GDR == 0

*initiate file
	eststo clear 
	DDD a d5   	"i.MOB" "if $C2 & $M1"
	esttab a* using "$tables/gdr_level_tables.txt", replace cells(none) nonumbers noobs nonote noline nogaps nomtitles ///
		prehead("START Document - GDR LEVEL"  "") 
		
foreach 1 of varlist $detailed { // $list_outcomes
	foreach j in "" { // "_f" "_m"
	// TOTAL
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if $C2 & $M1"
		DDRD a2 `1'`j'   	"i.MOB" "if $C2 & $M2"
		DDRD a3 `1'`j'   	"i.MOB" "if $C2 & $M3"
		DDRD a4 `1'`j'   	"i.MOB" "if $C2 & $M4"
		DDRD a5 `1'`j'   	"i.MOB" "if $C2 & $M5"
		DDRD a6 `1'`j'   	"i.MOB" "if $C2"
		DDRD a7 `1'`j'   	"i.MOB" "if $C2 & $MD"
		esttab a* using "$tables/gdr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps ///
			mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
			prehead("" "" "" "" "`1'" "DDRD - Overview for different bandwidths"  "") ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
			
		*ratio fertility
		DDRD b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD b6 r_fert_`1'`j'   "i.MOB" "if $C2"
		DDRD b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab b* using "$tables/gdr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
		*ratio population
		DDRD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD c6 r_popf_`1'`j'   "i.MOB" "if $C2"
		DDRD c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab c* using "$tables/gdr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_f"{ //  "_m"
	// FEMALE
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if $C2 & $M1"
		DDRD a2 `1'`j'   	"i.MOB" "if $C2 & $M2"
		DDRD a3 `1'`j'   	"i.MOB" "if $C2 & $M3"
		DDRD a4 `1'`j'   	"i.MOB" "if $C2 & $M4"
		DDRD a5 `1'`j'   	"i.MOB" "if $C2 & $M5"
		DDRD a6 `1'`j'   	"i.MOB" "if $C2"
		DDRD a7 `1'`j'   	"i.MOB" "if $C2 & $MD"
		esttab a* using "$tables/gdr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			title("WOMEN") nomtitles 
			*mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") 
			
		*ratio fertility
		DDRD b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD b6 r_fert_`1'`j'   "i.MOB" "if $C2"
		DDRD b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab b* using "$tables/gdr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
		*ratio population
		DDRD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD c6 r_popf_`1'`j'   "i.MOB" "if $C2"
		DDRD c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab c* using "$tables/gdr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_m" { // "" "_f" 
	// MEN
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if $C2 & $M1"
		DDRD a2 `1'`j'   	"i.MOB" "if $C2 & $M2"
		DDRD a3 `1'`j'   	"i.MOB" "if $C2 & $M3"
		DDRD a4 `1'`j'   	"i.MOB" "if $C2 & $M4"
		DDRD a5 `1'`j'   	"i.MOB" "if $C2 & $M5"
		DDRD a6 `1'`j'   	"i.MOB" "if $C2"
		DDRD a7 `1'`j'   	"i.MOB" "if $C2 & $MD"
		esttab a* using "$tables/gdr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline ///
			title("MEN") nomtitles nonumbers nogaps
			
		*ratio fertility
		DDRD b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD b6 r_fert_`1'`j'   "i.MOB" "if $C2"
		DDRD b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab b* using "$tables/gdr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
		*ratio population
		DDRD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD c6 r_popf_`1'`j'   "i.MOB" "if $C2"
		DDRD c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab c* using "$tables/gdr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	//Observations
	esttab a* using "$tables/gdr_level_tables.txt", append  ///
			cells(none) nonote noobs noline nomtitles  nogaps scalars("N Obs Abs_numb")
	esttab b* using "$tables/gdr_level_tables.txt", append  ///
			cells(none) nonote noobs noline nomtitles nonumbers nogaps scalars("N Obs R_fert")
	esttab c* using "$tables/gdr_level_tables.txt", append  ///
			cells(none) nonote  noobs noline nomtitles nonumbers nogaps scalars("N Obs R_pop") ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
} // ned:varlist
restore


**************************************************************************************
//1) DDD



// 1.a) DDD - different bandwidths (month of birth)
foreach 1 of varlist $list_outcomes { // $list_outcomes
	foreach j in "" { // "_f" "_m"
	// TOTAL
		eststo clear 
		*absolute numbers
		DDD a1 `1'`j'   	"i.MOB" "if $C2 & $M1"
		DDD a2 `1'`j'   	"i.MOB" "if $C2 & $M2"
		DDD a3 `1'`j'   	"i.MOB" "if $C2 & $M3"
		DDD a4 `1'`j'   	"i.MOB" "if $C2 & $M4"
		DDD a5 `1'`j'   	"i.MOB" "if $C2 & $M5"
		DDD a6 `1'`j'   	"i.MOB" "if $C2"
		DDD a7 `1'`j'   	"i.MOB" "if $C2 & $MD"
		esttab a* using "$tables/gdr_level_tables.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps ///
			mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
			prehead("" "" "START `1': $`1'" "DDD - Overview for different bandwidths"  "") ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
			
		*ratio fertility
		DDD b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDD b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDD b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDD b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDD b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDD b6 r_fert_`1'`j'   "i.MOB" "if $C2"
		DDD b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab b* using "$tables/gdr_level_tables.txt", append ///
			keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
		*ratio population
		DDD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDD c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDD c6 r_popf_`1'`j'   "i.MOB" "if $C2"
		DDD c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab c* using "$tables/gdr_level_tables.txt", append ///
			keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_f"{ //  "_m"
	// FEMALE
		eststo clear 
		*absolute numbers
		DDD a1 `1'`j'   	"i.MOB" "if $C2 & $M1"
		DDD a2 `1'`j'   	"i.MOB" "if $C2 & $M2"
		DDD a3 `1'`j'   	"i.MOB" "if $C2 & $M3"
		DDD a4 `1'`j'   	"i.MOB" "if $C2 & $M4"
		DDD a5 `1'`j'   	"i.MOB" "if $C2 & $M5"
		DDD a6 `1'`j'   	"i.MOB" "if $C2"
		DDD a7 `1'`j'   	"i.MOB" "if $C2 & $MD"
		esttab a* using "$tables/gdr_level_tables.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			title("WOMEN") nomtitles 
			*mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") 
			
		*ratio fertility
		DDD b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDD b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDD b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDD b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDD b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDD b6 r_fert_`1'`j'   "i.MOB" "if $C2"
		DDD b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab b* using "$tables/gdr_level_tables.txt", append ///
			keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
		*ratio population
		DDD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDD c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDD c6 r_popf_`1'`j'   "i.MOB" "if $C2"
		DDD c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab c* using "$tables/gdr_level_tables.txt", append ///
			keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_m" { // "" "_f" 
	// MEN
		eststo clear 
		*absolute numbers
		DDD a1 `1'`j'   	"i.MOB" "if $C2 & $M1"
		DDD a2 `1'`j'   	"i.MOB" "if $C2 & $M2"
		DDD a3 `1'`j'   	"i.MOB" "if $C2 & $M3"
		DDD a4 `1'`j'   	"i.MOB" "if $C2 & $M4"
		DDD a5 `1'`j'   	"i.MOB" "if $C2 & $M5"
		DDD a6 `1'`j'   	"i.MOB" "if $C2"
		DDD a7 `1'`j'   	"i.MOB" "if $C2 & $MD"
		esttab a* using "$tables/gdr_level_tables.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline ///
			title("MEN") nomtitles nonumbers nogaps
			
		*ratio fertility
		DDD b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDD b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDD b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDD b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDD b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDD b6 r_fert_`1'`j'   "i.MOB" "if $C2"
		DDD b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab b* using "$tables/gdr_level_tables.txt", append ///
			keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
		*ratio population
		DDD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDD c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDD c6 r_popf_`1'`j'   "i.MOB" "if $C2"
		DDD c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab c* using "$tables/gdr_level_tables.txt", append ///
			keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	//Observations
	esttab a* using "$tables/gdr_level_tables.txt", append  ///
			cells(none) nonote noobs noline nomtitles  nogaps scalars("N Obs Abs_numb")
	esttab b* using "$tables/gdr_level_tables.txt", append  ///
			cells(none) nonote noobs noline nomtitles nonumbers nogaps scalars("N Obs R_fert")
	esttab c* using "$tables/gdr_level_tables.txt", append  ///
			cells(none) nonote  noobs noline nomtitles nonumbers nogaps scalars("N Obs R_pop") ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				



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
	esttab a* using "$tables/gdr_level_tables.txt", append ///
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
	esttab c* using "$tables/gdr_level_tables.txt", append keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
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
	esttab b* using "$tables/gdr_level_tables.txt", append keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
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
	esttab a* using "$tables/gdr_level_tables.txt", append keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
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
	esttab c* using "$tables/gdr_level_tables.txt", append keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
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
	esttab b* using "$tables/gdr_level_tables.txt", append keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
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
	esttab a* using "$tables/gdr_level_tables.txt", append keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
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
	esttab c* using "$tables/gdr_level_tables.txt", append keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
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
	esttab b* using "$tables/gdr_level_tables.txt", append keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
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
	esttab a* using "$tables/gdr_level_tables.txt", append keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
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
	esttab c* using "$tables/gdr_level_tables.txt", append  ///
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
	esttab b* using "$tables/gdr_level_tables.txt", append keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		addnotes(---------------------------------------------------------------------------------------------------------------------------------------------------------------------)
*/


// 1.c) DDD - LIFECOURSE (table format)
	// TOTAL
	foreach j in "" { // "_f" "_m"
		eststo clear 
		*absolute numbers
		DDD a1 `1'`j'   	"i.MOB" "if $C2 & $age_17_21"
		DDD a2 `1'`j'   	"i.MOB" "if $C2 & $age_22_26"
		DDD a3 `1'`j'   	"i.MOB" "if $C2 & $age_27_31"
		DDD a4 `1'`j'   	"i.MOB" "if $C2 & $age_32_35"
		esttab a* using "$tables/gdr_level_tables.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nonumbers noobs nonote nogaps noline ///
			mtitles("Age 17-21" "Age 22-26" "Age 27-31" "Age 32-35" ) ///
			prehead("" "" "" """`1'" "DDD - life-course (table format)" "") ///
			posthead("---------------------------------------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
		*ratio fertility
		DDD b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_17_21"
		DDD b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_22_26"
		DDD b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_27_31"
		DDD b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_32_35"
		esttab b* using "$tables/gdr_level_tables.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline	
		*ratio population
		*DDD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_17_21"
		DDD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_22_26"
		DDD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_27_31"
		DDD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_32_35"
		esttab c* using "$tables/gdr_level_tables.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)						
	} 
	// Women
	foreach j in "_f" { // "_f" "_m"
		eststo clear 
		*absolute numbers
		DDD a1 `1'`j'   	"i.MOB" "if $C2 & $age_17_21"
		DDD a2 `1'`j'   	"i.MOB" "if $C2 & $age_22_26"
		DDD a3 `1'`j'   	"i.MOB" "if $C2 & $age_27_31"
		DDD a4 `1'`j'   	"i.MOB" "if $C2 & $age_32_35"
		esttab a* using "$tables/gdr_level_tables.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nonumbers noobs nonote nogaps noline ///
			title("WOMEN") nomtitles
		*ratio fertility
		DDD b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_17_21"
		DDD b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_22_26"
		DDD b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_27_31"
		DDD b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_32_35"
		esttab b* using "$tables/gdr_level_tables.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline	
		*ratio population
		*DDD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_17_21"
		DDD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_22_26"
		DDD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_27_31"
		DDD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_32_35"
		esttab c* using "$tables/gdr_level_tables.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)					
	}
	// MEN
	foreach j in "_m" { // "_f" "_m"
		eststo clear 
		*absolute numbers
		DDD a1 `1'`j'   	"i.MOB" "if $C2 & $age_17_21"
		DDD a2 `1'`j'   	"i.MOB" "if $C2 & $age_22_26"
		DDD a3 `1'`j'   	"i.MOB" "if $C2 & $age_27_31"
		DDD a4 `1'`j'   	"i.MOB" "if $C2 & $age_32_35"
		esttab a* using "$tables/gdr_level_tables.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nonumbers noobs nonote nogaps noline ///
			title("MEN") nomtitles
		*ratio fertility
		DDD b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_17_21"
		DDD b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_22_26"
		DDD b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_27_31"
		DDD b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $age_32_35"
		esttab b* using "$tables/gdr_level_tables.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline	
		*ratio population
		*DDD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_17_21"
		DDD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_22_26"
		DDD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_27_31"
		DDD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_32_35"
		esttab c* using "$tables/gdr_level_tables.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)					
	}
	//Observations
	esttab a* using "$tables/gdr_level_tables.txt", append  ///
			cells(none) nonote noobs noline nomtitles  nogaps scalars("N Obs Abs_numb")
	esttab b* using "$tables/gdr_level_tables.txt", append  ///
			cells(none) nonote noobs noline nomtitles nonumbers nogaps scalars("N Obs R_fert")
	esttab c* using "$tables/gdr_level_tables.txt", append  ///
			cells(none) nonote  noobs noline nomtitles nonumbers nogaps scalars("N Obs R_pop") ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				











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
		DDRD a1 `1'`j'   	"i.MOB" "if $C2 & $M1"
		DDRD a2 `1'`j'   	"i.MOB" "if $C2 & $M2"
		DDRD a3 `1'`j'   	"i.MOB" "if $C2 & $M3"
		DDRD a4 `1'`j'   	"i.MOB" "if $C2 & $M4"
		DDRD a5 `1'`j'   	"i.MOB" "if $C2 & $M5"
		DDRD a6 `1'`j'   	"i.MOB" "if $C2"
		DDRD a7 `1'`j'   	"i.MOB" "if $C2 & $MD"
		esttab a* using "$tables/gdr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps ///
			mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
			prehead("" "" "" "" "`1'" "DD - GDR placebo"  "") ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
			
		*ratio fertility
		DDRD b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD b6 r_fert_`1'`j'   "i.MOB" "if $C2"
		DDRD b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab b* using "$tables/gdr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
		*ratio population
		DDRD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD c6 r_popf_`1'`j'   "i.MOB" "if $C2"
		DDRD c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab c* using "$tables/gdr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_f"{ //  "_m"
	// FEMALE
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if $C2 & $M1"
		DDRD a2 `1'`j'   	"i.MOB" "if $C2 & $M2"
		DDRD a3 `1'`j'   	"i.MOB" "if $C2 & $M3"
		DDRD a4 `1'`j'   	"i.MOB" "if $C2 & $M4"
		DDRD a5 `1'`j'   	"i.MOB" "if $C2 & $M5"
		DDRD a6 `1'`j'   	"i.MOB" "if $C2"
		DDRD a7 `1'`j'   	"i.MOB" "if $C2 & $MD"
		esttab a* using "$tables/gdr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			title("WOMEN") nomtitles 
			*mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") 
			
		*ratio fertility
		DDRD b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD b6 r_fert_`1'`j'   "i.MOB" "if $C2"
		DDRD b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab b* using "$tables/gdr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
		*ratio population
		DDRD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD c6 r_popf_`1'`j'   "i.MOB" "if $C2"
		DDRD c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab c* using "$tables/gdr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_m" { // "" "_f" 
	// MEN
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if $C2 & $M1"
		DDRD a2 `1'`j'   	"i.MOB" "if $C2 & $M2"
		DDRD a3 `1'`j'   	"i.MOB" "if $C2 & $M3"
		DDRD a4 `1'`j'   	"i.MOB" "if $C2 & $M4"
		DDRD a5 `1'`j'   	"i.MOB" "if $C2 & $M5"
		DDRD a6 `1'`j'   	"i.MOB" "if $C2"
		DDRD a7 `1'`j'   	"i.MOB" "if $C2 & $MD"
		esttab a* using "$tables/gdr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline ///
			title("MEN") nomtitles nonumbers nogaps
			
		*ratio fertility
		DDRD b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD b6 r_fert_`1'`j'   "i.MOB" "if $C2"
		DDRD b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab b* using "$tables/gdr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline		
			
		*ratio population
		DDRD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD c6 r_popf_`1'`j'   "i.MOB" "if $C2"
		DDRD c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab c* using "$tables/gdr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	//Observations
	esttab a* using "$tables/gdr_level_tables.txt", append  ///
			cells(none) nonote noobs noline nomtitles nonumbers nogaps scalars("N Obs Abs_numb")
	esttab b* using "$tables/gdr_level_tables.txt", append  ///
			cells(none) nonote noobs noline nomtitles nonumbers nogaps scalars("N Obs R_fert")
	esttab c* using "$tables/gdr_level_tables.txt", append  ///
			cells(none) nonote  noobs noline nomtitles nonumbers nogaps scalars("N Obs R_pop") ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
 

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
	esttab a* using "$tables/gdr_level_tables.txt", append ///
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
	esttab c* using "$tables/gdr_level_tables.txt", append keep(TxA) coeflabels(TxA "Ratio fertility") ///
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
	esttab b* using "$tables/gdr_level_tables.txt", append keep(TxA) coeflabels(TxA "Ratio population") ///
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
	esttab a* using "$tables/gdr_level_tables.txt", append keep(TxA) coeflabels(TxA "Abs. numbers") ///
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
	esttab c* using "$tables/gdr_level_tables.txt", append keep(TxA) coeflabels(TxA "Ratio fertility") ///
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
	esttab b* using "$tables/gdr_level_tables.txt", append keep(TxA) coeflabels(TxA "Ratio population") ///
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
	esttab a* using "$tables/gdr_level_tables.txt", append keep(TxA) coeflabels(TxA "Abs. numbers") ///
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
	esttab c* using "$tables/gdr_level_tables.txt", append keep(TxA) coeflabels(TxA "Ratio fertility") ///
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
	esttab b* using "$tables/gdr_level_tables.txt", append keep(TxA) coeflabels(TxA "Ratio population") ///
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
	esttab a* using "$tables/gdr_level_tables.txt", append keep(TxA) coeflabels(TxA "Abs. numbers") ///
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
	esttab c* using "$tables/gdr_level_tables.txt", append  ///
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
	esttab b* using "$tables/gdr_level_tables.txt", append keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		addnotes("---------------------------------------------------------------------------------------------------------------------------------------------------------------------")
*/		
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
		esttab a* using "$tables/gdr_level_tables.txt", append  ///
			keep(FxA) coeflabels(FxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps ///
			mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
			prehead("" "" "" """`1'" "ALTERNATIVE DD (CG: same birth cohort in GDR) - Overview for different bandwidths (FRG+GDR)"  "") ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
		*ratio fertility
		DDalt b1 r_fert_`1'`j'   "i.MOB" "if  $M1"
		DDalt b2 r_fert_`1'`j'   "i.MOB" "if  $M2"
		DDalt b3 r_fert_`1'`j'   "i.MOB" "if  $M3"
		DDalt b4 r_fert_`1'`j'   "i.MOB" "if  $M4"
		DDalt b5 r_fert_`1'`j'   "i.MOB" "if  $M5"
		DDalt b6 r_fert_`1'`j'   "i.MOB" " 		 "
		DDalt b7 r_fert_`1'`j'   "i.MOB" "if  $MD"
		esttab b* using "$tables/gdr_level_tables.txt", append ///
			keep(FxA) coeflabels(FxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline
		*ratio population
		DDalt c1 r_popf_`1'`j'   "i.MOB" "if  $M1"
		DDalt c2 r_popf_`1'`j'   "i.MOB" "if  $M2"
		DDalt c3 r_popf_`1'`j'   "i.MOB" "if  $M3"
		DDalt c4 r_popf_`1'`j'   "i.MOB" "if  $M4"
		DDalt c5 r_popf_`1'`j'   "i.MOB" "if  $M5"
		DDalt c6 r_popf_`1'`j'   "i.MOB" "  	 "
		DDalt c7 r_popf_`1'`j'   "i.MOB" "if  $MD"
		esttab c* using "$tables/gdr_level_tables.txt", append ///
			keep(FxA) coeflabels(FxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
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
		esttab a* using "$tables/gdr_level_tables.txt", append  ///
			keep(FxA) coeflabels(FxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
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
		esttab b* using "$tables/gdr_level_tables.txt", append ///
			keep(FxA) coeflabels(FxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline	
		*ratio population
		DDalt c1 r_popf_`1'`j'   "i.MOB" "if $M1"
		DDalt c2 r_popf_`1'`j'   "i.MOB" "if $M2"
		DDalt c3 r_popf_`1'`j'   "i.MOB" "if $M3"
		DDalt c4 r_popf_`1'`j'   "i.MOB" "if $M4"
		DDalt c5 r_popf_`1'`j'   "i.MOB" "if $M5"
		DDalt c6 r_popf_`1'`j'   "i.MOB" "		"
		DDalt c7 r_popf_`1'`j'   "i.MOB" "if $MD"
		esttab c* using "$tables/gdr_level_tables.txt", append ///
			keep(FxA) coeflabels(FxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
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
		esttab a* using "$tables/gdr_level_tables.txt", append  ///
			keep(FxA) coeflabels(FxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline ///
			title("MEN") nomtitles nonumbers nogaps
		*ratio fertility
		DDalt b1 r_fert_`1'`j'   "i.MOB" "if  $M1"
		DDalt b2 r_fert_`1'`j'   "i.MOB" "if  $M2"
		DDalt b3 r_fert_`1'`j'   "i.MOB" "if  $M3"
		DDalt b4 r_fert_`1'`j'   "i.MOB" "if  $M4"
		DDalt b5 r_fert_`1'`j'   "i.MOB" "if  $M5"
		DDalt b6 r_fert_`1'`j'   "i.MOB" " 		 "
		DDalt b7 r_fert_`1'`j'   "i.MOB" "if  $MD"
		esttab b* using "$tables/gdr_level_tables.txt", append ///
			keep(FxA) coeflabels(FxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline	
		*ratio population
		DDalt c1 r_popf_`1'`j'   "i.MOB" "if $M1"
		DDalt c2 r_popf_`1'`j'   "i.MOB" "if $M2"
		DDalt c3 r_popf_`1'`j'   "i.MOB" "if $M3"
		DDalt c4 r_popf_`1'`j'   "i.MOB" "if $M4"
		DDalt c5 r_popf_`1'`j'   "i.MOB" "if $M5"
		DDalt c6 r_popf_`1'`j'   "i.MOB" "		"
		DDalt c7 r_popf_`1'`j'   "i.MOB" "if $MD"
		esttab c* using "$tables/gdr_level_tables.txt", append ///
			keep(FxA) coeflabels(FxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	//Observations
	esttab a* using "$tables/gdr_level_tables.txt", append  ///
			cells(none) nonote noobs noline nomtitles  nogaps scalars("N Obs Abs_numb")
	esttab b* using "$tables/gdr_level_tables.txt", append  ///
			cells(none) nonote noobs noline nomtitles  nogaps scalars("N Obs R_fert")
	esttab c* using "$tables/gdr_level_tables.txt", append  ///
			cells(none) nonote  noobs noline nomtitles nonumbers nogaps scalars("N Obs R_pop") ///
			addnotes("--------------------------------------------------------------------------------------------------------------------------------------" ///
			"" "" "END: `1'" "MWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMW")				
restore	// end:restore just treat == 1		
********************************************************************************		
		
		
		
		
} // end: varlist

