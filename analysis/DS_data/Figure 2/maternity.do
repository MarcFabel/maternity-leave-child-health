****************************************************
*How many go on maternity leave? Who goes on maternity leave?
**********************************************************
set more off
clear
clear matrix
set mem 2000m
***********1) Select all women who gave birth between 1.1. 1976 and 31.12. 1995. Use birth date of child


use blhvdr

gen Jan11976=mdy(1,1,1976)
gen Dec311995=mdy(12,31,1995)

gen child=0
forvalues i=1/10 {
replace child=`i' if Jan11976<=kgeb`i'&kgeb`i'<=Dec311995
compress
}

*drop mothers who did not give birth within this time period 
drop if child==0 

*******2) for each child, search for a nearby btyp-variable. Rule: It has to start 3 months before or after birth
rename mybt btyp

*Note: variable is only defined birthday of ith cihld falls between 1.1. 1976 and 31.12. 1995
forvalues i=1/10{
gen leave`i'=0 if Jan11976<=kgeb`i'&kgeb`i'<=Dec311995
replace leave`i'=1 if (btyp>=2&btyp<=6)&((adat>=kgeb`i'-90&adat<=kgeb`i'+90)|(edat>=kgeb`i'-90&edat<=kgeb`i'+90))
sort id leave`i'
qui by id: replace leave`i'=leave`i'[_N]
gen leaverobust`i'=0 if Jan11976<=kgeb1&kgeb`i'<=Dec311995
replace leaverobust`i'=1 if (btyp>=2&btyp<=6)&((adat>=kgeb`i'-180&adat<=kgeb`i'+180)|(edat>=kgeb`i'-180&edat<=kgeb`i'+180))
sort id leaverobust`i'
qui by id: replace leaverobust`i'=leaverobust`i'[_N]
}

********3) create new variables: education (final), east, foreigner, age at birth, working 9 months prior to birth

****indicator: east, defined by first spell
sort id adat
gen east=0
replace east=1 if (ost==0|ao_kreis>=11200)&id!=id[_n-1]
sort id east
qui by id: replace east=east[_N]
label variable east "East German"
drop ost

****indicator: foreign, defined by first spell
sort id adat
gen f=0
replace f=1 if foreign==1&id!=id[_n-1]
sort id f
qui by id: replace f=f[_N]
drop foreign
rename f foreign
label variable foreign "not German citizen"

*****education (final, does not change for the same individual)

/*uni: at least 3/10 of valid spells 5 or 6, educ=3
app: at least 3/10 of valid spells 2 or 4, educ=2
unskilled: otherwise, educ=1 
missing: always 7 or 9*/

replace bild=9 if bild==-5

/*number of valid firm spells*/
gen number=0
replace number=1 if btyp>0&btyp<7
sort id ajahr amonat atag
egen maxnumber=sum(number), by(id)
drop number

/*number of spells where education equal to 5 or 6*/
gen nuni=0
replace nuni=1 if (bild==5|bild==6)&btyp!=7
sort id ajahr amonat atag
egen maxnuni=sum(nuni), by(id)
gen propuni=maxnuni/maxnumber
drop maxnuni

/*number of spells where education equal to 2 or 4*/
gen napp=0
replace napp=1 if (bild==2|bild==4|stib==0)&btyp!=7
sort id ajahr amonat atag
egen maxnapp=sum(napp), by(id)
gen propapp=maxnapp/maxnumber
drop maxnapp

/*indicator if bild is always missing*/
gen bild1=bild
replace bild1=-1 if bild>=7
sort id ajahr amonat atag
egen maxbild=max(bild1), by(id)

gen educ=3 if propuni>0.3
replace educ=2 if propapp>=0.3&propuni<=0.3
replace educ=1 if propuni<=0.3&propapp<=0.3&maxbild>0
tab educ, miss

*assign workers with missing education to unskilled
replace educ=1 if educ==.

label variable educ "final education"
drop maxbild bild1 propuni propapp maxnumber napp nuni
compress

****************age at each birth

