/*Test de stationnarite des variables*/
%MACRO STATIONNARITE(DATA=, VARS=);
	options nocenter nonumber nodate mprint mlogic symbolgen orientation=landscape 
		ls=150 formchar="|----|+|---+=|-/\<>*";
	%local sig loop;
	%let sig = 0.1;
	%let loop = 1;

	%do %while (%scan(&VARS, &loop) ne %str());
		%let x = %scan(&VARS, &loop);

		PROC SQL noprint;
			select int(12 * ((count(&x) / 100) ** 0.25)) into :nlag1 from &DATA;
			select int(max(1, (count(&x) ** 0.5) / 5)) into :nlag2 from &DATA;
		QUIT;

		ods listing close;
		ods output kpss=_kpss (drop=MODEL lags rename=(prob=probeta)) 
			adf=_adf  (drop=MODEL lags rho probrho fstat probf rename=(tau=adf_tau 
			probtau=adf_probtau)) philperron=_pp  (drop=MODEL lags rho probrho 
			rename=(tau=pp_tau probtau=pp_probtau));

		PROC autoreg DATA=&DATA;
			MODEL &x= / noint stationarity=(adf=&nlag1, phillips=&nlag2, kpss=(kernel=nw 
				lag=&nlag1));
		RUN;

		QUIT;
		ods listing;

		PROC SQL noprint;
			CREATE TABLE _1 as select upcase("&x") as VARS length=32, upcase(_adf.type) 
				as type, _adf.adf_tau, _adf.adf_probtau, _pp.pp_tau, _pp.pp_probtau, 
				_kpss.eta, _kpss.probeta, case when _adf.adf_probtau < &sig and 
				_pp.pp_probtau < &sig and _kpss.probeta > &sig then "*" else " " end as 
				_flg, &loop                  as _i, monotonic() as _j from _adf inner join 
				_pp on _adf.type=_pp.type inner join _kpss on _adf.type=_kpss.type;
		QUIT;

		%if &loop=1 %then
			%do;

				DATA _result;
					SET _1;
				RUN;

			%end;
		%else
			%do;

				PROC append base=_result DATA=_1;
				RUN;

			%end;

		PROC DATASETs library=work nolist;
			delete _1 _adf _pp _kpss / memtype=DATA;
		QUIT;

		%let loop = %eval(&loop + 1);
	%end;

	PROC sort DATA=_result;
		by _i _j;
	RUN;

	PROC report DATA=_result box spacing=1 split="/" nowd;
		column("STATISTICAL TESTS FOR STATIONARITY/ " VARS type adf_tau adf_probtau 
			pp_tau pp_probtau eta probeta _flg);
		define VARS / "VARIABLES/ " width=20 group order order=DATA;
		define type / "TYPE/ " width=15 order order=DATA;
		define adf_tau / "ADF TEST/FOR/UNIT ROOT" width=10 format=8.2;
		define adf_probtau / "P-VALUE/FOR/ADF TEST" width=10 format=8.4 center;
		define pp_tau / "PP TEST/FOR/UNIT ROOT" width=10 format=8.2;
		define pp_probtau / "P-VALUE/FOR/PP TEST" width=10 format=8.4 center;
		define eta / "KPSS TEST/FOR/STATIONNARITE" width=10 format=8.2;
		define probeta / "P-VALUE/FOR/KPSS TEST" width=10 format=8.4 center;
		define _flg / "STATIONNARITE/FLAG" width=10 center;
	RUN;

%MEND STATIONNARITE;
