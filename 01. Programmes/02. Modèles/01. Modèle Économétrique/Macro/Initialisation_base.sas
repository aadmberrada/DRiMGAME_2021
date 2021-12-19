/* base comprenant :
- 4 retards sur DR (car un reatrd viendra dnas la modelisation)
- les differences premieres de DR, des variables d'interets et leurs 5 retards*/
/*Initialisation de la base*/
%MACRO DIFLAGN(DATAOR=, DATAF=, VARS=, n=, target=dr);
	DATA &DATAF.;
		SET &DATAOR.;
		d&VARS.=dif(&VARS.);

		%do i=1 %to &n;
			l&i.d&VARS.=lag&i.(d&VARS.);
		%end;

		%do i=1 %to &n-1;
			l&i.&target.=lag&i.(&target.);
		%end;
	RUN;

%MEND DIFLAGN;
