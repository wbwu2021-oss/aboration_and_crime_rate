/* Step 1: Import and prepare crime data.
   Set data_dir to your own SAS Studio server folder.
   Use VALIDVARNAME=ANY to preserve the CSV column names.
   This program assumes the crime numeric-looking fields import as
   character, as observed in the project SAS Studio session.
   Check PROC CONTENTS before the conversion if import types change.
*/
%let data_dir=/home/YOUR_SAS_USER/abortion_crime_modeling;
options validvarname=any;

proc import datafile="&data_dir./NationalAndStatePregnancy_PublicUse.csv"
    out=abortions dbms=csv replace;
    guessingrows=max;
    getnames=yes;
run;

proc import datafile="&data_dir./state_crime.csv"
    out=crimes dbms=csv replace;
    guessingrows=max;
    getnames=yes;
run;

data crimes_numeric;
    set crimes(rename=(Year=year_char));
    year = input(year_char, best32.);
    population = input('Data.Population'n, best32.);
    property_crime_rate = input('Data.Rates.Property.All'n, best32.);
    violent_crime_rate = input('Data.Rates.Violent.All'n, best32.);
    total_crime_rate = property_crime_rate + violent_crime_rate;
    keep State year population property_crime_rate
         violent_crime_rate total_crime_rate;
run;

proc print data=crimes_numeric(obs=10);
run;
proc contents data=crimes_numeric;
run;
