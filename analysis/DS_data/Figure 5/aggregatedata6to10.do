
clear
set mem 500m

cap log close
log using aggregatedata6to10.log, replace

**************************************
*Hessen
*******************************************


*****************************************************2002/2003
***************************************************************
clear
use heschool/datasets/stata/suf_abs_0203

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

*cohort indicators 

gen cohort=0
replace cohort=8384 if (gebjahr==1983&gebmonat>=7)|(gebjahr==1984&gebmonat<=6)

replace cohort=8485 if (gebjahr==1984&gebmonat>=7)|(gebjahr==1985&gebmonat<=6)

replace cohort=8586 if (gebjahr==1985&gebmonat>=7)|(gebjahr==1986&gebmonat<=6)

replace cohort=8687 if (gebjahr==1986&gebmonat>=7)|(gebjahr==1987&gebmonat<=6)

replace cohort=8788 if (gebjahr==1987&gebmonat>=7)|(gebjahr==1988&gebmonat<=6)

replace cohort=8889 if (gebjahr==1988&gebmonat>=7)|(gebjahr==1989&gebmonat<=6)

*keep relevant cohorts only
keep if cohort==8384|cohort==8485|cohort==8586|cohort==8687|cohort==8788|cohort==8889

gen BL=1 
gen year=2002

tab staat
keep if staat==1

destring stufe, replace
tab stufe, miss
destring v_stufe, replace
tab v_stufe, miss

tab stufe v_stufe, miss

tab sch_form, miss

*currently in grade 13
gen ingrade13=0
replace ingrade13=1 if stufe==13&(sch_form==6|sch_form==10|sch_form==8)

*this and last year in grade 13
gen prevgrade13=0
replace prevgrade13=1 if stufe==13&(sch_form==6|sch_form==10|sch_form==8)&v_stufe==13

*currently in grade 13, do not condition on school type
gen ingrade13_new=0
replace ingrade13_new=1 if stufe==13

*this and last year in grade 13, do not condition on school type
gen prevgrade13_new=0
replace prevgrade13_new=1 if stufe==13&v_stufe==13

sort cohort gebmonat sex
collapse (sum) ingrade13 prevgrade13 ingrade13_new prevgrade13_new (mean) year BL, by(cohort gebmonat sex)

save Hessen6to10_02, replace


*****************************************************2003/2004
***************************************************************
clear
use heschool/datasets/stata/suf_abs_0304

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

*cohort indicators 

gen cohort=0
replace cohort=8384 if (gebjahr==1983&gebmonat>=7)|(gebjahr==1984&gebmonat<=6)

replace cohort=8485 if (gebjahr==1984&gebmonat>=7)|(gebjahr==1985&gebmonat<=6)

replace cohort=8586 if (gebjahr==1985&gebmonat>=7)|(gebjahr==1986&gebmonat<=6)

replace cohort=8687 if (gebjahr==1986&gebmonat>=7)|(gebjahr==1987&gebmonat<=6)

replace cohort=8788 if (gebjahr==1987&gebmonat>=7)|(gebjahr==1988&gebmonat<=6)

replace cohort=8889 if (gebjahr==1988&gebmonat>=7)|(gebjahr==1989&gebmonat<=6)

*keep relevant cohorts only
keep if cohort==8384|cohort==8485|cohort==8586|cohort==8687|cohort==8788|cohort==8889

gen BL=1 
gen year=2003

tab staat
keep if staat==1

destring stufe, replace
tab stufe, miss
destring v_stufe, replace
tab v_stufe, miss

tab stufe v_stufe, miss

tab sch_form, miss

*currently in grade 13
gen ingrade13=0
replace ingrade13=1 if stufe==13&(sch_form==6|sch_form==10|sch_form==8)

*this and last year in grade 13
gen prevgrade13=0
replace prevgrade13=1 if stufe==13&(sch_form==6|sch_form==10|sch_form==8)&v_stufe==13


*currently in grade 13, do not condition on school type
gen ingrade13_new=0
replace ingrade13_new=1 if stufe==13