replace gebmon=. if gebmon==0
replace gebjahr=gebjahr+1900
forvalues i=1/10{
gen kmon`i'=month(kgeb`i')
gen kyear`i'=year(kgeb`i')
gen agebirth`i'=(kyear`i'-gebjahr)*12+kmon`i'-gebmon
replace agebirth`i'=agebirth`i'/12
compress
}


***************employed (full-time or part-time) prior to childbirth

forvalues i=1/10{
gen work`i'=0 if Jan11976<=kgeb`i'&kgeb`i'<=Dec311995
replace work`i'=1 if btyp==1&adat<=kgeb`i'-270&kgeb`i'-270<=edat
sort id work`i'
qui by id: replace work`i'=work`i'[_N]
}


****************Investigate mothers who are employed 9 months prior to childbirth but do not go on leave

*****claimed unemplyment benefits prior to childbirth
forvalues i=1/10 {
gen unemp`i'=0 if work`i'==1&leaverobust`i'==0
replace unemp`i'=1 if work`i'==1&leaverobust`i'==0&btyp==7&(adat<=kgeb`i'&adat<=kgeb`i'-270)
sort id unemp`i'
qui by id: replace unemp`i'=unemp`i'[_N]
}

*****was working 2 months before AND after childbirth
forvalues i=1/10 {
gen always`i'=0 if work`i'==1&leaverobust`i'==0
replace always`i'=1 if work`i'==1&leaverobust`i'==0&(btyp==1&adat<=kgeb`i'-60&kgeb`i'-60<=edat)&(btyp==1&adat<=kgeb`i'+90&kgeb`i'+90<=edat)&unemp`i'==0
sort id always`i'
qui by id: replace always`i'=always`i'[_N]
}

*****was working 2 months before childbirth
forvalues i=1/10 {
gen workbef2`i'=0 if work`i'==1&leaverobust`i'==0
replace workbef2`i'=1 if work`i'==1&leaverobust`i'==0&(btyp==1&adat<=kgeb`i'-60&kgeb`i'-60<=edat)
sort id workbef2`i'
qui by id: replace workbef2`i'=workbef2`i'[_N]
}

*****did not return within 5 years and was NOT working 2 months prior to childbirth

***first: years mother stayed at home
forvalues i=1/10 {
gen help`i'=. if Jan11976<=kgeb`i'&kgeb`i'<=Dec311995
replace help`i'=adat if btyp==1&adat>=kgeb`i'&(pers_gr==101|pers_gr==102)
sort id 
egen return`i'=min(help`i'), by(id)
gen time`i'=(return`i'-kgeb`i')/365
}

forvalues i=1/10 {
gen never`i'=0 if work`i'==1&leaverobust`i'==0
replace never`i'=1 if work`i'==1&leaverobust`i'==0&unemp`i'==0&time`i'>5&workbef2`i'==0
sort id never`i'
qui by id: replace never`i'=never`i'[_N]
drop return`i' time`i' help`i' workbef2`i'
}


**********state at childbirth
**fill in ao_kreis if unemplyed or missing
sort id adat
replace ao_kreis=. if ao_kreis<0
replace ao_kreis=ao_kreis[_n-1] if id==id[_n-1]&ao_kreis==.
gsort id -adat
replace ao_kreis=ao_kreis[_n-1] if id==id[_n-1]&ao_kreis==.
gen bula=int(ao_kreis/1000)

forvalues i=1/10{
sort id adat
cap drop help
gen help=0 if kgeb`i'!=.
replace help=1 if kgeb`i'>=adat&kgeb`i'!=.
gen bulakid`i'=0
replace bulakid`i'=bula if id==id[_n-1]&help==1&help[_n+1]==0
replace bulakid`i'=bula if id!=id[_n+1]&help==1 /*these mothers do not return*/
sort id bulakid`i'
qui by id: replace bulakid`i'=bulakid`i'[_N]


***if bulakid=0: mothers enter labor market after childbirth. Use first spell for these mothers
sort id adat
replace bulakid`i'=bula if bulakid`i'==0&id!=id[_n-1]
sort id bulakid`i'
qui by id: replace bulakid`i'=bulakid`i'[_N]
replace bulakid`i'=. if kgeb`i'==.
}

drop bula help

********************************4) Reshape data set: wirte births below each other
sort id adat
keep if id!=id[_n-1] 
keep id kgeb* kyear* leave* work* agebirth* unemp* always* never* foreign east educ bulakid*

reshape long kgeb kyear leave leaverobust work unemp always never agebirth bulakid, i(id) j(nchild)
drop if kgeb==.
save maternityleave, replace

**********************5) Analysis: Who many women go on leave? Who goes on leave?
cap log close
log using maternity.log, replace
clear
use maternityleave

