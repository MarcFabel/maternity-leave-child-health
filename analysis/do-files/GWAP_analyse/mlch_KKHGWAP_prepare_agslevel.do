/*******************************************************************************
* File name: 	mlch_KKHGWAP_prepare
* Author: 		Marc Fabel
* Date: 		28.02.2018
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

 use "$temp/KKH_ags_level_raw", clear

 ***** Bevölkerung auf MOB runterrechenn
	//mit MZ Gewichte
	*qui gen bev_mz = round(ratio_GDR * ypop_)
	*qui gen bev_mzf = round(ratio_GDR_female * ypop_f)
	*qui gen bev_mzm = round(ratio_GDR_male * ypop_m)
	//mit Geburtengewichte
	qui gen bev_fert = round(ratio_pop * _001_ypop_)
	qui gen bev_fertf = round(ratio_popf * _001_ypop_f)
	qui gen bev_fertm = round(ratio_popm * _001_ypop_m)
	qui drop  _001_ypop* ratio* //ratio*
	
***** Hospitalization w/o d14 (Pregnancy, childbirth and the puerperium)
	qui gen hospital2 = hospital - d14
	qui gen hospital2_m = hospital_m
	qui gen hospital2_f = hospital_f - d14
	
********************************************************************************
// RATIOS	

*totals
#delim ;
local totals 
	d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d17 d18 
	metabolic_syndrome respiratory_index drug_abuse
	
	diabetis hypertension ischemic adipositas
	lung_infect lung_chron pneumonia asthma 
	shizophrenia affective neurosis personality
	intestine_infec leukemia  
	childhood ear otitis_media 
	symp_circ_resp symp_digest heart 
	death hospital patients Summ_stay Sum_surgery;
#delim cr
// averages :Share_surgery/Length_of_stay

foreach var of varlist `totals' {
	qui gen r_popf_`var'   = `var'   *1000/bev_fert
	qui gen r_popf_`var'_f = `var'_f *1000/bev_fertf
	qui gen r_popf_`var'_m = `var'_m *1000/bev_fertm
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
	order ags_clean bula GDR Datum YOB MOB year
	
	//Für lifecourse spezifikation : harmonise age across different cohorts
	// Variablen, die noch ins prepare do-file ausgelagert werden müssen
	*generate age_treat: age of the respective treatment cohort -> harmonisieren des Alters
	qui gen year_treat = .
	qui replace year_treat = year if treat == 1 
	qui replace year_treat = year + 2 if control == 1
	qui replace year_treat = year + 1 if control == 2
	qui replace year_treat = year - 1 if control == 3
	*label
	#delim ;
	label define YEAR_TREAT 
		1995 "1995 [16]"
		1996 "1996 [17]"
		1997 "1997 [18]"
		1998 "1998 [19]"
		1999 "1999 [20]"
		2000 "2000 [21]"
		2001 "2001 [22]"
		2002 "2002 [23]"
		2003 "2003 [24]"
		2004 "2004 [25]"
		2005 "2005 [26]"
		2006 "2006 [27]"
		2007 "2007 [28]"
		2008 "2008 [29]"
		2009 "2009 [30]"
		2010 "2010 [31]"
		2011 "2011 [32]"
		2012 "2012 [33]"
		2013 "2013 [34]"
		2014 "2014 [35]";
	#delim cr
	label values year_treat YEAR_TREAT
	/*idea:  age(CG1_{t-2})=age(CG2_{t-1})=age(TG_{t})=age(CG_{t+1})
	Die Variable enthält das Jahr in dem die treatment Kohorte so alt ist wie die
	Control kohorte zu dem year x.
	*/ 
	
	order ags_clean bula GDR Datum YOB MOB year *_f

********************************************************************************	

// Saving
	
	qui save "$temp/KKH_final_agslevel_extended", replace
	keep if control !=.		// wirklich nur control groups 123 & TG
	qui save "$temp/KKH_final_ags_level", replace
	
	
	
