/*******************************************************************************
* File name: 	mlch_KKHGWAP_prepare_raw
* Author: 		Marc Fabel
* Date: 		01.05.2018
* Description:	
*				1) 
*
* Inputs:  		
*				
* Outputs:		
*
* Updates:		
*
*******************************************************************************/
/*
*MZ Gewichte vorbereiten
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
*/


********************************************************************************
// recovered die ags_clean files (Regionalstatistik) aus den Anspieldaten von Herrn Dr Janisch

use "$anspielen\kkh_mon_merged.dta", clear
	qui drop if ags_clean == .
	qui keep _014_emp* _002_pop* _001_ypop* _289_area* year ags_clean
		
	qui collapse (mean) _014_emp* _002_pop* _001_ypop* _289_area*, by(year ags_clean)
	sort ags_clean year
	
	*auf ags level speichern 
	qui save "$temp/exportfile_yearly_clean", replace
			
	* auf AMR aggregieren
	qui merge m:1 ags_clean using "$AMR/ags_clean_amr_ror_umsteiger.dta"  
	
	
	collapse (sum) _014_emp* _002_pop* _001_ypop* _289_area*, by(year amr_clean)
	foreach var of varlist _014_emp* _002_pop* _001_ypop* _289_area* {
		qui replace `var'= . if `var' == 0
	}
	sort amr_clean year
	qui save "$temp/exportfile_yearly_clean_AMR", replace


********************************************************************************
******* Bevölkerung einlesen
	use ${temp}\exportfile_yearly_clean.dta, clear
	keep ags_clean year _001_ypop_*
	drop _001_ypop_m _001_ypop_f
	reshape long _001_ypop_ _001_ypop_m _001_ypop_f, i(year ags_clean) j(age)
	qui gen YOB = year - age
	qui keep if YOB >= 1975 & YOB <= 1980
	drop age
	qui save "$temp/RS_population_ags", replace
	
	use ${temp}\exportfile_yearly_clean_AMR.dta, clear
	keep amr_clean year _001_ypop_*
	drop _001_ypop_m _001_ypop_f
	reshape long _001_ypop_ _001_ypop_m _001_ypop_f, i(year amr_clean) j(age)
	qui gen YOB = year - age
	qui keep if YOB >= 1975 & YOB <= 1980
	drop age
	qui save "$temp/RS_population_amr", replace
	
	*population GDR/FRG
	use "$temp/RS_population_ags", clear
	qui gen bula = floor(ags_clean/1000)
	qui gen GDR = cond(bula>=11 & bula<=16,1,0)
	drop if bula == 11
	collapse (sum)  _001_ypop* ,by(year YOB GDR)
	qui save "$temp/RS_population_gdr", replace  
 
 // Klassifikation: welche AMR fällt in  Ost/West
	use "$AMR/ags_clean_amr_ror_umsteiger.dta", clear
	qui gen bula = floor(ags_clean/1000)
	qui gen GDR = cond(bula>=11 & bula<=16,1,0)
	drop if bula == 11
	qui collapse (mean) GDR , by(amr_clean) 
	qui save "$temp/amr_gdr_classification", replace
 
// Geburten vorbereiten 
	run mlch_KKHGWAP_fertility_data.do
 
***********************************************************************	
 
 // Heterogenitätsvariablen
	use ${temp}\exportfile_yearly_clean_AMR.dta, clear
	
// 1) FLFP 	
	*Zähler - 014: SVP Beschäftigte nach Altersgruppen (ab 2001 nach Geschlecht) - IM TYPISCHEN eRWERBSALTER
	qui egen svp_f = rowtotal(_014_emp_20u_f _014_emp_2025_f _014_emp_2530_f _014_emp_3050_f _014_emp_5060_f _014_emp_6065_f), m
	* Nenner 
	qui egen pop_f = rowtotal(_002_pop_f1518 _002_pop_f1820 _002_pop_f2025 ///
		_002_pop_f2530 _002_pop_f3035 _002_pop_f3540 _002_pop_f4045 _002_pop_f4550 ///
		_002_pop_f5055 _002_pop_f5560 _002_pop_f6065), m
	*Bruch: 
	qui gen FLFP = svp_f / pop_f
	 *sample split at median
	capture drop high_FLFP
	qui summ FLFP if year == 2001, d
	qui gen temp = cond(FLFP > r(p50),1,0) if year == 2001
	by amr_clean: egen high_FLFP = min(temp) 
	drop temp
	label variable high_FLFP "sample split: high FLFP in year 2001"
	
// 2) Siedlungsstruktureller typ	
	qui gen density = _002_pop / _289_area		// population/area
	qui summ density if year == 1996, d 
	qui gen temp = cond(density > r(p50),1,0) if year == 1996
	by amr_clean: egen high_density = min(temp)
	drop temp
	order year amr_clean density high_density
	label var high_density "sample split: high density in year 1996 (pop/hectar)"
qui save ${temp}\exportfile_yearly_clean_AMR_heterogen.dta, replace

