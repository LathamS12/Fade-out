/********************************************************
* Author: Scott Latham
* Purpose: This file selects variables from the ECLS-K 1998 cohort
* 			for inclusion in the fade out analysis
* Uses:
*	"F:\NCES Data\ECLS-K\Extracted Data\Base Year - Child.dta"
*   "F:\NCES Data\ECLS-K\Extracted Data\1st Grade.dta"
*
* Creates: 
*	"Fade Out Raw 1998.dta"
*
* Created: 4/2/2013
* Last modified: 11/16/2016
********************************************************/

set more off
pause on

	******************
	*   Kindergarten
	******************

		use "${data}\ECLS-K 98 BY", clear

		keep /*

		ID variables
			*/ CHILDID PARENTID T1_ID T2_ID S1_ID S2_ID P1FIRKDG C1SPASMT /*
	
	
		Type of ECE
			*/ P1*PREK P1CPRGPK P1CFEEPK P1*HRSPK P1HSHRS /*
			

		Controls
		
			Child characteristics
				*/ GENDER RACE R1_KAGE R2_KAGE DOBYY DOBMM P1WEIGHP P1WEIGHO P1PRMLNG WKLANGST /*
				*/ P1EARLY P2EARLY P1EARDAY P2EARDAY C1HEIGHT C1WEIGHT WKSESL  /*
	
			Family characteristics
				*/ P1LESS18 P1OVER18 P1MOMTYP P1DADTYP P1NUMPLA KURBAN CREGION P1CLSGRN  /*
				*/ WKMOMED WKDADED P1ANYLNG P1HMAGE /*
			

		Moderators
			
			Kindergarten variables
				
				Class size/general time use
					*/ A1*TOTAG A1HRSDA B1WHLCLS-B1CHCLDS /*

				Reading/ELA time use
					*/ A2LERNLT-A2RDFLNT /*

				Math time use
					*/ A2OUTLOU-A2EQTN	/*


			Co-location and transition practices
				*/ P1CSAMEK S2PRKNDR  B1INFOHO-B1OTTRAN /*
			
			Parent involvement
				*/ P1READBO P1TELLST P2LIBRAR /*
				*/ P2WARMCL P2CHLIKE P2SHOWLV P2EXPRES  /*
				*/ P2ATTENB P2ATTENP P2PARADV P2VOLUNT P2FUNDRS /*	

			Extracurriculars
				*/  P2DANCE P2ATHLET P2MUSIC P2ARTCRF P2CRAFTS P2ORGANZ P2CLUB /*

			
		Outcomes
			
			*/ C1RSCALE C1MSCALE C2RSCALE C2MSCALE /*
			
			*/ T1LEARN T1CONTRO T1INTERP T1EXTERN T1INTERN P1CONTRO /*
			*/ T2LEARN T2CONTRO T2INTERP T2EXTERN T2INTERN P2CONTRO /*

				Assessment months
					*/ C1ASMTMM C2ASMTMM /*
			
		Weights
			*/ BYCW0 BYPW0 


		save "${path}\Generated datasets\Kinder", replace
		
		
	**************************
	* First grade variables
	**************************

		use "${data}\ECLS-K 98 first", clear
	
		keep  /*

			ID variables
				*/ CHILDID /*
			
			Age at assessment
				*/  R4AGE /*

			Outcomes
				*/ T4LEARN T4CONTRO T4INTERP T4EXTERN T4INTERN  /*		
				*/ C4RRSCAL C4RMSCAL /*
			
			Weights
			*/ C124CW0 C124PW0
		
		save "${path}\Generated datasets\First", replace
		
	**************************
	* Third grade variables
	**************************
		
		use "${data}\ECLS-K 98 third", clear
		
		keep  /*

			ID variables
				*/ CHILDID /*
			
			Age at assessment
				*/  R5AGE /*

			Outcomes
				*/ T5LEARN T5CONTRO T5INTERP T5EXTERN T5INTERN  /*		
				*/ *R2RSCL *R2MSCL /*
			
			Weights
			*/ C1_5FC0 C1_5FP0
	
		save "${path}\Generated datasets\Third", replace

	* Merging datasets	
	**********************

	cd "${path}\Generated Datasets"
		
		use "Kinder", clear
		
		merge 1:1 CHILDID using "First"
		drop _merge
		
		merge 1:1 CHILDID using "Third"
		drop _merge
		
		erase "First.dta"
		erase "Kinder.dta"
		erase "Third.dta"


	*Renaming variables to match 2010 dataset
	******************************************
		rename B1* A1*

		//3rd grade outcomes in 2010 have "7" prefixes rather than "5"
		//	rename ?5* ?7*
		//	rename C1_5* C1_7*
			
		//Demographics
			rename DOBMM X_DOBMM
			rename DOBYY X_DOBYY

			rename R1_KAGE X1KAGE
			rename R2_KAGE X2KAGE
			*rename R4AGE

			rename GENDER X_CHSEX
			rename RACE X_RACETH_R
			rename WKSESL X12SESL
			rename WKLANGST X12LANGST

			rename C1HEIGHT X1HEIGHT
			rename C1WEIGHT X1WEIGHT

			rename P*EARDAY P*ERLYUN
			rename CREGION X1REGION

			rename WKMOMED X12PAR1ED_I
			rename WKDADED X12PAR2ED_I
			rename P1HMAGE X1PAR1AGE

			rename P1OVER18 X1OVER18
			rename P1LESS18 X1LESS18


		//Outcomes
			//rename C*R2RSCL X*RSCALK3
			//rename C*R2MSCL X*MSCALK3
			
			rename T*CONTRO X*TCHCON
			rename T*EXTERN X*TCHEXT

			//Non rescaled outcomes
			rename C1RSCALE X1RSCALK1
			rename C1MSCALE X1MSCALK1
			
			rename C2RSCALE X2RSCALK1
			rename C2MSCALE X2MSCALK1

			rename C4RRSCAL X4RSCALK1
			rename C4RMSCAL X4MSCALK1
			
			
		//Other vars

			rename P1FIRKDG X1FIRKDG
			rename P2VOLUNT P2VOLSCH

			rename P2DANCE P2DANCLS
			rename P2ARTCRF P2ARTLSN
			rename P2ORGANZ P2PERFRM
			rename P1READBO P1READBK



	save "Fade Out Raw 1998", replace
	
	
	
