**************************
**    Financial Flows	**
**       Analysis       **
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

* Installing add-ins
ssc install listtex
ssc install outreg2

********************************************************************************
********************************************************************************
* 								Analysis
********************************************************************************
********************************************************************************

use "$data/financialflows.dta", clear

********************************************************************************
*** Restricting Dataset
keep if devstatus == 2 | devstatus == 3 // Developing and Transitioning Countries
keep if year >= 1990 // Year from 1990 onward

********************************************************************************
*** Generating Variables

* Revenue Variables
	* taxr // IMF Fiscal Affairs Deparment 
	* rev_tax // IMF GFS
	* trv_tot_resource_rev
	* tot_nresource_rev_inc_sc
	* genrev
	* grants
	* revenuePerGDP
*replace gdp_ppp = gdp
	
gen rGDP_ppp = gdp_ppp / cpi_d // cpi_d is cpi deflator with 2010 base year
gen rGDPpc_ppp = rGDP_ppp / population // both values in millions

gen Rev_GDP = imfFA_revMGnts_perGDP

gen rGDPpc_ppp_ln = ln(rGDPpc_ppp)
*gen TermsOfTrade_ln = ln(TermsOfTrade)
gen rGDPpc_ppp_sq = rGDPpc_ppp^2

*** Pen World Tables Data
sum rgdpl // Real GDP excluding the TOT adjustment per capita
gen ietot = rgdptt - rgdpl // income effect of the TOT per capita

*Real GDP excluding the TOT adjustment" per capita
gen rGDP_exTOTadj = rgdpl - rgdptt
gen rGDP_exTOTadj_pc = rGDP_exTOTadj / population 

*TOT adjustment as a share of GDP
gen rgdptt_shareGDP = rgdptt / rgdpl

*** Making LIC variable
*gen lic = 1 if inclvl_wb == 3
*replace lic = 0 if inclvl_wb != 3
replace lic = lic - 1
*** Making binary variables
replace ldc = ldc - 1
replace resRich = resRich - 1

*** Dividing by 100
replace rents_totnres = rents_totnres / 100
*replace rents_totnres = log(1+rents_totnres)

*Creating additional variables
gen rgdptt_ln = ln(rgdptt)
gen rgdpl_ln = ln(rgdpl)
gen oneplus_ietot_rgdpl_ln = ln(1 + (ietot/rgdpl))
gen licXrgdptt_ln = lic * rgdptt_ln
gen resXrgdptt_ln = resRich * rgdptt_ln
gen licXrgdpl_ln = lic * rgdpl_ln
gen licXoneplus_ietot_rgdpl_ln = lic * oneplus_ietot_rgdpl_ln
gen resXrgdpl_ln = resRich * rgdpl_ln
gen resXoneplus_ietot_rgdpl_ln = resRich * oneplus_ietot_rgdpl_ln
gen licXrents_totnres = lic * rents_totnres
gen resXrents_totnres = resRich * rents_totnres

********************************************************************************
*** Value Labels
label variable Rev_GDP "Rev/GDP"
label variable rgdptt_ln "log(pcGDI)"
label variable rgdpl_ln "log(pcGDP)"
label variable oneplus_ietot_rgdpl_ln "log(IETOT)"
label variable licXrgdptt_ln "LICálog(pcGDI)"
label variable resXrgdptt_ln "ResDepálog(pcGDI)"
label variable licXrgdpl_ln "LICálog(pcGDP)"
label variable licXoneplus_ietot_rgdpl_ln "LICálog(pcIETOT)"
label variable resXrgdpl_ln "ResDepálog(pcGDP)"
label variable resXoneplus_ietot_rgdpl_ln "ResDepálog(pcIETOT)"
label variable rents_totnres "Rents/GDP"
label variable licXrents_totnres "LICáRents/GDP"
label variable resXrents_totnres "ResDepáRents/GDP"

********************************************************************************
*** Regressions
rename ctry Countries
xtset Countries year

*** Without time-fixed effects

* Rev_GDP ~ GDI
xtreg Rev_GDP rgdptt_ln, fe robust
outreg2 using "$tables/table1", word label replace
xtreg Rev_GDP rgdptt_ln licXrgdptt_ln, fe robust
outreg2 using "$tables/table1", word label
xtreg Rev_GDP rgdptt_ln resXrgdptt_ln, fe robust
outreg2 using "$tables/table1", word label