*this and last year in grade 13, do not condition on school type
gen prevgrade13_new=0
replace prevgrade13_new=1 if stufe==13&v_stufe==13

sort cohort gebmonat sex
collapse (sum) ingrade13 prevgrade13 ingrade13_new prevgrade13_new (mean) year BL, by(cohort gebmonat sex)



save Hessen6to10_03, replace


*****************************************************2004/2005
***************************************************************
clear
use heschool/datasets/stata/suf_abs_0405

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

*cohort indicators 

gen cohort=0
replace cohort=8384 if (gebjahr==1983&gebmonat>=7)|(gebjahr==1984&gebmonat<=6)

replace cohort=8485 if (gebjahr==1984&gebmonat>=7)|(gebjahr==1985&gebmonat<=6)

replace cohort=8586 if (gebjahr==1985&gebmonat>=7)|(gebjahr==1986&gebmonat<=6)

replace cohort=8687 if (gebjahr==1986&gebmonat>=7)|(gebjahr==1987&gebmonat<=6)

replace cohort=8788 if (gebjahr==1987&gebmonat>=7)|(gebjahr==1988&gebmonat<=6)

replace cohort=8889 if (gebjahr==1988&gebmonat>=7)|(gebjahr==1989&gebmonat<=6)

*keep relevant cohorts only
keep if cohort==8384|cohort==8485|cohort==8586|cohort==8687|cohort==8788|cohort==8889

gen BL=1 
gen year=2004

tab staat
keep if staat==1

destring stufe, replace
tab stufe, miss
destring v_stufe, replace
tab v_stufe, miss

tab stufe v_stufe, miss

tab sch_form, miss

*currently in grade 13
gen ingrade13=0
replace ingrade13=1 if stufe==13&(sch_form==6|sch_form==10|sch_form==8)

*this and last year in grade 13
gen prevgrade13=0
replace prevgrade13=1 if stufe==13&(sch_form==6|sch_form==10|sch_form==8)&v_stufe==13


*currently in grade 13, do not condition on school type
gen ingrade13_new=0
replace ingrade13_new=1 if stufe==13

*this and last year in grade 13, do not condition on school type
gen prevgrade13_new=0
replace prevgrade13_new=1 if stufe==13&v_stufe==13

sort cohort gebmonat sex
collapse (sum) ingrade13 prevgrade13 ingrade13_new prevgrade13_new (mean) year BL, by(cohort gebmonat sex)

save Hessen6to10_04, replace



*****************************************************2005/2006
***************************************************************
clear
use heschool/datasets/stata/suf_abs_0506

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

*cohort indicators 

gen cohort=0
replace cohort=8384 if (gebjahr==1983&gebmonat>=7)|(gebjahr==1984&gebmonat<=6)

replace cohort=8485 if (gebjahr==1984&gebmonat>=7)|(gebjahr==1985&gebmonat<=6)

replace cohort=8586 if (gebjahr==1985&gebmonat>=7)|(gebjahr==1986&gebmonat<=6)

replace cohort=8687 if (gebjahr==1986&gebmonat>=7)|(gebjahr==1987&gebmonat<=6)

replace cohort=8788 if (gebjahr==1987&gebmonat>=7)|(gebjahr==1988&gebmonat<=6)

replace cohort=8889 if (gebjahr==1988&gebmonat>=7)|(gebjahr==1989&gebmonat<=6)

*keep relevant cohorts only
keep if cohort==8384|cohort==8485|cohort==8586|cohort==8687|cohort==8788|cohort==8889

gen BL=1 
gen year=2005

tab staat
keep if staat==1

destring stufe, replace
tab stufe, miss
destring v_stufe, replace
tab v_stufe, miss

tab stufe v_stufe, miss

tab sch_form, miss

*currently in grade 13
gen ingrade13=0
replace ingrade13=1 if stufe==13&(sch_form==6|sch_form==10|sch_form==8)

*this and last year in grade 13
gen prevgrade13=0
replace prevgrade13=1 if stufe==13&(sch_form==6|sch_form==10|sch_form==8)&v_stufe==13


