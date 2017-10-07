
clear
set mem 500m

cap log close
log using aggregatedata18to36.log, replace

**************************************
*Hessen
*******************************************


*****************************************************2002/2003
***************************************************************

use heschool/datasets/stata/suf_abs_0203

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

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

tab sch_form, miss

*school indicators
gen real=0
replace real=1 if sch_form==5
gen haupt=0
replace haupt=1 if sch_form==4
gen gym=0
replace gym=1 if sch_form==6
gen foerder=0
replace foerder=1 if sch_form==7
gen gesamt=0
replace gesamt=1 if sch_form==8
gen sonder=0
replace sonder=1 if sch_form==9
gen grund=0
replace grund=1 if sch_form==3
gen other=0 
replace other=1 if sch_form==1|sch_form==2|sch_form>=10

gen BL=1 
gen year=2002

destring stufe, replace
tab stufe, miss
destring v_stufe, replace
tab v_stufe, miss

tab stufe v_stufe, miss

tab staat
keep if staat==1

gen repeat=0
replace repeat=1 if v_stufe==stufe


*drop pupils in strange grades
tab stufe if cohort==8990
drop if cohort==8990&(stufe<=3|stufe>=10)
tab stufe if cohort==9091
drop if cohort==9091&(stufe<=2|stufe>=9)
tab stufe if cohort==9192
drop if cohort==9192&(stufe<=1|stufe>=8)
tab stufe if cohort==9293
drop if cohort==9293&(stufe<=0|stufe>=7)
tab stufe if cohort==9394
drop if cohort==9394&stufe>=6
tab stufe if cohort==9495
drop if cohort==9495&stufe>=5


forvalues i=0/9{
gen stufe`i'=0
replace stufe`i'=1 if stufe==`i'
}


save Hessen02_ind, replace
keep gebjahr gebmonat sex cohort real haupt gym foerder gesamt sonder grund other stufe0-stufe9 repeat BL year 
sort cohort gebmonat sex
collapse (sum) real haupt gym foerder gesamt sonder grund other stufe0 stufe1 stufe2 stufe3 stufe4 stufe5 stufe6 stufe7 stufe8 stufe9 repeat (mean) BL year, by(cohort gebmonat sex)

**************test
gen all1=real+haupt+gym+foerder+gesamt+sonder+grund+other
gen all2=stufe0+stufe1+stufe2+stufe3+stufe4+stufe5+stufe6+stufe7+stufe8+stufe9
count
count if all1==all2

save Hessen02, replace



*****************************************************2003/2004
***************************************************************
clear
use heschool/datasets/stata/suf_abs_0304

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

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

tab sch_form, miss

*school indicators
gen real=0
replace real=1 if sch_form==5
gen haupt=0
replace haupt=1 if sch_form==4
gen gym=0
replace gym=1 if sch_form==6
gen foerder=0
replace foerder=1 if sch_form==7
gen gesamt=0
replace gesamt=1 if sch_form==8
gen sonder=0
replace sonder=1 if sch_form==9
gen grund=0
replace grund=1 if sch_form==3
gen other=0 
replace other=1 if sch_form==1|sch_form==2|sch_form>=10

gen BL=1 
gen year=2003

destring stufe, replace
tab stufe, miss
destring v_stufe, replace
tab v_stufe, miss

tab stufe v_stufe, miss

tab staat
keep if staat==1

gen repeat=0
replace repeat=1 if v_stufe==stufe

*drop pupils in strange grades
tab stufe if cohort==8990
drop if cohort==8990&(stufe<=4|stufe>=11)
tab stufe if cohort==9091
drop if cohort==9091&(stufe<=3|stufe>=10)
tab stufe if cohort==9192
drop if cohort==9192&(stufe<=2|stufe>=9)
tab stufe if cohort==9293
drop if cohort==9293&(stufe<=1|stufe>=8)
tab stufe if cohort==9394
drop if cohort==9394&(stufe<=0|stufe>=7)
tab stufe if cohort==9495
drop if cohort==9495&(stufe>=6)


forvalues i=0/10{
gen stufe`i'=0
replace stufe`i'=1 if stufe==`i'
}


save Hessen03_ind, replace
keep gebjahr gebmonat sex cohort real haupt gym foerder gesamt sonder grund other stufe0-stufe10 repeat BL year 
sort cohort gebmonat sex
collapse (sum) real haupt gym foerder gesamt sonder grund other stufe0 stufe1 stufe2 stufe3 stufe4 stufe5 stufe6 stufe7 stufe8 stufe9 stufe10 repeat (mean) BL year, by(cohort gebmonat sex)

