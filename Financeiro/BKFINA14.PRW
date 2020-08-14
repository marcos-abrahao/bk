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

Local oOk
Local oNo
Local oDlg
Local oListId
Local oPanelLeft
Local lAll
Local oAll
Local aButtons := {}

Local aCtrId   := {}
Local lOk      := .F.
Local aAreaIni  := GetArea()
Local cQuery    := ""
Local nI        := 0
Local cTitulo   := "Seleção de Título - Borderô "+ALLTRIM(SM0->M0_NOME)
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
PRIVATE aFurnas := {}
PRIVATE nTedItau:= 2
PRIVATE cTedBco := "104"

aFurnas  := U_StringToArray(ALLTRIM(SuperGetMV("MV_XXFURNAS",.F.,"105000381/105000391")), "/" )

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

cBanco   := SUBSTR(cSEE,1,3)

If nTEDItau == 1 
	IF cBanco <> "341" 
		MSGSTOP("TED Itau diponível apenas para CEF (104)!!","Atenção") 
		Return Nil               
	ELSE
		IF !MsgYesNo("Confirma a geração de pagamentos da CEF no Banco Itau?",cPerg)
			Return Nil               
		ENDIF
	ENDIF
ENDIF

IF dData < dDatabase
	MSGSTOP("Data deve ser maior ou igual que a database!!","Atenção")                
	Return Nil
ENDIF

IF EMPTY(cDirTmp)
	MSGSTOP("Pasta deve ser preenchida!!","Atenção")                
	Return Nil
ENDIF

IF nFurnas == 1
	IF cBanco == "001"
		IF ALLTRIM(cSEE) <> "0013340 5561           00"
			MSGSTOP("Conta Furnas selecionada incorreta!!","Atenção")                
			Return Nil
		ENDIF
	ELSEIF nTED == 1
		MSGSTOP("Banco:"+cBanco+" selecionado para este Tipo PGTO Furnas incorreto!!","Atenção")                
		Return Nil
	ENDIF
ELSEIF nFurnas == 2
	IF cBanco == "001"
		IF ALLTRIM(cSEE) <> "0013340 5562           00"
			MSGSTOP("Conta Furnas Lote BK selecionada incorreta!!","Atenção")                
			Return Nil
		ENDIF
	ELSEIF nTED == 1
		MSGSTOP("Banco:"+cBanco+" selecionado para este Tipo PGTO Furnas Lote BK incorreto!!","Atenção")                
		Return Nil
	ENDIF
ELSE
	IF cBanco == "001"
		IF ALLTRIM(cSEE) == "0013340 5561           00"  .OR. ALLTRIM(cSEE)="0013340 5562           00"
			MSGSTOP("Conta selecionada incorreta!!","Atenção")                
			Return Nil
		ENDIF
	ENDIF
ENDIF

IF (nFurnas==1 .AND. nTED == 1 )  .OR. (nFurnas==2 .AND. nTED == 1 )
   cBancos += cBCOTED
ENDIF

aCtrId := {}
Processa ( {|| aCtrId := GeraQueryTit(dData,cBanco)})

If Empty(aCtrId)
	MsgStop("Não há títulos "+IIF(nFurnas==1," de FURNAS","")+IIF(nFurnas==2," de FURNAS LOTE BK","")+" disponíveis !!", "Atenção")
	RestArea(aAreaIni)
	Return
EndIf

MsgAlert("Verifique a DATA do Bordero!!","Atenção")

oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 450,650 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 330,225
oPanelLeft:Align := CONTROL_ALIGN_LEFT
lAll := .F.
@ 003, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelLeft SIZE 050, 010 PIXEL 
oAll:bChange := {|| Aeval(aCtrId,{|x| IIF(CTOD(x[10]) >= dDatabase .AND. x[3] $ cBancos,x[1]:=lAll,x[1]:=.F.) }), oListId:Refresh()}

@ 015, 005 LISTBOX oListId FIELDS HEADER "","Lote (CTRID)","Banco","Prefixo","Número","Parcela","Tipo","Pgto","Emissão","Vencimento","Total R$","Ref.","Tipo" SIZE 320,180 OF oPanelLeft PIXEL 
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

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , aButtons)
 
If ( lOk )
	aTit1Ger := {}
	aErros  := {}
	For nI:=1 To Len(aCtrId)
	    //Relugarização momentânia numero de CPF para IPT - Definitivo a partir de 01/10/12 - JA ESTA OK  
		IF aCtrId[nI,1]
			cQuery  := " SELECT Z2_CTRID,Z2_E2PRF,Z2_E2NUM,Z2_E2PARC,Z2_E2TIPO,Z2_PRONT,Z2_NOME,Z2_VALOR,Z2_DATAPGT,Z2_TIPO,Z2_NOMDEP,Z2_NOMMAE,"
			cQuery  += " Z2_CODEMP,Z2_TIPOPES,Z2_BANCO,Z2_AGENCIA,Z2_DIGAGEN,Z2_CONTA,Z2_DIGCONT,Z2_CPF,Z2_USUARIO,Z2_HORALIB,Z2_BORDERO,SZ2.R_E_C_N_O_ AS REC "
			cQuery  += " FROM "+RETSQLNAME("SZ2")+" SZ2 "