***********************************************************************	
//einzelne Wellen vorbereiten
// 1995-1999
foreach wave of numlist 1995(1)1999 {

	use "$KKH\${file}_`wave'.dta", clear
	*use "$KKH\${file}_1995.dta", clear
	qui gen year = `wave'
 
	*Zurückrechnen auf Geburtsdatum:
	*transform EF5 into monthly
	qui gen monthly = mofd(EF5)
	qui gen Datum = monthly - EF13U2
	format Datum %tm
	qui drop monthly
 
	qui gen MOB = month(dofm(Datum))
	qui gen YOB = year(dofm(Datum))
	
	*restrict to only relevant sample:
	*keep if (Datum >= tm(1976m11) & Datum <= tm(1980m10))
	qui keep if (Datum >= tm(1975m1) & Datum <= tm(1980m12))
	
	/*| /// 
			(Datum >= tm(1985m7)  & Datum <= tm(1989m6)) | ///
			(Datum >= tm(1990m7)  & Datum <= tm(1995m6))*/

	qui sort Datum

********************************************************************************
*****  Diagnosenzusammenfassung  *****
	
	*Main Diagnosis
	qui gen diag0 = substr(EF8,1,1)
	qui gen diag00 = substr(EF8,1,2)
	qui gen diag000 = substr(EF8,1,3)
	*qui gen diag0000 = 
	
	*encode different versions:
	qui destring diag0, replace force
	qui destring diag00, replace force
	qui destring diag000, replace force
	drop if diag0 ==.		// Sind die V Diagnosen (= ICD10: Z Diagnosen; andere Faktoren die den Gesundheitszustand ...)
	
	//Diagnosen
	
	qui gen Diag_death = cond(EF7==1,1,0)
		
	*Hauptdiagnosekapitel
	qui gen Diag1	= 1 if (diag000 >= 001 & diag000 <= 139)	// Infektiöse Krankheiten
	qui gen Diag2	= 1 if (diag000 >= 140 & diag000 <= 239)	// Neubildungen
	qui gen Diag3  = 1 if (diag000 >= 279 & diag000 <= 289)	// Blut
	qui gen Diag4 	= 1 if (diag000 >= 240 & diag000 <= 278)	// Stoffwechselkrankheiten
	qui gen Diag5	= 1 if (diag000 >= 290 & diag000 <= 319) 	//*mental and behavioral disorders
	qui gen Diag6  = 1 if (diag000 >= 320 & diag000 <= 359)	// Krankheiten des Nervensystems
	qui gen Diag7  = 1 if (diag000 >= 360 & diag000 <= 389)	// Auge & Ohr
	qui gen Diag8	= 1 if (diag000 >= 390 & diag000 <= 459)	//*Krankheiten des Kreislaufsystems
	qui gen Diag9	= 1 if (diag000 >= 460 & diag000 <= 519)	//*Atmungssystem
	qui gen Diag10 = 1 if (diag000 >= 520 & diag000 <= 579)	//* Verdauungssystem
	qui gen Diag11 = 1 if (diag000 >= 680 & diag000 <= 709)	// Haut
	qui gen Diag12 = 1 if (diag000 >= 710 & diag000 <= 739)	// Muskel_Skelett_Bindegewebe
	qui gen Diag13 = 1 if (diag000 >= 580 & diag000 <= 629)	// Urogenitalsystem
	qui gen Diag14 = 1 if (diag000 >= 630 & diag000 <= 676)	// Schwangerschaft
	qui gen Diag17 = 1 if (diag000 >= 780 & diag000 <= 799)	// Symptome & abnorme klinische Befunde
	qui gen Diag18 = 1 if (diag000 >= 800 & diag000 <= 999)	// Verletzungen und co
	
	* Indices:
	* 1) Metabolic Syndorme
	qui gen Diag_metabolic_syndrome = 1 if (diag000 == 250) // diabetes
	qui replace Diag_metabolic_syndrome = 1 if (diag000 == 401 | diag000 == 402 | diag000 == 404 | diag000 == 405) //bluthochdruck
	qui replace Diag_metabolic_syndrome = 1 if (diag000 == 278) // Adipositas und übergewicht
	qui replace Diag_metabolic_syndrome = 1 if (diag000 >= 410 & diag000 <= 414) //Ischämische Herzkrankheiten
	* 2) Respiratory Sytem
	qui gen Diag_Index_respiratory = 1 if (diag000 >= 460 & diag000 <= 466)	// Akute Infektionen der Atmungsorgane
	qui replace Diag_Index_respira = 1 if (diag000 >= 480 & diag000 <= 486)	// Lungenentzündung
	qui replace Diag_Index_respira = 1 if (diag000 >= 490 & diag000 <= 496 & diag000 != 495)	// Chron Entzündung untere Atemweg (inkl Asthma)

	
	//Einzeldiagnosen
	qui gen Diag_symp_circ_resp = 1 if (diag000 == 785 | diag000 == 786)
	qui gen Diag_symp_verdauung = 1 if diag000 == 787	// Syptmoe des Verdauungssytems
	qui gen Diag_sonst_herzkrank = 1 if (diag000 >= 420 & diag000 <= 429 & diag000 != 424)
	qui gen Diag_psych_drogen = 1 if (diag000 == 291 | diag000 ==303 | diag000 == 980 | diag000 == 304 | diag000 == 305)
	qui gen Diag_diabetis = 1 if (diag000 == 250) 
	qui gen Diag_hypertension = 1 if (diag000 == 401 | diag000 == 402 | diag000 == 404 | diag000 == 405)
	qui gen Diag_ischemic = 1 if (diag000 >= 410 & diag000 <= 414)
	qui gen Diag_adipositas = 1 if (diag000 == 278)
	qui gen Diag_infect_lung = 1 if (diag000 >= 460 & diag000 <= 466)
	qui gen Diag_pneumonia = 1 if (diag000 >= 480 & diag000 <= 486)
	qui gen Diag_chron_lung  = 1 if (diag000 >= 490 & diag000 <= 496 & diag000 != 495)
	qui gen Diag_asthma = 1 if (diag000 == 493) 
	qui gen Diag_infec_intestine = 1 if (diag000 >=001 & diag000 <=009)
	qui gen Diag_leukemia = 1 if (diag000 == 204 | diag000 == 205)
	qui gen Diag_shizophrenia = 1 if  (diag000 == 295)
	qui gen Diag_affective = 1 if (diag000 == 296)
	qui gen Diag_neurosis = 1 if (diag000 == 300)
	qui gen Diag_personality =1 if (diag000 == 301)
	qui gen Diag_childhood = 1 if (diag000 >=312 & diag000 <=316)
	qui gen Diag_ear = 1 if (diag000 >= 380 & diag000 <=389)
	qui gen Diag_otitis_media = 1 if (diag000 >= 381 & diag000 <=385)
	
	*Metadaten:
	qui gen patients = 1
	qui egen hospital = rowtotal(Diag1 -Diag18)
	qui gen Op = cond(EF10==1,1,0)
	qui gen Verweildauer = EF12
	qui replace Verweildauer = . if EF12 == 85
		
	
	//label variables                                                                 
	label define BINARY 0 "0 No" 1 "1 Yes"
	foreach var of varlist Diag_* {
		label values `var' BINARY
		qui replace `var' = 0 if `var' == .
	}

********************************************************************************
*****  location  *****
	qui destring EF14, gen(lkrid) force
	
	*Kreiskennziffern vereinheitlichen
	qui replace lkrid=2000 if lkrid==2  // Hamburg
	qui replace lkrid=11000 if lkrid==11 // Berlin
	qui gen lkr1000=floor(lkrid/1000) if lkrid>99999
	qui replace lkrid=lkr1000 if lkrid>99999  // Kreiskennziffern auf 4-5 Stellen einschraenken
	qui drop if lkrid<=1000 // zu kurze Kreiskennziffer loeschen
	qui drop if lkrid>99999 // zu lange Kreiskennziffer loeschen
	
	*Wenn nur Flaechenlaender angegeben sind: loeschen
	qui drop if lkrid==1000 | lkrid==3000 | lkrid==4000 | lkrid==5000 | lkrid==6000 | lkrid==7000 | lkrid==8000 | lkrid==9000 | lkrid==10000 | lkrid==12000 | lkrid==13000 | lkrid==14000 | lkrid==15000 | lkrid==16000
	qui gen ags_clean=lkrid
				qui replace ags_clean = 3241 if ags_clean == 3253 | ags_clean == 3201
				qui replace ags_clean = 5334 if ags_clean == 5354 | ags_clean == 5313 
				qui replace ags_clean = 12998 if ags_clean == 12071 | ags_clean == 12052
				qui replace ags_clean = 12999 if ags_clean == 12069 | ags_clean == 12054
				qui replace ags_clean = 13072 if ags_clean == 13053 | ags_clean == 13051
				qui replace ags_clean = 13073 if ags_clean == 13005 | ags_clean == 13057 | ags_clean == 13061
				qui replace ags_clean = 13074 if ags_clean == 13058 | ags_clean == 13006
				qui replace ags_clean = 13076 if ags_clean == 13054 | ags_clean == 13060
				qui replace ags_clean = 13999 if ags_clean == 13001 | ags_clean == 13002 | ags_clean == 13055 ///
					| ags_clean ==13062 | ags_clean == 13056 | ags_clean == 13059 | ags_clean == 13071 ///
					| ags_clean == 13052 | ags_clean == 13075
				qui replace ags_clean = 14523 if ags_clean == 14142 | ags_clean == 14136 | ags_clean == 14113 ///
					| ags_clean == 14146 | ags_clean == 14145 | ags_clean == 14178 | ags_clean == 14166 ///
					| ags_clean == 14013 | ags_clean == 14036 | ags_clean == 14042 | ags_clean == 14045  ///
					| ags_clean == 14046 | ags_clean == 14066
				qui replace ags_clean = 14730 if ags_clean == 14374 | ags_clean == 14389 | ags_clean == 14074 | ags_clean == 14089
				qui replace ags_clean = 14997 if ags_clean == 14061 | ags_clean == 14067 | ags_clean == 14071  /// 
						| ags_clean == 14073 | ags_clean == 14075 | ags_clean == 14077  ///
					| ags_clean == 14081 | ags_clean == 14082 | ags_clean == 14088 | ags_clean == 14091 ///
					| ags_clean == 14093 | ags_clean == 14161 | ags_clean == 14181 | ags_clean == 14191 ///
					| ags_clean == 14171 | ags_clean == 14188 | ags_clean == 14182 | ags_clean == 14177 ///
					| ags_clean == 14375 | ags_clean == 14193 | ags_clean == 14173 | ags_clean == 14167 ///
					| ags_clean == 14522 | ags_clean == 14524 | ags_clean == 14511 | ags_clean == 14521
				qui replace ags_clean = 14998 if ags_clean == 14365 | ags_clean == 14379 | ags_clean == 14383 ///
					| ags_clean == 14729 | ags_clean == 14713 | ags_clean == 14079 | ags_clean == 14065 | ags_clean == 14083
				qui replace ags_clean = 14999 if ags_clean == 14062 | ags_clean == 14063 | ags_clean == 14072 ///
						| ags_clean == 14095 | ags_clean == 14092 ///
					| ags_clean == 14262 | ags_clean == 14272 | ags_clean == 14292 | ags_clean == 14295   ///
					| ags_clean == 14264 | ags_clean == 14286 | ags_clean == 14284 | ags_clean == 14263 ///
					| ags_clean == 14280 | ags_clean == 14285 | ags_clean == 14287 | ags_clean == 14290 ///
					| ags_clean == 14294 | ags_clean == 14628 | ags_clean == 14625 | ags_clean == 14626 ///
					| ags_clean == 14295 | ags_clean == 14612 | ags_clean == 14627 | ags_clean == 14080 ///
					| ags_clean == 14085 | ags_clean == 14087 | ags_clean == 14090 | ags_clean == 14094 ///
					| ags_clean == 14086 | ags_clean == 14084
				qui replace ags_clean = 15002 if ags_clean == 15202
				qui replace ags_clean = 15003 if ags_clean == 15303
				qui replace ags_clean = 15083 if ags_clean == 15362 | ags_clean == 15355
				qui replace ags_clean = 15084 if ags_clean == 15256 | ags_clean == 15268
				qui replace ags_clean = 15087 if ags_clean == 15266 | ags_clean == 15260
				qui replace ags_clean = 15088 if ags_clean == 15265 | ags_clean == 15261
				qui replace ags_clean = 15997 if ags_clean == 15363 | ags_clean == 15081 | ags_clean == 15090 ///
					| ags_clean == 15370 
				qui replace ags_clean = 15998 if ags_clean == 15352 | ags_clean == 15085 | ags_clean == 15369 ///
					| ags_clean == 15367 |  ags_clean == 15153 | ags_clean == 15364 | ags_clean == 15089 ///
						| ags_clean == 15357
				qui replace ags_clean = 15999 if ags_clean == 15101 | ags_clean == 15171 | ags_clean == 15159 ///
					| ags_clean == 15151 |  ags_clean == 15091 | ags_clean == 15001 | ags_clean == 15082 ///
						| ags_clean == 15086 | 	ags_clean == 15358 | ags_clean == 15154
				qui replace ags_clean = 16999 if ags_clean == 16056 | ags_clean == 16063	
	
	
	
	
	/*
	*OLD
	*qui gen ab_ags=lkrid
	merge m:1 ab_ags using ${kreisreform}kreisreformen.dta  // Neue Kreiskennziffern angeben
	*drop if _m==2 //when data is not in hospital
	gen ags_clean=lkrid if _merge==1	// no reform took pleace
	replace ags_clean=auf_ags if _merge==3
	*drop _merge
	qui rename _merge merge_kreisreform*/

