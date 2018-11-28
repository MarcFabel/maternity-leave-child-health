	clear all
	set more off
	
	global path   "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis"	
	global temp   "$path/temp"
	global graphs "$path/graphs/KKH"
	global graph_paper "$path/graphs/paper" 
	global tables 		"$path/tables/KKH"
	global tables_paper "$path/tables/paper"

*1978 
 *a) bawü
 	import excel "$path\source\population\tagesgenaue_Geburten_DESTATIS\daily_births_1978_1979_BaWue.xlsx", ///
	sheet("Tabelle1") cellrange(A9:C130) allstring clear
	rename A date_string
	rename B birth_m
	rename C birth_f
	qui gen date = date(date_string, "MDY")
	format date %td
	drop date_string
	qui gen bula = 8 // Bawü 
	qui destring, replace
	qui save "$temp/daily_births_1978_bawue", replace
	
	*NRW
	import excel "$path\source\population\tagesgenaue_Geburten_DESTATIS\daily_births_1978_1979_NRW.xlsx", ///
	sheet("Fabel") cellrange(A66:H187) clear
	rename A day 
	rename B month 
	rename D birth_m
	rename E birth_f
	drop C F G H
	qui gen year = "1978"
	qui gen date_string = month+"/"+day+"/"+year
	qui gen date = date(date_string, "MDY")
	format date %td
	drop date_string day month year
	qui gen bula = 5 // NRW
	qui save "$temp/daily_births_1978_NRW", replace
	
	qui append using "$temp/daily_births_1978_bawue"
	qui collapse (sum) birth* ,by(date)
	
	* put in DOW
	*tuesday
	qui gen DOW = 2 if date == td(02may1978)
	qui gen temp = _n
	capt drop temp2 
	qui gen temp2 = abs(63 - temp)
	capt drop tempX
	qui gen tempX = 1 if temp2 == 7 | temp2 == 2*7 | temp2 == 3*7 | temp2 == 4*7 | temp2 == 5*7 | temp2 == 6*7 | temp2 == 7*7 | temp2 == 8*7 | temp2 == 9*7
	qui replace DOW = 2 if tempX == 1
	qui replace DOW = 3 if DOW[_n-1] == 2 & DOW[_n] == .
	qui replace DOW = 4 if DOW[_n-1] == 3 & DOW[_n] == .
	qui replace DOW = 5 if DOW[_n-1] == 4 & DOW[_n] == .
	qui replace DOW = 6 if DOW[_n-1] == 5 & DOW[_n] == .
	qui replace DOW = 7 if DOW[_n-1] == 6 & DOW[_n] == .
	qui replace DOW = 1 if DOW[_n-1] == 7 & DOW[_n] == .
	*nach oben hin auffüllen
	qui replace DOW = 1 if DOW[_n+1] == 2 & DOW[_n] == .
	qui replace DOW = 7 if DOW[_n+1] == 1 & DOW[_n] == .
	qui replace DOW = 6 if DOW[_n+1] == 7 & DOW[_n] == .
	qui replace DOW = 5 if DOW[_n+1] == 6 & DOW[_n] == .
	qui replace DOW = 4 if DOW[_n+1] == 5 & DOW[_n] == .
	qui replace DOW = 3 if DOW[_n+1] == 4 & DOW[_n] == .
	qui replace DOW = 2 if DOW[_n+1] == 3 & DOW[_n] == .
	drop temp*
	qui gen year = 1978
	
	
	qui save "$temp/daily_births_1978", replace
