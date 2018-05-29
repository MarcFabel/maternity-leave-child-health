/*******************************************************************************
* File name: 	MASTERFILE
* Author: 		Marc Fabel
* Date: 		02.05.2018
* Description:	Executes all relevants Do-Files
*


Titel des Projekts:				<Maternity leave expansions and long-run child outcomes>
Datengrundlage:					<KKH Daignosestatistik 1995 - 2013>
Dateiname des Programcodes: 	<mlch_KKHGWAP_MASTERFILE >
von:							<Marc Fabel>
Telefon:						<089/92241368>
Email:							<fabel@ifo.de>

Dateinamen des Output-Files:	<KKH_prepare_DATUM_MarcFabel.log>

Grundriss des Programms:
	< Zuallererst werden die einzelnen Wellen der KKH Diagnose-Einzeldaten vor-
	bereitet. Dies bedeuted es werden notwendige Variablen generiert, die Daten 
	auf das relevante sample beschränkt (Geburtskohorten 1976-1980, 1985-1995).
	Anschließend werden die einzelnen Wellen zu einer repeated Cross-Section 
	zusammengesetzt, welche das Datenset darstellt mit dem ich arbeiten werde. 
	Im Anschluss werden die Daten zusammengefasst (collapse) indem einzelne 
	Diagnosekategorien über Personen mit dem selben monatsgenauen Geburtsdatum und
	verschiedene räumliche Tiefen aufsummiert werden (Im zweiten Schritt auch nach 
	Gerschlecht). Die regionale Disagregierung betrifft einen 
	Vergleich zwischen Ost-West, eine Aggregierung auf Arbeitsmarktregion und Kreise.

		

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
							Diag_NAME		Dich. Variable: für bedeutende Einzeldiagnosen (orientiert isch an der europäischen Kurzliste)
						    GDR:			Dich. Variable: alte/neue Bundesländer
							MOB:			Geburtsmonat
							Op:				entspricht EF10
							Verweildauer:	entspricht EF12, Unterschied, alle Werte >84 habe ich als missing deklariert (im Ursprungsdatensatz findet sich top-coding wieder)
							year: 			Survey Jahr, korrigiert durch die Jahresüberhänge
							YOB: 			Geburtsjahr
							
							!!! NICHT VOLLSTÄNDIG !!!! WIRD VOR DER NÄCHSTEN ANFRAGE AKTUALISIERT !!!!!!!
							
							>

*******************************************************************************/



// ***************************** PREAMBLE********************************
	clear all
	set more off
/*	
* GWAP LANDESAMT (FÜR HERR BERGMANN)
	global path 		"B:\FDZ\Bearbeitung\3053_2016_ifo_Knoche_Hener"
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
	global file			"kdfv_sa95"
	*global file 		"gwap_sa95_"
*/

	
* Landesamt (Für mich)
	global path 		"Z:\ifo\GWA22_3053_MF_KH"
	*global KKH	 		"$path\A_Mikrodaten\"
	global temp 		"$path\D_Ergebnisse\temp\" 
	global tables   	"$path\D_Ergebnisse\TABLES"
	global graphs 		"$path\D_Ergebnisse\GRAPHS"
	global logfiles 	"$path\D_Ergebnisse\LOGFILES"
	global dofiles		"$path\C_Programm"
	
/*		
* Lokale Maschine
	global path 		"G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h\analysis\do-files\GWAP_analyse"
	global KKH	 		"G:\Projekte\Projekte_ab2016\EcUFam\Daten\Krankenhaus-Diagnose-Daten\strukturfiles\" 
	global anspielen	"G:\Projekte\Projekte_ab2016\EcUFam\Daten\Krankenhaus-Diagnose-Daten\strukturfiles\temp"
	global temp 		"$path\D_Ergebnisse\temp" 
	global logfiles		"$path\D_Ergebnisse\LOGFILES"
	global dofiles		"$path"
	global file 		"dstf_sa95"
	global AMR			"G:\Projekte\Projekte_ab2016\EcUFam\Daten\Arbeitsmarktregionen"
	*global regionalst 	"G:\Projekte\Projekte_ab2016\EcUFam\Daten\Regionaldatenbank\Data\Final\output"
	*global kreisreform 	"G:\Projekte\Projekte_ab2016\EcUFam\Daten\Gebietsreformen\finaldata\"
	*global population 	"G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis/source/population"
*/		

* magic numbers
	global first_year = 1995
	global last_year  = 2014	
	
* log file	
	global date1 = substr("$S_DATE",1,2)	// Day
	global date2 = substr("$S_DATE",4,3)	// Month
	global date3 = substr("$S_DATE",10,2)	// Year
	global date = "$date1"  + "$date2" + "$date3" 
	capture log close
	log using "$logfiles\KKH_prepare_${date}_MarcFabel" , text replace
	
* directory
	cd "$dofiles"
********************************************************************************


* 1) prepare raw format of hospital registry data (repeated cross section of individual level data)
	do  mlch_KKHGWAP_prepare_raw 
	disp "check: mlch_KKHGWAP_prepare_raw "

* 2) prepare dataset on different regional levels ( aggreagate and generate analysis relevant variables) 
	do mlch_KKHGWAP_prepare_agslevel
	do mlch_KKHGWAP_prepare_amrlevel
	do mlch_KKHGWAP_prepare_gdrlevel
	disp "check: mlch_KKHGWAP_prepare_REGIONALLEVELS"
	
* 3) analysis - tables
	do mlch_KKHGWAP_analysis_gdrlevel_tables
	do mlch_KKHGWAP_analysis_amrlevel_tables
		disp "check: mlch_KKHGWAP_analysis_tables"

	
	log close
	