********************************************************************************
*****  Recode Gender  *****
	qui gen female = cond(EF3==2,1,0)
	label define GENDER 0 "Male" 1 "Female"
	label values female GENDER


	
	save "$temp\prepared_`wave'.dta", replace
} // end: loop 1995-1999


////////////////////////////////////////////////////////////////////////////////
		*****  2000 - 2014  *****
////////////////////////////////////////////////////////////////////////////////	
foreach wave of numlist 2000(1)2014 {

	use "$KKH\${file}_`wave'.dta", clear
	qui gen year = `wave'
 
	*Zurückrechnen auf Geburtsdatum:
	*transform EF5 into monthly
	qui gen monthly = mofd(EF5)
	qui gen Datum = monthly - EF13U2
	format Datum %tm
	qui drop monthly
 
	qui gen MOB = month(dofm(Datum))
	qui gen YOB = year(dofm(Datum))
	
	*restrict to only relevant sample:
	qui keep if (Datum >= tm(1975m1) & Datum <= tm(1980m12)) 
	
	/*| /// 
			(Datum >= tm(1985m7)  & Datum <= tm(1989m6)) | ///
			(Datum >= tm(1990m7)  & Datum <= tm(1995m6))*/

	qui sort Datum

********************************************************************************
*****  Diagnosenzusammenfassung  *****
	
	*Main Diagnosis
	qui gen diagX = substr(EF8,1,1)
	qui gen diagX0 = substr(EF8,1,2)
	
	*encode first two digit:
	qui gen temp = substr(EF8,2,2)
	qui encode temp, gen(diag00)
	qui drop temp
	
	*Fälle zusammenfassen, nach Europäischer Kurzliste (aber nur die Hauptaugenmerke, nicht sehr disaggregiert) //	Anzahl 30-35  -> approx Werte pro Kohorte und MOB: West, Region, 
	gen diagOvrvw=.																
	qui replace diagOvrvw=1  if diagX == "A" | diagX == "B"						
	qui replace diagOvrvw=2  if diagX == "C" | (diagX == "D" & diag00<=48)		
	qui replace diagOvrvw=3  if diagX == "D" & (diag00 >=50 & diag00<=90)		
	qui replace diagOvrvw=4  if diagX == "E" & (diag00 >=00 & diag00 <=90)		
	qui replace diagOvrvw=5  if diagX == "F"									
	qui replace diagOvrvw=6  if diagX == "G"									
	qui replace diagOvrvw=7  if diagX == "H" & diag00<=95						
	qui replace diagOvrvw=8  if diagX == "I"									
	qui replace diagOvrvw=9  if diagX == "J"									
	qui replace diagOvrvw=10 if diagX == "K" & diag00 <=93						
	qui replace diagOvrvw=11 if diagX == "L" 									
	qui replace diagOvrvw=12 if diagX == "M"									
	qui replace diagOvrvw=13 if diagX == "N"									
	qui replace diagOvrvw=14 if diagX == "O"									
	qui replace diagOvrvw=15 if diagX == "P" & diag00 <=96						
	qui replace diagOvrvw=16 if diagX == "Q"									
	qui replace diagOvrvw=17 if diagX == "R"									
	qui replace diagOvrvw=18 if diagX == "S" | diagX == "T"						
	qui replace diagOvrvw=19 if diagX == "Z"
	
	
#delimit;
	label define DIAGNOSEN
	1  "[A00-B99] Infektiöse und parasitäre Krankheiten"
	2  "[C00-D48] Neubildungen"
	3  "[D50-D90] Krankheiten des Blutes und blutbildenden Organe"
	4  "[E00-E90] Endokrine, Ernährungs- u Stoffwechselkrankh."
	5  "[F00-F99] Psychische und Verhaltensstörungen"
	6  "[G00-G99] Krankheiten des Nervensystems"
	7  "[H00-H95] Krankheiten des Auges und Ohres"
	8  "[I00-I99] Krankheiten des Kreislaufsystems"	
	9  "[J00-J99] Krankheiten des Atmungssystems"
	10 "[K00-K93] Krankheiten des Verdauungssystems"
	11 "[L00-L99] Krankheiten der Haut"
	12 "[M00-M99] Muskel, Skelett u Bindegewebe"
	13 "[N00-N99] Urogenitalsystem"
	14 "[O00-O99] Schwangerschaft, Geburt, Wochenbett"
	15 "[P00-P96] Perinatalperiode"
	16 "[Q00-Q99] Angeborene Fehlbildungen, Deformitäten, Chromosomenabnomalien"
	17 "[R00-R99] Symptome, aborm. Laborbefunde"
	18 "[S00-T98] Verletzungen, Vergiftungen, äußere Ursachen"
	19 "[Z00-Z99] anderes, z.B Neugeborene"	;
#delimit cr

	label values diagOvrvw DIAGNOSEN
	
	
	*Nicht relevante Diagnosen ausschließen:
	*qui drop if diagOvrvw == 3
	qui drop if diagOvrvw == 15		// Fälle die ihren Ursprung in der Perinatalperiode haben 
	*qui drop if diagOvrvw == 16
	qui drop if diagOvrvw == 19
		

	
	*Hauptdiagnosekapitel
	foreach j of numlist 1/19 {
		qui gen Diag`j' = 1 if diagOvrvw == `j'
	}
	drop  Diag15 Diag16 Diag19
	
	qui gen Diag_death = cond(EF7==1,1,0)

	
	//Indices 
	* 1) Metabolic Syndorme
	qui gen Diag_metabolic_syndrome = 1 if (diagX == "E" & (diag00 ==11 | diag00 ==12)) // diabetes [HIER NUR TYP 2!!!]
	qui replace Diag_metabolic_syndrome = 1 if (diagX == "I" & (diag00 == 10 | diag00 == 11 | diag00 == 13 | diag00 == 15)) //bluthochdruck
	qui replace Diag_metabolic_syndrome = 1 if (diagX == "E" & (diag00 >= 65 & diag00 <= 68)) // Adipositas und übergewicht
	qui replace Diag_metabolic_syndrome = 1 if (diagX == "I" & (diag00 >= 20 & diag00 <= 25)) //Ischämische Herzkrankheiten
	* 2) Respiratory system
	qui gen Diag_Index_respiratory = 1 if (diagX == "J" & (diag00 >= 40 & diag00 <= 47)) // Chron Entzündung untere Atemweg (inkl Asthma)
	qui replace Diag_Index_respira = 1 if (diagX == "J" & (diag00 >= 20 & diag00 <= 22)) // akute Bronchitis
	qui replace Diag_Index_respira = 1 if (diagX == "J" & (diag00 >= 12 & diag00 <= 18)) // Lungenentzündung
		
	*Einzeldiagnosen
	qui gen Diag_symp_circ_resp = 1 if (diagX == "R" & (diag00 >= 00 & diag00 <= 09))
	qui gen Diag_symp_verdauung = 1 if (diagX == "R" & (diag00 >= 10 & diag00 <= 19))
	qui gen Diag_sonst_herzkrank = 1 if diagX == "I" & ((diag00>=30 & diag00<=33) | (diag00>=39 & diag00<=52))  
	qui gen Diag_psych_drogen = 1 if (diagX == "F" & diag00==10) | (diagX == "T" & diag00==51) 
	qui replace Diag_psych_drogen = 1 if (diagX == "F" & (diag00>= 11 & diag00<=19 & diag00 !=17) )
	qui gen Diag_diabetis = 1 if (diagX == "E" & (diag00 ==11 | diag00 ==12)) 
	qui gen Diag_hypertension = 1 if (diagX == "I" & (diag00 == 10 | diag00 == 11 | diag00 == 13 | diag00 == 15))
	qui gen Diag_ischemic = 1 if (diagX == "I" & (diag00 >= 20 & diag00 <= 25))
	qui gen Diag_adipositas = 1 if (diagX == "E" & (diag00 >= 65 & diag00 <= 68))
	qui gen Diag_infect_lung = 1 if (diagX == "J" & (diag00 >= 20 & diag00 <= 22))
	qui gen Diag_pneumonia = 1 if (diagX == "J" & (diag00 >= 12 & diag00 <= 18))
	qui gen Diag_chron_lung  = 1 if (diagX == "J" & (diag00 >= 40 & diag00 <= 47))
	qui gen Diag_asthma = 1 if (diagX == "J" & (diag00 >= 45 & diag00 <= 46)) 
	qui gen Diag_infec_intestine = 1 if (diagX == "A" & (diag00 >= 00 & diag00 <= 09))
	qui gen Diag_leukemia = 1 if (diagX == "C" & (diag00 == 91 | diag00 == 92)) // AML & ALL
	qui gen Diag_shizophrenia = 1 if (diagX == "F" & (diag00 >= 20 | diag00 <= 29))
	qui gen Diag_affective = 1 if (diagX == "F" & (diag00 >= 30 | diag00 <= 39))
	qui gen Diag_neurosis = 1 if (diagX == "F" & (diag00 >= 40 | diag00 <= 48))
	qui gen Diag_personality =1 if (diagX == "F" & (diag00 >= 60 | diag00 <= 69))
	qui gen Diag_childhood = 1 if (diagX == "F" & (diag00 >= 90 | diag00 <= 98))
	qui gen Diag_ear = 1 if (diagX == "H" & (diag00 >= 60 | diag00 <= 95))
	qui gen Diag_otitis_media = 1 if (diagX == "H" & (diag00 >= 65 | diag00 <= 75))
	
	
	*Metadaten:
	qui gen patients = 1
	qui egen hospital = rowtotal(Diag1 -Diag18)
	qui gen Op = cond(EF10==1,1,0)
	qui gen Verweildauer = EF12
	qui replace Verweildauer = . if EF12 == 85

	
	//label variables                                                                 
	label define BINARY 0 "0 No" 1 "1 Yes"
	foreach var of varlist Diag_* {
		label values `var' BINARY
		qui replace `var' = 0 if `var' == .
	}