* Rev_GDP ~ GDP + IETOT
xtreg Rev_GDP rgdpl_ln oneplus_ietot_rgdpl_ln, fe robust
outreg2 using "$tables/table2", word label replace
xtreg Rev_GDP rgdpl_ln oneplus_ietot_rgdpl_ln licXrgdpl_ln licXoneplus_ietot_rgdpl_ln, fe robust
outreg2 using "$tables/table2", word label
xtreg Rev_GDP rgdpl_ln oneplus_ietot_rgdpl_ln resXrgdpl_ln resXoneplus_ietot_rgdpl_ln, fe robust
outreg2 using "$tables/table2", word label

* Rev_GDP ~ GDP + Rents
xtreg Rev_GDP rgdpl_ln rents_totnres, fe robust
outreg2 using "$tables/table3", word label replace
xtreg Rev_GDP rgdpl_ln rents_totnres licXrgdpl_ln licXrents_totnres, fe robust
outreg2 using "$tables/table3", word label
xtreg Rev_GDP rgdpl_ln rents_totnres resXrgdpl_ln resXrents_totnres, fe robust
outreg2 using "$tables/table3", word label

* Rev_GDP ~ GDP
xtreg Rev_GDP rgdpl_ln, fe robust
outreg2 using "$tables/table4", word label replace
xtreg Rev_GDP rgdpl_ln licXrgdpl_ln, fe robust
outreg2 using "$tables/table4", word label
xtreg Rev_GDP rgdpl_ln resXrgdpl_ln, fe robust
outreg2 using "$tables/table4", word label
gen analysisSample = 1 if e(sample)

* pcIETOT ~ GDP
xtreg oneplus_ietot_rgdpl_ln rgdpl_ln if analysisSample == 1, fe robust
outreg2 using "$tables/table5", word label replace
xtreg oneplus_ietot_rgdpl_ln rgdpl_ln licXrgdpl_ln if analysisSample == 1, fe robust
outreg2 using "$tables/table5", word label
xtreg oneplus_ietot_rgdpl_ln rgdpl_ln resXrgdpl_ln if analysisSample == 1, fe robust
outreg2 using "$tables/table5", word label

