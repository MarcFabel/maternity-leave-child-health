// gdr level

clear all
version 14




/* NOTIZ AN HERRN BERGMANN: 

zunächst finden alle regressionenn auf Ost-West Ebene statt; danach auf AMR Region.
Pro variable gibt es mehrere Tabellen die alle einen ähnlichen Aufbau haben: 
Die Tabellen haben 6 Reihen, wobei je 2 Reihen sich auf alle Fälle, nur Frauen, 
und nur Männer beziehen. Die 2 Reihen sind unterschiedliche Spezifikationen. Die 
Idee ist die Anzahl der Diagnosen pro Geburtmonat entsprechend der entsprechenden
Grundgesammtheit zu gewichten. Die erste Spezifikation Ratio fertility (r_fert_DIAGNOSE)
gibt die Anzahl der Diagnosen pro 1000 geburten an. Die zweite Spezifikation 
Ratio popuation (r_popf_DIAGNOSE) gibt die Anzahl pro 1000 Personen in dem Alter
an (approximation). 
Jeder Koeffizient gibt an wieviele Observationen hinter der regression an und was
der baseline durchschnitt und Standardabweichung ist. 
Um die Geheimhaltungsprüfung weiter zu verienfachen möchte ich drauf hinweisen, 
dass sich die Tabellen "wiederholen". Dh die Tabellen sind gleich aufgebaut, nur
für andere outcomes. Z.B die Tabelle für die Diff-diff-diff mit einem Monat Bandbreite wird 
an jedem Eintrag der Tabelle immer dieselben Anzahl an Observationenn aufweisen wie eine andere DDD
Tabelle an der gleichen Stelle. 



*/




********************************************************************************
		*****  Programs  *****
