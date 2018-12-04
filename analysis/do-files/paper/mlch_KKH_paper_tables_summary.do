// Summary statistics
*********************************************************************************
*main diagnosis chapter

use "$temp\KKH_final_R1", clear
run "$auxiliary/varlists_varnames_sample-spcifications"

// summ for main chapters

#delimit ;
global summ_varlist 
	"r_fert_hospital2 
	r_fert_d1 
	r_fert_d2 
	r_fert_d5 
	r_fert_d6 
	r_fert_d7 
	r_fert_d8 
	r_fert_d9 
	r_fert_d10 
	r_fert_d11 
	r_fert_d12 
	r_fert_d13 
	r_fert_d17 
	r_fert_d18";
#delimit cr
eststo clear
 qui estpost sum $summ_varlist  if treat ==1 & after == 0
 
 esttab, cells("mean(fmt(%10.3fc)) sd(fmt(%10.3fc)) min(fmt(%10.2fc)) max(fmt(%10.2fc))") ///
	nonumber noobs nomtitles label  collabels(Mean "SD" Min Max)
	
* wird per Hand dazugefügt

*********************************************************************************
// 2) Mental and behavioral disorders


*define variable that contains varname
local j = 1
foreach 1 in "d5" "organic" "drug_abuse" "shizophrenia" "affective" "neurosis" "phys_factors" "personality" "retardation" "development" "childhood" { //  "development" "childhood"
	use "$path/tables/LfStat_GWAP/lc_`1'_yrs_brckts", clear
	qui gen var = `j'
	qui gen var_string = "`1'"
	qui save "$temp/lc_`1'_yrs_brckts_ed", replace
	local j = `j'+1
} // end 1: varlist
*append
qui use  "$temp/lc_d5_yrs_brckts_ed",clear	
foreach 1 in "organic" "drug_abuse" "shizophrenia" "affective" "neurosis" "phys_factors" "personality" "retardation" "development" "childhood" { //  "development" "childhood"
	qui append using "$temp/lc_`1'_yrs_brckts_ed"
} // end 1: varlist


*restrict to top 5 only 
*drop if var == 2 | var == 7 | var == 9	
 // OLD LABEL
*define label for variable
#delim ;
label define VAR
	1  "d5"
	2  "organic"
	3  "psychoactive substances"
	4  "schizophrenia"
	5  "affective"
	6  "neurosis"
	7  "physical factors"
	8  "personality"
	9  "retardation"
	10 "development"
	11 "childhood";
#delimit cr
label val var VAR

order var
keep if bandwidth == 6 & year == -98
*SD Rückrechnen 
qui gen SD = abs(beta / sd*100)


order var mean SD

*rauskopieren mit br

