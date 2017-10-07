/*****************************************************************************************************
Earnings x months after child birth
**************************************************************************************************/


cd D:\Datenaustausch\KEM\Ludsteck\MaternityLeave\Data

capture log close
log using Mlchildren\Estimates_earnings_diffindiff.log, replace

clear
clear matrix
set more off
set mem 10000m



/************************************************************************
1979 Reform
*************************************************************************/

use matall, clear

***keep relevant observations
keep if (byear==1976&bmonth>=11)|byear==1977|byear==1978|byear==1979|(byear==1980&bmonth<=10)

****keep relevant variables
keep w1-w65 byear bmonth wagebef educ agebirth fullbef wage1-wage65


****compute cumulative earnings i months after childbirth
****note: wages are daily wages. Multiply by 30 to get monthly wages
gen earnings0=30*wagebef
gen earnings1=earnings0+30*wagebef

***monthly wages
forvalues i=2/65{
gen help`i'=wage`i'*30
}

**deflate maternity benefit
gen MB=0 if byear<=1978|(byear==1979&bmonth<=4)
replace MB=750/0.63 if byear==1979&bmonth>=5
replace MB=750/0.664 if byear==1980
replace MB=750/0.706 if byear==1981
replace MB=750/0.743 if byear==1982
replace MB=750/0.767 if byear==1983
replace MB=750/0.786 if byear==1984
replace MB=750/0.802 if byear==1985
replace MB=600/0.801 if byear==1986
replace MB=600/0.803 if byear==1987
replace MB=600/0.813 if byear==1988
replace MB=600/0.836 if byear==1989
replace MB=600/0.858 if byear==1990
replace MB=600/0.890 if byear==1991
replace MB=600/0.925 if byear==1992
replace MB=600/0.958 if byear==1993
replace MB=600/0.984 if byear==1994
replace MB=600 if byear==1995

***effective monthly wage, not cumulative, months 2 to 5
forvalues i=2/5{
*after April 1979
gen effmonthly`i'=help`i' if (byear>1979|(byear==1979&bmonth>=5))&w`i'==1
replace effmonthly`i'=MB if (byear>1979|(byear==1979&bmonth>=5))&w`i'==0
*before April 1979
replace effmonthly`i'=help`i' if byear<=1978|(byear==1979&bmonth<=4)
}

***effective monthly wage, not cumulative, months 6 to 65
forvalues i=6/65{
gen effmonthly`i'=help`i' 
}

