	clear all
	set more off
	
	global path   "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis"	
	global temp   "$path/temp"
	global graphs "$path/graphs/KKH"
	global graph_paper "$path/graphs/paper" 
	global tables 		"$path/tables/KKH"
	global tables_paper "$path/tables/paper"
	global source "$path\source\population\tagesgenaue_Geburten_DESTATIS"
	
	
// NRW -time series births (1977-2017)
	qui import delimited "$source\NRW_daily_births_1977-2017.csv", delimiter(";") varnames(1) clear
	qui reshape long lebendgeborene_, i(geburtstag_kind geburtsmonat_kind) j(year)
	qui tostring geburtstag_kind geburtsmonat_kind year, g(geburtstag_string geburtsmonat_string year_string)
	qui gen date_string = geburtsmonat_string + "/"+ geburtstag_string+ "/"+ year_string
	qui gen date = date(date_string, "MDY")
	format date %td
	rename lebendgeborene_ birth
	qui gen DOY = geburtsmonat_string + "/"+ geburtstag_string
	rename geburtstag_kind day
	rename geburtsmonat_kind month
	keep date birth DOY year month day 
	qui gen bula = 5 
	order date
	sort date
	qui save "$temp/daily_births_TS_NRW", replace
	
// Bawue - time series births (1960-1990)
* first year
	import excel "$source\BaWue _daily_births_1968-1990.xlsx", ///
	sheet("1968-1990") cellrange(A9:AT190)  case(lower) allstring clear
	keep A B 
	rename B birth
	qui gen date = date(A, "MDY") 
	format date %td
	qui gen month = month(date) 
	qui gen day = day(date)
	qui gen year = year(date)
	tostring month day , g(month_s day_s)
	qui gen DOY = month_s + "/" + day_s
	keep birth date DOY year month day
	qui gen bula = 8 
	qui destring birth, replace
	order date
	sort date
	qui save "$temp/daily_births_TS_BaWue", replace
	
	
	// USE EXCELCOLUMN FOR THIS TASK (LOOP THROUGH COLUMNS)