*currently in grade 13, do not condition on school type
gen ingrade13_new=0
replace ingrade13_new=1 if stufe==13

*this and last year in grade 13, do not condition on school type
gen prevgrade13_new=0
replace prevgrade13_new=1 if stufe==13&v_stufe==13

sort cohort gebmonat sex
collapse (sum) ingrade13 prevgrade13 ingrade13_new prevgrade13_new (mean) year BL, by(cohort gebmonat sex)

save Hessen6to10_05, replace


*****************************************************2006/2007
***************************************************************
clear
use heschool/datasets/stata/suf_abs_0607

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

*cohort indicators 

gen cohort=0
replace cohort=8384 if (gebjahr==1983&gebmonat>=7)|(gebjahr==1984&gebmonat<=6)

replace cohort=8485 if (gebjahr==1984&gebmonat>=7)|(gebjahr==1985&gebmonat<=6)

replace cohort=8586 if (gebjahr==1985&gebmonat>=7)|(gebjahr==1986&gebmonat<=6)

replace cohort=8687 if (gebjahr==1986&gebmonat>=7)|(gebjahr==1987&gebmonat<=6)

replace cohort=8788 if (gebjahr==1987&gebmonat>=7)|(gebjahr==1988&gebmonat<=6)

replace cohort=8889 if (gebjahr==1988&gebmonat>=7)|(gebjahr==1989&gebmonat<=6)

*keep relevant cohorts only
keep if cohort==8384|cohort==8485|cohort==8586|cohort==8687|cohort==8788|cohort==8889

gen BL=1 
gen year=2006

tab staat
keep if staat==1

destring stufe, replace
tab stufe, miss
destring v_stufe, replace
tab v_stufe, miss

tab stufe v_stufe, miss

tab sch_form, miss

*currently in grade 13
gen ingrade13=0
replace ingrade13=1 if stufe==13&(sch_form==6|sch_form==10|sch_form==8)

*this and last year in grade 13
gen prevgrade13=0
replace prevgrade13=1 if stufe==13&(sch_form==6|sch_form==10|sch_form==8)&v_stufe==13


*currently in grade 13, do not condition on school type
gen ingrade13_new=0
replace ingrade13_new=1 if stufe==13

*this and last year in grade 13, do not condition on school type
gen prevgrade13_new=0
replace prevgrade13_new=1 if stufe==13&v_stufe==13

sort cohort gebmonat sex
collapse (sum) ingrade13 prevgrade13 ingrade13_new prevgrade13_new (mean) year BL, by(cohort gebmonat sex)

save Hessen6to10_06, replace



*****************************************************2007/2008 (previous grade is unusable)
***************************************************************
clear
use heschool/datasets/stata/suf_abs_0708

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

*cohort indicators 

gen cohort=0
replace cohort=8384 if (gebjahr==1983&gebmonat>=7)|(gebjahr==1984&gebmonat<=6)

replace cohort=8485 if (gebjahr==1984&gebmonat>=7)|(gebjahr==1985&gebmonat<=6)

replace cohort=8586 if (gebjahr==1985&gebmonat>=7)|(gebjahr==1986&gebmonat<=6)

replace cohort=8687 if (gebjahr==1986&gebmonat>=7)|(gebjahr==1987&gebmonat<=6)

replace cohort=8788 if (gebjahr==1987&gebmonat>=7)|(gebjahr==1988&gebmonat<=6)

replace cohort=8889 if (gebjahr==1988&gebmonat>=7)|(gebjahr==1989&gebmonat<=6)

*keep relevant cohorts only
keep if cohort==8384|cohort==8485|cohort==8586|cohort==8687|cohort==8788|cohort==8889

gen BL=1 
gen year=2007

tab staat
keep if staat==1

destring stufe, replace
tab stufe, miss
destring v_stufe, replace
tab v_stufe, miss

tab stufe v_stufe, miss

tab sch_form, miss

*currently in grade 13
gen ingrade13=0
replace ingrade13=1 if stufe==13&(sch_form==6|sch_form==10|sch_form==8)