********************************************************************************
*****  location  *****

	destring EF14, gen(lkrid) force
	
	
	*Kreiskennziffern vereinheitlichen
	qui replace lkrid=2000 if lkrid==2  // Hamburg
	qui replace lkrid=11000 if lkrid==11 // Berlin
	qui gen lkr1000=floor(lkrid/1000) if lkrid>99999
	qui replace lkrid=lkr1000 if lkrid>99999  // Kreiskennziffern auf 4-5 Stellen einschraenken
	qui drop if lkrid<=1000 // zu kurze Kreiskennziffer loeschen
	qui drop if lkrid>99999 // zu lange Kreiskennziffer loeschen
	
	*Wenn nur Flaechenlaender angegeben sind: loeschen
	qui drop if lkrid==1000 | lkrid==3000 | lkrid==4000 | lkrid==5000 | lkrid==6000 | lkrid==7000 | lkrid==8000 | lkrid==9000 | lkrid==10000 | lkrid==12000 | lkrid==13000 | lkrid==14000 | lkrid==15000 | lkrid==16000
	qui gen ags_clean=lkrid
				qui replace ags_clean = 3241 if ags_clean == 3253 | ags_clean == 3201
				qui replace ags_clean = 5334 if ags_clean == 5354 | ags_clean == 5313 
				qui replace ags_clean = 12998 if ags_clean == 12071 | ags_clean == 12052
				qui replace ags_clean = 12999 if ags_clean == 12069 | ags_clean == 12054
				qui replace ags_clean = 13072 if ags_clean == 13053 | ags_clean == 13051
				qui replace ags_clean = 13073 if ags_clean == 13005 | ags_clean == 13057 | ags_clean == 13061
				qui replace ags_clean = 13074 if ags_clean == 13058 | ags_clean == 13006
				qui replace ags_clean = 13076 if ags_clean == 13054 | ags_clean == 13060
				qui replace ags_clean = 13999 if ags_clean == 13001 | ags_clean == 13002 | ags_clean == 13055 ///
					| ags_clean ==13062 | ags_clean == 13056 | ags_clean == 13059 | ags_clean == 13071 ///
					| ags_clean == 13052 | ags_clean == 13075
				qui replace ags_clean = 14523 if ags_clean == 14142 | ags_clean == 14136 | ags_clean == 14113 ///
					| ags_clean == 14146 | ags_clean == 14145 | ags_clean == 14178 | ags_clean == 14166 ///
					| ags_clean == 14013 | ags_clean == 14036 | ags_clean == 14042 | ags_clean == 14045  ///
					| ags_clean == 14046 | ags_clean == 14066
				qui replace ags_clean = 14730 if ags_clean == 14374 | ags_clean == 14389 | ags_clean == 14074 | ags_clean == 14089
				qui replace ags_clean = 14997 if ags_clean == 14061 | ags_clean == 14067 | ags_clean == 14071  /// 
						| ags_clean == 14073 | ags_clean == 14075 | ags_clean == 14077  ///
					| ags_clean == 14081 | ags_clean == 14082 | ags_clean == 14088 | ags_clean == 14091 ///
					| ags_clean == 14093 | ags_clean == 14161 | ags_clean == 14181 | ags_clean == 14191 ///
					| ags_clean == 14171 | ags_clean == 14188 | ags_clean == 14182 | ags_clean == 14177 ///
					| ags_clean == 14375 | ags_clean == 14193 | ags_clean == 14173 | ags_clean == 14167 ///
					| ags_clean == 14522 | ags_clean == 14524 | ags_clean == 14511 | ags_clean == 14521
				qui replace ags_clean = 14998 if ags_clean == 14365 | ags_clean == 14379 | ags_clean == 14383 ///
					| ags_clean == 14729 | ags_clean == 14713 | ags_clean == 14079 | ags_clean == 14065 | ags_clean == 14083
				qui replace ags_clean = 14999 if ags_clean == 14062 | ags_clean == 14063 | ags_clean == 14072 ///
						| ags_clean == 14095 | ags_clean == 14092 ///
					| ags_clean == 14262 | ags_clean == 14272 | ags_clean == 14292 | ags_clean == 14295   ///
					| ags_clean == 14264 | ags_clean == 14286 | ags_clean == 14284 | ags_clean == 14263 ///
					| ags_clean == 14280 | ags_clean == 14285 | ags_clean == 14287 | ags_clean == 14290 ///
					| ags_clean == 14294 | ags_clean == 14628 | ags_clean == 14625 | ags_clean == 14626 ///
					| ags_clean == 14295 | ags_clean == 14612 | ags_clean == 14627 | ags_clean == 14080 ///
					| ags_clean == 14085 | ags_clean == 14087 | ags_clean == 14090 | ags_clean == 14094 ///
					| ags_clean == 14086 | ags_clean == 14084
				qui replace ags_clean = 15002 if ags_clean == 15202
				qui replace ags_clean = 15003 if ags_clean == 15303
				qui replace ags_clean = 15083 if ags_clean == 15362 | ags_clean == 15355
				qui replace ags_clean = 15084 if ags_clean == 15256 | ags_clean == 15268
				qui replace ags_clean = 15087 if ags_clean == 15266 | ags_clean == 15260
				qui replace ags_clean = 15088 if ags_clean == 15265 | ags_clean == 15261
				qui replace ags_clean = 15997 if ags_clean == 15363 | ags_clean == 15081 | ags_clean == 15090 ///
					| ags_clean == 15370 
				qui replace ags_clean = 15998 if ags_clean == 15352 | ags_clean == 15085 | ags_clean == 15369 ///
					| ags_clean == 15367 |  ags_clean == 15153 | ags_clean == 15364 | ags_clean == 15089 ///
						| ags_clean == 15357
				qui replace ags_clean = 15999 if ags_clean == 15101 | ags_clean == 15171 | ags_clean == 15159 ///
					| ags_clean == 15151 |  ags_clean == 15091 | ags_clean == 15001 | ags_clean == 15082 ///
						| ags_clean == 15086 | 	ags_clean == 15358 | ags_clean == 15154
				qui replace ags_clean = 16999 if ags_clean == 16056 | ags_clean == 16063
				
	/* OLD
	
	*Kreiskennziffern vereinheitlichen
	replace lkrid=2000 if lkrid==2  // Hamburg
	replace lkrid=11000 if lkrid==11 // Berlin
	gen lkr1000=floor(lkrid/1000) if lkrid>99999
	replace lkrid=lkr1000 if lkrid>99999  // Kreiskennziffern auf 4-5 Stellen einschraenken
	drop if lkrid<=1000 // zu kurze Kreiskennziffer loeschen
	drop if lkrid>99999 // zu lange Kreiskennziffer loeschen
	
	*Wenn nur Flaechenlaender angegeben sind: loeschen
	drop if lkrid==1000 | lkrid==3000 | lkrid==4000 | lkrid==5000 | lkrid==6000 | lkrid==7000 | lkrid==8000 | lkrid==9000 | lkrid==10000 | lkrid==12000 | lkrid==13000 | lkrid==14000 | lkrid==15000 | lkrid==16000
	gen ab_ags=lkrid
	merge m:1 ab_ags using ${kreisreform}kreisreformen.dta  // Neue Kreiskennziffern angeben
	*drop if _m==2 //when data is not in hospital
	gen ags_clean=lkrid if _merge==1	// no reform took pleace
	replace ags_clean=auf_ags if _merge==3
	*drop _merge
	rename _merge merge_kreisreform
	*/