**************test
gen all1=real+haupt+gym+foerder+gesamt+sonder+grund+other
gen all2=stufe0+stufe1+stufe2+stufe3+stufe4+stufe5+stufe6+stufe7+stufe8+stufe9+stufe10
count
count if all1==all2

save Hessen03, replace



*****************************************************2004/2005
***************************************************************
clear
use heschool/datasets/stata/suf_abs_0405

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

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

tab sch_form, miss

*school indicators
gen real=0
replace real=1 if sch_form==5
gen haupt=0
replace haupt=1 if sch_form==4
gen gym=0
replace gym=1 if sch_form==6
gen foerder=0
replace foerder=1 if sch_form==7
gen gesamt=0
replace gesamt=1 if sch_form==8
gen sonder=0
replace sonder=1 if sch_form==9
gen grund=0
replace grund=1 if sch_form==3
gen other=0 
replace other=1 if sch_form==1|sch_form==2|sch_form>=10

gen BL=1 
gen year=2004

destring stufe, replace
tab stufe, miss
destring v_stufe, replace
tab v_stufe, miss

tab stufe v_stufe, miss

tab staat
keep if staat==1

gen repeat=0
replace repeat=1 if v_stufe==stufe


*drop pupils in strange grades
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


save Hessen04_ind, replace
keep gebjahr gebmonat sex cohort real haupt gym foerder gesamt sonder grund other stufe1-stufe11 repeat BL year 
sort cohort gebmonat sex
collapse (sum) real haupt gym foerder gesamt sonder grund other stufe1 stufe2 stufe3 stufe4 stufe5 stufe6 stufe7 stufe8 stufe9 stufe10 stufe11 repeat (mean) BL year, by(cohort gebmonat sex)

**************test
gen all1=real+haupt+gym+foerder+gesamt+sonder+grund+other
gen all2=stufe1+stufe2+stufe3+stufe4+stufe5+stufe6+stufe7+stufe8+stufe9+stufe10+stufe11
count
count if all1==all2

save Hessen04, replace



*****************************************************2005/2006
***************************************************************
clear
use heschool/datasets/stata/suf_abs_0506

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

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

tab sch_form, miss

*school indicators

gen real=0
replace real=1 if sch_form==5


gen haupt=0
replace haupt=1 if sch_form==4
gen gym=0
replace gym=1 if sch_form==6
gen foerder=0
replace foerder=1 if sch_form==7
gen gesamt=0
replace gesamt=1 if sch_form==8
gen sonder=0
replace sonder=1 if sch_form==9
gen grund=0
replace grund=1 if sch_form==3
gen other=0 
replace other=1 if sch_form==1|sch_form==2|sch_form>=10


gen BL=1 
gen year=2005

destring stufe, replace
tab stufe, miss
destring v_stufe, replace
tab v_stufe, miss

tab stufe v_stufe, miss

tab staat
keep if staat==1

gen repeat=0
replace repeat=1 if v_stufe==stufe


*drop pupils in strange grades
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


save Hessen05_ind, replace
keep gebjahr gebmonat sex cohort real haupt gym foerder gesamt sonder grund other stufe2-stufe12 repeat BL year 
sort cohort gebmonat sex
collapse (sum) real haupt gym foerder gesamt sonder grund other stufe2 stufe3 stufe4 stufe5 stufe6 stufe7 stufe8 stufe9 stufe10 stufe11 stufe12 repeat (mean) BL year, by(cohort gebmonat sex)

**************test
gen all1=real+haupt+gym+foerder+gesamt+sonder+grund+other
gen all2=stufe2+stufe3+stufe4+stufe5+stufe6+stufe7+stufe8+stufe9+stufe10+stufe11+stufe12
count
count if all1==all2

save Hessen05, replace




*****************************************************2006/2007
***************************************************************
clear
use heschool/datasets/stata/suf_abs_0607

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

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

tab sch_form, miss

*school indicators

gen real=0
replace real=1 if sch_form==5
gen haupt=0


replace haupt=1 if sch_form==4
gen gym=0
replace gym=1 if sch_form==6
gen foerder=0
replace foerder=1 if sch_form==7
gen gesamt=0
replace gesamt=1 if sch_form==8
gen sonder=0
replace sonder=1 if sch_form==9
gen grund=0
replace grund=1 if sch_form==3
gen other=0 
replace other=1 if sch_form==1|sch_form==2|sch_form>=10