//			cQuery  += "LEFT JOIN bk_senior.bk_senior.r034fun ON SZ2.Z2_CODEMP = bk_senior.bk_senior.r034fun.numemp AND SZ2.Z2_PRONT=bk_senior.bk_senior.r034fun.numcad "
//			cQuery  += " AND bk_senior.bk_senior.r034fun.nomfun like Z2_NOME+'%' COLLATE SQL_Latin1_General_CP1_CI_AS "
			cQuery  += " WHERE Z2_CODEMP = '"+SM0->M0_CODIGO+"' AND Z2_CTRID = '"+aCtrId[nI,2]+"' "
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
			ProcRegua(LastRec())
			Do While !eof()
				IncProc("Carregando titulos para Borderôs "+ALLTRIM(SM0->M0_NOME)+"...")
 				IF QSZ2->Z2_DATAPGT == dData .AND. QSZ2->Z2_BANCO $ cBancos
					If QSZ2->Z2_CODEMP = "01" .AND. QSZ2->Z2_PRONT = "000296"
						cTpPes := "CLT"
					Else
						cTpPes := QSZ2->Z2_TIPOPES
					EndIf
 					AADD(aTit1Ger,{IIF(EMPTY(QSZ2->Z2_BORDERO),.T.,.F.),QSZ2->Z2_CTRID,QSZ2->Z2_PRONT,QSZ2->Z2_NOME,QSZ2->Z2_VALOR,QSZ2->Z2_DATAPGT,QSZ2->Z2_TIPO,QSZ2->Z2_BANCO,QSZ2->Z2_AGENCIA,QSZ2->Z2_DIGAGEN,QSZ2->Z2_CONTA,QSZ2->Z2_DIGCONT,QSZ2->Z2_CPF,QSZ2->Z2_USUARIO,QSZ2->Z2_E2TIPO,QSZ2->Z2_HORALIB,QSZ2->Z2_BORDERO,aCtrId[nI,9],QSZ2->REC,QSZ2->Z2_NOMDEP,QSZ2->Z2_NOMMAE,cTpPes})
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
	MsgAlert("Verifique a DATA do Bordero!!","Atenção")
Endif

If !EMPTY(aErros)
	For _nI:= 1 To Len(aErros)
		IF aErros[_nI,1] == 1 
			MsgStop("CtrId "+ALLTRIM(SM0->M0_NOME)+TRIM(aErros[_nI,2])+" data de pgto diferente ("+aErros[_nI,4]+"), registro não gerado."+CHR(13)+CHR(10)+"Prontuário: "+aErros[_nI,3]+" - "+aErros[_nI,5], "Atenção")
		ELSEIF aErros[_nI,1] == 2 
			MsgStop("CtrId "+ALLTRIM(SM0->M0_NOME)+TRIM(aErros[_nI,2])+" com layout banco ("+aErros[_nI,3]+") indisponível ", "Atenção")
		ENDIF
	NEXT
EndIf

If !EMPTY(aTit1Ger)
	ASORT(aTit1Ger,,,{|x,y| x[4]<y[4]})
 	Processa ( {|| lOk := ConfTit(aCtrid,dData,cBanco)})
EndIf

RestArea(aAreaIni)
Return
      

Static Function ValidaMrk(lRet,cPgto,cBanco,cBancos)

IF CTOD(cPgto) >= dDataBase  .AND. cBanco $ cBancos
	lRet := !lRet
ELSE
	IF CTOD(cPgto) < dDataBase
   		MsgStop("Data de pgto deste lote é inferior a data base do sistema", "Atenção")
   		lRet := .F.
	ELSE 
   		MsgStop("Layout banco ("+cBanco+") indisponível ", "Atenção")
   		lRet := .F.
 	ENDIF
ENDIF   
Return lRet


STATIC FUNCTION ConfTit(aCtrid,dData,cBanco)
Local oOk
Local oNo
Local oDlg2
Local oListId2
Local oPanelLeft2
Local aButtons 	:= {}
Local aTPCNAB 	:= {}
Local nTPCNAB 	:= 0
Local lOk      	:= .F.
Local nI
Local aTipoPes  := {"CLT","PJ"}
Local nTipoPes  := 0
Local cTipoPes  := ""

PRIVATE aBordero := {} 

AADD(aTPCNAB,{"LPMA/COM/LPM","PGTOSAL"})
AADD(aTPCNAB,{"LFE","FERIAS"})
AADD(aTPCNAB,{"LRC","RESCISAO"})
AADD(aTPCNAB,{"PEN","PENSAO"})
AADD(aTPCNAB,{"LD1/LD2","13SAL"})
AADD(aTPCNAB,{"LAD/LAS","ADIANT"})
AADD(aTPCNAB,{"LDV/RMB/NDB/CXA/PCT/DCH/SOL/HOS/EXM/LFG/MFG/VA/VR/VT/REE","PGTO_OUTROS"})

nTotal := 0