********************************************************************************
*****  Recode Gender  *****
	qui gen female = cond(EF3==2,1,0)
	label define GENDER 0 "Male" 1 "Female"
	label values female GENDER


	
	save "$temp\prepared_`wave'.dta", replace
} // end: loop 2000-2014



////////////////////////////////////////////////////////////////////////////////
		*****  GENERATE CROSS SECTION & MERGE WITH AMR/ROR *****
////////////////////////////////////////////////////////////////////////////////
// generate repeated cross-section
use "$temp\prepared_1995.dta", clear

foreach x of numlist 1996(1)2014 {
	qui append using "$temp\prepared_`x'.dta"
	qui erase "$temp\prepared_`x'.dta"
}
	qui erase "$temp\prepared_1995.dta"

	
	order year YOB MOB  lkrid ags 


	drop if ags_clean == .
	drop if ags_clean == 11000 // Berlin
	
	qui save "$temp/einzeldaten_repeatedcs_prepared", replace

// Aggregieren auf Kreisregion
collapse (sum) Diag* hospital patients Summ_stay=Verweildauer Sum_surgery=Op (mean) Share_surgery=Op ///
		Length_of_stay=Verweildauer, by(year YOB MOB female ags_clean)

*reshape
	qui gen j = "_f" if female == 1
	qui replace j = "_m" if female == 0
	drop female
	reshape wide Diag_death - Length_of_stay , i(YOB MOB year ags_clean) j(j) strin
	sort ags YOB year MOB
	
*totals
#delim ;
local totals 
	Diag1 Diag2 Diag3 Diag4 Diag5 Diag6 Diag7 Diag8 Diag9 Diag10 Diag11 Diag12 Diag13 Diag14 Diag17 Diag18 
	Diag_metabolic_syndrome Diag_Index_respiratory Diag_symp_circ_resp Diag_symp_verdauung Diag_sonst_herzkrank
	Diag_psych_drogen Diag_diabetis Diag_hypertension Diag_ischemic Diag_adipositas Diag_infect_lung Diag_pneumonia
	Diag_chron_lung Diag_asthma Diag_infec_intestine Diag_leukemia Diag_shizophrenia Diag_affective
	Diag_neurosis Diag_personality Diag_childhood Diag_ear Diag_otitis_media 
	Diag_death
	hospital patients Summ_stay Sum_surgery;
