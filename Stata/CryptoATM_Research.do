/*
Do File: CryptoATM_Research.do
Author: Eric Luong
Date: 03-10-2025
Description: This do-file graphs the trends for Gini-Coefficient, Top 10% Income and Social Public Expenditure by Market Types and Anglo-Saxon and Continental countries..
*/

clear all
set more off
capture log close
ssc install estout
ssc install asdoc
ssc install outreg2


// Set working directory
global home "/Users/ericluong/Documents/ECON_Research/CATM_EL001"
global graphs $home/graphs
global regs $home/regressions
cd "$home"


// Start a log file
log using "CryptoATM_Research.log", replace

// Load dataset
import excel "CryptoBill_Data.xlsx", sheet("fulldata_stata") firstrow clear
describe
destring IC3_ScamUSD, replace force float
recast double IC3_ScamUSD

//converting time variables
gen year = year(Date)
gen month= mofd(Date)
format month %tm

// Converting to Log
gen logATMs = log(ATMs)
gen logIC3_ScamNumber = log(IC3_ScamNumber)
gen logIC3_ScamUSD = log(IC3_ScamUSD)
gen logBitcoin = log(Bitcoin_Price)


// Figure One: ATM Data Over Time
twoway line ATMs Date, ////
    ytitle("CryptoATMs") ///
    xtitle("Date") ///
    xlabel(, angle(45) labsize(small)) ///
    ylabel(, grid) ///
    graphregion(color(white))
	
// Figure Two: Scam Data Over Time
twoway line IC3_ScamNumber year, ///
    ytitle("# of Scams") ///
    xtitle("Date") ///
    xlabel(, angle(45) labsize(small)) ///
    ylabel(, grid) ///
    graphregion(color(white))
	
// Figure Three; Scam Data over Time in USD (Billions)
twoway line IC3_ScamUSD_Billions year, ///
    ytitle("Value of Scams (In Billions)") ///
    xtitle("Date") ///
    xlabel(, angle(45) labsize(small)) ///
    ylabel(, grid) ///
    graphregion(color(white))
	
// Figure Six: Bitcoin Price
twoway line Bitcoin_Price Date, ///
    ytitle("BC Price") ///
    xtitle("Date") ///
    xlabel(, angle(45) labsize(small)) ///
    ylabel(, grid) ///
    graphregion(color(white))
	
// Table 1: Descriptive Stats
estpost summarize ATMs IC3_ScamNumber IC3_ScamUSD Bitcoin_Price
esttab using descriptives.rtf, replace cells("mean sd min max") title("Descriptive Statistics")

// Base Regressions
eststo r1: reg logIC3_ScamNumber logATMs, vce(robust)

eststo r2: reg logIC3_ScamNumber logATMs logBitcoin, vce(robust)

eststo r3: reg logIC3_ScamUSD logATMs, vce(robust)

eststo r4: reg logIC3_ScamUSD logATMs logBitcoin, vce(robust)

esttab r1 r2 r3 r4 using regressions.tex, replace stats(r2 N rmse) se star(* 0.1 ** 0.05 *** 0.01)mtitles("Number of Scams" "Number of Scams" "Total USD Scammed" "Total USD Scammed")

// Regression w/ FE for Year: 
eststo r5: reg logIC3_ScamNumber logATMs i.year, vce(robust)

eststo r6: reg logIC3_ScamNumber logATMs logBitcoin i.year, vce(robust)

eststo r7: reg logIC3_ScamUSD logATMs i.year, vce(robust)

eststo r8: reg logIC3_ScamUSD logATMs logBitcoin i.year, vce(robust)

esttab r5 r6 r7 r8 using regressions_fe.tex, replace stats(r2 N rmse) se star(* 0.1 ** 0.05 *** 0.01)mtitles("Number of Scams" "Number of Scams" "Total USD Scammed" "Total USD Scammed")
