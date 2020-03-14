#include "totvs.ch"
#include "protheus.ch"
#include "TopConn.ch"
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BKGCTA17   บ Autor ณ Adilson do Prado   บ Data ณ  02/02/16 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para montar a tela de edi็ใo de cadastro de         บฑฑ
ฑฑบ          ณ Itens Proje็ใo Financeira dos contratos                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BK                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function BKGCTA17(cContrat,cTipo)
Local lOk       := .F.
Local cTITULO2  := IIF(cTipo=="01","Benefํcios","Gastos Gerais")+" - Cadastro Itens da Proje็ใo Financeira do Contrato"
 
PRIVATE aSZL  := {}
PRIVATE oDlg2 
PRIVATE oPanelLeft2
PRIVATE oListID2
PRIVATE oSay1
PRIVATE oSay2
PRIVATE nTotInt := 0
PRIVATE oBDesc2
PRIVATE cBDesc2	:= SPACE(60)
PRIVATE cTipoZG   := cTipo



//BUSCA ITENS DA PROJEวรO FINANCEIRA POR TIPO
IF cTipo == "01"
	aSZL := {} 
	aSZL := aSZL01
 	FOR _nx := 1 to LEN(aSZL01)
		nTotInt += aSZL01[_nx,3]
  	NEXT
ELSEIF cTipo == "02"
	aSZL := {} 
	aSZL := aSZL02
 	FOR _nx := 1 to LEN(aSZL02)
		nTotInt += aSZL02[_nx,3]
	NEXT
ENDIF

IF LEN(aSZL) == 0
	AADD(aSZL,{SPACE(15),SPACE(30),0})
ENDIF

//ORDENAR POR DESCRIวรO
Asort(aSZL,,,{|x,y| x[2]<y[2]})

DEFINE MSDIALOG oDlg2 TITLE cTitulo2 FROM 000,000 TO 400,700 PIXEL 

@ 000,000 MSPANEL oPanelLeft2 OF oDlg2 SIZE 350,200


@ 005, 052 Say  oSay1 Prompt "Descri็ใo:" Size  80, 10 OF oPanelLeft2 Pixel
@ 005, 080 MSGet oBDesc2 VAR cBDesc2 OF oPanelLeft2 SIZE 140, 010 PIXEL Picture "@!"

TButton():New(005,225,'Pesquisar',oPanelLeft3,{|| BuscaSZL() },40,10,,,,.T.)  

@ 020, 005 LISTBOX oListID2 FIELDS HEADER "Codigo","Descri็ใo","Valor" SIZE 340,160 OF oPanelLeft2 PIXEL 
oListID2:SetArray(aSZL)
oListID2:bLine := {|| {       aSZL[oListId2:nAt][1],;
					          aSZL[oListId2:nAt][2],;
					Transform(aSZL[oListId2:nAt][3],'@E 99,999,999,999.99')}}  

oListID2:bLDblClick := {|| EDITSZL(@aSZL) ,SomaSZL(aSZL),oListID2:DrawSelect(), }


@ 180,005 SAY oSay2 PROMPT "Total: "+TRANSFORM(nTotInt,"@E 999,999,999.99") SIZE 250, 10 OF oPanelLeft2 PIXEL

//TButton():New(185,100,'&Alterar',oDlg2,{|| AltInclSZL(oListID2:nAt,4) },40,10,,,,.T.)

TButton():New(185,080,'&Selecionar Prod.',oDlg2,{|| U_SelcSZL(cTipo) },60,10,,,,.T.)

TButton():New(185,150,'&Incluir',oDlg2,{|| AltInclSZL(oListID2:nAt,3) },40,10,,,,.T.)

TButton():New(185,200,'&Excluir',oDlg2,{|| ExcSZL(oListID2:nAt) },40,10,,,,.T.)

TButton():New(185,250,'&Fechar',oDlg2,{|| oDlg2:End(),lok:= .T.},40,10,,,,.T.)

ACTIVATE MSDIALOG oDlg2 CENTERED Valid(IIF(lAlterad,MsgYesNo("Confimar altera็ใo?"),.T.)) 

If ( lOk )
	lOk:=.F.

	nTotInt := 0

	FOR _IX := 1 TO LEN(aSZL)
   		nTotInt += aSZL[_IX,3]
	NEXT

	IF cTipo == "01"
		aSZL01 := {}
		aSZL01 := aSZL 
	ELSEIF cTipo == "02"
		aSZL02 := {}
		aSZL02 := aSZL 
	ENDIF

ENDIF

RETURN nTotInt


STATIC FUNCTION BuscaSZL()
    nScan:= 0
    nScan:= aScan(aSZL,{|x| x[2]>= ALLTRIM(cBDesc2) })
    IF nScan > 0
		oListId2:nAt := nScan
    ELSE
    	MSGINFO("Nใo encontrado!!")
    ENDIF 
