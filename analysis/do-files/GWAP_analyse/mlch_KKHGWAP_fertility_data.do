drop _all 

set obs 15
gen YOB = _n
expand 12

qui replace YOB = YOB + 1974
sort YOB 

bys YOB: gen MOB = _n
expand 16 
bys YOB MOB: gen bula = _n 
drop if bula >= 11

********************************************************************************
// Fertility Bundesland
qui gen fert_bula = . 
qui replace fert_bula = 2019 	if YOB == 1975 & MOB == 1	& bula == 1	
qui replace fert_bula = 1989 	if YOB == 1975 & MOB == 2	& bula == 1	
qui replace fert_bula = 2124 	if YOB == 1975 & MOB == 3	& bula == 1	
qui replace fert_bula = 2089 	if YOB == 1975 & MOB == 4	& bula == 1	
qui replace fert_bula = 2123 	if YOB == 1975 & MOB == 5	& bula == 1	
qui replace fert_bula = 2015 	if YOB == 1975 & MOB == 6	& bula == 1	
qui replace fert_bula = 2095 	if YOB == 1975 & MOB == 7	& bula == 1	
qui replace fert_bula = 2007 	if YOB == 1975 & MOB == 8	& bula == 1	
qui replace fert_bula = 2017 	if YOB == 1975 & MOB == 9	& bula == 1	
qui replace fert_bula = 1942 	if YOB == 1975 & MOB == 10	& bula == 1	
qui replace fert_bula = 1850 	if YOB == 1975 & MOB == 11	& bula == 1	
qui replace fert_bula = 2012 	if YOB == 1975 & MOB == 12	& bula == 1	
qui replace fert_bula = 1175 	if YOB == 1975 & MOB == 1	& bula == 2	
qui replace fert_bula = 1098 	if YOB == 1975 & MOB == 2	& bula == 2	
qui replace fert_bula = 1118 	if YOB == 1975 & MOB == 3	& bula == 2	
qui replace fert_bula = 1116 	if YOB == 1975 & MOB == 4	& bula == 2	
qui replace fert_bula = 1169 	if YOB == 1975 & MOB == 5	& bula == 2	
qui replace fert_bula = 1131 	if YOB == 1975 & MOB == 6	& bula == 2	
qui replace fert_bula = 1148 	if YOB == 1975 & MOB == 7	& bula == 2	
qui replace fert_bula = 1104 	if YOB == 1975 & MOB == 8	& bula == 2	
qui replace fert_bula = 1082 	if YOB == 1975 & MOB == 9	& bula == 2	
qui replace fert_bula = 1026 	if YOB == 1975 & MOB == 10	& bula == 2	
qui replace fert_bula = 996 	if YOB == 1975 & MOB == 11	& bula == 2	
qui replace fert_bula = 1029 	if YOB == 1975 & MOB == 12	& bula == 2	
qui replace fert_bula = 6253 	if YOB == 1975 & MOB == 1	& bula == 3	
qui replace fert_bula = 5754 	if YOB == 1975 & MOB == 2	& bula == 3	
qui replace fert_bula = 6315 	if YOB == 1975 & MOB == 3	& bula == 3	
qui replace fert_bula = 6486 	if YOB == 1975 & MOB == 4	& bula == 3	
qui replace fert_bula = 6221 	if YOB == 1975 & MOB == 5	& bula == 3	
qui replace fert_bula = 6063 	if YOB == 1975 & MOB == 6	& bula == 3	
qui replace fert_bula = 6267 	if YOB == 1975 & MOB == 7	& bula == 3	
qui replace fert_bula = 5990 	if YOB == 1975 & MOB == 8	& bula == 3	
qui replace fert_bula = 5918 	if YOB == 1975 & MOB == 9	& bula == 3	
qui replace fert_bula = 5577 	if YOB == 1975 & MOB == 10	& bula == 3	
qui replace fert_bula = 5352 	if YOB == 1975 & MOB == 11	& bula == 3	
qui replace fert_bula = 5768 	if YOB == 1975 & MOB == 12	& bula == 3	
qui replace fert_bula = 547 	if YOB == 1975 & MOB == 1	& bula == 4	
qui replace fert_bula = 468 	if YOB == 1975 & MOB == 2	& bula == 4	
qui replace fert_bula = 546 	if YOB == 1975 & MOB == 3	& bula == 4	
qui replace fert_bula = 540 	if YOB == 1975 & MOB == 4	& bula == 4	
qui replace fert_bula = 518 	if YOB == 1975 & MOB == 5	& bula == 4	
qui replace fert_bula = 576 	if YOB == 1975 & MOB == 6	& bula == 4	
qui replace fert_bula = 582 	if YOB == 1975 & MOB == 7	& bula == 4	
qui replace fert_bula = 557 	if YOB == 1975 & MOB == 8	& bula == 4	
qui replace fert_bula = 561 	if YOB == 1975 & MOB == 9	& bula == 4	
qui replace fert_bula = 499 	if YOB == 1975 & MOB == 10	& bula == 4	
qui replace fert_bula = 514 	if YOB == 1975 & MOB == 11	& bula == 4	
qui replace fert_bula = 521 	if YOB == 1975 & MOB == 12	& bula == 4	
qui replace fert_bula = 14190 	if YOB == 1975 & MOB == 1	& bula == 5	
qui replace fert_bula = 12894 	if YOB == 1975 & MOB == 2	& bula == 5	
qui replace fert_bula = 14245 	if YOB == 1975 & MOB == 3	& bula == 5	
qui replace fert_bula = 13891 	if YOB == 1975 & MOB == 4	& bula == 5	
qui replace fert_bula = 14525 	if YOB == 1975 & MOB == 5	& bula == 5	
qui replace fert_bula = 13770 	if YOB == 1975 & MOB == 6	& bula == 5	
qui replace fert_bula = 14606 	if YOB == 1975 & MOB == 7	& bula == 5	
qui replace fert_bula = 13717 	if YOB == 1975 & MOB == 8	& bula == 5	
qui replace fert_bula = 13667 	if YOB == 1975 & MOB == 9	& bula == 5	
qui replace fert_bula = 13095 	if YOB == 1975 & MOB == 10	& bula == 5	
qui replace fert_bula = 12282 	if YOB == 1975 & MOB == 11	& bula == 5	
qui replace fert_bula = 13346 	if YOB == 1975 & MOB == 12	& bula == 5	
qui replace fert_bula = 4588 	if YOB == 1975 & MOB == 1	& bula == 6	
qui replace fert_bula = 4282 	if YOB == 1975 & MOB == 2	& bula == 6	
qui replace fert_bula = 4680 	if YOB == 1975 & MOB == 3	& bula == 6	
qui replace fert_bula = 4514 	if YOB == 1975 & MOB == 4	& bula == 6	
qui replace fert_bula = 4518 	if YOB == 1975 & MOB == 5	& bula == 6	
qui replace fert_bula = 4402 	if YOB == 1975 & MOB == 6	& bula == 6	
qui replace fert_bula = 4575 	if YOB == 1975 & MOB == 7	& bula == 6	
qui replace fert_bula = 4510 	if YOB == 1975 & MOB == 8	& bula == 6	
qui replace fert_bula = 4513 	if YOB == 1975 & MOB == 9	& bula == 6	
qui replace fert_bula = 4265 	if YOB == 1975 & MOB == 10	& bula == 6	
qui replace fert_bula = 4112 	if YOB == 1975 & MOB == 11	& bula == 6	
qui replace fert_bula = 4217 	if YOB == 1975 & MOB == 12	& bula == 6	
qui replace fert_bula = 3046 	if YOB == 1975 & MOB == 1	& bula == 7	
qui replace fert_bula = 2840 	if YOB == 1975 & MOB == 2	& bula == 7	
qui replace fert_bula = 3124 	if YOB == 1975 & MOB == 3	& bula == 7	
qui replace fert_bula = 2907 	if YOB == 1975 & MOB == 4	& bula == 7	
qui replace fert_bula = 2875 	if YOB == 1975 & MOB == 5	& bula == 7	
qui replace fert_bula = 2820 	if YOB == 1975 & MOB == 6	& bula == 7	
qui replace fert_bula = 2978 	if YOB == 1975 & MOB == 7	& bula == 7	
qui replace fert_bula = 2978 	if YOB == 1975 & MOB == 8	& bula == 7	
qui replace fert_bula = 2722 	if YOB == 1975 & MOB == 9	& bula == 7	
qui replace fert_bula = 2818 	if YOB == 1975 & MOB == 10	& bula == 7	
qui replace fert_bula = 2563 	if YOB == 1975 & MOB == 11	& bula == 7	
qui replace fert_bula = 2706 	if YOB == 1975 & MOB == 12	& bula == 7	
qui replace fert_bula = 8391 	if YOB == 1975 & MOB == 1	& bula == 8	
qui replace fert_bula = 7790 	if YOB == 1975 & MOB == 2	& bula == 8	
qui replace fert_bula = 8524 	if YOB == 1975 & MOB == 3	& bula == 8	
qui replace fert_bula = 8146 	if YOB == 1975 & MOB == 4	& bula == 8	
qui replace fert_bula = 8535 	if YOB == 1975 & MOB == 5	& bula == 8	
qui replace fert_bula = 8115 	if YOB == 1975 & MOB == 6	& bula == 8	
qui replace fert_bula = 8524 	if YOB == 1975 & MOB == 7	& bula == 8	
qui replace fert_bula = 8115 	if YOB == 1975 & MOB == 8	& bula == 8	
qui replace fert_bula = 8161 	if YOB == 1975 & MOB == 9	& bula == 8	
qui replace fert_bula = 7582 	if YOB == 1975 & MOB == 10	& bula == 8	
qui replace fert_bula = 7389 	if YOB == 1975 & MOB == 11	& bula == 8	
qui replace fert_bula = 7747 	if YOB == 1975 & MOB == 12	& bula == 8	
qui replace fert_bula = 9510 	if YOB == 1975 & MOB == 1	& bula == 9	
qui replace fert_bula = 8839 	if YOB == 1975 & MOB == 2	& bula == 9	
qui replace fert_bula = 9771 	if YOB == 1975 & MOB == 3	& bula == 9	
qui replace fert_bula = 9325 	if YOB == 1975 & MOB == 4	& bula == 9	
qui replace fert_bula = 9452 	if YOB == 1975 & MOB == 5	& bula == 9	
qui replace fert_bula = 8946 	if YOB == 1975 & MOB == 6	& bula == 9	
qui replace fert_bula = 9587 	if YOB == 1975 & MOB == 7	& bula == 9	
qui replace fert_bula = 8925 	if YOB == 1975 & MOB == 8	& bula == 9	
qui replace fert_bula = 9114 	if YOB == 1975 & MOB == 9	& bula == 9	
qui replace fert_bula = 8388 	if YOB == 1975 & MOB == 10	& bula == 9	
qui replace fert_bula = 7878 	if YOB == 1975 & MOB == 11	& bula == 9	
qui replace fert_bula = 8809 	if YOB == 1975 & MOB == 12	& bula == 9	
qui replace fert_bula = 830 	if YOB == 1975 & MOB == 1	& bula == 10	
qui replace fert_bula = 812 	if YOB == 1975 & MOB == 2	& bula == 10	
qui replace fert_bula = 750 	if YOB == 1975 & MOB == 3	& bula == 10	
qui replace fert_bula = 875 	if YOB == 1975 & MOB == 4	& bula == 10	
qui replace fert_bula = 787 	if YOB == 1975 & MOB == 5	& bula == 10	
qui replace fert_bula = 798 	if YOB == 1975 & MOB == 6	& bula == 10	
qui replace fert_bula = 802 	if YOB == 1975 & MOB == 7	& bula == 10	
qui replace fert_bula = 802 	if YOB == 1975 & MOB == 8	& bula == 10	
qui replace fert_bula = 822 	if YOB == 1975 & MOB == 9	& bula == 10	
qui replace fert_bula = 774 	if YOB == 1975 & MOB == 10	& bula == 10	
qui replace fert_bula = 718 	if YOB == 1975 & MOB == 11	& bula == 10	
qui replace fert_bula = 815 	if YOB == 1975 & MOB == 12	& bula == 10	
qui replace fert_bula = 1515 	if YOB == 1975 & MOB == 1	& bula == 11	
qui replace fert_bula = 1402 	if YOB == 1975 & MOB == 2	& bula == 11	
qui replace fert_bula = 1569 	if YOB == 1975 & MOB == 3	& bula == 11	
qui replace fert_bula = 1437 	if YOB == 1975 & MOB == 4	& bula == 11	
qui replace fert_bula = 1523 	if YOB == 1975 & MOB == 5	& bula == 11	
qui replace fert_bula = 1494 	if YOB == 1975 & MOB == 6	& bula == 11	
qui replace fert_bula = 1584 	if YOB == 1975 & MOB == 7	& bula == 11	
qui replace fert_bula = 1532 	if YOB == 1975 & MOB == 8	& bula == 11	
qui replace fert_bula = 1427 	if YOB == 1975 & MOB == 9	& bula == 11	
qui replace fert_bula = 1462 	if YOB == 1975 & MOB == 10	& bula == 11	
qui replace fert_bula = 1384 	if YOB == 1975 & MOB == 11	& bula == 11	
qui replace fert_bula = 1387 	if YOB == 1975 & MOB == 12	& bula == 11	
qui replace fert_bula = 2101 	if YOB == 1976 & MOB == 1	& bula == 1	
qui replace fert_bula = 2006 	if YOB == 1976 & MOB == 2	& bula == 1	
qui replace fert_bula = 2246 	if YOB == 1976 & MOB == 3	& bula == 1	
qui replace fert_bula = 2077 	if YOB == 1976 & MOB == 4	& bula == 1	
qui replace fert_bula = 2100 	if YOB == 1976 & MOB == 5	& bula == 1	
qui replace fert_bula = 2029 	if YOB == 1976 & MOB == 6	& bula == 1	
qui replace fert_bula = 2163 	if YOB == 1976 & MOB == 7	& bula == 1	
qui replace fert_bula = 2108 	if YOB == 1976 & MOB == 8	& bula == 1	
qui replace fert_bula = 2166 	if YOB == 1976 & MOB == 9	& bula == 1	
qui replace fert_bula = 1990 	if YOB == 1976 & MOB == 10	& bula == 1	
qui replace fert_bula = 1899 	if YOB == 1976 & MOB == 11	& bula == 1	
qui replace fert_bula = 1976 	if YOB == 1976 & MOB == 12	& bula == 1	
qui replace fert_bula = 1203 	if YOB == 1976 & MOB == 1	& bula == 2	
qui replace fert_bula = 1114 	if YOB == 1976 & MOB == 2	& bula == 2	
qui replace fert_bula = 1211 	if YOB == 1976 & MOB == 3	& bula == 2	
qui replace fert_bula = 1164 	if YOB == 1976 & MOB == 4	& bula == 2	
qui replace fert_bula = 1107 	if YOB == 1976 & MOB == 5	& bula == 2	
qui replace fert_bula = 1146 	if YOB == 1976 & MOB == 6	& bula == 2	
qui replace fert_bula = 1149 	if YOB == 1976 & MOB == 7	& bula == 2	
qui replace fert_bula = 1166 	if YOB == 1976 & MOB == 8	& bula == 2	
qui replace fert_bula = 1130 	if YOB == 1976 & MOB == 9	& bula == 2	
qui replace fert_bula = 1071 	if YOB == 1976 & MOB == 10	& bula == 2	
qui replace fert_bula = 1069 	if YOB == 1976 & MOB == 11	& bula == 2	
qui replace fert_bula = 1071 	if YOB == 1976 & MOB == 12	& bula == 2	
qui replace fert_bula = 6304 	if YOB == 1976 & MOB == 1	& bula == 3	
qui replace fert_bula = 5860 	if YOB == 1976 & MOB == 2	& bula == 3	
qui replace fert_bula = 6413 	if YOB == 1976 & MOB == 3	& bula == 3	
qui replace fert_bula = 6022 	if YOB == 1976 & MOB == 4	& bula == 3	
qui replace fert_bula = 6090 	if YOB == 1976 & MOB == 5	& bula == 3	
qui replace fert_bula = 6115 	if YOB == 1976 & MOB == 6	& bula == 3	
qui replace fert_bula = 6176 	if YOB == 1976 & MOB == 7	& bula == 3	
qui replace fert_bula = 6326 	if YOB == 1976 & MOB == 8	& bula == 3	
qui replace fert_bula = 6253 	if YOB == 1976 & MOB == 9	& bula == 3	
qui replace fert_bula = 5712 	if YOB == 1976 & MOB == 10	& bula == 3	
qui replace fert_bula = 5630 	if YOB == 1976 & MOB == 11	& bula == 3	
qui replace fert_bula = 5533 	if YOB == 1976 & MOB == 12	& bula == 3	
qui replace fert_bula = 558 	if YOB == 1976 & MOB == 1	& bula == 4	
qui replace fert_bula = 499 	if YOB == 1976 & MOB == 2	& bula == 4	
qui replace fert_bula = 552 	if YOB == 1976 & MOB == 3	& bula == 4	
qui replace fert_bula = 518 	if YOB == 1976 & MOB == 4	& bula == 4	
qui replace fert_bula = 535 	if YOB == 1976 & MOB == 5	& bula == 4	
qui replace fert_bula = 544 	if YOB == 1976 & MOB == 6	& bula == 4	
qui replace fert_bula = 559 	if YOB == 1976 & MOB == 7	& bula == 4	
qui replace fert_bula = 570 	if YOB == 1976 & MOB == 8	& bula == 4	
qui replace fert_bula = 532 	if YOB == 1976 & MOB == 9	& bula == 4	
qui replace fert_bula = 544 	if YOB == 1976 & MOB == 10	& bula == 4	
qui replace fert_bula = 451 	if YOB == 1976 & MOB == 11	& bula == 4	
qui replace fert_bula = 530 	if YOB == 1976 & MOB == 12	& bula == 4	
qui replace fert_bula = 14232 	if YOB == 1976 & MOB == 1	& bula == 5	
qui replace fert_bula = 13150 	if YOB == 1976 & MOB == 2	& bula == 5	
qui replace fert_bula = 14508 	if YOB == 1976 & MOB == 3	& bula == 5	
qui replace fert_bula = 13179 	if YOB == 1976 & MOB == 4	& bula == 5	
qui replace fert_bula = 14213 	if YOB == 1976 & MOB == 5	& bula == 5	
qui replace fert_bula = 13968 	if YOB == 1976 & MOB == 6	& bula == 5	
qui replace fert_bula = 14691 	if YOB == 1976 & MOB == 7	& bula == 5	
qui replace fert_bula = 14392 	if YOB == 1976 & MOB == 8	& bula == 5	
qui replace fert_bula = 14510 	if YOB == 1976 & MOB == 9	& bula == 5	
qui replace fert_bula = 13346 	if YOB == 1976 & MOB == 10	& bula == 5	
qui replace fert_bula = 12816 	if YOB == 1976 & MOB == 11	& bula == 5	
qui replace fert_bula = 13123 	if YOB == 1976 & MOB == 12	& bula == 5	
qui replace fert_bula = 4468 	if YOB == 1976 & MOB == 1	& bula == 6	
qui replace fert_bula = 4222 	if YOB == 1976 & MOB == 2	& bula == 6	
qui replace fert_bula = 4651 	if YOB == 1976 & MOB == 3	& bula == 6	
qui replace fert_bula = 4273 	if YOB == 1976 & MOB == 4	& bula == 6	
qui replace fert_bula = 4538 	if YOB == 1976 & MOB == 5	& bula == 6	
qui replace fert_bula = 4539 	if YOB == 1976 & MOB == 6	& bula == 6	
qui replace fert_bula = 4581 	if YOB == 1976 & MOB == 7	& bula == 6	
qui replace fert_bula = 4512 	if YOB == 1976 & MOB == 8	& bula == 6	
qui replace fert_bula = 4652 	if YOB == 1976 & MOB == 9	& bula == 6	
qui replace fert_bula = 4283 	if YOB == 1976 & MOB == 10	& bula == 6	
qui replace fert_bula = 4243 	if YOB == 1976 & MOB == 11	& bula == 6	
qui replace fert_bula = 4164 	if YOB == 1976 & MOB == 12	& bula == 6	
qui replace fert_bula = 3048 	if YOB == 1976 & MOB == 1	& bula == 7	
qui replace fert_bula = 2821 	if YOB == 1976 & MOB == 2	& bula == 7	
qui replace fert_bula = 2994 	if YOB == 1976 & MOB == 3	& bula == 7	
qui replace fert_bula = 2763 	if YOB == 1976 & MOB == 4	& bula == 7	
qui replace fert_bula = 2834 	if YOB == 1976 & MOB == 5	& bula == 7	
qui replace fert_bula = 2932 	if YOB == 1976 & MOB == 6	& bula == 7	
qui replace fert_bula = 3009 	if YOB == 1976 & MOB == 7	& bula == 7	
qui replace fert_bula = 2896 	if YOB == 1976 & MOB == 8	& bula == 7	
qui replace fert_bula = 3001 	if YOB == 1976 & MOB == 9	& bula == 7	
qui replace fert_bula = 2833 	if YOB == 1976 & MOB == 10	& bula == 7	
qui replace fert_bula = 2700 	if YOB == 1976 & MOB == 11	& bula == 7	
qui replace fert_bula = 2713 	if YOB == 1976 & MOB == 12	& bula == 7	
qui replace fert_bula = 8012 	if YOB == 1976 & MOB == 1	& bula == 8	
qui replace fert_bula = 7805 	if YOB == 1976 & MOB == 2	& bula == 8	
qui replace fert_bula = 8612 	if YOB == 1976 & MOB == 3	& bula == 8	
qui replace fert_bula = 7881 	if YOB == 1976 & MOB == 4	& bula == 8	
qui replace fert_bula = 8303 	if YOB == 1976 & MOB == 5	& bula == 8	
qui replace fert_bula = 8107 	if YOB == 1976 & MOB == 6	& bula == 8	
qui replace fert_bula = 8237 	if YOB == 1976 & MOB == 7	& bula == 8	
qui replace fert_bula = 8003 	if YOB == 1976 & MOB == 8	& bula == 8	
qui replace fert_bula = 8244 	if YOB == 1976 & MOB == 9	& bula == 8	
qui replace fert_bula = 7728 	if YOB == 1976 & MOB == 10	& bula == 8	
qui replace fert_bula = 7157 	if YOB == 1976 & MOB == 11	& bula == 8	
qui replace fert_bula = 7403 	if YOB == 1976 & MOB == 12	& bula == 8	
qui replace fert_bula = 9302 	if YOB == 1976 & MOB == 1	& bula == 9	
qui replace fert_bula = 9074 	if YOB == 1976 & MOB == 2	& bula == 9	
qui replace fert_bula = 9582 	if YOB == 1976 & MOB == 3	& bula == 9	
qui replace fert_bula = 9090 	if YOB == 1976 & MOB == 4	& bula == 9	
qui replace fert_bula = 9545 	if YOB == 1976 & MOB == 5	& bula == 9	
qui replace fert_bula = 8868 	if YOB == 1976 & MOB == 6	& bula == 9	
qui replace fert_bula = 9507 	if YOB == 1976 & MOB == 7	& bula == 9	
qui replace fert_bula = 9089 	if YOB == 1976 & MOB == 8	& bula == 9	
qui replace fert_bula = 9470 	if YOB == 1976 & MOB == 9	& bula == 9	
qui replace fert_bula = 8735 	if YOB == 1976 & MOB == 10	& bula == 9	
qui replace fert_bula = 8188 	if YOB == 1976 & MOB == 11	& bula == 9	
qui replace fert_bula = 8545 	if YOB == 1976 & MOB == 12	& bula == 9	
qui replace fert_bula = 791 	if YOB == 1976 & MOB == 1	& bula == 10	
qui replace fert_bula = 772 	if YOB == 1976 & MOB == 2	& bula == 10	
qui replace fert_bula = 887 	if YOB == 1976 & MOB == 3	& bula == 10	
qui replace fert_bula = 786 	if YOB == 1976 & MOB == 4	& bula == 10	
qui replace fert_bula = 785 	if YOB == 1976 & MOB == 5	& bula == 10	
qui replace fert_bula = 813 	if YOB == 1976 & MOB == 6	& bula == 10	
qui replace fert_bula = 846 	if YOB == 1976 & MOB == 7	& bula == 10	
qui replace fert_bula = 856 	if YOB == 1976 & MOB == 8	& bula == 10	
qui replace fert_bula = 755 	if YOB == 1976 & MOB == 9	& bula == 10	
qui replace fert_bula = 787 	if YOB == 1976 & MOB == 10	& bula == 10	
qui replace fert_bula = 776 	if YOB == 1976 & MOB == 11	& bula == 10	
qui replace fert_bula = 747 	if YOB == 1976 & MOB == 12	& bula == 10	
qui replace fert_bula = 1519 	if YOB == 1976 & MOB == 1	& bula == 11	
qui replace fert_bula = 1424 	if YOB == 1976 & MOB == 2	& bula == 11	
qui replace fert_bula = 1530 	if YOB == 1976 & MOB == 3	& bula == 11	
qui replace fert_bula = 1401 	if YOB == 1976 & MOB == 4	& bula == 11	
qui replace fert_bula = 1460 	if YOB == 1976 & MOB == 5	& bula == 11	
qui replace fert_bula = 1542 	if YOB == 1976 & MOB == 6	& bula == 11	
qui replace fert_bula = 1459 	if YOB == 1976 & MOB == 7	& bula == 11	
qui replace fert_bula = 1622 	if YOB == 1976 & MOB == 8	& bula == 11	
qui replace fert_bula = 1507 	if YOB == 1976 & MOB == 9	& bula == 11	
qui replace fert_bula = 1438 	if YOB == 1976 & MOB == 10	& bula == 11	
qui replace fert_bula = 1397 	if YOB == 1976 & MOB == 11	& bula == 11	
qui replace fert_bula = 1378 	if YOB == 1976 & MOB == 12	& bula == 11	
qui replace fert_bula = 1891 	if YOB == 1977 & MOB == 1	& bula == 1	
qui replace fert_bula = 1859 	if YOB == 1977 & MOB == 2	& bula == 1	
qui replace fert_bula = 2142 	if YOB == 1977 & MOB == 3	& bula == 1	
qui replace fert_bula = 1977 	if YOB == 1977 & MOB == 4	& bula == 1	
qui replace fert_bula = 1988 	if YOB == 1977 & MOB == 5	& bula == 1	
qui replace fert_bula = 1942 	if YOB == 1977 & MOB == 6	& bula == 1	
qui replace fert_bula = 1992 	if YOB == 1977 & MOB == 7	& bula == 1	
qui replace fert_bula = 1990 	if YOB == 1977 & MOB == 8	& bula == 1	
qui replace fert_bula = 1977 	if YOB == 1977 & MOB == 9	& bula == 1	
qui replace fert_bula = 1919 	if YOB == 1977 & MOB == 10	& bula == 1	
qui replace fert_bula = 1822 	if YOB == 1977 & MOB == 11	& bula == 1	
qui replace fert_bula = 1867 	if YOB == 1977 & MOB == 12	& bula == 1	
qui replace fert_bula = 1115 	if YOB == 1977 & MOB == 1	& bula == 2	
qui replace fert_bula = 1015 	if YOB == 1977 & MOB == 2	& bula == 2	
qui replace fert_bula = 1091 	if YOB == 1977 & MOB == 3	& bula == 2	
qui replace fert_bula = 1028 	if YOB == 1977 & MOB == 4	& bula == 2	
qui replace fert_bula = 1126 	if YOB == 1977 & MOB == 5	& bula == 2	
qui replace fert_bula = 1166 	if YOB == 1977 & MOB == 6	& bula == 2	
qui replace fert_bula = 1135 	if YOB == 1977 & MOB == 7	& bula == 2	
qui replace fert_bula = 1194 	if YOB == 1977 & MOB == 8	& bula == 2	
qui replace fert_bula = 1050 	if YOB == 1977 & MOB == 9	& bula == 2	
qui replace fert_bula = 1158 	if YOB == 1977 & MOB == 10	& bula == 2	
qui replace fert_bula = 967 	if YOB == 1977 & MOB == 11	& bula == 2	
qui replace fert_bula = 942 	if YOB == 1977 & MOB == 12	& bula == 2	
qui replace fert_bula = 5888 	if YOB == 1977 & MOB == 1	& bula == 3	
qui replace fert_bula = 5474 	if YOB == 1977 & MOB == 2	& bula == 3	
qui replace fert_bula = 6142 	if YOB == 1977 & MOB == 3	& bula == 3	
qui replace fert_bula = 5651 	if YOB == 1977 & MOB == 4	& bula == 3	
qui replace fert_bula = 6173 	if YOB == 1977 & MOB == 5	& bula == 3	
qui replace fert_bula = 5937 	if YOB == 1977 & MOB == 6	& bula == 3	
qui replace fert_bula = 5898 	if YOB == 1977 & MOB == 7	& bula == 3	
qui replace fert_bula = 5881 	if YOB == 1977 & MOB == 8	& bula == 3	
qui replace fert_bula = 5849 	if YOB == 1977 & MOB == 9	& bula == 3	
qui replace fert_bula = 5522 	if YOB == 1977 & MOB == 10	& bula == 3	
qui replace fert_bula = 5407 	if YOB == 1977 & MOB == 11	& bula == 3	
qui replace fert_bula = 5446 	if YOB == 1977 & MOB == 12	& bula == 3	
qui replace fert_bula = 505 	if YOB == 1977 & MOB == 1	& bula == 4	
qui replace fert_bula = 477 	if YOB == 1977 & MOB == 2	& bula == 4	
qui replace fert_bula = 493 	if YOB == 1977 & MOB == 3	& bula == 4	
qui replace fert_bula = 467 	if YOB == 1977 & MOB == 4	& bula == 4	
qui replace fert_bula = 514 	if YOB == 1977 & MOB == 5	& bula == 4	
qui replace fert_bula = 528 	if YOB == 1977 & MOB == 6	& bula == 4	
qui replace fert_bula = 518 	if YOB == 1977 & MOB == 7	& bula == 4	
qui replace fert_bula = 510 	if YOB == 1977 & MOB == 8	& bula == 4	
qui replace fert_bula = 550 	if YOB == 1977 & MOB == 9	& bula == 4	
qui replace fert_bula = 448 	if YOB == 1977 & MOB == 10	& bula == 4	
qui replace fert_bula = 471 	if YOB == 1977 & MOB == 11	& bula == 4	
qui replace fert_bula = 466 	if YOB == 1977 & MOB == 12	& bula == 4	
qui replace fert_bula = 13406 	if YOB == 1977 & MOB == 1	& bula == 5	
qui replace fert_bula = 12246 	if YOB == 1977 & MOB == 2	& bula == 5	
qui replace fert_bula = 13747 	if YOB == 1977 & MOB == 3	& bula == 5	
qui replace fert_bula = 12860 	if YOB == 1977 & MOB == 4	& bula == 5	
qui replace fert_bula = 14252 	if YOB == 1977 & MOB == 5	& bula == 5	
qui replace fert_bula = 13939 	if YOB == 1977 & MOB == 6	& bula == 5	
qui replace fert_bula = 14009 	if YOB == 1977 & MOB == 7	& bula == 5	
qui replace fert_bula = 13864 	if YOB == 1977 & MOB == 8	& bula == 5	
qui replace fert_bula = 13915 	if YOB == 1977 & MOB == 9	& bula == 5	
qui replace fert_bula = 13427 	if YOB == 1977 & MOB == 10	& bula == 5	
qui replace fert_bula = 12549 	if YOB == 1977 & MOB == 11	& bula == 5	
qui replace fert_bula = 12726 	if YOB == 1977 & MOB == 12	& bula == 5	
qui replace fert_bula = 4321 	if YOB == 1977 & MOB == 1	& bula == 6	
qui replace fert_bula = 3973 	if YOB == 1977 & MOB == 2	& bula == 6	
qui replace fert_bula = 4533 	if YOB == 1977 & MOB == 3	& bula == 6	
qui replace fert_bula = 4154 	if YOB == 1977 & MOB == 4	& bula == 6	
qui replace fert_bula = 4489 	if YOB == 1977 & MOB == 5	& bula == 6	
qui replace fert_bula = 4460 	if YOB == 1977 & MOB == 6	& bula == 6	
qui replace fert_bula = 4379 	if YOB == 1977 & MOB == 7	& bula == 6	
qui replace fert_bula = 4427 	if YOB == 1977 & MOB == 8	& bula == 6	
qui replace fert_bula = 4499 	if YOB == 1977 & MOB == 9	& bula == 6	
qui replace fert_bula = 4294 	if YOB == 1977 & MOB == 10	& bula == 6	
qui replace fert_bula = 4061 	if YOB == 1977 & MOB == 11	& bula == 6	
qui replace fert_bula = 4113 	if YOB == 1977 & MOB == 12	& bula == 6	
qui replace fert_bula = 2861 	if YOB == 1977 & MOB == 1	& bula == 7	
qui replace fert_bula = 2694 	if YOB == 1977 & MOB == 2	& bula == 7	
qui replace fert_bula = 2916 	if YOB == 1977 & MOB == 3	& bula == 7	
qui replace fert_bula = 2626 	if YOB == 1977 & MOB == 4	& bula == 7	
qui replace fert_bula = 2924 	if YOB == 1977 & MOB == 5	& bula == 7	
qui replace fert_bula = 2987 	if YOB == 1977 & MOB == 6	& bula == 7	
qui replace fert_bula = 2896 	if YOB == 1977 & MOB == 7	& bula == 7	
qui replace fert_bula = 2918 	if YOB == 1977 & MOB == 8	& bula == 7	
qui replace fert_bula = 3034 	if YOB == 1977 & MOB == 9	& bula == 7	
qui replace fert_bula = 2829 	if YOB == 1977 & MOB == 10	& bula == 7	
qui replace fert_bula = 2744 	if YOB == 1977 & MOB == 11	& bula == 7	
qui replace fert_bula = 2700 	if YOB == 1977 & MOB == 12	& bula == 7	
qui replace fert_bula = 7610 	if YOB == 1977 & MOB == 1	& bula == 8	
qui replace fert_bula = 7006 	if YOB == 1977 & MOB == 2	& bula == 8	
qui replace fert_bula = 8130 	if YOB == 1977 & MOB == 3	& bula == 8	
qui replace fert_bula = 7638 	if YOB == 1977 & MOB == 4	& bula == 8	
qui replace fert_bula = 8120 	if YOB == 1977 & MOB == 5	& bula == 8	
qui replace fert_bula = 7897 	if YOB == 1977 & MOB == 6	& bula == 8	
qui replace fert_bula = 7619 	if YOB == 1977 & MOB == 7	& bula == 8	
qui replace fert_bula = 7603 	if YOB == 1977 & MOB == 8	& bula == 8	
qui replace fert_bula = 7674 	if YOB == 1977 & MOB == 9	& bula == 8	
qui replace fert_bula = 7314 	if YOB == 1977 & MOB == 10	& bula == 8	
qui replace fert_bula = 7033 	if YOB == 1977 & MOB == 11	& bula == 8	
qui replace fert_bula = 7337 	if YOB == 1977 & MOB == 12	& bula == 8	
qui replace fert_bula = 9062 	if YOB == 1977 & MOB == 1	& bula == 9	
qui replace fert_bula = 8512 	if YOB == 1977 & MOB == 2	& bula == 9	
qui replace fert_bula = 9545 	if YOB == 1977 & MOB == 3	& bula == 9	
qui replace fert_bula = 8753 	if YOB == 1977 & MOB == 4	& bula == 9	
qui replace fert_bula = 9520 	if YOB == 1977 & MOB == 5	& bula == 9	
qui replace fert_bula = 9005 	if YOB == 1977 & MOB == 6	& bula == 9	
qui replace fert_bula = 9079 	if YOB == 1977 & MOB == 7	& bula == 9	
qui replace fert_bula = 8776 	if YOB == 1977 & MOB == 8	& bula == 9	
qui replace fert_bula = 8991 	if YOB == 1977 & MOB == 9	& bula == 9	
qui replace fert_bula = 8830 	if YOB == 1977 & MOB == 10	& bula == 9	
qui replace fert_bula = 8234 	if YOB == 1977 & MOB == 11	& bula == 9	
qui replace fert_bula = 8326 	if YOB == 1977 & MOB == 12	& bula == 9	
qui replace fert_bula = 812 	if YOB == 1977 & MOB == 1	& bula == 10	
qui replace fert_bula = 742 	if YOB == 1977 & MOB == 2	& bula == 10	
qui replace fert_bula = 834 	if YOB == 1977 & MOB == 3	& bula == 10	
qui replace fert_bula = 700 	if YOB == 1977 & MOB == 4	& bula == 10	
qui replace fert_bula = 911 	if YOB == 1977 & MOB == 5	& bula == 10	
qui replace fert_bula = 853 	if YOB == 1977 & MOB == 6	& bula == 10	
qui replace fert_bula = 836 	if YOB == 1977 & MOB == 7	& bula == 10	
qui replace fert_bula = 828 	if YOB == 1977 & MOB == 8	& bula == 10	
qui replace fert_bula = 872 	if YOB == 1977 & MOB == 9	& bula == 10	
qui replace fert_bula = 815 	if YOB == 1977 & MOB == 10	& bula == 10	
qui replace fert_bula = 828 	if YOB == 1977 & MOB == 11	& bula == 10	
qui replace fert_bula = 845 	if YOB == 1977 & MOB == 12	& bula == 10	
qui replace fert_bula = 1388 	if YOB == 1977 & MOB == 1	& bula == 11	
qui replace fert_bula = 1339 	if YOB == 1977 & MOB == 2	& bula == 11	
qui replace fert_bula = 1499 	if YOB == 1977 & MOB == 3	& bula == 11	
qui replace fert_bula = 1332 	if YOB == 1977 & MOB == 4	& bula == 11	
qui replace fert_bula = 1450 	if YOB == 1977 & MOB == 5	& bula == 11	
qui replace fert_bula = 1341 	if YOB == 1977 & MOB == 6	& bula == 11	
qui replace fert_bula = 1316 	if YOB == 1977 & MOB == 7	& bula == 11	
qui replace fert_bula = 1365 	if YOB == 1977 & MOB == 8	& bula == 11	
qui replace fert_bula = 1406 	if YOB == 1977 & MOB == 9	& bula == 11	
qui replace fert_bula = 1386 	if YOB == 1977 & MOB == 10	& bula == 11	
qui replace fert_bula = 1295 	if YOB == 1977 & MOB == 11	& bula == 11	
qui replace fert_bula = 1397 	if YOB == 1977 & MOB == 12	& bula == 11	
qui replace fert_bula = 1989 	if YOB == 1978 & MOB == 1	& bula == 1	
qui replace fert_bula = 1764 	if YOB == 1978 & MOB == 2	& bula == 1	
qui replace fert_bula = 1979 	if YOB == 1978 & MOB == 3	& bula == 1	
qui replace fert_bula = 1929 	if YOB == 1978 & MOB == 4	& bula == 1	
qui replace fert_bula = 2147 	if YOB == 1978 & MOB == 5	& bula == 1	
qui replace fert_bula = 1951 	if YOB == 1978 & MOB == 6	& bula == 1	
qui replace fert_bula = 2029 	if YOB == 1978 & MOB == 7	& bula == 1	
qui replace fert_bula = 1924 	if YOB == 1978 & MOB == 8	& bula == 1	
qui replace fert_bula = 1921 	if YOB == 1978 & MOB == 9	& bula == 1	
qui replace fert_bula = 1907 	if YOB == 1978 & MOB == 10	& bula == 1	
qui replace fert_bula = 1773 	if YOB == 1978 & MOB == 11	& bula == 1	
qui replace fert_bula = 1872 	if YOB == 1978 & MOB == 12	& bula == 1	
qui replace fert_bula = 1065 	if YOB == 1978 & MOB == 1	& bula == 2	
qui replace fert_bula = 989 	if YOB == 1978 & MOB == 2	& bula == 2	
qui replace fert_bula = 1155 	if YOB == 1978 & MOB == 3	& bula == 2	
qui replace fert_bula = 1058 	if YOB == 1978 & MOB == 4	& bula == 2	
qui replace fert_bula = 1175 	if YOB == 1978 & MOB == 5	& bula == 2	
qui replace fert_bula = 1086 	if YOB == 1978 & MOB == 6	& bula == 2	
qui replace fert_bula = 1065 	if YOB == 1978 & MOB == 7	& bula == 2	
qui replace fert_bula = 1042 	if YOB == 1978 & MOB == 8	& bula == 2	
qui replace fert_bula = 1000 	if YOB == 1978 & MOB == 9	& bula == 2	
qui replace fert_bula = 1000 	if YOB == 1978 & MOB == 10	& bula == 2	
qui replace fert_bula = 996 	if YOB == 1978 & MOB == 11	& bula == 2	
qui replace fert_bula = 985 	if YOB == 1978 & MOB == 12	& bula == 2	
qui replace fert_bula = 5707 	if YOB == 1978 & MOB == 1	& bula == 3	
qui replace fert_bula = 5505 	if YOB == 1978 & MOB == 2	& bula == 3	
qui replace fert_bula = 6177 	if YOB == 1978 & MOB == 3	& bula == 3	
qui replace fert_bula = 5931 	if YOB == 1978 & MOB == 4	& bula == 3	
qui replace fert_bula = 6135 	if YOB == 1978 & MOB == 5	& bula == 3	
qui replace fert_bula = 5885 	if YOB == 1978 & MOB == 6	& bula == 3	
qui replace fert_bula = 6015 	if YOB == 1978 & MOB == 7	& bula == 3	
qui replace fert_bula = 5812 	if YOB == 1978 & MOB == 8	& bula == 3	
qui replace fert_bula = 5573 	if YOB == 1978 & MOB == 9	& bula == 3	
qui replace fert_bula = 5427 	if YOB == 1978 & MOB == 10	& bula == 3	
qui replace fert_bula = 5170 	if YOB == 1978 & MOB == 11	& bula == 3	
qui replace fert_bula = 5220 	if YOB == 1978 & MOB == 12	& bula == 3	
qui replace fert_bula = 484 	if YOB == 1978 & MOB == 1	& bula == 4	
qui replace fert_bula = 441 	if YOB == 1978 & MOB == 2	& bula == 4	
qui replace fert_bula = 528 	if YOB == 1978 & MOB == 3	& bula == 4	
qui replace fert_bula = 512 	if YOB == 1978 & MOB == 4	& bula == 4	
qui replace fert_bula = 501 	if YOB == 1978 & MOB == 5	& bula == 4	
qui replace fert_bula = 495 	if YOB == 1978 & MOB == 6	& bula == 4	
qui replace fert_bula = 505 	if YOB == 1978 & MOB == 7	& bula == 4	
qui replace fert_bula = 518 	if YOB == 1978 & MOB == 8	& bula == 4	
qui replace fert_bula = 533 	if YOB == 1978 & MOB == 9	& bula == 4	
qui replace fert_bula = 453 	if YOB == 1978 & MOB == 10	& bula == 4	
qui replace fert_bula = 409 	if YOB == 1978 & MOB == 11	& bula == 4	
qui replace fert_bula = 438 	if YOB == 1978 & MOB == 12	& bula == 4	
qui replace fert_bula = 13419 	if YOB == 1978 & MOB == 1	& bula == 5	
qui replace fert_bula = 12685 	if YOB == 1978 & MOB == 2	& bula == 5	
qui replace fert_bula = 13987 	if YOB == 1978 & MOB == 3	& bula == 5	
qui replace fert_bula = 13546 	if YOB == 1978 & MOB == 4	& bula == 5	
qui replace fert_bula = 13836 	if YOB == 1978 & MOB == 5	& bula == 5	
qui replace fert_bula = 13464 	if YOB == 1978 & MOB == 6	& bula == 5	
qui replace fert_bula = 13742 	if YOB == 1978 & MOB == 7	& bula == 5	
qui replace fert_bula = 13356 	if YOB == 1978 & MOB == 8	& bula == 5	
qui replace fert_bula = 13333 	if YOB == 1978 & MOB == 9	& bula == 5	
qui replace fert_bula = 12895 	if YOB == 1978 & MOB == 10	& bula == 5	
qui replace fert_bula = 11853 	if YOB == 1978 & MOB == 11	& bula == 5	
qui replace fert_bula = 12362 	if YOB == 1978 & MOB == 12	& bula == 5	
qui replace fert_bula = 4229 	if YOB == 1978 & MOB == 1	& bula == 6	
qui replace fert_bula = 3990 	if YOB == 1978 & MOB == 2	& bula == 6	
qui replace fert_bula = 4390 	if YOB == 1978 & MOB == 3	& bula == 6	
qui replace fert_bula = 4395 	if YOB == 1978 & MOB == 4	& bula == 6	
qui replace fert_bula = 4552 	if YOB == 1978 & MOB == 5	& bula == 6	
qui replace fert_bula = 4466 	if YOB == 1978 & MOB == 6	& bula == 6	
qui replace fert_bula = 4445 	if YOB == 1978 & MOB == 7	& bula == 6	
qui replace fert_bula = 4337 	if YOB == 1978 & MOB == 8	& bula == 6	
qui replace fert_bula = 4319 	if YOB == 1978 & MOB == 9	& bula == 6	
qui replace fert_bula = 4102 	if YOB == 1978 & MOB == 10	& bula == 6	
qui replace fert_bula = 3826 	if YOB == 1978 & MOB == 11	& bula == 6	
qui replace fert_bula = 4088 	if YOB == 1978 & MOB == 12	& bula == 6	
qui replace fert_bula = 2932 	if YOB == 1978 & MOB == 1	& bula == 7	
qui replace fert_bula = 2696 	if YOB == 1978 & MOB == 2	& bula == 7	
qui replace fert_bula = 3039 	if YOB == 1978 & MOB == 3	& bula == 7	
qui replace fert_bula = 2831 	if YOB == 1978 & MOB == 4	& bula == 7	
qui replace fert_bula = 3075 	if YOB == 1978 & MOB == 5	& bula == 7	
qui replace fert_bula = 2936 	if YOB == 1978 & MOB == 6	& bula == 7	
qui replace fert_bula = 3076 	if YOB == 1978 & MOB == 7	& bula == 7	
qui replace fert_bula = 2849 	if YOB == 1978 & MOB == 8	& bula == 7	
qui replace fert_bula = 2893 	if YOB == 1978 & MOB == 9	& bula == 7	
qui replace fert_bula = 2715 	if YOB == 1978 & MOB == 10	& bula == 7	
qui replace fert_bula = 2525 	if YOB == 1978 & MOB == 11	& bula == 7	
qui replace fert_bula = 2779 	if YOB == 1978 & MOB == 12	& bula == 7	
qui replace fert_bula = 7399 	if YOB == 1978 & MOB == 1	& bula == 8	
qui replace fert_bula = 7146 	if YOB == 1978 & MOB == 2	& bula == 8	
qui replace fert_bula = 8027 	if YOB == 1978 & MOB == 3	& bula == 8	
qui replace fert_bula = 7652 	if YOB == 1978 & MOB == 4	& bula == 8	
qui replace fert_bula = 7957 	if YOB == 1978 & MOB == 5	& bula == 8	
qui replace fert_bula = 7616 	if YOB == 1978 & MOB == 6	& bula == 8	
qui replace fert_bula = 7758 	if YOB == 1978 & MOB == 7	& bula == 8	
qui replace fert_bula = 7521 	if YOB == 1978 & MOB == 8	& bula == 8	
qui replace fert_bula = 7553 	if YOB == 1978 & MOB == 9	& bula == 8	
qui replace fert_bula = 7321 	if YOB == 1978 & MOB == 10	& bula == 8	
qui replace fert_bula = 6769 	if YOB == 1978 & MOB == 11	& bula == 8	
qui replace fert_bula = 7205 	if YOB == 1978 & MOB == 12	& bula == 8	
qui replace fert_bula = 8789 	if YOB == 1978 & MOB == 1	& bula == 9	
qui replace fert_bula = 8571 	if YOB == 1978 & MOB == 2	& bula == 9	
qui replace fert_bula = 9262 	if YOB == 1978 & MOB == 3	& bula == 9	
qui replace fert_bula = 8939 	if YOB == 1978 & MOB == 4	& bula == 9	
qui replace fert_bula = 9301 	if YOB == 1978 & MOB == 5	& bula == 9	
qui replace fert_bula = 8998 	if YOB == 1978 & MOB == 6	& bula == 9	
qui replace fert_bula = 9322 	if YOB == 1978 & MOB == 7	& bula == 9	
qui replace fert_bula = 8697 	if YOB == 1978 & MOB == 8	& bula == 9	
qui replace fert_bula = 9246 	if YOB == 1978 & MOB == 9	& bula == 9	
qui replace fert_bula = 8563 	if YOB == 1978 & MOB == 10	& bula == 9	
qui replace fert_bula = 8010 	if YOB == 1978 & MOB == 11	& bula == 9	
qui replace fert_bula = 8447 	if YOB == 1978 & MOB == 12	& bula == 9	
qui replace fert_bula = 793 	if YOB == 1978 & MOB == 1	& bula == 10	
qui replace fert_bula = 774 	if YOB == 1978 & MOB == 2	& bula == 10	
qui replace fert_bula = 841 	if YOB == 1978 & MOB == 3	& bula == 10	
qui replace fert_bula = 760 	if YOB == 1978 & MOB == 4	& bula == 10	
qui replace fert_bula = 890 	if YOB == 1978 & MOB == 5	& bula == 10	
qui replace fert_bula = 810 	if YOB == 1978 & MOB == 6	& bula == 10	
qui replace fert_bula = 814 	if YOB == 1978 & MOB == 7	& bula == 10	
qui replace fert_bula = 860 	if YOB == 1978 & MOB == 8	& bula == 10	
qui replace fert_bula = 759 	if YOB == 1978 & MOB == 9	& bula == 10	
qui replace fert_bula = 751 	if YOB == 1978 & MOB == 10	& bula == 10	
qui replace fert_bula = 742 	if YOB == 1978 & MOB == 11	& bula == 10	
qui replace fert_bula = 780 	if YOB == 1978 & MOB == 12	& bula == 10	
qui replace fert_bula = 1419 	if YOB == 1978 & MOB == 1	& bula == 11	
qui replace fert_bula = 1252 	if YOB == 1978 & MOB == 2	& bula == 11	
qui replace fert_bula = 1383 	if YOB == 1978 & MOB == 3	& bula == 11	
qui replace fert_bula = 1414 	if YOB == 1978 & MOB == 4	& bula == 11	
qui replace fert_bula = 1470 	if YOB == 1978 & MOB == 5	& bula == 11	
qui replace fert_bula = 1396 	if YOB == 1978 & MOB == 6	& bula == 11	
qui replace fert_bula = 1526 	if YOB == 1978 & MOB == 7	& bula == 11	
qui replace fert_bula = 1408 	if YOB == 1978 & MOB == 8	& bula == 11	
qui replace fert_bula = 1453 	if YOB == 1978 & MOB == 9	& bula == 11	
qui replace fert_bula = 1361 	if YOB == 1978 & MOB == 10	& bula == 11	
qui replace fert_bula = 1255 	if YOB == 1978 & MOB == 11	& bula == 11	
qui replace fert_bula = 1350 	if YOB == 1978 & MOB == 12	& bula == 11	
qui replace fert_bula = 1870 	if YOB == 1979 & MOB == 1	& bula == 1	
qui replace fert_bula = 1771 	if YOB == 1979 & MOB == 2	& bula == 1	
qui replace fert_bula = 1927 	if YOB == 1979 & MOB == 3	& bula == 1	
qui replace fert_bula = 1913 	if YOB == 1979 & MOB == 4	& bula == 1	
qui replace fert_bula = 1974 	if YOB == 1979 & MOB == 5	& bula == 1	
qui replace fert_bula = 1914 	if YOB == 1979 & MOB == 6	& bula == 1	
qui replace fert_bula = 1846 	if YOB == 1979 & MOB == 7	& bula == 1	
qui replace fert_bula = 1925 	if YOB == 1979 & MOB == 8	& bula == 1	
qui replace fert_bula = 2003 	if YOB == 1979 & MOB == 9	& bula == 1	
qui replace fert_bula = 1996 	if YOB == 1979 & MOB == 10	& bula == 1	
qui replace fert_bula = 1808 	if YOB == 1979 & MOB == 11	& bula == 1	
qui replace fert_bula = 1863 	if YOB == 1979 & MOB == 12	& bula == 1	
qui replace fert_bula = 1075 	if YOB == 1979 & MOB == 1	& bula == 2	
qui replace fert_bula = 995 	if YOB == 1979 & MOB == 2	& bula == 2	
qui replace fert_bula = 1021 	if YOB == 1979 & MOB == 3	& bula == 2	
qui replace fert_bula = 1008 	if YOB == 1979 & MOB == 4	& bula == 2	
qui replace fert_bula = 1180 	if YOB == 1979 & MOB == 5	& bula == 2	
qui replace fert_bula = 1041 	if YOB == 1979 & MOB == 6	& bula == 2	
qui replace fert_bula = 1178 	if YOB == 1979 & MOB == 7	& bula == 2	
qui replace fert_bula = 1094 	if YOB == 1979 & MOB == 8	& bula == 2	
qui replace fert_bula = 1100 	if YOB == 1979 & MOB == 9	& bula == 2	
qui replace fert_bula = 1060 	if YOB == 1979 & MOB == 10	& bula == 2	
qui replace fert_bula = 1016 	if YOB == 1979 & MOB == 11	& bula == 2	
qui replace fert_bula = 954 	if YOB == 1979 & MOB == 12	& bula == 2	
qui replace fert_bula = 5708 	if YOB == 1979 & MOB == 1	& bula == 3	
qui replace fert_bula = 5101 	if YOB == 1979 & MOB == 2	& bula == 3	
qui replace fert_bula = 5707 	if YOB == 1979 & MOB == 3	& bula == 3	
qui replace fert_bula = 5648 	if YOB == 1979 & MOB == 4	& bula == 3	
qui replace fert_bula = 5982 	if YOB == 1979 & MOB == 5	& bula == 3	
qui replace fert_bula = 5665 	if YOB == 1979 & MOB == 6	& bula == 3	
qui replace fert_bula = 5910 	if YOB == 1979 & MOB == 7	& bula == 3	
qui replace fert_bula = 5886 	if YOB == 1979 & MOB == 8	& bula == 3	
qui replace fert_bula = 5859 	if YOB == 1979 & MOB == 9	& bula == 3	
qui replace fert_bula = 5651 	if YOB == 1979 & MOB == 10	& bula == 3	
qui replace fert_bula = 5209 	if YOB == 1979 & MOB == 11	& bula == 3	
qui replace fert_bula = 5311 	if YOB == 1979 & MOB == 12	& bula == 3	
qui replace fert_bula = 460 	if YOB == 1979 & MOB == 1	& bula == 4	
qui replace fert_bula = 424 	if YOB == 1979 & MOB == 2	& bula == 4	
qui replace fert_bula = 467 	if YOB == 1979 & MOB == 3	& bula == 4	
qui replace fert_bula = 460 	if YOB == 1979 & MOB == 4	& bula == 4	
qui replace fert_bula = 521 	if YOB == 1979 & MOB == 5	& bula == 4	
qui replace fert_bula = 448 	if YOB == 1979 & MOB == 6	& bula == 4	
qui replace fert_bula = 501 	if YOB == 1979 & MOB == 7	& bula == 4	
qui replace fert_bula = 516 	if YOB == 1979 & MOB == 8	& bula == 4	
qui replace fert_bula = 472 	if YOB == 1979 & MOB == 9	& bula == 4	
qui replace fert_bula = 471 	if YOB == 1979 & MOB == 10	& bula == 4	
qui replace fert_bula = 443 	if YOB == 1979 & MOB == 11	& bula == 4	
qui replace fert_bula = 457 	if YOB == 1979 & MOB == 12	& bula == 4	
qui replace fert_bula = 13268 	if YOB == 1979 & MOB == 1	& bula == 5	
qui replace fert_bula = 11974 	if YOB == 1979 & MOB == 2	& bula == 5	
qui replace fert_bula = 13240 	if YOB == 1979 & MOB == 3	& bula == 5	
qui replace fert_bula = 13150 	if YOB == 1979 & MOB == 4	& bula == 5	
qui replace fert_bula = 13594 	if YOB == 1979 & MOB == 5	& bula == 5	
qui replace fert_bula = 13219 	if YOB == 1979 & MOB == 6	& bula == 5	
qui replace fert_bula = 14080 	if YOB == 1979 & MOB == 7	& bula == 5	
qui replace fert_bula = 13893 	if YOB == 1979 & MOB == 8	& bula == 5	
qui replace fert_bula = 13705 	if YOB == 1979 & MOB == 9	& bula == 5	
qui replace fert_bula = 13570 	if YOB == 1979 & MOB == 10	& bula == 5	
qui replace fert_bula = 12754 	if YOB == 1979 & MOB == 11	& bula == 5	
qui replace fert_bula = 12931 	if YOB == 1979 & MOB == 12	& bula == 5	
qui replace fert_bula = 4296 	if YOB == 1979 & MOB == 1	& bula == 6	
qui replace fert_bula = 3922 	if YOB == 1979 & MOB == 2	& bula == 6	
qui replace fert_bula = 4280 	if YOB == 1979 & MOB == 3	& bula == 6	
qui replace fert_bula = 4362 	if YOB == 1979 & MOB == 4	& bula == 6	
qui replace fert_bula = 4429 	if YOB == 1979 & MOB == 5	& bula == 6	
qui replace fert_bula = 4337 	if YOB == 1979 & MOB == 6	& bula == 6	
qui replace fert_bula = 4583 	if YOB == 1979 & MOB == 7	& bula == 6	
qui replace fert_bula = 4481 	if YOB == 1979 & MOB == 8	& bula == 6	
qui replace fert_bula = 4430 	if YOB == 1979 & MOB == 9	& bula == 6	
qui replace fert_bula = 4475 	if YOB == 1979 & MOB == 10	& bula == 6	
qui replace fert_bula = 4044 	if YOB == 1979 & MOB == 11	& bula == 6	
qui replace fert_bula = 4215 	if YOB == 1979 & MOB == 12	& bula == 6	
qui replace fert_bula = 2945 	if YOB == 1979 & MOB == 1	& bula == 7	
qui replace fert_bula = 2589 	if YOB == 1979 & MOB == 2	& bula == 7	
qui replace fert_bula = 2903 	if YOB == 1979 & MOB == 3	& bula == 7	
qui replace fert_bula = 2860 	if YOB == 1979 & MOB == 4	& bula == 7	
qui replace fert_bula = 3022 	if YOB == 1979 & MOB == 5	& bula == 7	
qui replace fert_bula = 2848 	if YOB == 1979 & MOB == 6	& bula == 7	
qui replace fert_bula = 3132 	if YOB == 1979 & MOB == 7	& bula == 7	
qui replace fert_bula = 3018 	if YOB == 1979 & MOB == 8	& bula == 7	
qui replace fert_bula = 3054 	if YOB == 1979 & MOB == 9	& bula == 7	
qui replace fert_bula = 2903 	if YOB == 1979 & MOB == 10	& bula == 7	
qui replace fert_bula = 2780 	if YOB == 1979 & MOB == 11	& bula == 7	
qui replace fert_bula = 2751 	if YOB == 1979 & MOB == 12	& bula == 7	
qui replace fert_bula = 7490 	if YOB == 1979 & MOB == 1	& bula == 8	
qui replace fert_bula = 6869 	if YOB == 1979 & MOB == 2	& bula == 8	
qui replace fert_bula = 7910 	if YOB == 1979 & MOB == 3	& bula == 8	
qui replace fert_bula = 7754 	if YOB == 1979 & MOB == 4	& bula == 8	
qui replace fert_bula = 8079 	if YOB == 1979 & MOB == 5	& bula == 8	
qui replace fert_bula = 7528 	if YOB == 1979 & MOB == 6	& bula == 8	
qui replace fert_bula = 8083 	if YOB == 1979 & MOB == 7	& bula == 8	
qui replace fert_bula = 7880 	if YOB == 1979 & MOB == 8	& bula == 8	
qui replace fert_bula = 8091 	if YOB == 1979 & MOB == 9	& bula == 8	
qui replace fert_bula = 7702 	if YOB == 1979 & MOB == 10	& bula == 8	
qui replace fert_bula = 7419 	if YOB == 1979 & MOB == 11	& bula == 8	
qui replace fert_bula = 7620 	if YOB == 1979 & MOB == 12	& bula == 8	
qui replace fert_bula = 8997 	if YOB == 1979 & MOB == 1	& bula == 9	
qui replace fert_bula = 8308 	if YOB == 1979 & MOB == 2	& bula == 9	
qui replace fert_bula = 9084 	if YOB == 1979 & MOB == 3	& bula == 9	
qui replace fert_bula = 9048 	if YOB == 1979 & MOB == 4	& bula == 9	
qui replace fert_bula = 9557 	if YOB == 1979 & MOB == 5	& bula == 9	
qui replace fert_bula = 8782 	if YOB == 1979 & MOB == 6	& bula == 9	
qui replace fert_bula = 9355 	if YOB == 1979 & MOB == 7	& bula == 9	
qui replace fert_bula = 9261 	if YOB == 1979 & MOB == 8	& bula == 9	
qui replace fert_bula = 9050 	if YOB == 1979 & MOB == 9	& bula == 9	
qui replace fert_bula = 8968 	if YOB == 1979 & MOB == 10	& bula == 9	
qui replace fert_bula = 8635 	if YOB == 1979 & MOB == 11	& bula == 9	
qui replace fert_bula = 8622 	if YOB == 1979 & MOB == 12	& bula == 9	
qui replace fert_bula = 802 	if YOB == 1979 & MOB == 1	& bula == 10	
qui replace fert_bula = 686 	if YOB == 1979 & MOB == 2	& bula == 10	
qui replace fert_bula = 813 	if YOB == 1979 & MOB == 3	& bula == 10	
qui replace fert_bula = 814 	if YOB == 1979 & MOB == 4	& bula == 10	
qui replace fert_bula = 895 	if YOB == 1979 & MOB == 5	& bula == 10	
qui replace fert_bula = 770 	if YOB == 1979 & MOB == 6	& bula == 10	
qui replace fert_bula = 892 	if YOB == 1979 & MOB == 7	& bula == 10	
qui replace fert_bula = 866 	if YOB == 1979 & MOB == 8	& bula == 10	
qui replace fert_bula = 828 	if YOB == 1979 & MOB == 9	& bula == 10	
qui replace fert_bula = 913 	if YOB == 1979 & MOB == 10	& bula == 10	
qui replace fert_bula = 759 	if YOB == 1979 & MOB == 11	& bula == 10	
qui replace fert_bula = 749 	if YOB == 1979 & MOB == 12	& bula == 10	
qui replace fert_bula = 1403 	if YOB == 1979 & MOB == 1	& bula == 11	
qui replace fert_bula = 1281 	if YOB == 1979 & MOB == 2	& bula == 11	
qui replace fert_bula = 1429 	if YOB == 1979 & MOB == 3	& bula == 11	
qui replace fert_bula = 1343 	if YOB == 1979 & MOB == 4	& bula == 11	
qui replace fert_bula = 1519 	if YOB == 1979 & MOB == 5	& bula == 11	
qui replace fert_bula = 1468 	if YOB == 1979 & MOB == 6	& bula == 11	
qui replace fert_bula = 1522 	if YOB == 1979 & MOB == 7	& bula == 11	
qui replace fert_bula = 1574 	if YOB == 1979 & MOB == 8	& bula == 11	
qui replace fert_bula = 1531 	if YOB == 1979 & MOB == 9	& bula == 11	
qui replace fert_bula = 1448 	if YOB == 1979 & MOB == 10	& bula == 11	
qui replace fert_bula = 1385 	if YOB == 1979 & MOB == 11	& bula == 11	
qui replace fert_bula = 1356 	if YOB == 1979 & MOB == 12	& bula == 11	
qui replace fert_bula = 1969 	if YOB == 1980 & MOB == 1	& bula == 1	
qui replace fert_bula = 1921 	if YOB == 1980 & MOB == 2	& bula == 1	
qui replace fert_bula = 2042 	if YOB == 1980 & MOB == 3	& bula == 1	
qui replace fert_bula = 2028 	if YOB == 1980 & MOB == 4	& bula == 1	
qui replace fert_bula = 2133 	if YOB == 1980 & MOB == 5	& bula == 1	
qui replace fert_bula = 2082 	if YOB == 1980 & MOB == 6	& bula == 1	
qui replace fert_bula = 2220 	if YOB == 1980 & MOB == 7	& bula == 1	
qui replace fert_bula = 2108 	if YOB == 1980 & MOB == 8	& bula == 1	
qui replace fert_bula = 2005 	if YOB == 1980 & MOB == 9	& bula == 1	
qui replace fert_bula = 2134 	if YOB == 1980 & MOB == 10	& bula == 1	
qui replace fert_bula = 1807 	if YOB == 1980 & MOB == 11	& bula == 1	
qui replace fert_bula = 2096 	if YOB == 1980 & MOB == 12	& bula == 1	
qui replace fert_bula = 1094 	if YOB == 1980 & MOB == 1	& bula == 2	
qui replace fert_bula = 1046 	if YOB == 1980 & MOB == 2	& bula == 2	
qui replace fert_bula = 1070 	if YOB == 1980 & MOB == 3	& bula == 2	
qui replace fert_bula = 1140 	if YOB == 1980 & MOB == 4	& bula == 2	
qui replace fert_bula = 1179 	if YOB == 1980 & MOB == 5	& bula == 2	
qui replace fert_bula = 1155 	if YOB == 1980 & MOB == 6	& bula == 2	
qui replace fert_bula = 1251 	if YOB == 1980 & MOB == 7	& bula == 2	
qui replace fert_bula = 1114 	if YOB == 1980 & MOB == 8	& bula == 2	
qui replace fert_bula = 1184 	if YOB == 1980 & MOB == 9	& bula == 2	
qui replace fert_bula = 1205 	if YOB == 1980 & MOB == 10	& bula == 2	
qui replace fert_bula = 1077 	if YOB == 1980 & MOB == 11	& bula == 2	
qui replace fert_bula = 1065 	if YOB == 1980 & MOB == 12	& bula == 2	
qui replace fert_bula = 6155 	if YOB == 1980 & MOB == 1	& bula == 3	
qui replace fert_bula = 5467 	if YOB == 1980 & MOB == 2	& bula == 3	
qui replace fert_bula = 5957 	if YOB == 1980 & MOB == 3	& bula == 3	
qui replace fert_bula = 6006 	if YOB == 1980 & MOB == 4	& bula == 3	
qui replace fert_bula = 6208 	if YOB == 1980 & MOB == 5	& bula == 3	
qui replace fert_bula = 6099 	if YOB == 1980 & MOB == 6	& bula == 3	
qui replace fert_bula = 6403 	if YOB == 1980 & MOB == 7	& bula == 3	
qui replace fert_bula = 6133 	if YOB == 1980 & MOB == 8	& bula == 3	
qui replace fert_bula = 5983 	if YOB == 1980 & MOB == 9	& bula == 3	
qui replace fert_bula = 5904 	if YOB == 1980 & MOB == 10	& bula == 3	
qui replace fert_bula = 5589 	if YOB == 1980 & MOB == 11	& bula == 3	
qui replace fert_bula = 5848 	if YOB == 1980 & MOB == 12	& bula == 3	
qui replace fert_bula = 507 	if YOB == 1980 & MOB == 1	& bula == 4	
qui replace fert_bula = 502 	if YOB == 1980 & MOB == 2	& bula == 4	
qui replace fert_bula = 444 	if YOB == 1980 & MOB == 3	& bula == 4	
qui replace fert_bula = 432 	if YOB == 1980 & MOB == 4	& bula == 4	
qui replace fert_bula = 507 	if YOB == 1980 & MOB == 5	& bula == 4	
qui replace fert_bula = 506 	if YOB == 1980 & MOB == 6	& bula == 4	
qui replace fert_bula = 554 	if YOB == 1980 & MOB == 7	& bula == 4	
qui replace fert_bula = 539 	if YOB == 1980 & MOB == 8	& bula == 4	
qui replace fert_bula = 503 	if YOB == 1980 & MOB == 9	& bula == 4	
qui replace fert_bula = 504 	if YOB == 1980 & MOB == 10	& bula == 4	
qui replace fert_bula = 451 	if YOB == 1980 & MOB == 11	& bula == 4	
qui replace fert_bula = 496 	if YOB == 1980 & MOB == 12	& bula == 4	
qui replace fert_bula = 14115 	if YOB == 1980 & MOB == 1	& bula == 5	
qui replace fert_bula = 13248 	if YOB == 1980 & MOB == 2	& bula == 5	
qui replace fert_bula = 13971 	if YOB == 1980 & MOB == 3	& bula == 5	
qui replace fert_bula = 13936 	if YOB == 1980 & MOB == 4	& bula == 5	
qui replace fert_bula = 14392 	if YOB == 1980 & MOB == 5	& bula == 5	
qui replace fert_bula = 14113 	if YOB == 1980 & MOB == 6	& bula == 5	
qui replace fert_bula = 15080 	if YOB == 1980 & MOB == 7	& bula == 5	
qui replace fert_bula = 14735 	if YOB == 1980 & MOB == 8	& bula == 5	
qui replace fert_bula = 14665 	if YOB == 1980 & MOB == 9	& bula == 5	
qui replace fert_bula = 14252 	if YOB == 1980 & MOB == 10	& bula == 5	
qui replace fert_bula = 13398 	if YOB == 1980 & MOB == 11	& bula == 5	
qui replace fert_bula = 13923 	if YOB == 1980 & MOB == 12	& bula == 5	
qui replace fert_bula = 4487 	if YOB == 1980 & MOB == 1	& bula == 6	
qui replace fert_bula = 4194 	if YOB == 1980 & MOB == 2	& bula == 6	
qui replace fert_bula = 4485 	if YOB == 1980 & MOB == 3	& bula == 6	
qui replace fert_bula = 4477 	if YOB == 1980 & MOB == 4	& bula == 6	
qui replace fert_bula = 4707 	if YOB == 1980 & MOB == 5	& bula == 6	
qui replace fert_bula = 4725 	if YOB == 1980 & MOB == 6	& bula == 6	
qui replace fert_bula = 4900 	if YOB == 1980 & MOB == 7	& bula == 6	
qui replace fert_bula = 4676 	if YOB == 1980 & MOB == 8	& bula == 6	
qui replace fert_bula = 4527 	if YOB == 1980 & MOB == 9	& bula == 6	
qui replace fert_bula = 4578 	if YOB == 1980 & MOB == 10	& bula == 6	
qui replace fert_bula = 4336 	if YOB == 1980 & MOB == 11	& bula == 6	
qui replace fert_bula = 4443 	if YOB == 1980 & MOB == 12	& bula == 6	
qui replace fert_bula = 3109 	if YOB == 1980 & MOB == 1	& bula == 7	
qui replace fert_bula = 2850 	if YOB == 1980 & MOB == 2	& bula == 7	
qui replace fert_bula = 3130 	if YOB == 1980 & MOB == 3	& bula == 7	
qui replace fert_bula = 3124 	if YOB == 1980 & MOB == 4	& bula == 7	
qui replace fert_bula = 3119 	if YOB == 1980 & MOB == 5	& bula == 7	
qui replace fert_bula = 3131 	if YOB == 1980 & MOB == 6	& bula == 7	
qui replace fert_bula = 3314 	if YOB == 1980 & MOB == 7	& bula == 7	
qui replace fert_bula = 3210 	if YOB == 1980 & MOB == 8	& bula == 7	
qui replace fert_bula = 3198 	if YOB == 1980 & MOB == 9	& bula == 7	
qui replace fert_bula = 3028 	if YOB == 1980 & MOB == 10	& bula == 7	
qui replace fert_bula = 2967 	if YOB == 1980 & MOB == 11	& bula == 7	
qui replace fert_bula = 3073 	if YOB == 1980 & MOB == 12	& bula == 7	
qui replace fert_bula = 8001 	if YOB == 1980 & MOB == 1	& bula == 8	
qui replace fert_bula = 7642 	if YOB == 1980 & MOB == 2	& bula == 8	
qui replace fert_bula = 8114 	if YOB == 1980 & MOB == 3	& bula == 8	
qui replace fert_bula = 7382 	if YOB == 1980 & MOB == 4	& bula == 8	
qui replace fert_bula = 8593 	if YOB == 1980 & MOB == 5	& bula == 8	
qui replace fert_bula = 8464 	if YOB == 1980 & MOB == 6	& bula == 8	
qui replace fert_bula = 9433 	if YOB == 1980 & MOB == 7	& bula == 8	
qui replace fert_bula = 8323 	if YOB == 1980 & MOB == 8	& bula == 8	
qui replace fert_bula = 8728 	if YOB == 1980 & MOB == 9	& bula == 8	
qui replace fert_bula = 8684 	if YOB == 1980 & MOB == 10	& bula == 8	
qui replace fert_bula = 7711 	if YOB == 1980 & MOB == 11	& bula == 8	
qui replace fert_bula = 8646 	if YOB == 1980 & MOB == 12	& bula == 8	
qui replace fert_bula = 9591 	if YOB == 1980 & MOB == 1	& bula == 9	
qui replace fert_bula = 9061 	if YOB == 1980 & MOB == 2	& bula == 9	
qui replace fert_bula = 9671 	if YOB == 1980 & MOB == 3	& bula == 9	
qui replace fert_bula = 9454 	if YOB == 1980 & MOB == 4	& bula == 9	
qui replace fert_bula = 10066 	if YOB == 1980 & MOB == 5	& bula == 9	
qui replace fert_bula = 9430 	if YOB == 1980 & MOB == 6	& bula == 9	
qui replace fert_bula = 10134 	if YOB == 1980 & MOB == 7	& bula == 9	
qui replace fert_bula = 9619 	if YOB == 1980 & MOB == 8	& bula == 9	
qui replace fert_bula = 9622 	if YOB == 1980 & MOB == 9	& bula == 9	
qui replace fert_bula = 9384 	if YOB == 1980 & MOB == 10	& bula == 9	
qui replace fert_bula = 9024 	if YOB == 1980 & MOB == 11	& bula == 9	
qui replace fert_bula = 9395 	if YOB == 1980 & MOB == 12	& bula == 9	
qui replace fert_bula = 851 	if YOB == 1980 & MOB == 1	& bula == 10	
qui replace fert_bula = 860 	if YOB == 1980 & MOB == 2	& bula == 10	
qui replace fert_bula = 859 	if YOB == 1980 & MOB == 3	& bula == 10	
qui replace fert_bula = 877 	if YOB == 1980 & MOB == 4	& bula == 10	
qui replace fert_bula = 880 	if YOB == 1980 & MOB == 5	& bula == 10	
qui replace fert_bula = 929 	if YOB == 1980 & MOB == 6	& bula == 10	
qui replace fert_bula = 928 	if YOB == 1980 & MOB == 7	& bula == 10	
qui replace fert_bula = 832 	if YOB == 1980 & MOB == 8	& bula == 10	
qui replace fert_bula = 952 	if YOB == 1980 & MOB == 9	& bula == 10	
qui replace fert_bula = 862 	if YOB == 1980 & MOB == 10	& bula == 10	
qui replace fert_bula = 786 	if YOB == 1980 & MOB == 11	& bula == 10	
qui replace fert_bula = 895 	if YOB == 1980 & MOB == 12	& bula == 10	
qui replace fert_bula = 1518 	if YOB == 1980 & MOB == 1	& bula == 11	
qui replace fert_bula = 1386 	if YOB == 1980 & MOB == 2	& bula == 11	
qui replace fert_bula = 1421 	if YOB == 1980 & MOB == 3	& bula == 11	
qui replace fert_bula = 1416 	if YOB == 1980 & MOB == 4	& bula == 11	
qui replace fert_bula = 1631 	if YOB == 1980 & MOB == 5	& bula == 11	
qui replace fert_bula = 1608 	if YOB == 1980 & MOB == 6	& bula == 11	
qui replace fert_bula = 1699 	if YOB == 1980 & MOB == 7	& bula == 11	
qui replace fert_bula = 1715 	if YOB == 1980 & MOB == 8	& bula == 11	
qui replace fert_bula = 1494 	if YOB == 1980 & MOB == 9	& bula == 11	
qui replace fert_bula = 1608 	if YOB == 1980 & MOB == 10	& bula == 11	
qui replace fert_bula = 1510 	if YOB == 1980 & MOB == 11	& bula == 11	
qui replace fert_bula = 1530 	if YOB == 1980 & MOB == 12	& bula == 11	

