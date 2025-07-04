#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} BKCOMR08
BK - Relat�rio Tomada de Pre�os Compras

@Return
@author Adilson do Prado
@since 29/01/13
@version P12
/*/

User Function BKCOMR08()

Local aDbf 		    := {}
Local oTmpTb
Local titulo        := "Tomada de Pre�os Compras"

Private cTitulo     := "Tomada de Pre�os Compras"
Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 220
Private tamanho     := "G"
Private nomeprog    := "BKCOMR08" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 18
Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey    := 0
Private cPerg       := "BKCOMR08"
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "BKCOMR08" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString     := "SC7"

PRIVATE	cPict       := "@E 99,999,999,999.99"
PRIVATE nPeriodo    := 1
PRIVATE nPlan       := 1
Private aHeader	    := {}
PRIVATE aTitulos,aCampos,aCabs,aTotal
PRIVATE cProdI  	:= ""


ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif
u_MsgLog(cPerg)

cProdI 	:= mv_par01
titulo  := "Tomada de Pre�os Compras - Produto: "+TRIM(cProdI)
cTitulo := titulo
aDbf    := {} 

Aadd( aDbf, { 'XX_EMPRES',  'C', 10,00 } )
Aadd( aDbf, { 'XX_PRODT',  	'C', 15,00 } )
Aadd( aDbf, { 'XX_DESCP',  	'C', 60,00 } )
Aadd( aDbf, { 'XX_VUNIT',  	'N', 14,02 } )
Aadd( aDbf, { 'XX_EMISSAO', 'D', 08,00 } )
Aadd( aDbf, { 'XX_FORNEC', 	'C', 06,00 } )
Aadd( aDbf, { 'XX_LOJA',   	'C', 02,00 } ) 
Aadd( aDbf, { 'XX_FANTASI',	'C', 20,00 } ) 
Aadd( aDbf, { 'XX_NFORNEC',	'C', 80,00 } ) 
Aadd( aDbf, { 'XX_CNPJ',   	'C', 14,00 } ) 


///cArqTmp := CriaTrab( aDbf, .t. )
///dbUseArea( .t.,NIL,cArqTmp,'TRB',.f.,.f. )
///IndRegua("TRB",cArqTmp,"XX_PRODT+XX_FORNEC+XX_LOJA",,,"Indexando Arquivo de Trabalho") 

oTmpTb := FWTemporaryTable():New( "TRB")
oTmpTb:SetFields( aDbf )
oTmpTb:AddIndex("indice1", {"XX_PRODT","XX_FORNEC","XX_LOJA"} )
oTmpTb:Create()

aCabs   := {}
aCampos := {}
aTotal	:= {}
aTitulos:= {}

nomeprog := "BKCOMR08/"+TRIM(cUserName)

aAdd(aTitulos,nomeprog+" - "+titulo)


aAdd(aCampos,"TRB->XX_EMPRES")
aAdd(aCabs  ,"Empresa")
aAdd(aTotal,.F.)
aAdd(aHeader,{"Empresa","XX_EMPRES" ,"@!",10,00,"","","C","TRB","R"})

aAdd(aCampos,"TRB->XX_PRODT")
aAdd(aCabs  ,"Produtos")
aAdd(aTotal,.F.)
aAdd(aHeader,{"Produtos","XX_PRODT" ,"@!",15,00,"","","C","TRB","R"})

aAdd(aCampos,"TRB->XX_DESCP")
aAdd(aCabs  ,"Desc. Produtos")
aAdd(aTotal,.F.)
aAdd(aHeader,{"Desc. Produtos","XX_DESCP" ,"@!",60,00,"","","C","TRB","R"})

aAdd(aCampos,"TRB->XX_VUNIT")
aAdd(aCabs  ,"Valor Unit�rio")
aAdd(aTotal,.F.)
aAdd(aHeader,{"Valor Unit�rio","XX_VUNIT" ,"@E 999,999,999.99",14,02,"","","N","TRB","R"})

aAdd(aCampos,"TRB->XX_EMISSAO")
aAdd(aCabs  ,"Data Emissao")
aAdd(aTotal,.F.)
aAdd(aHeader,{"Data Emissao","XX_EMISSAO" ,"",08,00,"","","D","TRB","R"})

aAdd(aCampos,"TRB->XX_FORNEC")
aAdd(aCabs  ,"Cod. Fornecedor")
aAdd(aTotal,.F.)
aAdd(aHeader,{"Cod. Fornecedor","XX_FORNEC" ,"@!",06,00,"","","C","TRB","R"})

aAdd(aCampos,"TRB->XX_LOJA")
aAdd(aCabs  ,"Loja Fornecedor")
aAdd(aTotal,.F.)
aAdd(aHeader,{"Cod. Fornecedor","XX_LOJA" ,"@!",02,00,"","","C","TRB","R"})

aAdd(aCampos,"TRB->XX_FANTASI")
aAdd(aCabs  ,"Nome Fantasia")
aAdd(aTotal,.F.)
aAdd(aHeader,{"Nome Fantasia","XX_FANTASI" ,"@!",20,00,"","","C","TRB","R"})

aAdd(aCampos,"TRB->XX_NFORNEC")
aAdd(aCabs  ,"Raz�o Social")
aAdd(aTotal,.F.)
aAdd(aHeader,{"Raz�o Social","XX_NFORNEC" ,"@!",80,00,"","","C","TRB","R"})

aAdd(aCampos,"TRB->XX_CNPJ")
aAdd(aCabs  ,"CNPJ")
aAdd(aTotal,.F.)
aAdd(aHeader,{"CNPJ","XX_CNPJ" ,"@R 99.999.999/9999-99",14,00,"","","C","TRB","R"})

u_WaitLog(, {|| PBKCOMR08() })
u_WaitLog(, {|| MBKCOMR08() })

oTmpTb:Delete()
///TRB->(Dbclosearea())       
///FErase(cArqTmp+GetDBExtension())
///FErase(cArqTmp+OrdBagExt())
 
Return


Static Function MBKCOMR08()
Local 	cAlias 		:= "TRB"

Private cCadastro	:= "Tomada de Pre�os Compras - Produto: "+TRIM(cProdI)
Private aRotina		:= {}
Private aIndexSz  	:= {}

Private aSize   	:= MsAdvSize(,.F.,400)
Private aObjects	:= { { 450, 450, .T., .T. } }
Private aInfo   	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Private aPosObj 	:= MsObjSize( aInfo, aObjects, .T. )
Private lRefresh	:= .T.
Private aButton 	:= {}
Private _oGetDbSint
Private _oDlgSint

aAdd(aRotina,{"Exp. Excel"	,"U_1BKCOMR08",0,6})
aAdd(aRotina,{"Imprimir"    ,"U_2BKCOMR08",0,7})
aAdd(aRotina,{"Parametros"	,"U_3BKCOMR08",0,8})

dbSelectArea(cAlias)
dbSetOrder(1)
	
DEFINE MSDIALOG _oDlgSint ;
TITLE cCadastro ;
From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
_oGetDbSint := MsGetDb():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], 2, "AllwaysTrue()", "AllwaysTrue()",,,,,,"AllwaysTrue()","TRB")
	
aadd(aButton , { "BMPTABLE" , { || U_1BKCOMR08(), TRB->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Gera Planilha Excel" } )
aadd(aButton , { "BMPTABLE" , { || U_2BKCOMR08(), TRB->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Imprimir" } )
aadd(aButton , { "BMPTABLE" , { || U_3BKCOMR08(), TRB->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Parametros" } )
	
ACTIVATE MSDIALOG _oDlgSint ON INIT EnchoiceBar(_oDlgSint,{|| _oDlgSint:End()}, {||_oDlgSint:End()},, aButton)

Return Nil


Static Function LimpaBrw(cAlias)
	DbSelectArea(cAlias)
	(cAlias)->(dbgotop())
	Do While (cAlias)->(!eof())
		RecLock(cAlias,.F.)
		(cAlias)->(dbDelete())
		(cAlias)->(MsUnlock())
       	dbselectArea(cAlias)
   		(cAlias)->(dbskip())
	ENDDO

Return (.T.) 


// Gera Excel
User FUNCTION 1BKCOMR08()
Local aPlans  := {}

AADD(aPlans,{"TRB",TRIM(cPerg),"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, aTotal/*aTotal */, /*cQuebra*/, lClose:= .F. })
U_PlanXlsx(aPlans,cTitulo,TRIM(cPerg),.F.)
Return 


