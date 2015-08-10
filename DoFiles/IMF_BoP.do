**************************
**  Balance of Payments **
**                      ** 
**                      **
**		Rob Marty		**
**     USAID\E3\EP      **
**  Last Updated 8\10   **
**************************

********************************************************************************	
* Initial Set-Up  

* Set file path to financial flows folder
global projectpath "~\Desktop\USAID\ChiefEconomist\FinancialFlows"

global data "$projectpath\Data\"
global tables "$projectpath\Tables\"
global figures "$projectpath\Figures\"
global BOPfolder "$projectpath\RawData\BoP\"
global BOPrawData "$projectpath\RawData\BoP\IMF_Data\"

********************************************************************************
***** Importing and Keeping Useful Variables
import delimited "$BOPrawData\Data.csv", clear
drop datasourcelabel datasourcecode frequencylabel frequencycode timecode unitcode statuslabel statuscode countrycode
duplicates drop countrylabel timelabel value conceptcode unitlabel, force
save  "$BOPfolder\Data.dta", replace

********************************************************************************
***** Converting All Values to US Dollar
use  "$BOPfolder\Data.dta", clear
keep if unitlabel == "National Currency per US Dollar"
keep countrylabel timelabel value
rename value natCurPerUSDol
tempfile natCurPerUSDol
save `natCurPerUSDol'

use  "$BOPfolder\Data.dta", clear
keep if unitlabel == "ECU per National Currency"
keep countrylabel timelabel value
rename value ECUperNatCur
tempfile ECUperNatCur
save `ECUperNatCur'

use  "$BOPfolder\Data.dta", clear
merge m:1 countrylabel timelabel using `natCurPerUSDol', nogen
merge m:1 countrylabel timelabel using `ECUperNatCur', nogen

** Converting values in Euros to national currency
replace value = value / ECUperNatCur if unitlabel == "Euros"
replace unitlabel = "National Currency" if unitlabel == "Euros"

** Converting values in national currency to US dollar
replace value = value / natCurPerUSDol if unitlabel == "National Currency" | unitlabel == "National Currency, Adjusted at Annual Rates" | unitlabel == "National Currency, Seasonally Adjusted" | unitlabel == "National Currency, Seasonally Adjusted, Adjusted at Annual Rates"
replace unitlabel = "US Dollars" if unitlabel == "National Currency" | unitlabel == "National Currency, Adjusted at Annual Rates" | unitlabel == "National Currency, Seasonally Adjusted" | unitlabel == "National Currency, Seasonally Adjusted, Adjusted at Annual Rates"

drop if conceptcode == "ENDA" | conceptcode == "EENA"
drop natCurPerUSDol ECUperNatCur unitlabel

********************************************************************************
***** Change data into panel dataset
keep if conceptcode == "BXG"
drop conceptlabel conceptcode value 
save  "$BOPfolder\Base.dta", replace

