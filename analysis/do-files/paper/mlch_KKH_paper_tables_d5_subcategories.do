// Generate TABLE FROM d5 SUBKATEGORIES



/* 
ACHTUNG: + muss manuell durch * ersetzt werden, mit * funktioniert es nicht....  
*/


clear all
set more off 
use "$temp/d5_subcategories_results", clear
keep if bandwidth == 6
keep if year == -98 | (year >= 1 & year <= 4)

recode year (-98=0)

// Setup Program that generates lines that can be copied i tabel
foreach 1 of numlist 1 (1) 6 {
	foreach yrs  of numlist 0 1 2 3 4 {
		foreach j in "" "_f" "_m" {
			sum beta`j' if var == `1' & year == `yrs'
			scalar define beta`1'`j'_`yrs' = round(r(mean), .001 )
			scalar define beta`1'`j'_`yrs'_string = string(beta`1'`j'_`yrs',"%09.3fc") // define string that contains leading zeros
			sum se`j' if var == `1' & year == `yrs'
			scalar define se`1'`j'_`yrs'  = round(r(mean), .001 )
			scalar define t`1'`j'_`yrs' = abs(beta`1'`j'_`yrs' / se`1'`j'_`yrs')
			scalar def p`1'`j'_`yrs' = (2 * ttail(23, abs(t`1'`j'_`yrs')))		// Regressions have 23 degrees of freedom
			scalar define se`1'`j'_`yrs'_string = string(se`1'`j'_`yrs',"%09.3fc")
			if p`1'`j'_`yrs' > 0.1 {
				scalar define star`1'`j'_`yrs' = ""
			}
			if (p`1'`j'_`yrs' > 0.05  & p`1'`j'_`yrs' <= 0.1)  {
				scalar define star`1'`j'_`yrs' = "\sym{+}"
			}
			if (p`1'`j'_`yrs' > 0.01  & p`1'`j'_`yrs' <= 0.05)  {
				scalar define star`1'`j'_`yrs' = "\sym{**}"
			}
			if (p`1'`j'_`yrs' <= 0.01)  {
				scalar define star`1'`j'_`yrs' = "\sym{***}"
			}
		} // end j: gender
	} // end yrs: overall and age groups
	if `1' == 1 {
	scalar define name`1' = "MBD"
	}
	if `1' == 2 {
	scalar define name`1' = "Psychoactive substances"
	}
	if `1' == 3 {
	scalar define name`1' = "Schizophrenia"
	}
	if `1' == 4 {
	scalar define name`1' = "Affective"
	}
	if `1' == 5 {
	scalar define name`1' = "Neurosis"
	}
	if `1' == 6 {
	scalar define name`1' = "Personality"
	}
} // end 1: varlist

scalar list _all
foreach j in "" "_f" "_m" {
	disp "Gender:" "`j'"
	foreach 1 of numlist 1(1)6 {
		disp name`1' " & " beta`1'`j'_0_string star`1'`j'_0 " & " beta`1'`j'_1_string star`1'`j'_1 " & " beta`1'`j'_2_string star`1'`j'_2 ///
		" & " beta`1'`j'_3_string star`1'`j'_3 " & " beta`1'`j'_4_string star`1'`j'_4 " \\"
		disp " & " "(" se`1'`j'_0_string ")" " & " "(" se`1'`j'_1_string ")" " & " "(" se`1'`j'_2_string ")" ///
		" & " "(" se`1'`j'_3_string ")" " & " "(" se`1'`j'_4_string ")" " \\"
	} // end 1: varlist
} // end j: gender



