***************************************************************************
							DRIM GAME 2021 
			CODE POUR OBTENIR LES MATRICES DE MIGRATIONS

			DATE VERSION - 28/11/2021



PLAN DU CODE :

PARTIE 1 - 
	Mise en forme de la base pour la création des matrices de migration.

PARTIE 2 - 
	Matrice de migration PIT à l'aide de la base mise en forme.

PARTIE 3 - 
	Matrice de migration TTC à l'aide des matrice de migration PIT.

PARTIE 4 - 
	Matrice de migration TTC cumulée à l'aide des matrice de migration TTC.


***************************************************** INSTRUCTIONS ************************************************************;


/*
Ne pas RUN le code de la Partie 1 car il sert seulement à obtenir la table 
"table_date_join" qui est fournit avec le code car les temps de traitement 
peuvent être long.

Run seulement le code à partir de la Partie 2 pour obtenir les matrices de 
migration PIT.

La library drim doit contenir :
- Le dataset "BASE_1" fournit par Deloitte
- Le fichier "correspondance_date"


******************************************************** CHEMINS ***************************************************************;


/*Mettre table_date_join dans la lib drim et la set dans la work pour faire 
tourner le code */

%let chemin = C:\Users\xteii\Documents\MORGANE\Finance\DELOITTE;
%let che_macro = C:\Users\xteii\Documents\MORGANE\Finance\DELOITTE\01. Programmes\01. Matrices de transition\Macro;

libname mat_in "&chemin.\04. Inputs\01. Matrices de transition";
libname mat_out "&chemin.\05. Outputs\01. Matrices de transition";



********************************************************************************************************************************
							PARTIE 1 - Mise en forme de la base pour la création des matrices de migration
********************************************************************************************************************************;
%include "&che_macro.\Partie_1.sas";

/* Copie de la base et concaténation avec la nouvelle base */
	data Base_copie ; set mat_in.Base_1 mat_in.Base_2; 	
		date_name = put(dtf_per_trt, date9.);
	run; 

/* Selection des ID_client disctincts pour les left joins plus tard */

	proc sql ;
		create table ID_client
		as select DISTINCT ID_BCR_TRS from 
		Base_copie; 
	quit;

/* Trie de la base par date */

	proc sort data = Base_copie;
		by dtf_per_trt;
	run;
 
/* Création de la liste des dates uniques de la base initiale */

	data date_liste; set Base_copie ;
		by dtf_per_trt;
		if first.dtf_per_trt;
	run;

/* Création d'une macro variable totcount contenant le nombre de date unique de la base */

	proc sql noprint;
		select count(distinct dtf_per_trt) into: totcount
		from date_liste;
	quit;

	%put The total count of variables is &totcount.;

/* Lancement des macros */

	%separation_mensuelle ;
	%fusion;

data mat_in.table_date_join; set table_date_join ; run;

	

********************************************************************************************************************************
							PARTIE 2 - Matrice de migration PIT à l'aide de la base mise en forme
********************************************************************************************************************************;
%include "&che_macro.\Partie_2.sas";

/* Copie de la base */

	data table_date_join_copie ; set mat_in.table_date_join; run;

/* Pour créer un liste de 96 colonnes dates à drop */

	proc contents data = table_date_join_copie  out = CONTENTS ; run;

	data CONTENTS; set CONTENTS; 
		date=substr(NAME,13,16); 
	run;

	proc sql ;    
		select distinct(NAME)
	    into   :LIST_VARIABLES_TO_DROP
	    separated by ' '
	    from WORK.CONTENTS
		where length(date)>4;
	quit ;

	%put &LIST_VARIABLES_TO_DROP. ;

/* DROP des colonnes dates */

	data table_date_join_copie;  set table_date_join_copie (drop= &LIST_VARIABLES_TO_DROP.);run;

/* Renommage des colonnes pour pouvoir appeler les colonnes d après leur position dans une boucle (attention col2 correspond au 31JAN2010 !!!) */

	proc transpose data=table_date_join_copie(obs=0 /*keep=_numeric_*/) out=vars;
	   var _all_;
	run;
	filename FT76F001 temp;

	data _null_;
	   file FT76F001;
	   set vars;
	   put 'Rename ' _name_ '=Col' _n_ ';';
	run;

	proc datasets;
	   modify table_date_join_copie;
	   %inc FT76F001;
	   run;
	   quit;

