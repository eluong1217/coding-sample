**********************************************************
*Program: FINAL.do
*Author: ELENA ALBANO AND ERIC LUONG
*Date: Dec 22, 2024
*Purpose: Complete final project exercise.
**********************************************************

clear all
capture log close
cd "\Users\Eric.Luong001\OneDrive - University of Massachusetts Boston\Computer Files\Documents\ECON452\FinalProject"
log using final_project.log, replace
ssc install estout

set fredkey 61fb8a874693c36d581f6cbb8a601478 , permanent
import fred CPIAUCSL FEDFUNDS A939RX0Q048SBEA PCE GPDI NETEXP FGEXPND, aggregate(quarterly) daterange(1960q1 .) clear

/*
A939RX0Q048SBEA = GDP
PCE = Consumption
GPDI = Investment
FGEXPND = Government Spending
NETEXP = Net Exports
*/

*Make CPI stationary/ into Inflation
gen inflation = 100 * (CPIAUCSL - CPIAUCSL[_n-1]) / CPIAUCSL[_n-1]

*Converting to Quarterly Data.
gen quarter = tq(1947q1) + _n-1
format quarter %tq
tsset quarter 
sort quarter 
order quarter

*Make Data Stationary.
gen interest = d.FEDFUNDS
gen GDP = d.A939RX0Q048SBEA
gen consumption = d.PCE
gen investment = d.GPDI
gen dnetexp = d.NETEXP
gen government = d.FGEXPND
corr inflation interest GDP consumption investment dnetexp government

*Summary Table
*Making sure our stationary* fedfunds was not stationary so we created a new variable dfedrate and now it is. to see which is stationary we can look at p-values. cpi is also not. we should fix this the same way we fixed fedfunds. generating a new variable and then re-checking. test for stationary with our new control variables!!!! 

*Make Summary Table
estpost summarize CPIAUCSL FEDFUNDS A939RX0Q048SBEA PCE GPDI NETEXP FGEXPND inflation interest GDP consumption investment dnetexp government
esttab using summary_table.rtf, cells("obs mean sd min max") label replace

*Dickey Fuller Test
dfuller CPIAUCSL 
dfuller FEDFUNDS 
dfuller A939RX0Q048SBEA 
dfuller PCE 
dfuller GPDI 
dfuller NETEXP 
dfuller FGEXPND

dfuller interest
dfuller GDP
dfuller consumption
dfuller investment
dfuller dnetexp
dfuller government

*Phillips-Perron Test (Unnecessary?)
pperron CPIAUCSL 
pperron FEDFUNDS 
pperron A939RX0Q048SBEA 
pperron PCE 
pperron GPDI 
pperron NETEXP 
pperron FGEXPND

pperron interest
pperron GDP
pperron consumption
pperron investment
pperron dnetexp
pperron government

*Basic Regression and Scatterplot.
eststo r1: regress inflation interest, robust
scatter inflation interest, msize(small) ///
    title("Scatterplot of Inflation vs. Interest Rate") ///
    xlabel(, grid) ylabel(, grid)
twoway (scatter inflation interest, mcolor(blue)) (lfit inflation interest, lcolor(red)) ///
    , title("Inflation vs. Interest Rate") ///
      xlabel(, grid) ylabel(, grid)
	
* a 1 percentage point increase in change in interest rate is associated with percentage point change in inflation (.16 percentage point chnage increase in inflation)

*1st and 2nd Regressions: Multivariate Regression with different controls.
eststo r2: regress inflation interest GDP, robust
eststo r3: regress inflation interest consumption investment dnetexp government, robust
eststo r4: regress inflation interest GDP consumption investment dnetexp government, robust
estat vif

*Create Log variables
gen loginflation = log(inflation)
gen loginterest = log(interest)

*3rd Regression: Logarithimic Regression
eststo r5: regress loginflation loginterest , robust

*4th Regression: Logarithimic Regression with control variables
eststo r6: regress loginflation loginterest GDP, robust
eststo r7: regress loginflation loginterest consumption investment dnetexp government, robust
eststo r8: regress loginflation loginterest GDP consumption investment dnetexp government, robust
estat vif

*5th Regression: Time Lag (specifically the first one)
eststo r9: regress inflation interest L1.interest 
estat ic
eststo r10: regress inflation interest L1.interest L2.interest 
estat ic
eststo r11: regress inflation interest L1.interest L2.interest L3.interest
estat ic
eststo r12: regress inflation interest L1.interest L2.interest L3.interest L4.interest
estat ic
eststo r13: regress inflation interest L1.interest L2.interest L3.interest L4.interest L5.interest
estat ic
eststo r14: regress inflation interest L1.interest L2.interest L3.interest L4.interest L5.interest L6.interest
estat ic
*6th Regression: Time Lag w/ Lowest Bayes
eststo r15: regress inflation interest L1.interest L2.interest L3.interest L4.interest L5.interest L6.interest L7.interest
estat ic
eststo r16: regress inflation interest L1.interest L2.interest L3.interest L4.interest L5.interest L6.interest L7.interest L8.interest
estat ic

*Final Regression
eststo r17:regress inflation interest L1.interest L2.interest L3.interest L4.interest L5.interest L6.interest L7.interest consumption investment dnetexp government, robust
estat ic
estat vif

*Multivariate Chart
esttab r1 r2 r3 r4 using resultscontrols.tex, replace stats(r2 N rmse) se star(* 0.1 ** 0.05 *** 0.01)mtitles("OLS" "GDP" "GDP Vars" "All Controls")

*Logarithimic Chart
esttab r1 r5 r6 r7 r8 using resultslog.tex, replace stats(r2 N rmse) se star(* 0.1 ** 0.05 *** 0.01)mtitles("OLS" "Log" "Log w/ GDP" "Log w/ GDP Vars" "Log w/ All Controls")

*Lag Chart
esttab r9 r10 r11 r12 r13 r14 r15 r16 using resultslag.tex, replace stats(bic r2 N rmse) se star(* 0.1 ** 0.05 *** 0.01)mtitles("L1" "L2" "L3" "L4" "L5" "L6" "L7" "L8")

*Final Chart
esttab r1 r4 r8 r17 using results.tex, replace stats(r2 N rmse) se star(* 0.1 ** 0.05 *** 0.01)mtitles("OLS" "Controls" "Log w/ Controls" "Lag w/ Controls")