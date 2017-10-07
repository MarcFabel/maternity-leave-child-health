*****************************************************
*Difference in Difference Estimates, 1992 reform, separate effects by BL
****************************************************

cd U:\MLchildren\MLchildren_aggregatedata\Schoolcensus
*cd /data/uctpusc/Uta/MLchildren/MLchildren_aggregatedata/Schoolcensus

cap log close
log using RD_DiffinDiff_92.log, replace


clear
*clear matrix
set mem 500m


use Hesse1836_ind, replace
append using SH1836_ind
append using Bayern1836_ind

***put Haupt- or Sonderschule into one category
gen lowspecial=0
replace lowspecial=1 if low==1|special==1

gen after=0
replace after=1 if gebmonat<=6

gen treat=0
replace treat=1 if cohort==9192

gen treatafter=treat*after

gen time=gebmonat-6 if gebmonat>=7
replace time=gebmonat+6 if gebmonat<7

gen treattime=treat*time

tab BL, gen(b)

gen women=sex-1

sort gebmonat treat
gen gebmonattreat=0
replace gebmonattreat=1 if gebmonat!=gebmonat[_n-1]|treat!=treat[_n-1]
replace gebmonattreat=sum(gebmonattreat)

***normalize the running variable. June=0, July=1
replace time=time-7

*********************************************
*October to March, 3 months before/after, regression discontinuity
*********************************************

*no controls 
reg lowspecial time after if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&cohort==9192, robust
reg lowspecial time after if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&cohort==9192, cluster(gebmonat)

reg medium time after if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&cohort==9192, robust
reg medium time after if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&cohort==9192, cluster(gebmonat)

reg high time after if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&cohort==9192, robust
reg high time after if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&cohort==9192, cluster(gebmonat)


*********************************************
*October to March, 3 months before/after, regression discontinuity. Allow time effect to vary before and after; clustering not sensible
*********************************************
gen timeafter=time*after

*no controls 
reg lowspecial time after timeafter if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&cohort==9192, robust
reg lowspecial time after timeafter if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&cohort==9192, cluster(gebmonat)


reg medium time after timeafter  if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&cohort==9192, robust
reg medium time after timeafter  if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&cohort==9192, cluster(gebmonat)


reg high time after timeafter  if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&cohort==9192, robust
reg high time after timeafter  if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&cohort==9192, cluster(gebmonat)


*********************************************
*October to March, 3 months before/after, regression discontinuity and diff-in-diff
*coefficient of interest: treatafter
*********************************************

*no controls 
reg lowspecial time after treat treatafter treattime  if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9091|cohort==9394|cohort==9495), robust
reg lowspecial time after treat treatafter treattime  if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9091|cohort==9394|cohort==9495), cluster(gebmonat)
reg lowspecial time after treat treatafter treattime  if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9091|cohort==9394|cohort==9495), cluster(gebmonattreat)

reg medium time after treat treatafter treattime  if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9091|cohort==9394|cohort==9495), robust
reg medium time after treat treatafter treattime  if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9091|cohort==9394|cohort==9495), cluster(gebmonat)
reg medium time after treat treatafter treattime  if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9091|cohort==9394|cohort==9495), cluster(gebmonattreat)

reg high time after treat treatafter treattime  if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9091|cohort==9394|cohort==9495), robust
reg medium time after treat treatafter treattime  if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9091|cohort==9394|cohort==9495), cluster(gebmonat)
reg high time after treat treatafter treattime  if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9091|cohort==9394|cohort==9495), cluster(gebmonattreat)



*********************************************
*October to March, 3 months before/after, regression discontinuity and diff-in-diff
*coefficient of interest: treatafter; allow effect of time to vary before and after --> clustering not sensible
*********************************************

gen treattimeafter=timeafter*treat

*no controls 
reg lowspecial time after timeafter treat treatafter treattime treattimeafter if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9091|cohort==9394|cohort==9495), robust
reg lowspecial time after timeafter treat treatafter treattime treattimeafter if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9091|cohort==9394|cohort==9495), cluster(gebmonat)
reg lowspecial time after timeafter treat treatafter treattime treattimeafter if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9091|cohort==9394|cohort==9495), cluster(gebmonattreat)


reg medium time after timeafter  treat treatafter treattime treattimeafter if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9091|cohort==9394|cohort==9495), robust
reg medium time after timeafter  treat treatafter treattime treattimeafter if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9091|cohort==9394|cohort==9495), cluster(gebmonat)
reg medium time after timeafter  treat treatafter treattime treattimeafter if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9091|cohort==9394|cohort==9495), cluster(gebmonattreat)



reg high time after timeafter treat treatafter treattime treattimeafter if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9091|cohort==9394|cohort==9495), robust
reg high time after timeafter treat treatafter treattime treattimeafter if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9091|cohort==9394|cohort==9495), cluster(gebmonat)
reg high time after timeafter treat treatafter treattime treattimeafter if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9091|cohort==9394|cohort==9495), cluster(gebmonattreat)



log close
