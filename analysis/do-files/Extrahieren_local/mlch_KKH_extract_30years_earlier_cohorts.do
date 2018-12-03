//////////////////////////////////////////////////////////////////////////////// 
*	PARENTAL LEAVE PROJECT
*	MAKES:  Zusammenfassung von verschiedenen Diagnosen über monatsgenaues Geburtsdatum
*	USES:   Wellen 1995-2013 von der Krankenhausdiagnosestatistik
*	SAVES:  
*	Author: Marc Fabel
*	Last revision of this Do-File: 30.11.2018 
//////////////////////////////////////////////////////////////////////////////// 


***********************************************
	*** PREAMBLE ***
***********************************************
	clear all
	set more off


/*	
* GWAP LANDESAMT (FÜR HERR BERGMANN)
	global path 		"Z:\Gast\ifo\GWA22_3053_MF_KH\"
	*global path 		"D:\Data\Gast\GWA22_3053_MF_KH"
	*global path 		"Z:\ifo\GWA22_2827_MF_KH"
	global KKH	 		"$path\A_Mikrodaten\"
	global temp 		"$path\D_Ergebnisse\Fabel\temp\" 
	global tables   	"$path\D_Ergebnisse\Fabel\TABLES"
	global graphs		"$path\D_Ergebnisse\Fabel\GRAPHS"
	global logfiles 	"$path\D_Ergebnisse\Fabel\LOGFILES"
	global dofiles		"$path\C_Programm\Fabel\"
	global AMR			"$path\A_Mikrodaten"		// KREIS, RAUMORDNUNGSREGION -> Umsteiger: enthält die Datei "ags_clean_amr_ror_umsteiger.dta"
	global anspielen	"$path\A_Mikrodaten"		// enthält die von Herrn Janisch herangespeilten Daten, relevante Datei: kkh_mon_merged.dta
	global MZ_anspielen	"$path/A_Mikrodaten"		// verweist auf die Datei MZ_merge (von Hrrn. Janisch erhalten) 
	global file			"kdfv_sa95"
	*global file 		"gwap_sa95_"
*/

/*	
* Landesamt (Für mich)
	global path 		"Z:\ifo\GWA22_3053_MF_KH"
	global KKH	 		"$path\A_Mikrodaten\"
	global temp 		"$path\D_Ergebnisse\temp\" 
	global tables   	"$path\D_Ergebnisse\TABLES"
	global graphs 		"$path\D_Ergebnisse\GRAPHS"
	global logfiles 	"$path\D_Ergebnisse\LOGFILES"
	global dofiles		"$path\C_Programm"
	global file			"kdfv_sa95"
*/
	

* Lokale Maschine
	global path "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h\analysis\do-files\Extrahieren_local"	
	global KKH	 		"G:\Projekte\Projekte_ab2016\EcUFam\Daten\Krankenhaus-Diagnose-Daten\strukturfiles\" 

	global anspielen	"G:\Projekte\Projekte_ab2016\EcUFam\Daten\Krankenhaus-Diagnose-Daten\strukturfiles\temp"
	global temp 		"$path\D_Ergebnisse\temp" 
	global logfiles		"$path\D_Ergebnisse\LOGFILES"
	global dofiles		"$path"
	global file 		"dstf_sa95"
	global AMR			"G:\Projekte\Projekte_ab2016\EcUFam\Daten\Arbeitsmarktregionen"
	global tables   	"$path\D_Ergebnisse\TABLES"
	global graphs 		"$path\D_Ergebnisse\GRAPHS"
	global MZ_anspielen	"$path/A_Mikrodaten"
	*global regionalst 	"G:\Projekte\Projekte_ab2016\EcUFam\Daten\Regionaldatenbank\Data\Final\output"
	*global kreisreform 	"G:\Projekte\Projekte_ab2016\EcUFam\Daten\Gebietsreformen\finaldata\"
	*global population 	"G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis/source/population"

	
* directory
	cd "$dofiles"
	
*log-file
	global date1 = substr("$S_DATE",1,2)	// Day
	global date2 = substr("$S_DATE",4,3)	// Month
	global date3 = substr("$S_DATE",10,2)	// Year
	global date = "$date1"  + "$date2" + "$date3" 
	
	capture log close
	log using "$logfiles\KKH_extract30_years_1946-1976_${date}_MarcFabel" , text replace

	
