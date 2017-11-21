/*******************************************************************************
* File name: 	mlch_KKH_prepare_hosp
* Author: 		Marc Fabel
* Date: 		26.09.2017
* Description:	Analyse der KKH Diagnosedaten:
*				1) Zusammenspielen der einzelnen Datensätze von der KKH Diagnosestatistik
*				2) Mit der Bevölkerung  pro MOB (generiert in Do-File: prepare_regionalst_MY.do)
*				3) notwendige Variablen generieren
*
* Inputs:  		$KKH\0_OstWest_gender_meta  ...  $KKH\7_OstWest_alten
*				$temp\bevoelkerung_final.dta
* Outputs:		$temp\KKH_final_R1
*
* Updates:		21.11.2017: Verbesserungen aus dem long-format übernommen
*
*******************************************************************************/


// ***************************** PREAMBLE********************************
	clear all
	set more off
	
	global path  "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis"		//MAC at work
	global temp  "$path/temp"
	global KKH   "$path/source/KKH_FDZ" 

// ***********************************************************************
	
	
////////////////////////////////////////////////////////////////////////////////////////
//1. Krankenhausdaten vorbereiten, gemeinsames Datenset konstruieren
////////////////////////////////////////////////////////////////////////////////////////
*0 Metadaten aufmachen und Sachen dran mergen***********************************
	use "$KKH\0_OstWest_gender_meta.dta", clear
	qui gen j = "_f" if female == 1
	qui replace j = "_m" if female == 0
	drop female
*reshape 
	reshape wide SummeV	Share Durschn hospital , i(YOB MOB year GDR) j(j) string
	sort GDR year YOB MOB
	
*totals bauen
	foreach var in SummeVerweildauer hospital {
		qui egen `var' = rowtotal(`var'_m `var'_f)
	}
	
	order YOB MOB year GDR  *_f *_m
	
* rename Variables
	rename SummeVerweildauer_f   summ_stay_f
	rename SummeVerweildauer_m   summ_stay_m
	rename SummeVerweildauer	 summ_stay
	rename Share_OP_f 			 share_surgery_f
	rename Share_OP_m			 share_surgery_m
	rename DurschnVerweildauer_f length_of_stay_f
	rename DurschnVerweildauer_m length_of_stay_m
	//all right: hospital_f hospital_m  hospital
	save "$temp/KKH_prepare", replace
********************************************************************************
*OUTPUT 1 
	use "$KKH/1_OstWest_gender_alleKohorten.dta", clear
	qui gen j = "_f" if female == 1
	qui replace j = "_m" if female == 0
	drop female
	reshape wide Diag_1 - Diag_verletzung , i(YOB MOB year GDR) j(j) string
	sort GDR year YOB MOB
	foreach var in Diag_1 Diag_5 Diag_6 Diag_8 Diag_9 Diag_10 Diag_12 Diag_13 Diag_17 Diag_18 Diag_verletzung {
		qui egen `var' = rowtotal(`var'_m `var'_f)
	}
	
*merge
	merge 1:1 year YOB MOB GDR using "$temp/KKH_prepare"		// alle gemerged
	drop _merge
	
*rename variables
	rename Diag_1				d1
	rename Diag_1_f				d1_f
	rename Diag_1_m				d1_m
	rename Diag_5				d5
	rename Diag_5_f				d5_f
	rename Diag_5_m				d5_m
	rename Diag_6				d6
	rename Diag_6_f				d6_f
	rename Diag_6_m				d6_m
	rename Diag_8 				d8 
	rename Diag_8_f 			d8_f 
	rename Diag_8_m 			d8_m 
	rename Diag_9 				d9 		
	rename Diag_9_f 			d9_f 			
	rename Diag_9_m 			d9_m 		
	rename Diag_10 				d10
	rename Diag_10_f 			d10_f
	rename Diag_10_m 			d10_m
	rename Diag_12 				d12
	rename Diag_12_f 			d12_f
	rename Diag_12_m 			d12_m
	rename Diag_13  			d13
	rename Diag_13_f 			d13_f
	rename Diag_13_m 			d13_m	
	rename Diag_17 				d17
	rename Diag_17_f 			d17_f
	rename Diag_17_m 			d17_m
	rename Diag_18 				d18
	rename Diag_18_f 			d18_f
	rename Diag_18_m 			d18_m		
	rename Diag_verletzung		injuries
	rename Diag_verletzung_f 	injuries_f
	rename Diag_verletzung_m 	injuries_m
