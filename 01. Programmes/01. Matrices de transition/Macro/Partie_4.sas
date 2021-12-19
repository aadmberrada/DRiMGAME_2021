/*matrice TTC cumulée*/
%macro cumulate_TTC_matrix();

	/*Mise au format matrice de la matrice TTC*/
	PROC TRANSPOSE DATA = Table_for_TTC_matrix_sum OUT = Table_for_TTC_matrix_transp (drop = _NAME_) PREFIX = key2_ ;
	  BY key1 ;
	  VAR TTC_matrix ;
	  ID key2;
	RUN ;

	/*Au cas ou certaines migrations n'existeraient pas (exemple : migration de la classe 10 vers la classe 1*/
	proc stdize data = work.Table_for_TTC_matrix_transp 
		out= work.Table_for_TTC_matrix_transp_NM
		reponly missing=0;
	run;

	/*On boucle sur les colonnes pour avois les sommes cumulées de chaque ligne et on drop la matrice TTC initiale*/
	/*Notons qu'en raison des arrondis deux case de la première colonne ne sont pas exactement à 100% --> c'est un détail*/
	data Table_for_TTC_matrix_cumulate (drop= key2_1-key2_11); set Table_for_TTC_matrix_transp_NM;
		%DO j = 1 %to 11;
			cumulate_&j. = sum(of key2_&j. - key2_11);
		%end;
	run;

	data mat_out.Table_for_TTC_matrix_cumulate;  SET Table_for_TTC_matrix_cumulate; run;
%mend;
