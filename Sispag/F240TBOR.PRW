// Marcos B. Abrahão - 17/12/14
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ F240TBOR ºAutor  ³Marcos B. Abrahão   º Data ³  20/06/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada utilizado para passar o codigo de barras  º±±
±±º          ³ dos titulos selecionados em um bordero de pagamentos       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ KLOECKNER / BK                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  

A configuração deve atender as necessidades do sistema considerando as seguintes variáveis:

_ TITULO
_ESPECIE
_OCORRENCIA
_DATA
_VALOR
_DESPESA
_DESCONTO
_JUROS
_ABATIMENTO
_MULTA
_IOF
_OUTROSCREDITOS
_DATACREDITO
_MOTIVO
_NOSSONUMERO
_RESERVADO
_SEGMENTO

Funções Padrões Disponíveis:

_ MOD10

_ MOD11

_ VLDCODBAR

_ SOMAVALOR

_ INCREMENTA

_ INCREMENTAL

_ NOSSONUM

_ NUMTITULO

_ GRAVADATA
	Onde:
	ExpD1: Data a ser Convertida
	ExpL1: Tipo ( Se .T. com Barra, se .F. sem Barra)
	ExpN1: Formato
	
	1 - ddmmaa
	2 - mmddaa
	3 - aaddmm
	4 - aammdd
	5 - ddmmaaaa
	6 - mmddaaaa
	7 - aaaaddmm
	8 - aaaammdd

Cadastrar no SEB: 341 00  R  06  BAIXAS A PAGAR

// Sispag
Alterar o X1_TAMANHO do AFI300 04 para 50 e X1_VALID para !EMPTY(MV_PAR04 := U_SELARQ(MV_PAR04)) 

