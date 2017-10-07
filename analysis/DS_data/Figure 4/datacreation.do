***********************************************************
*Cohort definition: 6 months before and after expansion in leave coverage
*That is: children born between November 78 and October 79 belong
*to the same cohort
**************************************************************


cd N:\Ablagen\D01700-IAB-Projekte\D01700-BEH-Stichtag\LUDSTECK\AGLITZ\MLChildren\1978Reform


cap log close
log using datacreation.log, replace

clear
clear matrix
set mem 20000m

*****Keep relevant birth cohorts: 1976-1981 (treated: 1979)
***********************************************************
forvalues y=1991/2008{
use "N:\Ablagen\D01700-IAB-Projekte\D01700-BEH-Stichtag\anonym\data\clean`y'"
keep if gebj>=1976&gebj<=1981
gen year=`y'
compress
save help`y', replace
}

*****Append data
******************

clear
use help1991
forvalues y=1992/2008{
append using help`y'
}


*****Clean data
***************

*drop marginal employment
keep if pers_gr==101|pers_gr==102

*cohort indicator
gen cohort=7677 if (gebj==1976&gebm>=11)|(gebj==1977&gebm<=10)
replace cohort=7778 if (gebj==1977&gebm>=11)|(gebj==1978&gebm<=10)
replace cohort=7879 if (gebj==1978&gebm>=11)|(gebj==1979&gebm<=10)
replace cohort=7980 if (gebj==1979&gebm>=11)|(gebj==1980&gebm<=10)
replace cohort=8081 if (gebj==1980&gebm>=11)|(gebj==1981&gebm<=10)
drop if gebj==1981&gebm>=11
drop if gebj==1976&gebm<=10


***create an age variable where December and January kids who start school in 
***the same year have the same age
**according to this variable, the treated cohort 7879 is 29 in 2008

gen age_cohort=year-gebj-1 if gebm>=11
replace age_cohort=year-gebj if gebm<=10


***drop those younger than 15
tab age_cohort
drop if age_cohort<15
 **** we observe the treated cohort only up until the age they turn 29. Hence, drop everybody older then 29
 drop if age_cohort>29

***drop East Germans
gen bula=int(ao_gem/1000000)
sort vsnr_ano year
gen east=0
replace east=1 if (bula>10|bula==-9|bula==0)&vsnr_ano!=vsnr_ano[_n-1]
sort vsnr_ano east
qui by vsnr_ano: replace east=east[_N]
tab east
drop if east==1
drop east


***drop foreigners
sort vsnr_ano year
gen foreign=0
replace foreign=1 if staat!=0&vsnr_ano!=vsnr_ano[_n-1]
sort vsnr_ano foreign
qui by vsnr_ano: replace foreign=foreign[_N]
tab foreign
drop if foreign==1
drop foreign 


**bula first spell
sort vsnr_ano year
gen bulafirst=0
replace bulafirst=bula if vsnr_ano!=vsnr_ano[_n-1]
sort vsnr_ano bulafirst
qui by vsnr_ano: replace bulafirst=bulafirst[_N]
tab bulafirst
drop bula ao_gem ao_gst

**indicator women
gen women=sex-1
drop sex


***at least two spells in apprenticeship with the same firm
sort vsnr_ano bnr year
gen twoapp=0
replace twoapp=1 if berufstg==0&berufstg[_n-1]==0&bnr==bnr[_n-1]&vsnr==vsnr[_n-1]
sort vsnr_ano twoapp
qui by vsnr_ano: replace twoapp=twoapp[_N]

***maximum education 
gen bild=ausbild
replace bild=-1 if ausbild==7|ausbild==9
sort vsnr_ano year
egen maxbild=max(bild), by(vsnr_ano)

****main education classification
********************************************
gen low=0
replace low=1 if maxbild<=1&twoapp==0
sort vsnr low
qui by vsnr: replace low=low[_N]

*put graduation high track, no app, into low
gen low_high=0
replace low_high=1 if (maxbild<=1|maxbild==3)&twoapp==0
sort vsnr low_high
qui by  vsnr: replace low_high=low_high[_N]

gen medium=0
replace medium=1 if (maxbild>=2&maxbild<=4)|twoapp==1
sort vsnr medium
qui by vsnr: replace medium=medium[_N]

*remove high track, no app, from medium
gen medium_nohigh=0
replace medium_nohigh=1 if maxbild==2|maxbild==4|twoapp==1
sort vsnr medium_nohigh
qui by vsnr: replace medium_nohigh=medium_nohigh[_N]

gen high=0
replace high=1 if maxbild==5|maxbild==6
sort vsnr high
qui by vsnr: replace high=high[_N]

gen uni=0
replace uni=1 if maxbild==6
sort vsnr uni
qui by vsnr: replace uni=uni[_N]

gen hightrack=0
replace hightrack=1 if maxbild==3|maxbild==4|maxbild==5|maxbild==6
sort vsnr hightrack
qui by vsnr: replace hightrack=hightrack[_N]


***set these variables to missing for cohorts born after 1979. These
***cohorts are only 28 during the last year

foreach v in low low_high medium medium_nohigh high uni hightrack {
replace  `v'=. if cohort>=7980
}

