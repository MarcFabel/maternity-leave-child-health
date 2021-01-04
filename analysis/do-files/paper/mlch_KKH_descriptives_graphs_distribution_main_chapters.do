global path  "F:\econ\m-l-c-h/analysis"	//MAC
global graph_paper "$path/graphs/paper" 


import excel "$path\source\2014_Diagnosedaten\DiagnosedatenKrankenhaus2120621147005.xlsx", sheet("2.1.1.1") cellrange(A1:L72) clear

*delete unwanted rows
qui gen temp = _n
qui drop if temp < 7

* Rename variables
qui rename B icd_code
qui rename C diagnose_desc
qui rename E d_1
qui rename F d_1_5
qui rename G d_5_10
qui rename H d_10_15
qui rename I d_15_20
qui rename J d_20_25
qui rename K d_25_30
qui rename L d_30_35

* nur hauptdiagnosekapital behalten: 
keep if temp == 12 | temp == 17 | temp == 34 | temp == 35 | temp == 37 | temp == 40 | ///
	temp == 42 | temp == 43 | temp == 44 | temp == 48 | temp == 53 | temp == 56 | ///
	temp == 57 | temp == 59 | temp == 61 | temp == 62 | temp == 63 | temp == 66 | /// 
	temp == 68 
	
* drop unneeded variables
drop A	D

destring d_*, replace force
qui gen d_0_5 = d_1 + d_1_5
order icd diagn d_0
drop d_1 d_1_5

*drop Schwangerschaft
drop if temp == 61

/* rausfinden: Was ist über alle Altersgruppen die fünf hÄufisten Krankheiten
egen temp2 = rowtotal(d_*)
sort temp2
*/

*invertieren vom Datenset
drop  diagnose_desc temp 
reshape long d_ , i(icd_code) j(age,string)
*spaces rauslöschen
qui replace icd = "D50_D90" if icd == "D50-D90  "
qui replace icd = "E00_E90" if icd == "E00-E90  "
qui replace icd = "F00_F99" if icd == "F00-F99  "
qui replace icd = "G00_G99" if icd == "G00-G99  "
qui replace icd = "H00_H59" if icd == "H00-H59  "
qui replace icd = "H60_H95" if icd == "H60-H95  "
qui replace icd = "I00_I99" if icd == "I00-I99  "
qui replace icd = "J00_J99" if icd == "J00-J99  "
qui replace icd = "K00_K93" if icd == "K00-K93  "
qui replace icd = "L00_L99" if icd == "L00-L99  "
qui replace icd = "N00_N99" if icd == "N00-N99  "
qui replace icd = "P00_P96" if icd == "P00-P96  "
qui replace icd = "Q00_Q99" if icd == "Q00-Q99  "
qui replace icd = "R00_R99" if icd == "R00-R99  "
qui replace icd = "S00_T98" if icd == "S00-T98  "

qui replace icd = "A00_B99" if icd == "A00-B99"
qui replace icd = "C00_D48" if icd == "C00-D48"
qui replace icd = "M00_M99" if icd == "M00-M99"

reshape wide d_, i(age) j(icd_code,string)

qui gen age2 = 1 if age == "0_5"
qui replace age2 = 2 if age == "5_10"
qui replace age2 = 3 if age == "10_15" 
qui replace age2 = 4 if age == "15_20"
qui replace age2 = 5 if age == "20_25"
qui replace age2 = 6 if age == "25_30"
qui replace age2 = 7 if age == "30_35"

order age2 
labe define AGE 1 "0-5" 2 "5-10" 3 "10-15" 4 "15-20" 5 "20-25" 6 "25-30" 7 "30-35" 
label val age2 AGE 
drop age
rename age2 age
sort age
label variable age "Age brackets"



* Englische labels


* rest kategorien definieren

**************** Ende Vorbereitung 
/*
* Graph für alle ab 0 Altersgruppen mit jeweilgen top %
qui gen rest = d_C00_D48+ d_D50_D90+ d_E00_E90+ d_G00_G99+ d_H00_H59+ d_H60_H95+ d_I00_I99+ d_L00_L99
graph bar d_A00_B99  d_F00_F99 d_J00_J99 d_K00_K93 d_M00_M99 d_N00_N99 d_P00_P96 ///
	d_Q00_Q99 d_R00_R99 d_S00_T98 rest, over(age) stack


* 15 onwards
qui egen rest_from15 = rowtotal(d_A00_B99 d_C00_D48 d_D50_D90 d_E00_E90  d_G00_G99 d_H00_H59 d_H60_H95 d_I00_I99  d_L00_L99  d_P00_P96 d_Q00_Q99) 	
graph bar d_F00_F99 d_J00_J99 d_K00_K93 d_M00_M99 d_N00_N99 d_R00_R99 d_S00_T98 rest_from15 if age >3, over(age) stack
*/


* Natalia graph 
qui egen rest_natalia = rowtotal(d_C00_D48 d_D50_D90 d_E00_E90  d_G00_G99 d_H00_H59 d_H60_H95 d_I00_I99  d_L00_L99 d_M00_M99 d_N00_N99 d_P00_P96 d_Q00_Q99 d_R00_R99)

foreach var of varlist d_* rest* {
	qui replace `var' = `var' / 1000
}

graph bar d_S00_T98 d_F00_F99 d_J00_J99 d_K00_K93  d_A00_B99 rest_nata, over(age) stack ///
	ytitle("Absolute numbers [in thousand]") ylabel(,nogrid) ///
	legend( lab(1 "Injury, poisoning; other consequences of external causes") ///
		lab(2 "Mental & behavioral disorders") lab(3 "Diseases of the respiratory system ") ///
		lab(4 "Diseases of the digestive system") lab(5 "Certain infectious and parasitic diseases") ///
		lab(6 "Remaining diagnoses") ///
	size(vsmall)) ///
	bar(1, color(navy)) bar(2, color(cranberry)) bar(3, color(forest_green)) ///
		bar(4,color(dkorange)) bar(5, color(maroon)) bar(6, color(gs8%30)) ///
	scheme(s1mono) plotregion(color(white))
	graph export "$graph_paper/top5diagnoses_across_agegroups.pdf", as(pdf) replace

	
*als nächstes noch die Farben verändern


*was sind über alle Altersgruppen die häufigsten diagnosen, sodass man die 5 Hauptdiagnosen darstellt  
* a la Natalia.... i.e. sind die 5 ausgewählten die richtigen Diagnosen? 


/*


graph bar d_A00_B99 d_C00_D48, over(age) stack

* wie soll der Graph grob gehen
