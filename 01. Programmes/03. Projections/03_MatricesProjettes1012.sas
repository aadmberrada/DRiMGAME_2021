***************************************************************************************************

										DRIM GAME 2021
										LES PROJECTIONS

DATE DE VERSION DU CODE : 11/12/2021

MODIFICATION DU 10/12/2021 : Morgane CAILLOSSE
MODIFICATION DU 11/12/2021 : Morgane CAILLOSSE

PLAN DU CODE : -----------------------------------------------------------------------------------

PARTIE 1 :
	Calcul du rho à partir de la série historique de taux de défaut

PARTIE 2 : 
	Calcul des Zt pour chaque scénario à partir des séries de taux de défaut projetés

PARTIE 3 : 
	Projection des matrices d'après la méthode de Merton Vasicek

Partie 4 :
	Déduction des PIT non cumulées à partir des PIT cumulées



STRUCTURE DES LIBRAIRIES : -----------------------------------------------------------------------

La library "inputs" doit contenir : 
	- La série historique de taux de défaut sous le nom DR_hist (correspondant à la base WE12)
	- La matrice TTC cumulés obtenues précedemment 
	- Les DR projetés pour les 3 scénarios

***************************************************************************************************;

/*Modifier uniquement ce chemin pour lancer les codes sur votre ordinateurs*/
%let chemin = C:\Users\xteii\Documents\MORGANE\Finance\DELOITTE;

libname inputs "&chemin.\04. Inputs\03. Projections";
libname output "&chemin.\05. Outputs\03. Projections";

****************************************************************************************************
			PARTIE 1 :
				Calcul du rho à partir de la série historique de taux de défaut
****************************************************************************************************;

/*Selection des taux de défaut connus au moment des projections*/
Proc sql ; 
	create table DR_hist_2017 
	as select dtf_per_trt as date, 
			WE12 as DR
	from inputs.DR_histo
	where dtf_per_trt < "31JAN2018"d;
quit;

Proc IML ;
	use DR_hist_2017; 
	read all into DR_hist_2017; 
	print DR_hist_2017;
	close;
	
	do i = 1 to 96 ;
		q = DR_hist_2017[i,2];
		invnorm = quantile("Normal", q);
		vect = vect // invnorm;
	end;

	unbiased_variance = var(vect);

	rho = (unbiased_variance/(1+unbiased_variance));


****************************************************************************************************
			PARTIE 2 :
				Calcul des Zt à partir de la série de taux de défaut projetés
****************************************************************************************************;

	/*Module pour calculer les Zt*/
	start calcul_Zt(DR_proj, annee, rho, DR_hist_2017, col);
		if annee = 2018 then select = 28:31 ;
		if annee = 2019 then select = 32:35 ;
		if annee = 2020 then select = 36:39 ;
		
		/*Serie des DR_historique predit*/
		historique = DR_hist_2017[1:96,2] ;
		m_hist = mean(historique) ;
		m_hist_invnorm = quantile("Normal", m_hist);

		/*Serie des DR_projetés (attention la serie projetée est en poucentage) */
		proj = DR_proj[select, col] ;
		m_proj = mean(proj)/100 ;
		m_proj_invnorm = quantile("Normal", m_proj);

		root_rho = SQRT(rho) ;
		root_un_moins_rho = SQRT(1 - rho) ;

		numerateur = m_hist_invnorm - root_un_moins_rho * m_proj_invnorm ;
		denominateur = root_rho ;

		Zt = numerateur/denominateur ;
		
		return Zt ;
	finish calcul_Zt ;

	
****************************************************************************************************
			PARTIE 3 :
				Projection des matrices à l'aide de la méthode de Merton Vasiceck
****************************************************************************************************;

	use inputs.table_for_ttc_matrix_cumulate;
	read all into TTC_matrix_cumul; 
	print TTC_matrix_cumul;
	close;

	/*Division par 100 car la TTC_cumulée est en pourcentage*/
	TTC_cumul = TTC_matrix_cumul[1:10,2:12]/100;

	start TTC_TO_PIT(Matrix_cumul, Zt, rho);
			quant = quantile("Normal", Matrix_cumul[1:10, 2:11]);
			first = (1/SQRT(1-rho)) ;
			second = (quant-SQRT(rho)*Zt) ;
			PIT = Matrix_cumul[1:10,1]||cdf("Normal", first*second) ;
		return PIT ;
	finish TTC_TO_PIT ;
	
****************************************************************************************************
		PARTIE 4 :
			Déduction des PIT non cumulées à partir des PIT cumulées 