***entered by age i
*********************

foreach a in 25 26 27 28 {
gen enter_`a'=0
replace enter_`a'=1 if age_cohort<=`a'
sort vsnr_ano enter_`a'
qui by vsnr_ano: replace enter_`a'=enter_`a'[_N]
}
replace enter_28=. if cohort>=8081


***the 7980 cohort is only observed up until age 28. 
***Create variable that uses spells only up until age 28
****this variable is missing for individuals who enter after 28
********************************************************

***maximum education by age 28 
drop bild
gen bild=ausbild
replace bild=-1 if ausbild==7|ausbild==9|age_cohort>28
sort vsnr_ano year
egen maxbild_28=max(bild), by(vsnr_ano)


***at least two spells in apprenticeship with the same firm by age 28
sort vsnr_ano bnr year
gen twoapp_28=0
replace twoapp_28=1 if berufstg==0&berufstg[_n-1]==0&bnr==bnr[_n-1]&vsnr==vsnr[_n-1]&age_cohort<=28
sort vsnr_ano twoapp_28
qui by vsnr_ano: replace twoapp_28=twoapp_28[_N]

****main education classification, using spells only until age 28
******************************************************************
gen low_28=0
replace low_28=1 if maxbild_28<=1&twoapp_28==0
sort vsnr low_28
qui by vsnr: replace low_28=low_28[_N]


*put graduation high track, no app, into low
gen low_high_28=0
replace low_high_28=1 if (maxbild_28==1|maxbild_28==3)&twoapp_28==0
sort vsnr low_high_28
qui by  vsnr: replace low_high_28=low_high_28[_N]

gen medium_28=0
replace medium_28=1 if (maxbild_28>=2&maxbild_28<=4)|twoapp_28==1
sort vsnr medium_28
qui by vsnr: replace medium_28=medium_28[_N]

*remove high track, no app, from medium
gen medium_nohigh_28=0
replace medium_nohigh_28=1 if maxbild_28==2|maxbild_28==4|twoapp_28==1
sort vsnr medium_nohigh_28
qui by vsnr: replace medium_nohigh_28=medium_nohigh_28[_N]


gen high_28=0
replace high_28=1 if maxbild_28==5|maxbild_28==6
sort vsnr high_28
qui by vsnr: replace high_28=high_28[_N]

gen uni_28=0
replace uni_28=1 if maxbild_28==6
sort vsnr uni_28
qui by vsnr: replace uni_28=uni_28[_N]

gen hightrack_28=0
replace hightrack_28=1 if maxbild_28==3|maxbild_28==4|maxbild_28==5|maxbild_28==6
sort vsnr hightrack_28
qui by vsnr: replace hightrack_28=hightrack_28[_N]


***set variables to missing if individual has not entered by 28. For all individuals if born after 7980
foreach v in low low_high medium medium_nohigh high uni hightrack {
replace `v'_28=. if cohort>=8081|enter_28==0
}



***the 8182 cohort is only observed up until age 27. 
***Create variable that uses spells only up until age 27
********************************************************

***maximum education by age 27 
drop bild
gen bild=ausbild
replace bild=-1 if ausbild==7|ausbild==9|age_cohort>27
sort vsnr_ano year
egen maxbild_27=max(bild), by(vsnr_ano)


***at least three spells in apprenticeship with the same firm by age 27
sort vsnr_ano bnr year
gen twoapp_27=0
replace twoapp_27=1 if berufstg==0&berufstg[_n-1]==0&bnr==bnr[_n-1]&vsnr==vsnr[_n-1]&age_cohort<=27
sort vsnr_ano twoapp_27
qui by vsnr_ano: replace twoapp_27=twoapp_27[_N]

****main education classification, using spells only until age 28
******************************************************************
gen low_27=0
replace low_27=1 if maxbild_27<=1&twoapp_27==0
sort vsnr low_27
qui by vsnr: replace low_27=low_27[_N]


*put graduation high track, no app, into low
gen low_high_27=0
replace low_high_27=1 if (maxbild_27==1|maxbild_27==3)&twoapp_27==0
sort vsnr low_high_27
qui by  vsnr: replace low_high_27=low_high_27[_N]

gen medium_27=0
replace medium_27=1 if (maxbild_27>=2&maxbild_27<=4)|twoapp_27==1
sort vsnr medium_27
qui by vsnr: replace medium_27=medium_27[_N]


*remove high track, no app, from medium
gen medium_nohigh_27=0
replace medium_nohigh_27=1 if maxbild_27==2|maxbild_27==4|twoapp_27==1
sort vsnr medium_nohigh_27
qui by vsnr: replace medium_nohigh_27=medium_nohigh_27[_N]

gen high_27=0
replace high_27=1 if maxbild_27==5|maxbild_27==6
sort vsnr high_27
qui by vsnr: replace high_27=high_27[_N]


gen uni_27=0
replace uni_27=1 if maxbild_27==6
sort vsnr uni_27
qui by vsnr: replace uni_27=uni_27[_N]

gen hightrack_27=0
replace hightrack_27=1 if maxbild_27==3|maxbild_27==4|maxbild_27==5|maxbild_27==6
sort vsnr hightrack_27
qui by vsnr: replace hightrack_27=hightrack_27[_N]

***set variables to missing if individual has not entered by 27
foreach v in low low_high medium medium_nohigh high uni hightrack {
replace `v'_27=. if enter_27==0
}