RETURN NIL



STATIC FUNCTION EDITSZL(aSZL)

IF !EMPTY(aSZL[oListID2:nAt,1]) 
	lEditCell(aSZL,oListID2,'@E 99,999,999,999.99',3)
ENDIF
lAlterad := .T.

RETURN NIL


STATIC FUNCTION SomaSZL(aSZL)
Local _IX := 0

nTotInt := 0

FOR _IX := 1 TO LEN(aSZL)
   	nTotInt += aSZL[_IX,3]
NEXT
oSay2:refresh()

RETURN NIL



Static Function AltInclSZL(nITEM,nxXOpcao)
Local lOk     := .F.
Local lReload := .T.
Local cTitulo := IIF(nxXOpcao=3,"Incluir","Alterar")+ " Cadastro - Itens Proje็ใo Financeira do Contrato:"+ALLTRIM(CN9->CN9_NUMERO)+" Revisใo:"+CN9->CN9_REVISA

PRIVATE cCodSB1 := SPACE(TamSx3("B1_COD")[1])
PRIVATE cDesSB1 := SPACE(TamSx3("B1_DESC")[1])
PRIVATE nValSB1 := 0

PRIVATE oDlg03
PRIVATE oPanelLeft3
PRIVATE aButtons := {}

IF nxXOpcao == 4
	cCodSB1 := aSZL[nITEM,1]  
	cDesSB1 := aSZL[nITEM,2]  
	nValSB1 := aSZL[nITEM,3]  
ENDIF

Do While lReLoad

	lReload := .F.

	DEFINE MSDIALOG oDlg03 TITLE cTitulo FROM 000,000 TO 273,578 PIXEL 
	
	@ 000,000 MSPANEL oPanelLeft3 OF oDlg03 SIZE 473,578
	oPanelLeft3:Align := CONTROL_ALIGN_LEFT
	
	@ 010, 010 SAY "Codigo:" SIZE 60, 7 OF oPanelLeft3 PIXEL 
	@ 020, 010 MSGET oCodSB1 VAR cCodSB1 PICTURE "@!" VALID ExistCpo("SB1",cCodSB1) .and. MostraDesc(@cDesSB1,oDesSB1,cCodSB1 ) HASBUTTON F3 "SB1" SIZE 65, 11 OF oPanelLeft3 PIXEL
	                                                                           
	@ 010, 080 SAY "Descri็ใo:" SIZE 60, 7 OF oPanelLeft3 PIXEL 
	@ 020, 080 MSGET oDesSB1    VAR cDesSB1 PICTURE "@!"  WHEN .F. SIZE 200, 11 OF oPanelLeft3 PIXEL
	
	@ 045, 080 SAY "Valor:"  SIZE 60, 7 OF oPanelLeft3 PIXEL
	@ 055, 080 MSGET nValSB1 PICTURE "@E 99,999,999,999.99" VALID nValSB1 >= 0 SIZE 65, 11 OF oPanelLeft3 PIXEL 
	 
	ACTIVATE MSDIALOG oDlg03 CENTERED Valid(ValidAISZL(nITEM)) ON INIT EnchoiceBar(oDlg03,{|| lOk:=.T., oDlg03:End()},{|| lOk:=.F., oDlg03:End()}, , aButtons)   
	
	If ( lOk )
		lOk := .F.
		IF nxXOpcao == 3
			If EMPTY(aSZL[1,1])
				nITEM := 1
				aSZL[nITEM,1]  := IIF(cTipoZG='01',"18-1","W")+cCodSB1
				aSZL[nITEM,2]  := cDesSB1
				aSZL[nITEM,3]  := nValSB1
			Else
				nScan:= 0
    			nScan:= aScan(aSZL,{|x| ALLTRIM(x[1]) == IIF(cTipoZG='01',"18-1","W")+ALLTRIM(cCodSB1) })
    			IF nScan == 0
					AADD(aSZL,{ IIF(cTipoZG='01',"18-1","W")+ALLTRIM(cCodSB1),;
								cDesSB1	,;   
								nValSB1})
				ELSE
					MsgStop("Codigo jแ incluido!! Cod.: "+IIF(cTipoZG='01',"18-1","W")+cCodSB1+" - "+cDesSB1)
				ENDIF  
			EndIf
			lAlterad := .T.
			MSGINFO("Incluido com Sucesso!!")
		
		ELSEIF nxXOpcao == 4
			aSZL[nITEM,1]  := IIF(cTipoZG='01',"18-1","W")+ALLTRIM(cCodSB1)
			aSZL[nITEM,2]  := cDesSB1
			aSZL[nITEM,3]  := nValSB1
			lAlterad := .T.
			MSGINFO("Alterado com Sucesso!!")
		ENDIF
		SomaSZL(aSZL)
	Endif