****************************************************************************************************;
	Start CUMUL_TO_NONCUMUL(Matrix_PIT_cumul);
		do i = 1 to 10 ;
			j = i + 1 ;
			new = Matrix_PIT_cumul[,i]-Matrix_PIT_cumul[,j] ;
			matrice_non_cumul = matrice_non_cumul||new ;
		end;
		proj = matrice_non_cumul||Matrix_PIT_cumul[,11] ;
		return proj ;
	finish CUMUL_TO_NONCUMUL ;
		

****************************************************************************************************
		LANCEMENT DES TRAITEMENTS A PARTIR DES MODULES
****************************************************************************************************;

	/*Baseline*/
	use inputs.proj_baseline;
	read all into proj_baseline; 
	print proj_baseline;
	close;

	Zt_2018_baseline = calcul_Zt(proj_baseline, 2018 , rho, DR_hist_2017, 4) ;
	Zt_2019_baseline = calcul_Zt(proj_baseline, 2019 , rho, DR_hist_2017, 4) ;
	Zt_2020_baseline = calcul_Zt(proj_baseline, 2020 , rho, DR_hist_2017, 4) ;

	PIT_2018_baseline = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2018_baseline, rho));
	PIT_2019_baseline = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2019_baseline, rho));
	PIT_2020_baseline = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2020_baseline, rho));

	create PIT_2018_baseline from PIT_2018_baseline[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2018_baseline;
	close PIT_2018_baseline;

	create PIT_2019_baseline from PIT_2019_baseline[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2019_baseline;
	close PIT_2019_baseline;

	create PIT_2020_baseline from PIT_2020_baseline[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2020_baseline;
	close PIT_2020_baseline;


	/*Central*/
	use inputs.proj_central; 
	read all into proj_central; 
	print proj_central;
	close;

	Zt_2018_central = calcul_Zt(proj_central, 2018 , rho, DR_hist_2017, 4) ;
	Zt_2019_central = calcul_Zt(proj_central, 2019 , rho, DR_hist_2017, 4) ;
	Zt_2020_central = calcul_Zt(proj_central, 2020 , rho, DR_hist_2017, 4) ;

	PIT_2018_central =  CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2018_central, rho));
	PIT_2019_central =  CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2019_central, rho));
	PIT_2020_central =  CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2020_central, rho));


	create PIT_2018_central from PIT_2018_central[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2018_central;
	close PIT_2018_central;

	create PIT_2019_central from PIT_2019_central[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2019_central;
	close PIT_2019_central;

	create PIT_2020_central from PIT_2020_central[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2020_central;
	close PIT_2020_central;


	/*Adverse*/
	use inputs.proj_adverse; 
	read all into proj_adverse; 
	print proj_adverse;
	close;

	Zt_2018_adverse = calcul_Zt(proj_adverse, 2018 , rho, DR_hist_2017, 4) ;
	Zt_2019_adverse = calcul_Zt(proj_adverse, 2019 , rho, DR_hist_2017, 4) ;
	Zt_2020_adverse = calcul_Zt(proj_adverse, 2020 , rho, DR_hist_2017, 4) ;

	PIT_2018_adverse =  CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2018_adverse, rho));
	PIT_2019_adverse =  CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2019_adverse, rho));
	PIT_2020_adverse =  CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2020_adverse, rho));

	create PIT_2018_adverse from PIT_2018_adverse[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2018_adverse;
	close PIT_2018_adverse;

	create PIT_2019_adverse from PIT_2019_adverse[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2019_adverse;
	close PIT_2019_adverse;

	create PIT_2020_adverse from PIT_2020_adverse[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2020_adverse;
	close PIT_2020_adverse;

	/*Interval de confiance*/
	/*BASELINE*/
	/*BORNE INF*/
	use inputs.proj_baseline_concat_ic; 
	read all into proj_baseline_concat_ic; 
	print proj_baseline_concat_ic;
	close;

	Zt_2018_baseline_inf = calcul_Zt(proj_baseline_concat_ic, 2018 , rho, DR_hist_2017, 4) ;
	Zt_2019_baseline_inf = calcul_Zt(proj_baseline_concat_ic, 2019 , rho, DR_hist_2017, 4) ;
	Zt_2020_baseline_inf = calcul_Zt(proj_baseline_concat_ic, 2020 , rho, DR_hist_2017, 4) ;

	PIT_2018_baseline_inf = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2018_baseline_inf, rho));
	PIT_2019_baseline_inf = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2019_baseline_inf, rho));
	PIT_2020_baseline_inf = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2020_baseline_inf, rho));

	create PIT_2018_baseline_inf from PIT_2018_baseline_inf[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2018_baseline_inf;
	close PIT_2018_baseline_inf;

	create PIT_2019_baseline_inf from PIT_2019_baseline_inf[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2019_baseline_inf;
	close PIT_2019_baseline_inf;

	create PIT_2020_baseline_inf from PIT_2020_baseline_inf[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2020_baseline_inf;
	close PIT_2020_baseline_inf;

	/*BASELINE*/
	/*BORNE SUP*/

	Zt_2018_baseline_sup = calcul_Zt(proj_baseline_concat_ic, 2018 , rho, DR_hist_2017, 3) ;
	Zt_2019_baseline_sup = calcul_Zt(proj_baseline_concat_ic, 2019 , rho, DR_hist_2017, 3) ;
	Zt_2020_baseline_sup = calcul_Zt(proj_baseline_concat_ic, 2020 , rho, DR_hist_2017, 3) ;

	PIT_2018_baseline_sup = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2018_baseline_sup, rho));
	PIT_2019_baseline_sup = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2019_baseline_sup, rho));
	PIT_2020_baseline_sup = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2020_baseline_sup, rho));

	create PIT_2018_baseline_sup from PIT_2018_baseline_sup[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2018_baseline_sup;
	close PIT_2018_baseline_sup;

	create PIT_2019_baseline_sup from PIT_2019_baseline_sup[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2019_baseline_sup;
	close PIT_2019_baseline_sup;

	create PIT_2020_baseline_sup from PIT_2020_baseline_sup[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2020_baseline_sup;
	close PIT_2020_baseline_sup;

	/*Interval de confiance*/
	/*BASELINE*/
	/*BORNE INF*/
	use inputs.proj_baseline_concat_ic; 
	read all into proj_baseline_concat_ic; 
	print proj_baseline_concat_ic;
	close;

	Zt_2018_baseline_inf = calcul_Zt(proj_baseline_concat_ic, 2018 , rho, DR_hist_2017, 4) ;
	Zt_2019_baseline_inf = calcul_Zt(proj_baseline_concat_ic, 2019 , rho, DR_hist_2017, 4) ;
	Zt_2020_baseline_inf = calcul_Zt(proj_baseline_concat_ic, 2020 , rho, DR_hist_2017, 4) ;

	PIT_2018_baseline_inf = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2018_baseline_inf, rho));
	PIT_2019_baseline_inf = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2019_baseline_inf, rho));
	PIT_2020_baseline_inf = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2020_baseline_inf, rho));

	create PIT_2018_baseline_inf from PIT_2018_baseline_inf[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2018_baseline_inf;
	close PIT_2018_baseline_inf;

	create PIT_2019_baseline_inf from PIT_2019_baseline_inf[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2019_baseline_inf;
	close PIT_2019_baseline_inf;

	create PIT_2020_baseline_inf from PIT_2020_baseline_inf[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2020_baseline_inf;
	close PIT_2020_baseline_inf;

	/*ADVERSE*/
	/*BORNE SUP*/
	use inputs.proj_adverse_concat_ic; 
	read all into proj_adverse_concat_ic; 
	print proj_adverse_concat_ic;
	close;

	Zt_2018_adverse_sup = calcul_Zt(proj_adverse_concat_ic, 2018 , rho, DR_hist_2017, 3) ;
	Zt_2019_adverse_sup = calcul_Zt(proj_adverse_concat_ic, 2019 , rho, DR_hist_2017, 3) ;
	Zt_2020_adverse_sup = calcul_Zt(proj_adverse_concat_ic, 2020 , rho, DR_hist_2017, 3) ;

	PIT_2018_adverse_sup = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2018_adverse_sup, rho));
	PIT_2019_adverse_sup = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2019_adverse_sup, rho));
	PIT_2020_adverse_sup = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2020_adverse_sup, rho));

	create PIT_2018_adverse_sup from PIT_2018_adverse_sup[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2018_adverse_sup;
	close PIT_2018_adverse_sup;

	create PIT_2019_adverse_sup from PIT_2019_adverse_sup[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2019_adverse_sup;
	close PIT_2019_adverse_sup;

	create PIT_2020_adverse_sup from PIT_2020_adverse_sup[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2020_adverse_sup;
	close PIT_2020_adverse_sup;

	/*BORNE INF*/
	Zt_2018_adverse_inf = calcul_Zt(proj_adverse_concat_ic, 2018 , rho, DR_hist_2017, 4) ;
	Zt_2019_adverse_inf = calcul_Zt(proj_adverse_concat_ic, 2019 , rho, DR_hist_2017, 4) ;
	Zt_2020_adverse_inf = calcul_Zt(proj_adverse_concat_ic, 2020 , rho, DR_hist_2017, 4) ;

	PIT_2018_adverse_inf = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2018_adverse_inf, rho));
	PIT_2019_adverse_inf = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2019_adverse_inf, rho));
	PIT_2020_adverse_inf = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2020_adverse_inf, rho));

	create PIT_2018_adverse_inf from PIT_2018_adverse_inf[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2018_adverse_inf;
	close PIT_2018_adverse_inf;

	create PIT_2019_adverse_inf from PIT_2019_adverse_inf[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2019_adverse_inf;
	close PIT_2019_adverse_inf;

	create PIT_2020_adverse_inf from PIT_2020_adverse_inf[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2020_adverse_inf;
	close PIT_2020_adverse_inf;


	/*CENTRAL*/
	/*BORNE SUP*/
	use inputs.proj_central_concat_ic; 
	read all into proj_central_concat_ic; 
	print proj_central_concat_ic;
	close;

	Zt_2018_central_sup = calcul_Zt(proj_central_concat_ic, 2018 , rho, DR_hist_2017, 3) ;
	Zt_2019_central_sup = calcul_Zt(proj_central_concat_ic, 2019 , rho, DR_hist_2017, 3) ;
	Zt_2020_central_sup = calcul_Zt(proj_central_concat_ic, 2020 , rho, DR_hist_2017, 3) ;

	PIT_2018_central_sup = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2018_central_sup, rho));
	PIT_2019_central_sup = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2019_central_sup, rho));
	PIT_2020_central_sup = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2020_central_sup, rho));

	create PIT_2018_central_sup from PIT_2018_central_sup[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2018_central_sup;
	close PIT_2018_central_sup;

	create PIT_2019_central_sup from PIT_2019_central_sup[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2019_central_sup;
	close PIT_2019_central_sup;

	create PIT_2020_central_sup from PIT_2020_central_sup[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2020_central_sup;
	close PIT_2020_central_sup;

	/*BORNE INF*/
	Zt_2018_central_inf = calcul_Zt(proj_central_concat_ic, 2018 , rho, DR_hist_2017, 3) ;
	Zt_2019_central_inf = calcul_Zt(proj_central_concat_ic, 2019 , rho, DR_hist_2017, 3) ;
	Zt_2020_central_inf = calcul_Zt(proj_central_concat_ic, 2020 , rho, DR_hist_2017, 3) ;

	PIT_2018_central_inf = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2018_central_inf, rho));
	PIT_2019_central_inf = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2019_central_inf, rho));
	PIT_2020_central_inf = CUMUL_TO_NONCUMUL(TTC_TO_PIT(TTC_cumul, Zt_2020_central_inf, rho));

	create PIT_2018_central_inf from PIT_2018_central_inf[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2018_central_inf;
	close PIT_2018_central_inf;

	create PIT_2019_central_inf from PIT_2019_central_inf[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2019_central_inf;
	close PIT_2019_central_inf;

	create PIT_2020_central_inf from PIT_2020_central_inf[colname={"1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "Defaut"}];
	append from PIT_2020_central_inf;
	close PIT_2020_central_inf;

QUIT;


data output.PIT_2018_baseline; set PIT_2018_baseline ; run ;
data output.PIT_2019_baseline; set PIT_2019_baseline ; run ;
data output.PIT_2020_baseline; set PIT_2020_baseline ; run ;

data output.PIT_2018_central; set PIT_2018_central ; run ;
data output.PIT_2019_central; set PIT_2019_central ; run ;
data output.PIT_2020_central; set PIT_2020_central ; run ;

data output.PIT_2018_adverse; set PIT_2018_adverse ; run ;
data output.PIT_2019_adverse; set PIT_2019_adverse ; run ;
data output.PIT_2020_adverse; set PIT_2020_adverse ; run ;

%macro exportation(scenario=, annee=);

	data output.PIT_&annee._&scenario._inf; set PIT_&annee._&scenario._inf ; run ;
	data output.PIT_&annee._&scenario._sup; set PIT_&annee._&scenario._sup ; run ;
	
	PROC EXPORT DATA=PIT_&annee._&scenario._inf
			    DBMS=csv 
			    OUTFILE="&chemin.\05. Outputs\03. Projections\PIT_&annee._&scenario._inf.csv" 
			    REPLACE;
	 		    DELIMITER=";";
	run;

	PROC EXPORT DATA=PIT_&annee._&scenario._sup
			    DBMS=csv 
			    OUTFILE="&chemin.\05. Outputs\03. Projections\PIT_&annee._&scenario._sup.csv" 
			    REPLACE;
	 		    DELIMITER=";";
	run;
%mend;

%exportation(scenario=baseline, annee=2018);
%exportation(scenario=baseline, annee=2019);
%exportation(scenario=baseline, annee=2020);

%exportation(scenario=central, annee=2018);
%exportation(scenario=central, annee=2019);
%exportation(scenario=central, annee=2020);

%exportation(scenario=adverse, annee=2018);
%exportation(scenario=adverse, annee=2019);
%exportation(scenario=adverse, annee=2020);