gen BL=1 
gen year=2006

destring stufe, replace
tab stufe, miss
destring v_stufe, replace
tab v_stufe, miss

tab stufe v_stufe, miss

tab staat
keep if staat==1

gen repeat=0
replace repeat=1 if v_stufe==stufe


*drop pupils in strange grades
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


save Hessen06_ind, replace
keep gebjahr gebmonat sex cohort real haupt gym foerder gesamt sonder grund other stufe3-stufe13 repeat BL year 
sort cohort gebmonat sex
collapse (sum) real haupt gym foerder gesamt sonder grund other stufe3 stufe4 stufe5 stufe6 stufe7 stufe8 stufe9 stufe10 stufe11 stufe12 stufe13 repeat (mean) BL year, by(cohort gebmonat sex)

**************test
gen all1=real+haupt+gym+foerder+gesamt+sonder+grund+other
gen all2=stufe3+stufe4+stufe5+stufe6+stufe7+stufe8+stufe9+stufe10+stufe11+stufe12+stufe13
count
count if all1==all2

save Hessen06, replace



*****************************************************2007/2008
***************************************************************
clear
use heschool/datasets/stata/suf_abs_0708

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

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

tab sch_form, miss

*school indicators

gen real=0
replace real=1 if sch_form==5
gen haupt=0
replace haupt=1 if sch_form==4
gen gym=0
replace gym=1 if sch_form==6
gen foerder=0
replace foerder=1 if sch_form==7
gen gesamt=0
replace gesamt=1 if sch_form==8
gen sonder=0
replace sonder=1 if sch_form==9
gen grund=0
replace grund=1 if sch_form==3
gen other=0 
replace other=1 if sch_form==1|sch_form==2|sch_form>=10


gen BL=1 
gen year=2007

destring stufe, replace
tab stufe, miss
destring v_stufe, replace
tab v_stufe, miss

tab stufe v_stufe, miss

tab staat
keep if staat==1


***previous grade looks strange. Set this variable to missing.
gen repeat=.


*drop pupils in strange grades
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


save Hessen07_ind, replace
keep gebjahr gebmonat sex cohort real haupt gym foerder gesamt sonder grund other stufe4-stufe13 repeat BL year 
sort cohort gebmonat sex
collapse (sum) real haupt gym foerder gesamt sonder grund other stufe4 stufe5 stufe6 stufe7 stufe8 stufe9 stufe10 stufe11 stufe12 stufe13 repeat (mean) BL year, by(cohort gebmonat sex)

**************test
gen all1=real+haupt+gym+foerder+gesamt+sonder+grund+other
gen all2=stufe4+stufe5+stufe6+stufe7+stufe8+stufe9+stufe10+stufe11+stufe12+stufe13
count
count if all1==all2

save Hessen07, replace



*****************************************************2008/2009
***************************************************************
clear
use heschool/datasets/stata/suf_abs_0809

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

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

tab sch_form, miss

*school indicators

gen real=0
replace real=1 if sch_form==5
gen haupt=0
replace haupt=1 if sch_form==4
gen gym=0
replace gym=1 if sch_form==6
gen foerder=0
replace foerder=1 if sch_form==7
gen gesamt=0
replace gesamt=1 if sch_form==8
gen sonder=0
replace sonder=1 if sch_form==9
gen grund=0
replace grund=1 if sch_form==3
gen other=0 
replace other=1 if sch_form==1|sch_form==2|sch_form>=10


gen BL=1 
gen year=2008

destring stufe, replace
tab stufe, miss
destring v_stufe, replace
tab v_stufe, miss

tab stufe v_stufe, miss

tab staat
keep if staat==1

***previous grade looks strange. Set this variable to missing.
gen repeat=.


*drop pupils in strange grades
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


save Hessen08_ind, replace
keep gebjahr gebmonat sex cohort real haupt gym foerder gesamt sonder grund other stufe5-stufe13 repeat BL year 
sort cohort gebmonat sex
collapse (sum) real haupt gym foerder gesamt sonder grund other  stufe5 stufe6 stufe7 stufe8 stufe9 stufe10 stufe11 stufe12 stufe13 repeat (mean) BL year, by(cohort gebmonat sex)

**************test
gen all1=real+haupt+gym+foerder+gesamt+sonder+grund+other
gen all2=stufe5+stufe6+stufe7+stufe8+stufe9+stufe10+stufe11+stufe12+stufe13
count
count if all1==all2

