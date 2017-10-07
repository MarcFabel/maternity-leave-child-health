****************************************************
*How many go on maternity leave? Project Long-term Impact of Expansions on Children
**********************************************************

clear
clear matrix
set mem 1000m


cap log close
log using maternity_MLchildren.log, replace
clear
use maternityleave

*keep West Germany, German citizens
keep if east==0&foreign==0

**keep 1985 to 1995
keep if kyear>=1985&kyear<=1995

***keep relevant states
keep if bulakid==1|bulakid==6|bulakid==9

*****leave taking by year
tab kyear, sum(leaverobust)

****get standard errors
sort kyear
by kyear: reg leaverobust 

****leave taking over the sample we study
gen kmonth=month(kgeb)

******1992 reform
************************

**one month before, one month after
reg leaverobust if (kyear==1991&kmonth==12)|(kyear==1992&kmonth==1)
**two months before, two months after
reg leaverobust if (kyear==1991&(kmonth==12|kmonth==11))|(kyear==1992&(kmonth==1|kmonth==2))
**three months before, three months after
reg leaverobust if (kyear==1991&(kmonth==12|kmonth==11|kmonth==10))|(kyear==1992&(kmonth==1|kmonth==2|kmonth==3))
**three months before, three months after, excluding January and December
reg leaverobust if (kyear==1991&(kmonth==11|kmonth==10))|(kyear==1992&(kmonth==2|kmonth==3))
**four months before, four months after
reg leaverobust if (kyear==1991&(kmonth==12|kmonth==11|kmonth==10|kmonth==9))|(kyear==1992&(kmonth==1|kmonth==2|kmonth==3|kmonth==4))
**six months before, six months after
reg leaverobust if (kyear==1991&(kmonth==12|kmonth==11|kmonth==10|kmonth==9|kmonth==8|kmonth==7))|(kyear==1992&(kmonth==1|kmonth==2|kmonth==3|kmonth==4|kmonth==5|kmonth==6))
**six months before, six months after, excluding January and December
reg leaverobust if (kyear==1991&(kmonth==11|kmonth==10|kmonth==9|kmonth==8|kmonth==7))|(kyear==1992&(kmonth==2|kmonth==3|kmonth==4|kmonth==5|kmonth==6))


**six months before, six months after, excluding November to December
reg leaverobust if (kyear==1991&(kmonth==10|kmonth==9|kmonth==8|kmonth==7))|(kyear==1992&(kmonth==1|kmonth==2|kmonth==3|kmonth==4|kmonth==5|kmonth==6))
**six months before, six months after, excluding September to December
reg leaverobust if (kyear==1991&(kmonth==8|kmonth==7))|(kyear==1992&(kmonth==1|kmonth==2|kmonth==3|kmonth==4|kmonth==5|kmonth==6))


******1986 reform
****************************

***one month before, one month after
reg leaverobust if (kyear==1985&kmonth==12)|(kyear==1986&kmonth==1)
**two months before, two months after
reg leaverobust if (kyear==1985&(kmonth==12|kmonth==11))|(kyear==1986&(kmonth==1|kmonth==2))
**three months before, three months after
reg leaverobust if (kyear==1985&(kmonth==12|kmonth==11|kmonth==10))|(kyear==1986&(kmonth==1|kmonth==2|kmonth==3))
**three months before, three months after, excluding January and December
reg leaverobust if (kyear==1985&(kmonth==11|kmonth==10))|(kyear==1986&(kmonth==2|kmonth==3))
**four months before, four months after
reg leaverobust if (kyear==1985&(kmonth==12|kmonth==11|kmonth==10|kmonth==9))|(kyear==1986&(kmonth==1|kmonth==2|kmonth==3|kmonth==4))
**four months before, six months after
reg leaverobust if (kyear==1985&(kmonth==12|kmonth==11|kmonth==10|kmonth==9))|(kyear==1986&(kmonth==1|kmonth==2|kmonth==3|kmonth==4|kmonth==5|kmonth==6))
**four months before, six months after, excluding January and December
reg leaverobust if (kyear==1985&(kmonth==11|kmonth==10|kmonth==9))|(kyear==1986&(kmonth==2|kmonth==3|kmonth==4|kmonth==5|kmonth==6))

**four months before, six months after, excluding November and December
reg leaverobust if (kyear==1985&(kmonth==10|kmonth==9))|(kyear==1986&(kmonth==1|kmonth==2|kmonth==3|kmonth==4|kmonth==5|kmonth==6))

**six months before, six months after, excluding November and December
reg leaverobust if (kyear==1985&(kmonth==10|kmonth==9|kmonth==8|kmonth==7))|(kyear==1986&(kmonth==1|kmonth==2|kmonth==3|kmonth==4|kmonth==5|kmonth==6))

**six months before, six months after, excluding September to December
reg leaverobust if (kyear==1985&(kmonth==8|kmonth==7))|(kyear==1986&(kmonth==1|kmonth==2|kmonth==3|kmonth==4|kmonth==5|kmonth==6))

*collapse data for figure: by year
********************************************

clear
use maternityleave

*keep West Germany, German citizens
keep if east==0&foreign==0

**keep 1985 to 1995
keep if kyear>=1985&kyear<=1995


sort kyear
collapse leaverobust, by(kyear)

save maternity_MLchildren_agg, replace

log close
