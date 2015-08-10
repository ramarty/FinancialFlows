**************************
**    Financial Flows	**
**        Graphs        **
**						**
**		Rob Marty		**
**     USAID\E3\EP      **
**  Last Updated 8\10   **
**************************

********************************************************************************
********************************************************************************	
** 								INITIAL SETUP                                 **
********************************************************************************
********************************************************************************

* Set file path to financial flows folder
global projectpath "~\Desktop\USAID\ChiefEconomist\FinancialFlows"

global data "$projectpath\Data\"
global tables "$projectpath\Tables\"
global figures "$projectpath\Figures\"

 						*** Install Packages ***
* NOTE: You'll need to install "dm88_1" package. Just enter: "findit dm88_1," and
* install the one package you see. For some reason the ssc command isn't working
* with this, so you need to use findit to search and install. 
* dm88_1 allows you to systematically rename variables with prefixes and suffixes. 


********************************************************************************
********************************************************************************	
** 								MAKING FIGURE                                 **
********************************************************************************
********************************************************************************

use "$data\financialflows_const.dta", clear

*Setup
	*WEIGHTED
	*all dev
		*use "$data\financialflows_const.dta", clear
		collapse (sum) gdp epol_oda epol_oof epol_remittances epol_private, by(year)
		gen epol_official = epol_oda + epol_oof
			lab var epol_official "ODA and other offical flows"
			drop epol_oda epol_oof
		foreach v of varlist gdp-epol_official{
			replace `v' = `v'/1000 //convert to billions
			}
		keep year epol_official epol_remittances epol_private gdp
		gen lic = 3
		order year lic gdp epol_remittances epol_private epol_official
		tempfile availability
		save `availability'
	*lic and other
		use "$data\financialflows_const.dta", clear
		count if lic==2 & year==2012
			global count_lic = `r(N)'
		count if lic==1 & year==2012
			global count_other = `r(N)'
			global count_all = $count_lic + $count_other
		collapse (sum) gdp epol_oda epol_oof epol_remittances epol_private, by(lic year)
		gen epol_official = epol_oda + epol_oof
			lab var epol_official "ODA and other offical flows"
			drop epol_oda epol_oof
		foreach v of varlist gdp-epol_official{
			replace `v' = `v'/1000 //convert to billions
			}
		append using `availability'
			label define lic_2 3 "All", add
		gen ends = 1 if inlist(year, 1995, 2012)
		gen labelo = "Net Official" if year==2012
		gen labelr = "Remittances" if year==2012
		gen labelp = "Net Private" if year==2012
	*stacked area variables
		gen sa_official = epol_official
		gen sa_remittances = sa_official + epol_remittances
		gen sa_private = sa_remittances + epol_private
	*shares of GDP
		foreach f of varlist epol_remittances-epol_official{
			gen sh_`f' = (`f'/gdp)*100
			}
			*end
	tempfile weighted
	save `weighted'
			
		
	*UNWEIGHTED 
	*all dev
		use "$data\financialflows_const.dta", clear
		collapse (mean) gdp epol_oda epol_oof epol_remittances epol_private, by(year ctry)
		gen epol_official = epol_oda + epol_oof
			lab var epol_official "ODA and other offical flows"
			drop epol_oda epol_oof
		foreach v of varlist gdp-epol_official{
			replace `v' = `v'/1000 //convert to billions
			}
		keep year epol_official epol_remittances epol_private gdp
		gen lic = 3
		order year lic gdp epol_remittances epol_private epol_official
		tempfile availability
		save `availability'
	*lic and other
		use "$data\financialflows_const.dta", clear
		count if lic==2 & year==2012
			global count_lic = `r(N)'
		count if lic==1 & year==2012
			global count_other = `r(N)'
			global count_all = $count_lic + $count_other
		collapse (mean) gdp epol_oda epol_oof epol_remittances epol_private, by(lic year ctry)
		gen epol_official = epol_oda + epol_oof
			lab var epol_official "ODA and other offical flows"
			drop epol_oda epol_oof
		foreach v of varlist gdp-epol_official{
			replace `v' = `v'/1000 //convert to billions
			}
		append using `availability'
			label define lic_2 3 "All", add
	*shares of GDP
		foreach f of varlist epol_remittances-epol_official{
			gen sh_`f' = (`f'/gdp)*100
			}
			*end				
	collapse (mean) gdp epol_remittances epol_private epol_official sh_epol_remittances sh_epol_private sh_epol_official, by(lic year)
	renvars gdp epol_remittances epol_private epol_official sh_epol_remittances sh_epol_private sh_epol_official, prefix(uw_)
	
	merge 1:1 year lic using `weighted', nogen

	*Area graphs ***************************************************************
	*establish locals for loop
		local name1 alldev_area
		local name2 lic_area
		local name3 othdev_area
		local group1 "lic==3"
		local group2 "lic==2"
		*local group3 "lic==1"
		local title1 "Total Current Billions (USD)"
		local title2 ""
		local title3 ""
		local ytitle1 "All Developing (n=$count_all)"
		local ytitle2 "LICs (n=$count_lic)"
		local ytitle3 "Other Developing (n=$count_other)"
		local ylabel1 0(100)600
		local ylabel2 0(10)50
		local ylabel3 0(100)600
	*graphs
	* http://www.statalist.org\forums\forum\general-stata-discussion\general\257534-getting-bold-and-italics-simultaneously-via-%7Bbf-and-%7Bit
		*forvalues i = 1\2{
			twoway area sa_private sa_remittances sa_official year if lic==3, ///
				xlabel(1995(5)2012, notick labsize(small)) xscale(noline) ///
				ylabel(0(100)600, grid angle(0) notick labsize(small) labstyle(right)) yscale(noline) ///
				legend(off) ///
				title("{bf:Total Current Billions (USD)}", size(medsmall) color(black)) ///
				ytitle("{bf:All Developing (n=$count_all)}", color(black) box bexpand bcolor("217 217 217")  size(medsmall)) xtitle("") ///
				name(alldev_area, replace) ///
				plotregion(style(none)) ///
				graphregion(color(white)) ///
				color("1 28 88" "179 0 44" "83 83 83") ///
				fcolor("1 28 88" "179 0 44" "83 83 83") ///
				lpattern(solid solid solid) ///
				text(30 2008.7 "Net Official Flows", size(small) color(white)) ///
				text(180 2009 "Remittances", size(small) color(white)) ///
				text(235 2000.7 "Net Private Flows", size(small) color("1 28 88")) ///
				text(490 2001 "{bf:Total net private flows and}" ///
				"{bf:remittances outstrip total net}" ///
				"{bf:flows from official donors, but}" ///
				"{bf:this is driven by a handful of}" ///
				"{bf:larger economies.}", size(*.73) color(black) just(left)) ///
				nodraw
								
			twoway area sa_private sa_remittances sa_official year if lic==2, ///
				xlabel(1995(5)2012, notick labsize(small)) xscale(noline) ///
				ylabel(0(10)40, grid angle(0) notick labsize(small) labstyle(right)) yscale(noline) ///
				legend(off) ///
				ytitle("{bf: LICs (n=$count_lic)}", color(black) box bexpand bcolor("217 217 217")  size(medsmall)) xtitle("") ///
				name(lic_area, replace) ///
				plotregion(style(none)) ///
				graphregion(color(white)) ///
				color("1 28 88" "179 0 44" "83 83 83") ///
				fcolor("1 28 88" "179 0 44" "83 83 83") ///
				lpattern(solid solid solid) ///
				text(35 2001 "{bf:For low income countries,}" ///
				"{bf:private flows remain negligible}" ///
				"{bf:by comparison to remittances}" ///
				"{bf:and donor flows.}", size(*.73) color(black) just(left)) ///
				nodraw

				*}
				*end
				
				
		*Official: 1 28 88
		*Remittances: 179 0 44
		*Private: 83 83 83
		
				
	*Shares of GDP Graphs ****************************************************
	*establish locals for loop
		local name1 alldev_share
		local name2 lic_share
		*local name3 othdev_share
		local group1 "lic==3"
		local group2 "lic==2"
		*local group3 "lic==1"
		local title1 "Share of GDP, %"
		local title2 ""
		*local title3 ""
		local ylabel1 -5(5)10
		local ylabel2 -10(5)20
		*local ylabel3 -5(5)10
		local weightType1 ""
		local weightType2 ""
		*local weightType3 ""
		
		local name3 uw_alldev_share
		local name4 uw_lic_share
		*local name6 uw_othdev_share
		local group3 "lic==3"
		local group4 "lic==2"
		*local group6 "lic==1"
		local title3 "Average Share of GDP (as a Percentage)"
		local title4 ""
		*local title6 ""
		local ylabel3 -3 "-3%" 0 "0%" 3 "3%" 6 "6%" 9 "9%" // ylabel(0 "0%" 20 "20%"  40 "40%" 60 "60%") -5(5)10 
		local ylabel4 -10 "-10%" -5 "-5%" 0 "0%" 5 "5%" 10 "10%" 15 "15%" 20 "20%" // -10(5)20
		*local ylabel6 -5(5)10
		local weightType3 "uw_"
		local weightType4 "uw_"
		*local weightType6 "uw_"

		*Official: 83 83 83
		*Remittances: 179 0 44
		*Private: 1 28 88
		
	*graphs 
		*forvalues i = 1\4{
		
			twoway line uw_sh_epol_official year if lic==3, lcolor("83 83 83" ) lpattern(solid) lwidth(medthick) ylabel(-3 "-3%" 0 "0%" 3 "3%" 6 "6%" 9 "9%") || ///
				scatter uw_sh_epol_official year if lic==3 & ends==1, msize(large) mcolor("83 83 83") ylabel(-3 "-3%" 0 "0%" 3 "3%" 6 "6%" 9 "9%") || ///
				scatter uw_sh_epol_official year if ends==1 & lic==3, msize(large) ///
					mcolor("83 83 83") mlabel(labelo) mlabposition(3) mlabcolor(black) || ///
				line uw_sh_epol_remittances year if lic==3, lcolor("179 0 44" ) lpattern(shortdash) lwidth(medthick) ylabel(-3 "-3%" 0 "0%" 3 "3%" 6 "6%" 9 "9%") || ///
				scatter uw_sh_epol_remittances year if lic==3 & ends==1, msize(large) mcolor("179 0 44") ylabel(-3 "-3%" 0 "0%" 3 "3%" 6 "6%" 9 "9%") || ///
				scatter uw_sh_epol_remittances year if ends==1 & lic==3, msize(large) ///
					mcolor("179 0 44") mlabel(labelr) mlabposition(3) mlabcolor(black) || ///
				line uw_sh_epol_private year if lic==3, lcolor("1 28 88") lpattern(dash) lwidth(medthick) ylabel(-3 "-3%" 0 "0%" 3 "3%" 6 "6%" 9 "9%") || ///
				scatter uw_sh_epol_private year if lic==3 & ends==1, msize(large) mcolor("1 28 88")  || ///
				scatter uw_sh_epol_private year if ends==1 & lic==3, msize(large) ///
					mcolor("1 28 88") mlabel(labelp) mlabposition(3) mlabcolor(black)  ///
				legend(off) ///
				title("{bf:Average Share of GDP (as a Percentage)}", color(black) size(medsmall)) ///
				ytitle("") xtitle("") ///
				xlabel(1995(5)2012, notick labsize(small)) xscale(noline) ///
				xscale(range(2015)) ///
				ylabel(-3 "-3%" 0 "0%" 3 "3%" 6 "6%" 9 "9%", angle(0) notick labsize(small)) yscale( noline) ///
				name(uw_alldev_share, replace) ///
				plotregion(style(none)) ///
				text(.053 2013.779 "Flows", size(small) color(black)) ///
				text(3.0 2013.779 "Flows", size(small) color(black)) ///
				graphregion(color(white)) ///
				text(8 2007.5 "{bf:For the average country, official flows are declining}" ///
				"{bf:in importance but remain larger than private flows.}", size(*.73) color(black) just(left)) ///
				nodraw	
				
				
		
			twoway line uw_sh_epol_official year if lic==2, lcolor("83 83 83" ) lpattern(solid) lwidth(medthick) ylabel(-10 "-10%" -5 "-5%" 0 "0%" 5 "5%" 10 "10%" 15 "15%" 20 "20%") || ///
				scatter uw_sh_epol_official year if lic==2 & ends==1, msize(large) mcolor("83 83 83") ylabel(-10 "-10%" -5 "-5%" 0 "0%" 5 "5%" 10 "10%" 15 "15%" 20 "20%") || ///
				line uw_sh_epol_remittances year if lic==2, lcolor("179 0 44" ) lpattern(shortdash) lwidth(medthick) ylabel(-10 "-10%" -5 "-5%" 0 "0%" 5 "5%" 10 "10%" 15 "15%" 20 "20%") || ///
				scatter uw_sh_epol_remittances year if lic==2 & ends==1, msize(large) mcolor("179 0 44") ylabel(-10 "-10%" -5 "-5%" 0 "0%" 5 "5%" 10 "10%" 15 "15%" 20 "20%") || ///
				line uw_sh_epol_private year if lic==2, lcolor("1 28 88") lpattern(dash) lwidth(medthick) ylabel(-10 "-10%" -5 "-5%" 0 "0%" 5 "5%" 10 "10%" 15 "15%" 20 "20%") || ///
				scatter uw_sh_epol_private year if lic==2 & ends==1, msize(large) mcolor("1 28 88")  ///
				scatter uw_sh_epol_private year if lic==2 & ends==1, msize(large) mcolor("1 28 88")  ///
				scatter uw_sh_epol_private year if lic==2 & ends==1, msize(large) mcolor("1 28 88")  ///
				legend(off) ///
				ytitle("") xtitle("") ///
				xlabel(1995(5)2012, notick labsize(small)) xscale(noline) ///
				xscale(range(2015)) ///
				ylabel(-5 "-5%" 0 "0%" 5 "5%" 10 "10%" 15 "15%" 20 "20%", angle(0) notick labsize(small)) yscale( noline) ///
				name(uw_lic_share, replace) ///
				plotregion(style(none)) ///
				graphregion(color(white)) ///
				text(18 2006 "{bf:Again, for the typical LIC, aid is much}" ///
				"{bf:more important than other flows.}", size(*.73) color(black) just(left)) ///
				nodraw	
				*
				*end
				
	*combine graphs
		graph combine alldev_area uw_alldev_share lic_area  uw_lic_share, row(2) col(2) ///
			graphregion(color(white)) nodraw ///
			title("{bf: Financial Flows Across Income Levels}", color(black) box bexpand bcolor("217 217 217") size(small)) ///
			note("Sources: Net Official and Net Private Flows, OECD; Remittances and GDP, The World Bank." ///
				"Notes: The sample consists of the 77 developing countries with data for both 1995 and 2012; missing observations between 1995" /// 
				"and 2012 are linearly interpolated; shares are unweighted averages across countries.", ///
				size(vsmall))
		graph display, ysize(4) xsize(5)
		graph export "$figures\Fig6_ExtPovVision.pdf", replace
		

			
	
