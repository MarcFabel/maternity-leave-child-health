
capture log close

**************************************************************************************************************
**  UMSTEIGER CODE von Kreiskennziffern auf regional einheitliche Definition von							**
**  1995 bis 2014; Ausgangsbasis/Codes: Kreiskennziffern, Gebietsstand 2014.								**
**  Do-File erstellt von Patrick Reich (Anpassung der Kreis-IDs ->neue Variable: ags_clean) und 			**
**  Natalia Danzer (Umsteiger ags_clean auf AMR und ROR --> neue Variablen: amr_clean, ror_clean)			**
**************************************************************************************************************




*** Erstellt 16.2.17 von Natalia Danzer ***
*** 22.05.2017: Aktualisierung um 2 Kreise 1995: 14066=14166 ==> 14523; 14092=14292 ==> 14999

global source "G:\Projekte\Projekte_ab2016\EcUFam\Daten\Arbeitsmarktregionen"
global directory "G:\Projekte\Projekte_ab2016\EcUFam\Daten\Arbeitsmarktregionen"

**Kreis-AMR-Umsteiger**
import excel "$source\Umsteiger_BBSR_ref_amr_xls_kreise_AMR.xlsx", clear sheet("Zuordnung Kreise ")
rename A kkz
rename E amr
rename G amr_typ
lab var amr "Arbeitsmarktregion BMWi 2014"
drop if B=="" | B=="krs14name" 
keep kkz amr amr_typ
destring, replace
replace kkz=floor(kkz/1000)
label define AMR_TYP 1 "1 Städtische Arbeitsmarktregionen" ///
2 "2	Ländliche Arbeitsmarktregionen mit Verdichtungsansätzen" 3 "3 Dünn besiedelte ländliche Arbeitsmarktregionen"
label val amr_typ AMR_TYP
save $directory\temp\amrcodes2014_urbanpattern.dta, replace

**Kreis-ROR-Umsteiger**
import excel "$source\Download_Ref_Krs.xlsx", clear sheet("Zuordnung Kreise")
rename A kkz
rename E ror
rename G ror_typ
lab var ror "Raumordnungsregion 2014"
drop if B=="" | B=="name" 
keep kkz ror ror_typ
destring, replace
replace kkz=floor(kkz/1000)
label define ROR_TYP 1 "1 Städtische Regionen" 2 "2	Regionen mit Verstädterungsansätzen" ///
	3 "3 Ländliche Regionen"
label val ror_typ ROR_TYP
save $directory\temp\rorcodes2014_urbanpattern.dta, replace

merge 1:1 kkz using $directory\temp\amrcodes2014_urbanpattern.dta
drop _merge



*Kreiskennziffern vereinheitlichen
replace kkz=2000 if kkz==2  // Hamburg
replace kkz=11000 if kkz==11 // Berlin
gen kkz1000=floor(kkz/1000) if kkz>99999
replace kkz=kkz1000 if kkz>99999  // Kreiskennziffern auf 4-5 Stellen einschraenken
drop if kkz<=1000 // zu kurze Kreiskennziffer loeschen
drop if kkz>99999 // zu lange Kreiskennziffer loeschen
*Wenn nur Flaechenlaender angegeben sind: loeschen
drop if kkz==1000 | kkz==3000 | kkz==4000 | kkz==5000 | kkz==6000 | kkz==7000 | kkz==8000 | kkz==9000 | kkz==10000 | kkz==12000 | kkz==13000 | kkz==14000 | kkz==15000 | kkz==16000


*Kreise an Kreisreformen anpassen // von Patrick
/*Ergaenzung (4.1.): BerÃ¼cksichtigung der vor der VerschlÃ¼sselung der Regierungsbezirke in 
Sachsen bestehenden Kreiskennhziffern (31.12.1995): 140XY Ziffern werden je nach Regierungsbezirk zu
141XY, 142XY oder 143XY */ 

