%macro matrice_TTC;
	%do i=2 %TO 85 ;
		proc sql; 
			CREATE TABLE Table_for_TTC_matrix AS
			SELECT * from Table_for_TTC_matrix as a LEFT JOIN matrix_&i.
			ON a.key1 = matrix_&i..key1 and a.key2 = matrix_&i..key2;
		quit;
	%end;

	proc stdize data = work.Table_for_TTC_matrix 
		out= work.Table_for_TTC_matrix_notmiss 
		reponly missing=0;
	run;

%mend ;
