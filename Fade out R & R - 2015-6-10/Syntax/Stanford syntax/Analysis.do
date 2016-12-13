/*************************************************************
* Author: Scott Latham
* Purpose: This file cleans variables from the ECLS-K and 
* constructs variables necessary for analysis of fade out
* 
* Creates: Lots o' tables
*		   
* 
* Created: 8/14/2013
* Last modified: 6/9/2015
*************************************************************/

pause on
global path "Z:\save here\Scott Latham\Fade out"
	use "$path\Fade Out Final 1998", clear
	use "$path\Fade Out Final 2010", clear

*********************************************************************************************************************************
	
#delimit ;

	gl demog "MALE BLACK HISP ASIAN SESQ1 SESQ2 SESQ3 SESQ4 
				LOBWGHT PREMAT1 PREMAT2 P1NUMPLA CITY SUBURB NORTHEAST MIDWEST SOUTH 
				MDROPOUT MGRDEG DDROPOUT DGRDEG MOMAGE1 MOMAGE2 MOMAGE3 
				P1SINGLE P1BLENDED P1ADOPT P1CLSGRN X1LESS18 X1OVER18 ";

// Used to do analysis by SES..can't figure out why the multiple imputed datasets omit different SES indicators;
	gl mid_ses "MALE BLACK HISP ASIAN SESQ2 SESQ3
				LOBWGHT PREMAT1 PREMAT2 P1NUMPLA CITY SUBURB NORTHEAST MIDWEST SOUTH 
				MDROPOUT MGRDEG DDROPOUT DGRDEG MOMAGE1 MOMAGE2 MOMAGE3 
				P1SINGLE P1BLENDED P1ADOPT P1CLSGRN X1LESS18 X1OVER18 ";
	
	gl cluster "T1_ID";
	gl fmt "%4.2f";

#delimit cr

