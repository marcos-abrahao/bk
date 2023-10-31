#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"         

//-------------------------------------------------------------------
/*/{Protheus.doc} BKFINA14
BK - Borderô - Folha
@Return
@author Adilson do Prado
@since 13/03/2012 Rev 02/06/20
@version P12
/*/
//-------------------------------------------------------------------

User Function BKFINA14()

Local oDlg
Local aSize	   	:= FWGetDialogSize( oMainWnd )
Local nTop		:= 0
Local nLeft		:= 0

Local oOk 		:= LoadBitmap( GetResources(), "LBTIK" )
Local oNo 		:= LoadBitmap( GetResources(), "LBNO" )
Local oLayer
Local oListId
Local oPanelUp
Local oPanelDown

Local lAll
Local oAll
//Local aButtons := {}

Local aCtrId   := {}
Local lOk      := .F.
Local aAreaIni  := GetArea()
Local cQuery    := ""
Local nI        := 0
Local _nI       := 0
Local cTitulo   := "Seleção de Título - Borderô "+FWEmpName(cEmpAnt)
Local aErros	:= {}
Local cBanco    := ""
Local cBancos	:= "001/033/104/151/237/341"
//Local aBancos	:= {"237","001","341","033","151","104"}
Local dData		:= dDatabase
Local cTpPes	:= "" // Solicitado pelo Anderson em 25/03/20

Private cPerg   := "BKFINA14"
Private cDirTmp := ""
Private cSEE    := ""
Private oSay 
Private nTotal  := 0
Private aTit1Ger:= {}
Private nFurnas := 0 
Private nTED	:= 0
Private cBCOTED := "/399/756/"
Private aFurnas	:= U_MVXFURNAS()
PRIVATE nTedItau:= 2
PRIVATE cTedBco := "104"

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif

dData  	 := mv_par01
cSEE	 := ALLTRIM(mv_par02) //aBancos[mv_par02]
cDirTmp	 := ALLTRIM(mv_par03)+"\BORDERO" 
nFurnas  := mv_par04
nTED 	 := mv_par05
nTEDItau := mv_par06
cTedBco	 := mv_par07

cBanco   := SUBSTR(cSEE,1,3)

If nTEDItau == 1 
	IF cBanco <> "341" 
		u_MsgLog(cPerg,"Para TED Itau, selecione conta do Banco 341 !","E") 
		Return Nil
	ELSE
		//If !(cTedBco $ "104/237/001")
		//	MSGSTOP("TED Itau diponível apenas para BB, CEF e BRD !",cPerg) 
		//	Return Nil 
		//Else
			IF !u_MsgLog(cPerg,"Confirma a geração de pagamentos do banco "+cTedBco+" no Banco Itau?","Y")
				Return Nil               
			ENDIF
		//EndIf
	ENDIF
ENDIF

IF dData < dDatabase
	u_MsgLog(cPerg,"Data deve ser maior ou igual que a database!!","E")
	Return Nil
ENDIF

IF EMPTY(cDirTmp)
	u_MsgLog(cPerg,"Pasta deve ser preenchida!!","E")
	Return Nil
ENDIF

IF nFurnas == 1
	IF cBanco == "001"
		IF ALLTRIM(cSEE) <> "0013340 5561           00"
			u_MsgLog(cPerg,"Conta Furnas selecionada incorreta!!","E")
			Return Nil
		ENDIF
	ELSEIF nTED == 1
		u_MsgLog(cPerg,"Banco:"+cBanco+" selecionado para este Tipo PGTO Furnas incorreto!!","E")
		Return Nil
	ENDIF
ELSEIF nFurnas == 2
	IF cBanco == "001"
		IF ALLTRIM(cSEE) <> "0013340 5562           00"
			u_MsgLog(cPerg,"Conta Furnas Lote BK selecionada incorreta!!","E")
			Return Nil
		ENDIF
	ELSEIF nTED == 1
		u_MsgLog(cPerg,"Banco:"+cBanco+" selecionado para este Tipo PGTO Furnas Lote BK incorreto!!","E")
		Return Nil
	ENDIF
ELSE
	IF cBanco == "001"
		IF ALLTRIM(cSEE) == "0013340 5561           00"  .OR. ALLTRIM(cSEE)="0013340 5562           00"
			u_MsgLog(cPerg,"Conta selecionada incorreta!!","E")
			Return Nil
		ENDIF
	ENDIF
ENDIF

IF (nFurnas==1 .AND. nTED == 1 )  .OR. (nFurnas==2 .AND. nTED == 1 )
   cBancos += cBCOTED
ENDIF

aCtrId := {}

u_WaitLog(cPerg, {|| aCtrId := GeraQueryTit(dData,cBanco)},cTitulo)

If Empty(aCtrId)
	u_MsgLog(cPerg,"Não há títulos "+IIF(nFurnas==1," de FURNAS","")+IIF(nFurnas==2," de FURNAS LOTE BK","")+" disponíveis !!","E")
	RestArea(aAreaIni)
	Return
EndIf

MsgAlert("Verifique a DATA do Bordero!!",cPerg)


oDlg := MsDialog():New( nTop, nLeft, aSize[3], aSize[4],cTitulo,,,,,,,,, .T.,,,, .F. )

oDlg:nClientHeight  := aSize[3]
oDlg:nClientWidth   := aSize[4]

oDlg:Refresh()

EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End() })

oLayer := FWLayer():new()
oLayer:init(oDlg,.F.)

oLayer:addCollumn ('Col1',100,.F.)

oLayer:addWindow('Col1', 'WinTop' ,'Seleção' ,15,.F.,.F.,,,)
oLayer:addWindow('Col1', 'WinGrid','Títulos' ,85,.F.,.F.,,,)

oPanelUp := oLayer:getWinPanel('Col1','WinTop')
oPanelDown := oLayer:getWinPanel('Col1','WinGrid')


lAll := .F.
@ 003, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelUp SIZE 050, 010 PIXEL 
oAll:bChange := {|| Aeval(aCtrId,{|x| IIF(CTOD(x[10]) >= dDatabase .AND. x[3] $ cBancos,x[1]:=lAll,x[1]:=.F.) }), oListId:Refresh()}

@ 015, 005 LISTBOX oListId FIELDS HEADER "","Lote (CTRID)","Banco","Prefixo","Número","Parcela","Tipo","Pgto","Emissão","Vencimento","Total R$","Ref.","Tipo" SIZE 320,180 OF oPanelDown PIXEL 
oListID:SetArray(aCtrId)
oListID:bLine := {|| {If(aCtrId[oListId:nAt][1],oOk,oNo),;
						aCtrId[oListId:nAt][2],;
						aCtrId[oListId:nAt][3],;
						aCtrId[oListId:nAt][4],;
						aCtrId[oListId:nAt][5],;
						aCtrId[oListId:nAt][6],;
						aCtrId[oListId:nAt][7],;
						aCtrId[oListId:nAt][8],;
						aCtrId[oListId:nAt][9],;
						aCtrId[oListId:nAt][10],;
						aCtrId[oListId:nAt][11],;
						aCtrId[oListId:nAt][12],;
						aCtrId[oListId:nAt][15]}}

oListId:bLDblClick := {|| aCtrId[oListId:nAt][1] := ValidaMrk(aCtrId[oListId:nAt][1],aCtrId[oListId:nAt][10],aCtrId[oListId:nAt][3],cBancos), oListId:DrawSelect()}
oListId:Align := CONTROL_ALIGN_ALLCLIENT

//ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , aButtons)
oDlg:Activate()

If ( lOk )
	aTit1Ger := {}
	aErros  := {}
	For nI:=1 To Len(aCtrId)
	    //Regularização momentânia numero de CPF para IPT - Definitivo a partir de 01/10/12 - JA ESTA OK  
		IF aCtrId[nI,1]
			cQuery  := " SELECT Z2_CTRID,Z2_E2PRF,Z2_E2NUM,Z2_E2PARC,Z2_E2TIPO,Z2_PRONT,Z2_NOME,Z2_VALOR,Z2_DATAPGT,Z2_TIPO,Z2_NOMDEP,Z2_NOMMAE,"
			cQuery  += " Z2_CODEMP,Z2_TIPOPES,Z2_BANCO,Z2_AGENCIA,Z2_DIGAGEN,Z2_CONTA,Z2_DIGCONT,Z2_CPF,Z2_USUARIO,Z2_HORALIB,Z2_BORDERO,SZ2.R_E_C_N_O_ AS REC "
			cQuery  += " FROM "+RETSQLNAME("SZ2")+" SZ2 "
//			cQuery  += "LEFT JOIN bk_senior.bk_senior.r034fun ON SZ2.Z2_CODEMP = bk_senior.bk_senior.r034fun.numemp AND SZ2.Z2_PRONT=bk_senior.bk_senior.r034fun.numcad "
//			cQuery  += " AND bk_senior.bk_senior.r034fun.nomfun like Z2_NOME+'%' COLLATE SQL_Latin1_General_CP1_CI_AS "
			cQuery  += " WHERE Z2_CODEMP = '"+cEmpAnt+"' AND Z2_CTRID = '"+aCtrId[nI,2]+"' "
			cQuery  += " AND Z2_E2PRF='"+aCtrId[nI,4]+"' AND Z2_E2NUM='"+aCtrId[nI,5]+"' AND Z2_E2PARC='"+aCtrId[nI,6]+"' AND Z2_TIPOPES NOT IN ('CLA','AC') AND Z2_E2TIPO='"+aCtrId[nI,7]+"'"
			If nTEDItau == 1
				cQuery  += " AND Z2_BANCO = '"+cTedBco+"' "
			ELSE
				cQuery  += " AND Z2_BANCO = '"+aCtrId[nI,3]+"' "
			ENDIF
			cQuery  += " AND Z2_STATUS='S' AND SZ2.D_E_L_E_T_ <> '*' AND Z2_VALOR > 0"
			
			TCQUERY cQuery NEW ALIAS "QSZ2"
			
			TCSETFIELD("QSZ2","Z2_DATAPGT","D",8,0)

			DbSelectArea("QSZ2")
			DbGoTop()
			//ProcRegua(LastRec())
			Do While !eof()
				//IncProc("Carregando titulos para Borderôs "+FWEmpName(cEmpAnt)+"...")
 				IF QSZ2->Z2_DATAPGT == dData .AND. QSZ2->Z2_BANCO $ cBancos
					If QSZ2->Z2_CODEMP = "01" .AND. QSZ2->Z2_PRONT = "000296"
						cTpPes := "CLT"
					Else
						cTpPes := QSZ2->Z2_TIPOPES
					EndIf
 					AADD(aTit1Ger,{IIF(EMPTY(QSZ2->Z2_BORDERO),.T.,.F.),QSZ2->Z2_CTRID,QSZ2->Z2_PRONT,QSZ2->Z2_NOME,Round(QSZ2->Z2_VALOR,2),QSZ2->Z2_DATAPGT,QSZ2->Z2_TIPO,QSZ2->Z2_BANCO,QSZ2->Z2_AGENCIA,QSZ2->Z2_DIGAGEN,QSZ2->Z2_CONTA,QSZ2->Z2_DIGCONT,QSZ2->Z2_CPF,QSZ2->Z2_USUARIO,QSZ2->Z2_E2TIPO,QSZ2->Z2_HORALIB,QSZ2->Z2_BORDERO,aCtrId[nI,9],QSZ2->REC,QSZ2->Z2_NOMDEP,QSZ2->Z2_NOMMAE,cTpPes})
 				    //                            1                           2               3            4               5              6              7              8                  9              10              11              12             13               14             15               16                17           18          19            20            21         22
				ELSEIF QSZ2->Z2_DATAPGT <> dData 
					nErros := 0
					nErros := aScan(aErros,{|x| x[1]==1 .AND. x[2]==QSZ2->Z2_CTRID .AND. x[3]=QSZ2->Z2_PRONT })
					IF nErros == 0
					   AADD(aErros,{1,QSZ2->Z2_CTRID,QSZ2->Z2_PRONT,DTOC(QSZ2->Z2_DATAPGT),QSZ2->Z2_NOME})
					ENDIF                                                                                                  
				ELSE
					nErros := 0
					nErros := aScan(aErros,{|x| x[1]==2 .AND. x[2]==aCtrId[nI,2] .AND. x[3]=aCtrId[nI,3] })
					IF nErros == 0
					   AADD(aErros,{2,TRIM(aCtrId[nI,2]),aCtrId[nI,3],aCtrId[nI,10]})
					ENDIF
				ENDIF
				DbSkip()
			Enddo
			QSZ2->(DbCloseArea())
		ENDIF
	NEXT
	MsgAlert("Verifique a DATA do Bordero!!",cPerg)
Endif

If !EMPTY(aErros)
	For _nI:= 1 To Len(aErros)
		IF aErros[_nI,1] == 1 
			u_MsgLog(cPerg,"CtrId "+FWEmpName(cEmpAnt)+TRIM(aErros[_nI,2])+" data de pgto diferente ("+aErros[_nI,4]+"), registro não gerado."+CHR(13)+CHR(10)+"Prontuário: "+aErros[_nI,3]+" - "+aErros[_nI,5],"E")
		ELSEIF aErros[_nI,1] == 2 
			u_MsgLog(cPerg,"CtrId "+FWEmpName(cEmpAnt)+TRIM(aErros[_nI,2])+" com layout banco ("+aErros[_nI,3]+") indisponível ","E")
		ENDIF
	NEXT
EndIf

If !EMPTY(aTit1Ger)
	ASORT(aTit1Ger,,,{|x,y| x[4]<y[4]})
 	//Processa ( {|| lOk := ConfTit(aCtrid,dData,cBanco)})
	u_WaitLog(cPerg, {|| lOk := ConfTit(aCtrid,dData,cBanco)})
EndIf

RestArea(aAreaIni)
Return
      

Static Function ValidaMrk(lRet,cPgto,cBanco,cBancos)

IF CTOD(cPgto) >= dDataBase  .AND. cBanco $ cBancos
	lRet := !lRet
ELSE
	IF CTOD(cPgto) < dDataBase
   		u_MsgLog(cPerg,"Data de pgto deste lote é inferior a data base do sistema","E")
   		lRet := .F.
	ELSE 
   		u_MsgLog(cPerg,"Layout banco ("+cBanco+") indisponível ","E")
   		lRet := .F.
 	ENDIF
ENDIF   
Return lRet


STATIC FUNCTION ConfTit(aCtrid,dData,cBanco)

Local oDlg2
Local aSize	   	:= FWGetDialogSize( oMainWnd )
Local nTop		:= 0
Local nLeft		:= 0

Local oOk := LoadBitmap( GetResources(), "LBTIK" )
Local oNo := LoadBitmap( GetResources(), "LBNO" )
Local oListId2

Local oLayer2
Local oPanelU2
Local oPanelD2

//Local aButtons 	:= {}
Local aTPCNAB 	:= {}
Local nTPCNAB 	:= 0
Local lOk      	:= .F.
Local nI
Local aTipoPes  := {"CLT","PJ"}
Local nTipoPes  := 0
Local cTipoPes  := ""
Local lTitBor   := .T.
Local nLimAvCLT := U_LimAvCLT()
Private aBordero  := {} 

AADD(aTPCNAB,{"LPMA/COM/LPM","PGTOSAL"})
AADD(aTPCNAB,{"LFE","FERIAS"})
AADD(aTPCNAB,{"LRC","RESCISAO"})
AADD(aTPCNAB,{"PEN","PENSAO"})
AADD(aTPCNAB,{"LD1/LD2","13SAL"})
AADD(aTPCNAB,{"LAD/LAS","ADIANT"})
AADD(aTPCNAB,{"LDV/RMB/NDB/CXA/PCT/DCH/SOL/HOS/EXM/LFG/MFG/VA/VR/VT/REE/ADF/DSA/GRA/HEX/DIN","PGTO_OUTROS"})
	
nTotal := 0

