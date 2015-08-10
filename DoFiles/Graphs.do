**************************
**    Financial Flows	**
**        Graphs        **
**						**
**		Rob Marty		**
**     USAID/E3/EP      **
**  Last Updated 7/##   **
**************************


********************************************************************************
********************************************************************************	
** 								INITIAL SETUP                                 **
********************************************************************************
********************************************************************************

* Set file path to financial flows folder
global projectpath "~/Desktop/USAID/ChiefEconomist/FinancialFlows/"

global data "$projectpath/Data/"
global tables "$projectpath/Tables/"
global figures "$projectpath/Figures/"

 						*** Install Packages ***
* NOTE: You'll need to install "dm88_1" package. Just enter: "findit dm88_1," and
* install the one package you see. For some reason the ssc command isn't working
* with this, so you need to use findit to search and install. 
* dm88_1 allows you to systematically rename variables with prefixes and suffixes. 

********************************************************************************
********************************************************************************
							*** FIGURE 1 ***
********************************************************************************
********************************************************************************


*Setup
	*availability sample
		use "$data/financialflows.dta", clear
		collapse (sum) oda oof remittances private, by(year)
		gen official = oda + oof
			lab var official "ODA and other offical flows"
		drop if year<1995 | year>2012
		keep year official remittances private
		tempfile availability
		save `availability'
	*constant sample
		use "$data/financialflows_const.dta", clear				
		count if lic==2 & year==2012
			global count_lic = `r(N)'
		count if lic==1 & year==2012
			global count_other = `r(N)'
			global count_all = $count_lic + $count_other
		
		collapse (sum) epol_oda epol_oof epol_remittances epol_private, by(year)
		gen epol_official = epol_oda + epol_oof
			lab var epol_official "ODA and other offical flows"
			drop epol_oda epol_oof
		merge 1:1 year using `availability', nogen
		foreach v of varlist epol_remittances-official{
			replace `v' = `v'/1000 //convert to billions
			} 
		gen ends = 1 if inlist(year, 1995, 2012)
		gen labela = "Availability" if year==2012
		gen labelc = "Constant" if year==2012
		
	*shares
		gen totflow_c = epol_remittances + epol_private + epol_official
		gen totflow_a = remittances + private + official
		foreach f of varlist epol_remittances-epol_official{
			gen sh_`f' = (`f'/totflow_c)*100
			}
			*end
		foreach f of varlist remittances-official{
			gen sh_`f' = (`f'/totflow_a)*100
			}
			*end
	
*Graph
	*Panel A
	*establish locals for loop
		local flow1 official 
		local flow2 remittances
		local flow3 private
		local color1 "15 111 198" 
		local color2 "16 207 115" 
		local color3 "4 97 123"
		local title1 "Net Official (ODA + OOF)" 
		local title2 "Remittances" 
		local title3 "Net Private"
		local yscale1 ""
		local yscale2 off
		local yscale3 off
	*graphs
		forvalues i = 1/3{
			twoway line epol_`flow`i'' year, lcolor("`color`i''") lwidth(medthick) || ///
				scatter epol_`flow`i'' year if ends==1, msize(large) mcolor("`color`i''") || ///
				scatter epol_`flow`i'' year if ends==1 & `i'==3, msize(medlarge) ///
					mcolor("`color`i''") mlabel(labelc) mlabposition(6) mlabcolor(black) || ///
				line `flow`i'' year, lcolor("166 166 166") lwidth(medthick) || ///
				scatter `flow`i'' year if ends==1, msize(large) mcolor("166 166 166") || ///
				scatter `flow`i'' year if ends==1 & `i'==3, msize(large) ///
					mcolor("166 166 166") mlabel(labela) mlabposition(6) mlabcolor(black) ///
				legend(off) ///
				title("`title`i''", color(black)) ///
				ytitle("") xtitle("") ///
				xlabel(1995(5)2012, notick) xscale(noline) ///
				ylabel(, grid angle(0) notick) yscale(`yscale`i'' noline) ///
				name(`flow`i'', replace) ///
				plotregion(style(none)) ///
				graphregion(color(white)) ///
				nodraw				
				}
				*end
		graph combine official remittances private, ycommon row(1) nodraw ///
			graphregion(color(white)) ///
			title("Financial Flows in billions of current USD", color(black) box bexpand bcolor("217 217 217")) ///
			name(panela, replace)
		graph display, ysize(2) xsize(4)
	
	*Panel B
	*establish locals for loop
		local flow1 official 
		local flow2 remittances
		local flow3 private
		local color1 "15 111 198" 
		local color2 "16 207 115" 
		local color3 "4 97 123"
		local title1 "Net Official (ODA + OOF)" 
		local title2 "Remittances" 
		local title3 "Net Private"
		local yscale1 ""
		local yscale2 off
		local yscale3 off
	*graphs
		forvalues i = 1/3{
			twoway line sh_epol_`flow`i'' year, lcolor("`color`i''") lwidth(medthick) || ///
				scatter sh_epol_`flow`i'' year if ends==1, msize(large) mcolor("`color`i''") || ///
				line sh_`flow`i'' year, lcolor("166 166 166") lwidth(medthick) || ///
				scatter sh_`flow`i'' year if ends==1, msize(large) mcolor("166 166 166") ///
				legend(off) ///
				title("`title`i''", color(black)) ///
				ytitle("") xtitle("") ///
				xlabel(1995(5)2012, notick) xscale(noline) ///
				ylabel(, grid angle(0) notick) yscale(`yscale`i'' noline) ///
				name(`flow`i'', replace) ///
				plotregion(style(none)) ///
				graphregion(color(white)) ///
				nodraw				
				}
				*end
		graph combine official remittances private, ycommon row(1) nodraw ///
			graphregion(color(white)) ///
			title("Financial Flows, share of total flows (%)", color(black) box bexpand bcolor("217 217 217")) ///
			note("Source: Official and Private Flows (OECD); Remittances (The World Bank)" ///
				"Note: Sample of $count_all countries constant across all 12 years; interpolated where data was missing", ///
				size(vsmall)) name(panelb, replace)
		graph display, ysize(2) xsize(4)
		
	*Combine Panel A and B
		graph combine panela panelb, row(2) ///
		graphregion(color(white))
		
		graph export "$figures/ff_fig1.pdf", replace
		

graph drop _all
********************************************************************************
********************************************************************************
							*** FIGURE 2a ***
********************************************************************************
********************************************************************************

