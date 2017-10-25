//////////////////////////////////////////////////////////////////////////////// 
*	PARENTAL LEAVE PROJECT
*	MAKES:  Zusammenfassung von verschiedenen Diagnosen über monatsgenaues Geburtsdatum
*	USES:   Wellen 2005-2013 von der Krankenhausdiagnosestatistik
*	SAVES:  
*	Author: Marc Fabel
*	Last revision of this Do-File: 25.10.2017 
//////////////////////////////////////////////////////////////////////////////// 


***********************************************
	*** PREAMBLE ***
***********************************************
	clear all
	set more off
	*global path "D:\Data\Gast\GWA22_3053_MF_KH"
	*global path "Z:\ifo\GWA22_2827_MF_KH"
	global path "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h\analysis\do-files\Extrahieren_local"
	* global path "B:\FDZ\Bearbeitung\3053_2016_ifo_Knoche_Hener"
	
	global source "G:\Projekte\Projekte_ab2016\EcUFam\Daten\Krankenhaus-Diagnose-Daten\strukturfiles\" 

	*global source "$path\A_Mikrodaten\"
	*global temp "$path\D_Ergebnisse\temp\" 
	*global tables   "$path\D_Ergebnisse\TABLES"
	*global logfiles "$path\D_Ergebnisse\LOGFILES"
	
	
	global temp "$path\temp" 
	global logfiles "$path\LOGFILES"

	global date1 = substr("$S_DATE",1,2)	// Day
	global date2 = substr("$S_DATE",4,3)	// Month
	global date3 = substr("$S_DATE",10,2)	// Year
	global date = "$date1"  + "$date2" + "$date3" 
	
	capture log close
	*log using "$logfiles\KKH_Metabolic_syndrome_${date}_MarcFabel" , text replace

	
//////////////////////////////////////////////////////////////////////////////// 
/*
Titel des Projekts:				<Maternity leave expansions and long-run child outcomes>
Datengrundlage:					<KKH Daignosestatistik 2005 - 2013>
Dateiname des Programcodes: 	<KKH_Diagnosen.do>
erstellt:						<25.10.2017 >
von:							<Marc Fabel>
Telefon:						<089/92241368>
Email:							<fabel@ifo.de>

Dateinamen des Output-Files:	<KKH_Faelle_DATUM_MarcFabel.log>

Grundriss des Programms:
	< Zuallererst werden die einzelnen Wellen der KKH Diagnose-Einzeldaten vor-
	bereitet. Dies bedeuted es werden notwendige Variablen generiert, die Daten 
	auf das relevante sample beschränkt (Geburtskohorten 1976-1980, 1985-1995),
	und für Kreisreformen korrigiert. Anschließend werden die einzelnen Wellen 
	zu einer repeated Cross-Section zusammengesetzt, welche das Datenset dar-
	stellt mit dem ich arbeiten werde. 
	Im Anschluss werden die Daten zusammengefasst (collapse) indem einzelne 
	Diagnosekategorien über Personen mit dem selben monatsgenauen Geburtsdatum und
	verschiedene räumliche Tiefen aufsummiert werden (Im zweiten Schritt auch nach 
	Gerschlecht). Die regionale Disagregierung betrifft(in zunehmender Tiefe): 
	Ost-West Vergleich,	Raumregionen (siehe weiter unten), Bundesländer, 
	Regierungsbezirke und selten Kreise. Da besondere ist, dass im finalen Output nur 
	Variablen auftauchen, die den Anforderungen der Geheimhaltungsprüfung genügen, 
	sodass pro Observation nur Variablen enthalten sind, die Beobahtungen größer\
	gleich drei enthalten. 
		

Verwendete Variablen:
	a) Original variablen:														
																				
						   <EF3:			Geschlecht
						    EF5:			Zugangsdatum
							EF8:			Hauptdiagnose (ICD-Schlüssel)
							EF13U2:			Alter in Monaten								
							EF14: 			Patientenwohnort (AGS-Schlüssel)
							>
							
						
	b)Neu angelegt Variablen: (alphabetisch geordnet)
						   <bula:			Kategorische Variable: entspricht den 16 Bundesländern
						    Datum: 			Geburtsdatum (im STATA time format, monthly)
							Diag_NAME		Dich. Variable: für bedeutende Einzeldiagnosen (orientiert isch an der europäischen Kurzliste)
						    GDR:			Dich. Variable: alte/neue Bundesländer
							MOB:			Geburtsmonat
							year: 			Survey Jahr, korrigiert durch die Jahresüberhänge
							YOB: 			Geburtsjahr
							>
					
*/
//////////////////////////////////////////////////////////////////////////////// 	
	
	
////////////////////////////////////////////////////////////////////////////////
	
	
//einzelne Wellen vorbereiten
// 1995-1999
foreach wave of numlist 1995(1)1999 {

	 use "$source\dstf_sa95_`wave'.dta", clear
	 *use "$source\dstf_sa95_1995.dta", clear
	 *use "$source\kdfv_sa95_`wave'.dta", clear
	 
	*use "$source\gwap_sa95_2013.dta", clear
 
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
	keep if (Datum >= tm(1976m11) & Datum <= tm(1980m10)) | /// 
			(Datum >= tm(1985m7)  & Datum <= tm(1989m6)) | ///
			(Datum >= tm(1990m7)  & Datum <= tm(1995m6))

	sort Datum
	order YOB MOB

********************************************************************************
		*****  Diagnosenzusammenfassung  *****
********************************************************************************	
	*encode three digit number
	*destring EF8, gen(lkrid) force
	
	*Main Diagnosis
	qui gen diag0 = substr(EF8,1,1)
	qui gen diag00 = substr(EF8,1,2)
	qui gen diag000 = substr(EF8,1,3)
	*qui gen diag0000 = 
	
	*encode different versions:
	destring diag0, replace force
	destring diag00, replace force
	destring diag000, replace force
	drop if diag0 ==.
	
	//Daignose
	qui gen Diag_metabolic_syndrome = 1 if (diag000 == 250) // diabetes
	qui replace Diag_metabolic_syndrome = 1 if (diag000 == 401 | diag000 == 402 | diag000 == 404 | diag000 == 405) //bluthochdruck
	qui replace Diag_metabolic_syndrome = 1 if (diag000 == 278) // Adipositas und übergewicht
	qui replace Diag_metabolic_syndrome = 1 if (diag000 >= 410 & diag000 <= 414) //Ischämische Herzkrankheiten
		
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


	
	save "$temp\prepared_`wave'.dta", replace
} // end: loop 1995-1999