gen ags_clean=kkz
replace ags_clean = 3241 if ags_clean == 3253 | ags_clean == 3201
replace ags_clean = 5334 if ags_clean == 5354 | ags_clean == 5313 
replace ags_clean = 12998 if ags_clean == 12071 | ags_clean == 12052    // beide Kreise=AMR 207
replace ags_clean = 12999 if ags_clean == 12069 | ags_clean == 12054	// beide Kreise=AMR 206
replace ags_clean = 13072 if ags_clean == 13053 | ags_clean == 13051
replace ags_clean = 13073 if ags_clean == 13005 | ags_clean == 13057 | ags_clean == 13061
replace ags_clean = 13074 if ags_clean == 13058 | ags_clean == 13006
replace ags_clean = 13076 if ags_clean == 13054 | ags_clean == 13060
replace ags_clean = 13999 if ags_clean == 13001 | ags_clean == 13002 | ags_clean == 13055 ///
	| ags_clean ==13062 | ags_clean == 13056 | ags_clean == 13059 | ags_clean == 13071 ///
	| ags_clean == 13052 | ags_clean == 13075							// nur 2 IDs in 2014: 13071=amr 218; 13075=AMR 220
replace ags_clean = 14523 if ags_clean == 14142 | ags_clean == 14136 | ags_clean == 14113 ///
	| ags_clean == 14146 | ags_clean == 14145 | ags_clean == 14178 | ags_clean == 14166 | ags_clean== 14066 ///
	| ags_clean == 14013 | ags_clean == 14036 | ags_clean == 14042 | ags_clean == 14045  ///
	| ags_clean == 14046 | ags_clean == 14166
replace ags_clean = 14730 if ags_clean == 14374 | ags_clean == 14389 | ags_clean == 14074 | ags_clean == 14089  // wird zu amr 230
replace ags_clean = 14997 if ags_clean == 14061 | ags_clean == 14067 | ags_clean == 14071  /// 
    | ags_clean == 14073 | ags_clean == 14075 | ags_clean == 14077 | ags_clean == 14077 ///
	| ags_clean == 14081 | ags_clean == 14082 | ags_clean == 14088 | ags_clean == 14091 ///
	| ags_clean == 14093 | ags_clean == 14161 | ags_clean == 14181 | ags_clean == 14191 ///
	| ags_clean == 14171 | ags_clean == 14188 | ags_clean == 14182 | ags_clean == 14177 ///
	| ags_clean == 14375 | ags_clean == 14193 | ags_clean == 14173 | ags_clean == 14167 ///
	| ags_clean == 14522 | ags_clean == 14524 | ags_clean == 14511 | ags_clean == 14521		// 14522=223 | 14524=225 | 14511=221 | 14521=222
replace ags_clean = 14998 if ags_clean == 14365 | ags_clean == 14379 | ags_clean == 14383 ///
	| ags_clean == 14729 | ags_clean == 14713 | ags_clean == 14079 | ags_clean == 14065 | ags_clean == 14083  // 14729=230  14713=230
replace ags_clean = 14999 if ags_clean == 14062 | ags_clean == 14063 | ags_clean == 14072 ///
    | ags_clean == 14095 | ags_clean == 14262 | ags_clean == 14272 | ags_clean == 14292 | ags_clean == 14295   ///
	| ags_clean == 14264 | ags_clean == 14286 | ags_clean == 14284 | ags_clean == 14263 ///
	| ags_clean == 14280 | ags_clean == 14285 | ags_clean == 14287 | ags_clean == 14290 ///
	| ags_clean == 14294 | ags_clean == 14628 | ags_clean == 14625 | ags_clean == 14626 ///
	| ags_clean == 14295 | ags_clean == 14612 | ags_clean == 14627 | ags_clean == 14080 ///
	| ags_clean == 14085 | ags_clean == 14087 | ags_clean == 14090 | ags_clean== 14092 | ags_clean == 14094 ///
	| ags_clean == 14086 | ags_clean == 14084													// 14612=226 14625-227 14626-228 14627-229 14628-226 
replace ags_clean = 15002 if ags_clean == 15202
replace ags_clean = 15003 if ags_clean == 15303
replace ags_clean = 15083 if ags_clean == 15362 | ags_clean == 15355
replace ags_clean = 15084 if ags_clean == 15256 | ags_clean == 15268
replace ags_clean = 15087 if ags_clean == 15266 | ags_clean == 15260
replace ags_clean = 15088 if ags_clean == 15265 | ags_clean == 15261
replace ags_clean = 15997 if ags_clean == 15363 | ags_clean == 15081 | ags_clean == 15090 ///
	| ags_clean == 15370 																		// 15081-234 15090-240
