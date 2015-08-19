/*
This do-file provides sample code for high-frequency checks listed in "CAI
high-frequency checks 03.20.2012.docx."

While the code below can serve as a guide for your own, it is ultimately
your responsibility to ensure that there are no errors in your code. Never
use code that you do not understand.

Contact Matthew White, IPA Data Coordinator, with questions.

Outline:
1. Routing and logic checks, part 1
2. Unique ID checks
3. Routing and logic checks, part 2
4. Date checks, part 1
5. Data flow checks
6. Distribution checks
7. Enumerator checks
8. Other checks
9. Date checks, part 2
*/

version 10

use survey_data, clear

/*
Description of the dataset:

              storage  display     value
variable name   type   format      label      variable label
------------------------------------------------------------
id              byte   %8.0g                  Unique ID
idreentry       byte   %8.0g                  Unique ID reentry
startdate       int    %td..                  Interview start date
starttime       long   %tc..                  Interview start time
duration        float  %tcHH:MM               Interview duration
enddate         int    %td..                  Interview end date
endtime         long   %tc..                  Interview end time
enumerator      byte   %8.0g       enumerator
                                              Enumerator
consent         byte   %10.0g      yesno      Consent administered?
name            str17  %17s                   Name
firstname       str7   %9s                    First name
lastname        str11  %11s                   Last name
govtid          str10  %10s                   Government ID
city            str15  %15s                   City
enumarea        byte   %10.0g      dkrf       Enumeration area
sex             byte   %10.0g      sex        Sex
age             byte   %10.0g      dkrf       Age
pregnant        byte   %10.0g      yesno      Respondent is pregnant
nativelang      byte   %10.0g      language   Native language
nativelang_spec str5   %9s                    Native language (specify)
wklyinc         int    %10.0g      dkrf       Weekly income
hhsize          byte   %10.0g      dkrf       Household size
primaryinc      byte   %10.0g      dkrf       Primary source of income for the household
testscore       byte   %9.0g                  Test score
comments        str52  %52s                   Enumerator comments
------------------------------------------------------------

For numeric variables, "don't know" (DK) is the extended missing value .a,
and "refusal" (RF) is .b. For string variables, DK is "don't know", and RF
is "refusal". See -help missing- for more on extended missing values.
*/


***************************************************************************
*********************ROUTING AND LOGIC CHECKS, PART 1**********************
***************************************************************************

* Check that all interviews were completed.
* Example: If an interview has no end time, the enumerator may have stopped
* midway through the interview, or may never have started it.

generate incomplete = missing(endtime)
display "Displaying incomplete interviews:"
sort id startdate starttime
list id startdate starttime enumerator if incomplete == 1

* There are two incomplete interviews: id 3 and id 6. Before we decide how
* to address them, we have to get more information. For each, there are three
* possibilities:
* (1) The incomplete interview does not have a corresponding complete
*	  interview.
*		 - Action: Drop the incomplete interview. Additionally, determine
*		   the cause of the incomplete interview, probably discussing with
*		   your field team.
* (2) The incomplete interview has a corresponding complete interview, and
*	  the incomplete interview does not have a nonmissing value that
*	  differs from the value of the complete interview.
*		 - Action: Drop the incomplete interview. If the incomplete
*		   interview was started but immediately stopped, you probably
*		   don't need to follow up with your team. However, if a
*		   significant portion was completed, you should determine the
*		   cause of the incomplete interview.
* (3) The incomplete interview has a corresponding complete interview, but
*	  the incomplete interview does have a nonmissing value that differs
*	  from the value of the complete interview.
*		 - Action: Work closely with your team to determine which values
*		   are correct.

* Possibility 1
* ! is the logical not operator.
bysort id: egen numcomplete = total(!incomplete)
display "Displaying incomplete interviews that do not have a corresponding complete interview and will be dropped:"
sort id startdate starttime
list id startdate starttime enumerator if numcomplete == 0
drop if numcomplete == 0