*currently in grade 13, do not condition on school type
gen ingrade13_new=0
replace ingrade13_new=1 if stufe==13


sort cohort gebmonat sex
collapse (sum) ingrade13 ingrade13_new  (mean) year BL, by(cohort gebmonat sex)


save Hessen6to10_07, replace


*****************************************************2008/2009 (previous grade is unusable)
***************************************************************
clear
use heschool/datasets/stata/suf_abs_0809

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

*cohort indicators 

gen cohort=0
replace cohort=8384 if (gebjahr==1983&gebmonat>=7)|(gebjahr==1984&gebmonat<=6)

replace cohort=8485 if (gebjahr==1984&gebmonat>=7)|(gebjahr==1985&gebmonat<=6)

replace cohort=8586 if (gebjahr==1985&gebmonat>=7)|(gebjahr==1986&gebmonat<=6)

replace cohort=8687 if (gebjahr==1986&gebmonat>=7)|(gebjahr==1987&gebmonat<=6)

replace cohort=8788 if (gebjahr==1987&gebmonat>=7)|(gebjahr==1988&gebmonat<=6)

replace cohort=8889 if (gebjahr==1988&gebmonat>=7)|(gebjahr==1989&gebmonat<=6)

*keep relevant cohorts only
keep if cohort==8384|cohort==8485|cohort==8586|cohort==8687|cohort==8788|cohort==8889

gen BL=1 
gen year=2008

tab staat
keep if staat==1

destring stufe, replace
tab stufe, miss
destring v_stufe, replace
tab v_stufe, miss

tab stufe v_stufe, miss

tab sch_form, miss


*currently in grade 13
gen ingrade13=0
replace ingrade13=1 if stufe==13&(sch_form==6|sch_form==10|sch_form==8)

*currently in grade 13, do not condition on school type
gen ingrade13_new=0
replace ingrade13_new=1 if stufe==13

sort cohort gebmonat sex
collapse (sum) ingrade13 ingrade13_new  (mean) year BL, by(cohort gebmonat sex)

save Hessen6to10_08, replace



**************************************
*Schleswig/Holstein (previous grade does not exist)
*******************************************


*****************************************************2003/2004
***************************************************************
clear
use shschool/datasets/suf_sh_0304

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

*cohort indicators 

gen cohort=0
replace cohort=8384 if (gebjahr==1983&gebmonat>=7)|(gebjahr==1984&gebmonat<=6)

replace cohort=8485 if (gebjahr==1984&gebmonat>=7)|(gebjahr==1985&gebmonat<=6)

replace cohort=8586 if (gebjahr==1985&gebmonat>=7)|(gebjahr==1986&gebmonat<=6)

replace cohort=8687 if (gebjahr==1986&gebmonat>=7)|(gebjahr==1987&gebmonat<=6)

replace cohort=8788 if (gebjahr==1987&gebmonat>=7)|(gebjahr==1988&gebmonat<=6)

replace cohort=8889 if (gebjahr==1988&gebmonat>=7)|(gebjahr==1989&gebmonat<=6)

*keep relevant cohorts only
keep if cohort==8384|cohort==8485|cohort==8586|cohort==8687|cohort==8788|cohort==8889

gen BL=2
gen year=2003

tab staat
keep if staat==1

destring stufe, replace
tab stufe, miss
tab sch_form, miss

tab sch_form if stufe==13

*currently in grade 13
gen ingrade13=0
replace ingrade13=1 if stufe==13&(sch_form==6|sch_form==10|sch_form==8)

*include Abendgzmnasien (we are likely to double count them)
gen ingrade13_new=0
replace ingrade13_new=1 if ingrade13==1|sch_form==10

sort cohort gebmonat sex
collapse (sum) ingrade13 ingrade13_new (mean) year BL, by(cohort gebmonat sex)

save SH6to10_03, replace



*****************************************************2004/2005
***************************************************************
clear
use shschool/datasets/suf_sh_0405

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

*cohort indicators 

gen cohort=0
replace cohort=8384 if (gebjahr==1983&gebmonat>=7)|(gebjahr==1984&gebmonat<=6)

