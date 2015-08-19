* Authors: Lindsey Shaughnessy (from Matt White's template - see link below) 
* Purpose: Demo HFC template for SurveyCTO Crash Course   
* Date of last revision: 2015-02-02

/*
This do-file is a VERY basic demonstration of high-frequency checks. 
It checks for duplicate IDs, and the distribution of a select-one ODK question. 

Make sure to check IPA's extensive template do file for high frequency checks, available at: 
https://ipastorage.box.com/hfc-package 

?s to researchsupport@poverty-action.org 
*/

*clear any existing data from stata 
 clear 
 
*log your results
 cap log close
 log using "8.3 hfc log.log", replace 

*set your current directory to your truecrypt container 
*noting that this is a a bad practice (use master do-file, global macro for path, and relative file paths)
 cd "???" 

*import your odk survey data 
 use "???.dta"  

*check for and display duplicate IDs 
 duplicates tag ???, generate (dup) 
 display "Displaying unique ID duplicates:"
 sort consentedid starttime 
 list consentedid starttime if dup > 0
  
*tabulate responses to your select_one fruit question, check for fair distribution 
 tab ??? 

*save and replace your checked data, and clear stata 
 save "8.2 survey data, checked.dta", replace
 
 clear 