FOR nI := 1 TO LEN(aTit1Ger)

	IF aTit1Ger[nI,1]
		nTotal += aTit1Ger[nI,5] 
	ENDIF
	//PARA EMPRESA 16 MOOVE-SP FOI RETIRADO A AGLUTINAÇÃO DE TITULOS - SOLICITADO PELO LAUDECIR FINANCEIRO - 10/05/2023
	IF FWCodEmp() == "16"
		AADD(aBordero,aTit1Ger[nI])
	ELSE
		//  1        2             3         4       5          6        7      8        9       10       11      12     13     14       15        16               17            18      19    20       21
		// "","Lote (CTRID)","Prontuario","Nome","Valor R$","Dt.PGTO","Tipo","Banco","Agencia","Dg.Ag","Conta","Dg.CC","Cpf","Usuário","Tipo","Data Hora Lib","No. Lote CNAB","Emissão","Reg.","NOMDEP","Z2_NOMMAE"
		nScan:= 0
		nScan:= aScan(aBordero,{|x| x[3]==aTit1Ger[nI,3] .AND. x[6]==aTit1Ger[nI,6] .AND. x[8]==aTit1Ger[nI,8] .AND. x[9]==aTit1Ger[nI,9] .AND. x[11]==aTit1Ger[nI,11] .AND. x[13]==aTit1Ger[nI,13]})
		IF nScan == 0
			AADD(aBordero,aTit1Ger[nI])
		ELSE
			aBordero[nScan,5] += aTit1Ger[nI,5]
		ENDIF
	ENDIF

NEXT

oDlg2 := MsDialog():New( nTop, nLeft, aSize[3], aSize[4],"Confirme os Borderôs a gerar (consolidados)",,,,,,,,, .T.,,,, .F. )

oDlg2:nClientHeight  := aSize[3]
oDlg2:nClientWidth   := aSize[4]

oDlg2:Refresh()

EnchoiceBar(oDlg2,{|| lOk:=.T., oDlg2:End()},{|| oDlg2:End() })

oLayer2 := FWLayer():new()
oLayer2:init(oDlg2,.F.)

oLayer2:addCollumn ('Col1',100,.F.)

oLayer2:addWindow('Col1', 'WinTop' ,'Seleção' ,15,.F.,.F.,,,)
oLayer2:addWindow('Col1', 'WinGrid','Títulos' ,85,.F.,.F.,,,)

oPanelU2 := oLayer2:getWinPanel('Col1','WinTop')
oPanelD2 := oLayer2:getWinPanel('Col1','WinGrid')

lAll:= .F. 
@ 003, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelU2 SIZE 050, 010 PIXEL 
oAll:bChange := {|| MudaCell(lAll) , oListId2:Refresh()}

oSay := tSay():New(003,100,{||'Total Selecionado: '+ TransForm(nTotal,"@E 99,999,999.99")},oPanelU2,,,,,,.T.,,,200,20)

@ 012, 005 LISTBOX oListID2 FIELDS HEADER "","Lote (CTRID)","Prontuario","Nome","Valor R$","Dt.PGTO","Tipo","Banco","Agencia","Dg.Ag","Conta","Dg.CC","Cpf","Usuário","Tipo","Data Hora Lib","No. Lote CNAB","Emissão","Reg.","NomeDep","NomeMae","Tipo Pes" SIZE 320,180 OF oPanelD2 PIXEL 

oListID2:SetArray(aBordero)
oListID2:bLine := {|| {If(aBordero[oListId2:nAt][1],oOk,oNo),;
 						aBordero[oListId2:nAt][2],;
						aBordero[oListId2:nAt][3],;
						aBordero[oListId2:nAt][4],;
						TRANSFORM(aBordero[oListId2:nAt][5],"@E 999,999,999.99"),;
						aBordero[oListId2:nAt][6],;
						aBordero[oListId2:nAt][7],;
						aBordero[oListId2:nAt][8],;
						aBordero[oListId2:nAt][9],;
						aBordero[oListId2:nAt][10],;
						aBordero[oListId2:nAt][11],;
						aBordero[oListId2:nAt][12],;
						aBordero[oListId2:nAt][13],;
						aBordero[oListId2:nAt][14],;
						aBordero[oListId2:nAt][15],;
						aBordero[oListId2:nAt][16],;
						aBordero[oListId2:nAt][17],;
						aBordero[oListId2:nAt][18],;
						aBordero[oListId2:nAt][19],;
						aBordero[oListId2:nAt][20],;
						aBordero[oListId2:nAt][21],;
						aBordero[oListId2:nAt][22]}}

oListID2:bLDblClick := {|| aBordero[oListId2:nAt][1] := MrkTit(aBordero[oListId2:nAt][17],aBordero[oListId2:nAt][1],aBordero[oListId2:nAt][5]), oListID2:DrawSelect()}
oListID2:Align := CONTROL_ALIGN_ALLCLIENT

//ACTIVATE MSDIALOG oDlg2 CENTERED ON INIT EnchoiceBar(oDlg2,{|| lOk:=.T., oDlg2:End()},{|| oDlg2:End()}, , aButtons)
oDlg2:Activate()

If ( lOk )
	lOk  := .F.
	nTPCNAB  := 0
	nBordero := 0

	FOR nTipoPes := 1 TO LEN(aTipoPes)
		cTipoPes := aTipoPes[nTipoPes]
		FOR nTPCNAB := 1 TO LEN(aTPCNAB) 
			aTit := {}
			lTit := .F.
			FOR nI := 1 TO LEN(aBordero)
				IF aBordero[nI,1] .AND. ALLTRIM(aBordero[nI,7]) $ aTPCNAB[nTPCNAB,1] .AND. TRIM(aBordero[nI,22]) == cTipoPes
					// Anderson solicitou aviso de pagamento acima de 15.000,00 em 04/08/22
					lTitBor := .T.
					If aBordero[nI,5] > nLimAvCLT .AND. aBordero[nI,22] == "CLT"
						If !MsgYesNo("ATENÇÃO: Pagamento para "+ALLTRIM(aBordero[nI,4])+" acima de "+ALLTRIM(STR(nLimAvCLT,14,2))+", confirma?", "BKFINA14")
							lTitBor := .F.
							aBordero[nI,1] := .F.
						Else
							u_MsgLog(cPerg,"Pagamento para "+ALLTRIM(aBordero[nI,4])+" acima de "+ALLTRIM(STR(nLimAvCLT,14,2))+" foi confirmado")
						EndIf
					EndIf
					If lTitBor
						AADD(aTit,{aBordero[nI,2],aBordero[nI,3],aBordero[nI,4],aBordero[nI,5],aBordero[nI,6],aBordero[nI,7],aBordero[nI,8],aBordero[nI,9],aBordero[nI,10],aBordero[nI,11],aBordero[nI,12],aBordero[nI,13],aBordero[nI,14],aBordero[nI,15],aBordero[nI,16],aBordero[nI,17],aBordero[nI,18],aBordero[nI,19],aBordero[nI,20],aBordero[nI,21],,aBordero[nI,22]})
						lTit := .T.
						nBordero++
					EndIf
				ENDIF
			NEXT nI 
			IF lTit
				//Processa ( {|| GravaBordero(aTit,aCtrid,dData,cBanco,aTPCNAB[nTPCNAB,2],cTipoPes)})
				u_WaitLog(cPerg, {|| GravaBordero(aTit,aCtrid,dData,cBanco,aTPCNAB[nTPCNAB,2],cTipoPes)},"Gravando Borderô")
			ENDIF
			IF nBordero == LEN(aBordero)
				nTPCNAB := LEN(aTPCNAB) 
			ENDIF
		NEXT nTPCNAB
	NEXT nTipoPes
EndIf

Return lOk


Static Function MudaCell(lAll)
Local nAviso := 1
Local nI

nTotal := 0

IF lAll
	nAviso := u_AvisoLog("BKFINA14","Marcar todos - Atenção:","Alguns destes PGTOs ja estão inclusos no Lote CNAB. Deseja gerar novamente ??",{"Sim","Não"})
	FOR nI := 1 TO LEN(aBordero)
		IF nAviso == 1
			aBordero[nI,1] := lAll
		ENDIF
		IF aBordero[nI,1]
			nTotal += aBordero[nI,5]
		ENDIF
	NEXT
	oSay:cCaption := "Total Selecionado: "+TRANSFORM(nTotal,"@E 999,999,999.99")
ELSE
	nAviso := u_AvisoLog("BKFINA14","Desmarcar todos - Atenção:","Para alguns destes PGTOs NÃO foram gerados lotes ainda.",{"Só os já gerados","Desmarcar todos"})
	FOR nI := 1 TO LEN(aBordero)
		IF EMPTY(ALLTRIM(aBordero[nI,17])) .AND. nAviso == 1
			aBordero[nI,1] := .T.
			nTotal += aBordero[nI,5]
		ELSE
			aBordero[nI,1] := .F.
		ENDIF
	next
	oSay:cCaption := "Total Selecionado: "+TRANSFORM(nTotal,"@E 999,999,999.99")
ENDIF

Return


Static Function MrkTit(cBordero,lTit,nVal)
LOCAL lOk := .T.

IF !EMPTY(cBordero)
    IF !lTit
		IF u_AvisoLog("BKFINA14",cPerg,"Este PGTO ja incluso no Lote CNAB: "+cBordero+", enviar novamente??",{"Sim","Não"}) <> 1
			lOk := .F.
		Endif
	ELSE
		lOk := .F.
	ENDIF
ELSE
	IF lTit
  		lOk := .F.
	ENDIF
ENDIF

IF lTit <> lOk

	IF lOk
		nTotal += nVal
	ELSE
		nTotal -= nVal
	ENDIF
ENDIF

oSay:cCaption := "Total Selecionado: "+TRANSFORM(nTotal,"@E 999,999,999.99")


Return lOk 



Static Function GravaBordero(aTitGer,aCtrid,dData,cBanco,cGrupo,cTipoPes)
Local cCrLf   	:= Chr(13) + Chr(10)
Local cQuery    := ""
Local cArqTmp 	:= ""
Local BncoTxtT	:= ""
Local cAgencia  := ""
Local cDVAgenc	:= ""
Local cConta    := ""
Local cDVConta  := ""
Local cCGC		:= ""
Local cNomeCom  := ""
Local nLote 	:= 0
Local cDirTmp2  := ALLTRIM(cDirTmp)
Local nI
Local cMsgLog   := ""

DbSelectArea("SM0")

//CONSORCIOS USAR LOTE BK
IF cEmpAnt $ "06/08/09/10/11/14/15"
	cQuery  := "SELECT EE_CODIGO,EE_AGENCIA,EE_CONTA,EE_LOTECP "
	cQuery  += " FROM SEE010 "
	cQuery  += " WHERE EE_FILIAL='"+xFILIAL("SEE")+"' AND EE_CODIGO='"+SUBSTR(cSEE,1,3)+"' AND D_E_L_E_T_ = '' "  
	cQuery  += " AND EE_AGENCIA='"+SUBSTR(cSEE,4,5)+"' AND EE_CONTA='"+SUBSTR(cSEE,9,10)+"' AND EE_SUBCTA='"+SUBSTR(cSEE,19,3)+"'"

	If Select("QSEE") > 0
		QSEE->(DbCloseArea())
	EndIf

	TCQUERY cQuery NEW ALIAS "QSEE"
			
	DbSelectArea("QSEE")
	QSEE->(DbGoTop())
	DO WHILE QSEE->(!EOF())
		nLote := VAL(QSEE->EE_LOTECP)
		QSEE->(dbSkip())
	ENDDO
	QSEE->(DbCloseArea())

	IF  nLote > 0
		nLote := VAL(Soma1(STR(nLote),8))

    	cQuery 	:= " UPDATE SEE010 SET EE_LOTECP = '"+STRZERO(nLote,8)+"' "
		cQuery  += " WHERE EE_FILIAL='"+xFILIAL("SEE")+"' AND EE_CODIGO='"+SUBSTR(cSEE,1,3)+"' AND D_E_L_E_T_ = '' "  
		cQuery  += " AND EE_AGENCIA='"+SUBSTR(cSEE,4,5)+"' AND EE_CONTA='"+SUBSTR(cSEE,9,10)+"' AND EE_SUBCTA='"+SUBSTR(cSEE,19,3)+"'"
    	TcSqlExec(cQuery)
	ENDIF

ENDIF

DbSelectArea("SEE")
DbSetOrder(1)
IF DbSeek(xFilial("SEE")+cSEE,.F.)
	//CONSORCIOS: USAR CNPJ BK
	cCGC      := IIF(cEmpAnt $ "06/08/09/10/11/14/15".AND. nLote > 0 ,"03022122000177",SM0->M0_CGC)
    cNomeCom  := IIF(cEmpAnt $ "06/08/09/10/11/14/15".AND. nLote > 0 ,"BK CONSULTORIA E SERVICOS LTDA",Acento(ALLTRIM(SM0->M0_NOMECOM)))

    IF (cEmpAnt $ "06/08/09/10/11/14/15") .AND. nLote > 0 
		u_MsgLog(cPerg,"Borderô dos consorcios considerando CNPJ da BK!","W")
	EndIf


	RecLock("SEE",.F.)                             
	Replace SEE->EE_LOTECP With IIF(cEmpAnt $ "06/08/09/10/11/14/15" .AND. nLote > 0 ,STRZERO(nLote,8),Soma1(SEE->EE_LOTECP,8))
	SEE->( MsUnlock() )
	nLote := VAL(SEE->EE_LOTECP)
 
	cAgencia  := STRTRAN(SEE->EE_AGENCIA,"-","")
	cDVAgenc  := SEE->EE_DVAGE
	cConta    := STRTRAN(SEE->EE_CONTA,"-","")
	cDVConta  := SEE->EE_DVCTA
ELSE
	u_MsgLog(,"Parâmetro do Banco não cadastrado!!",'E')
	Return nil
ENDIF

MakeDir(cDirTmp2)
/*
IF cEmpAnt = "06"
	cDirTmp2 := "\BKDAHER"
ELSEIF cEmpAnt = "08"
	cDirTmp2 := "\CAMPINAS" 
ELSEIF cEmpAnt = "09"
	cDirTmp2 := "\OSASCO" 
ELSEIF cEmpAnt = "10"
	cDirTmp2 := "\TABOAO"
ELSEIF cEmpAnt = "11"
	cDirTmp2 := "\LIMEIRA"
ELSE
	cDirTmp2 := "\BK"
ENDIF
MakeDir(cDirTmp2)
*/
IF cBanco = "001"
	cDirTmp2 += "\BRASIL"
ELSEIF cBanco = "033"
	cDirTmp2 += "\SANTANDER"
ELSEIF cBanco = "104"
	cDirTmp2 += "\CAIXA"
ELSEIF cBanco = "151"
	cDirTmp2 += "\NOSSACAIXA"
ELSEIF cBanco = "237"
	cDirTmp2 += "\BRADESCO"
ELSEIF cBanco = "341"
	cDirTmp2 += "\ITAU"
ENDIF

MakeDir(cDirTmp2)

IF nFurnas==1
	cDirTmp2 +="\FURNAS"
	MakeDir(cDirTmp2)
ENDIF

ASORT(aTitGer,,,{|x,y| x[3]<y[3]})

//cArqTmp := cDirTmp+"\"+IIF(nFurnas==1,"FURNAS_","")+IIF(nFurnas==2,"FURNAS_LBK_","")+cGrupo+"_"+cBanco+"_"+DTOS(dData)+"_Lote_"+STRZERO(nLote,6)+"\"+IIF(nFurnas==1,"FURNAS_","")+IIF(nFurnas==2,"FURNAS_LBK_","")+"RELACAO_BANCARIA_"+cGrupo+"_"+cBanco+"_"+DTOS(dData)+".DOC"

IF cBanco = "001"
	cArqTmp := cDirTmp2+"\BB"
ELSEIF cBanco = "033"
	cArqTmp := cDirTmp2+"\ST"
ELSEIF cBanco = "104"
	cArqTmp := cDirTmp2+"\CX"
ELSEIF cBanco = "151"
	cArqTmp := cDirTmp2+"\NC"
ELSEIF cBanco = "237"
	cArqTmp := cDirTmp2+"\BR"
ELSEIF cBanco = "341"
	cArqTmp := cDirTmp2+"\IT"
ENDIF

cArqTmp +=STRZERO(nLote,6)

IF File(cArqTmp+".DOC")
   If !MsgYesNo("Ja existe arquivo(s) ("+cArqTmp+".DOC) neste local, deseja sobrepor?")
		Return nil
	EndIf
EndIf

//Cria Arquivo Relação Bancaria
//MakeDir(cDirTmp+"\"+IIF(nFurnas==1,"FURNAS_","")+IIF(nFurnas==2,"FURNAS_LBK_","")+cGrupo+"_"+cBanco+"_"+DTOS(dData)+"_Lote_"+STRZERO(nLote,6))

