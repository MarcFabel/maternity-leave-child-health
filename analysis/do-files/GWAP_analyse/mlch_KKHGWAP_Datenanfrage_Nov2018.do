// gdr level

clear all
version 14




/* NOTIZ AN HERRN BERGMANN: 
Insgesammt werden 4 Dateien erstellt, 2 auf Ost/West Ebene, 2 auf der Aggregations-
ebene von Arbeitsmarktregionen.
Zunächst finden alle regressionenn auf Ost-West Ebene statt; danach auf AMR Region.
Pro variable gibt es 3 Tabellen die alle einen ähnlichen Aufbau haben:
Pro Reihe wird eine ökonometrische Spezifikation laufen gelassen, zunächst über 
alle Jahre (Overall), dann für bestimmte Altersgruppen (ab Spalte 2.
Das ganze wird für alle Diagnosen (TOTAL) und für Männer und Frauen dargstellt. 
Die Variable sind immer de Anzahl der jeweiligen Diagnosen geteilt durch 1,000 
Personen in der Altersklasse. 
Neben den Regressionskoeffizienten findet sich die Anzahl der Observationen und 
Durchschnitt und Effektgröße in Standardabweichungen der jeweiligen Baseline
 Vergleichsgruppe.
 
Um die Geheimhaltungsprüfung weiter zu verienfachen möchte ich drauf hinweisen, 
dass sich die Tabellen "wiederholen". Dh die Tabellen sind gleich aufgebaut, nur
für andere outcomes. Z.B die Tabelle für die Diff-diff-diff mit einem Monat Bandbreite wird 
an jedem Eintrag der Tabelle immer dieselben Anzahl an Observationenn aufweisen wie eine andere DDD
Tabelle an der gleichen Stelle. 

*/




********************************************************************************
		*****  Programs  *****
