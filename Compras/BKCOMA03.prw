#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKCOMA03()
Inclusao Benef�cios VT/VR/VA Pr�-Documento de Entrada e Assist�ncia M�dica

@author Adilson do Prado
@since 10/04/2012
@version P12
@return .T.
/*/

User Function BKCOMA03()

Local nSnd       := 15
Local nTLin      := 15
Local cTipoArq   := "Todos os Arquivos (*.*) | *.* | "
Local oDlg01     as Object
Local nOpcA      := 0
Local lOk        := .F.
Local aSX5       := {}
Local nX		 := 0
Local aTbSx5     := {}
Local nX5        := 0

Private cTitulo  := "Inclus�o VT,VR,VA e AM em Pr�-Documento de Entrada"
Private cProg    := "BKCOMA03"
Private cPerg    := "BKCOMA03"
Private cDoc     := SPACE(9),cSerie:=SPACE(3),cForn:= SPACE(6),cLoja:=SPACE(2),cEspec:=SPACE(5),cUF:=SPACE(2)
Private cProduto := SPACE(15),cHIST := SPACE(200)
Private nValor   := 0
Private nTotPlan := 0
Private aTipoNF  := {}
Private aValida  := {}
Private cTipoNF  := '' 
Private cArq     := U_BKGetMv("BKCOMA03DR") // Diretorio do ultimo arquivo selecionado
Private cDir     := cArq 
Private dEmissao := dDatabase
Private cCompl   := "2-N�o"
Private aCompl   := {"1-Sim","2-N�o"}

u_MsgLog("BKCOMA03")

/*
// Codigo removido - codeanalisys 17/11/22
dbSelectArea("SX5")
dbSetOrder(1)
dbSeek(xFilial("SX5")+"Z301",.F.)
DO WHILE !EOF() .AND. SX5->X5_TABELA == "Z3"
	aItemX5 := StrTokArr(SX5->X5_DESCRI,";")
    IF LEN(aItemX5) == 4
 		AADD(aSX5,{aItemX5[1],aItemX5[2],aItemX5[3],aItemX5[4]})
 	ENDIF
	SX5->(DBSKIP())
ENDDO
*/

aTbSx5 := FWGetSX5("Z3")
FOR nX5 := 1 To Len(aTbSx5)
	aItemX5 := StrTokArr(aTbSx5[nX5,4],";")
    IF LEN(aItemX5) == 4
 		AADD(aSX5,{aItemX5[1],aItemX5[2],aItemX5[3],aItemX5[4]})
 	ENDIF
NEXT

FOR nX := 2 TO LEN(aSX5)
    AADD(aTipoNF,ALLTRIM(aSX5[nX,1])+" - "+ALLTRIM(aSX5[nX,2]))
    AADD(aValida,{aSX5[nX,1],aSX5[nX,3],aSX5[nX,4]})
NEXT _nX

cTipoNF := aTipoNF[1] 


DEFINE MSDIALOG oDlg01 FROM  96,9 TO 310,592 TITLE OemToAnsi(cProg+" - "+cTitulo) PIXEL

@ nSnd,010 Say "N�mero" Size 080,010 Pixel Of oDlg01
@ nSnd,045 MsGet oNumNF VAR cDoc Picture '@!' Size 040,010 Pixel Of oDlg01 VALID NaoVazio(cDoc) .AND.  cDoc<>'000000000'

oNumNF:bLostFocus := { || IIF(LEN(ALLTRIM(cDoc)) < 9 ,cDoc := STRZERO(0,9-LEN(ALLTRIM(cDoc)))+ALLTRIM(cDoc),), oNumNF:Refresh() }

@ nSnd,090 Say "S�rie" Size 080,010 Pixel Of oDlg01
@ nSnd,125 MsGet cSerie Picture '@!' Size 008,010 Pixel Of oDlg01

@ nSnd,185 Say "DT Emiss�o" Size 080,010 Pixel Of oDlg01
@ nSnd,230 MsGet dEmissao Picture "@E"  Size 040,010 Pixel Of oDlg01 
nSnd += nTLin

@ nSnd,010 SAY "Fornecedor" SIZE 080,010 Pixel Of oDlg01
@ nSnd,045 MsGet oForn VAR cForn SIZE 040,010 OF oDlg01 PIXEL PICTURE '@!' HASBUTTON  F3 "SA2" VALID NaoVazio(cForn)

oForn:bLostFocus := { || cLoja := SA2->A2_LOJA, oForn:Refresh() }

@ nSnd,090 Say "Loja" Size 080,010 Pixel Of oDlg01
@ nSnd,125 MsGet cLoja Picture '@!' Size 008,010 Pixel Of oDlg01 VALID ExistCpo("SA2",cForn+cLoja) .AND. NaoVazio(cLoja)

@ nSnd,185 Say "Espec. Docum." Size 080,010 Pixel Of oDlg01
@ nSnd,230 MsGet cEspec SIZE 040,010 OF oDlg01 PIXEL PICTURE '@!' HASBUTTON  F3 "42" VALID CheckSx3("F2_ESPECIE") .AND. NaoVazio(cEspec)
nSnd += nTLin

@ nSnd,010 Say "Uf.Origem" Size 080,010 Pixel Of oDlg01
@ nSnd,045 MsGet cUF Picture '@!' Size 008,010 OF oDlg01 PIXEL HASBUTTON  F3 "12" Valid Tk273Estado(cUF) .AND. NaoVazio(cUF)

@ nSnd,090 Say "Produto"  Size 080,010 Pixel Of oDlg01
@ nSnd,125 MsGet cProduto SIZE 060,010 OF oDlg01 PIXEL PICTURE '@!' HASBUTTON  F3 "SB1" VALID ExistCPO("SB1",cProduto) .AND. NaoVazio(cProduto)

@ nSnd,185 Say "Valor da NF" Size 080,010 Pixel Of oDlg01
@ nSnd,230 MsGet nValor Picture "@E 999,999,999,999.99" Size 060,010 Pixel Of oDlg01 VALID NaoVazio(nValor)
nSnd += nTLin

@ nSnd,010 SAY 'Tipo'   SIZE 080,010 OF oDlg01 PIXEL
@ nSnd,045 COMBOBOX cTipoNF  ITEMS aTipoNF SIZE 100,010 Pixel OF oDlg01