**********************************************************************************************************************************	;	



	*********************************************
	*
	* Main analysis separately by subgroup
	*
	********************************************
		capture program drop est_results
		program define est_results, rclass
			args coeff

				loc b = ""
				loc se = ""
				loc stars = ""

				loc b: di %3.2f _b[`coeff']
				loc se: di %3.2f _se[`coeff']
				
				if abs(`b'/`se') >= 1.96	loc stars "*" 
				if abs(`b'/`se') >= 2.576	loc stars "**"	
				if abs(`b'/`se') >= 3.291	loc stars "***"

				return loc co = `"("`b'`stars'${bold}")"'
				return loc se = `" ("(`se')") "'		

		end //ends program est_results


		capture program drop subgroup
		program define subgroup
			args year outcome subgroups controls sample filename
				
				use "$path\Generated datasets\Fade Out Final `year'", clear
				
				//capture log close
				//log using "F:\Scott\Fade Out\Logs\Analysis `year' - `filename'", replace

				set matsize 1000

				loc postgroups "" //Initialize postfile columns
				foreach x in `subgroups'	{
					loc postgroups "`postgroups' `x' `x'2 `x'3"
				}

				tempname name
				tempfile file
				postfile `name' str25(coef) str10(`postgroups') using `file'

				foreach x in `outcome' 	{

					//Initialize locals
						foreach v in pre pk cen ft pt	{

							loc `v'_b 	= "" 
							loc `v'_se 	= ""

						} // close v loop
					
						loc n = ""

					foreach subsamp in `subgroups' {

						foreach i in 1 2 4	{
							
							if `i' == 1		{
								if "`year'" == "1998"	loc weight = "[pw=BYCW0]"
								if "`year'" == "2010"	loc weight = "[pw=W12T0]"
								
								loc age = "X1KAGE AGE_SEPTK " //fall
							}

							if `i' == 2		{
								if "`year'" == "1998"	loc weight = "[pw=BYCW0]"
								if "`year'" == "2010"	loc weight = "[pw=W12T0]"

								loc age = "X2KAGE AGE_SEPTK " //spring K
							}

							if `i' == 4		{
								if "`year'" == "1998"	loc weight = "[pw=C124CW0]"
								if "`year'" == "2010"	loc weight = "[pw=W4C4P_20]"
								
								loc age = "X2KAGE AGE_SEPTK " //spring 1st
							}
					

							mi estimate, post: reg *`i'`x' PRESCHOOL2 HEADSTART `age' `controls' `weight' if `sample' ==1 & `subsamp' ==1, cl($cluster)						

								loc n = `"`n'"' + `" ("`e(N)'")"'

								gl bold = ""
								est_results PRESCHOOL2
									loc pre_b  `"`pre_b' `r(co)' "'
									loc pre_se `"`pre_se' `r(se)' "'

							mi estimate, post: reg *`i'`x' CENTER PREK HEADSTART `age' `controls' `weight' if `sample' ==1 & `subsamp' ==1, cl($cluster)
								
								test _b[CENTER] == _b[PREK]						
									gl bold = ""
									if r(p) <.05	gl bold = "BOLD" 

								est_results CENTER								
									loc cen_b  `"`cen_b' `r(co)' "'
									loc cen_se `"`cen_se' `r(se)' "'

								est_results PREK
									loc pk_b  `"`pk_b' `r(co)' "'
									loc pk_se `"`pk_se' `r(se)' "'


							mi estimate, post: reg *`i'`x' PART_PK FULL_PK HEADSTART `age' `controls' `weight' if `sample' ==1 & `subsamp' ==1, cl($cluster)				
							
								test _b[PART_PK] == _b[FULL_PK]						
									gl bold = ""
									if r(p) <.05	gl bold = "BOLD" 							

								est_results PART_PK
									loc pt_b  `"`pt_b' `r(co)' "'
									loc pt_se `"`pt_se' `r(se)' "'

								est_results FULL_PK
									loc ft_b  `"`ft_b' `r(co)' "'
									loc ft_se `"`ft_se' `r(se)' "'

						} //close i loop

						di `" `n' "'

					} //close subsamp loop	


					foreach y in pre cen pk pt ft	{

						post `name' ("`y'") ``y'_b'
						post `name' ("SE") ``y'_se'
	
					} //close y loop
	
					post `name' ("N") `n' //Post sample sizes
	
				} //close x loop

				preserve
					postclose `name'
					use `file', clear				
					export excel using "${path}\Tables\Subgroups `year' `filename'", replace
				restore
				
				//log close

		end //ends program "subgroup"

		subgroup "2010" "RSCALEz MSCALEz" "ALL BLACK HISP LOWSES"  "$demog"	 "csamp1" 	"- Literacy and math"	
		subgroup "1998" "RSCALEz MSCALEz" "ALL BLACK HISP LOWSES"  "$demog"  "csamp1"   "- Literacy and math"

		subgroup "2010" "TCHEXTz TCHCONz" "ALL BLACK HISP LOWSES"  "$demog"  "bsamp1" 	"- Behavioral outcomes"
		subgroup "1998" "TCHEXTz TCHCONz" "ALL BLACK HISP LOWSES"  "$demog" "bsamp1" 	"- Behavioral outcomes"


	*********************************
	*
	* 	Moderator analysis
	*
	*********************************

		capture program drop moderators
		program moderators
			args year grade weight sample filename prescore

				use "${path}\Generated Datasets\Fade Out Final `year'", clear

				if "`grade'" == "K"		loc v = 2
				if "`grade'" == "1" 	loc v = 4

				loc outcomes = "RSCALEz MSCALEz TCHEXTz TCHCONz"
				loc wght = "[pw=`weight']"
				loc age = "X1KAGE AGE_SEPTK "

				
				loc structure 	"FULL_K COLOC SMCLASS_K " 
				loc process 	"DIDACT ADV_READ ADV_MATH KTRANS"
				loc parent 		"LIT_EXPOSE PINVOLVE PINTERACT"

				tempname name
				tempfile file
				postfile `name' str75 (model) str25 (`outcomes') using `file'

				foreach mod in `structure' `process' `parent'	{			
					
					foreach y in `outcomes' 	{
						loc fallk ""
						if "`prescore'" == "fallk"  loc fallk = "*1`y'"
				
						loc out = "`v'`y'"  //shortcut so I don't have to look at "`v'`y'" a million times

						mi estimate, post: reg  *`out' PRESCHOOL2 HEADSTART `mod' `mod'_int `fallk' `age' $demog `wght' if `sample' ==1, cl($cluster)

							loc `out'_b1: di ${fmt} _b[PRESCHOOL2] //betas
							loc `out'_b2: di ${fmt} _b[`mod']
							loc `out'_b3: di ${fmt} _b[`mod'_int]
							
							loc `out'_se1: di ${fmt} _se[PRESCHOOL2] //standard errors
							loc `out'_se2: di ${fmt} _se[`mod']
							loc `out'_se3: di ${fmt} _se[`mod'_int]
							
							loc t1 = _b[PRESCHOOL2]	/_se[PRESCHOOL2] //t values
							loc t2 = _b[`mod']		/_se[`mod']
							loc t3 = _b[`mod'_int]	/_se[`mod'_int]
						
							forvalues x = 1/3	{
								loc `out'_s`x' = ""
								
								if abs(`t`x'') >= 1.645		loc `out'_s`x' = "+" 
								if abs(`t`x'') >= 1.96  	loc `out'_s`x' = "*" 							
								if abs(`t`x'') >= 2.576 	loc `out'_s`x' = "**" 						
								if abs(`t`x'') >= 3.291	 	loc `out'_s`x' = "***" 

								loc `out'_co`x' 	"``out'_b`x''``out'_s`x''"

							} //close x loop

					} // close y loop									
			
				//Post results to a table
					forvalues i = 1/3	{
						if `i' ==1		loc coef = "PRESCHOOL"
						if `i' ==2		loc coef = "`mod'"
						if `i' ==3		loc coef = "PRESCHOOL * `mod'"

						post `name' ("`coef'") ("``v'RSCALEz_co`i''") ("``v'MSCALEz_co`i''") ("``v'TCHEXTz_co`i''") ("``v'TCHCONz_co`i''")  
							 
						post `name' ("") 	("(``v'RSCALEz_se`i'')") ("(``v'MSCALEz_se`i'')") ("(``v'TCHEXTz_se`i'')") ("(``v'TCHCONz_se`i'')")  
					
					} // close i loop
				
				} // close mod loop

		
			postclose `name'
			preserve
				use `file', clear
				export excel using "${path}\Tables/Moderator analysis `year'`filename'.xls", replace
			restore

		end //ends program "moderators"

		moderators "2010" "K" "W12T0" 	 "csampk" " - K outcomes"
		moderators "1998" "K" "BYCW0" 	 "csampk" " - K outcomes"

		moderators "2010" "1" "W4C4P_20" "csamp1" " - 1st outcomes"
		moderators "1998" "1" "C124CW0"  "csamp1" " - 1st outcomes"
