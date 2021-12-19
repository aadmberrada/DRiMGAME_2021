%MACRO mise_en_forme(type_stress);
	PROC IMPORT OUT= &type_stress. 
	            DATAFILE= "&chemin.\04. Inputs\03. Modèles\01. Modèle économétrique\scenarios_stress_tests.xlsx" 
	            DBMS=EXCEL REPLACE;
	     SHEET="&type_stress._base"; 
	     GETNAMES=YES;
	     MIXED=YES;
	     SCANTEXT=YES;
	     USEDATE=YES;
	     SCANTIME=YES;
	 RUN;

	 data &type_stress._N; set &type_stress.; obs = _N_; run;
%MEND;


%MACRO MODELISATION(base=, end_range_solve=, name_out=);
	/*Modèle*/
	PROC MODEL DATA=&base.;
		date=date;
		DR=beta*lag(DR)+ intercept + coeff_dr*lag3(dif(DR)) 
			+ coeff_gdp*lag4(dif(GDP))+coeff_irlt*lag2(dif(IRLT));
		FIT DR /PRL=BOTH;
		range obs=1 to 32;
		solve DR / dynamic Theil out=&name_out.;
		range obs=1 to &end_range_solve.;
		RUN;

		/*Graphique des DRhat et DR*/
	DATA &name_out._2;
		SET &name_out.;
		keep date DR;
		rename DR=DRhat;
	RUN;

	DATA finall_&name_out.;
		merge &base. (keep=date dr) &name_out._2;
		by date;
	RUN;

	symbol i=join v=+;

	PROC GPLOT DATA=finall_&name_out.;
		PLOT (DR DRhat)*date / overlay legend;
		RUN;
	QUIT;

%MEND;


%MACRO INTERVAL_CONFIDENCE(base=, name_out=, bounds=,end_range_solve= );
	proc model data = &base.;
		DR= intercept + beta*lag(DR)+ coeff_dr*lag3(dif(DR)) + coeff_gdp*lag4(dif(GDP))+ coeff_irlt*lag2(dif(IRLT));
		/* Fit the EXCHANGE data */
		fit DR / sur outest=xch_est outcov outs=s;
		range obs=1 to 32;
		/* Solve using the WHATIF data set */
		solve DR / dynamic estdata=xch_est
		random=100 seed=123 out=&name_out.;
		range obs=32 to &end_range_solve.;
	run;

	proc sort data=&name_out.;
		by obs;
	run;

	proc univariate data=&name_out. noprint;
		by obs;
		var DR;
		output out=&bounds. mean=mean P5=P5 P95=P95;
	run;

	proc sgplot data=&bounds. noautolegend;
		series x=obs y=mean / markers;
		series x=obs y=P5 / markers;
		series x=obs y=P95 / markers;
	run;

%MEND;

%macro mise_en_forme_base_finale(scenario= );
	proc sql; 
		create table proj_&scenario._concat_IC as select a.obs, a.date, a.DR, b.P95, b.P5 from proj_&scenario. as a
		left join proj_&scenario._IC_bounds as b on a.obs=b.obs;
	quit;
%mend;