fErase(cArqTmp+".DOC")
nHandle := MsfCreate(cArqTmp+".DOC",0)


//Cria Arquivo Remessa Bancaria 
IF cBanco = "104"
//	cArqTmp := cDirTmp+"\"+IIF(nFurnas==1,"FURNAS_","")+IIF(nFurnas==2,"FURNAS_LBK_","")+cGrupo+"_"+cBanco+"_"+DTOS(dData)+"_Lote_"+STRZERO(nLote,6)+"\"+IIF(nFurnas==1,"FURNAS_","")+IIF(nFurnas==2,"FURNAS_LBK_","")+cGrupo+"_"+"siac"+SUBSTRING(DTOC(date()),1,2)+SUBSTRING(DTOC(date()),4,2)+".rem"
	cArqTmp +=".REM"
ELSE
//	cArqTmp := cDirTmp+"\"+IIF(nFurnas==1,"FURNAS_","")+IIF(nFurnas==2,"FURNAS_LBK_","")+cGrupo+"_"+cBanco+"_"+DTOS(dData)+"_Lote_"+STRZERO(nLote,6)+"\"+IIF(nFurnas==1,"FURNAS_","")+IIF(nFurnas==2,"FURNAS_LBK_","")+"REMESSA_"+cGrupo+"_"+cBanco+"_"+DTOS(dData)+".TXT"
	cArqTmp +=".TXT"
ENDIF

IF File(cArqTmp)
   If !MsgYesNo("Ja existe arquivos ("+cArqTmp+") neste local, deseja sobrepor?")
		Return nil
	EndIf
EndIf


BncoTxt := ''
BncoTxt += '<table width="100%" align="CENTER" cellpadding="2" cellspacing="2" style="border-style:outset; border-width:1; padding-left:4px; padding-right:4px; padding-top:1px; padding-bottom:1px">'
BncoTxt += '<tr>'
BncoTxt += '<td align="center">Prontuario</td>'
BncoTxt += '<td align="center">Cpf</td>'
BncoTxt += '<td align="center">Nome</td>'
BncoTxt += '<td align="center">Agencia</td>'
BncoTxt += '<td align="center">Conta</td>'
BncoTxt += '<td align="center">Valor</td>'
BncoTxt += '</tr>'
	
fErase(cArqTmp)
nHandle2 := MsfCreate(cArqTmp,0)
				