@ nSnd,185 Say "Hist�rico" Size 080,010 Pixel Of oDlg01
@ nSnd,230 MsGet cHIST Picture '@!' Size 060,010 OF oDlg01 PIXEL
nSnd += nTLin

@ nSnd,010  SAY "Arquivo " of oDlg01 PIXEL // "Objeto "
@ nSnd,045  MsGet cArq SIZE 100,010 of oDlg01 PIXEL READONLY

@ nSnd,185 SAY 'NF Complementar'   SIZE 080,010 OF oDlg01 PIXEL
@ nSnd,230 COMBOBOX cCompl  ITEMS aCompl SIZE 060,010 Pixel OF oDlg01

nSnd += nTLin

@ nSnd,105 BUTTON oButSel PROMPT 'Selecionar' SIZE 40, 12 OF oDlg01 ACTION ( cArq := cGetFile(cTipoArq,"Selecione o diret�rio contendo os arquivos",,cArq,.F.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY,.F.,.T.)  ) PIXEL  // "Selecionar" 

DEFINE SBUTTON FROM nSnd, 223 TYPE 1 ACTION (oDlg01:End(),nOpcA:=1) ENABLE OF oDlg01
DEFINE SBUTTON FROM nSnd, 253 TYPE 2 ACTION (oDlg01:End(),,nOpcA:=0) ENABLE OF oDlg01

ACTIVATE MSDIALOG oDlg01 CENTER Valid(ValidaNF())

If nOpcA == 1
	nOpcA:=0
	IF SUBSTR(cTipoNF,1,2) == "AS"
		u_WaitLog(cProg, {|| MontaPlaAS()}, 'Gerando os Itens (AS). Aguarde!')		
	ELSE
		u_WaitLog(cProg, {|| MontaItemNF()}, 'Gerando os Itens ('+cTipoNF+'). Aguarde!')		
	ENDIF
Endif

RETURN lOk


Static Function MontaItemNF()
Local nSnd       := 15
Local nTLin      := 15
Local oDlg01     as Object
Local aButtons   := {}
Local cBuffer    :=''
Local nX         := 0
Local lID        := .F.
Local lOk        := .F.
Local cCODFUN    := ''
Local cQuery     := ''
Local nQUANT     := 0
Local nVALITNF   := 0 
Local nTotal     := 0
Local nValRat    := 0
Local aX5        := {}
Local nI		 := 0
Local aTbSx5     := {}
Local nX5        := 0
Local aItemLinha := {}
Local aItemCC    := {}

aX5 := {}

/*
dbSelectArea("SX5")
dbSetOrder(1)
dbSeek(xFilial("SX5")+"Z4"+SUBSTR(cTipoNF,1,2),.T.)
DO WHILE !EOF() .AND. SUBSTR(SX5->X5_CHAVE,1,2) == SUBSTR(cTipoNF,1,2)
	IncProc('Carregando Itens da NF')
	AADD(aX5,StrTokArr(SX5->X5_DESCRI,";"))
	SX5->(DBSKIP())
ENDDO
*/

aTbSx5 := FWGetSX5("Z4")
FOR nX5 := 1 To Len(aTbSx5)
	//IncProc('Carregando defini��o de Itens')
	If SUBSTR(aTbSx5[nX5,3],1,2) == SUBSTR(cTipoNF,1,2)
		AADD(aX5,StrTokArr(aTbSx5[nX5,4],";"))
	EndIf
NEXT

nTotal := 0

FT_FUSE(cArq)  //abrir
FT_FGOTOP() //vai para o topo
//Procregua(FT_FLASTREC())  //quantos registros para ler
 
While !FT_FEOF()
 
	//IncProc('Carregando Itens da NF')
 
	//Capturar dados
	cBuffer := FT_FREADLN()  //lendo a linha
	If ( !Empty(cBuffer) )
    	lID 	:= .F.
		cCODFUN := ''
		nQUANT 	:= 0
		nVALITNF:= 0

		For nI := 2 To LEN(aX5)
    		IF aX5[nI,1] == 'ID' .AND.  SUBSTR(cBuffer,VAL(aX5[nI,2]),VAL(aX5[nI,3])) == ALLTRIM(aX5[nI,4]) 
    			lID := .T.
    		ENDIF
    		IF aX5[nI,1] == 'CODFUN'
      			cCODFUN := SUBSTR(cBuffer,VAL(aX5[nI,2]),VAL(aX5[nI,3])) 
      		ENDIF
    		IF aX5[nI,1] == 'QTD' .AND. VAL(aX5[nI,2]) > 0
      			nQUANT := VAL(StrTran(SUBSTR(cBuffer,VAL(aX5[nI,2]),VAL(aX5[nI,3])),".","")) 
      		ENDIF
    		IF aX5[nI,1] == 'VAL'
      			nVALITNF := VAL(StrTran(SUBSTR(cBuffer,VAL(aX5[nI,2]),VAL(aX5[nI,3])),".","")) 
      		ENDIF
		Next nI
    	IF lID
    	    IF cCompl <> '1-Sim'
				AADD(aItemLinha,{cCODFUN,IIF(nQUANT>0,(nQUANT*nVALITNF)*0.01,nVALITNF*0.01)})
				nTotal += IIF(nQUANT>0,(nQUANT*nVALITNF)*0.01,nVALITNF*0.01)
			ELSE
				AADD(aItemLinha,{cCODFUN,0})
				nTotal += 0
			ENDIF
    	ENDIF
    ENDIF
	FT_FSKIP()   //proximo registro no arquivo txt
Enddo
 
FT_FUSE()  //fecha o arquivo txt


// Calcula valor rateio
aLINHAxx := {}
IF LEN(aItemLinha) > 0
	nValRat := (nValor - nTotal) / LEN(aItemLinha) 
	//Procregua(LEN(aItemLinha))
	For nX := 1 To LEN(aItemLinha)
		//IncProc('Calculando Rateio do Item da NF')
		AADD(aLINHAxx,{aItemLinha[nX,1],aItemLinha[nX,2],nValRat,""})		
		aItemLinha[nX,2] += nValRat
	NEXT
ENDIF

IF LEN(aItemLinha) == 0
   u_MsgLog(cProg,"Itens da NF n�o encontrados verifique o arquivo de Lote","E")
   RETURN NIL
