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
