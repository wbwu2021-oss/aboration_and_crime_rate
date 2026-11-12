/* 01_import_crime.sas
   Purpose: import the crime CSV with explicit types for modeling.
   Input: DATAFILE/state_crime.csv (copy to SAS Studio server first).
   Output: WORK.CRIMES_NUMERIC.
   Set data_dir to the directory containing your uploaded CSV.
   Run in SAS Studio; this program has not yet been executed in SAS.
*/

%let data_dir = /home/YOUR_SAS_USER/STAT520;

data work.crimes_numeric;
    infile "&data_dir./state_crime.csv"
        dsd dlm=',' firstobs=2 truncover lrecl=32767;
    length state_name $40;
    input state_name :$40.
          year :best32.
          population :best32.
          property_crime_rate :best32.
          burglary_rate :best32.
          larceny_rate :best32.
          motor_rate :best32.
          violent_crime_rate :best32.;
    total_crime_rate = property_crime_rate + violent_crime_rate;
    keep state_name year population property_crime_rate
         violent_crime_rate total_crime_rate;
run;

/* Verify imported types and sample values. */
proc contents data=work.crimes_numeric;
run;

proc print data=work.crimes_numeric(obs=10);
run;

/* Check missing values and coverage before any merge. */
proc means data=work.crimes_numeric n nmiss min max;
    var year population property_crime_rate
        violent_crime_rate total_crime_rate;
run;