#delim cr
// averages :Share_surgery/Length_of_stay
foreach var in `totals' {
		qui egen `var' = rowtotal(`var'_m `var'_f)
}
 order ags  YOB MOB year  *_f *_m
 
 // renameing
	rename Diag1			d1
	rename Diag1_f			d1_f
	rename Diag1_m			d1_m
	rename Diag2 	 		d2
	rename Diag2_f 			d2_f
	rename Diag2_m 			d2_m
	rename Diag3 	 		d3
	rename Diag3_f 			d3_f
	rename Diag3_m 			d3_m
	rename Diag4 	 		d4
	rename Diag4_f 			d4_f
	rename Diag4_m 			d4_m
	rename Diag5			d5
	rename Diag5_f			d5_f
	rename Diag5_m			d5_m
	rename Diag6			d6
	rename Diag6_f			d6_f
	rename Diag6_m			d6_m
	rename Diag7 			d7	
	rename Diag7_f 			d7_f
	rename Diag7_m 			d7_m
	rename Diag8 			d8 
	rename Diag8_f 			d8_f 
	rename Diag8_m 			d8_m 
	rename Diag9 			d9 		
	rename Diag9_f 			d9_f 			
	rename Diag9_m 			d9_m 		
	rename Diag10 			d10
	rename Diag10_f 		d10_f
	rename Diag10_m 		d10_m
	rename Diag11  			d11
	rename Diag11_f 		d11_f
	rename Diag11_m 		d11_m
	rename Diag12 			d12
	rename Diag12_f 		d12_f
	rename Diag12_m 		d12_m
	rename Diag13  			d13
	rename Diag13_f 		d13_f
	rename Diag13_m 		d13_m	
	rename Diag14			d14
	rename Diag17 			d17
	rename Diag17_f 		d17_f
	rename Diag17_m 		d17_m
	rename Diag18 			d18
	rename Diag18_f 		d18_f
	rename Diag18_m 		d18_m	
	
	rename Diag_metabolic_syndrome		metabolic_syndrome
	rename Diag_metabolic_syndrome_f	metabolic_syndrome_f
	rename Diag_metabolic_syndrome_m	metabolic_syndrome_m
	rename Diag_Index_respiratory 		respiratory_index
	rename Diag_Index_respiratory_f 	respiratory_index_f
	rename Diag_Index_respiratory_m 	respiratory_index_m
	rename Diag_sonst_herzkrank 		heart
	rename Diag_sonst_herzkrank_f 		heart_f
	rename Diag_sonst_herzkrank_m 		heart_m
	rename Diag_psych_drogen 			drug_abuse
	rename Diag_psych_drogen_f 			drug_abuse_f
	rename Diag_psych_drogen_m 			drug_abuse_m
	
	qui rename Diag_symp_circ_resp			symp_circ_resp
	qui rename Diag_symp_circ_resp_f		symp_circ_resp_f	
	qui rename Diag_symp_circ_resp_m		symp_circ_resp_m	
	qui rename Diag_symp_verdauung  		symp_digest  
	qui rename Diag_symp_verdauung_f		symp_digest_f
	qui rename Diag_symp_verdauung_m		symp_digest_m
	qui rename Diag_diabetis  				diabetis  
	qui rename Diag_diabetis_f				diabetis_f
	qui rename Diag_diabetis_m				diabetis_m
	qui rename Diag_hypertension  			hypertension
	qui rename Diag_hypertension_f			hypertension_f
	qui rename Diag_hypertension_m			hypertension_m
	qui rename Diag_ischemic  				ischemic
	qui rename Diag_ischemic_f				ischemic_f
	qui rename Diag_ischemic_m				ischemic_m
	qui rename Diag_adipositas  			adipositas
	qui rename Diag_adipositas_f			adipositas_f
	qui rename Diag_adipositas_m			adipositas_m
	qui rename Diag_infect_lung  			lung_infect
	qui rename Diag_infect_lung_f			lung_infect_f
	qui rename Diag_infect_lung_m			lung_infect_m
	qui rename Diag_pneumonia  				pneumonia  				
	qui rename Diag_pneumonia_f				pneumonia_f				
	qui rename Diag_pneumonia_m				pneumonia_m				
	qui rename Diag_chron_lung  			lung_chron	
	qui rename Diag_chron_lung_f			lung_chron_f
	qui rename Diag_chron_lung_m			lung_chron_m
	qui rename Diag_asthma  				asthma
	qui rename Diag_asthma_f				asthma_f
	qui rename Diag_asthma_m				asthma_m
	qui rename Diag_infec_intestine  		intestine_infec  		
	qui rename Diag_infec_intestine_f		intestine_infec_f
	qui rename Diag_infec_intestine_m		intestine_infec_m
	qui rename Diag_leukemia  				leukemia  				
	qui rename Diag_leukemia_f				leukemia_f				
	qui rename Diag_leukemia_m				leukemia_m				
	qui rename Diag_shizophrenia  			shizophrenia  			
	qui rename Diag_shizophrenia_f			shizophrenia_f			
	qui rename Diag_shizophrenia_m			shizophrenia_m			
	qui rename Diag_affective				affective			
	qui rename Diag_affective_f				affective_f			
	qui rename Diag_affective_m				affective_m			
	qui rename Diag_neurosis				neurosis			
	qui rename Diag_neurosis_f				neurosis_f			
	qui rename Diag_neurosis_m				neurosis_m			
	qui rename Diag_personality				personality			
	qui rename Diag_personality_f			personality_f				
	qui rename Diag_personality_m			personality_m				
	qui rename Diag_childhood				childhood			
	qui rename Diag_childhood_f				childhood_f			
	qui rename Diag_childhood_m				childhood_m			
	qui rename Diag_ear						ear	
	qui rename Diag_ear_f					ear_f		
	qui rename Diag_ear_m					ear_m		
	qui rename Diag_otitis_media			otitis_media				
	qui rename Diag_otitis_media_f			otitis_media_f				
	qui rename Diag_otitis_media_m			otitis_media_m	
	qui rename Diag_death					death
	qui rename Diag_death_f					death_f
	qui rename Diag_death_m					death_m
	
	

	
	
 
 
	*save "$temp\data_final", replace
	

////////////////////////////////////////////////////////////////////////////////
		*****  AGGREGIEREN UND DATEN DRANMERGEN  *****
////////////////////////////////////////////////////////////////////////////////
*use "$temp\data_final", clear




// a)Regionaldaten
	merge m:1 ags_clean year using ${temp}\exportfile_yearly_clean.dta, gen(merge_regionaldaten) // Jahresebene wird vervielfacht
	drop _001_ypop_*
	/*

    Result                           # of obs.
    -----------------------------------------
    not matched                         3,273
        from master                         0  (merge_regionaldaten==1)
        from using                      3,273  (merge_regionaldaten==2)

    matched                             8,517  (merge_regionaldaten==3)
    -----------------------------------------


	merge 2 Fälle sollten in der Realität nicht vorkommen
	*/
	keep if merge_regionaldaten == 3
	merge m:1 ags_clean year YOB using "$temp/RS_population_ags"
	keep if _merge == 3
	drop _merge
	
	
// b) Geburtsgewichte 
	qui gen bula = floor(ags_clean/1000)
	qui gen GDR = cond(bula>=11 & bula<=16,1,0)
	drop if bula == 11
	order ags_clean bula GDR YOB MOB year 
	*merge m:1 YOB MOB GDR year using "$temp/MZ_gewichte_prepared.dta"
	merge m:1 YOB MOB GDR using "$temp/geburten_GDR"	//gender specific weights
	drop _merge
	
	
	
	
* averages	
*qui gen share_surgery = (hospital_f/ hospital)* share_surgery_f + ( hospital_m/hospital)* share_surgery_m
*qui gen length_of_stay = (hospital_f/ hospital)* length_of_stay_f + ( hospital_m/hospital)* length_of_stay_m
	
	
qui save "$temp/KKH_ags_level_raw", replace	







********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
//2)  AMR Aggregieren
********************************************************************************
********************************************************************************=
********************************************************************************

use "$temp/einzeldaten_repeatedcs_prepared", clear

*merge with amr dataset
merge m:1 ags_clean using "$AMR/ags_clean_amr_ror_umsteiger.dta" 
// merge 2 Fälle should not be existent in reality
drop if amr_clean == 205 // Berlin
order ags_clean amr_clean YOB MOB year 

// Aggregieren auf AMR Region
collapse (sum) Diag* hospital patients Summ_stay=Verweildauer Sum_surgery=Op (mean) Share_surgery=Op ///
		Length_of_stay=Verweildauer, by(year YOB MOB female amr_clean)

*reshape
	qui gen j = "_f" if female == 1
	qui replace j = "_m" if female == 0
	drop female
	reshape wide Diag_death - Length_of_stay , i(YOB MOB year amr_clean) j(j) strin
	sort amr YOB year MOB
	
*totals
#delim ;
local totals 
	Diag1 Diag2 Diag3 Diag4 Diag5 Diag6 Diag7 Diag8 Diag9 Diag10 Diag11 Diag12 Diag13 Diag14 Diag17 Diag18 
	Diag_metabolic_syndrome Diag_Index_respiratory Diag_symp_circ_resp Diag_symp_verdauung Diag_sonst_herzkrank
	Diag_psych_drogen Diag_diabetis Diag_hypertension Diag_ischemic Diag_adipositas Diag_infect_lung Diag_pneumonia
	Diag_chron_lung Diag_asthma Diag_infec_intestine Diag_leukemia Diag_shizophrenia Diag_affective
	Diag_neurosis Diag_personality Diag_childhood Diag_ear Diag_otitis_media 
	Diag_death
	hospital patients Summ_stay Sum_surgery;
#delim cr
// averages :Share_surgery/Length_of_stay
foreach var in `totals' {
		qui egen `var' = rowtotal(`var'_m `var'_f)
}
 
 // renameing
	rename Diag1			d1
	rename Diag1_f			d1_f
	rename Diag1_m			d1_m
	rename Diag2 	 		d2
	rename Diag2_f 			d2_f
	rename Diag2_m 			d2_m
	rename Diag3 	 		d3
	rename Diag3_f 			d3_f
	rename Diag3_m 			d3_m
	rename Diag4 	 		d4
	rename Diag4_f 			d4_f
	rename Diag4_m 			d4_m
	rename Diag5			d5
	rename Diag5_f			d5_f
	rename Diag5_m			d5_m
	rename Diag6			d6
	rename Diag6_f			d6_f
	rename Diag6_m			d6_m
	rename Diag7 			d7	
	rename Diag7_f 			d7_f
	rename Diag7_m 			d7_m
	rename Diag8 			d8 
	rename Diag8_f 			d8_f 
	rename Diag8_m 			d8_m 
	rename Diag9 			d9 		
	rename Diag9_f 			d9_f 			
	rename Diag9_m 			d9_m 		
	rename Diag10 			d10
	rename Diag10_f 		d10_f
	rename Diag10_m 		d10_m
	rename Diag11  			d11
	rename Diag11_f 		d11_f
	rename Diag11_m 		d11_m
	rename Diag12 			d12
	rename Diag12_f 		d12_f
	rename Diag12_m 		d12_m
	rename Diag13  			d13
	rename Diag13_f 		d13_f
	rename Diag13_m 		d13_m	
	rename Diag14			d14
	rename Diag17 			d17
	rename Diag17_f 		d17_f
	rename Diag17_m 		d17_m
	rename Diag18 			d18
	rename Diag18_f 		d18_f
	rename Diag18_m 		d18_m	
	
	rename Diag_metabolic_syndrome		metabolic_syndrome
	rename Diag_metabolic_syndrome_f	metabolic_syndrome_f
	rename Diag_metabolic_syndrome_m	metabolic_syndrome_m
	rename Diag_Index_respiratory 		respiratory_index
	rename Diag_Index_respiratory_f 	respiratory_index_f
	rename Diag_Index_respiratory_m 	respiratory_index_m
	rename Diag_sonst_herzkrank 		heart
	rename Diag_sonst_herzkrank_f 		heart_f
	rename Diag_sonst_herzkrank_m 		heart_m
	rename Diag_psych_drogen 			drug_abuse
	rename Diag_psych_drogen_f 			drug_abuse_f
	rename Diag_psych_drogen_m 			drug_abuse_m
	
	qui rename Diag_symp_circ_resp			symp_circ_resp
	qui rename Diag_symp_circ_resp_f		symp_circ_resp_f	
	qui rename Diag_symp_circ_resp_m		symp_circ_resp_m	
	qui rename Diag_symp_verdauung  		symp_digest  
	qui rename Diag_symp_verdauung_f		symp_digest_f
	qui rename Diag_symp_verdauung_m		symp_digest_m
	qui rename Diag_diabetis  				diabetis  
	qui rename Diag_diabetis_f				diabetis_f
	qui rename Diag_diabetis_m				diabetis_m
	qui rename Diag_hypertension  			hypertension
	qui rename Diag_hypertension_f			hypertension_f
	qui rename Diag_hypertension_m			hypertension_m
	qui rename Diag_ischemic  				ischemic
	qui rename Diag_ischemic_f				ischemic_f
	qui rename Diag_ischemic_m				ischemic_m
	qui rename Diag_adipositas  			adipositas
	qui rename Diag_adipositas_f			adipositas_f
	qui rename Diag_adipositas_m			adipositas_m
	qui rename Diag_infect_lung  			lung_infect
	qui rename Diag_infect_lung_f			lung_infect_f
	qui rename Diag_infect_lung_m			lung_infect_m
	qui rename Diag_pneumonia  				pneumonia  				
	qui rename Diag_pneumonia_f				pneumonia_f				
	qui rename Diag_pneumonia_m				pneumonia_m				
	qui rename Diag_chron_lung  			lung_chron	
	qui rename Diag_chron_lung_f			lung_chron_f
	qui rename Diag_chron_lung_m			lung_chron_m
	qui rename Diag_asthma  				asthma
	qui rename Diag_asthma_f				asthma_f
	qui rename Diag_asthma_m				asthma_m
	qui rename Diag_infec_intestine  		intestine_infec  		
	qui rename Diag_infec_intestine_f		intestine_infec_f
	qui rename Diag_infec_intestine_m		intestine_infec_m
	qui rename Diag_leukemia  				leukemia  				
	qui rename Diag_leukemia_f				leukemia_f				
	qui rename Diag_leukemia_m				leukemia_m				
	qui rename Diag_shizophrenia  			shizophrenia  			
	qui rename Diag_shizophrenia_f			shizophrenia_f			
	qui rename Diag_shizophrenia_m			shizophrenia_m			
	qui rename Diag_affective				affective			
	qui rename Diag_affective_f				affective_f			
	qui rename Diag_affective_m				affective_m			
	qui rename Diag_neurosis				neurosis			
	qui rename Diag_neurosis_f				neurosis_f			
	qui rename Diag_neurosis_m				neurosis_m			
	qui rename Diag_personality				personality			
	qui rename Diag_personality_f			personality_f				
	qui rename Diag_personality_m			personality_m				
	qui rename Diag_childhood				childhood			
	qui rename Diag_childhood_f				childhood_f			
	qui rename Diag_childhood_m				childhood_m			
	qui rename Diag_ear						ear	
	qui rename Diag_ear_f					ear_f		
	qui rename Diag_ear_m					ear_m		
	qui rename Diag_otitis_media			otitis_media				
	qui rename Diag_otitis_media_f			otitis_media_f				
	qui rename Diag_otitis_media_m			otitis_media_m	
	qui rename Diag_death					death
	qui rename Diag_death_f					death_f
	qui rename Diag_death_m					death_m
	
	


