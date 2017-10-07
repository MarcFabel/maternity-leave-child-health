*cd Uta/Maternityleave-mothers

cap log close
log using figure2.log, replace


******************************************
*share of women who take maternity leave, by year
*IABS-Plus versus approximation
****************************************

******************************
******approximation
*******************************

***number of observations in the data
****************************************
use observations_year, clear

*drop 1976 as January is missing; March onwards is missing for 1996
drop if byear==1976|byear==1996

save help, replace

***number of births
****************************************
use births_germancitizens_west, clear
rename c1 byear
rename c2 births
drop if byear==1976

sort byear 
merge byear using help
tab _merge
drop _merge

gen approximation=N/births

sort byear
save help, replace

******************************
******merge more reliable information based on IABS-Plus
*******************************

clear
use maternity_MLchildren_agg
rename kyear byear
sort byear
merge byear using help
tab _merge
drop _merge

**************Analysis
************************
gen diff_true_appr=leaverobust-approximation

sort byear
list byear approximation leaverobust diff

*adjustment factor
reg diff


****************Figure
***********************************************

drop if byear>1993
label variable byear "year of birth"

label variable leaverobust "IABS 75-95 Plus"

#delimit;
scatter appro leaverobust byear, xlabel(1977(2)1993)
connect(l l) lpattern(solid dash) scheme(s2mono)
ytitle("share maternity leave")
xline(1979) xline(1985.5) xline(1991.5) xline(1992.5)
ylabel(0.3(0.05)0.6)
text(0.6 1977.85 "JP: 2, MB: 2", size(vsmall))
text(0.6 1982.5 "JP:6, MB: 6", size(vsmall))
text(0.6 1986.3 "JP: 10", size(vsmall))
text(0.585 1986.3 "MB: 10",size(vsmall)) 
text(0.6 1990.6 "JP: 18", size(vsmall))
text(0.585 1990.6 "MB: 18",size(vsmall))
text(0.6 1992 "JP: 36", size(vsmall))
text(0.585 1992 "MB: 18",size(vsmall))
text(0.6 1993.04 "JP: 36", size(vsmall))
text(0.585 1993.04 "MB: 24",size(vsmall))
saving(maternity.gph, replace); 

graph export maternity.eps, replace;


erase help.dta;



log close;
