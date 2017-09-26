

***********************************************
	*** PREAMBLE ***
***********************************************
	clear all
	set more off
	
	global path "F:\KKH_Diagnosedaten\analyse_local"
	global temp  "$path\temp"
	//ENTSPRECHEN MOMENTAN NUR DUMMYDATEN
	*global KKH "F:\KKH_Diagnosedaten\analyse_local\source" 
	global graphs "$path\graphs"
	
////////////////////////////////////////////////////////////////////////////////
//extensive graphs, with fits		
capture program drop RD_graphe
	program define RD_graphe
		preserve
		qui keep if treat == 1 `6'
		qui drop if `1' ==.
		
		qui bys Datum:egen AVRG_`1' = mean (`1')
		qui sum `1'
		scalar define `1'_nrobs=r(N)	
		scalar define `1'_mean=r(mean)
		qui reg `1' NumX Num_after after
		qui predict `1'_hat_linear
		qui reg `1' NumX NumX2 after Num_after Num2_after
		qui predict `1'_hat_quadratic
		qui reg `1' NumX NumX2 NumX3 after Num_after Num2_after Num3_after
		qui predict `1'_hat_cubic	
		qui reg `1'  NumX Num_after after if (NumX!=-1 & NumX!=1)
		qui predict `1'_donut_linear
		scatter AVRG_`1' Datum2,  scheme(s1mono )  title(" `4' ") `7' ///
                 tline(01may1979, lw(medthick ) lpattern(solid)) ///
                xtitle("Birth month") ytitle(" `1' ") yscale(r(`2' `3')) ///
                ylabel(#5,grid) tlabel(15nov1978 (60) 15sep1979, format(%tdmy)) tmtick(15dec1978 (60) 15oct1979) ///
				ttext(`5' 01apr1979 "2 months", box) ttext(`5' 01jun1979 "6 months", box)  || ///
				line `1'_hat_linear    Datum2 if after == 1, sort color(black) lpattern(dash) || ///
				line `1'_hat_linear    Datum2 if after == 0, sort color(black) lpattern(dash) || ///
				line `1'_hat_quadratic Datum2 if after == 1, sort color(black) || ///
				line `1'_hat_quadratic Datum2 if after == 0, sort color(black) || ///
				line `1'_hat_cubic     Datum2 if after == 1, sort color(black) lpattern(dot) || ///
				line `1'_hat_cubic     Datum2 if after == 0, sort color(black) lpattern(dot) || ///
				line `1'_donut_linear  Datum2 if (after == 1 & NumX!=1), sort color(gray) || ///
				line `1'_donut_linear  Datum2 if (after == 0 & NumX!=-1), sort color(gray) /// 
				legend(off) //note("Notitz fuer die Geheimhaltungspruefung: Diese Graphik basiert auf `=`1'_nrobs' Beobachtungen.")
		graph export "$graphs/R1_RD_`1'_fits.pdf", as(pdf) replace
		restore
	end
	
//plain averages
capture program drop RD_graph
	program define RD_graph
		preserve
		qui keep if treat == 1 
		qui drop if `1' ==.
		
		qui bys Datum:egen AVRG_`1' = mean (`1')
		qui sum `1'
		scalar define `1'_nrobs=r(N)	
		scalar define `1'_mean=r(mean)
		qui reg `1' NumX Num_after after
		qui predict `1'_hat_linear
		qui reg `1' NumX NumX2 after Num_after Num2_after
		qui predict `1'_hat_quadratic
		qui reg `1' NumX NumX2 NumX3 after Num_after Num2_after Num3_after
		qui predict `1'_hat_cubic	
		qui reg `1'  NumX Num_after after if (NumX!=-1 & NumX!=1)
		qui predict `1'_donut_linear
		scatter AVRG_`1' Datum2,  scheme(s1mono )  title(" `4' ") ///
                 tline(01may1979, lw(medthick ) lpattern(solid)) ///
                xtitle("Birth month") ytitle(" `1' ") yscale(r(`2' `3')) ///
                ylabel(#5,grid) tlabel(15nov1978 (60) 15sep1979, format(%tdmy)) tmtick(15dec1978 (60) 15oct1979) ///
				ttext(`5' 01apr1979 "2 months", box) ttext(`5' 01jun1979 "6 months", box)  ///
				legend(off)
				
		graph export "$graphs/R1_RD_`1'_plain.pdf", as(pdf) replace
		restore
	end		
	
	
		
		
	
	
////////////////////////////////////////////////////////////////////////////////
						*** Graphical Analysis ***
////////////////////////////////////////////////////////////////////////////////
	use "$temp\KKH_final_R1", clear
	drop if FRG == 0

********************************
*Metadaten
********************************
	
	*hospital
	RD_graph hospital_r 0	0.25 "Hospital admission" 0.2						// no effect
	RD_graphe hospital_r 0	0.25 "Hospital admission" 8 " "						
	
	RD_graphe hospital_rf 0	0.35 "Hospital admission" 8							//no effects
	RD_graphe hospital_rm 0	0.2 "Hospital admission" 11							
	
	*Share_OP_t
	RD_graph Share_OP 0.33 0.4 "Surgery" 0.38									// no effect
	RD_graphe Share_OP 0.33 0.38 "Surgery" 8									// SEHR UNWAHRSCHEINLICH				
	
	RD_graph Share_OP_f 0.33 0.4 "Surgery" 0.38									//kein mehrwert
	RD_graphe Share_OP_m 0.30 0.38 "Surgery" 0.37									// MÄNNER WERDEN EHER OPERIERT
	
	*DurschnVerweildauer_t
	rename DurschnVerweildauer LoS
	RD_graph LoS 6 7 "Average length of stay" 6.9 								//no effect
	RD_graphe LoS 5 8 "Average length of stay" 6.9
	
	rename DurschnVerweildauer_f LOS_F
	RD_graphe LOS_F 4 7 "Average length of stay" 6.9
	rename DurschnVerweildauer_m LOS_M
	RD_graphe LOS_M 6 10 "Average length of stay" 9								//eventually
	
	
	*SummVerweildauer
	*a) level - NOT INTERESTING
	*rename SummeVerweildauer_t SummStay2
	*RD_graph SummStay2 40000 70000 "Accumulated length of stay" 67000

	*b)ratio
	rename SummeVerweildauer_r SummStay
	RD_graph SummStay 0.5 1.5 "Accumulated length of stay" 1.2
	
********************************
*Hauptdiagnosekapitel
********************************
	RD_graphe Diag_1_r 0 0.005 "Certain infectious and parasitic diseases" 0.0045	//no effects
	RD_graphe Diag_1_rf 0 0.005 "Certain infectious and parasitic diseases" 0.0045
	RD_graphe Diag_1_rm 0 0.005 "Certain infectious and parasitic diseases" 0.0045
	
	RD_graphe Diag_2_r 0 0.006 "Neoplasms" 0.0055
	RD_graphe Diag_2_r 0.002 0.008 "Neoplasms" 0.0055 							// eventually
	RD_graphe Diag_2_rf 0 0.008 "Neoplasms" 0.0065								// nach geschlecht geht nicht viel her
	RD_graphe Diag_2_rm 0 0.008 "Neoplasms" 0.0065
	
	RD_graphe Diag_5_r 0 0.03 "Mental and behavioural disorders" 0.027 		//no effect
	RD_graphe Diag_5_rf 0 0.03 "Mental and behavioural disorders" 0.027
	RD_graphe Diag_5_rm 0 0.03 "Mental and behavioural disorders" 0.027
	
	RD_graphe Diag_6_r 0 0.015 "Diseases of the nervous system" 0.01 			//no effect
	RD_graphe Diag_6_rf 0 0.015 "Diseases of the nervous system" 0.01
	RD_graphe Diag_6_rm 0 0.015 "Diseases of the nervous system" 0.01
	
	RD_graphe Diag_7_r 0 0.003 "Diseases of the eye and ear" 0.0027 			//no effect
	RD_graphe Diag_7_r 0 0.005 "Diseases of the eye and ear" 0.02 				
	RD_graphe Diag_7_rf 0 0.003 "Diseases of the eye and ear" 0.0027
	RD_graphe Diag_7_rm 0 0.003 "Diseases of the eye and ear" 0.0027			//vielleicht males
	
	RD_graphe Diag_8_r 0 0.005 "Diseases of the circulatory system" 0.0045 	//eventually
	RD_graphe Diag_8_rf 0 0.005 "Diseases of the circulatory system" 0.0045
	RD_graphe Diag_8_rm 0.002 0.007 "Diseases of the circulatory system" 0.0065	//vielleicht males, eher nichts
	
	RD_graphe Diag_9_r 0 0.02 "Diseases of the respiratory system" 0.015		//no effect
	RD_graphe Diag_9_rf 0 0.02 "Diseases of the respiratory system" 0.015
	RD_graphe Diag_9_rm 0 0.02 "Diseases of the respiratory system" 0.015
	
	RD_graphe Diag_10_r 0 0.02 "Diseases of the digestive system" 0.015 		//no effect
	RD_graphe Diag_10_rf 0 0.02 "Diseases of the digestive system" 0.015
	RD_graphe Diag_10_rm 0 0.02 "Diseases of the digestive system" 0.015
	
	RD_graphe Diag_11_r 0 0.006 "Diseases of the skin and subcutaneous tissue" 0.005 //no effect
	RD_graphe Diag_11_rf 0 0.006 "Diseases of the skin and subcutaneous tissue" 0.005
	RD_graphe Diag_11_rm 0 0.006 "Diseases of the skin and subcutaneous tissue" 0.005	//vielleicht males
	
	RD_graphe Diag_12_r 0 0.01 "Diseases of the musculoskeletal system and connective tissue" 0.005 //no effect
	RD_graphe Diag_12_rf 0 0.01 "Diseases of the musculoskeletal system and connective tissue" 0.005
	RD_graphe Diag_12_rm 0 0.01 "Diseases of the musculoskeletal system and connective tissue" 0.005
	
	RD_graphe Diag_13_r 0.005 0.015 "Diseases of the genitourinary system"  0.012		//no effect
	RD_graphe Diag_13_rf 0.005 0.015 "Diseases of the genitourinary system"  0.012
	RD_graphe Diag_13_rm 0.005 0.015 "Diseases of the genitourinary system"  0.012
	
	RD_graphe Diag_14_r 0 0.1 "Pregnancy, childbirth and the puerperium" 0.08 	//no effect

	RD_graphe Diag_17_r 0 0.01 "Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified" 0.009 //no effect
	RD_graphe Diag_17_rf 0 0.01 "Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified" 0.009 //no effect
	RD_graphe Diag_17_rm 0 0.01 "Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified" 0.009 //no effect

	
	RD_graphe Diag_18_r 0.005 0.02 "External causes of morbidity and mortality" 0.017  //no effect
	RD_graphe Diag_18_rf 0.005 0.02 "External causes of morbidity and mortality" 0.017
	RD_graphe Diag_18_rm 0.005 0.02 "External causes of morbidity and mortality" 0.017

	
	
********************************
*Spezielle Einzeldiagnosen
********************************
	*Diag_verletzung_t
	RD_graphe Diag_verletzung_r 0.004 0.014 "Injuries" 0.012 					//no effect
	RD_graphe Diag_verletzung_rf 0.004 0.014 "Injuries" 0.012
	RD_graphe Diag_verletzung_rm 0.004 0.014 "Injuries" 0.012
	
	*Diag_neurot_stoerung 
	rename Diag_neurot_stoerung_r Neurosis
	RD_graphe Neurosis 0 0.006 "Neurosis" 0.005									//no effect
	rename Diag_neurot_stoerung_rf Neurosis_f
	RD_graphe Neurosis_f 0 0.006 "Neurosis" 0.005
	rename Diag_neurot_stoerung_rm Neurosis_m
	RD_graphe Neurosis_m 0 0.006 "Neurosis" 0.005
	
	*Diag_andere_wirkstoff (nicht enthalten!!!!)
	/* KÖNNTE AUCH MIT ALCOHOL ZUSAMMENGENOMMEN WERDEN!!!! 
	*/
	
	*Diag_gelenkerkrankung
	rename Diag_gelenkerkrankung_r Joints			
	RD_graphe Joints 0 0.006 "Disease of the joints" 0.005						//no effect
	rename Diag_gelenkerkrankung_rf Joints_f
	RD_graphe Joints_f 0 0.006 "Disease of the joints" 0.005
	rename Diag_gelenkerkrankung_rm Joints_m
	RD_graphe Joints_m 0 0.006 "Disease of the joints" 0.005
	
	*Diag_nierenkrank
	rename Diag_nierenkrank_r Kidneys			
	RD_graphe Kidneys 0 0.006 "Diseases of the kidneys" 0.005					// no effect
	rename Diag_nierenkrank_rf Kidneys_f			
	RD_graphe Kidneys_f 0 0.006 "Diseases of the kidneys" 0.005
	rename Diag_nierenkrank_rm Kidneys_m			
	RD_graphe Kidneys_m 0 0.006 "Diseases of the kidneys" 0.005
	
	* Diag_galle_pankreas
	rename Diag_galle_pankreas_r Bile_pancreas			
	RD_graphe Bile_pancreas 0 0.006 "Diseases of the bile and pancreas" 0.005	//no effect
	rename Diag_galle_pankreas_rf Bile_pancreas_f			
	RD_graphe Bile_pancreas_f 0 0.006 "Diseases of the bile and pancreas" 0.005	//vielleicht
	rename Diag_galle_pankreas_rm Bile_pancreas_m			
	RD_graphe Bile_pancreas_m 0 0.006 "Diseases of the bile and pancreas" 0.005
	
	
	//Frauenkrankheiten, auch als total gelabelt
	*Diag_genital_w																//no effect
	RD_graphe Diag_genital_w_r 0 0.006 "Non-inflammatory diseases of the female genital tract" 0.005
		
	*Diag_krank_schwanger														//no effect
	rename Diag_krank_schwanger_r Pregnancy
	RD_graphe Pregnancy 0 0.01 "Diseases of the mother, associated with the pregnancy" 0.009

	*Diag_betreuung_problem + Diag_komplikation_wehe	(zusammengenommen)		// no effect
	qui egen Delivery = rowtotal(Diag_betreuung_problem_r Diag_komplikation_wehen_r)
	RD_graphe Delivery 0.03 0.06 "Obstructed labor & problems during delivery" 0.05
	
	
	   
	
	/////////
	*nciht merh nach gender!
	/////////
	
	*Diag_magen_krank_t
	rename Diag_magen_krank_r Stomach
	RD_graphe Stomach 0 0.006 "Diseases of the stomach" 0.004					// no effect
		
	*Diag_verdauung_t
	RD_graphe Diag_verdauung_r 0 0.006 "Symptoms of the digestive system" 0.004 //no effect
	
	
	*gutartige tumore (gibt es nicht nach gender)
	rename Diag_gutartg_krebs_r Benign_neoplasm
	RD_graphe Benign_neoplasm 0 0.006 "Benign neoplasm" 0.004					//no effect

	*Tumor (gibt es nicht nach gender)
	rename Diag_boesartg_neubild_r Malig_neoplasm
	RD_graphe Malig_neoplasm 0 0.006 "Malignant neoplasm" 0.004 				//no effect
 
	*lymphkrebs
	rename Diag_venen_lymph_r Lymphoma
	RD_graphe Lymphoma 0 0.005 "Diseases of the blood & lymphatic vessels"0.004						//kleiner positiver effekt?
	
	*Diag_depression_r 
	rename Diag_depression_r  Depression
	RD_graph Depression 0 .003 "Depression" 0.0025 								//no effect
	RD_graphe Depression 0 0.004 "Depression" 0.0025 

	*Diag_sonst_herzkrank_t (non-ischemic heart disease)
	rename Diag_sonst_herzkrank_r  Heart
	RD_graphe Heart 0 .003 "Non-ischemic heart disease" 0.0025					// vielleicht kleiner efekt
	
	*Diag_persoenlichk_stoerung_t 
	rename Diag_persoenlichk_stoerung_r Personality							// no effect
	RD_graphe Personality 0 .003 "Personality and behavioral disorder" 0.0025					
	
	*Diag_kreislauf_atmung_t
	rename Diag_kreislauf_atmung_r Symp_resp									// no effect
	RD_graphe Symp_resp 0 .003 "Symptoms of the respiratory & circulatory system" 0.0025
	
	*Diag_steine_t 
	rename Diag_steine_r Calculi												//no effect
	RD_graphe Calculi 0 .003 "Renal insufficiency (Calculi)" 0.0025
	

	
