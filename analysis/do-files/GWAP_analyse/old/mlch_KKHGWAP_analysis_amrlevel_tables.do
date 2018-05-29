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
	
capture program drop DDxLFP
	program define DDxLFP
	qui  eststo `1': reg `2' treat after FLFP_2001 TxA TxFLFP AxFLFP TxAxFLFP `3'  `4', vce(cluster MxY) 
	end
	
capture program drop DDD
	program define DDD
		qui eststo `1': reg `2' treat after FRG TxA FxT FxA FxTxA `3' `4', vce(cluster MxYxFRG)
	end
********************************************************************************

/* Aufbau des Do-Files
1) DD
	- normal overview
		* a) choice of bandwidth
		* b) choice of control group
	- sample splits für heterogeneity analysis 
		* c) urban/rural 
		* d) FLFP)
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
qui gen MxYxFRG = MxY * FRG

capture drop FLFP_2001
qui gen temp = FLFP if year == 2001 
qui bys amr_clean: egen FLFP_2001 = min(temp)

qui gen TxFLFP = treat * FLFP_2001
qui gen AxFLFP = after * FLFP_2001
qui gen TxAxFLFP = TxA * FLFP_2001

*initiate file
	eststo clear 
	DDD a d5   	"i.MOB" "if $C2 & $M1"
	esttab a* using "$tables/amr_level_tables.txt", replace cells(none) nonumbers noobs nonote noline nogaps nomtitles ///
		prehead("START Document - AMR LEVEL"  "") 

********************************************************************************
* ONLY FRG!!!!!!!!!!!!
foreach 1 of varlist $list_outcomes { // $list_outcomes
preserve
keep if GDR == 0


// 1.a) DDRD - different bandwidths (month of birth)
	foreach j in "" { // "_f" "_m"
	// TOTAL
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDRD a2 `1'`j'   	"i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDRD a3 `1'`j'   	"i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDRD a4 `1'`j'   	"i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDRD a5 `1'`j'   	"i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDRD a6 `1'`j'   	"i.MOB" "if $C2 [w = _002_pop]"
		DDRD a7 `1'`j'   	"i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps ///
			mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
			prehead("" "" "START `1': $`1'" "DDRD - Overview for different bandwidths (FRG only)"  "") ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
			
		*ratio population
		DDRD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDRD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDRD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDRD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDRD c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDRD c6 r_popf_`1'`j'   "i.MOB" "if $C2 [w = _002_pop]"
		DDRD c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_f"{ //  "_m"
	// FEMALE
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDRD a2 `1'`j'   	"i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDRD a3 `1'`j'   	"i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDRD a4 `1'`j'   	"i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDRD a5 `1'`j'   	"i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDRD a6 `1'`j'   	"i.MOB" "if $C2 [w = _002_pop]"
		DDRD a7 `1'`j'   	"i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			title("WOMEN") nomtitles 
			*mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") 
			
		*ratio population
		DDRD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDRD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDRD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDRD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDRD c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDRD c6 r_popf_`1'`j'   "i.MOB" "if $C2 [w = _002_pop]"
		DDRD c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_m" { // "" "_f" 
	// MEN
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDRD a2 `1'`j'   	"i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDRD a3 `1'`j'   	"i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDRD a4 `1'`j'   	"i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDRD a5 `1'`j'   	"i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDRD a6 `1'`j'   	"i.MOB" "if $C2 [w = _002_pop]"
		DDRD a7 `1'`j'   	"i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline ///
			title("MEN") nomtitles nonumbers nogaps
			
		*ratio population
		DDRD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDRD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDRD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDRD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDRD c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDRD c6 r_popf_`1'`j'   "i.MOB" "if $C2 [w = _002_pop]"
		DDRD c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	//Observations
	esttab a* using "$tables/amr_level_tables.txt", append  ///
			cells(none) nonote noobs noline nomtitles  nogaps scalars("N Obs Abs_numb")
	esttab c* using "$tables/amr_level_tables.txt", append  ///
			cells(none) nonote  noobs noline nomtitles nonumbers nogaps scalars("N Obs R_pop") ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				

********************************************************************************

// 1.b) DDRD - choice of control group
	// PANEL: 2 MONTHS 
	*absolute numbers
	eststo clear
	DDRD a1 `1'   "i.MOB" "if $C2    & $M2 [w = _002_pop]"
	DDRD a2 `1'   "i.MOB" "if $C1_C2 & $M2 [w = _002_pop]" 
	DDRD a3 `1'   "i.MOB" "if          $M2 [w = _002_pop]"
	DDRD a4 `1'_f "i.MOB" "if $C2    & $M2 [w = _002_pop]"
	DDRD a5 `1'_f "i.MOB" "if $C1_C2 & $M2 [w = _002_pop]" 
	DDRD a6 `1'_f "i.MOB" "if          $M2 [w = _002_pop]"
	DDRD a7 `1'_m "i.MOB" "if $C2    & $M2 [w = _002_pop]"
	DDRD a8 `1'_m "i.MOB" "if $C1_C2 & $M2 [w = _002_pop]" 
	DDRD a9 `1'_m "i.MOB" "if          $M2 [w = _002_pop]"
	esttab a* using "$tables/amr_level_tables.txt", append ///
		keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label  noobs nonote nogaps noline	 ///
		mtitles("T_C2" "T_C1+2" "T_C1-3" "F_C2" "F_C1+2" "F_C1-3" "M_C2" "M_C1+2" "M_C1-3") ///
		prehead("" "" "" """`1'" "DDRD - overview - choice of control group (FRG only)" "") ///
		posthead("---------------------------------------------------------------------------------------------------------------------------------------------------------------------" "2 MONTHS")
	*Ratio population
	DDRD b1 r_popf_`1'   "i.MOB" "if $C2    & $M2 [w = _002_pop]"
	DDRD b2 r_popf_`1'   "i.MOB" "if $C1_C2 & $M2 [w = _002_pop]" 
	DDRD b3 r_popf_`1'   "i.MOB" "if          $M2 [w = _002_pop]"
	DDRD b4 r_popf_`1'_f "i.MOB" "if $C2    & $M2 [w = _002_pop]"
	DDRD b5 r_popf_`1'_f "i.MOB" "if $C1_C2 & $M2 [w = _002_pop]" 
	DDRD b6 r_popf_`1'_f "i.MOB" "if          $M2 [w = _002_pop]"
	DDRD b7 r_popf_`1'_m "i.MOB" "if $C2    & $M2 [w = _002_pop]"
	DDRD b8 r_popf_`1'_m "i.MOB" "if $C1_C2 & $M2 [w = _002_pop]" 
	DDRD b9 r_popf_`1'_m "i.MOB" "if          $M2 [w = _002_pop]"
	esttab b* using "$tables/amr_level_tables.txt", append keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		addnotes(---------------------------------------------------------------------------------------------------------------------------------------------------------------------)				


	// PANEL: 4 MONTHS 
	*absolute numbers
	eststo clear
	DDRD a1 `1'   "i.MOB" "if $C2    & $M4 [w = _002_pop]"
	DDRD a2 `1'   "i.MOB" "if $C1_C2 & $M4 [w = _002_pop]" 
	DDRD a3 `1'   "i.MOB" "if          $M4 [w = _002_pop]"
	DDRD a4 `1'_f "i.MOB" "if $C2    & $M4 [w = _002_pop]"
	DDRD a5 `1'_f "i.MOB" "if $C1_C2 & $M4 [w = _002_pop]" 
	DDRD a6 `1'_f "i.MOB" "if          $M4 [w = _002_pop]"
	DDRD a7 `1'_m "i.MOB" "if $C2    & $M4 [w = _002_pop]"
	DDRD a8 `1'_m "i.MOB" "if $C1_C2 & $M4 [w = _002_pop]" 
	DDRD a9 `1'_m "i.MOB" "if          $M4 [w = _002_pop]"
	esttab a* using "$tables/amr_level_tables.txt", append keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		title("4 MONTHS")	
	*Ratio population
	DDRD b1 r_popf_`1'   "i.MOB" "if $C2    & $M4 [w = _002_pop]"
	DDRD b2 r_popf_`1'   "i.MOB" "if $C1_C2 & $M4 [w = _002_pop]" 
	DDRD b3 r_popf_`1'   "i.MOB" "if          $M4 [w = _002_pop]"
	DDRD b4 r_popf_`1'_f "i.MOB" "if $C2    & $M4 [w = _002_pop]"
	DDRD b5 r_popf_`1'_f "i.MOB" "if $C1_C2 & $M4 [w = _002_pop]" 
	DDRD b6 r_popf_`1'_f "i.MOB" "if          $M4 [w = _002_pop]"
	DDRD b7 r_popf_`1'_m "i.MOB" "if $C2    & $M4 [w = _002_pop]"
	DDRD b8 r_popf_`1'_m "i.MOB" "if $C1_C2 & $M4 [w = _002_pop]" 
	DDRD b9 r_popf_`1'_m "i.MOB" "if          $M4 [w = _002_pop]"
	esttab b* using "$tables/amr_level_tables.txt", append keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		addnotes(---------------------------------------------------------------------------------------------------------------------------------------------------------------------)					
	
	// PANEL: 6 MONTHS 
	*absolute numbers
	eststo clear
	DDRD a1 `1'   "i.MOB" "if $C2    [w = _002_pop]"
	DDRD a2 `1'   "i.MOB" "if $C1_C2 [w = _002_pop]" 
	DDRD a3 `1'   "i.MOB" "          [w = _002_pop]"
	DDRD a4 `1'_f "i.MOB" "if $C2    [w = _002_pop]"
	DDRD a5 `1'_f "i.MOB" "if $C1_C2 [w = _002_pop]" 
	DDRD a6 `1'_f "i.MOB" "          [w = _002_pop]"
	DDRD a7 `1'_m "i.MOB" "if $C2    [w = _002_pop]"
	DDRD a8 `1'_m "i.MOB" "if $C1_C2 [w = _002_pop]" 
	DDRD a9 `1'_m "i.MOB" "          [w = _002_pop]"
	esttab a* using "$tables/amr_level_tables.txt", append keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		title("6 MONTHS")	
	
	*Ratio population
	DDRD b1 r_popf_`1'   "i.MOB" "if $C2    [w = _002_pop]"
	DDRD b2 r_popf_`1'   "i.MOB" "if $C1_C2 [w = _002_pop]" 
	DDRD b3 r_popf_`1'   "i.MOB" "          [w = _002_pop]"
	DDRD b4 r_popf_`1'_f "i.MOB" "if $C2    [w = _002_pop]"
	DDRD b5 r_popf_`1'_f "i.MOB" "if $C1_C2 [w = _002_pop]" 
	DDRD b6 r_popf_`1'_f "i.MOB" "          [w = _002_pop]"
	DDRD b7 r_popf_`1'_m "i.MOB" "if $C2    [w = _002_pop]"
	DDRD b8 r_popf_`1'_m "i.MOB" "if $C1_C2 [w = _002_pop]" 
	DDRD b9 r_popf_`1'_m "i.MOB" "          [w = _002_pop]"
	esttab b* using "$tables/amr_level_tables.txt", append keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		addnotes(---------------------------------------------------------------------------------------------------------------------------------------------------------------------)					

	// PANEL: DONUT 
	*absolute numbers
	eststo clear
	DDRD a1 `1'   "i.MOB" "if $C2    & $MD [w = _002_pop]"
	DDRD a2 `1'   "i.MOB" "if $C1_C2 & $MD [w = _002_pop]" 
	DDRD a3 `1'   "i.MOB" "if          $MD [w = _002_pop]"
	DDRD a4 `1'_f "i.MOB" "if $C2    & $MD [w = _002_pop]"
	DDRD a5 `1'_f "i.MOB" "if $C1_C2 & $MD [w = _002_pop]" 
	DDRD a6 `1'_f "i.MOB" "if          $MD [w = _002_pop]"
	DDRD a7 `1'_m "i.MOB" "if $C2    & $MD [w = _002_pop]"
	DDRD a8 `1'_m "i.MOB" "if $C1_C2 & $MD [w = _002_pop]" 
	DDRD a9 `1'_m "i.MOB" "if          $MD [w = _002_pop]"
	esttab a* using "$tables/amr_level_tables.txt", append keep(TxA) coeflabels(TxA "Abs. numbers") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline	///
		title("Donut")
	
	*Ratio population
	DDRD b1 r_popf_`1'   "i.MOB" "if $C2    & $MD [w = _002_pop]"
	DDRD b2 r_popf_`1'   "i.MOB" "if $C1_C2 & $MD [w = _002_pop]" 
	DDRD b3 r_popf_`1'   "i.MOB" "if          $MD [w = _002_pop]"
	DDRD b4 r_popf_`1'_f "i.MOB" "if $C2    & $MD [w = _002_pop]"
	DDRD b5 r_popf_`1'_f "i.MOB" "if $C1_C2 & $MD [w = _002_pop]" 
	DDRD b6 r_popf_`1'_f "i.MOB" "if          $MD [w = _002_pop]"
	DDRD b7 r_popf_`1'_m "i.MOB" "if $C2    & $MD [w = _002_pop]"
	DDRD b8 r_popf_`1'_m "i.MOB" "if $C1_C2 & $MD [w = _002_pop]" 
	DDRD b9 r_popf_`1'_m "i.MOB" "if          $MD [w = _002_pop]"
	esttab b* using "$tables/amr_level_tables.txt", append keep(TxA) coeflabels(TxA "Ratio population") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		label nomtitles nonumbers noobs nonote nogaps noline ///
		addnotes(---------------------------------------------------------------------------------------------------------------------------------------------------------------------)

********************************************************************************


//1.c) DD - sample split according to rural/urban
	foreach j in "" { // "_f" "_m"
	// TOTAL
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if high_density == 0 & $C2 & $M2 [w = _002_pop]"
		DDRD a2 `1'`j'   	"i.MOB" "if high_density == 0 & $C2 & $M4  [w = _002_pop]"
		DDRD a3 `1'`j'   	"i.MOB" "if high_density == 0 & $C2  [w = _002_pop]"
		DDRD a4 `1'`j'   	"i.MOB" "if high_density == 0 & $C2 & $MD [w = _002_pop]"
		DDRD a5 `1'`j'   	"i.MOB" "if high_density == 1 & $C2 & $M2 [w = _002_pop]"
		DDRD a6 `1'`j'   	"i.MOB" "if high_density == 1 & $C2 & $M4 [w = _002_pop]"
		DDRD a7 `1'`j'   	"i.MOB" "if high_density == 1 & $C2 [w = _002_pop]"
		DDRD a8 `1'`j'   	"i.MOB" "if high_density == 1 & $C2 & $MD [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote nogaps noline ///
			mtitles("2M" "4M" "6M" "Donut" "2M" "4M" "6M" "Donut") ///
			mgroups("Rural" "Urban", pattern(1 0 0 0 1 0 0 0)) /// 
			prehead("" "" "" "`1'"  "DD - HETEROGENEITY analysis (RURAL vs. URBAN) (FRG only)"  "") ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
		*ratio population 
		DDRD c1 r_popf_`1'`j'   	"i.MOB" "if high_density == 0 & $C2 & $M2 [w = _002_pop]"
		DDRD c2 r_popf_`1'`j'   	"i.MOB" "if high_density == 0 & $C2 & $M4 [w = _002_pop]"
		DDRD c3 r_popf_`1'`j'   	"i.MOB" "if high_density == 0 & $C2 [w = _002_pop]"
		DDRD c4 r_popf_`1'`j'   	"i.MOB" "if high_density == 0 & $C2 & $MD [w = _002_pop]"
		DDRD c5 r_popf_`1'`j'   	"i.MOB" "if high_density == 1 & $C2 & $M2 [w = _002_pop]"
		DDRD c6 r_popf_`1'`j'   	"i.MOB" "if high_density == 1 & $C2 & $M4 [w = _002_pop]"
		DDRD c7 r_popf_`1'`j'   	"i.MOB" "if high_density == 1 & $C2 [w = _002_pop]"
		DDRD c8 r_popf_`1'`j'   	"i.MOB" "if high_density == 1 & $C2 & $MD [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------------------------)				
	} // end: total
	foreach j in "_f" { // "_f" "_m"
	// FEMALE
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if high_density == 0 & $C2 & $M2 [w = _002_pop]"
		DDRD a2 `1'`j'   	"i.MOB" "if high_density == 0 & $C2 & $M4 [w = _002_pop]"
		DDRD a3 `1'`j'   	"i.MOB" "if high_density == 0 & $C2 [w = _002_pop]"
		DDRD a4 `1'`j'   	"i.MOB" "if high_density == 0 & $C2 & $MD [w = _002_pop]"
		DDRD a5 `1'`j'   	"i.MOB" "if high_density == 1 & $C2 & $M2 [w = _002_pop]"
		DDRD a6 `1'`j'   	"i.MOB" "if high_density == 1 & $C2 & $M4 [w = _002_pop]"
		DDRD a7 `1'`j'   	"i.MOB" "if high_density == 1 & $C2 [w = _002_pop]"
		DDRD a8 `1'`j'   	"i.MOB" "if high_density == 1 & $C2 & $MD [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			title("WOMEN") nomtitles			
			
		*ratio population 
		DDRD c1 r_popf_`1'`j'   	"i.MOB" "if high_density == 0 & $C2 & $M2 [w = _002_pop]"
		DDRD c2 r_popf_`1'`j'   	"i.MOB" "if high_density == 0 & $C2 & $M4 [w = _002_pop]"
		DDRD c3 r_popf_`1'`j'   	"i.MOB" "if high_density == 0 & $C2 [w = _002_pop]"
		DDRD c4 r_popf_`1'`j'   	"i.MOB" "if high_density == 0 & $C2 & $MD [w = _002_pop]"
		DDRD c5 r_popf_`1'`j'   	"i.MOB" "if high_density == 1 & $C2 & $M2 [w = _002_pop]"
		DDRD c6 r_popf_`1'`j'   	"i.MOB" "if high_density == 1 & $C2 & $M4 [w = _002_pop]"
		DDRD c7 r_popf_`1'`j'   	"i.MOB" "if high_density == 1 & $C2 [w = _002_pop]"
		DDRD c8 r_popf_`1'`j'   	"i.MOB" "if high_density == 1 & $C2 & $MD [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------------------------)				
	} // end: female
	foreach j in "_m" { // "_f" "_m"
	// MALE
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if high_density == 0 & $C2 & $M2 [w = _002_pop]"
		DDRD a2 `1'`j'   	"i.MOB" "if high_density == 0 & $C2 & $M4 [w = _002_pop]"
		DDRD a3 `1'`j'   	"i.MOB" "if high_density == 0 & $C2 [w = _002_pop]"
		DDRD a4 `1'`j'   	"i.MOB" "if high_density == 0 & $C2 & $MD [w = _002_pop]"
		DDRD a5 `1'`j'   	"i.MOB" "if high_density == 1 & $C2 & $M2 [w = _002_pop]"
		DDRD a6 `1'`j'   	"i.MOB" "if high_density == 1 & $C2 & $M4 [w = _002_pop]"
		DDRD a7 `1'`j'   	"i.MOB" "if high_density == 1 & $C2 [w = _002_pop]"
		DDRD a8 `1'`j'   	"i.MOB" "if high_density == 1 & $C2 & $MD [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			title("MEN") nomtitles			
			
		*ratio population 
		DDRD c1 r_popf_`1'`j'   	"i.MOB" "if high_density == 0 & $C2 & $M2 [w = _002_pop]"
		DDRD c2 r_popf_`1'`j'   	"i.MOB" "if high_density == 0 & $C2 & $M4 [w = _002_pop]"
		DDRD c3 r_popf_`1'`j'   	"i.MOB" "if high_density == 0 & $C2 [w = _002_pop]"
		DDRD c4 r_popf_`1'`j'   	"i.MOB" "if high_density == 0 & $C2 & $MD [w = _002_pop]"
		DDRD c5 r_popf_`1'`j'   	"i.MOB" "if high_density == 1 & $C2 & $M2 [w = _002_pop]"
		DDRD c6 r_popf_`1'`j'   	"i.MOB" "if high_density == 1 & $C2 & $M4 [w = _002_pop]"
		DDRD c7 r_popf_`1'`j'   	"i.MOB" "if high_density == 1 & $C2 [w = _002_pop]"
		DDRD c8 r_popf_`1'`j'   	"i.MOB" "if high_density == 1 & $C2 & $MD [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------------------------)				
	} // end: men
	// Observations
	esttab a* using "$tables/amr_level_tables.txt", append  ///
			cells(none) nonote noobs noline nomtitles  nogaps scalars("N Obs Abs_numb")
	esttab c* using "$tables/amr_level_tables.txt", append  ///
			cells(none) nonote  noobs noline nomtitles nonumbers nogaps scalars("N Obs R_pop") ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				

********************************************************************************
			
//1.d) DD - sample split according to FLFP
	foreach j in "" { // "_f" "_m"
	// TOTAL
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 & $M2 [w = _002_pop]"
		DDRD a2 `1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 & $M4 [w = _002_pop]"
		DDRD a3 `1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 [w = _002_pop]"
		DDRD a4 `1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 & $MD [w = _002_pop]"
		DDRD a5 `1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 & $M2 [w = _002_pop]"
		DDRD a6 `1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 & $M4 [w = _002_pop]"
		DDRD a7 `1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 [w = _002_pop]"
		DDRD a8 `1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 & $MD [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote nogaps noline ///
			mtitles("2M" "4M" "6M" "Donut" "2M" "4M" "6M" "Donut") ///
			mgroups("low FLFP" "high FLFP", pattern(1 0 0 0 1 0 0 0)) /// 
			prehead("" "" "" "`1'"  "DD - HETEROGENEITY analysis: FLFP (FRG only)"  "") ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
		*ratio population 
		DDRD c1 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 & $M2 [w = _002_pop]"
		DDRD c2 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 & $M4 [w = _002_pop]"
		DDRD c3 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 [w = _002_pop]"
		DDRD c4 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 & $MD [w = _002_pop]"
		DDRD c5 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 & $M2 [w = _002_pop]"
		DDRD c6 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 & $M4 [w = _002_pop]"
		DDRD c7 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 [w = _002_pop]"
		DDRD c8 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 & $MD [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------------------------)				
	} // end: total
	foreach j in "_f" { // "_f" "_m"
	// FEMALE
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 & $M2 [w = _002_pop]"
		DDRD a2 `1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 & $M4 [w = _002_pop]"
		DDRD a3 `1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 [w = _002_pop]"
		DDRD a4 `1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 & $MD [w = _002_pop]"
		DDRD a5 `1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 & $M2 [w = _002_pop]"
		DDRD a6 `1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 & $M4 [w = _002_pop]"
		DDRD a7 `1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 [w = _002_pop]"
		DDRD a8 `1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 & $MD [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			title("WOMEN") nomtitles			
			
		*ratio population 
		DDRD c1 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 & $M2 [w = _002_pop]"
		DDRD c2 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 & $M4 [w = _002_pop]"
		DDRD c3 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 [w = _002_pop]"
		DDRD c4 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 & $MD [w = _002_pop]"
		DDRD c5 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 & $M2 [w = _002_pop]"
		DDRD c6 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 & $M4 [w = _002_pop]"
		DDRD c7 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 [w = _002_pop]"
		DDRD c8 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 & $MD [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------------------------)				
	} // end: female
	foreach j in "_m" { // "_f" "_m"
	// MALE
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 & $M2 [w = _002_pop]"
		DDRD a2 `1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 & $M4 [w = _002_pop]"
		DDRD a3 `1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 [w = _002_pop]"
		DDRD a4 `1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 & $MD [w = _002_pop]"
		DDRD a5 `1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 & $M2 [w = _002_pop]"
		DDRD a6 `1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 & $M4 [w = _002_pop]"
		DDRD a7 `1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 [w = _002_pop]"
		DDRD a8 `1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 & $MD [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			title("MEN") nomtitles			
			
		*ratio population 
		DDRD c1 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 & $M2 [w = _002_pop]"
		DDRD c2 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 & $M4 [w = _002_pop]"
		DDRD c3 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 [w = _002_pop]"
		DDRD c4 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 0 & $C2 & $MD [w = _002_pop]"
		DDRD c5 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 & $M2 [w = _002_pop]"
		DDRD c6 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 & $M4 [w = _002_pop]"
		DDRD c7 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 [w = _002_pop]"
		DDRD c8 r_popf_`1'`j'   	"i.MOB" "if high_FLFP == 1 & $C2 & $MD [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------------------------)				
	} // end: men
	// Observations
	esttab a* using "$tables/amr_level_tables.txt", append  ///
			cells(none) nonote noobs noline nomtitles  nogaps scalars("N Obs Abs_numb")
	esttab c* using "$tables/amr_level_tables.txt", append  ///
			cells(none) nonote  noobs noline nomtitles nonumbers nogaps scalars("N Obs R_pop") ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				

********************************************************************************

//  1.e) life-course table format
	foreach j in "" { // "_f" "_m"
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if $C2 & $age_17_21 [w = _002_pop]"
		DDRD a2 `1'`j'   	"i.MOB" "if $C2 & $age_22_26 [w = _002_pop]"
		DDRD a3 `1'`j'   	"i.MOB" "if $C2 & $age_27_31 [w = _002_pop]"
		DDRD a4 `1'`j'   	"i.MOB" "if $C2 & $age_32_35 [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nonumbers noobs nonote nogaps noline ///
			mtitles("Age 17-21" "Age 22-26" "Age 27-31" "Age 32-35" ) ///
			prehead("" "" "" """`1'" "DD - life-course (FRG only)" "") ///
			posthead("--------------------------------------------------------------------------------------" "TOTAL")
		
		*ratio population
		*DDRD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_17_21 [w = _002_pop]"
		DDRD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_22_26 [w = _002_pop]"
		DDRD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_27_31 [w = _002_pop]"
		DDRD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_32_35 [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------)						
	} 
	// Women
	foreach j in "_f" { // "_f" "_m"
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if $C2 & $age_17_21 [w = _002_pop]"
		DDRD a2 `1'`j'   	"i.MOB" "if $C2 & $age_22_26 [w = _002_pop]"
		DDRD a3 `1'`j'   	"i.MOB" "if $C2 & $age_27_31 [w = _002_pop]"
		DDRD a4 `1'`j'   	"i.MOB" "if $C2 & $age_32_35 [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nonumbers noobs nonote nogaps noline ///
			title("WOMEN") nomtitles
			
		*ratio population
		*DDRD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_17_21 [w = _002_pop]"
		DDRD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_22_26 [w = _002_pop]"
		DDRD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_27_31 [w = _002_pop]"
		DDRD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_32_35 [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------)					
	}
	// MEN
	foreach j in "_m" { // "_f" "_m"
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if $C2 & $age_17_21 [w = _002_pop]"
		DDRD a2 `1'`j'   	"i.MOB" "if $C2 & $age_22_26 [w = _002_pop]"
		DDRD a3 `1'`j'   	"i.MOB" "if $C2 & $age_27_31 [w = _002_pop]"
		DDRD a4 `1'`j'   	"i.MOB" "if $C2 & $age_32_35 [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nonumbers noobs nonote nogaps noline ///
			title("MEN") nomtitles
		
		*ratio population
		*DDRD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_17_21 [w = _002_pop]"
		DDRD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_22_26 [w = _002_pop]"
		DDRD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_27_31 [w = _002_pop]"
		DDRD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_32_35 [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------)					
	}
	//Observations
	esttab a* using "$tables/amr_level_tables.txt", append  ///
			cells(none) nonote noobs noline nomtitles  nogaps scalars("N Obs Abs_numb")
	
	esttab c* using "$tables/amr_level_tables.txt", append  ///
			cells(none) nonote  noobs noline nomtitles nonumbers nogaps scalars("N Obs R_pop") ///
			addnotes(--------------------------------------------------------------------------------------)				
restore // end: keep only FRG


********************************************************************************

preserve
keep if treat == 1 
// 1.f) alternative DD specification, overview bandwidth
	foreach j in "" { // "_f" "_m"
	// TOTAL
		eststo clear 
		*absolute numbers
		DDalt a1 `1'`j'   	"i.MOB" "if $M1 [w = _002_pop]"
		DDalt a2 `1'`j'   	"i.MOB" "if $M2 [w = _002_pop]"
		DDalt a3 `1'`j'   	"i.MOB" "if $M3 [w = _002_pop]"
		DDalt a4 `1'`j'   	"i.MOB" "if $M4 [w = _002_pop]"
		DDalt a5 `1'`j'   	"i.MOB" "if $M5 [w = _002_pop]"
		DDalt a6 `1'`j'   	"i.MOB" "	    [w = _002_pop]"
		DDalt a7 `1'`j'   	"i.MOB" "if $MD [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(FxA) coeflabels(FxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps ///
			mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
			prehead("" "" "" """`1'" "ALTERNATIVE DD (CG: same birth cohort in GDR) - Overview for different bandwidths (FRG+GDR)"  "") ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
			
		*ratio population
		DDalt c1 r_popf_`1'`j'   "i.MOB" "if  $M1 [w = _002_pop]"
		DDalt c2 r_popf_`1'`j'   "i.MOB" "if  $M2 [w = _002_pop]"
		DDalt c3 r_popf_`1'`j'   "i.MOB" "if  $M3 [w = _002_pop]"
		DDalt c4 r_popf_`1'`j'   "i.MOB" "if  $M4 [w = _002_pop]"
		DDalt c5 r_popf_`1'`j'   "i.MOB" "if  $M5 [w = _002_pop]"
		DDalt c6 r_popf_`1'`j'   "i.MOB" "  	  [w = _002_pop]"
		DDalt c7 r_popf_`1'`j'   "i.MOB" "if  $MD [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append ///
			keep(FxA) coeflabels(FxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_f"{ //  "_m"
	// FEMALE
		eststo clear 
		*absolute numbers
		DDalt a1 `1'`j'   	"i.MOB" "if $M1 [w = _002_pop]"
		DDalt a2 `1'`j'   	"i.MOB" "if $M2 [w = _002_pop]"
		DDalt a3 `1'`j'   	"i.MOB" "if $M3 [w = _002_pop]"
		DDalt a4 `1'`j'   	"i.MOB" "if $M4 [w = _002_pop]"
		DDalt a5 `1'`j'   	"i.MOB" "if $M5 [w = _002_pop]"
		DDalt a6 `1'`j'   	"i.MOB" "		[w = _002_pop]"
		DDalt a7 `1'`j'   	"i.MOB" "if $MD [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(FxA) coeflabels(FxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			title("WOMEN") nomtitles 
			*mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") 
			
		*ratio population
		DDalt c1 r_popf_`1'`j'   "i.MOB" "if $M1 [w = _002_pop]"
		DDalt c2 r_popf_`1'`j'   "i.MOB" "if $M2 [w = _002_pop]"
		DDalt c3 r_popf_`1'`j'   "i.MOB" "if $M3 [w = _002_pop]"
		DDalt c4 r_popf_`1'`j'   "i.MOB" "if $M4 [w = _002_pop]"
		DDalt c5 r_popf_`1'`j'   "i.MOB" "if $M5 [w = _002_pop]"
		DDalt c6 r_popf_`1'`j'   "i.MOB" "		 [w = _002_pop]"
		DDalt c7 r_popf_`1'`j'   "i.MOB" "if $MD [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append ///
			keep(FxA) coeflabels(FxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_m" { // "" "_f" 
	// MEN
		eststo clear 
		*absolute numbers
		DDalt a1 `1'`j'   	"i.MOB" "if $M1 [w = _002_pop]"
		DDalt a2 `1'`j'   	"i.MOB" "if $M2 [w = _002_pop]"
		DDalt a3 `1'`j'   	"i.MOB" "if $M3 [w = _002_pop]"
		DDalt a4 `1'`j'   	"i.MOB" "if $M4 [w = _002_pop]"
		DDalt a5 `1'`j'   	"i.MOB" "if $M5 [w = _002_pop]"
		DDalt a6 `1'`j'   	"i.MOB" "		[w = _002_pop]"
		DDalt a7 `1'`j'   	"i.MOB" "if $MD [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(FxA) coeflabels(FxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline ///
			title("MEN") nomtitles nonumbers nogaps
			
		*ratio population
		DDalt c1 r_popf_`1'`j'   "i.MOB" "if $M1 [w = _002_pop]"
		DDalt c2 r_popf_`1'`j'   "i.MOB" "if $M2 [w = _002_pop]"
		DDalt c3 r_popf_`1'`j'   "i.MOB" "if $M3 [w = _002_pop]"
		DDalt c4 r_popf_`1'`j'   "i.MOB" "if $M4 [w = _002_pop]"
		DDalt c5 r_popf_`1'`j'   "i.MOB" "if $M5 [w = _002_pop]"
		DDalt c6 r_popf_`1'`j'   "i.MOB" "		[w = _002_pop]"
		DDalt c7 r_popf_`1'`j'   "i.MOB" "if $MD [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append ///
			keep(FxA) coeflabels(FxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	//Observations
	esttab a* using "$tables/amr_level_tables.txt", append  ///
			cells(none) nonote noobs noline nomtitles  nogaps scalars("N Obs Abs_numb")
	esttab c* using "$tables/amr_level_tables.txt", append  ///
			cells(none) nonote  noobs noline nomtitles nonumbers nogaps scalars("N Obs R_pop") ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
restore	// end:restore just treat == 1



********************************************************************************
// 1.g) GDR Placebo			
preserve
keep if GDR == 1


	foreach j in "" { // "_f" "_m"
	// TOTAL
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDRD a2 `1'`j'   	"i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDRD a3 `1'`j'   	"i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDRD a4 `1'`j'   	"i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDRD a5 `1'`j'   	"i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDRD a6 `1'`j'   	"i.MOB" "if $C2 [w = _002_pop]"
		DDRD a7 `1'`j'   	"i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps ///
			mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
			prehead("" "" "" "" "`1'" "DD - GDR placebo"  "") ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")	
			
		*ratio population
		DDRD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDRD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDRD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDRD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDRD c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDRD c6 r_popf_`1'`j'   "i.MOB" "if $C2 [w = _002_pop]"
		DDRD c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_f"{ //  "_m"
	// FEMALE
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDRD a2 `1'`j'   	"i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDRD a3 `1'`j'   	"i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDRD a4 `1'`j'   	"i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDRD a5 `1'`j'   	"i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDRD a6 `1'`j'   	"i.MOB" "if $C2 [w = _002_pop]"
		DDRD a7 `1'`j'   	"i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			title("WOMEN") nomtitles 
			*mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") 
				
		*ratio population
		DDRD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDRD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDRD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDRD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDRD c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDRD c6 r_popf_`1'`j'   "i.MOB" "if $C2 [w = _002_pop]"
		DDRD c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_m" { // "" "_f" 
	// MEN
		eststo clear 
		*absolute numbers
		DDRD a1 `1'`j'   	"i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDRD a2 `1'`j'   	"i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDRD a3 `1'`j'   	"i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDRD a4 `1'`j'   	"i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDRD a5 `1'`j'   	"i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDRD a6 `1'`j'   	"i.MOB" "if $C2 [w = _002_pop]"
		DDRD a7 `1'`j'   	"i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(TxA) coeflabels(TxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline ///
			title("MEN") nomtitles nonumbers nogaps	
			
		*ratio population
		DDRD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDRD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDRD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDRD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDRD c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDRD c6 r_popf_`1'`j'   "i.MOB" "if $C2 [w = _002_pop]"
		DDRD c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	//Observations
	esttab a* using "$tables/amr_level_tables.txt", append  ///
			cells(none) nonote noobs noline nomtitles nonumbers nogaps scalars("N Obs Abs_numb")
	esttab c* using "$tables/amr_level_tables.txt", append  ///
			cells(none) nonote  noobs noline nomtitles nonumbers nogaps scalars("N Obs R_pop") ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	restore // end: keep only GDR



********************************************************************************
// 2) triple diff
	foreach j in "" { // "_f" "_m"
	// TOTAL
		eststo clear 
		*absolute numbers
		DDD a1 `1'`j'   	"i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDD a2 `1'`j'   	"i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDD a3 `1'`j'   	"i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDD a4 `1'`j'   	"i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDD a5 `1'`j'   	"i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDD a6 `1'`j'   	"i.MOB" "if $C2 [w = _002_pop]"
		DDD a7 `1'`j'   	"i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps ///
			mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
			prehead("" "" "" """`1'" "DDD - Overview for different bandwidths (FRG+GDR)"  "") ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
			
	
		*ratio population
		DDD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDD c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDD c6 r_popf_`1'`j'   "i.MOB" "if $C2 [w = _002_pop]"
		DDD c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append ///
			keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_f"{ //  "_m"
	// FEMALE
		eststo clear 
		*absolute numbers
		DDD a1 `1'`j'   	"i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDD a2 `1'`j'   	"i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDD a3 `1'`j'   	"i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDD a4 `1'`j'   	"i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDD a5 `1'`j'   	"i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDD a6 `1'`j'   	"i.MOB" "if $C2 [w = _002_pop]"
		DDD a7 `1'`j'   	"i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			title("WOMEN") nomtitles 
			*mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") 	
		*ratio population
		DDD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDD c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDD c6 r_popf_`1'`j'   "i.MOB" "if $C2 [w = _002_pop]"
		DDD c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append ///
			keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_m" { // "" "_f" 
	// MEN
		eststo clear 
		*absolute numbers
		DDD a1 `1'`j'   	"i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDD a2 `1'`j'   	"i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDD a3 `1'`j'   	"i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDD a4 `1'`j'   	"i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDD a5 `1'`j'   	"i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDD a6 `1'`j'   	"i.MOB" "if $C2 [w = _002_pop]"
		DDD a7 `1'`j'   	"i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(FxTxA) coeflabels(FxTxA "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline ///
			title("MEN") nomtitles nonumbers nogaps
		*ratio population
		DDD c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDD c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDD c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDD c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDD c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDD c6 r_popf_`1'`j'   "i.MOB" "if $C2 [w = _002_pop]"
		DDD c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append ///
			keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	//Observations
	esttab a* using "$tables/amr_level_tables.txt", append  ///
		cells(none) nonote noobs noline nomtitles  nogaps scalars("N Obs Abs_numb")
	esttab c* using "$tables/amr_level_tables.txt", append  ///
		cells(none) nonote  noobs noline nomtitles nonumbers nogaps scalars("N Obs R_pop") ///
		addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
********************************************************************************
		
	
preserve 	
keep if GDR == 0

// 3) DDxLFP - different bandwidths (month of birth)
	foreach j in "" { // "_f" "_m"
	// TOTAL
		eststo clear 
		*absolute numbers
		DDxLFP a1 `1'`j'   	"i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDxLFP a2 `1'`j'   	"i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDxLFP a3 `1'`j'   	"i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDxLFP a4 `1'`j'   	"i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDxLFP a5 `1'`j'   	"i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDxLFP a6 `1'`j'   	"i.MOB" "if $C2 [w = _002_pop]"
		DDxLFP a7 `1'`j'   	"i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(TxAxFLFP) coeflabels(TxAxFLFP "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps ///
			mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
			prehead("" "" "" """`1'" "DDxLFP - Overview for different bandwidths (FRG only)"  "") ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
			
		*ratio population
		DDxLFP c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDxLFP c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDxLFP c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDxLFP c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDxLFP c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDxLFP c6 r_popf_`1'`j'   "i.MOB" "if $C2 [w = _002_pop]"
		DDxLFP c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append ///
			keep(TxAxFLFP) coeflabels(TxAxFLFP "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_f"{ //  "_m"
	// FEMALE
		eststo clear 
		*absolute numbers
		DDxLFP a1 `1'`j'   	"i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDxLFP a2 `1'`j'   	"i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDxLFP a3 `1'`j'   	"i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDxLFP a4 `1'`j'   	"i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDxLFP a5 `1'`j'   	"i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDxLFP a6 `1'`j'   	"i.MOB" "if $C2 [w = _002_pop]"
		DDxLFP a7 `1'`j'   	"i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(TxAxFLFP) coeflabels(TxAxFLFP "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			title("WOMEN") nomtitles 
			*mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") 
			
		*ratio population
		DDxLFP c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDxLFP c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDxLFP c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDxLFP c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDxLFP c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDxLFP c6 r_popf_`1'`j'   "i.MOB" "if $C2 [w = _002_pop]"
		DDxLFP c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append ///
			keep(TxAxFLFP) coeflabels(TxAxFLFP "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	foreach j in "_m" { // "" "_f" 
	// MEN
		eststo clear 
		*absolute numbers
		DDxLFP a1 `1'`j'   	"i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDxLFP a2 `1'`j'   	"i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDxLFP a3 `1'`j'   	"i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDxLFP a4 `1'`j'   	"i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDxLFP a5 `1'`j'   	"i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDxLFP a6 `1'`j'   	"i.MOB" "if $C2 [w = _002_pop]"
		DDxLFP a7 `1'`j'   	"i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab a* using "$tables/amr_level_tables.txt", append  ///
			keep(TxAxFLFP) coeflabels(TxAxFLFP "Abs. numbers") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline ///
			title("MEN") nomtitles nonumbers nogaps
			
		*ratio population
		DDxLFP c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1 [w = _002_pop]"
		DDxLFP c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2 [w = _002_pop]"
		DDxLFP c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3 [w = _002_pop]"
		DDxLFP c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4 [w = _002_pop]"
		DDxLFP c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5 [w = _002_pop]"
		DDxLFP c6 r_popf_`1'`j'   "i.MOB" "if $C2 [w = _002_pop]"
		DDxLFP c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD [w = _002_pop]"
		esttab c* using "$tables/amr_level_tables.txt", append ///
			keep(TxAxFLFP) coeflabels(TxAxFLFP "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	}
	//Observations
	esttab a* using "$tables/amr_level_tables.txt", append  ///
		cells(none) nonote noobs noline nomtitles  nogaps scalars("N Obs Abs_numb")
	esttab c* using "$tables/amr_level_tables.txt", append  ///
		cells(none) nonote  noobs noline nomtitles nonumbers nogaps scalars("N Obs R_pop") ///
		addnotes("--------------------------------------------------------------------------------------------------------------------------------------" ///
		"" "" "END: `1'" "MWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMW")				

	restore // end: FRG only		
		
		
		
		
	
} // end: varlist
********************************************************************************

	
	
	
/*
//Rumprobieren, weighting und clustering 

qui gen AMRxMxY = amr_clean * MxY
qui gen AMRXafter = amr_clean * after


eststo clear	
	qui eststo c1: reg r_popf_d5_m treat after TxA i.MOB if high_FLFP == 1 & $C2 				 , vce(cluster MxY)
	qui eststo c2: reg r_popf_d5_m treat after TxA i.MOB if high_FLFP == 1 & $C2  [w = _002_pop] , vce(cluster MxY)
	qui eststo c3: reg r_popf_d5_m treat after TxA i.MOB if high_FLFP == 1 & $C2  [w = _002_pop] , vce(cluster AMRXafter)	
esttab c*, keep(TxA) se star(* 0.10 ** 0.05 *** 0.01)
		






