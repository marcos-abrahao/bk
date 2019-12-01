#ifdef SPANISH
	#define STR0001 "Este programa imprimira el diario general modelo 1, de acuerdo"
	#define STR0002 "con los parametros sugeridos por el usuario. Este modelo es ideal"
	#define STR0003 "para plan de cuentas que posean codigos no muy extensos."
	#define STR0004 "A Rayas"
	#define STR0005 "Administracion"
	#define STR0006 "Emision del diario general"
	#define STR0007 If( cPaisLoc == "ANG", "            C U E N T  A                  H I S T O R I A L                        NUMERO                         V  A  L  O  R", If( cPaisLoc == "EQU", "            C U E N T  A                  H I S T O R I A L                        NUMERO                         V  A  L  O  R", If( cPaisLoc == "HAI", "            C U E N T  A                  H I S T O R I A L                        NUMERO                         V  A  L  O  R", If( cPaisLoc == "MEX", "            C U E N T  A                  H I S T O R I A L                        NUMERO                         V  A  L  O  R", If( cPaisLoc == "PTG", "            C U E N T  A                  H I S T O R I A L                        NUMERO                         V  A  L  O  R", "            C U E N T A                   H I S T O R I A L                        NUMERO                         V  A  L  O  R" ) ) ) ) )
	#define STR0008 If( cPaisLoc == "MEX", "C A R G  O           A B O N O                                                     ASIENTO                     CARGO         ABONO  ", "D E B I T O          C R E D I T O                                                 ASIENTO                     DEBITO        CREDITO" )
	#define STR0009 "DE DIARIO GRAL. "
	#define STR0010 " A "
	#define STR0011 " EN "
	#define STR0012 "***** ANULADO POR EL OPERADOR *****"
	#define STR0013 "A Transportar =======>"
	#define STR0014 "De Transporte =======>"
	#define STR0015 "Total de este dia ======>"
	#define STR0016 "Total de este mes ======>"
	#define STR0017 "Total General ==========>"
	#define STR0018 "D I A R I O    G E N E R A L"
	#define STR0019 "Pag. :    "
	#define STR0020 "Microsiga Software S/A "
	#define STR0021 "Hora Termino: "
	#define STR0022 If( cPaisLoc == "MEX", "Val.Cargo", "Val.Debito" )
	#define STR0023 If( cPaisLoc == "MEX", "Val.Abono", "Val.Credito" )
	#define STR0024 "Nº Asiento"
	#define STR0025 "Fch. de los Asientos"
	#define STR0026 "Asientos Contables"
	#define STR0027 "                   C U E N T A                                                   H I S T O R I A L                        Número                                  V  A  L  O  R"
	#define STR0028 If( cPaisLoc == "MEX", "C A R G O                                A B O N O                                                                        Asto.                            Cargo               Abono  ", "D E B I T O                              C R E D I T O                                                                    Asiento                          Debito              Credito" )
	#define STR0029 "              CUE N T A                             H I S T O R I A L              NUMERO                         V  A  L  O  R"
	#define STR0030 If( cPaisLoc == "MEX", "C A R G O                 A B O N O                                                ASTO.                      CARGO         ABONO  ", "D E B I T O               C R E D I T O                                            ASIENTO                     DEBITO        CREDITO" )
	#define STR0031 "                 C U E N T A                        H I S T O R I A L    NUMERO                                   V  A  L  O  R"
	#define STR0032 If( cPaisLoc == "MEX", "C A R G O                 A B O N O                                      ASTO.                                 CARGO         ABONO  ", "D E B I T O               C R E D I T O                                  ASIENTO                               DEBITO        CREDITO" )
	#define STR0033 "Totalizadores de Dia / Mes / General"
	#define STR0034 "Totalizador de Transporte de Pagina"
	#define STR0035 "Sucursal: "
	#define STR0036 "¡Atencion!"
	#define STR0037 "Diario no contiene datos para los parametros especificados. ¿Continuar Imprimiendo Balance Parcial?"
	#define STR0038 "No"
	#define STR0039 "Si"
	#define STR0040 "Diario no contiene datos para los parametros especificados. ¿Continuar Imprimiendo Plan de Cuentas?"
	#define STR0041 "Para esta version del informe, el numero de lineas no puede ser superior a 90 lineas"
	#define STR0042 "Para esta version del informe, el numero de lineas no puede ser superior a 65 lineas"
