* Authors: Lindsey Shaughnessy
* Purpose: Demo bcstats template for SurveyCTO Crash Course   
* Date of last revision: 2015-02-02

set more off

*************************************************************************************************************************************
*************************************************************************************************************************************
*Program: BC_comparison.do
*Programmer: Hana Scheetz Freymiller
*Edited By: Matthew White
*Date created: 2011-10-27
*Date modified: 2012-12-01
*Purpose: Compare original and back check data, generate fieldwork statistics and prepare a reconciliation sheet.
*************************************************************************************************************************************
*************************************************************************************************************************************

**********************************************************************
*Step 1: Set CD and locals
**********************************************************************
* Set your working directory to use relative references.
cd ""
* Log your results.
cap log close
log using ""

* ENUMERATOR, TEAMS, BACK CHECKERS
* Enumerator variable
local enum ""
* Enumerator Team variable
local enumteam ""
* Back checker variable
local  bcer ""

* DATASETS
* The original dataset that will be used for the comparison
local orig_dta ""
* The backcheck dataset that will be used for the comparison
local bc_dta ""

* Unique ID*
local id ""

* VARIABLE LISTS
* Type 1 Vars: These should not change. They guage whether the enumerator
* performed the interview and whether it was with the right respondent.
* If these are high, you must discuss them with your field team and consider
* disciplinary action against the surveyor and redoing her/his interviews.

local t1vars ""

* Type 2 Vars: These are difficult questions to administer, such as skip
* patterns or those with a number of examples. The responses should be the
* same, though respondents may change their answers. Discrepanices should be
* discussed with the team and may indicate the need for additional training.

local t2vars ""

* Type 3 Vars: These are key outcomes that you want to understand how
* they're working in the field. These discrepancies are not used
* to hold surveyors accountable, but rather to gauge the stability
* of the measure and how well your survey is performing.

local t3vars ""

* Variables from the backcheck that you want to see in the outputted .csv,
* but not compare.

local keepbc ""

* Variables from the original survey that you want to see in the
* outputted .csv, but not compare.

local keepsurvey ""


* STABILITY TESTS*
* Type 3 Variables that are continuous. The stability check is a ttest.
local ttest ""
* Type 3 Variables that are discrete. The stability check uses signrank.
local signrank ""

* VALUES TO EXCLUDE*
* Set the values that you do not wanted included in the comparison
* if a backcheck variable has this value. These responses will not affect
* error rates and will not appear in the outputted .csv. Typically, you'll
* only use this only when the back check check data set has data for multiple
* back check versions.

local exclude_num ""
local exclude_str ""

**********************************************************************
*Step 2: Assembling and cleaning the original data, if necessary
**********************************************************************
* Clean duplicates and id's
* Assemble into one data set against which to compare the backcheck data

**********************************************************************
*Step 2: Assembling and cleaning the backcheck data
**********************************************************************
* Rename vars from the backcheck to match the original survey, if necessary
* Clean duplicates and id's
* Assemble into one data set

**********************************************************************
*Step 3: Compare the backcheck and original data
**********************************************************************
* Run the comparison
* Make sure to specify the enumeratorm enumerator team and backchecker vars.
* Select the options that you want to use, i.e. okrate, okrange, full, filename
* This is the code that we think will be the most applicable across projects.
* Feel free to edit and add functionality.

bcstats, ///
	surveydata(`orig_dta') bcdata(`bc_dta') id(`id') exclude(`exclude_num' "`exclude_str'")///
	t1vars(`t1vars') enumerator(`enum') enumteam(`enumteam') backchecker(`bcer') ///
	t2vars(`t2vars') signrank(`signrank') ///
	t3vars(`t3vars') ttest(`ttest') ///
	keepbc(`keepbc') keepsurvey(`keepsurvey') ///
	lower nosymbol trim
