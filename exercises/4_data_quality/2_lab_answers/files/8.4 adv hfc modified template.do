/*
Advanced HFC
============
Author: Christopher Boyer
Date: 18 Aug 2015
GST NH 2015

Outline:
1. Interview Completeness
2. Missing Values
3. Unique IDs Check
4. Logic Checks
5. Date Checks
6. Distribution Checks
7. Enumerator Checks
*/

clear
cd "C:\Users\cboyer.IPA\Box Sync\cboyer\global_staff_training\new_hampshire_2015\SurveyCTO\exercises\4_data_quality\2_lab_answers\files"
use "8.5 adv hfc data.dta", clear //REPLACE ??? with the data set
log using "8.6 adv hfc modified template.smcl", replace

///////////////////////////////////////////////////////////////////////////
///////////////////// Part 1: Interview Completeness //////////////////////
///////////////////////////////////////////////////////////////////////////

/* 
   Let's check that all interviews were completed.
     - If an interview has no end time, the enumerator may have stopped
       midway through the interview, or may never have started it.
*/

generate incomplete = missing(endtime)
display "Displaying incomplete interviews:"
sort id  starttime
list id  starttime r_enum if incomplete == 1

// QUESTION 1: HOW MANY INCOMPLETE INTERVIEWS ARE THERE?
// ANSWER: _____________

/* 
  Before we decide how to address the incomplete interviews, we have to get more
  information. Each incomplete interview should fall within one of three 
  distinct categories:
  (1) The incomplete interview does not have a corresponding complete
	  interview.
		 - Action: Drop the incomplete interview. Additionally, determine
		   the cause of the incomplete interview, probably discussing with
		   your field team.
  (2) The incomplete interview has a corresponding complete interview, and
	  the incomplete interview does not have a nonmissing value that
	  differs from the value of the complete interview.
		 - Action: Drop the incomplete interview. If the incomplete
		   interview was started but immediately stopped, you probably
		   don't need to follow up with your team. However, if a
		   significant portion was completed, you should determine the
		   cause of the incomplete interview.
  (3) The incomplete interview has a corresponding complete interview, but
	  the incomplete interview does have a nonmissing value that differs
	  from the value of the complete interview.
		 - Action: Work closely with your team to determine which values
		   are correct.
*/

// Possibility 1
bysort id: egen numcomplete = total(!incomplete)
display "Displaying incomplete interviews that do not have a corresponding complete interview and will be dropped:"
sort id  starttime
list id  starttime r_enum if numcomplete == 0
drop if numcomplete == 0

// Possibility 2
generate same = 1

// continuous variables
ds  starttime endtime incomplete, not
ds `r(varlist)', has(type numeric)
foreach var in `r(varlist)' {
	generate incompletemiss = incomplete & `var' == .
	bysort id incompletemiss (`var'): replace same = 0 if `var'[1] != `var'[_N]
	drop incompletemiss
}

// string variables
ds  starttime endtime incomplete, not
ds `r(varlist)', has(type string)
foreach var in `r(varlist)' {
	generate incompletemiss = incomplete & `var' == ""
	bysort id incompletemiss (`var'): replace same = 0 if `var'[1] != `var'[_N]
	drop incompletemiss
}

display "Displaying incomplete interviews that agree with their corresponding complete interview and will be dropped:"
sort id  starttime
list id  starttime r_enum if incomplete & same == 1
drop if incomplete & same == 1

* Possibility 3
display "Displaying incomplete interviews that disagree with their corresponding complete interview:"
sort id  starttime
list id  starttime r_enum if incomplete & same == 0
drop incomplete numcomplete same

// QUESTION 2: WHAT HAPPENED? WHICH CASE DID OUR INCOMPLETE INTERVIEWS FALL IN TO?
// ANSWER: _____________


///////////////////////////////////////////////////////////////////////////
//////////////////////// Part 2: Missing Values ///////////////////////////
///////////////////////////////////////////////////////////////////////////

/*
  Check that certain variables have no missing values, where missing
  indicates a skip.
  
  Examples: 
    - The unique ID, name, other identifying information, survey date
      and time variables, the consent confirmation variable.
    - A variable at the start of a section often should never be
      missing.
  
  For simplicity, we'll check numeric and string variables separately.
*/

