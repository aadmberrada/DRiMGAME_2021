**********************************************************************************************************************************
							DRIM GAME 2021 
			MISE EN OEUVRE DU MODELE ECONOMETRIQUE

			DATE VERSION - 12/11/2021



PLAN DU CODE :

PARTIE 1 - 
	Tests de stationnarité.

PARTIE 2 - 
	Transformation des variables.

PARTIE 3 - 
	Analyse exploratoire.

PARTIE 4 - 
	Sélection des variables.

PARTIE 5 -
	Modélisation

PARTIE 6 -
	Mise en oeuvre des stress


***************************************************** INSTRUCTIONS ************************************************************;


/* Pour plus de clarté, les macros sont stockés dans des fichiers séparés. Pour lancer le code seul "chemin" doit être modifier
ce dernier doit pointer vers le fichier "DELOITTE". 



******************************************************** CHEMINS ***************************************************************/


%let chemin = C:\Users\xteii\Documents\MORGANE\Finance\DELOITTE;
%let che_macro_eco = &chemin.\01. Programmes\02. Modéles\01. Modéle econo\Macro;

libname tab_in "&chemin.\04. Inputs\03. Modèles\01. Modèle économétrique";
libname tab_out "&chemin.\05. Outputs\02. Modèle économétrique";


DATA VARS;
	SET tab_in.DATASET;
RUN;




********************************************************************************************************************************
										PARTIE 1 - Tests de stationnarité
********************************************************************************************************************************;

/*Test de stationnarite des variables*/
%include "&che_macro_eco.\Stationnarité.sas";


/*Une etoile dans la dernière colonne veut dire que tous les 3 tests concluent à la stationnarite,
pas d'etoile si au moins un test rejette la stationnarite*/
%STATIONNARITE(DATA=VARS, VARS=CPI IRLT GDP RRES DR);



********************************************************************************************************************************
										PARTIE 2 - Transformation des variables
********************************************************************************************************************************;
%include "&che_macro_eco.\Initialisation_base.sas";

/*4 retards sur DR, les differences premieres de DR, des variables d'interets et leurs 5 retards*/
%DIFLAGN(DATAOR=VARS, DATAF=VARS, VARS=dr, n=5);
%DIFLAGN(DATAOR=VARS, DATAF=VARS, VARS=cpi, n=5);
%DIFLAGN(DATAOR=VARS, DATAF=VARS, VARS=irlt, n=5);
%DIFLAGN(DATAOR=VARS, DATAF=VARS, VARS=gdp, n=5);
%DIFLAGN(DATAOR=VARS, DATAF=VARS, VARS=rres, n=5);


********************************************************************************************************************************
										PARTIE 3 - Analyse exploratoire
********************************************************************************************************************************;
%include "&che_macro_eco.\graphiques.sas";


%GRAPH(VAR=CPI);
%GRAPH(VAR=GDP);
%GRAPH(VAR=RRES);

PROC SGPLOT DATA=VARS;
	title "Evolution du taux de defaut et de IRLT en fonction de la date";
	series x=date y=DR;
	series x=date y=IRLT;
RUN;

title;


/*DDR en fonction des lags des series differenciees*/
%GRAPHIQUES(VAR=DRRES);
%GRAPHIQUES(VAR=DCPI);
%GRAPHIQUES(VAR=DDR);
%GRAPHIQUES(VAR=DIRLT);
%GRAPHIQUES(VAR=DGDP);


********************************************************************************************************************************
										PARTIE 4 - Sélection des variables
********************************************************************************************************************************;

PROC contents DATA=VARS noprint out=list_vars
               (keep=name);
RUN;

PROC SQL NOPRINT;
	SELECT name INTO : XVARS SEPARATED BY ' ' FROM list_vars WHERE name NOT 
		IN("cpi", "IRLT", "gdp", "rres", "dr", "Date", "obs", 
		/*On enlève les variables brutes*/
					"dcpi", "dgdp", "drres", "ddr", 
		/* On enlève les predicteurs, on ne garde que les lags*/
					"l1dcpi", "l2dcpi", "l3dcpi", "l4dcpi", "l5dcpi", "DR");
		/*Le prix n'est pas un bon predicteur (voir macro graphique)*/
QUIT;

PROC GLMSELECT DATA=VARS plots=all;
	MODEL DR=&XVARS. / selection=stepwise(select=SL choose=press);
RUN;

********************************************************************************************************************************
										PARTIE 5 - Modélisation
********************************************************************************************************************************;

%include "&che_macro_eco.\modélisation.sas";