********************************************************************************
	capture program drop DDRD
	program define DDRD
		qui eststo `1': reg `2' treat after TxA   `3'  `4', vce(cluster MxY) 
	end
	
	capture program drop DDRD_sclrs
	program define DDRD_sclrs
		qui eststo `1': reg `2' treat after TxA  `3'  `4', vce(cluster MxY) 	// Regression
		qui estadd scalar Nn = e(N)												// Anzahl Observationen als Skalar hinzufuegen
		qui sum `2' if e(sample) & treat== 1 & after == 0 						// Summary: abhaengige Variable fuer treatment cohorte im pre-refrom Zustand
		qui estadd scalar mean = round(`r(mean)',.01)							// Skalar Arithmetisches Mittel hinzufuegen
		qui estadd scalar sd = abs(round(_b[TxA]/`r(sd)'*100,.01))				// Skalar: relative Effektgröße im Bezug zur Standardabweichung hinzufuegen (Effekt/sd)
	end	
	
	capture program drop DDalt
	program define DDalt
		qui eststo `1': reg `2' after FRG FxA   `3'  `4', vce(cluster MxYxFRG) 
		qui estadd scalar Nn = e(N)
		qui sum `2' if e(sample) & treat == 1 & after == 0
		qui estadd scalar mean = round(`r(mean)',.01)
		qui estadd scalar sd = abs(round(_b[FxA]/`r(sd)'*100,.01))		
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
2) GDR (placebo)
	- different bandwidths	
3) andere DD Spezifikation:  (FRG: X|X) vs (GDR: X| X)

*/

********************************************************************************

global liste_1 "d5 respiratory_index metabolic_syndrome hospital"
global liste_2 "drug_abuse	shizophrenia affective neurosis personality childhood" 
global liste_3 "lung_infect	pneumonia lung_chron asthma" 

*initiate file (empty)
	eststo clear 
	DDD a d5   	"i.MOB" "if $C2 & $M1"
	esttab a* using "$tables/gdr_level_tables_Ausgabe.txt", replace cells(none) nonumbers noobs nonote noline nogaps nomtitles ///
		prehead("START Document - GDR LEVEL"  "") 
********************************************************************************
// A) JUST LIST 1

	// 1.) DDD - different bandwidths (month of birth - 1 month 2 months .... Donut means the middle months are exlcuded)
	foreach 1 of varlist $liste_1 { //  $liste_1
		foreach j in "" { // "_f" "_m"
		// TOTAL
			eststo clear 
			*ratio fertility
			DDD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"					// nur Controlgruppe 2 (eine Kohorte davor geboren) und eine Bandbreite von einem Monat
			DDD_sclrs b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"					// nur Controlgruppe 2 (eine Kohorte davor geboren) und eine Bandbreite von zwei Monaten
			DDD_sclrs b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
			DDD_sclrs b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
			DDD_sclrs b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
			DDD_sclrs b6 r_fert_`1'`j'   "i.MOB" "if $C2"
			DDD_sclrs b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
			esttab b* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
				keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label  nonumbers noobs nonote nogaps noline  ///
				mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
				prehead("" "" "START `1': $`1'" "DDD - Overview for different bandwidths"  "") ///
				scalars("Nn Observ" "mean mean" "sd % sd" )   ///
				posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
			
				
			*ratio population
			DDD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
			DDD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
			DDD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
			DDD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
			DDD_sclrs c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
			DDD_sclrs c6 r_popf_`1'`j'   "i.MOB" "if $C2"
			DDD_sclrs c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
			esttab c* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
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
			*ratio fertility
			DDD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
			DDD_sclrs b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
			DDD_sclrs b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
			DDD_sclrs b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
			DDD_sclrs b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
			DDD_sclrs b6 r_fert_`1'`j'   "i.MOB" "if $C2"
			DDD_sclrs b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
			esttab b* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
				keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label noobs nonote noline nogaps nonumbers ///
				title("WOMEN") nomtitles  ///
				scalars("Nn Observ" "mean mean" "sd % sd")    	
				
			*ratio population
			DDD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
			DDD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
			DDD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
			DDD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
			DDD_sclrs c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
			DDD_sclrs c6 r_popf_`1'`j'   "i.MOB" "if $C2"
			DDD_sclrs c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
			esttab c* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
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
			*ratio fertility
			DDD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
			DDD_sclrs b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
			DDD_sclrs b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
			DDD_sclrs b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
			DDD_sclrs b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
			DDD_sclrs b6 r_fert_`1'`j'   "i.MOB" "if $C2"
			DDD_sclrs b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
			esttab b* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
				keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label noobs nonote noline ///
				title("MEN") nomtitles nonumbers nogaps ///
				scalars("Nn Observ" "mean mean" "sd % sd")   	
				
			*ratio population
			DDD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
			DDD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
			DDD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
			DDD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
			DDD_sclrs c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
			DDD_sclrs c6 r_popf_`1'`j'   "i.MOB" "if $C2"
			DDD_sclrs c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
			esttab c* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
				keep(FxTxA) coeflabels(FxTxA "Ratio population") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label nomtitles nonumbers noobs nonote nogaps noline  ///
				prehead("") ///
				scalars("Nn Observ" "mean mean" "sd % sd")   ///
				addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
		}
	
********************************************************************************
	// 2) GDR PLACEBO
	preserve
	keep if GDR == 1			
	
		foreach j in "" { // "_f" "_m"
		// TOTAL
			eststo clear 
			*ratio fertility
			DDRD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
			DDRD_sclrs b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
			DDRD_sclrs b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
			DDRD_sclrs b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
			DDRD_sclrs b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
			DDRD_sclrs b6 r_fert_`1'`j'   "i.MOB" "if $C2"
			DDRD_sclrs b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
			esttab b* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
				keep(TxA) coeflabels(TxA "Ratio fertility") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label noobs nonote noline nogaps ///
				mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
				prehead("" "" "" "" "`1'" "DD - GDR placebo"  "") ///
				scalars("Nn Observ" "mean mean" "sd % sd" )   ///
				posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
			
				
			*ratio population
			DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
			DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
			DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
			DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
			DDRD_sclrs c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
			DDRD_sclrs c6 r_popf_`1'`j'   "i.MOB" "if $C2"
			DDRD_sclrs c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
			esttab c* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
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
			*ratio fertility
			DDRD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
			DDRD_sclrs b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
			DDRD_sclrs b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
			DDRD_sclrs b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
			DDRD_sclrs b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
			DDRD_sclrs b6 r_fert_`1'`j'   "i.MOB" "if $C2"
			DDRD_sclrs b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
			esttab b* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
				keep(TxA) coeflabels(TxA "Ratio fertility") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label noobs nonote noline nogaps nonumbers ///
				scalars("Nn Observ" "mean mean" "sd % sd" )   ///
				title("WOMEN") nomtitles		
				
			*ratio population
			DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
			DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
			DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
			DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
			DDRD_sclrs c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
			DDRD_sclrs c6 r_popf_`1'`j'   "i.MOB" "if $C2"
			DDRD_sclrs c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
			esttab c* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
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
			*ratio fertility
			DDRD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
			DDRD_sclrs b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
			DDRD_sclrs b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
			DDRD_sclrs b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
			DDRD_sclrs b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
			DDRD_sclrs b6 r_fert_`1'`j'   "i.MOB" "if $C2"
			DDRD_sclrs b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
			esttab b* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
				keep(TxA) coeflabels(TxA "Ratio fertility") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label noobs nonote noline ///
				scalars("Nn Observ" "mean mean" "sd % sd" )   ///
				title("MEN") nomtitles nonumbers nogaps		
				
			*ratio population
			DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
			DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
			DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
			DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
			DDRD_sclrs c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
			DDRD_sclrs c6 r_popf_`1'`j'   "i.MOB" "if $C2"
			DDRD_sclrs c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
			esttab c* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
				keep(TxA) coeflabels(TxA "Ratio population") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label nomtitles nonumbers noobs nonote nogaps noline ///
				prehead("") ///
				scalars("Nn Observ" "mean mean" "sd % sd")   ///
				addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
		}
	
	restore // end:only GDR		
********************************************************************************
	// 3) alternative DD specification, overview bandwidth
	preserve
	keep if treat == 1 
		foreach j in "" { // "_f" "_m"
		// TOTAL
			eststo clear 
			*ratio fertility
			DDalt b1 r_fert_`1'`j'   "i.MOB" "if  $M1"
			DDalt b2 r_fert_`1'`j'   "i.MOB" "if  $M2"
			DDalt b3 r_fert_`1'`j'   "i.MOB" "if  $M3"
			DDalt b4 r_fert_`1'`j'   "i.MOB" "if  $M4"
			DDalt b5 r_fert_`1'`j'   "i.MOB" "if  $M5"
			DDalt b6 r_fert_`1'`j'   "i.MOB" " 		 "
			DDalt b7 r_fert_`1'`j'   "i.MOB" "if  $MD"
			esttab b* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
				keep(FxA) coeflabels(FxA "Ratio fertility") ///
				label noobs nonote noline nogaps ///
				mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
				prehead("" "" "" """`1'" "ALTERNATIVE DD (CG: same birth cohort in GDR) - Overview for different bandwidths (FRG+GDR)"  "") ///
				scalars("Nn Observ" "mean mean" "sd % sd" )   ///
				posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
		
			*ratio population
			DDalt c1 r_popf_`1'`j'   "i.MOB" "if  $M1"
			DDalt c2 r_popf_`1'`j'   "i.MOB" "if  $M2"
			DDalt c3 r_popf_`1'`j'   "i.MOB" "if  $M3"
			DDalt c4 r_popf_`1'`j'   "i.MOB" "if  $M4"
			DDalt c5 r_popf_`1'`j'   "i.MOB" "if  $M5"
			DDalt c6 r_popf_`1'`j'   "i.MOB" "  	 "
			DDalt c7 r_popf_`1'`j'   "i.MOB" "if  $MD"
			esttab c* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
				keep(FxA) coeflabels(FxA "Ratio population") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label nomtitles nonumbers noobs nonote nogaps noline ///
				prehead("") ///
				scalars("Nn Observ" "mean mean" "sd % sd")   ///
				addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
		}
		foreach j in "_f" { //  "_m"
		// FEMALE
			eststo clear 
			*ratio fertility
			DDalt b1 r_fert_`1'`j'   "i.MOB" "if  $M1"
			DDalt b2 r_fert_`1'`j'   "i.MOB" "if  $M2"
			DDalt b3 r_fert_`1'`j'   "i.MOB" "if  $M3"
			DDalt b4 r_fert_`1'`j'   "i.MOB" "if  $M4"
			DDalt b5 r_fert_`1'`j'   "i.MOB" "if  $M5"
			DDalt b6 r_fert_`1'`j'   "i.MOB" " 		 "
			DDalt b7 r_fert_`1'`j'   "i.MOB" "if  $MD"
			esttab b* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
				keep(FxA) coeflabels(FxA "Ratio fertility") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label noobs nonote noline nogaps nonumbers ///
				scalars("Nn Observ" "mean mean" "sd % sd" )   ///
				title("WOMEN") nomtitles 	
			*ratio population
			DDalt c1 r_popf_`1'`j'   "i.MOB" "if $M1"
			DDalt c2 r_popf_`1'`j'   "i.MOB" "if $M2"
			DDalt c3 r_popf_`1'`j'   "i.MOB" "if $M3"
			DDalt c4 r_popf_`1'`j'   "i.MOB" "if $M4"
			DDalt c5 r_popf_`1'`j'   "i.MOB" "if $M5"
			DDalt c6 r_popf_`1'`j'   "i.MOB" "		"
			DDalt c7 r_popf_`1'`j'   "i.MOB" "if $MD"
			esttab c* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
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
			*ratio fertility
			DDalt b1 r_fert_`1'`j'   "i.MOB" "if  $M1"
			DDalt b2 r_fert_`1'`j'   "i.MOB" "if  $M2"
			DDalt b3 r_fert_`1'`j'   "i.MOB" "if  $M3"
			DDalt b4 r_fert_`1'`j'   "i.MOB" "if  $M4"
			DDalt b5 r_fert_`1'`j'   "i.MOB" "if  $M5"
			DDalt b6 r_fert_`1'`j'   "i.MOB" " 		 "
			DDalt b7 r_fert_`1'`j'   "i.MOB" "if  $MD"
			esttab b* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
				keep(FxA) coeflabels(FxA "Ratio fertility") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label noobs nonote noline ///
				scalars("Nn Observ" "mean mean" "sd % sd" )   ///
				title("MEN") nomtitles nonumbers nogaps	
			*ratio population
			DDalt c1 r_popf_`1'`j'   "i.MOB" "if $M1"
			DDalt c2 r_popf_`1'`j'   "i.MOB" "if $M2"
			DDalt c3 r_popf_`1'`j'   "i.MOB" "if $M3"
			DDalt c4 r_popf_`1'`j'   "i.MOB" "if $M4"
			DDalt c5 r_popf_`1'`j'   "i.MOB" "if $M5"
			DDalt c6 r_popf_`1'`j'   "i.MOB" "		"
			DDalt c7 r_popf_`1'`j'   "i.MOB" "if $MD"
			esttab c* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
				keep(FxA) coeflabels(FxA "Ratio population") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label nomtitles nonumbers noobs nonote nogaps noline ///
				prehead("") ///
				scalars("Nn Observ" "mean mean" "sd % sd")   ///
				addnotes("--------------------------------------------------------------------------------------------------------------------------------------")
				
		}
		// END MARK OF VARIABLE
		esttab c* using "$tables/gdr_level_tables_Ausgabe.txt", append  ///
				cells(none) nonote  noobs noline nomtitles nonumbers nogaps  ///
				addnotes("" "END: `1'" "MWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMW")				
	restore	// end:restore just treat == 1		
	********************************************************************************		
	} // end: varlist

	
////////////////////////////////////////////////////////////////////////////////
/////////////////////				Subcategories			     ///////////////
////////////////////////////////////////////////////////////////////////////////

// Subkategorien: DD Overview & LC


preserve
keep if GDR == 0

		
foreach 1 of varlist $liste_2 $liste_3 { // $liste_2 $liste_3
	//DD OVERVIEW
	foreach j in "" { // "_f" "_m"
	// TOTAL
		eststo clear 
		*ratio fertility
		DDRD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD_sclrs b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD_sclrs b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD_sclrs b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD_sclrs b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD_sclrs b6 r_fert_`1'`j'   "i.MOB" "if $C2"
		DDRD_sclrs b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab b* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps ///
			mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
			prehead("" "" "" "START `1': $`1'" "DDRD - Overview for different bandwidths"  "") ///
			scalars("Nn Observ" "mean mean" "sd % sd" )   ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL")
   
			
		*ratio population
		DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD_sclrs c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD_sclrs c6 r_popf_`1'`j'   "i.MOB" "if $C2"
		DDRD_sclrs c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab c* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
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
		*ratio fertility
		DDRD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD_sclrs b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD_sclrs b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD_sclrs b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD_sclrs b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD_sclrs b6 r_fert_`1'`j'   "i.MOB" "if $C2"
		DDRD_sclrs b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab b* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nonumbers ///
			title("WOMEN") nomtitles ///
			scalars("Nn Observ" "mean mean" "sd % sd" )
			
		*ratio population
		DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD_sclrs c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD_sclrs c6 r_popf_`1'`j'   "i.MOB" "if $C2"
		DDRD_sclrs c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab c* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
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
		*ratio fertility
		DDRD_sclrs b1 r_fert_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD_sclrs b2 r_fert_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD_sclrs b3 r_fert_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD_sclrs b4 r_fert_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD_sclrs b5 r_fert_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD_sclrs b6 r_fert_`1'`j'   "i.MOB" "if $C2"
		DDRD_sclrs b7 r_fert_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab b* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline ///
			title("MEN") nomtitles nonumbers nogaps ///
			scalars("Nn Observ" "mean mean" "sd % sd" )  
			
		*ratio population
		DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $M1"
		DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $M2"
		DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $M3"
		DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $M4"
		DDRD_sclrs c5 r_popf_`1'`j'   "i.MOB" "if $C2 & $M5"
		DDRD_sclrs c6 r_popf_`1'`j'   "i.MOB" "if $C2"
		DDRD_sclrs c7 r_popf_`1'`j'   "i.MOB" "if $C2 & $MD"
		esttab c* using "$tables/gdr_level_tables_Ausgabe.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	} // end: men

**********************************************************************************
// Life -course
	foreach j in "" { // "_f" "_m"
		eststo clear 
		*ratio fertility
		DDRD_sclrs a1 r_fert_`1'`j'   	"i.MOB" "if $C2 & $age_17_21 "
		DDRD_sclrs a2 r_fert_`1'`j'   	"i.MOB" "if $C2 & $age_22_26 "
		DDRD_sclrs a3 r_fert_`1'`j'   	"i.MOB" "if $C2 & $age_27_31 "
		DDRD_sclrs a4 r_fert_`1'`j'   	"i.MOB" "if $C2 & $age_32_35 "
		esttab a* using "$tables/gdr_level_tables_Ausgabe.txt", append  ///
			keep(TxA) coeflabels(TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nonumbers noobs nonote nogaps noline ///
			mtitles("Age 17-21" "Age 22-26" "Age 27-31" "Age 32-35" ) ///
			prehead("" "" "" """`1'" "DD - life-course (FRG only)" "") ///
			scalars("Nn Observ" "mean mean" "sd % sd" )   ///
			posthead("--------------------------------------------------------------------------------------" "TOTAL")
		
		*ratio population
		*DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_17_21"
		DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_22_26 "
		DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_27_31 "
		DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_32_35 "
		esttab c* using "$tables/gdr_level_tables_Ausgabe.txt", append  ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------)						
	} 
	foreach j in "_f" { // "_f" "_m"
	// Women
		eststo clear 
		*ratio fertility
		DDRD_sclrs a1 r_fert_`1'`j'   	"i.MOB" "if $C2 & $age_17_21 "
		DDRD_sclrs a2 r_fert_`1'`j'   	"i.MOB" "if $C2 & $age_22_26 "
		DDRD_sclrs a3 r_fert_`1'`j'   	"i.MOB" "if $C2 & $age_27_31 "
		DDRD_sclrs a4 r_fert_`1'`j'   	"i.MOB" "if $C2 & $age_32_35 "
		esttab a* using "$tables/gdr_level_tables_Ausgabe.txt", append  ///
			keep(TxA) coeflabels(TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nonumbers noobs nonote nogaps noline ///
			scalars("Nn Observ" "mean mean" "sd % sd" )   ///
			title("WOMEN") nomtitles
			
		*ratio population
		*DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_17_21"
		DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_22_26 "
		DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_27_31 "
		DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_32_35 "
		esttab c* using "$tables/gdr_level_tables_Ausgabe.txt", append  ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------)					
	}
	foreach j in "_m" { // "_f" "_m"
	// MEN
		eststo clear 
		*ratio fertility
		DDRD_sclrs a1 r_fert_`1'`j'   	"i.MOB" "if $C2 & $age_17_21 "
		DDRD_sclrs a2 r_fert_`1'`j'   	"i.MOB" "if $C2 & $age_22_26 "
		DDRD_sclrs a3 r_fert_`1'`j'   	"i.MOB" "if $C2 & $age_27_31 "
		DDRD_sclrs a4 r_fert_`1'`j'   	"i.MOB" "if $C2 & $age_32_35 "
		esttab a* using "$tables/gdr_level_tables_Ausgabe.txt", append  ///
			keep(TxA) coeflabels(TxA "Ratio fertlity") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nonumbers noobs nonote nogaps noline ///
			scalars("Nn Observ" "mean mean" "sd % sd" )   ///
			title("MEN") nomtitles
		
		*ratio population
		*DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_17_21"
		DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_22_26 "
		DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_27_31 "
		DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB" "if $C2 & $age_32_35 "
		esttab c* using "$tables/gdr_level_tables_Ausgabe.txt", append  ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label nomtitles nonumbers noobs nonote nogaps noline ///
			prehead("") ///
			scalars("Nn Observ" "mean mean" "sd % sd")   ///
			addnotes(--------------------------------------------------------------------------------------)					
	} // end: tfm
	// END MARK OF VARIABLE
	esttab c* using "$tables/gdr_level_tables_Ausgabe.txt", append  ///
		cells(none) nonote  noobs noline nomtitles nonumbers nogaps  ///
		addnotes("" "END: `1'" "MWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMW")				

} // end:varlist
restore // end: FRG only
		

////////////////////////////////////////////////////////////////////////////////		
////////////////////////////////////////////////////////////////////////////////		
////////////////////////////////////////////////////////////////////////////////		
/////////////////////		AMR LEVEL	   /////////////////////////////////////		
////////////////////////////////////////////////////////////////////////////////	
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////	




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
		qui eststo `1': reg `2' treat after TxA   `3'  `4', vce(cluster MxY) 
	end
	
capture program drop DDRD_sclrs
	program define DDRD_sclrs
		qui eststo `1': reg `2' treat after TxA  `3'  `4', vce(cluster MxY) //MxYxAMR
		qui estadd scalar Nn = e(N)
		qui sum `2' if e(sample) & treat== 1 & after == 0 
		qui estadd scalar mean = round(`r(mean)',.01)
		qui estadd scalar sd = abs(round(_b[TxA]/`r(sd)'*100,.01))
	end	
	
capture program drop DDalt
	program define DDalt
		qui eststo `1': reg `2' after FRG FxA   `3'  `4', vce(cluster MxYxFRG)
		qui estadd scalar Nn = e(N)
		qui sum `2' if e(sample) & treat == 1 & after == 0
		qui estadd scalar mean = round(`r(mean)',.01)
		qui estadd scalar sd = abs(round(_b[FxA]/`r(sd)'*100,.01))		
	end
	
capture program drop DDxLFP
	program define DDxLFP
	qui  eststo `1': reg `2' treat after FLFP_2001 TxA TxFLFP AxFLFP TxAxFLFP `3'  `4', vce(cluster MxY) 
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
	end	
********************************************************************************

/* Aufbau des Do-Files
1) DD
	- normal overview
		* a) choice of bandwidth
	- sample splits für heterogeneity analysis 
		* c) urban/rural 
		
	- 	
*/

********************************************************************************
	
use ${temp}/KKH_final_amr_level, clear
run "auxiliary_varlists_varnames_sample-spcifications"
sort amr_clean Datum year


*initiate file (empty)
	eststo clear 
	DDD a d5   	"i.MOB i.amr_clean" "if $C2 & $M1"
	esttab a* using "$tables/amr_level_tables_Ausgabe.txt", replace cells(none) nonumbers noobs nonote noline nogaps nomtitles ///
		prehead("START Document - AMR LEVEL"  "") 

********************************************************************************
* ONLY FRG!!!!!!!!!!!!
preserve
keep if GDR == 0
foreach 1 of varlist $liste_1 { // $liste_1
	
	* 1.a) DDRD - different bandwidths (month of birth)
		foreach j in "" { // "_f" "_m"
		// TOTAL
			eststo clear 
			*ratio population
			DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
			DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
			DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
			DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
			DDRD_sclrs c5 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
			DDRD_sclrs c6 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
			DDRD_sclrs c7 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
			esttab c* using "$tables/amr_level_tables_Ausgabe.txt", append ///
				keep(TxA) coeflabels(TxA "Ratio population") ///
				label noobs nonote noline nogaps ///
				mtitles("1M" "2M" "3M" "4M" "5M" "6M" "Donut") ///
				prehead("" "" "START `1': $`1'" "DDRD_sclrs - Overview for different bandwidths (FRG only)"  "") ///
				scalars("Nn Observ" "mean mean" "sd % sd" )   ///
				posthead("--------------------------------------------------------------------------------------------------------------------------------------" "TOTAL") ///
				addnotes(--------------------------------------------------------------------------------------------------------------------------------------)
		}
		foreach j in "_f"{ //  "_m"
		// FEMALE
			eststo clear 
			*ratio population
			DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
			DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
			DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
			DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
			DDRD_sclrs c5 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
			DDRD_sclrs c6 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
			DDRD_sclrs c7 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
			esttab c* using "$tables/amr_level_tables_Ausgabe.txt", append ///
				keep(TxA) coeflabels(TxA "Ratio population") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label noobs nonote noline nogaps nonumbers ///
				title("WOMEN") nomtitles ///
				scalars("Nn Observ" "mean mean" "sd % sd") ///
				addnotes(--------------------------------------------------------------------------------------------------------------------------------------)
		}
		foreach j in "_m" { // "" "_f" 
		// MEN
			eststo clear 
			*ratio population
			DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M1 [w = popweights]"
			DDRD_sclrs c2 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M2 [w = popweights]"
			DDRD_sclrs c3 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M3 [w = popweights]"
			DDRD_sclrs c4 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M4 [w = popweights]"
			DDRD_sclrs c5 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $M5 [w = popweights]"
			DDRD_sclrs c6 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 [w = popweights]"
			DDRD_sclrs c7 r_popf_`1'`j'   "i.MOB i.amr_clean" "if $C2 & $MD [w = popweights]"
			esttab c* using "$tables/amr_level_tables_Ausgabe.txt", append ///
				keep(TxA) coeflabels(TxA "Ratio population") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label noobs nonote noline ///
				title("MEN") nomtitles nonumbers nogaps ///
				scalars("Nn Observ" "mean mean" "sd % sd" )
		}
		
********************************************************************************
	*1.c) DD - sample split according to rural/urban
		foreach j in "" { // "_f" "_m"
		// TOTAL
			eststo clear 
			*ratio population 
			DDRD_sclrs c1 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M2 [w = popweights]"
			DDRD_sclrs c2 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M4 [w = popweights]"
			DDRD_sclrs c3 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 [w = popweights]"
			DDRD_sclrs c4 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $MD [w = popweights]"
			DDRD_sclrs c5 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M2 [w = popweights]"
			DDRD_sclrs c6 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M4 [w = popweights]"
			DDRD_sclrs c7 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 [w = popweights]"
			DDRD_sclrs c8 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $MD [w = popweights]"
			esttab c* using "$tables/amr_level_tables_Ausgabe.txt", append ///
				keep(TxA) coeflabels(TxA "Ratio population") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label noobs nonote nogaps noline ///
				mtitles("2M" "4M" "6M" "Donut" "2M" "4M" "6M" "Donut") ///
				mgroups("Rural" "Urban", pattern(1 0 0 0 1 0 0 0)) /// 
				prehead("" "" "" "`1'"  "DD - HETEROGENEITY analysis (RURAL vs. URBAN) (FRG only)"  "") ///
				scalars("Nn Observ" "mean mean" "sd % sd" )   ///
				posthead("--------------------------------------------------------------------------------------------------------------------------------------------------------" "TOTAL") ///
				addnotes(--------------------------------------------------------------------------------------------------------------------------------------------------------)
				
			} // end: total
		foreach j in "_f" { // "_f" "_m"
		// FEMALE
			eststo clear 
			*ratio population 
			DDRD_sclrs c1 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M2 [w = popweights]"
			DDRD_sclrs c2 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M4 [w = popweights]"
			DDRD_sclrs c3 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 [w = popweights]"
			DDRD_sclrs c4 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $MD [w = popweights]"
			DDRD_sclrs c5 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M2 [w = popweights]"
			DDRD_sclrs c6 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M4 [w = popweights]"
			DDRD_sclrs c7 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 [w = popweights]"
			DDRD_sclrs c8 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $MD [w = popweights]"
			esttab c* using "$tables/amr_level_tables_Ausgabe.txt", append ///
				keep(TxA) coeflabels(TxA "Ratio population") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label noobs nonote noline nogaps nonumbers ///
				scalars("Nn Observ" "mean mean" "sd % sd" )   ///
				title("WOMEN") nomtitles ///
				addnotes(--------------------------------------------------------------------------------------------------------------------------------------------------------)
		} // end: female
		foreach j in "_m" { // "_f" "_m"
		// MALE
			eststo clear 
			*ratio population 
			DDRD_sclrs c1 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M2 [w = popweights]"
			DDRD_sclrs c2 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $M4 [w = popweights]"
			DDRD_sclrs c3 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 [w = popweights]"
			DDRD_sclrs c4 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 0 & $C2 & $MD [w = popweights]"
			DDRD_sclrs c5 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M2 [w = popweights]"
			DDRD_sclrs c6 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $M4 [w = popweights]"
			DDRD_sclrs c7 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 [w = popweights]"
			DDRD_sclrs c8 r_popf_`1'`j'   	"i.MOB i.amr_clean" "if high_density == 1 & $C2 & $MD [w = popweights]"
			esttab c* using "$tables/amr_level_tables_Ausgabe.txt", append ///
				keep(TxA) coeflabels(TxA "Ratio population") ///
				se star(* 0.10 ** 0.05 *** 0.01) ///
				label noobs nonote noline nogaps nonumbers ///
				scalars("Nn Observ" "mean mean" "sd % sd" )   ///
				title("MEN") nomtitles
		} // end: men
		
		
	// END MARK OF VARIABLE
	esttab c* using "$tables/amr_level_tables_Ausgabe.txt", append  ///
		cells(none) nonote  noobs noline nomtitles nonumbers nogaps  ///
		addnotes("" "END: `1'" "MWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMW")				

				
} // end: varlist
restore // end: keep only FRG

********************************************************************************

