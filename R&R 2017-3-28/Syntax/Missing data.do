/*************************************************************
* Author: Scott Latham
* Purpose: This file imputes missing data for both ECLS-K datasets 
*		for  the fade out analysis
*    
* 
* Created: 8/15/2013
* Last modified: 3/11/2017
*************************************************************/

	pause on
	use "$path\Generated datasets\Fade out clean - appended", clear
	
	# delimit ;
	
		loc mods "FULL_K PRESCH_PEER KTRANS ADV_READ ADV_MATH ALL_SMALL_K ALL_SMALL_1 ALL_SMALL_3" ;
		loc ints "";
		
		foreach x in `mods'	{	;
			loc ints "`ints' `x'_int"	;
		}	;

		loc dvs "X1MSCALEz X2MSCALEz X4MSCALEz X7MSCALEz X1RSCALEz X2RSCALEz X4RSCALEz X7RSCALEz
				 X1TCHEXTz X2TCHEXTz X4TCHEXTz X7TCHEXTz X1TCHCONz X2TCHCONz X4TCHCONz X7TCHCONz ";
		
		gl impute "HEADSTART CENTER PREK FULL_PK   
					`dvs' `mods' `ints'
		
					X1AGE X2AGE X4AGE X7AGE BLACK HISP ASIAN MALE AGE_SEPTK SESQ1 SESQ2 SESQ3 SESQ4 SESQ_all_1 SESQ_all_2 SESQ_all_3 SESQ_all_4 
					LOBWGHT PREMAT1 PREMAT2 P1NUMPLA MDROPOUT MGRDEG DDROPOUT 
					DGRDEG MOMAGE1 MOMAGE2 MOMAGE3 P1CLSGRN 
					P1SINGLE P1BLENDED P1ADOPT X1LESS18 X1OVER18	
					NORTHEAST MIDWEST SOUTH weight_4 weight_7   "; 	

		gl reg "CITY SUBURB weight_1 weight_2 K2010 ";
	
	#delimit cr							
		
	// Sample restriction!!!
		**************************
		 drop if weight_1 ==. | weight_2 == . | CITY==. | SUBURB==. //This just allows enough vars to do the imputation
			
		sum $impute $reg

		//Set and register the data
			mi set wide
			mi register imputed $impute
			mi register regular $reg

			set seed 15000

			mi impute chained (regress) ${impute} = ${reg}, dots add(20)	
			
			save "${path}\Generated Datasets\Temp", replace
			use "${path}\Generated Datasets\Temp", clear
	
		//Generate variables from ordinal variables			
			mi passive: gen PRESCHOOL2 = CENTER+PREK
			mi passive: gen PART_PK2 = PRESCHOOL2-FULL_PK
			mi passive: gen NO_PRE2 = 1-PRESCHOOL2

		
		save "${path}\Generated Datasets\Fade out appended final (20 imp)", replace
