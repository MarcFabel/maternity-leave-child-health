/*****************************************************************************************************
Proportion of women who are working full-time x months after child birth
**************************************************************************************************/


cd D:\Datenaustausch\KEM\Ludsteck\MaternityLeave\Data

capture log close
log using MLchildren\weights_LATE.log, replace

clear
clear matrix
set more off
set mem 10000m



/************************************************************************
1979 Reform
*************************************************************************/

use matall

***keep relevant observations
keep if (byear==1976&bmonth>=11)|byear==1977|byear==1978|byear==1979|(byear==1980&bmonth<=10)

****keep relevant variables
keep nmonth40 byear bmonth wagebef educ agebirth fullbef birthbula


/****************************************************************
Difference-in-Difference Estimates
***********************************************************/

gen cohort=7677 if (byear==1976&bmonth>=11)|(byear==1977&bmonth<=10)
replace cohort=7778 if (byear==1977&bmonth>=11)|(byear==1978&bmonth<=10)
replace cohort=7879 if (byear==1978&bmonth>=11)|(byear==1979&bmonth<=10)
replace cohort=7980 if (byear==1979&bmonth>=11)|(byear==1980&bmonth<=10)


gen treat=0
replace treat=1 if cohort==7879
gen after=0
replace after=1 if bmonth>=5&bmonth<=10

gen treatafter=treat*after

**control variables
gen lnwbef=ln(wagebef)
tab educ, gen(e)

gen Feb=0
replace Feb=1 if bmonth==2

gen AprilMay=0
replace AprilMay=1 if bmonth==4|bmonth==5

tab birthbula, gen(b)
gen time=bmonth-10 if bmonth>10
replace time=bmonth+2 if bmonth<=10
tab time, gen(t)


**months at home 3 years after childbirth
gen timehome=40-nmonth40

forvalues i=0/39{
gen home`i'=0
replace home`i'=1 if timehome<=`i'
}


compress


*******baseline specification: 6 months before and after, excluding May and April, CG: 7677, 7778, 7980
reg timehome treat after treatafter t1 t2 t3 t4 t9 t10 t11 t12 if (bmonth==11|bmonth==12|bmonth==1|bmonth==2|bmonth==3|bmonth==6|bmonth==7|bmonth==8|bmonth==9|bmonth==10)&(cohort==7677|cohort==7778|cohort==7879|cohort==7980), robust

forvalues i=0/39{
di "regression, month `i', birth month"
reg home`i' treat after treatafter t1 t2 t3 t4 t9 t10 t11 t12 if (bmonth==11|bmonth==12|bmonth==1|bmonth==2|bmonth==3|bmonth==6|bmonth==7|bmonth==8|bmonth==9|bmonth==10)&(cohort==7677|cohort==7778|cohort==7879|cohort==7980), robust
cap drop beta_home_`i'
gen beta_home_`i'=-_b[treatafter]
}


***test: coefficients should add up to first stage
egen total=rowtotal(beta_home_0-beta_home_39)
sum total


*compute weights
forvalues i=0/39{
gen weight`i'=beta_home_`i'/total
}

keep if _n==1
gen i=1
reshape long weight, i(i) j(timeathome)
keep weight timeathome

***Figure
label variable timeathome "time at home"

scatter weight timeathome, connect(l) scheme(s2mono) xlabel(2 6 12 18 24 30 36 40) title("Panel A: Expansion from 2 to 6 Months") saving(MLchildren\weights_1979, replace)
graph export MLchildren\weight_1979.eps, replace



/************************************************************************
1986 Reform
*************************************************************************/

clear
use matall

***keep Hesse, SH, and Bavaria
keep if birthbula==1|birthbula==6|birthbula==9

***keep relevant observations
keep if (byear==1985&bmonth>=7)|(byear==1986&bmonth<=6)|(byear==1986&bmonth>=7)|(byear==1987&bmonth<=6)|(byear==1988&bmonth>=7)|(byear==1989&bmonth<=6)

****keep relevant variables
keep nmonth40 byear bmonth wagebef educ agebirth fullbef birthbula


/****************************************************************
Difference-in-Difference Estimates
***********************************************************/

gen cohort=8586 if (byear==1985&bmonth>=9)|(byear==1986&bmonth<=6)
replace cohort=8687 if (byear==1986&bmonth>=9)|(byear==1987&bmonth<=6)
replace cohort=8889 if (byear==1988&bmonth>=9)|(byear==1989&bmonth<=6)

gen treat=0
replace treat=1 if cohort==8586

gen after=0
replace after=1 if bmonth<=6

gen treatafter=treat*after

***control variables
gen lnwbef=ln(wagebef)
tab educ, gen(e)
gen Feb=0
replace Feb=1 if bmonth==2
tab birthbula, gen(b)
compress