* Possibility 2
* Drop incomplete interviews with a corresponding complete interview if for
* all variables other than survey dates and times, the complete interview
* and all corresponding incomplete interviews with a nonmissing value
* agree.
* If you're confused by the use of -bysort- below, a great short tutorial
* is "Speaking Stata: How to move step by: step," available here:
* http://www.stata-journal.com/sjpdf.html?articlenum=pr0004
generate same = 1
* For simplicity, we'll loop through numeric and string variables
* seperately.
ds startdate starttime enddate endtime incomplete, not
ds `r(varlist)', has(type numeric)
foreach var in `r(varlist)' {
	generate incompletemiss = incomplete & `var' == .
	bysort id incompletemiss (`var'): replace same = 0 if `var'[1] != `var'[_N]
	drop incompletemiss
}
ds startdate starttime enddate endtime incomplete, not
ds `r(varlist)', has(type string)
foreach var in `r(varlist)' {
	generate incompletemiss = incomplete & `var' == ""
	bysort id incompletemiss (`var'): replace same = 0 if `var'[1] != `var'[_N]
	drop incompletemiss
}
display "Displaying incomplete interviews that agree with their corresponding complete interview and will be dropped:"
sort id startdate starttime
list id startdate starttime enumerator if incomplete & same == 1
drop if incomplete & same == 1

* Possibility 3
display "Displaying incomplete interviews that disagree with their corresponding complete interview:"
sort id startdate starttime
list id startdate starttime enumerator if incomplete & same == 0
drop incomplete numcomplete same


***************************************************************************
* Check that certain variables have no missing values, where missing
* indicates a skip.
* Examples: The unique ID, name, other identifying information, survey date
* and time variables, the consent confirmation variable.
* Example: A variable at the start of a section often should never be
* missing.

* For simplicity, we'll check numeric and string variables separately.

