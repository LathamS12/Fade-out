/*************************************************************
* Author: Scott Latham
* Purpose: This file calculates descriptive statistics 
* 	for students from the two ECLS-K samples	   
* 
* Created: 5/26/2014
* Last modified: 3/27/2017
*************************************************************/

	pause on

	***************************
	* Descriptives by subgroup
	***************************
		
		capture program drop subgroup_desc
		program define subgroup_desc
			args vars title extra_cond

			//List of subgroups
				loc sub "ALL LOWSES BLACK HISP "
				loc sub2 ""

				foreach x in `sub'	{
					loc sub2 = "`sub2'" + " `x'" + " `x'2"
				}

			tempname center
			tempfile file
			postfile `center' str50(label) str5(`sub2') using `file'

				loc Ns ""
					
					use "${path}\Generated Datasets\Fade out appended final (20 imp)", clear

					foreach z in `sub'	{
					
						loc toggle`z' = 0 //Create a toggle so I only record sample sizes once
					
						foreach x in `vars'	{
							
							loc `x'lab: variable label `x'
							
							mi estimate: mean `x' if a_samp3 ==1 & K2010 ==0 & `z' == 1 `extra_cond' [aw=weight_1]
								mat mean = e(b_mi)
								loc `x'_`z'_1998: di %4.2f mean[1,1]
							
							if `toggle`z'' == 0 	{
								loc n = e(N)
								loc Ns = `"`Ns'"' + `" ("`n'") "'
							}
							
							mi estimate: mean `x' if a_samp3 ==1 & K2010 ==1 & `z' == 1 `extra_cond' [aw=weight_1]
								mat mean = e(b_mi)
								loc `x'_`z'_2010: di %4.2f mean[1,1]
								
							if `toggle`z'' == 0	{
								loc n = e(N)
								loc Ns = `"`Ns'"' + `" ("`n'") "'
							}
							
							loc toggle`z' =1
							
							di `" `Ns' "'
						
						} //close x loop
					} //close z loop


				//Post header row
				# delimit ;
					post `center' ("Variable") 	("ALL_1998") 		("ALL_2010")
												("LOWSES_1998") 	("LOWSES_2010")
												("BLACK_1998") 		("BLACK_2010")
												("HISP_1998") 		("HISP_2010") ;
					# delimit cr

				foreach x in `vars'	{

					# delimit ;
					post `center' ("``x'lab'") 	("``x'_ALL_1998'") 			("``x'_ALL_2010'")
												("``x'_LOWSES_1998'") 		("``x'_LOWSES_2010'")
												("``x'_BLACK_1998'") 		("``x'_BLACK_2010'")
												("``x'_HISP_1998'") 		("``x'_HISP_2010'") ;
					# delimit cr
					
				} //close x loop 
						
				post `center' ("") `Ns' //Post sample sizes
					
			postclose `center'
			
			preserve
				use `file', clear
				export excel using "${path}\Tables/Descriptives by subgroup - `title'.xls", replace
			restore	
			
		end //ends program "subgroup_desc"
			
		subgroup_desc "PRESCHOOL2 CENTER PREK PART_PK2 FULL_PK HEADSTART NO_PRE2" "ECE"
		
		subgroup_desc "FULL_K KTRANS ADV_READ ADV_MATH ALL_SMALL_K ALL_SMALL_1 ALL_SMALL_3"  "Moderators"
		
		subgroup_desc "FULL_K KTRANS ADV_READ ADV_MATH ALL_SMALL_K ALL_SMALL_1 ALL_SMALL_3"  "Moderators (Preschool only)" "& PRESCHOOL2 ==1"
		subgroup_desc "FULL_K KTRANS ADV_READ ADV_MATH ALL_SMALL_K ALL_SMALL_1 ALL_SMALL_3"  "Moderators (No preschool only)" "& PRESCHOOL2 ==0"
		

