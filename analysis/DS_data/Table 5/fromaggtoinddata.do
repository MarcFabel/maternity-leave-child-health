*****************************************************
*Figures 1992 Reform
****************************************************

*cd U:\MLchildren\MLchildren_aggregatedata\Schoolcensus
cd /data/uctpusc/Uta/MLchildren/MLchildren_aggregatedata/Schoolcensus

clear
set mem 500m

**************************************
*Hesse
**************************************


use Hessen18to36_agg_ano

****keep only potential 8th grade
keep if (cohort==9091&year==2004)|(cohort==9192&year==2005)|(cohort==9293&year==2006)|(cohort==9394&year==2007)|(cohort==9495&year==2008)

*expand data set
expand all1

*indicator variable for each cell
sort cohort gebmonat sex year
gen ind=0
replace ind=1 if cohort!=cohort[_n-1]|gebmonat!=gebmonat[_n-1]|sex!=sex[_n-1]|year!=year[_n-1]
replace ind=sum(ind)

*counter within each cell
sort cohort gebmonat sex year
gen count=1
replace count=count+count[_n-1] if ind==ind[_n-1]

*assign types of schools to individuals
gen real1=0
replace real1=1 if count<=real

gen haupt1=0
replace haupt1=1 if count>real&count<=real+haupt

gen gym1=0
replace gym1=1 if count>real+haupt&count<=real+haupt+gym

gen foerder1=0
replace foerder1=1 if count>real+haupt+gym&count<=real+haupt+gym+foerder

gen gesamt1=0
replace gesamt1=1 if count>real+haupt+gym+foerder&count<=real+haupt+gym+foerder+gesamt

gen sonder1=0
replace sonder1=1 if count>real+haupt+gym+foerder+gesamt&count<=real+haupt+gym+foerder+gesamt+sonder

gen grund1=0
replace grund1=1 if count>real+haupt+gym+foerder+gesamt+sonder&count<=real+haupt+gym+foerder+gesamt+sonder+grund

gen other1=0
replace other1=1 if count>real+haupt+gym+foerder+gesamt+sonder+grund&count<=real+haupt+gym+foerder+gesamt+sonder+grund+other

*****************************************************************
*Note: the correlation between being in correct grade and type of school
*makes no sense
*****************************************************************

gen correct1=0
replace correct1=1 if count<=correct
drop correct
rename correct1 correct


***consistent school classification across states
*************************************************

**Hauptschule (excluding special needs schools)
gen low=0
replace low=1 if haupt1==1|foerder1==1|grund1==1|other1==1

**Realschule
gen medium=0
replace medium=1 if real1==1|gesamt1==1


**Gymnasium
gen high=0
replace high=1 if gym1==1

**special needs schools
gen special=0
replace special=1 if sonder1==1

keep cohort gebmonat sex year BL low medium high special correct 

save Hesse1836_ind, replace


***************************************************************
*Schleswig-Holstein
*************************************************************


clear
use SH18to36_agg_ano

****keep only potential 8th grade
keep if (cohort==9091&year==2004)|(cohort==9192&year==2005)|(cohort==9293&year==2006)|(cohort==9394&year==2007)|(cohort==9495&year==2008)

*expand data set
expand all1

*indicator variable for each cell
sort cohort gebmonat sex year
gen ind=0
replace ind=1 if cohort!=cohort[_n-1]|gebmonat!=gebmonat[_n-1]|sex!=sex[_n-1]|year!=year[_n-1]
replace ind=sum(ind)

*counter within each cell
sort cohort gebmonat sex year
gen count=1
replace count=count+count[_n-1] if ind==ind[_n-1]

*assign types of schools to individuals
gen real1=0
replace real1=1 if count<=real

gen haupt1=0
replace haupt1=1 if count>real&count<=real+haupt

gen gym1=0
replace gym1=1 if count>real+haupt&count<=real+haupt+gym

gen gesamt1=0
replace gesamt1=1 if count>real+haupt+gym&count<=real+haupt+gym+gesamt

gen sonder1=0
replace sonder1=1 if count>real+haupt+gym+gesamt&count<=real+haupt+gym+gesamt+sonder

gen grund1=0
replace grund1=1 if count>real+haupt+gym+gesamt+sonder&count<=real+haupt+gym+gesamt+sonder+grund

gen other1=0
replace other1=1 if count>real+haupt+gym+gesamt+sonder+grund&count<=real+haupt+gym+gesamt+sonder+grund+other

gen deafblind1=0
replace deafblind1=1 if count>real+haupt+gym+gesamt+sonder+grund+other&count<=real+haupt+gym+gesamt+sonder+grund+other+deafblind


*****************************************************************
*Note: the correlation between being in correct grade and type of school
*makes no sense
*****************************************************************

gen correct1=0
replace correct1=1 if count<=correct
drop correct
rename correct1 correct


***consistent school classification across states
*************************************************


**Hauptschule (excluding special needs schools)
gen low=0
replace low=1 if haupt1==1|other1==1

**Realschule
gen medium=0
replace medium=1 if real1==1|gesamt1==1


**Gymnasium
gen high=0
replace high=1 if gym1==1

**special needs schools
gen special=0
replace special=1 if sonder1==1|deafblind1==1

keep cohort gebmonat sex year BL low medium high special correct 

save SH1836_ind, replace


***************************************************************
*Bavaria
*************************************************************


clear
use Bayern18to36_agg_ano

**make gender variable consistent with Hesse and SH
gen sex1=2 if sex==0
replace sex1=1 if sex==1
drop sex
rename sex1 sex

*expand data set
expand all1

*indicator variable for each cell
sort cohort gebmonat sex year
gen ind=0
replace ind=1 if cohort!=cohort[_n-1]|gebmonat!=gebmonat[_n-1]|sex!=sex[_n-1]|year!=year[_n-1]
replace ind=sum(ind)

*counter within each cell
sort cohort gebmonat sex year
gen count=1
replace count=count+count[_n-1] if ind==ind[_n-1]

*assign types of schools to individuals
gen real1=0
replace real1=1 if count<=real

gen haupt1=0
replace haupt1=1 if count>real&count<=real+haupt

gen gym1=0
replace gym1=1 if count>real+haupt&count<=real+haupt+gym

gen sonder1=0
replace sonder1=1 if count>real+haupt+gym&count<=real+haupt+gym+sonder

*****************************************************************
*Note: the correlation between being in correct grade and type of school
*makes no sense
*****************************************************************

gen correct1=0
replace correct1=1 if count<=correct
drop correct
rename correct1 correct


***consistent school classification across states
*************************************************


**Hauptschule (excluding special needs schools)
gen low=0
replace low=1 if haupt1==1

**Realschule
gen medium=0
replace medium=1 if real1==1


**Gymnasium
gen high=0
replace high=1 if gym1==1

**special needs schools
gen special=0
replace special=1 if sonder1==1

keep cohort gebmonat sex year BL low medium high special correct 

save Bayern1836_ind, replace
