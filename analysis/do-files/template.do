/*******************************************************************************
* File name: 	mlch_KKH_prepare_regionalst_MZ
* Author: 		Marc Fabel
* Date: 		26.09.2017
* Description:	Prepare Regionalstatistik und Mikrozensus
*				1) nimmt Regionalstatistik auf Kreisebene und collspsed auf GDR Ebene
*				2) MZ dranspielen
*
* Inputs:  		$excel/Bevoelkerung_Altersjahre_Geschlecht `i'
*				$MZ/MOB_Distr_GDRFRG.csv
* Outputs:		$temp\bevoelkerung_final.dta
*
* Updates:
*
*******************************************************************************/



// ***************************** PREAMBLE********************************
	clear all
	set more off
	
	global path "F:\econ\m-l-c-h\analysis"
	global excel "G:\Projekte\Projekte_ab2016\EcUFam\Daten\Regionaldatenbank\Data\Excel\Rohdaten"
	global MZ "F:\KKH_Diagnosedaten\"
	global temp  "$path/temp"	
// ***********************************************************************