foreach IFScode in BXG BMG BXS BMS BICXT BIDXT BXITA BMIT BKAA_CD BK_DB BFDA BFDIA BFPXFDA BFPXFDL BFOA BFOLA BFOAA BFOLAA BFPADF BFPLF BOP NX NFI NINV NM {
	use  "$BOPfolder\Data.dta", clear
	qui keep if conceptcode == "`IFScode'"
	renvars value, prefix(`IFScode'_)
	drop conceptlabel conceptcode unitlabel
	qui merge m:m timelabel countrylabel using "$BOPfolder\Base.dta", nogen
	qui save "$BOPfolder\Base.dta", replace
}

********************************************************************************
***** Changing variable names and assigning value labels

rename BKAA_CD_value kaniecre 
rename BK_DB_value kaniedeb 
rename BFDIA_value fdicre 
rename BFDA_value fdideb 
rename BFOLA_value oicre 
rename BFOA_value oideb 
rename BFPXFDL_value picre 
rename BFPXFDA_value pideb 
rename BFPLF_value findercre 
rename BFPADF_value finderdeb 
rename BOP_value neterrom 
rename BFOLAA_value oimacre 
rename BFOAA_value oimadeb 
rename BXG_value expfob 
rename BMG_value impfob 
rename BXS_value sercre 
rename BMS_value serdeb 
rename BICXT_value inccre 
rename BIDXT_value incdeb 
rename BXITA_value ctrcre 
rename BMIT_value ctrdeb 
rename NX_value exports 
rename NM_value imports 
rename NFI_value gfkf 
rename NINV_value chstocks 

la var kaniecre "BKAA_CD: Capital Account, N.I.E.: Credit"
la var kaniedeb "BK_DB: Capital Account, Debit"
la var fdicre "BFDIA: Dir. Invest. in Rep. Econ., N.I.E."
la var fdideb "BFDA: Direct Investment Abroad"
la var oicre "BFOLA: Other investment Liab., N.I.E."
la var oideb "BFOA: Other Investment Assets"
la var picre "BFPXFDL: Portfolio Investment Liab., N.I.E."
la var pideb "BFPXFDA: Portfolio Investment Assets"
la var findercre "BFPLF: Finan Derivatives: Liabil"
la var finderdeb "BFPADF: Finan Derivatives: Assets"
la var neterrom "BOP: Net Errors and Omissions"
la var oimacre "BFOLAA: OI Mon Auth Liab"
la var oimadeb "BFOAA: OI Mon Auth Assets"
la var expfob "BXG: Goods Exports: F.O.B."
la var impfob "BMG: Goods Imports: F.O.B."
la var sercre "BXS: Services: Credit"
la var serdeb "BMS: Services: Debit"
la var inccre "BICXT: Income: Credit"
la var incdeb "BIDXT: Income: Debit"
la var ctrcre "BXITA: Current Transfers, N.I.E.: Cre"
la var ctrdeb "BMIT: Current Transfers: Deb"
la var exports "NX: Exports of Goods & Services"
la var imports "NM: Imports of Goods & Services"
la var gfkf "NFI: Gross Fixed Capital Formation"
la var chstocks "NINV: Changes in Inventories"

replace countrylabel = "Afghanistan" if countrylabel == "Afghanistan, Islamic Republic of"
replace countrylabel = "Armenia" if countrylabel == "Armenia, Republic of"
replace countrylabel = "Azerbaijan" if countrylabel == "Azerbaijan, Republic of"
replace countrylabel = "Bahrain" if countrylabel == "Bahrain, Kingdom of"
replace countrylabel = "China" if countrylabel == "China, P.R.: Mainland"
replace countrylabel = "Hong Kong SAR, China" if countrylabel == "China, P.R.: Hong Kong"
replace countrylabel = "Congo, Dem. Rep." if countrylabel == "Congo, Democratic Republic of"
replace countrylabel = "Congo, Rep." if countrylabel == "Congo, Republic of"
replace countrylabel = "Egypt, Arab Rep." if countrylabel == "Egypt"
replace countrylabel = "Iran, Islamic Rep." if countrylabel == "Iran, Islamic Republic of"
replace countrylabel = "Korea, Rep." if countrylabel == "Korea, Republic of"
replace countrylabel = "Lao PDR" if countrylabel == "Lao People's Democratic Republic"
replace countrylabel = "Macao SAR, China" if countrylabel == "China, P.R.: Macao"
replace countrylabel = "Serbia" if countrylabel == "Serbia, Republic of"
replace countrylabel = "Timor-Leste" if countrylabel == "Timor-Leste, Dem. Rep. of"
replace countrylabel = "Venezuela, RB" if countrylabel == "Venezuela, Republica Bolivariana de"
replace countrylabel = "Yemen, Rep." if countrylabel == "Yemen, Republic of"

duplicates drop countrylabel timelabel, force
rename countrylabel ctrys
rename timelabel year
save  "$BOPfolder\BoP_Data.dta", replace

********************************************************************************
***** Merging BoP dataset with Financial Flow Dataset
use  "$data\financialflows.dta", clear 
decode ctry, generate(ctrys)
drop if ctry == .
merge 1:1 ctrys year using "$BOPfolder\BoP_Data.dta"
save "$BOPfolder\BoP_Data_IFSAvailability.dta", replace

********************************************************************************
***** LIC and Only Dev and Transition ***
use "$BOPfolder\BoP_Data_IFSAvailability.dta", clear
*gen lic = 2 if inclvl_wb == 3
*replace lic = 1 if inclvl_wb != 3

keep if devstatus == 2 | devstatus == 3
save "$BOPfolder\BoP_Data_IFSAvailability.dta", replace

********************************************************************************
***** Gross Financial Trade
use "$BOPfolder\BoP_Data_IFSAvailability.dta", clear
qui g abscap_imf = abs(kaniecre) + abs(kaniedeb)
foreach v in picre pideb oicre oideb{
	g a_`v' = abs(`v')
}
qui egen absfin_imf = rowtotal(a_picre a_pideb a_oicre a_oideb), m
qui g absnero_imf = abs(neterrom)
qui g abska_imf = abscap_imf + absfin_imf
qui g abskae_imf = abska_imf + absnero_imf
foreach v in abscap absfin absnero abska abskae{
	 qui g `v'_imfy = 100 *`v'_imf / (gdp*1000000)
}
save "$BOPfolder\BoP_Data_IFSAvailability.dta", replace
collapse (mean) abscap_imfy absfin_imfy absnero_imfy abska_imfy abskae_imfy, by(year lic)
keep if year >= 1980 & year <= 2008
gen ends = 1 if inlist(year, 1980, 2008)
gen labelLIC = "LIC" if year==2008
gen labelnonLIC = "non-LIC" if year==2008