**share January and December birhts
gen JanDec=0
replace JanDec=1 if bmonth==12|bmonth==1

gen time=bmonth-6 if bmonth>6
replace time=bmonth+6 if bmonth<=6
tab time, gen(t)

**months at home 3 years after childbirth
gen timehome=40-nmonth40

forvalues i=0/39{
gen home`i'=0
replace home`i'=1 if timehome<=`i'
}


*****baseline specification: Septebmer to June, excluding January and December, CG: 1986/87 and 1988/89 

reg nmonth40 treat after treatafter t3 t4 t9 t10 t11 t12 if (bmonth==9|bmonth==10|bmonth==11|bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==8586|cohort==8687|cohort==8889), robust

forvalues i=0/39{
di "regression, month `i', birth month"
reg home`i' treat after treatafter t3 t4 t9 t10 t11 t12 if (bmonth==9|bmonth==10|bmonth==11|bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==8586|cohort==8687|cohort==8889), robust
cap drop beta_home_`i'
gen beta_home_`i'=-_b[treatafter]
}

***test: coefficients should add up to first stage
egen total=rowtotal(beta_home_0-beta_home_39)
sum total


*compute weights
forvalues i=0/39{
gen weight`i'=beta_home_`i'/total
}

keep if _n==1
gen i=1
reshape long weight, i(i) j(timeathome)
keep weight timeathome

***Figure
label variable timeathome "time at home"

scatter weight timeathome, xlabel(2 6 10 12 18 24 30 36 40) scheme(s2mono) connect(l) title("Panel B: Expansion from 6 to 10 Months") saving(MLchildren\weights_1986, replace)
graph export MLchildren\weight_1986.eps, replace




/************************************************************************
1992 Reform
*************************************************************************/

clear
use matall

***keep Hesse, SH, and Bavaria
keep if birthbula==1|birthbula==6|birthbula==9

***keep relevant observations
keep if (byear==1990&bmonth>=6)|byear==1991|(byear==1992&bmonth<=6)|(byear==1993&bmonth>=6)|byear==1994|(byear==1995&bmonth<=6)

****keep relevant variables
keep return nmonth40 byear bmonth wagebef educ agebirth fullbef birthbula

tab birthbula, gen(b)


/****************************************************************
Difference-in-Difference Estimates
***********************************************************/

gen cohort=9091 if (byear==1990&bmonth>=7)|(byear==1991&bmonth<=6)
replace cohort=9192 if (byear==1991&bmonth>=7)|(byear==1992&bmonth<=6)
replace cohort=9394 if (byear==1993&bmonth>=7)|(byear==1994&bmonth<=6)
replace cohort=9495 if (byear==1994&bmonth>=7)|(byear==1995&bmonth<=6)

gen treat=0
replace treat=1 if cohort==9192

gen after=0
replace after=1 if bmonth<=6

gen treatafter=treat*after
***control variables
gen lnwbef=ln(wagebef)
tab educ, gen(e)
gen Feb=0
replace Feb=1 if bmonth==2
compress

**share January and December birhts
gen JanDec=0
replace JanDec=1 if bmonth==12|bmonth==1

gen time=bmonth-6 if bmonth>6
replace time=bmonth+6 if bmonth<=6
tab time, gen(t)

**months at home 3 years after childbirth
gen timehome=40-nmonth40

forvalues i=0/39{
gen home`i'=0
replace home`i'=1 if timehome<=`i'
}

********baseline specification: July to June, excluding January and December, CG: 1990/91, 93/94, 94/95
reg timehome treat after treatafter t1 t2 t3 t4 t9 t10 t11 t12 if (bmonth==7|bmonth==8|bmonth==9|bmonth==10|bmonth==11|bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==9091|cohort==9192|cohort==9394|cohort==9495), robust
forvalues i=0/39{
di "regressions months at home, month `i', birth month controls"
reg home`i' treat after treatafter t1 t2 t3 t4 t9 t10 t11 t12 if (bmonth==7|bmonth==8|bmonth==9|bmonth==10|bmonth==11|bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==9091|cohort==9192|cohort==9394|cohort==9495), robust
cap drop beta_home_`i'
gen beta_home_`i'=-_b[treatafter]
}


***test: coefficients should add up to first stage
egen total=rowtotal(beta_home_0-beta_home_39)
sum total


*compute weights
forvalues i=0/39{
gen weight`i'=beta_home_`i'/total
}

keep if _n==1
gen i=1
reshape long weight, i(i) j(timeathome)
keep weight timeathome

***Figure
label variable timeathome "time at home"

scatter weight timeathome, xlabel(2 6 12 18 24 30 36 40) scheme(s2mono) connect(l) title("Panel C: Expansion from 18 to 36 Months") saving(MLchildren\weights_1992, replace)
graph export MLchildren\weight_1992.eps, replace



log close