****cumulative
forvalues i=2/65{
egen earnings`i'=rowtotal(effmonthly2-effmonthly`i') 
**add income from first two months
replace earnings`i'=earnings`i'+earnings1 
drop help`i'
}



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

gen time=bmonth-10 if bmonth>10
replace time=bmonth+2 if bmonth<=10
tab time, gen(t)

compress

*********************************
*cumulative earnings
********************************


*******baseline specification: 6 months before and after, excluding May and April, CG: 7677, 7778, 7980
forvalues i=2/65{
sum earnings`i' if (bmonth==11|bmonth==12|bmonth==1|bmonth==2|bmonth==3)&(cohort==7879)
di "regression, month `i', birth months"
reg earnings`i' t1 t2 t3 t4 t9 t10 t11 t12 treat after treatafter  if (bmonth==11|bmonth==12|bmonth==1|bmonth==2|bmonth==3|bmonth==6|bmonth==7|bmonth==8|bmonth==9|bmonth==10)&(cohort==7677|cohort==7778|cohort==7879|cohort==7980), robust
}

********Robustness Checks
*******1 month before and after
forvalues i=2/65{
sum earnings`i' if (bmonth==4)&(cohort==7879)
di "regression, month `i', no controls"
reg earnings`i' treat after treatafter if (bmonth==4|bmonth==5)&(cohort==7677|cohort==7778|cohort==7879|cohort==7980), robust
}

*******2 months before and after
**share April/May births
reg AprilMay if (bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==7677|cohort==7778|cohort==7879|cohort==7980)
forvalues i=2/65{
di "regression, month `i', birth months"
reg earnings`i' treat after treatafter t5 t8 if (bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==7677|cohort==7778|cohort==7879|cohort==7980), robust
}

*******4 months before, 2 months after
**share April/May births
reg AprilMay if (bmonth==1|bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==7677|cohort==7778|cohort==7879|cohort==7980)
forvalues i=2/65{
di "regression, month `i', birth months"
reg earnings`i' treat after treatafter t3 t4 t5 t8 if (bmonth==1|bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==7677|cohort==7778|cohort==7879|cohort==7980), robust
}

*******4 months before, 2 months after, excluding April and May
forvalues i=2/65{
di "regression, month `i', birth month"
reg earnings`i' treat after treatafter t3 t4  if (bmonth==1|bmonth==2|bmonth==3|bmonth==6)&(cohort==7677|cohort==7778|cohort==7879|cohort==7980), robust
}

*******6 months before, 6 months after
**share April/May births
reg AprilMay if (bmonth==11|bmonth==12|bmonth==1|bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6|bmonth==7|bmonth==8|bmonth==9|bmonth==10)&(cohort==7677|cohort==7778|cohort==7879|cohort==7980)
forvalues i=2/65{
di "regression, month `i', birth month"
reg earnings`i' treat after treatafter t1 t2 t3 t4 t5 t8 t9 t10 t11 t12 if ((bmonth==11|bmonth==12|bmonth==1|bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6|bmonth==7|bmonth==8|bmonth==9|bmonth==10))&(cohort==7677|cohort==7778|cohort==7879|cohort==7980), robust
}


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
keep w1-w65 byear bmonth wagebef educ agebirth fullbef wage1-wage65

****compute cumulative earnings i months after childbirth
****note: wages are daily wages. Multiply by 30 to get monthly wages
gen earnings0=30*wagebef
gen earnings1=earnings0+30*wagebef


**deflate maternity benefit
gen MB=0 if byear<=1978|(byear==1979&bmonth<=4)
replace MB=750/0.63 if byear==1979&bmonth>=5
replace MB=750/0.664 if byear==1980
replace MB=750/0.706 if byear==1981
replace MB=750/0.743 if byear==1982
replace MB=750/0.767 if byear==1983
replace MB=750/0.786 if byear==1984
replace MB=750/0.802 if byear==1985
replace MB=600/0.801 if byear==1986
replace MB=600/0.803 if byear==1987
replace MB=600/0.813 if byear==1988
replace MB=600/0.836 if byear==1989
replace MB=600/0.858 if byear==1990
replace MB=600/0.890 if byear==1991
replace MB=600/0.925 if byear==1992
replace MB=600/0.958 if byear==1993
replace MB=600/0.984 if byear==1994
replace MB=600 if byear==1995


**monthly wages, from daily wages
forvalues i=2/65{
gen help`i'=wage`i'*30
}

***effective monthly wage, not cumulative, months 2 to 5
forvalues i=2/5{
gen effmonthly`i'=help`i' if w`i'==1
replace effmonthly`i'=MB if w`i'==0
}

***effective monthly wage, not cumulative, months 6 to 9
forvalues i=6/9{
*1985
gen effmonthly`i'=help`i' if byear<=1985
*after 1986
replace effmonthly`i'=help`i' if byear>1985&w`i'==1
replace effmonthly`i'=MB if byear>1985&w`i'==0
}


***effective monthly wage, not cumulative, months 6 to 65
forvalues i=10/65{
gen effmonthly`i'=help`i' 
}

