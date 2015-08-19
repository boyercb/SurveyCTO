* Created on August 18, 2015 at 10:13:44 by the following -odkmeta- command:
* odkmeta using "7.1 odkmeta do-file for backcheck data.do",         csv("6.0 backcheck data.csv") survey("5.2 backcheck, survey worksheet csv.csv") choices("5.3 backcheck, choices worksheet csv.csv") replace
* -odkmeta- version 1.1.0 was used.

version 9

* Change these values as required by your data.

* The mask of date values in the .csv files. See -help date()-.
* Fields of type date or today have these values.
local datemask MDY
* The mask of time values in the .csv files. See -help clock()-.
* Fields of type time have these values.
local timemask hms
* The mask of datetime values in the .csv files. See -help clock()-.
* Fields of type datetime, start, or end have these values.
local datetimemask MDYhms


/* -------------------------------------------------------------------------- */

* Start the import.
* Be cautious about modifying what follows.

local varabbrev = c(varabbrev)
set varabbrev off

* Find unused Mata names.
foreach var in values text {
	mata: st_local("external", invtokens(direxternal("*")'))
	tempname `var'
	while `:list `var' in external' {
		tempname `var'
	}
}

label drop _all

#delimit ;
* yesno;
label define yesno
	1   Yes
	0   No
	999 "Don't know"
	888 "Refused to answer"
;
* fruit;
label define fruit
	1   Mango
	2   Banana
	3   Pineapple
	4   "Tomato "
	5   Apple
	999 "Don't know"
	888 "Refused to answer"
;
* vegetable;
label define vegetable
	1   Carrot
	2   "Onion "
	3   Cucumber
	4   Pepper
	999 "Don't know"
	888 "Refused to answer"
;
* title;
label define title
	1   "Country Director"
	2   "Research Manager "
	3   "Project Coordinator"
	4   "Project Associate "
	5   "HQ staff"
	999 "Don't know"
	888 "Refused to answer"
;
* field;
label define field
	1   Agriculture
	2   Health
	3   Education
	4   Finance
	5   Governance
	6   "Water and sanitation"
	999 "Don't know"
	888 "Refused to answer"
;
* status;
label define status
	1   "In development"
	2   Ongoing
	3   Completed
	999 "Don't know"
	888 "Refused to answer"
;
#delimit cr

* Add "other" values to value labels that need them.
local otherlabs title vegetable field
foreach lab of local otherlabs {
	mata: st_vlload("`lab'", `values' = ., `text' = "")
	mata: st_local("otherval", strofreal(max(`values') + 1, "%24.0g"))
	local othervals `othervals' `otherval'
	label define `lab' `otherval' other, add
}

* Save label information.
label dir
local labs `r(names)'
foreach lab of local labs {
	quietly label list `lab'
	* "nassoc" for "number of associations"
	local nassoc `nassoc' `r(k)'
}

* Import ODK attributes as characteristics.
* - constraint message will be imported to the characteristic Odk_constraint_message.

insheet using "6.0 backcheck data.csv", comma names case clear

* starttime
char starttime[Odk_name] starttime
char starttime[Odk_bad_name] 0
char starttime[Odk_long_name] starttime
char starttime[Odk_type] start
char starttime[Odk_or_other] 0
char starttime[Odk_is_other] 0

* endtime
char endtime[Odk_name] endtime
char endtime[Odk_bad_name] 0
char endtime[Odk_long_name] endtime
char endtime[Odk_type] end
char endtime[Odk_or_other] 0
char endtime[Odk_is_other] 0

* deviceid
char deviceid[Odk_name] deviceid
char deviceid[Odk_bad_name] 0
char deviceid[Odk_long_name] deviceid
char deviceid[Odk_type] deviceid
char deviceid[Odk_or_other] 0
char deviceid[Odk_is_other] 0

* subscriberid
char subscriberid[Odk_name] subscriberid
char subscriberid[Odk_bad_name] 0
char subscriberid[Odk_long_name] subscriberid
char subscriberid[Odk_type] subscriberid
char subscriberid[Odk_or_other] 0
char subscriberid[Odk_is_other] 0

* simid
char simid[Odk_name] simid
char simid[Odk_bad_name] 0
char simid[Odk_long_name] simid
char simid[Odk_type] simserial
char simid[Odk_or_other] 0
char simid[Odk_is_other] 0

* devicephonenum
char devicephonenum[Odk_name] devicephonenum
char devicephonenum[Odk_bad_name] 0
char devicephonenum[Odk_long_name] devicephonenum
char devicephonenum[Odk_type] phonenumber
char devicephonenum[Odk_or_other] 0
char devicephonenum[Odk_is_other] 0

* intronote
char intronote[Odk_name] intronote
char intronote[Odk_bad_name] 0
char intronote[Odk_long_name] intronote
char intronote[Odk_type] note
char intronote[Odk_or_other] 0
char intronote[Odk_is_other] 0
char intronote[Odk_label] This is an example *BACKCHECK* file for an introduction to ODK training. The data produced by this file will be used to demonstrate ODK protocols.

* consent
char consent[Odk_name] consent
char consent[Odk_bad_name] 0
char consent[Odk_long_name] consent
char consent[Odk_type] select_one yesno
char consent[Odk_list_name] yesno
char consent[Odk_or_other] 0
char consent[Odk_is_other] 0
char consent[Odk_label] "Would you like to proceed with this survey? "

* begin group consented

* stamp
char consentedstamp[Odk_name] stamp
char consentedstamp[Odk_bad_name] 0
char consentedstamp[Odk_group] consented
char consentedstamp[Odk_long_name] consented-stamp
char consentedstamp[Odk_type] datetime
char consentedstamp[Odk_or_other] 0
char consentedstamp[Odk_is_other] 0
char consentedstamp[Odk_label] "Please record the date and time of this interview. "

* id
char consentedid[Odk_name] id
char consentedid[Odk_bad_name] 0
char consentedid[Odk_group] consented
char consentedid[Odk_long_name] consented-id
char consentedid[Odk_type] integer
char consentedid[Odk_or_other] 0
char consentedid[Odk_is_other] 0
char consentedid[Odk_label] Please enter the enumerator ID (number from 1 to 99).
char consentedid[Odk_constraint] . > 0 and . < 100
char consentedid[Odk_constraint_message] You must enter a number from 1 to 99.

* name
char consentedname[Odk_name] name
char consentedname[Odk_bad_name] 0
char consentedname[Odk_group] consented
char consentedname[Odk_long_name] consented-name
char consentedname[Odk_type] text
char consentedname[Odk_or_other] 0
char consentedname[Odk_is_other] 0
char consentedname[Odk_label] What is your name?

* thanks
char consentedthanks[Odk_name] thanks
char consentedthanks[Odk_bad_name] 0
char consentedthanks[Odk_group] consented
char consentedthanks[Odk_long_name] consented-thanks
char consentedthanks[Odk_type] note
char consentedthanks[Odk_or_other] 0
char consentedthanks[Odk_is_other] 0
char consentedthanks[Odk_label] "Thank you, \${name}, for agreeing to participate! Now, I'd like to ask a few questions about you. "

* title
foreach suffix in "" _other {
	char consentedtitle`suffix'[Odk_name] title
	char consentedtitle`suffix'[Odk_bad_name] 0
	char consentedtitle`suffix'[Odk_group] consented
	char consentedtitle`suffix'[Odk_long_name] consented-title
	char consentedtitle`suffix'[Odk_type] select_one title or_other
	char consentedtitle`suffix'[Odk_list_name] title
	char consentedtitle`suffix'[Odk_or_other] 1
	local isother = "`suffix'" != ""
	char consentedtitle`suffix'[Odk_is_other] `isother'
	local labend "`=cond("`suffix'" == "", "", " (Other)")'"
	char consentedtitle`suffix'[Odk_label] What is your title?`labend'
}

* age
char consentedage[Odk_name] age
char consentedage[Odk_bad_name] 0
char consentedage[Odk_group] consented
char consentedage[Odk_long_name] consented-age
char consentedage[Odk_type] integer
char consentedage[Odk_or_other] 0
char consentedage[Odk_is_other] 0
char consentedage[Odk_label] How old are you?

* favfruit
char consentedfavfruit[Odk_name] favfruit
char consentedfavfruit[Odk_bad_name] 0
char consentedfavfruit[Odk_group] consented
char consentedfavfruit[Odk_long_name] consented-favfruit
char consentedfavfruit[Odk_type] select_one fruit
char consentedfavfruit[Odk_list_name] fruit
char consentedfavfruit[Odk_or_other] 0
char consentedfavfruit[Odk_is_other] 0
char consentedfavfruit[Odk_label] What is your ONE favorite kind of fruit from the options presented?

* favveg
foreach suffix in "" _other {
	char consentedfavveg`suffix'[Odk_name] favveg
	char consentedfavveg`suffix'[Odk_bad_name] 0
	char consentedfavveg`suffix'[Odk_group] consented
	char consentedfavveg`suffix'[Odk_long_name] consented-favveg
	char consentedfavveg`suffix'[Odk_type] select_multiple vegetable or_other
	char consentedfavveg`suffix'[Odk_list_name] vegetable
	char consentedfavveg`suffix'[Odk_or_other] 1
	local isother = "`suffix'" != ""
	char consentedfavveg`suffix'[Odk_is_other] `isother'
	local labend "`=cond("`suffix'" == "", "", " (Other)")'"
	char consentedfavveg`suffix'[Odk_label] What kinds of vegetables do you like to eat?`labend'
}

* researcharea
foreach suffix in "" _other {
	char consentedresearcharea`suffix'[Odk_name] researcharea
	char consentedresearcharea`suffix'[Odk_bad_name] 0
	char consentedresearcharea`suffix'[Odk_group] consented
	char consentedresearcharea`suffix'[Odk_long_name] consented-researcharea
	char consentedresearcharea`suffix'[Odk_type] select_multiple field or_other
	char consentedresearcharea`suffix'[Odk_list_name] field
	char consentedresearcharea`suffix'[Odk_or_other] 1
	local isother = "`suffix'" != ""
	char consentedresearcharea`suffix'[Odk_is_other] `isother'
	local labend "`=cond("`suffix'" == "", "", " (Other)")'"
	char consentedresearcharea`suffix'[Odk_label] Which research area(s) do you work in?`labend'
	char consentedresearcharea`suffix'[Odk_hint] "We're assuming we're interviewing only research staff. :) "
}

* end group consented

* endnote
char endnote[Odk_name] endnote
char endnote[Odk_bad_name] 0
char endnote[Odk_long_name] endnote
char endnote[Odk_type] note
char endnote[Odk_or_other] 0
char endnote[Odk_is_other] 0
char endnote[Odk_label] "Thank you!C2 This is the end of the survey. "

* enumeratorcomment
char enumeratorcomment[Odk_name] enumeratorcomment
char enumeratorcomment[Odk_bad_name] 0
char enumeratorcomment[Odk_long_name] enumeratorcomment
char enumeratorcomment[Odk_type] text
char enumeratorcomment[Odk_or_other] 0
char enumeratorcomment[Odk_is_other] 0
char enumeratorcomment[Odk_label] "Enumerator, please use this space to save any additional comments about this BACKCHECK interview. Then, please move to the next screen to name and save your survey form. "

* Rename any variable names that are difficult for -split-.
// rename ...

* Split select_multiple variables.
ds, has(char Odk_type)
foreach typevar in `r(varlist)' {
	if strmatch("`:char `typevar'[Odk_type]'", "select_multiple *") & ///
		!`:char `typevar'[Odk_is_other]' {
		* Add an underscore to the variable name if it ends in a number.
		local var `typevar'
		local list : char `var'[Odk_list_name]
		local pos : list posof "`list'" in labs
		local nparts : word `pos' of `nassoc'
		if `:list list in otherlabs' & !`:char `var'[Odk_or_other]' ///
			local --nparts
		if inrange(substr("`var'", -1, 1), "0", "9") & ///
			length("`var'") < 32 - strlen("`nparts'") {
			numlist "1/`nparts'"
			local splitvars " `r(numlist)'"
			local splitvars : subinstr local splitvars " " " `var'_", all
			capture confirm new variable `var'_ `splitvars'
			if !_rc {
				rename `var' `var'_
				local var `var'_
			}
		}

		capture confirm numeric variable `var', exact
		if !_rc ///
			tostring `var', replace format(%24.0g)
		split `var'
		local parts `r(varlist)'
		local next = `r(nvars)' + 1
		destring `parts', replace

		forvalues i = `next'/`nparts' {
			local newvar `var'`i'
			generate byte `newvar' = .
			local parts : list parts | newvar
		}

		local chars : char `var'[]
		local label : char `var'[Odk_label]
		local len : length local label
		local i 0
		foreach part of local parts {
			local ++i

			foreach char of local chars {
				mata: st_global("`part'[`char']", st_global("`var'[`char']"))
			}

			if `len' {
				mata: st_global("`part'[Odk_label]", st_local("label") + ///
					(substr(st_local("label"), -1, 1) == " " ? "" : " ") + ///
					"(#`i'/`nparts')")
			}

			move `part' `var'
		}

		drop `var'
	}
}

* Drop note variables.
ds, has(char Odk_type)
foreach var in `r(varlist)' {
	if "`:char `var'[Odk_type]'" == "note" ///
		drop `var'
}

* Date and time variables
capture confirm variable SubmissionDate, exact
if !_rc {
	local type : char SubmissionDate[Odk_type]
	assert !`:length local type'
	char SubmissionDate[Odk_type] datetime
}
local datetime date today time datetime start end
tempvar temp
ds, has(char Odk_type)
foreach var in `r(varlist)' {
	local type : char `var'[Odk_type]
	if `:list type in datetime' {
		capture confirm numeric variable `var'
		if !_rc {
			tostring `var', replace
			replace `var' = "" if `var' == "."
		}

		if inlist("`type'", "date", "today") {
			local fcn    date
			local mask   datemask
			local format %tdMon_dd,_CCYY
		}
		else if "`type'" == "time" {
			local fcn    clock
			local mask   timemask
			local format %tchh:MM:SS_AM
		}
		else if inlist("`type'", "datetime", "start", "end") {
			local fcn    clock
			local mask   datetimemask
			local format %tcMon_dd,_CCYY_hh:MM:SS_AM
		}
		generate double `temp' = `fcn'(`var', "``mask''")
		format `temp' `format'
		count if missing(`temp') & !missing(`var')
		if r(N) {
			display as err "{p}"
			display as err "`type' variable `var'"
			if "`repeat'" != "" ///
				display as err "in repeat group `repeat'"
			display as err "could not be converted using the mask ``mask''"
			display as err "{p_end}"
			exit 9
		}

		move `temp' `var'
		foreach char in `:char `var'[]' {
			mata: st_global("`temp'[`char']", st_global("`var'[`char']"))
		}
		drop `var'
		rename `temp' `var'
	}
}
capture confirm variable SubmissionDate, exact
if !_rc ///
	char SubmissionDate[Odk_type]

* Attach value labels.
ds, not(vallab)
if "`r(varlist)'" != "" ///
	ds `r(varlist)', has(char Odk_list_name)
foreach var in `r(varlist)' {
	if !`:char `var'[Odk_is_other]' {
		capture confirm string variable `var', exact
		if !_rc {
			replace `var' = ".o" if `var' == "other"
			destring `var', replace
		}

		local list : char `var'[Odk_list_name]
		if !`:list list in labs' {
			display as err "list `list' not found in choices sheet"
			exit 9
		}
		label values `var' `list'
	}
}