save Hessen08, replace


**************************************
*Schleswig-Holstein
*******************************************

****Note: deaf, blind, down syndrome pupils are assigned a rather arbitrarz grade, and the assignment changes over time. I set the grade variable to missing for these pupils.

*****************************************************2003/2004
*************************************************************

clear
use shschool/datasets/suf_sh_0304

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

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

*school indicators
tab sch_form
gen real=0
replace real=1 if sch_form==5
gen haupt=0
replace haupt=1 if sch_form==4
gen gym=0
replace gym=1 if sch_form==6
gen gesamt=0
replace gesamt=1 if sch_form==8
gen sonder=0
replace sonder=1 if sch_form==9
gen grund=0
replace grund=1 if sch_form==3
gen other=0 
replace other=1 if sch_form==1|sch_form==2|sch_form>=10
gen deafblind=0
replace deafblind=1 if sch_form==7

gen BL=2
gen year=2003

destring stufe, replace

tab staat
keep if staat==1

*note: previous grade is not included in SH data

*drop pupils in strange grades
replace stufe=. if deafblind==1
tab stufe if cohort==8990
drop if cohort==8990&(stufe<=4|stufe>=11)&deafblind==0
tab stufe if cohort==9091
drop if cohort==9091&(stufe<=3|stufe>=10)&deafblind==0
tab stufe if cohort==9192
drop if cohort==9192&(stufe<=2|stufe>=9)&deafblind==0
tab stufe if cohort==9293
drop if cohort==9293&(stufe<=1|stufe>=8)&deafblind==0
tab stufe if cohort==9394
drop if cohort==9394&(stufe<=0|stufe>=7)&deafblind==0
tab stufe if cohort==9495
drop if cohort==9495&(stufe>=6)&deafblind==0


forvalues i=0/10{
gen stufe`i'=0
replace stufe`i'=1 if stufe==`i'
}


save SH03_ind, replace
keep gebjahr gebmonat sex cohort real haupt gym  gesamt sonder grund other deafblind stufe0-stufe10  BL year 
sort cohort gebmonat sex
collapse (sum) real haupt gym gesamt sonder grund other deafblind  stufe0 stufe1 stufe2 stufe3 stufe4 stufe5 stufe6 stufe7 stufe8 stufe9 stufe10 (mean) BL year, by(cohort gebmonat sex)

**************test
gen all1=real+haupt+gym+gesamt+sonder+grund+other+deafblind
gen all2=stufe0+stufe1+stufe2+stufe3+stufe4+stufe5+stufe6+stufe7+stufe8+stufe9+stufe10+deafblind
count
count if all1==all2

save SH03, replace


*****************************************************2004/2005
*************************************************************

clear
use shschool/datasets/suf_sh_0405

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

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

*school indicators
tab sch_form
gen real=0
replace real=1 if sch_form==5
gen haupt=0
replace haupt=1 if sch_form==4
gen gym=0
replace gym=1 if sch_form==6
gen gesamt=0
replace gesamt=1 if sch_form==8
gen sonder=0
replace sonder=1 if sch_form==9
gen grund=0
replace grund=1 if sch_form==3
gen other=0 
replace other=1 if sch_form==1|sch_form==2|sch_form>=10
gen deafblind=0
replace deafblind=1 if sch_form==7

gen BL=2
gen year=2004


destring stufe, replace

tab staat
keep if staat==1

*note: previous grade is not included in SH data

*drop pupils in strange grades
replace stufe=. if deafblind==1
tab stufe if cohort==8990

drop if cohort==8990&(stufe<=5|stufe>=12)&deafblind==0
tab stufe if cohort==9091
drop if cohort==9091&(stufe<=4|stufe>=11)&deafblind==0
tab stufe if cohort==9192
drop if cohort==9192&(stufe<=3|stufe>=10)&deafblind==0
tab stufe if cohort==9293
drop if cohort==9293&(stufe<=2|stufe>=9)&deafblind==0
tab stufe if cohort==9394
drop if cohort==9394&(stufe<=1|stufe>=8)&deafblind==0
tab stufe if cohort==9495
drop if cohort==9495&(stufe<=0|stufe>=7)&deafblind==0


forvalues i=1/11{
gen stufe`i'=0
replace stufe`i'=1 if stufe==`i'
}