//////////////////////////////////////////////////////////////////////////////// 
/*
Titel des Projekts:				<Maternity leave expansions and long-run child outcomes>
Datengrundlage:					<KKH Daignosestatistik 1995 - 2013>
Dateiname des Programcodes: 	<KKH_Diagnosen.do>
erstellt:						<25.10.2017 >
von:							<Marc Fabel>
Telefon:						<089/92241368>
Email:							<fabel@ifo.de>

Dateinamen des Output-Files:	<KKH_Faelle_DATUM_MarcFabel.log>

Grundriss des Programms:
	< Zuallererst werden die einzelnen Wellen der KKH Diagnose-Einzeldaten vor-
	bereitet. Dies bedeuted es werden notwendige Variablen generiert, die Daten 
	auf das relevante sample beschränkt (Geburtskohorten 1946-1976).
	Anschließend werden die einzelnen Wellen zu einer repeated Cross-Section 
	zusammengesetzt, welche das Datenset darstellt mit dem ich arbeiten werde. 
	Im Anschluss werden die Daten zusammengefasst (collapse) indem einzelne 
	Diagnosekategorien über Personen mit dem selben monatsgenauen Geburtsdatum und
	verschiedene räumliche Tiefen aufsummiert werden (Im zweiten Schritt auch nach 
	Gerschlecht). Die regionale Disagregierung betrifft ausschließlich einen 
	Vergelich zwischen Ost-West. Das besondere ist, dass im finalen Output nur 
	Variablen auftauchen, die den Anforderungen der Geheimhaltungsprüfung genügen, 
	sodass pro Observation nur Variablen enthalten sind, die Beobahtungen größer\
	gleich drei enthalten. 
	
	ZUSATZ: Ich habe eine aehnliche Datenstruktur im Juni beantragt, jedoch fuer 
	andere Geburtskohorten (1976-1980) und für deutlich mehr und zum teil feinere
	Diagnosen. D.h. es gibt keinerlei Überschneidungen mit Output, den ich in der
	Vergangenheit schon mal beantragt habe. 
		

Verwendete Variablen:
	a) Original variablen:														
																				
						   <EF3:			Geschlecht
						    EF5:			Zugangsdatum
							EF8:			Hauptdiagnose (ICD-Schlüssel)
							EF10:			Operation (y/n)
							EF12:			Verweildauer
							EF13U2:			Alter in Monaten								
							EF14: 			Patientenwohnort (AGS-Schlüssel)
							>
							
						
	b)Neu angelegt Variablen: (alphabetisch geordnet)
						   <bula:			Kategorische Variable: entspricht den 16 Bundesländern
						    Datum: 			Geburtsdatum (im STATA time format, monthly)
							diagOvrvw		Kategorische Variable (orientiert sich an den 22 Diagnosekapiteln der ICD 10 Systematik)
							Diag_NUMMER		Dich. Variable: für jedes Diagnosekapitel der ICD 10 Systematik
						    GDR:			Dich. Variable: alte/neue Bundesländer
							MOB:			Geburtsmonat
							Op:				entspricht EF10
							year: 			Survey Jahr, korrigiert durch die Jahresüberhänge
							YOB: 			Geburtsjahr
							>
					
*/
//////////////////////////////////////////////////////////////////////////////// 	
	
	
////////////////////////////////////////////////////////////////////////////////
	
	
//einzelne Wellen vorbereiten
// 1995-1999
foreach wave of numlist 1995(1)1999 {

	use "$KKH\${file}_`wave'.dta", clear
	*use "$KKH\${file}_1995.dta", clear
	gen year = `wave'
 
	*Zurückrechnen auf Geburtsdatum:
	*transform EF5 into monthly
	qui gen monthly = mofd(EF5)
	qui gen Datum = monthly - EF13U2
	format Datum %tm
	drop monthly
 
	qui gen MOB = month(dofm(Datum))
	qui gen YOB = year(dofm(Datum))
	
	*restrict to only relevant sample:
	keep if (Datum >= tm(1946m11) & Datum <= tm(1976m10))


	sort Datum
	order YOB MOB

********************************************************************************
		*****  Diagnosenzusammenfassung  *****
********************************************************************************	
	*Main Diagnosis
	qui gen diag0 = substr(EF8,1,1)
	qui gen diag00 = substr(EF8,1,2)
	qui gen diag000 = substr(EF8,1,3)
	*qui gen diag0000 = 
	
	*encode different versions:
	destring diag0, replace force
	destring diag00, replace force
	destring diag000, replace force
	drop if diag0 ==.		// Sind die V Diagnosen (= ICD10: Z Diagnosen; andere Faktoren die den Gesundheitszustand ...)
	
	//Diagnosen
		
	*Hauptdiagnosekapitel
	qui gen Diag_1	= 1 if (diag000 >= 001 & diag000 <= 139)	// Infektiöse Krankheiten
	qui gen Diag_2	= 1 if (diag000 >= 140 & diag000 <= 239)	// Neubildungen
	qui gen Diag_4 	= 1 if (diag000 >= 240 & diag000 <= 278)	// Stoffwechselkrankheiten
	qui gen Diag_5	= 1 if (diag000 >= 290 & diag000 <= 319) 	//*mental and behavioral disorders
	qui gen Diag_6  = 1 if (diag000 >= 320 & diag000 <= 359)	// Krankheiten des Nervensystems
	qui gen Diag_7  = 1 if (diag000 >= 360 & diag000 <= 389)	// Auge & Ohr
	qui gen Diag_8	= 1 if (diag000 >= 390 & diag000 <= 459)	//*Krankheiten des Kreislaufsystems
	qui gen Diag_9	= 1 if (diag000 >= 460 & diag000 <= 519)	//*Atmungssystem
	qui gen Diag_10 = 1 if (diag000 >= 520 & diag000 <= 579)	//* Verdauungssystem
	qui gen Diag_11 = 1 if (diag000 >= 680 & diag000 <= 709)	// Haut
	qui gen Diag_12 = 1 if (diag000 >= 710 & diag000 <= 739)	// Muskel_Skelett_Bindegewebe
	qui gen Diag_13 = 1 if (diag000 >= 580 & diag000 <= 629)	// Urogenitalsystem
	qui gen Diag_14 = 1 if (diag000 >= 630 & diag000 <= 676)	// Schwangerschaft
	qui gen Diag_17 = 1 if (diag000 >= 780 & diag000 <= 799)	// Symptome & abnorme klinische Befunde
	qui gen Diag_18 = 1 if (diag000 >= 800 & diag000 <= 999)	// Verletzungen und co
	
	
	*Metadaten:
	*hospital admission
	qui egen hospital2 = rowtotal(Diag_1 Diag_2 Diag_4 Diag_5 Diag_6 Diag_7 ///
		Diag_8 Diag_9 Diag_10 Diag_11 Diag_12 Diag_13 Diag_17 Diag_18)
	
		
	
	//label variables                                                                 
	label define BINARY 0 "0 No" 1 "1 Yes"
	foreach var of varlist Diag_* {
		label values `var' BINARY
		qui replace `var' = 0 if `var' == .
	}