* select or_other variables
forvalues i = 1/`:list sizeof otherlabs' {
	local lab      : word `i' of `otherlabs'
	local otherval : word `i' of `othervals'

	ds, has(vallab `lab')
	if "`r(varlist)'" != "" ///
		recode `r(varlist)' (.o=`otherval')
}

* Attach field labels as variable labels and notes.
ds, has(char Odk_long_name)
foreach var in `r(varlist)' {
	* Variable label
	local label : char `var'[Odk_label]
	mata: st_varlabel("`var'", st_local("label"))

	* Notes
	if `:length local label' {
		char `var'[note0] 1
		mata: st_global("`var'[note1]", "Question text: " + ///
			st_global("`var'[Odk_label]"))
		mata: st_local("temp", ///
			" " * (strlen(st_global("`var'[note1]")) + 1))
		#delimit ;
		local fromto
			{			"`temp'"
			}			"{c )-}"
			"`temp'"	"{c -(}"
			'			"{c 39}"
			"`"			"{c 'g}"
			"$"			"{c S|}"
		;
		#delimit cr
		while `:list sizeof fromto' {
			gettoken from fromto : fromto
			gettoken to   fromto : fromto
			mata: st_global("`var'[note1]", ///
				subinstr(st_global("`var'[note1]"), "`from'", "`to'", .))
		}
	}
}