Static Function PBKCOMR08
Local cQuery := ""
Local nReg := 0
Local aBkGrupo := u_BKGrupo()
Local nE := 0

LimpaBrw("TRB")

nReg := 0

For nE := 1 To Len(aBkGrupo)
	If !Empty(cProdI)
		cQuery := "SELECT DISTINCT TOP 10 C7_FORNECE,C7_LOJA FROM SC7"+TRIM(aBkGrupo[nE,1])+"0 WHERE D_E_L_E_T_=''"
		cQuery += " AND C7_PRODUTO = '"+cProdI+"'"
	Else
		cQuery := "SELECT TOP 10 C7_FORNECE,C7_LOJA,C7_EMISSAO FROM SC7"+TRIM(aBkGrupo[nE,1])+"0 WHERE D_E_L_E_T_=''"
		cQuery += " ORDER BY C7_EMISSAO,C7_FORNECE,C7_LOJA DESC"
	EndIf
 
	TCQUERY cQuery NEW ALIAS "QTMP"

	dbSelectArea("QTMP")
	QTMP->(dbGoTop())
	DO WHILE QTMP->(!EOF())
    
		cQuery := "SELECT TOP 1 C7_PRODUTO,B1_DESC,C7_PRECO,C7_EMISSAO,C7_FORNECE,C7_LOJA,A2_NREDUZ,A2_NOME,A2_CGC"
		cQuery += " FROM SC7"+TRIM(aBkGrupo[nE,1])+"0 SC7"
		cQuery += " INNER JOIN SB1"+TRIM(aBkGrupo[nE,1])+"0 SB1 ON SC7.C7_PRODUTO=SB1.B1_COD AND SB1.D_E_L_E_T_=''"
		cQuery += " INNER JOIN SA2"+TRIM(aBkGrupo[nE,1])+"0 SA2 ON SC7.C7_FORNECE=SA2.A2_COD AND SC7.C7_LOJA=SA2.A2_LOJA AND SA2.D_E_L_E_T_=''"
 		cQuery += " WHERE SC7.D_E_L_E_T_='' and SC7.C7_FORNECE='"+QTMP->C7_FORNECE+"' and SC7.C7_LOJA='"+QTMP->C7_LOJA+"'"
		If !Empty(cProdI)
			cQuery += " AND SC7.C7_PRODUTO = '"+cProdI+"'"
		EndIf
		cQuery += " ORDER BY C7_EMISSAO,C7_PRODUTO DESC"

		TCQUERY cQuery NEW ALIAS "QSC7"
		TCSETFIELD("QSC7","C7_EMISSAO","D",8,0)

		//ProcRegua(QSC7->(LASTREC()))

		dbSelectArea("QSC7")
		QSC7->(dbGoTop())
		DO WHILE QSC7->(!EOF())
	    	nReg++
			//IncProc("Consultando banco de dados...")
			Reclock("TRB",.T.)
			TRB->XX_EMPRES 	:= ALLTRIM(FWEmpName(cEmpAnt))
			TRB->XX_PRODT 	:= QSC7->C7_PRODUTO
			TRB->XX_DESCP 	:= QSC7->B1_DESC
			TRB->XX_VUNIT 	:= QSC7->C7_PRECO
			TRB->XX_EMISSAO := QSC7->C7_EMISSAO
			TRB->XX_FORNEC	:= QSC7->C7_FORNECE
			TRB->XX_LOJA 	:= QSC7->C7_LOJA
			TRB->XX_FANTASI := QSC7->A2_NREDUZ
			TRB->XX_NFORNEC := QSC7->A2_NOME
			TRB->XX_CNPJ 	:= QSC7->A2_CGC
 			TRB->(Msunlock())

			QSC7->(dbSkip())
		ENDDO
		QSC7->(dbCloseArea())
		
		QTMP->(dbSkip())
	ENDDO
	QTMP->(dbCloseArea())