****Main group: West, Germans
tab kyear if east==0&foreign==0&kyear>=1986&kyear<=1995, sum(leave)
tab kyear if east==0&foreign==0&kyear>=1987&kyear<=1994, sum(leaverobust)

****Foreigners
tab east if foreign==1
tab kyear if foreign==1&kyear>=1987&kyear<=1994, sum(leave)
tab kyear if foreign==1&kyear>=1987&kyear<=1994, sum(leaverobust)

****East, Germans
tab kyear if east==1&foreign==0&kyear>=1993&kyear<=1994, sum(leave)
tab kyear if east==1&foreign==0&kyear>=1993&kyear<=1994, sum(leaverobust)


******************maternity leave and number of child
gen nkid=nchild
replace nkid=4 if nchild>=4
****Main group: West, Germans
sort nkid
by nkid: tab kyear if east==0&foreign==0&kyear>=1987&kyear<=1994, sum(leave)
by nkid: tab kyear if east==0&foreign==0&kyear>=1987&kyear<=1994, sum(leaverobust)

****Foreigners
sort nkid
by nkid: tab kyear if east==0&foreign==1&kyear>=1987&kyear<=1994, sum(leave)
by nkid: tab kyear if east==0&foreign==1&kyear>=1987&kyear<=1994, sum(leaverobust)

****cannot be done for East Germany

*******************Maternity Leave and Education
****Main group: West, Germans
tab kyear educ if east==0&foreign==0&kyear>=1987&kyear<=1994, sum(leave)
tab kyear educ if east==0&foreign==0&kyear>=1987&kyear<=1994, sum(leaverobust)
tab kyear educ if nchild==1&east==0&foreign==0&kyear>=1987&kyear<=1994, sum(leave)
tab kyear educ if nchild==1&east==0&foreign==0&kyear>=1987&kyear<=1994, sum(leaverobust)


****Foreigners
tab kyear educ if east==0&foreign==1&kyear>=1987&kyear<=1994, sum(leave)
tab kyear educ if east==0&foreign==1&kyear>=1987&kyear<=1994, sum(leaverobust)
tab kyear educ if east==0&nchild==1&foreign==1&kyear>=1987&kyear<=1994, sum(leave)
tab kyear educ if east==0&nchild==1&foreign==1&kyear>=1987&kyear<=1994, sum(leaverobust)


****East, Germans
tab kyear educ if east==1&foreign==0&kyear>=1993&kyear<=1994, sum(leave)
tab kyear educ if east==1&foreign==0&kyear>=1993&kyear<=1994, sum(leaverobust)

*******************Maternity Leave and Age of Birth
gen agebirth_agg=1 if agebirth>=14&agebirth<=24
replace agebirth_agg=2 if agebirth>24&agebirth<=31
replace agebirth_agg=3 if agebirth>31

****Main group: West, Germans
tab kyear agebirth_agg if east==0&foreign==0&kyear>=1987&kyear<=1994, sum(leave)
tab kyear agebirth_agg if east==0&foreign==0&kyear>=1987&kyear<=1994, sum(leaverobust)
tab kyear agebirth_agg if nchild==1&east==0&foreign==0&kyear>=1987&kyear<=1994, sum(leave)
tab kyear agebirth_agg if nchild==1&east==0&foreign==0&kyear>=1987&kyear<=1994, sum(leaverobust)