Colocar a formula no X1_VALID do grupo FIN240 01: !EMPTY(MV_PAR02:= MV_PAR01)
Colocar a formula no X1_VALID do grupo FIN240 02: !EMPTY(MV_PAR04:="S:\SISPAG\REMESSA\"+TRIM(MV_PAR01)+".TXT" 

Copia de Cheques:
Colocar a formula no X1_VALID do grupo FIN490 04: !EMPTY(MV_PAR05:= MV_PAR04)
 
Alterar o campo X3_BROWSE = "S" para o campo E2_IDCNAB	
		
*/

User Function F240TBOR()
Local cAlias   := ALIAS()
Local aAreaSe2 := SE2->(GetArea())           
Local aAreaSa2 := SA2->(GetArea())           

PRIVATE nValor,cCodBar,cBanco,cAg,cConta

cCodBar := SE2->E2_CODBAR
nValor  := SE2->E2_SALDO - SE2->E2_SDDECRE + SE2->E2_SDACRES

IF cModPgto $ "01/03/41" // Doc e Deposito em conta
	TelaBco()
ELSEIF cModPgto $ "17" // Gps
	TelaGps()
ELSEIF cModPgto $ "16" // Darf
	TelaDarf()
ELSEIF cModPgto $ "25/27/26" // IPVA / DPVAT / LICENCIAMENTO
	TelaIPVA()
ELSE   // 30/31-BOLETO  13-CONCESSIONARIAS
	TelaBar()
ENDIF

dbSelectArea("SA2")
RestArea(aAreaSa2)

dbSelectArea("SE2")
RestArea(aAreaSe2)

DbSelectArea(cAlias)

Return(nil)


Static Function TelaBar()
Local cNumTit
Local oDlg1

cNumTit := NUMTITULO()
 	
DbSelectArea("SE2")

Define MsDialog oDlg1 Title "Entrada de Codigo de Barras do Titulo" From 000,000 To 200,380 Of oDlg1 Pixel

@ 005,005 SAY "Titulo" Of oDlg1 Pixel
@ 005,050 GET cNumTit SIZE 140,10 WHEN .F. Of oDlg1 Pixel  // se2->e2_prefixo+" "+se2->e2_num+" "+se2->e2_parcela+" "+se2->e2_tipo
	
@ 017,005 SAY "Fornecedor" Of oDlg1 Pixel
@ 017,050 GET SE2->E2_NOMFOR SIZE 140,10 WHEN .F. Of oDlg1 Pixel 
	
@ 029,005 SAY "Valor R$" Of oDlg1 Pixel
@ 029,050 GET nValor SIZE 80,10 picture "@e 9,999,999.99" WHEN .F. Of oDlg1 Pixel
	
@ 050,005 SAY "Codigo de Barras" Of oDlg1 Pixel
@ 061,005 GET cCodBar SIZE 148,10 Valid (!EMPTY(cCodBar) .AND. U_CodBarTVl(cCodBar,nValor)) Of oDlg1 Pixel

DEFINE SBUTTON FROM 077,050 TYPE 1 ACTION (oDlg1:End(),GravaBar()) ENABLE OF oDlg1
	
ACTIVATE DIALOG oDlg1 CENTER
	
//EndIf

Return(nil)

*****************************************************************************

Static Function GravaBar()

DbSelectArea("SE2")
RecLock("SE2",.f.)

SE2->E2_CODBAR  := U_ConvTLD(cCodBar)

MsUnlock()

// Grava valor do bordero no SEA
DbSelectArea("SEA")
RecLock("SEA",.F.)
SEA->EA_XXVALOR := SE2->E2_SALDO - SE2->E2_SDDECRE + SE2->E2_SDACRES
MsUnlock()

Return

**********************************************************************************************

Static Function TelaBco()
Local cForn
Local cNumTit

cNumTit := NUMTITULO()
 
dbSelectArea("SA2") 
dbSetOrder(1)

dbseek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
cForn   := TRIM(SA2->A2_COD)+"-"+TRIM(SA2->A2_LOJA)+" "+SA2->A2_NOME

IF SUBSTR(SE2->E2_CODBAR,1,1) <> "C"
	cBanco  := SA2->A2_BANCO
	cAg     := SubStr(SA2->A2_AGENCIA,1,4)
	cConta  := SA2->A2_NUMCON
ELSE
	//CBBBAAAACCCCCCCCCC
	cBanco  := SUBSTR(SE2->E2_CODBAR,2,3)
	cAg     := SUBSTR(SE2->E2_CODBAR,5,4)
	cConta  := SUBSTR(SE2->E2_CODBAR,9,10)
ENDIF

Define MsDialog oDlg2 Title "Cadastro da C/C do Fornecedor" From 000,000 To 200,380 Pixel

@ 005,005 SAY "Título" Of oDlg2 Pixel
@ 005,050 GET cNumTit SIZE 140,10 Of oDlg2 Pixel WHEN .F.

@ 017,005 SAY "Fornecedor:" Of oDlg2 Pixel
@ 017,050 GET cForn SIZE 140,10 Of oDlg2 Pixel WHEN .F.

@ 029,005 SAY "Valor R$"
@ 029,050 GET nValor SIZE 80,10 picture "@e 9,999,999.99" Of oDlg2 Pixel WHEN .F. 

@ 041,005 SAY "Banco:" Of oDlg2 Pixel
@ 041,050 GET cBanco SIZE 17,10 Valid !EMPTY(cBanco) Of oDlg2 Pixel

@ 053,005 SAY "Agencia:" Of oDlg2 Pixel
@ 053,050 GET cAg    SIZE 20,10 Valid !EMPTY(cAg) Of oDlg2 Pixel

@ 065,005 SAY "C/Corrente+dig" Of oDlg2 Pixel
@ 065,050 GET cConta SIZE 50,10 Valid !EMPTY(cConta) Of oDlg2 Pixel

//@ 065,005 SAY "Dig C/Corrente"
//@ 065,035 GET cCcDig SIZE 50,50

DEFINE SBUTTON FROM 080,050 TYPE 1 ACTION (oDlg2:End(),GravaFor()) ENABLE OF oDlg2

ACTIVATE DIALOG oDlg2 CENTER

Return Nil

*********************************************************************************************

Static Function GravaFor()

dbSelectArea("SA2")
RecLock("SA2",.f.)
sa2->a2_banco   := cBanco
sa2->a2_agencia := cAg
sa2->a2_numcon  := cConta
MsUnlock()

dbSelectArea("SE2")
RecLock("SE2",.f.)
// Grava Banco Ag e Conta no cod de barras apenas para histórico
se2->e2_codbar  := "C"+cBanco+cAg+cConta
MsUnlock()

// Grava valor do bordero no SEA
DbSelectArea("SEA")
RecLock("SEA",.F.)
SEA->EA_XXVALOR := SE2->E2_SALDO - SE2->E2_SDDECRE + SE2->E2_SDACRES
MsUnlock()

Return

*********************************************************************************************
Static Function TelaGps()
Local cNumTit
Local dLast := dDataBase - DAY(dDataBase)
Private cCodRec,cCompet
 
cNumTit := NUMTITULO()
 
dbSelectArea("SA2") 
dbSetOrder(1)

IF SUBSTR(SE2->E2_CODBAR,1,1) <> "G"
	cCodRec := "2100  "
	cCompet := STRZERO(MONTH(dLast),2)+STRZERO(YEAR(dLast),4)
ELSE
	//GCCCCCCPPPPPP
	cCodRec := SUBSTR(SE2->E2_CODBAR,2,6)
	cCompet := SUBSTR(SE2->E2_CODBAR,8,6)
ENDIF

Define MsDialog oDlg2 Title "Pagamento de GPS" From 000,000 To 200,380 Pixel

@ 005,005 SAY "Título" Of oDlg2 Pixel
@ 005,050 GET cNumTit SIZE 140,10 WHEN .F. Of oDlg2 Pixel

@ 017,005 SAY "Código da receita" Of oDlg2 Pixel
@ 017,050 GET cCodRec SIZE 25,10 Of oDlg2 Pixel

@ 029,005 SAY "Competência:" Of oDlg2 Pixel
@ 029,050 GET cCompet SIZE 25,10 Of oDlg2 Pixel

@ 041,005 SAY "Valor R$" Of oDlg2 Pixel
@ 041,050 GET nValor SIZE 80,10 picture "@e 9,999,999.99" WHEN .F. Of oDlg2 Pixel

DEFINE SBUTTON FROM 077,050 TYPE 1 ACTION (oDlg2:End(),GravaGps()) ENABLE OF oDlg2

ACTIVATE DIALOG oDlg2 CENTER

Return Nil

*********************************************************************************************

Static Function GravaGps()

dbSelectArea("SE2")
RecLock("SE2",.f.)
// Grava Banco Ag e Conta no cod de barras apenas para histórico
se2->e2_codbar  := "G"+cCodRec+cCompet
MsUnlock()

// Grava valor do bordero no SEA
DbSelectArea("SEA")
RecLock("SEA",.F.)
SEA->EA_XXVALOR := SE2->E2_SALDO - SE2->E2_SDDECRE + SE2->E2_SDACRES
MsUnlock()
Return
*********************************************************************************************

*********************************************************************************************
Static Function TelaDarf()
Local cNumTit
Private cCodRec  := SPACE(6)
Private cRef     := SPACE(17)
Private dPeriodo := dDataBase - DAY(dDataBase)
 
cNumTit := NUMTITULO()
 
IF SUBSTR(SE2->E2_CODBAR,1,1) == "D"
	//DCCCCCCRRRRRRRRRRRRRRRRRPPPPPPPP
	cCodR    := SUBSTR(SE2->E2_CODBAR,2,6)
	cRef     := SUBSTR(SE2->E2_CODBAR,8,17)
	dPeriodo := STOD(SUBSTR(SE2->E2_CODBAR,25,8))
ENDIF

Define MsDialog oDlg2 Title "Pagamento de DARF" From 000,000 To 200,380 Pixel

@ 005,005 SAY "Título" Of oDlg2 Pixel
@ 005,050 GET cNumTit SIZE 140,10 WHEN .F. Of oDlg2 Pixel

@ 017,005 SAY "Código da receita" Of oDlg2 Pixel
@ 017,050 GET cCodRec SIZE 20,10 Of oDlg2 Pixel

@ 029,005 SAY "Referencia" Of oDlg2 Pixel
@ 029,050 GET cRef SIZE 140,10 Of oDlg2 Pixel

@ 041,005 SAY "Período:" Of oDlg2 Pixel
@ 041,050 GET dPeriodo SIZE 50,10 Of oDlg2 Pixel

@ 053,005 SAY "Valor R$" Of oDlg2 Pixel
@ 053,050 GET nValor SIZE 80,10 picture "@e 9,999,999.99" WHEN .F. Of oDlg2 Pixel

DEFINE SBUTTON FROM 077,050 TYPE 1 ACTION (oDlg2:End(),GravaDarf()) ENABLE OF oDlg2

ACTIVATE DIALOG oDlg2 CENTER

Return Nil

*********************************************************************************************

Static Function GravaDarf()

dbSelectArea("SE2")
RecLock("SE2",.f.)
// Grava Banco Ag e Conta no cod de barras apenas para histórico
se2->e2_codbar  := "D"+cCodRec+cRef+DTOS(dPeriodo)
MsUnlock()

// Grava valor do bordero no SEA
DbSelectArea("SEA")
RecLock("SEA",.F.)
SEA->EA_XXVALOR := SE2->E2_SALDO - SE2->E2_SDDECRE + SE2->E2_SDACRES
MsUnlock()
Return

*********************************************************************************************


*********************************************************************************************
Static Function TelaIPVA()
Local cNumTit
Local oDlg2
Local cTitulo    := ""
Private cCodRec  := SPACE(6)
Private cAnoBase := SPACE(4)
Private cRenavam := SPACE(9)
Private cUF      := "SP"
Private cMun	 := SPACE(5)
Private cPlaca   := SPACE(7)
Private nOpcPg   := 1
Private aOpcPg   := {}

AADD(aOpcPg,"1 = Parcela unica com desconto")
AADD(aOpcPg,"2 = Parcela unica sem desconto")
AADD(aOpcPg,"3 = Parcela 1                 ")
AADD(aOpcPg,"4 = Parcela 2                 ")
AADD(aOpcPg,"5 = Parcela 3                 ")
AADD(aOpcPg,"6 = Parcela 4                 ")
AADD(aOpcPg,"7 = Parcela 5                 ")
AADD(aOpcPg,"8 = Parcela 6                 ")	
 
cNumTit := NUMTITULO()
 
IF SUBSTR(SE2->E2_CODBAR,1,1) == "I"
	// DCCCCCCRRRRRRRRRUFMMMMMPPPPPPPO
	cCodRec  := SUBSTR(SE2->E2_CODBAR,2,6)
	cAnoBase := SUBSTR(SE2->E2_CODBAR,8,4)
	cRenavam := SUBSTR(SE2->E2_CODBAR,12,9)
	cUF      := SUBSTR(SE2->E2_CODBAR,21,2)
	cMun	 := SUBSTR(SE2->E2_CODBAR,23,5)
	cPlaca   := SUBSTR(SE2->E2_CODBAR,28,7)
	nOpcPg   := VAL(SUBSTR(SE2->E2_CODBAR,35,1))
	IF nOpcPg < 1 .OR. nOpcPg > 8
		nOpcPg := 1
	ENDIF
ENDIF
cOpcPg  := aOpcPg[nOpcPg]
	
If cModPgto == "25"
	cTitulo := "Pagamento de IPVA"
ElseIf cModPgto = "27"
	cTitulo := "Pagamento de DPVAT"
EndIf
 
Define MsDialog oDlg2 Title cTitulo From 000,000 To 260,380 PIXEL

@ 005,005 SAY "Título" OF oDlg2 PIXEL
@ 005,050 GET cNumTit SIZE 140,10 WHEN .F. OF oDlg2 PIXEL 

@ 017,005 SAY "Código da receita" OF oDlg2 PIXEL
@ 017,050 GET cCodRec SIZE 20,10  OF oDlg2 PIXEL 

@ 029,005 SAY "Ano base" OF oDlg2 PIXEL
@ 029,050 GET cAnoBase SIZE 50,10 OF oDlg2 PIXEL  

@ 041,005 SAY "Renavam" OF oDlg2 PIXEL
@ 041,050 GET cRenavam SIZE 50,10 OF oDlg2 PIXEL  

@ 053,005 SAY "UF:" OF oDlg2 PIXEL
@ 053,050 GET cUF SIZE 10,10 OF oDlg2 PIXEL

@ 065,005 SAY "Municipio:" OF oDlg2 PIXEL
@ 065,050 GET cMun SIZE 25,10 OF oDlg2 PIXEL

@ 077,005 SAY "Placa:" OF oDlg2 PIXEL
@ 077,050 GET cPlaca SIZE 30,10 OF oDlg2 PIXEL 

@ 089,005 SAY "Opção pgto:" OF oDlg2 PIXEL
@ 089,050 MSCOMBOBOX oComboBo1 VAR nOpcPg ITEMS aOpcPg SIZE 100, 008 OF oDlg2 COLORS 0, 16777215 PIXEL
//@ 089,050 COMBOBOX cOpcPg ITEMS aOpcPg SIZE 100,50 OF oDlg2 PIXEL

@ 101,005 SAY "Valor R$" OF oDlg2 PIXEL
@ 101,050 GET nValor SIZE 80,10 picture "@e 9,999,999.99" WHEN .F. OF oDlg2 PIXEL

DEFINE SBUTTON FROM 116,050 TYPE 1 ACTION (oDlg2:End(),GravaIpva()) ENABLE OF oDlg2

ACTIVATE DIALOG oDlg2 CENTER

Return Nil

*********************************************************************************************

Static Function GravaIPVA()
Local cOpcPg
cOpcPg := VALTYPE(nOpcPg)
If VALTYPE(nOpcPg) == "N"
	cOpcPg := aOpcPg[nOpcPg]
Else
	cOpcPg := nOpcPg
EndIf

dbSelectArea("SE2")
RecLock("SE2",.f.)
// Grava Banco Ag e Conta no cod de barras apenas para histórico
SE2->E2_CODBAR  := "I"+cCodRec+cAnoBase+cRenavam+cUF+cMun+cPlaca+SUBSTR(cOpcPg,1,1)

MsUnlock()

// Grava valor do bordero no SEA
DbSelectArea("SEA")
RecLock("SEA",.F.)
SEA->EA_XXVALOR := SE2->E2_SALDO - SE2->E2_SDDECRE + SE2->E2_SDACRES
MsUnlock()

Return

*********************************************************************************************
