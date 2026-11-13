/* Step 2: Standardize state names.
   Run 01_import_crime.sas first in the same SAS session.
   Preserve the full state name and create a two-letter matching key.
   US and unrecognized names are retained for review, not silently deleted.
*/

data crimes_state;
    set crimes_numeric;
    length state_code $2;

    select (strip(State));
        when ('Alabama') state_code='AL';
        when ('Alaska') state_code='AK';
        when ('Arizona') state_code='AZ';
        when ('Arkansas') state_code='AR';
        when ('California') state_code='CA';
        when ('Colorado') state_code='CO';
        when ('Connecticut') state_code='CT';
        when ('Delaware') state_code='DE';
        when ('District of Columbia') state_code='DC';
        when ('Florida') state_code='FL';
        when ('Georgia') state_code='GA';
        when ('Hawaii') state_code='HI';
        when ('Idaho') state_code='ID';
        when ('Illinois') state_code='IL';
        when ('Indiana') state_code='IN';
        when ('Iowa') state_code='IA';
        when ('Kansas') state_code='KS';
        when ('Kentucky') state_code='KY';
        when ('Louisiana') state_code='LA';
        when ('Maine') state_code='ME';
        when ('Maryland') state_code='MD';
        when ('Massachusetts') state_code='MA';
        when ('Michigan') state_code='MI';
        when ('Minnesota') state_code='MN';
        when ('Mississippi') state_code='MS';
        when ('Missouri') state_code='MO';
        when ('Montana') state_code='MT';
        when ('Nebraska') state_code='NE';
        when ('Nevada') state_code='NV';
        when ('New Hampshire') state_code='NH';
        when ('New Jersey') state_code='NJ';
        when ('New Mexico') state_code='NM';
        when ('New York') state_code='NY';
        when ('North Carolina') state_code='NC';
        when ('North Dakota') state_code='ND';
        when ('Ohio') state_code='OH';
        when ('Oklahoma') state_code='OK';
        when ('Oregon') state_code='OR';
        when ('Pennsylvania') state_code='PA';
        when ('Rhode Island') state_code='RI';
        when ('South Carolina') state_code='SC';
        when ('South Dakota') state_code='SD';
        when ('Tennessee') state_code='TN';
        when ('Texas') state_code='TX';
        when ('Utah') state_code='UT';
        when ('Vermont') state_code='VT';
        when ('Virginia') state_code='VA';
        when ('Washington') state_code='WA';
        when ('West Virginia') state_code='WV';
        when ('Wisconsin') state_code='WI';
        when ('Wyoming') state_code='WY';
        when ('United States') state_code='US';
        otherwise state_code='??';
    end;
run;

/* QC: show the mapping and identify any unrecognized state names. */
proc freq data=crimes_state;
    tables State*state_code / list missing;
run;

proc print data=crimes_state;
    where state_code='??';
    var State year;
run;