sort YOB bula
//ratios aus Geburtenstatistik
	bys YOB bula: egen sum_fert_bula = total(fert_bula)
	qui gen ratio_fert_bula = fert_bula / sum_fert_bula
	drop sum_fert_bula
	
	save "$temp/geburten_bula", replace
	
********************************************************************************
// Geburten GDR level

drop _all 

set obs 15
gen YOB = _n
expand 12

qui replace YOB = YOB + 1974
sort YOB 

bys YOB: gen MOB = _n
expand 2 // 10 Länder Westen und Osten
bys YOB MOB: gen GDR = _n 
qui replace GDR = GDR - 1
sort YOB GDR MOB


// FEMALES
qui gen fertf = .
qui replace fertf = 25059 if YOB == 1975 & MOB ==1	& GDR == 0	
qui replace fertf = 23326 if YOB == 1975 & MOB ==2	& GDR == 0	
qui replace fertf = 25941 if YOB == 1975 & MOB ==3	& GDR == 0	
qui replace fertf = 24951 if YOB == 1975 & MOB ==4	& GDR == 0	
qui replace fertf = 25517 if YOB == 1975 & MOB ==5	& GDR == 0	
qui replace fertf = 24249 if YOB == 1975 & MOB ==6	& GDR == 0	
qui replace fertf = 25585 if YOB == 1975 & MOB ==7	& GDR == 0	
qui replace fertf = 24272 if YOB == 1975 & MOB ==8	& GDR == 0	
qui replace fertf = 24362 if YOB == 1975 & MOB ==9	& GDR == 0	
qui replace fertf = 23038 if YOB == 1975 & MOB ==10	& GDR == 0	
qui replace fertf = 21697 if YOB == 1975 & MOB ==11	& GDR == 0	
qui replace fertf = 23380 if YOB == 1975 & MOB ==12	& GDR == 0	
qui replace fertf = 24950 if YOB == 1976 & MOB ==1	& GDR == 0	
qui replace fertf = 23732 if YOB == 1976 & MOB ==2	& GDR == 0	
qui replace fertf = 26070 if YOB == 1976 & MOB ==3	& GDR == 0	
qui replace fertf = 23789 if YOB == 1976 & MOB ==4	& GDR == 0	
qui replace fertf = 25040 if YOB == 1976 & MOB ==5	& GDR == 0	
qui replace fertf = 24593 if YOB == 1976 & MOB ==6	& GDR == 0	
qui replace fertf = 25625 if YOB == 1976 & MOB ==7	& GDR == 0	
qui replace fertf = 25131 if YOB == 1976 & MOB ==8	& GDR == 0	
qui replace fertf = 25405 if YOB == 1976 & MOB ==9	& GDR == 0	
qui replace fertf = 23601 if YOB == 1976 & MOB ==10	& GDR == 0	
qui replace fertf = 22779 if YOB == 1976 & MOB ==11	& GDR == 0	
qui replace fertf = 22751 if YOB == 1976 & MOB ==12	& GDR == 0	
qui replace fertf = 23645 if YOB == 1977 & MOB ==1	& GDR == 0	
qui replace fertf = 22082 if YOB == 1977 & MOB ==2	& GDR == 0	
qui replace fertf = 24696 if YOB == 1977 & MOB ==3	& GDR == 0	
qui replace fertf = 22968 if YOB == 1977 & MOB ==4	& GDR == 0	
qui replace fertf = 24826 if YOB == 1977 & MOB ==5	& GDR == 0	
qui replace fertf = 24384 if YOB == 1977 & MOB ==6	& GDR == 0	
qui replace fertf = 24243 if YOB == 1977 & MOB ==7	& GDR == 0	
qui replace fertf = 23873 if YOB == 1977 & MOB ==8	& GDR == 0	
qui replace fertf = 24202 if YOB == 1977 & MOB ==9	& GDR == 0	
qui replace fertf = 23247 if YOB == 1977 & MOB ==10	& GDR == 0	
qui replace fertf = 22076 if YOB == 1977 & MOB ==11	& GDR == 0	
qui replace fertf = 22367 if YOB == 1977 & MOB ==12	& GDR == 0	
qui replace fertf = 23528 if YOB == 1978 & MOB ==1	& GDR == 0	
qui replace fertf = 22260 if YOB == 1978 & MOB ==2	& GDR == 0	
qui replace fertf = 24686 if YOB == 1978 & MOB ==3	& GDR == 0	
qui replace fertf = 23840 if YOB == 1978 & MOB ==4	& GDR == 0	
qui replace fertf = 24772 if YOB == 1978 & MOB ==5	& GDR == 0	
qui replace fertf = 23929 if YOB == 1978 & MOB ==6	& GDR == 0	
qui replace fertf = 24262 if YOB == 1978 & MOB ==7	& GDR == 0	
qui replace fertf = 23597 if YOB == 1978 & MOB ==8	& GDR == 0	
qui replace fertf = 23616 if YOB == 1978 & MOB ==9	& GDR == 0	
qui replace fertf = 22551 if YOB == 1978 & MOB ==10	& GDR == 0	
qui replace fertf = 21137 if YOB == 1978 & MOB ==11	& GDR == 0	
qui replace fertf = 21942 if YOB == 1978 & MOB ==12	& GDR == 0	
qui replace fertf = 23505 if YOB == 1979 & MOB ==1	& GDR == 0	
qui replace fertf = 21499 if YOB == 1979 & MOB ==2	& GDR == 0	
qui replace fertf = 23779 if YOB == 1979 & MOB ==3	& GDR == 0	
qui replace fertf = 23469 if YOB == 1979 & MOB ==4	& GDR == 0	
qui replace fertf = 24704 if YOB == 1979 & MOB ==5	& GDR == 0	
qui replace fertf = 23437 if YOB == 1979 & MOB ==6	& GDR == 0	
qui replace fertf = 24837 if YOB == 1979 & MOB ==7	& GDR == 0	
qui replace fertf = 24530 if YOB == 1979 & MOB ==8	& GDR == 0	
qui replace fertf = 24479 if YOB == 1979 & MOB ==9	& GDR == 0	
qui replace fertf = 24264 if YOB == 1979 & MOB ==10	& GDR == 0	
qui replace fertf = 22560 if YOB == 1979 & MOB ==11	& GDR == 0	
qui replace fertf = 22746 if YOB == 1979 & MOB ==12	& GDR == 0	
qui replace fertf = 25329 if YOB == 1980 & MOB ==1	& GDR == 0	
qui replace fertf = 23264 if YOB == 1980 & MOB ==2	& GDR == 0	
qui replace fertf = 24926 if YOB == 1980 & MOB ==3	& GDR == 0	
qui replace fertf = 24444 if YOB == 1980 & MOB ==4	& GDR == 0	
qui replace fertf = 26111 if YOB == 1980 & MOB ==5	& GDR == 0	
qui replace fertf = 25393 if YOB == 1980 & MOB ==6	& GDR == 0	
qui replace fertf = 27227 if YOB == 1980 & MOB ==7	& GDR == 0	
qui replace fertf = 25701 if YOB == 1980 & MOB ==8	& GDR == 0	
qui replace fertf = 25826 if YOB == 1980 & MOB ==9	& GDR == 0	
qui replace fertf = 25271 if YOB == 1980 & MOB ==10	& GDR == 0	
qui replace fertf = 23702 if YOB == 1980 & MOB ==11	& GDR == 0	
qui replace fertf = 24983 if YOB == 1980 & MOB ==12	& GDR == 0	
qui replace fertf = 24819 if YOB == 1981 & MOB ==1	& GDR == 0	
qui replace fertf = 23896 if YOB == 1981 & MOB ==2	& GDR == 0	
qui replace fertf = 25858 if YOB == 1981 & MOB ==3	& GDR == 0	
qui replace fertf = 24824 if YOB == 1981 & MOB ==4	& GDR == 0	
qui replace fertf = 25308 if YOB == 1981 & MOB ==5	& GDR == 0	
qui replace fertf = 25754 if YOB == 1981 & MOB ==6	& GDR == 0	
qui replace fertf = 27226 if YOB == 1981 & MOB ==7	& GDR == 0	
qui replace fertf = 26631 if YOB == 1981 & MOB ==8	& GDR == 0	
qui replace fertf = 26451 if YOB == 1981 & MOB ==9	& GDR == 0	
qui replace fertf = 25102 if YOB == 1981 & MOB ==10	& GDR == 0	
qui replace fertf = 23590 if YOB == 1981 & MOB ==11	& GDR == 0	
qui replace fertf = 24465 if YOB == 1981 & MOB ==12	& GDR == 0	
qui replace fertf = 25456 if YOB == 1982 & MOB ==1	& GDR == 0	
qui replace fertf = 23426 if YOB == 1982 & MOB ==2	& GDR == 0	
qui replace fertf = 26132 if YOB == 1982 & MOB ==3	& GDR == 0	
qui replace fertf = 24254 if YOB == 1982 & MOB ==4	& GDR == 0	
qui replace fertf = 24499 if YOB == 1982 & MOB ==5	& GDR == 0	
qui replace fertf = 25179 if YOB == 1982 & MOB ==6	& GDR == 0	
qui replace fertf = 26596 if YOB == 1982 & MOB ==7	& GDR == 0	
qui replace fertf = 26037 if YOB == 1982 & MOB ==8	& GDR == 0	
qui replace fertf = 26532 if YOB == 1982 & MOB ==9	& GDR == 0	
qui replace fertf = 25545 if YOB == 1982 & MOB ==10	& GDR == 0	
qui replace fertf = 23955 if YOB == 1982 & MOB ==11	& GDR == 0	
qui replace fertf = 24269 if YOB == 1982 & MOB ==12	& GDR == 0	
qui replace fertf = 24217 if YOB == 1983 & MOB ==1	& GDR == 0	
qui replace fertf = 23152 if YOB == 1983 & MOB ==2	& GDR == 0	
qui replace fertf = 24733 if YOB == 1983 & MOB ==3	& GDR == 0	
qui replace fertf = 23353 if YOB == 1983 & MOB ==4	& GDR == 0	
qui replace fertf = 24820 if YOB == 1983 & MOB ==5	& GDR == 0	
qui replace fertf = 24505 if YOB == 1983 & MOB ==6	& GDR == 0	
qui replace fertf = 25213 if YOB == 1983 & MOB ==7	& GDR == 0	
qui replace fertf = 25492 if YOB == 1983 & MOB ==8	& GDR == 0	
qui replace fertf = 24952 if YOB == 1983 & MOB ==9	& GDR == 0	
qui replace fertf = 23435 if YOB == 1983 & MOB ==10	& GDR == 0	
qui replace fertf = 22095 if YOB == 1983 & MOB ==11	& GDR == 0	
qui replace fertf = 22955 if YOB == 1983 & MOB ==12	& GDR == 0	
qui replace fertf = 22784 if YOB == 1984 & MOB ==1	& GDR == 0	
qui replace fertf = 22840 if YOB == 1984 & MOB ==2	& GDR == 0	
qui replace fertf = 24126 if YOB == 1984 & MOB ==3	& GDR == 0	
qui replace fertf = 22789 if YOB == 1984 & MOB ==4	& GDR == 0	
qui replace fertf = 23800 if YOB == 1984 & MOB ==5	& GDR == 0	
qui replace fertf = 23583 if YOB == 1984 & MOB ==6	& GDR == 0	
qui replace fertf = 25197 if YOB == 1984 & MOB ==7	& GDR == 0	
qui replace fertf = 25081 if YOB == 1984 & MOB ==8	& GDR == 0	
qui replace fertf = 24516 if YOB == 1984 & MOB ==9	& GDR == 0	
qui replace fertf = 24191 if YOB == 1984 & MOB ==10	& GDR == 0	
qui replace fertf = 22544 if YOB == 1984 & MOB ==11	& GDR == 0	
qui replace fertf = 22586 if YOB == 1984 & MOB ==12	& GDR == 0	
qui replace fertf = 23934 if YOB == 1985 & MOB ==1	& GDR == 0	
qui replace fertf = 21966 if YOB == 1985 & MOB ==2	& GDR == 0	
qui replace fertf = 24426 if YOB == 1985 & MOB ==3	& GDR == 0	
qui replace fertf = 23853 if YOB == 1985 & MOB ==4	& GDR == 0	
qui replace fertf = 24368 if YOB == 1985 & MOB ==5	& GDR == 0	
qui replace fertf = 23078 if YOB == 1985 & MOB ==6	& GDR == 0	
qui replace fertf = 25656 if YOB == 1985 & MOB ==7	& GDR == 0	
qui replace fertf = 24589 if YOB == 1985 & MOB ==8	& GDR == 0	
qui replace fertf = 25238 if YOB == 1985 & MOB ==9	& GDR == 0	
qui replace fertf = 24631 if YOB == 1985 & MOB ==10	& GDR == 0	
qui replace fertf = 22192 if YOB == 1985 & MOB ==11	& GDR == 0	
qui replace fertf = 22171 if YOB == 1985 & MOB ==12	& GDR == 0	
qui replace fertf = 24705 if YOB == 1986 & MOB ==1	& GDR == 0	
qui replace fertf = 23323 if YOB == 1986 & MOB ==2	& GDR == 0	
qui replace fertf = 24690 if YOB == 1986 & MOB ==3	& GDR == 0	
qui replace fertf = 25588 if YOB == 1986 & MOB ==4	& GDR == 0	
qui replace fertf = 25246 if YOB == 1986 & MOB ==5	& GDR == 0	
qui replace fertf = 25104 if YOB == 1986 & MOB ==6	& GDR == 0	
qui replace fertf = 26682 if YOB == 1986 & MOB ==7	& GDR == 0	
qui replace fertf = 26602 if YOB == 1986 & MOB ==8	& GDR == 0	
qui replace fertf = 27175 if YOB == 1986 & MOB ==9	& GDR == 0	
qui replace fertf = 26314 if YOB == 1986 & MOB ==10	& GDR == 0	
qui replace fertf = 23698 if YOB == 1986 & MOB ==11	& GDR == 0	
qui replace fertf = 25652 if YOB == 1986 & MOB ==12	& GDR == 0	
qui replace fertf = 25700 if YOB == 1987 & MOB ==1	& GDR == 0	
qui replace fertf = 23211 if YOB == 1987 & MOB ==2	& GDR == 0	
qui replace fertf = 25761 if YOB == 1987 & MOB ==3	& GDR == 0	
qui replace fertf = 24885 if YOB == 1987 & MOB ==4	& GDR == 0	
qui replace fertf = 26507 if YOB == 1987 & MOB ==5	& GDR == 0	
qui replace fertf = 26716 if YOB == 1987 & MOB ==6	& GDR == 0	
qui replace fertf = 28253 if YOB == 1987 & MOB ==7	& GDR == 0	
qui replace fertf = 27694 if YOB == 1987 & MOB ==8	& GDR == 0	
qui replace fertf = 27595 if YOB == 1987 & MOB ==9	& GDR == 0	
qui replace fertf = 25892 if YOB == 1987 & MOB ==10	& GDR == 0	
qui replace fertf = 24038 if YOB == 1987 & MOB ==11	& GDR == 0	
qui replace fertf = 25099 if YOB == 1987 & MOB ==12	& GDR == 0	
qui replace fertf = 27409 if YOB == 1988 & MOB ==1	& GDR == 0	
qui replace fertf = 26196 if YOB == 1988 & MOB ==2	& GDR == 0	
qui replace fertf = 28552 if YOB == 1988 & MOB ==3	& GDR == 0	
qui replace fertf = 25814 if YOB == 1988 & MOB ==4	& GDR == 0	
qui replace fertf = 28229 if YOB == 1988 & MOB ==5	& GDR == 0	
qui replace fertf = 26657 if YOB == 1988 & MOB ==6	& GDR == 0	
qui replace fertf = 28519 if YOB == 1988 & MOB ==7	& GDR == 0	
qui replace fertf = 29282 if YOB == 1988 & MOB ==8	& GDR == 0	
qui replace fertf = 29088 if YOB == 1988 & MOB ==9	& GDR == 0	
qui replace fertf = 27008 if YOB == 1988 & MOB ==10	& GDR == 0	
qui replace fertf = 25891 if YOB == 1988 & MOB ==11	& GDR == 0	
qui replace fertf = 26476 if YOB == 1988 & MOB ==12	& GDR == 0	
qui replace fertf = 27286 if YOB == 1989 & MOB ==1	& GDR == 0	
qui replace fertf = 25665 if YOB == 1989 & MOB ==2	& GDR == 0	
qui replace fertf = 27901 if YOB == 1989 & MOB ==3	& GDR == 0	
qui replace fertf = 26662 if YOB == 1989 & MOB ==4	& GDR == 0	
qui replace fertf = 27702 if YOB == 1989 & MOB ==5	& GDR == 0	
qui replace fertf = 27311 if YOB == 1989 & MOB ==6	& GDR == 0	
qui replace fertf = 30137 if YOB == 1989 & MOB ==7	& GDR == 0	
qui replace fertf = 29695 if YOB == 1989 & MOB ==8	& GDR == 0	
qui replace fertf = 28417 if YOB == 1989 & MOB ==9	& GDR == 0	
qui replace fertf = 27285 if YOB == 1989 & MOB ==10	& GDR == 0	
qui replace fertf = 26476 if YOB == 1989 & MOB ==11	& GDR == 0	
qui replace fertf = 27821 if YOB == 1989 & MOB ==12	& GDR == 0	
qui replace fertf = 7998 if YOB == 1975 & MOB ==1	& GDR == 1	
qui replace fertf = 6975 if YOB == 1975 & MOB ==2	& GDR == 1	
qui replace fertf = 7983 if YOB == 1975 & MOB ==3	& GDR == 1	
qui replace fertf = 7817 if YOB == 1975 & MOB ==4	& GDR == 1	
qui replace fertf = 7940 if YOB == 1975 & MOB ==5	& GDR == 1	
qui replace fertf = 7285 if YOB == 1975 & MOB ==6	& GDR == 1	
qui replace fertf = 7705 if YOB == 1975 & MOB ==7	& GDR == 1	
qui replace fertf = 7430 if YOB == 1975 & MOB ==8	& GDR == 1	
qui replace fertf = 7222 if YOB == 1975 & MOB ==9	& GDR == 1	
qui replace fertf = 6583 if YOB == 1975 & MOB ==10	& GDR == 1	
qui replace fertf = 6478 if YOB == 1975 & MOB ==11	& GDR == 1	
qui replace fertf = 6727 if YOB == 1975 & MOB ==12	& GDR == 1	
qui replace fertf = 8448 if YOB == 1976 & MOB ==1	& GDR == 1	
qui replace fertf = 7466 if YOB == 1976 & MOB ==2	& GDR == 1	
qui replace fertf = 8703 if YOB == 1976 & MOB ==3	& GDR == 1	
qui replace fertf = 8148 if YOB == 1976 & MOB ==4	& GDR == 1	
qui replace fertf = 8489 if YOB == 1976 & MOB ==5	& GDR == 1	
qui replace fertf = 7918 if YOB == 1976 & MOB ==6	& GDR == 1	
qui replace fertf = 8161 if YOB == 1976 & MOB ==7	& GDR == 1	
qui replace fertf = 7857 if YOB == 1976 & MOB ==8	& GDR == 1	
qui replace fertf = 8056 if YOB == 1976 & MOB ==9	& GDR == 1	
qui replace fertf = 7446 if YOB == 1976 & MOB ==10	& GDR == 1	
qui replace fertf = 7367 if YOB == 1976 & MOB ==11	& GDR == 1	
qui replace fertf = 7060 if YOB == 1976 & MOB ==12	& GDR == 1	
qui replace fertf = 8231 if YOB == 1977 & MOB ==1	& GDR == 1	
qui replace fertf = 7944 if YOB == 1977 & MOB ==2	& GDR == 1	
qui replace fertf = 9858 if YOB == 1977 & MOB ==3	& GDR == 1	
qui replace fertf = 9594 if YOB == 1977 & MOB ==4	& GDR == 1	
qui replace fertf = 10074 if YOB == 1977 & MOB ==5	& GDR == 1	
qui replace fertf = 9470 if YOB == 1977 & MOB ==6	& GDR == 1	
qui replace fertf = 9299 if YOB == 1977 & MOB ==7	& GDR == 1	
qui replace fertf = 9188 if YOB == 1977 & MOB ==8	& GDR == 1	
qui replace fertf = 9156 if YOB == 1977 & MOB ==9	& GDR == 1	
qui replace fertf = 8600 if YOB == 1977 & MOB ==10	& GDR == 1	
qui replace fertf = 8512 if YOB == 1977 & MOB ==11	& GDR == 1	
qui replace fertf = 8312 if YOB == 1977 & MOB ==12	& GDR == 1	
qui replace fertf = 9378 if YOB == 1978 & MOB ==1	& GDR == 1	
qui replace fertf = 8792 if YOB == 1978 & MOB ==2	& GDR == 1	
qui replace fertf = 10213 if YOB == 1978 & MOB ==3	& GDR == 1	
qui replace fertf = 9685 if YOB == 1978 & MOB ==4	& GDR == 1	
qui replace fertf = 10418 if YOB == 1978 & MOB ==5	& GDR == 1	
qui replace fertf = 9392 if YOB == 1978 & MOB ==6	& GDR == 1	
qui replace fertf = 9665 if YOB == 1978 & MOB ==7	& GDR == 1	
qui replace fertf = 9275 if YOB == 1978 & MOB ==8	& GDR == 1	
qui replace fertf = 9241 if YOB == 1978 & MOB ==9	& GDR == 1	
qui replace fertf = 8975 if YOB == 1978 & MOB ==10	& GDR == 1	
qui replace fertf = 8653 if YOB == 1978 & MOB ==11	& GDR == 1	
qui replace fertf = 8946 if YOB == 1978 & MOB ==12	& GDR == 1	
qui replace fertf = 9583 if YOB == 1979 & MOB ==1	& GDR == 1	
qui replace fertf = 9009 if YOB == 1979 & MOB ==2	& GDR == 1	
qui replace fertf = 10716 if YOB == 1979 & MOB ==3	& GDR == 1	
qui replace fertf = 9725 if YOB == 1979 & MOB ==4	& GDR == 1	
qui replace fertf = 10086 if YOB == 1979 & MOB ==5	& GDR == 1	
qui replace fertf = 9214 if YOB == 1979 & MOB ==6	& GDR == 1	
qui replace fertf = 9732 if YOB == 1979 & MOB ==7	& GDR == 1	
qui replace fertf = 9442 if YOB == 1979 & MOB ==8	& GDR == 1	
qui replace fertf = 9563 if YOB == 1979 & MOB ==9	& GDR == 1	
qui replace fertf = 9212 if YOB == 1979 & MOB ==10	& GDR == 1	
qui replace fertf = 8667 if YOB == 1979 & MOB ==11	& GDR == 1	
qui replace fertf = 8869 if YOB == 1979 & MOB ==12	& GDR == 1	
qui replace fertf = 10145 if YOB == 1980 & MOB ==1	& GDR == 1	
qui replace fertf = 9574 if YOB == 1980 & MOB ==2	& GDR == 1	
qui replace fertf = 10848 if YOB == 1980 & MOB ==3	& GDR == 1	
qui replace fertf = 10434 if YOB == 1980 & MOB ==4	& GDR == 1	
qui replace fertf = 10563 if YOB == 1980 & MOB ==5	& GDR == 1	
qui replace fertf = 9723 if YOB == 1980 & MOB ==6	& GDR == 1	
qui replace fertf = 10438 if YOB == 1980 & MOB ==7	& GDR == 1	
qui replace fertf = 9796 if YOB == 1980 & MOB ==8	& GDR == 1	
qui replace fertf = 10120 if YOB == 1980 & MOB ==9	& GDR == 1	
qui replace fertf = 9540 if YOB == 1980 & MOB ==10	& GDR == 1	
qui replace fertf = 8901 if YOB == 1980 & MOB ==11	& GDR == 1	
qui replace fertf = 9382 if YOB == 1980 & MOB ==12	& GDR == 1	
qui replace fertf = 9806 if YOB == 1981 & MOB ==1	& GDR == 1	
qui replace fertf = 9491 if YOB == 1981 & MOB ==2	& GDR == 1	
qui replace fertf = 10667 if YOB == 1981 & MOB ==3	& GDR == 1	
qui replace fertf = 9870 if YOB == 1981 & MOB ==4	& GDR == 1	
qui replace fertf = 10008 if YOB == 1981 & MOB ==5	& GDR == 1	
qui replace fertf = 9353 if YOB == 1981 & MOB ==6	& GDR == 1	
qui replace fertf = 9856 if YOB == 1981 & MOB ==7	& GDR == 1	
qui replace fertf = 9679 if YOB == 1981 & MOB ==8	& GDR == 1	
qui replace fertf = 9902 if YOB == 1981 & MOB ==9	& GDR == 1	
qui replace fertf = 9113 if YOB == 1981 & MOB ==10	& GDR == 1	
qui replace fertf = 8771 if YOB == 1981 & MOB ==11	& GDR == 1	
qui replace fertf = 9120 if YOB == 1981 & MOB ==12	& GDR == 1	
qui replace fertf = 9561 if YOB == 1982 & MOB ==1	& GDR == 1	
qui replace fertf = 9256 if YOB == 1982 & MOB ==2	& GDR == 1	
qui replace fertf = 10354 if YOB == 1982 & MOB ==3	& GDR == 1	
qui replace fertf = 9944 if YOB == 1982 & MOB ==4	& GDR == 1	
qui replace fertf = 9973 if YOB == 1982 & MOB ==5	& GDR == 1	
qui replace fertf = 9792 if YOB == 1982 & MOB ==6	& GDR == 1	
qui replace fertf = 10247 if YOB == 1982 & MOB ==7	& GDR == 1	
qui replace fertf = 9842 if YOB == 1982 & MOB ==8	& GDR == 1	
qui replace fertf = 10020 if YOB == 1982 & MOB ==9	& GDR == 1	
qui replace fertf = 9374 if YOB == 1982 & MOB ==10	& GDR == 1	
qui replace fertf = 9102 if YOB == 1982 & MOB ==11	& GDR == 1	
qui replace fertf = 9171 if YOB == 1982 & MOB ==12	& GDR == 1	
qui replace fertf = 9603 if YOB == 1983 & MOB ==1	& GDR == 1	
qui replace fertf = 9086 if YOB == 1983 & MOB ==2	& GDR == 1	
qui replace fertf = 10504 if YOB == 1983 & MOB ==3	& GDR == 1	
qui replace fertf = 9416 if YOB == 1983 & MOB ==4	& GDR == 1	
qui replace fertf = 10056 if YOB == 1983 & MOB ==5	& GDR == 1	
qui replace fertf = 9466 if YOB == 1983 & MOB ==6	& GDR == 1	
qui replace fertf = 9686 if YOB == 1983 & MOB ==7	& GDR == 1	
qui replace fertf = 9700 if YOB == 1983 & MOB ==8	& GDR == 1	
qui replace fertf = 9622 if YOB == 1983 & MOB ==9	& GDR == 1	
qui replace fertf = 9094 if YOB == 1983 & MOB ==10	& GDR == 1	
qui replace fertf = 8626 if YOB == 1983 & MOB ==11	& GDR == 1	
qui replace fertf = 8713 if YOB == 1983 & MOB ==12	& GDR == 1	
qui replace fertf = 9329 if YOB == 1984 & MOB ==1	& GDR == 1	
qui replace fertf = 9153 if YOB == 1984 & MOB ==2	& GDR == 1	
qui replace fertf = 10180 if YOB == 1984 & MOB ==3	& GDR == 1	
qui replace fertf = 9095 if YOB == 1984 & MOB ==4	& GDR == 1	
qui replace fertf = 9776 if YOB == 1984 & MOB ==5	& GDR == 1	
qui replace fertf = 9227 if YOB == 1984 & MOB ==6	& GDR == 1	
qui replace fertf = 9661 if YOB == 1984 & MOB ==7	& GDR == 1	
qui replace fertf = 9345 if YOB == 1984 & MOB ==8	& GDR == 1	
qui replace fertf = 9369 if YOB == 1984 & MOB ==9	& GDR == 1	
qui replace fertf = 8838 if YOB == 1984 & MOB ==10	& GDR == 1	
qui replace fertf = 8549 if YOB == 1984 & MOB ==11	& GDR == 1	
qui replace fertf = 8486 if YOB == 1984 & MOB ==12	& GDR == 1	
qui replace fertf = 9560 if YOB == 1985 & MOB ==1	& GDR == 1	
qui replace fertf = 8709 if YOB == 1985 & MOB ==2	& GDR == 1	
qui replace fertf = 10042 if YOB == 1985 & MOB ==3	& GDR == 1	
qui replace fertf = 9488 if YOB == 1985 & MOB ==4	& GDR == 1	
qui replace fertf = 9546 if YOB == 1985 & MOB ==5	& GDR == 1	
qui replace fertf = 8836 if YOB == 1985 & MOB ==6	& GDR == 1	
qui replace fertf = 9644 if YOB == 1985 & MOB ==7	& GDR == 1	
qui replace fertf = 9153 if YOB == 1985 & MOB ==8	& GDR == 1	
qui replace fertf = 9611 if YOB == 1985 & MOB ==9	& GDR == 1	
qui replace fertf = 8677 if YOB == 1985 & MOB ==10	& GDR == 1	
qui replace fertf = 8614 if YOB == 1985 & MOB ==11	& GDR == 1	
qui replace fertf = 8573 if YOB == 1985 & MOB ==12	& GDR == 1	
qui replace fertf = 9489 if YOB == 1986 & MOB ==1	& GDR == 1	
qui replace fertf = 8606 if YOB == 1986 & MOB ==2	& GDR == 1	
qui replace fertf = 9661 if YOB == 1986 & MOB ==3	& GDR == 1	
qui replace fertf = 9087 if YOB == 1986 & MOB ==4	& GDR == 1	
qui replace fertf = 9641 if YOB == 1986 & MOB ==5	& GDR == 1	
qui replace fertf = 8858 if YOB == 1986 & MOB ==6	& GDR == 1	
qui replace fertf = 9379 if YOB == 1986 & MOB ==7	& GDR == 1	
qui replace fertf = 9089 if YOB == 1986 & MOB ==8	& GDR == 1	
qui replace fertf = 9376 if YOB == 1986 & MOB ==9	& GDR == 1	
qui replace fertf = 8696 if YOB == 1986 & MOB ==10	& GDR == 1	
qui replace fertf = 8135 if YOB == 1986 & MOB ==11	& GDR == 1	
qui replace fertf = 8535 if YOB == 1986 & MOB ==12	& GDR == 1	
qui replace fertf = 9160 if YOB == 1987 & MOB ==1	& GDR == 1	
qui replace fertf = 8894 if YOB == 1987 & MOB ==2	& GDR == 1	
qui replace fertf = 9987 if YOB == 1987 & MOB ==3	& GDR == 1	
qui replace fertf = 9298 if YOB == 1987 & MOB ==4	& GDR == 1	
qui replace fertf = 9445 if YOB == 1987 & MOB ==5	& GDR == 1	
qui replace fertf = 9555 if YOB == 1987 & MOB ==6	& GDR == 1	
qui replace fertf = 9534 if YOB == 1987 & MOB ==7	& GDR == 1	
qui replace fertf = 9174 if YOB == 1987 & MOB ==8	& GDR == 1	
qui replace fertf = 9093 if YOB == 1987 & MOB ==9	& GDR == 1	
qui replace fertf = 8651 if YOB == 1987 & MOB ==10	& GDR == 1	
qui replace fertf = 8541 if YOB == 1987 & MOB ==11	& GDR == 1	
qui replace fertf = 8615 if YOB == 1987 & MOB ==12	& GDR == 1	
qui replace fertf = 9108 if YOB == 1988 & MOB ==1	& GDR == 1	
qui replace fertf = 8690 if YOB == 1988 & MOB ==2	& GDR == 1	
qui replace fertf = 9501 if YOB == 1988 & MOB ==3	& GDR == 1	
qui replace fertf = 8473 if YOB == 1988 & MOB ==4	& GDR == 1	
qui replace fertf = 9137 if YOB == 1988 & MOB ==5	& GDR == 1	
qui replace fertf = 8609 if YOB == 1988 & MOB ==6	& GDR == 1	
qui replace fertf = 8926 if YOB == 1988 & MOB ==7	& GDR == 1	
qui replace fertf = 8825 if YOB == 1988 & MOB ==8	& GDR == 1	
qui replace fertf = 9230 if YOB == 1988 & MOB ==9	& GDR == 1	
qui replace fertf = 8248 if YOB == 1988 & MOB ==10	& GDR == 1	
qui replace fertf = 8042 if YOB == 1988 & MOB ==11	& GDR == 1	
qui replace fertf = 8032 if YOB == 1988 & MOB ==12	& GDR == 1	
qui replace fertf = 8196 if YOB == 1989 & MOB ==1	& GDR == 1	
qui replace fertf = 7926 if YOB == 1989 & MOB ==2	& GDR == 1	
qui replace fertf = 8829 if YOB == 1989 & MOB ==3	& GDR == 1	
qui replace fertf = 8093 if YOB == 1989 & MOB ==4	& GDR == 1	
qui replace fertf = 8343 if YOB == 1989 & MOB ==5	& GDR == 1	
qui replace fertf = 8040 if YOB == 1989 & MOB ==6	& GDR == 1	
qui replace fertf = 8429 if YOB == 1989 & MOB ==7	& GDR == 1	
qui replace fertf = 8275 if YOB == 1989 & MOB ==8	& GDR == 1	
qui replace fertf = 8076 if YOB == 1989 & MOB ==9	& GDR == 1	
qui replace fertf = 7724 if YOB == 1989 & MOB ==10	& GDR == 1	
qui replace fertf = 7128 if YOB == 1989 & MOB ==11	& GDR == 1	
qui replace fertf = 7456 if YOB == 1989 & MOB ==12	& GDR == 1	