*Setup
	*all dev
		use "$data/financialflows_const.dta", clear
		collapse (sum) epol_oda epol_oof epol_remittances epol_private, by(year)
		gen epol_official = epol_oda + epol_oof
			lab var epol_official "ODA and other offical flows"
			drop epol_oda epol_oof
		foreach v of varlist epol_remittances-epol_official{
			replace `v' = `v'/1000 //convert to billions
			}
		keep year epol_official epol_remittances epol_private
		gen lic = 3
		order year lic epol_remittances epol_private epol_official
		tempfile availability
		save `availability'
	*lic and other
		use "$data/financialflows_const.dta", clear
		count if lic==2 & year==2012
			global count_lic = `r(N)'
		count if lic==1 & year==2012
			global count_other = `r(N)'
			global count_all = $count_lic + $count_other
		collapse (sum) epol_oda epol_oof epol_remittances epol_private, by(lic year)
		gen epol_official = epol_oda + epol_oof
			lab var epol_official "ODA and other offical flows"
			drop epol_oda epol_oof
		foreach v of varlist epol_remittances-epol_official{
			replace `v' = `v'/1000 //convert to billions
			}
		append using `availability'
			label define lic_2 3 "All", add
		gen ends = 1 if inlist(year, 1995, 2012)
		gen labelo = "Official" if year==2012
		gen labelr = "Remittances" if year==2012
		gen labelp = "Private" if year==2012
	*stacked area variables
		gen sa_official = epol_official
		gen sa_remittances = sa_official + epol_remittances
		gen sa_private = sa_remittances + epol_private
	*shares
		gen totflow_c = epol_remittances + epol_private + epol_official
		foreach f of varlist epol_remittances-epol_official{
			gen sh_`f' = (`f'/totflow_c)*100
			}
			*end
	
	
	*Area graphs
	*establish locals for loop
		local name1 alldev_area
		local name2 lic_area
		local name3 othdev_area
		local group1 "lic==3"
		local group2 "lic==2"
		local group3 "lic==1"
		local title1 "Total current billions USD"
		local title2 ""
		local title3 ""
		local ytitle1 "All Developing (n=$count_all)"
		local ytitle2 "LIC (n=$count_lic)"
		local ytitle3 "Other Developing (n=$count_other)"
		local ylabel1 0(100)600
		local ylabel2 0(10)60
		local ylabel3 0(100)600
	*graphs
		forvalues i = 1/3{
			twoway area sa_private sa_remittances sa_official year if `group`i'', ///
				xlabel(1995(5)2012, notick) xscale(noline) ///
				ylabel(`ylabel`i'', grid angle(0) notick) yscale(noline) ///
				legend(off) ///
				title("`title`i''", color(black)) ///
				ytitle("{bf:`ytitle`i''}") xtitle("") ///
				name(`name`i'', replace) ///
				plotregion(style(none)) ///
				graphregion(color(white)) ///
				color("4 97 123" "16 207 115" "15 111 198") ///
				nodraw	
				}
				*end
	
	*Shares of Total Graphs
	*establish locals for loop
		local name1 alldev_share
		local name2 lic_share
		local name3 othdev_share
		local group1 "lic==3"
		local group2 "lic==2"
		local group3 "lic==1"
		local title1 "Share of Total, %"
		local title2 ""
		local title3 ""
		local ylabel1 0(25)100
		local ylabel2 0(25)100
		local ylabel3 0(25)100
	*graphs 
		forvalues i = 1/3{
			twoway line sh_epol_official year if `group`i'', lcolor("15 111 198" ) lwidth(medthick) ylabel(`ylabel`i'') || ///
				scatter sh_epol_official year if `group`i'' & ends==1, msize(large) mcolor("15 111 198") ylabel(`ylabel`i'') || ///
				scatter sh_epol_official year if ends==1 & `group`i'' & `i'==1, msize(large) ///
					mcolor("15 111 198") mlabel(labelo) mlabposition(6) mlabcolor(black) || ///
				line sh_epol_remittances year if `group`i'', lcolor("16 207 115" ) lwidth(medthick) ylabel(`ylabel`i'') || ///
				scatter sh_epol_remittances year if `group`i'' & ends==1, msize(large) mcolor("16 207 115") ylabel(`ylabel`i'') || ///
				scatter sh_epol_remittances year if ends==1 & `group`i'' & `i'==1, msize(large) ///
					mcolor("16 207 115") mlabel(labelr) mlabposition(12) mlabcolor(black) || ///
				line sh_epol_private year if `group`i'', lcolor("4 97 123") lwidth(medthick) ylabel(`ylabel`i'') || ///
				scatter sh_epol_private year if `group`i'' & ends==1, msize(large) mcolor("4 97 123")  || ///
				scatter sh_epol_private year if ends==1 & `group`i'' & `i'==1, msize(large) ///
					mcolor("4 97 123") mlabel(labelp) mlabposition(12) mlabcolor(black)  ///
				legend(off) ///
				title("`title`i''", color(black)) ///
				ytitle("") xtitle("") ///
				xlabel(1995(5)2012, notick) xscale(noline) ///
				ylabel(0(25)100, angle(0) notick) yscale( noline) ///
				name(`name`i'', replace) ///
				plotregion(style(none)) ///
				graphregion(color(white)) ///
				nodraw				
				}
				*end
				
	*combine graphs
		graph combine alldev_area alldev_share lic_area lic_share othdev_area othdev_share, row(3) col(2) ///
			graphregion(color(white)) nodraw ///
			title("Financial Flows Across Income Levels", color(black) box bexpand bcolor("217 217 217") size(medsmall)) ///
			note("Source: Official and Private Flows (OECD); Remittances (The World Bank)" ///
				"Note: Sample of $count_all countries constant across all 12 years (constant sample);" ///
				"interpolated where data was missing", ///
				size(vsmall))
		graph display, ysize(5) xsize(4)
		graph export "$figures/ff_fig2a.pdf", replace
		
				
********************************************************************************
********************************************************************************
							*** FIGURE 2b ***
********************************************************************************
********************************************************************************

*Setup
	use "$data/financialflows_const.dta", clear
		
		count if lic==2 & year==2012
			global count_lic = `r(N)'
		count if lic==1 & year==2012
			global count_other = `r(N)'
			global count_all = $count_lic + $count_other
			
	*Avg over 2008-2012 (keep obs in timeframe)
		keep if year>=2008 & year<=2012
				
	*create variable - official flows
		gen epol_official = epol_oda + epol_oof
		lab var epol_official "ODA and other offical flows"
			
	*create variable - total flows
		gen totflow = epol_official + epol_remittances + epol_private
		
	*convert to share of total at country level (unweighted average)
		foreach f in epol_official epol_remittances epol_private {
			gen sh_`f' = (`f'/totflow)*100
		}

	*locals for collpase
		local flows epol_official epol_private epol_remittances totflow
		local shares sh_epol_official sh_epol_remittances sh_epol_private
	*collapse
		collapse `flows' `shares', by(lic)
		ds epol_* totflow
		foreach v in `r(varlist)'{
			replace `v' = `v'/1000 //convert to billions
			}
		*end
	*shares of aggregate
		foreach f in official remittances private{
			gen agsh_`f' = (epol_`f'/totflow)*100
		}
		*end
	
	*unweighted
	local count = 1
	foreach f in official remittances private{
		rename sh_epol_`f' fsh`count'
		local count = 1 + `count'
		}
		*end
	*weighted
	local count = 4
	foreach f in official remittances private{
		rename agsh_`f' fsh`count'
		local count = 1 + `count'
		}
		*end
		
	keep lic fsh*
	reshape long fsh, i(lic) j(flow)
		lab def flow 1 "Official" 2 "Remittances" 3 "Private"
		lab val flow flow
	gen weighted = cond(flow<4,2,1)
		lab var weighted "Weighted Average"
		lab def weighted 1 "Weighted" 2 "Unweighted"
		lab val weighted weighted
	recode flow (4=1) (5=2) (6=3)
	order lic weighted flow
	tempfile base
	save `base'
	
	keep if lic==2
	drop lic
	reshape wide fsh, i(weight)  j(flow)
	gen lic = 2
	tempfile lic
	save `lic'
	
	use `base'
	keep if lic==1
	drop lic
	reshape wide fsh, i(weight)  j(flow)
	gen lic=1
	append using `lic'
	
	order lic weighted
	recode lic (1=2) (2=1)
		lab def lic 1 "LIC (n=$count_lic)" 2 "Other Developing (n=$count_other)"
		lab val lic lic
	
	rename fsh1 official
	rename fsh2 remittances
	rename fsh3 private
	*gen spacers between bars
		gen space1 = 75 - official
		gen space2 = 60 - remittances
		gen space3 = 35 - private
	egen id = group(lic weight)
	
	graph hbar (asis) official space1 remittances space2 private space3, ///
		over(weighted) over(lic, label(angle(vertical))) stack ///
		bar(1, fcolor("15 111 198") lcolor("15 111 198")) ///
		bar(2, fcolor(none) lcolor(white)) ///
		bar(3, fcolor("16 207 115") lcolor("16 207 115") ) ///
		bar(4, fcolor(none) lcolor(white)) ///
		bar(5, fcolor("4 97 123") lcolor("4 97 123") ) ///
		bar(6, fcolor(none) lcolor(white) ) ///
		blabel(bar, color(white) position(center) format(%3.0f)) ///
		title("Share of Total Average Financial Flows (%)", color(black) box bexpand bcolor("217 217 217")) ///
		plotregion(style(none)) ///
		graphregion(color(white)) ///
		ytitle("") ylabel(0(200)140) yscale(off) ///
		legend(off) ///
		text(30 101 "Official", size(vsmall)) ///
		text(97 101 "Remittances", size(vsmall)) ///
		text(150 101 "Private", size(vsmall)) ///
		note("Source: Official and Private Flows (OECD); Remittances (The World Bank)" ///
			"Note: County averages between 2008-2012 (Constant Sample); interpolated where data was missing", ///
			size(vsmall))
		graph export "$figures/ff_fig2b.pdf", replace
		
********************************************************************************
********************************************************************************
							*** FIGURE 2 ALT ***
********************************************************************************
********************************************************************************


*Setup
	*WEIGHTED
	*all dev
		use "$data/financialflows_const.dta", clear
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
		use "$data/financialflows_const.dta", clear
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
		gen labelo = "Official" if year==2012
		gen labelr = "Remittances" if year==2012
		gen labelp = "Private" if year==2012
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
		use "$data/financialflows_const.dta", clear
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
		use "$data/financialflows_const.dta", clear
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
		local group3 "lic==1"
		local title1 "Total current billions USD"
		local title2 ""
		local title3 ""
		local ytitle1 "All Developing (n=$count_all)"
		local ytitle2 "LIC (n=$count_lic)"
		local ytitle3 "Other Developing (n=$count_other)"
		local ylabel1 0(100)600
		local ylabel2 0(10)60
		local ylabel3 0(100)600
	*graphs
		forvalues i = 1/3{
			twoway area sa_private sa_remittances sa_official year if `group`i'', ///
				xlabel(1995(5)2012, notick labsize(small)) xscale(noline) ///
				ylabel(`ylabel`i'', grid angle(0) notick labsize(small) labstyle(right)) yscale(noline) ///
				legend(off) ///
				title("`title`i''", color(black) size(medsmall)) ///
				ytitle("{bf:`ytitle`i''}", size(small)) xtitle("") ///
				name(`name`i'', replace) ///
				plotregion(style(none)) ///
				graphregion(color(white)) ///
				color("4 97 123" "16 207 115" "15 111 198") ///
				nodraw	
				}
				*end
				
	*Shares of GDP Graphs ****************************************************
	*establish locals for loop
		local name1 alldev_share
		local name2 lic_share
		local name3 othdev_share
		local group1 "lic==3"
		local group2 "lic==2"
		local group3 "lic==1"
		local title1 "Share of GDP, %"
		local title2 ""
		local title3 ""
		local ylabel1 -5(5)10
		local ylabel2 -10(5)20
		local ylabel3 -5(5)10
		local weightType1 ""
		local weightType2 ""
		local weightType3 ""
		
		local name4 uw_alldev_share
		local name5 uw_lic_share
		local name6 uw_othdev_share
		local group4 "lic==3"
		local group5 "lic==2"
		local group6 "lic==1"
		local title4 "Share of GDP, % (Unweighted)"
		local title5 ""
		local title6 ""
		local ylabel4 -5(5)10
		local ylabel5 -10(5)20
		local ylabel6 -5(5)10
		local weightType4 "uw_"
		local weightType5 "uw_"
		local weightType6 "uw_"

	*graphs 
		forvalues i = 1/6{
			twoway line `weightType`i''sh_epol_official year if `group`i'', lcolor("15 111 198" ) lwidth(medthick) ylabel(`ylabel`i'') || ///
				scatter `weightType`i''sh_epol_official year if `group`i'' & ends==1, msize(large) mcolor("15 111 198") ylabel(`ylabel`i'') || ///
				scatter `weightType`i''sh_epol_official year if ends==1 & `group`i'' & `i'==4, msize(large) ///
					mcolor("15 111 198") mlabel(labelo) mlabposition(3) mlabcolor(black) || ///
				line `weightType`i''sh_epol_remittances year if `group`i'', lcolor("16 207 115" ) lwidth(medthick) ylabel(`ylabel`i'') || ///
				scatter `weightType`i''sh_epol_remittances year if `group`i'' & ends==1, msize(large) mcolor("16 207 115") ylabel(`ylabel`i'') || ///
				scatter `weightType`i''sh_epol_remittances year if ends==1 & `group`i'' & `i'==4, msize(large) ///
					mcolor("16 207 115") mlabel(labelr) mlabposition(12) mlabcolor(black) || ///
				line `weightType`i''sh_epol_private year if `group`i'', lcolor("4 97 123") lwidth(medthick) ylabel(`ylabel`i'') || ///
				scatter `weightType`i''sh_epol_private year if `group`i'' & ends==1, msize(large) mcolor("4 97 123")  || ///
				scatter `weightType`i''sh_epol_private year if ends==1 & `group`i'' & `i'==4, msize(large) ///
					mcolor("4 97 123") mlabel(labelp) mlabposition(3) mlabcolor(black)  ///
				legend(off) ///
				title("`title`i''", color(black) size(medsmall)) ///
				ytitle("") xtitle("") ///
				xlabel(1995(5)2012, notick labsize(small)) xscale(noline) ///
				xscale(range(2015)) ///
				ylabel(`ylabel`i'', angle(0) notick labsize(small)) yscale( noline) ///
				name(`name`i'', replace) ///
				plotregion(style(none)) ///
				graphregion(color(white)) ///
				nodraw				
				}
				*end
				
	*combine graphs
		graph combine alldev_area alldev_share uw_alldev_share lic_area lic_share uw_lic_share othdev_area othdev_share uw_othdev_share, row(3) col(3) ///
			graphregion(color(white)) nodraw ///
			title("Financial Flows Across Income Levels", color(black) box bexpand bcolor("217 217 217") size(medsmall)) ///
			note("Source: Official and Private Flows (OECD); Remittances (The World Bank)" ///
				"Note: Sample of $count_all countries constant across all 12 years (constant sample);" ///
				"interpolated where data was missing", ///
				size(vsmall))
		graph display, ysize(5) xsize(4)
		graph export "$figures/ff_fig2alt.pdf", replace
		
	
			
		