// a)Regionaldaten
	merge m:1 amr_clean year using ${temp}\exportfile_yearly_clean_AMR_heterogen.dta, gen(merge_regionaldaten) // Jahresebene wird vervielfacht
	drop _001_ypop_*
	/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         1,672
        from master                        15  (merge_regionaldaten==1)
        from using                      1,657  (merge_regionaldaten==2)

    matched                             8,062  (merge_regionaldaten==3)
    -----------------------------------------



	merge 2 Fälle sollten in der Realität nicht vorkommen
	*/
	keep if merge_regionaldaten == 3
	merge m:1 amr_clean year YOB using "$temp/RS_population_amr"
	keep if _merge == 3
	drop _merge
	
	
// b) Geburtsgewichte 
	merge m:1 amr_clean using "$temp/amr_gdr_classification"
	drop _merge
	/* Merge 2 Fälle sollte es nicht geben
	   Merge 1 Fälle???
	*/

	order amr_clean GDR YOB MOB year 
	*merge m:1 YOB MOB GDR year using "$temp/MZ_gewichte_prepared.dta"
	merge m:1 YOB MOB GDR using "$temp/geburten_GDR"	//gender specific weights
	drop _merge
	
	
	
	
* averages	
*qui gen share_surgery = (hospital_f/ hospital)* share_surgery_f + ( hospital_m/hospital)* share_surgery_m
*qui gen length_of_stay = (hospital_f/ hospital)* length_of_stay_f + ( hospital_m/hospital)* length_of_stay_m
	
	
qui save "$temp/KKH_amr_level_raw", replace	




********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
//3)  OST WEST Aggregieren
********************************************************************************
********************************************************************************=
********************************************************************************

use "$temp/einzeldaten_repeatedcs_prepared", clear
qui gen bula = floor(ags_clean/1000)
qui gen GDR = cond(bula>=11 & bula<=16,1,0)
drop if bula == 11



// Aggregieren auf GDR Region
collapse (sum) Diag* hospital patients Summ_stay=Verweildauer Sum_surgery=Op (mean) Share_surgery=Op ///
		Length_of_stay=Verweildauer, by(year YOB MOB female GDR)

*reshape
	qui gen j = "_f" if female == 1
	qui replace j = "_m" if female == 0
	drop female
	reshape wide Diag_death - Length_of_stay , i(YOB MOB year GDR) j(j) strin
	sort GDR YOB year MOB
	