// Males
qui gen fertm = .
qui replace fertm = 27005	if YOB == 1975 & MOB ==	1	& GDR == 0	
qui replace fertm = 24842	if YOB == 1975 & MOB ==	2	& GDR == 0	
qui replace fertm = 26825	if YOB == 1975 & MOB ==	3	& GDR == 0	
qui replace fertm = 26375	if YOB == 1975 & MOB ==	4	& GDR == 0	
qui replace fertm = 26729	if YOB == 1975 & MOB ==	5	& GDR == 0	
qui replace fertm = 25881	if YOB == 1975 & MOB ==	6	& GDR == 0	
qui replace fertm = 27163	if YOB == 1975 & MOB ==	7	& GDR == 0	
qui replace fertm = 25965	if YOB == 1975 & MOB ==	8	& GDR == 0	
qui replace fertm = 25642	if YOB == 1975 & MOB ==	9	& GDR == 0	
qui replace fertm = 24390	if YOB == 1975 & MOB ==	10	& GDR == 0	
qui replace fertm = 23341	if YOB == 1975 & MOB ==	11	& GDR == 0	
qui replace fertm = 24977	if YOB == 1975 & MOB ==	12	& GDR == 0	
qui replace fertm = 26588	if YOB == 1976 & MOB ==	1	& GDR == 0	
qui replace fertm = 25015	if YOB == 1976 & MOB ==	2	& GDR == 0	
qui replace fertm = 27116	if YOB == 1976 & MOB ==	3	& GDR == 0	
qui replace fertm = 25365	if YOB == 1976 & MOB ==	4	& GDR == 0	
qui replace fertm = 26470	if YOB == 1976 & MOB ==	5	& GDR == 0	
qui replace fertm = 26010	if YOB == 1976 & MOB ==	6	& GDR == 0	
qui replace fertm = 26752	if YOB == 1976 & MOB ==	7	& GDR == 0	
qui replace fertm = 26409	if YOB == 1976 & MOB ==	8	& GDR == 0	
qui replace fertm = 26815	if YOB == 1976 & MOB ==	9	& GDR == 0	
qui replace fertm = 24866	if YOB == 1976 & MOB ==	10	& GDR == 0	
qui replace fertm = 23547	if YOB == 1976 & MOB ==	11	& GDR == 0	
qui replace fertm = 24432	if YOB == 1976 & MOB ==	12	& GDR == 0	
qui replace fertm = 25214	if YOB == 1977 & MOB ==	1	& GDR == 0	
qui replace fertm = 23255	if YOB == 1977 & MOB ==	2	& GDR == 0	
qui replace fertm = 26376	if YOB == 1977 & MOB ==	3	& GDR == 0	
qui replace fertm = 24218	if YOB == 1977 & MOB ==	4	& GDR == 0	
qui replace fertm = 26641	if YOB == 1977 & MOB ==	5	& GDR == 0	
qui replace fertm = 25671	if YOB == 1977 & MOB ==	6	& GDR == 0	
qui replace fertm = 25434	if YOB == 1977 & MOB ==	7	& GDR == 0	
qui replace fertm = 25483	if YOB == 1977 & MOB ==	8	& GDR == 0	
qui replace fertm = 25615	if YOB == 1977 & MOB ==	9	& GDR == 0	
qui replace fertm = 24695	if YOB == 1977 & MOB ==	10	& GDR == 0	
qui replace fertm = 23335	if YOB == 1977 & MOB ==	11	& GDR == 0	
qui replace fertm = 23798	if YOB == 1977 & MOB ==	12	& GDR == 0	
qui replace fertm = 24697	if YOB == 1978 & MOB ==	1	& GDR == 0	
qui replace fertm = 23553	if YOB == 1978 & MOB ==	2	& GDR == 0	
qui replace fertm = 26082	if YOB == 1978 & MOB ==	3	& GDR == 0	
qui replace fertm = 25127	if YOB == 1978 & MOB ==	4	& GDR == 0	
qui replace fertm = 26267	if YOB == 1978 & MOB ==	5	& GDR == 0	
qui replace fertm = 25174	if YOB == 1978 & MOB ==	6	& GDR == 0	
qui replace fertm = 26035	if YOB == 1978 & MOB ==	7	& GDR == 0	
qui replace fertm = 24727	if YOB == 1978 & MOB ==	8	& GDR == 0	
qui replace fertm = 24967	if YOB == 1978 & MOB ==	9	& GDR == 0	
qui replace fertm = 23944	if YOB == 1978 & MOB ==	10	& GDR == 0	
qui replace fertm = 22191	if YOB == 1978 & MOB ==	11	& GDR == 0	
qui replace fertm = 23584	if YOB == 1978 & MOB ==	12	& GDR == 0	
qui replace fertm = 24809	if YOB == 1979 & MOB ==	1	& GDR == 0	
qui replace fertm = 22421	if YOB == 1979 & MOB ==	2	& GDR == 0	
qui replace fertm = 25002	if YOB == 1979 & MOB ==	3	& GDR == 0	
qui replace fertm = 24891	if YOB == 1979 & MOB ==	4	& GDR == 0	
qui replace fertm = 26048	if YOB == 1979 & MOB ==	5	& GDR == 0	
qui replace fertm = 24583	if YOB == 1979 & MOB ==	6	& GDR == 0	
qui replace fertm = 26245	if YOB == 1979 & MOB ==	7	& GDR == 0	
qui replace fertm = 25864	if YOB == 1979 & MOB ==	8	& GDR == 0	
qui replace fertm = 25644	if YOB == 1979 & MOB ==	9	& GDR == 0	
qui replace fertm = 24893	if YOB == 1979 & MOB ==	10	& GDR == 0	
qui replace fertm = 23692	if YOB == 1979 & MOB ==	11	& GDR == 0	
qui replace fertm = 24083	if YOB == 1979 & MOB ==	12	& GDR == 0	
qui replace fertm = 26068	if YOB == 1980 & MOB ==	1	& GDR == 0	
qui replace fertm = 24913	if YOB == 1980 & MOB ==	2	& GDR == 0	
qui replace fertm = 26238	if YOB == 1980 & MOB ==	3	& GDR == 0	
qui replace fertm = 25828	if YOB == 1980 & MOB ==	4	& GDR == 0	
qui replace fertm = 27304	if YOB == 1980 & MOB ==	5	& GDR == 0	
qui replace fertm = 26849	if YOB == 1980 & MOB ==	6	& GDR == 0	
qui replace fertm = 28689	if YOB == 1980 & MOB ==	7	& GDR == 0	
qui replace fertm = 27303	if YOB == 1980 & MOB ==	8	& GDR == 0	
qui replace fertm = 27035	if YOB == 1980 & MOB ==	9	& GDR == 0	
qui replace fertm = 26872	if YOB == 1980 & MOB ==	10	& GDR == 0	
qui replace fertm = 24954	if YOB == 1980 & MOB ==	11	& GDR == 0	
qui replace fertm = 26427	if YOB == 1980 & MOB ==	12	& GDR == 0	
qui replace fertm = 26502	if YOB == 1981 & MOB ==	1	& GDR == 0	
qui replace fertm = 25302	if YOB == 1981 & MOB ==	2	& GDR == 0	
qui replace fertm = 26621	if YOB == 1981 & MOB ==	3	& GDR == 0	
qui replace fertm = 26486	if YOB == 1981 & MOB ==	4	& GDR == 0	
qui replace fertm = 26635	if YOB == 1981 & MOB ==	5	& GDR == 0	
qui replace fertm = 26815	if YOB == 1981 & MOB ==	6	& GDR == 0	
qui replace fertm = 28952	if YOB == 1981 & MOB ==	7	& GDR == 0	
qui replace fertm = 28174	if YOB == 1981 & MOB ==	8	& GDR == 0	
qui replace fertm = 28300	if YOB == 1981 & MOB ==	9	& GDR == 0	
qui replace fertm = 25999	if YOB == 1981 & MOB ==	10	& GDR == 0	
qui replace fertm = 24932	if YOB == 1981 & MOB ==	11	& GDR == 0	
qui replace fertm = 25915	if YOB == 1981 & MOB ==	12	& GDR == 0	
qui replace fertm = 26651	if YOB == 1982 & MOB ==	1	& GDR == 0	
qui replace fertm = 24798	if YOB == 1982 & MOB ==	2	& GDR == 0	
qui replace fertm = 27515	if YOB == 1982 & MOB ==	3	& GDR == 0	
qui replace fertm = 25868	if YOB == 1982 & MOB ==	4	& GDR == 0	
qui replace fertm = 26047	if YOB == 1982 & MOB ==	5	& GDR == 0	
qui replace fertm = 26998	if YOB == 1982 & MOB ==	6	& GDR == 0	
qui replace fertm = 28356	if YOB == 1982 & MOB ==	7	& GDR == 0	
qui replace fertm = 27991	if YOB == 1982 & MOB ==	8	& GDR == 0	
qui replace fertm = 27949	if YOB == 1982 & MOB ==	9	& GDR == 0	
qui replace fertm = 26598	if YOB == 1982 & MOB ==	10	& GDR == 0	
qui replace fertm = 24789	if YOB == 1982 & MOB ==	11	& GDR == 0	
qui replace fertm = 25733	if YOB == 1982 & MOB ==	12	& GDR == 0	
qui replace fertm = 25662	if YOB == 1983 & MOB ==	1	& GDR == 0	
qui replace fertm = 24150	if YOB == 1983 & MOB ==	2	& GDR == 0	
qui replace fertm = 26099	if YOB == 1983 & MOB ==	3	& GDR == 0	
qui replace fertm = 24880	if YOB == 1983 & MOB ==	4	& GDR == 0	
qui replace fertm = 26372	if YOB == 1983 & MOB ==	5	& GDR == 0	
qui replace fertm = 25679	if YOB == 1983 & MOB ==	6	& GDR == 0	
qui replace fertm = 26581	if YOB == 1983 & MOB ==	7	& GDR == 0	
qui replace fertm = 26878	if YOB == 1983 & MOB ==	8	& GDR == 0	
qui replace fertm = 26265	if YOB == 1983 & MOB ==	9	& GDR == 0	
qui replace fertm = 24887	if YOB == 1983 & MOB ==	10	& GDR == 0	
qui replace fertm = 23667	if YOB == 1983 & MOB ==	11	& GDR == 0	
qui replace fertm = 24135	if YOB == 1983 & MOB ==	12	& GDR == 0	
qui replace fertm = 24096	if YOB == 1984 & MOB ==	1	& GDR == 0	
qui replace fertm = 24115	if YOB == 1984 & MOB ==	2	& GDR == 0	
qui replace fertm = 25566	if YOB == 1984 & MOB ==	3	& GDR == 0	
qui replace fertm = 23964	if YOB == 1984 & MOB ==	4	& GDR == 0	
qui replace fertm = 25465	if YOB == 1984 & MOB ==	5	& GDR == 0	
qui replace fertm = 24894	if YOB == 1984 & MOB ==	6	& GDR == 0	
qui replace fertm = 26597	if YOB == 1984 & MOB ==	7	& GDR == 0	
qui replace fertm = 26624	if YOB == 1984 & MOB ==	8	& GDR == 0	
qui replace fertm = 25433	if YOB == 1984 & MOB ==	9	& GDR == 0	
qui replace fertm = 25409	if YOB == 1984 & MOB ==	10	& GDR == 0	
qui replace fertm = 23993	if YOB == 1984 & MOB ==	11	& GDR == 0	
qui replace fertm = 23964	if YOB == 1984 & MOB ==	12	& GDR == 0	
qui replace fertm = 25121	if YOB == 1985 & MOB ==	1	& GDR == 0	
qui replace fertm = 23261	if YOB == 1985 & MOB ==	2	& GDR == 0	
qui replace fertm = 25799	if YOB == 1985 & MOB ==	3	& GDR == 0	
qui replace fertm = 24727	if YOB == 1985 & MOB ==	4	& GDR == 0	
qui replace fertm = 25979	if YOB == 1985 & MOB ==	5	& GDR == 0	
qui replace fertm = 24051	if YOB == 1985 & MOB ==	6	& GDR == 0	
qui replace fertm = 26932	if YOB == 1985 & MOB ==	7	& GDR == 0	
qui replace fertm = 25935	if YOB == 1985 & MOB ==	8	& GDR == 0	
qui replace fertm = 26132	if YOB == 1985 & MOB ==	9	& GDR == 0	
qui replace fertm = 25767	if YOB == 1985 & MOB ==	10	& GDR == 0	
qui replace fertm = 23202	if YOB == 1985 & MOB ==	11	& GDR == 0	
qui replace fertm = 23147	if YOB == 1985 & MOB ==	12	& GDR == 0	
qui replace fertm = 26191	if YOB == 1986 & MOB ==	1	& GDR == 0	
qui replace fertm = 24012	if YOB == 1986 & MOB ==	2	& GDR == 0	
qui replace fertm = 25953	if YOB == 1986 & MOB ==	3	& GDR == 0	
qui replace fertm = 26880	if YOB == 1986 & MOB ==	4	& GDR == 0	
qui replace fertm = 26973	if YOB == 1986 & MOB ==	5	& GDR == 0	
qui replace fertm = 26907	if YOB == 1986 & MOB ==	6	& GDR == 0	
qui replace fertm = 28164	if YOB == 1986 & MOB ==	7	& GDR == 0	
qui replace fertm = 27920	if YOB == 1986 & MOB ==	8	& GDR == 0	
qui replace fertm = 28739	if YOB == 1986 & MOB ==	9	& GDR == 0	
qui replace fertm = 27340	if YOB == 1986 & MOB ==	10	& GDR == 0	
qui replace fertm = 25060	if YOB == 1986 & MOB ==	11	& GDR == 0	
qui replace fertm = 27045	if YOB == 1986 & MOB ==	12	& GDR == 0	
qui replace fertm = 27379	if YOB == 1987 & MOB ==	1	& GDR == 0	
qui replace fertm = 24646	if YOB == 1987 & MOB ==	2	& GDR == 0	
qui replace fertm = 26956	if YOB == 1987 & MOB ==	3	& GDR == 0	
qui replace fertm = 26398	if YOB == 1987 & MOB ==	4	& GDR == 0	
qui replace fertm = 28096	if YOB == 1987 & MOB ==	5	& GDR == 0	
qui replace fertm = 28973	if YOB == 1987 & MOB ==	6	& GDR == 0	
qui replace fertm = 30195	if YOB == 1987 & MOB ==	7	& GDR == 0	
qui replace fertm = 29354	if YOB == 1987 & MOB ==	8	& GDR == 0	
qui replace fertm = 29365	if YOB == 1987 & MOB ==	9	& GDR == 0	
qui replace fertm = 27187	if YOB == 1987 & MOB ==	10	& GDR == 0	
qui replace fertm = 25524	if YOB == 1987 & MOB ==	11	& GDR == 0	
qui replace fertm = 26586	if YOB == 1987 & MOB ==	12	& GDR == 0	
qui replace fertm = 29053	if YOB == 1988 & MOB ==	1	& GDR == 0	
qui replace fertm = 27506	if YOB == 1988 & MOB ==	2	& GDR == 0	
qui replace fertm = 29903	if YOB == 1988 & MOB ==	3	& GDR == 0	
qui replace fertm = 27149	if YOB == 1988 & MOB ==	4	& GDR == 0	
qui replace fertm = 29613	if YOB == 1988 & MOB ==	5	& GDR == 0	
qui replace fertm = 28362	if YOB == 1988 & MOB ==	6	& GDR == 0	
qui replace fertm = 30381	if YOB == 1988 & MOB ==	7	& GDR == 0	
qui replace fertm = 30762	if YOB == 1988 & MOB ==	8	& GDR == 0	
qui replace fertm = 30858	if YOB == 1988 & MOB ==	9	& GDR == 0	
qui replace fertm = 28650	if YOB == 1988 & MOB ==	10	& GDR == 0	
qui replace fertm = 27306	if YOB == 1988 & MOB ==	11	& GDR == 0	
qui replace fertm = 28595	if YOB == 1988 & MOB ==	12	& GDR == 0	
qui replace fertm = 28534	if YOB == 1989 & MOB ==	1	& GDR == 0	
qui replace fertm = 27054	if YOB == 1989 & MOB ==	2	& GDR == 0	
qui replace fertm = 29227	if YOB == 1989 & MOB ==	3	& GDR == 0	
qui replace fertm = 27994	if YOB == 1989 & MOB ==	4	& GDR == 0	
qui replace fertm = 29687	if YOB == 1989 & MOB ==	5	& GDR == 0	
qui replace fertm = 28938	if YOB == 1989 & MOB ==	6	& GDR == 0	
qui replace fertm = 31394	if YOB == 1989 & MOB ==	7	& GDR == 0	
qui replace fertm = 31147	if YOB == 1989 & MOB ==	8	& GDR == 0	
qui replace fertm = 29674	if YOB == 1989 & MOB ==	9	& GDR == 0	
qui replace fertm = 28740	if YOB == 1989 & MOB ==	10	& GDR == 0	
qui replace fertm = 27692	if YOB == 1989 & MOB ==	11	& GDR == 0	
qui replace fertm = 29098	if YOB == 1989 & MOB ==	12	& GDR == 0	
qui replace fertm = 8414	if YOB == 1975 & MOB ==	1	& GDR == 1	
qui replace fertm = 7373	if YOB == 1975 & MOB ==	2	& GDR == 1	
qui replace fertm = 8467	if YOB == 1975 & MOB ==	3	& GDR == 1	
qui replace fertm = 8331	if YOB == 1975 & MOB ==	4	& GDR == 1	
qui replace fertm = 8470	if YOB == 1975 & MOB ==	5	& GDR == 1	
qui replace fertm = 7718	if YOB == 1975 & MOB ==	6	& GDR == 1	
qui replace fertm = 8122	if YOB == 1975 & MOB ==	7	& GDR == 1	
qui replace fertm = 7769	if YOB == 1975 & MOB ==	8	& GDR == 1	
qui replace fertm = 7724	if YOB == 1975 & MOB ==	9	& GDR == 1	
qui replace fertm = 7106	if YOB == 1975 & MOB ==	10	& GDR == 1	
qui replace fertm = 7025	if YOB == 1975 & MOB ==	11	& GDR == 1	
qui replace fertm = 7136	if YOB == 1975 & MOB ==	12	& GDR == 1	
qui replace fertm = 8880	if YOB == 1976 & MOB ==	1	& GDR == 1	
qui replace fertm = 7998	if YOB == 1976 & MOB ==	2	& GDR == 1	
qui replace fertm = 9152	if YOB == 1976 & MOB ==	3	& GDR == 1	
qui replace fertm = 8610	if YOB == 1976 & MOB ==	4	& GDR == 1	
qui replace fertm = 8791	if YOB == 1976 & MOB ==	5	& GDR == 1	
qui replace fertm = 8352	if YOB == 1976 & MOB ==	6	& GDR == 1	
qui replace fertm = 8608	if YOB == 1976 & MOB ==	7	& GDR == 1	
qui replace fertm = 8461	if YOB == 1976 & MOB ==	8	& GDR == 1	
qui replace fertm = 8634	if YOB == 1976 & MOB ==	9	& GDR == 1	
qui replace fertm = 7800	if YOB == 1976 & MOB ==	10	& GDR == 1	
qui replace fertm = 7518	if YOB == 1976 & MOB ==	11	& GDR == 1	
qui replace fertm = 7560	if YOB == 1976 & MOB ==	12	& GDR == 1	
qui replace fertm = 8648	if YOB == 1977 & MOB ==	1	& GDR == 1	
qui replace fertm = 8601	if YOB == 1977 & MOB ==	2	& GDR == 1	
qui replace fertm = 10701	if YOB == 1977 & MOB ==	3	& GDR == 1	
qui replace fertm = 10395	if YOB == 1977 & MOB ==	4	& GDR == 1	
qui replace fertm = 10710	if YOB == 1977 & MOB ==	5	& GDR == 1	
qui replace fertm = 9847	if YOB == 1977 & MOB ==	6	& GDR == 1	
qui replace fertm = 10047	if YOB == 1977 & MOB ==	7	& GDR == 1	
qui replace fertm = 9536	if YOB == 1977 & MOB ==	8	& GDR == 1	
qui replace fertm = 9794	if YOB == 1977 & MOB ==	9	& GDR == 1	
qui replace fertm = 9022	if YOB == 1977 & MOB ==	10	& GDR == 1	
qui replace fertm = 8663	if YOB == 1977 & MOB ==	11	& GDR == 1	
qui replace fertm = 8950	if YOB == 1977 & MOB ==	12	& GDR == 1	
qui replace fertm = 9935	if YOB == 1978 & MOB ==	1	& GDR == 1	
qui replace fertm = 9225	if YOB == 1978 & MOB ==	2	& GDR == 1	
qui replace fertm = 11137	if YOB == 1978 & MOB ==	3	& GDR == 1	
qui replace fertm = 10448	if YOB == 1978 & MOB ==	4	& GDR == 1	
qui replace fertm = 11068	if YOB == 1978 & MOB ==	5	& GDR == 1	
qui replace fertm = 9990	if YOB == 1978 & MOB ==	6	& GDR == 1	
qui replace fertm = 10310	if YOB == 1978 & MOB ==	7	& GDR == 1	
qui replace fertm = 9698	if YOB == 1978 & MOB ==	8	& GDR == 1	
qui replace fertm = 9898	if YOB == 1978 & MOB ==	9	& GDR == 1	
qui replace fertm = 9401	if YOB == 1978 & MOB ==	10	& GDR == 1	
qui replace fertm = 9047	if YOB == 1978 & MOB ==	11	& GDR == 1	
qui replace fertm = 9361	if YOB == 1978 & MOB ==	12	& GDR == 1	
qui replace fertm = 10242	if YOB == 1979 & MOB ==	1	& GDR == 1	
qui replace fertm = 9412	if YOB == 1979 & MOB ==	2	& GDR == 1	
qui replace fertm = 11078	if YOB == 1979 & MOB ==	3	& GDR == 1	
qui replace fertm = 10305	if YOB == 1979 & MOB ==	4	& GDR == 1	
qui replace fertm = 10652	if YOB == 1979 & MOB ==	5	& GDR == 1	
qui replace fertm = 9678	if YOB == 1979 & MOB ==	6	& GDR == 1	
qui replace fertm = 10439	if YOB == 1979 & MOB ==	7	& GDR == 1	
qui replace fertm = 10418	if YOB == 1979 & MOB ==	8	& GDR == 1	
qui replace fertm = 10338	if YOB == 1979 & MOB ==	9	& GDR == 1	
qui replace fertm = 9722	if YOB == 1979 & MOB ==	10	& GDR == 1	
qui replace fertm = 9519	if YOB == 1979 & MOB ==	11	& GDR == 1	
qui replace fertm = 9612	if YOB == 1979 & MOB ==	12	& GDR == 1	
qui replace fertm = 10637	if YOB == 1980 & MOB ==	1	& GDR == 1	
qui replace fertm = 10122	if YOB == 1980 & MOB ==	2	& GDR == 1	
qui replace fertm = 11294	if YOB == 1980 & MOB ==	3	& GDR == 1	
qui replace fertm = 11097	if YOB == 1980 & MOB ==	4	& GDR == 1	
qui replace fertm = 11102	if YOB == 1980 & MOB ==	5	& GDR == 1	
qui replace fertm = 10259	if YOB == 1980 & MOB ==	6	& GDR == 1	
qui replace fertm = 10926	if YOB == 1980 & MOB ==	7	& GDR == 1	
qui replace fertm = 10347	if YOB == 1980 & MOB ==	8	& GDR == 1	
qui replace fertm = 10458	if YOB == 1980 & MOB ==	9	& GDR == 1	
qui replace fertm = 9879	if YOB == 1980 & MOB ==	10	& GDR == 1	
qui replace fertm = 9627	if YOB == 1980 & MOB ==	11	& GDR == 1	
qui replace fertm = 9920	if YOB == 1980 & MOB ==	12	& GDR == 1	
qui replace fertm = 10497	if YOB == 1981 & MOB ==	1	& GDR == 1	
qui replace fertm = 10022	if YOB == 1981 & MOB ==	2	& GDR == 1	
qui replace fertm = 11123	if YOB == 1981 & MOB ==	3	& GDR == 1	
qui replace fertm = 10622	if YOB == 1981 & MOB ==	4	& GDR == 1	
qui replace fertm = 10388	if YOB == 1981 & MOB ==	5	& GDR == 1	
qui replace fertm = 9992	if YOB == 1981 & MOB ==	6	& GDR == 1	
qui replace fertm = 10434	if YOB == 1981 & MOB ==	7	& GDR == 1	
qui replace fertm = 10273	if YOB == 1981 & MOB ==	8	& GDR == 1	
qui replace fertm = 10341	if YOB == 1981 & MOB ==	9	& GDR == 1	
qui replace fertm = 9557	if YOB == 1981 & MOB ==	10	& GDR == 1	
qui replace fertm = 9098	if YOB == 1981 & MOB ==	11	& GDR == 1	
qui replace fertm = 9560	if YOB == 1981 & MOB ==	12	& GDR == 1	
qui replace fertm = 10345	if YOB == 1982 & MOB ==	1	& GDR == 1	
qui replace fertm = 9700	if YOB == 1982 & MOB ==	2	& GDR == 1	
qui replace fertm = 11104	if YOB == 1982 & MOB ==	3	& GDR == 1	
qui replace fertm = 10470	if YOB == 1982 & MOB ==	4	& GDR == 1	
qui replace fertm = 10661	if YOB == 1982 & MOB ==	5	& GDR == 1	
qui replace fertm = 10221	if YOB == 1982 & MOB ==	6	& GDR == 1	
qui replace fertm = 10855	if YOB == 1982 & MOB ==	7	& GDR == 1	
qui replace fertm = 10437	if YOB == 1982 & MOB ==	8	& GDR == 1	
qui replace fertm = 10476	if YOB == 1982 & MOB ==	9	& GDR == 1	
qui replace fertm = 9868	if YOB == 1982 & MOB ==	10	& GDR == 1	
qui replace fertm = 9397	if YOB == 1982 & MOB ==	11	& GDR == 1	
qui replace fertm = 9932	if YOB == 1982 & MOB ==	12	& GDR == 1	
qui replace fertm = 10080	if YOB == 1983 & MOB ==	1	& GDR == 1	
qui replace fertm = 9589	if YOB == 1983 & MOB ==	2	& GDR == 1	
qui replace fertm = 10951	if YOB == 1983 & MOB ==	3	& GDR == 1	
qui replace fertm = 10074	if YOB == 1983 & MOB ==	4	& GDR == 1	
qui replace fertm = 10599	if YOB == 1983 & MOB ==	5	& GDR == 1	
qui replace fertm = 10238	if YOB == 1983 & MOB ==	6	& GDR == 1	
qui replace fertm = 10385	if YOB == 1983 & MOB ==	7	& GDR == 1	
qui replace fertm = 10219	if YOB == 1983 & MOB ==	8	& GDR == 1	
qui replace fertm = 10065	if YOB == 1983 & MOB ==	9	& GDR == 1	
qui replace fertm = 9449	if YOB == 1983 & MOB ==	10	& GDR == 1	
qui replace fertm = 9342	if YOB == 1983 & MOB ==	11	& GDR == 1	
qui replace fertm = 9193	if YOB == 1983 & MOB ==	12	& GDR == 1	
qui replace fertm = 9807	if YOB == 1984 & MOB ==	1	& GDR == 1	
qui replace fertm = 9582	if YOB == 1984 & MOB ==	2	& GDR == 1	
qui replace fertm = 10513	if YOB == 1984 & MOB ==	3	& GDR == 1	
qui replace fertm = 9815	if YOB == 1984 & MOB ==	4	& GDR == 1	
qui replace fertm = 10415	if YOB == 1984 & MOB ==	5	& GDR == 1	
qui replace fertm = 9697	if YOB == 1984 & MOB ==	6	& GDR == 1	
qui replace fertm = 10196	if YOB == 1984 & MOB ==	7	& GDR == 1	
qui replace fertm = 9768	if YOB == 1984 & MOB ==	8	& GDR == 1	
qui replace fertm = 9808	if YOB == 1984 & MOB ==	9	& GDR == 1	
qui replace fertm = 9345	if YOB == 1984 & MOB ==	10	& GDR == 1	
qui replace fertm = 9100	if YOB == 1984 & MOB ==	11	& GDR == 1	
qui replace fertm = 9081	if YOB == 1984 & MOB ==	12	& GDR == 1	
qui replace fertm = 10117	if YOB == 1985 & MOB ==	1	& GDR == 1	
qui replace fertm = 9182	if YOB == 1985 & MOB ==	2	& GDR == 1	
qui replace fertm = 10664	if YOB == 1985 & MOB ==	3	& GDR == 1	
qui replace fertm = 10115	if YOB == 1985 & MOB ==	4	& GDR == 1	
qui replace fertm = 10241	if YOB == 1985 & MOB ==	5	& GDR == 1	
qui replace fertm = 9558	if YOB == 1985 & MOB ==	6	& GDR == 1	
qui replace fertm = 10109	if YOB == 1985 & MOB ==	7	& GDR == 1	
qui replace fertm = 9951	if YOB == 1985 & MOB ==	8	& GDR == 1	
qui replace fertm = 9853	if YOB == 1985 & MOB ==	9	& GDR == 1	
qui replace fertm = 9271	if YOB == 1985 & MOB ==	10	& GDR == 1	
qui replace fertm = 9037	if YOB == 1985 & MOB ==	11	& GDR == 1	
qui replace fertm = 9097	if YOB == 1985 & MOB ==	12	& GDR == 1	
qui replace fertm = 9901	if YOB == 1986 & MOB ==	1	& GDR == 1	
qui replace fertm = 8917	if YOB == 1986 & MOB ==	2	& GDR == 1	
qui replace fertm = 10103	if YOB == 1986 & MOB ==	3	& GDR == 1	
qui replace fertm = 9867	if YOB == 1986 & MOB ==	4	& GDR == 1	
qui replace fertm = 9847	if YOB == 1986 & MOB ==	5	& GDR == 1	
qui replace fertm = 9394	if YOB == 1986 & MOB ==	6	& GDR == 1	
qui replace fertm = 9686	if YOB == 1986 & MOB ==	7	& GDR == 1	
qui replace fertm = 9521	if YOB == 1986 & MOB ==	8	& GDR == 1	
qui replace fertm = 9998	if YOB == 1986 & MOB ==	9	& GDR == 1	
qui replace fertm = 9109	if YOB == 1986 & MOB ==	10	& GDR == 1	
qui replace fertm = 8510	if YOB == 1986 & MOB ==	11	& GDR == 1	
qui replace fertm = 8864	if YOB == 1986 & MOB ==	12	& GDR == 1	
qui replace fertm = 9445	if YOB == 1987 & MOB ==	1	& GDR == 1	
qui replace fertm = 9189	if YOB == 1987 & MOB ==	2	& GDR == 1	
qui replace fertm = 10550	if YOB == 1987 & MOB ==	3	& GDR == 1	
qui replace fertm = 9973	if YOB == 1987 & MOB ==	4	& GDR == 1	
qui replace fertm = 10305	if YOB == 1987 & MOB ==	5	& GDR == 1	
qui replace fertm = 9900	if YOB == 1987 & MOB ==	6	& GDR == 1	
qui replace fertm = 10272	if YOB == 1987 & MOB ==	7	& GDR == 1	
qui replace fertm = 9530	if YOB == 1987 & MOB ==	8	& GDR == 1	
qui replace fertm = 9780	if YOB == 1987 & MOB ==	9	& GDR == 1	
qui replace fertm = 9194	if YOB == 1987 & MOB ==	10	& GDR == 1	
qui replace fertm = 8904	if YOB == 1987 & MOB ==	11	& GDR == 1	
qui replace fertm = 8970	if YOB == 1987 & MOB ==	12	& GDR == 1	
qui replace fertm = 9544	if YOB == 1988 & MOB ==	1	& GDR == 1	
qui replace fertm = 8957	if YOB == 1988 & MOB ==	2	& GDR == 1	
qui replace fertm = 10104	if YOB == 1988 & MOB ==	3	& GDR == 1	
qui replace fertm = 9138	if YOB == 1988 & MOB ==	4	& GDR == 1	
qui replace fertm = 9695	if YOB == 1988 & MOB ==	5	& GDR == 1	
qui replace fertm = 9212	if YOB == 1988 & MOB ==	6	& GDR == 1	
qui replace fertm = 9502	if YOB == 1988 & MOB ==	7	& GDR == 1	
qui replace fertm = 9583	if YOB == 1988 & MOB ==	8	& GDR == 1	
qui replace fertm = 9480	if YOB == 1988 & MOB ==	9	& GDR == 1	
qui replace fertm = 8745	if YOB == 1988 & MOB ==	10	& GDR == 1	
qui replace fertm = 8504	if YOB == 1988 & MOB ==	11	& GDR == 1	
qui replace fertm = 8449	if YOB == 1988 & MOB ==	12	& GDR == 1	
qui replace fertm = 8818	if YOB == 1989 & MOB ==	1	& GDR == 1	
qui replace fertm = 8600	if YOB == 1989 & MOB ==	2	& GDR == 1	
qui replace fertm = 9186	if YOB == 1989 & MOB ==	3	& GDR == 1	
qui replace fertm = 8563	if YOB == 1989 & MOB ==	4	& GDR == 1	
qui replace fertm = 8958	if YOB == 1989 & MOB ==	5	& GDR == 1	
qui replace fertm = 8418	if YOB == 1989 & MOB ==	6	& GDR == 1	
qui replace fertm = 8825	if YOB == 1989 & MOB ==	7	& GDR == 1	
qui replace fertm = 8804	if YOB == 1989 & MOB ==	8	& GDR == 1	
qui replace fertm = 8636	if YOB == 1989 & MOB ==	9	& GDR == 1	
qui replace fertm = 8120	if YOB == 1989 & MOB ==	10	& GDR == 1	
qui replace fertm = 7717	if YOB == 1989 & MOB ==	11	& GDR == 1	
qui replace fertm = 7762	if YOB == 1989 & MOB ==	12	& GDR == 1	

rename fertf fertf_GDR
rename fertm fertm_GDR
qui gen fert_GDR = fertf + fertm

bys YOB GDR: egen sum_fert_GDR = total(fert_GDR)
bys  YOB GDR: egen sum_fertm_GDR = total(fertm_GDR)
bys  YOB GDR: egen sum_fertf_GDR = total(fertf_GDR)
qui gen ratio_pop  = fert_GDR /sum_fert_GDR
qui gen ratio_popm = fertm_GDR/sum_fertm_GDR
qui gen ratio_popf = fertf_GDR/sum_fertf_GDR
drop sum_fert*
qui drop if YOB >= 1981
save "$temp/geburten_gdr", replace
	

