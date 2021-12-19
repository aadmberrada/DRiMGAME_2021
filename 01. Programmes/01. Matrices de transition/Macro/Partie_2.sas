
/* Macro matrice de migration annuelles avec un pas trimestriel */

%macro migration_matrix();
	%DO i = 2 %TO 121;
		%let j = %eval(&i+12) ;
		%let nom = %eval(&i-1);

		data _null_;
			set correspondance_date;
			if _n_=&nom. then do;
			call symput("date_name_2", date_name_2);
			end;
		run;

		data table_for_matrix_&date_name_2.; set table_date_join_copie(keep = col&i.-col&j.); 
			if missing(col&i.) or col&i.=11 or missing(col&j.) then delete ; 
		run;
		
		/*défaut absorbant*/
		data table_for_matrix2_&date_name_2.; set table_for_matrix_&date_name_2.; 
			%DO mois = &i. %TO &j.;
				%if col&mois. = 11 %then col&j. = 11 ; 
			%end;
		run;

		/***********matrice de migration PIT*************/
		proc freq data = table_for_matrix2_&date_name_2. NOPRINT;
				Tables col&i.*col&j. /out= matrix_&i. outpct;
		run;

		/*retrait des labels car la proc freq met automatiquement des labels*/
		proc datasets library=WORK nolist;
		  modify matrix_&i.;
		  attrib _all_ label='';
		quit;
		
		/*Drop ce dont on a pas besoin et rename PCT_ROW avec la date pour la jointure. Rename aussi des clefs de jointures*/
		data matrix_&i.(drop = COUNT PERCENT PCT_COL); 
			set matrix_&i.(rename = (PCT_ROW = percent_&date_name_2. col&i. = key1 col&j. = key2)); 
			if missing(percent_&date_name_2.) then percent_&date_name_2. = 0;
			else percent_&date_name_2. = percent_&date_name_2.;
		run;	
	%end;
%mend;


/* Macro matrice de migration annuelles avec un pas trimestriel */

%macro migration_matrix2();
	%DO i = 86 %TO 110;
		%let j = %eval(&i+12) ;
		%let nom = %eval(&i-1);

		data _null_;
			set correspondance_date;
			if _n_=&nom. then do;
			call symput("date_name_2", date_name_2);
			end;
		run;

		data table_for_matrix_&date_name_2.; set table_date_join2_copie(keep = col&i.-col&j.); 
			if missing(col&i.) or col&i.=11 or missing(col&j.) then delete ; 
		run;
		
		/*défaut absorbant*/
		data table_for_matrix2_&date_name_2.; set table_for_matrix_&date_name_2.; 
			%DO mois = &i. %TO &j.;
				%if col&mois. = 11 %then col&j. = 11 ; 
			%end;
		run;

		/***********matrice de migration PIT*************/
		proc freq data = table_for_matrix2_&date_name_2. NOPRINT;
				Tables col&i.*col&j. /out= matrix_&i. outpct;
		run;

		/*retrait des labels car la proc freq met automatiquement des labels*/
		proc datasets library=WORK nolist;
		  modify matrix_&i.;
		  attrib _all_ label='';
		quit;
		
		/*Drop ce dont on a pas besoin et rename PCT_ROW avec la date pour la jointure. Rename aussi des clefs de jointures*/
		data matrix_&i.(drop = COUNT PERCENT PCT_COL); 
			set matrix_&i.(rename = (PCT_ROW = percent_&date_name_2. col&i. = key1 col&j. = key2)); 
			if missing(percent_&date_name_2.) then percent_&date_name_2. = 0;
			else percent_&date_name_2. = percent_&date_name_2.;
		run;	
	%end;
%mend;