*totals
#delim ;
local totals 
	Diag1 Diag2 Diag3 Diag4 Diag5 Diag6 Diag7 Diag8 Diag9 Diag10 Diag11 Diag12 Diag13 Diag14 Diag17 Diag18 
	Diag_metabolic_syndrome Diag_Index_respiratory Diag_symp_circ_resp Diag_symp_verdauung Diag_sonst_herzkrank
	Diag_psych_drogen Diag_diabetis Diag_hypertension Diag_ischemic Diag_adipositas Diag_infect_lung Diag_pneumonia
	Diag_chron_lung Diag_asthma Diag_infec_intestine Diag_leukemia Diag_shizophrenia Diag_affective
	Diag_neurosis Diag_personality Diag_childhood Diag_ear Diag_otitis_media 
	Diag_death
	hospital patients Summ_stay Sum_surgery;
#delim cr
// averages :Share_surgery/Length_of_stay
foreach var in `totals' {
		qui egen `var' = rowtotal(`var'_m `var'_f)
}
 
 // renameing
	rename Diag1			d1
	rename Diag1_f			d1_f
	rename Diag1_m			d1_m
	rename Diag2 	 		d2
	rename Diag2_f 			d2_f
	rename Diag2_m 			d2_m
	rename Diag3 	 		d3
	rename Diag3_f 			d3_f
	rename Diag3_m 			d3_m
	rename Diag4 	 		d4
	rename Diag4_f 			d4_f
	rename Diag4_m 			d4_m
	rename Diag5			d5
	rename Diag5_f			d5_f
	rename Diag5_m			d5_m
	rename Diag6			d6
	rename Diag6_f			d6_f
	rename Diag6_m			d6_m
	rename Diag7 			d7	
	rename Diag7_f 			d7_f
	rename Diag7_m 			d7_m
	rename Diag8 			d8 
	rename Diag8_f 			d8_f 
	rename Diag8_m 			d8_m 
	rename Diag9 			d9 		
	rename Diag9_f 			d9_f 			
	rename Diag9_m 			d9_m 		
	rename Diag10 			d10
	rename Diag10_f 		d10_f
	rename Diag10_m 		d10_m
	rename Diag11  			d11
	rename Diag11_f 		d11_f
	rename Diag11_m 		d11_m
	rename Diag12 			d12
	rename Diag12_f 		d12_f
	rename Diag12_m 		d12_m
	rename Diag13  			d13
	rename Diag13_f 		d13_f
	rename Diag13_m 		d13_m	
	rename Diag14			d14
	rename Diag17 			d17
	rename Diag17_f 		d17_f
	rename Diag17_m 		d17_m
	rename Diag18 			d18
	rename Diag18_f 		d18_f
	rename Diag18_m 		d18_m	
	
	rename Diag_metabolic_syndrome		metabolic_syndrome
	rename Diag_metabolic_syndrome_f	metabolic_syndrome_f
	rename Diag_metabolic_syndrome_m	metabolic_syndrome_m
	rename Diag_Index_respiratory 		respiratory_index
	rename Diag_Index_respiratory_f 	respiratory_index_f
	rename Diag_Index_respiratory_m 	respiratory_index_m
	rename Diag_sonst_herzkrank 		heart
	rename Diag_sonst_herzkrank_f 		heart_f
	rename Diag_sonst_herzkrank_m 		heart_m
	rename Diag_psych_drogen 			drug_abuse
	rename Diag_psych_drogen_f 			drug_abuse_f
	rename Diag_psych_drogen_m 			drug_abuse_m
	
	qui rename Diag_symp_circ_resp			symp_circ_resp
	qui rename Diag_symp_circ_resp_f		symp_circ_resp_f	
	qui rename Diag_symp_circ_resp_m		symp_circ_resp_m	
	qui rename Diag_symp_verdauung  		symp_digest  
	qui rename Diag_symp_verdauung_f		symp_digest_f
	qui rename Diag_symp_verdauung_m		symp_digest_m
	qui rename Diag_diabetis  				diabetis  
	qui rename Diag_diabetis_f				diabetis_f
	qui rename Diag_diabetis_m				diabetis_m
	qui rename Diag_hypertension  			hypertension
	qui rename Diag_hypertension_f			hypertension_f
	qui rename Diag_hypertension_m			hypertension_m
	qui rename Diag_ischemic  				ischemic
	qui rename Diag_ischemic_f				ischemic_f
	qui rename Diag_ischemic_m				ischemic_m
	qui rename Diag_adipositas  			adipositas
	qui rename Diag_adipositas_f			adipositas_f
	qui rename Diag_adipositas_m			adipositas_m
	qui rename Diag_infect_lung  			lung_infect
	qui rename Diag_infect_lung_f			lung_infect_f
	qui rename Diag_infect_lung_m			lung_infect_m
	qui rename Diag_pneumonia  				pneumonia  				
	qui rename Diag_pneumonia_f				pneumonia_f				
	qui rename Diag_pneumonia_m				pneumonia_m				
	qui rename Diag_chron_lung  			lung_chron	
	qui rename Diag_chron_lung_f			lung_chron_f
	qui rename Diag_chron_lung_m			lung_chron_m
	qui rename Diag_asthma  				asthma
	qui rename Diag_asthma_f				asthma_f
	qui rename Diag_asthma_m				asthma_m
	qui rename Diag_infec_intestine  		intestine_infec  		
	qui rename Diag_infec_intestine_f		intestine_infec_f
	qui rename Diag_infec_intestine_m		intestine_infec_m
	qui rename Diag_leukemia  				leukemia  				
	qui rename Diag_leukemia_f				leukemia_f				
	qui rename Diag_leukemia_m				leukemia_m				
	qui rename Diag_shizophrenia  			shizophrenia  			
	qui rename Diag_shizophrenia_f			shizophrenia_f			
	qui rename Diag_shizophrenia_m			shizophrenia_m			
	qui rename Diag_affective				affective			
	qui rename Diag_affective_f				affective_f			
	qui rename Diag_affective_m				affective_m			
	qui rename Diag_neurosis				neurosis			
	qui rename Diag_neurosis_f				neurosis_f			
	qui rename Diag_neurosis_m				neurosis_m			
	qui rename Diag_personality				personality			
	qui rename Diag_personality_f			personality_f				
	qui rename Diag_personality_m			personality_m				
	qui rename Diag_childhood				childhood			
	qui rename Diag_childhood_f				childhood_f			
	qui rename Diag_childhood_m				childhood_m			
	qui rename Diag_ear						ear	
	qui rename Diag_ear_f					ear_f		
	qui rename Diag_ear_m					ear_m		
	qui rename Diag_otitis_media			otitis_media				
	qui rename Diag_otitis_media_f			otitis_media_f				
	qui rename Diag_otitis_media_m			otitis_media_m	
	qui rename Diag_death					death
	qui rename Diag_death_f					death_f
	qui rename Diag_death_m					death_m
	
	
	
	
	

	

/*
// a)Regionaldaten
	merge m:1 amr_clean year using ${regionalst}\exportfile_yearly_clean_gdr.dta, gen(merge_regionaldaten) // Jahresebene wird vervielfacht
	drop _001_ypop_*
	/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         1,672
        from master                        15  (merge_regionaldaten==1)
        from using                      1,657  (merge_regionaldaten==2)

    matched                             8,062  (merge_regionaldaten==3)
    -----------------------------------------



	merge 2 Fälle sollten in der Realität nicht vorkommen
	*/
	keep if merge_regionaldaten == 3
*/
	merge m:1 GDR year YOB using "$temp/RS_population_gdr"
	keep if _merge == 3
	drop _merge
	
	
// b) Geburtsgewichte 
		order GDR YOB MOB year 
	*merge m:1 YOB MOB GDR year using "$temp/MZ_gewichte_prepared.dta"
	merge m:1 YOB MOB GDR using "$temp/geburten_GDR"	//gender specific weights
	drop _merge
	
	
* averages	
*qui gen share_surgery = (hospital_f/ hospital)* share_surgery_f + ( hospital_m/hospital)* share_surgery_m
*qui gen length_of_stay = (hospital_f/ hospital)* length_of_stay_f + ( hospital_m/hospital)* length_of_stay_m
	
	
qui save "$temp/KKH_gdr_level_raw", replace	











