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
