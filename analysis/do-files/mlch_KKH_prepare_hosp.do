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
* Updates:
*
*******************************************************************************/


// ***************************** PREAMBLE********************************
	clear all
	set more off
	
	global path  "F:\econ\m-l-c-h\analysis"		//MAC at work
	global temp  "$path/temp"
	global KKH   "$path/source/KKH_FDZ" 

// ***********************************************************************
	
	
////////////////////////////////////////////////////////////////////////////////////////
//1. Krankenhausdaten vorbereiten, gemeinsames Datenset konstruieren
////////////////////////////////////////////////////////////////////////////////////////
*0 Metadaten aufmachen und Sachen dran mergen
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
	save "$temp/KKH_prepare", replace

*Output 1 
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
	order YOB MOB year GDR  *_f *_m
	save "$temp/KKH_prepare", replace
	
*Output 2
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
	order YOB MOB year GDR  *_f *_m
	save "$temp/KKH_prepare", replace
	
*Output 3 (NUR FRAUEN - WERDEN ALS TOTAL EINGETRAGEN: NACH GESCHLECHTER MACHT AUCH KEIN SINN)
	use "$KKH\3_OstWest_Frauen_ohneJunge.dta", clear
	
	merge 1:1 year YOB MOB GDR using "$temp/KKH_prepare"		// wieder 1080 mal nicht gemerged (R3)
	drop _merge
	order YOB MOB year GDR *_f *_m
	save "$temp/KKH_prepare", replace
	
*Output 4
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
	order YOB MOB year GDR  *_f *_m
	save "$temp/KKH_prepare", replace
	
	
	//////////////////////////////////
	*ab jetzt nicht mehr per gender
	//////////////////////////////////
	
*Output 5
	use "$KKH\5_OstWest_alleKohorten", clear
	
	drop SummeVerweildauer	//ist bereits oben schon generiert worden
		
	merge 1:1 year YOB MOB GDR using "$temp/KKH_prepare"		//perfect match
	
	drop _merge
	order YOB MOB year GDR  *_f *_m
	save "$temp/KKH_prepare", replace
	
*Output 6
	use "$KKH\6_OstWest_ohneJunge", clear
	
	merge 1:1 year YOB MOB GDR using "$temp/KKH_prepare"		//perfect match
	drop _merge
	order YOB MOB year GDR  *_f *_m
	save "$temp/KKH_prepare", replace
	
*Output 7
	use "$KKH\7_OstWest_alten", clear
	
	merge 1:1 year YOB MOB GDR using "$temp/KKH_prepare"		//1944 mal nicht gemerged (R2 & R3)
	drop _merge
	order YOB MOB year GDR  *_f *_m
	save "$temp/KKH_prepare", replace
	
	qui gen reform=.
	qui replace reform = 1 if (YOB >= 1976 & YOB <= 1980)
	qui replace reform = 2 if (YOB >= 1985 & YOB <= 1989)
	qui replace reform = 3 if (YOB >= 1990 & YOB <= 1995)
	
	
////////////////////////////////////////////////////////////////////////////////////////
//2. Mit den Geburtszahlen verbinden
////////////////////////////////////////////////////////////////////////////////////////
	
	merge 1:1 year YOB MOB GDR using "$temp\bevoelkerung_final.dta"		// no perfect match: 648 cases (Mikrozensus war nicht sauber vorbereitet - Daten nicht benoetigt)
	keep if _merge ==3 
	drop _merge

	
	
////////////////////////////////////////////////////////////////////////////////////////
//3. Generate ratios
////////////////////////////////////////////////////////////////////////////////////////	

**********************
*a)totals
**********************
	#delimit;
	global total 
	Diag_steine
	Diag_boesartg_neubild
	Diag_sonst_herzkrank
	Diag_gutartg_krebs
	Diag_depression
	Diag_persoenlichk_stoerung
	Diag_venen_lymph
	Diag_kreislauf_atmung
	Diag_magen_krank
	Diag_verdauung	
	Diag_nierenkrank
	Diag_galle_pankreas
	Diag_14
	Diag_genital_w
	Diag_krank_schwanger
	Diag_betreuung_problem
	Diag_komplikation_wehen
	Diag_2
	Diag_7
	Diag_11
	Diag_neurot_stoerung
	Diag_gelenkerkrankung
	Diag_1
	Diag_5
	Diag_6
	Diag_8
	Diag_9
	Diag_10
	Diag_12
	Diag_13
	Diag_17
	Diag_18
	Diag_verletzung
	SummeVerweildauer
	hospital;
	#delimit cr
	*rausgenommen, da averages: Share_OP, DurschnVerweildauer
	
	
	foreach var of varlist $total {
		generate `var'_r = `var' / bev
	}
		

**********************
*b) female
**********************	
	#delimit;
	global female
	Diag_nierenkrank
	Diag_galle_pankreas
	Diag_2
	Diag_7
	Diag_11
	Diag_neurot_stoerung
	Diag_gelenkerkrankung
	Diag_1
	Diag_5
	Diag_6
	Diag_8
	Diag_9
	Diag_10
	Diag_12
	Diag_13
	Diag_17
	Diag_18
	Diag_verletzung
	SummeVerweildauer
	hospital;
	#delimit cr
	*rausgenommen: Share_OP_f DurschnVerweildauer_f

	foreach var of varlist $female {
		generate `var'_rf = `var'_f / bevf
	}
	
	
**********************
*c) male
**********************	
	
	#delimit;
	global male
	Diag_nierenkrank
	Diag_galle_pankreas
	Diag_2
	Diag_7
	Diag_11
	Diag_neurot_stoerung
	Diag_gelenkerkrankung
	Diag_1
	Diag_5
	Diag_6
	Diag_8
	Diag_9
	Diag_10
	Diag_12
	Diag_13
	Diag_17
	Diag_18
	Diag_verletzung
	SummeVerweildauer
	hospital;
	#delimit cr
	*rausgenommen: Share_OP_m DurschnVerweildauer_m
	
	foreach var of varlist $male {
		generate `var'_rm = `var' / bevm
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
	
	
	save "$temp\KK_final_all", replace
	*in Reformen abspeichern
preserve
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
	
		save "$temp\KKH_final_R1", replace
		saveold "$temp\KKH_final_R1", replace v(12)
		
restore
	
	clear all
	
	
	