ProcRegua(Len(aTit1Ger))
FOR nI := 1 TO LEN(aTit1Ger)
	IncProc("Gerando Confirmação dos Borderôs "+ALLTRIM(SM0->M0_NOME)+"...")

	IF aTit1Ger[nI,1]
		nTotal += aTit1Ger[nI,5] 
	ENDIF
	//  1        2             3         4       5          6        7      8        9       10       11      12     13     14       15        16               17            18      19    20       21
	// "","Lote (CTRID)","Prontuario","Nome","Valor R$","Dt.PGTO","Tipo","Banco","Agencia","Dg.Ag","Conta","Dg.CC","Cpf","Usuário","Tipo","Data Hora Lib","No. Lote CNAB","Emissão","Reg.","NOMDEP","Z2_NOMMAE"
	nScan:= 0
	nScan:= aScan(aBordero,{|x| x[3]==aTit1Ger[nI,3] .AND. x[6]==aTit1Ger[nI,6] .AND. x[8]==aTit1Ger[nI,8] .AND. x[9]==aTit1Ger[nI,9] .AND. x[11]==aTit1Ger[nI,11] .AND. x[13]==aTit1Ger[nI,13]})
	IF nScan == 0
		AADD(aBordero,aTit1Ger[nI])
	ELSE
		aBordero[nScan,5] += aTit1Ger[nI,5]
	ENDIF

NEXT

oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

DEFINE MSDIALOG oDlg2 TITLE "Confirme os Borderôs a gerar (consolidados)" FROM 000,000 TO 450,650 PIXEL 

@ 000,000 MSPANEL oPanelLeft2 OF oDlg2 SIZE 330,225
oPanelLeft2:Align := CONTROL_ALIGN_LEFT 

lAll:= .F. 
@ 003, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelLeft2 SIZE 050, 010 PIXEL 
oAll:bChange := {|| MudaCell(lAll) , oListId2:Refresh()}

oSay := tSay():New(003,100,{||'Total Selecionado: '+ TransForm(nTotal,"@E 99,999,999.99")},oPanelLeft2,,,,,,.T.,,,200,20)

@ 012, 005 LISTBOX oListID2 FIELDS HEADER "","Lote (CTRID)","Prontuario","Nome","Valor R$","Dt.PGTO","Tipo","Banco","Agencia","Dg.Ag","Conta","Dg.CC","Cpf","Usuário","Tipo","Data Hora Lib","No. Lote CNAB","Emissão","Reg.","NomeDep","NomeMae","Tipo Pes" SIZE 320,180 OF oPanelLeft2 PIXEL 

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

ACTIVATE MSDIALOG oDlg2 CENTERED ON INIT EnchoiceBar(oDlg2,{|| lOk:=.T., oDlg2:End()},{|| oDlg2:End()}, , aButtons)


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
					AADD(aTit,{aBordero[nI,2],aBordero[nI,3],aBordero[nI,4],aBordero[nI,5],aBordero[nI,6],aBordero[nI,7],aBordero[nI,8],aBordero[nI,9],aBordero[nI,10],aBordero[nI,11],aBordero[nI,12],aBordero[nI,13],aBordero[nI,14],aBordero[nI,15],aBordero[nI,16],aBordero[nI,17],aBordero[nI,18],aBordero[nI,19],aBordero[nI,20],aBordero[nI,21],,aBordero[nI,22]})
					lTit := .T.
					nBordero++
				ENDIF
			NEXT nI 
			IF lTit
				Processa ( {|| GravaBordero(aTit,aCtrid,dData,cBanco,aTPCNAB[nTPCNAB,2],cTipoPes)})
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

nTotal := 0

IF lAll
	nAviso := AVISO("Marcar todos - Atenção:","Alguns destes PGTOs ja estão inclusos no Lote CNAB. Deseja gerar novamente ??",{"Sim","Não"})
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
	nAviso := AVISO("Desmarcar todos - Atenção:","Para alguns destes PGTOs NÃO foram gerados lotes ainda.",{"Só os já gerados","Desmarcar todos"})
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
		IF AVISO("Atenção","Este PGTO ja incluso no Lote CNAB: "+cBordero+", enviar novamente??",{"Sim","Não"}) <> 1
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

DbSelectArea("SM0")

//BKDAHER BHG USAR LOTE BK
IF SM0->M0_CODIGO $ "06/08/09/10/11/14/15"
	cQuery  := "SELECT EE_CODIGO,EE_AGENCIA,EE_CONTA,EE_LOTECP "
	cQuery  += " FROM SEE010 "
	cQuery  += " WHERE EE_FILIAL='"+xFILIAL("SEE")+"' AND EE_CODIGO='"+SUBSTR(cSEE,1,3)+"' AND D_E_L_E_T_ = '' "  
	cQuery  += " AND EE_AGENCIA='"+SUBSTR(cSEE,4,5)+"' AND EE_CONTA='"+SUBSTR(cSEE,9,10)+"' AND EE_SUBCTA='"+SUBSTR(cSEE,19,3)+"'"
			
	TCQUERY cQuery NEW ALIAS "QSEE"
			
	DbSelectArea("QSEE")
	DbGoTop()
  
	nLote := VAL(Soma1(QSEE->EE_LOTECP,8))
	QSEE->(DbCloseArea())

    cQuery 	:= " UPDATE SEE010 SET EE_LOTECP = '"+STRZERO(nLote,8)+"' "
	cQuery  += " WHERE EE_FILIAL='"+xFILIAL("SEE")+"' AND EE_CODIGO='"+SUBSTR(cSEE,1,3)+"' AND D_E_L_E_T_ = '' "  
	cQuery  += " AND EE_AGENCIA='"+SUBSTR(cSEE,4,5)+"' AND EE_CONTA='"+SUBSTR(cSEE,9,10)+"' AND EE_SUBCTA='"+SUBSTR(cSEE,19,3)+"'"
    TcSqlExec(cQuery)

ENDIF

