/*************************************************************
* Author: Scott Latham
* Purpose: This file imputes missing data for both ECLS-K datasets 
*		for  the fade out analysis
* 
* Uses:
*		"Fade Out 1998 Clean"
* 		"Fade Out 2010 Clean"
*
* Creates: 
*		"Fade Out 1998 Final" 
*		"Fade Out 2010 Final"   
* 
* Created: 8/15/2013
* Last modified: 11/16/2016
*************************************************************/

	pause on

	********************
	*	1998
	********************

		use "${path}\Generated Datasets\Fade Out Clean 1998", clear
			
		# delimit ;
		
			gl impute "HEADSTART CENTER PREK FULL_PK

						FULL_K COLOC HIGHPEER SMCLASS_K DIDACT ADV_READ ADV_MATH 
						KTRANS LIT_EXPOSE PINVOLVE PINTERACT
						FULL_K_int COLOC_int HIGHPEER_int SMCLASS_K_int DIDACT_int ADV_READ_int ADV_MATH_int
						KTRANS_int LIT_EXPOSE_int PINVOLVE_int PINTERACT_int

						X1KAGE X2KAGE BLACK HISP ASIAN SESQ1 SESQ2 SESQ3 SESQ4 
						LOBWGHT PREMAT1 PREMAT2 P1NUMPLA MDROPOUT MGRDEG DDROPOUT 
						DGRDEG MOMAGE1 MOMAGE2 MOMAGE3 P1CLSGRN "; 	

			gl reg "AGE_SEPTK MALE CITY SUBURB NORTHEAST MIDWEST SOUTH P1SINGLE 
				P1BLENDED P1ADOPT X1LESS18 X1OVER18 BYCW0 C124CW0 ";

		#delimit cr

			// Sample restriction!!!
			**************************
				keep if csamp1 ==1 | bsamp1 ==1  //Does it make sense to restrict sample here?

				sum $impute $reg
			
			//Set and register the data
				mi set wide
				mi register imputed $impute
				mi register regular $reg

				set seed 15000

				mi impute chained (regress) ${impute} = ${reg}, noisily add(20)	
				

			//Generate variables from ordinal variables			
				mi passive: gen PRESCHOOL2 = CENTER+PREK



			save "${path}\Generated Datasets\Fade Out Final 1998", replace

	********************
	*	2010
	********************
		use "${path}\Generated Datasets\Fade Out Clean 2010", clear

		#delimit ;
			
			gl impute " HEADSTART CENTER PREK FULL_PK

						FULL_K COLOC HIGHPEER SMCLASS_K DIDACT ADV_READ ADV_MATH 
						KTRANS LIT_EXPOSE PINVOLVE PINTERACT
						FULL_K_int COLOC_int HIGHPEER_int SMCLASS_K_int DIDACT_int ADV_READ_int ADV_MATH_int
						KTRANS_int LIT_EXPOSE_int PINVOLVE_int PINTERACT_int					

						X1KAGE X2KAGE AGE_SEPTK MALE BLACK HISP ASIAN SESQ1 SESQ2 SESQ3 SESQ4 
						LOBWGHT PREMAT1 PREMAT2 P1NUMPLA 
						MDROPOUT MGRDEG DDROPOUT DGRDEG MOMAGE1 MOMAGE2 MOMAGE3  					
						P1SINGLE P1BLENDED P1ADOPT P1CLSGRN X1LESS18 X1OVER18 ";	

			gl reg " CITY SUBURB NORTHEAST MIDWEST SOUTH W12T0 W4C4P_20 ";

		#delimit cr


			// Sample restriction!!!
			**************************
				keep if csamp1 ==1 | bsamp1 ==1  //Does it make sense to restrict sample here?
				

				sum $impute $reg

			//Set and register the data
				mi set wide
				mi register imputed $impute
				mi register regular $reg

				set seed 15000

				mi impute chained (regress) ${impute} = ${reg}, noisily add(20)	

			//Generate variables from ordinal variables
				mi passive: gen PRESCHOOL2 = CENTER+PREK


			save "${path}\Generated Datasets\Fade Out Final 2010", replace



