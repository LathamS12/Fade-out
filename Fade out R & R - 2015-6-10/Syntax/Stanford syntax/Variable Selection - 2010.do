/***********************************************************************
* Author: Scott Latham
* Purpose: This file selects variables from the ECLS-K 2010 cohort for 
*	inclusion in the analysis of fade out of gains from preschool
*
* Creates: 
*	"Fade Out Raw 2010.dta"
*
* Created: 8/14/2013
* Last modified: 11/16/2016
************************************************************************/

set more off
pause on
		
	*******************
	*  Base year 2010
	*******************	
		use "${data}\ECLS-K 10 K-1", clear
	
		keep /*

		ID variables
			*/ CHILDID PARENTID T1_ID T2_ID S1_ID S2_ID X1FIRKDG X1FLSCRN C1SPASMT /*
		

		Type of ECE
			*/ P1CPREK P1HSPKCN P1CHRSPK P1CTRST  /*

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
					*/ A1?TOTAG A1?HRSDA T1CLASS A1FULDAY A1HALF* A1WHLCLS-A1CHCLDS  /*

				Reading/ELA time use
					*/ A2CONVNT-A2RDFLNT A2PRACLT-A2PATTXT /*

				Math time use
					*/ A2QUANTI-A2EQTN A2OUTLOU-A2NUMBLN  /*


			Co-location and transition practices
				*/ P1CSAMEK S2PRKNDR A1INFOHO-A1STAGGR /*
			
			Parent involvement	
				*/ P1TELLST P1READBK P2LIBRAR /*
				*/ P2WARMCL P2CHLIKE P2SHOWLV P2EXPRES  /*
				*/ P2ATTENB P2ATTENP P2PARADV P2VOLSCH P2FUNDRS /*	

			Extracurriculars
				*/  P2DANCLS-P2CRAFTS /*


		Outcomes	
			 X1RSCALK3 X1MSCALK3 X2RSCALK3 X2MSCALK3 
			*/ X1RSCALK1 X1MSCALK1 X2RSCALK1 X2MSCALK1 /*
			
			*/ X1TCHCON X1TCHPER X1TCHEXT X1TCHINT X1TCHAPP /*
			*/ X2TCHCON X2TCHPER X2TCHEXT X2TCHINT X2TCHAPP /*
		
				Assessment months
					*/ F1ASMTMM F2ASMTMM /*
					 X1ASMTMM X2ASMTMM 

		Weights
			*/ W12T0 W12P0  /*


	**************************
	* First grade variables
	**************************
		
		Outcomes	
			*/ X4RSCALK1 X4MSCALK1 /*
			X4RSCALK3 X4MSCALK3 
			
			*/ X4TCHCON X4TCHPER X4TCHEXT X4TCHINT X4TCHAPP X4LOCALE /*
		
		Age at assessment?

		Sampling weight
			*/ W4C4P_20 
			
	***************************
	* Third grade variables
	***************************
	 /* /*
		Outcomes
			*/ X7RSCALK3 X7MSCALK3 X7TCHCON X7TCHPER X7TCHEXT X7TCHINT X7TCHAPP X4LOCALE /*
			
		Weight
			*/ W7C7P_20
*/
	save "${path}\Generated datasets\Fade Out Raw 2010", replace
		

   
