*****************************************************
*Difference in Difference Estimates, 1992 reform, separate effects by BL
****************************************************

cd U:\MLchildren\MLchildren_aggregatedata\Schoolcensus
*cd /data/uctpusc/Uta/MLchildren/MLchildren_aggregatedata/Schoolcensus

set more off

cap log close
log using RD_DiffinDiff_86.log, replace


clear
*clear matrix
set mem 500m

****append data sets for the three states

clear
use Bayern6to10agg
gen bl=3
replace sex=sex+1
append using Hessen6to10_agg
replace bl=1 if bl==.
append using SH6to10_agg
replace bl=2 if bl==.
sort bl cohort gebmonat
drop if cohort==8384
save help, replace

***merge birth data
use births_86, clear
sort bl cohort gebmonat
merge bl cohort gebmonat using help
tab _merge
drop if _merge==2
drop _merge


***Problems
***BY: first data starts in 2004. Hence, of the 1985/86 cohort, we do not observe
***those who graduated by age 18. The number is substantial in particular for July born
***kids, and also for August and September born kids.
***SH: we cannot distinguish between German and foreign births
***Hesse: There appears to be a problem in the data for the 8586 cohort from 2005 to 2006. There is a large
***jump from graduating from high track from age 20 to 21 for those born from January to June 86, but none
***at all for those born from July to December 1985. This is not due to a coding error of mine, but also in the raw data

***total number of births
gen all=girls if sex==2
replace all=boys if sex==1

***keep only relevant variables
keep gebmonat bl cohort all grad5_age20 sex 


****blow up data
*************************
expand all


*indicator variable for each cell
sort bl cohort gebmonat sex 

gen ind=0
replace ind=1 if bl!=bl[_n-1]|cohort!=cohort[_n-1]|gebmonat!=gebmonat[_n-1]|sex!=sex[_n-1]
replace ind=sum(ind)

*counter within each cell
sort bl cohort gebmonat sex 
gen count=1
replace count=count+count[_n-1] if ind==ind[_n-1]

*assign Abitur to individuals
gen abitur=0
replace abitur=1 if count<=grad5_age20


gen time=gebmonat-6 if gebmonat>6
replace time=gebmonat+6 if gebmonat<=6

gen time2=time^2

gen after=0
replace after=1 if gebmonat<=6

gen treat=0
replace treat=1 if cohort==8586

gen treatafter=treat*after
gen treattime=treat*time

gen treattime2=treat*time2

sort gebmonat treat
gen gebmonattreat=0
replace gebmonattreat=1 if gebmonat!=gebmonat[_n-1]|treat!=treat[_n-1]
replace gebmonattreat=sum(gebmonattreat)

tab bl, gen(b)

gen women=sex-1

***normalize the running variable. June=0, July=1
replace time=time-7

*********************************************
*October to March, 3 months before/after, regression discontinuity
*********************************************

*no controls 
reg abitur time after if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&cohort==8586, robust
reg abitur time after if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&cohort==8586, cluster(gebmonat)


*********************************************
*October to March, 3 months before/after, regression discontinuity, allow effect of time to be different before and after
*********************************************
gen timeafter=time*after

*no controls 
reg abitur time after timeafter if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&cohort==8586, robust
reg abitur time after timeafter if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&cohort==8586, cluster(gebmonat)


*********************************************
*October to March, 3 months before/after, regression discontinuity and diff-in-diff
*coefficient of interest: treatafter, 8687 and 8889 as control group
*********************************************

*no controls 
reg abitur time after treat treatafter treattime  if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==8586|cohort==8687|cohort==8889), robust
reg abitur time after treat treatafter treattime  if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==8586|cohort==8687|cohort==8889), cluster(gebmonat)
reg abitur time after treat treatafter treattime  if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==8586|cohort==8687|cohort==8889), cluster(gebmonattreat)


*********************************************
*October to March, 3 months before/after, regression discontinuity and diff-in-diff
*coefficient of interest: treatafter, 8687 and 8889 as control group, allow effect of time to be different before and after
*********************************************

gen treattimeafter=timeafter*treat

*no controls 
reg abitur time after timeafter treat treatafter treattime treattimeafter if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==8586|cohort==8687|cohort==8889), robust
reg abitur time after timeafter treat treatafter treattime treattimeafter  if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==8586|cohort==8687|cohort==8889), cluster(gebmonat)
reg abitur time after timeafter treat treatafter treattime treattimeafter  if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==8586|cohort==8687|cohort==8889), cluster(gebmonattreat)



log close
