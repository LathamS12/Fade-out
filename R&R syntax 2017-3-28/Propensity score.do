//Purpose: Conducts propensity score estimates for the "fade out" paper
//Author: Scott Latham
//Date created: 3/21/2017

use "$path\Generated datasets\Fade out clean - appended", clear
set matsize 1000
pause on

# delimit ;

	gl ps_control1 "MALE    
				LOBWGHT CITY SUBURB NORTHEAST MIDWEST SOUTH 
				 DDROPOUT  
				  X1LESS18 X1OVER18 ";
				
	gl ps_control2 "MDROPOUT BLACK P1SINGLE P1BLENDED HISP ASIAN SESQ1 SESQ2 SESQ3 SESQ4 PREMAT1 MOMAGE1 MOMAGE2 MOMAGE3 P1NUMPLA P1CLSGRN" ;
	
# delimit cr				
	
	gl ps_missing ""
	
	foreach x in $ps_control1	{
		gen `x'_m = `x' ==.
		gl ps_missing "${ps_missing} `x'_m " //Add to the list of controls
	}
	
	//Not adding these to the list because they don't go in every model
		foreach x of varlist PRESCHOOL X?AGE AGE_SEPTK $ps_control2	{
			gen `x'_m = `x' ==.
		}
	
	di "$ps_control1"
	di "$ps_control2"
	di "$ps_missing"
	
	recode PRESCHOOL HEADSTART X?AGE AGE_SEPTK $ps_control1 $ps_control2 (.=0) 
	
	
	capture program drop ps_estimates
	program define ps_estimates
		args year outcome subgroups controls sample filename
	
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
					loc pre_b 	= "" 
					loc pre_se 	= ""
				
					loc n = ""

				foreach subsamp in `subgroups' {

					foreach i in 1 2 4 7 {

						loc age = "X`i'AGE AGE_SEPTK AGE_SEPTK_m"
						
						cap drop match* score*
						cap drop pscore
						teffects psmatch (*`i'`x') (PRESCHOOL `age' `controls') if `subsamp' ==1 & `sample' ==1 & K2010 ==`year_val', gen(score)
						
						if "`e(depvar)'" == "X1MSCALEz"	{
							teffects overlap, ptlevel(1) tlevels(0 1)
							graph export "${path}\Figures\Pscore overlap - `i' `subsamp' `year'.png", replace
						}
						
						predict pscore, ps
						
						teffects psmatch (*`i'`x') (PRESCHOOL `age' `controls') if `subsamp' ==1 & `sample' ==1 & K2010 ==`year_val' & pscore >=.2 & pscore <.8, gen(match)
								
						loc n = `"`n'"' + `" ("`e(N)'")"'

						matrix b = e(b)
						matrix V = e(V)
						
						loc b = b[1,1]
						loc se = sqrt(V[1,1])
						
						loc bround = round(`b', .01)
						loc seround = round(`se', .01)
						
						loc stars = ""
						if abs(`b'/`se') >= 1.96	loc stars "*" 
						if abs(`b'/`se') >= 2.576	loc stars "**"	
						if abs(`b'/`se') >= 3.291	loc stars "***"
						
						loc CO = `"`bround'`stars'"'
						loc SE = `"(`seround')"'
						
						loc pre_b  `"`pre_b' ("`CO'")"'
						loc pre_se `"`pre_se' ("`SE'")"'

					} //close i loop

					di `" `n' "'

				} //close subsamp loop	

				post `name' ("`y'") `pre_b'
				post `name' ("SE") `pre_se'
				
				post `name' ("N") `n' //Post sample sizes

			} //close x loop

			preserve
				postclose `name'
				use `file', clear				
				export excel using "${path}\Tables\Propensity score estimates `year' `filename'", replace
			restore

	end //ends program "ps_estimates"

	ps_estimates "2010" "RSCALEz MSCALEz" "ALL"  "$ps_control1 $ps_control2 $ps_missing"	 "a_samp3" 	"- Literacy and math (smaller bw)"	
	ps_estimates "1998" "RSCALEz MSCALEz" "ALL"  "$ps_control1 $ps_control2 $ps_missing"	 "a_samp3" 	"- Literacy and math (smaller bw)"

	ps_estimates "2010" "TCHEXTz TCHCONz" "ALL"  "$ps_control1 $ps_control2 $ps_missing"	 "a_samp3" 	"- Externalizing & self control"	
	ps_estimates "1998" "TCHEXTz TCHCONz" "ALL"  "$ps_control1 $ps_control2 $ps_missing"	 "a_samp3" 	"- Externalizing & self control"
	
	
	ps_estimates "2010" "MSCALEz_all" "ALL HISP"  "$ps_control1 $ps_control2 $ps_missing"	 "m_samp3" 	"- Literacy and math"	
	ps_estimates "1998" "MSCALEz_all" "ALL HISP"  "$ps_control1 $ps_control2 $ps_missing"	 "m_samp3" 	"- Literacy and math"
	