replace cohort=8485 if (gebjahr==1984&gebmonat>=7)|(gebjahr==1985&gebmonat<=6)

replace cohort=8586 if (gebjahr==1985&gebmonat>=7)|(gebjahr==1986&gebmonat<=6)

replace cohort=8687 if (gebjahr==1986&gebmonat>=7)|(gebjahr==1987&gebmonat<=6)

replace cohort=8788 if (gebjahr==1987&gebmonat>=7)|(gebjahr==1988&gebmonat<=6)

replace cohort=8889 if (gebjahr==1988&gebmonat>=7)|(gebjahr==1989&gebmonat<=6)

*keep relevant cohorts only
keep if cohort==8384|cohort==8485|cohort==8586|cohort==8687|cohort==8788|cohort==8889

gen BL=2 
gen year=2004

tab staat
keep if staat==1

destring stufe, replace
tab stufe, miss
tab sch_form, miss

tab sch_form if stufe==13

*currently in grade 13
gen ingrade13=0
replace ingrade13=1 if stufe==13&(sch_form==6|sch_form==10|sch_form==8)

*include Abendgzmnasien (we are likely to double count them)
gen ingrade13_new=0
replace ingrade13_new=1 if ingrade13==1|sch_form==10


sort cohort gebmonat sex
collapse (sum) ingrade13 ingrade13_new (mean) year BL, by(cohort gebmonat sex)

save SH6to10_04, replace



*****************************************************2005/2006
***************************************************************
clear
use shschool/datasets/suf_sh_0506

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

*cohort indicators 

gen cohort=0
replace cohort=8384 if (gebjahr==1983&gebmonat>=7)|(gebjahr==1984&gebmonat<=6)

replace cohort=8485 if (gebjahr==1984&gebmonat>=7)|(gebjahr==1985&gebmonat<=6)

replace cohort=8586 if (gebjahr==1985&gebmonat>=7)|(gebjahr==1986&gebmonat<=6)

replace cohort=8687 if (gebjahr==1986&gebmonat>=7)|(gebjahr==1987&gebmonat<=6)

replace cohort=8788 if (gebjahr==1987&gebmonat>=7)|(gebjahr==1988&gebmonat<=6)

replace cohort=8889 if (gebjahr==1988&gebmonat>=7)|(gebjahr==1989&gebmonat<=6)

*keep relevant cohorts only
keep if cohort==8384|cohort==8485|cohort==8586|cohort==8687|cohort==8788|cohort==8889

gen BL=2 
gen year=2005

tab staat
keep if staat==1

destring stufe, replace
tab stufe, miss
tab sch_form, miss
tab sch_form, nol

tab sch_form if stufe==13

*currently in grade 13
gen ingrade13=0
replace ingrade13=1 if stufe==13&(sch_form==6|sch_form==10|sch_form==8)

*include Abendgzmnasien (we are likely to double count them)
gen ingrade13_new=0
replace ingrade13_new=1 if ingrade13==1|sch_form==10

sort cohort gebmonat sex
collapse (sum) ingrade13 ingrade13_new (mean) year BL, by(cohort gebmonat sex)

save SH6to10_05, replace


*****************************************************2006/2007
***************************************************************
clear
use shschool/datasets/suf_sh_0607

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

*cohort indicators 

gen cohort=0
replace cohort=8384 if (gebjahr==1983&gebmonat>=7)|(gebjahr==1984&gebmonat<=6)

replace cohort=8485 if (gebjahr==1984&gebmonat>=7)|(gebjahr==1985&gebmonat<=6)

replace cohort=8586 if (gebjahr==1985&gebmonat>=7)|(gebjahr==1986&gebmonat<=6)

replace cohort=8687 if (gebjahr==1986&gebmonat>=7)|(gebjahr==1987&gebmonat<=6)

replace cohort=8788 if (gebjahr==1987&gebmonat>=7)|(gebjahr==1988&gebmonat<=6)

replace cohort=8889 if (gebjahr==1988&gebmonat>=7)|(gebjahr==1989&gebmonat<=6)

