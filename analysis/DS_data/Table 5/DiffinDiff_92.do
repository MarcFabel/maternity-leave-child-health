*****************************************************
*Difference in Difference Estimates, 1992 reform, controls for birth month
****************************************************

*cd U:\MLchildren\MLchildren_aggregatedata\Schoolcensus
cd /data/uctpusc/Uta/MLchildren/MLchildren_aggregatedata/Schoolcensus

cap log close
log using DiffinDiff_92.log, replace


clear
clear matrix
set mem 500m


use Hesse1836_ind, replace
append using SH1836_ind
append using Bayern1836_ind

*** put Haupt- and Sonderschule in one category
gen lowspecial=0
replace lowspecial=1 if low==1|special==1

gen after=0
replace after=1 if gebmonat<=6

gen treat=0
replace treat=1 if cohort==9192

gen treatafter=treat*after

tab BL, gen(b)

gen time=gebmonat-6 if gebmonat>=7
replace time=gebmonat+6 if gebmonat<7
tab time, gen(t)


*********************************************
*one months before and after
*********************************************

****control group: 9091, 9394 and 9495 cohort, no controls
reg lowspecial treat after treatafter if (gebmonat==1|gebmonat==12)&(cohort==9192|cohort==9394|cohort==9091|cohort==9495), robust
reg medium treat after treatafter if (gebmonat==1|gebmonat==12)&(cohort==9192|cohort==9394|cohort==9091|cohort==9495), robust
reg high treat after treatafter if (gebmonat==1|gebmonat==12)&(cohort==9192|cohort==9394|cohort==9091|cohort==9495), robust


*********************************************
*two months before and after
*********************************************

****control group: 9091, 9394 and 9495 cohort, no controls
reg lowspecial treat after treatafter t5 t8 if (gebmonat==1|gebmonat==2|gebmonat==12|gebmonat==11)&(cohort==9192|cohort==9394|cohort==9091|cohort==9495), robust
reg medium treat after treatafter t5 t8 if (gebmonat==1|gebmonat==2|gebmonat==12|gebmonat==11)&(cohort==9192|cohort==9394|cohort==9091|cohort==9495), robust
reg high treat after treatafter t5 t8 if (gebmonat==1|gebmonat==2|gebmonat==12|gebmonat==11)&(cohort==9192|cohort==9394|cohort==9091|cohort==9495), robust


*********************************************
*three months before and after
*********************************************

****control group: 9091, 9394 and 9495 cohort, no controls
reg lowspecial treat after treatafter t4 t5 t8 t9 if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9394|cohort==9091|cohort==9495), robust
reg medium treat after treatafter t4 t5 t8 t9 if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9394|cohort==9091|cohort==9495), robust
reg high treat after treatafter t4 t5 t8 t9 if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==12|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9394|cohort==9091|cohort==9495), robust


*********************************************
*three months before and after, excluding January and December
*********************************************

reg lowspecial treat after treatafter t4 t9 if (gebmonat==2|gebmonat==3|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9394|cohort==9091|cohort==9495), robust
reg medium treat after treatafter t4 t9 if (gebmonat==2|gebmonat==3|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9394|cohort==9091|cohort==9495), robust
reg high treat after treatafter t4 t9 if (gebmonat==2|gebmonat==3|gebmonat==11|gebmonat==10)&(cohort==9192|cohort==9394|cohort==9091|cohort==9495), robust

*********************************************
*four months before and after
*********************************************

reg lowspecial treat after treatafter t3 t4 t5 t8 t9 t10 if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==4|gebmonat==12|gebmonat==11|gebmonat==10|gebmonat==9)&(cohort==9192|cohort==9394|cohort==9091|cohort==9495), robust
reg medium treat after treatafter t3 t4 t5 t8 t9 t10 if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==4|gebmonat==12|gebmonat==11|gebmonat==10|gebmonat==9)&(cohort==9192|cohort==9394|cohort==9091|cohort==9495), robust
reg high treat after treatafter t3 t4 t5 t8 t9 t10 if (gebmonat==1|gebmonat==2|gebmonat==3|gebmonat==4|gebmonat==12|gebmonat==11|gebmonat==10|gebmonat==9)&(cohort==9192|cohort==9394|cohort==9091|cohort==9495), robust


*********************************************
*six months before and after
*********************************************

reg lowspecial treat after treatafter t1 t2 t3 t4 t5 t8 t9 t10 t11 t12 if (cohort==9192|cohort==9394|cohort==9091|cohort==9495), robust
reg medium treat after treatafter t1 t2 t3 t4 t5 t8 t9 t10 t11 t12 if (cohort==9192|cohort==9394|cohort==9091|cohort==9495), robust
reg high treat after treatafter t1 t2 t3 t4 t5 t8 t9 t10 t11 t12 if (cohort==9192|cohort==9394|cohort==9091|cohort==9495), robust


*********************************************
*six months before and after, excluding January and December
*********************************************

reg lowspecial treat after treatafter t1 t2 t3 t4 t9 t10 t11 t12 if (gebmonat==2|gebmonat==3|gebmonat==4|gebmonat==5|gebmonat==6|gebmonat==11|gebmonat==10|gebmonat==9|gebmonat==8|gebmonat==7)&(cohort==9192|cohort==9394|cohort==9091|cohort==9495), robust
reg medium treat after treatafter t1 t2 t3 t4 t9 t10 t11 t12 if (gebmonat==2|gebmonat==3|gebmonat==4|gebmonat==5|gebmonat==6|gebmonat==11|gebmonat==10|gebmonat==9|gebmonat==8|gebmonat==7)&(cohort==9192|cohort==9394|cohort==9091|cohort==9495), robust
reg high treat after treatafter t1 t2 t3 t4 t9 t10 t11 t12 if (gebmonat==2|gebmonat==3|gebmonat==4|gebmonat==5|gebmonat==6|gebmonat==11|gebmonat==10|gebmonat==9|gebmonat==8|gebmonat==7)&(cohort==9192|cohort==9394|cohort==9091|cohort==9495), robust

log close