If nHandle > 0 .OR. nHandle2 > 0
   	qValTot := 0
   	qTot 	:= 0
   	BncoTxtT := ""
	If cBanco == "001"
		IF (nFurnas==1 .OR. nFurnas==2) .AND. nTED == 1
			//Layout BRASIL TED - 240 - HEADER DE ARQUIVO "0"		
			Bcn001H := ""
			Bcn001H += "001"    //001 003
			Bcn001H += "0000"   //004 007
			Bcn001H += "0"               //008 008
			Bcn001H += SPACE(9)          //009 017
			Bcn001H += "2"               //018 018
			Bcn001H += STRZERO(VAL(cCGC),14) //019 032
			Bcn001H += PAD(STRZERO(VAL(SEE->EE_CODEMP),13),20) //033 052 - Código do Convênio //  "0008539930126       "
			Bcn001H += STRZERO(VAL(cAgencia),5)   //053 057
			Bcn001H += STRZERO(VAL(cDVAgenc),1)   //058 058 DV AGENCIA
			Bcn001H += STRZERO(VAL(cConta),12)  //059 070
			Bcn001H += STRZERO(VAL(cDVConta),1) //071 071 DV CONTA
			Bcn001H += "0"	  //072 072 
			Bcn001H += PAD(cNomeCom,30) //073 102
			Bcn001H += PAD("BANCO DO BRASIL S/A",30)  //103 132
			Bcn001H += SPACE(10)                  //133 142
			Bcn001H += "1"                        //143 143 1-Remessa 2-Retorno
			Bcn001H += Day2Str(DATE())+Month2Str(DATE())+Year2Str(DATE())  //144 151
			cTime := TIME()
			cHora := SUBSTR(cTime, 1, 2)
			cMinutos := SUBSTR(cTime, 4, 2)
			cSegundos := SUBSTR(cTime, 7, 2)
			Bcn001H += STRZERO(0,6) //cHora+cMinutos+cSegundos      //152 157
			Bcn001H += STRZERO(nLote,6)           //158 163  - LOTE
			Bcn001H += "050"               //164 166  - VERSAO LAYOUT
			Bcn001H += SPACE(5)            //167 171
			Bcn001H += SPACE(20)           //172 191
			Bcn001H += SPACE(20)           //192 211
			Bcn001H += SPACE(11)           //212 222
			Bcn001H += SPACE(3)            //223 225
			Bcn001H += SPACE(3)               //226 228
			Bcn001H += SPACE(2)            //229 230
			Bcn001H += SPACE(10)           //231 240
			Bcn001H += cCrLf
							
			//Grava Bordero - HEADER DE ARQUIVO "0"
			fWrite(nHandle2,Bcn001H)
		    
		    //- HEADER DE ARQUIVO "1" 
			Bcn001HD := ""
			Bcn001HD += "001"        //001 003
			Bcn001HD += "0001"       //004 007
			Bcn001HD += "1"          //008 008
			Bcn001HD += "C"          //009 009
			Bcn001HD += IIf(cTipoPes == "CLT","30","20")         //010 011
			Bcn001HD += "41"      	 //012 013
			Bcn001HD += "031"        //014 016
			Bcn001HD += SPACE(1)     //017 017
			Bcn001HD += "2"          //018 018
			Bcn001HD += STRZERO(VAL(cCGC),14) //019 032
			//If cEmpAnt <> "15"
				Bcn001HD += "0008539930126       " //SUBSTRING(SEE->EE_CODEMP,1,6) 033 052 - Código do Convênio
			//Else
			//	Bcn001HD += "0002732690126       " //SUBSTRING(SEE->EE_CODEMP,1,6) 033 052 - Código do Convênio
			//EndIf
			Bcn001HD += STRZERO(VAL(cAgencia),5)    //053 057
			Bcn001HD += STRZERO(VAL(cDVAgenc),1)   //058 058
			Bcn001HD += STRZERO(VAL(cConta),12)  //059 070
			Bcn001HD += STRZERO(VAL(cDVConta),1) //071 071 DV CONTA
			Bcn001HD += "0"	  //072 072
			Bcn001HD += PAD(cNomeCom,30) //073 102
			Bcn001HD += SPACE(128)   //103 230
			Bcn001HD += "V.PAG10134"//231 241
			Bcn001HD += cCrLf
							
			//Grava Bordero - Descrição do Registro DETALHE - “A”
			fWrite(nHandle2,Bcn001HD)
			nSeq := 0
			//ProcRegua(Len(aTitGer))
			For nI:=1 To Len(aTitGer)
				//IncProc("Criando Borderô "+FWEmpName(cEmpAnt)+"...")
						
				qValTot += aTitGer[nI,4]
				qTot++
				nSeq++
				BncoTxtT := cNomeCom+'<BR>RELAÇÃO BANCÁRIA BANCO DO BRASIL '+IIF(nFurnas==1," - FURNAS","")+IIF(nFurnas==2," - FURNAS LOTE BK","")+' <b> Lote: '+STRZERO(nLote,8)+'</b><BR> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=1><i>Emitida em : '+aTitGer[nI,15]+' - pelo usuário : '+aTitGer[nI,13]+'</i><br><br>&nbsp;'
	
	            //Descrição do Registro DETALHE - “A”
			    Bcn001D := ""
				Bcn001D += "001"     //001 003
				Bcn001D += "0001"    //004 007
				Bcn001D += "3"       //008 008
				Bcn001D += STRZERO(nSeq,5) //009 0013
				Bcn001D += "A"             //014 014
				Bcn001D += "0"             //015 015
				Bcn001D += "00"            //016 017
				Bcn001D += "018"           //018 020
				Bcn001D += STRZERO(VAL(aTitGer[nI,7]),3)  //021 023 BANCO
				Bcn001D += STRZERO(VAL(aTitGer[nI,8]),5)  //024 028 AGENCIA
				Bcn001D += PAD(aTitGer[nI,9],1)           //029 029
				Bcn001D += STRZERO(VAL(aTitGer[nI,10]),12) //030 041 CONTA
				Bcn001D += STRZERO(VAL(aTitGer[nI,11]),1) //042 042 DV CONTA
				Bcn001D += SPACE(1)						  //043 043
				Bcn001D += PAD(Acento(ALLTRIM(IIF(aTitGer[nI,6]='PEN',IIF(!EMPTY(aTitGer[nI,20]),aTitGer[nI,20],aTitGer[nI,19]),aTitGer[nI,3]))),30) //044 073
				Bcn001D += STRZERO(VAL(aTitGer[nI,1]),14)+STRZERO(VAL(aTitGer[nI,2]),6) //074 093
				Bcn001D += Day2Str(aTitGer[nI,5])+Month2Str(aTitGer[nI,5])+Year2Str(aTitGer[nI,5]) //094 101
				Bcn001D += "BRL"  //102 104
				Bcn001D += STRZERO(0,15)//105 119
			    Bcn001D += STRZERO(INT(aTitGer[nI,4]*100),15) //120 134
				Bcn001D += SPACE(20)	//135 154
				Bcn001D += STRZERO(0,23)		//155 177
				Bcn001D += "06" 			//178 179
				Bcn001D += SPACE(18)		//180 197
				Bcn001D += IIf(cTipoPes == "CLT","STE PGTO SALARIO T  ","PGTO FORNECEDORES   ") //198 217
				Bcn001D += "06"              //218 219 
				Bcn001D += SPACE(10)        //220 229
				Bcn001D += "0"              //230 230
				Bcn001D += SPACE(10)        //231 240
				Bcn001D += cCrLf
	
				//Grava Descrição dos campos do Registro “A”
				fWrite(nHandle2,Bcn001D)
	
				nSeq++
				//Descrição dos campos do Registro “B”
		    	Bcn001DB := ""
				Bcn001DB += "001"     //001 003
				Bcn001DB += "0001"    //004 007
				Bcn001DB += "3"       //008 008
				Bcn001DB += STRZERO(nSeq,5) //009 0013
				Bcn001DB += "B"             //014 014
				Bcn001DB += SPACE(3)        //015 017
				Bcn001DB += "1"            //018 018
				Bcn001DB += STRZERO(VAL(aTitGer[nI,12]),14)          //019 032
				Bcn001DB += PAD(ACENTO(ALLTRIM(SM0->M0_ENDCOB)),30) //033 062
				Bcn001DB += "00000"		 	//063 067
				Bcn001DB += PAD(ACENTO(ALLTRIM(SM0->M0_COMPENT)),15) 		//068 082
				Bcn001DB += PAD(ACENTO(ALLTRIM(SM0->M0_BAIRENT)),15) 		//083 097
				Bcn001DB += PAD(ACENTO(ALLTRIM(SM0->M0_CIDCOB)),20) 		//098 117
				Bcn001DB += PAD(SM0->M0_CEPCOB,8) //118 125
				Bcn001DB += PAD(SM0->M0_ESTCOB,2) //126 127
				Bcn001DB += Day2Str(aTitGer[nI,5])+Month2Str(aTitGer[nI,5])+Year2Str(aTitGer[nI,5]) //128 135
				Bcn001DB += STRZERO(INT(aTitGer[nI,4]*100),15)	//136 150
				Bcn001DB += SPACE(90)       //151 240
				Bcn001DB += cCrLf
								
				//Grava Bordero - Descrição dos campos do Registro “B”
				fWrite(nHandle2,Bcn001DB)
	
			 					 						    
				BncoTxt += '<tr>'
				BncoTxt += '<td align="center">'+aTitGer[nI,2]+'</td>'
				BncoTxt += '<td align="center">'+aTitGer[nI,12]+'</td>'
				BncoTxt += '<td align="center">'+aTitGer[nI,3]+IIF(aTitGer[nI,6]='PEN',"- Pensão de -"+aTitGer[nI,19],"")+'</td>'
				BncoTxt += '<td align="center">'+aTitGer[nI,8]+'-'+aTitGer[nI,9]+'</td>'
				BncoTxt += '<td align="center">'+aTitGer[nI,10]+'-'+aTitGer[nI,11]+'</td>'
				BncoTxt += '<td align="center">'+TRANSFORM(aTitGer[nI,4],"@E 999,999,999.99")+'</td>'
				BncoTxt += '</tr>'
	
				cQuery 	:= ""
	    		cQuery 	:= " UPDATE "+RETSQLNAME("SZ2")+" SET Z2_BORDERO = '"+STRZERO(nLote,8)+"' "
				cQuery  += " WHERE R_E_C_N_O_="+STR(aTitGer[nI,18],10)  
	    		TcSqlExec(cQuery)
	
			NEXT
					
			BncoTxtT+= BncoTxt+'<tr><td colspan="6">&nbsp;</td></tr><tr><td colspan="5" align="right">TOTAL DE <b>'+ STR(qTot,6) +'</b> PAGAMENTOS NO VALOR TOTAL DE R$</td><td align="center"><b>'+TRANSFORM(qValTot,"@E 999,999,999.99")+'</b></td></tr></table>'
	
	        //Descrição do Registro “TRAILLER” de lote - “5”
			Bcn001TD := ""
			Bcn001TD += "001"    //001 003
			Bcn001TD += "0001"   //004 007
			Bcn001TD += "5"      //008 008
			Bcn001TD += SPACE(9) //009 017
			Bcn001TD += STRZERO(nSeq+2,6)  //018 023
			Bcn001TD += STRZERO(INT(qValTot*100),18) //024 041
			Bcn001TD += SPACE(199)        //042 240
			Bcn001TD += cCrLf 
		
			//Grava Bordero - Descrição do Registro “TRAILLER” de lote - “5”
			fWrite(nHandle2,Bcn001TD)
	        
	        //Descrição do Registro “TRAILLER” de arquivo - “9”
			//nSeq++
			Bcn001T := ""
			Bcn001T += "001"   //001 003
			Bcn001T += "9999"  //004 007
			Bcn001T += "9"     //008 008
			Bcn001T += SPACE(9) //009 017
			Bcn001T += "000001" //018 023
			Bcn001T += STRZERO(nSeq+4,6) //024 029
			Bcn001T += SPACE(211)      //030 240
			Bcn001T += cCrLf 
						
			//Grava Bordero- Descrição do Registro “TRAILLER” de arquivo - “9”
			fWrite(nHandle2,Bcn001T)
	 
	 		//Fechar Bordero
			fClose(nHandle2)
			
		ELSE
			nSeq := 1
			For nI:=1 To Len(aTitGer)
		 		qValTot += aTitGer[nI,4]
		 		qTot++
				nSeq++
	
				BncoTxtT := cNomeCom+'<BR>RELAÇÃO BANCÁRIA BANCO DO BRASIL '+IIF(nFurnas==1," - FURNAS","")+IIF(nFurnas==2," - FURNAS LOTE BK","")+'<b>Lote: '+STRZERO(nLote,8)+'</b><BR> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=1><i>Emitida em : '+aTitGer[nI,15]+' - pelo usuário : '+aTitGer[nI,13]+'</i><<br>&nbsp;'
			
	 			Bcn001D := ""
				Bcn001D += PAD(Acento(ALLTRIM(IIF(aTitGer[nI,6]='PEN',IIF(!EMPTY(aTitGer[nI,20]),aTitGer[nI,20],aTitGer[nI,19]),aTitGer[nI,3]))),25) //044 073
	 		    Bcn001D += SPACE(5)
	 		    Bcn001D += "1"
	 		    Bcn001D += STRZERO(VAL(aTitGer[nI,12]),11)
	 		    Bcn001D += SPACE(3)
	 		    Bcn001D += Day2Str(aTitGer[nI,5])+Month2Str(aTitGer[nI,5])+Year2Str(aTitGer[nI,5])
	 		    Bcn001D += STRZERO(INT(aTitGer[nI,4]*100),15)
	 		    Bcn001D += "0000"
	 		    Bcn001D += "-"
	 		    Bcn001D += STRZERO(VAL(aTitGer[nI,2]),15)
	 		    Bcn001D += "01"
	 		    Bcn001D += SPACE(2)
			    Bcn001D += IIf(cTipoPes == "CLT","30","20") 
			    Bcn001D += "001"
			    Bcn001D += STRZERO(VAL(aTitGer[nI,8]),4)+aTitGer[nI,9]
			    Bcn001D += STRZERO(VAL(ALLTRIM(aTitGer[nI,10])),10)
			    Bcn001D += ALLTRIM(aTitGer[nI,11])
	 			Bcn001D += "1"
	 			Bcn001D += PAD(Acento(ALLTRIM(SM0->M0_ENDCOB))+" "+Acento(ALLTRIM(SM0->M0_COMPENT)),30)
	 			Bcn001D += PAD(Acento(ALLTRIM(SM0->M0_CIDCOB)),9)
	 			Bcn001D += SPACE(11)
	 			Bcn001D += PAD(SM0->M0_CEPCOB,8)
	 			Bcn001D += "SP"
	 			Bcn001D += "1"
	 			Bcn001D += cCrLf
			 				
	 			//Grava Bordero - Detalhe
	 			fWrite(nHandle2,Bcn001D)
			 					 						    
	 			BncoTxt += '<tr>'
				BncoTxt += '<td align="center">'+aTitGer[nI,2]+'</td>'
				BncoTxt += '<td align="center">'+aTitGer[nI,12]+'</td>'
				BncoTxt += '<td align="center">'+aTitGer[nI,3]+IIF(aTitGer[nI,6]='PEN',"- Pensão de -"+aTitGer[nI,19],"")+'</td>'
				BncoTxt += '<td align="center">'+aTitGer[nI,8]+'-'+aTitGer[nI,9]+'</td>'
				BncoTxt += '<td align="center">'+aTitGer[nI,10]+'-'+aTitGer[nI,11]+'</td>'
				BncoTxt += '<td align="center">'+TRANSFORM(aTitGer[nI,4],"@E 999,999,999.99")+'</td>'
				BncoTxt += '</tr>'
	            
				cQuery 	:= ""
	    		cQuery 	:= " UPDATE "+RETSQLNAME("SZ2")+" SET Z2_BORDERO = '"+STRZERO(nLote,8)+"' "
				cQuery  += " WHERE R_E_C_N_O_="+STR(aTitGer[nI,18],10)  
	    		TcSqlExec(cQuery)
	
			NEXT
			BncoTxtT+= BncoTxt+'<tr><td colspan="6">&nbsp;</td></tr><tr><td colspan="5" align="right">TOTAL DE <b>'+ STR(qTot,6) +'</b> PAGAMENTOS NO VALOR TOTAL DE R$</td><td align="center"><b>'+TRANSFORM(qValTot,"@E 999,999,999.99")+'</b></td></tr></table>'
	 
   
			//Fechar Bordero
			fClose(nHandle2)
	    ENDIF
	ENDIF
	
    /*
    Layout - 400 antigo
	If cBanco == "033"
		nSeq := 1
		Bcn033H := ""
		Bcn033H += "0"
		Bcn033H += "1"
		Bcn033H += "REMESSA"
		Bcn033H += "03"
		Bcn033H += "CREDITO EM C/C"
		Bcn033H += "9574"
		Bcn033H += SPACE(17)
		Bcn033H += PAD(ACENTO(ALLTRIM(SM0->M0_NOMECOM)),30)
		Bcn033H += "033"
		Bcn033H += PAD("BANCO SANTANDER",15)
		Bcn033H += Day2Str(DATE())+Month2Str(DATE())+SUBSTR(Year2Str(DATE()),3,2)
		Bcn033H += "99999"
		Bcn033H += "BPI"
		Bcn033H += "01"
		Bcn033H += SPACE(84)
		Bcn033H += "000001"
		Bcn033H += cCrLf
				
		//Grava Bordero Header
		fWrite(nHandle2,Bcn033H)
		ProcRegua(Len(aTitGer))
		For nI:=1 To Len(aTitGer)
			IncProc("Criando Borderô "+FWEmpName(cEmpAnt)+"...")
			qValTot += aTitGer[nI,4]
			qTot++
			nSeq++
		
			BncoTxtT := ALLTRIM(SM0->M0_NOMECOM)+'<BR>RELAÇÃO BANCÁRIA BANCO SANTANDER '+IIF(nFurnas==1," - FURNAS","")+IIF(nFurnas==2," - FURNAS LOTE BK","")+'<b> Lote: '+STRZERO(nLote,8)+'</b><BR> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=1><i>Emitida em : '+aTitGer[nI,15]+' - pelo usuário : '+aTitGer[nI,13]+'</i><br><br>&nbsp;'
		
		    Bcn033D := ""
			Bcn033D += "1"
			Bcn033D += "02"
			Bcn033D += "03022122000177"
			Bcn033D += "9574"
			Bcn033D += SPACE(16)
			Bcn033D += PAD("CREDITO DE SALARIOS",25)
		    Bcn033D += SUBSTR(STRZERO(VAL(ALLTRIM(aTitGer[nI,8])),4),2,3)
		    Bcn033D += STRZERO(VAL(aTitGer[nI,10]),08)
		    Bcn033D += PAD(aTitGer[nI,11],1)
			Bcn033D += SPACE(8)
			Bcn033D += PAD(Acento(ALLTRIM(IIF(aTitGer[nI,6]='PEN',IIF(!EMPTY(aTitGer[nI,20]),aTitGer[nI,20],aTitGer[nI,19]),aTitGer[nI,3]))),40)
			Bcn033D += Day2Str(DATE())+Month2Str(DATE())+SUBSTR(Year2Str(DATE()),3,2)
		    Bcn033D += STRZERO(INT(ROUND((aTitGer[nI,4])*100,2)),13)
		    Bcn033D += "001"
		    Bcn033D += "021"
		    Bcn033D += SPACE(3)
		    Bcn033D +=  "C"
		    Bcn033D += SPACE(3)
			Bcn033D += PAD(Acento(ALLTRIM(IIF(aTitGer[nI,6]='PEN',IIF(!EMPTY(aTitGer[nI,20]),aTitGer[nI,20],aTitGer[nI,19]),aTitGer[nI,3]))),14)
			Bcn033D += SPACE(26)
			Bcn033D += STRZERO(nSeq,6)
			Bcn033D += cCrLf
							
			//Grava Bordero Detalhe
			fWrite(nHandle2,Bcn033D)
		 					 						    
			BncoTxt += '<tr>'
			BncoTxt += '<td align="center">'+aTitGer[nI,2]+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,12]+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,3]+IIF(aTitGer[nI,6]='PEN',"- Pensão de -"+aTitGer[nI,19],"")+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,8]+'-'+aTitGer[nI,9]+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,10]+'-'+aTitGer[nI,11]+'</td>'
			BncoTxt += '<td align="center">'+TRANSFORM(aTitGer[nI,4],"@E 999,999,999.99")+'</td>'
			BncoTxt += '</tr>'
		NEXT

		BncoTxtT+= BncoTxt+'<tr><td colspan="6">&nbsp;</td></tr><tr><td colspan="5" align="right">TOTAL DE <b>'+ STR(qTot,6) +'</b> PAGAMENTOS NO VALOR TOTAL DE R$</td><td align="center"><b>'+TRANSFORM(qValTot,"@E 999,999,999.99")+'</b></td></tr></table>'

		nSeq++
		Bcn033T := ""
		Bcn033T += "9"
		Bcn033T += SPACE(149)
		Bcn033T += "000000"
		Bcn033T += "000000000000000"
		Bcn033T += STRZERO(qTot,6)
		Bcn033T += STRZERO(INT(ROUND((qValTot)*100,2)),15)
		Bcn033T += SPACE(2)
		Bcn033T += STRZERO(nSeq,6)

		//Grava Bordero Trailer
		fWrite(nHandle2,Bcn033T)
	 
		//Fechar Bordero
		fClose(nHandle2)

	ENDIF
	*/
	If cBanco == "033"
		//Layout Santanter - 240 novo			
		Bcn033H := ""
		Bcn033H += "033"    //001 003
		Bcn033H += "0000"   //004 007
		Bcn033H += "0"               //008 008
		Bcn033H += SPACE(9)          //009 017
		Bcn033H += "2"               //018 018
		Bcn033H += STRZERO(VAL(cCGC),14) //019 032
		Bcn033H += "0033"+STRZERO(VAL(cAgencia),4)+SEE->EE_CODEMP  //033 052
		Bcn033H += STRZERO(VAL(cAgencia),5)    //053 057
		Bcn033H += SPACE(1)   //058 058 DV AGENCIA
		Bcn033H += STRZERO(VAL(cConta),13)  //059 070
		//Bcn033H += STRZERO(VAL(cDVConta),1) //071 071 DV CONTA
		Bcn033H += SPACE(1)	  //072 072 
		Bcn033H += PAD(cNomeCom,30) //073 102
		Bcn033H += PAD("BANCO SANTANDER BANESPA",30)  //103 132
		Bcn033H += SPACE(10)                  //133 142
		Bcn033H += "1"                        //143 143 1-Remessa 2-Retorno
		Bcn033H += Day2Str(DATE())+Month2Str(DATE())+Year2Str(DATE())  //144 151
		cTime := TIME()
		cHora := SUBSTR(cTime, 1, 2)
		cMinutos := SUBSTR(cTime, 4, 2)
		cSegundos := SUBSTR(cTime, 7, 2)
		Bcn033H += cHora+cMinutos+cSegundos      //152 157
		Bcn033H += STRZERO(nLote,6)           //158 163  - LOTE
		Bcn033H += "060"               //164 166  - VERSAO LAYOUT
		Bcn033H += "00000"              //167 171
		Bcn033H += SPACE(20)                     //172 191
		Bcn033H += SPACE(20)                     //192 211
		Bcn033H += SPACE(19)                     //212 230
		Bcn033H += SPACE(10)                     //231 240
		Bcn033H += cCrLf
						
		//Grava Bordero Header
		fWrite(nHandle2,Bcn033H)
	
		Bcn033HD := ""
		Bcn033HD += "033"        //001 003
		Bcn033HD += "0001"       //004 007
		Bcn033HD += "1"          //008 008
		Bcn033HD += "C"          //009 009
		Bcn033HD += IIf(cTipoPes == "CLT","30","20")         //010 011
		Bcn033HD += "01"      	 //012 013
		Bcn033HD += "031"        //014 016
		Bcn033HD += SPACE(1)     //017 017
		Bcn033HD += "2"          //018 018
		Bcn033HD += STRZERO(VAL(cCGC),14) //019 032
		Bcn033HD += "0033"+STRZERO(VAL(cAgencia),4)+SEE->EE_CODEMP  //033 052
		Bcn033HD += STRZERO(VAL(cAgencia),5)    //053 057
		Bcn033HD += SPACE(1)   //058 058
		Bcn033HD += STRZERO(VAL(cConta),13)  //059 070
		//Bcn033HD += STRZERO(VAL(cDVConta),1) //071 071 DV CONTA
		Bcn033HD += SPACE(1)	  //072 072
		Bcn033HD += PAD(cNomeCom,30) //073 102
		Bcn033HD += SPACE(40)   //103 142
		Bcn033HD += PAD(ACENTO(ALLTRIM(SM0->M0_ENDCOB)),30) //143 172
		Bcn033HD += "00000"		 //173 177
		Bcn033HD += PAD(ACENTO(ALLTRIM(SM0->M0_COMPENT)),15) //178 192
		Bcn033HD += PAD(ACENTO(ALLTRIM(SM0->M0_CIDCOB)),20)  //193 212
		Bcn033HD += PAD(SM0->M0_CEPCOB,8)                    //213 220
		Bcn033HD += PAD(SM0->M0_ESTCOB,2)                    //221 222
		Bcn033HD +=  SPACE(8)                                //223 230
		Bcn033HD +=  SPACE(10)                               //231 240
		Bcn033HD += cCrLf
						
		//Grava Bordero Header
		fWrite(nHandle2,Bcn033HD)
		nSeq := 0
		//ProcRegua(Len(aTitGer))
		For nI:=1 To Len(aTitGer)
			//IncProc("Criando Borderô "+FWEmpName(cEmpAnt)+"...")
					
			qValTot += aTitGer[nI,4]
			qTot++
			nSeq++
		
			BncoTxtT := cNomeCom+'<BR>RELAÇÃO BANCÁRIA BANCO SANTANDER '+IIF(nFurnas==1," - FURNAS","")+IIF(nFurnas==2," - FURNAS LOTE BK","")+' <b>Lote: '+STRZERO(nLote,8)+'</b><BR> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=1><i>Emitida em : '+aTitGer[nI,15]+' - pelo usuário : '+aTitGer[nI,13]+'</i><br><br>&nbsp;'

		    Bcn033D := ""
			Bcn033D += "033"     //001 003
			Bcn033D += "0001"    //004 007
			Bcn033D += "3"       //008 008
			Bcn033D += STRZERO(nSeq,5) //009 0013
			Bcn033D += "A"             //014 014
			Bcn033D += "0"             //015 015
			Bcn033D += "00"            //016 017
			Bcn033D += "000"           //018 020
			Bcn033D += "033"           //021 023 
			Bcn033D += STRZERO(VAL(aTitGer[nI,8]),5)  //024 028 AGENCIA
			Bcn033D += SPACE(1)                       //029 029
			Bcn033D += STRZERO(VAL(aTitGer[nI,10]),12)//030 041 CONTA
			Bcn033D += STRZERO(VAL(aTitGer[nI,11]),1) //042 042 DV CONTA
			Bcn033D += SPACE(1)						  //043 043
			Bcn033D += PAD(Acento(ALLTRIM(IIF(aTitGer[nI,6]='PEN',IIF(!EMPTY(aTitGer[nI,20]),aTitGer[nI,20],aTitGer[nI,19]),aTitGer[nI,3]))),30) //044 073
			Bcn033D += "RH"+STRZERO(nSeq,12)+STRZERO(nLote,6) //074 093
			Bcn033D += Day2Str(aTitGer[nI,5])+Month2Str(aTitGer[nI,5])+Year2Str(aTitGer[nI,5]) //094 101
			Bcn033D += "BRL"  //102 104
			Bcn033D += STRZERO(0,15)//105 119
		    Bcn033D += STRZERO(INT(aTitGer[nI,4]*100),15) //120 134
			Bcn033D += SPACE(20)   		//135 154
			Bcn033D += STRZERO(0,8)		//155 162
			Bcn033D += STRZERO(0,15)    //163 177
			Bcn033D += SPACE(40)        //178 217
			Bcn033D += "01" 			//218 219
			Bcn033D += SPACE(10)		//220 229
			Bcn033D += "0"              //230 230
			Bcn033D += SPACE(10)        //231 240
			Bcn033D += cCrLf
							
			//Grava Bordero Detalhe
			fWrite(nHandle2,Bcn033D)
			
			nSeq++
			//Descrição dos campos do Registro “B”
	    	Bcn033DB := ""
			Bcn033DB += "033"     //001 003
			Bcn033DB += "0001"    //004 007
			Bcn033DB += "3"       //008 008
			Bcn033DB += STRZERO(nSeq,5) //009 0013
			Bcn033DB += "B"             //014 014
			Bcn033DB += SPACE(3)        //015 017
			Bcn033DB += "1"            //018 018
			Bcn033DB += STRZERO(VAL(aTitGer[nI,12]),14)          //019 032
			Bcn033DB += PAD(ACENTO(ALLTRIM(SM0->M0_ENDCOB)),30) //033 062
			Bcn033DB += "00000"		 	//063 067
			Bcn033DB += PAD(ACENTO(ALLTRIM(SM0->M0_COMPENT)),15) 		//068 082
			Bcn033DB += PAD(ACENTO(ALLTRIM(SM0->M0_BAIRENT)),15) 		//083 097
			Bcn033DB += PAD(ACENTO(ALLTRIM(SM0->M0_CIDCOB)),20) 		//098 117
			Bcn033DB += PAD(SM0->M0_CEPCOB,8) //118 125
			Bcn033DB += PAD(SM0->M0_ESTCOB,2) //126 127
			Bcn033DB += Day2Str(aTitGer[nI,5])+Month2Str(aTitGer[nI,5])+Year2Str(aTitGer[nI,5]) //128 135
			Bcn033DB += STRZERO(INT(aTitGer[nI,4]*100),15)	//136 150
			Bcn033DB += STRZERO(0,15)	//151 165
			Bcn033DB += STRZERO(0,15)	//166 180
			Bcn033DB += STRZERO(0,15)	//181 195
			Bcn033DB += STRZERO(0,15)	//196 210
			Bcn033DB += STRZERO(0,4)	//211 214
			Bcn033DB += SPACE(11)       //215 225

			//Bcn033DB += '0000'       	//226 229
			//codigo tipo de pagamento Crédito Salário - OLHAR MANUAL PAG 06 e 11
			IF ALLTRIM(aTitGer[nI,22]) = "PJ"
				Bcn033DB += '    '
			ELSE
				IF "PGTOSAL" $ cGRUPO
					Bcn033DB += '2007'       	//226 229 //CRÉDITO DE SALÁRIO
				ELSEIF "FERIAS" $ cGRUPO
					Bcn033DB += '0087'       	//226 229 //FERIAS
				ELSEIF "RESCISAO" $ cGRUPO
					Bcn033DB += '0021'       	//226 229 //RESCISAO
				ELSEIF "13SAL" $ cGRUPO
					Bcn033DB += '2029'       	//226 229 //13 SALÁRIO
				ELSEIF "ADIANT" $ cGRUPO
					Bcn033DB += '2002'       	//226 229 //ADIANTAMENTO
				ELSEIF "PGTO_OUTROS" $ cGRUPO  .OR. "VAL_REFE" $ cGRUPO 
					Bcn033DB += '2002'       	//226 229 // VALE REF OU ALIMENTACAO
				ELSEIF "PENSAO" $ cGrupo
					Bcn033DB += '2002'			// PENSAO: VERIFICAR NO BANCO SANTANDER, NÃO TEM NO MANUAL
				ELSE
					Bcn033DB += '    '
				ENDIF
			ENDIF

			Bcn033DB += SPACE(1)        //230 230
			Bcn033DB += SPACE(10)       //231 240
			Bcn033DB += cCrLf
							
			//Grava Bordero - Descrição dos campos do Registro “B”
			fWrite(nHandle2,Bcn033DB)
			
		 					 						    
			BncoTxt += '<tr>'
			BncoTxt += '<td align="center">'+aTitGer[nI,2]+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,12]+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,3]+IIF(aTitGer[nI,6]='PEN',"- Pensão de -"+aTitGer[nI,19],"")+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,8]+'-'+aTitGer[nI,9]+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,10]+'-'+aTitGer[nI,11]+'</td>'
			BncoTxt += '<td align="center">'+TRANSFORM(aTitGer[nI,4],"@E 999,999,999.99")+'</td>'
			BncoTxt += '</tr>'

			cQuery 	:= ""
    		cQuery 	:= " UPDATE "+RETSQLNAME("SZ2")+" SET Z2_BORDERO = '"+STRZERO(nLote,8)+"' "
			cQuery  += " WHERE R_E_C_N_O_="+STR(aTitGer[nI,18],10)  
    		TcSqlExec(cQuery)

		NEXT
				
		BncoTxtT+= BncoTxt+'<tr><td colspan="6">&nbsp;</td></tr><tr><td colspan="5" align="right">TOTAL DE <b>'+ STR(qTot,6) +'</b> PAGAMENTOS NO VALOR TOTAL DE R$</td><td align="center"><b>'+TRANSFORM(qValTot,"@E 999,999,999.99")+'</b></td></tr></table>'

		nSeq++
		nSeq++
		Bcn033TD := ""
		Bcn033TD += "033"    //001 003
		Bcn033TD += "0001"   //004 007
		Bcn033TD += "5"      //008 008
		Bcn033TD += SPACE(9) //009 017
		Bcn033TD += STRZERO(nSeq,6)  //018 023
		Bcn033TD += STRZERO(INT(qValTot*100),18) //024 041
		Bcn033TD += STRZERO(0,18)     //042 059
		Bcn033TD += STRZERO(0,6)      //060 065
		Bcn033TD += SPACE(165)        //066 230
		Bcn033TD += SPACE(10)         //231 240
		Bcn033TD += cCrLf 
	
		//Grava Bordero Trailer
		fWrite(nHandle2,Bcn033TD)

		nSeq++
		nSeq++
		Bcn033T := ""
		Bcn033T += "033"   //001 003
		Bcn033T += "9999"  //004 007
		Bcn033T += "9"     //008 008
		Bcn033T += SPACE(9) //009 017
		Bcn033T += "000001" //018 023
		Bcn033T += STRZERO(nSeq,6) //024 029
		Bcn033T += SPACE(211)      //030 240
		Bcn033T += cCrLf 
					
		//Grava Bordero Trailer
		fWrite(nHandle2,Bcn033T)
 
 		//Fechar Bordero
		fClose(nHandle2)
	ENDIF


	If cBanco == "104" .AND. nTEDItau == 2
		//Layout CAIXA - 240 - HEADER DE ARQUIVO "0"		
		Bcn104H := ""
		Bcn104H += "104"    				//001 003 - Código do Banco
		Bcn104H += "0000"   				//004 007 - Lote de Serviço
		Bcn104H += "0"               		//008 008 - Código do Registro
		Bcn104H += SPACE(9)          		//009 017 - Filler
		Bcn104H += "2"               		//018 018 - Tipo de inscrição
		Bcn104H += STRZERO(VAL(cCGC),14) 	//019 032 - Número de inscrição
		Bcn104H += SUBSTR(SEE->EE_CODEMP,1,6) //"188161"  //"180327" //010001"  
											//033 038 - Código convênio no Banco
		Bcn104H += IIF(alltrim(cConta)=="0300000043","02","01") //"VA"  
											//039 040  - Parâmetro de Transmissão
		Bcn104H += "P"   					//041 041 - Ambiente Cliente
		Bcn104H += Space(1) 				//042 042 - Ambiente CAIXA
		Bcn104H += Space(3) 				//043 045 - Origem Aplicativo
		Bcn104H += "0000" 					//046 049 - Número de Versão
		Bcn104H += Space(3) 				//050 052 - Filler
		Bcn104H += STRZERO(VAL(cAgencia),5) //053 057 - Agencia da conta corrente
		Bcn104H += STRZERO(VAL(cDVAgenc),1) //058 058 - DV da Agência
		Bcn104H += STRZERO(VAL(cConta),12)  //059 070 - Número da conta
		Bcn104H += STRZERO(VAL(cDVConta),1) //071 071 - DV da conta
		Bcn104H += SPACE(1)	  				//072 072 - DV da agência/conta
		Bcn104H += PAD(cNomeCom,30) 		//073 102 - Nome da empresa
		Bcn104H += PAD("CAIXA",30)  		//103 132 - Nome do Banco
		Bcn104H += SPACE(10)                //133 142 - Filler
		Bcn104H += "1"                      //143 143 - Tipo de Arquivo = 1-Remessa 2-Retorno
		Bcn104H += Day2Str(DATE())+Month2Str(DATE())+Year2Str(DATE())  
											//144 151 - Data geração do arquivo
		cTime := TIME()
		cHora := SUBSTR(cTime, 1, 2)
		cMinutos := SUBSTR(cTime, 4, 2)
		cSegundos := SUBSTR(cTime, 7, 2)
		Bcn104H += cHora+cMinutos+cSegundos	//152 157 - Hora geração do arquivo
		Bcn104H += STRZERO(nLote,6)         //158 163 - NSA - LOTE
		Bcn104H += "080"               		//164 166 - Versão leiaute do arquivo
		Bcn104H += "01600"             		//167 171 - Densidade de gravação
		Bcn104H += SPACE(20)           		//172 191 - Reservado do Banco
		Bcn104H += SPACE(20)           		//192 211 - Reservado da Empresa
		Bcn104H += SPACE(11)           		//212 222 - Uso exclusivo FEBRABAN
		Bcn104H += SPACE(3)            		//223 225 - Ident. Cobrança
		Bcn104H += "000"               		//226 228 - Uso exclusivo das VAN
		Bcn104H += SPACE(2)            		//229 230 - Tipo de serviço
		Bcn104H += SPACE(10)           		//231 240 - Ocorrência Cob. Sem papel
		Bcn104H += cCrLf
						
		//Grava Bordero - HEADER DE ARQUIVO "0"
		fWrite(nHandle2,Bcn104H)
	    nI := 1

	    //- HEADER DE ARQUIVO "1" 
		Bcn104HD := ""
		Bcn104HD += "104"        			//001 003 - Código do Banco
		Bcn104HD += "0001"     				//004 007 - Lote de Serviço
		Bcn104HD += "1"          			//008 008 - Código do Registro
		Bcn104HD += "C"          			//009 009 - Tipo de Operação
		Bcn104HD += IIF(aTitGer[nI,6]='PEN',"98",IIf(cTipoPes == "CLT","30","20"))	//010 011 - Tipo de Serviço
		Bcn104HD += "01"      	 			//012 013 - Forma de Lançamento
		Bcn104HD += "041"        			//014 016 - Versão do leiaute do lote
		Bcn104HD += SPACE(1)     			//017 017 - Filler
		Bcn104HD += "2"          			//018 018 - Tipo de inscrição
		Bcn104HD += STRZERO(VAL(cCGC),14) 	//019 032 - Número da inscrição
		Bcn104HD += SUBSTR(SEE->EE_CODEMP,1,6) //"188161" //"180327"  	//033 038 - Código Convênio no Banco
		Bcn104HD += IIF(aTitGer[nI,6]='PEN',"06",SUBSTR(SEE->EE_CODEMP,7,2)) //"01"//039 040 - Tipo de Compromisso
		Bcn104HD += IIF(aTitGer[nI,6]='PEN',"0003","0003") //"0002" //"0001" //"0002" //041 044 - Código do compromisso
		Bcn104HD += IIF(alltrim(cConta)=="0300000043","02","01") //"01" //"VA"  
											//045 046 - Parâmetro de transmissão
		Bcn104HD += SPACE(6)   				//047 052 - Filler
		Bcn104HD += STRZERO(VAL(cAgencia),5)//053 057 - Agencia da Conta Corrente
		Bcn104HD += STRZERO(VAL(cDVAgenc),1)//058 058 - DV da Agência
		Bcn104HD += STRZERO(VAL(cConta),12) //059 070 - Número da Conta Corrente
		Bcn104HD += STRZERO(VAL(cDVConta),1)//071 071 - DV da Conta Corrente
		Bcn104HD += SPACE(1)	  			//072 072 - Dígito da Agência/Conta
		Bcn104HD += PAD(cNomeCom,30) 		//073 102 - Nome da Empresa
		Bcn104HD += SPACE(40)   			//103 142 - Mensagem de Aviso 1
		Bcn104HD += PAD(ACENTO(ALLTRIM(SM0->M0_ENDCOB)),30) 
											//143 172 - Logradouro
		Bcn104HD += "00000"		 			//173 177 - Número no local
		Bcn104HD += PAD(ACENTO(ALLTRIM(SM0->M0_COMPENT)),15) 
											//178 192 - Complemento
		Bcn104HD += PAD(ACENTO(ALLTRIM(SM0->M0_CIDCOB)),20)  
											//193 212 - Cidade
		Bcn104HD += PAD(SM0->M0_CEPCOB,8)   //213 220 - CEP
		Bcn104HD += PAD(SM0->M0_ESTCOB,2)   //221 222 - Sigla do Estado
		Bcn104HD += SPACE(8)                //223 230 - Uso exclusivo FEBRABAN
		Bcn104HD += SPACE(10)               //231 240 - Ocorrências
		Bcn104HD += cCrLf
						
		//Grava Bordero - Descrição do Registro DETALHE - “A”
		fWrite(nHandle2,Bcn104HD)
		nSeq := 0
		//ProcRegua(Len(aTitGer))
		For nI:=1 To Len(aTitGer)
			//IncProc("Criando Borderô "+FWEmpName(cEmpAnt)+"...")
					
			qValTot += aTitGer[nI,4]
			qTot++
			nSeq++
			BncoTxtT := cNomeCom+'<BR>RELAÇÃO BANCÁRIA BANCO CAIXA ECONOMICA FEDERAL '+IIF(nFurnas==1," - FURNAS","")+IIF(nFurnas==2," - FURNAS LOTE BK","")+' <b> Lote: '+STRZERO(nLote,8)+'</b><BR> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=1><i>Emitida em : '+aTitGer[nI,15]+' - pelo usuário : '+aTitGer[nI,13]+'</i><br><br>&nbsp;'

            //Descrição do Registro DETALHE - “A”
		    Bcn104D := ""
			Bcn104D += "104"     			//001 003 - Código do Banco
			Bcn104D += "0001"    			//004 007 - Lote de Serviço
			Bcn104D += "3"       			//008 008 - Código do registro
			Bcn104D += STRZERO(nSeq,5) 		//009 013 - NSR
			Bcn104D += "A"             		//014 014 - Cód. Segmento
			Bcn104D += "0"             		//015 015 - Tipo Movimento
			Bcn104D += "00"            		//016 017 - Código Instrução Movimento
			Bcn104D += IIF(aTitGer[nI,6]='PEN',"000","700")    //018 020 - Câmara compensação
			Bcn104D += "104"           		//021 023 - Código Banco Destino
			Bcn104D += STRZERO(VAL(aTitGer[nI,8]),5)  //024 028 - Código Agencia Destino
			Bcn104D += PAD(aTitGer[nI,9],1) //029 029 - DV Agência Destino

			//AJUSTE POSICIONAMENTO DA CONTA
			cCONTAF :=""
			cCONTAF :=STRZERO(VAL(aTitGer[nI,10]),12)
			IF SUBSTR(cCONTAF,1,3) == "013"
				cCONTAF := "0013"+SUBSTR(cCONTAF,5,8) 
			ENDIF

			Bcn104D += cCONTAF //030 041 - Conta Corrente Destino 
			Bcn104D += STRZERO(VAL(aTitGer[nI,11]),1) //042 042 - DV Conta Destino
			Bcn104D += SPACE(1)				//043 043 - DV Agência/Conta Destino
			Bcn104D += PAD(Acento(ALLTRIM(IIF(aTitGer[nI,6]='PEN',IIF(!EMPTY(aTitGer[nI,20]),aTitGer[nI,20],aTitGer[nI,19]),aTitGer[nI,3]))),30) 
											//044 073 - Nome do Terceiro (favorecido)
			Bcn104D += STRZERO(nI,6) //SUBSTRING(SEE->EE_CODEMP,1,6) //"188161"//"180327" 
											//074 079 - Número Documento atribuído pela Empresa
			Bcn104D += SPACE(13) 			//080 092 - Filler
			Bcn104D += "0" 					//093 093 - Tipo de conta – Finalidade TED
			Bcn104D += Day2Str(aTitGer[nI,5])+Month2Str(aTitGer[nI,5])+Year2Str(aTitGer[nI,5]) 
											//094 101 - Data Vencimento
			Bcn104D += "BRL"  				//102 104 - Tipo da moeda
			Bcn104D += STRZERO(0,15)		//105 119 - Quantidade de moeda
		    Bcn104D += STRZERO(INT(aTitGer[nI,4]*100),15) 
											//120 134 - Valor Lançamento
			Bcn104D += IIF(aTitGer[nI,6]='PEN',SPACE(9),STRZERO(0,9))			//135 143 - Número Documento Banco
			Bcn104D += SPACE(3)   			//144 146 - Filler
			Bcn104D += "01"   				//147 148 - Quantidade de Parcelas
			Bcn104D += "N"   				//149 149 - Indicador de bloqueio
			Bcn104D += "1"   				//150 150 - Indicador forma parcelamento
			Bcn104D += Day2Str(aTitGer[nI,5])	
											//151 152 - Período ou dia vencimento
			Bcn104D += "00"   				//153 154 - Número Parcela
			Bcn104D += STRZERO(0,8)			//155 162 - Data da Efetivação
			Bcn104D += STRZERO(0,15)    	//163 177 - Valor Real Efetivado
			Bcn104D += SPACE(40)        	//178 217 - Informação 2
			Bcn104D += "00" 				//218 219 - Finalidade DOC
			Bcn104D += SPACE(10)			//220 229 - Uso FEBRABAN
			Bcn104D += "0"              	//230 230 - Aviso ao Favorecido
			Bcn104D += SPACE(10)        	//231 240 - Ocorrências
			Bcn104D += cCrLf
							

			//Grava Descrição dos campos do Registro “A”
			fWrite(nHandle2,Bcn104D)

			nSeq++
			//Descrição dos campos do Registro “B”
	    	Bcn104DB := ""
			Bcn104DB += "104"     			//001 003 - Código do Banco
			Bcn104DB += "0001"    			//004 007 - Lote de Serviço
			Bcn104DB += "3"       			//008 008 - Código do registro
			Bcn104DB += STRZERO(nSeq,5) 	//009 013 - NSR
			Bcn104DB += "B"             	//014 014 - Cód. Segmento
			Bcn104DB += SPACE(3)        	//015 017 - Uso FEBRABAN
			Bcn104DB += "1"            		//018 018 - Tipo Inscrição
			Bcn104DB += STRZERO(VAL(aTitGer[nI,12]),14)          
											//019 032 - Número Inscrição
			Bcn104DB += PAD(ACENTO(ALLTRIM(SM0->M0_ENDCOB)),30) 
											//033 062 - Logradouro
			Bcn104DB += "00000"		 		//063 067 - Número no local
			Bcn104DB += PAD(ACENTO(ALLTRIM(SM0->M0_COMPENT)),15) 		
											//068 082 - Complemento
			Bcn104DB += PAD(ACENTO(ALLTRIM(SM0->M0_BAIRENT)),15) 		
											//083 097 - Bairro
			Bcn104DB += PAD(ACENTO(ALLTRIM(SM0->M0_CIDCOB)),20) 		
											//098 117 - Cidade
			Bcn104DB += PAD(SM0->M0_CEPCOB,8) 
											//118 125 - CEP
			Bcn104DB += PAD(SM0->M0_ESTCOB,2) 
											//126 127 - UF do Estado
			Bcn104DB += Day2Str(aTitGer[nI,5])+Month2Str(aTitGer[nI,5])+Year2Str(aTitGer[nI,5]) 
											//128 135 - Data do Vencimento
			Bcn104DB += STRZERO(0,15)		//136 150 - Valor do Documento
			Bcn104DB += STRZERO(0,15)		//151 165 - Valor do Abatimento
			Bcn104DB += STRZERO(0,15)		//166 180 - Valor do Desconto
			Bcn104DB += STRZERO(0,15)		//181 195 - Valor da Mora
			Bcn104DB += STRZERO(0,15)		//196 210 - Valor da Multa
			Bcn104DB += SPACE(15)       	//211 225 - Código Documento Favorecido
			Bcn104DB += SPACE(15)       	//226 240 - Uso da FEBRABAN
			Bcn104DB += cCrLf
							
			//Grava Bordero - Descrição dos campos do Registro “B”
			fWrite(nHandle2,Bcn104DB)

		 					 						    
			BncoTxt += '<tr>'
			BncoTxt += '<td align="center">'+aTitGer[nI,2]+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,12]+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,3]+IIF(aTitGer[nI,6]='PEN',"- Pensão de -"+aTitGer[nI,19],"")+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,8]+'-'+aTitGer[nI,9]+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,10]+'-'+aTitGer[nI,11]+'</td>'
			BncoTxt += '<td align="center">'+TRANSFORM(aTitGer[nI,4],"@E 999,999,999.99")+'</td>'
			BncoTxt += '</tr>'

			cQuery 	:= ""
    		cQuery 	:= " UPDATE "+RETSQLNAME("SZ2")+" SET Z2_BORDERO = '"+STRZERO(nLote,8)+"' "
			cQuery  += " WHERE R_E_C_N_O_="+STR(aTitGer[nI,18],10)  
    		TcSqlExec(cQuery)

		NEXT
				
		BncoTxtT+= BncoTxt+'<tr><td colspan="6">&nbsp;</td></tr><tr><td colspan="5" align="right">TOTAL DE <b>'+ STR(qTot,6) +'</b> PAGAMENTOS NO VALOR TOTAL DE R$</td><td align="center"><b>'+TRANSFORM(qValTot,"@E 999,999,999.99")+'</b></td></tr></table>'

        //Descrição do Registro “TRAILLER” de lote - “5”
		Bcn104TD := ""
		Bcn104TD += "104"    				//001 003 - Código do Banco
		Bcn104TD += "0001"   				//004 007 - Lote de Serviço
		Bcn104TD += "5"      				//008 008 - Código do registro
		Bcn104TD += SPACE(9) 				//009 017 - Uso exclusivo FEBRABAN
		Bcn104TD += STRZERO(nSeq+2,6)  		//018 023 - Quantidade de Registros no Lote
		Bcn104TD += STRZERO(INT(qValTot*100),18) 
											//024 041 - Somatória dos Valores
		Bcn104TD += STRZERO(0,18)     		//042 059 - Somatório Qtde Moeda
		Bcn104TD += STRZERO(0,6)      		//060 065 - Número Aviso Débito
		Bcn104TD += SPACE(165)        		//066 230 - Uso exclusivo FEBRABAN-2
		Bcn104TD += SPACE(10)         		//231 240 - Ocorrências
		Bcn104TD += cCrLf 
	
		//Grava Bordero - Descrição do Registro “TRAILLER” de lote - “5”
		fWrite(nHandle2,Bcn104TD)
        
        //Descrição do Registro “TRAILLER” de arquivo - “9”
		//nSeq++
		Bcn104T := ""
		Bcn104T += "104"   					//001 003 - Código do Banco
		Bcn104T += "9999"  					//004 007 - Lote de Serviço
		Bcn104T += "9"     					//008 008 - Código do registro
		Bcn104T += SPACE(9) 				//009 017 - Uso exclusivo FEBRABAN
		Bcn104T += "000001" 				//018 023 - Quantidade de Lotes no Arquivo
		Bcn104T += STRZERO(nSeq+4,6) 		//024 029 - Quantidade de Registro do Arquivo
		Bcn104T += STRZERO(0,6)      		//030 035 - Quantidade de Contas para Conciliação
		Bcn104T += SPACE(205)      			//036 240 - Uso exclusivo FEBRABAN
		Bcn104T += cCrLf 
					
		//Grava Bordero- Descrição do Registro “TRAILLER” de arquivo - “9”
		fWrite(nHandle2,Bcn104T)
 
 		//Fechar Bordero
		fClose(nHandle2)
	ENDIF

 
	If cBanco == "151"
					
		nSeq := 1
		Bcn151H := ""
		Bcn151H += "15100000"
		Bcn151H += SPACE(9)
		Bcn151H += "20302212200017721121PPA"
		Bcn151H += SPACE(12)
		Bcn151H += "0084780000040014287"
		Bcn151H += SPACE(1)
		Bcn151H += PAD(cNomeCom,30)
		Bcn151H += PAD("NOSSA CAIXA NOSSO BANCO",25)
		Bcn151H += SPACE(16)
		Bcn151H += "1"
		Bcn151H += Day2Str(DATE())+Month2Str(DATE())+Year2Str(DATE())
		cTime := TIME()
		cHora := SUBSTR(cTime, 1, 2)
		cMinutos := SUBSTR(cTime, 4, 2)
		cSegundos := SUBSTR(cTime, 7, 2)
		Bcn151H += cHora+cMinutos+cSegundos
		Bcn151H += "00"
		Bcn151H += STRZERO(nLote,3)
		Bcn151H += "02000000"
		Bcn151H += SPACE(69)
		Bcn151H += cCrLf
						
		//Grava Bordero Header
		fWrite(nHandle2,Bcn151H)
					
	 
		Bcn151HD := ""
		Bcn151HD += "15100011C3001020"
		Bcn151HD += SPACE(1)
		Bcn151HD += "20302212200017721121PPA"
		Bcn151HD += SPACE(12)
		Bcn151HD += "0084780000040014287"
		Bcn151HD +=  SPACE(1)
		Bcn151HD += PAD(cNomeCom,40)
		Bcn151HD += PAD(ACENTO(ALLTRIM(SM0->M0_ENDCOB)),35)
		Bcn151HD += PAD(ACENTO(ALLTRIM(SM0->M0_COMPENT)),15)
		Bcn151HD += PAD(ACENTO(ALLTRIM(SM0->M0_CIDCOB)),20)
		Bcn151HD += PAD(SM0->M0_CEPCOB,8)
		Bcn151HD += PAD(SM0->M0_ESTCOB,2)
		Bcn151HD +=  SPACE(8)
		Bcn151HD +=  SPACE(10)
		Bcn151HD += cCrLf
				
		//Grava Bordero Header
		fWrite(nHandle2,Bcn151HD)
	
		//ProcRegua(Len(aTitGer))
		For nI:=1 To Len(aTitGer)
			//IncProc("Criando Borderô "+FWEmpName(cEmpAnt)+"...")
					
			qValTot += aTitGer[nI,4]
			qTot++
			nSeq++

			BncoTxtT := cNomeCom+'<BR>RELAÇÃO BANCÁRIA BANCO NOSSA CAIXA NOSSO BANCO '+IIF(nFurnas==1," - FURNAS","")+IIF(nFurnas==2," - FURNAS LOTE BK","")+' <b> Lote: '+STRZERO(nLote,8)+'</b><BR> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=1><i>Emitida em : '+aTitGer[nI,15]+' - pelo usuário : '+aTitGer[nI,13]+'</i><br><br>&nbsp;'
		
			Bcn151D := ""
			Bcn151D += "151"
			Bcn151D += "00001"
			Bcn151D += "3"
			Bcn151D += STRZERO(nSeq,5)
			Bcn151D += "A"
			Bcn151D += "000000"
			Bcn151D += "151"
			Bcn151D += STRZERO(VAL(aTitGer[nI,8]),5)
			Bcn151D += STRZERO(VAL(aTitGer[nI,9]),1)
			Bcn151D += STRZERO(VAL(aTitGer[nI,10]),12)
			Bcn151D += STRZERO(VAL(aTitGer[nI,11]),1)
			Bcn151D += SPACE(1)
			Bcn151D += PAD(Acento(ALLTRIM(IIF(aTitGer[nI,6]='PEN',IIF(!EMPTY(aTitGer[nI,20]),aTitGer[nI,20],aTitGer[nI,19]),aTitGer[nI,3]))),30) 
			Bcn151D += SPACE(20) 
			Bcn151D += Day2Str(aTitGer[nI,5])+Month2Str(aTitGer[nI,5])+Year2Str(aTitGer[nI,5])
			Bcn151D += "BRL"
			Bcn151D += STRZERO(0,15) 
			Bcn151D += STRZERO(INT(aTitGer[nI,4]*100),15)
			Bcn151D += SPACE(20) 
			Bcn151D += STRZERO(0,23) 
			Bcn151D += SPACE(52)
			Bcn151D += "0" 
			Bcn151D += SPACE(10)
			Bcn151D += cCrLf
						
			//Grava Bordero Detalhe
			fWrite(nHandle2,Bcn151D)
		 					 						    
			BncoTxt += '<tr>'
			BncoTxt += '<td align="center">'+aTitGer[nI,2]+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,12]+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,3]+IIF(aTitGer[nI,6]='PEN',"- Pensão de -"+aTitGer[nI,19],"")+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,8]+'-'+aTitGer[nI,9]+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,10]+'-'+aTitGer[nI,11]+'</td>'
			BncoTxt += '<td align="center">'+TRANSFORM(aTitGer[nI,4],"@E 999,999,999.99")+'</td>'
			BncoTxt += '</tr>'

			cQuery 	:= ""
    		cQuery 	:= " UPDATE "+RETSQLNAME("SZ2")+" SET Z2_BORDERO = '"+STRZERO(nLote,8)+"' "
			cQuery  += " WHERE R_E_C_N_O_="+STR(aTitGer[nI,18],10)  
    		TcSqlExec(cQuery)

		NEXT
				
		BncoTxtT+= BncoTxt+'<tr><td colspan="6">&nbsp;</td></tr><tr><td colspan="5" align="right">TOTAL DE <b>'+ STR(qTot,6) +'</b> PAGAMENTOS NO VALOR TOTAL DE R$</td><td align="center"><b>'+TRANSFORM(qValTot,"@E 999,999,999.99")+'</b></td></tr></table>'
	
		nSeq++
		Bcn151TD := ""
		Bcn151TD += "15100015"
		Bcn151TD += SPACE(9) 
		Bcn151TD += STRZERO(nSeq,6)
		Bcn151TD += STRZERO(INT(qValTot*100),18)
		Bcn151TD += SPACE(18) 
		Bcn151TD += SPACE(181)
		Bcn151TD += cCrLf 

		//Grava Bordero Trailer
		fWrite(nHandle2,Bcn151TD)
    
	 
		nSeq++
		Bcn151T := ""
		Bcn151T += "15199999         000001"
		Bcn151T += STRZERO(nSeq,6)
		Bcn151T += "000000"
		Bcn151T += SPACE(205)
		Bcn151T += cCrLf 
						
		//Grava Bordero Trailer
		fWrite(nHandle2,Bcn151T)
	 
	 
		//Fechar Bordero
		fClose(nHandle2)
	ENDIF
	
	If cBanco == "237"
						
		nSeq := 1
		Bcn237H := ""
		Bcn237H += "0"
		Bcn237H += STRZERO(VAL(SEE->EE_CODEMP),8)  //codigo
		Bcn237H += "2"
		Bcn237H += STRZERO(VAL(cCGC),15)
		Bcn237H += PAD(cNomeCom,40)
		Bcn237H += "20"
		Bcn237H += "1"
		Bcn237H += STRZERO(nLote,5)
		Bcn237H += "00000"
		Bcn237H += Year2Str(DATE())+Month2Str(DATE())+Day2Str(DATE())
		cTime := TIME()
		cHora := SUBSTR(cTime, 1, 2)
		cMinutos := SUBSTR(cTime, 4, 2)
		cSegundos := SUBSTR(cTime, 7, 2)
		Bcn237H += cHora+cMinutos+cSegundos 
		Bcn237H += SPACE(13)
		Bcn237H += "0"
		Bcn237H += SPACE(388)
		Bcn237H += STRZERO(nSeq,6)
		Bcn237H += cCrLf
					
		//Grava Bordero Header
		fWrite(nHandle2,Bcn237H)
	
		//ProcRegua(Len(aTitGer))
		For nI:=1 To Len(aTitGer)
			//IncProc("Criando Borderô "+FWEmpName(cEmpAnt)+"...")
 					
			qValTot += aTitGer[nI,4]
			qTot++
			nSeq++
		
			BncoTxtT := cNomeCom+'<BR>RELAÇÃO BANCÁRIA BANCO BRADESCO '+IIF(nFurnas==1," - FURNAS","")+IIF(nFurnas==2," - FURNAS LOTE BK","")+' <b> Lote: '+STRZERO(nLote,8)+'</b><BR> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=1><i>Emitida em : '+aTitGer[nI,15]+' - pelo usuário : '+aTitGer[nI,13]+'</i><br><br>&nbsp;'
		
		    Bcn237D := ""
			Bcn237D += "11"
			Bcn237D += SubStr(STRZERO(VAL(aTitGer[nI,12]),11),1,9)
			Bcn237D += "0000"
			Bcn237D += SubStr(STRZERO(VAL(aTitGer[nI,12]),11),10,2)
			Bcn237D += PAD(Acento(ALLTRIM(IIF(aTitGer[nI,6]='PEN',IIF(!EMPTY(aTitGer[nI,20]),aTitGer[nI,20],aTitGer[nI,19]),aTitGer[nI,3]))),30) 
			Bcn237D += PAD(ACENTO(ALLTRIM(SM0->M0_ENDCOB))+" "+ACENTO(ALLTRIM(SM0->M0_COMPENT)),40)
			Bcn237D += PAD(SM0->M0_CEPCOB,8)
			Bcn237D += STRZERO(VAL(aTitGer[nI,7]),3)
		    Bcn237D += STRZERO(VAL(aTitGer[nI,8]),5)
			Bcn237D += STRZERO(VAL(aTitGer[nI,9]),1)
		    Bcn237D += STRZERO(VAL(ALLTRIM(aTitGer[nI,10])),13)
		    Bcn237D += PAD(aTitGer[nI,11],2)
		    Bcn237D += ""
			Bcn237D += "RH"+STRZERO(nSeq,6)+STRZERO(nLote,8)
			Bcn237D += "000000000000000"
			Bcn237D += SPACE(15)
			Bcn237D += Year2Str(aTitGer[nI,5])+Month2Str(aTitGer[nI,5])+Day2Str(aTitGer[nI,5])
			Bcn237D += "00000000"
			Bcn237D += "00000000"
			Bcn237D += "0"
			Bcn237D += "0000
			Bcn237D += "0000000000"
		    Bcn237D += STRZERO(INT(aTitGer[nI,4]*100),15)
			Bcn237D += "000000000000000000000000000000"
			Bcn237D += "05"
			Bcn237D += "0000000000"
			Bcn237D += SPACE(2)
			Bcn237D += "05" // Tipo Doc
			Bcn237D += Year2Str(aTitGer[nI,5])+Month2Str(aTitGer[nI,5])+Day2Str(aTitGer[nI,5])
			Bcn237D += SPACE(3)
			Bcn237D += "01"
			Bcn237D += SPACE(10)
			Bcn237D += "0"
			Bcn237D += "00"
			Bcn237D += SPACE(122)
			Bcn237D += "11"
			Bcn237D += PAD(Acento(ALLTRIM(IIF(aTitGer[nI,6]='PEN',IIF(!EMPTY(aTitGer[nI,20]),aTitGer[nI,20],aTitGer[nI,19]),aTitGer[nI,3]))),35) 
			Bcn237D += SPACE(22)

