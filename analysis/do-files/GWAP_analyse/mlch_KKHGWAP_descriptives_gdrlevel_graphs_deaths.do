
/*
Dieses Do-File generiert einen Graphen, der den Anteil der Todesfälle an allen 
Krankenhausaufenthalten für eine Geburtskohorte über die Zeit darstellt.
*/

use "$temp/KKH_final_gdr_level", clear
keep if GDR == 0 
keep if control == 4	

*label
	#delim ;
	label define YEAR 
		1995 "1995 [16]"
		1996 "1996 [17]"
		1997 "1997 [18]"
		1998 "1998 [19]"
		1999 "1999 [20]"
		2000 "2000 [21]"
		2001 "2001 [22]"
		2002 "2002 [23]"
		2003 "2003 [24]"
		2004 "2004 [25]"
		2005 "2005 [26]"
		2006 "2006 [27]"
		2007 "2007 [28]"
		2008 "2008 [29]"
		2009 "2009 [30]"
		2010 "2010 [31]"
		2011 "2011 [32]"
		2012 "2012 [33]"
		2013 "2013 [34]"
		2014 "2014 [35]";
	#delim cr
	label values year YEAR

collapse (sum) death hospital2 hospital2_m hospital2_f, by(year )
 
qui gen share_death = death *100 / hospital2


line share_death year, sort color(black) lw(medthick) || ///
	scatter share_death year, sort color(gs6) m(O) ///
	title("Panel E. Share death",pos(11) span  size(vlarge)) subtitle(" ") ///
	ytitle("Share deaths [in percent]") ///
	xtitle("") /// 
	legend(off) ///
	xlabel(1996 (4) 2014 ,val angle(0)) ///
	xmtick(1996 (2) 2014)  ///
	ylabel(, grid glc(gs12) glw(vthin)) ///
	plotregion(color(white)) scheme(s1mono)	///	
	saving("$graphs/descriptive_E_death_$date", replace)  