////////////////////////////////////////////////////////////////////////////////
		*****  2000 - 2013  *****
////////////////////////////////////////////////////////////////////////////////	
foreach wave of numlist 2000(1)2013 {

	 use "$source\dstf_sa95_`wave'.dta", clear
	* use "$source\dstf_sa95_2000.dta", clear
	 *use "$source\kdfv_sa95_`wave'.dta", clear
	 
	*use "$source\gwap_sa95_2013.dta", clear
 
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
	keep if (Datum >= tm(1976m11) & Datum <= tm(1980m10)) | /// 
			(Datum >= tm(1985m7)  & Datum <= tm(1989m6)) | ///
			(Datum >= tm(1990m7)  & Datum <= tm(1995m6))

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
	
	//Daignose
	qui gen Diag_metabolic_syndrome = 1 if (diagX == "E" & (diag00>=10 & diag00<=14)) // diabetes
	qui replace Diag_metabolic_syndrome = 1 if (diagX == "I" & (diag00 == 10 | diag00 == 11 | diag00 == 13 | diag00 == 15)) //bluthochdruck
	qui replace Diag_metabolic_syndrome = 1 if (diagX == "E" & (diag00 >= 65 & diag00 <= 68)) // Adipositas und übergewicht
	qui replace Diag_metabolic_syndrome = 1 if (diagX == "I" & (diag00 >= 20 & diag00 <= 25)) //Ischämische Herzkrankheiten
		
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


	
	save "$temp\prepared_`wave'.dta", replace
} // end: loop 2000-2013





// generate repeated cross-section
use "$temp\prepared_1995.dta", clear

foreach x of numlist 1996(1)2013 {
	qui append using "$temp\prepared_`x'.dta"
	qui erase "$temp\prepared_`x'.dta"
}
	qui erase "$temp\prepared_1995.dta"

	
//Reformkohorten markieren
	qui gen reform=.
	qui replace reform = 1 if (YOB >= 1976 & YOB <= 1980)
	qui replace reform = 2 if (YOB >= 1985 & YOB <= 1989)
	qui replace reform = 3 if (YOB >= 1990 & YOB <= 1995)
	
save "$temp\data_final", replace


//check: 
foreach x of numlist 1996(1)2013 {
	summ Diag* if year == `x'
}


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

//COLLAPSE für einzelne Variablen
	
	/* Notitz an Herrn Bergmann: 
	1) zunächst keine Probleme mit Anzahl der Fälle (immer grösser gleich 3) 
		-> Stellen, die einer Streichung bedürfen, markiere ich extra
	2) keine Diagnose wird in unterschiedlichen tiefen angefragt, d.h. ich frage immer die 
	tiefstmögliche tiefe an und sonst aggregiere ich hoch (z.B. nicht nach geschlecht)
	3) tiefste Ebene ist: Anzahl der Fälle nach Geburtsmonat, Ost/West und Geschlecht
	*/
	

	

	
	*1) auf West/Ost collapsen -- alle Kohorten
	use "$temp\data_final.dta", clear
	collapse (sum) Diag_metabolic_syndrome, ///
		by(year YOB MOB GDR female)
	save "$tables/8_Metabolic_syndrome.dta", replace
	
	
	
log close	
	
	
	
	
	