/* Récupération du fichier de correspondance entre les numéros de colonnes et les dates */

	proc import datafile="&chemin.\04. Inputs\01. Matrices de transition\Correspondance_date_matrix.csv"
	    out=mat_in.correspondance_date   
	    dbms=csv               
	    replace;              
	    delimiter=';';        
	    getnames=yes;        
	run; 

/* Mise au format des dates */

	data correspondance_date ; set mat_in.correspondance_date ; 
		date_name_2 = put(Date_names, date9.);
	run;

/* Lancement de la macro */

%migration_matrix;

/*Construction des matrices de migrations annuelles de 2018 et 2019 comme une moyenne des matrices PIT pour ces années*/

%matrice_2018_2019;

data mat_out.PIT_2018_transp; set PIT_2018_transp; run; 
data mat_out.PIT_2019_transp; set PIT_2019_transp; run; 
data mat_out.table_date_join; set table_date_join; run; 


PROC EXPORT DATA=mat_out.PIT_2018_transp
		    DBMS=csv 
		    OUTFILE="&chemin.\05. Outputs\01. Matrices de transition\PIT_2018_transp.csv" 
		    REPLACE;
 		    DELIMITER=";";
run;

PROC EXPORT DATA=mat_out.PIT_2019_transp
		    DBMS=csv 
		    OUTFILE="&chemin.\05. Outputs\01. Matrices de transition\PIT_2019_transp.csv" 
		    REPLACE;
 		    DELIMITER=";";
run;

********************************************************************************************************************************
							PARTIE 3 - Matrice de migration TTC à l'aide des matrice de migration PIT
********************************************************************************************************************************;
%include "&che_macro.\Partie_3.sas";

proc sql; 
	create table base as select key1, key2 from matrix_2;
quit;

proc sql;
   insert into base
   values (8,1)
   values (10,1)
	values (10,3);
quit;


proc sql ;
	create table Table_for_TTC_matrix 
	as select * from base;
quit ;

data correspondance_date2 ; set mat_in.correspondance_date;
	key_date = substr(Varnames,4,1);
run; 

%matrice_TTC;

proc contents data = Table_for_TTC_matrix_notmiss  out = VAR_TTC_matrix ; run;

proc sql ;    
        select distinct(NAME)
        into   :LIST_VARIABLES_TO_SUM
        separated by ' '
        from WORK.VAR_TTC_matrix
		where length(NAME) > 4;
		select COUNT(NAME)
        into   :NB_VARIABLES_TO_SUM
        from WORK.VAR_TTC_matrix
		where length(NAME) > 4;
        ;
    quit ;

data Table_for_TTC_matrix_sum (keep = key1 key2 TTC_matrix) ; set Table_for_TTC_matrix_notmiss;
 	TTC_matrix = sum(of &LIST_VARIABLES_TO_SUM.)/&NB_VARIABLES_TO_SUM.;
 run;

********************************************************************************************************************************
							PARTIE 4 - Matrice de migration TTC cumulée à l'aide des matrice de migration TTC
********************************************************************************************************************************;



%include "&che_macro.\Partie_4.sas";

%cumulate_TTC_matrix;

data mat_out.Table_for_TTC_matrix_transp; set Table_for_TTC_matrix_transp; run; 




********************************************************************************************************************************;

/*Exportation des tables au format CSV*/

	PROC EXPORT DATA=Table_for_TTC_matrix_cumulate
			    DBMS=csv 
			    OUTFILE="&chemin.\04. Inputs\03. Projections\Table_for_TTC_matrix_cumulate.csv"  
			    REPLACE;
	 		    DELIMITER=";";
	run;

	PROC EXPORT DATA=Table_for_TTC_matrix_cumulate
			    DBMS=csv 
			    OUTFILE="&chemin.\04. Inputs\01. Matrices de transition\Table_for_TTC_matrix_cumulate.csv"  
			    REPLACE;
	 		    DELIMITER=";";
	run;

	PROC EXPORT DATA=Table_for_TTC_matrix_transp
			    DBMS=csv 
			    OUTFILE="&chemin.\05. Outputs\01. Matrices de transition\Table_for_TTC_matrix_transp.csv"  
			    REPLACE;
	 		    DELIMITER=";";
	run;

	PROC EXPORT DATA=Table_for_TTC_matrix_notmiss
			    DBMS=csv 
			    OUTFILE="&chemin.\05. Outputs\01. Matrices de transition\Table_for_TTC_matrix_notmiss.csv"  
			    REPLACE;
	 		    DELIMITER=";";
	run;
