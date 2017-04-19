/*************************************************************
* Author: Scott Latham
* Purpose: This file cleans variables from the ECLS-K and 
* constructs variables necessary for analysis of fade out
* 
* Creates: Lots o' tables
*		   
* 
* Created: 8/14/2013
* Last modified: 4/4/2017
*************************************************************/

pause on

*********************************************************************************************************************************
	
#delimit ;

	gl demog "MALE BLACK HISP ASIAN SESQ1 SESQ2 SESQ3 SESQ4 
				LOBWGHT PREMAT1 PREMAT2 P1NUMPLA CITY SUBURB NORTHEAST MIDWEST SOUTH 
				MDROPOUT MGRDEG DDROPOUT DGRDEG MOMAGE1 MOMAGE2 MOMAGE3 
				P1SINGLE P1BLENDED P1ADOPT P1CLSGRN X1LESS18 X1OVER18 ";
				
	gl demog_all "MALE BLACK HISP ASIAN SESQ_all_1 SESQ_all_2 SESQ_all_3 SESQ_all_4 
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

		*********************
		* Full sample results
		*********************
		
		capture program drop full_samp
		program define full_samp
			args outcome controls sample filename
				
				use "$path\Generated datasets\Fade out appended final (20 imp)", clear
				set matsize 1000

				tempname name
				tempfile file
				postfile `name' str25(coef) str10(FK98 SK98 F98 T98 FK10 SK10 F10 T10) using `file'

				foreach x in `outcome' 	{

					//Initialize locals
						foreach v in pre pk cen ft pt	{
							loc `v'_b 	= "" 
							loc `v'_se 	= ""
						} // close v loop
					
						loc n = ""

					foreach year in 1998 2010 {

						if `year' == 1998	loc year_val = 0
						if `year' == 2010	loc year_val = 1

						foreach i in 1 2 4 7 {

							loc age = "X`i'AGE AGE_SEPTK"
							loc weight = "[pw=weight_`i']"
							//loc clus = "T`i'_ID" - If I want to change cluster var for diff waves (probably technically correct, but doesn't make substantive difference AT ALL)
							
							mi estimate, post: reg *`i'`x' PRESCHOOL2 HEADSTART `age' `controls' `weight' if K2010 ==`year_val' `sample', cl($cluster)	
								loc n = `"`n'"' + `" ("`e(N)'")"'

								gl bold = ""
								est_results PRESCHOOL2
									loc pre_b  `"`pre_b' `r(co)' "'
									loc pre_se `"`pre_se' `r(se)' "'

							mi estimate, post: reg *`i'`x' CENTER PREK HEADSTART `age' `controls' `weight' if K2010 ==`year_val' `sample', cl($cluster)
								
								test _b[CENTER] == _b[PREK]						
									gl bold = ""
									if r(p) <.05	gl bold = "BOLD" 

								est_results CENTER								
									loc cen_b  `"`cen_b' `r(co)' "'
									loc cen_se `"`cen_se' `r(se)' "'

								est_results PREK
									loc pk_b  `"`pk_b' `r(co)' "'
									loc pk_se `"`pk_se' `r(se)' "'


							mi estimate, post: reg *`i'`x' PART_PK2 FULL_PK HEADSTART `age' `controls' `weight' if K2010 ==`year_val' `sample', cl($cluster)				
							
								test _b[PART_PK2] == _b[FULL_PK]						
									gl bold = ""
									if r(p) <.05	gl bold = "BOLD" 							

								est_results PART_PK2
									loc pt_b  `"`pt_b' `r(co)' "'
									loc pt_se `"`pt_se' `r(se)' "'

								est_results FULL_PK
									loc ft_b  `"`ft_b' `r(co)' "'
									loc ft_se `"`ft_se' `r(se)' "'
						
						} //close i loop

						di `" `n' "'

					} //close year loop	

					foreach y in pre cen pk pt ft	{

						post `name' ("`y'") ``y'_b'
						post `name' ("SE") ``y'_se'
	
					} //close y loop
	
					post `name' ("N") `n' //Post sample sizes
	
				} //close x loop

				gl bold = "" //Making sure this doesn't carry over to any other analysis
				
				preserve
					postclose `name'
					use `file', clear				
					export excel using "${path}\Tables\Full sample `filename'", replace
				restore

		end //ends program "full_samp"

		full_samp "RSCALEz MSCALEz" "$demog"  "& a_samp3 ==1" 	"- Literacy and math"	
		full_samp "TCHEXTz TCHCONz"	"$demog"  "& b_samp3 ==1" 	"- Externalizing & self-control"
		
		full_samp "RSCALEz_all MSCALEz_all" "$demog"  "" 	"- Literacy and math (all available students)"	//Specification check - what if we don't limit to fixed sample?
		full_samp "TCHEXTz_all TCHCONz_all"	"$demog"  "" 	"- Externalizing & self-control (all available students)"
		
	
	************************
	* Separately by subgroup
	************************
		capture program drop subgroup
		program define subgroup
			args year outcome subgroups controls sample filename
				
				use "$path\Generated datasets\Fade out appended final (20 imp - 2)", clear
				set matsize 1000
				
				if `year' == 1998	loc year_val = 0
				if `year' == 2010	loc year_val = 1

				loc postgroups "" //Initialize postfile columns
				foreach x in `subgroups'	{
					loc postgroups "`postgroups' `x'1 `x'2 `x'4 `x'7" 
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

						foreach i in 1 2 4 7 {

							loc age = "X`i'AGE AGE_SEPTK"
							loc weight = "[pw=weight_`i']"

							mi estimate, post: reg *`i'`x' PRESCHOOL2 HEADSTART `age' `controls' `weight' if `sample' ==1 & `subsamp' ==1 & K2010 ==`year_val', cl($cluster)	

								loc n = `"`n'"' + `" ("`e(N)'")"'

								gl bold = ""
								est_results PRESCHOOL2
									loc pre_b  `"`pre_b' `r(co)' "'
									loc pre_se `"`pre_se' `r(se)' "'

							mi estimate, post: reg *`i'`x' CENTER PREK HEADSTART `age' `controls' `weight' if `sample' ==1 & `subsamp' ==1 & K2010 ==`year_val', cl($cluster)
								
								test _b[CENTER] == _b[PREK]						
									gl bold = ""
									if r(p) <.05	gl bold = "BOLD" 

								est_results CENTER								
									loc cen_b  `"`cen_b' `r(co)' "'
									loc cen_se `"`cen_se' `r(se)' "'

								est_results PREK
									loc pk_b  `"`pk_b' `r(co)' "'
									loc pk_se `"`pk_se' `r(se)' "'


							mi estimate, post: reg *`i'`x' PART_PK2 FULL_PK HEADSTART `age' `controls' `weight' if `sample' ==1 & `subsamp' ==1 & K2010 ==`year_val', cl($cluster)				
							pause
								test _b[PART_PK2] == _b[FULL_PK]						
									gl bold = ""
									if r(p) <.05	gl bold = "BOLD" 							

								est_results PART_PK2
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

				gl bold "" //Making sure this doesn't carry over to any other analysis
				
				preserve
					postclose `name'
					use `file', clear				
					export excel using "${path}\Tables\Subgroups `year' `filename'", replace
				restore

		end //ends program "subgroup"

		subgroup "2010" "RSCALEz MSCALEz" " BLACK HISP LOWSES"  "$demog"	 "a_samp3" 	"- Literacy and math"	
		subgroup "1998" "RSCALEz MSCALEz" "LOWSES BLACK HISP"  "$demog"  "a_samp3"  "- Literacy and math" 		
		
		subgroup "2010" "MSCALEz_2" "HISP "  "$demog"	"m_samp3" 	"- Math (Hispanic sample)"	//Sample of kids who had math outcomes (includes kids who failed English screener)
		subgroup "1998" "MSCALEz_2" "HISP "  "$demog"	"m_samp3" 	"- Math (Hispanic sample)"	
			
		subgroup "2010" "TCHEXTz TCHCONz" "LOWSES BLACK HISP"  "$demog"  "b_samp3" 	"- Behavioral outcomes"
		subgroup "1998" "TCHEXTz TCHCONz" "LOWSES BLACK HISP"  "$demog"  "b_samp3" 	"- Behavioral outcomes"

		//Specification checks - what if we include all available observations?
			subgroup "2010" "RSCALEz_all MSCALEz_all" "ALL LOWSES_all BLACK HISP"  "$demog_all"	 "" 	"- Literacy and math (all available obs)"
			subgroup "1998" "RSCALEz_all MSCALEz_all" "ALL LOWSES_all BLACK HISP"  "$demog_all"	 "" 	"- Literacy and math (all available obs)"
					
			subgroup "2010" "TCHEXTz_all TCHCONz_all" "ALL LOWSES_all BLACK HISP"  "$demog_all"  "" 	"- Behavioral outcomes (all available obs)"
			subgroup "1998" "TCHEXTz_all TCHCONz_all" "ALL LOWSES_all BLACK HISP"  "$demog_all"  "" 	"- Behavioral outcomes (all available obs)"
		
	
	
	*********************************
	*
	* 	Moderator analysis
	*
	*********************************

	gl mods "FULL_K KTRANS ADV_READ ADV_MATH ALL_SMALL_K ALL_SMALL_1 ALL_SMALL_3"
	
	//Main effects of moderators
		capture program drop mods_ME
		program define mods_ME
			args outcome controls sample filename
				
				use "$path\Generated datasets\Fade out appended final (20 imp)", clear
				set matsize 1000

				tempname name
				tempfile file
				postfile `name' str25(coef) str10(SK98 F98 T98 SK10 F10 T10) using `file'

				foreach x in `outcome' 	{
				
					foreach mod in ${mods}	{
						loc `mod'_b ""
						loc `mod'_se ""
						loc n = ""
						
						foreach year in 1998 2010 {

							if `year' == 1998	loc year_val = 0
							if `year' == 2010	loc year_val = 1
							
							foreach i in 2 4 7	{
							
								loc age = "X`i'AGE AGE_SEPTK"
								loc weight = "[pw=weight_`i']"

								mi estimate, post: reg *`i'`x' `mod' `age' `controls' `weight' if K2010 ==`year_val' `sample', cl($cluster)	
									loc n = `"`n'"' + `" ("`e(N)'")"'

									est_results `mod'
										loc `mod'_b  `"``mod'_b' `r(co)' "'
										loc `mod'_se `"``mod'_se' `r(se)' "'
									
									di "`mod'"
									di `" ``mod'_b' "'
									di `" ``mod'_se' "'
						

							} //close i loop
							di `" `n' "'

						} //close year loop	

						post `name' ("`mod'")	``mod'_b'
						post `name' ("") 		``mod'_se'
		
					} //close mod loop
	
					post `name' ("N") `n' //Post sample sizes
	
				} //close x loop

				preserve
					postclose `name'
					use `file', clear				
					export excel using "${path}\Tables\Moderator main effects `filename'", replace
				restore

		end //ends program "mods_ME"
		
		mods_ME "RSCALEz MSCALEz" "$demog"  "& a_samp3 ==1" 	"- Literacy and math"
		

			
	//Interactions w/preschool
		capture program drop mod_analysis
		program mod_analysis
			args grade controls sample filename prescore

				use "${path}\Generated Datasets\Fade out appended final (20 imp)", clear

				if "`grade'" == "K"		loc v = 2
				if "`grade'" == "1" 	loc v = 4
				if "`grade'" == "3" 	loc v = 7

				loc outcomes = "X`v'RSCALEz X`v'MSCALEz X`v'TCHEXTz X`v'TCHCONz"
				loc weight = "[pw=weight_`v']"
				loc age = "X`v'AGE AGE_SEPTK "

				tempname name
				tempfile file
				postfile `name' str25 (model) str10(`outcomes') using `file'

				foreach mod in $mods	{			
					
					foreach dv in `outcomes' 	{
						//loc fallk ""
						//if "`prescore'" == "fallk"  loc fallk = "*1`y'"
	
						mi estimate, post: reg  `dv' PRESCHOOL2 HEADSTART `mod' `mod'_int `age' `controls' `weight' `sample', cl($cluster)
							
							loc `dv'_n "`e(N)'"  //Saves over for every moderator but sample should be identical across mods

							est_results PRESCHOOL2
								loc `dv'_`mod'_pre_co = `r(co)'
								loc `dv'_`mod'_pre_se = `r(se)'							
							
							est_results `mod'
								loc `dv'_`mod'_main_co = `r(co)'
								loc `dv'_`mod'_main_se = `r(se)'
										
							est_results `mod'_int
								loc `dv'_`mod'_int_co = `r(co)'
								loc `dv'_`mod'_int_se = `r(se)'

					} // close dv loop									
			
				//Post results to a table
					foreach type in pre main int	{						
						loc mtype "`mod'_`type'" //To keep the length of the postfile lines manageable

						post `name' ("`mod' `type'") ("`X`v'RSCALEz_`mtype'_co'") ("`X`v'MSCALEz_`mtype'_co'") ("`X`v'TCHEXTz_`mtype'_co'") ("`X`v'TCHCONz_`mtype'_co'")  						 
						post `name' ("") 			 ("`X`v'RSCALEz_`mtype'_se'") ("`X`v'MSCALEz_`mtype'_se'") ("`X`v'TCHEXTz_`mtype'_se'") ("`X`v'TCHCONz_`mtype'_se'") 
					
					} // close type loop		
				} // close mod loop
				
				post `name' ("N") ("`X`v'RSCALEz_n'") ("`X`v'MSCALEz_n'") ("`X`v'TCHEXTz_n'") ("`X`v'TCHCONz_n'")
					
			postclose `name'
			
			preserve
				use `file', clear
				export excel using "${path}\Tables/Moderator analysis `filename'.xls", replace
			restore

		end //ends program "mod_analysis"
		
		mod_analysis "K" "$demog"	"if a_samp3==1 & K2010 ==0" " - K outcomes (1998)"
		mod_analysis "K" "$demog"	"if a_samp3==1 & K2010 ==1" " - K outcomes (2010)"
		
		mod_analysis "1" "$demog"	"if a_samp3==1 & K2010 ==0" " - 1st outcomes (1998)"
		mod_analysis "1" "$demog"	"if a_samp3==1 & K2010 ==1" " - 1st outcomes (2010)"
		
		mod_analysis "3" "$demog"	"if a_samp3==1 & K2010 ==0" " - 3rd outcomes (1998)"
		mod_analysis "3" "$demog"	"if a_samp3==1 & K2010 ==1" " - 3rd outcomes (2010)"
		
		*******************************************************************************
		
		//Figures showing comparisons across cohorts
		*********************************************
	/*	
		
		use "$path\Generated datasets\Fade out appended final (20 imp)", clear
			
		foreach i in 1 2 4 7	{
		
			loc age = "X`i'AGE AGE_SEPTK"
			loc weight = "[pw=weight_`i']"
							
			mi estimate, post: reg X`i'RSCALEz PRESCHOOL2 HEADSTART `age' $demog `weight' if  a_samp3 ==1 & K2010==0, cl(${cluster})
			estimates store wave`i'_98
			
			mi estimate, post: reg X`i'RSCALEz PRESCHOOL2 HEADSTART `age' $demog `weight' if  a_samp3 ==1 & K2010==1, cl(${cluster})
			estimates store wave`i'_10	
	
			foreach x in 98 10	{
			
				if `i' ==1	loc lab "Fall K"
				if `i' ==2 	loc lab "Spring K"
				if `i' ==4	loc lab "Spring 1st"
				if `i' ==7	loc lab "Spring 3rd"
				
				loc w`i'_`x' = "wave`i'_`x', label(`lab')"
				loc w`i'`x' =  "wave`i'_`x'"
			}
		}
		
	
		coefplot 	(`w1_98') (`w2_98') (`w4_98') (`w7_98'), bylabel(1998) || ///
					(`w110') (`w210') (`w4_10') (`w7_10'), bylabel(2010) ||,  /// 
						keep(PRESCHOOL2) xline(0) xtitle(Effect size) ///
						 mlabel format(%3.2f) mlabposition(12) mlabgap(*2) ///
						 ci(95) ciopts(recast(rcap)) citop	///
						 coeflabels(PRESCHOOL2 = "Preschool coefficients")
	
		graph export "${path}\Tables\Sample 1.pdf"
		
		coefplot 	(`w1_98') (`w2_98') (`w4_98') (`w7_98'), bylabel(1998) || ///
					(`w110') (`w210') (`w4_10') (`w7_10'), bylabel(2010) ||,  /// 
						keep(PRESCHOOL2) yline(0) ytitle(Effect size)  ///
						 mlabel format(%3.2f) mlabposition(9) mlabgap(*2) ///
						 vertical ci(95) ciopts(recast(rcap)) citop	///
						 coeflabels(PRESCHOOL2 = "Preschool coefficients")
		graph export "${path}\Tables\Sample 2.pdf"
		
		coefplot 	(`w1_98') (`w2_98') (`w4_98') (`w7_98'), bylabel(1998) || ///
					(`w110') (`w210') (`w4_10') (`w7_10'), bylabel(2010) ||,  /// 
						keep(PRESCHOOL2) yline(0) ytitle(Effect size)  ///
						 recast(bar) barwidth(.125) fcolor(*.5) ///
						 vertical ci(95) ciopts(recast(rcap)) citop	///
						 coeflabels(PRESCHOOL2 = "Preschool coefficients") ///
						 
		graph export "${path}\Tables\Sample 3.pdf"
	*/	

		use "$path\Generated datasets\Fade out appended final (20 imp)", clear
		
			mi passive: gen PRESCHOOL2_1 = CENTER+PREK
			mi passive: gen PRESCHOOL2_2 = CENTER+PREK
			mi passive: gen PRESCHOOL2_4 = CENTER+PREK
			mi passive: gen PRESCHOOL2_7 = CENTER+PREK

		cap program drop coef_comp	
		program coef_comp
			args dv 
		
			//use "$path\Generated datasets\Fade out appended final ", clear
		
			foreach subsamp in ALL LOWSES BLACK HISP	{
			
				if "`subsamp'" =="ALL"		loc subtit = "All children"
				if "`subsamp'" =="LOWSES"	loc subtit = "Low SES children"
				if "`subsamp'" =="BLACK"	loc subtit = "Black children"
				if "`subsamp'" =="HISP"		loc subtit = "Hispanic children"
				
				foreach i in 1 2 4 7	{
				
					loc age = "X`i'AGE AGE_SEPTK"
					loc weight = "[pw=weight_`i']"
									
					mi estimate, post: reg X`i'`dv' PRESCHOOL2_`i' HEADSTART `age' $demog `weight' if  a_samp3 ==1 & `subsamp'==1 & K2010==0, cl(${cluster})
					estimates store wave`i'_98_`subsamp'
					
					mi estimate, post: reg X`i'`dv' PRESCHOOL2_`i' HEADSTART `age' $demog `weight' if  a_samp3 ==1 & `subsamp'==1 & K2010==1, cl(${cluster})
					estimates store wave`i'_10_`subsamp'
					
					foreach x in 98 10	{
					
						if `i' ==1	loc lab "Fall K"
						if `i' ==2 	loc lab "Spring K"
						if `i' ==4	loc lab "Spring 1st"
						if `i' ==7	loc lab "Spring 3rd"
						
						loc w`i'_`x'_`subsamp' = "wave`i'_`x'_`subsamp', label(`lab')"
						loc w`i'`x'_`subsamp' =  "wave`i'_`x'_`subsamp'"
						
					} //Ends x loop
				} //Ends i loop
			
				coefplot 	(`w1_98_`subsamp'') (`w2_98_`subsamp'') (`w4_98_`subsamp'') (`w7_98_`subsamp''), bylabel(1998)  || ///
							(`w110_`subsamp'') (`w210_`subsamp'') (`w4_10_`subsamp'') (`w7_10_`subsamp''), bylabel(2010) ||,  /// 
								keep(PRESCHOOL2_?) vertical offset(0) nokey  ///
								yline(0, lcolor(gs9)) ytitle(Effect size) yscale(range(-.2 .5)) ylabel(-.2(.2).4) xlabel(,labsize(small) angle(forty_five)) ///
								mlabel mlabcolor(black) mcolor(black) format(%3.2f) mlabposition(9) mlabgap(*0) ///
								ci(95) citop ciopts(recast(rcap) lcolor(black))    ///
								coeflabels(PRESCHOOL2_1 = "Fall K" PRESCHOOL2_2 = "Spring K" PRESCHOOL2_4 = "Spring 1st" PRESCHOOL2_7 = "Spring 3rd") ///
								title("`subtit'") saving("`subsamp'", replace)

			} //Ends subsamp loop
			
				graph combine "ALL" "LOWSES" "BLACK" "HISP"
				
				pause
			graph export "${path}\Figures\Coefficient comparisons - `title' `dv'.png", replace
			
		end //Ends program coef_comp
		
		coef_comp RSCALEz  	//Have to manually fix titles and delete leading zeroes	
		coef_comp MSCALEz 
	
