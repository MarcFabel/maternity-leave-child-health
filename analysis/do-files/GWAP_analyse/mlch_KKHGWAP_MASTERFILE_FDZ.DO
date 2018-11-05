/*******************************************************************************
* File name: 	MASTERFILE
* Author: 		Marc Fabel
* Date: 		14.06.2018
* Description:	Executes all relevants Do-Files
*


Titel des Projekts:				<Maternity leave and long-run child outcomes>
Datengrundlage:					<KKH Daignosestatistik 1995 - 2013>
Dateiname des Programcodes: 	<mlch_KKHGWAP_MASTERFILE >
von:							<Marc Fabel>
Telefon:						<089/92241368>
Email:							<fabel@ifo.de>

Dateinamen des Output-Files:	<KKH_prepare_DATUM_MarcFabel.log>

Grundriss des Programms: Das Programm greift auf 4 Do-Files zu
	< 
	1) PREPARE_RAW: 
	Zuallererst werden die Regionalstatistikdaten von dem Datensatz von Hrrn.
	Janisch losgelöst und in die Form gebracht, mit der ich weiterarbeiten kann. 
	Ich beschränke mich dabei auf ein kleineres Datenset wie zB DanzerHenerReich,
	da ich deutlich weniger Variablen benötige. 
	Ich nächsten Schritt werden die einzelnen Wellen der KKH Diagnose-Einzeldaten
	vorbereitet. Dies bedeuted es werden notwendige Variablen generiert und die Daten 
	auf das relevante sample beschränkt (Geburtskohorten 1975-1980).
	Anschließend werden die einzelnen Wellen zu einer repeated Cross-Section 
	zusammengesetzt, und  auf verschiedene regionen aggregiert, die die rohen 
	preparierten Datensätze darstellen.
	
	2) PREPARE_XXXLEVEL
	Anschließend werden diese Rohdatensätze auf dem jeweiligen Aggregationsniveau 
	weiterverarbeitet. Mich interessieren nicht so sehr die absoluten Anzahlen an
	bestimmten Diagnosen sondern vielmehr die Diagnosen im Verhältnis zur Bevölkerung.
	Daher teile ich die Diagnosen durch die Geburten/Personen im entsprechenden
	Alter. 
	
	3) mlch_KKHGWAP_Datenanfrage_Jun2018_Unterdiagnosen
	Es werden für zwei Geburtskohorten die Anzahl der Diagnosen pro Jahr ermittelt.
	
	Weitere Details sind in den einzelnen do-Files zu finden

		

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
						   <amr:			Arbeitsmarktregion
							bev_fert		approx bevoelkerung 
							control			definiert 3 verschiedene Control Kohorten (Geburtsjahrgaenge)
						    Datum: 			Geburtsdatum (im STATA time format, monthly)
							diagOvrvw		Kategorische Variable (orientiert sich an den 22 Diagnosekapiteln der ICD 10 Systematik)
							Diag_NUMMER		Dich. Variable: für jedes Diagnosekapitel der ICD 10 Systematik
							Diag_NAME		Dich. Variable: für bedeutende Einzeldiagnosen (orientiert isch an der europäischen Kurzliste)
							FRG:			Dich. Varable: alte Bundesländer (Negativ von GDR)
						    GDR:			Dich. Variable: alte/neue Bundesländer
							high_density	Dich. Variable: ist der AMR eher urban/laendlich geprägt (abhängig von der mediandichte)
							MOB:			Geburtsmonat
							NumX			Anzahl der Monate: wie weit entfernt bis zur Schwelle Mai
							NumX#			Polynom #-ten Grades von NumX
							Op:				entspricht EF10
							popweigths		Bevölkerungsgewichte
							r_fert_			Anzahl der Diagnose pro 1000 Geburten
							r_popf_			Anzahl der Diagnose pro 1000 Personen (approx): Diag*1000/bev_fert
							Verweildauer:	entspricht EF12, Unterschied, alle Werte >84 habe ich als missing deklariert (im Ursprungsdatensatz findet sich top-coding wieder)
							year: 			Survey Jahr, korrigiert durch die Jahresüberhänge
							year_treat		harmonisierts suveryjahr, beruecksichtigt dass zu einem bestimmten Zeitpunkt die verschiedenen Kohorten nihct gleich sind
							YOB: 			Geburtsjahr
							variable_m/f	Suffix bezieht sich auf eine Variable für nur 	Männer(_m)/	Frauen(_f)
							
							
						Variablen für die Regression:
							after			Dich. Variable: geboren (Mai-Okt)
							FxA				Interaktion FRG*after
							FxT				Interaktion FRG*treat
							FxTxA			Interkation FRG*treat*after
							MxY				Interaktion MOB*YOB (cluster variable)
							MxYxFRG			Interaktion MOB*YOB*FRG (cluster variable)
							treat			Dich. Variable: geboren (Nov78-Okt79)
							TxA				Interaktion treat*after
							
						Diagnosenüberischt: (NUR WAS ICH BEANTRAGE)
							d5					Psychische und Verhaltensstörungen
							respiratory_index 	Index für Krankheiten der unteren Atemwege
							metabolic_syndrome 	Index für Krankheiten, die das metabolische Syndrom (Stoffwechsel) betreffen
							hospital			Anzahl aller Krankenhausfälle
							drug_abuse			Missbrauch von Drogen	
							shizophrenia 		Shizophrenie
							affective 			Affektive Verhaltensstoerungen
							neurosis 			Neurosen
							personality 		persönlichkeitsstoerung
							childhood			Stoerung der Persoenlichkeit, dass seinen Ursprung in der Vergangenheit hat
							lung_infect			Akute Lungeninfektionen
							pneumonia 			Lungenentzuendung
							lung_chron 			chronische Erkrankungen der unteren Atemwege
							asthma				Asthma
							
							
							
							
							
							>

*******************************************************************************/



