cap log close
log using RD_DiffinDiff.log, replace

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


gen treat=0
replace treat=1 if cohort==7879

gen after=0
replace after=1 if bmonth>=5&bmonth<=10

gen treatafter=treat*after

gen time=bmonth-10 if bmonth>=11
replace time=bmonth+2 if bmonth<=10
replace time=time-7



gen treattime=treat*time

tab bulafirst, gen(b)

sort bmonth treat
gen bmonthtreat=0
replace bmonthtreat=1 if bmonth!=bmonth[_n-1]|treat!=treat[_n-1]
replace bmonthtreat=sum(bmonthtreat)

gen lnwFT_28=ln(wageFT_28)


***********************************************************
*RD, three  months before, 2 months after
****************************************************

*no controls
foreach v in low_28 medium_28 high_28 uni_28 hightrack_28 educ_28 educ_nohigh_28 lnwFT_28 validFT_28{
reg `v' time after if (bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&cohort==7879, robust
reg `v' time after if (bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&cohort==7879, cluster(bmonth)
}



***********************************************************
*RD, three  months before, 2 months after, allow effect of time to be different before and after  expansion
****************************************************
gen timeafter=time*after

*no controls
foreach v in low_28 medium_28 high_28 uni_28 hightrack_28 educ_28 educ_nohigh_28 lnwFT_28 validFT_28{
reg `v' time timeafter after if (bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&cohort==7879, robust
reg `v' time timeafter after if (bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&cohort==7879, cluster(bmonth)
}



***********************************************************
*RD and DiffinDiff, 3 months before and 2 months after
****************************************************

*** no controls
foreach v in low_28 medium_28 high_28 uni_28 hightrack_28 educ_28 educ_nohigh_28 lnwFT_28 validFT_28{
reg `v' time after treat treattime treatafter if (bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==7879|cohort==7778|cohort==7677|cohort==7980), robust
reg `v' time after treat treattime treatafter if (bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==7879|cohort==7778|cohort==7677|cohort==7980), cluster(bmonthtreat)
reg `v' time after treat treattime treatafter if (bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==7879|cohort==7778|cohort==7677|cohort==7980), cluster(bmonth)
}

***********************************************************
*RD and DiffinDiff, 3 months before and 2 months after, allow effect of time to differ before and after
****************************************************

gen treattimeafter=timeafter*treat

*** no controls
foreach v in low_28 medium_28 high_28 uni_28 hightrack_28 educ_28 educ_nohigh_28 lnwFT_28 validFT_28{
reg `v' time after timeafter treat treattime treatafter treattimeafter if (bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==7879|cohort==7778|cohort==7677|cohort==7980), robust
reg `v' time after treat treattime treatafter treattimeafter if (bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==7879|cohort==7778|cohort==7677|cohort==7980), cluster(bmonthtreat)
reg `v' time after treat treattime treatafter treattimeafter if (bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)&(cohort==7879|cohort==7778|cohort==7677|cohort==7980), cluster(bmonth)
}


log close