ENDIF

//Procregua(LEN(aItemLinha))
aItemCC := {}
aSemCC  := {}

nTotal  := 0

For nX := 1 To LEN(aItemLinha)
	//IncProc('Carregando Itens da NF')
	nTotal += aItemLinha[nX,2]

	cQuery  := "SELECT TOP 1 bk_senior.bk_senior.r034fun.numcad,bk_senior.bk_senior.r034fun.nomfun, "
	cQuery  += "right('00' + cast(bk_senior.bk_senior.r034fun.numemp as varchar(2)),2) AS cEmp, "
	cQuery  += "right('000' + cast(bk_senior.bk_senior.R030FIL.CodFil as varchar(3)),3) AS cFil, " 
	cQuery  += "(SELECT BKIntegraRubi.dbo.fnCCSiga(bk_senior.bk_senior.r034fun.numemp,bk_senior.bk_senior.r034fun.tipcol,bk_senior.bk_senior.r034fun.numcad, 'CLT') AS Expr1) AS CCSiga, "
	cQuery  += "bk_senior.bk_senior.R030FIL.NomFil "
	cQuery  += "FROM  bk_senior.bk_senior.r034fun "
	cQuery  += "INNER JOIN bk_senior.bk_senior.R030FIL ON bk_senior.bk_senior.r034fun.numemp = bk_senior.bk_senior.R030FIL.NumEmp "
	cQuery  += "AND bk_senior.bk_senior.r034fun.codfil = bk_senior.bk_senior.R030FIL.CodFil "
	cQuery  += "LEFT JOIN bk_senior.bk_senior.R016HIE ON bk_senior.bk_senior.R016HIE.NumLoc =bk_senior.bk_senior.r034fun.numloc "
	cQuery  += "WHERE bk_senior.bk_senior.r034fun.tipcol ='1' "
	cQuery  += "AND bk_senior.bk_senior.r034fun.numemp='"+SM0->M0_CODIGO+"' "
	//VERIFICA CONSIGNADO
	IF SUBSTR(cTipoNF,1,2) == "CS"
		cQuery  += "AND bk_senior.bk_senior.r034fun.numcpf='"+aItemLinha[nX,1]+"'" 
	ELSE
		cQuery  += "AND bk_senior.bk_senior.r034fun.numcad='"+aItemLinha[nX,1]+"'" 
	ENDIF


			
	TCQUERY cQuery NEW ALIAS "QTB"
			
	DbSelectArea("QTB")

	cQTBCC := ''
	cQTBCC := QTB->CCSiga
	
	//IF QTB->cFil == '034'
	//   cQTBCC := "008"+cLoc+cFil
	//ELSEIF QTB->cFil == '026'
	   //Centro de Custo BK
	//   cQTBCC := '000000001'
	//ELSE
	//   cQTBCC := '000'+cFil
	//ENDIF
	
	QTB->(dbCloseArea())
	
	//cQuery := "SELECT CTT_CUSTO,CTT_DESC01 FROM "+RETSQLNAME("CTT")+" WHERE "+IIF(LEN(cQTBCC)>6,"CTT_CUSTO","substring(CTT_CUSTO,4,6)")+" = '"+cQTBCC+"' AND D_E_L_E_T_ <> '*' "
	cQuery := "SELECT CTT_CUSTO,CTT_DESC01 FROM "+RETSQLNAME("CTT")+" WHERE CTT_CUSTO = '"+cQTBCC+"' AND D_E_L_E_T_ <> '*' "

	TCQUERY cQuery NEW ALIAS "QCTT"
	DbSelectArea("QCTT")

    nScan:= 0
    nScan:= aScan(aItemCC,{|x| x[2] == QCTT->CTT_CUSTO })
    IF nScan == 0
		AADD(aItemCC,{cProduto,QCTT->CTT_CUSTO,QCTT->CTT_DESC01,aItemLinha[nX,2]})
	ELSE
	    aItemCC[nScan,4] += aItemLinha[nX,2]
	ENDIF
	
	IF EMPTY(QCTT->CTT_CUSTO)
	   AADD(aSemCC,{aItemLinha[nX,1],aItemLinha[nX,2]})
	ENDIF
	aLINHAxx[nX,4] := QCTT->CTT_CUSTO

	QCTT->(dbCloseArea())

NEXT

/*
IF LEN(aLINHAxx) > 0

	nHandle := MsfCreate(u_LTmpDir()+"VTOUTU.CSV",0)
   
	If nHandle > 0
      
   		FOR _ni := 1 TO LEN(aLINHAxx)
      		fWrite(nHandle, aLINHAxx[_ni,1]+";"+STR(aLINHAxx[_ni,2],10,2)+";"+STR(aLINHAxx[_ni,3],10,2)+";"+aLINHAxx[_ni,4]+Chr(13) + Chr(10))
   		NEXT
   		fClose(nHandle) 
	ENDIF

ENDIF
*/

