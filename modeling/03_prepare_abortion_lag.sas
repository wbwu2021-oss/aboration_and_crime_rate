/* Step 3: Prepare abortion data with a 20-year lag.
   Prerequisite: run 01_import_crime.sas in the same SAS session.
   Use the original abortion rate per 1,000 women aged 15-44.
   Preserve the original abortion year; align year to the crime year.
   Exclude national totals and limit target crime years to 1985-2020,
   consistent with the group's existing lag analysis.
*/

data abortions_lag;
    set abortions;

    length state_code $2;
    state_code = upcase(strip(state));

    cohort_year = year;
    year = cohort_year + 20;

    abortion_rate = abortionratetotal;

    if state_code = 'US' then delete;
    if missing(state_code) then delete;
    if year < 1985 or year > 2020 then delete;
    if missing(abortion_rate) then delete;

    keep state_code cohort_year year abortion_rate;
run;

/* QC: inspect observations and actual year coverage. */
proc print data=abortions_lag(obs=10);
run;

proc freq data=abortions_lag;
    tables year / missing;
run;

proc means data=abortions_lag n nmiss min max;
    var cohort_year year abortion_rate;
run;