********************************************************************************
********************************************************************************
							*** FIGURE 3a ***
********************************************************************************
********************************************************************************

*Setup
	*WEIGHTED
	***all dev
		use "$data/financialflows_const.dta", clear
		keep if include_Rev == 2
		collapse (sum) gdp epol_imfFA_revMGnts epol_oda epol_oof epol_remittances epol_private, by(year)
		gen totflow = epol_oda + epol_oof + epol_private + epol_remittances	
			lab var totflow "Total Financial Flows"	
			drop epol_oda epol_oof epol_private epol_remittances	
		foreach v of varlist gdp-totflow{
			replace `v' = `v'/1000000 //convert to trillions
			}	
		order year gdp epol_imfFA_revMGnts totflow
		gen lic = 3	
		tempfile availability
		save `availability'
	***lic and other		
		use "$data/financialflows_const.dta", clear
		keep if include_Rev == 2
		count if lic==2 & year==2012
			global count_lic = `r(N)'
		count if lic==1 & year==2012
			global count_other = `r(N)'
			global count_all = $count_lic + $count_other
		collapse (sum) gdp epol_imfFA_revMGnts epol_oda epol_oof epol_remittances epol_private, by(year lic)
		gen totflow = epol_oda + epol_oof + epol_private + epol_remittances	
			lab var totflow "Total Financial Flows"	
			drop epol_oda epol_oof epol_private epol_remittances	
		foreach v of varlist gdp-totflow{
			replace `v' = `v'/1000000 //convert to tillions
			}	
		order year gdp epol_imfFA_revMGnts totflow
		append using `availability'
			label define lic_2 3 "All", add
		gen ends = 1 if inlist(year, 1995, 2012)
		gen labelt = "Gov't Rev" if year==2012
		gen labelo = "Other" if year==2012
			*stacked area variables
		gen sa_totflow = totflow
		gen sa_revtax = sa_totflow + epol_imfFA_revMGnts
	*shares of GDP
		foreach f of varlist epol_imfFA_revMGnts-totflow{
			gen shGDP_`f' = (`f'/gdp)*100
			}
			*end
	*shares of total
		gen Total = epol_imfFA_revMGnts + totflow
		foreach f of varlist epol_imfFA_revMGnts-totflow{
			gen shTot_`f' = (`f'/Total)*100
			}
			*end
	tempfile weighted
	save `weighted'	
	
	
	*UNWEIGHTED
	***all dev
		use "$data/financialflows_const.dta", clear
		keep if include_Rev == 2
		collapse (mean) gdp epol_imfFA_revMGnts epol_oda epol_oof epol_remittances epol_private, by(year ctry)
		gen totflow = epol_oda + epol_oof + epol_private + epol_remittances	
			lab var totflow "Total Financial Flows"	
			drop epol_oda epol_oof epol_private epol_remittances	
		foreach v of varlist gdp-totflow{
			replace `v' = `v'/1000000 //convert to trillions
			}	
		order year gdp epol_imfFA_revMGnts totflow
		gen lic = 3	
		tempfile availability
		save `availability'
	***lic and other		
		use "$data/financialflows_const.dta", clear
		keep if include_Rev == 2
		count if lic==2 & year==2012
			global count_lic = `r(N)'
		count if lic==1 & year==2012
			global count_other = `r(N)'
			global count_all = $count_lic + $count_other
		collapse (mean) gdp epol_imfFA_revMGnts epol_oda epol_oof epol_remittances epol_private, by(year lic ctry)
		gen totflow = epol_oda + epol_oof + epol_private + epol_remittances	
			lab var totflow "Total Financial Flows"	
			drop epol_oda epol_oof epol_private epol_remittances	
		foreach v of varlist gdp-totflow{
			replace `v' = `v'/1000000 //convert to tillions
			}	
		order year gdp epol_imfFA_revMGnts totflow
		append using `availability'
			label define lic_2 3 "All", add

	*shares of GDP
		foreach f of varlist epol_imfFA_revMGnts-totflow{
			gen shGDP_`f' = (`f'/gdp)*100
			}
			*end
	*shares of total
		gen Total = epol_imfFA_revMGnts + totflow
		foreach f of varlist epol_imfFA_revMGnts-totflow{
			gen shTot_`f' = (`f'/Total)*100
			}
			*end
			
	collapse (mean) gdp epol_imfFA_revMGnts totflow ctry shGDP_epol_imfFA_revMGnts shGDP_totflow Total shTot_epol_imfFA_revMGnts shTot_totflow ,by(lic year)
	renvars gdp epol_imfFA_revMGnts totflow ctry shGDP_epol_imfFA_revMGnts shGDP_totflow Total shTot_epol_imfFA_revMGnts shTot_totflow, prefix(uw_)
	
	merge 1:1 year lic using `weighted', nogen
		
		
	*Area graphs ***********************
	*establish locals for loop
		local name1 alldev_area
		local name2 lic_area
		local name3 othdev_area
		local group1 "lic==3"
		local group2 "lic==2"
		local group3 "lic==1"
		local title1 "Total current trillions USD"
		local title2 ""
		local title3 ""
		local ytitle1 "All Developing (n=$count_all)"
		local ytitle2 "LIC (n=$count_lic)"
		local ytitle3 "Other Developing (n=$count_other)"
		local ylabel1 0(.5)1
		local ylabel2 0(.01).03
		local ylabel3 0(.5)1
	*graphs
		forvalues i = 1/3{
			twoway area sa_revtax sa_totflow year if `group`i'', ///
				xlabel(1995(5)2012, notick labsize(small)) xscale(noline) ///
				ylabel(`ylabel`i'', grid angle(0) notick) yscale(noline) ///
				legend(off) ///
				title("`title`i''", color(black) size(medsmall)) ///
				ytitle("{bf:`ytitle`i''}", size(small)) xtitle("") ///
				name(`name`i'', replace) ///
				plotregion(style(none)) ///
				graphregion(color(white)) ///
				color("130 192 233" "166 166 166") ///
				nodraw	
				}
				*end
			*combine graphs
			
					
*Shares of GDP Graphs ****************************************************
	*establish locals for loop
		local name1 alldev_shareGDP
		local name2 lic_shareGDP
		local name3 othdev_shareGDP
		local group1 "lic==3"
		local group2 "lic==2"
		local group3 "lic==1"
		local title1 "Share of GDP, %"
		local title2 ""
		local title3 ""
		local ylabel1 0(5)25
		local ylabel2 0(5)25
		local ylabel3 0(5)25
		local shareType1 "shGDP_"
		local shareType2 "shGDP_"
		local shareType3 "shGDP_"
		
		local name4 alldev_shareGDP_uw
		local name5 lic_shareGDP_uw
		local name6 othdev_shareGDP_uw
		local group4 "lic==3"
		local group5 "lic==2"
		local group6 "lic==1"
		local title4 "Share of GDP, % (Unweighted)"
		local title5 ""
		local title6 ""
		local ylabel4 0(5)25
		local ylabel5 0(5)25
		local ylabel6 0(5)25
		local shareType4 "uw_shGDP_"
		local shareType5 "uw_shGDP_"
		local shareType6 "uw_shGDP_"
			 		
	*graphs 
		forvalues i = 1/6{
			twoway line `shareType`i''epol_imfFA_revMGnts year if `group`i'', lcolor("130 192 233") lwidth(medthick) ylabel(`ylabel`i'') || ///
				scatter `shareType`i''epol_imfFA_revMGnts year if `group`i'' & ends==1, msize(large) mcolor("130 192 233") ylabel(`ylabel`i'') || ///
				scatter `shareType`i''epol_imfFA_revMGnts year if ends==1 & `group`i'' & `i'==4, msize(large) ///
					mcolor("130 192 233") mlabel(labelt) mlabposition(12) mlabcolor(black) || ///
				line `shareType`i''totflow year if `group`i'', lcolor("166 166 166" ) lwidth(medthick) ylabel(`ylabel`i'') || ///
				scatter `shareType`i''totflow year if `group`i'' & ends==1, msize(large) mcolor("166 166 166") ylabel(`ylabel`i'') || ///
				scatter `shareType`i''totflow year if ends==1 & `group`i'' & `i'==4, msize(large) ///
					mcolor("166 166 166") mlabel(labelo) mlabposition(6) mlabcolor(black) ///
				legend(off) ///
				title("`title`i''", color(black) size(medsmall)) ///
				ytitle("") xtitle("") ///
				xlabel(1995(5)2012, notick labsize(small)) xscale(noline) ///
				ylabel(`ylabel`i'', angle(0) notick) yscale( noline) ///
				name(`name`i'', replace) ///
				plotregion(style(none)) ///
				graphregion(color(white)) ///
				nodraw				
				}
				*end
				
		graph combine alldev_area alldev_shareGDP alldev_shareGDP_uw lic_area lic_shareGDP lic_shareGDP_uw othdev_area othdev_shareGDP othdev_shareGDP_uw, row(3) col(3) ///
			graphregion(color(white)) nodraw ///
			title("Gov't Revenue (Central Government)", color(black) box bexpand bcolor("217 217 217") size(medsmall)) ///
			note("Sources: Tax revenues (IMF Fiscal Affairs Department's Revenue Database);" /// 
			"Other = Official and Private Flows (OECD), Remittances (WDI);" ///
			"Note: Sample of $count_all countries from constant sample used; interpolated where data was missing", ///
				size(vsmall))
		graph display, ysize(5) xsize(4)
		graph export "$figures/ff_fig3a.pdf", replace
	
********************************************************************************
********************************************************************************
							*** FIGURE 3b ***
********************************************************************************
********************************************************************************


*Setup
	*WEIGHTED
	***all dev
		use "$data/financialflows_const.dta", clear
		keep if include_Rev == 2
		collapse (sum) gdp epol_imfFA_revMGnts epol_oda epol_oof epol_remittances epol_private, by(year)
		gen totflow = epol_oda + epol_oof + epol_private + epol_remittances	
			lab var totflow "Total Financial Flows"	
			drop epol_oda epol_oof epol_private epol_remittances	
		foreach v of varlist gdp-totflow{
			replace `v' = `v'/1000000 //convert to trillions
			}	
		order year gdp epol_imfFA_revMGnts totflow
		gen resRich = 3	
		tempfile availability
		save `availability'
	***resRich and other		
		use "$data/financialflows_const.dta", clear
		keep if include_Rev == 2
		count if resRich==2 & year==2012
			global count_resRich = `r(N)'
		count if resRich==1 & year==2012
			global count_other = `r(N)'
			global count_all = $count_resRich + $count_other
		collapse (sum) gdp epol_imfFA_revMGnts epol_oda epol_oof epol_remittances epol_private, by(year resRich)
		gen totflow = epol_oda + epol_oof + epol_private + epol_remittances	
			lab var totflow "Total Financial Flows"	
			drop epol_oda epol_oof epol_private epol_remittances	
		foreach v of varlist gdp-totflow{
			replace `v' = `v'/1000000 //convert to tillions
			}	
		order year gdp epol_imfFA_revMGnts totflow
		append using `availability'
			label define resRich_2 3 "All", add
		gen ends = 1 if inlist(year, 1995, 2012)
		gen labelt = "Gov't Rev" if year==2012
		gen labelo = "Other" if year==2012
			*stacked area variables
		gen sa_totflow = totflow
		gen sa_revtax = sa_totflow + epol_imfFA_revMGnts
	*shares of GDP
		foreach f of varlist epol_imfFA_revMGnts-totflow{
			gen shGDP_`f' = (`f'/gdp)*100
			}
			*end
	*shares of total
		gen Total = epol_imfFA_revMGnts + totflow
		foreach f of varlist epol_imfFA_revMGnts-totflow{
			gen shTot_`f' = (`f'/Total)*100
			}
			*end
	tempfile weighted
	save `weighted'	
	
	
	*UNWEIGHTED
	***all dev
		use "$data/financialflows_const.dta", clear
		keep if include_Rev == 2
		collapse (mean) gdp epol_imfFA_revMGnts epol_oda epol_oof epol_remittances epol_private, by(year ctry)
		gen totflow = epol_oda + epol_oof + epol_private + epol_remittances	
			lab var totflow "Total Financial Flows"	
			drop epol_oda epol_oof epol_private epol_remittances	
		foreach v of varlist gdp-totflow{
			replace `v' = `v'/1000000 //convert to trillions
			}	
		order year gdp epol_imfFA_revMGnts totflow
		gen resRich = 3	
		tempfile availability
		save `availability'
	***resRich and other		
		use "$data/financialflows_const.dta", clear
		keep if include_Rev == 2
		count if resRich==2 & year==2012
			global count_resRich = `r(N)'
		count if resRich==1 & year==2012
			global count_other = `r(N)'
			global count_all = $count_resRich + $count_other
		collapse (mean) gdp epol_imfFA_revMGnts epol_oda epol_oof epol_remittances epol_private, by(year resRich ctry)
		gen totflow = epol_oda + epol_oof + epol_private + epol_remittances	
			lab var totflow "Total Financial Flows"	
			drop epol_oda epol_oof epol_private epol_remittances	
		foreach v of varlist gdp-totflow{
			replace `v' = `v'/1000000 //convert to tillions
			}	
		order year gdp epol_imfFA_revMGnts totflow
		append using `availability'
			label define resRich_2 3 "All", add

	*shares of GDP
		foreach f of varlist epol_imfFA_revMGnts-totflow{
			gen shGDP_`f' = (`f'/gdp)*100
			}
			*end
	*shares of total
		gen Total = epol_imfFA_revMGnts + totflow
		foreach f of varlist epol_imfFA_revMGnts-totflow{
			gen shTot_`f' = (`f'/Total)*100
			}
			*end
			
	collapse (mean) gdp epol_imfFA_revMGnts totflow ctry shGDP_epol_imfFA_revMGnts shGDP_totflow Total shTot_epol_imfFA_revMGnts shTot_totflow ,by(resRich year)
	renvars gdp epol_imfFA_revMGnts totflow ctry shGDP_epol_imfFA_revMGnts shGDP_totflow Total shTot_epol_imfFA_revMGnts shTot_totflow, prefix(uw_)
	
	merge 1:1 year resRich using `weighted', nogen
		
		
	*Area graphs ***********************
	*establish locals for loop
		local name1 alldev_area
		local name2 resRich_area
		local name3 othdev_area
		local group1 "resRich==3"
		local group2 "resRich==2"
		local group3 "resRich==1"
		local title1 "Total current trillions USD"
		local title2 ""
		local title3 ""
		local ytitle1 "All Developing (n=$count_all)"
		local ytitle2 "Resource Dependent (n=$count_resRich)"
		local ytitle3 "Other Developing (n=$count_other)"
		local ylabel1 0(1)4
		local ylabel2 0(.25)1
		local ylabel3 0(1)4
	*graphs
		forvalues i = 1/3{
			twoway area sa_revtax sa_totflow year if `group`i'', ///
				xlabel(1995(5)2012, notick labsize(small)) xscale(noline) ///
				ylabel(`ylabel`i'', grid angle(0) notick) yscale(noline) ///
				legend(off) ///
				title("`title`i''", color(black) size(medsmall)) ///
				ytitle("{bf:`ytitle`i''}", size(small)) xtitle("") ///
				name(`name`i'', replace) ///
				plotregion(style(none)) ///
				graphregion(color(white)) ///
				color("130 192 233" "166 166 166") ///
				nodraw	
				}
				*end
			*combine graphs
			
					
*Shares of GDP Graphs ****************************************************
	*establish locals for loop
		local name1 alldev_shareGDP
		local name2 resRich_shareGDP
		local name3 othdev_shareGDP
		local group1 "resRich==3"
		local group2 "resRich==2"
		local group3 "resRich==1"
		local title1 "Share of GDP, %"
		local title2 ""
		local title3 ""
		local ylabel1 0(5)30
		local ylabel2 0(5)30
		local ylabel3 0(5)30
		local shareType1 "shGDP_"
		local shareType2 "shGDP_"
		local shareType3 "shGDP_"
		
		local name4 alldev_shareGDP_uw
		local name5 resRich_shareGDP_uw
		local name6 othdev_shareGDP_uw
		local group4 "resRich==3"
		local group5 "resRich==2"
		local group6 "resRich==1"
		local title4 "Share of GDP, % (Unweighted)"
		local title5 ""
		local title6 ""
		local ylabel4 0(5)30
		local ylabel5 0(5)30
		local ylabel6 0(5)30
		local shareType4 "uw_shGDP_"
		local shareType5 "uw_shGDP_"
		local shareType6 "uw_shGDP_"
			 		
	*graphs 
		forvalues i = 1/6{
			twoway line `shareType`i''epol_imfFA_revMGnts year if `group`i'', lcolor("130 192 233") lwidth(medthick) ylabel(`ylabel`i'') || ///
				scatter `shareType`i''epol_imfFA_revMGnts year if `group`i'' & ends==1, msize(large) mcolor("130 192 233") ylabel(`ylabel`i'') || ///
				scatter `shareType`i''epol_imfFA_revMGnts year if ends==1 & `group`i'' & `i'==4, msize(large) ///
					mcolor("130 192 233") mlabel(labelt) mlabposition(12) mlabcolor(black) || ///
				line `shareType`i''totflow year if `group`i'', lcolor("166 166 166" ) lwidth(medthick) ylabel(`ylabel`i'') || ///
				scatter `shareType`i''totflow year if `group`i'' & ends==1, msize(large) mcolor("166 166 166") ylabel(`ylabel`i'') || ///
				scatter `shareType`i''totflow year if ends==1 & `group`i'' & `i'==4, msize(large) ///
					mcolor("166 166 166") mlabel(labelo) mlabposition(6) mlabcolor(black) ///
				legend(off) ///
				title("`title`i''", color(black) size(medsmall)) ///
				ytitle("") xtitle("") ///
				xlabel(1995(5)2012, notick labsize(small)) xscale(noline) ///
				ylabel(`ylabel`i'', angle(0) notick) yscale( noline) ///
				name(`name`i'', replace) ///
				plotregion(style(none)) ///
				graphregion(color(white)) ///
				nodraw				
				}
				*end
				
		graph combine alldev_area alldev_shareGDP alldev_shareGDP_uw resRich_area resRich_shareGDP resRich_shareGDP_uw othdev_area othdev_shareGDP othdev_shareGDP_uw, row(3) col(3) ///
			graphregion(color(white)) nodraw ///
			title("Government Revenue", color(black) box bexpand bcolor("217 217 217") size(medsmall)) ///
			note("Sources: Government Revenue; Other = Official and Private Flows (OECD), Remittances (WDI);" /// 
			"Resource Dependence (IMF)" ///
			"Note: Sample of $count_all countries from constant sample used; interpolated where data was missing" ///
			"Resource dependence country defined as a country whose non-renewable natural resources comprised" ///
			"at least 20 percent of total exports or 20 percent of natural resource revenues, based on a" ///
			"2006-2010 average.", ///
				size(vsmall))
		graph display, ysize(5) xsize(4)
		graph export "$figures/ff_fig3b.pdf", replace
	

		
********************************************************************************
********************************************************************************
********************************************************************************
* 								FIGURE 4 
********************************************************************************
********************************************************************************
********************************************************************************

* Real Avg Resource Dependence Flows (2006-2010)
		
	use "$data/financialflows_const.dta", clear

	* indentify a constant sample for resource dependence
	* (full obseravtions for all years and flows)
	
		keep if year>=2008 & year<=2012
		
		table year, c(n trv_tot_resource_rev n trv_tot_nresource_rev_inc_sc n trv_social_contrib)
		
		tab resRich year, m // 78 countries (342 not, 48 yes over 5 years)
		
		*identify country with all flows in a given year // AARON HAD COMMENTED OUT
			*egen flowmisscount = rowmiss(trv_tot_resource_rev trv_tot_nresource_rev_inc_sc trv_social_contrib)
			*drop if flowmisscount==3 //no flows in a given year
			*drop flowmisscount
		
		*gen official
			gen epol_official = epol_oda + epol_oof
			lab var epol_official "ODA and other offical flows"
			
		*gen totflow
			gen totflow = trv_tot_resource_rev + trv_tot_nresource_rev_inc_sc + epol_official + epol_remittances + epol_private
		
		*keep only full series (drop if rev data is missing)
*			drop if totflow==.
			unique ctry, by(resRich) gen(unique) //15 no, 9 yes
*				drop unique

			count if resRich==2 & year==2012
				global count_resdep = `r(N)'
			count if resRich==1 & year==2012
				global count_noresRich = `r(N)'
			global count_all = $count_resdep + $count_noresRich
			
				
		*rename (due to length)
			rename trv_tot_nresource_rev_inc_sc trv_tot_nresource_rev
			
		*convert to real
			foreach f in trv_tot_resource_rev trv_tot_nresource_rev epol_official epol_remittances epol_private totflow{
				gen r_`f' = `f'/cpi_d
			}
			*end
			
		*share of total at country level (unweighted average)
			ds r_*
			foreach f in `r(varlist)'{
				gen sh_`f' = `f'/r_totflow
				}
				*end
			
		*identify averages
			local rev r_trv_tot_resource_rev r_trv_tot_nresource_rev
			local flows r_epol_official r_epol_private r_epol_remittances
			local shares sh_r_trv_tot_resource_rev sh_r_trv_tot_nresource_rev sh_r_epol_official sh_r_epol_remittances sh_r_epol_private
			*foreach f in `rev' `flows'{
			*	bysort ctry: egen avg_`f' = mean(`f')
			*	}
				*end
			
		*collapse
			*collapse `rev' `flows' `shares', by(resRich)
			*collapse avg_*, by(resdep)
			
			
			tempfile beforeCollapse
			save `beforeCollapse'
			
			collapse `rev' `flows', by(resRich) // Rob Addition
			
			* calculating shares
			gen totflow_sh = r_trv_tot_resource_rev + r_trv_tot_nresource_rev + r_epol_official + r_epol_private + r_epol_remittances
			foreach f of varlist `rev' `flows'{
				gen sh_`f' = `f'/totflow_sh
			}
						
			keep resRich sh_* 
			
			tempfile weighted
			save `weighted'
			
			* Unweigthed
			use `beforeCollapse'
			
			collapse (mean) `rev' `flows', by(resRich ctry)
			
			gen totflow_sh = r_trv_tot_resource_rev + r_trv_tot_nresource_rev + r_epol_official + r_epol_private + r_epol_remittances
			foreach f of varlist `rev' `flows'{
				gen sh_`f' = `f'/totflow_sh
			}
			
			collapse (mean) sh_*, by(resRich)
			renvars sh_*, prefix(u) // u for unweighted
			
			merge 1:1 resRich using `weighted', nogen
			
			gen uresRich = resRich
			
			stack uresRich ush_r_trv_tot_resource_rev ush_r_trv_tot_nresource_rev ush_r_epol_official ush_r_epol_private ush_r_epol_remittances resRich sh_r_trv_tot_resource_rev sh_r_trv_tot_nresource_rev sh_r_epol_official sh_r_epol_private sh_r_epol_remittances, into(resRich resRev nonResRev official private remittances) clear
			
			rename _stack weighted
			
			replace resRich = 3 if resRich == 2
			replace resRich = 4 if resRich == 1
			
			replace weighted = 3 if weighted == 2
			replace weighted = 4 if weighted == 1


			lab define weight_bin 3 "Weighted" 4 "Unweighted"
			lab define ResyesNo 3 "Resource Dependent" 4 "Non-Resource Dependent"
			
			lab values weighted weight_bin
			lab values resRich ResyesNo
			
******* Making the Graph

	* Private is negativeÑmake 0
*	sort private
*	replace private = 0 in 1	
	
	foreach f of varlist resRev nonResRev official private remittances{
		replace `f' = `f'*100
	}
				
	scalar spaceAmount = 4
	
	gsort - resRev // sort in descending order
	gen space1 = (resRev[1] + spaceAmount) - resRev 
	scalar resRev_textPos = resRev[1]/2 
	
	gsort - nonResRev // sort in descending order
	gen space2 = (nonResRev[1] + spaceAmount) - nonResRev
	scalar nonResRev_textPos = (nonResRev[1]/2) + spaceAmount + (resRev_textPos*2)
	
	gsort - official // sort in descending order
	gen space3 = (official[1] + spaceAmount) - official
	scalar official_textPos = (official[1]/2) + spaceAmount + (resRev_textPos*2) + spaceAmount + (nonResRev_textPos*2)
	
	gsort - remittances // sort in descending order
	gen space4 = (remittances[1] + spaceAmount) - remittances
	scalar remittances_textPos = (remittances[1]/2) + spaceAmount + (resRev_textPos*2) + spaceAmount + (nonResRev_textPos*2) + spaceAmount + (official_textPos*2)
	
	gsort - private // sort in descending order
	scalar private_textPos = (private[1]/2) + spaceAmount + (resRev_textPos*2) + spaceAmount + (nonResRev_textPos*2) + spaceAmount + (official_textPos*2) + spaceAmount + (remittances_textPos*2)
	
	*egen id = group(resdep weight)
	
	graph hbar (asis) resRev space1 nonResRev space2 official space3 remittances space4 private, ///
		over(resRich, label(labsize(small))) over(weighted, label(angle(vertical) labsize(small))) stack ///
		bar(1, fcolor("0 204 204") lcolor("0 204 204")) ///
		bar(2, fcolor("255 255 255") lcolor("255 255 255")) ///
		bar(3, fcolor("0 153 153") lcolor("0 153 153") ) ///
		bar(4, fcolor("255 255 255") lcolor("255 255 255")) ///
		bar(5, fcolor("15 111 198") lcolor("15 111 198") ) ///
		bar(6, fcolor("255 255 255") lcolor("255 255 255")) ///
		bar(7, fcolor("16 207 115") lcolor("16 207 115") ) ///
		bar(8, fcolor("255 255 255") lcolor("255 255 255")) ///
		bar(9, fcolor("4 97 123") lcolor("4 97 123") ) ///
		blabel(bar, color(white) position(center) format(%3.0f)) ///
		title("Share of Total Average Financial Flows (%)", color(black) size(medium) box bexpand bcolor("217 217 217")) ///
		plotregion(style(none)) ///
		graphregion(color(white)) ///
		ytitle("") ylabel(0(200)150) yscale(off) ///
		legend(off) ///
		text(`=scalar(resRev_textPos)' 101 "Res Rev", size(vsmall)) ///
		text(`=scalar(nonResRev_textPos)' 101 "Non-Res Rev", size(vsmall)) ///
		text(113 101 "Official", size(vsmall)) ///
		text(139 101 "Remittances", size(vsmall)) ///
		text(157 101 "Private", size(vsmall)) ///
		note("Source: International Center for Tax and Development (Revenues); Official and Private Flows (OECD);" ///
			"Remittances (The World Bank)" ///
			"Note: Constant sample comprises of $count_resdep resource dependent countries and $count_noresRich non-resource dependent" /// 
			"countries; Resource dependence country defined as a country whose non-renewable natural resources " ///
			"comprised at least 20 percent of total exports or 20 percent of natural resource revenues, based on a" /// 
			"2006-2010 average.", ///
			size(vsmall))	
		graph export "$figures/ff_fig4.pdf", replace
			
********************************************************************************
********************************************************************************
						*** APPENDIX FIGURE A1 ***
********************************************************************************
********************************************************************************

*Setup
	use "$data/financialflows.dta", clear
	collapse (sum) oda oof remittances private population (mean) cpi_d, by(year)
	gen official = oda + oof
		lab var official "ODA and other offical flows"
	drop if year<1995 | year>2012
	keep year cpi_d population official remittances private
	order year cpi_d population official remittances private
		
	* Generating Variables
	foreach f of varlist official-private{
		gen `f'_real = `f'/cpi_d
	}
		
	foreach f of varlist official_real-private_real{
		gen `f'_PC = `f'/population
	}
		
	foreach f of varlist official-private{
		rename `f' `f'_nominal
	}
		
	* Generating Growth Rates Relative to 1995
	tsset year
	foreach f of varlist official_nominal-private_real_PC{
		gen `f'_grth95 = (`f'[_n] - `f'[1]) / `f'[1] * 100 if _n > 1	
		replace `f'_grth95 = 0 if _n == 1
	}
	
	keep year official_nominal_grth95-private_real_PC_grth95

	gen ends = 1 if inlist(year, 1995, 2012)
	gen labeln = "Nominal" if year==2012
	gen labelr = "Real" if year==2012
	gen labelrpc = "Real PC" if year==2012
		
	*establish locals for loop
		local name1 official
		local name2 remittances
		local name3 private
		local title1 "Net Official (ODA + OOF)"
		local title2 "Remittances"
		local title3 "Net Private"
		local ylabel1 -100(100)700
		local ylabel2 -100(100)700
		local ylabel3 -100(100)700
		local color1 ""15 111 198""
		local color2 ""16 207 115""
		local color3 ""4 97 123""
				
	*graphs 
		forvalues i = 1/3{
			twoway line `name`i''_nominal_grth95 year, lcolor(`color`i'') lpattern(solid) lwidth(medthick) ylabel(`ylabel`i'') || ///		
				scatter `name`i''_nominal_grth95 year if ends==1, msize(large) mcolor(`color`i'') ylabel(`ylabel`i'') || ///
				scatter `name`i''_nominal_grth95 year if ends==1 & `i'==3, msize(large) ///
					mcolor(`color`i'') mlabel(labeln) mlabposition(6) mlabcolor(black) || ///
				line `name`i''_real_grth95 year, lcolor(`color`i'') lpattern(dot) lwidth(medthick) ylabel(`ylabel`i'') || ///
				scatter `name`i''_real_grth95 year if ends==1, msize(large) mcolor(`color`i'') ylabel(`ylabel`i'') || ///
				scatter `name`i''_real_grth95 year if ends==1 & `i'==3, msize(large) ///
					mcolor(`color`i'') mlabel(labelr) mlabposition(12) mlabcolor(black) || ///
				line `name`i''_real_PC_grth95 year, lcolor(`color`i'') lpattern(dash) lwidth(medthick) ylabel(`ylabel`i'') || ///
				scatter `name`i''_real_PC_grth95 year if ends==1, msize(large) mcolor(`color`i'')  || ///
				scatter `name`i''_real_PC_grth95 year if ends==1 & `i'==3, msize(large) ///
					mcolor(`color`i'') mlabel(labelrpc) mlabposition(6) mlabcolor(black)  ///
				legend(off) ///
				title("`title`i''", color(black)) ///
				ytitle("") xtitle("") ///
				xlabel(1995(5)2012, notick) xscale(noline) ///
				ylabel(`ylabel`i'', angle(0) notick) yscale( noline) ///
				name(`name`i''2, replace) ///
				plotregion(style(none)) ///
				graphregion(color(white)) ///
				nodraw				
				}
				*end
				
	*combine graphs
		graph combine official2 remittances2 private2, row(1) col(3) ///
			graphregion(color(white)) nodraw ///
			title("Financial Flows, Cumulative Growth Rates Relative to 1995", color(black) box bexpand bcolor("217 217 217")) ///
			note("Source: Official and Private Flows (OECD); Remittances (The World Bank)", ///
				size(small))
		graph display, ysize(2) xsize(4)
		graph export "$figures/ff_AppenFigA1.pdf", replace

********************************************************************************
********************************************************************************
						*** Comparing Two Revenues ***
********************************************************************************
********************************************************************************		
use "$data/financialflows_const.dta", clear

	sum taxr // IMF Fiscal Affairs Deparment
	sum rev_tax // IMF GFS

	collapse (sum) rev_tax taxr, by(year)
	keep if year >= 1995 & year <= 2011
	
	foreach f of varlist rev_tax taxr{
		replace `f' = `f' / 1000000  // Convert to Trillions
	}
	
	gen ends = 1 if inlist(year, 1995, 2011)
	gen labelFAD = "IMF Fiscal Affairs Department" if year==2011
	gen labelGFS = "IMF GFS" if year==2011
	
	local color1 ""130 192 233""
	local color2 ""15 111 198""
	local ylabel 0(1)4
			
	twoway line taxr year, lcolor(`color1') lpattern(solid) lwidth(medthick) ylabel(`ylabel')  || ///
				scatter taxr year if ends==1, msize(large) mcolor(`color1') ylabel(`ylabel') || ///
				scatter taxr year if ends==1, msize(large) ///
					mcolor(`color1') mlabel(labelFAD) mlabposition(12) mlabcolor(black) ylabel(`ylabel') || ///
		   line rev_tax year, lcolor(`color2') lpattern(solid) lwidth(medthick) ylabel(`ylabel') || ///
				scatter rev_tax year if ends==1, msize(large) mcolor(`color2')  || ///
				scatter rev_tax year if ends==1, msize(large) ///
					mcolor(`color2') mlabel(labelGFS) mlabposition(1) mlabcolor(black)  ///
			legend(off) ///
			title("Tax Revenues", color(black) box bexpand bcolor("217 217 217")) ///
			ytitle("Trillions (USD)") xtitle("") ///
			xlabel(1995(5)2015, notick) xscale(noline) ///
			ylabel(`ylabel', angle(0) notick) yscale( noline) ///
			name("FigureTaxRev", replace) ///
			plotregion(style(none)) ///
			graphregion(color(white)) ///
			note("Source: IMF Fiscal Affairs Department and IMF Government Financial Statistics (GFS) Database" ///
			"Note: Sample of $count_all countries constant across 11 years (constant sample); interpolated where data was missing", ///
			size(vsmall))
			
			graph export "$figures/TaxRev.pdf", replace


			
********************************************************************************
********************************************************************************
						*** Governmnet Expentiture ***
********************************************************************************
********************************************************************************


use "$data/financialflows_const.dta", clear
	collapse (sum) expetyp_totexp rev_tax, by(year)
	keep if year >= 1995 & year <= 2011

	gen ends = 1 if inlist(year, 1995, 2011)
	gen labelExp = "Expenditures" if year==2011
	gen labelRev = "Gov't Revenue" if year==2011
	
	foreach f of varlist expetyp_totexp rev_tax{
		replace `f' = `f' / 1000000  // Convert to Trillions
	}
	
	local color1 ""130 192 233""
	local color2 ""15 111 198""
	local ylabel1 0(300)1580
	local ylabel2 0(1)5
			
	twoway line expetyp_totexp year, lcolor(`color1') lpattern(solid) lwidth(medthick) ylabel(`ylabel1') yaxis(1) || ///
				scatter expetyp_totexp year if ends==1, msize(large) mcolor(`color1') ylabel(`ylabel1') yaxis(1) || ///
				scatter expetyp_totexp year if ends==1, msize(large) ///
					mcolor(`color1') mlabel(labelExp) mlabposition(12) mlabcolor(black) ylabel(`ylabel1') yaxis(1) || ///
		   line rev_tax year, lcolor(`color2') lpattern(solid) lwidth(medthick) ylabel(`ylabel2') yaxis(2) || ///
				scatter rev_tax year if ends==1, msize(large) mcolor(`color2') ylabel(`ylabel2') yaxis(2)  || ///
				scatter rev_tax year if ends==1, msize(large) ///
					mcolor(`color2') mlabel(labelRev) mlabposition(12) mlabcolor(black) ylabel(`ylabel2') yaxis(2)  ///
			legend(off) ///
			title("Gov't Expenditures and Tax Revenues", color(black) box bexpand bcolor("217 217 217")) ///
			ytitle("Trillions (USD) - Expenditures", axis(1)) ///
			ylabel(`ylabel1', angle(0) notick axis(1)) yscale(noline axis(1)) ///
			ytitle("Trillions (USD) - Tax Revenue", axis(2)) ///
			ylabel(`ylabel2', angle(0) notick axis(2)) yscale(noline axis(2)) ///
			xtitle("") ///
			xlabel(1995(5)2015, notick) xscale(noline) ///			
			name("FigureTaxRev", replace) ///
			yscale(range(5.2) axis(2)) ///	
			plotregion(style(none)) ///
			graphregion(color(white)) ///
			note("Source: IMF Government Financial Statistics" ///
			"Note: Sample of $count_all countries constant across 11 years (constant sample); interpolated where data was missing", ///
			size(vsmall))
			
			graph export "$figures/ExpendRev.pdf", replace