replace ags_clean = 15998 if ags_clean == 15352 | ags_clean == 15085 | ags_clean == 15369 ///
	| ags_clean == 15367 |  ags_clean == 15153 | ags_clean == 15364 | ags_clean == 15089 ///
    | ags_clean == 15357																		// 15085-237  15089-239
replace ags_clean = 15999 if ags_clean == 15101 | ags_clean == 15171 | ags_clean == 15159 ///
	| ags_clean == 15151 |  ags_clean == 15091 | ags_clean == 15001 | ags_clean == 15082 ///
    | ags_clean == 15086 | 	ags_clean == 15358 | ags_clean == 15154								// 15091-241 15001-231 15082-235 15086-233
replace ags_clean = 16999 if ags_clean == 16056 | ags_clean == 16063							// 16056-247 16063-247


*** Anpassung der Arbeitsmarktregionen (AMR) an Kreisreformen
*** Ziel: Für jede korrigierte Kreisnr (ags_clean) eine eindeutige Zuordnung zu einer Arbeitsmarktregion (amr_clean)
*** Neue zeitkonsistente geographische Einheiten erhalten die Nummmern 901, 902, ...

gen amr_clean=amr

*** AMR pro ags_clean eindeutig; amr umfasst 1 ags_clean (=2kkz) + 1 kkz (12066)
* keine Zusammenlegung notwendig
* ags_clean = 12998 // 1 ags_clean, 3 kkz, 1 amr
tab kkz if amr==207 // 3:1 (3 kkz= 1 amr) - 12071 12052 12066  = 2 ags_clean

*** AMR pro ags_clean eindeutig; amr umfasst 1 ags_clean (=2kkz) + 1 kkz (12066)
* keine Zusammenlegung notwendig
* ags_clean = 12999 // 1 ags_clean, 3 kkz, 1 amr
tab kkz if amr==206 // 4:1 (4 kkz= 1 amr) - 12051 12054 12063 12069 = 3 ags_clean

*** Zusammenlegung zu neuer amr
*ags_clean = 13999 // 1 ags_clean, 2 kkz, 2 amr's
tab kkz if amr==218 // 1:1 (1 kkz=1 amr) 13071
tab kkz if amr==220 // 1:1 (1 kkz=1 amr) 13075
replace amr_clean=901 if ags_clean==13999 

*** Zusammenlegung zu neuer amr
*ags_clean = 14997 // 1 ags_clean, 4 kkz, 4 amr's
tab kkz if amr==221 // 1:1 (1 kkz=1 amr) 14511
tab kkz if amr==222 // 1:1 (1 kkz=1 amr) 14521
tab kkz if amr==223 // 1:1 (1 kkz=1 amr) 14522
tab kkz if amr==225 // 1:1 (1 kkz=1 amr) 14524
replace amr_clean=902 if ags_clean==14997 // amr==221 | amr==222 | amr==223 | amr==225

*** AMR pro ags_clean eindeutig; amr umfasst 2 ags_clean (=2kkz) + 1 kkz
*ags_clean = 14998 / keine Zusammenlegung notwendig
tab kkz if amr==230 // 3:1 (3 kkz=1 amr) 14730 14713 14729 // 2 ags_clean, 3 kkz, 1 amr

*** Zusammenlegung zu neuer amr
* = 14999 // 1 ags_clean, 5 kkz, 4 amr's
tab kkz if amr==226 // 2:1 (2 kkz=1 amr) - 14612 14628
tab kkz if amr==227 // 1:1 (1 kkz=1 amr) - 14625
tab kkz if amr==228 // 1:1 (1 kkz=1 amr) - 14626
tab kkz if amr==229 // 1:1 (1 kkz=1 amr) - 14627
replace amr_clean=903 if ags_clean==14999 // amr==226 | amr==227 | amr==228 | amr==229  

*** Zusammenlegung zu neuer amr
* ags_clean = 15997 // 1 ags_clean, 2 kkz, 2 amr's
tab kkz if amr==234 // 1:1 (1 kkz=1 amr) - 15081
tab kkz if amr==240 // 1:1 (1 kkz=1 amr) - 15090
replace amr_clean=904 if ags_clean==15997 // amr==234 | amr==240  


