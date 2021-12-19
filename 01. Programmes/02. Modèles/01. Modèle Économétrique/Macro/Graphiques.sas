%MACRO GRAPH(VAR=);
	PROC SGPLOT DATA=VARS;
		title "Evolution du taux de defaut et de &VAR. en fonction de la date";
		series x=date y=DR;
		series x=date y=&VAR. / Y2Axis;
	RUN;

	title;
%MEND GRAPH;


%MACRO GRAPHIQUES(VAR=);
	%let v = %SUBSTR(&VAR., 2, 4 );

	PROC template;
		define statgraph GRAPH;
			dynamic _L1&VAR. _DDR _L2&VAR. _DDR2 _L3&VAR. _DDR3 _L4&VAR. _DDR4 
				_L5&VAR. _DDR5;
			begingraph / designwidth=1206 designheight=660;
			entrytitle halign=center "DDR* en fonction des lags de la variable &VAR.*";
			entryfootnote halign=left "DDR = dif(DR); &VAR. = dif(&v.)";
			layout lattice / rowDATArange=DATA columnDATArange=DATA rows=2 columns=3 
				rowgutter=10 columngutter=10 rowweights=(1.0 1.0) columnweights=(1.0 1.0 
				1.0);
			layout overlay;
			MODELband 'CLM' / name='MODELband';
			MODELband 'CLI' / name='MODELband2' display=(outline);
			scatterplot x=_L1&VAR. y=_DDR / name='scatter';
			regressionplot x=_L1&VAR. y=_DDR / name='regression' clm='CLM' cli='CLI';
			endlayout;
			layout overlay;
			MODELband 'CLM2' / name='MODELband3';
			MODELband 'CLI2' / name='MODELband4' display=(outline);
			scatterplot x=_L2&VAR. y=_DDR2 / name='scatter2';
			regressionplot x=_L2&VAR. y=_DDR2 / name='regression2' clm='CLM2' cli='CLI2';
			endlayout;
			layout overlay;
			MODELband 'CLM3' / name='MODELband5';
			MODELband 'CLI3' / name='MODELband6' display=(outline);
			scatterplot x=_L3&VAR. y=_DDR3 / name='scatter3';
			regressionplot x=_L3&VAR. y=_DDR3 / name='regression3' clm='CLM3' cli='CLI3';
			endlayout;
			layout overlay;
			MODELband 'CLM4' / name='MODELband7';
			MODELband 'CLI4' / name='MODELband8' display=(outline);
			scatterplot x=_L4&VAR. y=_DDR4 / name='scatter4';
			regressionplot x=_L4&VAR. y=_DDR4 / name='regression4' clm='CLM4' cli='CLI4';
			endlayout;
			layout overlay;
			MODELband 'CLM5' / name='MODELband9';
			MODELband 'CLI5' / name='MODELband10' display=(outline);
			scatterplot x=_L5&VAR. y=_DDR5 / name='scatter5';
			regressionplot x=_L5&VAR. y=_DDR5 / name='regression5' clm='CLM5' cli='CLI5';
			endlayout;
			layout overlay;
			entry _id='dropsite6' halign=center '(drop a PLOT here...)' / valign=center;
			endlayout;
			endlayout;
			endgraph;
		end;
	RUN;

	PROC sgrender DATA=WORK.VARS template=GRAPH;
		dynamic _L1&VAR.="L1&VAR." _DDR="DDR" _L2&VAR.="L2&VAR." _DDR2="DDR" 
			_L3&VAR.="L3&VAR." _DDR3="DDR" _L4&VAR.="L4&VAR." _DDR4="DDR" 
			_L5&VAR.="L5&VAR." _DDR5="DDR";
	RUN;

%MEND GRAPHIQUES;