save SH04_ind, replace
keep gebjahr gebmonat sex cohort real haupt gym deafblind gesamt sonder grund other stufe1-stufe11  BL year 
sort cohort gebmonat sex
collapse (sum) real haupt gym deafblind gesamt sonder grund other stufe1 stufe2 stufe3 stufe4 stufe5 stufe6 stufe7 stufe8 stufe9 stufe10 stufe11 (mean) BL year, by(cohort gebmonat sex)

**************test
gen all1=real+haupt+gym+deafblind+gesamt+sonder+grund+other
gen all2=stufe1+stufe2+stufe3+stufe4+stufe5+stufe6+stufe7+stufe8+stufe9+stufe10+stufe11+deafblind
count
count if all1==all2

save SH04, replace


*****************************************************2005/2006
*************************************************************

clear
use shschool/datasets/suf_sh_0506

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

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

*school indicators
tab sch_form
gen real=0
replace real=1 if sch_form==5
gen haupt=0
replace haupt=1 if sch_form==4
gen gym=0
replace gym=1 if sch_form==6
gen gesamt=0
replace gesamt=1 if sch_form==8
gen sonder=0
replace sonder=1 if sch_form==9
gen grund=0
replace grund=1 if sch_form==3
gen other=0 
replace other=1 if sch_form==1|sch_form==2|sch_form>=10
gen deafblind=0
replace deafblind=1 if sch_form==7

gen BL=2
gen year=2005


destring stufe, replace

tab staat
keep if staat==1

*note: previous grade is not included in SH data

*drop pupils in strange grades
replace stufe=. if deafblind==1

tab stufe if cohort==8990
drop if cohort==8990&(stufe<=6|stufe>=13)&deafblind==0
tab stufe if cohort==9091
drop if cohort==9091&(stufe<=5|stufe>=12)&deafblind==0
tab stufe if cohort==9192
drop if cohort==9192&(stufe<=4|stufe>=11)&deafblind==0
tab stufe if cohort==9293
drop if cohort==9293&(stufe<=3|stufe>=10)&deafblind==0
tab stufe if cohort==9394
drop if cohort==9394&(stufe<=2|stufe>=9)&deafblind==0
tab stufe if cohort==9495
drop if cohort==9495&(stufe<=1|stufe>=8)&deafblind==0


forvalues i=2/12{
gen stufe`i'=0
replace stufe`i'=1 if stufe==`i'
}


save SH05_ind, replace
keep gebjahr gebmonat sex cohort real haupt gym deafblind gesamt sonder grund other stufe2-stufe12  BL year 
sort cohort gebmonat sex
collapse (sum) real haupt gym deafblind gesamt sonder grund other stufe2 stufe3 stufe4 stufe5 stufe6 stufe7 stufe8 stufe9 stufe10 stufe11 stufe12 (mean) BL year, by(cohort gebmonat sex)

**************test
gen all1=real+haupt+gym+deafblind+gesamt+sonder+grund+other
gen all2=stufe2+stufe3+stufe4+stufe5+stufe6+stufe7+stufe8+stufe9+stufe10+stufe11+stufe12+deafblind
count
count if all1==all2

save SH05, replace


*****************************************************2006/2007
*************************************************************

clear
use shschool/datasets/suf_sh_0607

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

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

*school indicators
tab sch_form
gen real=0
replace real=1 if sch_form==5
gen haupt=0
replace haupt=1 if sch_form==4
gen gym=0
replace gym=1 if sch_form==6
gen gesamt=0
replace gesamt=1 if sch_form==8
gen sonder=0
replace sonder=1 if sch_form==9
gen grund=0
replace grund=1 if sch_form==3
gen other=0 
replace other=1 if sch_form==1|sch_form==2|sch_form>=10
gen deafblind=0
replace deafblind=1 if sch_form==7

gen BL=2
gen year=2006


destring stufe, replace

tab staat
keep if staat==1

*note: previous grade is not included in SH data

*drop pupils in strange grades. 
replace stufe=. if deafblind==1
tab stufe if cohort==8990
drop if cohort==8990&(stufe<=7)&deafblind==0
tab stufe if cohort==9091
drop if cohort==9091&(stufe<=6|stufe>=13)&deafblind==0
tab stufe if cohort==9192
drop if cohort==9192&(stufe<=5|stufe>=12)&deafblind==0
tab stufe if cohort==9293
drop if cohort==9293&(stufe<=4|stufe>=11)&deafblind==0
tab stufe if cohort==9394
drop if cohort==9394&(stufe<=3|stufe>=10)&deafblind==0
tab stufe if cohort==9495
drop if cohort==9495&(stufe<=2|stufe>=9)&deafblind==0