//			Bcn237D += "00298" //codigo tipo de pagamento CRÉDITO DE SALÁRIO - OLHAR MANUAL PAG 04
			IF ALLTRIM(aTitGer[nI,22]) = "PJ"
				Bcn237D += "     "
			ELSE
				IF "PGTOSAL" $ cGRUPO
					Bcn237D += "00469"  //CRÉDITO DE SALÁRIO
				ELSEIF "FERIAS" $ cGRUPO
					Bcn237D += "01361" //FERIAS
				ELSEIF "RESCISAO" $ cGRUPO
					Bcn237D += "01654" //RESCISAO
				ELSEIF "13SAL" $ cGRUPO
					Bcn237D += "01360" //13 SALÁRIO
				ELSEIF "ADIANT" $ cGRUPO
					Bcn237D += "01363"  //ADIANTAMENTO
				ELSEIF "PGTO_OUTROS" $ cGRUPO
					Bcn237D += "01363" // VALE REF OU ALIMENTACAO
				ELSEIF "PENSAO" $ cGrupo
					Bcn237D += "01604"
				ELSE 
					Bcn237D += "     "
				ENDIF
			ENDIF

			Bcn237D += " "
			Bcn237D += "1"
			Bcn237D += "0281320"
			Bcn237D += SPACE(8)
			Bcn237D += STRZERO(nSeq,6)
			Bcn237D += cCrLf
							
			//Grava Bordero Detalhe
			fWrite(nHandle2,Bcn237D)
		 					 						    
			BncoTxt += '<tr>'
			BncoTxt += '<td align="center">'+aTitGer[nI,2]+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,12]+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,3]+IIF(aTitGer[nI,6]='PEN',"- Pensão de -"+aTitGer[nI,19],"")+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,8]+'-'+aTitGer[nI,9]+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,10]+'-'+aTitGer[nI,11]+'</td>'
			BncoTxt += '<td align="center">'+TRANSFORM(aTitGer[nI,4],"@E 999,999,999.99")+'</td>'
			BncoTxt += '</tr>'

			cQuery 	:= ""
    		cQuery 	:= " UPDATE "+RETSQLNAME("SZ2")+" SET Z2_BORDERO = '"+STRZERO(nLote,8)+"' "
			cQuery  += " WHERE R_E_C_N_O_="+STR(aTitGer[nI,18],10)  
    		TcSqlExec(cQuery)

		NEXT
				
		BncoTxtT+= BncoTxt+'<tr><td colspan="6">&nbsp;</td></tr><tr><td colspan="5" align="right">TOTAL DE <b>'+ STR(qTot,6) +'</b> PAGAMENTOS NO VALOR TOTAL DE R$</td><td align="center"><b>'+TRANSFORM(qValTot,"@E 999,999,999.99")+'</b></td></tr></table>'
	
		nSeq++
		Bcn237T := ""
		Bcn237T += "9"
		Bcn237T += STRZERO(nSeq,6)
		Bcn237T += STRZERO(INT(qValTot*100),17)
		Bcn237T += SPACE(470)
		Bcn237T += STRZERO(nSeq,6)
		Bcn237T += cCrLf
	
		//Grava Bordero Trailer
		fWrite(nHandle2,Bcn237T)
	 
		//Fechar Bordero
		fClose(nHandle2)
	ENDIF
	
	If cBanco == "341" .OR. nTEDItau == 1
					
		Bcn341H := ""
		Bcn341H += "341"    //001 003
		Bcn341H += "0000"   //004 007
		Bcn341H += "0"               //008 008
		Bcn341H += SPACE(6)          //009 014
		Bcn341H += "080"			 //015 017
		Bcn341H += "2"               //018 018
		Bcn341H += STRZERO(VAL(cCGC),14) //019 032
		Bcn341H += SPACE(20)  //033 052
		Bcn341H += "0"        //053 053
		Bcn341H += STRZERO(VAL(cAgencia),4)      //054 057 Agencia
		Bcn341H += SPACE(1)   //058 058
		Bcn341H += "0000000"  //059 065
		/*
		IF cEmpAnt == "01" 
			Bcn341H += "56105"    //066 070 conta 
			Bcn341H += SPACE(1)   //071 071
			Bcn341H += "8"		  //072 072 DV CONTA
		ELSEIF cEmpAnt == "02"
			Bcn341H += "29090"    //066 070 conta 
			Bcn341H += SPACE(1)   //071 071
			Bcn341H += "0"		  //072 072 DV CONTA
		ELSEIF cEmpAnt == "04"
			Bcn341H += "29099"    //066 070 conta 
			Bcn341H += SPACE(1)   //071 071
			Bcn341H += "1"		  //072 072 DV CONTA
        ELSEIF cEmpAnt == "06" 
			Bcn341H += "56105"    //066 070 conta 
			Bcn341H += SPACE(1)   //071 071
			Bcn341H += "8"		  //072 072 DV CONTA
        ENDIF
        */
        
		Bcn341H += SUBSTR(SEE->EE_CODEMP,1,5)    //066 070 conta 
		Bcn341H += SPACE(1)   //071 071
		Bcn341H += SUBSTR(SEE->EE_CODEMP,6,1) 		  //072 072 DV CONTA


		Bcn341H += PAD(cNomeCom,30) //073 102
		Bcn341H += PAD("BANCO ITAU S.A.",30)  //103 132
		Bcn341H += SPACE(10)                  //133 142
		Bcn341H += "1"                        //143 143
		Bcn341H += Day2Str(DATE())+Month2Str(DATE())+Year2Str(DATE())  //144 151
		cTime := TIME()
		cHora := SUBSTR(cTime, 1, 2)
		cMinutos := SUBSTR(cTime, 4, 2)
		cSegundos := SUBSTR(cTime, 7, 2)
		Bcn341H += cHora+cMinutos+cSegundos      //152 157
		Bcn341H += "00000000000000"              //158 171
		Bcn341H += SPACE(69)                     //172 240
		Bcn341H += cCrLf
						
		//Grava Bordero Header
		fWrite(nHandle2,Bcn341H)
	
		Bcn341HD := ""
		Bcn341HD += "341"        //001 003
		Bcn341HD += "0001"       //004 007
		Bcn341HD += "1"          //008 008
		Bcn341HD += "C"          //009 009
		Bcn341HD += IIf(cTipoPes == "CLT" .AND. nTEDItau == 2,"30","20") //IIF(cBanco=='341',"30","20") //010 011
		Bcn341HD += IIF(nTEDItau == 1,"41","01") //IIf(nTEDItau == 1,"41","01") //IIF(cBanco=='341' .AND. cTipoPes == "CLT","01","41")   //012 013
		Bcn341HD += "040"        //014 016
		Bcn341HD += SPACE(1)     //017 017
		Bcn341HD += "2"          //018 018
		Bcn341HD += STRZERO(VAL(cCGC),14) //019 032
		Bcn341HD += SPACE(13)    //033 045
		Bcn341HD += SPACE(7)	 //046 052
		Bcn341HD += "0"          //053 053
		Bcn341HD += STRZERO(VAL(cAgencia),4)       //054 057 AGENCIA
		Bcn341HD += SPACE(1)     //058 058
		Bcn341HD += "0000000"    //059 065
		/*     D
		IF cEmpAnt == "01" 
			Bcn341HD += "56105"      //066 070 CONTA
			Bcn341HD += SPACE(1)     //071 071 
			Bcn341HD += "8"          //072 072 DV CONTA
		ELSEIF cEmpAnt == "02"
			Bcn341HD += "29090"      //066 070 CONTA
			Bcn341HD += SPACE(1)     //071 071 
			Bcn341HD += "0"          //072 072 DV CONTA
		ELSEIF cEmpAnt == "04"
			Bcn341HD += "29099"      //066 070 CONTA
			Bcn341HD += SPACE(1)     //071 071 
			Bcn341HD += "1"          //072 072 DV CONTA
        ELSEIF cEmpAnt == "06" 
			Bcn341HD += "56105"      //066 070 CONTA
			Bcn341HD += SPACE(1)     //071 071 
			Bcn341HD += "8"          //072 072 DV CONTA
        ENDIF
        */
		Bcn341HD += SUBSTR(SEE->EE_CODEMP,1,5)    //066 070 conta 
		Bcn341HD += SPACE(1)   //071 071
		Bcn341HD += SUBSTR(SEE->EE_CODEMP,6,1) 		  //072 072 DV CONTA

		Bcn341HD += PAD(cNomeCom,30) //073 102
		Bcn341HD += SPACE(40) //103 142 
		Bcn341HD += PAD(ACENTO(ALLTRIM(SM0->M0_ENDCOB)),30)  //143 172
		Bcn341HD += "00000"		                             //173 177
		Bcn341HD += PAD(ACENTO(ALLTRIM(SM0->M0_COMPENT)),15) //178 192
		Bcn341HD += PAD(ACENTO(ALLTRIM(SM0->M0_CIDCOB)),20)  //193 212
		Bcn341HD += PAD(SM0->M0_CEPCOB,8)                    //213 220
		Bcn341HD += PAD(SM0->M0_ESTCOB,2)                    //221 222
		Bcn341HD += SPACE(8)                                 //223 230
		Bcn341HD += SPACE(10)                                //231 240
		Bcn341HD += cCrLf
						
		//Grava Bordero Header
		fWrite(nHandle2,Bcn341HD)
		nSeq := 0
		//ProcRegua(Len(aTitGer))
		For nI:=1 To Len(aTitGer)
			//IncProc("Criando Borderô "+FWEmpName(cEmpAnt)+"...")
					
			qValTot += INT(aTitGer[nI,4]*100)//aTitGer[nI,4]
			qTot++
			nSeq++
		
			BncoTxtT := cNomeCom+'<BR>RELAÇÃO BANCÁRIA BANCO ITAU '+IIF(nFurnas==1," - FURNAS","")+IIF(nFurnas==2," - FURNAS LOTE BK","")+' <b> Lote: '+STRZERO(nLote,8)+'</b><BR> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=1><i>Emitida em : '+aTitGer[nI,15]+' - pelo usuário : '+aTitGer[nI,13]+'</i><br><br>&nbsp;'

		    Bcn341D := ""
			Bcn341D += "341"     					  	//001 003
			Bcn341D += "0001"   					  	//004 007
			Bcn341D += "3"       					  	//008 008
			Bcn341D += STRZERO(nSeq,5)  			  	//009 0013
			Bcn341D += "A"              			  	//014 014
			Bcn341D += IIF(nTedItau==1 .OR. aTitGer[nI,6]='PEN',"000","001")     
									       		      	//015 017 Verificação de dados - CPF 001 verifica, 000 Não verifica
			Bcn341D += "000"            			  	//018 020
			Bcn341D += IIF(nTedItau==1,cTedBco,"341") 	//021 023 
			Bcn341D += "0"              			  	//024 024 COMPLEMENTO DE REGISTRO
			Bcn341D += STRZERO(VAL(aTitGer[nI,8]),4)  	//025 028 NÚMERO AGÊNCIA CREDITADA
			Bcn341D += SPACE(1)                       	//029 029 COMPLEMENTO DE REGISTRO
			//Bcn341D += "000000"							//030 035 COMPLEMENTO DE REGISTRO
			//Bcn341D += SUBSTR(STRZERO(VAL(aTitGer[nI,10]),12),7,6) //036 041 NÚMERO DE C/C CREDITADA 
			Bcn341D += STRZERO(VAL(aTitGer[nI,10]),12)  //030 041 NÚMERO DE C/C CREDITADA 
			Bcn341D += SPACE(1) 						//042 042 COMPLEMENTO DE REGISTRO
			Bcn341D += STRZERO(VAL(aTitGer[nI,11]),1) 	//043 043 DAC DA AGÊNCIA/CONTA CREDITADA
			Bcn341D += PAD(Acento(ALLTRIM(IIF(aTitGer[nI,6]='PEN',IIF(!EMPTY(aTitGer[nI,20]),aTitGer[nI,20],aTitGer[nI,19]),aTitGer[nI,3]))),30) //044 073
			Bcn341D += SPACE(15) 						//074 088
			Bcn341D += SPACE(05) 						//089 093
			Bcn341D += Day2Str(aTitGer[nI,5])+Month2Str(aTitGer[nI,5])+Year2Str(aTitGer[nI,5]) 
														//094 101
			Bcn341D += "REA"  							//102 104
			Bcn341D += STRZERO(0,15)					//105 119
		    Bcn341D += STRZERO(INT(aTitGer[nI,4]*100),15) //120 134
			Bcn341D += SPACE(20)   						//135 154
			Bcn341D += STRZERO(0,8)						//155 162
			Bcn341D += STRZERO(0,15)    				//163 177
			//codigo tipo de pagamento CRÉDITO DE SALÁRIO - OLHAR MANUAL - Março 2013 SISPAG ITAU Febraban 240 PAG 45
			IF ALLTRIM(aTitGer[nI,22]) = "PJ"
				Bcn341D += "    "
			ELSE
				IF "PGTOSAL" $ cGRUPO
					Bcn341D += "HP01"        			//178 181 PAGTO SALARIO
				ELSEIF "FERIAS" $ cGRUPO
					Bcn341D += "HP02"        			//178 181 PAGTO FÉRIAS
				ELSEIF "RESCISAO" $ cGRUPO
					Bcn341D += "HP07"        			//178 181 PAGTO RESCIS CONTRATUAL 
				ELSEIF "13SAL" $ cGRUPO
					Bcn341D += "HP03"        			//178 181 PAGTO 13. SALARIO
				ELSEIF "ADIANT" $ cGRUPO
					Bcn341D += "HP06"        			//178 181 PAGTO ADIANT SALARIAL
				ELSEIF "PGTO_OUTROS" $ cGRUPO
					Bcn341D += "HP06"        			//178 181 PAGTO VALE TRANSPORTE
				ELSEIF "PENSAO" $ cGRUPO
					Bcn341D += "HP10"        			//178 181 PAGTO PENSIONISTA
				ELSE
					Bcn341D += "    "
				ENDIF
			ENDIF

			Bcn341D += SPACE(16)						//182 196
			Bcn341D += STRZERO(VAL(aTitGer[nI,12]),20) 	//197 216
			Bcn341D += SPACE(12)
			Bcn341D += "0" 
			Bcn341D += SPACE(10)
			Bcn341D += cCrLf
							
			//Grava Bordero Detalhe
			fWrite(nHandle2,Bcn341D)
		 					 						    
			BncoTxt += '<tr>'
			BncoTxt += '<td align="center">'+aTitGer[nI,2]+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,12]+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,3]+IIF(aTitGer[nI,6]='PEN',"- Pensão de -"+aTitGer[nI,19],"")+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,8]+'-'+aTitGer[nI,9]+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,10]+'-'+aTitGer[nI,11]+'</td>'
			BncoTxt += '<td align="center">'+TRANSFORM(aTitGer[nI,4],"@E 999,999,999.99")+'</td>'
			BncoTxt += '</tr>'

			cQuery 	:= ""
    		cQuery 	:= " UPDATE "+RETSQLNAME("SZ2")+" SET Z2_BORDERO = '"+STRZERO(nLote,8)+"' "
			cQuery  += " WHERE R_E_C_N_O_="+STR(aTitGer[nI,18],10)  
    		TcSqlExec(cQuery)

		NEXT
				
		BncoTxtT+= BncoTxt+'<tr><td colspan="6">&nbsp;</td></tr><tr><td colspan="5" align="right">TOTAL DE <b>'+ STR(qTot,6) +'</b> PAGAMENTOS NO VALOR TOTAL DE R$</td><td align="center"><b>'+TRANSFORM((qValTot/100),"@E 999,999,999.99")+'</b></td></tr></table>'

		nSeq++
		nSeq++
		Bcn341TD := ""
		Bcn341TD += "341"    //001 003
		Bcn341TD += "0001"   //004 007
		Bcn341TD += "5"      //008 008
		Bcn341TD += SPACE(9) //009 017
		Bcn341TD += STRZERO(nSeq,6)  //018 023
		Bcn341TD += STRZERO(qValTot,18)//STRZERO(INT(qValTot*100),18) //024 041

		Bcn341TD += STRZERO(0,18)     //042 059
		Bcn341TD += SPACE(181)        //060 240
		Bcn341TD += cCrLf 
	
		//Grava Bordero Trailer
		fWrite(nHandle2,Bcn341TD)

		nSeq++
		nSeq++
		Bcn341T := ""
		Bcn341T += "341"   //001 003
		Bcn341T += "9999"  //004 007
		Bcn341T += "9"     //008 008
		Bcn341T += SPACE(9) //009 017
		Bcn341T += "000001" //018 023
		Bcn341T += STRZERO(nSeq,6) //024 029
		Bcn341T += SPACE(211)      //030 240
		Bcn341T += cCrLf 
					
		//Grava Bordero Trailer
		fWrite(nHandle2,Bcn341T)
 
 		//Fechar Bordero
		fClose(nHandle2)
	ENDIF
	
	//Grava e Fechar Doc 
	fWrite(nHandle,BncoTxtT)
	fClose(nHandle)
	cNumBor := ""

	u_WaitLog(cPerg,{|| cNumBor := RunBordero(aCtrId,cBanco,cAgencia,cConta,dData)},"Associando Títulos ao Borderô")
	
	cMsgLog := 'Borderô Nº: '+cNumBor+ ' gerado com sucesso na pasta: "'+cDirTmp2+'"'
	u_MsgLog(cPerg,cMsgLog,"S")