/**************************************************************
wages
*************************************************************/
rename tag_entg entgelt
replace entgelt=. if entgelt==0
gen entgelt1=entgelt
/*lower bound*/
replace entgelt1=15 if entgelt<=15&year==1991
replace entgelt1=16 if entgelt<=16&year==1992
replace entgelt1=17 if entgelt<=17&year==1993
replace entgelt1=19 if entgelt<=19&year==1994
replace entgelt1=19 if entgelt<=19&year==1995
replace entgelt1=20 if entgelt<=20&year==1996
replace entgelt1=20 if entgelt<=20&year==1997
replace entgelt1=20 if entgelt<=20&year==1998

/*upper bound*/
replace entgelt1=143 if entgelt>=143&year==1999&entgelt!=.
replace entgelt1=144 if entgelt>=144&year==2000&entgelt!=.
replace entgelt1=145 if entgelt>=145&year==2001&entgelt!=.
replace entgelt1=146 if entgelt>=146&year==2002&entgelt!=.
replace entgelt1=165 if entgelt>=165&year==2003&entgelt!=.
replace entgelt1=166 if entgelt>=166&year==2004&entgelt!=.
replace entgelt1=168 if entgelt>=168&year==2005&entgelt!=.
replace entgelt1=170 if entgelt>=170&year==2006&entgelt!=.
replace entgelt1=170 if entgelt>=170&year==2007&entgelt!=.
replace entgelt1=171 if entgelt>=171&year==2008&entgelt!=.


label variable entgelt1 "wage, includes censoring limits"

/*indicator for left censoring*/
gen left=0
replace left=1 if entgelt<=15&year==1991
replace left=1 if entgelt<=16&year==1992
replace left=1 if entgelt<=17&year==1993
replace left=1 if entgelt<=19&year==1994
replace left=1 if entgelt<=19&year==1995
replace left=1 if entgelt<=20&year==1996
replace left=1 if entgelt<=20&year==1997
replace left=1 if entgelt<=20&year==1998
label variable left "left censored"


/*indicator for right censoring*/
gen right=0
replace right=1 if entgelt>=214&year==1991&entgelt!=.
replace right=1 if entgelt>=223&year==1992&entgelt!=.
replace right=1 if entgelt>=237&year==1993&entgelt!=.
replace right=1 if entgelt>=250&year==1994&entgelt!=.
replace right=1 if entgelt>=256&year==1995&entgelt!=.
replace right=1 if entgelt>=262&year==1996&entgelt!=.
replace right=1 if entgelt>=270&year==1997&entgelt!=.
replace right=1 if entgelt>=276&year==1998&entgelt!=.
replace right=1 if entgelt>=143&year==1999&entgelt!=.
replace right=1 if entgelt>=144&year==2000&entgelt!=.
replace right=1 if entgelt>=146&year==2001&entgelt!=.
replace right=1 if entgelt>=146&year==2002&entgelt!=.
replace right=1 if entgelt>=165&year==2003&entgelt!=.
replace right=1 if entgelt>=166&year==2004&entgelt!=.
replace right=1 if entgelt>=168&year==2005&entgelt!=.
replace right=1 if entgelt>=170&year==2006&entgelt!=.
replace right=1 if entgelt>=170&year==2007&entgelt!=.
replace right=1 if entgelt>=171&year==2008&entgelt!=.
label variable right "right censored"

/*convert Euros into DM, 1 Euro = 1,95583 DM  */
replace entgelt1=entgelt1*1.95583 if year>=1999
replace left=1 if entgelt<=20&year>=1999

