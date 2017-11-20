/*******************************************************************************
* File name: 	mlch_KKH_prepare_pergender_hosp
* Author: 		Marc Fabel
* Date: 		26.09.2017
* Description:	Analyse der KKH Diagnosedaten:
*				1) Zusammenspielen der einzelnen Datensätze von der KKH Diagnosestatistik
*				2) Mit der Bevölkerung  pro MOB (generiert in Do-File: prepare_regionalst_MY.do)
*				3) notwendige Variablen generieren
*				4) in einzelne Reformen abspeichern
*
* Inputs:  		$KKH\0_OstWest_gender_meta  ...  $KKH\7_OstWest_alten
*				$temp\bevoelkerung_final.dta
* Outputs:		$temp\KK_final_allreforms_incl_GDR
*				$temp\KKH_final_R1_long_incl_GDR
*				$temp\KKH_final_R1_long
*
* Updates:
*
*******************************************************************************/


// ***************************** PREAMBLE********************************
	clear all
	set more off
	
	global path  "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis"		//MAC at work
	global temp  "$path/temp"
	global KKH   "$path/source/KKH_FDZ" 

// ***********************************************************************
	
	// in Frauendatensatz ein female dummy einfügen, dass auf diesen gemerged werden kann
	use "$KKH/3_OstWest_Frauen_ohneJunge.dta", clear
	qui gen female = 1
	save "$KKH/3-2_OstWest_Frauen_ohneJunge.dta", replace
	
	
////////////////////////////////////////////////////////////////////////////////////////
//1. Krankenhausdaten vorbereiten, gemeinsames Datenset konstruieren
////////////////////////////////////////////////////////////////////////////////////////
*0 Metadaten aufmachen und Sachen dran mergen
	use "$KKH\0_OstWest_gender_meta.dta", clear
	merge 1:1 year YOB MOB GDR female using "$KKH/1_OstWest_gender_alleKohorten.dta", nogen
	merge 1:1 year YOB MOB GDR female using "$KKH/2_OstWest_gender_ohneJunge_ohne_Diag_andere_Wirkstoff.dta", nogen
	merge 1:1 year YOB MOB GDR female using "$KKH/3-2_OstWest_Frauen_ohneJunge.dta", nogen
	merge 1:1 year YOB MOB GDR female using "$KKH/4_OstWest_gender_alten.dta", nogen
	
	qui gen reform=.
	qui replace reform = 1 if (YOB >= 1976 & YOB <= 1980)
	qui replace reform = 2 if (YOB >= 1985 & YOB <= 1989)
	qui replace reform = 3 if (YOB >= 1990 & YOB <= 1995)
	
	
////////////////////////////////////////////////////////////////////////////////////////
//2. Mit den Bevölkerungszahlen verbinden
////////////////////////////////////////////////////////////////////////////////////////
	
	merge 1:1 year YOB MOB GDR female using "$temp/bevoelkerung_final_long.dta"		
	/* no perfect match: 1296 cases (_merge==2) (Mikrozensus war nicht sauber vorbereitet - Daten nicht benoetigt)
	*/
	keep if _merge ==3 
	drop _merge

	
	
////////////////////////////////////////////////////////////////////////////////////////
//3. Generate ratios
////////////////////////////////////////////////////////////////////////////////////////	

// Rename & generate variables 
order YOB MOB year GDR female reform fert bev SummeVerweildauer Share_OP  ///
	DurschnVerweildauer hospital Diag_1 Diag_2 Diag_5 Diag_6 Diag_7 Diag_8 Diag_9 Diag_10 ///
	Diag_11 Diag_12 Diag_13 Diag_14 Diag_17 Diag_18 Diag_verletzung Diag_neurot_stoerung ///
	Diag_gelenkerkrankung Diag_nierenkrank Diag_galle_pankreas ///	
	 Diag_krank_schwanger Diag_genital_w ///
	Diag_betreuung_problem Diag_komplikation_wehen  

*Metadaten
rename DurschnVerweildauer Length_of_Stay
rename SummeVerweildauer SummStay
*Hauptdiagnosekapitel
rename Diag_1  D_1
rename Diag_2  D_2
rename Diag_5  D_5
rename Diag_6  D_6
rename Diag_7  D_7
rename Diag_8  D_8
rename Diag_9  D_9
rename Diag_10 D_10
rename Diag_11 D_11
rename Diag_12 D_12
rename Diag_13 D_13
rename Diag_14 D_14
rename Diag_17 D_17
rename Diag_18 D_18 

*Einzeldiagnosen
rename Diag_verletzung Injuries
rename Diag_neurot_stoerung Neurosis
rename Diag_gelenkerkrankung Joints
rename Diag_nierenkrank Kidneys
rename Diag_galle_pankreas Bile_pancreas

*Women only
rename Diag_krank_schwanger Pregnancy
rename Diag_genital_w Dis_fgenital_tract
qui egen Delivery = rowtotal(Diag_betreuung_problem Diag_komplikation_wehen)
qui replace Delivery = . if Diag_betreuung_problem ==. & Diag_komplikation_wehen == .
drop Diag_betreuung_problem Diag_komplikation_wehen
label var Delivery "Obstructed labor & problems during delivery"




**********************
*a)totals
**********************
	#delimit;
	global total
	SummStay
	hospital
	D_1
	D_2
	D_5
	D_6
	D_8
	D_9
	D_10
	D_11
	D_12
	D_13
	D_14
	D_17
	D_18
	Injuries
	Neurosis
	Joints
	Kidneys
	Bile_pancreas
	Pregnancy 
	Dis_fgenital_tract
	Delivery 		
	;
	#delimit cr
	*rausgenommen, da averages: Share_OP, Length_of_Stay
	
	
	foreach var of varlist $total {
		generate r_pop_`var' = `var'*1000 / bev
		label var r_pop_`var' "Ratio: approx. (MZ + Regionalstatistik); per thousand"
		generate r_fert_`var' = `var'*1000 / fert
		label var r_fert_`var' "Ratio using number of births (destatis); per thousand"
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
	replace MOB_ma = . if MOB_ma == 1 | MOB_ma == 2 | MOB_ma == 11 | MOB_ma == 12
	
	
	save "$temp\KK_final_allreforms_incl_GDR", replace
	
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

	
	save "$temp\KKH_final_R1_long_incl_GDR", replace
	drop if GDR == 1
	save "$temp\KKH_final_R1_long", replace
		*saveold "$temp\KKH_final_R1_V12", replace v(12)
		
	
	
	
	
