#ifdef SPANISH
	#define STR0001 "Este programa imprime el plan de cuentas."
	#define STR0002 "Se impimira según los parametro solicitados por"
	#define STR0003 "el usuario."
	#define STR0004 "Cuenta"
	#define STR0005 "Descripc."
	#define STR0006 "A Rayas"
	#define STR0007 "Administracion"
	#define STR0008 "Lista del plan de cuentas"
	#define STR0009 "CUENTA"
	#define STR0010 "***** ANULADO POR EL OPERADOR *****"
	#define STR0011 "Seleccionando registros..."
	#define STR0012 "Bloqueada"
	#define STR0013 "No Bloqueada"
	#define STR0014 "Sintetica"
	#define STR0015 "Analitica"
	#define STR0016 "Deudora"
	#define STR0017 "Acreedora"
	#define STR0018 "CL/CON"
	#define STR0019 "DC"
	#define STR0020 "COD.RES."
	#define STR0021 "D E N O M I N A C .   "
	#define STR0022 "CLASE"
	#define STR0023 "C.NORMAL"
	#define STR0024 "CTA SUPERIOR"
	#define STR0025 "BLOQ"
	#define STR0026 "Microsiga Software S/A"
	#define STR0027 "Hora Termino: "
	#define STR0028 "Cta. contable"
#else
	#ifdef ENGLISH
		#define STR0001 "This program will print the Chart of Accounts."
		#define STR0002 "It will be printed according to the parameters"
		#define STR0003 "selected by the users."
		#define STR0004 "Account"
		#define STR0005 "Description"
		#define STR0006 "Z.Form"
		#define STR0007 "Management"
		#define STR0008 "Chart of Accounts Report"
		#define STR0009 "ACCT."
		#define STR0010 "***** CANCELLED BY THE OPERATOR *****"
		#define STR0011 "Selecting Records..."
		#define STR0012 "Blocked"
		#define STR0013 "Not Blocked"
		#define STR0014 "Summarized"
		#define STR0015 "Detailed"
		#define STR0016 "Debtor"
		#define STR0017 "Creditor"
		#define STR0018 "CL/CON"
		#define STR0019 "DC"
		#define STR0020 "RES.COD."
		#define STR0021 "N O M I N A T E      "
		#define STR0022 "CATEG."
		#define STR0023 "NORMAL C."
		#define STR0024 "SUPERIOR ACT"
		#define STR0025 "LOCK"
		#define STR0026 "Microsiga Software S/A"
		#define STR0027 "End time: "
		#define STR0028 "Ledger Acct.  "
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Este Programa Irá Imprimir O Plano De Contas.", "Este programa irá imprimir o Plano de Contas." )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Sera impresso de acordo com os parâmetro s solicitados pelo", "Será impresso de acordo com os parâmetros solicitados pelo" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Utilizador.", "usuário." )
		#define STR0004 "Conta"
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Descrição", "Descriçäo" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Código de barras", "Zebrado" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Administração", "Administracao" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Listagem Do Plano De Contas", "Listagem do Plano de Contas" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Conta", "CONTA" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "***** cancelado pelo operador *****", "***** CANCELADO PELO OPERADOR *****" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "A Seleccionar Registos...", "Selecionando Registros..." )
		#define STR0012 "Bloqueada"
		#define STR0013 "Nao Bloqueada"
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Sintética", "Sintetica" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Analítica", "Analitica" )
		#define STR0016 "Devedora"
		#define STR0017 "Credora"
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Cl/con", "CL/CON" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Dc", "DC" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Cód.res.", "COD.RES." )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "D E N O M I N A ç ã O", "D E N O M I N A C A O" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Classe", "CLASSE" )
		#define STR0023 "C.NORMAL"
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Conta Superior", "CTA SUPERIOR" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Bloq", "BLOQ" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Microsiga Software S/a", "Microsiga Software S/A" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Hora termino: ", "Hora Termino: " )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Conta contabilística", "Conta contábil" )
	#endif
#endif
