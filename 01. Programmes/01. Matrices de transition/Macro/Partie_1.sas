/* Macro permettant de séparer la base initiale en 96 bases mensuelles tout en renommant les variables avec la date (pour pas se tromper plus tard)*/

%macro separation_mensuelle();
	%do counter = 1 %to &totcount.;

		/*Création d'une macro variable compteur (counter) et d'une macro variable date du mois*/
		data _null_;
			set date_liste;
			if _n_=&counter.;
			call symput("date_mois", dtf_per_trt);
		run;
		%put &date_mois;

		/*création d'une macro variable date du mois en chaine de caractère pour renommer les variables*/
		data _null_;
			call symput("date_mois_chaine", put(&date_mois, date9.));
		run;
			
		/*créer un dataframe avec uniquement les observations d'un mois*/
		proc sql; 
			create table table_date_&counter.
			as select * from Base_copie
			where date_name = put(&date_mois., date9.) ;
		quit;

		/*renommer les variables de la base en tenant compte de la date*/
		data table_date_&counter.; 
			set table_date_&counter. (drop = date_name 
									rename = (classe = classe_&date_mois_chaine dtf_per_trt = dtf_per_trt_&date_mois_chaine));
		run;
	%end;
%mend;

/* Left join chaque base sur la base support */

%macro fusion;

/* Création de la base support */

	proc sql ;
		create table Table_date_join 
		as select * from ID_client as a
		left join Table_date_1 
		on a.ID_BCR_TRS = Table_date_1.ID_BCR_TRS;
	quit ;

	%do i=2 %TO &totcount.;
		proc sql; 
			CREATE TABLE Table_date_join AS
			SELECT * from Table_date_join as a LEFT JOIN Table_date_&i
			ON a.ID_BCR_TRS = Table_date_&i..ID_BCR_TRS;
		quit;
	%end;
%mend;


/* Macro permettant de séparer la base initiale en 96 bases mensuelles tout en renommant les variables avec la date (pour pas se tromper plus tard)*/

%macro separation_mensuelle2();
	%do counter = 1 %to &totcount.;

		/*Création d'une macro variable compteur (counter) et d'une macro variable date du mois*/
		data _null_;
			set date_liste2;
			if _n_=&counter.;
			call symput("date_mois", dtf_per_trt);
		run;
		%put &date_mois;

		/*création d'une macro variable date du mois en chaine de caractère pour renommer les variables*/
		data _null_;
			call symput("date_mois_chaine", put(&date_mois, date9.));
		run;
			
		/*créer un dataframe avec uniquement les observations d'un mois*/
		proc sql; 
			create table table_date2_&counter.
			as select * from Base_2_copie
			where date_name = put(&date_mois., date9.) ;
		quit;

		/*renommer les variables de la base en tenant compte de la date*/
		data table_date2_&counter.; 
			set table_date2_&counter. (drop = date_name 
									rename = (classe = classe_&date_mois_chaine dtf_per_trt = dtf_per_trt_&date_mois_chaine));
		run;
	%end;
%mend;

/* Left join chaque base sur la base support */

%macro fusion2;

/* Création de la base support */

	proc sql ;
		create table Table_date_join2 
		as select * from ID_client2 as a
		left join Table_date_2 
		on a.ID_BCR_TRS = Table_date_2.ID_BCR_TRS;
	quit ;

	%do i=1 %TO &totcount.;
		proc sql; 
			CREATE TABLE Table_date_join2 AS
			SELECT * from Table_date_join2 as a LEFT JOIN Table_date2_&i
			ON a.ID_BCR_TRS = Table_date2_&i..ID_BCR_TRS;
		quit;
	%end;
%mend;



%macro matrice_2018_2019;

	proc sql; 
		create table base_2018 as select key1, key2 from matrix_98;
	quit;

	proc sql;
	   insert into base_2018 
	   values (10,1);
	quit;


	proc sql ;
		create table Table_for_2018_PIT 
		as select * from base_2018;
	quit ;

	proc sql; 
		create table base_2019 as select key1, key2 from matrix_110;
	quit;

	proc sql;
	   insert into base_2019
	   values (9,1)
	   values (10,1);
	quit;

	proc sql ;
		create table Table_for_2019_PIT 
		as select * from base_2019;
	quit ;

	data correspondance_date2 ; set mat_in.correspondance_date;
		key_date = substr(Varnames,4,1);
	run; 

	%do i = 98 %TO 109 ;
		proc sql; 
			CREATE TABLE Table_for_2018_PIT AS
			SELECT * from Table_for_2018_PIT as a LEFT JOIN matrix_&i.
			ON a.key1 = matrix_&i..key1 and a.key2 = matrix_&i..key2;
		quit;
	%end;

	%do i = 110 %TO 121 ;
		proc sql; 
			CREATE TABLE Table_for_2019_PIT AS
			SELECT * from Table_for_2019_PIT as a LEFT JOIN matrix_&i.
			ON a.key1 = matrix_&i..key1 and a.key2 = matrix_&i..key2;
		quit;
	%end;

	
	proc stdize data = work.Table_for_2018_PIT 
		out= work.Table_for_2018_PIT_not_miss 
		reponly missing=0;
	run;

	proc stdize data = work.Table_for_2019_PIT 
		out= work.Table_for_2019_PIT_not_miss 
		reponly missing=0;
	run;

	proc contents data = Table_for_2018_PIT  out = VAR_Table_for_2018_PIT ; run;
	proc contents data = Table_for_2019_PIT  out = VAR_Table_for_2019_PIT ; run;

	

	proc sql ;    
	        select distinct(NAME)
	        into   :LIST_VARIABLES_TO_SUM_2018
	        separated by ' '
	        from WORK.VAR_Table_for_2018_PIT
			where length(NAME) > 4;
			select distinct(NAME)
	        into   :LIST_VARIABLES_TO_SUM_2019
	        separated by ' '
	        from WORK.VAR_Table_for_2019_PIT
			where length(NAME) > 4;
			select COUNT(NAME)
	        into   :NB_VARIABLES_TO_SUM_2018
	        from WORK.VAR_Table_for_2018_PIT
			where length(NAME) > 4;
			select COUNT(NAME)
			into   :NB_VARIABLES_TO_SUM_2019
	        from WORK.VAR_Table_for_2019_PIT
			where length(NAME) > 4;
	        ;
		run;

	data PIT_2018 (keep = key1 key2 PIT_2018) ; set Table_for_2018_PIT_not_miss;
	 	PIT_2018 = sum(of &LIST_VARIABLES_TO_SUM_2018.)/&NB_VARIABLES_TO_SUM_2018.;
	 run;

	data PIT_2019 (keep = key1 key2 PIT_2019) ; set Table_for_2019_PIT_not_miss;
	 	PIT_2019 = sum(of &LIST_VARIABLES_TO_SUM_2019.)/&NB_VARIABLES_TO_SUM_2019.;
	 run;

	PROC TRANSPOSE DATA = PIT_2018 OUT = PIT_2018_transp (drop = _NAME_) PREFIX = key2_ ;
	  BY key1 ;
	  VAR PIT_2018 ;
	  ID key2;
	RUN ;

	PROC TRANSPOSE DATA = PIT_2019 OUT = PIT_2019_transp (drop = _NAME_) PREFIX = key2_ ;
	  BY key1 ;
	  VAR PIT_2019 ;
	  ID key2;
	RUN ;



%mend ;
