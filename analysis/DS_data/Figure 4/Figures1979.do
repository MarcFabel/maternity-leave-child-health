cap log close
log using Figures.log, replace

cd N:\Ablagen\D01700-IAB-Projekte\D01700-BEH-Stichtag\LUDSTECK\AGLITZ\MLChildren\1978Reform


clear
clear matrix
set mem 3000m

use reform1979
sort vsnr year
keep if vsnr!=vsnr[_n-1]

rename gebj byear
rename gebm bmonth

keep if (byear==1978&bmonth>=11)|(byear==1979&bmonth<=10)

gen educ=16 if low==1
replace educ=19 if medium==1&hightrack==0
replace educ=19 if medium==0&hightrack==1
replace educ=21 if medium==1&hightrack==1
replace educ=24 if high==1&uni==0
replace educ=25 if uni==1

gen time=bmonth-10 if bmonth>=11
replace time=bmonth+2 if bmonth<=10


gen N=1
gen lnwFT=ln(wageFT)
sort time
collapse low medium high uni hightrack educ validFT lnwFT (sum) N, by(time)

label variable time "birth month"
label define time1 1 "11/78" 3 "1/79" 5 "3/79" 7 "5/79" 9 "7/79" 11 "9/79"
label values time time1


*****share low-skilled
**********************
#delimit;
scatter low time, ylabel(0.025(0.05)0.225) xlabel(1(2)11, valuelabel)
xline(6.5) xline(8.5, lpatter(dash)) scheme(s2mono) ytitle("Low-Skilled")
text(0.225 5.7 "2 months", box) text(0.225 7.3 "6 months", box)
title("Panel A: Low-Skilled") saving(low, replace);
graph export low.eps, replace;
#delimit cr;


*****share medium-skilled
**********************
#delimit;
scatter med time, ylabel(0.68(0.05)0.93) xlabel(1(2)11, valuelabel)
xline(6.5) xline(8.5, lpatter(dash)) scheme(s2mono) ytitle("Medium-Skilled")
text(0.93 5.7 "2 months", box) text(0.93 7.3 "6 months", box)
title("Panel B: Medium-Skilled") saving(medium, replace);
graph export medium.eps, replace;
#delimit cr;


*****share high-skilled
**********************
#delimit;
scatter high time, ylabel(0.05(0.05)0.25) xlabel(1(2)11, valuelabel)
xline(6.5) xline(8.5, lpatter(dash)) scheme(s2mono) ytitle("High-Skilled")
text(0.25 5.7 "2 months", box) text(0.25 7.3 "6 months", box)
title("Panel C: High-Skilled") saving(high, replace);
graph export high.eps, replace;
#delimit cr;


*****share university
**********************
#delimit;
scatter uni time, ylabel(0.05(0.025)0.15) xlabel(1(2)11, valuelabel)
xline(6.5) xline(8.5, lpatter(dash)) scheme(s2mono) ytitle("University")
text(0.15 3.7 "2 months", box) text(0.15 5.3 "6 months", box)
title("University") saving(uni, replace);
graph export uni.eps, replace;
#delimit cr;


*****share high track
**********************
#delimit;
scatter hightrack time, ylabel(0.2(0.05)0.4) xlabel(1(2)11, valuelabel)
xline(6.5) xline(8.5, lpatter(dash)) scheme(s2mono) ytitle("Graduation High Track")
text(0.4 5.7 "2 months", box) text(0.4 7.3 "6 months", box)
title("Graduation High Track") saving(hightrack, replace);
graph export hightrack.eps, replace;
#delimit cr;

*****years of education
**********************
#delimit;
scatter educ time, ylabel(19(0.25)20.5) xlabel(1(2)11, valuelabel)
xline(6.5) xline(8.5, lpatter(dash)) scheme(s2mono) ytitle("Years of Education")
text(20.5 5.7 "2 months", box) text(20.5 7.3 "6 months", box)
title("Panel D: Years of Education") saving(educ, replace);
graph export educ.eps, replace;
#delimit cr;


*****wages
**********************
#delimit;
scatter lnwFT time, ylabel(4.95(0.05)5.15) xlabel(1(2)11, valuelabel)
xline(6.5) xline(8.5, lpatter(dash)) scheme(s2mono) ytitle("Log-Wages")
text(5.15 5.7 "2 months", box) text(5.15 7.3 "6 months", box)
title("Panel E: Log-Wages") saving(wages, replace);
graph export wages.eps, replace;
#delimit cr;

*****full-time work
**********************
#delimit;
scatter validFT time, ylabel(0.5(0.025)0.6) xlabel(1(2)11, valuelabel)
xline(6.5) xline(8.5, lpatter(dash)) scheme(s2mono) ytitle("full-time employment")
text(0.6 5.7 "2 months", box) text(0.6 7.3 "6 months", box)
title("Panel F: Full-Time Employment") saving(fulltime, replace);
graph export fulltime.eps, replace;
#delimit cr;


*****Share in data
**********************

***merge number of births
sort time
save aggdata, replace

clear
use births1976_1982
gen all=german+foreigners
keep year months all german
keep if (year==1978&months>=11)|(year==1979&months<=10)

gen time=months-10 if months>=11
replace time=months+2 if months<=10

sort time
merge time using aggdata
tab _merge
drop _merge

gen share=N/all

#delimit;
scatter share time, ylabel(0.85(0.05)1.15) xlabel(1(2)11, valuelabel)
xline(4.5) xline(6.5, lpatter(dash)) scheme(s2mono) ytitle("Ever in Data")
text(1.15 3.7 "2 months", box) text(1.15 5.3 "6 months", box)
title("Ever in Data") saving(everindata, replace);
graph export everindata.eps, replace;
#delimit cr;


log close

