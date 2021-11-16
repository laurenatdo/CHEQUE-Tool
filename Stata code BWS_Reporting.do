*Do file: Stata code for BWS Survey, 36 attributes, 6 items/profile
*Date last modified: 4/19/2021
 
 ***This do file has the following sections: ***
	*1. General setting up for stata - specify your path folder here! 
	*2. Import data
	*3. Clean up, expand, set up data for analysis
	*4. Regression analysis of BWS data
 

*--------------------------------------------------
*1. General Stata program set-up
*--------------------------------------------------
clear all
set linesize 200
macro drop _all
capture log close
cd "G:\Projects\PhRMA Foundation Research Award - CEA Quality Assessment Tool\7. Data Analysis\Reporting"
set more off, perm
*--------------------------------------------------

*--------------------------------------------------
*2. Import your exp design and data
*--------------------------------------------------

*Import your experimental design from xls & save in stata format .dta
import excel "BWS_1_36 objects REPORTING.xlsx", sheet("Sheet1") firstrow
save "BWSExpDesign.dta", replace

*Import your data
import excel "BWSData_Reporting.xlsx", sheet("Sheet1") firstrow clear
save "BWSData_Reporting.dta", replace


*--------------------------------------------------
* 3. Clean up, expand, set up data for analysis
*--------------------------------------------------

*Create Response ID
	gen respid=_n
	order respid
		//creates a unique response number for each respondent 

*Reshape data into long format
	reshape long T@_Best T@_Worst, i(respid) j(task)
		
*Generate a grouping variable
	gen resptask=respid*100+task
		//creates an id that is unique for both the person and the task

*Generate 6 options for each task
	expand 6
	sort respid task
	egen option = seq(), f(1) t(6)
	order respid task option
	sort respid task option
	

*Merge with BWS experimental design
	merge m:1 task option using "BWSExpDesign.dta", nogen

	sort respid task option 

	
*Make the attribute selected variable dichotimous, 0 = not selected,1 = selected, . = refused to answer
	gen best=1 if factor==T_Best
	replace best=0 if factor!=T_Best
	replace best=. if T_Best==-1
	
	gen worst=1 if factor==T_Worst
	replace worst=0 if factor!=T_Worst
	replace worst=. if T_Worst==-1
	
	order respid task option factor best worst

*Label statements - optional but highly reccomended
	label define factorlabel ///
	1 "1. Decision problem and scope" ///
	2 "2. Decision problem and scope" ///
	3 "1. Intervention and comparator(s)" ///
	4 "2. Intervention and comparator(s)" ///
	5 "1. Perspective" ///
	6 "1. Population" ///
	7 "2. Population" ///
	8 "1. Outcome measures" ///
	9 "2. Outcome measures" ///
	10 "1. Time Horizon and discounting" ///
	11 "2. Time Horizon and discounting" ///
	12 "1. Modeling" ///
	13 "2. Modeling" ///
	14 "3. Modeling" ///
	15 "4. Modeling" ///
	16 "5. Modeling" ///
	17 "1. Data inputs and evidence synthesis" ///
	18 "2. Data inputs and evidence synthesis" ///
	19 "3. Data inputs and evidence synthesis" ///
	20 "1. Consequences" ///
	21 "1.  Utilities (preference measures)" ///
	22 "1. Costs and resource use" ///
	23 "2. Costs and resource use" ///
	24 "1. Analysis" ///
	25 "2. Analysis" ///
	26 "3. Analysis" ///
	27 "1. Equity considerations" ///
	28 "1. Transparency and reporting" ///
	29 "2. Transparency and reporting" ///
	30 "3. Transparency and reporting" ///
	31 "4. Transparency and reporting" ///
	32 "5. Transparency and reporting" ///
	33 "6. Transparency and reporting" ///
	34 "7. Transparency and reporting" ///
	35 "8. Transparency and reporting" ///
	36 "9. Transparency and reporting"
	
	label values factor factorlabel

	save "BWS_best.dta", replace


* Create a 'worst' dataset
	gen typew=1
		// generating an identifying variable indicating that this data is from the 
		// worst dataset; helpful for data management when we append back to original

	gen choice=worst
		// indicating which attribute was chosen as worst
			
	drop if best==1
		//sequential BWS. We assume that people choose the best attribute first,
		// so whatever "best" attribue was chosen is no longer an option for worst. 
		// This is removing that best attribute, leaving only three choices for worst
			
	replace f1=-f1
	replace f2=-f2
	replace f3=-f3
	replace f4=-f4
	replace f5=-f5
	replace f6=-f6
	replace f7=-f7
	replace f8=-f8
	replace f9=-f9
	replace f10=-f10
	replace f11=-f11
	replace f12=-f12
	replace f13=-f13
	replace f14=-f14
	replace f15=-f15
	replace f16=-f16
	replace f16=-f16
	replace f17=-f17
	replace f18=-f18
	replace f19=-f19
	replace f20=-f20
	replace f21=-f21
	replace f22=-f22
	replace f23=-f23
	replace f24=-f24
	replace f25=-f25
	replace f26=-f26
	replace f27=-f27
	replace f28=-f28
	replace f29=-f29
	replace f30=-f30
	replace f31=-f31
	replace f32=-f32
	replace f33=-f33
	replace f34=-f34
	replace f35=-f35
	replace f36=-f36
	// changing the independant variables to negative; this will indicate that they were chosen as "worst" once we append with the best data in the original dataset 
	save "BWS_worst.dta", replace
	
