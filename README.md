# FinancialFlows

Contains data, do-files, figures and tables for financial flows analysis. To download the entire 'FinancialFlows' folder, click the "Download ZIP" button to the right.  

**Data**
* **financialflows.dta:** Full available sample
* **financialflows_const.dta:** Constant sample

**DoFiles**
* **Analysis.do:** Performs regression analysis and generates graphs of independent variables used in the analysis. 
* **ExtPovFigure.do:** Generates the figure for the extreme poverty vision statement.
* **Graphs.do:** Generates graphs of financial flows.
* **IMF_BoP.do:** Generates graphs of gross balance of payment flows, specifically of: (1) gross trade, (2) gross financial trade, and (3) ratio of KA to CA trade. 
* **UpdateSamples.do:** Updates the available sample and the constant sample. Specifically, it can be used to update: (1)  the gov't revenue variable, and (2) parameters for constructing the constant sample (i.e., time-span and how many observations a variable must have before interpolating).
* **To make the do-files work on your computer,** you'll need to update the "global projectpath" in each of the do-files so the file path goes to the FinancialFlows folder. This is located near the top of each do-file. In addition, the do-files were written on a Mac computer. In a file path, Macs use a forward slash ( / ) to separate files, while PCs use a backslash ( \ ). To get the do-files to work on a PC, you'll have to "find and replace" "/" with "\".    

**Documents**
* This folder contains documents that describes some of the key variables. Most of the documents were created by Aaron. 

**Figures**
* This folder contains figures generated by any of the do-files. 

**RawData**
* This folder contains select raw data. Specifically, it contains: (1) Penn World Tables data, (2) countries that are considered resource rich according to the IMF (both in Excel and the IMF document that lists the countries), (3) IMF Fiscal Affairs Department Data, and (4) Balance of Payments Data. The IMP_BoP.do file directly pulls in Excel files from the BoP folder.   

**Tables**
* **Tables 1 - 5:** Tables 1-5 are generated by Analysis.do 
* **CountriesInSample:** A folder that contains lists of countries included in: (1) the constant sample, (2) the constant sample with revenue data (i.e., figures 3a and 3b), and (2) the regression analysis. Countries are listed by whether they are resource dependent and an LIC.