EndDo

//ORDENAR POR DESCRIวรO
Asort(aSZL,,,{|x,y| x[2]<y[2]})
oListId2:SetArray(aSZL)
oListID2:bLine := {|| {       aSZL[oListId2:nAt][1],;
					          aSZL[oListId2:nAt][2],;
					Transform(aSZL[oListId2:nAt][3],'@E 99,999,999,999.99')}}  

oListID2:bLDblClick := {|| EDITSZL(@aSZL) ,SomaSZL(aSZL),oListID2:DrawSelect(), }
oListID2:Refresh()
	
Return Nil

STATIC FUNCTION ValidAISZL(nITEM)
Local lRet:= .T.
Local nScan:= 0

IF EMPTY(cCodSB1)
	MsgStop("C๓digo nใo informado!", "Aten็ใo")
	lRet:= .F.
ENDIF

dbSelectArea("SB1")
dbSetOrder(1)
IF !MsSeek(xFilial("SB1")+cCodSB1,.F.)
	MsgStop("C๓digo Invแlido!", "Aten็ใo")
	lRet:= .F.
ENDIF


IF nValSB1 <= 0
	IF !MsgYesNo("Valor nใo informado. Continua?")
		lRet:= .F.
	ENDIF
ENDIF

nScan:= 0
nScan:= aScan(aSZL,{|x| ALLTRIM(x[1]) == IIF(cTipoZG='01',"18-1","W")+ALLTRIM(cCodSB1) })
IF nScan > 0
	IF nScan <> nITEM
		MsgStop("C๓digo jแ incluido. Favor Verificar!!", "Aten็ใo")
		lRet:= .F.
	ENDIF
ENDIF

Return lRet



STATIC FUNCTION ExcSZL(nItem)
LOCAL aItem := {}

IF nItem > 0
	IF !EMPTY(aSZL[nITEM,1])
		IF MsgYesNo("Confirma exclusใo Item: "+aSZL[nITEM,1]+"-"+aSZL[nITEM,2]+"  Valor: "+TRANSFORM(aSZL[nITEM,3],"@E 999,999,999.99") )
	        	
			aItem := aClone(aSZL)
	        aSZL := {}
	        FOR _nx := 1 to LEN(aItem)
	        	IF _nx <> nItem
	        	   AADD(aSZL,aItem[_nx])
	          	ENDIF
	        NEXT
	            
			// Incluir pelo menos 1 linha no array
			If LEN(aSZL) = 0
				cCodSB1 := SPACE(TamSx3("B1_COD")[1])
				cDesSB1 := SPACE(TamSx3("B1_DESC")[1])
				nValSB1 := 0
				AADD(aSZL,{cCodSB1,cDesSB1,nValSB1})  
			EndIf			

			//ORDENAR POR DESCRIวรO
			Asort(aSZL,,,{|x,y| x[2]<y[2]})
	
			oListId2:SetArray(aSZL)
			oListID2:bLine := {|| {       aSZL[oListId2:nAt][1],;
					    			      aSZL[oListId2:nAt][2],;
								Transform(aSZL[oListId2:nAt][3],'@E 99,999,999,999.99')}}  

			oListID2:bLDblClick := {|| EDITSZL(@aSZL) ,SomaSZL(aSZL),oListID2:DrawSelect(), }
			oListID2:Refresh()
			lAlterad := .T.
			MSGINFO("Excluido com Sucesso!!")
		ENDIF
	ENDIF
ENDIF

SomaSZL(aSZL)

RETURN NIL
    

Static Function MostraDesc(cDesc,oDesc,cProd)
Local cAlias,nOldRecno,nOldOrder

cAlias:=Alias()
dbSelectArea("SB1")
nOldOrder:=IndexOrd()
nOldRecno:=Recno()
dbSetOrder(1)
MsSeek(xFilial("SB1")+cProd)
cDesc:=SB1->B1_DESC
oDesc:Refresh(.F.)
dbSetOrder(nOldOrder)
dbGoTo(nOldRecno)
dbSelectArea(cAlias)

Return .T.


User Function SelcSZL(cTipo)

Local cQuery   := ""
Local cTitulo2 := "Sele็ใo de Codigos Proje็ใo Financeira"
Local nScan    := 0
Local lOk      := .F.

PRIVATE oOk
PRIVATE oNo
PRIVATE oDlg3
PRIVATE oListId3
PRIVATE oPanelLeft3
PRIVATE lAll3
PRIVATE oAll3
PRIVATE oBDesc3
PRIVATE oSay3
PRIVATE aButtons3 := {}
PRIVATE aSelRent := {}
PRIVATE cBDesc3	 := SPACE(60)


