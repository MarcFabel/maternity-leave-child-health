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
qui save "$temp/daily_births_TS_intersection"


	
	
	