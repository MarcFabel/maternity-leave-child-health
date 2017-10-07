cap log close
log using DiffinDiff.log, replace

cd N:\Ablagen\D01700-IAB-Projekte\D01700-BEH-Stichtag\LUDSTECK\AGLITZ\MLChildren\1978Reform


clear
clear matrix
set mem 3000m

use reform1979
sort vsnr year
keep if vsnr!=vsnr[_n-1]

rename gebj byear
rename gebm bmonth

*******generate continuous education variable
*********************************************

gen educ=16 if low==1
replace educ=19 if medium==1&hightrack==0
replace educ=19 if medium==0&hightrack==1
replace educ=21 if medium==1&hightrack==1
replace educ=24 if high==1&uni==0
replace educ=25 if uni==1

gen educ_28=16 if low_28==1
replace educ_28=19 if medium_28==1&hightrack_28==0
replace educ_28=19 if medium_28==0&hightrack_28==1
replace educ_28=21 if medium_28==1&hightrack_28==1
replace educ_28=24 if high_28==1&uni_28==0
replace educ_28=25 if uni_28==1


*****generate additional variables that do not use information on high track completion
gen educ_nohigh=16 if low_high==1
replace educ_nohigh=19 if medium_nohigh==1
replace educ_nohigh=24 if high==1&uni==0
replace educ_nohigh=25 if uni==1

gen educ_nohigh_28=16 if low_high_28==1
replace educ_nohigh_28=19 if medium_nohigh_28==1
replace educ_nohigh_28=24 if high_28==1&uni_28==0
replace educ_nohigh_28=25 if uni_28==1

****treatment variables
gen treat=0
replace treat=1 if cohort==7879

gen after=0
replace after=1 if bmonth>=5&bmonth<=10

gen treatafter=treat*after

tab bulafirst, gen(b)
gen time=bmonth-10 if bmonth>=11
replace time=bmonth+2 if bmonth<=10
tab time, gen(t)

gen lnwFT=ln(wageFT)
gen lnwFT_28=ln(wageFT_28)

**************************************************
*Age 28
*******************************************************************


***********************************************************
*one months before and after
****************************************************

****control group: 77, 78 and 80, no controls 
foreach v in low_28 low_high_28 medium_28 medium_nohigh_28 high_28 uni_28 hightrack_28 educ_28  educ_nohigh_28 validFT_28 lnwFT_28{ 
reg `v' treat after treatafter  if (bmonth==4|bmonth==5)&(cohort==7879|cohort==7980|cohort==7778|cohort==7677), robust
}


***********************************************************
*two  months before, 2 months after
****************************************************

****control group: 77, 78 and 80, birth month dummies
foreach v in low_28 low_high_28 medium_28 medium_nohigh_28 high_28 uni_28 hightrack_28 educ_28  educ_nohigh_28 validFT lnwFT_28 {
reg `v' treat after treatafter t5 t8 if (bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==7879|cohort==7980|cohort==7778|cohort==7677), robust
}



***********************************************************
*four  months before, 2 months after
****************************************************



****control group: 77, 78 and 80, birth month dummies
foreach v in low_28 low_high_28 medium_28 medium_nohigh_28 high_28 uni_28 hightrack_28 educ_28  educ_nohigh_28 validFT lnwFT_28 {
reg `v' treat after treatafter t3 t4 t5 t8 if (bmonth==1|bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==7879|cohort==7980|cohort==7778|cohort==7677), robust
}


***********************************************************
*6  months before, 6 months after
****************************************************


****control group: 77, 78 and 80, controls for birth month dummies
foreach v in low_28 low_high_28 medium_28 medium_nohigh_28 high_28 uni_28 hightrack_28 educ_28  educ_nohigh_28 validFT lnwFT_28 {
reg `v' treat after treatafter t1 t2 t3 t4 t5 t8 t9 t10 t11 t12 if (bmonth==11|bmonth==12|bmonth==1|bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6|bmonth==7|bmonth==8|bmonth==9|bmonth==10)&(cohort==7879|cohort==7980|cohort==7778|cohort==7677), robust
}


***********************************************************
*6  months before, 6 months after, excluding April and May
****************************************************

****control group: 77, 78 and 80, controls birth month dummies
foreach v in low_28 low_high_28 medium_28 medium_nohigh_28 high_28 uni_28 hightrack_28 educ_28  educ_nohigh_28 validFT lnwFT_28 {
reg `v' treat after treatafter t1 t2 t3 t4 t9 t10 t11 t12 if (bmonth==11|bmonth==12|bmonth==1|bmonth==2|bmonth==3|bmonth==6|bmonth==7|bmonth==8|bmonth==9|bmonth==10)&(cohort==7879|cohort==7980|cohort==7778|cohort==7677), robust
}




**************************************************
*Age 29
*******************************************************************


***********************************************************
*one months before and after
****************************************************

****control group: 77, 78, no controls 
foreach v in low low_high medium medium_nohigh high uni hightrack educ  educ_nohigh validFT lnwFT{ 
reg `v' treat after treatafter  if (bmonth==4|bmonth==5)&(cohort==7879|cohort==7778|cohort==7677), robust
}


***********************************************************
*two  months before, 2 months after
****************************************************


****control group: 77, 78, no controls 
foreach v in low low_high medium medium_nohigh high uni hightrack educ  educ_nohigh validFT lnwFT{
reg `v' treat after treatafter t5 t8 if (bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==7879|cohort==7778|cohort==7677), robust
}



***********************************************************
*four  months before, 2 months after
****************************************************


****control group: 77, 78, no controls 
foreach v in low low_high medium medium_nohigh high uni hightrack educ  educ_nohigh validFT lnwFT{
reg `v' treat after treatafter t3 t4 t5 t8 if (bmonth==1|bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==7879|cohort==7778|cohort==7677), robust
}


***********************************************************
*6  months before, 6 months after
****************************************************


****control group: 77, 78, no controls 
foreach v in low low_high medium medium_nohigh high uni hightrack educ  educ_nohigh validFT lnwFT{
reg `v' treat after treatafter t1 t2 t3 t4 t5 t8 t9 t10 t11 t12 if (bmonth==11|bmonth==12|bmonth==1|bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6|bmonth==7|bmonth==8|bmonth==9|bmonth==10)&(cohort==7879|cohort==7778|cohort==7677), robust
}


***********************************************************
*6  months before, 6 months after, excluding April and May
****************************************************


****control group: 77, 78, no controls 
foreach v in low low_high medium medium_nohigh high uni hightrack educ  educ_nohigh validFT lnwFT{
reg `v' treat after treatafter t1 t2 t3 t4 t9 t10 t11 t12 if (bmonth==11|bmonth==12|bmonth==1|bmonth==2|bmonth==3|bmonth==6|bmonth==7|bmonth==8|bmonth==9|bmonth==10)&(cohort==7879|cohort==7778|cohort==7677), robust
}


log close