*keep relevant cohorts only
keep if cohort==8384|cohort==8485|cohort==8586|cohort==8687|cohort==8788|cohort==8889

gen BL=2 
gen year=2006

tab staat
keep if staat==1

destring stufe, replace
tab stufe, miss
tab sch_form, miss
tab sch_form, nol

tab sch_form if stufe==13

*currently in grade 13
gen ingrade13=0
replace ingrade13=1 if stufe==13&(sch_form==6|sch_form==10|sch_form==8)

*include Abendgzmnasien (we are likely to double count them)
gen ingrade13_new=0
replace ingrade13_new=1 if ingrade13==1|sch_form==10

sort cohort gebmonat sex
collapse (sum) ingrade13 ingrade13_new (mean) year BL, by(cohort gebmonat sex)

save SH6to10_06, replace



*****************************************************2007/2008
***************************************************************
clear
use shschool/datasets/suf_sh_0708

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

*cohort indicators 

gen cohort=0
replace cohort=8384 if (gebjahr==1983&gebmonat>=7)|(gebjahr==1984&gebmonat<=6)

replace cohort=8485 if (gebjahr==1984&gebmonat>=7)|(gebjahr==1985&gebmonat<=6)

replace cohort=8586 if (gebjahr==1985&gebmonat>=7)|(gebjahr==1986&gebmonat<=6)

replace cohort=8687 if (gebjahr==1986&gebmonat>=7)|(gebjahr==1987&gebmonat<=6)

replace cohort=8788 if (gebjahr==1987&gebmonat>=7)|(gebjahr==1988&gebmonat<=6)

replace cohort=8889 if (gebjahr==1988&gebmonat>=7)|(gebjahr==1989&gebmonat<=6)

*keep relevant cohorts only
keep if cohort==8384|cohort==8485|cohort==8586|cohort==8687|cohort==8788|cohort==8889

gen BL=2 
gen year=2007

tab staat
keep if staat==1

destring stufe, replace
tab stufe, miss
tab sch_form, miss
tab sch_form, nol

tab sch_form if stufe==13

*currently in grade 13
gen ingrade13=0
replace ingrade13=1 if stufe==13&(sch_form==6|sch_form==10|sch_form==8)

*include Abendgzmnasien (we are likely to double count them)
gen ingrade13_new=0
replace ingrade13_new=1 if ingrade13==1|sch_form==10

sort cohort gebmonat sex
collapse (sum) ingrade13 ingrade13_new (mean) year BL, by(cohort gebmonat sex)

save SH6to10_07, replace






*****************************************************2007/2008
***************************************************************
clear
use shschool/datasets/suf_sh_0809

*rename birth year and birth month
rename geb_j gebjahr
rename geb_m gebmonat

*cohort indicators 

gen cohort=0
replace cohort=8384 if (gebjahr==1983&gebmonat>=7)|(gebjahr==1984&gebmonat<=6)

replace cohort=8485 if (gebjahr==1984&gebmonat>=7)|(gebjahr==1985&gebmonat<=6)

replace cohort=8586 if (gebjahr==1985&gebmonat>=7)|(gebjahr==1986&gebmonat<=6)

replace cohort=8687 if (gebjahr==1986&gebmonat>=7)|(gebjahr==1987&gebmonat<=6)

replace cohort=8788 if (gebjahr==1987&gebmonat>=7)|(gebjahr==1988&gebmonat<=6)

replace cohort=8889 if (gebjahr==1988&gebmonat>=7)|(gebjahr==1989&gebmonat<=6)

*keep relevant cohorts only
keep if cohort==8384|cohort==8485|cohort==8586|cohort==8687|cohort==8788|cohort==8889

gen BL=2 
gen year=2008

tab staat
keep if staat==1

destring stufe, replace
tab stufe, miss
tab sch_form, miss
tab sch_form, nol

tab sch_form if stufe==13

*currently in grade 13
gen ingrade13=0
replace ingrade13=1 if stufe==13&(sch_form==6|sch_form==10|sch_form==8)

*include Abendgymnasien (we are likely to double count them)
gen ingrade13_new=0
replace ingrade13_new=1 if ingrade13==1|sch_form==10