foreach var of varlist ///
	id												/* unique ID */ ///
	starttime endtime duration	                    /* date and time variables */ ///
	consent											/* consent variable */ ///
	{
	display "Displaying interviews with missing values of `var':"
	sort id starttime
	list id starttime r_enum if `var' == .
}

/*
  Check the percentage of missing values for each variable, where missing
  indicates a skip.
*/

display "Displaying percent missing..."
quietly ds, has(type numeric)
foreach var in `r(varlist)' {
	quietly count if `var' == .
	* See -help format- for what "%5.1f" means.
	display "`var':" _column(35) string(100 * r(N) / _N, "%5.1f") "%"
}
quietly ds, has(type string)
foreach var in `r(varlist)' {
	quietly count if `var' == ""
	display "`var':" _column(35) string(100 * r(N) / _N, "%5.1f") "%"
}

// QUESTION 3: WHICH VARIABLES HAVE HIGH RATES OF MISSING RESPONSES?
// ANSWER: _____________


///////////////////////////////////////////////////////////////////////////
/////////////////////// Part 3: Unique IDs Check //////////////////////////
///////////////////////////////////////////////////////////////////////////

// Check that the unique ID is actually unique.

duplicates tag id, generate(dup)
display "Displaying unique ID duplicates:"
sort id starttime
list id starttime r_enum if dup > 0
drop dup

/*
  We could also check that a survey matches other records for its unique ID.
  Examples:
    - For a follow up survey we could check that, for each id, the name in the 
	  baseline data matches the one in the master tracking list.
	- We could check additional unique id's (govt id, ssn, etc.) that are not 
	  the survey id.
	- We could check unique combinations of variables
*/


// Now that these checks have been completed, the following command should
// be successful:

isid id


///////////////////////////////////////////////////////////////////////////
////////////////// Part 4: Routing and Logic Checks ///////////////////////
///////////////////////////////////////////////////////////////////////////

/*
  Double-check important routing instructions (skip patterns):

    In this survey, the respondent must first consent to being interview before
  proceeding with the rest of the survey. This consent is recorded in the 
  consent variable. Respondents who do not give express consent should not be 
  interviewed. This is easier to enforce with CAI, but sometimes it's good 
  practice to check anyway.
*/
display "Displaying respondents with consent violations:"
sort id
list id starttime r_enum if consent == 0 & inlist(0, missing(r_cont),  ///
                                                     missing(r_count), ///
													 missing(r_bin),   ///
													 missing(r_cat))

// QUESTION 4: ARE THERE ANY CONSENT VIOLATIONS? IF SO DROP THEM!
// ANSWER: _____________

drop if consent == 0

/* 
  You can use similar code for the following checks:
    - Double-check important hard checks.
    - If the CAI survey program calculates a field using other fields, check in
      Stata that the calculated variable is consistent with the other variables.
    - Logic checks not implemented in the CAI survey program
*/


///////////////////////////////////////////////////////////////////////////
///////////////////////// Part 5: Date Checks /////////////////////////////
///////////////////////////////////////////////////////////////////////////

* Check that interview start date and interview end date are the same.

display "Displaying unequal start and end dates:"
sort id
list id starttime endtime if dofc(starttime) != dofc(endtime)

// QUESTION 5: ARE THERE ANY DATES THAT ARE NOT THE SAME? ARE THEY REASONABLE?
// ANSWER: _____________

***************************************************************************
* Interview date should not be before the start of data collection.

* In this survey, the start of data collection was January 1, 2015.

display "Displaying interviews before the start of data collection:"
sort id
list id starttime if starttime < mdy(1, 1, 2015)


***************************************************************************
* Interview date should not be after the system date.

display "Displaying interviews after the system date:"
sort id
list id starttime if starttime > date(c(current_date), "DMYhms")


///////////////////////////////////////////////////////////////////////////
///////////////////// Part 6: Outliers/Dist. Check ////////////////////////
///////////////////////////////////////////////////////////////////////////

// a. Check that no variable has only a single distinct value.