********************************************************************************	
*1979
	*a) bawü
	import excel "$path\source\population\tagesgenaue_Geburten_DESTATIS\daily_births_1978_1979_BaWue.xlsx", ///
	sheet("Tabelle1") cellrange(F9:H130) allstring clear
	rename F date_string
	rename G birth_m
	rename H birth_f
	qui gen date = date(date_string, "MDY")
	format date %td
	drop date_string
	qui gen bula = 8 // Bawü 
	qui destring, replace
	qui save "$temp/daily_births_1979_bawue", replace
	
	*b) NRW 
	import excel "$path\source\population\tagesgenaue_Geburten_DESTATIS\daily_births_1978_1979_NRW.xlsx", ///
	sheet("Fabel") cellrange(A66:H187) clear
	rename A day 
	rename B month 
	rename G birth_m
	rename H birth_f
	drop C D E F
	qui gen year = "1979"
	qui gen date_string = month+"/"+day+"/"+year
	qui gen date = date(date_string, "MDY")
	format date %td
	drop date_string day month year
	qui gen bula = 5 // NRW
	qui save "$temp/daily_births_1979_NRW", replace
	
	qui append using "$temp/daily_births_1979_bawue"
	qui collapse (sum) birth* ,by(date)
	

	
	* put in DOW
	*tuesday
	qui gen DOW = 2 if date == td(01may1979)
	qui gen temp = _n
	capt drop temp2 
	qui gen temp2 = abs(62 - temp)
	capt drop tempX
	qui gen tempX = 1 if temp2 == 7 | temp2 == 2*7 | temp2 == 3*7 | temp2 == 4*7 | temp2 == 5*7 | temp2 == 6*7 | temp2 == 7*7 | temp2 == 8*7 | temp2 == 9*7
	qui replace DOW = 2 if tempX == 1
	qui replace DOW = 3 if DOW[_n-1] == 2 & DOW[_n] == .
	qui replace DOW = 4 if DOW[_n-1] == 3 & DOW[_n] == .
	qui replace DOW = 5 if DOW[_n-1] == 4 & DOW[_n] == .
	qui replace DOW = 6 if DOW[_n-1] == 5 & DOW[_n] == .
	qui replace DOW = 7 if DOW[_n-1] == 6 & DOW[_n] == .
	qui replace DOW = 1 if DOW[_n-1] == 7 & DOW[_n] == .
	*nach oben hin auffüllen
	qui replace DOW = 1 if DOW[_n+1] == 2 & DOW[_n] == .
	qui replace DOW = 7 if DOW[_n+1] == 1 & DOW[_n] == .
	qui replace DOW = 6 if DOW[_n+1] == 7 & DOW[_n] == .
	qui replace DOW = 5 if DOW[_n+1] == 6 & DOW[_n] == .
	qui replace DOW = 4 if DOW[_n+1] == 5 & DOW[_n] == .
	qui replace DOW = 3 if DOW[_n+1] == 4 & DOW[_n] == .
	qui replace DOW = 2 if DOW[_n+1] == 3 & DOW[_n] == .
	drop temp*
	qui gen year = 1979
	qui save "$temp/daily_births_1979", replace

	qui append using "$temp/daily_births_1978"
	
	*Public Holidays
	capt drop holiday
	qui gen holiday = 0 
	qui replace holiday = 1 if date == td(13apr1978) | date == td(24mar1978) // Karfreitag
	qui replace holiday = 1 if date == td(15apr1978) | date == td(26mar1978) // Ostern
	qui replace holiday = 1 if date == td(16apr1978) | date == td(27mar1978) // Ostermontag
	qui replace holiday = 1 if date == td(01may1978) | date == td(01may1978) // Tag der Arbeit
	qui replace holiday = 1 if date == td(24may1978) | date == td(04may1978) // Christi Himmelfahrt
	qui replace holiday = 1 if date == td(03jun1978) | date == td(14may1978) // Pfingsten
	qui replace holiday = 1 if date == td(04jun1978) | date == td(15may1978) // Pfingstmontag
	qui replace holiday = 1 if date == td(14jun1978) | date == td(25may1978) // Fronleichnam
	
	qui gen days_num =  date -td(01may1979)

	*take males and female together
	qui gen birth = birth_m + birth_f
	qui drop birth_m birth_f
	sort date
	order date birth DOW 
	
	qui gen ln_birth = ln(birth)
	qui save "$temp/daily_births_prepared", replace