sort cohort gebmonat sex
collapse (sum) ingrade13 ingrade13_new (mean) year BL, by(cohort gebmonat sex)

save SH6to10_08, replace


************************************************************
*aggregate data and add up pupils in 13th grade
*********************************************************


***********************
*Hessen
********************


clear
use Hessen6to10_02
append using Hessen6to10_03
append using Hessen6to10_04
append using Hessen6to10_05
append using Hessen6to10_06
append using Hessen6to10_07
append using Hessen6to10_08


gen age=19 if year==2002
replace age=20 if year==2003
replace age=21 if year==2004
replace age=22 if year==2005
replace age=23 if year==2006
replace age=24 if year==2007
replace age=25 if year==2008

replace age=age-1 if cohort==8485
replace age=age-2 if cohort==8586
replace age=age-3 if cohort==8687
replace age=age-4 if cohort==8788
replace age=age-5 if cohort==8889


sort cohort sex gebmonat year
***grade repeaters are double counted, school type is used
gen graduation_1=ingrade13
replace graduation_1=graduation_1+graduation_1[_n-1] if cohort==cohort[_n-1]&sex==sex[_n-1]&gebmonat==gebmonat[_n-1]
***grade repeaters are substracted, school type is used
gen graduation_2=ingrade13-prevgrade13
replace graduation_2=graduation_2+graduation_2[_n-1] if cohort==cohort[_n-1]&sex==sex[_n-1]&gebmonat==gebmonat[_n-1]

***grade repeaters are double counted, school type is not used
gen graduation_3=ingrade13_new
replace graduation_3=graduation_3+graduation_3[_n-1] if cohort==cohort[_n-1]&sex==sex[_n-1]&gebmonat==gebmonat[_n-1]
***grade repeaters are substracted, school type is used
gen graduation_4=ingrade13_new-prevgrade13_new
replace graduation_4=graduation_4+graduation_4[_n-1] if cohort==cohort[_n-1]&sex==sex[_n-1]&gebmonat==gebmonat[_n-1]