foreach var of varlist _all {
	quietly tabulate `var'
	if r(r) == 1 {
		display "`var' has only one distinct value."
		describe `var'
	}
}

/*
  b. Check for outliers.

  You probably do not need to check for outliers for variables that have
  hard range limits (constraints) in the CAI survey program. In most cases, any
  response in this range is already considered reasonable.

  However, in this survey we didn't use any hard range limits for weekly
  income, probably a mistake. We'll check for outliers by looking for
  incomes that are 3 standard deviations from the mean.

  In general, you should not drop outliers from the data. Variation is
  exactly what we're hoping to measure, and there will likely be some
  outliers just naturally. Contact your PI for further guidance on how to
  manage outliers.
*/

egen mean = mean(r_cont)
egen sd = sd(r_cont)
generate sds = (r_cont - mean) / sd
format mean sd sds %9.2f
display "Displaying r_cont outliers:"
sort id
list id r_cont mean sd sds if abs(sds) > 3 & !missing(sds)
// code inserted here!
drop if abs(sds) > 3 & !missing(sds)
drop mean sd sds

// QUESTION 6: ARE THERE ANY OBVIOUS OUTLIERS? (IF SO DROP THEM)
// ANSWER: _____________


///////////////////////////////////////////////////////////////////////////
////////////////////// Part 7: Enumerator Checks //////////////////////////
///////////////////////////////////////////////////////////////////////////

// a. Review the enumerator comments variable.

sort id
list id starttime r_enum comment if !missing(comment)

// QUESTION 7: ARE THERE ANY CAUSES FOR CONCERN? WHAT SHOULD YOU DO?
// ANSWER: _____________

drop if comment != ""

// b. Check average interview duration by enumerator.
bysort r_enum: egen avgdur = mean(duration / 60000) // 60000 to convert to ms
egen mean = mean(duration / 60000)                      // overal avg.
generate diff = avgdur - mean                           // diff btw avg and mean
generate percdiff = 100 * diff / mean                   // % diff
egen sd = sd(duration / 60000)                          // standard dev.
generate sds = diff / sd                                // # std from mean
format avgdur mean diff percdiff sd %9.1f
format sds %9.2f
egen tag = tag(r_enum)

display "Displaying interview duration averages by r_enum:"
sort r_enum
list r_enum avgdur mean diff percdiff sd sds if tag
drop avgdur mean diff percdiff sd sds tag

// QUESTION 8: ARE THERE SIGNIFICANT DIFFERENCES IN ENUMERATOR TIMES? WHAT ARE 
//             SOME POTENTIAL REASONS FOR THESE DIFFERENCES?
// ANSWER: _____________

// note: you can use similar code to check avg section durations by enumerator.


/* 
   c. Check for unusually short or long interview durations.

   Here, we'll define "unusually short or long" as 2 standard deviations
   from the mean, knowing that this might list too many interviews.
*/
egen mean = mean(duration / 60000)
egen sd = sd(duration / 60000)
generate sds = (duration / 60000 - mean) / sd
format mean sd %9.1f
format sds %9.2f

display "Displaying unusually short or long interviews:"
sort r_enum
list r_enum duration mean sd sds if abs(sds) > 2 & !missing(sds)
drop mean sd sds

// note: use similar code to check for unusually short or long section durations.

/*
  d. Check enumerator productivity 
  
  Here we define productivity as the number of interviews completed and
  number of responses entered. Different productivity levels do not necessarily
  indicate foul play, be sure to check with field managers who can provide insights
  into geographic and cultural difficulties that can drive differences in 
  productivity. Also, note that outlier observations will affect these avgs.
  
*/
bysort r_enum: generate interviews = _N

generate nonmiss = 0
quietly ds, has(type numeric)
foreach var in `r(varlist)' {
	replace nonmiss = nonmiss + cond(`var' != ., 1, 0)
}
quietly ds, has(type string)
foreach var in `r(varlist)' {
	replace nonmiss = nonmiss + cond(`var' != "", 1, 0)
}
bysort r_enum: egen responses = total(nonmiss)
drop nonmiss

egen tag = tag(r_enum)

foreach stat in interviews responses {
	egen mean = mean(`stat')
	generate diff = `stat' - mean
	generate percdiff = 100 * diff / mean
	format mean diff percdiff %9.1f
	
	display "Displaying number of `stat' by r_enum:"
	sort r_enum
	list r_enum `stat' mean diff percdiff if tag
	drop mean diff percdiff
}

drop interviews responses tag

/*
  e. Check enumerator effects on key variables.

  At IPA HQ, we're still trying to figure out the best way to measure
  enumerator fixed effects on key variables. For instance, how do we best
  control for the fact that enumerators are often assigned to different
  enumeration areas, so differences in key variables across enumerators
  could just be due to regional differences? If you have ideas, please
  e-mail us!

  That said, the following is a start. There are no controls for
  enumeration area, etc., so you might have to take the results with a
  grain of salt. However, if you see significant fixed effects, it's
  probably cause for further investigation.
  
  NOTE: if prior to Stata 11 use xi: before regress commands
*/

regress r_cont i.r_enum
regress r_count i.r_enum
regress r_bin i.r_enum
regress r_cat i.r_enum

// QUESTION 9: ARE THERE ANY SIGNFICANT ENUMERATOR FIXED EFFECTS? WHICH VARIABLES
//             EXHIBIT SIGNIFICANT EFFECTS? WHAT COULD EXPLAIN THEM?
// ANSWER: _____________

log close