IF LEN(aItemCC) > 0

	ASORT(aItemCC,,,{|x,y| x[2]<y[2]})

    // Calcula Valor Maximo para Rateio
    nScan   := 0
    nMAXRAT := 0
    nScan   := aScan(aValida,{|x| x[1] == SUBSTR(cTipoNF,1,2) })
    nMAXRAT := nValor*(VAL(aValida[nScan,2])*0.01)

    IF (nValor - nTotal) > nMAXRAT
		u_MsgLog(cProg,"Valor do rateio maior que valor maximo verifique Par�metros Tabela X5 - Z3, Valor Total para Rateio: "+STR((nValor - nTotal),10,2)+"   Valor M�ximo:"+STR(nMAXRAT,10,2), "E")
 	    RETURN NIL    
    ENDIF
    
		
	IF Len(aSemCC) > 0
    	cCodFunc := ""   
    	FOR nX := 1 to Len(aSemCC)
       		cCodFunc +=  "CodFun:  "+Alltrim(aSemCC[nX,1])+"  Valor:  "+STR(aSemCC[nX,2],14,2)+CHR(13)+CHR(10)
    	NEXT nX
		u_MsgLog(cProg,"C�digo(s) de Funcion�rio(s) n�o possuem Centro de Custo: "+CHR(13)+CHR(10)+cCodFunc, "W" )
	ENDIF

	
	IF TRANSFORM(nTotal,"@E 999,999,999.99") <> TRANSFORM(nValor,"@E 999,999,999.99")
	   u_MsgLog(cProg,"Valor total da NF diferente do valor calculado favor verificar: "+TRANSFORM(nValor,"@E 999,999,999.99")+"     "+TRANSFORM(nTotal,"@E 999,999,999.99"),"E")
 	   RETURN NIL
	ENDIF

    Define MsDialog oDlg01 Title "Confirmar Itens da NF" From 000,000 To 450,600 Of oDlg01 Pixel
	
	@ 000,000 MSPANEL oPanelLeft OF oDlg01 SIZE 430,600 
	oPanelLeft:Align := CONTROL_ALIGN_LEFT
	
	@ nSnd,010 Say "N�mero" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,045 MsGet oNumNF VAR cDoc Picture '@!' Size 040,010 Pixel OF oPanelLeft WHEN .F.
	
	@ nSnd,090 Say "S�rie" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,125 MsGet cSerie Picture '@!' Size 008,010 Pixel OF oPanelLeft WHEN .F.
	
	@ nSnd,185 Say "DT Emiss�o" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,230 MsGet dEmissao Picture "@E"  Size 040,010 Pixel OF oPanelLeft WHEN .F.
	nSnd += nTLin
	
	@ nSnd,010 SAY "Fornecedor" SIZE 080,010 Pixel OF oPanelLeft
	@ nSnd,045 MsGet oForn VAR cForn SIZE 040,010 OF oPanelLeft PIXEL PICTURE '@!' WHEN .F.
	
	@ nSnd,090 Say "Loja" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,125 MsGet cLoja Picture '@!' Size 008,010 Pixel OF oPanelLeft WHEN .F.
	
	@ nSnd,185 Say "Espec. Docum." Size 080,010 Pixel OF oPanelLeft
	@ nSnd,230 MsGet cEspec SIZE 040,010 OF oPanelLeft PIXEL PICTURE '@!' WHEN .F.
	
	nSnd += nTLin
	
	@ nSnd,010 Say "Uf.Origem" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,045 MsGet cUF Picture '@!' Size 008,010 OF oPanelLeft PIXEL PICTURE '@!' WHEN .F.
	
	@ nSnd,090 Say "Produto"  Size 080,010 Pixel OF oPanelLeft
	@ nSnd,125 MsGet cProduto SIZE 060,010 OF oPanelLeft PIXEL PICTURE '@!' WHEN .F.
	
	@ nSnd,185 Say "Valor da NF" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,230 MsGet nValor Picture "@E 999,999,999,999.99" Size 060,010 Pixel OF oPanelLeft WHEN .F.
	nSnd += nTLin
	
	@ nSnd,010 SAY 'Tipo'   SIZE 080,010 OF oPanelLeft PIXEL
	@ nSnd,045 COMBOBOX cTipoNF  ITEMS aTipoNF SIZE 100,010 Pixel OF oPanelLeft WHEN .F.
	nSnd += nTLin
	
	@ nSnd,010  SAY "Arquivo " OF oPanelLeft PIXEL // "Objeto "
	@ nSnd,045  MsGet cArq SIZE 130,010 OF oPanelLeft PIXEL READONLY WHEN .F.

	@ nSnd,185 SAY 'NF Complementar'   SIZE 080,010 OF oPanelLeft PIXEL
	@ nSnd,230 COMBOBOX cCompl  ITEMS aCompl SIZE 060,010 Pixel OF oPanelLeft WHEN .F.
	
	nSnd += nTLin
	
	@ nSnd, 005 LISTBOX oListID FIELDS HEADER "Cod. Produto","Custo","Valor R$","Descri��o" SIZE 290,085  OF oPanelLeft PIXEL 
	
	oListID:SetArray(aItemCC)
	oListID:bLine := {|| {	aItemCC[oListId:nAt][1],;
							aItemCC[oListId:nAt][2],;
							TRANSFORM(aItemCC[oListId:nAt][4],"@E 999,999,999.99"),;
							aItemCC[oListId:nAt][3]}}
	
	
	ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)

	If ( lOk )
		lOk:=.F.
		u_WaitLog(cProg, {|| IncluiNF(aItemCC)}, 'Incluido Pr�-Documento de Entrada')
	Endif
ENDIF
RETURN NIL



Static Function ValidaNF()
LOCAL lOk	:=.T.
LOCAL aArq 	:= {}
Local nX	:= 0