* Clean Up Folder
cd "$projectpath/Tables/"
local datafiles: dir "`workdir'" files "*.txt"
foreach datafile of local datafiles {
        rm `datafile'
}

********************************************************************************
*** Correlation
xtreg rgdpl_ln if analysisSample == 1, fe
predict rgdpl_resid, ue
xtreg oneplus_ietot_rgdpl_ln if analysisSample == 1, fe
predict ietot_resid, ue
cor  ietot_resid rgdpl_resid if analysisSample == 1

tempfile datasetRegressions
save `datasetRegressions'

********************************************************************************
********************************************************************************
* MAKING GRAPHS
********************************************************************************
********************************************************************************

********************************************************************************
*** Variables for Graphs
gen rgdptt_ln_LIC = rgdptt_ln if lic == 1
gen rgdpl_ln_LIC = rgdpl_ln if lic == 1
gen oneplus_ietot_rgdpl_ln_LIC = oneplus_ietot_rgdpl_ln if lic == 1
gen rents_totnres_LIC = rents_totnres if lic == 1

gen rgdptt_ln_nonLIC = rgdptt_ln if lic == 0
gen rgdpl_ln_nonLIC = rgdpl_ln if lic == 0
gen oneplus_ietot_rgdpl_ln_nonLIC = oneplus_ietot_rgdpl_ln if lic == 0
gen rents_totnres_nonLIC = rents_totnres if lic == 0 

gen rgdptt_ln_RES = rgdptt_ln if resRich == 1
gen rgdpl_ln_RES = rgdpl_ln if resRich == 1
gen oneplus_ietot_rgdpl_ln_RES = oneplus_ietot_rgdpl_ln if resRich == 1
gen rents_totnres_RES = rents_totnres if resRich == 1

gen rgdptt_ln_nonRES = rgdptt_ln if resRich == 0
gen rgdpl_ln_nonRES = rgdpl_ln if resRich == 0
gen oneplus_ietot_rgdpl_ln_nonRES = oneplus_ietot_rgdpl_ln if resRich == 0
gen rents_totnres_nonRES = rents_totnres if resRich == 0
*rgdptt_ln_LIC-rents_totnres_nonRES

*keep if analysisSample == 1
keep if year >= 1990 
keep if year <= 2010

collapse (mean) rgdpl_ln oneplus_ietot_rgdpl_ln rgdptt_ln rents_totnres rgdptt_ln_LIC-rents_totnres_nonRES, by(year)

gen ends = 1 if year == 1990 | year == 2010
gen labelAll = "All" if year == 2010
gen labelLIC = "LIC" if year == 2010
gen labelnonLIC = "non-LIC" if year == 2010
gen labelRES = "Res" if year == 2010
gen labelnonRES = "non-Res" if year == 2010



********************************************************************************
********************************************************************************
* 							    FIGURES
********************************************************************************
********************************************************************************

*** Graph of Independent Variables - Not Divided by Country Category
		twoway line rgdptt_ln year, ///
			legend(off) ///
			title("{bf: per capita GDI}", color(black) size(medium) box bexpand bcolor("217 217 217")) ///
			ytitle("log(pcGDI)") xtitle("") ///
			xlabel(1990(5)2010, notick) xscale(noline) ///
			name("gdi", replace) ///
			plotregion(style(none)) ///
			graphregion(color(white)) ///
			lwidth(medthick) ///
			nodraw

		twoway line rgdpl_ln year, ///
			legend(off) ///
			title("{bf: per capita GDP}", color(black) size(medium) box bexpand bcolor("217 217 217")) ///
			ytitle("log(pcGDP)") xtitle("") ///
			xlabel(1990(5)2010, notick) xscale(noline) ///
			name("gdp", replace) ///
			plotregion(style(none)) ///
			graphregion(color(white)) ///
			lwidth(medthick) ///
			nodraw

		twoway line oneplus_ietot_rgdpl_ln year, ///
			legend(off) ///
			title("{bf: per capita Income Effect of Terms of Trade}", color(black) size(medium) box bexpand bcolor("217 217 217")) ///
			ytitle("log(1+(ietot/pcGDP))") xtitle("") ///
			xlabel(1990(5)2010, notick) xscale(noline) ///
			name("ietot", replace) ///
			plotregion(style(none)) ///
			graphregion(color(white)) ///
			lwidth(medthick) ///
			nodraw
			
		graph combine gdi gdp ietot, row(3) graphregion(color(white)) ///
		note("Data is averaged across countries for each year")
		graph display, ysize(5) xsize(4)
		graph export "$figures/Analysis_Indepn.pdf", replace

*** Graph of Independent Variables - LIC
		twoway line rgdptt_ln year, lcolor("black") lwidth(medthick) || ///
				scatter rgdptt_ln year if ends == 1, mcolor("black") msize(medium) /// 
				mlabel(labelAll) mlabposition(3) mlabcolor(black) || ///		
			line rgdptt_ln_LIC year, lcolor("blue") lwidth(medthick) || ///
				scatter rgdptt_ln_LIC year if ends == 1, mcolor("blue") msize(medium) ///
				mlabel(labelLIC) mlabposition(3) mlabcolor(black) || ///
			line rgdptt_ln_nonLIC year, lcolor("green" ) lwidth(medthick) || ///
				scatter rgdptt_ln_nonLIC year if ends == 1, mcolor("green") msize(medium) ///
				mlabel(labelnonLIC) mlabposition(3) mlabcolor(black) ///
			title("{bf: log(pcGDI)}", color(black) size(small) box bexpand bcolor("217 217 217")) ///
			ytitle("") xtitle("") ///
			xlabel(1990(5)2012, notick) xscale(noline) ///
			ytick(#3) ylabel(#3) ///
			name("rgdptt_ln_LIC", replace) ///
			plotregion(style(none)) ///
			graphregion(color(white)) ///
			legend(off) ///
			nodraw

		twoway line rgdpl_ln year, lcolor("black") lwidth(medthick) || ///
				scatter rgdpl_ln year if ends == 1, mcolor("black") msize(medium) || ///
			line rgdpl_ln_LIC year, lcolor("blue") lwidth(medthick) || ///
				scatter rgdpl_ln_LIC year if ends == 1, mcolor("blue") msize(medium) || ///
			line rgdpl_ln_nonLIC year, lcolor("green" ) lwidth(medthick) || ///
				scatter rgdpl_ln_nonLIC year if ends == 1, mcolor("green") msize(medium) ///
			title("{bf: log(pcGDP)}", color(black) size(small) box bexpand bcolor("217 217 217")) ///
			ytitle("") xtitle("") ///
			xlabel(1990(5)2012, notick) xscale(noline) ///
			ytick(#3) ylabel(#3) ///
			name("rgdpl_ln_LIC", replace) ///
			plotregion(style(none)) ///
			graphregion(color(white)) ///
			legend(off) ///
			nodraw
			
		twoway line oneplus_ietot_rgdpl_ln year, lcolor("black") lwidth(medthick) || ///
				scatter oneplus_ietot_rgdpl_ln year if ends == 1, mcolor("black") msize(medium) || ///
			line oneplus_ietot_rgdpl_ln_LIC year, lcolor("blue") lwidth(medthick) || ///
				scatter oneplus_ietot_rgdpl_ln_LIC year if ends == 1, mcolor("blue") msize(medium) || ///
			line oneplus_ietot_rgdpl_ln_nonLIC year, lcolor("green" ) lwidth(medthick) || ///
				scatter oneplus_ietot_rgdpl_ln_nonLIC year if ends == 1, mcolor("green") msize(medium) ///
			title("{bf: log(1+IETOT/pcGDP)}", color(black) size(small) box bexpand bcolor("217 217 217")) ///
			ytitle("") xtitle("") ///
			xlabel(1990(5)2012, notick) xscale(noline) ///
			ytick(#3) ylabel(#3) ///
			name("oneplus_ietot_rgdpl_ln_LIC", replace) ///
			plotregion(style(none)) ///
			graphregion(color(white)) ///
			legend(off) ///
			nodraw

		twoway line rents_totnres year, lcolor("black") lwidth(medthick) || ///
				scatter rents_totnres year if ends == 1, mcolor("black") msize(medium) || ///
			line rents_totnres_LIC year, lcolor("blue") lwidth(medthick) || ///
				scatter rents_totnres_LIC year if ends == 1, mcolor("blue") msize(medium) || ///
			line rents_totnres_nonLIC year, lcolor("green" ) lwidth(medthick) || ///
				scatter rents_totnres_nonLIC year if ends == 1, mcolor("green") msize(medium) ///
			title("{bf: Rents/GDP}", color(black) size(small) box bexpand bcolor("217 217 217")) ///
			ytitle("") xtitle("") ///
			xlabel(1990(5)2012, notick) xscale(noline) ///
			ytick(#2) ylabel(#2) ///
			name("rents_totnres_LIC", replace) ///
			plotregion(style(none)) ///
			graphregion(color(white)) ///
			legend(off) ///
			nodraw
				
		graph combine rgdptt_ln_LIC rgdpl_ln_LIC oneplus_ietot_rgdpl_ln_LIC rents_totnres_LIC, row(4) graphregion(color(white)) ///
		note("Data is averaged across countries for each year. 'LIC' indicates Low-Income Country.", size(vsmall))
		graph display, ysize(5) xsize(4)
		graph export "$figures/Analysis_Indepn_LIC.pdf", replace
	
		
*** Graph of Independent Variables - RES
		twoway line rgdptt_ln year, lcolor("black") lwidth(medthick) || ///
				scatter rgdptt_ln year if ends == 1, mcolor("black") msize(medium) /// 
				mlabel(labelAll) mlabposition(3) mlabcolor(black) || ///		
			line rgdptt_ln_RES year, lcolor("blue") lwidth(medthick) || ///
				scatter rgdptt_ln_RES year if ends == 1, mcolor("blue") msize(medium) ///
				mlabel(labelRES) mlabposition(3) mlabcolor(black) || ///
			line rgdptt_ln_nonRES year, lcolor("green" ) lwidth(medthick) || ///
				scatter rgdptt_ln_nonRES year if ends == 1, mcolor("green") msize(medium) ///
				mlabel(labelnonRES) mlabposition(3) mlabcolor(black) ///
			title("{bf: log(pcGDI)}", color(black) size(small) box bexpand bcolor("217 217 217")) ///
			ytitle("") xtitle("") ///
			xlabel(1990(5)2012, notick) xscale(noline) ///
			ytick(#3) ylabel(#3) ///
			name("rgdptt_ln_RES", replace) ///
			plotregion(style(none)) ///
			graphregion(color(white)) ///
			legend(off) ///
			nodraw

		twoway line rgdpl_ln year, lcolor("black") lwidth(medthick) || ///
				scatter rgdpl_ln year if ends == 1, mcolor("black") msize(medium) || ///
			line rgdpl_ln_RES year, lcolor("blue") lwidth(medthick) || ///
				scatter rgdpl_ln_RES year if ends == 1, mcolor("blue") msize(medium) || ///
			line rgdpl_ln_nonRES year, lcolor("green" ) lwidth(medthick) || ///
				scatter rgdpl_ln_nonRES year if ends == 1, mcolor("green") msize(medium) ///
			title("{bf: log(pcGDP)}", color(black) size(small) box bexpand bcolor("217 217 217")) ///
			ytitle("") xtitle("") ///
			xlabel(1990(5)2012, notick) xscale(noline) ///
			ytick(#3) ylabel(#3) ///
			name("rgdpl_ln_RES", replace) ///
			plotregion(style(none)) ///
			graphregion(color(white)) ///
			legend(off) ///
			nodraw
			
		twoway line oneplus_ietot_rgdpl_ln year, lcolor("black") lwidth(medthick) || ///
				scatter oneplus_ietot_rgdpl_ln year if ends == 1, mcolor("black") msize(medium) || ///
			line oneplus_ietot_rgdpl_ln_RES year, lcolor("blue") lwidth(medthick) || ///
				scatter oneplus_ietot_rgdpl_ln_RES year if ends == 1, mcolor("blue") msize(medium) || ///
			line oneplus_ietot_rgdpl_ln_nonRES year, lcolor("green" ) lwidth(medthick) || ///
				scatter oneplus_ietot_rgdpl_ln_nonRES year if ends == 1, mcolor("green") msize(medium) ///
			title("{bf: log(1+IETOT/pcGDP)}", color(black) size(small) box bexpand bcolor("217 217 217")) ///
			ytitle("") xtitle("") ///
			xlabel(1990(5)2012, notick) xscale(noline) ///
			ytick(#3) ylabel(#3) ///
			name("oneplus_ietot_rgdpl_ln_RES", replace) ///
			plotregion(style(none)) ///
			graphregion(color(white)) ///
			legend(off) ///
			nodraw

		twoway line rents_totnres year, lcolor("black") lwidth(medthick) || ///
				scatter rents_totnres year if ends == 1, mcolor("black") msize(medium) || ///
			line rents_totnres_RES year, lcolor("blue") lwidth(medthick) || ///
				scatter rents_totnres_RES year if ends == 1, mcolor("blue") msize(medium) || ///
			line rents_totnres_nonRES year, lcolor("green" ) lwidth(medthick) || ///
				scatter rents_totnres_nonRES year if ends == 1, mcolor("green") msize(medium) ///
			title("{bf: Rents/GDP}", color(black) size(small) box bexpand bcolor("217 217 217")) ///
			ytitle("") xtitle("") ///
			xlabel(1990(5)2012, notick) xscale(noline) ///
			ytick(#2) ylabel(#2) ///
			name("rents_totnres_RES", replace) ///
			plotregion(style(none)) ///
			graphregion(color(white)) ///
			legend(off) ///
			nodraw
				
		graph combine rgdptt_ln_RES rgdpl_ln_RES oneplus_ietot_rgdpl_ln_RES rents_totnres_RES, row(4) graphregion(color(white)) ///
		note("Data is averaged across countries for each year. 'Res' indicates Resource Dependent.", size(vsmall))
		graph display, ysize(5) xsize(4)
		graph export "$figures/Analysis_Indepn_RES.pdf", replace
		

*List countries in regression sample
		
use `datasetRegressions', clear
keep if analysisSample == 1
collapse (mean) resRich lic rgdpl_ln oneplus_ietot_rgdpl_ln, by(Countries)
cd "$tables/CountriesInSample/Regressions/" 

listtex Countries using NonRes_NonLIC.txt if resRich == 0 & lic == 0, rstyle(tabdelim) replace // Non-Resource Dependent & Non-LIC
listtex Countries using Res_LIC.txt       if resRich == 1 & lic == 1, rstyle(tabdelim) replace // Resource Dependent & LIC
listtex Countries using Res_NonLIC.txt    if resRich == 1 & lic == 0, rstyle(tabdelim) replace // Resource Dependent & Non-LIC
listtex Countries using NonRes_LIC.txt    if resRich == 0 & lic == 1, rstyle(tabdelim) replace // Non-Resource Dependent & LIC





