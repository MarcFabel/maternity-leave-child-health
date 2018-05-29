// auxiliary file for DDRD regression


	#delimit ;
	global controlvars 
		age
		agesq;
	#delimit cr
	

	rename NumX Numx
	rename NumX2 Numx2
	rename NumX3 Numx3
	
	//Important globals
	* List of control groups
	global C2    = "(control == 2 | control == 4)"
	global C1_C2 = "control != 3"
	
	* Bandwidths (sample selection)
	global M1 = "(Numx >= -1 & Numx <= 1)"
	global M2 = "(Numx >= -2 & Numx <= 2)"
	global M3 = "(Numx >= -3 & Numx <= 3)"
	global M4 = "(Numx >= -4 & Numx <= 4)"
	global M5 = "(Numx >= -5 & Numx <= 5)"
	global MD = "(Numx != -1 & Numx != 1)"
	
	* globals for age range 5 years taken together (age refers to year in which TG is that old)
	global age_17_21 = "(year_treat >= 1996 & year_treat<=2000)"
	global age_22_26 = "(year_treat >= 2001 & year_treat<=2005)"
	global age_27_31 = "(year_treat >= 2006 & year_treat<=2010)"
	global age_32_35 = "(year_treat >= 2011 & year_treat<=2014)"
	
	
	
	
	
	********************************************************************************	
	// globals definieren für überschrift in den Tabellen
	global length_of_stay		"Average length of stay"
	global summ_stay			"Accumulated length of stay"
	global share_surgery		"Share with surgery"
	global hospital				"Hospital admission"
	global hospital2			"Hopsital admission w/o d14"
	global d1					"Certain infectious and parasitic diseases"
	global d2					"Neoplasms"
	global d5					"Mental and behavioral disorders"
	global d6 					"Diseases of the nervous system"
	global d7 					"Diseases of the eye and ear"
	global d8 					"Diseases of the circulatory system"
	global d9 					"Diseases of the respiratory system"
	global d10 					"Diseases of the digestive system"
	global d11 					"Diseases of the skin and subcutaneous tissue"
	global d12 					"Diseases of the musculoskeletal system and connective tissue"
	global d13 					"Diseases of the genitourinary system"
	global d17 					"Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified"
	global d18 					"External causes of morbidity and mortality"
	
	global metabolic_syndrome 	"Incidence of metabolic Syndrome"	
	global respiratory_index 	"Index respiratory system"
	global drug_abuse 			"Psychoactive substance abuse"
	global heart				"Non-ischemic heart diseases"
		
	global injuries 			"Injuries"
	global neurosis 			"Neurosis"
	global joints 				"Disease of the joints"
	global kidneys 				"Diseases of the kidneys"
	global bile_pancreas		"Diseases of the bile and pancreas"
		
	global d14 					"Pregnancy, childbirth and the puerperium"
	global female_genital_tract	"Non-inflammatory diseases of the female genital tract"
	global pregnancy			"Diseases of the mother, associated with the pregnancy"
	global delivery 			"Obstructed labor \& problems during delivery"
	
	global stomach				"Diseases of the stomach"
	global symp_dig_system		"Symptoms of the digestive system"
	global mal_neoplasm			"Malignant neoplasm"
	global ben_neoplasm			"Benign neoplasm"

	global depression			"Depression"
	global personality			"Personality and behavioral disorder"
	global lymphoma				"Diseases of the blood \& lymphatic vessels"
	global symp_resp_system		"Symptoms of the respiratory \& circulatory system"
	global calculi				"Renal insufficiency (Calculi)"
	
********************************************************************************
// Liste erstellen; variablen die per gender sind und bei denen ratios existierenh
#delimit ;
global list_outcomes "
	d5
	metabolic_syndrome 
	respiratory_index 
	drug_abuse 
	heart
	
	diabetis 
	hypertension
	ischemic 
	adipositas
	lung_infect
	pneumonia
	lung_chron 
	asthma 
	intestine_infec
	leukemia 
	shizophrenia 
	affective
	neurosis 
	personality 
	childhood 
	ear
	otitis_media
	
	symp_circ_resp
	symp_digest
	
	Summ_stay	
	Sum_surgery
	hospital
	hospital2
	patients
	d1				
	d2
	d3
	d4				
	d6 				
	d7 				
	d8 				
	d9 				
	d10 					
	d11 					
	d12 					
	d13 					
	d17 					
	d18
	";
#delimit cr