****cumulative
forvalues i=2/65{
egen earnings`i'=rowtotal(effmonthly2-effmonthly`i') 
**add income from first two months
replace earnings`i'=earnings`i'+earnings1 
drop help`i'
}


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
compress

**share January and December birhts
gen JanDec=0
replace JanDec=1 if bmonth==12|bmonth==1

gen time=bmonth-6 if bmonth>6
replace time=bmonth+6 if bmonth<=6
tab time, gen(t)

***************************************************
*cumulative earnings
********************************************
*****baseline specification: Septebmer to June, excluding January and December, CG: 1986/87 and 1988/89 
forvalues i=2/65 {
di "cumulative, treated cohort, before, month `i'"
sum earnings`i' if cohort==8586&after==0&bmonth!=12
di "regression, month `i', birth month"
reg earnings`i' treat after treatafter t3 t4 t9 t10 t11 t12 if (bmonth==9|bmonth==10|bmonth==11|bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==8586|cohort==8687|cohort==8889), robust
}

****robustness checks
forvalues i=2/65 {
di "regression, month `i'"
reg earnings`i' treat after treatafter if (bmonth==12|bmonth==1)&(cohort==8586|cohort==8687|cohort==8889), robust
}


****October to March, CG: 1986/87 and 1988/89 
*share January and December  births
reg JanDec if (bmonth==10|bmonth==11|bmonth==12|bmonth==1|bmonth==2|bmonth==3)&(cohort==8586|cohort==8687|cohort==8889)
forvalues i=2/65 {
di "regression, month `i', birth month"
reg earnings`i' treat after treatafter t4 t5 t8 t9 if (bmonth==10|bmonth==11|bmonth==12|bmonth==1|bmonth==2|bmonth==3)&(cohort==8586|cohort==8687|cohort==8889), robust
}


****October to March, excluding January and December, CG: 1986/87 and 1988/89 
forvalues i=2/65 {
di "regression, month `i', birth month"
reg earnings`i' treat after treatafter t4 t9 if (bmonth==10|bmonth==11|bmonth==2|bmonth==3)&(cohort==8586|cohort==8687|cohort==8889), robust
}

****September to April, CG: 1986/87 and 1988/89 
*share January and December  births
reg JanDec if (bmonth==9|bmonth==10|bmonth==11|bmonth==12|bmonth==1|bmonth==2|bmonth==3|bmonth==4)&(cohort==8586|cohort==8687|cohort==8889)
forvalues i=2/65 {
di "regression, month `i', birth month"
reg earnings`i' treat after treatafter t3 t4 t5 t8 t9 t10 if (bmonth==9|bmonth==10|bmonth==11|bmonth==12|bmonth==1|bmonth==2|bmonth==3|bmonth==4)&(cohort==8586|cohort==8687|cohort==8889), robust
}

****September to June, CG: 1986/87 and 1988/89 
*share January and December  births
reg JanDec if (bmonth==9|bmonth==10|bmonth==11|bmonth==12|bmonth==1|bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==8586|cohort==8687|cohort==8889)
forvalues i=2/65 {
di "regression, month `i', birth month"
reg earnings`i' treat after treatafter t3 t4 t5 t8 t9 t10 t11 t12 if (bmonth==9|bmonth==10|bmonth==11|bmonth==12|bmonth==1|bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==8586|cohort==8687|cohort==8889), robust
}


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
keep w1-w65 byear bmonth wagebef educ agebirth fullbef wage1-wage65

****compute cumulative earnings i months after childbirth
****note: wages are daily wages. Multiply by 30 to get monthly wages
gen earnings0=30*wagebef
gen earnings1=earnings0+30*wagebef

**deflate maternity benefit
gen MB=0 if byear<=1978|(byear==1979&bmonth<=4)
replace MB=750/0.63 if byear==1979&bmonth>=5
replace MB=750/0.664 if byear==1980
replace MB=750/0.706 if byear==1981
replace MB=750/0.743 if byear==1982
replace MB=750/0.767 if byear==1983
replace MB=750/0.786 if byear==1984
replace MB=750/0.802 if byear==1985
replace MB=600/0.801 if byear==1986
replace MB=600/0.803 if byear==1987
replace MB=600/0.813 if byear==1988
replace MB=600/0.836 if byear==1989
replace MB=600/0.858 if byear==1990
replace MB=600/0.890 if byear==1991
replace MB=600/0.925 if byear==1992
replace MB=600/0.958 if byear==1993
replace MB=600/0.984 if byear==1994
replace MB=600 if byear==1995


**monthly wages, from daily wages
forvalues i=2/65{
gen help`i'=wage`i'*30
}

