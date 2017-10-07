
/* This dofiles uses the PISA 2003 and 2006 data for Germany and prepares it for the analysis carried out
   by the dofile reg_analysis.
   
   Schooltracks are recoded in three categories: low, medium and high
   A dummy is created to distinguish native Germans from other students. Only the former are included in the
   analysis
*/


clear matrix
set more off

cap log close

cd "K:\"

global PathData "[Data]\PISA"
global PathSave "Lanzara\Germany_schooltracks\working_data"
global PathLog "Lanzara\Germany_schooltracks\log_files"

log using "$PathLog\create_dataset.txt", replace

/*YEAR 2006*/

use "$PathData\PISA2006\data\int_stu06_dec07.dta", clear

*Keep variables of interest

keep  COUNTRY SUBNATIO SCHOOLID STIDSTD CNT  ST01Q01 ST03Q02 ST03Q03 ST04Q01 ST11Q01 ST11Q02 ST11Q03 ST15Q01 ///
      PROGN COBN_M COBN_F COBN_S ST11Q04 FISCED MISCED PV1MATH-PV5SCIE  W_FSTUWT-W_FSTR80

*Keep only Germany (country==276)

destring COUNTRY, generate(country)
keep if country==276

/*
Recode school-tracks in three levels: High, Medium, Low
       - variable "p" numbers the different school tracks in year 2006
*/

egen p=group(PROGN)
generate track=1 if p==2|p==10|p==12
replace track=3 if p==4|p==5
mvencode track, mv(2)

label define track 1 "Low" 2 "Medium" 3 "High"
label values track track

/*Convert education levels in years of education, based on PISA Technical Report (2006) */

*father
gen eduyearsF=0
replace eduyearsF=4 if FISCED==1
replace eduyearsF=10 if FISCED==2
replace eduyearsF=13 if FISCED==3|FISCED==4
replace eduyearsF=15 if FISCED==5
replace eduyearsF=18 if FISCED==6

*mother
gen eduyearsM=0
replace eduyearsM=4 if MISCED==1
replace eduyearsM=10 if MISCED==2
replace eduyearsM=13 if MISCED==3|MISCED==4
replace eduyearsM=15 if MISCED==5
replace eduyearsM=18 if MISCED==6


*destring month of birth
destring ST03Q02, replace

*gen var for year
gen year=2006

*Merge with school questionnaire

merge CNT SCHOOLID  using "$PathData\PISA2006\data\int_sch06_dec07.dta", uniqusing sort
keep if _merge==3
drop _merge

*Merge with parents questionnaire

merge CNT STIDSTD using "$PathData\PISA2006\data\int_par06_dec07.dta", unique sort
keep if _merge==3

gen income=0
replace income=100 if  PA15Q01==1| PA15Q01==2| PA15Q01==3
replace income=. if PA15Q01==.

gen books=0 
replace books=100 if ST15Q01==1|ST15Q01==2
replace books=. if ST15Q01==.

save "$PathSave\2006.dta", replace

/*YEAR 2003*/

use "$PathData\PISA2003\data\INT_stui_2003.dta", clear

*Keep variables of interest

keep  country cnt subnatio schoolid stidstd   st01q01  st02q02  st02q03 st20q01 st21q01 st03q01 st15q01 st15q02 st15q03 st19q01 ///
      st15q04 progn  iso_s iso_m iso_f misced fisced pv1math-pv5math  pv1read- pv5scie  w_fstuwt  w_fstr1- w_fstr80

*Rename variables so that they are consistent with 2006

rename country COUNTRY
rename subnatio SUBNATIO
rename stidstd STIDSTD 
rename   st03q01 ST04Q01 
rename  st15q04 ST11Q04 
rename  st15q02 ST11Q02 
rename   st15q03 ST11Q03 
rename  st15q01 ST11Q01 
rename progn PROGN
rename iso_s COBN_S
rename iso_m COBN_M
rename iso_f COBN_F
rename misced MISCED
rename fisced FISCED
rename  st01q01 ST01Q01
rename  st02q02 ST03Q02 
rename  st02q03 ST03Q03

rename pv1math PV1MATH
rename pv2math PV2MATH
rename pv3math PV3MATH
rename pv4math PV4MATH
rename pv5math PV5MATH
rename pv1read PV1READ
rename pv2read PV2READ
rename pv3read PV3READ
rename pv4read PV4READ
rename pv5read PV5READ
rename pv1scie PV1SCIE
rename pv2scie PV2SCIE
rename pv3scie PV3SCIE
rename pv4scie PV4SCIE
rename pv5scie PV5SCIE

rename w_fstuwt W_FSTUWT