***by age 19 to 25 
forvalues i=1/4{
forvalues a=19/25{
gen grad`i'_age`a'=0
replace grad`i'_age`a'=graduation_`i' if age==`a'
sort cohort sex gebmonat grad`i'_age`a'
by cohort sex gebmonat: replace grad`i'_age`a'=grad`i'_age`a'[_N] 
}
}


**** set variables to missing if the cohort is too young and the variable is not defined
forvalues i=1/4{
replace grad`i'_age25=. if cohort>8384
replace grad`i'_age24=. if cohort>8485
replace grad`i'_age23=. if cohort>8586
replace grad`i'_age22=. if cohort>8687
replace grad`i'_age21=. if cohort>8788
}


**********how many graduate at age 14, 15, 16, 17, 18?

sum ingrade13 ingrade13_new if age==14
sum ingrade13 ingrade13_new if age==15
sum ingrade13 ingrade13_new if age==16
sum ingrade13 ingrade13_new if age==17
sum ingrade13 ingrade13_new if age==18

tab gebmonat if age==18, sum(ingrade13)
tab gebmonat if age==18, sum(ingrade13_new)


*************additional variable: count pupils in grade 13 only from age 19 onwards, otherwise corresponds to definition 1
sort cohort sex gebmonat year
gen help=ingrade13
replace help=0 if age<19
gen graduation_5=help
replace graduation_5=graduation_5+graduation_5[_n-1] if cohort==cohort[_n-1]&sex==sex[_n-1]&gebmonat==gebmonat[_n-1]
drop help

***by age 19 to 25 
forvalues a=19/25{
gen grad5_age`a'=0
replace grad5_age`a'=graduation_5 if age==`a'
sort cohort sex gebmonat grad5_age`a'
by cohort sex gebmonat: replace grad5_age`a'=grad5_age`a'[_N] 
}

**** set variables to missing if the cohort is too young and the variable is not defined
replace grad5_age25=. if cohort>8384
replace grad5_age24=. if cohort>8485
replace grad5_age23=. if cohort>8586
replace grad5_age22=. if cohort>8687
replace grad5_age21=. if cohort>8788

drop graduation_5
keep cohort sex gebmonat year grad1_age19-grad5_age25

*keep one year only
keep if year==2002
drop year

save Hessen6to10_agg, replace






***********************
*Schleswig-Holstein
********************


clear
use SH6to10_03
append using SH6to10_04
append using SH6to10_05
append using SH6to10_06
append using SH6to10_07
append using SH6to10_08


gen age=19 if year==2002
replace age=20 if year==2003
replace age=21 if year==2004
replace age=22 if year==2005
replace age=23 if year==2006
replace age=24 if year==2007
replace age=25 if year==2008

replace age=age-1 if cohort==8485
replace age=age-2 if cohort==8586
replace age=age-3 if cohort==8687
replace age=age-4 if cohort==8788
replace age=age-5 if cohort==8889


sort cohort sex gebmonat year
***grade repeaters are double counted, school type is used, Abendgymnasien are excluded. Note: previous grade variable does not exist for SH. Hence, definitions 2 and 4 are not used
gen graduation_1=ingrade13
replace graduation_1=graduation_1+graduation_1[_n-1] if cohort==cohort[_n-1]&sex==sex[_n-1]&gebmonat==gebmonat[_n-1]

***grade repeaters are double counted, Abendgymnasien are included.
gen graduation_3=ingrade13_new
replace graduation_3=graduation_3+graduation_3[_n-1] if cohort==cohort[_n-1]&sex==sex[_n-1]&gebmonat==gebmonat[_n-1]
***grade repeaters are substracted, school type is used

***by age 19 to 25 
foreach i in 1 3{
forvalues a=19/25{
gen grad`i'_age`a'=0
replace grad`i'_age`a'=graduation_`i' if age==`a'
sort cohort sex gebmonat grad`i'_age`a'
by cohort sex gebmonat: replace grad`i'_age`a'=grad`i'_age`a'[_N] 
}
}


**** set variables to missing if the cohort is too young and the variable is not defined
foreach i in 1 3{
replace grad`i'_age25=. if cohort>8384
replace grad`i'_age24=. if cohort>8485
replace grad`i'_age23=. if cohort>8586
replace grad`i'_age22=. if cohort>8687
replace grad`i'_age21=. if cohort>8788
replace grad`i'_age19=. if cohort==8384
}







**********how many graduate at age 14, 15, 16, 17, 18?

sum ingrade13 ingrade13_new if age==14
sum ingrade13 ingrade13_new if age==15
sum ingrade13 ingrade13_new if age==16
sum ingrade13 ingrade13_new if age==17
sum ingrade13 ingrade13_new if age==18

tab gebmonat if age==18, sum(ingrade13)
tab gebmonat if age==18, sum(ingrade13_new)


*************additional variable: count pupils in grade 13 only from age 19 onwards, otherwise corresponds to definition 1

sort cohort sex gebmonat year
gen help=ingrade13
replace help=0 if age<19
gen graduation_5=help
replace graduation_5=graduation_5+graduation_5[_n-1] if cohort==cohort[_n-1]&sex==sex[_n-1]&gebmonat==gebmonat[_n-1]
drop help

***by age 19 to 25 
forvalues a=19/25{
gen grad5_age`a'=0
replace grad5_age`a'=graduation_5 if age==`a'
sort cohort sex gebmonat grad5_age`a'
by cohort sex gebmonat: replace grad5_age`a'=grad5_age`a'[_N] 
}

**** set variables to missing if the cohort is too young and the variable is not defined
replace grad5_age25=. if cohort>8384
replace grad5_age24=. if cohort>8485
replace grad5_age23=. if cohort>8586
replace grad5_age22=. if cohort>8687
replace grad5_age21=. if cohort>8788
replace grad5_age19=. if cohort==8384

drop graduation_5
keep cohort sex gebmonat year grad1_age19-grad5_age25

*keep one year only
keep if year==2003
drop year

save SH6to10_agg, replace




log close