forvalues i=3/13{
gen stufe`i'=0
replace stufe`i'=1 if stufe==`i'
}


save SH06_ind, replace
keep gebjahr gebmonat sex cohort real haupt gym deafblind gesamt sonder grund other stufe3-stufe13  BL year 
sort cohort gebmonat sex
collapse (sum) real haupt gym deafblind gesamt sonder grund other stufe3 stufe4 stufe5 stufe6 stufe7 stufe8 stufe9 stufe10 stufe11 stufe12 stufe13 (mean) BL year, by(cohort gebmonat sex)

**************test
gen all1=real+haupt+gym+deafblind+gesamt+sonder+grund+other
gen all2=stufe3+stufe4+stufe5+stufe6+stufe7+stufe8+stufe9+stufe10+stufe11+stufe12+stufe13+deafblind
count
count if all1==all2

save SH06, replace




*****************************************************2007/2008
*************************************************************

clear
use shschool/datasets/suf_sh_0708

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

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

*school indicators
tab sch_form
gen real=0
replace real=1 if sch_form==5
gen haupt=0
replace haupt=1 if sch_form==4
gen gym=0
replace gym=1 if sch_form==6
gen gesamt=0
replace gesamt=1 if sch_form==8
gen sonder=0
replace sonder=1 if sch_form==9
gen grund=0
replace grund=1 if sch_form==3
gen other=0 
replace other=1 if sch_form==1|sch_form==2|sch_form>=10
gen deafblind=0
replace deafblind=1 if sch_form==7

gen BL=2
gen year=2007


destring stufe, replace

tab staat
keep if staat==1

*note: previous grade is not included in SH data

*drop pupils in strange grades. 
replace stufe=. if deafblind==1
tab stufe if cohort==8990
drop if cohort==8990&(stufe<=8)&deafblind==0
tab stufe if cohort==9091
drop if cohort==9091&(stufe<=7)&deafblind==0
tab stufe if cohort==9192
drop if cohort==9192&(stufe<=6|stufe>=13)&deafblind==0
tab stufe if cohort==9293
drop if cohort==9293&(stufe<=5|stufe>=12)&deafblind==0
tab stufe if cohort==9394
drop if cohort==9394&(stufe<=4|stufe>=11)&deafblind==0
tab stufe if cohort==9495
drop if cohort==9495&(stufe<=3|stufe>=10)&deafblind==0


forvalues i=4/13{
gen stufe`i'=0
replace stufe`i'=1 if stufe==`i'
}


save SH07_ind, replace
keep gebjahr gebmonat sex cohort real haupt gym deafblind gesamt sonder grund other stufe4-stufe13  BL year 
sort cohort gebmonat sex
collapse (sum) real haupt gym deafblind gesamt sonder grund other  stufe4 stufe5 stufe6 stufe7 stufe8 stufe9 stufe10 stufe11 stufe12 stufe13 (mean) BL year, by(cohort gebmonat sex)

**************test
gen all1=real+haupt+gym+deafblind+gesamt+sonder+grund+other
gen all2=stufe4+stufe5+stufe6+stufe7+stufe8+stufe9+stufe10+stufe11+stufe12+stufe13+deafblind
count
count if all1==all2

save SH07, replace




*****************************************************2008/2009
*************************************************************

clear
use shschool/datasets/suf_sh_0809

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

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

*school indicators
tab sch_form
gen real=0
replace real=1 if sch_form==5
gen haupt=0
replace haupt=1 if sch_form==4
gen gym=0
replace gym=1 if sch_form==6
gen gesamt=0
replace gesamt=1 if sch_form==8
gen sonder=0
replace sonder=1 if sch_form==9
gen grund=0
replace grund=1 if sch_form==3
gen other=0 
replace other=1 if sch_form==1|sch_form==2|sch_form>=10
gen deafblind=0
replace deafblind=1 if sch_form==7

gen BL=2
gen year=2008


destring stufe, replace

tab staat
keep if staat==1

*note: previous grade is not included in SH data

*drop pupils in strange grades. 
replace stufe=. if deafblind==1
tab stufe if cohort==8990
drop if cohort==8990&stufe<=9&deafblind==0
tab stufe if cohort==9091
drop if cohort==9091&stufe<=8&deafblind==0
tab stufe if cohort==9192
drop if cohort==9192&stufe<=7&deafblind==0
tab stufe if cohort==9293
drop if cohort==9293&(stufe<=6|stufe>=13)&deafblind==0
tab stufe if cohort==9394
drop if cohort==9394&(stufe<=6|stufe>=12)&deafblind==0
tab stufe if cohort==9495
drop if cohort==9495&(stufe<=4|stufe>=11)&deafblind==0
drop if stufe==20