forvalues i=1/80 {

rename w_fstr`i' W_FSTR`i'

}

*Keep only Germany (country==276)

destring COUNTRY, generate(country)
keep if country==276

/*
Recode school-tracks in three levels: High, Medium, Low
       - variable "t" numbers the different school tracks in year 2003
*/

egen t=group(PROGN)
generate track=1 if t==2
replace track=3 if t==4|t==15|t==16
drop if t==17
mvencode track, mv(2)


label define track 1 "Low" 2 "Medium" 3 "High"
label values track track

/*Convert education levels in years of education, based on PISA Technical Report (2006) */

*father
gen eduyearsF=0
replace eduyearsF=4 if FISCED==1
replace eduyearsF=10 if FISCED==2
replace eduyearsF=13 if FISCED==3|FISCED==4
replace eduyearsF=15 if FISCED==5
replace eduyearsF=18 if FISCED==6

*mother
gen eduyearsM=0
replace eduyearsM=4 if MISCED==1
replace eduyearsM=10 if MISCED==2
replace eduyearsM=13 if MISCED==3|MISCED==4
replace eduyearsM=15 if MISCED==5
replace eduyearsM=18 if MISCED==6


gen books=0 
replace books=100 if st19q01 ==1|st19q01 ==2
replace books=. if st19q01 ==.

*Merge with school questionnaire

merge cnt schoolid using "$PathData\PISA2003\data\INT_schi_2003.dta", uniqusing sort
keep if _merge==3
drop _merge

*rename vars
rename cnt CNT
rename schoolid SCHOOLID

*gen var for year
gen year=2003

save "$PathSave\2003.dta", replace


/*POOL 2006 AND 2003*/

append using "$PathSave\2006.dta", force

*recode gender: males=0 and females=100
recode ST04Q01 (2=0) (1=100)

*rename vars
rename   ST04Q01 gender
rename  ST11Q04 ageofarrival
rename  ST11Q02 mothbirth
rename   ST11Q03 fathbirth
rename  ST11Q01 childbirth
rename ST01Q01 grade
rename  ST03Q02 monthb
rename  ST03Q03 yearb
rename  st21q01 ageschooly

/* Drop those with no information on father's, mother's or own country of birth */

drop if mothbirth==. | fathbirth==. | childbirth==.

/*Consider a german student a student born in Germany from German-born parents
        -15 obs. are foreign-born with German-born parents. They are coded as german==0       */

gen german=1 if mothbirth==1 & fathbirth==1 & childbirth==1
mvencode german, mv(0)

*Generate school-track variable for German students only

generate trackG=track if german==1

*Standardize PISA scores: mean 0 and se 1 in Germany

foreach var of varlist PV1MATH - PV5SCIE {

egen z`var'=std(`var')

}

*gen and standardize sum of test scores

forvalues i=1/5{
gen PV`i'SUM=PV`i'READ+PV`i'MATH
}

foreach var of varlist PV1SUM - PV5SUM {

egen z`var'=std(`var')

}

*Gen track-school string sequence

egen school = concat(track SCHOOLID)

*Generate unique school weight variable 
replace  W_FSCHWT = scweight if W_FSCHWT==.
drop scweight

*Average plausible values for reading and mathematics

gen read =(zPV1READ+ zPV2READ+ zPV3READ+ zPV4READ+ zPV5READ)/5
gen math =(zPV1MATH+ zPV2MATH+ zPV3MATH+ zPV4MATH+ zPV5MATH)/5


*Gen legal age of schoolentry

gen legalageschool=13/12 if month==7
replace legalageschool= 1 if month==8
replace legalageschool=11/12 if month==9
replace legalageschool=10/12 if month==10
replace legalageschool=9/12 if month==11
replace legalageschool=8/12 if month==12
replace legalageschool=7/12 if month==1
replace legalageschool=6/12 if month==2
replace legalageschool=5/12 if month==3
replace legalageschool=4/12 if month==4
replace legalageschool=3/12 if month==5
replace legalageschool=2/12 if month==6

/*Kids born bewteen September and June: 
        -if ageschooly = 6, ageschool= legal age
        - if ageschooly = 7, it means they entered school one year later
                                                                            */
gen ageschool = ageschooly + legalageschool -6 if (monthb>=1 & monthb<=6) | (monthb>=9 |monthb<12)

/*Kids born in July and August
        - if ageschooly = 7, ageschool= legal age
        - if ageschooly=6, they entered school one year in advance 
                                                                             */

replace ageschool= ageschooly + legalageschool - 7 if monthb==7|monthb==8



save "$PathSave\pool.dta", replace

log close