ELSE 
	IF nHandle <> 0
		//cArqTmp := cDirTmp2+"\"+IIF(nFurnas==1,"FURNAS_","")+IIF(nFurnas==2,"FURNAS_LBK_","")+cGrupo+"_"+cBanco+"_"+DTOS(dData)+"\"+IIF(nFurnas==1,"FURNAS_","")+IIF(nFurnas==2,"FURNAS_LBK_","")+"RELACAO_BANCARIA_"+cGrupo+"_"+cBanco+"_"+DTOS(dData)+".DOC"
		cMsgLog := "Falha na criação do arquivo "+cArqTmp
		u_MsgLog(cPerg,cMsgLog,"E")
	ENDIF
	IF nHandle2 <> 0
		//cArqTmp := cDirTmp+"\"+IIF(nFurnas==1,"FURNAS_","")+IIF(nFurnas==2,"FURNAS_LBK_","")+cGrupo+"_"+cBanco+"_"+DTOS(dData)+"\"+IIF(nFurnas==1,"FURNAS_","")+IIF(nFurnas==2,"FURNAS_LBK_","")+"REMESSA_"+cGrupo+"_"+cBanco+"_"+DTOS(dData)+".TXT"
		cMsgLog := "Falha na criação do arquivo "+cArqTmp
		u_MsgLog(cPerg,cMsgLog,"E")
	ENDIF
