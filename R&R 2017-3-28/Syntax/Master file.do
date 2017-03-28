/*************************************************************
* Author: Scott Latham
* Purpose: This is a master file for the Fade out project
*
*		   
* Created: 	5/24/2015
* Last modified: 3/7/2017
*************************************************************/

version 13.1

gl path "Z:\save here\Scott Latham\Fade out"
gl data "Z:\save here\Scott Latham\ECLS-K data"


do "${path}\Syntax\Variable selection"
do "${path}\Syntax\Data cleaning"
do "${path}\Syntax\Missing data"
