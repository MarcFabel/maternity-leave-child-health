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
* Updates:		14.11.2017 Long format im letzten Schritt noch hinzugefÃ¼gt (Ohne DDR)
*
*******************************************************************************/



// ***************************** PREAMBLE********************************
	clear all
	set more off
	
	global path       "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis" 	//WORK _Windows
*	global path  	  "/Users/marcfabel/econ/m-l-c-h/analysis"					//Mac
	global population "$path/source/population"
	global temp  	  "$path/temp"	
	
*magic numbers
	global first_year = 2003
	global last_year  = 2014	
// ***********************************************************************
	

	
	
********************************************************************************
		*****  Erster Schritt, Regionalstatistik  *****
********************************************************************************

 // *** 49 BevÃ¶lkerung in Altersjahre (population) *** 

*erst ab Welle 2003, frÃ¼here Jahre sind in der Regionalstatistik nicht verfÃ¼gbar

forvalues i = $first_year (1) $last_year {


	import excel "$population/49 Bevoelkerung Altersjahre/Bevoelkerung_Altersjahre_Geschlecht `i'.xlsx", ///
		/*cellrange(A29:L9460)*/ clear
		
		*import excel "$population\49 Bevoelkerung Altersjahre\Bevoelkerung_Altersjahre_Geschlecht 2005.xlsx", clear

	qui gen _d="december31" 

	qui rename A lkrid
	qui label var lkrid "Landkreis(ID)"
	qui rename B lkr
	qui label var lkr "Landkreis" 
	qui rename C agegroup
	qui rename D ypop_
	qui rename E ypop_m
	qui rename F ypop_f


	qui replace lkrid=lkrid[_n-1] if lkrid==""
	qui replace lkr=lkr[_n-1] if lkr=="" 
	qui drop if ypop_=="" & ypop_m=="" & ypop_f==""
	qui drop if lkr==""
	
	qui replace lkrid="00" if lkrid=="DG"
	/*destring lkrid, replace ignore("DG")*/
	qui destring lkrid, replace  
	
	
	
	/// ACHTUNG UNTERSCHIED ZU BEVOR; ICH GEHE UEBER DIE BUNDESLAENDER!!!! 
	qui keep if lkrid >= 1 & lkrid <= 16
	
	
	qui gen year=`i'
	qui label var year "Year" 
	
	
	//reshape in long format[own lines]
	qui gen temp = substr(agegroup,1,2)
	*transform to a string 2
	capture drop temp2
	qui gen temp2 = string(real(temp))
	// NEU EINGEFÃœGT,NUR RELVANTE KOHORTEN EINFÃœGEN
		qui destring temp2, gen(temp3)
		//generate YOB = year - temp3
		qui gen YOB = year - temp3
		*nur die relevanten JahrgÃ¤nge drinbehalten
		qui keep if YOB >= 1976 & YOB <=1980 | ///
				YOB >= 1985 & YOB <=1995 

		
		*replace temp2 = "all" if agegroup=="Insgesamt"
	*drop Personen  Ã¤lter als 74 Jahre & jÃ¼nger als ein Jahr
		*drop if temp == "un" //unter einem Jahr
		*drop if temp2 == "75" | temp2 == "80" | temp2 == "85"
	*	capture drop if temp2 == "90" // only present in some years
	//Ende VerÃ¤nderungen

	qui drop agegroup temp*
	
	
	// gen GDR
	qui gen GDR = .
	qui replace GDR = cond(lkrid>=11,1,0)
	
	
	//auf GDR collapsen
	qui destring, replace ignore ("-" ".")	
	qui collapse (sum) ypop* , by(year YOB GDR) 
	
	
	*order lkrid lkr year 

	if `i'==$first_year{
		save "$temp/regionalstatistik_prepared.dta", replace

		}
			
	else{
		append using "$temp/regionalstatistik_prepared.dta" 
		*sort lkrid lkr year
		*sort lkrid lkr year gender
		
		*drop goettingen krs
		*drop if lkrid == 3159
		save "$temp/regionalstatistik_prepared.dta", replace
		sort GDR year YOB 
		} 

}




////////////////
//		Schritt 2: 
////////////////

*Regionalstatistik an die Mikrozensusgewichte ranmergen

	*MZ Gewichte aufrufen
	import delim using "$population/MOB_Distr_GDRFRG.csv", clear
	qui rename v1 MOB
	qui rename v2 year
	qui rename v3 YOB
	qui rename v4 GDR
	qui rename v5 ratio_GDR
	qui rename v6 ratio_GDR_male
	qui rename v7 ratio_GDR_female
	qui drop v8 v9 v10
	qui gen temp = _n	// Hilfsvariable, die das lÃ¶schen der Variablennamen in den EintrÃ¤gen ermÃ¶glicht
	qui drop if temp <= 2
	qui drop temp
	qui destring, replace
	*auf relevantes sample beschrÃ¤nken
	qui keep if (YOB >=1976 & YOB<=1980) | (YOB>=1985 & YOB<=1995)	
	qui drop if (MOB < 11 & YOB == 1976) | (MOB > 10 & YOB == 1980)	
	qui drop if (MOB <  7 & YOB == 1985) | (MOB >  6 & YOB == 1987)
	qui drop if (MOB <  7 & YOB == 1988) | (MOB >  6 & YOB == 1989)
	qui drop if (MOB <  7 & YOB == 1990) | (MOB >  6 & YOB == 1992) 
	qui drop if (MOB <  7 & YOB == 1993) | (MOB >  6 & YOB == 1995)
	
	*ratios durch 100 teilen
	foreach var of varlist ratio* {
		qui replace `var' = `var' /100
	}
	
	save "$temp/MZ_gewichte_prepared.dta", replace
	

	
	
	
	
	
////////////////
//		Schritt 3: Destatis Daten zur ursprŸnglichen Bevšlkerung mitaufnehmen 
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
	
	gen temp = _n	// Hilfsvariable, die das lÃ¶schen der Variablennamen in den EintrÃ¤gen ermÃ¶glicht
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
	qui gen GDR = 0		// nur fÃ¼r Westdeutschland
	//ratios aus Geburtenstatistik
	bys YOB: egen sum_fert = total(fert)
	by  YOB: egen sum_fertm = total(fertm)
	by  YOB: egen sum_fertf = total(fertf)
	qui gen ratio_pop  = fert /sum_fert
	qui gen ratio_popm = fertm/sum_fertm
	qui gen ratio_popf = fertf/sum_fertf
	drop sum_fert*
	
	*auf relevantes sample beschränken
	qui drop if (MOB < 11 & YOB == 1976) | (MOB > 10 & YOB == 1980)	
	qui drop if (MOB <  7 & YOB == 1985) | (MOB >  6 & YOB == 1987)
	qui drop if (MOB <  7 & YOB == 1988) | (MOB >  6 & YOB == 1989)
	qui drop if (MOB <  7 & YOB == 1990) | (MOB >  6 & YOB == 1992) 
	qui drop if (MOB <  7 & YOB == 1993) | (MOB >  6 & YOB == 1995)
	
	save "$temp/geburten_prepared.dta", replace
	/*


	
	
	
	
	
	
	
	
	
	
	
	
	
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
	
	