ENDIF

Return nil 


Static Function GeraQueryTit(dData,cBanco)
LOCAL aCtrId 	:= {}
Local cBcoBor 	:= cBanco
Local cTpPes	:= ""

If nTEDItau  == 1
	cBcoBor := cTedBco
ENDIF

DbSelectArea("SE2")
DbSetOrder(3)
DbGoTop()
dbSeek(xFilial("SE2")+DTOS(dData),.T.)
Do While !eof() .AND. SE2->E2_VENCREAL == dData 
    IF !EMPTY(SE2->E2_XXCTRID) .AND. SE2->E2_VENCREAL == dData  .AND. SE2->E2_VALOR == SE2->E2_SALDO .AND. ALLTRIM(SE2->E2_XXTIPBK) <> 'MFG' .AND.;
		  IIF(cBcoBor=='001' .AND. (nFurnas == 1 .OR. nFurnas == 2) .AND. nTED == 1, ALLTRIM(SE2->E2_PORTADO) $ cBCOTED, SE2->E2_PORTADO == cBcoBor) 
		  // Filtro abaixo removido em 09/12/2019, desta forma, serão incluídos os pagamentos a PJ.
		  //.AND. ( ALLTRIM(SE2->E2_TIPO) <> 'PA' .OR. ( ALLTRIM(SE2->E2_TIPO) == 'PA' .AND. (ALLTRIM(SE2->E2_XXTIPBK) == 'CXA' .OR. ALLTRIM(SE2->E2_XXTIPBK) == 'SOL' .OR. ALLTRIM(SE2->E2_XXTIPBK) == 'HOS')))
		DbSelectArea("SZ2")
		DbSetOrder(3)
		dbSeek(xFilial("SZ2")+cEmpAnt+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO,.T.)
		IF ALLTRIM(SZ2->Z2_TIPOPES) $ "CLT/RPA/PJ"

			If SZ2->Z2_CODEMP = "01" .AND. SZ2->Z2_PRONT = "000296"
				cTpPes := "CLT"
			Else
				cTpPes := SZ2->Z2_TIPOPES
			EndIf

			IF nFurnas == 1
				IF ALLTRIM(SZ2->Z2_CC) == aFURNAS[1]
					IF cBanco=='104'
				   		IF SUBSTR(SZ2->Z2_CONTA,1,2) == "37" .OR. SUBSTR(SZ2->Z2_CONTA,1,3) == "098" .OR. SUBSTR(SZ2->Z2_CONTA,1,2) == "98"
							AADD(aCtrId,{.F.,SE2->E2_XXCTRID,SE2->E2_PORTADO,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_XXTIPBK,DTOC(SE2->E2_EMISSAO),DTOC(SE2->E2_VENCREAL),TRANSFORM(SE2->E2_VALOR,"@E 999,999,999.99"),SE2->E2_NOMFOR,SE2->E2_FORNECE,SE2->E2_LOJA,cTpPes}) 
						ENDIF	
					ELSE
						AADD(aCtrId,{.F.,SE2->E2_XXCTRID,SE2->E2_PORTADO,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_XXTIPBK,DTOC(SE2->E2_EMISSAO),DTOC(SE2->E2_VENCREAL),TRANSFORM(SE2->E2_VALOR,"@E 999,999,999.99"),SE2->E2_NOMFOR,SE2->E2_FORNECE,SE2->E2_LOJA,cTpPes})
					ENDIF
				ENDIF
			ELSEIF nFurnas == 2
				IF ALLTRIM(SZ2->Z2_CC) == aFURNAS[2]
					IF cBanco=='104'
				   		IF SUBSTR(SZ2->Z2_CONTA,1,2) == "37" .OR. SUBSTR(SZ2->Z2_CONTA,1,3) == "098" .OR. SUBSTR(SZ2->Z2_CONTA,1,2) == "98"
							AADD(aCtrId,{.F.,SE2->E2_XXCTRID,SE2->E2_PORTADO,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_XXTIPBK,DTOC(SE2->E2_EMISSAO),DTOC(SE2->E2_VENCREAL),TRANSFORM(SE2->E2_VALOR,"@E 999,999,999.99"),SE2->E2_NOMFOR,SE2->E2_FORNECE,SE2->E2_LOJA,cTpPes}) 
						ENDIF	
					ELSE
						AADD(aCtrId,{.F.,SE2->E2_XXCTRID,SE2->E2_PORTADO,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_XXTIPBK,DTOC(SE2->E2_EMISSAO),DTOC(SE2->E2_VENCREAL),TRANSFORM(SE2->E2_VALOR,"@E 999,999,999.99"),SE2->E2_NOMFOR,SE2->E2_FORNECE,SE2->E2_LOJA,cTpPes})
					ENDIF
				ENDIF
			ELSE
				IF ALLTRIM(SZ2->Z2_CC) <> aFURNAS[1] .and. ALLTRIM(SZ2->Z2_CC) <> aFURNAS[2]
					//IF cBanco=='104'
					//	IF SUBSTR(SZ2->Z2_CONTA,1,2) == "37" .OR. SUBSTR(SZ2->Z2_CONTA,1,3) == "098"
					//		AADD(aCtrId,{.F.,SE2->E2_XXCTRID,SE2->E2_PORTADO,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_XXTIPBK,DTOC(SE2->E2_EMISSAO),DTOC(SE2->E2_VENCREAL),TRANSFORM(SE2->E2_VALOR,"@E 999,999,999.99"),SE2->E2_NOMFOR,SE2->E2_FORNECE,SE2->E2_LOJA,cTpPes}) 
					//	ENDIF	
					//ELSE
						AADD(aCtrId,{.F.,SE2->E2_XXCTRID,SE2->E2_PORTADO,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_XXTIPBK,DTOC(SE2->E2_EMISSAO),DTOC(SE2->E2_VENCREAL),TRANSFORM(SE2->E2_VALOR,"@E 999,999,999.99"),SE2->E2_NOMFOR,SE2->E2_FORNECE,SE2->E2_LOJA,cTpPes})
					//ENDIF
				ENDIF
	    	ENDIF
	    ENDIF
	ENDIF
	SE2->(DbSkip())