*************************************************************
	
	use "$temp/daily_births_prepared", clear
	
	
	*regression
	qui gen after = cond(date >= td(01may1979),1,0)
	qui gen AxNum = after * days_num
	
	* different day windows
	eststo clear
	qui eststo a1 :reg birth days_num AxNum after i.DOW i.holiday if days_num >= -5  & days_num <= 4	   // 5 days
	qui eststo a2 :reg birth days_num AxNum after i.DOW i.holiday if days_num >= -10  & days_num <= 9   // 10 days
	qui eststo a3 :reg birth days_num AxNum after i.DOW i.holiday if days_num >= -15  & days_num <= 14  // 15 days
	qui eststo a4 :reg birth days_num AxNum after i.DOW i.holiday if days_num >= -30  & days_num <= 29  // 30 days
 
	esttab a* using "$tables_paper/include/RD_fertility_raw.tex", replace ///
		keep(after) scalars("N Observations" "r2 \$R^2$") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		booktabs fragment ///
		coeflabels(after "number of births") ///
		label nomtitles nonumbers noobs nonote nogaps noline 
		
	* b) ln(births)	
	eststo clear
	qui eststo a1 :reg ln_birth days_num AxNum after i.DOW i.holiday if days_num >= -5  & days_num <= 4	   // 5 days
	qui eststo a2 :reg ln_birth days_num AxNum after i.DOW i.holiday if days_num >= -10  & days_num <= 9   // 10 days
	qui eststo a3 :reg ln_birth days_num AxNum after i.DOW i.holiday if days_num >= -15  & days_num <= 14  // 15 days
	qui eststo a4 :reg ln_birth days_num AxNum after i.DOW i.holiday if days_num >= -30  & days_num <= 29  // 30 days
 
	esttab a* using "$tables_paper/include/RD_fertility_ln.tex", replace ///
		keep(after) scalars("N Observations" "r2 \$R^2$") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		booktabs fragment ///
		coeflabels(after "ln(number of births)") ///
		label nomtitles nonumbers noobs nonote nogaps noline 

	
	*figures
	reg birth i.year##i.DOW i.holiday if date < td(01apr1979) | date > td(31may1979)
	predict birth_hat
	qui gen delta = birth_hat - birth
	
	*raw 
	line birth date if date > td(01apr1979) & date < td(31may1979), xline(7059.5)  /// 
		scheme(s1mono) yscale(r(400 1000)) /// 
		title("Panel A. Raw data") ytitle("Births per day (unadjusted)") ///
		xsize(15) ysize(4) tlabel(03apr1979 (14) 31may1979) /// 
		saving($graphs/fertility_raw, replace) ylabel(#4,nogrid) xtitle("")
	
	*regression adjusted
	line delta date if date > td(01apr1979) & date < td(31may1979), xline(7059.5) yline(0) ///
		scheme(s1mono)  /// 
		title("Panel B. Regression-Adjusted") ytitle("Births per day (relative to expected)") ///
		xsize(15) ysize(4) tlabel(03apr1979 (14) 31may1979) ///
		saving($graphs/fertility_regression_adjusted, replace) ylabel(#4,nogrid) xtitle("")
		
	graph combine "$graphs/fertility_raw" "$graphs/fertility_regression_adjusted", /// 
		 scheme(s1mono) col(1) 
	graph export "$graph_paper/fertility_raw_regression_adjusted.pdf", as(pdf) replace
	

	
	
	
********************************************************************************
	* What is 01may1979 equivalent when not displayed in date format? 7060
	DCdensity birth_m, breakpoint(7060) generate(Xj Yj r0 fhat se_fhat) 
	

	

scatter birth_m date if days_num > -30 & days_num < 30, tline(01may1979)
scatter birth_m date if days_num > -15 & days_num < 15, tline(01may1979)
scatter birth_m date if days_num > - 7 & days_num <  7, tline(01may1979)







/*
*1978
import excel "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h\analysis\source\population\dailz_births_1978_1979_BaWue.xlsx", sheet("Tabelle1") cellrange(A9:C131) clear

rename A date_string
rename B birth_m
rename C birth_f

*bring string in date format 
qui gen date = date(date_string, "MDY")
format date %td
drop date_string


qui gen days_num =  date -td(01may1978)

* 30 Tage window 
scatter birth_m date if days_num > -30 & days_num < 30, tline(01may1978)
scatter birth_m date if days_num > -15 & days_num < 15, tline(01may1978)
scatter birth_m date if days_num > - 7 & days_num <  7, tline(01may1978)

scatter birth_m date if date>td(15apr1978) & date<td(15jun1978), tline(01may1978)



*1979
import excel "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h\analysis\source\population\dailz_births_1978_1979_BaWue.xlsx", sheet("Tabelle1") cellrange(F9:H131) clear
rename F date_string
rename G birth_m
rename H birth_f
qui gen date = date(date_string, "MDY")
format date %td
drop date_string
qui gen days_num =  date -td(01may1979)

scatter birth_m date if days_num > -30 & days_num < 30, tline(01may1979)
scatter birth_m date if days_num > -15 & days_num < 15, tline(01may1979)
scatter birth_m date if days_num > - 7 & days_num <  7, tline(01may1979)