#else
	#ifdef ENGLISH
		#define STR0001 "This program will print a General Journal Model 1, according"
		#define STR0002 "to the parameters selected by the user. This model is appro-"
		#define STR0003 "priate for Charts of Accounts with short codes."
		#define STR0004 "Z.Form"
		#define STR0005 "Management"
		#define STR0006 "Print General Journal"
		#define STR0007 "          A C C O U N T                   H I S T O R Y                            ENTRY                          V  A  L  U  E"
		#define STR0008 "D E B I T            C R E D I T                                                   NUMBER                    DEBIT           CREDIT "
		#define STR0009 "GENERAL JOURNAL FROM"
		#define STR0010 " TO "
		#define STR0011 " IN "
		#define STR0012 "***** CANCELLED BY THE OPERATOR *****"
		#define STR0013 "To Transport =======>"
		#define STR0014 "From Transport =======>"
		#define STR0015 "Totals of this Day =======>"
		#define STR0016 "Totals of this Month =======>"
		#define STR0017 "Grand Total ============>"
		#define STR0018 "G E N E R A L   J O U R N A L"
		#define STR0019 "Sheet:    "
		#define STR0020 "Microsiga Software S/A "
		#define STR0021 "End time: "
		#define STR0022 If( cPaisLoc == "MEX", "Debit amnt.", "Debit amn." )
		#define STR0023 "Credit amnt."
		#define STR0024 "Entry number "
		#define STR0025 "Entries date        "
		#define STR0026 "Accounting entries   "
		#define STR0027 "                   A C C O U N T                                                     H I S T O R Y                        Number                                  V  A  L  U  E"
		#define STR0028 If( cPaisLoc == "MEX", "D E B I T                                C R E D I T                                                                      Entry                            Debit              Credit", "D E B I T                                 C R E D I T                                                                      Entry                               Debit                Credit" )
		#define STR0029 "              ACCOUNT                               H I S T O R Y                   NUMBER                        V  A  L  U  E"
		#define STR0030 If( cPaisLoc == "MEX", "D E B I T                C R E D I T                                               ENTRY                      DEBIT         CREDIT", "D E B I T                     C R E D I T                                        ENTRY                      DEBIT        CREDIT" )
		#define STR0031 "                 A C C O U N T                               H I S T O R Y    NUMBER                             V  A  L  U  E"
		#define STR0032 If( cPaisLoc == "MEX", "D E B I T                 C R E D I T                                    ENTRY                                 DEBIT         CREDIT", "D E B I T                     C R E D I T                                        ENTRY                      DEBIT        CREDIT" )
		#define STR0033 "Totalizers of Day / Month / General"
		#define STR0034 "Totalizer of Page Transport"
		#define STR0035 "Branch: "
		#define STR0036 "Attention"
		#define STR0037 "Journal does not present data for specified parameters. Keep printing trial balance?"
		#define STR0038 "No"
		#define STR0039 "Yes"
		#define STR0040 "Journal does not present data for specified parameters. Keep printing chart of accounts?"
		#define STR0041 "This report version allows the maximum of 90 rows."
		#define STR0042 "This report version allows the maximum of 65 rows."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Este programa irá imprimir o registo geral modelo 1, de acordo", "Este programa ira imprimir o Diario Geral Modelo 1, de acordo" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Com os parâmetros sugeridos pelo utilizador. este modelo é ideal", "com os parametros sugeridos pelo usuario. Este modelo e ideal" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Para plano de contas que possuam códigos não muito extensos.", "para Plano de Contas que possuam codigos nao muito extensos." )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Código de barras", "Zebrado" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Administração", "Administracao" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Emissão Do Diário Crial", "Emissao do Diario Geral" )
		#define STR0007 If( cPaisLoc $ "ANG|EQU|HAI", "            C O N T A                     H I S T Ó R I C O                        NÚMERO                         V  A  L  O  R", If( cPaisLoc $ "MEX|PTG", "            C O N T A                     H I S T ó R I C O                        Número                         V  A  L  O  R", "            C O N T A                     H I S T O R I C O                        NUMERO                         V  A  L  O  R" ) )
		#define STR0008 If( cPaisLoc $ "ANG|EQU|HAI", "D É B I T O          C R É D I T O                                                 LANCTO                      DÉBITO        CRÉDITO", If( cPaisLoc $ "MEX|PTG", "D é B I T O          C R é D I T O                                                 Lancto                      Débito        Crédito", "D E B I T O          C R E D I T O                                                 LANCTO                      DEBITO        CREDITO" ) )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "DIÁRIO CRIAL DE", "DIARIO GERAL DE " )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", " até ", " ATE " )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", " em ", " EM " )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "***** cancelado pelo operador *****", "***** CANCELADO PELO OPERADOR *****" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "A transportar =======>", "A Transportar =======>" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "De transporte =======>", "De Transporte =======>" )
		#define STR0015 "Totais deste dia =======>"
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Totais deste mês =======>", "Totais deste mes =======>" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Total crial ============>", "Total Geral ============>" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "D I Á R I O    C R I A L", "D I A R I O    G E R A L" )
		#define STR0019 "Folha:    "
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Microsiga software s/a ", "Microsiga Software S/A " )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Hora termino: ", "Hora Termino: " )
		#define STR0022 If( cPaisLoc == "MEX", "Vlr.Débito", If( cPaisLoc $ "ANG|PTG", "Valor débito", "Vlr.Debito" ) )
		#define STR0023 If( cPaisLoc == "MEX", "Vlr.Crédito", If( cPaisLoc $ "ANG|PTG", "Val.crédito", "Vlr.Credito" ) )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Número Lançt.", "Numero Lancto" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Data Dos Movimentos", "Data dos Lançamentos" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Lançamentos Contabilísticos", "Lançamentos Contábeis" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "                   C O N T A                                                     H I S T ó R I C O                        Número                             V  A  L  O  R", "                   C O N T A                                                     H I S T ó R I C O                        Número                                  V  A  L  O  R" )
		#define STR0028 If( cPaisLoc == "MEX", "D É B I T O                              C R É D I T O                                                                    Lançto                           Débito              Crédito", If( cPaisLoc $ "ANG|PTG", "D É B I T O                              C R É D I T O                                                                    Lancto                           Débito              Crédito", "D é B I T O                              C R é D I T O                                                                    Lancto                           Débito              Crédito" ) )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "              C O N T A                             H I S T Ó R I C O              NÚMERO                         V  A  L  O  R", "              C O N T A                             H I S T O R I C O              NUMERO                         V  A  L  O  R" )
		#define STR0030 If( cPaisLoc == "MEX", "D É B I T O               C R É D I T O                                            LANÇTO                     DÉBITO        CRÉDITO", If( cPaisLoc $ "ANG|PTG", "D É B I T O               C R É D I T O                                            LANCTO                     DÉBITO        CRÉDITO", "D E B I T O               C R E D I T O                                            LANCTO                     DEBITO        CREDITO" ) )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "                 C O N T A                               H I S T ó R I C O    NúMERO                         V  A  L  O  R", "                 C O N T A                          H I S T O R I C O    NUMERO                                   V  A  L  O  R" )
		#define STR0032 If( cPaisLoc == "MEX", "D É B I T O               C R É D I T O                                  LANÇTO                                DÉBITO        CRÉDITO", If( cPaisLoc $ "ANG|PTG", "D é B I T O                    C R é D I T O                                       LANÇTO                      DéBITO        CRéDITO", "D E B I T O               C R E D I T O                                  LANCTO                                DEBITO        CREDITO" ) )
		#define STR0033 "Totalizadores de Dia / Mês / Geral"
		#define STR0034 "Totalizador de Transporte da Página"
		#define STR0035 "Filial : "
		#define STR0036 If( cPaisLoc $ "ANG|PTG", "Atenção", "Atencao" )
		#define STR0037 If( cPaisLoc $ "ANG|PTG", "Diário não contém dados para os parâmetros especificados. Continua a imprimir Balancete?", "Diario nao contem dados para os parametros especificados. Continuar Imprimindo Balancete?" )
		#define STR0038 If( cPaisLoc $ "ANG|PTG", "Não", "Nao" )
		#define STR0039 "Sim"
		#define STR0040 If( cPaisLoc $ "ANG|PTG", "Diário não contém dados para os parâmetros especificados. Continua a imprimiro Plano de Contas?", "Diario nao contem dados para os parametros especificados. Continuar Imprimindo Plano de contas?" )
		#define STR0041 If( cPaisLoc $ "ANG|PTG", "Para esta versão do relatório, o número de linhas não pode ser maior que 90 linhas", "Para esta versão do relatorio o número de linhas não pode ser maior que 90 linhas" )
		#define STR0042 If( cPaisLoc $ "ANG|PTG", "Para esta versão do relatório, o número de linhas não pode ser maior que 65 linhas", "Para esta versão do relatório o númoer de linhas não pode ser maior que 65 linhas" )
	#endif
#endif
