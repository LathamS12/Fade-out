/*******************************************************************
* Author: Scott Latham
* Purpose: This file selects variables from the two ECLS-K cohorts
* 			for inclusion in the fade out analysis
*
* Uses:
*	"ECLS-K 98 BY.dta"
*	"ECLS-K 98 first.dta"
*	"ECLS-K 98 third.dta"
*	"ECLS-K 10 K-3.dta"
*
* Creates: 
*	"Fade out Raw 1998.dta"
*	"Fade out Raw 2010.dta"
*
*
* Created: 4/2/2013
* Last modified: 3/2/2017
*******************************************************************/

set more off
pause on

	
	////////////////////////////
	// 1998 cohort
	///////////////////////////
	
	use "${data}\ECLS-K 98 BY", clear
	
	// Kindergarten
	******************
	
		keep /*

		ID variables
			*/ CHILDID PARENTID T1_ID T2_ID S1_ID S2_ID P1FIRKDG /*
	
	
		Type of ECE
			*/ P1*PREK P1CPRGPK P1CFEEPK P1*HRSPK P1HSHRS S2KPUPRI  /*
			

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
					*/ A2LERNLT-A2RDFLNT A2OFTRDL A2TXRDLA A2OFTMTH A2TXMTH/*

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
			
			Vars related to English screener
				*/ C1SPASMT C1SC* C1SPHOME /*
		
		Weights
			*/ BYCW0 BYPW0 


		save "${path}\Generated datasets\Kinder", replace
		
		
	// First grade 
	*******************

		use "${data}\ECLS-K 98 first", clear
	
		keep  /*

			ID variables
				*/ CHILDID /*
			
			Age at assessment
				*/  R4AGE /*

			Outcomes
				*/ T4LEARN T4CONTRO T4INTERP T4EXTERN T4INTERN  /*		
				*/ C4RRSCAL C4RMSCAL /*
			
			1st grade moderators
				*/	A4TOTAG	A4TXRDLA A4OFTRDL A4OFTMTH A4TXMTH			/*
				
			Weights
			*/ C124CW0 C124PW0
		
		save "${path}\Generated datasets\First", replace
		

	// Third grade
	*********************
		
		use "${data}\ECLS-K 98 third", clear
		
		keep  /*

			ID variables
				*/ CHILDID /*
			
			Age at assessment
				*/  R5AGE /*

			Outcomes
				*/ T5LEARN T5CONTRO T5INTERP T5EXTERN T5INTERN  /*		
				*/ *R2RSCL *R2MSCL /*
			
			3rd grade moderators
				*/ A5TOTAG A5OFTRDL A5TXRDLA A5OFTMTH A5TXMTH /*
			Weights
			*/ C1_5FC0 C1_5FP0
	
		save "${path}\Generated datasets\Third", replace

	// Merging across waves	
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


	// Renaming variables to match 2010
	******************************************
		rename B1* A1*

		//3rd grade outcomes in 2010 have "7" prefixes rather than "5"
			rename ?5* ?7*
			rename C1_5* C1_7*
			
		//Demographics
			rename DOBMM X_DOBMM
			rename DOBYY X_DOBYY

			rename R1_KAGE  X1AGE
			rename R2_KAGE  X2AGE
			rename R4AGE	X4AGE
			rename R7AGE	X7AGE

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
			rename C*R2RSCL X*RSCALK3
			rename C*R2MSCL X*MSCALK3
			
			rename T*CONTRO X*TCHCON
			rename T*EXTERN X*TCHEXT

			/*Non rescaled outcomes
			rename C1RSCALE X1RSCALK1
			rename C1MSCALE X1MSCALK1
			
			rename C2RSCALE X2RSCALK1
			rename C2MSCALE X2MSCALK1

			rename C4RRSCAL X4RSCALK1
			rename C4RMSCAL X4MSCALK1
			*/
			
		//Other vars

			rename P1FIRKDG X1FIRKDG
			rename P2VOLUNT P2VOLSCH

			rename P2DANCE  P2DANCLS
			rename P2ARTCRF P2ARTLSN
			rename P2ORGANZ P2PERFRM
			rename P1READBO P1READBK
			
			rename S2KPUPRI X2PUBPRI


		save "Fade out raw 1998", replace
	
	
	////////////////////////////////////
	// 2010 cohort
	///////////////////////////////////
	
	use "${data}\ECLS-K 10 K-3", clear
	
	// Kindergarten
	*******************		
	
		keep /*

		ID variables
			*/ CHILDID PARENTID T1_ID T2_ID S1_ID S2_ID X1FIRKDG X1FLSCRN C1SPASMT /*
		
		Type of ECE
			*/ P1CPREK P1HSPKCN P1CHRSPK P1CTRST X2PUBPRI /*

		Controls

			Child characteristics
				*/ X_CHSEX X_RACETH_R X1KAGE X2KAGE X_DOBMM X_DOBYY X12SESL P1PRMLNG P1PRMLN1 P1PRMLN2 X12LANGST /*
				*/	P1PRMLNG P1WEIGHP P1WEIGHO P*EARLY P*ERLYUN X1HEIGHT X1WEIGHT /*

			Family characteristics
				*/ X1LESS18 X1OVER18 X1HPAR1 X1HPAR2 P1NUMPLA X1LOCALE X1REGION P1CLSGRN /*
				*/   X12PAR1ED_I X12PAR2ED_I X1PAR1AGE /*


		Moderators

			Kindergarten variables

				Class size/general time use
					*/ A1?TOTAG A1?HRSDA T1CLASS A1FULDAY A1HALF* A1WHLCLS-A1CHCLDS A2OFTRDL A2TXRDL A2OFTMTH A2TXMTH /*

				Reading/ELA time use
					*/ A2CONVNT-A2RDFLNT A2PRACLT-A2PATTXT /*

				Math time use
					*/ A2QUANTI-A2EQTN A2OUTLOU-A2NUMBLN  /*


			Co-location and transition practices
				*/ P1CSAMEK S2PRKNDR A1INFOHO-A1STAGGR  /*
			
			Parent involvement	
				*/ P1TELLST P1READBK P2LIBRAR /*
				*/ P2WARMCL P2CHLIKE P2SHOWLV P2EXPRES  /*
				*/ P2ATTENB P2ATTENP P2PARADV P2VOLSCH P2FUNDRS /*	

			Extracurriculars
				*/  P2DANCLS-P2CRAFTS /*


		Outcomes		  
			*/ X1RSCALK3 X1MSCALK3 X2RSCALK3 X2MSCALK3 /*
			
			*/ X1TCHCON X1TCHPER X1TCHEXT X1TCHINT X1TCHAPP /*
			*/ X2TCHCON X2TCHPER X2TCHEXT X2TCHINT X2TCHAPP /*
		
			Assessment months
				*/ X1ASMTMM X2ASMTMM /*
			
			Variables related to English screener
				*/ C1SPASMT X1PL* C1SPHOME /*

		Weights
			*/ W12T0 W12P0 W12AC0 W1_2P0 /*

			
	// First grade
	*****************
	
		Outcomes	
			*/ X4RSCALK3 X4MSCALK3 /*
			X4RSCALK3 X4MSCALK3 
			
			*/ X4TCHCON X4TCHPER X4TCHEXT X4TCHINT X4TCHAPP X4LOCALE /*
		
		Age at assessment
			*/ X4AGE /*
		
		First grade moderators	
			*/ A4TOTAG	A4OFTRDL A4TXRDLA A4OFTMTH A4TXMTH /*
			
			
		Sampling weight
			*/ W4C4P_20 /*
			

	// Third grade 
	******************

		Outcomes
			*/ X7RSCALK3 X7MSCALK3 X7TCHCON X7TCHPER X7TCHEXT X7TCHINT X7TCHAPP X4LOCALE /*
		
		Age at assessment
			*/ X7AGE /*
			
		Third grade moderators
			*/ A7ENROL A7OFTRDL A7TXRDL A7OFTMTH A7TXMTH  /*
			
		Weight
			*/ W7C7P_20

			
	//Rename a couple of wayward variables	
		rename X1KAGE_R X1AGE
		rename X2KAGE_R X2AGE
		rename A7ENROL A7TOTAG
		
	save "${path}\Generated datasets\Fade out raw 2010", replace
		
