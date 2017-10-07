*****************************************************
*Figures 1992 Reform
****************************************************

*cd U:\MLchildren\MLchildren_aggregatedata\Schoolcensus
cd /data/uctpusc/Uta/MLchildren/MLchildren_aggregatedata/Schoolcensus

****append data sets for the three states

clear
use Bayern18to36_agg_ano
append using Hessen18to36_agg_ano
append using SH18to36_agg_ano

keep if cohort==9192
keep if year==2005

***consistent school classification across states

**Hauptschule (excluding special needs schools)
gen low=haupt+foerder+grund+other if BL==1
replace low=haupt+other if BL==2
replace low=haupt if BL==3

**Realschule
gen medium=real+gesamt if BL==1|BL==2
replace medium=real if BL==3

**Gymnasium
gen high=gym

**special needs schools
gen special=sonder if BL==1|BL==3
replace special=sonder+deafblind if BL==2





**collapse data by BL and birth month
sort gebmonat 
collapse (sum) low medium high special correct all1, by(gebmon)

gen time=gebmon-6 if gebmon>=7
replace time=6+gebmon if gebmon<=6

label variable time "Birth month"
label define timenew 1 "7/91" 3 "9/91" 5 "11/91" 7 "1/92" 9 "3/92" 11 "5/92", modify
label values time timenew


***high track schools
gen gym=high/all

#delimit;
sort time;
scatter gym time, connect(none) symbol(dot) clpattern(none) 
xlabel(1 3 5 7 9 11, valuelabel) xline(6.5) ylabel(0.25(0.05)0.45) ytitle("High Track Choice") 
scheme(s2mono) legend(off) title("Panel C: High Track")
text(0.45 5.5 "18 months", box) text(0.45 7.5 "36 months", box) saving(gym9192, replace);
graph export gym9192.eps, replace;
#delimit cr;

***intermediate track choice
gen real=medium/all

#delimit;
sort time;
scatter real time, connect (none) symbol(dot) clpattern(none) 
xlabel(1 3 5 7 9 11, valuelabel) xline(6.5) ylabel(0.25(0.05)0.45) ytitle("Intermediate Track Choice") scheme(s2mono) legend(off)
text(0.45 5.5 "18 months", box) 
title("Panel B: Medium Track")
text(0.45 7.5 "36 months", box) saving(real9192, replace);
graph export real9192.eps, replace;
#delimit cr;


***low track choice
gen hauptsonder=(low+special)/all

#delimit;
sort time;
scatter hauptsonder time, connect (none l l) symbol(dot none none) clpattern(none solid solid) 
xlabel(1 3 5 7 9 11, valuelabel) xline(6.5) ylabel(0.2(0.05)0.4) ytitle("Low Track Choice") scheme(s2mono) legend(off)
text(0.4 5.5 "18 months", box) 
title("Panel A: Low Track")
text(0.4 7.5 "36 months", box) saving(low9192, replace);
graph export low9192.eps, replace;
#delimit cr;