Enddo

ASORT(aCtrId,,,{|x,y| x[3]<y[3]})

Return aCtrId


Static Function Acento( cTexto )
Local cAcentos:= "Ç ç Ä À Â Ã Å à á ã ä å É È Ê Ë è é ê ë Ì Í Î Ï Ò Ó Ô Õ Ö ò ó ô õ ö Ù Ú Û Ü ù ú û ü Ñ ñ , ; "
Local cAcSubst:= "C c A A A A A a a a a a E E E E e e e e I I I I O O O O O o o o o o U U U U u u u u N n     "
Local cImpCar := ""
Local cImpLin := ""
Local nChar   := 0.00
Local nChars  := 0.00
Local nAt     := 0.00     

cTexto := IF( Empty( cTexto ) .or. ValType( cTexto ) != "C", "" , cTexto )

nChars := Len( cTexto )
For nChar := 1 To nChars
     cImpCar := SubStr( cTexto , nChar , 1 )
     IF ( nAt := At( cImpCar , cAcentos ) ) > 0
          cImpCar := SubStr( cAcSubst , nAt , 1 )
     EndIF
     cImpLin += cImpCar
Next nChar

Return( cImpLin )



Static Function ValidPerg(cPerg)
Local i,j
Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Data:" ,"Data:"  ,"Data:"  ,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Banco:","Banco:" ,"Banco:" ,"mv_ch2","C",26,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SEE_2"})
AADD(aRegistros,{cPerg,"03","Pasta (Diretório):","Pasta (Diretório):" ,"Pasta (Diretório):" ,"mv_ch3","C",40,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","Furnas:","Furnas:","Furnas" ,"mv_ch4","N",01,0,2,"C","","mv_par04","Lote Emergencial","Lote Emergencial","Lote Emergencial","","","Lote BK","Lote BK","Lote BK","","","Não","Não","Não","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"05","TED Salario:","TED Salario:","TED Salario" ,"mv_ch5","N",01,0,2,"C","","mv_par05","Sim","Sim","Sim","","","Não","Não","Não","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"06","TED pelo ITAU:","TED pelo ITAU:","TED pelo ITAU:" ,"mv_ch6","N",01,0,2,"C","","mv_par06","Sim","Sim","Sim","","","Não","Não","Não","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"07","TED do Banco:","TED do Banco:" ,"TED do Banco:" ,"mv_ch7","C",03,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SA6BCO"})

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




Static Function RunBordero(aCtrId,cBanco,cAgencia,cConta,dData)
Local _nI 		:= 0
Local cNBor 	:= ""
LOCAL cNumBor	:= ""
Local cNumBor2	:= ""

Private lMSHelpAuto := .F.
Private lAutoErrNoFile := .T.

For _nI:=1 To Len(aCtrId)
	dbSelectArea("SE2")
	dbSetOrder(1)
	DBSEEK(xFilial("SE2")+aCtrId[_nI,4]+aCtrId[_nI,5]+aCtrId[_nI,6]+aCtrId[_nI,7]+aCtrId[_nI,13]+aCtrId[_nI,14])
	IF !EMPTY(SE2->E2_NUMBOR) .AND. EMPTY(cNumBor)
		cNumBor := ALLTRIM(SE2->E2_NUMBOR)
	ENDIF
NEXT

IF EMPTY(cNumBor)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica numero do ultimo Bordero Gerado                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNumBor := Soma1(Pad(GetMV("MV_NUMBORP"),Len(SE2->E2_NUMBOR)),Len(SE2->E2_NUMBOR))
	While !MayIUseCode( "E2_NUMBOR"+xFilial("SE2")+cNumBor)  //verifica se esta na memoria, sendo usado
		cNumBor := Soma1(cNumBor)							 // busca o proximo numero disponivel 
	EndDo                                           
ENDIF      

//ProcRegua(Len(aCtrId))
For _nI:=1 To Len(aCtrId)
	IF aCtrId[_nI,1]
		//IncProc("Associando Título ao Borderô "+FWEmpName(cEmpAnt)+"...")
		
		dbSelectArea("SE2")
		dbSetOrder(1)
		DBSEEK(xFilial("SE2")+aCtrId[_nI,4]+aCtrId[_nI,5]+aCtrId[_nI,6]+aCtrId[_nI,7]+aCtrId[_nI,13]+aCtrId[_nI,14])
   		IF EMPTY(SE2->E2_NUMBOR)
			dbSelectArea("SEA")
			RecLock("SEA",.T. )
			Replace	SEA->EA_FILIAL  With xFilial("SEA"),;
					SEA->EA_PORTADO With cBanco,;
					SEA->EA_AGEDEP  With SEE->EE_AGENCIA,;//cAgencia,;
					SEA->EA_NUMCON  With SEE->EE_CONTA,;//cConta,;
					SEA->EA_NUMBOR  With cNumBor,;
					SEA->EA_DATABOR With dData,;
					SEA->EA_PREFIXO With aCtrId[_nI,4],;
					SEA->EA_NUM     With aCtrId[_nI,5],;
					SEA->EA_PARCELA With aCtrId[_nI,6],;
					SEA->EA_TIPO    With aCtrId[_nI,7],;
					SEA->EA_FORNECE With aCtrId[_nI,13],;
					SEA->EA_LOJA	With aCtrId[_nI,14],;
					SEA->EA_CART    With "P",;
					SEA->EA_MODELO  With "01",;
					SEA->EA_TIPOPAG With "98",;
					SEA->EA_SITUANT	With "X",;			
					SEA->EA_FILORIG With SE2->E2_FILIAL
			MsUnlock()
			FKCOMMIT()
	
			RecLock("SE2")
			Replace SE2->E2_NUMBOR  With cNumBor
			MsUnlock( )
			FKCOMMIT()
		ENDIF
	ELSE
		dbSelectArea("SE2")
		dbSetOrder(1)
		DBSEEK(xFilial("SE2")+aCtrId[_nI,4]+aCtrId[_nI,5]+aCtrId[_nI,6]+aCtrId[_nI,7]+aCtrId[_nI,13]+aCtrId[_nI,14])
		IF !EMPTY(SE2->E2_NUMBOR)
			cNumBor2 := ALLTRIM(SE2->E2_NUMBOR)
			RecLock("SE2")
			Replace SE2->E2_NUMBOR  With ""
			MsUnlock( )
			FKCOMMIT()
			dbSelectArea("SEA")
			dbSetOrder(1)
			DBSEEK(xFilial("SE2")+cNumBor2+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA)
			RecLock("SEA",.F.,.T.)
			dbDelete()
			MsUnlock( )
			FKCOMMIT()
		ENDIF
	ENDIF
NEXT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o numero do bordero atualizado                         ³
//³ Utilize sempre GetMv para posicionar o SX6. N„o use SEEK !!! ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*
dbSelectArea("SX6")
GetMv("MV_NUMBORP")
// Garante que o numero do bordero seja sempre superior ao numero anterior
If SX6->X6_CONTEUD < cNumbor
	RecLock("SX6",.F.)
	SX6->X6_CONTEUD := cNumbor
	msUnlock()
EndIf
*/

cNBor := GetMv("MV_NUMBORP")
// Garante que o numero do bordero seja sempre superior ao numero anterior
If cNBor < cNumbor
	PutMv("MV_NUMBORP",cNBor)
EndIf


RETURN cNumBor
