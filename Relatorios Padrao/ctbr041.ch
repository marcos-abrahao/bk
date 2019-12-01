#ifdef SPANISH
	#define STR0001 "CODIGO DE LA CUENTA"
	#define STR0002 " D  E  S  C  R  I  P  C  I  O  N"
	#define STR0003 "SALDO ANTERIOR"
	#define STR0004 If( cPaisLoc == "MEX", "CARGO", "DEBITO" )
	#define STR0005 If( cPaisLoc == "MEX", "ABONO", "CREDITO" )
	#define STR0006 "SALDO ACTUAL"
	#define STR0007 " A  "
	#define STR0008 " EN "
	#define STR0009 "BALANCE DE VERIFICACION SINTETICO DE "
	#define STR0010 "Balance de Verificacion"
	#define STR0011 "T O T A L E S  D E L  P E R I O D O : "
	#define STR0012 "BALANCE DE VERIFICACION ANALITICO DE "
	#define STR0013 "BALANCE DE VERIFICACION DE "
	#define STR0014 "Creando archivo temporal..."
	#define STR0015 "T O T A L E S  D E L  G R U P O ("
	#define STR0016 "Parametros  - "
	#define STR0017 "Generando informe, espere..."
	#define STR0018 "MOV PERIODO"
	#define STR0019 "Por favor rellenar los parametros Grupos Ingresos/Gastos y Fecha Sld Ant. Ingresos/Gastos o "
	#define STR0020 "dejar el parametro Ignora Sl Ant.Cob/Des = No "
#else
	#ifdef ENGLISH
		#define STR0001 "ACCOUNT CODE"
		#define STR0002 " D  E  S  C  R  I  P  T  I  O  N"
		#define STR0003 "PREVIOUS BALANCE"
		#define STR0004 "DEBIT"
		#define STR0005 "CREDIT"
		#define STR0006 "CURRENCT BALANCE"
		#define STR0007 " TO "
		#define STR0008 " IN "
		#define STR0009 "SUMMARIZED TRIAL BALANCE OF "
		#define STR0010 "Check-Up Trial Balance"
		#define STR0011 "T O T A L S  O F  T H E  P E R I O D : "
		#define STR0012 "DETAILED TRIAL BALANCE OF "
		#define STR0013 "TRIAL BALANCE OF "
		#define STR0014 "Creating Temporary File..."
		#define STR0015 "T O T A L S  O F  T H E  G R O U P ("
		#define STR0016 "Parameters  - "
		#define STR0017 "Generating report. Wait..."
		#define STR0018 "PERIOD MOV. "
		#define STR0019 "Please, fill out the parameters Groups Incomes/Expenses& Date Prv Blnc Incomes/Expenses or "
		#define STR0020 "leave the parameter Ignor Prv.BlnInc/Exp = No  "
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Código Da Conta", "CODIGO DA CONTA" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", " D  E  S  C  R  I  ç  ã  O", " D  E  S  C  R  I  C  A  O" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Saldo Anterior", "SALDO ANTERIOR" )
		#define STR0004 If( cPaisLoc $ "ANG|EQU|HAI", "DÉBITO", If( cPaisLoc == "MEX", "Cartão Débito", If( cPaisLoc == "PTG", "Débito", "DEBITO" ) ) )
		#define STR0005 If( cPaisLoc $ "ANG|EQU|HAI", "CRÉDITO", If( cPaisLoc $ "MEX|PTG", "Crédito", "CREDITO" ) )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Saldo Actual", "SALDO ATUAL" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", " até ", " ATE " )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", " em ", " EM " )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Do balancete de verificação sintético  ", "BALANCETE DE VERIFICACAO SINTETICO DE " )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Balancete De Verificação", "Balancete de Verificacao" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "T o t a i s  d o  p e r í o d o : ", "T O T A I S  D O  P E R I O D O : " )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Do balancete de verificação analítico  ", "BALANCETE DE VERIFICACAO ANALITICO DE " )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Do balancete de verificação  ", "BALANCETE DE VERIFICACAO DE " )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "A Criar Ficheiro Temporário...", "Criando Arquivo Temporario..." )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "T o t a i s  d o  g r u p o (", "T O T A I S  D O  G R U P O (" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Parâmetros  - ", "Parametros  - " )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "A criar relatório, aguarde...", "Gerando relatorio, aguarde..." )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Mov. Período", "MOV. PERIODO" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Favor preencher os parâmetros grupos receitas/despesas e data sld ant. receitas/despesas ou ", "Favor preencher os parametros Grupos Receitas/Despesas e Data Sld Ant. Receitas/Despesas ou " )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Deixar o parâmetro ignora sl ant.rec/des = não ", "deixar o parametro Ignora Sl Ant.Rec/Des = Nao " )
	#endif
#endif