********************************************************************************
		*****  location  *****
********************************************************************************
	destring EF14, gen(lkrid) force
	
	*Kreiskennziffern vereinheitlichen
	replace lkrid=2000 if lkrid==2  // Hamburg
	replace lkrid=11000 if lkrid==11 // Berlin
	gen lkr1000=floor(lkrid/1000) if lkrid>99999
	replace lkrid=lkr1000 if lkrid>99999  // Kreiskennziffern auf 4-5 Stellen einschraenken
	*Wenn nur Flaechenlaender angegeben sind: loeschen
	drop if lkrid==1000 | lkrid==3000 | lkrid==4000 | lkrid==5000 | lkrid==6000 | lkrid==7000 | lkrid==8000 | lkrid==9000 | lkrid==10000 | lkrid==12000 | lkrid==13000 | lkrid==14000 | lkrid==15000 | lkrid==16000

	drop lkr1000
	
	drop if lkrid<=1000 // zu kurze Kreiskennziffer loeschen
	drop if lkrid>99999 // zu lange Kreiskennziffer loeschen
	*für die kreisebene muss ich noch 

	*Bundesland
	qui gen bula = floor(lkrid/1000)
	keep if bula >=1 & bula <= 16
	
	*Ost-West Deutschland
	qui gen GDR = cond(bula>=11 & bula<=16,1,0)
********************************************************************************
		*****  Recode Gender  *****
********************************************************************************	
	qui gen female = cond(EF3==2,1,0)
	label define GENDER 0 "Male" 1 "Female"
	label values female GENDER

	keep Diag_5 hospital2 female GDR year YOB MOB
	keep if GDR == 0
	collapse (sum) Diag* hospital2, by(year YOB MOB female)
	save "$temp\prepared_`wave'_Nov2018.dta", replace
} // end: loop 1995-1999



////////////////////////////////////////////////////////////////////////////////
		*****  2000 - 2013  *****