/*compute real wage, 1995 is base year*/
gen realw=entgelt1
replace realw=entgelt1/0.751 if year==1991
replace realw=entgelt1/0.798 if year==1992
replace realw=entgelt1/0.833 if year==1993
replace realw=entgelt1/0.856 if year==1994
replace realw=entgelt1/0.871 if year==1995
replace realw=entgelt1/0.883 if year==1996
replace realw=entgelt1/0.900 if year==1997
replace realw=entgelt1/0.909 if year==1998
replace realw=entgelt1/0.914 if year==1999
replace realw=entgelt1/0.927 if year==2000
replace realw=entgelt1/0.945 if year==2001
replace realw=entgelt1/0.959 if year==2002
replace realw=entgelt1/0.969 if year==2003
replace realw=entgelt1/0.984 if year==2004
replace realw=entgelt1/1.00 if year==2005
replace realw=entgelt1/1.016 if year==2006
replace realw=entgelt1/1.039 if year==2007
replace realw=entgelt1/1.066 if year==2008
label variable realw "real wage, 2005 base year"
drop entgelt entgelt1


*****valid wage 
*at age 29
gen valid=0
replace valid=1 if age_cohort==29&realw!=.&left==0
sort vsnr_ano valid
qui by vsnr_ano: replace valid=valid[_N]
replace valid=. if cohort>=7980

*at age 28
gen valid_28=0
replace valid_28=1 if age_cohort==28&realw!=.&left==0
sort vsnr_ano valid_28
qui by vsnr_ano: replace valid_28=valid_28[_N]
replace valid_28=. if cohort>=8081|enter_28==0

*at age 27
gen valid_27=0
replace valid_27=1 if age_cohort==27&realw!=.&left==0
sort vsnr_ano valid_27
qui by vsnr_ano: replace valid_27=valid_27[_N]
replace valid_27=. if enter_27==0

*****valid full-time wage 
*at age 29
gen validFT=0
replace validFT=1 if age_cohort==29&realw!=.&left==0&berufstg>0&berufstg<7
sort vsnr_ano validFT
qui by vsnr_ano: replace validFT=validFT[_N]
replace validFT=. if cohort>=7980

*at age 28
gen validFT_28=0
replace validFT_28=1 if age_cohort==28&realw!=.&left==0&berufstg>0&berufstg<7
sort vsnr_ano validFT_28
qui by vsnr_ano: replace validFT_28=validFT_28[_N]
replace validFT_28=. if cohort>=8081|enter_28==0

*at age 27
gen validFT_27=0
replace validFT_27=1 if age_cohort==27&realw!=.&left==0&berufstg>0&berufstg<7
sort vsnr_ano validFT_27
qui by vsnr_ano: replace validFT_27=validFT_27[_N]
replace validFT_27=. if enter_27==0

****wage at age 27, 28 and 29

gen wage=0
replace wage=realw if age_cohort==29&valid==1
sort vsnr_ano wage
qui by vsnr_ano: replace wage=wage[_N]
replace wage=. if valid==.

gen wage_28=0
replace wage_28=realw if age_cohort==28&valid_28==1
sort vsnr_ano wage_28
qui by vsnr_ano: replace wage_28=wage_28[_N]
replace wage_28=. if valid_28==.


gen wage_27=0
replace wage_27=realw if age_cohort==27&valid_27==1
sort vsnr_ano wage_27
qui by vsnr_ano: replace wage_27=wage_27[_N]
replace wage_27=. if valid_27==.


****fulltime wage at age 29, 28, 27. Missing if no valid full-time wage

gen wageFT=wage
replace wageFT=. if validFT==0|validFT==.
gen wageFT_28=wage_28
replace wageFT_28=. if validFT_28==0|validFT_28==.
gen wageFT_27=wage_27
replace wageFT_27=. if validFT_27==0|validFT_27==.


*********wage at age 29, 28 or 27 censored
gen right_29=0
replace right_29=1 if right==1&age_cohort==29
sort vsnr_ano right_29
qui by vsnr_ano: replace right_29=right_29[_N]
replace right_29=. if cohort>=7980

gen right_28=0
replace right_28=1 if right==1&age_cohort==28
sort vsnr_ano right_28
qui by vsnr_ano: replace right_28=right_28[_N]
replace right_28=. if cohort>=8081|enter_28==0

gen right_27=0
replace right_27=1 if right==1&age_cohort==27
sort vsnr_ano right_27
qui by vsnr_ano: replace right_27=right_27[_N]
replace right_27=. if cohort>=8182|enter_27==0


***drop unneccary variables
***************************
drop dauer wo_gem beruford berufstg ausbild pers_gr wz73 alter estsize ten wz93 wz03
drop maxbild maxbild_28 maxbild_27
compress


save reform1979, replace

forvalues y=1991/2008{
erase help`y'.dta
}

log close