%MODELISATION(base=VARS, end_range_solve=40, name_out=res1);
%INTERVAL_CONFIDENCE(base= VARS, name_out=res1, bounds= bounds_econo, end_range_solve=40);




********************************************************************************************************************************
										PARTIE 6 - Mise en oeuvre des stress
********************************************************************************************************************************;

PROC SQL;
	CREATE TABLE stressed_prep as select date, gdp, irlt, DR from VARS where 
		date < "31dec2017"d;
QUIT;


****************  BASELINE  **********************;

%mise_en_forme(baseline);
%modelisation(base = baseline_N, end_range_solve=44, name_out= proj_baseline);
%INTERVAL_CONFIDENCE(base= baseline_N, name_out=proj_baseline_IC, bounds= proj_baseline_IC_bounds, end_range_solve=44);
%mise_en_forme_base_finale(scenario=baseline);

PROC EXPORT DATA=proj_baseline
		    DBMS=csv 
		    OUTFILE= "&chemin.\05. Outputs\02. Modèle économétrique\proj_baseline.csv"  
		    REPLACE;
 		    DELIMITER=";";
run;

data tab_out.proj_baseline; set proj_baseline ; run;
data tab_out.proj_baseline_concat_IC; set proj_baseline_concat_IC ; run;

PROC EXPORT DATA=proj_baseline_concat_IC
		    DBMS=csv 
		    OUTFILE="&chemin.\05. Outputs\02. Modèle économétrique\proj_baseline_concat_IC.csv" 
		    REPLACE;
 		    DELIMITER=";";
run;

****************  ADVERSE  **********************;

%mise_en_forme(adverse);
%modelisation(base = adverse_N, end_range_solve=44, name_out= proj_adverse);
%INTERVAL_CONFIDENCE(base= adverse_N, name_out=proj_adverse_IC, bounds= proj_adverse_IC_bounds, end_range_solve=44);
%mise_en_forme_base_finale(scenario=adverse);


 PROC EXPORT DATA=proj_adverse
		    DBMS=csv 
		    OUTFILE="&chemin.\05. Outputs\02. Modèle économétrique\proj_adverse.xlsx" 
		    REPLACE;
 		    DELIMITER=";";
run;

data tab_out.proj_adverse; set proj_adverse ; run;
data tab_out.proj_adverse_concat_IC; set proj_adverse_concat_IC ; run;

PROC EXPORT DATA=proj_adverse_concat_IC
		    DBMS=csv 
		    OUTFILE="&chemin.\05. Outputs\02. Modèle économétrique\proj_adverse_concat_IC.csv" 
		    REPLACE;
 		    DELIMITER=";";
run;


****************  CENTRAL  **********************;

%mise_en_forme(central);
%modelisation(base = central_N, end_range_solve=44, name_out= proj_central);
%INTERVAL_CONFIDENCE(base= central_N, name_out=proj_central_IC, bounds= proj_central_IC_bounds, end_range_solve=44);
%mise_en_forme_base_finale(scenario=central);


PROC EXPORT DATA=proj_central
		    DBMS=csv 
		    OUTFILE= "&chemin.\05. Outputs\02. Modèle économétrique\proj_central.xlsx" 
		    REPLACE;
 		    DELIMITER=";";
run;
data tab_out.proj_central; set proj_central ; run;
data tab_out.proj_central_concat_IC; set proj_central_concat_IC ; run;

PROC EXPORT DATA=proj_central_concat_IC
		    DBMS=csv 
		    OUTFILE="&chemin.\05. Outputs\02. Modèle économétrique\proj_central_concat_IC.csv" 
		    REPLACE;
 		    DELIMITER=";";
run;


******************************************************************************************
BASELINE SCENARIO AND ADVERSE SCENARIO 

Italy GDP 
 Baseline Growth (%)----------------------------------------
 2018 1.4
 2019 1.3 
 2020 1.3 

 Growth rate deviation (percentage points)------------------
 2018 -2.0 
 2019 -2.8 
 2020 -1.9 

 Adverse Growth (%)-----------------------------------------
 2018 -0.6 
 2019 -1.5 
 2020 -0.6 

 Adverse cumulative Growth (%)------------------------------
 -2.7 

 Level deviation (%)----------------------------------------
 -6.5

Italy IRLT
 Starting point rate 2017
 2.1

 Baseline rates (%)----------------------------------------
 2018 2.1 
 2019 2.5 
 2020 2.8

 Deviation from baseline (basis points)------------------
 2018 121 
 2019 124 
 2020 117 

 Adverse rates (%)-----------------------------------------
 2018 3.3 
 2019 3.7 
 2020 4.0
	

******************************************************************************************;
