//Synthetic control weights


// ***************************** PREAMBLE********************************
	clear all
	set more off
	
	global path   "G:\Projekte\Projekte_ab2016\EcUFam\m-l-c-h/analysis"	
	global temp   "$path/temp"
	global graphs "$path/graphs/KKH"
	global tables "$path/tables/KKH"
	
	*magic numbers
	global first_year = 1995
	global last_year  = 2014
// ***********************************************************************




use "$temp\KKH_final_R1", clear
*keep if after == 0
order control d5 

//d5 aggregieren über die Zeit
collapse (sum) d5 fert, by(YOB MOB_altern MOB control after TxA) 
sort YOB MOB

// using synth package: 
tsset control MOB_altern

 synth d5 fert , trunit(4) trperiod(7) fig
 
 
 [ counit(numlist) xperiod(numlist) mspeperiod() resultsperiod() nested allopt
        unitnames(varname) figure keep(file) customV(numlist) optsettings ]
