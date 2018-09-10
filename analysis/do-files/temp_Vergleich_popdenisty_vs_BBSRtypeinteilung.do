import excel "G:\Projekte\Projekte_ab2016\EcUFam\Daten\Arbeitsmarktregionen\Kopie von Referenz Gemeinden Kreise NUTS.xlsx", sheet("Kreise") firstrow clear

keep Kreiskennziffer Flächeinha31122013 Bevölkerung31122013 SiedlungsstrukturellerKreistyp StädtischerLändlicherRaum

qui gen ags_clean = floor(Kreiskenn)/1000
drop Kreiskennziffer

rename Fläche area
rename Bevölkerung population
rename SiedlungsstrukturellerKreistyp ags_type
rename StädtischerLändlicherRaum rural_urban
qui gen Durban = cond(rural_urban == 1, 1,0)
drop rural_urban

qui gen density = population / area


order ags_clean density ags_type Durban
sort density


qui gen TEMP = cond(density>r(p50),1,0)

tab Durban TEMP, row


/*
85 % korrekt spezifiziert

           |         TEMP
    Durban |         0          1 |     Total
-----------+----------------------+----------
         0 |       171         28 |       199 
           |     85.93      14.07 |    100.00 
-----------+----------------------+----------
         1 |        30        173 |       203 
           |     14.78      85.22 |    100.00 
-----------+----------------------+----------
     Total |       201        201 |       402 
           |     50.00      50.00 |    100.00 
 
*/