*order & save	
	order YOB MOB year GDR  
	save "$temp/KKH_prepare", replace
********************************************************************************=
*OUTPUT 2*
	use "$KKH/2_OstWest_gender_ohneJunge_ohne_Diag_andere_Wirkstoff.dta", clear
	qui gen j = "_f" if female == 1
	qui replace j = "_m" if female == 0
	drop female
	reshape wide Diag_2 - Diag_gelenkerkrankung , i(YOB MOB year GDR) j(j) string
	foreach var in Diag_2 Diag_7 Diag_11  Diag_neurot_stoerung Diag_gelenkerkrankung {
		qui egen `var' = rowtotal(`var'_m `var'_f)
	}
	merge 1:1 year YOB MOB GDR using "$temp/KKH_prepare"			// erstes mal kein perfektes merge, da R3 fehlt (1080 Fälle)
	drop _merge
*rename variables
	rename Diag_2 	 				d2
	rename Diag_2_f 				d2_f
	rename Diag_2_m 				d2_m
	rename Diag_7 					d7	
	rename Diag_7_f 				d7_f
	rename Diag_7_m 				d7_m
	rename Diag_11  				d11
	rename Diag_11_f 				d11_f
	rename Diag_11_m 				d11_m
	rename Diag_neurot_stoerung 	neurosis
	rename Diag_neurot_stoerung_f 	neurosis_f
	rename Diag_neurot_stoerung_m 	neurosis_m
	rename Diag_gelenkerkrankung 	joints
	rename Diag_gelenkerkrankung_f 	joints_f
	rename Diag_gelenkerkrankung_m 	joints_m
*order & save		
	order YOB MOB year GDR 
	save "$temp/KKH_prepare", replace
********************************************************************************	
*OUTPUT 3 (NUR FRAUEN - WERDEN ALS TOTAL EINGETRAGEN: NACH GESCHLECHTER MACHT AUCH KEIN SINN)
	use "$KKH\3_OstWest_Frauen_ohneJunge.dta", clear
	
	merge 1:1 year YOB MOB GDR using "$temp/KKH_prepare"		// wieder 1080 mal nicht gemerged (R3)
	drop _merge
	
*rename variables
	rename Diag_14				d14
	rename Diag_genital_w       female_genital_tract
	rename Diag_krank_schwanger pregnancy
	qui egen delivery = rowtotal(Diag_betreuung_problem Diag_komplikation_wehen)
	drop Diag_betreuung_problem Diag_komplikation_wehen
	label var delivery "Obstructed labor & problems during delivery"
*order & save
	order YOB MOB year GDR 
	save "$temp/KKH_prepare", replace
********************************************************************************
*OUTPUT 4
	use "$KKH\4_OstWest_gender_alten.dta", clear
	qui gen j = "_f" if female == 1
	qui replace j = "_m" if female == 0
	drop female
	reshape wide Diag_nierenkrank Diag_galle_pankreas , i(YOB MOB year GDR) j(j) string
	foreach var in Diag_nierenkrank Diag_galle_pankreas {
		qui egen `var' = rowtotal(`var'_m `var'_f)
	}
	merge 1:1 year YOB MOB GDR using "$temp/KKH_prepare"			// 1944 mal nicht gemerged (R2 & R3)
	drop _merge
*rename variables
	rename Diag_nierenkrank 	 kidneys
	rename Diag_nierenkrank_f	 kidneys_f
	rename Diag_nierenkrank_m	 kidneys_m
	rename Diag_galle_pankreas	 bile_pancreas
	rename Diag_galle_pankreas_f bile_pancreas_f
	rename Diag_galle_pankreas_m bile_pancreas_m
*order & save	
	order YOB MOB year GDR  
	save "$temp/KKH_prepare", replace
