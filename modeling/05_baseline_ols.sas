/* Step 5: Baseline ordinary least squares (OLS) regression.
   Run Steps 01-04 first in the same SAS Studio session.
   Input: WORK.MODEL_DATA (one record per matched state and crime year).
   Y: total_crime_rate (crimes per 100,000 residents).
   X: abortion_rate (abortions per 1,000 women aged 15-44,
      measured 20 years before the crime observation year).

   This is an unadjusted baseline association, NOT a causal model.
   Ordinary PROC REG standard errors do not account for repeated
   observations within states. We will address that in a later model.
*/

/* Check the sample that will enter the regression. */
proc means data=model_data n nmiss;
    var abortion_rate total_crime_rate;
run;

/* Fit the simple OLS model and request 95% coefficient intervals. */
ods graphics on;

proc reg data=model_data;
    model total_crime_rate = abortion_rate / clb;
    title "Step 5: Baseline OLS - Abortion Rate and Crime Rate";
run;
quit;

title;
ods graphics off;

/* User-reported SAS results (Nov 18, 2026):
   N=153; slope=29.28381; SE=6.08889;
   95% CI=(17.25339, 41.31423); p<0.0001;
   intercept=2617.25008; R-squared=0.1328;
   Root MSE=803.64832.
   The coefficient is a preliminary positive association.
   These values are documentation, not programmatically verified here.
*/