aArq:= StrTokArr(cArq,"\")

IF LEN(aArq) > 0
    cDir := ''
    FOR nX := 1 TO LEN(aArq)-1
    	cDir += UPPER(aArq[nX])+"\"
    NEXT
    GrvMVARQ()
ENDIF

IF EMPTY(cDoc) .OR. cDoc == '000000000'
	u_MsgLog(cProg,"N�mero do Pr�-Documento de Entrada incorreto", "E")
	lOk:= .F.
    RETURN lOk 
Endif
   
IF EMPTY(cForn)
	u_MsgLog(cProg,"N�mero do Fornecedor incorreto", "E")
	lOk:= .F.
    RETURN lOk 
Endif

IF EMPTY(cEspec)
	u_MsgLog(cProg,"Esp�cie do Pr�-Documento de Entrada incorreto", "E")
	lOk:= .F.
    RETURN lOk 
Endif

IF EMPTY(cUF)
	u_MsgLog(cProg,"UF do Pr�-Documento de Entrada incorreto", "E")
	lOk:= .F.
    RETURN lOk 
Endif

IF EMPTY(cProduto)
	u_MsgLog(cProg,"Produto do Pr�-Documento de Entrada incorreto", "E")
	lOk:= .F.
    RETURN lOk 
Endif

IF nValor <= 0
	u_MsgLog(cProg,"Valor do Pr�-Documento de Entrada incorreto", "E")
	lOk:= .F.
    RETURN lOk 
Endif

IF EMPTY(cTipoNF)
	u_MsgLog(cProg,"Tipo do Pr�-Documento de Entrada incorreto", "E")
	lOk:= .F.
    RETURN lOk 
Endif

IF EMPTY(cArq)  .And. SUBSTR(cTipoNF,1,2) <> "AS"
	u_MsgLog(cProg,"Arquivo de importa��o de rateio do Pr�-Documento de Entrada incorreto", "E")
	lOk:= .F.
    RETURN lOk 
Endif

DbSelectArea("SF1")
SET ORDER TO 1
IF SF1->(dbSeek(xFilial("SF1")+cDoc+cSerie+cForn+cLoja+"N",.F.))
	u_MsgLog(cProg,"Pr�-Documento de Entrada j� Existe", "E")
	lOk:= .F.
    RETURN lOk 
Endif

IF !EMPTY(cProduto)
    nScan:= 0
    nScan:= aScan(aValida,{|x| x[1] == SUBSTR(cTipoNF,1,2) })
    IF nScan == 0
		u_MsgLog(cProg,"Produto do Pr�-Documento de Entrada incorreto", "E")
		lOk:= .F.
		RETURN lOk 
    ELSEIF ALLTRIM(cProduto) $ ALLTRIM(aValida[nScan,3])
		lOk:= .T.
    ELSE
		u_MsgLog(cProg,"Produto do Pr�-Documento de Entrada incorreto", "E")
		lOk:= .F.
    	RETURN lOk 
    ENDIF
ENDIF

IF LEN(aArq) > 0 .And. SUBSTR(cTipoNF,1,2) <> "AS"
	nArq := 0
	nArq := LEN(aArq)
	cNomeArq := ''
	cNomeArq := UPPER(aArq[nArq])
	IF !(SUBSTR(cTipoNF,1,2) $ cNomeArq)
	    u_MsgLog(cProg,"Arquivo de importa��o de rateio do Pr�-Documento de Entrada incorreto, verifique a exten��o do arquivo", "E")
		lOk:= .F.
    ENDIF
ENDIF

RETURN lOk 


Static function IncluiNF(aItemCC)
Local aCabec 	:= {}, aLinha := {}, aItens := {}
Local nX		:= 0
Local nItem		:= 0
Local lRet		:= .T.

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.
Private aAutoErro 	:= {}

ASORT(aItemCC,,,{|x,y| x[2]<y[2]})

aadd(aCabec,{"F1_FILIAL ",xFilial("SF1")})
aadd(aCabec,{"F1_TIPO"   ,"N"})
aadd(aCabec,{"F1_FORMUL" ,"N"})
aadd(aCabec,{"F1_DOC"    ,ALLTRIM(cDoc)})
aadd(aCabec,{"F1_SERIE"  ,ALLTRIM(cSerie)})
aadd(aCabec,{"F1_EMISSAO",dEmissao})
aadd(aCabec,{"F1_FORNECE",cForn})
aadd(aCabec,{"F1_LOJA"   ,cLoja})
aadd(aCabec,{"F1_ESPECIE",cEspec})
aadd(aCabec,{"F1_EST",cUF})
If SUBSTR(cTipoNF,1,2) == "CS"
	aadd(aCabec,{"F1_COND","000"})
	aadd(aCabec,{"F1_XXPVPGT",dDataBase})
EndIf

//Gera num randomico para diferenca de casas decimais
IF LEN(aItemCC) > 1
	nItem := Randomize( 1, LEN(aItemCC) )
ELSE
	nItem := 0
ENDIF

//Carrega valores 
nTotal := 0
For nX := 1 To LEN(aItemCC)
	IF nItem <> nX .AND. !EMPTY(aItemCC[nX,1])
		aLinha := {}
		aadd(aLinha,{"D1_FILIAL ",xFilial("SD1")})
		aadd(aLinha,{"D1_COD"  ,aItemCC[nX,1],Nil})
		aadd(aLinha,{"D1_QUANT",1,Nil})
		aadd(aLinha,{"D1_VUNIT",VAL(STR(aItemCC[nX,4],18,2)),Nil})
		aadd(aLinha,{"D1_TOTAL",VAL(STR(aItemCC[nX,4],18,2)),Nil})
		aadd(aLinha,{"D1_CC",aItemCC[nX,2],Nil})
		aadd(aLinha,{"D1_XXHIST",ALLTRIM(cHist),Nil})
		aadd(aItens,aLinha)
	ENDIF
	nTotal += VAL(STR(aItemCC[nX,4],18,2))	
Next nX

IF nItem > 0
    nDifRat := 0
    nDifRat := nValor - nTotal
	aLinha := {}
	aadd(aLinha,{"D1_FILIAL ",xFilial("SD1")})
	aadd(aLinha,{"D1_COD"  ,aItemCC[nItem,1],Nil})
	aadd(aLinha,{"D1_QUANT",1,Nil})
	aadd(aLinha,{"D1_VUNIT",VAL(STR(aItemCC[nItem,4]+nDifRat,18,2)),Nil})
	aadd(aLinha,{"D1_TOTAL",VAL(STR(aItemCC[nItem,4]+nDifRat,18,2)),Nil})
	aadd(aLinha,{"D1_CC",aItemCC[nItem,2],Nil})
	aadd(aLinha,{"D1_XXHIST",cHist,Nil})
	aadd(aItens,aLinha)
ENDIF

// Inclusao da Pre Nota
Begin Transaction
	
	nOpc := 3
 	MSExecAuto({|x,y,z| MATA140(x,y,z)}, aCabec, aItens, nOpc,.T.)   
	IF lMsErroAuto
		u_LogMsExec(cProg,"Problemas no Pr�-Documento de Entrada "+cDoc+" "+cSerie)
		DisarmTransaction()
		lRet := .F.
	Else
		u_MsgLog(cProg,"Pr�-Documento de Entrada incluido com sucesso! "+cDoc+" "+cSerie,"S")
	EndIf

End Transaction

Return lRet
                         
                         
Static Function GrvMVARQ()

// Grava o Diretorio do ultimo arquivo selecionado
If UPPER(ALLTRIM(U_BKGetMv("BKCOMA03DR"))) <> UPPER(ALLTRIM(cDir))
	U_BKPutMv("BKCOMA03DR",UPPER(ALLTRIM(cDir)),"C",70,0,"Diretorio do ultimo arquivo selecionado")	
EndIf

RETURN NIL


Static Function MontaPlaAS()
//Local nSnd  := 15
Local oDlgAS,nOpcA := 0
Local aPlanos:= {}
Local cPlano:= ""

cQueryPLA := "SELECT DISTINCT bk_senior.bk_senior.R032OEM.CodOem,bk_senior.bk_senior.R032OEM.NomOem "
cQueryPLA += "FROM bk_senior.bk_senior.R164PLA " 
cQueryPLA += "INNER JOIN bk_senior.bk_senior.R032OEM ON bk_senior.bk_senior.R164PLA.CodOem = bk_senior.bk_senior.R032OEM.CodOem "
cQueryPLA += "ORDER BY bk_senior.bk_senior.R032OEM.NomOem"

AADD(aPlanos,"")

TCQUERY cQueryPLA NEW ALIAS "QPLA"
DbSelectArea("QPLA")
QPLA->(dbGoTop())
DO WHILE !EOF()
	AADD(aPlanos,STRZERO(QPLA->CodOem,6)+" - "+ALLTRIM(QPLA->NomOem))
	QPLA->(DBSKIP())
ENDDO
QPLA->(dbCloseArea())

DEFINE MSDIALOG oDlgAS FROM  96,9 TO 200,592 TITLE OemToAnsi("Selecionar Plano - BS Rubi") PIXEL

@ 10,10 SAY 'planos:'   SIZE 50,10 OF oDlgAS PIXEL
@ 10,65 COMBOBOX cPlano  ITEMS aPlanos SIZE 200,50 OF oDlgAS PIXEL

DEFINE SBUTTON FROM 40, 223 TYPE 1 ACTION (oDlgAS:End(),nOpcA:=1) ENABLE OF oDlgAS
DEFINE SBUTTON FROM 40, 253 TYPE 2 ACTION (oDlgAS:End(),nOpcA:=0) ENABLE OF oDlgAS
ACTIVATE MSDIALOG oDlgAS CENTER Valid(ValidaAS(cPlano))


If nOpcA == 1
	nOpcA := 0
	// Faz Processamento
	MontaItemAS(cPlano)

Endif
Return NIL

Static Function ValidaAS(cPlano)
LOCAL lOk:=.T.

IF VAL(SUBSTR(cPlano,1,6)) < 1 
	u_MsgLog(cProg,"Plano BS Rubi incorreto"+cPlano,"E")
	lOk:= .F.
    RETURN lOk 
Endif

RETURN lOk



Static Function MontaItemAS(cPlano)
Local nSnd  := 15,nTLin := 15,_i:=0
Local oDlg01,aButtons := {}
LOCAL lOk := .F.
LOCAL cQuery1:=''
//LOCAL aX5 := {}
LOCAL aItemAS:={}

cQuery1  := "SELECT * from bk_senior.dbo.BK_vw_MicrosigaBSTitular " 
cQuery1  += "WHERE CodOem='"+ALLTRIM(STR(VAL(SUBSTR(cPlano,1,6)),6))+"' "
cQuery1  += "AND cEmp='"+cEmpAnt+"' "
cQuery1  += "ORDER BY nomfun"

TCQUERY cQuery1 NEW ALIAS "QTPA"

nOrdem  := 0
DbSelectArea("QTPA")
//ProcRegua(QTPA->(LastRec()))
QTPA->(DbGotop())
DO WHILE !EOF()
	//IncProc('Incluindo Itens Plano - BS Rubi')

	cQTPACC := ''
	IF QTPA->cFil == '034'
	   cQTPACC := "008"+cLoc+cFil
	ELSEIF QTPA->cFil == '026'
	   //Centro de Custo BK
	   cQTPACC := '000000001'
	ELSE
	   cQTPACC := '000'+cFil
	ENDIF
    ++nOrdem
	AADD(aItemAS,{QTPA->numcad,QTPA->nomfun,QTPA->DesSit,cQTPACC,QTPA->NomFil,QTPA->TotTit,QTPA->cEmp,QTPA->tipcol,QTPA->numcad,QTPA->CodOem,nOrdem})
	
	QTPA->(DbSkip())

ENDDO 	
QTPA->(dbCloseArea())


IF LEN(aItemAS) > 0

	aItemDep:= {}
	aItemDep:= ItemDep(cPlano,aItemAS)

	FOR _i:=1 to LEN(aItemDep)
    	AADD(aItemAS,aItemDep[_i])
	NEXT
    nTotPlan := 0
	FOR _i:=1 to LEN(aItemAS)
	    aCusto := {}
	    aCusto := ItemCusto(aItemAS[_i,4])

    	aItemAS[_i,4] := aCusto[1,1]
    	aItemAS[_i,5] := aCusto[1,2]
    	nTotPlan += aItemAS[_i,6]
	NEXT
	
	ASORT(aItemAS,,,{|x,y| x[11]<y[11]})

	IF TRANSFORM(nTotPlan,"@E 999,999,999.99") <> TRANSFORM(nValor,"@E 999,999,999.99")
	   u_MsgLog(cProg,"Valor total da NF diferente do valor total do plano: "+TRANSFORM(nValor,"@E 999,999,999.99")+"     "+TRANSFORM(nTotPlan,"@E 999,999,999.99"),"E")
	ENDIF
	

    Define MsDialog oDlg01 Title "Confirmar Itens da NF" From 000,000 To 450,600 Of oDlg01 Pixel
	
	@ 000,000 MSPANEL oPanelLeft OF oDlg01 SIZE 430,600 
	oPanelLeft:Align := CONTROL_ALIGN_LEFT
	
	@ nSnd,010 Say "N�mero" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,045 MsGet oNumNF VAR cDoc Picture '@!' Size 040,010 Pixel OF oPanelLeft WHEN .F.
	
	@ nSnd,090 Say "S�rie" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,125 MsGet cSerie Picture '@!' Size 008,010 Pixel OF oPanelLeft WHEN .F.
	
	@ nSnd,185 Say "DT Emiss�o" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,230 MsGet dEmissao Picture "@E"  Size 040,010 Pixel OF oPanelLeft WHEN .F.
	nSnd += nTLin
	
	@ nSnd,010 SAY "Fornecedor" SIZE 080,010 Pixel OF oPanelLeft
	@ nSnd,045 MsGet oForn VAR cForn SIZE 040,010 OF oPanelLeft PIXEL PICTURE '@!' WHEN .F.
	
	@ nSnd,090 Say "Loja" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,125 MsGet cLoja Picture '@!' Size 008,010 Pixel OF oPanelLeft WHEN .F.
	
	@ nSnd,185 Say "Espec. Docum." Size 080,010 Pixel OF oPanelLeft
	@ nSnd,230 MsGet cEspec SIZE 040,010 OF oPanelLeft PIXEL PICTURE '@!' WHEN .F.
	
	nSnd += nTLin
	
	@ nSnd,010 Say "Uf.Origem" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,045 MsGet cUF Picture '@!' Size 008,010 OF oPanelLeft PIXEL PICTURE '@!' WHEN .F.
	
	@ nSnd,090 Say "Produto"  Size 080,010 Pixel OF oPanelLeft
	@ nSnd,125 MsGet cProduto SIZE 060,010 OF oPanelLeft PIXEL PICTURE '@!' WHEN .F.
	
	@ nSnd,185 Say "Valor da NF" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,230 MsGet nValor Picture "@E 999,999,999,999.99" Size 060,010 Pixel OF oPanelLeft WHEN .F.
	nSnd += nTLin
	
	@ nSnd,010 SAY 'Tipo'   SIZE 080,010 OF oPanelLeft PIXEL
	@ nSnd,045 COMBOBOX cTipoNF  ITEMS aTipoNF SIZE 100,010 Pixel OF oPanelLeft WHEN .F.

	@ nSnd,185 Say "Valor Tot. Plano"                Size 080,010 Pixel OF oPanelLeft
	@ nSnd,230 MsGet nTotPlan Picture "@E 999,999,999,999.99" Size 060,010 Pixel OF oPanelLeft WHEN .F.
	
	nSnd += nTLin

	@ nSnd,185 SAY 'NF Complementar'   SIZE 080,010 OF oPanelLeft PIXEL
	@ nSnd,230 COMBOBOX cCompl  ITEMS aCompl SIZE 060,010 Pixel OF oPanelLeft WHEN .F.

	nSnd += nTLin
	
	
	@ nSnd, 005 LISTBOX oListID FIELDS HEADER "Cod. Func.","Nome Func.","Sit. Func.","CC","Descri��o","Valor Plano" SIZE 290,085  OF oPanelLeft PIXEL 

	oListID:SetArray(aItemAS)
	oListID:bLine := {|| {	aItemAS[oListId:nAt][1],;
							aItemAS[oListId:nAt][2],;
							aItemAS[oListId:nAt][3],;
							aItemAS[oListId:nAt][4],;
							aItemAS[oListId:nAt][5],;
							TRANSFORM(aItemAS[oListId:nAt][6],"@E 999,999,999.99"),}}
	
	
	ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F.,oDlg01:End()}, , aButtons) Valid(ValidaBS())

	If ( lOk )
	   lOk:=.F.
       MontaBS(aItemAS)
	Endif
