
/* This do.file investigates the gaps in reading and mathematics test score gaps for native German students in 
   Germany. It performs a regression of PISA test scores on school track dummies. The analysis follows the 
   PISA Unbiased shortcut described in PISA Technical Report (2006)
   
 */

clear 

cap log close
set mem 400m
set more off


cd "K:\"


global PathData "Lanzara\Germany_schooltracks\working_data"        
global PathLog  "Lanzara\Germany_schooltracks\log_files"
global PathTables "Lanzara\Germany_schooltracks\tables"

log using "$PathLog\reg_analysis", replace

use "$PathData\pool.dta", clear

/* Dummify variables */

tab trackG, g(tG_)
tab track, g(t_)
tab year, g(y_)


/* REG ANALYSIS */

*Loop: 1=German students only, 2=all

forvalues i=1/1 {

if `i'==1 local X "tG_2 tG_3 y_2"
else if `i'==2 local X "t_2 t_3 y_2"
     
         *Loop over subjects

         local subjects "READ MATH"
                       
         foreach subject of local subjects {

         *State number of coefficients (including constant)
         local noc = 4
		 
		                  **************************************
		                  /* PISA UNBIASED SHORTCUT PROCEDURE */
                          **************************************
						  
						  
                   *This matrix will contain the coefficients obtained with Final Weight on all plausible values
                   mat M`i'=J(1,`noc',0)  
                   mat RSq`i'=J(1, 1, 0) 
                   *This matrix will contain the deviations from the mean of the coefficients obtained with Final Weight on PV1-5
                   mat T`i'=J(1,`noc',0)  
                   *This matrix will contain the deviations of coefficients obtained with 80 replicate weights from coefficients obtained with Final Weight, on PV 1 
                   mat R`i'=J(1,`noc',0)    
                   *This matrix will be used to obtain the column sums for R
                   mat J=J(1,81,1) 
                   *This matrix will be used to obtain the column sums for M
                   mat K=J(1,6,1) 
                   *This matrix will be used to obtain the column sums for SV and T
                   mat H=J(1,5,1) 
                   


               /*COMPUTATION OF FINAL COEFFICIENTS*/
 

               *Calculate coefficients on PVs 1-5 using only Final Weight

                foreach score of varlist zPV1`subject' - zPV5`subject' {
 
                                                              xi:  reg `score' `X' [pw=W_FSTUWT] 
                                                              
                                                              mat m`i'=e(b)
                                                              mat M`i'=M`i'\m`i' 
                                                              mat r2`i'=e(r2_a)
                                                              mat RSq`i'=RSq`i'\r2`i'
                                                              mat n`i'=e(N)
                                                              }   

                *Final Coefficients: Average the coefficients obtained with different PVs (K is a 1x6 vector of 1s)

                 mat FC`i'=(K*M`i')*(1/5) 

                *Final adjusted R-squared: Average the R squared obtained with different PVs (K is a 1x6 vector of 1s)

                 mat FRSq`i'`subject'=(K*RSq`i')*(1/5) 
               
                

                 /*COMPUTATION OF SAMPLING VARIANCE*/

                
                 *Calculate coefficients on PV1 using Final Weight and store them in vector a

                 xi: reg zPV1`subject' `X' [pw=W_FSTUWT]                                                         
                 mat a=e(b)
                 
                 *Calculate coefficients on PV1 for 80 replicate weights, subtract coefficients obtained with Final Weight and append the resulting vector to matrix R  

                 foreach weight of varlist  W_FSTR1- W_FSTR80 {

                                                                 xi: reg zPV1`subject' `X' [pw=`weight']                   
                                                                  mat b`i'=e(b)

                                                                  mat r`i'=b`i'-a
              
                                                                  mat R`i'=R`i'\r`i'

                                                             }
 
               *Hadamard(A, B) multiplies each element in A for the corresponding element in B. In this case we square each element of matrix R                                               }

               matrix vSQdiff`i'=hadamard(R`i', R`i') 
               
               *J is a 1x81 vector of 1s: J*R gives the column sum for each column of R
                                         
               matrix vsumSQdiff`i'=J*vSQdiff`i'
 
               *Calculate Sampling Variance on PV1 by dividing by 20 the sum of the squared deviations

               matrix SV`i'=vsumSQdiff`i'*(1/20)
                          
               
               
              
               
                 /*COMPUTATION OF IMPUTATION VARIANCE*/



                        forvalues row=2/6 {
                 
                        mat t`i'=M`i'[`row',1...]-FC`i'`m'
                         
                        mat T`i'=T`i'\t`i'
                               }

                        mat mSQdiff`i'=hadamard(T`i', T`i')

                        mat msumSQdiff`i'=K*mSQdiff`i'

                        mat IV`i'=msumSQdiff`i'*(1/4)




                /*FINAL ERROR VARIANCE AND FINAL STANDARD ERROR*/

                 mat wIV`i'=1.2*IV`i'
                     
                 mat FV`i'=SV`i'+ wIV`i'

                

                 *Calculate Final Standard Error

                                mat FSE`i'=J(1, `noc', 0)

                                forvalues element=1/`noc' {
           
                                scalar z=sqrt(FV`i'[1,`element'])

                                mat FSE`i'[1,`element']=z

                                }

                 /* CALCULATE P-VALUE */
                 
                  *T-stat

                  mat tstat`i'=J(1, `noc', 0)
         
                  forvalues element=1/`noc' {
  
                  scalar w=FC`i'[1,`element']/FSE`i'`m'[1,`element']
 
                  mat tstat`i'[1,`element']=w

                 }

                *P-value

                 mat P`i'=J(1, `noc', 0)

                 forvalues element=1/`noc' {
  
                  scalar pv=2*normal(-(abs(tstat`i'[1,`element'])))
 
                  mat P`i'[1,`element']=pv

                 }

   

mat results`i'`subject' = (FC`i'\FSE`i'\P`i')'

*end of loop over subjects
}
*end of loop over native Germans/all
}

/* EXPORT RESULTS*/

*native Germans only
mat results=results1READ, results1MATH
mat FRSq=FRSq1READ, FRSq1MATH
mat obs = n1

mat rownames results = Medium High year_2006 Constant
mat colnames results = Coeff SE P_value Coeff SE P_value 

mat rownames FRSq = adjusted_R_squared
mat rownames obs = observations

mat2txt, matrix(results) saving($PathTables\results.xls)  format(%12.3f) replace
mat2txt, matrix(FRSq) saving($PathTables\results.xls)  format(%12.3f) append
mat2txt, matrix(obs) saving($PathTables\results.xls)  format(%12.3f) append

log close