DbSelectArea("SEE")
DbSetOrder(1)
IF DbSeek(xFilial("SEE")+cSEE,.F.)
	RecLock("SEE",.F.)                             
	Replace SEE->EE_LOTECP With IIF(SM0->M0_CODIGO $ "06/08/09/10/11/14/15",STRZERO(nLote,8),Soma1(SEE->EE_LOTECP,8))
	SEE->( MsUnlock() )
	nLote := VAL(SEE->EE_LOTECP)
 
	cAgencia  := STRTRAN(SEE->EE_AGENCIA,"-","")
	cDVAgenc  := SEE->EE_DVAGE
	cConta    := STRTRAN(SEE->EE_CONTA,"-","")
	cDVConta  := SEE->EE_DVCTA
	//BKDAHER USAR CNPJ BK
	cCGC      := IIF(SM0->M0_CODIGO $ "06/08/09/10/11/14/15","03022122000177",SM0->M0_CGC)
    cNomeCom  := IIF(SM0->M0_CODIGO $ "06/08/09/10/11/14/15","BK CONSULTORIA E SERVICOS LTDA",Acento(ALLTRIM(SM0->M0_NOMECOM)))
    //***************** 
    IIF(SM0->M0_CODIGO $ "06/08/09/10/11/14/15",MSGINFO("Borderô BKDAHER / BHG CAMPINAS / BHG OSASCO / BHG Taboão / BK DAHER Limeira / BHG INT 3 - Considerando CNPJ BK / Consorcio Nova Balsa !!",cPerg),"")
ELSE
	MSGSTOP("Parâmetro do Banco não cadastrado!!",'Atenção')
	Return nil
ENDIF

