/*OLS modeling*/
proc means data=model_data n nmiss; /* count non-missing and missing observations*/
	var abortion_rate total_crime_rate; /*specify the variables to examine*/
	
run;

/*statistical modeling OLS*/
proc reg data=model_data;
	model total_crime_rate=abortion_rate/clb;
	/* model Y(dependent variable)=X (independent variable)
	/clb confidence intervals*/
run;
quit;

/* two_way fixed effects regression*/

proc glm data=model_data; /* glm: general linear models*/
	class state_code year;
	
	model total_crime_rate = abortion_rate state_code year/solution;
	/* solution: display the estimated regression coefficients*/

run;
quit;

/* Fixed effects with clustered standard errors*/

proc surveyreg data=model_data; /* using survey-design variance estimation*/
	cluster state_code;
	class state_code year;
	
	model total_crime_rate = abortion_rate state_code year/solution;

run;

proc freq data=crimes_state;
	where year in (2008,2012,2016,2020);
	tables year;
run;

/* indentify influential observations*/

proc reg data=model_data;
	model total_crime_rate = abortion_rate;
	output out=ols_diagnostics
		cookd=cooks_d;
		
run;
quit;

/*sort observations by cook's distance*/

proc sort data=ols_diagnostics;
	by descending cooks_d;
run;

/* display the 5 most influential observations*/

proc print data=ols_diagnostics (obs=5);
	var state_code year abortion_rate
		total_crime_rate cooks_d;
run;

/* OLS sensitivity analysis excluding DC*/

proc reg data=model_data;
	where state_code ne 'DC';
	model total_crime_rate = abortion_rate/clb;
run;
quit;

/*compare CA and TX only*/

proc print data=model_data;
	where state_code in ('CA', 'TX');
	
	var state_code
		cohort_year
		year
		abortion_rate
		total_crime_rate;
		
run;

data ca_tx;
	set model_data;
	where state_code in ('CA', 'TX');
	
	texas=(state_code = 'TX');
	interaction =abortion_rate * texas;
run;

proc reg data=ca_tx;
	model total_crime_rate = abortion_rate texas interaction/clb;
run;
quit;