* Moving back to 'best' dataset and appending best and worst datasets **

	use "BWS_best.dta", clear
	
	gen typew=0
		// indicating the data reflects best, not worst
		
	gen choice=best
		// indicating which attribute was chosen as best
	
	append using "BWS_worst.dta"	
		// appending this original dataset which includes best data with the dataset including the worst data

	sort respid	task 
		
	gen resptasktypew=1000*respid+10*task+typew
		// unique ID for each specific task, first 1-3 numbers reflects responID; 
		// next two reflects task number; final reflects best (0) or worst (1)

	save "BWS_best_worst.dta", replace
	
*Creating effects coding
	gen f1e=f1-f36
	gen f2e=f2-f36 
	gen f3e=f3-f36
	gen f4e=f4-f36
	gen f5e=f5-f36
	gen f6e=f6-f36
	gen f7e=f7-f36
	gen f8e=f8-f36
	gen f9e=f9-f36
	gen f10e=f10-f36
	gen f11e=f11-f36
	gen f12e=f12-f36
	gen f13e=f13-f36
	gen f14e=f14-f36 
	gen f15e=f15-f36
	gen f16e=f16-f36
	gen f17e=f17-f36
	gen f18e=f18-f36
	gen f19e=f19-f36
	gen f20e=f20-f36
	gen f21e=f21-f36
	gen f22e=f22-f36
	gen f23e=f23-f36
	gen f24e=f24-f36
	gen f25e=f25-f36
	gen f26e=f26-f36
	gen f27e=f27-f36
	gen f28e=f28-f36
	gen f29e=f29-f36
	gen f30e=f30-f36
	gen f31e=f31-f36
	gen f32e=f32-f36
	gen f33e=f33-f36
	gen f34e=f34-f36
	gen f35e=f35-f36
	
*--------------------------------------------------
* 4. Regression analysis of BWS data
*--------------------------------------------------
*Install necesarry packages if you do not already have them
ssc install mixlogit
ssc install lclogit


*Conditional logit - these are the variables denoting the attributes/levels
global varse "f1e f2e f3e f4e f5e f6e f7e f8e f9e f10e f11e f12e f13e f14e f15e f16e f17e f18e f19e f20e f21e f22e f23e f24e f25e f26e f27e f28e f29e f30e f31e f32e f33e f34e f35e"

clogit choice $varse , group(resptasktypew) vce(cluster resptasktypew)

*Confidence in survey answers
clogit choice $varse if Q1_D==0|Q1_D==1, group(resptasktypew) vce(cluster resptasktypew)
clogit choice $varse if Q1_D==2|Q1_D==3, group(resptasktypew) vce(cluster resptasktypew)

*Understanding of CEAs
**Choice "1" has been removed because it represented no understanding of CEAs
clogit choice $varse if Q2_D==2, group(resptasktypew) vce(cluster resptasktypew)
clogit choice $varse if Q2_D==3, group(resptasktypew) vce(cluster resptasktypew)

*Length of career in HEOR
clogit choice $varse if Q3_D==1|Q3_D==2|Q3_D==3, group(resptasktypew) vce(cluster resptasktypew)
clogit choice $varse if Q3_D==4|Q3_D==5|Q3_D==6, group(resptasktypew) vce(cluster resptasktypew)

*Sector participant works in
clogit choice $varse if strpos(lower(Q4D),"university/academic")>0|strpos(lower(Q4D),"government")>0|strpos(lower(Q4D),"hospital/medical care delivery")>0, group(resptasktypew) vce(cluster resptasktypew)
clogit choice $varse if strpos(lower(Q4D),"consulting/contract research")>0|strpos(lower(Q4D),"biotech/pharmaceutical/medical technology")>0|strpos(lower(Q4D),"non-profit organization (e.g. foundation)")>0, group(resptasktypew) vce(cluster resptasktypew)


*Mixed logit
mixlogit choice, group(resptasktypew) id(respid) rand($varse)

*Latent class
lclogit choice $varse, id(respid) group(resptask) nclasses(3) nolog
	// you are specifying 3 classes here, that can be changed
