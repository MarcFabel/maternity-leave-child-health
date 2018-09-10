/*******************************************************************************
* File name: 	mlch_KKH_prepare_geburtendaten_destatis
* Author: 		Marc Fabel
* Date: 		07.03.2018
* Description:	Prepare Geburtendaten (erhalten über Anfrage an Stat. Bundesamt)
*				NEU ist dass die monatlichen Geburtendaten nach Geschlecht für
*				DDR und BRD verfügbar sind.
*
* Inputs:  		$population\DESTATIS_ANFRAGE/tables
*
* Outputs:		"$temp/geburten_prepared_final"
*
*
*******************************************************************************/

	global path       "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis" 	//WORK _Windows
	global population "$path/source/population"
	global temp  	  "$path/temp"	

********************************************************************************
// 1) Männlich - Frühere BRD
	import excel "$population\DESTATIS_ANFRAGE\BRD_Maenner_1946-1989.xls", ///
		sheet("1975 - 1989 ") cellrange(A7:N24) firstrow clear
	qui gen temp =_n
	qui drop B 
	qui drop if temp == 1 | temp ==2
	qui gen YOB = substr(Jahr,1,4)
	qui drop Jahr temp
	order YOB
	qui destring _all, replace
	*rename months for reshape (name them fertm0 - 0 für GDR ==0) 
	rename Januar fertm01
	rename Februar fertm02
	rename März fertm03
	rename April fertm04
	rename Mai fertm05
	rename Juni fertm06
	rename Juli fertm07
	rename August fertm08
	rename September fertm09
	rename Oktober fertm010
	rename November fertm011
	rename Dezember fertm012
	*reshape
	reshape long fertm0, i(YOB) j(MOB)
	qui save "$temp/geburten_prepare", replace
********************************************************************************
// 2) Männlich - Gesammtdeutschland
	import excel "$population\DESTATIS_ANFRAGE\GER_Maenner_1946_1989.xls", ///
		sheet("1975 - 1989 ") cellrange(A7:N24) firstrow clear
	qui gen temp =_n
	qui drop B 
	qui drop if temp == 1 | temp ==2
	qui gen YOB = substr(Jahr,1,4)
	qui drop Jahr temp
	order YOB
	qui destring _all, replace
	*rename months for reshape (name them fertm - da Gesamtdeutschland) 
	rename Januar fertm1
	rename Februar fertm2
	rename März fertm3
	rename April fertm4
	rename Mai fertm5
	rename Juni fertm6
	rename Juli fertm7
	rename August fertm8
	rename September fertm9
	rename Oktober fertm10
	rename November fertm11
	rename Dezember fertm12
	*reshape
	reshape long fertm, i(YOB) j(MOB)
	*merge with other 
	qui merge 1:1 YOB MOB using "$temp/geburten_prepare"
	drop _merge
	qui gen fertm1 = fertm - fertm0
	drop fertm
	qui save "$temp/geburten_prepare", replace
********************************************************************************
	
// 3) Weiblich - Frühere BRD
	import excel "$population\DESTATIS_ANFRAGE\BRD_Frauen_1946-1989.xls", ///
		sheet("1975 - 1989 ") cellrange(A7:N24) firstrow clear
	qui gen temp =_n
	qui drop B 
	qui drop if temp == 1 | temp ==2
	qui gen YOB = substr(Jahr,1,4)
	qui drop Jahr temp
	order YOB
	qui destring _all, replace
	*rename months for reshape (name them fertf0 - 0 für GDR ==0) 
	rename Januar fertf01
	rename Februar fertf02
	rename März fertf03
	rename April fertf04
	rename Mai fertf05
	rename Juni fertf06
	rename Juli fertf07
	rename August fertf08
	rename September fertf09
	rename Oktober fertf010
	rename November fertf011
	rename Dezember fertf012
	*reshape
	reshape long fertf0, i(YOB) j(MOB)
	qui merge 1:1 YOB MOB using "$temp/geburten_prepare"
	drop _merge
	qui save "$temp/geburten_prepare", replace
********************************************************************************
// 4) Weiblich - Gesammtdeutschland
	import excel "$population\DESTATIS_ANFRAGE\GER_Frauen_1946_1989.xls", ///
		sheet("1975 - 1989 ") cellrange(A7:N24) firstrow clear
	qui gen temp =_n
	qui drop B 
	qui drop if temp == 1 | temp ==2
	qui gen YOB = substr(Jahr,1,4)
	qui drop Jahr temp
	order YOB
	qui destring _all, replace
	*rename months for reshape (name them fertf - da Gesamtdeutschland) 
	rename Januar fertf1
	rename Februar fertf2
	rename März fertf3
	rename April fertf4
	rename Mai fertf5
	rename Juni fertf6
	rename Juli fertf7
	rename August fertf8
	rename September fertf9
	rename Oktober fertf10
	rename November fertf11
	rename Dezember fertf12
	*reshape
	reshape long fertf, i(YOB) j(MOB)
	*merge with other 
	qui merge 1:1 YOB MOB using "$temp/geburten_prepare"
	drop _merge
	qui gen fertf1 = fertf - fertf0
	drop fertf
********************************************************************************
	// 5) Reshape DDR BRD und totals generieren
	reshape long fertf fertm, i(YOB MOB) j(GDR)
	*totals
	qui gen fert = fertm + fertf
	*generate ratios
	bys YOB GDR: egen sum_fert = total(fert)
	by  YOB GDR: egen sum_fertm = total(fertm)
	by  YOB GDR: egen sum_fertf = total(fertf)
	qui gen ratio_pop  = fert /sum_fert
	qui gen ratio_popm = fertm/sum_fertm
	qui gen ratio_popf = fertf/sum_fertf
	drop sum_fert*
	
	
	
	qui save "$temp/geburten_prepared_final", replace
	qui erase "$temp/geburten_prepare.dta"
	
	

	