local i = 3
while `i' < 47 { // i< 47 (23 Jahre)
	excelcol `i'
	local col_date `r(column)'
	local j = `i' + 1 // markiert birth column
	excelcol `j'
	local col_birth `r(column)'
	
	import excel "$source\BaWue _daily_births_1968-1990.xlsx", ///
	sheet("1968-1990") cellrange(`col_date'9:`col_birth'190)  case(lower) allstring clear
	rename `col_birth' birth
	qui gen date = date(`col_date', "MDY") 
	format date %td
	qui gen month = month(date) 
	qui gen day = day(date)
	qui gen year = year(date)
	tostring month day , g(month_s day_s)
	qui gen DOY = month_s + "/" + day_s
	keep birth date DOY year month day
	qui gen bula = 8 
	qui destring birth, replace
	order date
	sort date
	qui append using "$temp/daily_births_TS_BaWue"
	qui save "$temp/daily_births_TS_BaWue", replace
	local i = `i' + 2
}
drop if date == .
qui save "$temp/daily_births_TS_BaWue", replace
********************************************************************	
// 1st data set: Intersection (14yrs) 
qui use "$temp/daily_births_TS_BaWue", replace
qui append using "$temp/daily_births_TS_NRW"	
keep if (year >= 1977 & year <= 1990)   
keep if (month >= 2 & month <= 7) // drop more than 3m for NRW
drop if date == .
keep date bula birth
qui collapse (sum) birth ,by(date)
qui save "$temp/daily_births_TS_intersection", replace



import delimited "$source\holidays_dow.csv", delimiter(";") clear 
rename märzjuni date_string
rename feiertage1gesetzlicherfeiertagin holiday
rename wochentage dow_string
keep date_string holiday dow_string
qui gen date = date(date_string, "DMY")
format date %td
drop date_string
keep if date != .
qui gen dow = 1 if dow_string == "Montag"
qui replace dow = 2 if dow_string == "Dienstag"
qui replace dow = 3 if dow_string == "Mittwoch"
qui replace dow = 4 if dow_string == "Donnerstag"
qui replace dow = 5 if dow_string == "Freitag"
qui replace dow = 6 if dow_string == "Samstag"
qui replace dow = 7 if dow_string == "Sonntag"
drop dow_string
label define DOW 1 "Mon" 2 "Tue" 3 "Wed" 4 "Thu" 5 "Fri" 6 "Sat" 7 "Sun"
label val dow DOW

merge 1:1 date using "$temp/daily_births_TS_intersection"
keep if _merge == 3
drop _merge

*dow 
qui gen month = month(date) 
qui gen day = day(date)
qui gen year = year(date)
qui gen doy = (month *100)+day


*days tp threshold
qui gen tempd = "01/"
qui gen tempm = "05/"
tostring year, g(tempy)
qui gen temp_date = tempm+tempd+tempy
qui gen threshold = date(temp_date, "MDY")
format threshold %td
drop temp*
qui gen days = date -threshold
*make positive ones larger by one unit 
qui replace days = days + 1 if days>=0
qui gen days_to_threshold = abs(days)
drop days

*ln(birth) 
qui gen ln_birth = ln(birth)

*reform dummy
qui gen reform = cond(date>=td(01may1979) & date<=td(30jun1979),1,0)
	 qui save "$temp/daily_births_prepared_final", replace
	 
	 
*******************************************************************************	 
// Analysis 
	 
	 use  "$temp/daily_births_prepared_final", clear
	 keep if days_to_threshold <= 28
	 
* Figure - panel A 
line birth date if date > td(01apr1979) & date < td(31may1979), xline(7059.5)  /// 
	scheme(s1mono)  plotregion(color(white)) yscale(r(400 1000)) /// 
	title("Panel A. Raw data") ytitle("Births per day (unadjusted)" "") ///
	xsize(15) ysize(4) tlabel(3apr1979 (7) 29may1979, angle(45) format(%tdDDmon)) /// 
	 ylabel(#4,nogrid) xtitle("")	 ///
	 saving($graphs/fertility_raw, replace)
	 
* Figure - panel B 
reg birth i.year##i.dow i.holiday i.doy if date < td(01apr1979) | date > td(31may1979)
	predict birth_hat
	qui gen delta = birth_hat - birth

line delta date if date > td(01apr1979) & date < td(31may1979), xline(7059.5) yline(0) ///
		scheme(s1mono) plotregion(color(white)) /// 
		title("Panel B. Regression-Adjusted") ytitle("Births per day" "(relative to expected)") ///
		xsize(15) ysize(4) tlabel(3apr1979 (7) 29may1979, angle(45) format(%tdDDmon)) ///
		 ylabel(-300 -150 0 150 300,nogrid) xtitle("") ///
		 saving($graphs/fertility_regression_adjusted, replace)
		 
		 graph combine "$graphs/fertility_raw" "$graphs/fertility_regression_adjusted", /// 
		 scheme(s1mono) col(1) 
	graph export "$graph_paper/fertility_raw_regression_adjusted.pdf", as(pdf) replace
		 
		 
* Regression: 	
* a) births 
	use  "$temp/daily_births_prepared_final", clear
	eststo clear	 
	qui eststo a1 :reg birth reform i.year##i.dow i.holiday i.doy if days_to_threshold <= 7	  // 7  days
	qui eststo a2 :reg birth reform i.year##i.dow i.holiday i.doy if days_to_threshold <= 14  // 14 days
	qui eststo a3 :reg birth reform i.year##i.dow i.holiday i.doy if days_to_threshold <= 21  // 21 days
	qui eststo a4 :reg birth reform i.year##i.dow i.holiday i.doy if days_to_threshold <= 28  // 28 days
	
	esttab a* using "$tables_paper/include/birth_rate_effects_births.tex", replace ///
		keep(reform) scalars("N Observations" "r2 \$R^2$") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		booktabs fragment ///
		coeflabels(reform "ML reform") ///
		label nomtitles nonumbers noobs nonote nogaps noline 
		
* b) ln(births)
	eststo clear	 
	qui eststo a1 :reg ln_birth reform i.year##i.dow i.holiday i.doy if days_to_threshold <= 7	  // 7  days
	qui eststo a2 :reg ln_birth reform i.year##i.dow i.holiday i.doy if days_to_threshold <= 14   // 14 days
	qui eststo a3 :reg ln_birth reform i.year##i.dow i.holiday i.doy if days_to_threshold <= 21   // 21 days
	qui eststo a4 :reg ln_birth reform i.year##i.dow i.holiday i.doy if days_to_threshold <= 28   // 28 days
	
	esttab a* using "$tables_paper/include/birth_rate_effects_lnbirths.tex", replace ///
		keep(reform) scalars("N Observations" "r2 \$R^2$") ///
		se star(* 0.10 ** 0.05 *** 0.01) ///
		booktabs fragment ///
		coeflabels(reform "ML reform") ///
		label nomtitles nonumbers noobs nonote nogaps noline


	
	
	