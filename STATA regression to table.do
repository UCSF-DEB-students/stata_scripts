/*
Pam Murnane
May 13 2022
This is my attempt to output multiple regression models into one readable table
In this example the model is run in the full population then stratified by sex.

1. use regsave to output regression results to new dataset (here G1os)
see more: https://ideas.repec.org/c/boc/bocode/s456964.html

2. then use putdocx to make a pretty table in WordDocFilename
*/


/** Run the model in the full pop and by sex */
melogit outcome_var female age other_covariates || studynum: , or vce(robust)
regsave using "G1os", replace ci pval addlabel(subgroup, "Overall") // initiate the output file with replace
		
melogit outcome_var age other_covariates if female == 1 || studynum: , or vce(robust)	
regsave using "G1os", append ci pval addlabel(subgroup, "Female") // add rows to the output file with append

melogit outcome_var age other_covariates if female == 0 || studynum: , or vce(robust)	
regsave using "G1os", append ci pval addlabel(subgroup, "Male")


/** Set up table */
use G1os, clear
// format OR and CI, also keep beta and CI
gen str orci = string(exp(coef),"%5.2f") + " (" + string(exp(ci_lower),"%5.2f") + "-" + string(exp(ci_upper),"%5.2f") + ")"
gen str bci = string(coef,"%5.3f") + " (" + string(ci_lower,"%5.3f") + ", " + string(ci_upper,"%5.3f") + ")"
order subgroup var orci bci 

// open a word doc
putdocx begin, landscape margin(left,0.5) margin(right,0.5) margin(top,0.5) margin(bottom,0.5) font(arial, 9)

putdocx paragraph, style(Heading1)
putdocx text ("Primary Results")
putdocx table tablename = data(*), varnames layout(autofitc) 
// data(*) prints all data in memory
// could instead select vars:  putdocx table tablename = data(varlist)
// or skip regsave and use putdocx to output regression https://www.stata.com/stata-news/news32-3/spotlight-putdocx/
// but I'm not sure how to assemble results from multiple models without regsave

putdocx save WordDocFilename, replace