********************************************************************************	
	//////////////////////////////////
	*ab jetzt nicht mehr per gender
	//////////////////////////////////
*OUTPUT 5
	use "$KKH\5_OstWest_alleKohorten", clear
	drop SummeVerweildauer	//ist bereits oben schon generiert worden		
	merge 1:1 year YOB MOB GDR using "$temp/KKH_prepare"		//perfect match
	drop _merge
*rename variables	
	rename Share_OP				share_surgery
	rename DurschnVerweildauer	length_of_stay
	rename Diag_magen_krank 	stomach
	rename Diag_verdauung		symp_dig_system	
*order & save	
	order YOB MOB year GDR 
	save "$temp/KKH_prepare", replace
********************************************************************************	
*OUTPUT 6
	use "$KKH\6_OstWest_ohneJunge", clear
	
	merge 1:1 year YOB MOB GDR using "$temp/KKH_prepare"		//perfect match
	drop _merge
*rename variables
	rename Diag_boesartg_neubild 		mal_neoplasm
	rename Diag_sonst_herzkrank  		heart
	rename Diag_gutartg_krebs 	 		ben_neoplasm
	rename Diag_depression 		 		depression
	rename Diag_persoenlichk_stoerung 	personality
	rename Diag_venen_lymph 	 		lymphoma
	rename Diag_kreislauf_atmung 		symp_resp_system
	
	order YOB MOB year GDR 
	save "$temp/KKH_prepare", replace
********************************************************************************	
*OUTPUT 7
	use "$KKH\7_OstWest_alten", clear
	
	merge 1:1 year YOB MOB GDR using "$temp/KKH_prepare"		//1944 mal nicht gemerged (R2 & R3)
	drop _merge
*rename 
	rename Diag_steine calculi
	
	order YOB MOB year GDR  
	save "$temp/KKH_prepare", replace
	
	qui gen reform=.
	qui replace reform = 1 if (YOB >= 1976 & YOB <= 1980)
	qui replace reform = 2 if (YOB >= 1985 & YOB <= 1989)
	qui replace reform = 3 if (YOB >= 1990 & YOB <= 1995)
********************************************************************************
	
	
////////////////////////////////////////////////////////////////////////////////////////
//2. Mit den Geburtszahlen verbinden & order erstellen
////////////////////////////////////////////////////////////////////////////////////////
	
	merge 1:1 year YOB MOB GDR using "$temp\bevoelkerung_final.dta"		// no perfect match: 648 cases (Mikrozensus war nicht sauber vorbereitet - Daten nicht benoetigt)
	keep if _merge ==3 
	drop _merge
********************************************************************************
//erst totals und dann irgendwie: f und male
#delimit;
order YOB MOB year GDR reform fert bev length_of_stay summ_stay share_surgery  	/*meta*/
	hospital d1 d2 d5 d6 d7 d8 d9 d10 d11 d12 d13  d17 d18						/*Hauptdiagnosekapitel*/
	injuries neurosis joints kidneys bile_pancreas 								/*einzel - per gender*/
	
	d14 female_genital_tract pregnancy delivery 								/* nur frauen */
	
	stomach symp_dig_system	mal_neoplasm ben_neoplasm heart depression 			/* einzel -nur total*/
	personality lymphoma symp_resp_system calculi
	
	*_f *_m
;
#delimit cr 	
	
////////////////////////////////////////////////////////////////////////////////////////
//3. Generate ratios
////////////////////////////////////////////////////////////////////////////////////////	