local repeats `"`repeats' """'

local badnames
ds, has(char Odk_bad_name)
foreach var in `r(varlist)' {
	if `:char `var'[Odk_bad_name]' & ///
		("`:char `var'[Odk_type]'" != "begin repeat" | ///
		("`repeat'" != "" & ///
		"`:char `var'[Odk_name]'" == "SET-OF-`repeat'")) {
		local badnames : list badnames | var
	}
}
local allbadnames `"`allbadnames' "`badnames'""'

ds, not(char Odk_name)
local datanotform `r(varlist)'
local exclude SubmissionDate KEY PARENT_KEY metainstanceID
local datanotform : list datanotform - exclude
local alldatanotform `"`alldatanotform' "`datanotform'""'

compress

local dta `""6.0 backcheck data.dta""'
save `dta', replace
local dtas : list dtas | dta

capture mata: mata drop `values' `text'

set varabbrev `varabbrev'

* Display warning messages.
quietly {
	noisily display

	#delimit ;
	local problems
		allbadnames
			"The following variables' names differ from their field names,
			which could not be {cmd:insheet}ed:"
		alldatanotform
			"The following variables appear in the data but not the form:"
	;
	#delimit cr
	while `:list sizeof problems' {
		gettoken local problems : problems
		gettoken desc  problems : problems

		local any 0
		foreach vars of local `local' {
			local any = `any' | `:list sizeof vars'
		}
		if `any' {
			noisily display as txt "{p}`desc'{p_end}"
			noisily display "{p2colset 0 34 0 2}"
			noisily display as txt "{p2col:repeat group}variable name{p_end}"
			noisily display as txt "{hline 65}"

			forvalues i = 1/`:list sizeof repeats' {
				local repeat : word `i' of `repeats'
				local vars   : word `i' of ``local''

				foreach var of local vars {
					noisily display as res "{p2col:`repeat'}`var'{p_end}"
				}
			}

			noisily display as txt "{hline 65}"
			noisily display "{p2colreset}"
		}
	}
}
