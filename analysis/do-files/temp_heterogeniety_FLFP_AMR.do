/*

	Quick and dirty: wie heterogen ist die Beschäftigtenquote
	
*/

clear all 
set more off 
********************************************************************************* 
// AMR EBENE 
	use "G:\Projekte\Projekte_ab2016\EcUFam\Daten\Regionaldatenbank\Data\Final\output\exportfile_yearly_clean_AMR.dta", clear 

// 1) FLFP 	
	*Zähler - 014: SVP Beschäftigte nach Altersgruppen (ab 2001 nach Geschlecht) - IM TYPISCHEN eRWERBSALTER
	qui egen svp_f = rowtotal(_014_emp_20u_f _014_emp_2025_f _014_emp_2530_f _014_emp_3050_f _014_emp_5060_f _014_emp_6065_f), m
	* Nenner 
	qui egen pop_f = rowtotal(_002_pop_f1518 _002_pop_f1820 _002_pop_f2025 ///
		_002_pop_f2530 _002_pop_f3035 _002_pop_f3540 _002_pop_f4045 _002_pop_f4550 ///
		_002_pop_f5055 _002_pop_f5560 _002_pop_f6065), m
	*Bruch: 
	qui gen FLFP = svp_f / pop_f
	 *sample split at median
	capture drop high_FLFP
	qui summ FLFP if year == 2001, d
	qui gen temp = cond(FLFP > r(p50),1,0) if year == 2001
	by amr_clean: egen high_FLFP = min(temp) 
	drop temp
	label variable high_FLFP "sample split: high FLFP in year 2001"
	
// 2) Siedlungsstruktureller typ	
	qui gen density = _002_pop / _289_area		// population/area
	summ density if year == 1996, d 
	qui gen temp = cond(density > r(p50),1,0) if year == 1996
	by amr_clean: egen high_density = min(temp)
	drop temp
	order year amr_clean density high_density
	label var high_density "sample split: high density in year 1996 (pop/hectar)"
********************************************************************************* 
// Bula Ebene
	clear all
	use "G:\Projekte\Projekte_ab2016\EcUFam\Daten\Regionaldatenbank\Data\Final\output\exportfile_yearly_clean.dta"
	
	*get Bula identifier
	qui tostring ags_clean, gen(temp)
	capture drop temp2
	qui gen temp2 = substr(temp,1,2)
	qui gen bula = substr(temp2,1,1) if length(temp) == 4
	qui replace bula = temp2 if length(temp) == 5
	qui destring bula, replace
	drop temp*
	order year ags_clea bula
	
	*aggregate on bula level
	collapse (sum) _014*_f _002_pop_f* _001_ypop* , by(year bula)
	sort bula year
	
	*Zähler - 014: SVP Beschäftigte nach Altersgruppen (ab 2001 nach Geschlecht) - IM TYPISCHEN eRWERBSALTER
	qui egen svp_f = rowtotal(_014_emp_20u_f _014_emp_2025_f _014_emp_2530_f _014_emp_3050_f _014_emp_5060_f _014_emp_6065_f), m
 
	* Nenner 
	qui egen pop_f = rowtotal(_002_pop_f1518 _002_pop_f1820 _002_pop_f2025 ///
		_002_pop_f2530 _002_pop_f3035 _002_pop_f3540 _002_pop_f4045 _002_pop_f4550 ///
		_002_pop_f5055 _002_pop_f5560 _002_pop_f6065), m
	
	*Bruch: 
	qui gen FLFP = svp_f / pop_f
	