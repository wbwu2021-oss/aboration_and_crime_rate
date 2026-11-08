

/*This code clans the fertility and crime data sets so that the data can be merged.
Code shows data from 1985 to 2019 that is present in both data sets.*/

%let lag_years = 20;

/*National and State Pregnancy dataset*/
proc import datafile='/home/u64580526/STAT520/NationalAndStatePregnancy_PublicUse.csv'
    out=abortions
    dbms=csv
    replace;
    guessingrows=max;
    getnames=yes;
run;

/*State Crime dataset*/
proc import datafile= '/home/u64580526/STAT520/state_crime.csv'
    out=crimes
    dbms=csv
    replace;
    getnames=yes;
    guessingrows=max;
run;

/*Restricting a time period, can be changed to 2000-2019*/
data abortions_clean;
    set abortions;
    cohort_year = year; 
    where (1985 - &lag_years.) <= year <= (2020 - &lag_years.); 
    
    if population1544 > 0 then do;
    abortionratetotal_100k = (abortionstotal/population1544)* 100000;
  end;
  state = upcase(strip(state)); 
  year = year + &lag_years.;
run;

/*Since the crime rate is already by 100k people this instead ccak*/
data crime_rates;
    set crimes;
    total_crime = Data_Totals_Property_All + Data_Totals_Violent_All;
    total_crime_rate = Data_Rates_Property_All + Data_Rates_Violent_All;
run;

data crimes_clean;
    length state $2. year 8;
    set crime_rates(rename=(state=orig_state));
    where 1985 <= year <=2020;

    orig_state_clean = strip(orig_state);
    select (orig_state_clean);
        when ('Alabama')              state = 'AL';
        when ('Alaska')               state = 'AK';
        when ('Arizona')              state = 'AZ';
        when ('Arkansas')             state = 'AR';
        when ('California')           state = 'CA';
        when ('Colorado')             state = 'CO';
        when ('Connecticut')          state = 'CT';
        when ('Delaware')             state = 'DE';
        when ('District of Columbia') state = 'DC';
        when ('Florida')              state = 'FL';
        when ('Georgia')              state = 'GA';
        when ('Hawaii')               state = 'HI';
        when ('Idaho')                state = 'ID';
        when ('Illinois')             state = 'IL';
        when ('Indiana')              state = 'IN';
        when ('Iowa')                 state = 'IA';
        when ('Kansas')               state = 'KS';
        when ('Kentucky')             state = 'KY';
        when ('Louisiana')            state = 'LA';
        when ('Maine')                state = 'ME';
        when ('Maryland')             state = 'MD';
        when ('Massachusetts')        state = 'MA';
        when ('Michigan')             state = 'MI';
        when ('Minnesota')            state = 'MN';
        when ('Mississippi')          state = 'MS';
        when ('Missouri')             state = 'MO';
        when ('Montana')              state = 'MT';
        when ('Nebraska')             state = 'NE';
        when ('Nevada')               state = 'NV';
        when ('New Hampshire')        state = 'NH';
        when ('New Jersey')           state = 'NJ';
        when ('New Mexico')           state = 'NM';
        when ('New York')             state = 'NY';
        when ('North Carolina')       state = 'NC';
        when ('North Dakota')         state = 'ND';
        when ('Ohio')                 state = 'OH';
        when ('Oklahoma')             state = 'OK';
        when ('Oregon')               state = 'OR';
        when ('Pennsylvania')         state = 'PA';
        when ('Rhode Island')         state = 'RI';
        when ('South Carolina')       state = 'SC';
        when ('South Dakota')         state = 'SD';
        when ('Tennessee')            state = 'TN';
        when ('Texas')                state = 'TX';
        when ('Utah')                 state = 'UT';
        when ('United States')        state = 'US';
        when ('Vermont')              state = 'VT';
        when ('Virginia')             state = 'VA';
        when ('Washington')           state = 'WA';
        when ('West Virginia')        state = 'WV';
        when ('Wisconsin')            state = 'WI';
        when ('Wyoming')              state = 'WY';
        otherwise                     state = '??';
    end;
    drop orig_state orig_state_clean;
run;


proc sort data=abortions_clean;
    by state year;
run;

proc sort data=crimes_clean;
    by state year;
run;

proc means data=abortions_clean n nmiss mean std min max maxdec=2;
    var abortionratetotal_100k;
run;

proc means data=crimes_clean n nmiss mean std min max maxdec=2;
    var total_crime_rate;
run;

/*merge*/
data merged_data;
    merge abortions_clean(in=a)
          crimes_clean(in=b);
    by state year;
    if b;
    if missing(abortionratetotal_100k) then missing_abortion = 1;
    else missing_abortion = 0;
run;

proc means data=merged_data
    mean median std min max q1 q3;
    var abortionratetotal abortionratetotal_100k total_crime_rate;
run;

proc freq data=merged_data;
    tables year;
run;

proc sql;
select state,cohort_year as abortion_original_year,
     year as crime_observation_year,&lag_years. as applied_time_lag,
    Data_Population,total_crime,total_crime_rate,Data_Rates_Property_All,Data_Rates_Property_Burglary,
    Data_Rates_Property_Larceny,Data_Rates_Property_Motor,Data_Rates_Violent_All, Data_Rates_Violent_Assault,
    abortionratetotal_100k,abortionstotal,abortionratetotal,
    birthstotal,birthratetotal,pregnanciestotal,pregnancyratetotal,population1544
from merged_data
where state in ('CA', 'TX')
order by state, year;
quit;


proc univariate data=merged_data;
    var abortionratetotal_100k total_crime_rate;
run;


proc corr data=merged_data pearson spearman;
    var abortionratetotal_100k total_crime_rate;
run;

proc sgplot data=merged_data;
    scatter x=abortionratetotal_100k y=total_crime_rate;
    reg x=abortionratetotal_100k y=total_crime_rate;
run;

proc sgplot data=merged_data;
    where state in ('CA', 'TX');
    series x=year y=total_crime_rate / name="crime" lineattrs=(color=red thickness=2);
    series x=year y=abortionratetotal_100k / y2axis name="abortion" lineattrs=(color=blue thickness=2 pattern=dash);
    xaxis label="Crime Observation Year";
    yaxis label="Total Crime Rate (per 100k)";
    y2axis label="Abortion Rate (per 100k) — 20 Years Prior"; 
    keylegend "crime" "abortion";
run;
