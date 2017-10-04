/*******************************************************************************
* File name: 	mlch_KKH_prepare_regionalst_MZ
* Author: 		Marc Fabel
* Date: 		26.09.2017
* Description:	Prepare Regionalstatistik und Mikrozensus
*				1) nimmt Regionalstatistik auf Kreisebene und collspsed auf GDR Ebene
*				2) MZ dranspielen
*
* Inputs:  		$excel/Bevoelkerung_Altersjahre_Geschlecht `i'
*				$MZ/MOB_Distr_GDRFRG.csv
* Outputs:		$temp\bevoelkerung_final.dta
*
* Updates:
*
*******************************************************************************/



// ***************************** PREAMBLE********************************
	clear all
	set more off
	
	global path       "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis" 	//WORK _Windows
*	global path  	  "/Users/marcfabel/econ/m-l-c-h/analysis"					//Mac
	global population "$path/source/population"
	global temp  	  "$path/temp"	
// ***********************************************************************
	

	
	
********************************************************************************
		*****  Erster Schritt, Regionalstatistik  *****
********************************************************************************

{ // *** 49 Bevölkerung in Altersjahre (population) *** 

*erst ab Welle 2003, frühere Jahre sind in der Regionalstatistik nicht verfügbar

forvalues i = 2005(1)2013 {


	import excel "$population/49 Bevoelkerung Altersjahre/Bevoelkerung_Altersjahre_Geschlecht `i'.xlsx", ///
		/*cellrange(A29:L9460)*/ clear
		
		*import excel "$excel\49 Bevoelkerung Altersjahre\Bevoelkerung_Altersjahre_Geschlecht 2005.xlsx", clear

	gen _d="december31" 

	rename A lkrid
	label var lkrid "Landkreis(ID)"
	rename B lkr
	label var lkr "Landkreis" 
	rename C agegroup
	rename D ypop_
	rename E ypop_m
	rename F ypop_f


	replace lkrid=lkrid[_n-1] if lkrid==""
	replace lkr=lkr[_n-1] if lkr=="" 
	drop if ypop_=="" & ypop_m=="" & ypop_f==""
	drop if lkr==""
	
	replace lkrid="00" if lkrid=="DG"
	/*destring lkrid, replace ignore("DG")*/
	destring lkrid, replace  
	
	
	
	/// ACHTUNG UNTERSCHIED ZU BEVOR; ICH GEHE UEBER DIE BUNDESLAENDER!!!! 
	keep if lkrid >= 1 & lkrid <= 16
	
	
	gen year=`i'
	label var year "Year" 
	
	
	//reshape in long format[own lines]
	gen temp = substr(agegroup,1,2)
	*transform to a string 2
	capture drop temp2
	gen temp2 = string(real(temp))
	// NEU EINGEFÜGT,NUR RELVANTE KOHORTEN EINFÜGEN
		destring temp2, gen(temp3)
		//generate YOB = year - temp3
		qui gen YOB = year - temp3
		*nur die relevanten Jahrgänge drinbehalten
		keep if YOB >= 1976 & YOB <=1980 | ///
				YOB >= 1985 & YOB <=1995 

		
		*replace temp2 = "all" if agegroup=="Insgesamt"
	*drop Personen  älter als 74 Jahre & jünger als ein Jahr
		*drop if temp == "un" //unter einem Jahr
		*drop if temp2 == "75" | temp2 == "80" | temp2 == "85"
	*	capture drop if temp2 == "90" // only present in some years
	//Ende Veränderungen

	drop agegroup temp*
	
	
	// gen GDR
	qui gen GDR = .
	qui replace GDR = cond(lkrid>=11,1,0)
	
	
	//auf GDR collapsen
	qui destring, replace ignore ("-" ".")	
	collapse (sum) ypop* , by(year YOB GDR) 
	
	
	*order lkrid lkr year 

	if `i'==2005{
		save "$temp/bevoelkerung_prepare.dta", replace

		}
			
	else{
		append using "$temp/bevoelkerung_prepare.dta" 
		*sort lkrid lkr year
		*sort lkrid lkr year gender
		
		*drop goettingen krs
		*drop if lkrid == 3159
		save "$temp/bevoelkerung_prepare.dta", replace
		sort GDR year YOB 
		} 

}
}



////////////////
//		Schritt 2: 
////////////////

*Regionalstatistik an die Mikrozensusgewichte ranmergen

	*MZ Gewichte aufrufen
	import delim using "$population/MOB_Distr_GDRFRG.csv", clear
	rename v1 MOB
	rename v2 year
	rename v3 YOB
	rename v4 GDR
	rename v5 ratio_GDR
	rename v6 ratio_GDR_male
	rename v7 ratio_GDR_female
	drop v8 v9 v10
	gen temp = _n	// Hilfsvariable, die das löschen der Variablennamen in den Einträgen ermöglicht
	drop if temp <= 2
	drop temp
	destring, replace
	*auf relevantes sample beschränken
	keep if (YOB >=1976 & YOB<=1980) | (YOB>=1985 & YOB<=1995)	
	
	*ratios durch 100 teilen
	foreach var of varlist ratio* {
		qui replace `var' = `var' /100
	}
	

	// MERGE
	merge m:1 year YOB GDR using "$temp/bevoelkerung_prepare"
	drop _merge
	
	sort GDR year YOB MOB
	
	//Bevoelkerung pro Geburtsmonat
	qui gen bev = round(ratio_GDR * ypop_)
	qui gen bevf = round(ratio_GDR_female * ypop_f)
	qui gen bevm = round(ratio_GDR_male * ypop_m)
	drop  ypop* //ratio*
	order year GDR YOB MOB
	
	save "$temp/bevoelkerung_final.dta", replace
	
	
	
	
////////////////
//		Schritt 3: Destatis Daten zur urspr�nglichen Bev�lkerung mitaufnehmen 
////////////////	
	import excel "$population/destatis_fertility_long.xlsx", sheet("Sheet 1") cellrange(A1:E194) clear
	rename A YOB 
	rename B mt		//auxiliary variable, has to be transformed
	rename C fertm
	rename D fertf
	rename E fert
	
	label var fert "Fertility birthyear (total)"
	label var fertm "Fertility birthyear (male)"
	label var fertf "Fertility birthyear (female)"
	
	gen temp = _n	// Hilfsvariable, die das löschen der Variablennamen in den Einträgen ermöglicht
	drop if temp <= 2
	drop temp
	
	
	qui gen MOB = 1 if mt == "Januar" 
	qui replace MOB = 2 if mt == "Februar"
	qui replace MOB = 3 if mt == "März"
	qui replace MOB = 4 if mt == "April"
	qui replace MOB = 5 if mt == "Mai"
	qui replace MOB = 6 if mt == "Juni"
	qui replace MOB = 7 if mt == "Juli"
	qui replace MOB = 8 if mt == "August"
	qui replace MOB = 9 if mt == "September"
	qui replace MOB = 10 if mt == "Oktober"
	qui replace MOB = 11 if mt == "November"
	qui replace MOB = 12 if mt == "Dezember"
	drop mt
	
	destring, replace
	qui gen GDR = 0		// nur für Westdeutschland
	
	merge 1:m MOB YOB GDR using "$temp/bevoelkerung_final"
	drop _merge 
	
	save "$temp/bevoelkerung_final.dta", replace

	



	
