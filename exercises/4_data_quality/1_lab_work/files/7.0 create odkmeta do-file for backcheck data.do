* Authors: Lindsey Shaughnessy
* Purpose: Demo odkmeta for SurveyCTO Crash Course 
* Date of last revision: 2015-02-02


/* -------------------------------------------------------------------------- */
					/* create do for demo  */
					
cd "???" 
					
odkmeta using "7.1 odkmeta do-file for backcheck data.do", ///
	csv("???.csv") survey("???.csv") choices("???.csv") replace

	run "7.1 odkmeta do-file for backcheck data.do"