////////////////////////////////////////////////////////////////////////////////	
foreach wave of numlist 2000(1)2014 {

	use "$KKH\${file}_`wave'.dta", clear
	*use "$KKH\${file}_2014.dta", clear
	gen year = `wave'
 
	*Zurückrechnen auf Geburtsdatum:
	*transform EF5 into monthly
	qui gen monthly = mofd(EF5)
	qui gen Datum = monthly - EF13U2
	format Datum %tm
	drop monthly
 
	qui gen MOB = month(dofm(Datum))
	qui gen YOB = year(dofm(Datum))
	
	*restrict to only relevant sample:
	keep if (Datum >= tm(1946m11) & Datum <= tm(1976m10))

	sort Datum
	order YOB MOB

********************************************************************************
		*****  Diagnosenzusammenfassung  *****
********************************************************************************	
	
	*Main Diagnosis
	qui gen diagX = substr(EF8,1,1)
	qui gen diagX0 = substr(EF8,1,2)
	
	*encode first two digit:
	qui gen temp = substr(EF8,2,2)
	encode temp, gen(diag00)
	drop temp
	
	*Fälle zusammenfassen, nach Europäischer Kurzliste (aber nur die Hauptaugenmerke, nicht sehr disaggregiert) //	Anzahl 30-35  -> approx Werte pro Kohorte und MOB: West, Region, 
	gen diagOvrvw=.																
	qui replace diagOvrvw=1  if diagX == "A" | diagX == "B"						
	qui replace diagOvrvw=2  if diagX == "C" | (diagX == "D" & diag00<=48)		
	*qui replace diagOvrvw=3  if diagX == "D" & (diag00 >=50 & diag00<=90)		
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
	drop if diagOvrvw == 3
	drop if diagOvrvw == 15		// Fälle die ihren Ursprung in der Perinatalperiode haben 
	drop if diagOvrvw == 16
	drop if diagOvrvw == 19
		

	
	*Hauptdiagnosekapitel
	foreach j of numlist 1/19 {
		qui gen Diag_`j' = 1 if diagOvrvw == `j'
	}
	drop Diag_3 Diag_15 Diag_16 Diag_19
	
	
	
	*Metadaten:
	qui egen hospital2 = rowtotal(Diag_1 Diag_2 Diag_4 Diag_5 Diag_6 Diag_7 ///
		Diag_8 Diag_9 Diag_10 Diag_11 Diag_12 Diag_13 Diag_17 Diag_18)

	
	//label variables                                                                 
	label define BINARY 0 "0 No" 1 "1 Yes"
	foreach var of varlist Diag_* {
		label values `var' BINARY
		qui replace `var' = 0 if `var' == .
	}

********************************************************************************
		*****  location  *****
********************************************************************************
	destring EF14, gen(lkrid) force
	
	*Kreiskennziffern vereinheitlichen
	replace lkrid=2000 if lkrid==2  // Hamburg
	replace lkrid=11000 if lkrid==11 // Berlin
	gen lkr1000=floor(lkrid/1000) if lkrid>99999
	replace lkrid=lkr1000 if lkrid>99999  // Kreiskennziffern auf 4-5 Stellen einschraenken
	*Wenn nur Flaechenlaender angegeben sind: loeschen
	drop if lkrid==1000 | lkrid==3000 | lkrid==4000 | lkrid==5000 | lkrid==6000 | lkrid==7000 | lkrid==8000 | lkrid==9000 | lkrid==10000 | lkrid==12000 | lkrid==13000 | lkrid==14000 | lkrid==15000 | lkrid==16000

	drop lkr1000
	
	drop if lkrid<=1000 // zu kurze Kreiskennziffer loeschen
	drop if lkrid>99999 // zu lange Kreiskennziffer loeschen
	*für die kreisebene muss ich noch 

	*Bundesland
	qui gen bula = floor(lkrid/1000)
	keep if bula >=1 & bula <= 16
	
	*Ost-West Deutschland
	qui gen GDR = cond(bula>=11 & bula<=16,1,0)
********************************************************************************
		*****  Recode Gender  *****
********************************************************************************	
	qui gen female = cond(EF3==2,1,0)
	label define GENDER 0 "Male" 1 "Female"
	label values female GENDER


	keep Diag_5 hospital2 female GDR year YOB MOB
	keep if GDR == 0
	collapse (sum) Diag* hospital2, by(year YOB MOB female)
	save "$temp\prepared_`wave'_Nov2018.dta", replace
} // end: loop 2000-2014





// generate repeated cross-section
use "$temp\prepared_1995_Nov2018.dta", clear

foreach x of numlist 1996(1)2014 {
	qui append using "$temp\prepared_`x'_Nov2018.dta"
	*qui erase "$temp\prepared_`x'_Nov2018.dta"
}
	*qui erase "$temp\prepared_1995_Nov2018.dta"
	
	
	sort YOB MOB year female
	save "$temp/Anfrage_Nov2018_data_final_collapsed_1946-1976.dta", replace	
	
	
		
	
	
log close	
	
	
	
	
	


