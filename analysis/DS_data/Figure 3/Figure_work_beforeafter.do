/*****************************************************************************************************
Proportion of women who have returned x months after child birth
**************************************************************************************************/


cd D:\Datenaustausch\KEM\Ludsteck\MaternityLeave\Data

capture log close
log using Mlchildren\Figure_work_beforeafter.log, replace

clear
clear matrix
set more off
set mem 10000m



/************************************************************************
1979 Reform
*************************************************************************/

use matall, clear

***keep relevant variables
keep byear bmonth return birthbula

***keep relevant observations
keep if (byear==1978&bmonth>=11)|(byear==1979&bmonth<=10)

***drop April and May
drop if bmonth==4|bmonth==5

gen after=0
replace after=1 if byear==1979&bmonth>=5

****indicator variables: returned by t months after childbirth
forvalues r=0/60{
gen r`r'=0
replace r`r'=1 if return<=`r'
}

preserve
keep if after==0
collapse r0-r60
gen i=1
reshape long r, i(i) j(month)
rename r before
sort month
save helpbefore, replace
restore
keep if after==1
collapse r0-r60
gen i=1
reshape long r, i(i) j(month)
rename r after
sort month
merge month using helpbefore
tab _merge
drop _merge

replace after=1-after
replace before=1-before

label variable month "Months Since Childbirth"
drop if month>40

#delimit;
scatter before after month, c(l l) symbol(O D) scheme(s2mono)
xline(1.5 5.5) ytitle("Share at Home") ylabel(0.3(0.1)1)
title("Panel A: Expansion in Leave Coverage from 2 to 6 Months")
subtitle("May 1979")
xlabel(2 6 10 18 24 36)
saving(MLchildren\work_79_beforeafter, replace);
#delimit cr;
graph export MLchildren\work_79_beforeafter.eps, replace


/************************************************************************
1986 Reform
*************************************************************************/

clear
use matall


***keep relevant variables
keep byear bmonth return birthbula

***keep Hesse, SH, and Bavaria
keep if birthbula==1|birthbula==6|birthbula==9

***keep relevant observations
keep if (byear==1985&bmonth>=9)|(byear==1986&bmonth<=6)


***drop January and December
drop if bmonth==12|bmonth==1

gen after=0
replace after=1 if byear==1986&bmonth<=6

****indicator variables: returned by t months after childbirth
forvalues r=0/60{
gen r`r'=0
replace r`r'=1 if return<=`r'
}

preserve
keep if after==0
collapse r0-r60
gen i=1
reshape long r, i(i) j(month)
rename r before
sort month
save helpbefore, replace
restore
keep if after==1
collapse r0-r60
gen i=1
reshape long r, i(i) j(month)
rename r after
sort month
merge month using helpbefore
tab _merge
drop _merge

replace after=1-after
replace before=1-before

label variable month "Months Since Childbirth"

drop if month>40

#delimit;
scatter before after month, c(l l) symbol(O D) scheme(s2mono)
xline(5.5 9.5) ytitle("Share at Home") ylabel(0.3(0.1)1)
title("Panel B: Expansion in Leave Coverage from 6 to 10 Months")
subtitle("January 1986")
xlabel(2 6 10 18 24 36)
saving(MLchildren\work_86_beforeafter, replace);
#delimit cr;
graph export MLchildren\work_86_beforeafter.eps, replace



/************************************************************************
1992 Reform
*************************************************************************/

clear
use matall


***keep relevant variables
keep byear bmonth return birthbula

***keep Hesse, SH, and Bavaria
keep if birthbula==1|birthbula==6|birthbula==9

***keep relevant observations
keep if (byear==1991&bmonth>=6)|(byear==1992&bmonth<=6)

***drop January and December
drop if bmonth==12|bmonth==1

gen after=0
replace after=1 if byear==1992&bmonth<=6

****indicator variables: returned by t months after childbirth
forvalues r=0/60{
gen r`r'=0
replace r`r'=1 if return<=`r'
}

preserve
keep if after==0
collapse r0-r60
gen i=1
reshape long r, i(i) j(month)
rename r before
sort month
save helpbefore, replace
restore
keep if after==1
collapse r0-r60
gen i=1
reshape long r, i(i) j(month)
rename r after
sort month
merge month using helpbefore
tab _merge
drop _merge

replace after=1-after
replace before=1-before

label variable month "Months Since Childbirth"

drop if month>40

#delimit;
scatter before after month, c(l l) symbol(O D) scheme(s2mono)
xline(17.5 35.5) xline(23.5, lpattern(dash)) ytitle("Share at Home") ylabel(0.4(0.1)1)
title("Panel C: Expansion in Leave Coverage from 18 to 36 Months")
subtitle("January 1992")
 xlabel(2 6 10 18 24 36) 
saving(MLchildren\work_92_beforeafter, replace);
#delimit cr;
graph export MLchildren\work_92_beforeafter.eps, replace

erase helpbefore.dta

log close