**********************
*a)totals
**********************
	#delimit;
	global total 
	hospital summ_stay
	d1 d2 d5 d6 d7 d8 d9 d10 d11 d12 d13  d17 d18
	injuries neurosis joints kidneys bile_pancreas
	d14 female_genital_tract pregnancy delivery 
	stomach symp_dig_system	mal_neoplasm ben_neoplasm heart depression personality
	lymphoma symp_resp_system calculi	
	;
	#delimit cr
	*rausgenommen, da averages: Share_OP, DurschnVerweildauer
	
	
	foreach var of varlist $total {
		generate r_pop_`var' = `var'*1000 / bev
		label var r_pop_`var' "Ratio: approx. (MZ + Regionalstatistik); per thousand"
		generate r_fert_`var' = `var'*1000 / fert
		label var r_fert_`var' "Ratio using number of births (destatis); per thousand"
	}
		

**********************
*b) female
**********************	
	#delimit;
	global female
	hospital summ_stay
	d1 d2 d5 d6 d7 d8 d9 d10 d11 d12 d13  d17 d18
	injuries neurosis joints kidneys bile_pancreas
	;
	#delimit cr
	*rausgenommen: Share_OP_f DurschnVerweildauer_f

	foreach var of varlist $female {
		generate r_pop_`var'_f = `var'_f*1000 / bevf
		label var r_pop_`var'_f "Ratio: approx. (MZ + Regionalstatistik); per thousand"
		generate r_fert_`var'_f = `var'*1000 / fertf
		label var r_fert_`var'_f "Ratio using number of births (destatis); per thousand"
	}
	
	
**********************
*c) male
**********************	
	
	#delimit;
	global male
	hospital summ_stay
	d1 d2 d5 d6 d7 d8 d9 d10 d11 d12 d13  d17 d18
	injuries neurosis joints kidneys bile_pancreas
	;
	#delimit cr
	*rausgenommen: Share_OP_m DurschnVerweildauer_m
	
	foreach var of varlist $male {
		generate r_pop_`var'_m = `var'*1000 / bevm
		label var r_pop_`var'_m "Ratio: approx. (MZ + Regionalstatistik); per thousand"
		generate r_fert_`var'_m = `var'*1000 / fertm
		label var r_fert_`var'_m "Ratio using number of births (destatis); per thousand"
	}
	
////////////////////////////////////////////////////////////////////////////////////////
//4. Notwendige Variablen generieren
////////////////////////////////////////////////////////////////////////////////////////	

**********************************************
	*** AGE VARIABLES ***
***********************************************	
	// birth variable as monthly and daily (auxiliary variable for RD plots)
	qui tostring YOB, gen(temp1)
	qui tostring MOB, gen(temp2)
	qui gen temp3 = temp1+"m"+temp2
	qui gen Datum = monthly(temp3, "YM")
	format Datum %tm	
	qui gen temp4 = "15"
	qui gen temp5 = temp2+"/"+temp4+"/"+temp1
	qui gen Datum2 = daily(temp5, "MDY")
	format Datum2 %td
	qui drop temp*
	
	//define quarterly age at time of interview: 
	*set-up quarter-of-birth
	qui gen QOB =.
	qui replace QOB = 1 if (MOB==1|MOB==2|MOB==3)
	qui replace QOB = 2 if (MOB==4|MOB==5|MOB==6)
	qui replace QOB = 3 if (MOB==7|MOB==8|MOB==9)
	qui replace QOB = 4 if (MOB==10|MOB==11|MOB==12)
	
	//age - nicht perfekt, kann mit DVF besser gemacht werden!!!!!!!!!!!!!!!!
	qui gen age = year - YOB
	qui gen agesq = age*age

	//FRG
	qui gen FRG = cond(GDR==0,1,0)
	
	// alternative MOB (depict TG & CG in same graph)
	qui gen     MOB_altern = 1  if MOB == 11
	qui replace MOB_altern = 2  if MOB == 12
	qui replace MOB_altern = 3  if MOB == 1
	qui replace MOB_altern = 4  if MOB == 2
	qui replace MOB_altern = 5  if MOB == 3
	qui replace MOB_altern = 6  if MOB == 4
	qui replace MOB_altern = 7  if MOB == 5
	qui replace MOB_altern = 8  if MOB == 6
	qui replace MOB_altern = 9  if MOB == 7
	qui replace MOB_altern = 10 if MOB == 8
	qui replace MOB_altern = 11 if MOB == 9
	qui replace MOB_altern = 12 if MOB == 10
	label define MOB_ALTERN 1 "11" 2 "12" 3 "01" 4 "02" 5 "03" 6 "04" 7 "05" 8 "06" ///
		9 "07" 10 "08" 11 "09" 12 "10"  
	label values MOB_altern MOB_ALTERN
	label var MOB_altern "Um TG & CG im selben graph darstellen zu können"
	
	// MOB für Moving average graphen 
	qui gen MOB_ma = MOB_al	
	#delimit ;
	label define MOB_MA 
		3 "11/12/01"
		4 "12/01/02"
		5 "01/02/03"
		6 "02/03/04"
		7 "05/06/07"
		8 "06/07/08"
		9 "07/08/09"
		10 "08/09/10";
	#delimit cr
	label val MOB_ma MOB_MA
	
	
	save "$temp\KK_final_allreforms_inclGDR", replace
	
	
////////////////////////////////////////////////////////////////////////////////////////
//5. IN REFORMEN ABSPEICHERN
////////////////////////////////////////////////////////////////////////////////////////	
keep if reform == 1

	//generate dummy variables for the regression:
	qui gen threshold = monthly("1979m5", "YM")
	format threshold %tm
	local threshm 5
	local binw 6
	qui gen treat = cond((Datum>threshold-`binw'-1 & Datum<threshold + `binw' ),1,0)	//Nov78-Oct79
	qui gen after = cond((MOB>= `threshm' & MOB< `threshm'+`binw' ),1,0)		// Months after reform
	qui gen TxA = treat*after
	//construct interaction terms for DDD analysis
	qui gen FxT= FRG*treat
	qui gen FxTxA = FRG*treat*after
	qui gen FxA= FRG*after
	
	// Month dummies: 
	forvalues x =  1/12 {
		if `x'!= `threshm' & `x'!= `threshm'-1 {
				qui gen Dmonth`x' = cond(MOB==`x',1,0) 
		}
	}
	 
	
	//generate cluster variable (for each month of each birth cohort, #clusters= #CGs+TG)*12 )
	qui gen MxY = YOB * MOB
		
	
	// Control variables
	qui gen control1 = cond((Datum>threshold-`binw'-1-24 & Datum<threshold + `binw' -24),1,0)
	qui gen control2 = cond((Datum>threshold-`binw'-1-12 & Datum<threshold + `binw' -12),1,0)
	qui gen control3 = cond((Datum>threshold-`binw'-1+12 & Datum<threshold + `binw' +12),1,0)

	qui gen control =.
	qui replace control = 1 if control1 == 1 
	qui replace control = 2 if control2 == 1
	qui replace control = 3 if control3 == 1
	qui replace control	= 4 if treat == 1
	
	label define CNTRL 1 "[1] Control1" 2 "[2] Control2" 3 "[3] Control3" 4 "[4] Treatment" 
	label val control CNTRL
	
	keep if control !=.
	
	
	********************************************************************************
		*****  General command for RD graphs (MIX WITH NUMX & DATUM)  *****
	********************************************************************************
	// Numerical running variable
	qui gen NumX = -6    if MOB== 11
	qui replace NumX =-5 if MOB== 12
	qui replace NumX =-4 if MOB== 1
	qui replace NumX =-3 if MOB== 2
	qui replace NumX =-2 if MOB== 3
	qui replace NumX =-1 if MOB== 4
	qui replace NumX = 1 if MOB== 5
	qui replace NumX = 2 if MOB== 6
	qui replace NumX = 3 if MOB== 7
	qui replace NumX = 4 if MOB== 8
	qui replace NumX = 5 if MOB== 9
	qui replace NumX = 6 if MOB== 10


	qui gen NumX2 = NumX^2
	qui gen NumX3 = NumX^3
	qui gen NumX4 = NumX^4
	qui gen NumX5 = NumX^5
	qui gen NumX6 = NumX^6
	qui gen Num_after = NumX * after
	qui gen Num2_after = NumX2 * after
	qui gen Num3_after = NumX3 * after
	qui gen Num4_after = NumX4 * after
	qui gen Num5_after = NumX5 * after
	qui gen Num6_after = NumX6 * after	
	
	sort Datum GDR year
	*order year Datum QOB FRG GDR treat after TxA FxT FxTxA FxA  MxY control reform Dmon*
	
	
	drop if GDR == 1
	
		save "$temp\KKH_final_R1", replace
		saveold "$temp\KKH_final_R1_V12", replace v(12)
		

	
	
	
