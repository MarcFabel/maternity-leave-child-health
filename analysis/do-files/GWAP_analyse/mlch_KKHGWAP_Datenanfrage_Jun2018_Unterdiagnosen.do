********************************************************************************
* Datenanfrage 21. Juni 2018

/*
Notiz an Herrn Bergmann: 

Ich beantrage die Anzahl von vier Diagnosen für zwei Geburtskohorten für die Jahre 1995-2014: 

Anschuliches Beispiel: wieviel Diagnosen für Shizophrenie wurden im Jahr 2001 für die 
Kohorte der Personen, die zwischen November 1977 und Oktober 1978 geboren wurden, gestellt. 
*/



*open dataset
use "$temp/KKH_final_gdr_level", clear
run "auxiliary_varlists_varnames_sample-spcifications"

*restrict to relevant sample
keep if GDR == 0 
keep if treat == 1 | control == 2

*adjust label
label define CONTROL 2 "[2]control group: born 11/77-10/78" 4 "[4]treatment group: born 11/78-10/79"
label values control CONTROL

* aggregate data to the cohort x year level
collapse (sum) shizophrenia affective neurosis personality , by(year control)
qui save "$tables/number_diagnoses_per_year", replace 