MakeDir(cDirTmp2)
/*
IF SM0->M0_CODIGO = "06"
	cDirTmp2 := "\BKDAHER"
ELSEIF SM0->M0_CODIGO = "08"
	cDirTmp2 := "\CAMPINAS" 
ELSEIF SM0->M0_CODIGO = "09"
	cDirTmp2 := "\OSASCO" 
ELSEIF SM0->M0_CODIGO = "10"
	cDirTmp2 := "\TABOAO"
ELSEIF SM0->M0_CODIGO = "11"
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
			Bcn001H += "0008539930126       " //SUBSTRING(SEE->EE_CODEMP,1,6) 033 052
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
			Bcn001HD += "0008539930126       " //SUBSTRING(SEE->EE_CODEMP,1,6) 033 052
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
			ProcRegua(Len(aTitGer))
			For nI:=1 To Len(aTitGer)
				IncProc("Criando Borderô "+ALLTRIM(SM0->M0_NOME)+"...")
						
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
	
				BncoTxtT := cNomeCom+'<BR>RELAÇÃO BANCÁRIA BANCO DO BRASIL '+IIF(nFurnas==1," - FURNAS","")+IIF(nFurnas==2," - FURNAS LOTE BK","")+'<b>Lote: '+STRZERO(nLote,8)+'</b><BR> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=1><i>Emitida em : '+aTitGer[nI,15]+' - pelo usuário : '+aTitGer[nI,13]+'</i><br><br>&nbsp;'
			
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
			IncProc("Criando Borderô "+ALLTRIM(SM0->M0_NOME)+"...")
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
		ProcRegua(Len(aTitGer))
		For nI:=1 To Len(aTitGer)
			IncProc("Criando Borderô "+ALLTRIM(SM0->M0_NOME)+"...")
					
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
		Bcn104H += "104"    //001 003
		Bcn104H += "0000"   //004 007
		Bcn104H += "0"               //008 008
		Bcn104H += SPACE(9)          //009 017
		Bcn104H += "2"               //018 018
		Bcn104H += STRZERO(VAL(cCGC),14) //019 032
		Bcn104H += SUBSTR(SEE->EE_CODEMP,1,6) //"188161"  //"180327" //010001"  //033 038
		Bcn104H += IIF(alltrim(cConta)=="0300000043","02","01") //"VA"  //039 040  ?????????????????????????????????????
		Bcn104H += "P"   //041 041
		Bcn104H += Space(1) //042 042
		Bcn104H += Space(3) //043 045
		Bcn104H += "0000" //046 049
		Bcn104H += Space(3) //050 052
		Bcn104H += STRZERO(VAL(cAgencia),5)   //053 057
		Bcn104H += STRZERO(VAL(cDVAgenc),1)   //058 058 DV AGENCIA
		Bcn104H += STRZERO(VAL(cConta),12)  //059 070
		Bcn104H += STRZERO(VAL(cDVConta),1) //071 071 DV CONTA
		Bcn104H += SPACE(1)	  //072 072 
		Bcn104H += PAD(cNomeCom,30) //073 102
		Bcn104H += PAD("CAIXA",30)  //103 132
		Bcn104H += SPACE(10)                  //133 142
		Bcn104H += "1"                        //143 143 1-Remessa 2-Retorno
		Bcn104H += Day2Str(DATE())+Month2Str(DATE())+Year2Str(DATE())  //144 151
		cTime := TIME()
		cHora := SUBSTR(cTime, 1, 2)
		cMinutos := SUBSTR(cTime, 4, 2)
		cSegundos := SUBSTR(cTime, 7, 2)
		Bcn104H += cHora+cMinutos+cSegundos      //152 157
		Bcn104H += STRZERO(nLote,6)           //158 163  - LOTE
		Bcn104H += "080"               //164 166  - VERSAO LAYOUT
		Bcn104H += "01600"             //167 171
		Bcn104H += SPACE(20)           //172 191
		Bcn104H += SPACE(20)           //192 211
		Bcn104H += SPACE(11)           //212 222
		Bcn104H += SPACE(3)            //223 225
		Bcn104H += "000"               //226 228
		Bcn104H += SPACE(2)            //229 230
		Bcn104H += SPACE(10)           //231 240
		Bcn104H += cCrLf
						
		//Grava Bordero - HEADER DE ARQUIVO "0"
		fWrite(nHandle2,Bcn104H)
	    nI := 1

	    //- HEADER DE ARQUIVO "1" 
		Bcn104HD := ""
		Bcn104HD += "104"        //001 003
		Bcn104HD += "0001"       //004 007
		Bcn104HD += "1"          //008 008
		Bcn104HD += "C"          //009 009
		Bcn104HD += IIf(cTipoPes == "CLT","30","20")         //010 011
		Bcn104HD += "01"      	 //012 013
		Bcn104HD += "041"        //014 016
		Bcn104HD += SPACE(1)     //017 017
		Bcn104HD += "2"          //018 018
		Bcn104HD += STRZERO(VAL(cCGC),14) //019 032
		Bcn104HD += SUBSTR(SEE->EE_CODEMP,1,6) //"188161" //"180327"  //033 038
		Bcn104HD += IIF(aTitGer[nI,6]='PEN',"01",SUBSTR(SEE->EE_CODEMP,7,2)) //"06"  //039 040
		Bcn104HD += IIF(aTitGer[nI,6]='PEN',"0001","0003") //"0002" //"0001" //"0002"  //041 044
		Bcn104HD += IIF(alltrim(cConta)=="0300000043","02","01") //"01" //"VA"  //045 046
		Bcn104HD += SPACE(6)   //047 052
		Bcn104HD += STRZERO(VAL(cAgencia),5)    //053 057
		Bcn104HD += STRZERO(VAL(cDVAgenc),1)    //058 058
		Bcn104HD += STRZERO(VAL(cConta),12)  //059 070
		Bcn104HD += STRZERO(VAL(cDVConta),1) //071 071 DV CONTA
		Bcn104HD += SPACE(1)	  //072 072
		Bcn104HD += PAD(cNomeCom,30) //073 102
		Bcn104HD += SPACE(40)   //103 142
		Bcn104HD += PAD(ACENTO(ALLTRIM(SM0->M0_ENDCOB)),30) //143 172
		Bcn104HD += "00000"		 //173 177
		Bcn104HD += PAD(ACENTO(ALLTRIM(SM0->M0_COMPENT)),15) //178 192
		Bcn104HD += PAD(ACENTO(ALLTRIM(SM0->M0_CIDCOB)),20)  //193 212
		Bcn104HD += PAD(SM0->M0_CEPCOB,8)                    //213 220
		Bcn104HD += PAD(SM0->M0_ESTCOB,2)                    //221 222
		Bcn104HD += SPACE(8)                                 //223 230
		Bcn104HD += SPACE(10)                                //231 240
		Bcn104HD += cCrLf
						
		//Grava Bordero - Descrição do Registro DETALHE - “A”
		fWrite(nHandle2,Bcn104HD)
		nSeq := 0
		ProcRegua(Len(aTitGer))
		For nI:=1 To Len(aTitGer)
			IncProc("Criando Borderô "+ALLTRIM(SM0->M0_NOME)+"...")
					
			qValTot += aTitGer[nI,4]
			qTot++
			nSeq++
			BncoTxtT := cNomeCom+'<BR>RELAÇÃO BANCÁRIA BANCO CAIXA ECONOMICA FEDERAL '+IIF(nFurnas==1," - FURNAS","")+IIF(nFurnas==2," - FURNAS LOTE BK","")+' <b> Lote: '+STRZERO(nLote,8)+'</b><BR> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=1><i>Emitida em : '+aTitGer[nI,15]+' - pelo usuário : '+aTitGer[nI,13]+'</i><br><br>&nbsp;'

            //Descrição do Registro DETALHE - “A”
		    Bcn104D := ""
			Bcn104D += "104"     //001 003
			Bcn104D += "0001"    //004 007
			Bcn104D += "3"       //008 008
			Bcn104D += STRZERO(nSeq,5) //009 0013
			Bcn104D += "A"             //014 014
			Bcn104D += "0"             //015 015
			Bcn104D += "00"            //016 017
			Bcn104D += "700"           //018 020
			Bcn104D += "104"           //021 023 
			Bcn104D += STRZERO(VAL(aTitGer[nI,8]),5)  //024 028 AGENCIA
			Bcn104D += PAD(aTitGer[nI,9],1)           //029 029
//			Bcn104D += "0037" 						  //030 033 Operação Conta
//			Bcn104D += SUBSTR(STRZERO(VAL(aTitGer[nI,10]),12),5,8) //034 041 CONTA
			Bcn104D += STRZERO(VAL(aTitGer[nI,10]),12) //030 041 CONTA
			Bcn104D += STRZERO(VAL(aTitGer[nI,11]),1) //042 042 DV CONTA
			Bcn104D += SPACE(1)						  //043 043
			Bcn104D += PAD(Acento(ALLTRIM(IIF(aTitGer[nI,6]='PEN',IIF(!EMPTY(aTitGer[nI,20]),aTitGer[nI,20],aTitGer[nI,19]),aTitGer[nI,3]))),30) //044 073
			Bcn104D += STRZERO(nI,6) //SUBSTRING(SEE->EE_CODEMP,1,6) //"188161"//"180327" //074 079
			Bcn104D += SPACE(13) //080 092
			Bcn104D += "0" //093 093
			Bcn104D += Day2Str(aTitGer[nI,5])+Month2Str(aTitGer[nI,5])+Year2Str(aTitGer[nI,5]) //094 101
			Bcn104D += "BRL"  //102 104
			Bcn104D += STRZERO(0,15)//105 119
		    Bcn104D += STRZERO(INT(aTitGer[nI,4]*100),15) //120 134
			Bcn104D += STRZERO(0,9)	//135 143
			Bcn104D += SPACE(3)   	//144 146
			Bcn104D += "01"   		//147 148
			Bcn104D += "N"   		//149 149
			Bcn104D += "1"   		//150 150
			Bcn104D += Day2Str(aTitGer[nI,5])	//151 152
			Bcn104D += "00"   		//153 154
			Bcn104D += STRZERO(0,8)		//155 162
			Bcn104D += STRZERO(0,15)    //163 177
			Bcn104D += SPACE(40)        //178 217
			Bcn104D += "00" 			//218 219
			Bcn104D += SPACE(10)		//220 229
			Bcn104D += "0"              //230 230
			Bcn104D += SPACE(10)        //231 240
			Bcn104D += cCrLf
							

			//Grava Descrição dos campos do Registro “A”
			fWrite(nHandle2,Bcn104D)

			nSeq++
			//Descrição dos campos do Registro “B”
	    	Bcn104DB := ""
			Bcn104DB += "104"     //001 003
			Bcn104DB += "0001"    //004 007
			Bcn104DB += "3"       //008 008
			Bcn104DB += STRZERO(nSeq,5) //009 0013
			Bcn104DB += "B"             //014 014
			Bcn104DB += SPACE(3)        //015 017
			Bcn104DB += "1"            //018 018
			Bcn104DB += STRZERO(VAL(aTitGer[nI,12]),14)          //019 032
			Bcn104DB += PAD(ACENTO(ALLTRIM(SM0->M0_ENDCOB)),30) //033 062
			Bcn104DB += "00000"		 	//063 067
			Bcn104DB += PAD(ACENTO(ALLTRIM(SM0->M0_COMPENT)),15) 		//068 082
			Bcn104DB += PAD(ACENTO(ALLTRIM(SM0->M0_BAIRENT)),15) 		//083 097
			Bcn104DB += PAD(ACENTO(ALLTRIM(SM0->M0_CIDCOB)),20) 		//098 117
			Bcn104DB += PAD(SM0->M0_CEPCOB,8) //118 125
			Bcn104DB += PAD(SM0->M0_ESTCOB,2) //126 127
			Bcn104DB += Day2Str(aTitGer[nI,5])+Month2Str(aTitGer[nI,5])+Year2Str(aTitGer[nI,5]) //128 135
			Bcn104DB += STRZERO(0,15)	//136 150
			Bcn104DB += STRZERO(0,15)	//151 165
			Bcn104DB += STRZERO(0,15)	//166 180
			Bcn104DB += STRZERO(0,15)	//181 195
			Bcn104DB += STRZERO(0,15)	//196 210
			Bcn104DB += SPACE(15)       //211 225
			Bcn104DB += SPACE(15)       //226 240
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
		Bcn104TD += "104"    //001 003
		Bcn104TD += "0001"   //004 007
		Bcn104TD += "5"      //008 008
		Bcn104TD += SPACE(9) //009 017
		Bcn104TD += STRZERO(nSeq+2,6)  //018 023
		Bcn104TD += STRZERO(INT(qValTot*100),18) //024 041
		Bcn104TD += STRZERO(0,18)     //042 059
		Bcn104TD += STRZERO(0,6)      //060 065
		Bcn104TD += SPACE(165)        //066 230
		Bcn104TD += SPACE(10)         //231 240
		Bcn104TD += cCrLf 
	
		//Grava Bordero - Descrição do Registro “TRAILLER” de lote - “5”
		fWrite(nHandle2,Bcn104TD)
        
        //Descrição do Registro “TRAILLER” de arquivo - “9”
		//nSeq++
		Bcn104T := ""
		Bcn104T += "104"   //001 003
		Bcn104T += "9999"  //004 007
		Bcn104T += "9"     //008 008
		Bcn104T += SPACE(9) //009 017
		Bcn104T += "000001" //018 023
		Bcn104T += STRZERO(nSeq+4,6) //024 029
		Bcn104T += STRZERO(0,6)      //030 035
		Bcn104T += SPACE(205)      //036 240
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
	
		ProcRegua(Len(aTitGer))
		For nI:=1 To Len(aTitGer)
			IncProc("Criando Borderô "+ALLTRIM(SM0->M0_NOME)+"...")
					
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
	
		ProcRegua(Len(aTitGer))
		For nI:=1 To Len(aTitGer)
			IncProc("Criando Borderô "+ALLTRIM(SM0->M0_NOME)+"...")
 					
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
		IF SM0->M0_CODIGO == "01" 
			Bcn341H += "56105"    //066 070 conta 
			Bcn341H += SPACE(1)   //071 071
			Bcn341H += "8"		  //072 072 DV CONTA
		ELSEIF SM0->M0_CODIGO == "02"
			Bcn341H += "29090"    //066 070 conta 
			Bcn341H += SPACE(1)   //071 071
			Bcn341H += "0"		  //072 072 DV CONTA
		ELSEIF SM0->M0_CODIGO == "04"
			Bcn341H += "29099"    //066 070 conta 
			Bcn341H += SPACE(1)   //071 071
			Bcn341H += "1"		  //072 072 DV CONTA
        ELSEIF SM0->M0_CODIGO == "06" 
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
		Bcn341HD += IIf(cTipoPes == "CLT" .AND. nTEDItau == 2,"30","20")      //010 011
		Bcn341HD += IIf(nTEDItau == 1,"41","01")     	 //012 013
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
		IF SM0->M0_CODIGO == "01" 
			Bcn341HD += "56105"      //066 070 CONTA
			Bcn341HD += SPACE(1)     //071 071 
			Bcn341HD += "8"          //072 072 DV CONTA
		ELSEIF SM0->M0_CODIGO == "02"
			Bcn341HD += "29090"      //066 070 CONTA
			Bcn341HD += SPACE(1)     //071 071 
			Bcn341HD += "0"          //072 072 DV CONTA
		ELSEIF SM0->M0_CODIGO == "04"
			Bcn341HD += "29099"      //066 070 CONTA
			Bcn341HD += SPACE(1)     //071 071 
			Bcn341HD += "1"          //072 072 DV CONTA
        ELSEIF SM0->M0_CODIGO == "06" 
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
		ProcRegua(Len(aTitGer))
		For nI:=1 To Len(aTitGer)
			IncProc("Criando Borderô "+ALLTRIM(SM0->M0_NOME)+"...")
					
			qValTot += aTitGer[nI,4]
			qTot++
			nSeq++
		
			BncoTxtT := cNomeCom+'<BR>RELAÇÃO BANCÁRIA BANCO ITAU '+IIF(nFurnas==1," - FURNAS","")+IIF(nFurnas==2," - FURNAS LOTE BK","")+' <b> Lote: '+STRZERO(nLote,8)+'</b><BR> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=1><i>Emitida em : '+aTitGer[nI,15]+' - pelo usuário : '+aTitGer[nI,13]+'</i><br><br>&nbsp;'

		    Bcn341D := ""
			Bcn341D += "341"     //001 003
			Bcn341D += "0001"    //004 007
			Bcn341D += "3"       //008 008
			Bcn341D += STRZERO(nSeq,5) //009 0013
			Bcn341D += "A"             //014 014
			Bcn341D += "000"           //015 017
			Bcn341D += "000"           //018 020
			Bcn341D += IIF(nTedItau==1,cTedBco,"341")   //021 023 
			Bcn341D += "0"             //024 024
			Bcn341D += STRZERO(VAL(aTitGer[nI,8]),4)  //025 028 AGENCIA
			Bcn341D += SPACE(1)                       //029 029
			Bcn341D += STRZERO(VAL(aTitGer[nI,10]),12)//030 041 CONTA
			Bcn341D += SPACE(1)                       //042 042
			Bcn341D += STRZERO(VAL(aTitGer[nI,11]),1) //043 043 DV CONTA
			Bcn341D += PAD(Acento(ALLTRIM(IIF(aTitGer[nI,6]='PEN',IIF(!EMPTY(aTitGer[nI,20]),aTitGer[nI,20],aTitGer[nI,19]),aTitGer[nI,3]))),30) //044 073
			Bcn341D += SPACE(15) //074 088
			Bcn341D += SPACE(05) //089 093
			Bcn341D += Day2Str(aTitGer[nI,5])+Month2Str(aTitGer[nI,5])+Year2Str(aTitGer[nI,5]) //094 101
			Bcn341D += "REA"  //102 104
			Bcn341D += STRZERO(0,15)//105 119
		    Bcn341D += STRZERO(INT(aTitGer[nI,4]*100),15) //120 134
			Bcn341D += SPACE(20)   		//135 154
			Bcn341D += STRZERO(0,8)		//155 162
			Bcn341D += STRZERO(0,15)    //163 177
			//codigo tipo de pagamento CRÉDITO DE SALÁRIO - OLHAR MANUAL - Março 2013 SISPAG ITAU Febraban 240 PAG 45
			IF ALLTRIM(aTitGer[nI,22]) = "PJ"
				Bcn341D += "    "
			ELSE
				IF "PGTOSAL" $ cGRUPO
					Bcn341D += "HP01"        	//178 181 PAGTO SALARIO
				ELSEIF "FERIAS" $ cGRUPO
					Bcn341D += "HP02"        	//178 181 PAGTO FÉRIAS
				ELSEIF "RESCISAO" $ cGRUPO
					Bcn341D += "HP07"        	//178 181 PAGTO RESCIS CONTRATUAL 
				ELSEIF "13SAL" $ cGRUPO
					Bcn341D += "HP03"        	//178 181 PAGTO 13. SALARIO
				ELSEIF "ADIANT" $ cGRUPO
					Bcn341D += "HP06"        	//178 181 PAGTO ADIANT SALARIAL
				ELSEIF "PGTO_OUTROS" $ cGRUPO
					Bcn341D += "HP06"        	//178 181 PAGTO VALE TRANSPORTE
				ELSEIF "PENSAO" $ cGRUPO
					Bcn341D += "HP10"        	//178 181 PAGTO PENSIONISTA
				ELSE
					Bcn341D += "    "
				ENDIF
			ENDIF

			Bcn341D += SPACE(16)		//182 196
			Bcn341D += STRZERO(VAL(aTitGer[nI,12]),20) //197 216
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
				
		BncoTxtT+= BncoTxt+'<tr><td colspan="6">&nbsp;</td></tr><tr><td colspan="5" align="right">TOTAL DE <b>'+ STR(qTot,6) +'</b> PAGAMENTOS NO VALOR TOTAL DE R$</td><td align="center"><b>'+TRANSFORM(qValTot,"@E 999,999,999.99")+'</b></td></tr></table>'

		nSeq++
		nSeq++
		Bcn341TD := ""
		Bcn341TD += "341"    //001 003
		Bcn341TD += "0001"   //004 007
		Bcn341TD += "5"      //008 008
		Bcn341TD += SPACE(9) //009 017
		Bcn341TD += STRZERO(nSeq,6)  //018 023
		Bcn341TD += STRZERO(INT(qValTot*100),18) //024 041

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
	Processa ( {|| cNumBor := RunBordero(aCtrId,cBanco,cAgencia,cConta,dData)})
	
	MSGINFO('Borderô Nº: '+cNumBor+ ' gerado com sucesso verificar na pasta   "  '+cDirTmp2+'  "    !!',"Atenção")

ELSE
	IF nHandle <> 0
		//cArqTmp := cDirTmp2+"\"+IIF(nFurnas==1,"FURNAS_","")+IIF(nFurnas==2,"FURNAS_LBK_","")+cGrupo+"_"+cBanco+"_"+DTOS(dData)+"\"+IIF(nFurnas==1,"FURNAS_","")+IIF(nFurnas==2,"FURNAS_LBK_","")+"RELACAO_BANCARIA_"+cGrupo+"_"+cBanco+"_"+DTOS(dData)+".DOC"
		MsgAlert("Falha na criação do arquivo "+cArqTmp)
	ENDIF
	IF nHandle2 <> 0
		//cArqTmp := cDirTmp+"\"+IIF(nFurnas==1,"FURNAS_","")+IIF(nFurnas==2,"FURNAS_LBK_","")+cGrupo+"_"+cBanco+"_"+DTOS(dData)+"\"+IIF(nFurnas==1,"FURNAS_","")+IIF(nFurnas==2,"FURNAS_LBK_","")+"REMESSA_"+cGrupo+"_"+cBanco+"_"+DTOS(dData)+".TXT"
		MsgAlert("Falha na criação do arquivo "+cArqTmp)
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
ProcRegua(LastRec())
dbSeek(xFilial("SE2")+DTOS(dData),.T.)
Do While !eof() .AND. SE2->E2_VENCREAL == dData 
	IncProc("Localizando titulos para Borderôs "+ALLTRIM(SM0->M0_NOME)+"...") 
    IF !EMPTY(SE2->E2_XXCTRID) .AND. SE2->E2_VENCREAL == dData  .AND. SE2->E2_VALOR == SE2->E2_SALDO .AND. ALLTRIM(SE2->E2_XXTIPBK) <> 'MFG' .AND.;
		  IIF(cBcoBor=='001' .AND. (nFurnas == 1 .OR. nFurnas == 2) .AND. nTED == 1, ALLTRIM(SE2->E2_PORTADO) $ cBCOTED, SE2->E2_PORTADO == cBcoBor) 
		  // Filtro abaixo removido em 09/12/2019, desta forma, serão incluídos os pagamentos a PJ.
		  //.AND. ( ALLTRIM(SE2->E2_TIPO) <> 'PA' .OR. ( ALLTRIM(SE2->E2_TIPO) == 'PA' .AND. (ALLTRIM(SE2->E2_XXTIPBK) == 'CXA' .OR. ALLTRIM(SE2->E2_XXTIPBK) == 'SOL' .OR. ALLTRIM(SE2->E2_XXTIPBK) == 'HOS')))
		DbSelectArea("SZ2")
		DbSetOrder(3)
		dbSeek(xFilial("SZ2")+SM0->M0_CODIGO+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO,.T.)
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
AADD(aRegistros,{cPerg,"06","TED CEF no ITAU:","TED CEF no ITAU:","TED CEF no ITAU:" ,"mv_ch6","N",01,0,2,"C","","mv_par06","Sim","Sim","Sim","","","Não","Não","Não","","","","","","","","","","","","","","","S","",""})

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
Local _nI := 0
LOCAL cNumBor := "",cNumBor2 := ""

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

ProcRegua(Len(aCtrId))
For _nI:=1 To Len(aCtrId)
	IF aCtrId[_nI,1]
		IncProc("Associando Título ao Borderô "+ALLTRIM(SM0->M0_NOME)+"...")
		
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

dbSelectArea("SX6")
GetMv("MV_NUMBORP")
// Garante que o numero do bordero seja sempre superior ao numero anterior
If SX6->X6_CONTEUD < cNumbor
	RecLock("SX6",.F.)
	SX6->X6_CONTEUD := cNumbor
	msUnlock()
EndIf

RETURN cNumBor