forvalues i=5/13{
gen stufe`i'=0
replace stufe`i'=1 if stufe==`i'
}


save SH08_ind, replace
keep gebjahr gebmonat sex cohort real haupt gym deafblind gesamt sonder grund other stufe5-stufe13  BL year 
sort cohort gebmonat sex
collapse (sum) real haupt gym deafblind gesamt sonder grund other stufe5 stufe6 stufe7 stufe8 stufe9 stufe10 stufe11 stufe12 stufe13 (mean) BL year, by(cohort gebmonat sex)

**************test
gen all1=real+haupt+gym+deafblind+gesamt+sonder+grund+other
gen all2=stufe5+stufe6+stufe7+stufe8+stufe9+stufe10+stufe11+stufe12+stufe13+deafblind
count
count if all1==all2

save SH08, replace


******************************************
*append data
****************************************
clear
use Hessen02
append using Hessen03
append using Hessen04
append using Hessen05
append using Hessen06
append using Hessen07
append using Hessen08

save Hessen18to36_agg, replace
 
*****anonymize data
***create a variable # of pupils in correct grade (i.e. started school in time and did not repeat a grade)

gen correct=stufe7+stufe8+stufe9 if cohort==8990&year==2002
replace correct=stufe8+stufe9+stufe10 if cohort==8990&year==2003
replace correct=stufe9+stufe10+stufe11 if cohort==8990&year==2004
replace correct=stufe10+stufe11+stufe12 if cohort==8990&year==2005
replace correct=stufe11+stufe12+stufe13 if cohort==8990&year==2006
replace correct=stufe12+stufe13 if cohort==8990&year==2007
replace correct=stufe13 if cohort==8990&year==2008

replace correct=stufe6+stufe7+stufe8 if cohort==9091&year==2002
replace correct=stufe7+stufe8+stufe9 if cohort==9091&year==2003
replace correct=stufe8+stufe9+stufe10 if cohort==9091&year==2004
replace correct=stufe9+stufe10+stufe11 if cohort==9091&year==2005
replace correct=stufe10+stufe11+stufe12 if cohort==9091&year==2006
replace correct=stufe11+stufe12+stufe13 if cohort==9091&year==2007
replace correct=stufe12+stufe13 if cohort==9091&year==2008
 
replace correct=stufe5+stufe6+stufe7 if cohort==9192&year==2002
replace correct=stufe6+stufe7+stufe8 if cohort==9192&year==2003
replace correct=stufe7+stufe8+stufe9 if cohort==9192&year==2004
replace correct=stufe8+stufe9+stufe10 if cohort==9192&year==2005
replace correct=stufe9+stufe10+stufe11 if cohort==9192&year==2006
replace correct=stufe10+stufe11+stufe12 if cohort==9192&year==2007
replace correct=stufe11+stufe12+stufe13 if cohort==9192&year==2008

replace correct=stufe4+stufe5+stufe6 if cohort==9293&year==2002
replace correct=stufe5+stufe6+stufe7 if cohort==9293&year==2003
replace correct=stufe6+stufe7+stufe8 if cohort==9293&year==2004
replace correct=stufe7+stufe8+stufe9 if cohort==9293&year==2005
replace correct=stufe8+stufe9+stufe10 if cohort==9293&year==2006
replace correct=stufe9+stufe10+stufe11 if cohort==9293&year==2007
replace correct=stufe10+stufe11+stufe12 if cohort==9293&year==2008

replace correct=stufe3+stufe4+stufe5 if cohort==9394&year==2002
replace correct=stufe4+stufe5+stufe6 if cohort==9394&year==2003
replace correct=stufe5+stufe6+stufe7 if cohort==9394&year==2004
replace correct=stufe6+stufe7+stufe8 if cohort==9394&year==2005
replace correct=stufe7+stufe8+stufe9 if cohort==9394&year==2006
replace correct=stufe8+stufe9+stufe10 if cohort==9394&year==2007
replace correct=stufe9+stufe10+stufe11 if cohort==9394&year==2008

