/*****************************************************************************************************
Share of women on maternity leave in 1979 -- approximated as share number of observations and share births
**************************************************************************************************/


cd D:\Datenaustausch\KEM\Ludsteck\MaternityLeave\Data

capture log close
log using Mlchildren\MaternityLeave_1979.log, replace

clear
clear matrix
set more off
set mem 1000m

use D:\Datenaustausch\KEM\Ludsteck\MaternityLeave\Data\births1976_1982, clear
rename year byear
rename month bmonth
keep byear bmonth german
sort byear bmonth
save help, replace

use D:\Datenaustausch\KEM\Ludsteck\MaternityLeave\Data\aggdata_prebirth, clear
keep if byear>=1976&byear<=1982
****aggregate states up
keep byear bmonth birthbula N
sort byear bmonth birthbula
collapse (sum) N, by(byear bmonth)
sort byear bmonth
merge byear bmonth using help
tab _merge
list if _merge==2
drop if _merge==2
drop _merge

gen share=N/german


******one month before, one month after
reg share if byear==1979&(bmonth==4|bmonth==5)
*compute SE and mean share based on N
sort byear bmonth
gen sample=0
replace sample=1 if byear==1979&(bmonth==4|bmonth==5)
egen Nobs=sum(N) if sample==1
gen help=N*share
egen share_sample=sum(help) if sample==1
replace share_sample=share_sample/Nobs if sample==1
gen se_share_sample=sqrt(share_sample*(1-share_sample)/Nobs)
sum share_sample se_share_sample
drop sample Nobs help share_sample se_share_sample


******two months before, two months after
reg share if byear==1979&(bmonth==3|bmonth==4|bmonth==5|bmonth==6)
*compute SE and mean share based on N
sort byear bmonth
gen sample=0
replace sample=1 if byear==1979&(bmonth==3|bmonth==4|bmonth==5|bmonth==6)
egen Nobs=sum(N) if sample==1
gen help=N*share
egen share_sample=sum(help) if sample==1
replace share_sample=share_sample/Nobs if sample==1
gen se_share_sample=sqrt(share_sample*(1-share_sample)/Nobs)
sum share_sample se_share_sample
drop sample Nobs help share_sample se_share_sample



******four months before, two months after
reg share if byear==1979&(bmonth==1|bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)
*compute SE and mean share based on N
sort byear bmonth
gen sample=0
replace sample=1 if byear==1979&(bmonth==1|bmonth==2|bmonth==3|bmonth==4|bmonth==5|bmonth==6)
egen Nobs=sum(N) if sample==1
gen help=N*share
egen share_sample=sum(help) if sample==1
replace share_sample=share_sample/Nobs if sample==1
gen se_share_sample=sqrt(share_sample*(1-share_sample)/Nobs)
sum share_sample se_share_sample
drop sample Nobs help share_sample se_share_sample

******six months before, six months after
reg share if (byear==1978&bmonth>=11)|(byear==1979&bmonth<=10)
*compute SE and mean share based on N
sort byear bmonth
gen sample=0
replace sample=1 if (byear==1978&bmonth>=11)|(byear==1979&bmonth<=10)
egen Nobs=sum(N) if sample==1
gen help=N*share
egen share_sample=sum(help) if sample==1
replace share_sample=share_sample/Nobs if sample==1
gen se_share_sample=sqrt(share_sample*(1-share_sample)/Nobs)
sum share_sample se_share_sample
drop sample Nobs help share_sample se_share_sample


******six months before, six months after, excluding April and May
reg share if (byear==1978&bmonth>=11)|(byear==1979&(bmonth==1|bmonth==2|bmonth==3|bmonth==6|bmonth==7|bmonth==8|bmonth==9|bmonth==10))
*compute SE and mean share based on N
sort byear bmonth
gen sample=0
replace sample=1 if (byear==1978&bmonth>=11)|(byear==1979&(bmonth==1|bmonth==2|bmonth==3|bmonth==6|bmonth==7|bmonth==8|bmonth==9|bmonth==10))
egen Nobs=sum(N) if sample==1
gen help=N*share
egen share_sample=sum(help) if sample==1
replace share_sample=share_sample/Nobs if sample==1
gen se_share_sample=sqrt(share_sample*(1-share_sample)/Nobs)
sum share_sample se_share_sample
drop sample Nobs help share_sample se_share_sample



******six months before, six months after, excluding April and March
reg share if (byear==1978&bmonth>=11)|(byear==1979&(bmonth==1|bmonth==2|bmonth==5|bmonth==6|bmonth==7|bmonth==8|bmonth==9|bmonth==10))
*compute SE and mean share based on N
sort byear bmonth
gen sample=0
replace sample=1 if (byear==1978&bmonth>=11)|(byear==1979&(bmonth==1|bmonth==2|bmonth==5|bmonth==6|bmonth==7|bmonth==8|bmonth==9|bmonth==10))
egen Nobs=sum(N) if sample==1
gen help=N*share
egen share_sample=sum(help) if sample==1
replace share_sample=share_sample/Nobs if sample==1
gen se_share_sample=sqrt(share_sample*(1-share_sample)/Nobs)
sum share_sample se_share_sample
drop sample Nobs help share_sample se_share_sample

******six months before, six months after, excluding January to April
reg share if (byear==1978&bmonth>=11)|(byear==1979&(bmonth==5|bmonth==6|bmonth==7|bmonth==8|bmonth==9|bmonth==10))
*compute SE and mean share based on N
sort byear bmonth
gen sample=0
replace sample=1 if (byear==1978&bmonth>=11)|(byear==1979&(bmonth==5|bmonth==6|bmonth==7|bmonth==8|bmonth==9|bmonth==10))
egen Nobs=sum(N) if sample==1
gen help=N*share
egen share_sample=sum(help) if sample==1
replace share_sample=share_sample/Nobs if sample==1
gen se_share_sample=sqrt(share_sample*(1-share_sample)/Nobs)
sum share_sample se_share_sample
drop sample Nobs help share_sample se_share_sample


log close