*** Zusammenlegung zu neuer amr
* ags_clean = 15998 // 1 ags_clean, 2 kkz, 2 amr's
tab kkz if amr==237 // 1:1 (1 kkz=1 amr) - 15085
tab kkz if amr==239 // 1:1 (1 kkz=1 amr) - 15089
replace amr_clean=905 if ags_clean==15998 // amr==237 | amr==239 


*** Zusammenlegung zu neuer amr
* ags_clean = 15999 // 3 ags_clean, 6 kkz, 4 amr; ags_clean==15003 & ags_clean==15083
tab kkz if amr==241 // 1:1 (1 kkz=1 amr) - 15091
tab kkz if amr==231 // 1:1 (1 kkz=1 amr) - 15001
tab kkz if amr==235 // 1:1 (1 kkz=1 amr) - 15082
tab kkz if amr==233 // 3:1 (3 kkz=1 amr) - 15086  - hiere: weitere Kreise betroffen ags_clean==15003 & ags_clean==15083
replace amr_clean=906 if ags_clean == 15999 | ags_clean==15003 | ags_clean==15083 // amr==241 | amr==231 | amr==235 | amr==233 

*** Eindeutige Zuordnung ags_clean-amr vorhanden
* ags_clean = 16999 // 1 ags_clean, 2 kkz, 1 amr
tab kkz if amr==247 // 2:1 (2 kkz=1 amr) - 16056 16063 


**************************************************************
*** ROR  Raum-Ordnungs-Region - Anpassung an Kreisreformen ***
tab ror if ags_clean == 13999  // 2 rors
tab ags_clean if (ror==1301 | ror==1303) // 2 ags_clean

tab ror if ags_clean == 14997 

tab ror if ags_clean ==14999  // 2 rors
tab ags_clean if ror==1401 | ror==1402

tab ror if ags_clean ==15998 // ror=1504(!)
tab ror if ags_clean ==15999 // 2 rors 1502 & 1504(!)
tab ror if ags_clean ==16999
tab ror if ags_clean==15999
tab ags_clean if (ror==1502 | ror==1504) // 4 ags_clean
tab ror if ags_clean==15999 | ags_clean==15003 | ags_clean==15083 | ags_clean==15998

tab ags_clean if (ror==1403 | ror==1404)

gen ror_clean=ror
replace ror_clean=1499 if ags_clean==14999  // ror==1401 & ror==1402
replace ror_clean=1599 if ags_clean==15999 | ags_clean==15003 | ags_clean==15083 | ags_clean==15998 // ror==1502 & ror==1504
replace ror_clean=1399 if ags_clean==13999 | ags_clean==13073  // == ror==1301 & ror==1303
replace ror_clean=1498 if ags_clean==14523 | ags_clean==14730 | ags_clean==14997 | ags_clean==14998


*****************************************************************
*** Test, ob Zuordnung von ags_clean zu amr_clean und Raumordnungsregion (ror) eindeutig? Ja:
egen test=group(amr_clean ags_clean)  // Anzahl der Gruppen sollte gleich Anzahl ags_clean entsprechen.
egen test2=group(ror_clean ags_clean)  // Anzahl der Gruppen sollte gleich Anzahl ags_clean entsprechen.

su test test2 ags_clean // Ja: 385 Gruppen = 385 ags_clean = auch für ror OK!
drop test*
order ags_clean amr_clean amr_typ ror_clean ror_typ

sort ags_clean
br if ags_clean[_n] == ags_clean[_n-1]

*****************************************************************
*** Reduktion des Datensatzes um pro ags_clean eine Zeile mit Umsteiger auf amr_clean zu erhalten
collapse (mean) amr_clean amr_typ ror_clean, by(ags_clean)

su 

lab var ags_clean "Kreiskennziffern; zeitkonsistent unter Berücksichtung der Kreisreformen bis 2014"
lab var amr_clean "Arbeitsmarktregion; zeitkonsistent unter Berücksichtung der Kreisreformen bis 2014"
lab var ror_clean "Raumordnungsregionen; zeitkonsistent unter Berücksichtung der Kreisreformen bis 2014"

save $directory\ags_clean_amr_ror_umsteiger_urbanpattern.dta, replace