cQuery  := "SELECT ZL_CODIGO,ZL_DESC from "+RetSqlName("SZL")+" SZL" 
cQuery  += " WHERE D_E_L_E_T_='' AND ZL_TIPO='"+cTipo+"' GROUP BY ZL_CODIGO,ZL_DESC  "
			
TCQUERY cQuery NEW ALIAS "QSZL"
			
DbSelectArea("QSZL")
QSZL->(DbGoTop())
Do While QSZL->(!eof())
    nScan:= 0
    nScan:= aScan(aSZL,{|x| alltrim(x[1])== ALLTRIM(QSZL->ZL_CODIGO) })
    IF nScan == 0
    	nScan:= 0
    	nScan:= aScan(aSelRent,{|x| ALLTRIM(x[2])== ALLTRIM(QSZL->ZL_CODIGO) })
    	IF nScan == 0
    		AADD(aSelRent,{.F.,QSZL->ZL_CODIGO,StrTran(QSZL->ZL_DESC,"*","")})
    	ENDIF
	ENDIF
	QSZL->(DbSkip())
Enddo
QSZl->(Dbclosearea())

IF  LEN(aSelRent) < 1
	MsgInfo("Todos os C๓digos incluidos.") 
	RETURN NIL
ENDIF

//ORDENAR POR DESCRIวรO
Asort(aSelRent,,,{|x,y| x[3]<y[3]})

 
oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

DEFINE MSDIALOG oDlg3 TITLE cTitulo2 FROM 000,000 TO 370,530 PIXEL 

@ 000,000 MSPANEL oPanelLeft3 OF oDlg3 SIZE 320,225
oPanelLeft3:Align := CONTROL_ALIGN_LEFT

lAll3 := .F.
@ 005, 005 CHECKBOX oAll3 VAR lAll3 PROMPT "Marcar todos" OF oPanelLeft3 SIZE 080, 010 PIXEL 
oAll3:bChange := {|| Aeval(aSelRent,{|x| x[1]:=lAll3 }), oListId3:Refresh()}

@ 005, 052 Say  oSay3 Prompt "Descri็ใo:" Size  80, 10 OF oPanelLeft3 Pixel
@ 005, 080 MSGet oBDesc3 VAR cBDesc3 OF oPanelLeft3 SIZE 140, 010 PIXEL Picture "@!"

TButton():New(005,225,'Pesquisar',oPanelLeft3,{|| BuscSelRent() },40,10,,,,.T.)  

@ 020, 005 LISTBOX oListID3 FIELDS HEADER "","Codigo","Descri็ใo" SIZE 250,150 OF oPanelLeft3 PIXEL 
oListID3:SetArray(aSelRent)
oListID3:bLine := {|| {If(aSelRent[oListId3:nAt][1],oOk,oNo),aSelRent[oListId3:nAt][2],aSelRent[oListId3:nAt][3]}}
oListID3:bLDblClick := {|| aSelRent[oListId3:nAt][1] := IIF(aSelRent[oListId3:nAt][1],.F.,.T.), oListID3:DrawSelect()}

ACTIVATE MSDIALOG oDlg3 CENTERED ON INIT EnchoiceBar(oDlg3,{|| lOk:=.T., oDlg3:End()},{|| lOk:=.F., oDlg3:End()}, , aButtons3)

If ( lOk )
	lOk := .F.
	IF LEN(aSZL) == 1
		IF EMPTY(aSZL[1,1])
		   aSZL:= {}
		ENDIF
	ENDIF 
	FOR _IX:=1 TO LEN(aSelRent)
		IF aSelRent[_IX,1]
    		nScan:= 0
    		nScan:= aScan(aSZL,{|x| x[1]= aSelRent[_IX,2] })
    		IF nScan == 0
    			AADD(aSZL,{aSelRent[_IX,2],aSelRent[_IX,3],0})
    		ENDIF
    	ENDIF
	NEXT
	//ORDENAR POR DESCRIวรO	
	Asort(aSZL,,,{|x,y| x[2]<y[2]})
	oListId2:SetArray(aSZL)
	oListID2:bLine := {|| {       aSZL[oListId2:nAt][1],;
					          aSZL[oListId2:nAt][2],;
					Transform(aSZL[oListId2:nAt][3],'@E 99,999,999,999.99')}}  

	oListID2:bLDblClick := {|| EDITSZL(@aSZL) ,SomaSZL(aSZL),oListID2:DrawSelect(), }
	oListID2:Refresh()

ENDIF

RETURN

STATIC FUNCTION BuscSelRent()
    nScan:= 0
    nScan:= aScan(aSelRent,{|x| x[3]>= ALLTRIM(cBDesc3) })
    IF nScan > 0
		oListId3:nAt := nScan
    ELSE
    	MSGINFO("Nใo encontrado!!")
    ENDIF 
RETURN NIL