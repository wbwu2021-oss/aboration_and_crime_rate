/* Step 4: Merge state-year abortion and crime data.
   Prerequisites: Steps 1-3 in the same SAS session.
   The Step 3 GitHub dataset is named ABORTIONS_LAG.
   Run the duplicate checks first; proceed only if both return no rows.
*/

/* Check that each matching key appears only once in each input. */
proc sql;
    select state_code, year, count(*) as n
    from abortions_lag
    group by state_code, year
    having calculated n > 1;

    select state_code, year, count(*) as n
    from crimes_state
    where state_code not in ('US', '??', '')
    group by state_code, year
    having calculated n > 1;
quit;

/* Match state and year, keeping only complete model observations. */
proc sql;
    create table model_data as
    select a.state_code, a.cohort_year, a.year, a.abortion_rate,
           c.population, c.property_crime_rate,
           c.violent_crime_rate, c.total_crime_rate
    from abortions_lag as a
    inner join crimes_state as c
        on a.state_code = c.state_code
        and a.year = c.year
    where a.state_code not in ('US', '??', '')
      and c.total_crime_rate is not missing
      and a.abortion_rate is not missing
    order by a.state_code, a.year;
quit;

/* QC: inspect values, count observations and confirm lag. */
proc print data=model_data(obs=10);
run;

proc freq data=model_data;
    tables year / missing;
run;

proc sql;
    select count(*) as n_observations,
           count(distinct state_code) as n_states,
           min(year) as first_year,
           max(year) as last_year
    from model_data;

    select distinct year-cohort_year as actual_lag
    from model_data;
quit;
