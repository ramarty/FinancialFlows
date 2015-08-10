**************************
**    Financial Flows	**
**        Graphs        **
**						**
**		Rob Marty		**
**     USAID/E3/EP      **
**  Last Updated 8/10   **
**************************

********************************************************************************	
* INITIAL SET-UP    

* Set file path to financial flows folder
global projectpath "~/Desktop/USAID/ChiefEconomist/FinancialFlows/"

global data "$projectpath/Data/"
global tables "$projectpath/Tables/"
global figures "$projectpath/Figures/"

* Parameters
scalar define beginYear = 1995
scalar define endYear   = 2012
scalar define observNeeded = 9

* Installing add-in
ssc install listtex

********************************************************************************
* UPDATE AVAILABLE SAMPLE

use "$data/financialflows.dta", clear

* Defining Revenue Variable
replace imfFA_revMGnts_perGDP = (imfFA_rev - imfFA_grants_zeros)/100 // (imfFA_grants_zeros, missing values = zero) (imfFA_grants, missing values = missing) 
replace imfFA_revMGnts = gdp * imfFA_revMGnts_perGDP

save "$data/financialflows.dta", replace

********************************************************************************
* MAKE CONSTANT SAMPLE

use "$data/financialflows.dta", clear

*** Define which years and countries to keep
keep if year >= `=scalar(beginYear)' & year <= `=scalar(endYear)'
keep if devstatus == 2 | devstatus == 3 // Developing and Transitioning economies

keep ctry iso year oda oof private remittances gdp 
order ctry iso year oda oof private remittances gdp 

gen end1995 = .
gen end2012 = . 

replace end1995 = 1 if oda != . & oof != . & private != . & remittances != . & gdp != . & year == `=scalar(beginYear)'
replace end2012 = 1 if oda != . & oof != . & private != . & remittances != . & gdp != . & year == `=scalar(endYear)'

replace end1995 = 0 if end1995 == .
replace end2012 = 0 if end2012 == .
gen end95_12 = end1995 + end2012
replace end95_12 = . if end95_12 == 0

foreach f in oda oof private remittances gdp{
	replace `f' = 1 if `f' != .
}

collapse (sum) oda oof private remittances gdp end95_12, by(iso)

keep if end95_12 == 2 & oda >= `=scalar(observNeeded)' & oof >= `=scalar(observNeeded)' & private >= `=scalar(observNeeded)' & remittances >= `=scalar(observNeeded)' & gdp >= `=scalar(observNeeded)'

drop oda oof private remittances gdp end95_12

gen constantKeep = 1

tempfile constantCountries
save `constantCountries'

***** Merging
use "$data/financialflows.dta", clear
keep if year >= `=scalar(beginYear)' & year <= `=scalar(endYear)'
keep if devstatus == 2 | devstatus == 3

merge m:1 iso using `constantCountries', nogen

****** Interpolating

*interpolate between endpoints
	sort ctry year
	foreach v of varlist oda oof private remittances gdp imfFA_revMGnts{
		by ctry: ipolate `v' year, gen(epol_`v') epolate
			local label : variable label `v'		
			lab var epol_`v' "Interpolated `label'"
		}
		
drop if constantKeep != 1
drop constantKeep
		
save "$data/financialflows_const.dta", replace


********************************************************************************
* Define which countries are in Gov't Revenue Constant Sample

use "$data/financialflows.dta", clear

*** Figure out which countries to keep
keep if year >= `=scalar(beginYear)' & year <= `=scalar(endYear)'
keep if devstatus == 2 | devstatus == 3

keep ctry iso year imfFA_revMGnts
order ctry iso year imfFA_revMGnts

gen end1995 = .
gen end2012 = . 

replace end1995 = 1 if imfFA_revMGnts != . & year == `=scalar(beginYear)'
replace end2012 = 1 if imfFA_revMGnts != . & year == `=scalar(endYear)'

replace end1995 = 0 if end1995 == .
replace end2012 = 0 if end2012 == .
gen end95_12 = end1995 + end2012
replace end95_12 = . if end95_12 == 0

replace imfFA_revMGnts = 1 if imfFA_revMGnts != .

collapse (sum) imfFA_revMGnts end95_12, by(iso)

keep if end95_12 == 2 & imfFA_revMGnts >= `=scalar(observNeeded)'

drop imfFA_revMGnts end95_12

gen include_Rev = 2

tempfile RevCountries
save `RevCountries' 

***** Merging
use "$data/financialflows_const.dta", clear

merge m:1 iso using `RevCountries'
*drop if _merge == 2
*drop _merge
replace include_Rev = 1 if include_Rev != 2

*gen imfFA_revMGnts = imfFA_revMGnts_perGDP * epol_gdp
keep if year >= `=scalar(beginYear)' & year <= `=scalar(endYear)'
save "$data/financialflows_const.dta", replace

*List countries in constant sample

cd "$tables/CountriesInSample/ConstantSample/" 
listtex ctry using NonRes_NonLIC.txt if resRich == 1 & lic == 1 & year == 2000, rstyle(tabdelim) replace // Non-Resource Dependent & Non-LDC
listtex ctry using Res_LIC.txt       if resRich == 2 & lic == 2 & year == 2000, rstyle(tabdelim) replace // Resource Dependent & LDC
listtex ctry using Res_NonLIC.txt    if resRich == 2 & lic == 1 & year == 2000, rstyle(tabdelim) replace // Resource Dependent & Non-LDC
listtex ctry using NonRes_LIC.txt    if resRich == 1 & lic == 2 & year == 2000, rstyle(tabdelim) replace // Non-Resource Dependent & LDC

cd "$tables/CountriesInSample/ConstantSample_GovtRevenue/" 
listtex ctry using NonRes_NonLIC_GovtRev.txt if resRich == 1 & lic == 1 & include_Rev == 2 & year == 2000, rstyle(tabdelim) replace // Non-Resource Dependent & Non-LDC
listtex ctry using Res_LIC_GovtRev.txt       if resRich == 2 & lic == 2 & include_Rev == 2 & year == 2000, rstyle(tabdelim) replace // Resource Dependent & LDC
listtex ctry using Res_NonLIC_GovtRev.txt    if resRich == 2 & lic == 1 & include_Rev == 2 & year == 2000, rstyle(tabdelim) replace // Resource Dependent & Non-LDC
listtex ctry using NonRes_LIC_GovtRev.txt    if resRich == 1 & lic == 2 & include_Rev == 2 & year == 2000, rstyle(tabdelim) replace // Non-Resource Dependent & LDC



