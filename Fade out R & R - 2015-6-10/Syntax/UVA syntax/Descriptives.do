/*************************************************************
* Author: Scott Latham
* Purpose: This file calculates descriptive statistics 
* 	for students from the two ECLS-K samples	   
* 
* Created: 5/26/2014
* Last modified: 6/10/2015
*************************************************************/

	pause on

	***************************
	* Descriptives by subgroup
	***************************


		capture program drop combined
		program define combined
			args vars title

			//List of subgroups
				loc sub "ALL BLACK HISP LOWSES PRESCHOOL HEADSTART NO_PRE "
				loc sub2 ""

				foreach x in `sub'	{
					loc sub2 = "`sub2'" + " `x'" + " `x'2"
				}

			tempname center
			tempfile file
			postfile `center' str50(label) str5(`sub2') using `file'

				foreach cohort in 1998 2010		{
					
					if `cohort' == 1998		loc weight = "C124CW0"
					if `cohort' == 2010		loc weight = "W4C4P_20"
		 	
					use "F:\Scott\Fade Out\Generated Datasets\Fade Out Final `cohort'", clear

					foreach x in `vars'	{					

						loc `x'lab: variable label `x'				

						*loc n98 = ""
						*loc n10 = ""

						foreach z in `sub'	{

							sum `x' if csamp1 ==1 & `z' == 1 [aw=`weight'] 
							loc `x'_`z'_`cohort': di %4.2f r(mean)
							
							*if `cohort' == 1998		loc n98 = `"`n98'"' + `" ("`r(N)' ") "' + `"("") "'
							*if `cohort' == 2010		loc n10 = `"`n10'"' + `"("") "' + `"("`r(N)'") "'

						} //close z loop
							di `" `n98' "'
							di `" `n10' "'

					} //close x loop
				} //close cohort loop

				//Post header row
				# delimit ;
					post `center' ("Variable") 	("ALL_1998") 		("ALL_2010")	
												("BLACK_1998") 		("BLACK_2010")
												("HISP_1998") 		("HISP_2010")
												("LOWSES_1998") 	("LOWSES_2010")
												("PRESCHOOL_1998")	("PRESCHOOL_2010") 
												("HEADSTART_1998")	("HEADSTART_2010") 
												("NO_PRE_1998")		("NO_PRE_2010") 	;
					# delimit cr

				foreach x in `vars'	{

					# delimit ;
					post `center' ("``x'lab'") 	("``x'_ALL_1998'") 			("``x'_ALL_2010'")
												("``x'_BLACK_1998'") 		("``x'_BLACK_2010'")
												("``x'_HISP_1998'") 		("``x'_HISP_2010'")
												("``x'_LOWSES_1998'") 		("``x'_LOWSES_2010'")
												("``x'_PRESCHOOL_1998'")	("``x'_PRESCHOOL_2010'") 
												("``x'_HEADSTART_1998'")	("``x'_HEADSTART_2010'") 
												("``x'_NO_PRE_1998'")		("``x'_NO_PRE_2010'") 	;
					# delimit cr
	
					*post `center' ("") `" `n98' "'
					*post `center' ("") `" `n10' "'

				} //close x loop 

			postclose `center'
			
			preserve
				use `file', clear
				export excel using "F:\Scott\Fade Out\Tables/`title' descriptives by subgroup.xls", replace
			restore	
			
		end //ends program "combined"
			

			combined "PRESCHOOL CENTER PREK PART_PK FULL_PK HEADSTART" "ECE"
			combined "FULL_K COLOC SMCLASS_K HIGHPEER DIDACT ADV_READ ADV_MATH KTRANS LIT_EXPOSE PINVOLVE PINTERACT" "Moderators"
			
		# delimit ;

			combined "MALE BLACK HISP ASIAN SESQ1 SESQ2 SESQ3 SESQ4 SESQ5
				LOBWGHT PREMAT1 PREMAT2 P1NUMPLA CITY SUBURB NORTHEAST MIDWEST SOUTH
				MDROPOUT MGRDEG DDROPOUT DGRDEG MOMAGE1 MOMAGE2 MOMAGE3 
				P1SINGLE P1BLENDED P1ADOPT P1CLSGRN X1LESS18 X1OVER18" 
					"Control variables (no weights)" ;

		# delimit cr