twoway line abskae_imfy year if lic == 1, lcolor("179 0 44") lwidth(medthick) || ///
			scatter abskae_imfy year if lic == 1 & ends == 1, msize(large) mcolor("179 0 44")  ///
			mlabel(labelnonLIC) mlabposition(6) mlabcolor(black) || ///
	   line abskae_imfy year if lic == 2, lcolor("1 28 88") lwidth(medthick) || ///
			scatter abskae_imfy year if lic == 2 & ends == 1, msize(large) mcolor("1 28 88")  ///
			mlabel(labelLIC) mlabposition(6) mlabcolor(black) ///
	   ti("{bf:Gross Financial Trade Flows}", size(medsmall)) ///
	   legend(off) ///
	   yti("Percent of GDP") ///
	   plotregion(style(none)) ///
	   note("Values are averaged across countries") ///
	   graphregion(color(white))

graph export "$figures\GrossFinancialTrade.pdf", replace
  	   
********************************************************************************
***** Gross Trade
use "$BOPfolder\BoP_Data_IFSAvailability.dta", clear
qui g absg_imf = abs(expfob) + abs(impfob)
qui g absgs_imf = absg_imf + abs(sercre) + abs(serdeb)
qui g absgsi_imf = absgs_imf + abs(inccre) + abs(incdeb)
qui g absca_imf = absgsi_imf + abs(ctrcre) + abs(ctrdeb)
foreach v in absg absgs absgsi absca{
	 g `v'_imfy = 100*`v'_imf / (gdp*1000000)
}
save "$BOPfolder\BoP_Data_IFSAvailability.dta", replace
collapse (mean) absg_imfy absgs_imfy absgsi_imfy absca_imfy, by(year lic)
keep if year >= 1980

twoway area absca_imfy absgsi_imfy absgs_imfy absg_imfy year if lic == 1 & year < 2008, /// 
c(L L L L) ///
lwidth(medthick medthick medthick medthick) ///
m(p p p p) ///
yti(Percent of GDP) ///
ti("{bf:non-LICs}", size(medsmall)) ///
legend(label(1 "Transfers") label(2 "Income") label(3 "Services") label(4 "Goods")) ///
legend(off) ///
plotregion(style(none)) ///
graphregion(color(white)) ///
ylabel(0(50)150, notick) xscale(noline) ///
name(grossTradenonLIC, replace)

twoway area absca_imfy absgsi_imfy absgs_imfy absg_imfy   year if lic == 2 & year < 2008, ///
c(L L L L) ///
lwidth(medthick medthick medthick medthick) ///
m(p p p p) ///
yti(Percent of GDP) ///
ti("{bf:LICs}", size(medsmall)) ///
legend(label(1 "Transfers") label(2 "Income") label(3 "Services") label(4 "Goods")) ///
ylabel(0(50)100, notick) xscale(noline) ///
legend(on) ///
plotregion(style(none)) ///
graphregion(color(white)) ///
name(grossTradeLIC, replace)

graph combine grossTradenonLIC grossTradeLIC , ///
row(2) col(1) ///
plotregion(style(none)) ///
graphregion(color(white)) ///
ti("{bf:Gross Trade Flows: Current Account}", size(medium)) ///
note("Values are averaged across countries") 

graph display, ysize(5) xsize(4)

graph export "$figures\GrossTrade.pdf", replace

********************************************************************************
***** Gross Financial Trade as Ratio to Gross Total
use "$BOPfolder\BoP_Data_IFSAvailability.dta", clear

qui g finshare = 100*abskae_imf / (abskae_imf + absca_imf)
collapse (mean) finshare, by(year lic)
keep if year >= 1980 & year <= 2008
gen ends = 1 if inlist(year, 1980, 2008)
gen labelLIC = "LIC" if year==2008
gen labelnonLIC = "non-LIC" if year==2008

twoway line finshare year if lic == 1, lcolor("179 0 44") lwidth(medthick) || ///
			scatter finshare year if lic == 1 & ends == 1, msize(large) mcolor("179 0 44")  ///
			mlabel(labelnonLIC) mlabposition(3) mlabcolor("179 0 44") || ///
	   line finshare year if lic == 2, lcolor("1 28 88") lwidth(medthick) || ///
			scatter finshare year if lic == 2 & ends == 1, msize(large) mcolor("1 28 88")  ///
			mlabel(labelLIC) mlabposition(6) mlabcolor("1 28 88") ///
	   ti("{bf:Ratio of gross KA trade to gross CA trade}", size(medsmall)) ///
	   legend(off) ///
	   yti(Percent) ///
	   plotregion(style(none)) ///
	   note("Values are averaged across countries") ///
	   graphregion(color(white))

graph export "$figures\GrossFinancialTRatioTrade.pdf", replace