// ***************************** PREAMBLE********************************
	clear all
	set more off
	
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
	global MZ_anspielen	"$path/A_Mikrodaten"		// verweist auf die Datei MZ_merge (von Hrrn. Janisch erhalten) 
	global file			"kdfv_sa95"
	*global file 		"gwap_sa95_"


/*	
* Landesamt (Für mich)
	global path 		"Z:\ifo\GWA22_3053_MF_KH"
	*global KKH	 		"$path\A_Mikrodaten\"
	global temp 		"$path\D_Ergebnisse\temp\" 
	global tables   	"$path\D_Ergebnisse\TABLES"
	global graphs 		"$path\D_Ergebnisse\GRAPHS"
	global logfiles 	"$path\D_Ergebnisse\LOGFILES"
	global dofiles		"$path\C_Programm"
*/
	
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
	global tables   	"$path\D_Ergebnisse\TABLES"
	global graphs 		"$path\D_Ergebnisse\GRAPHS"
	global MZ_anspielen	"$path/A_Mikrodaten"
	*global regionalst 	"G:\Projekte\Projekte_ab2016\EcUFam\Daten\Regionaldatenbank\Data\Final\output"
	*global kreisreform 	"G:\Projekte\Projekte_ab2016\EcUFam\Daten\Gebietsreformen\finaldata\"
	*global population 	"G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis/source/population"
*/
	
* directory
	cd "$dofiles"	
	
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
	

********************************************************************************


* 1) prepare raw format of hospital registry data (repeated cross section of individual level data)
	do  mlch_KKHGWAP_prepare_raw 
	*disp "check: mlch_KKHGWAP_prepare_raw "

* 2) prepare dataset on different regional levels ( aggreagate and generate analysis relevant variables) 
	*do mlch_KKHGWAP_prepare_agslevel
	do mlch_KKHGWAP_prepare_amrlevel
	do mlch_KKHGWAP_prepare_gdrlevel
	*disp "check: mlch_KKHGWAP_prepare_REGIONALLEVELS"
	
* 3) Beantragen	
	do mlch_KKHGWAP_descriptives_gdrlevel_graphs_d5partition
	do mlch_KKHGWAP_analysis_gdr_lc_subcatgeories
	do mlch_KKHGWAP_descriptives_gdrlevel_graphs_deaths	
	*do mlch_KKHGWAP_RF_amr_MA_weighted
	
	
	
* 3) analysis - tables
	*do mlch_KKHGWAP_analysis_gdrlevel_tables
	*do mlch_KKHGWAP_analysis_amrlevel_tables
	*do mlch_KKHGWAP_analysis_amrlevel_tables_clusterbula
	*do mlch_KKHGWAP_analysis_amr_lc_subcatgeories_mz
	
		*disp "check: mlch_KKHGWAP_analysis_tables"
		
* 4) analysis -graphs
	*do mlch_KKHGWAP_analysis_gdrlevel_graphs
	*do mlch_KKHGWAP_analysis_amrlevel_graphs
		*disp "check: graphs"
		
	*Datenanfrage
	*do mlch_KKHGWAP_Datenanfrage_Jun2018
	*do mlch_KKHGWAP_Datenanfrage_Jun2018_Unterdiagnosen
	

	
	log close
	