Next


IF nReg < 1
	Reclock("TRB",.T.)
	TRB->XX_PRODT 	:= "Null"
 	TRB->(Msunlock())
ENDIF

TRB->(dbGoTop())

Return



User Function 2BKCOMR08()
Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de acordo com os parametros informados pelo usuario."
Local cDesc3        := ""
Local nLin          := 80
Local Cabec1        := ""
Local Cabec2        := ""
Local aOrd          := {}
Local titulo        := ""

titulo := "Tomada de Pre�os Compras - Produto: "+TRIM(cProdI)


	//���������������������������������������������������������������������Ŀ
	//� Monta a interface padrao com o usuario...                           �
	//�����������������������������������������������������������������������
	
	wnrel := SetPrint(cString,"BKCOMR08",cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.) 
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
	   Return
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)
	            
	//���������������������������������������������������������������������Ŀ
	//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
	//�����������������������������������������������������������������������
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	m_pag   := 01 
	
RETURN


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � AP6 IDE            � Data �  08/04/08   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

nEsp    := 2
cPicQ 	:= "@E 99999999.99"
cPicV 	:= "@E 999,999,999.99"

Cabec1  += PAD("Empresa",LEN(TRB->XX_EMPRES)+nEsp)
Cabec1  += PAD("Produto",LEN(TRB->XX_PRODT)+nEsp)
Cabec1  += PAD("Desc.Prod.",33+nEsp)
Cabec1  += PADL("Unit. R$",LEN(cPicV)-3)+SPACE(nEsp)
Cabec1  += PAD("Emiss�o",8+nEsp)
Cabec1  += PAD("Fornec",LEN(TRB->XX_FORNEC)+nEsp)
Cabec1  += PAD("Lj",LEN(TRB->XX_LOJA)+nEsp)
Cabec1  += PAD("Nome Fantasia",LEN(TRB->XX_FANTASI)+nEsp)
Cabec1  += PAD("Raz�o Social",15+nEsp)
Cabec1  += PAD("CNPJ",15+nEsp)