* See -help comments- on the syntax here.
foreach var of varlist ///
	id												/* unique ID */ ///
	sex age											/* other identifying information */ ///
	startdate starttime enddate endtime duration	/* date and time variables */ ///
	consent											/* consent variable */ ///
	hhsize											/* section start */ ///
	{
	display "Displaying interviews with missing values of `var':"
	sort id startdate starttime
	list id startdate starttime enumerator if `var' == .
}

foreach var of varlist ///
	name govtid	city								/* other identifying information */ ///
	{
	display "Displaying interviews with missing values of `var':"
	sort id startdate starttime
	list id startdate starttime enumerator if `var' == ""
}


***************************************************************************
*****************************UNIQUE ID CHECKS******************************
***************************************************************************

* Check that the unique ID is actually unique.

duplicates tag id, generate(dup)
display "Displaying unique ID duplicates:"
sort id startdate starttime
list id startdate starttime enumerator if dup > 0
drop dup


***************************************************************************
* Check that other variables that should be unique are actually unique.
* Example: government ID.

duplicates tag govtid if govtid != "don't know" & govtid != "refusal", generate(dup)
display "Displaying government ID duplicates:"
sort govtid id startdate starttime
list id govtid name sex age city if dup > 0 & dup != .
drop dup

* A93057 is a duplicate government ID. However, it looks like these are two
* different respondents. We should immediately follow up with the
* enumerators or their supervisors to make sure this was recorded
* correctly.


***************************************************************************
* Review observations with duplicate values of a variable for which
* duplicates are uncommon: These may be the same respondent.
* Example: duplicates by name.

duplicates tag name, generate(dup)
display "Displaying duplicates by name:"
sort name id startdate starttime
list id name govtid sex age city if dup > 0
drop dup

* "John Walker" is a duplicate name. However, it looks like these are two
* different respondents, so there's no need to follow up with the
* enumerators or surveyors.


***************************************************************************
* Check that a survey matches other records for its unique ID.
* Example: For each ID, check that the name in the baseline data matches
* the one in the master tracking list.

merge id using master_tracking_list, sort uniqusing
drop if _merge == 2
drop _merge
display "Displaying discrepancies with the master tracking list:"
sort id startdate starttime
list id name tracking_name startdate starttime enumerator if name != tracking_name
drop tracking_name tracking_firstname tracking_lastname

* It looks like respondent Richard Brent with id 8 has an incorrect value
* of id in the survey data. After reviewing the master tracking list and
* discussing with the field team, we figure out that this was supposed to
* be id 9, and make the change in the data. Note how multiple variables are
* used to identify the observations to make sure other observations are not
* accidentally modified.

* Note: Data modifications usually occur before the check. See
* general_tips.do.

replace id = 9 if id == 8 & startdate == mdy(1, 30, 2012) & starttime == hms(16, 57, 51)

* Now that these checks have been completed, the following command should
* be successful:

isid id


***************************************************************************
*********************ROUTING AND LOGIC CHECKS, PART 2**********************
***************************************************************************

* Check that no variables have only missing values, where missing indicates
* a skip. This could mean that the routing of the CAI survey program was
* incorrectly programmed.

quietly ds, has(type numeric)
foreach var in `r(varlist)' {
	quietly count if `var' == .
	if r(N) == _N {
		display "`var' has only missing values."
		describe `var'
	}
}
quietly ds, has(type string)
foreach var in `r(varlist)' {
	quietly count if `var' == ""
	if r(N) == _N {
		display "`var' has only missing values."
		describe `var'
	}
}


***************************************************************************
* Double-check important routing instructions (skip patterns).

* In this survey, the field pregnant is asked if and only if sex == 2.
* Here, this isn't a particularly important skip pattern, so you probably
* wouldn't actually check it in Stata. Nonetheless, we'll use it as an
* example.

display "Displaying female respondents with a missing pregnant response:"
sort id
list id startdate enumerator if sex == 2 & pregnant == .

display "Displaying male respondents with a nonmissing pregnant response:"
sort id
list id startdate enumerator if sex == 1 & pregnant != .

* Oops! Looks like the CAI programmer messed up.

* You can use similar code for the following checks:

* Double-check important hard checks.

* If the CAI survey program calculates a field using other fields, check in
* Stata that the calculated variable is consistent with the other variables.

* Logic checks not implemented in the CAI survey program


***************************************************************************
****************************DATE CHECKS, PART 1****************************
***************************************************************************

* Check that interview start date and interview end date are the same.

display "Displaying unequal start and end dates:"
sort id
list id startdate starttime enddate endtime if startdate != enddate


***************************************************************************
* Interview date should not be before the start of data collection.

* In this survey, the start of data collection was January 1, 2012.

display "Displaying interviews before the start of data collection:"
sort id
list id startdate if startdate < mdy(1, 1, 2012)


***************************************************************************
* Interview date should not be after the system date.

display "Displaying interviews after the system date:"
sort id
list id startdate if startdate > date(c(current_date), "DMY")


***************************************************************************
* Within the same enumeration area, interview dates should be close to the
* same date.

bysort enumarea: egen mindate = min(startdate)
by enumarea: egen maxdate = max(startdate)
display "Displaying interviews in the same enumeration area more than four days apart:"
sort enumarea startdate id
list id enumarea startdate if maxdate > mindate + 4
drop mindate maxdate


***************************************************************************
*****************************DATA FLOW CHECKS******************************
***************************************************************************

* Check that the list of imported surveys is consistent with the field
* tracking list.

* Check that the list of imported surveys is consistent with the consent
* forms turned in.

* If enumerators complete CAI assignment reports, check that the list of
* imported surveys is consistent with their reports.

* The code for these data flow checks is similar to that of this unique ID
* check:

* Check that a survey matches other records for its unique ID.
* Example: For each ID, check that the name in the baseline data matches
* the one in the master tracking list.


***************************************************************************
****************************DISTRIBUTION CHECKS****************************
***************************************************************************

* Check that no variable has only a single distinct value.

foreach var of varlist _all {
	quietly tabulate `var'
	if r(r) == 1 {
		display "`var' has only one distinct value."
		describe `var'
	}
}


***************************************************************************
* Check the percentage of missing values for each variable, where missing
* indicates a skip.

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


***************************************************************************
* Check the percentage of "don't know" (DK) and "refusal" (RF) values for
* each variable.

* If a dataset's "don't know" and "refusal" values are inconsistently
* coded, contact the IPA Data Coordinator for code that automatically
* recodes them consistently.

display "Displaying percent DK/RF..."
foreach var of varlist _all {
	display "`var':"
	
	capture confirm numeric variable `var'
	if _rc == 0 {
		quietly count if `var' != .
		local nonmiss = r(N)
		quietly count if `var' == .a
		local dkn = r(N)
		quietly count if `var' == .b
		local rfn = r(N)
	}
	else {
		quietly count if `var' != ""
		local nonmiss = r(N)
		quietly count if `var' == "don't know"
		local dkn = r(N)
		quietly count if `var' == "refusal"
		local rfn = r(N)
	}
	
	display "  DK  " string(100 * `dkn' / `nonmiss', "%5.1f") "%"
	display "  RF  " string(100 * `rfn' / `nonmiss', "%5.1f") "%"
}

* Now, you probably don't need to see all these low DK/RF rates. The
* code below will display the DK/RF rates of a variable only if one of the
* following is true:
* (1) The DK rate is at least 2.5%.
* (2) The RF rate is at least 2.5%.
* (3) A single enumerator had at least three DK or RF responses.

display "Displaying percent DK/RF..."
foreach var of varlist _all {
	capture confirm numeric variable `var'
	if _rc == 0 {
		scalar miss = .
		scalar dk = .a
		scalar rf = .b
	}
	else {
		scalar miss = ""
		scalar dk = "don't know"
		scalar rf = "refusal"
	}
	
	quietly count if `var' != miss
	local nonmiss = r(N)
	quietly count if `var' == dk
	local dkn = r(N)
	local dkrate = `dkn' / `nonmiss'
	quietly count if `var' == rf
	local rfn = r(N)
	local rfrate = `rfn' / `nonmiss'
	
	bysort enumerator: egen totdkrf = total(inlist(`var', dk, rf))
	quietly count if totdkrf >= 3
	
	if `dkrate' >= 0.025 | `rfrate' >= 0.025 | r(N) > 0 {
		describe `var'
		display "DK:  " string(100 * `dkrate', "%5.1f") "%"
		display "RF:  " string(100 * `rfrate', "%5.1f") "%"
		tabulate enumerator `var' if inlist(`var', dk, rf) == 1, missing
	}
	
	drop totdkrf
}


***************************************************************************
* Check the percentage of other/specify values for each variable that
* allows this response.

* How to implement this check depends on the specifics of the other/specify
* variables in your dataset.

* Ideally, other/specify variables have the same name as their associated
* variable, but with a suffix. This is the case in this dataset, where the
* suffix is "_spec".

* In this scenario, you can use the following code:

display "Displaying percent other/specify..."
foreach varspec of varlist *_spec {
	* `var' is the name of the variable associated with the other/specify
	* variable.
	local var = regexr("`varspec'", "_spec$", "")
	quietly count if `var' != .
	local nonmiss = r(N)
	* !missing(`varspec') is the same as missing(`varspec') == 0, and is
	* one of Stata's recommended tests for nonmissing values. See
	* -help missing- for more details.
	quietly count if !missing(`varspec')
	display "`var':" _column(35) string(100 * r(N) / `nonmiss', "%5.1f") "%"
}

* Alternatively, if "other" has a unique value (as .a is DK's unique
* value), you can use similar code to that of the DK/RF check.

* Even if "other" doesn't have a unique value, as long as all variables
* that allow an other/specify response use the same value label text for
* the response, you can implement a similar check. In this dataset, all
* "other" responses have the value label text "other".

display "Displaying percent other/specify..."
quietly ds, has(type numeric)
foreach var in `r(varlist)' {
	local label : value label `var'
	if "`label'" != "" {
		quietly label list `label'
		local max = r(max)
		generate teststr = "other"
		encode teststr, generate(testnum) label(`label')
		if testnum[1] <= `max' & !missing(testnum[1]) {
			decode `var', generate(decoded)
			quietly count if decoded != ""
			local nonmiss = r(N)
			quietly count if decoded == "other"
			display "`var':" _column(35) string(100 * r(N) / `nonmiss', "%5.1f") "%"
			drop decoded
		}
		
		drop teststr testnum
	}
}


***************************************************************************
* Review other/specify values to check that other/specify isn't being
* entered when other responses should be.

foreach var of varlist *_spec {
	egen tag = tag(`var')
	display "Displaying other/specify values of `var':"
	sort `var'
	list `var' if tag
	drop tag
}

* If a value is being truncated because it is too long, use option -notrim-
* of -list-.


***************************************************************************
* If the CAI survey program imposes hard range limits on a field, check
* that some limits have not been met. If a limit has been met, consider
* changing it in the CAI survey program.

* Plan: The dataset CAI_program_limits.dta contains the maximum allowed
* values of number variables. Use this dataset to check whether any
* variable in survey_data.dta has reached its maximum allowed value.

preserve

use CAI_program_limits, clear
putmata variable max, replace
local limits = _N

restore

forvalues i = 1/`limits' {
	mata: st_local("var", variable[`i', 1])
	mata: st_local("max", strofreal(max[`i', 1]))
	quietly count if `var' == `max'
	if r(N) > 0 {
		display "`var' has reached its maximum allowed value:"
		sort id
		list id `var' if `var' == `max'
	}
}

* You might also want to check for values nearing a limit so you can make
* limit changes preemptively.


***************************************************************************
* Check for outliers.

* You probably do not need to check for outliers for variables that have
* hard range limits in the CAI survey program. In most cases, any response
* in this range is already considered reasonable.

* However, in this survey we didn't use any hard range limits for weekly
* income, probably a mistake. We'll check for outliers by looking for
* incomes that are 3 standard deviations from the mean.

* In general, you should not drop outliers from the data. Variation is
* exactly what we're hoping to measure, and there will likely be some
* outliers just naturally. Contact your PI for further guidance on how to
* manage outliers.

egen mean = mean(wklyinc)
egen sd = sd(wklyinc)
generate sds = (wklyinc - mean) / sd
format mean sd sds %9.2f
display "Displaying wklyinc outliers:"
sort id
list id wklyinc mean sd sds if abs(sds) > 3 & !missing(sds)
drop mean sd sds


***************************************************************************
*****************************ENUMERATOR CHECKS*****************************
***************************************************************************

* Review the enumerator comments variable.

sort id
list id startdate enumerator comments if !missing(comments)


***************************************************************************
* Check average interview duration by enumerator.

* Dividing by 60,000 to convert from milliseconds to minutes
* avgdur is the average interview duration by enumerator.
bysort enumerator: egen avgdur = mean(duration / 60000)
* mean is the overall average interview duration.
egen mean = mean(duration / 60000)
* diff is the difference between avgdur and mean.
generate diff = avgdur - mean
* percdiff is the percent difference between avgdur and mean.
generate percdiff = 100 * diff / mean
* sd is the standard deviation of duration.
egen sd = sd(duration / 60000)
* sds is the number of standard deviations avgdur is from mean.
generate sds = diff / sd
format avgdur mean diff percdiff sd %9.1f
format sds %9.2f
egen tag = tag(enumerator)

display "Displaying interview duration averages by enumerator:"
sort enumerator
list enumerator avgdur mean diff percdiff sd sds if tag
drop avgdur mean diff percdiff sd sds tag

* You can use similar code for the following check:

* Check average section durations by enumerator.


***************************************************************************
* Check for unusually short or long interview durations.

* Here, we'll define "unusually short or long" as 1.5 standard deviations
* from the mean, knowing that this might list too many interviews.

egen mean = mean(duration / 60000)
egen sd = sd(duration / 60000)
generate sds = (duration / 60000 - mean) / sd
format mean sd %9.1f
format sds %9.2f

display "Displaying unusually short or long interviews:"
sort enumerator
list enumerator duration mean sd sds if abs(sds) > 1.5 & !missing(sds)
drop mean sd sds

* You can use similar code for the following check:

* Check for unusually short or long section durations.


***************************************************************************
* Check enumerator productivity by number of interviews completed and
* number of responses entered.

bysort enumerator: generate interviews = _N

generate nonmiss = 0
quietly ds, has(type numeric)
foreach var in `r(varlist)' {
	replace nonmiss = nonmiss + cond(`var' != ., 1, 0)
}
quietly ds, has(type string)
foreach var in `r(varlist)' {
	replace nonmiss = nonmiss + cond(`var' != "", 1, 0)
}
bysort enumerator: egen responses = total(nonmiss)
drop nonmiss

egen tag = tag(enumerator)

foreach stat in interviews responses {
	egen mean = mean(`stat')
	generate diff = `stat' - mean
	generate percdiff = 100 * diff / mean
	format mean diff percdiff %9.1f
	
	display "Displaying number of `stat' by enumerator:"
	sort enumerator
	list enumerator `stat' mean diff percdiff if tag
	drop mean diff percdiff
}

drop interviews responses tag


***************************************************************************
* Implement CAI soft checks again in Stata. Check the number of soft check
* warnings by enumerator. Just because it's conceivable that an enumerator
* should suppress a soft check doesn't mean you shouldn't verify that the
* suppression was correct.

* softchecks is the number of soft check warnings shown for an observation.
generate softchecks = 0

* Here, we'll reimplement the soft check that wklyinc should be <= 100.
generate softcheck = cond(wklyinc > 100 & !missing(wklyinc), 1, 0)
display "Displaying interviews that showed a soft check warning about wklyinc > 100:"
sort id
list id wklyinc startdate enumerator if softcheck == 1
replace softchecks = softchecks + softcheck
drop softcheck

* totchecks is the number of soft check warnings by enumerator.
bysort enumerator: egen totchecks = total(softchecks)
egen tag = tag(enumerator)
display "Displaying the number of soft check warnings by enumerator:"
sort enumerator
list enumerator totchecks if tag
drop softchecks totchecks tag


***************************************************************************
* Check enumerator effects on key variables.

* At IPA HQ, we're still trying to figure out the best way to measure
* enumerator fixed effects on key variables. For instance, how do we best
* control for the fact that enumerators are often assigned to different
* enumeration areas, so differences in key variables across enumerators
* could just be due to regional differences? If you have ideas, please
* e-mail us!

* That said, the following is a start. There are no controls for
* enumeration area, etc., so you might have to take the results with a
* grain of salt. However, if you see significant fixed effects, it's
* probably cause for further investigation.

xi: regress testscore i.enumerator
test _Ienumerato_2 _Ienumerato_3
drop _I*

* The p-value on _Ienumerato_2 is getting to be low. Further, the p-value
* of the F statistic is 0.0163, so we could have a problem.


***************************************************************************
*******************************OTHER CHECKS********************************
***************************************************************************

* If you have multiple datasets with data for the same respondent, check
* that the datasets are consistent.

* The code for this check is similar to that of this unique ID check:

* Check that a survey matches other records for its unique ID.
* Example: For each ID, check that the name in the baseline data matches
* the one in the master tracking list.


***************************************************************************
* Are enumerators able to navigate to completed forms on the CAI device and
* change entered values or inadvertently change automatically generated
* values, such as date? Are enumerators able to delete forms on the CAI
* device? Either the CAI survey program should prevent this or you should
* check in Stata that this has not happened with the most recently imported
* dataset.

* Plan: Every day, save the survey data in the "Past data" folder with the
* date attached to the filename. For this check, we'll have Stata figure
* out the most recent previous dataset, then use -cfout- to compare the
* current dataset with this previous one. If any interviews in the previous
* dataset differ from the ones in the current one, or if there are
* interviews in the previous dataset not in the current one, there could be
* a problem.

* If you haven't already installed -cfout-, type the following in Stata:
*
* ssc install cfout

* Save the survey data in the "Past data" folder with the date attached to
* the filename.
local today = date(c(current_date), "DMY")
local todaystr = string(`today', "%td")
save "Past data\survey_data_`todaystr'", replace

* Have Stata figure out the most recent previous dataset.
local maxdate .
local dtas : dir "Past data" files "survey_data_*.dta"
foreach dta of local dtas {
	local dtadatestr = regexr(regexr("`dta'", "^survey_data_", ""), "\.dta$", "")
	local dtadate = date("`dtadatestr'", "DMY")
	if inlist(`dtadate', `today', .) == 0 & (missing(`maxdate') | `dtadate' > `maxdate') local maxdate `dtadate'
}
local pastdta = "Past data\survey_data_" + string(`maxdate', "%td") + ".dta"
display "The current dataset will be compared against: `pastdta'."

cfout _all using "`pastdta'", id(id) replace

* If you don't understand this code, you can just determine the most recent
* previous dataset yourself, then run -cfout- manually.


***************************************************************************
****************************DATE CHECKS, PART 2****************************
***************************************************************************

* Newly imported interviews should have interview dates close to the system
* date.

* For this check, we'll again use `pastdta'. We'll define "newly imported"
* as having a value of id not in `pastdta'.

merge id using "`pastdta'", sort keep(id)
display "Displaying newly imported interview dates with unexpectedly early dates:"
sort id
list id startdate if _merge == 1 & startdate < date(c(current_date), "DMY") - 3
drop if _merge == 2
drop _merge
