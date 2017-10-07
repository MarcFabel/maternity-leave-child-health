*****************************************************
*Figures 1986 Reform
****************************************************
set more off
clear
set more off
set mem 500m

*cd U:\MLchildren\MLchildren_aggregatedata\Schoolcensus
cd /data/uctpusc/Uta/MLchildren/MLchildren_aggregatedata/Schoolcensus

cap log close
log using DiffinDiff_86.log, replace


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


************************************************
*Difference in differnce estimates
************************************************

*Note: possible control groups: 86/87 and 88/89
***********************************************


gen after=0
replace after=1 if gebmonat<=6

gen treat=0
replace treat=1 if cohort==8586

gen treatafter=treat*after

tab bl, gen(b)

gen women=sex-1

gen time=gebmonat-6 if gebmonat>=7
replace time=gebmonat+6 if gebmonat<7
tab time, gen(t)

************************************************
*one months before or after
************************************************

***control group: 8687 and 8889, no controls
reg abitur treat after treatafter if (gebmonat==12|gebmonat==1)&(cohort==8586|cohort==8889|cohort==8687), robust


************************************************
*two months before or after
************************************************

***control group: 8687 and 8889, no controls
reg abitur treat after treatafter t5 t8 if (gebmonat==11|gebmonat==12|gebmonat==1|gebmonat==2)&(cohort==8586|cohort==8889|cohort==8687), robust


************************************************
*two months before or after, excluding December and January
************************************************

***control group: 8687 and 8889, no controls
reg abitur treat after treatafter if (gebmonat==11|gebmonat==2)&(cohort==8586|cohort==8889|cohort==8687), robust


************************************************
*three months before or after
************************************************

***control group: 8687 and 8889, no controls
reg abitur treat after treatafter t4 t5 t8 t9 if (gebmonat==10|gebmonat==11|gebmonat==12|gebmonat==1|gebmonat==2|gebmonat==3)&(cohort==8586|cohort==8889|cohort==8687), robust


************************************************
*three months before or after, excluding January and December
************************************************

***control group: 8687 and 8889, no controls
reg abitur treat after treatafter t4 t9 if (gebmonat==10|gebmonat==11|gebmonat==2|gebmonat==3)&(cohort==8586|cohort==8889|cohort==8687), robust


************************************************
*four months before or after
************************************************

***control group: 8687 and 8889, no controls
reg abitur treat after treatafter t3 t4 t5 t8 t9 t10 if (gebmonat==9|gebmonat==10|gebmonat==11|gebmonat==12|gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==4)&(cohort==8586|cohort==8889|cohort==8687), robust



************************************************
*September to June, 4 months before, 6 months after
************************************************

***control group: 8687 and 8889, no controls
reg abitur treat after treatafter t3 t4 t5 t8 t9 t10 t11 t12 if (gebmonat==9|gebmonat==10|gebmonat==11|gebmonat==12|gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==4|gebmonat==5|gebmonat==6)&(cohort==8586|cohort==8889|cohort==8687), robust


*****************************************************
*September to June, excluding January and December
******************************************************

***control group: 8687 and 8889, no controls
reg abitur treat after treatafter t3 t4 t9 t10 t11 t12 if (gebmonat==9|gebmonat==10|gebmonat==11|gebmonat==2|gebmonat==3|gebmonat==4|gebmonat==5|gebmonat==6)&(cohort==8586|cohort==8889|cohort==8687), robust

erase help.dta

log close
