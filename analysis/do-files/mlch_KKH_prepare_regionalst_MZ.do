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
	
	global path  "F:\econ\m-l-c-h\analysis"
	global excel "G:\Projekte\Projekte_ab2016\EcUFam\Daten\Regionaldatenbank\Data\Excel\Rohdaten"
	global MZ    "F:\KKH_Diagnosedaten\"
	global temp  "$path/temp"	
// ***********************************************************************
	

	
********************************************************************************
		*****  Erster Schritt, Regionalstatistik  *****
********************************************************************************

{ // *** 49 Bevölkerung in Altersjahre (population) *** 

*erst ab Welle 2003, frühere Jahre sind in der Regionalstatistik nicht verfügbar

forvalues i = 2005(1)2013{


	import excel "$excel\49 Bevoelkerung Altersjahre\Bevoelkerung_Altersjahre_Geschlecht `i'.xlsx", ///
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
		save "$temp\bevoelkerung_prepare.dta", replace

		}
			
	else{
		append using "$temp\bevoelkerung_prepare.dta" 
		*sort lkrid lkr year
		*sort lkrid lkr year gender
		
		*drop goettingen krs
		*drop if lkrid == 3159
		save "$temp\bevoelkerung_prepare.dta", replace
		sort GDR year YOB 
		} 

}
}



////////////////
//		Schritt 2: 
////////////////

*Regionalstatistik an die Mikrozensusgewichte ranmergen

	*MZ Gewichte aufrufen
	import delim using "$MZ\MOB_Distr_GDRFRG.csv", clear
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
	drop ratio* ypop*
	order year GDR YOB MOB
	
	save "$temp\bevoelkerung_final.dta", replace