***effective monthly wage, not cumulative, months 2 to 17
forvalues i=2/17{
*1985
gen effmonthly`i'=help`i' if w`i'==1
replace effmonthly`i'=MB if w`i'==0
}

***effective monthly wage, not cumulative, months 18 to 23
forvalues i=18/23{
*1991
gen effmonthly`i'=help`i' if byear<=1991
*1992
replace effmonthly`i'=help`i' if byear==1992
*1993 and later
replace effmonthly`i'=MB if byear>1992&w`i'==0
replace effmonthly`i'=help`i' if byear>1992&w`i'==1
}

***effective monthly wage, not cumulative, from month 24 to 65
forvalues i=24/65{
gen effmonthly`i'=help`i' 
}

****cumulative
forvalues i=2/65{
egen earnings`i'=rowtotal(effmonthly2-effmonthly`i') 
**add income from first two months
replace earnings`i'=earnings`i'+earnings1 
drop help`i'
}



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

********************************************
*cumulative earnings
***********************************

********baseline specification: July to June, excluding January and December, CG: 1990/91, 93/94, 94/95
forvalues i=2/65{
di "share working, treated cohort, before, month `i'"
sum earnings`i' if cohort==9192&after==0&bmonth!=12
di "regression, month `i', birth month"
reg earnings`i' treat after treatafter t1 t2 t3 t4 t9 t10 t11 t12 if (bmonth==7|bmonth==8|bmonth==9|bmonth==10|bmonth==11|bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==9091|cohort==9192|cohort==9394|cohort==9495), robust
}


*****************rboustness checks
***********January to December, CG: 1990/91, 93/94, 94/95
forvalues i=2/65{
di "regression, month `i', no controls"
reg earnings`i' treat after treatafter if (bmonth==1|bmonth==12)&(cohort==9091|cohort==9192|cohort==9394|cohort==9495), robust
}

***********Octover to March, CG: 1990/91, 93/94, 94/95
**share December/January births
reg JanDec if (bmonth==10|bmonth==11|bmonth==12|bmonth==1|bmonth==2|bmonth==3)&(cohort==9091|cohort==9192|cohort==9394|cohort==9495)
forvalues i=2/65{
di "regression, month `i', birth month"
reg earnings`i' treat after treatafter t4 t5 t8 t9 if (bmonth==10|bmonth==11|bmonth==12|bmonth==1|bmonth==2|bmonth==3)&(cohort==9091|cohort==9192|cohort==9394|cohort==9495), robust
}


***********Octover to March, excluding January and December, CG: 1990/91, 93/94, 94/95
forvalues i=2/65{
di "regression, month `i', birth month"
reg earnings`i' treat after treatafter t4 t9 if (bmonth==10|bmonth==11|bmonth==2|bmonth==3)&(cohort==9091|cohort==9192|cohort==9394|cohort==9495), robust
}


***********September to April, CG: 1990/91, 93/94, 94/95
**share December/January births
reg JanDec if (bmonth==9|bmonth==10|bmonth==11|bmonth==12|bmonth==1|bmonth==2|bmonth==3|bmonth==4)&(cohort==9091|cohort==9192|cohort==9394|cohort==9495)
forvalues i=2/65{
di "regression, month `i', birth month"
reg earnings`i' treat after treatafter t3 t4 t5 t8 t9 t10 if (bmonth==9|bmonth==10|bmonth==11|bmonth==12|bmonth==1|bmonth==2|bmonth==3|bmonth==4)&(cohort==9091|cohort==9192|cohort==9394|cohort==9495), robust
}


***********July  to June, CG: 1990/91, 93/94, 94/95
**share December/January births
reg JanDec if (cohort==9091|cohort==9192|cohort==9394|cohort==9495)
forvalues i=2/65{
di "regression, month `i', birth month"
reg earnings`i' treat after treatafter t1 t2 t3 t4 t5 t8 t9 t10 t11 t12 if (bmonth==7|bmonth==8|bmonth==9|bmonth==10|bmonth==11|bmonth==12|bmonth==1|bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==9091|cohort==9192|cohort==9394|cohort==9495), robust
}



log close