IF LEN(Cabec1) > 132
   Tamanho := "G"
ENDIF   

Titulo   := TRIM(Titulo)

nomeprog := "BKCOMR08/"+TRIM(cUserName)
   
Dbselectarea("TRB")
Dbgotop()
SetRegua(LastRec())

DO While !TRB->(EOF())

   IncRegua()
   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //���������������������������������������������������������������������Ŀ
   //� Impressao do cabecalho do relatorio. . .                            �
   //�����������������������������������������������������������������������

   If nLin > 75 // Salto de P�gina. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,nomeprog,Tamanho,nTipo,,.F.)
      nLin := 9
   Endif

   nPos := 0

   @ nLin,nPos PSAY TRB->XX_EMPRES
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_PRODT
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY PAD(TRB->XX_DESCP,35)
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_VUNIT PICTURE cPicV
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_EMISSAO 
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_FORNEC 
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_LOJA 
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_FANTASI
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY PAD(TRB->XX_NFORNEC,15) 
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_CNPJ  PICTURE "@R 99.999.999/9999-99"
   nPos := PCOL()+nEsp

   nLin++
  
   TRB->(dbSkip())
EndDo


//���������������������������������������������������������������������Ŀ
//� Finaliza a execucao do relatorio...                                 �
//�����������������������������������������������������������������������

SET DEVICE TO SCREEN

//���������������������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenciador de impressao...          �
//�����������������������������������������������������������������������

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return


User FUNCTION 3BKCOMR08()

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif

cProdI  := mv_par01

titulo  := "Tomada de Pre�os Compras - Produto: "+TRIM(cProdI)

cTitulo := titulo

u_WaitLog(, {|| PBKCOMR08() })

Return Nil


Static Function  ValidPerg(cPerg)
Local i,j
Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Produto ?","Produto ?","Produto ?","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1","S","",""})

For i:=1 to Len(aRegistros)
	If !dbSeek(cPerg+aRegistros[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegistros[i])
				FieldPut(j,aRegistros[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

RestArea(aArea)

Return(NIL)