********************************************************************************
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
		qui sum `2' if e(sample) & treat == 1 & after == 0 & GDR==0
		qui estadd scalar mean = round(`r(mean)',.01)
		qui estadd scalar sd = abs(round(_b[FxA]/`r(sd)'*100,.01))		
	end
	
	capture program drop DDD_sclrs
	program define DDD_sclrs
		qui eststo `1': reg `2' treat after FRG TxA FxT FxA FxTxA `3' `4', vce(cluster MxYxFRG)
		qui estadd scalar Nn = e(N)
		qui sum `2' if e(sample) & treat == 1 & after == 0 & GDR==0
		qui estadd scalar mean = round(`r(mean)',.01)
		qui estadd scalar sd = abs(round(_b[FxTxA]/`r(sd)'*100,.01))
	end		

********************************************************************************
// A) GDR LEVEL

use "$temp/KKH_final_gdr_level", clear
qui gen MxYxFRG = MxY * FRG

run "auxiliary_varlists_varnames_sample-spcifications"

/*
Es gibt pro Variable ein text file, in dem alle Ergebnisse reingeschrieben werden

Aufbau des Do-Files: 
1) DDD 
2) andere DD Spezifikation:  (FRG: X|X) vs (GDR: X| X)	
3) GDR (placebo)

zunächst overall effect und dann pro Altersgruppe
*/

foreach 1 of varlist hospital2 d5 {
*initiate file (empty)
	eststo clear 
	DDD_sclrs a d5   	"i.MOB" "if $C2 & $M1"
	esttab a* using "$tables/gdr_level_tables_Ausgabe_`1'_2018_11.txt", replace cells(none) nonumbers noobs nonote noline nogaps nomtitles ///
		prehead("START Document - GDR LEVEL"  "Variable: `1' ($`1')") 

	* define labels	
	foreach j in "" "_f" "_m"{
		if "`j'" == "" {
			local label = "TOTAL"
		}
		if "`j'" == "_f" {
			local label = "WOMEN"
		}
		if "`j'" == "_m" {
			local label = "MEN"
		}
	// DDD (triple-diff model)
		eststo clear
		* overall effect
		DDD_sclrs 	a1 r_fert_`1'`j'   "i.MOB i.year" "if $C2"
		*age group 
		local count = 2
		foreach age_bracket in "$age_17_21" "$age_22_26" "$age_27_31" "$age_32_35" {
			DDD_sclrs 	a`count' r_fert_`1'`j'   "i.MOB i.year" "if $C2 & `age_bracket'"
			local count = `count' + 1
		}
		esttab a* using "$tables/gdr_level_tables_Ausgabe_`1'_2018_11.txt", append ///
			keep(FxTxA) coeflabels(FxTxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label  nonumbers noobs nonote nogaps noline  ///
			mtitles("Overall" "Age 17-21" "Age 22-26" "Age 27-31" "Age 32-35") ///
			prehead("" "" "`label'" "") ///
			scalars("Nn Observ" "mean mean" "sd % sd" )   ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "DDD model")
	
	// alt DD			
		eststo clear 
		DDalt 		b1 r_fert_`1'`j'   "i.MOB i.year" "if treat == 1"
		local count = 2
		foreach age_bracket in "$age_17_21" "$age_22_26" "$age_27_31" "$age_32_35" {
			DDalt 		b`count' r_fert_`1'`j'   "i.MOB i.year" "if treat == 1 & `age_bracket'"
			local count = `count' + 1
		}
		esttab b* using "$tables/gdr_level_tables_Ausgabe_`1'_2018_11.txt", append ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			keep(FxA) coeflabels(FxA "Ratio fertility") ///
			label noobs nonote noline nogaps nomtitles nonum ///
			scalars("Nn Observ" "mean mean" "sd % sd" )   ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "Alternative DD")
		
	// GDR Placebo  	
		eststo clear 
		DDRD_sclrs 	b1 r_fert_`1'`j'   "i.MOB i.year" "if $C2 & GDR == 1"
		local count = 2
		foreach age_bracket in "$age_17_21" "$age_22_26" "$age_27_31" "$age_32_35" {
			DDRD_sclrs 	b`count' r_fert_`1'`j'   "i.MOB i.year" "if $C2 & GDR == 1 & `age_bracket'"
			local count = `count' + 1
		}
		esttab b* using "$tables/gdr_level_tables_Ausgabe_`1'_2018_11.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio fertility") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps nomtitles nonum ///
			scalars("Nn Observ" "mean mean" "sd % sd" )   ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "GDR Placebo") ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)				
	} // end j: tfm
} // end 1: varlist	



/////////////////////////////////////////////////////////////////////////////////
* 	AMR LEVEL
////////////////////////////////////////////////////////////////////////////////
	
	
*****  Own program  *****
capture program drop DDRD_sclrs
	program define DDRD_sclrs
		qui eststo `1': reg `2' treat after TxA  `3'  `4', vce(cluster MxY) //MxYxAMR
		qui estadd scalar Nn = e(N)
		qui sum `2' if e(sample) & treat== 1 & after == 0 
		qui estadd scalar mean = round(`r(mean)',.01)
		qui estadd scalar sd = abs(round(_b[TxA]/`r(sd)'*100,.01))
	end	

********************************************************************************


use ${temp}/KKH_final_amr_level, clear
run "auxiliary_varlists_varnames_sample-spcifications"
sort amr_clean Datum year


	
keep if GDR == 0 // only FRG

/*
Es gibt pro Variable ein text file, in dem alle Ergebnisse reingeschrieben werden

Aufbau des Do-Files: 
1) normale DD (auf AMR Ebene)
2) DD - laendliche Gegenden
3) DD - staedtische Gegenden

zunächst overall effect und dann pro Altersgruppe
*/
		
foreach 1 of varlist hospital2 d5 {
	*initiate file (empty)
	eststo clear 
	DDRD_sclrs a d5   	"i.MOB  i.amr_clean" "if $C2 & $M1"
	esttab a* using "$tables/amr_level_tables_Ausgabe_`1'_2018_11.txt", replace cells(none) nonumbers noobs nonote noline nogaps nomtitles ///
		prehead("START Document - AMR LEVEL"  "Variable: `1' ($`1')") 
	* define labels	
	foreach j in "" "_f" "_m"  { // "" "_f" "_m"
		if "`j'" == "" {
			local label = "TOTAL"
		}
		if "`j'" == "_f" {
			local label = "WOMEN"
		}
		if "`j'" == "_m" {
			local label = "MEN"
		}
		
		// 1) AMR Region
		eststo clear
		DDRD_sclrs c1 r_popf_`1'`j'   "i.MOB i.year i.amr_clean" "if $C2 [w = popweights] "
		local count = 2
		foreach age_bracket in  "$age_22_26" "$age_27_31" "$age_32_35" { // "$age_17_21"
			DDRD_sclrs c`count' r_popf_`1'`j'   "i.MOB i.year i.amr_clean" "if $C2 & `age_bracket' [w = popweights]"
			local count = `count' + 1
		} // end age_bracket
		esttab c* using "$tables/amr_level_tables_Ausgabe_`1'_2018_11.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote noline nogaps ///
			mtitles("Overall"  "Age 24-26" "Age 27-31" "Age 32-35") ///
			prehead("" "" "`label'" "") ///
			scalars("Nn Observ" "mean mean" "sd % sd" )   ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "DD model") ///
			
		// 2) Rural
		eststo clear
		DDRD_sclrs c1 r_popf_`1'`j'  "i.MOB i.year i.amr_clean" "if high_density == 0 & $C2 [w = popweights]"
		local count = 2
		foreach age_bracket in  "$age_22_26" "$age_27_31" "$age_32_35" { // "$age_17_21"
			DDRD_sclrs c`count' r_popf_`1'`j'  "i.MOB i.year i.amr_clean" "if high_density == 0 & $C2 & `age_bracket' [w = popweights]"
			local count = `count' + 1
		} // end age_bracket
		esttab c* using "$tables/amr_level_tables_Ausgabe_`1'_2018_11.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote nogaps noline nomtitles nonum ///
			scalars("Nn Observ" "mean mean" "sd % sd" )   ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "RURAL") ///

		// 3) URBAN
		eststo clear
		DDRD_sclrs c1 r_popf_`1'`j'  "i.MOB i.year i.amr_clean" "if high_density == 1 & $C2 [w = popweights]"
		local count = 2
		foreach age_bracket in  "$age_22_26" "$age_27_31" "$age_32_35" { // "$age_17_21"
			DDRD_sclrs c`count' r_popf_`1'`j'  "i.MOB i.year i.amr_clean" "if high_density == 1 & $C2 & `age_bracket' [w = popweights]"
			local count = `count' + 1
		} // end age_bracket
		esttab c* using "$tables/amr_level_tables_Ausgabe_`1'_2018_11.txt", append ///
			keep(TxA) coeflabels(TxA "Ratio population") ///
			se star(* 0.10 ** 0.05 *** 0.01) ///
			label noobs nonote nogaps noline nomtitles nonum ///
			scalars("Nn Observ" "mean mean" "sd % sd" )   ///
			posthead("--------------------------------------------------------------------------------------------------------------------------------------" "URBAN") ///
			addnotes(--------------------------------------------------------------------------------------------------------------------------------------)
	

	} // end j: gender
} // end 1: varlist	