ENDIF
RETURN NIL



STATIC FUNCTION ValidaBS()
LOCAL ok := .T.
IF TRANSFORM(nTotPlan,"@E 999,999,999.99") <> TRANSFORM(nValor,"@E 999,999,999.99")
	u_MsgLog(cProg,"Valor total da NF diferente do valor total do plano: "+TRANSFORM(nTotPlan,"@E 999,999,999.99")+"     "+TRANSFORM(nValor,"@E 999,999,999.99"),"E")
  	ok := .F.
ENDIF
RETURN ok 


STATIC FUNCTION ItemCusto(cQTPACC)
LOCAL cQuery2 := ""

cQuery2 := "SELECT CTT_CUSTO,CTT_DESC01 FROM "+RETSQLNAME("CTT")+" WHERE "+IIF(LEN(cQTPACC)>6,"CTT_CUSTO","substring(CTT_CUSTO,4,6)")+" = '"+cQTPACC+"' AND D_E_L_E_T_ <> '*' "
	
TCQUERY cQuery2 NEW ALIAS "QYCTT"
DbSelectArea("QYCTT")
	
AADD(aCusto,{QYCTT->CTT_CUSTO,QYCTT->CTT_DESC01})
	
QYCTT->(dbCloseArea())

RETURN  aCusto



