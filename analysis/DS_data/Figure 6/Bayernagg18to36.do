clear
clear matrix
set mem 500m
set more 1
cap log close

log using  ${o_dir}${S}BYaggregatedata18to36.log, replace

* *************************************************************

global S "\"

set mem 500m   /* if the data files are larger, this number has to be increased - problem if not enough RAM in Computer */
global d_dir"c:\pp\pr65tce\data" /* this sets the directory with the mz.dta files */
global d1_dir"c:\pp\pr65tce\data" /* this sets the directory with the mz.dta files */
global g_dir "c:\pp\pr65tce\gph"	/* this sets the ???? directory	*/
global o_dir "c:\pp\pr65tce\out"	/* this sets the output directory	-- this is where the logs are*/
global p_dir "c:\pp\pr65tce\prg"	/* this sets the output directory	-- this is where the logs are*/

* *************************************************************


**************************************
*Bayern
*******************************************


*****************************************************2004/2005
***************************************************************
clear
use ${d_dir}${S}FDZ_ALLG_SCHULE_B0405_ANONYM_END.dta


*rename birth year and birth month
rename GEBJAHR gebjahr
rename GEBMON gebmonat

*cohort indicators 
gen cohort=0
replace cohort=8990 if (gebjahr==1989&gebmonat>=7)|(gebjahr==1990&gebmonat<=6)

replace cohort=9091 if (gebjahr==1990&gebmonat>=7)|(gebjahr==1991&gebmonat<=6)

replace cohort=9192 if (gebjahr==1991&gebmonat>=7)|(gebjahr==1992&gebmonat<=6)

replace cohort=9293 if (gebjahr==1992&gebmonat>=7)|(gebjahr==1993&gebmonat<=6)

replace cohort=9394 if (gebjahr==1993&gebmonat>=7)|(gebjahr==1994&gebmonat<=6)

replace cohort=9495 if (gebjahr==1994&gebmonat>=7)|(gebjahr==1995&gebmonat<=6)

*keep relevant cohorts only
keep if cohort==8990|cohort==9091|cohort==9192|cohort==9293|cohort==9394|cohort==9495

rename SART sch_form
tab sch_form, miss

*school indicators
gen real=0
replace real=1 if sch_form==7
*(note: this includes Grundschule)
gen haupt=0
replace haupt=1 if sch_form==1
gen gym=0
replace gym=1 if sch_form==10
*(note: Orientierungsstufe)
gen foerder=0
replace foerder=1 if sch_form==20
gen gesamt=0
replace gesamt=1 if sch_form==19
gen sonder=0
replace sonder=1 if sch_form==4|sch_form==8
*note: Grundschule is in the same category as Volksschule
*note: other schools are Freie Waldorfschule
gen other=0 
replace other=1 if sch_form==22

gen BL=3 
gen year=2004

rename STAATSAN staat
tab staat, nol
keep if staat==1


rename SUEJGST stufe
destring stufe, replace force
tab stufe, miss

rename VORJJGST v_stufe 
destring v_stufe, replace force
tab v_stufe, miss

tab stufe v_stufe, miss
*note: previous grade missing for Abendgymnasium and Kolleg

gen repeat=0
replace repeat=1 if v_stufe==stufe