****Foreigners
tab kyear agebirth_agg if east==0&foreign==1&kyear>=1987&kyear<=1994, sum(leave)
tab kyear agebirth_agg if east==0&foreign==1&kyear>=1987&kyear<=1994, sum(leaverobust)
tab kyear agebirth_agg if east==0&nchild==1&foreign==1&kyear>=1987&kyear<=1994, sum(leave)
tab kyear agebirth_agg if east==0&nchild==1&foreign==1&kyear>=1987&kyear<=1994, sum(leaverobust)

****East, Germans
tab kyear agebirth_agg if east==1&foreign==0&kyear>=1993&kyear<=1994, sum(leave)
tab kyear agebirth_agg if east==1&foreign==0&kyear>=1993&kyear<=1994, sum(leaverobust)

*******************Maternity Leave and Working Prior to Child Birth
****Main group: West, Germans
tab kyear work if east==0&foreign==0&kyear>=1987&kyear<=1994, sum(leave)
tab kyear work if east==0&foreign==0&kyear>=1987&kyear<=1994, sum(leaverobust)
tab kyear work if nchild==1&east==0&foreign==0&kyear>=1987&kyear<=1994, sum(leave)
tab kyear work if nchild==1&east==0&foreign==0&kyear>=1987&kyear<=1994, sum(leaverobust)

****Foreigners
tab kyear work if east==0&foreign==1&kyear>=1987&kyear<=1994, sum(leave)
tab kyear work if east==0&foreign==1&kyear>=1987&kyear<=1994, sum(leaverobust)
tab kyear work if nchild==1&east==0&foreign==1&kyear>=1987&kyear<=1994, sum(leave)
tab kyear work if nchild==1&east==0&foreign==1&kyear>=1987&kyear<=1994, sum(leaverobust)

****East, Germans
tab kyear work if east==1&foreign==0&kyear>=1993&kyear<=1994, sum(leave)
tab kyear work if east==1&foreign==0&kyear>=1993&kyear<=1994, sum(leaverobust)


******************More details on mothers who work 9 months prior to childbirth,
*but do not go on leave

******West, Germans
tab unemp if work==1&leaverobust==0&east==0&foreign==0
tab always if work==1&leaverobust==0&east==0&foreign==0
tab never if work==1&leaverobust==0&east==0&foreign==0

******East, Germans
tab unemp if work==1&leaverobust==0&east==1&foreign==0
tab always if work==1&leaverobust==0&east==1&foreign==0
tab never if work==1&leaverobust==0&east==1&foreign==0

******foreigners
tab unemp if work==1&leaverobust==0&east==0&foreign==1
tab always if work==1&leaverobust==0&east==0&foreign==1
tab never if work==1&leaverobust==0&east==0&foreign==1


*************Some probit regressions
drop if kyear<1986
drop if kyear>1995
replace leaverobust=. if east==1&kyear<1992
gen agebirth2=agebirth^2

*****all
xi: dprobit leaverobust east foreign agebirth agebirth2 i.educ i.kyear if kyear>=1987&kyear<=1994, robust

****West, Germans
xi: dprobit leaverobust agebirth agebirth2 i.educ i.kyear i.nkid if east==0&foreign==0&kyear>=1987&kyear<=1994, robust
xi: dprobit leaverobust agebirth agebirth2 i.educ i.kyear if east==0&foreign==0&kyear>=1987&kyear<=1994&nchild==1, robust

****East, Germans
xi: dprobit leaverobust agebirth agebirth2 i.educ i.kyear if east==1&foreign==0&kyear>=1993&kyear<=1994, robust

****foreigners
xi: dprobit leaverobust agebirth agebirth2 i.educ i.kyear i.nkid if foreign==1&kyear>=1987&kyear<=1994&east==0, robust
xi: dprobit leaverobust agebirth agebirth2 i.educ i.kyear if foreign==1&kyear>=1987&kyear<=1994&nchild==1&east==0, robust

cap log close