STATIC FUNCTION ItemDep(cPlano,aItemAS)
LOCAL cQuery1  :=""
LOCAL aItemDep := {}

cQuery1  := "SELECT * from bk_senior.dbo.BK_vw_MicrosigaBSDep " 
cQuery1  += "WHERE CodOem='"+ALLTRIM(STR(VAL(SUBSTR(cPlano,1,6)),6))+"' "
cQuery1  += "AND cEmp='"+SM0->M0_CODIGO+"' "
cQuery1  += "ORDER BY nomfun"
	
TCQUERY cQuery1 NEW ALIAS "QTPA"

nTotal  := 0
DbSelectArea("QTPA")
//ProcRegua(QTPA->(LastRec()))
QTPA->(DbGotop())
DO WHILE !EOF()
	//IncProc('Incluido Itens Plano - BS Rubi')

	cQTPACC := ''
	IF QTPA->cFil == '034'
	   cQTPACC := "008"+cLoc+cFil
	ELSEIF QTPA->cFil == '026'
	   //Centro de Custo BK
	   cQTPACC := '000000001'
	ELSE
	   cQTPACC := '000'+cFil
	ENDIF
    nOrdem := 0
    nScan:= 0
    nScan:= aScan(aItemAS,{|x| x[1] == QTPA->numcad })
    IF nScan > 0
    	nOrdem := aItemAS[nScan,11] + 0.9
    ELSE
    	nOrdem := 999999
    ENDIF    
	AADD(aItemDep,{QTPA->numcad,QTPA->NomDep,"Dependente",cQTPACC,QTPA->NomFil,QTPA->TotDpl,QTPA->cEmp,QTPA->tipcol,QTPA->numcad,QTPA->CodOem,nOrdem})
	
	QTPA->(DbSkip())

ENDDO 	
QTPA->(dbCloseArea())

RETURN  aItemDep


Static Function MontaBS(aItemAS)
Local nSnd  := 15,nTLin := 15
Local oDlg01,aButtons := {}
LOCAL nX
LOCAL lOk := .F.
LOCAL nTotal:=0
LOCAL aItemCC:={}

//Procregua(LEN(aItemAS))
aItemCC := {}
aSemCC  := {}
nTotal  := 0