*drop pupils in strange grades (Note: this procedure also drops the
*very few pupils in grades VK and 1A 
drop if stufe==.
tab stufe if cohort==8990
drop if cohort==8990&(stufe<=5|stufe>=12)
tab stufe if cohort==9091
drop if cohort==9091&(stufe<=4|stufe>=11)
tab stufe if cohort==9192
drop if cohort==9192&(stufe<=3|stufe>=10)
tab stufe if cohort==9293
drop if cohort==9293&(stufe<=2|stufe>=9)
tab stufe if cohort==9394
drop if cohort==9394&(stufe<=1|stufe>=8)
tab stufe if cohort==9495
drop if cohort==9495&(stufe<=0|stufe>=7)


forvalues i=1/11{
gen stufe`i'=0
replace stufe`i'=1 if stufe==`i'
}


**1 if boy
gen sex=0
replace sex=1 if GESCHL==3

keep gebjahr gebmonat sex cohort real haupt gym foerder gesamt sonder other stufe1-stufe11 repeat BL year 
sort cohort gebmonat sex
collapse (sum) real haupt gym foerder gesamt sonder other stufe1 stufe2 stufe3 stufe4 stufe5 stufe6 stufe7 stufe8 stufe9 stufe10 stufe11 repeat (mean) BL year, by(cohort gebmonat sex)

**************test
gen all1=real+haupt+gym+foerder+gesamt+sonder+other
gen all2=stufe1+stufe2+stufe3+stufe4+stufe5+stufe6+stufe7+stufe8+stufe9+stufe10+stufe11
count
count if all1==all2

save ${d_dir}${S}Bayern04, replace


*****************************************************2005/2006
***************************************************************
clear
use ${d_dir}${S}FDZ_ALLG_SCHULE_B0506_ANONYM_END.dta


*rename birth year and birth month
rename GEBJAHR gebjahr
rename GEBMON gebmonat

*cohort indicators 
gen cohort=0
replace cohort=8990 if (gebjahr==1989&gebmonat>=7)|(gebjahr==1990&gebmonat<=6)

replace cohort=9091 if (gebjahr==1990&gebmonat>=7)|(gebjahr==1991&gebmonat<=6)

replace cohort=9192 if (gebjahr==1991&gebmonat>=7)|(gebjahr==1992&gebmonat<=6)

replace cohort=9293 if (gebjahr==1992&gebmonat>=7)|(gebjahr==1993&gebmonat<=6)

replace cohort=9394 if (gebjahr==1993&gebmonat>=7)|(gebjahr==1994&gebmonat<=6)

replace cohort=9495 if (gebjahr==1994&gebmonat>=7)|(gebjahr==1995&gebmonat<=6)

*keep relevant cohorts only
keep if cohort==8990|cohort==9091|cohort==9192|cohort==9293|cohort==9394|cohort==9495

rename SART sch_form
tab sch_form, miss

*school indicators
gen real=0
replace real=1 if sch_form==7
*(note: this includes Grundschule)
gen haupt=0
replace haupt=1 if sch_form==1
gen gym=0
replace gym=1 if sch_form==10|sch_form==16
*(note: Orientierungsstufe)
gen foerder=0
replace foerder=1 if sch_form==20
gen gesamt=0
replace gesamt=1 if sch_form==19
gen sonder=0
replace sonder=1 if sch_form==4|sch_form==8
*note: Grundschule is in the same category as Volksschule
*note: other schools are Freie Waldorfschule
gen other=0 
replace other=1 if sch_form==22

gen BL=3 
gen year=2005

rename STAATSAN staat
tab staat, nol
keep if staat==1


rename SUEJGST stufe
destring stufe, replace force
tab stufe, miss

rename VORJJGST v_stufe 
destring v_stufe, replace force
tab v_stufe, miss

tab stufe v_stufe, miss
*note: previous grade missing for Abendgymnasium and Kolleg

gen repeat=0
replace repeat=1 if v_stufe==stufe


*drop pupils in strange grades (Note: this procedure also drops the
*very few pupils in grades VK and 1A
drop if stufe==.
tab stufe if cohort==8990
drop if cohort==8990&(stufe<=6|stufe>=13)
tab stufe if cohort==9091
drop if cohort==9091&(stufe<=5|stufe>=12)
tab stufe if cohort==9192
drop if cohort==9192&(stufe<=4|stufe>=11)
tab stufe if cohort==9293
drop if cohort==9293&(stufe<=3|stufe>=10)
tab stufe if cohort==9394
drop if cohort==9394&(stufe<=2|stufe>=9)
tab stufe if cohort==9495
drop if cohort==9495&(stufe<=1|stufe>=8)


forvalues i=2/12{
gen stufe`i'=0
replace stufe`i'=1 if stufe==`i'
}


**1 if boy
gen sex=0
replace sex=1 if GESCHL==3

keep gebjahr gebmonat sex cohort real haupt gym foerder gesamt sonder other stufe2-stufe12 repeat BL year 
sort cohort gebmonat sex
collapse (sum) real haupt gym foerder gesamt sonder other stufe2 stufe3 stufe4 stufe5 stufe6 stufe7 stufe8 stufe9 stufe10 stufe11 stufe12 repeat (mean) BL year, by(cohort gebmonat sex)

**************test
gen all1=real+haupt+gym+foerder+gesamt+sonder+other
gen all2=stufe2+stufe3+stufe4+stufe5+stufe6+stufe7+stufe8+stufe9+stufe10+stufe11+stufe12
count
count if all1==all2

save ${d_dir}${S}Bayern05, replace


*****************************************************2006/2007
***************************************************************
clear
use ${d_dir}${S}FDZ_ALLG_SCHULE_B0607_ANONYM_END.dta


*rename birth year and birth month
rename gebjahr1 gebjahr
rename GEBMON gebmonat
destring gebmonat, replace

*cohort indicators 
gen cohort=0
replace cohort=8990 if (gebjahr==1989&gebmonat>=7)|(gebjahr==1990&gebmonat<=6)

replace cohort=9091 if (gebjahr==1990&gebmonat>=7)|(gebjahr==1991&gebmonat<=6)

replace cohort=9192 if (gebjahr==1991&gebmonat>=7)|(gebjahr==1992&gebmonat<=6)

replace cohort=9293 if (gebjahr==1992&gebmonat>=7)|(gebjahr==1993&gebmonat<=6)

replace cohort=9394 if (gebjahr==1993&gebmonat>=7)|(gebjahr==1994&gebmonat<=6)

replace cohort=9495 if (gebjahr==1994&gebmonat>=7)|(gebjahr==1995&gebmonat<=6)

*keep relevant cohorts only
keep if cohort==8990|cohort==9091|cohort==9192|cohort==9293|cohort==9394|cohort==9495

rename SART sch_form
tab sch_form, miss
destring sch_form, replace

*school indicators
gen real=0
replace real=1 if sch_form==7
*(note: this includes Grundschule)
gen haupt=0
replace haupt=1 if sch_form==1
gen gym=0
replace gym=1 if sch_form==10|sch_form==16|sch_form==17
*(note: Orientierungsstufe)
gen foerder=0
replace foerder=1 if sch_form==20
gen gesamt=0
replace gesamt=1 if sch_form==19
gen sonder=0
replace sonder=1 if sch_form==4|sch_form==8
*note: Grundschule is in the same category as Volksschule
*note: other schools are Freie Waldorfschule
gen other=0 
replace other=1 if sch_form==22

gen BL=3 
gen year=2006

rename staatsan_neu staat
tab staat, nol
keep if staat==1


rename SUEJGST stufe
destring stufe, replace force
tab stufe, miss

rename VORJJGST v_stufe 
destring v_stufe, replace force
tab v_stufe, miss

tab stufe v_stufe, miss
*note: previous grade missing for Abendgymnasium and Kolleg

gen repeat=0
replace repeat=1 if v_stufe==stufe


*drop pupils in strange grades (Note: this procedure also drops the
*very few pupils in grades VK and 1A 
drop if stufe==.
tab stufe if cohort==8990
drop if cohort==8990&(stufe<=7)
tab stufe if cohort==9091
drop if cohort==9091&(stufe<=6|stufe>=13)
tab stufe if cohort==9192
drop if cohort==9192&(stufe<=5|stufe>=12)
tab stufe if cohort==9293
drop if cohort==9293&(stufe<=4|stufe>=11)
tab stufe if cohort==9394
drop if cohort==9394&(stufe<=3|stufe>=10)
tab stufe if cohort==9495
drop if cohort==9495&(stufe<=2|stufe>=9)


forvalues i=3/13{
gen stufe`i'=0
replace stufe`i'=1 if stufe==`i'
}


**1 if boy
gen sex=0
replace sex=1 if GESCHL=="3"

keep gebjahr gebmonat sex cohort real haupt gym foerder gesamt sonder other stufe3-stufe13 repeat BL year 
sort cohort gebmonat sex
collapse (sum) real haupt gym foerder gesamt sonder other stufe3 stufe4 stufe5 stufe6 stufe7 stufe8 stufe9 stufe10 stufe11 stufe12 stufe13 repeat (mean) BL year, by(cohort gebmonat sex)

**************test
gen all1=real+haupt+gym+foerder+gesamt+sonder+other
gen all2=stufe3+stufe4+stufe5+stufe6+stufe7+stufe8+stufe9+stufe10+stufe11+stufe12+stufe13
count
count if all1==all2

save ${d_dir}${S}Bayern06, replace




*****************************************************2006/2007
***************************************************************
clear
use ${d_dir}${S}FDZ_ALLG_SCHULE_B0708_ANONYM_END.dta


*rename birth year and birth month
rename gebjahr1 gebjahr
rename GEBMON gebmonat


*cohort indicators 
gen cohort=0
replace cohort=8990 if (gebjahr==1989&gebmonat>=7)|(gebjahr==1990&gebmonat<=6)

replace cohort=9091 if (gebjahr==1990&gebmonat>=7)|(gebjahr==1991&gebmonat<=6)

replace cohort=9192 if (gebjahr==1991&gebmonat>=7)|(gebjahr==1992&gebmonat<=6)

replace cohort=9293 if (gebjahr==1992&gebmonat>=7)|(gebjahr==1993&gebmonat<=6)

replace cohort=9394 if (gebjahr==1993&gebmonat>=7)|(gebjahr==1994&gebmonat<=6)

replace cohort=9495 if (gebjahr==1994&gebmonat>=7)|(gebjahr==1995&gebmonat<=6)

*keep relevant cohorts only
keep if cohort==8990|cohort==9091|cohort==9192|cohort==9293|cohort==9394|cohort==9495

rename SART sch_form
tab sch_form, miss


*school indicators
gen real=0
replace real=1 if sch_form==7|sch_form==13
*(note: this includes Grundschule)
gen haupt=0
replace haupt=1 if sch_form==1
gen gym=0
replace gym=1 if sch_form==10|sch_form==16|sch_form==17
*(note: Orientierungsstufe)
gen foerder=0
replace foerder=1 if sch_form==20
gen gesamt=0
replace gesamt=1 if sch_form==19
gen sonder=0
replace sonder=1 if sch_form==4|sch_form==8
*note: Grundschule is in the same category as Volksschule
*note: other schools are Freie Waldorfschule
gen other=0 
replace other=1 if sch_form==22

gen BL=3 
gen year=2007

rename staatsan_neu staat
tab staat, nol
keep if staat==1


rename SUEJGST stufe
destring stufe, replace force
tab stufe, miss

rename VORJJGST v_stufe 
destring v_stufe, replace force
tab v_stufe, miss

tab stufe v_stufe, miss
*note: previous grade missing for Abendgymnasium and Kolleg

gen repeat=0
replace repeat=1 if v_stufe==stufe


*drop pupils in strange grades (Note: this procedure also drops the
*very few pupils in grades VK and 1A 
drop if stufe==.
tab stufe if cohort==8990
drop if cohort==8990&(stufe<=8)
tab stufe if cohort==9091
drop if cohort==9091&(stufe<=7)
tab stufe if cohort==9192
drop if cohort==9192&(stufe<=6|stufe>=13)
tab stufe if cohort==9293
drop if cohort==9293&(stufe<=5|stufe>=12)
tab stufe if cohort==9394
drop if cohort==9394&(stufe<=4|stufe>=11)
tab stufe if cohort==9495
drop if cohort==9495&(stufe<=3|stufe>=10)


forvalues i=4/13{
gen stufe`i'=0
replace stufe`i'=1 if stufe==`i'
}


**1 if boy
gen sex=0
replace sex=1 if GESCHL==3

keep gebjahr gebmonat sex cohort real haupt gym foerder gesamt sonder other stufe4-stufe13 repeat BL year 
sort cohort gebmonat sex
collapse (sum) real haupt gym foerder gesamt sonder other stufe4 stufe5 stufe6 stufe7 stufe8 stufe9 stufe10 stufe11 stufe12 stufe13 repeat (mean) BL year, by(cohort gebmonat sex)

**************test
gen all1=real+haupt+gym+foerder+gesamt+sonder+other
gen all2=stufe4+stufe5+stufe6+stufe7+stufe8+stufe9+stufe10+stufe11+stufe12+stufe13
count
count if all1==all2

save ${d_dir}${S}Bayern07, replace


*****************************************************2008/2009
***************************************************************
clear
use ${d_dir}${S}FDZ_ALLG_SCHULE_B0809_ANONYM_END.dta


*rename birth year and birth month
rename gebjahr1 gebjahr
rename GEBMON gebmonat


*cohort indicators 
gen cohort=0
replace cohort=8990 if (gebjahr==1989&gebmonat>=7)|(gebjahr==1990&gebmonat<=6)

replace cohort=9091 if (gebjahr==1990&gebmonat>=7)|(gebjahr==1991&gebmonat<=6)

replace cohort=9192 if (gebjahr==1991&gebmonat>=7)|(gebjahr==1992&gebmonat<=6)

replace cohort=9293 if (gebjahr==1992&gebmonat>=7)|(gebjahr==1993&gebmonat<=6)

replace cohort=9394 if (gebjahr==1993&gebmonat>=7)|(gebjahr==1994&gebmonat<=6)

replace cohort=9495 if (gebjahr==1994&gebmonat>=7)|(gebjahr==1995&gebmonat<=6)

*keep relevant cohorts only
keep if cohort==8990|cohort==9091|cohort==9192|cohort==9293|cohort==9394|cohort==9495

rename SART sch_form
tab sch_form, miss


*school indicators
gen real=0
replace real=1 if sch_form==7|sch_form==13
*(note: this includes Grundschule)
gen haupt=0
replace haupt=1 if sch_form==1
gen gym=0
replace gym=1 if sch_form==10|sch_form==16|sch_form==17
*(note: Orientierungsstufe)
gen foerder=0
replace foerder=1 if sch_form==20
gen gesamt=0
replace gesamt=1 if sch_form==19
gen sonder=0
replace sonder=1 if sch_form==4|sch_form==8
*note: Grundschule is in the same category as Volksschule
*note: other schools are Freie Waldorfschule
gen other=0 
replace other=1 if sch_form==22

gen BL=3 
gen year=2008

rename staatsan_neu staat
tab staat, nol
keep if staat==1


rename SUEJGST stufe
destring stufe, replace force
tab stufe, miss

rename VORJJGST v_stufe 
destring v_stufe, replace force
tab v_stufe, miss

tab stufe v_stufe, miss
*note: previous grade missing for Abendgymnasium and Kolleg

gen repeat=0
replace repeat=1 if v_stufe==stufe


*drop pupils in strange grades (Note: this procedure also drops the
*very few pupils in grades VK and 1A 
drop if stufe==.
tab stufe if cohort==8990
drop if cohort==8990&(stufe<=9)
tab stufe if cohort==9091
drop if cohort==9091&(stufe<=8)
tab stufe if cohort==9192
drop if cohort==9192&(stufe<=7)
tab stufe if cohort==9293
drop if cohort==9293&(stufe<=6|stufe>=13)
tab stufe if cohort==9394
drop if cohort==9394&(stufe<=5|stufe>=12)
tab stufe if cohort==9495
drop if cohort==9495&(stufe<=4|stufe>=11)


forvalues i=5/13{
gen stufe`i'=0
replace stufe`i'=1 if stufe==`i'
}


**1 if boy
gen sex=0
replace sex=1 if GESCHL==3

keep gebjahr gebmonat sex cohort real haupt gym foerder gesamt sonder other stufe5-stufe13 repeat BL year 
sort cohort gebmonat sex
collapse (sum) real haupt gym foerder gesamt sonder other stufe5 stufe6 stufe7 stufe8 stufe9 stufe10 stufe11 stufe12 stufe13 repeat (mean) BL year, by(cohort gebmonat sex)

**************test
gen all1=real+haupt+gym+foerder+gesamt+sonder+other
gen all2=stufe5+stufe6+stufe7+stufe8+stufe9+stufe10+stufe11+stufe12+stufe13
count
count if all1==all2

save ${d_dir}${S}Bayern08, replace

******************************************
*append data
****************************************
clear
use Bayern04
append using Bayern05
append using Bayern06
append using Bayern07
append using Bayern08

save Bayern18to36_agg, replace
 
*****anonymize data

clear
use Bayern18to36_agg

***create a variable # of pupils in correct grade (i.e. started school in time and did not repeat a grade)


gen correct=stufe9+stufe10+stufe11 if cohort==8990&year==2004
replace correct=stufe10+stufe11+stufe12 if cohort==8990&year==2005
replace correct=stufe11+stufe12+stufe13 if cohort==8990&year==2006
replace correct=stufe12+stufe13 if cohort==8990&year==2007
replace correct=stufe13 if cohort==8990&year==2008

replace correct=stufe8+stufe9+stufe10 if cohort==9091&year==2004
replace correct=stufe9+stufe10+stufe11 if cohort==9091&year==2005
replace correct=stufe10+stufe11+stufe12 if cohort==9091&year==2006
replace correct=stufe11+stufe12+stufe13 if cohort==9091&year==2007
replace correct=stufe12+stufe13 if cohort==9091&year==2008
 
replace correct=stufe7+stufe8+stufe9 if cohort==9192&year==2004
replace correct=stufe8+stufe9+stufe10 if cohort==9192&year==2005
replace correct=stufe9+stufe10+stufe11 if cohort==9192&year==2006
replace correct=stufe10+stufe11+stufe12 if cohort==9192&year==2007
replace correct=stufe11+stufe12+stufe13 if cohort==9192&year==2008


replace correct=stufe6+stufe7+stufe8 if cohort==9293&year==2004
replace correct=stufe7+stufe8+stufe9 if cohort==9293&year==2005
replace correct=stufe8+stufe9+stufe10 if cohort==9293&year==2006
replace correct=stufe9+stufe10+stufe11 if cohort==9293&year==2007
replace correct=stufe10+stufe11+stufe12 if cohort==9293&year==2008


replace correct=stufe5+stufe6+stufe7 if cohort==9394&year==2004
replace correct=stufe6+stufe7+stufe8 if cohort==9394&year==2005
replace correct=stufe7+stufe8+stufe9 if cohort==9394&year==2006
replace correct=stufe8+stufe9+stufe10 if cohort==9394&year==2007
replace correct=stufe9+stufe10+stufe11 if cohort==9394&year==2008


replace correct=stufe4+stufe5+stufe6 if cohort==9495&year==2004
replace correct=stufe5+stufe6+stufe7 if cohort==9495&year==2005
replace correct=stufe6+stufe7+stufe8 if cohort==9495&year==2006
replace correct=stufe7+stufe8+stufe9 if cohort==9495&year==2007
replace correct=stufe8+stufe9+stufe10 if cohort==9495&year==2008
 
drop stufe*

****keep only potential 8th grade
keep if (cohort==9091&year==2004)|(cohort==9192&year==2005)|(cohort==9293&year==2006)|(cohort==9394&year==2007)|(cohort==9495&year==2008)

***foerder are put into Hauptschule
replace haupt=haupt + foerder
drop foerder

*Waldorf is put into Realschule
replace real=real+other
drop other

*gesamt is put into Realschule
replace real=real+gesamt
drop gesamt

save Bayern18to36_agg_ano, replace

log close