replace correct=stufe2+stufe3+stufe4 if cohort==9495&year==2002
replace correct=stufe3+stufe4+stufe5 if cohort==9495&year==2003
replace correct=stufe4+stufe5+stufe6 if cohort==9495&year==2004
replace correct=stufe5+stufe6+stufe7 if cohort==9495&year==2005
replace correct=stufe6+stufe7+stufe8 if cohort==9495&year==2006
replace correct=stufe7+stufe8+stufe9 if cohort==9495&year==2007
replace correct=stufe8+stufe9+stufe10 if cohort==9495&year==2008
 
 foreach v in real haupt gym foerder gesamt sonder grund other {
   replace `v' = 3 if `v'==1|`v'==2
   }
drop stufe*

save Hessen18to36_agg_ano, replace


**********************************
*Schleswig-Holstein
************************************ 
clear
use SH03
append using SH04
append using SH05
append using SH06
append using SH07
append using SH08
 

save SH18to36_agg, replace


*****anonymize data
***create a variable # of pupils in correct grade (i.e. started school in time and did not repeat a grade)

gen correct=stufe7+stufe8+stufe9 if cohort==8990&year==2002
replace correct=stufe8+stufe9+stufe10 if cohort==8990&year==2003
replace correct=stufe9+stufe10+stufe11 if cohort==8990&year==2004
replace correct=stufe10+stufe11+stufe12 if cohort==8990&year==2005
replace correct=stufe11+stufe12+stufe13 if cohort==8990&year==2006
replace correct=stufe12+stufe13 if cohort==8990&year==2007
replace correct=stufe13 if cohort==8990&year==2008

replace correct=stufe6+stufe7+stufe8 if cohort==9091&year==2002
replace correct=stufe7+stufe8+stufe9 if cohort==9091&year==2003
replace correct=stufe8+stufe9+stufe10 if cohort==9091&year==2004
replace correct=stufe9+stufe10+stufe11 if cohort==9091&year==2005
replace correct=stufe10+stufe11+stufe12 if cohort==9091&year==2006
replace correct=stufe11+stufe12+stufe13 if cohort==9091&year==2007
replace correct=stufe12+stufe13 if cohort==9091&year==2008
 
replace correct=stufe5+stufe6+stufe7 if cohort==9192&year==2002
replace correct=stufe6+stufe7+stufe8 if cohort==9192&year==2003
replace correct=stufe7+stufe8+stufe9 if cohort==9192&year==2004
replace correct=stufe8+stufe9+stufe10 if cohort==9192&year==2005
replace correct=stufe9+stufe10+stufe11 if cohort==9192&year==2006
replace correct=stufe10+stufe11+stufe12 if cohort==9192&year==2007
replace correct=stufe11+stufe12+stufe13 if cohort==9192&year==2008

replace correct=stufe4+stufe5+stufe6 if cohort==9293&year==2002
replace correct=stufe5+stufe6+stufe7 if cohort==9293&year==2003
replace correct=stufe6+stufe7+stufe8 if cohort==9293&year==2004
replace correct=stufe7+stufe8+stufe9 if cohort==9293&year==2005
replace correct=stufe8+stufe9+stufe10 if cohort==9293&year==2006
replace correct=stufe9+stufe10+stufe11 if cohort==9293&year==2007
replace correct=stufe10+stufe11+stufe12 if cohort==9293&year==2008

replace correct=stufe3+stufe4+stufe5 if cohort==9394&year==2002
replace correct=stufe4+stufe5+stufe6 if cohort==9394&year==2003
replace correct=stufe5+stufe6+stufe7 if cohort==9394&year==2004
replace correct=stufe6+stufe7+stufe8 if cohort==9394&year==2005
replace correct=stufe7+stufe8+stufe9 if cohort==9394&year==2006
replace correct=stufe8+stufe9+stufe10 if cohort==9394&year==2007
replace correct=stufe9+stufe10+stufe11 if cohort==9394&year==2008

replace correct=stufe2+stufe3+stufe4 if cohort==9495&year==2002
replace correct=stufe3+stufe4+stufe5 if cohort==9495&year==2003
replace correct=stufe4+stufe5+stufe6 if cohort==9495&year==2004
replace correct=stufe5+stufe6+stufe7 if cohort==9495&year==2005
replace correct=stufe6+stufe7+stufe8 if cohort==9495&year==2006
replace correct=stufe7+stufe8+stufe9 if cohort==9495&year==2007
replace correct=stufe8+stufe9+stufe10 if cohort==9495&year==2008 



foreach v in real haupt gym deafblind gesamt sonder grund other {
 replace `v' = 3 if `v'==1|`v'==2
 }

drop stufe*

save SH18to36_agg_ano, replace
 
log close