For nX := 1 To LEN(aItemAS)
	//IncProc('Carregando Itens da NF')
	nTotal += aItemAS[nX,6]

    nScan:= 0
    nScan:= aScan(aItemCC,{|x| x[2] == ALLTRIM(aItemAS[nX,4]) })
    IF nScan == 0
		AADD(aItemCC,{cProduto,ALLTRIM(aItemAS[nX,4]),ALLTRIM(aItemAS[nX,5]),aItemAS[nX,6]})
	ELSE
	    aItemCC[nScan,4] += aItemAS[nX,6]
	ENDIF
	
	IF EMPTY(ALLTRIM(aItemAS[nX,5])) 
	   AADD(aSemCC,{STR(aItemAS[nX,1],6),aItemAS[nX,6]})
	ENDIF
	
NEXT

IF LEN(aItemCC) > 0

	ASORT(aItemCC,,,{|x,y| x[2]<y[2]})

	IF Len(aSemCC) > 0
    	cCodFunc := ""   
    	FOR nX := 1 to Len(aSemCC)
       		cCodFunc +=  "CodFun:  "+Alltrim(aSemCC[nX,1])+"  Valor:  "+STR(aSemCC[nX,2],14,2)+CHR(13)+CHR(10)
    	NEXT nX
		u_MsgLog(cProg,"Codigo Funcion�rio(s) n�o possui Centro de Custo: "+cCodFunc,"W" )
	ENDIF

	
	IF TRANSFORM(nTotal,"@E 999,999,999.99") <> TRANSFORM(nValor,"@E 999,999,999.99")
	   u_MsgLog(cProg,"Valor total da NF diferente do valor calculado favor verificar: "+TRANSFORM(nValor,"@E 999,999,999.99")+"     "+TRANSFORM(nTotal,"@E 999,999,999.99"),"E")
	ENDIF

    Define MsDialog oDlg01 Title "Confirmar Itens da NF" From 000,000 To 450,600 Of oDlg01 Pixel
	
	@ 000,000 MSPANEL oPanelLeft OF oDlg01 SIZE 430,600 
	oPanelLeft:Align := CONTROL_ALIGN_LEFT
	
	@ nSnd,010 Say "N�mero" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,045 MsGet oNumNF VAR cDoc Picture '@!' Size 040,010 Pixel OF oPanelLeft WHEN .F.
	
	@ nSnd,090 Say "S�rie" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,125 MsGet cSerie Picture '@!' Size 008,010 Pixel OF oPanelLeft WHEN .F.
	
	@ nSnd,185 Say "DT Emiss�o" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,230 MsGet dEmissao Picture "@E"  Size 040,010 Pixel OF oPanelLeft WHEN .F.
	nSnd += nTLin
	
	@ nSnd,010 SAY "Fornecedor" SIZE 080,010 Pixel OF oPanelLeft
	@ nSnd,045 MSGET oForn VAR cForn SIZE 040,010 OF oPanelLeft PIXEL PICTURE '@!' WHEN .F.
	
	@ nSnd,090 Say "Loja" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,125 MsGet cLoja Picture '@!' Size 008,010 Pixel OF oPanelLeft WHEN .F.
	
	@ nSnd,185 Say "Espec. Docum." Size 080,010 Pixel OF oPanelLeft
	@ nSnd,230 MSGET cEspec SIZE 040,010 OF oPanelLeft PIXEL PICTURE '@!' WHEN .F.
	
	nSnd += nTLin
	
	@ nSnd,010 Say "Uf.Origem" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,045 MsGet cUF Picture '@!' Size 008,010 OF oPanelLeft PIXEL PICTURE '@!' WHEN .F.
	
	@ nSnd,090 Say "Produto"  Size 080,010 Pixel OF oPanelLeft
	@ nSnd,125 MSGET cProduto SIZE 060,010 OF oPanelLeft PIXEL PICTURE '@!' WHEN .F.
	
	@ nSnd,185 Say "Valor da NF" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,230 MsGet nValor Picture "@E 999,999,999,999.99" Size 060,010 Pixel OF oPanelLeft WHEN .F.
	nSnd += nTLin
	
	@ nSnd,010 SAY 'Tipo'   SIZE 080,010 OF oPanelLeft PIXEL
	@ nSnd,045 COMBOBOX cTipoNF  ITEMS aTipoNF SIZE 100,010 Pixel OF oPanelLeft WHEN .F.

	nSnd += nTLin
	
	@ nSnd,010  SAY "Arquivo " OF oPanelLeft PIXEL // "Objeto "
	@ nSnd,045  MSGET cArq SIZE 130,010 OF oPanelLeft PIXEL READONLY WHEN .F.

	@ nSnd,185 SAY 'NF Complementar'   SIZE 080,010 OF oPanelLeft PIXEL
	@ nSnd,230 COMBOBOX cCompl  ITEMS aCompl SIZE 060,010 Pixel OF oPanelLeft WHEN .F.
	
	nSnd += nTLin
	
	@ nSnd, 005 LISTBOX oListID FIELDS HEADER "Cod. Produto","Custo","Valor R$","Descri��o" SIZE 290,085  OF oPanelLeft PIXEL 
	
	oListID:SetArray(aItemCC)
	oListID:bLine := {|| {	aItemCC[oListId:nAt][1],;
							aItemCC[oListId:nAt][2],;
							TRANSFORM(aItemCC[oListId:nAt][4],"@E 999,999,999.99"),;
							aItemCC[oListId:nAt][3]}}
	
	
	ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons) VALID(ValidaInNF(nTotal))
	
	
	If ( lOk )
		lOk:=.F.
		u_WaitLog(cProg, {|| IncluiNF(aItemCC)}, 'Incluido Pr�-Documento de Entrada')
	Endif
ENDIF
RETURN NIL

STATIC FUNCTION ValidaInNF(nTotal)
LOCAL ok := .T.

IF TRANSFORM(nTotal,"@E 999,999,999.99") <> TRANSFORM(nValor,"@E 999,999,999.99")
	u_MsgLog(cProg,"Valor total da NF diferente do valor calculado favor verificar: "+TRANSFORM(nValor,"@E 999,999,999.99")+"     "+TRANSFORM(nTotal,"@E 999,999,999.99"),"E")
  	ok := .F.
ENDIF

RETURN ok
