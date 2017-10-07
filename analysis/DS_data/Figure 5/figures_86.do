*****************************************************
*Figures 1986 Reform
****************************************************

*cd U:\MLchildren\MLchildren_aggregatedata\Schoolcensus
cd /data/uctpusc/Uta/MLchildren/MLchildren_aggregatedata/Schoolcensus

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
drop if cohort==8889

***Problems
***BY: first data starts in 2004. Hence, of the 1985/86 cohort, we do not observe
***those who graduated by age 18. The number is substantial in particular for July born
***kids, and also for August and September born kids.
***SH: we cannot distinguish between German and foreign births
***Hesse: There appears to be a problem in the data for the 8586 cohort from 2005 to 2006. There is a large
***jump from graduating from high track from age 20 to 21 for those born from January to June 86, but none
***at all for those born from July to December 1985. This is not due to a coding error of mine, but also in the raw data


******add up boys and girls, and three states
gen births=girls if sex==2
replace births=boys if sex==1
sort gebmonat
collapse (sum) grad1_age20 grad2_age20 grad3_age20 grad4_age20 grad5_age20 births, by(gebmonat)

***Main variable: graduation by age 20, excluding age 18, divided by total number of births
gen abitur=grad5_age20/births

gen time=gebmonat-6 if gebmonat>6
replace time=gebmonat+6 if gebmonat<=6

label variable time "Birth month"
label define timenew 1 "7/85" 3 "9/85" 5 "11/85" 7 "1/86" 9 "3/86" 11 "5/86", modify
label values time timenew

gen abitur1=abitur if gebmonat==7|gebmonat==8
gen abitur2=abitur if gebmonat!=7&gebmonat!=8



#delimit;
sort time;
scatter abitur1 abitur2 time, connect(none none) symbol(x dot) clpattern(none none) legend(off)
xlabel(1 3 5 7 9 11, valuelabel) xline(6.5) ylabel(0.05(0.05)0.35) ytitle("Graduation High Track") 
scheme(s2mono) legend(off) text(0.35 5.5 "6 months", box) text(0.35 7.5 "10 months", box) saving(gradtrack8586, replace);
graph export gradtrack8586.eps, replace;
#delimit cr;




erase help.dta
