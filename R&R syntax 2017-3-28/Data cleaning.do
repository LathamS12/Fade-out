/*************************************************************
* Author: Scott Latham
* Purpose: This file cleans variables from the ECLS-K and 
* 		constructs variables necessary for the fadeout analysis
* 
* Uses:
*	"Fade out raw 1998.dta"
*	"Fade out raw 2010.dta"
*
* Creates: 
*	"Fade out clean 1998.dta"
*	"Fade out clean 2010.dta"	 	  
* 
* Created: 4/4/2013
* Last modified: 3/7/2017
*************************************************************/
	
	version 13.1
	pause on
	cd "Z:\save here\Scott Latham\Fade out\Generated datasets"
	
	foreach cohort in 1998 2010	{

		use "Fade out raw `cohort'", clear
			
			if "`cohort'" == "1998"  	recode X1REGION-A7TXMTH 	(-1=.a) (-7=.) (-8=.) (-9=.) // Need to recode these before selecting the sample
			if "`cohort'" == "2010"  	recode W12T0-S2PRKNDR 		(-1=.a) (-7=.) (-8=.) (-9=.)
		
		* Define our samples
		***********************************
			*Academic sample
				gen a_samp1 = 1 //Initialize academic sample
					replace a_samp1 = 0 if X1FIRKDG !=1 //No kindergarten repeaters
						if "`cohort'" == "1998" replace a_samp1 = 0 if C1SCTOT <=36 //Passed language screener (Cutoff was 36)
						if "`cohort'" == "2010" replace a_samp1 = 0 if X1PLTOT <=16 //Passed language screener (Cutoff was 16)						
					replace a_samp1 = 0 if X1RSCALK3 >=. | X1MSCALK3 >=. | X2RSCALK3 >=. | X2MSCALK3 >=. | X4RSCALK3 >=. | X4MSCALK3 >=. //Condition on having math/lit scores through first grade	

				label var a_samp1 "Academic sample (through 1st grade)"
				
				gen a_samp3 = a_samp1
				replace a_samp3 = 0 if X7RSCALK3 >=. | X7MSCALK3 >=.	
				label var a_samp3 "Academic sample (through 3rd grade)" //Final sample should be 10,401 in 1998; 8930 in 2010

			*Math sample
				gen m_samp3 = 1
					replace m_samp3=0 if X1FIRKDG !=1
					replace m_samp3=0 if X1MSCALK3 >=. | X2MSCALK3 >=. | X4MSCALK3 >=. | X7MSCALK3 >=.
							
			*Behavioral sample	
				gen b_samp1 = 1 //Initialize behavioral sample
					replace b_samp1 = 0 if X1FIRKDG !=1 //No kindergarten repeaters
					replace b_samp1 = 0 if X1TCHEXT >=. | X1TCHCON >=. | X2TCHEXT >=. | X2TCHCON >=. | X4TCHEXT >=. | X4TCHCON >=.	
				
				label var b_samp1 "Behavioral sample (through 1st grade)"	

				gen b_samp3 = b_samp1
				replace b_samp3 = 0 if X7TCHEXT >=. | X7TCHCON >=.
				label var b_samp3 "Behavioral sample (through 3rd grade)"

			//Remove from sample if they have a weight of 0 in any wave (only seems to apply in 2010)
				if "`cohort'" == "1998"  {
					replace a_samp3 = 0 if BYCW0 == 0 | C124CW0 == 0 | C1_7FC0 ==0 
					replace b_samp3 = 0 if BYCW0 == 0 | C124CW0 == 0 | C1_7FC0 ==0 
					replace m_samp3 = 0 if BYCW0 == 0 | C124CW0 == 0 | C1_7FC0 ==0
				}
				if "`cohort'" == "2010"	{
					replace a_samp3 = 0 if W1_2P0 == 0 | W4C4P_20 == 0 | W7C7P_20 ==0
					replace b_samp3 = 0 if W1_2P0 == 0 | W4C4P_20 == 0 | W7C7P_20 ==0
					replace m_samp3 = 0 if W1_2P0 == 0 | W4C4P_20 == 0 | W7C7P_20 ==0
				}

		*******************
		*	1998 specific
		*******************
			if "`cohort'" == "1998"	{		

				gen K2010 =0
				label var K2010 "Child was in the 2010 cohort"
				
				clonevar weight_1 = BYCW0
				clonevar weight_2 = BYCW0
				clonevar weight_4 = C124CW0
				clonevar weight_7 = C1_7FC0
	
				* Early childcare - Head start, public pre-k, or center
				*********************************************************
						
					label var P1CHRSPK "Hours/wk spent in center care in the year before kindergarten"							
					recode P1CHRSPK P1HSHRS (.a=0) //Recode "N/A" to "0 hours" for kids in HS and center based care

					gen HEADSTART = P1HSHRS >=5 //Equals 1 for students who were in HS 5 or more hours/wk
					replace HEADSTART =. if P1CHRSPK ==. | P1HSHRS ==.	
					label var HEADSTART "Child attended Head Start in year before K"
				
					gen PREK = P1CPREK ==1 & P1CPRGPK <. & P1CFEEPK ==2 //If child attended free center based care
					replace PREK =1 if P1CSAMEK ==1 & X2PUBPRI ==1  //If child attended PK and K in same school and school is public
					replace PREK = 0 if P1CHRSPK <5 | (P1HSHRS >0) //Less than five hours per week or ANY # of hours in HS
					replace PREK = . if P1CHRSPK ==. | P1HSHRS ==.
					label var PREK "Child attended public prek"
					
					gen CENTER = P1CHRSPK >=5 & HEADSTART==0 & PREK ==0
					replace CENTER =. if P1CHRSPK ==. | P1HSHRS ==.
					label var CENTER "Child attended center based care in year before k"

					gen PRESCHOOL = PREK==1|CENTER==1
					replace PRESCHOOL =. if PREK ==. | CENTER==.
					label var PRESCHOOL "Child attended preschool (Pre-k or center) in the year before K"

				//	gen NO_PRE = PRESCHOOL ==0 & HEADSTART ==0
				//	replace NO_PRE = . if PRESCHOOL ==. | HEADSTART ==. 
				//	label var NO_PRE "Child did not attend preschool/Head Start in year before K"

					//Full time v part time care

						gen FULL_PK = (P1CHRSPK >=20 | P1HSHRS >=20) & PRESCHOOL ==1
						replace FULL_PK = . if P1CHRSPK ==.	| P1HSHRS ==.
						label var FULL_PK "Child attended full time care in the year before K"

						gen PART_PK = FULL_PK ==0 & P1CHRSPK >=5 
						replace PART_PK = 0 if HEADSTART ==1
						replace PART_PK =. if P1CHRSPK ==. | HEADSTART ==.
						label var PART_PK "Child attended part time care in year before K"

				//City/Suburban
					gen CITY = KURBAN==1 | KURBAN==2
					replace CITY = . if KURBAN ==.
					label var CITY "Student lives in a city"
					
					gen SUBURB = KURBAN==3 | KURBAN==4 | KURBAN==5
					replace SUBURB = . if KURBAN ==.
					label var SUBURB "Student lives in suburbs"

				//Family structure
					gen P1SINGLE = (P1MOMTYP ==1 & P1DADTYP ==3) | (P1MOMTYP ==3 & P1DADTYP ==1)
					replace P1SINGLE =. if P1MOMTYP ==. | P1DADTYP ==.
					label var P1SINGLE "Single parent family"
					
					gen P1BLENDED = (P1MOMTYP ==1 & P1DADTYP ==2) | (P1MOMTYP ==2 & P1DADTYP ==1)
					replace P1BLENDED =. if P1MOMTYP ==. | P1DADTYP ==.
					label var P1BLENDED "Blended family (one biological parent)"
					
					gen P1ADOPT = (P1MOMTYP ==2 & P1DADTYP ==2)
					replace P1ADOPT =. if P1MOMTYP ==. | P1DADTYP ==.
					label var P1ADOPT "Adopted/foster parents"	
		
				//Time on classroom reading/math instruction
					
					egen AVG_RDL_K = rmean(A2TXRDL)
					egen AVG_RDL_1 = rmean(A2TXRDL A4TXRDL)
					egen AVG_RDL_3 = rmean(A2TXRDL A4TXRDL A7TXRDL)
					
					egen AVG_MTH_K = rmean(A2TXMTH)
					egen AVG_MTH_1 = rmean(A2TXMTH A4TXMTH)
					egen AVG_MTH_3 = rmean(A2TXMTH A4TXMTH A7TXMTH)
					
					
					foreach subj in RDL MTH	{
						foreach x in K 1 3	{
						
							sum AVG_`subj'_`x', detail
							gen HI_`subj'_`x' = AVG_`subj'_`x' >= r(p50)
							replace HI_`subj'_`x' = . if AVG_`subj'_`x' ==.
							
							label var HI_`subj'_`x' "Above median exposure to `subj' content in `x'"

							} //close x loop
					} //close subj loop
		
				
			} // close "if cohort==1998"

		*******************
		*	2010 specific
		*******************
			if "`cohort'" == "2010"	{

				gen K2010 = 1
				label var K2010 "Child is in the 2010 cohort"

				clonevar weight_1 = W1_2P0
				clonevar weight_2 = W1_2P0
				clonevar weight_4 = W4C4P_20
				clonevar weight_7 = W7C7P_20										

				* Early childcare - Head Start, public pre-k, or center
				*********************

					label var P1CHRSPK "Hours/wk spent in center care in the year before kindergarten"		
					recode P1CHRSPK  (.a=0)

					gen HEADSTART = P1HSPKCN ==1 & P1CHRSPK >= 5
					replace HEADSTART=. if P1CHRSPK ==.
					label var HEADSTART "Child attended Head Start in year before K"

					gen PREK = P1CPREK == 1 & P1CTRST ==1
					replace PREK = 1 if P1CSAMEK ==1 & X2PUBPRI ==1
					replace PREK = 0 if P1CHRSPK <5 | P1HSPKCN ==1 //Less than 5 hours or ANY Head Start
					replace PREK = . if P1CHRSPK ==.
					label var PREK "Child attended public pre-k"
					
					gen CENTER = P1CPREK ==1 & PREK ==0 & HEADSTART==0
					replace CENTER = 0 if P1CHRSPK <5
					replace CENTER =. if P1CHRSPK ==.
					label var CENTER "Child attended center based care in year before K"

					gen PRESCHOOL = PREK==1 | CENTER==1 
					replace PRESCHOOL = . if PREK ==. | CENTER ==. 
					label var PRESCHOOL "Child attended preschool (Pre-k or center) in year before K"

				//	gen NO_PRE = PRESCHOOL ==0 & HEADSTART ==0
				//	replace NO_PRE = . if PRESCHOOL ==. | HEADSTART ==. 
				//	label var NO_PRE "Child did not attend preschool/Head Start in year before K"

					//Full time v part time care
						gen FULL_PK = P1CHRSPK >=20 & PRESCHOOL==1
						replace FULL_PK = 0 if HEADSTART ==1
						replace FULL_PK =. if P1CHRSPK ==.
						label var FULL_PK "Child attended full time care in year before K" 

						gen PART_PK = FULL_PK ==0 & P1CHRSPK >=5 
						replace PART_PK = 0 if HEADSTART ==1
						replace PART_PK =. if P1CHRSPK ==. | HEADSTART ==.
						label var PART_PK "Child attended part time care in year before K"

					//City/suburban
						gen CITY = X1LOCALE>=11& X1LOCALE<=13
						label var CITY "Student lives in a city"
						
						gen SUBURB = X1LOCALE>=21& X1LOCALE<=23
						label var SUBURB "Student lives in suburbs"
		

					//Family structure
						gen P1SINGLE = X1HPAR1 !=. & (X1HPAR2==15 | X1HPAR2 ==.a)
						replace P1SINGLE =. if X1HPAR1 ==.			
						label var P1SINGLE "Single parent family"
						
						gen P1BLENDED = X1HPAR1==1 & (X1HPAR2 > 2 & X1HPAR2 <15)
						replace P1BLENDED = 1 if X1HPAR1 ==2 & X1HPAR2 > 2
						replace P1BLENDED = 1 if X1HPAR2 ==2 & X1HPAR1 > 2
						replace P1BLENDED =. if X1HPAR1 ==.
						label var P1BLENDED "Blended family (one biological parent)"
						
						gen P1ADOPT = (X1HPAR1 > 2 & X1HPAR1 < 15) & (X1HPAR2 > 2 & X1HPAR2 < 15)
						replace P1ADOPT =. if X1HPAR1 ==.
						label var P1ADOPT "Adopted/foster parents"

						
					//Time on classroom reading/math instruction
					
						recode A?TX* (1=.) (2=1) (3=2) (4=3) (5 6 7 8 = 4) 
		
						egen AVG_RDL_K = rmean(A2TXRDL)
						egen AVG_RDL_1 = rmean(A2TXRDL A4TXRDL)
						egen AVG_RDL_3 = rmean(A2TXRDL A4TXRDL A7TXRDL)
						
						egen AVG_MTH_K = rmean(A2TXMTH)
						egen AVG_MTH_1 = rmean(A2TXMTH A4TXMTH)
						egen AVG_MTH_3 = rmean(A2TXMTH A4TXMTH A7TXMTH)
					
					
					foreach subj in RDL MTH	{
						foreach x in K 1 3	{
						
							sum AVG_`subj'_`x', detail
							gen HI_`subj'_`x' = AVG_`subj'_`x' >= r(p50)
							replace HI_`subj'_`x' = . if AVG_`subj'_`x' ==.
							
							label var HI_`subj'_`x' "Above median exposure to `subj' content in `x'"

							} //close x loop
					} //close subj loop
					
			} //close "if cohort ==2010"

		******************
		*	Both cohorts
		*******************	
		
			*	Standardize and label outcome variables
			******************************************
			
				//Math and reading scores
					foreach i of numlist 1 2 4 7	{	
					
						egen X`i'MSCALEz = std(X`i'MSCALK3) if a_samp3 == 1
						label var X`i'MSCALEz "Standardized math scale score (wave `i')"
						
						egen X`i'RSCALEz = std(X`i'RSCALK3) if a_samp3 == 1
						label var X`i'RSCALEz "Standardized reading scale score (wave `i')"
						
						egen X`i'MSCALEz_2 = std(X`i'MSCALK3) if m_samp3 ==1
						label var X`i'MSCALEz_2 "Standardized math score (including Spanish speakers)"
						
						egen X`i'MSCALEz_all = std(X`i'MSCALK3) //To look at all kids available in each year (i.e. no fixed sample)
						egen X`i'RSCALEz_all = std(X`i'RSCALK3)
					}
				
				//Behavioral outcomes
					label var X1TCHCON 	"Self control (fall K)"
					label var X2TCHCON 	"Self control (spring K)"
					label var X4TCHCON 	"Self control (spring 1st)"
					label var X7TCHCON	"Self control (spring 3rd)"

					label var X1TCHEXT 	"Externalizing behavior (fall K)"
					label var X2TCHEXT 	"Externalizing behavior (spring K)"
					label var X4TCHEXT 	"Externalizing behavior (spring 1st)"
					label var X7TCHEXT 	"Externalizing behavior (spring 3rd)"
					
					//Probably need to standardize these within the behavioral sample
					foreach x in TCHEXT TCHCON	{				
						foreach i in 1 2 4 7 {
							egen X`i'`x'z = std(X`i'`x') if b_samp3 == 1
							
							egen X`i'`x'z_all = std(X`i'`x') //To look at all kids available in each year (i.e. no fixed sample)
						}
					}
					
			* 	Moderators
			********************

				//"Structural" moderators 

					*Full day kindergarten
						cap gen new = A1DHRSDA
						cap replace new = A1AHRSDA if new ==.
						cap replace new = A1PHRSDA if new ==.
						cap rename new A1HRSDA

						gen FULL_K = A1HRSDA>=5
						replace FULL_K = . if A1HRSDA==.
						label var FULL_K "Kindergarten class is full day"	

					*Class size
						cap gen A1TOTAG = A1ATOTAG if T1CLASS==2
						cap replace A1TOTAG = A1PTOTAG if T1CLASS==3
						cap replace A1TOTAG = A1DTOTAG if T1CLASS==1  //In 2010 this was split across 3 variables
				
						gen ALL_SMALL_K = A1TOTAG <=20
						replace ALL_SMALL_K = . if A1TOTAG ==. | A4TOTAG==. | A7TOTAG ==.
						label var ALL_SMALL_K "Child's K class was <=20 students"
						
						gen ALL_SMALL_1 = A1TOTAG <=20 & A4TOTAG <=20
						replace ALL_SMALL_1 = . if A1TOTAG ==. | A4TOTAG==. | A7TOTAG ==.
						label var ALL_SMALL_1 "All classes K & 1 were <=20 students"
						
						gen ALL_SMALL_3 = A1TOTAG <=20 & A4TOTAG <=20 & A7TOTAG <=20
						replace ALL_SMALL_3 = . if A1TOTAG ==. | A4TOTAG==. | A7TOTAG ==.
						label var ALL_SMALL_3 "All classes K, 1, & 3 were <=20 students"			

					*Pre-K/K co-location
						rename S2PRKNDR COLOC
						recode COLOC (2=0)						
						label variable COLOC "Kindergarten and prekindergarten are co-located"
				
						rename P1CSAMEK SAMEPK
						recode SAMEPK (2=0) (.a=0)
						label variable SAMEPK "Student attended preschool and kindergarten in same school"							
			
					*Peer Pre-k exposure			
						bysort T1_ID: egen num = total(PRESCHOOL), missing
						replace num=num-PRESCHOOL
						gen new = 1 if PRESCHOOL<.
						
						bysort T1_ID: egen denom = count(new)
						replace denom = denom-1
						
						gen PRESCH_PEER = num/denom
						label variable PRESCH_PEER "Kindergarten peer exposure to preschool (not including student)"					
						drop num denom new

						gen HIGH_PEER = PRESCH_PEER >= .50
						replace HIGH_PEER=. if PRESCH_PEER==.
						label variable HIGH_PEER ">=50% of child's K classmates attended preschool"

					
				//"Process" moderators

					*Didactic instruction
						gen MT3_WHLCLS = A1WHLCLS >=5
						replace MT3_WHLCLS = . if A1WHLCLS==.
						label var MT3_WHLCLS "More than 3 hrs/day of teacher-directed whole class activities"

						gen MT1_CHSEL = A1CHCLDS >=3
						replace MT1_CHSEL =. if A1CHCLDS ==.
						label var MT1_CHSEL "More than 1 hr/day of child-selected activities"

							drop A1WHLCLS A1CHCLDS
					
						gen DIDACT_R = A2BASAL==6 | A2WRKBK ==6					
						replace DIDACT_R =. if A2BASAL ==.
						label var DIDACT_R "Daily use of reading textbooks/workbooks"
						
						gen DIDACT_M = A2MTHSHT==6 | A2MTHTXT==6
						replace DIDACT_M =. if A2MTHSHT ==.	
						label var DIDACT_M "Daily use of math textbooks/worksheets"
						
					//	egen DIDACT = rowmean(MT3_WHLCLS r_didact m_didact)
					//	label var DIDACT "Didactic instruction"
	
					*Preschool to kindergarten transition practices							
						recode A1INFOHO-A1PRNTOR (2=0)

						egen KTRANS = rowtotal(A1INFOHO-A1PRNTOR)
						label variable KTRANS "Kindergarten transition practices"

						foreach x of varlist A1INFOHO-A1PRNTOR	{
							replace KTRANS =. if `x' ==.
						}

					*Advanced content (The average of skills that over 25% of teachers never taught in 1998)
						loc adv_m "A2EQTN A2PRBBTY A23DGT A2W12100 A2PLACE A2FRCTNS A2BYD100"
						loc adv_r "A2COMPSE A2WRTSTO A2SPELL A2SYLLAB A2ALPBTZ A2RDFLNT"

						loc math_weekly = ""
						loc read_weekly = ""
						
						foreach subj in adv_m adv_r	{			
							foreach x in ``subj'' {
							
								if "`subj'" == "adv_m"	loc math_weekly = "`math_weekly'" + "`x'_w "
								if "`subj'" == "adv_r"	loc read_weekly = "`read_weekly'" + "`x'_w "

								gen `x'_w = `x' >=5 //At least weekly
								replace `x'_w = . if `x' ==.
								
							} //close x loop
						} //close subj loop

						egen ADV_MATH = rowmean(`math_weekly')
						label var ADV_MATH "Advanced math content"

						foreach x in `math_weekly'	{
							replace ADV_MATH =. if `x'==.
						}					
				
						egen ADV_READ = rowmean(`read_weekly')
						label var ADV_READ "Advanced reading content"
						
						foreach x in `read_weekly'	{
							replace ADV_READ =. if `x'==.
						}				

						drop *_w					

				//Parent moderators

					*Literacy exposure
						gen lit_ed = P1READBK ==4 | P1TELLST ==4
						replace lit_ed = . if P1READBK ==. | P1TELLST ==.
							// Read books or told stories every day

						gen librar = P2LIBRAR ==1
						replace librar = . if P2LIBRAR ==.
							// Visited library in last month

						egen LIT_EXPOSE = rowmean(lit_ed librar)
						replace LIT_EXPOSE = . if lit_ed ==. | librar ==.
						label var LIT_EXPOSE "Literacy exposure"

							drop lit_ed librar 

					*Involvement with school
						recode P2ATTENB P2ATTENP P2PARADV P2VOLSCH P2FUNDRS (2=0)
						
						label variable P2ATTENB "Parent attended open house"
						label variable P2ATTENP "Parent attended a PTA meeting"
						label variable P2PARADV "Parent attended a parental advisory meeting"
						label variable P2VOLSCH "Parent volunteered"
						label variable P2FUNDRS "Parent participated in fundraising"
				
						egen PINVOLVE = rowmean(P2ATTENB P2ATTENP P2PARADV P2VOLSCH P2FUNDRS)	
						label var PINVOLVE "Parental involvement index"
				
						foreach x in P2ATTENB P2ATTENP P2PARADV P2VOLSCH P2FUNDRS	{
							replace PINVOLVE =. if `x' ==.
						}

					*Interactions with child					
						foreach x in P2WARMCL P2CHLIKE P2SHOWLV P2EXPRES	{

							recode `x' (.a = .)

							gen `x'_temp = `x' ==1
							replace `x'_temp = . if `x' ==.

						}

						egen PINTERACT = rowmean(*_temp)
						label var PINTERACT "Parental interaction index"
							
						foreach x of varlist *_temp	{
							replace PINTERACT = . if `x' ==.
						}

							drop *_temp

					*Extracurriculars
						recode P2DANCLS P2ATHLET P2MUSIC P2ARTLSN P2CRAFTS P2PERFRM P2CLUB (2=0)
						
						label variable P2DANCLS 	"Child takes dance lessons"
						label variable P2ATHLET 	"Child participates in athletics"
						label variable P2MUSIC 		"Child takes music lessons"
						label variable P2ARTLSN 	"Child takes art lessons"
						label variable P2CRAFTS		"Child takes craft lessons"	
						label variable P2PERFRM 	"Child participated in performing arts"
						label variable P2CLUB		"Child participated in organized club/s"


			* Generate interaction variables for the moderators
			*****************************************************

				loc moderators 	"FULL_K PRESCH_PEER KTRANS ADV_READ ADV_MATH ALL_SMALL_K ALL_SMALL_1 ALL_SMALL_3" 

				foreach x in `moderators'	{
					gen `x'_int = `x' * PRESCHOOL
					label var `x'_int "`x' * PRESCHOOL"
				}

		*	Control variables
		*****************************
	
			//Age
				gen year = (`cohort'.75-X_DOBYY)*12

				gen AGE_SEPTK = year - (X_DOBMM-1)
				label var AGE_SEPTK "Child's age in September of `cohort' (months)"
				drop year
				
				label variable X1AGE "Age at fall K assessment"
				label variable X2AGE "Age at spring K assessment"				
				label variable X4AGE "Age at 1st grade assessment"
				label variable X7AGE "Age at 3rd grade assessment"
			
			//Gender
				recode X_CHSEX (2=0)
				rename X_CHSEX MALE
				label variable MALE "Child is male"

				gen FEMALE = MALE ==0
				replace FEMALE =. if MALE ==.
				label variable FEMALE "Child is female"
				
			//Birthweight
				gen wght = P1WEIGHP
				replace wght = wght + (P1WEIGHO/16) if P1WEIGHO !=.
				replace wght =. if P1WEIGHO==.
				
				gen LOBWGHT = wght < 5.5
				replace LOBWGHT = . if wght ==.
				label variable LOBWGHT "Low birth weight (<5.5 lbs)"
				drop wght P1WEIGHP P1WEIGHO
				
				
			//Race
				rename X_RACETH_R RACE

				gen ALL =1
				
				gen WHITE = RACE==1
				replace WHITE =. if RACE >=.
				label variable WHITE "Child is white"
				
				gen BLACK = RACE == 2
				replace BLACK = . if RACE >=.
				label variable BLACK "Child is black"
				
				gen HISP = RACE == 3 | RACE ==4
				replace HISP = . if RACE >=.
				label variable HISP "Child is Hispanic"	
				
				gen ASIAN = RACE == 5 
				replace ASIAN = . if RACE >=.
				label variable ASIAN "Child is Asian"	
				
				gen OTHER = RACE >5
				replace OTHER = . if RACE >=.
				label variable OTHER "Child is not white/black/Hispanic/Asian"
				
				gen RACES = 1 if WHITE ==1
				replace RACES = 2 if BLACK ==1
				replace RACES = 3 if HISP ==1
				replace RACES = 4 if ASIAN ==1
				
				label var RACES "Race tabulation"
				label define race 1 "White" 2 "Black" 3 "Hispanic" 4 "Asian"
				label values RACES race
			
			//SES
				egen SESQ`cohort' = cut(X12SESL) if m_samp3 ==1, group(5) 
				recode SESQ`cohort' (0=1) (1=2) (2=3) (3=4) (4=5) 
				
				label define quints 1 "Lowest quintile" 2 "Second quintile" 3 "Third quintile" 4 "Fourth quintile" 5 "Highest quintile"
				label values SESQ`cohort' quints
				label variable SESQ`cohort' "Income quintiles"
		
				tab SESQ`cohort', gen(SESQ)

					gen LOWSES = SESQ1 ==1
					replace LOWSES = . if SESQ`cohort'==.
					label variable LOWSES "Child is in the lowest SES quintile"
					
					gen MEDSES = (SESQ2 ==1 | SESQ3 ==1 | SESQ4 ==1)
					replace MEDSES =. if SESQ`cohort'==.
					label variable MEDSES "Child is in the 3 middle SES quintiles"
					
					gen HIGHSES = SESQ5==1
					replace HIGHSES = . if SESQ`cohort'==.
					label variable HIGHSES "Child is in the highest SES quintile"
		
					//To look at all kids (i.e. not a fixed sample)
						egen SESQ`cohort'_all = cut(X12SESL), group(5)
						recode SESQ`cohort'_all (0=1) (1=2) (2=3) (3=4) (4=5) 
				
						tab SESQ`cohort'_all, gen(SESQ_all_)

							gen LOWSES_all = SESQ_all_1 ==1
							replace LOWSES_all = . if SESQ`cohort'_all==.
							label variable LOWSES_all "Child is in the lowest SES quintile"
							
							gen MEDSES_all = (SESQ_all_2 ==1 | SESQ_all_3 ==1 | SESQ_all_4 ==1)
							replace MEDSES_all =. if SESQ`cohort'_all==.
							label variable MEDSES_all "Child is in the 3 middle SES quintiles"
							
							gen HIGHSES_all = SESQ_all_5==1
							replace HIGHSES_all = . if SESQ`cohort'_all==.
							label variable HIGHSES_all "Child is in the highest SES quintile"
							
							
			//ELL
				cap replace P1PRMLNG = P1PRMLN1 if P1PRMLN1 ==P1PRMLN2 //Only for 2010
				gen ELL = P1PRMLNG >0 & P1PRMLNG <. //Intentionally excluding values of "."
				replace ELL = . if P1PRMLNG ==.
				label var ELL "Student's primary language is not English"
	 

			//Premature birth
				gen weeksprem 	  = P1EARLY 	if P1ERLYUN==1
				replace weeksprem = P1EARLY/7 	if P1ERLYUN==2

				replace weeksprem = P2EARLY 	if P2ERLYUN==1 & weeksprem==.
				replace weeksprem = P2EARLY/7 	if P2ERLYUN==2 & weeksprem==.

				
				gen PREMAT1 = weeksprem>=3 & weeksprem<=7
				replace PREMAT1 = . if weeksprem ==.				
				replace PREMAT1 = 0 if P1EARLY ==.a				
				label variable PREMAT1 "Child was 3-7 weeks premature"
				
				gen PREMAT2 = weeksprem>7 & weeksprem <.	
				replace PREMAT2 = . if weeksprem ==.	
				replace PREMAT2 = 0 if P1EARLY ==.a		
				label variable PREMAT2 "Child was more than 7 weeks premature"
				
				drop weeksprem P1EARLY P2EARLY P1ERLYUN P2ERLYUN			
		
	
			//Region of country
				gen NORTHEAST = X1REGION ==1
				replace NORTHEAST =. if X1REGION ==.

				gen MIDWEST = X1REGION ==2
				replace MIDWEST =. if X1REGION ==.

				gen SOUTH = X1REGION ==3
				replace SOUTH =. if X1REGION ==.

				label variable NORTHEAST "Northeast"
				label variable MIDWEST "Midwest"	
				label variable SOUTH "South"
			
				
			//Mother's education
				gen MDROPOUT = X12PAR1ED_I < 3
				replace MDROPOUT =. if X12PAR1ED_I>=.
				label variable MDROPOUT "Mother did not complete HS"
				
				gen MGRADHS = X12PAR1ED_I >2 & X12PAR1ED_I <6
				replace MGRADHS =. if X12PAR1ED_I >=.
				label variable MGRADHS "Mother graduated HS"
						
				gen MGRDEG = X12PAR1ED_I >=8 & X12PAR1ED_I <.
				replace MGRDEG = . if X12PAR1ED_I >=.
				label variable MGRDEG "Mother received a grad degree"
				
				drop X12PAR1ED_I
				
				
			//Father's education
				gen DDROPOUT = X12PAR2ED_I < 3
				replace DDROPOUT =. if X12PAR2ED_I>=.			
				label variable DDROPOUT "Father did not complete HS"
				
				gen DGRADHS = X12PAR2ED_I >2 & X12PAR2ED_I<6
				replace DGRADHS =. if X12PAR2ED_I>=.
				label variable DGRADHS "Father graduated HS"
						
				gen DGRDEG = X12PAR2ED_I >=8 & X12PAR2ED_I<.
				replace DGRDEG = . if X12PAR2ED_I >=.
				label variable DGRDEG "Father received a grad degree"
				
				drop X12PAR2ED_I
			
			
			//Mother's age
				gen MOMAGE1 = X1PAR1AGE <25
				replace MOMAGE1 = . if X1PAR1AGE ==.
				label variable MOMAGE1 "Mother was less than 25 at kindergarten entry"
				
				gen MOMAGE2 = X1PAR1AGE >=25 & X1PAR1AGE <=35
				replace MOMAGE2 = . if X1PAR1AGE ==.
				label variable MOMAGE2 "Mother was between 25 and 35 years old at kindergarten entry"
				
				gen MOMAGE3 = X1PAR1AGE >35 & X1PAR1AGE <=45
				replace MOMAGE3 = . if X1PAR1AGE ==.
				label variable MOMAGE3 "Mother was between 35 and 45 years old at kindergarten entry"
				
				drop X1PAR1AGE

		
			//Labeling and recoding variables
				label var X1HEIGHT "Child's height in kindergarten"
				label var X1WEIGHT "Child's weight in kindergarten"
				label var P1NUMPLA "Number of places child has lived"

				label var P1CLSGRN "Number of close grandparents"
				recode P1CLSGRN (.a = .)

			
		
	save "Fade out clean `cohort'", replace	
	
	} //close x loop

							 
	use "$path\Generated datasets\Fade out clean 1998", clear
	append using "$path\Generated datasets\Fade out clean 2010"
	
	save "$path\Generated datasets\Fade out clean - appended", replace
