#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKBXBNCO
BK - Baixa retorno Banco Lancamentos LF

@Return
@author Adilson do Prado
@since 22/08/14
@version P11/P12
/*/

User Function BKBXBNCO()

Local nSnd:= 15,nTLin 	:= 15
Local cTipoArq   		:= "Todos os Arquivos (*.*) | *.* | "
Local oDlg01
Local nOpcA             := 0
Local lOk				:= .F.
Local aDbf 				:= {}
Local oTmpTb

Private aBNC 			:= {}
Private cTitulo			:= "Retorno PGTO Banco"
Private cProg  			:= "BKBXBNCO"
Private cPerg  			:= "BKBXBNCO" 
Private oBanc 
Private cBanc 			:= SPACE(3)
Private cArq  			:= ""
Private cString     	:= "SEE"
Private tamanho     	:= "M"
Private m_pag       	:= 01
Private aReturn     	:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private aTitulos,aCampos,aCabs,aCampos2,aCabs2
Private cLOTE  := ""
Private cAgenc := ""
Private cConta := ""
Private dData  := CTOD("")
Private cHora  := "" 
Private aCtrId := {}
Private aSIM   := {}
Private cSim   := "Não"
Private aFurnas:= {} 
Private cArqTmp

aFurnas  := U_StringToArray(ALLTRIM(SuperGetMV("MV_XXFURNAS",.F.,"105000381/105000391")), "/" )

AADD(aSIM,"Emergencial")
AADD(aSIM,"Lote BK")
AADD(aSIM,"Não")


AADD(aBNC,{"104","Caixa Economica Federal"})

aDbf    := {}
Aadd( aDbf, { 'XX_MAT',  'C', 6,00 } )
Aadd( aDbf, { 'XX_NOME', 'C', 30,00 } ) 
Aadd( aDbf, { 'XX_CPF',	 'C', 14,00 } ) 
Aadd( aDbf, { 'XX_AG',	 'C', 5,00 } ) 
Aadd( aDbf, { 'XX_DA',	 'C', 1,00 } ) 
Aadd( aDbf, { 'XX_CC',	 'C', 15,00 } ) 
Aadd( aDbf, { 'XX_DC',	 'C', 1,00 } ) 
Aadd( aDbf, { 'XX_DTPGT','D', 8,00 } ) 
Aadd( aDbf, { 'XX_VAL',	 'N', 14,2 } ) 
Aadd( aDbf, { 'XX_STATUS','C', 10,00 } )
Aadd( aDbf, { 'XX_CRIT ','C', 200,00 } )


///cArqTmp := CriaTrab( aDbf, .t. )
///dbUseArea( .t.,NIL,cArqTmp,'TRB',.f.,.f. )
///IndRegua("TRB",cArqTmp,"XX_NOME",,,"Indexando Arquivo de Trabalho") 

oTmpTb := FWTemporaryTable():New( 'TRB' )
oTmpTb:SetFields( aDbf )
oTmpTb:AddIndex("indice1", {"XX_NOME"} )
oTmpTb:Create()

aCabs   := {}
aCampos := {}
aTitulos:= {}

nomeprog := "BKBXBNCO/"+TRIM(SUBSTR(cUsuario,7,15))

AADD(aCampos,"TRB->XX_MAT")
AADD(aCabs  ,"Matricula")

AADD(aCampos,"TRB->XX_NOME")
AADD(aCabs  ,"Nome")

AADD(aCampos,"TRB->XX_CPF")
AADD(aCabs  ,"CPF")

AADD(aCampos,"TRB->XX_AG+IIF(!EMPTY(TRB->XX_DA),'-'+TRB->XX_DA,'')")
AADD(aCabs  ,"Agencia")

AADD(aCampos,"TRB->XX_CC+IIF(!EMPTY(TRB->XX_DC),'-'+TRB->XX_DC,'')")
AADD(aCabs  ,"Conta")

AADD(aCampos,"TRB->XX_DTPGT")
AADD(aCabs  ,"Data de PGTO")

AADD(aCampos,"TRB->XX_VAL")
AADD(aCabs  ,"Valor")

AADD(aCampos,"TRB->XX_STATUS")
AADD(aCabs  ,"Status")

AADD(aCampos,"TRB->XX_CRIT")
AADD(aCabs  ,"Ocorrencia(s)")


DEFINE MSDIALOG oDlg01 FROM  96,9 TO 300,320 TITLE OemToAnsi(cProg+" - "+cTitulo) PIXEL

@ nSnd,010 SAY "Banco" SIZE 080,010 Pixel Of oDlg01
@ nSnd,045 MSGET oBanc VAR cBanc SIZE 040,010 OF oDlg01 PIXEL PICTURE '@!' HASBUTTON  F3 "SEE_2" VALID NaoVazio(cBanc)
nSnd += nTLin

@ nSnd,010  SAY "Arquivo " of oDlg01 PIXEL // "Objeto "
@ nSnd,045  MSGET cArq SIZE 100,010 of oDlg01 PIXEL READONLY
nSnd += nTLin

@ nSnd,105 BUTTON oButSel PROMPT 'Selecionar' SIZE 40, 12 OF oDlg01 ACTION ( cArq := cGetFile(cTipoArq,"Selecione arquivos do banco",,cArq,.F.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY,.F.,.T.)  ) PIXEL  // "Selecionar" 
nSnd += nTLin

@ nSnd,010 SAY "Furnas"     SIZE 50,10 OF oDlg01 PIXEL
@ nSnd,045 COMBOBOX cSim   ITEMS aSIM SIZE 100,50 OF oDlg01 PIXEL
nSnd += nTLin
nSnd += nTLin

DEFINE SBUTTON FROM nSnd, 085 TYPE 1 ACTION (oDlg01:End(),nOpcA:=1) ENABLE OF oDlg01
DEFINE SBUTTON FROM nSnd, 115 TYPE 2 ACTION (oDlg01:End(),,nOpcA:=0) ENABLE OF oDlg01


ACTIVATE MSDIALOG oDlg01 CENTER Valid(ValidaBX())

If nOpcA == 1
	nOpcA:=0
	Processa( {|| PROCBXBNC()})	
Endif

oTmpTb:Delete()

RETURN lOk 


Static Function ValidaBX()
Local lOk     := .T.
Local cBuffer := ""
Local cBcoArq := ""

FT_FUSE(cArq)  //abrir
FT_FGOTOP() //vai para o topo
cBuffer := FT_FREADLN()  //lendo a linha

IF cBanc $ "104/237"
	cBcoArq	:= SUBSTR(cBuffer,1,3)
	IF LEN(cBuffer) >= 500
		cBcoArq := "237"
	ENDIF
	IF !cBcoArq $ "104/237"
		MsgStop("Banco informado layout indisponível!!", "Atenção")
		lOk:= .F.
	ENDIF
	IF cBcoArq <> cBanc .AND. cbanc <> "237"
		MsgStop("Banco informado diferente do Arquivo informado!!", "Atenção")
		lOk:= .F.
	ELSE
		IF cBanc == "104"
			IF SUBSTR(cBuffer,143,1) == "2"
				cLOTE  := SUBSTR(cBuffer,158,6)
				cAgenc := SUBSTR(cBuffer,53,5)+"-"+SUBSTR(cBuffer,58,1)
				cConta := SUBSTR(cBuffer,59,12)+"-"+SUBSTR(cBuffer,71,1)
				dData  := CTOD(SUBSTR(cBuffer,144,2)+"/"+SUBSTR(cBuffer,146,2)+"/"+SUBSTR(cBuffer,148,4))
				cHora  := SUBSTR(cBuffer,152,2)+":"+SUBSTR(cBuffer,154,2)+":"+SUBSTR(cBuffer,156,2)
			ELSE
				MsgStop("Arquivo selecionado não é retorno. Verifique!!", "Atenção")
				lOk:= .F.
			ENDIF
		ENDIF
	ENDIF
ELSEIF cBanc == "033"
	lOk:= .F. 
	FT_FGOTOP() //vai para o topo
	Procregua(FT_FLASTREC())  //quantos registros para ler
 	While !FT_FEOF()
		IncProc('Validado Arquivo')
 		//Capturar linha
		cBuffer := FT_FREADLN()  //lendo a linha
		IF SUBSTR(cBuffer,4,3) == "033" .AND. SUBSTR(cBuffer,66,30) == "BK CONSULTORIA E SERVICOS LTDA"
			cLOTE  := SUBSTR(cBuffer,51,6)
			cAgenc := STRZERO(VAL(SUBSTR(cBuffer,14,4)),5)
			cConta := SUBSTR(cBuffer,26,9)+"-"+SUBSTR(cBuffer,35,1)
			dData  := CTOD(SUBSTR(cBuffer,123,10))
			cHora  := "  :  "
			lOk:= .T.
	    ENDIF
		FT_FSKIP()   //proximo registro no arquivo txt
	ENDDO
	IF !lOk 
		MsgStop("Arquivo selecionado não é retorno. Verifique!!", "Atenção")
	ENDIF
ENDIF

FT_FUSE()  //fecha o arquivo txt
 

RETURN lOk 



STATIC FUNCTION PROCBXBNC()
LOCAL cBuffer  := ""
LOCAL c2Buffer := ""
LOCAL cQuery   := ""
Local oOk
Local oNo
Local oDlg
Local oListId
Local oPanelLeft
Local lAll
Local oAll
Local aButtons := {}
Local lOk      := .F.
Local cPicV    := ""

Local cDtVenc,cCPFFav,cNome,cBcFav,cAgFav,cDvAgFav,cCCFav,cDvCCFav,nValFav,cOcorr,cDesOcorr,nCont,cStatus


cPicV 	:= "@E 999,999,999.99"

FT_FUSE(cArq)  //abrir
FT_FGOTOP() //vai para o topo
Procregua(FT_FLASTREC())  //quantos registros para ler
 
While !FT_FEOF()

	IncProc('Carregando Arquivo')
 
	//Capturar dados
	cBuffer := FT_FREADLN()  //lendo a linha
	IF SUBSTR(cBuffer,1,3) == "104" .AND. SUBSTR(cBuffer,14,1) == "A"
		FT_FSKIP()   //proximo registro no arquivo txt
		c2Buffer:= FT_FREADLN() 
	 	dDtpto  := CTOD("")
        dDtpto  := CTOD(SUBSTR(SUBSTR(cBuffer,94,8),1,2)+"/"+SUBSTR(SUBSTR(cBuffer,94,8),3,2)+"/"+SUBSTR(SUBSTR(cBuffer,94,8),5,4))
		cQuery  := "SELECT Z2_PRONT,Z2_DATAPGT,Z2_BANCO,Z2_AGENCIA,Z2_DIGAGEN,Z2_CONTA,Z2_DIGCONT,Z2_CPF"
		cQuery  += " FROM "+RETSQLNAME("SZ2")+" SZ2 "
		cQuery  += "WHERE SZ2.D_E_L_E_T_ = '' AND  Z2_CODEMP = '"+SM0->M0_CODIGO+"' AND Z2_TIPOPES NOT IN ('CLA','AC')" 
		cQuery  += " AND Z2_DATAPGT='"+DTOS(dDtpto)+"' AND Z2_BANCO='"+SUBSTR(cBuffer,1,3)+"'"
		cQuery  += " AND Z2_NOME LIKE '"+ALLTRIM(SUBSTR(cBuffer,44,30))+"%'"
		cQuery  += " AND right('00000'+Z2_AGENCIA,5) = '"+SUBSTR(cBuffer,24,5)+"'"
		cQuery  += " AND right('000000000000'+Z2_CONTA,12)= '"+SUBSTR(cBuffer,30,12)+"'"
		IF SUBSTR(cSim,1,1) == "E"
			cQuery  += " AND Z2_CC = '"+aFURNAS[1]+"'"
		ELSEIF SUBSTR(cSim,1,1) == "L"
			cQuery  += " AND Z2_CC = '"+aFURNAS[2]+"'"
		ELSE
			cQuery  += " AND Z2_CC NOT IN('"+aFURNAS[1]+"','"+aFURNAS[2]+"')"
		ENDIF
        
        // aviso("atenção",cQuery,{"ok"}) 
        
		TCQUERY cQuery NEW ALIAS "QSZ2"
	    
	 	//IF !EMPTY(QSZ2->Z2_PRONT)
			Reclock("TRB",.T.)
			TRB->XX_MAT 	:= QSZ2->Z2_PRONT
			TRB->XX_NOME 	:= SUBSTR(cBuffer,44,30)
			TRB->XX_CPF 	:= SUBSTR(c2Buffer,19,14)
			TRB->XX_AG 		:= SUBSTR(cBuffer,24,5)
			TRB->XX_DA 		:= SUBSTR(cBuffer,29,1)
			TRB->XX_CC 		:= SUBSTR(cBuffer,30,12)
			TRB->XX_DC 		:= SUBSTR(cBuffer,42,1)
			TRB->XX_DTPGT 	:= dDtpto
			TRB->XX_VAL 	:= VAL(SUBSTR(cBuffer,120,15))/100
			//OCORRENCIAS
			cOCORRENCIA := ""
			cOCORRENCIA := ALLTRIM(SUBSTR(cBuffer,231,10))
			nCONT := 1 
			cDESOCORR := ""
			cStatus := ""
			//nLANG	  := 50 - ((10*(LEN(cOCORRENCIA)/2))-10)  
			FOR _IX:=1 TO LEN(cOCORRENCIA)/2
				IF !EMPTY(SUBSTR(cOCORRENCIA,nCONT,2))
					//cDESOCORR += PAD(Posicione("SEB",1,xFilial("SEB")+SUBSTR(cBuffer,1,3)+SUBSTR(cOCORRENCIA,nCONT,2),"EB_DESCRI"),nLANG) 
					cDESOCORR += Posicione("SEB",1,xFilial("SEB")+SUBSTR(cBuffer,1,3)+SUBSTR(cOCORRENCIA,nCONT,2),"EB_DESCRI") 
					cStatus := IIF(SEB->EB_OCORR=="01","Confirmado","Rejeitado")
				ENDIF
				nCONT +=2
			NEXT 
			TRB->XX_STATUS 	:= cStatus
			TRB->XX_CRIT 	:= cDESOCORR
			TRB->(Msunlock()) 
		//ENDIF
		QSZ2->(Dbclosearea())
		
	ELSEIF SUBSTR(cBuffer,4,3) == "033" 
		IF SUBSTR(cBuffer,66,30) <> "BK CONSULTORIA E SERVICOS LTDA" 
        	cBcFav  := SUBSTR(cBuffer,4,3)
        	cAgFav  := STRZERO(VAL(SUBSTR(cBuffer,14,4)),5)
        	cDvAgFav:= ""
        	cCCFav  := STRZERO(VAL(SUBSTR(cBuffer,26,9)),13)
        	cDvCCFav:= SUBSTR(cBuffer,35,1)
       		cNome   := SUBSTR(cBuffer,66,30)
			FT_FSKIP()   //proximo registro no arquivo txt
			cBuffer := FT_FREADLN()
        	cValFav := ""
        	cValFav := SUBSTR(cBuffer,1,23)
        	cValFav := STRTRAN(cValFav,".","")
        	cValFav := STRTRAN(cValFav,",",".")
        	nValFav := VAL(cValFav)
        	cDtVenc := DTOS(CTOD(SUBSTR(cBuffer,37,10)))
        
			cQuery  := "SELECT Z2_PRONT,Z2_DATAPGT,Z2_BANCO,Z2_AGENCIA,Z2_DIGAGEN,Z2_CONTA,Z2_DIGCONT,Z2_CPF"
			cQuery  += " FROM "+RETSQLNAME("SZ2")+" SZ2 "
			cQuery  += "WHERE SZ2.D_E_L_E_T_ = '' AND  Z2_CODEMP = '"+SM0->M0_CODIGO+"' AND Z2_TIPOPES NOT IN ('CLA','AC')" 
			cQuery  += " AND Z2_DATAPGT='"+cDtVenc+"' AND Z2_BANCO='"+cBcFav+"'"
			--cQuery  += " AND Z2_NOME LIKE '"+ALLTRIM(cNome)+"%'"
			cQuery  += " AND right('00000'+Z2_AGENCIA,5) = '"+cAgFav+"'"
			cQuery  += " AND right('0000000000000'+Z2_CONTA,13)= '"+cCCFav+"'"
			IF SUBSTR(cSim,1,1) == "E"
				cQuery  += " AND Z2_CC = '"+aFURNAS[1]+"'"
			ELSEIF SUBSTR(cSim,1,1) == "L"
				cQuery  += " AND Z2_CC = '"+aFURNAS[2]+"'"
			ELSE
				cQuery  += " AND Z2_CC NOT IN('"+aFURNAS[1]+"','"+aFURNAS[2]+"')"
			ENDIF
        
   			TCQUERY cQuery NEW ALIAS "QSZ2"
	    
			Reclock("TRB",.T.)
			TRB->XX_MAT 	:= QSZ2->Z2_PRONT
			TRB->XX_NOME 	:= cNome
			TRB->XX_CPF 	:= QSZ2->Z2_CPF
			TRB->XX_AG 		:= cAgFav
			TRB->XX_DA 		:= cDvAgFav
			TRB->XX_CC 		:= cCCFav
			TRB->XX_DC 		:= cDvCCFav
			TRB->XX_DTPGT 	:= STOD(cDtVenc)
			TRB->XX_VAL 	:= nValFav

			//OCORRENCIAS
			cOcorr    := ""
			nCont     := 1 
			cDesOcorr := ""
			cStatus   := ""
			cStatus := IIF("REGISTRO ACEITO" == ALLTRIM(SUBSTR(cBuffer,70,50)),"Confirmado","Rejeitado") 
		
			TRB->XX_STATUS 	:= cStatus
			TRB->XX_CRIT 	:= cDesOcorr
			TRB->(Msunlock()) 
			QSZ2->(Dbclosearea())
			
		ENDIF

	ELSEIF SUBSTR(cBuffer,1,1) == "0" .AND. LEN(cBuffer) >= 500 // Header Bradesco
		cBuffer := FT_FREADLN() 

	ELSEIF SUBSTR(cBuffer,1,1) == "1" .AND. LEN(cBuffer) >= 500 // Detalhe Bradesco
		
		cBuffer := FT_FREADLN() 
        cDtVenc := SUBSTR(cBuffer,166,8)
        cNome   := SUBSTR(cBuffer,18,30)
        cCPFFav := SUBSTR(cBuffer,3,9)+SUBSTR(cBuffer,16,2)
        cBcFav  := SUBSTR(cBuffer,96,3)
        cAgFav  := SUBSTR(cBuffer,99,5)
        cDvAgFav:= SUBSTR(cBuffer,104,1)
        cCCFav  := SUBSTR(cBuffer,105,13)
        cDvCCFav:= SUBSTR(cBuffer,118,2)
        nValFav := VAL(SUBSTR(cBuffer,205,15))/100
        
		cQuery  := "SELECT Z2_PRONT,Z2_DATAPGT,Z2_BANCO,Z2_AGENCIA,Z2_DIGAGEN,Z2_CONTA,Z2_DIGCONT,Z2_CPF"
		cQuery  += " FROM "+RETSQLNAME("SZ2")+" SZ2 "
		cQuery  += "WHERE SZ2.D_E_L_E_T_ = '' AND  Z2_CODEMP = '"+SM0->M0_CODIGO+"' AND Z2_TIPOPES NOT IN ('CLA','AC')" 
		cQuery  += " AND Z2_DATAPGT='"+cDtVenc+"' AND Z2_BANCO='"+cBcFav+"'"
		//cQuery  += " AND Z2_NOME LIKE '"+ALLTRIM(cNome)+"%'"
		cQuery  += " AND right('00000000000'+Z2_CPF,11) = '"+ALLTRIM(cCPFFav)+"'"
		cQuery  += " AND right('00000'+Z2_AGENCIA,5) = '"+cAgFav+"'"
		cQuery  += " AND right('0000000000000'+Z2_CONTA,13)= '"+cCCFav+"'"
		IF SUBSTR(cSim,1,1) == "E"
			cQuery  += " AND Z2_CC = '"+aFURNAS[1]+"'"
		ELSEIF SUBSTR(cSim,1,1) == "L"
			cQuery  += " AND Z2_CC = '"+aFURNAS[2]+"'"
		ELSE
			cQuery  += " AND Z2_CC NOT IN('"+aFURNAS[1]+"','"+aFURNAS[2]+"')"
		ENDIF
       
        // aviso("atenção",cQuery,{"ok"}) 
        
		TCQUERY cQuery NEW ALIAS "QSZ2"
	    
	    //IF !EMPTY(QSZ2->Z2_PRONT)
			Reclock("TRB",.T.)
			TRB->XX_MAT 	:= QSZ2->Z2_PRONT
			TRB->XX_NOME 	:= cNome
			TRB->XX_CPF 	:= cCPFFav
			TRB->XX_AG 		:= cAgFav
			TRB->XX_DA 		:= cDvAgFav
			TRB->XX_CC 		:= cCCFav
			TRB->XX_DC 		:= cDvCCFav
			TRB->XX_DTPGT 	:= STOD(cDtVenc)
			TRB->XX_VAL 	:= nValFav

			//OCORRENCIAS
			cOcorr    := ALLTRIM(SUBSTR(cBuffer,279,10))
			nCont     := 1 
			cDesOcorr := ""
			cStatus   := "" 
		
			FOR _IX:=1 TO LEN(cOcorr)/2
				IF !EMPTY(SUBSTR(cOcorr,nCont ,2))
					//cDESOCORR += PAD(Posicione("SEB",1,xFilial("SEB")+SUBSTR(cBuffer,1,3)+SUBSTR(cOCORRENCIA,nCONT,2),"EB_DESCRI"),nLANG) 
					cDesOcorr += SUBSTR(cOcorr,nCont,2)+"-"+Posicione("SEB",1,xFilial("SEB")+cBcFav+SUBSTR(cOcorr,nCont,2),"EB_DESCRI")+ " " 
					cStatus   := IIF(SEB->EB_OCORR=="01","Confirmado","Rejeitado")
				ENDIF
				nCont +=2 
			NEXT 
			TRB->XX_STATUS 	:= cStatus
			TRB->XX_CRIT 	:= cDesOcorr
			TRB->(Msunlock()) 
		//ENDIF
		QSZ2->(Dbclosearea())
	ENDIF 

	FT_FSKIP()   //proximo registro no arquivo txt
Enddo
 
FT_FUSE()  //fecha o arquivo txt

aCtrId := {}
DbSelectArea("TRB")
TRB->(Dbgotop())
DO WHILE TRB->(!EOF())
	AADD(aCtrId,{.T.,TRB->XX_MAT,TRB->XX_NOME,TRB->XX_CPF,TRB->XX_AG,TRB->XX_DA,TRB->XX_CC,TRB->XX_DC,TRB->XX_DTPGT,TRB->XX_VAL,TRB->XX_STATUS,TRB->XX_CRIT})
	TRB->(Dbskip())
ENDDO


///TRB->(Dbclosearea())		
///FErase(cArqTmp+GetDBExtension())
///FErase(cArqTmp+OrdBagExt())

IF LEN(aCtrId) == 0
	MSGSTOP("Não há dados "+IIF(SUBSTR(cSim,1,1) == "S"," de FURNAS","")+IIF(SUBSTR(cSim,1,1) == "L"," de FURNAS LOTE BK","")+" no arquivo. Verifique!")
	RETURN NIL
ENDIF

oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )


DEFINE MSDIALOG oDlg TITLE "Selecione o boleto desejado para impressão" FROM 000,000 TO 500,830 PIXEL 

lAll := .T.
@ 012, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelLeft SIZE 080, 010 PIXEL 
oAll:bChange := {|| Aeval(aCtrId,{|x| x[1]:=lAll }), oListId:Refresh()}

@ 022, 005 LISTBOX oListID FIELDS HEADER "","Prontuario","Nome","CPF","Agencia","DA","Conta Corrente","DC","Dt.PGTO","Valor","Status","Ocorrência(s)" SIZE 410,220 OF oPanelLeft PIXEL 


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
                         TRANSFORM(aCtrId[oListId:nAt][10],cPicV  ),;
                         aCtrId[oListId:nAt][11],;
                         aCtrId[oListId:nAt][12]}}

oListID:bLDblClick := {|| aCtrId[oListId:nAt][1] := IIF(aCtrId[oListId:nAt][1],.F.,.T.), oListID:DrawSelect()}


ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| lOk:=.F., oDlg:End()}, , aButtons)

If ( lOk )
	lOk:=.F.
	Processa( {|| U_RBKBXBNCO()})
ENDIF	


RETURN


User Function RBKBXBNCO()
Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de acordo com os parametros informados pelo usuario."
Local cDesc3        := ""
Local nLin          := 80
Local Cabec1        := ""
Local Cabec2        := ""
Local aOrd          := {}
Local titulo        := ""

    nScan:= 0
    nScan:= aScan(aBNC,{|x| x[1]== cBanc })
    IF nScan<>0
		titulo := "Retorno PGTO Banco "+aBNC[nScan,2]
    ELSE
		titulo := "Retorno PGTO Banco "
    ENDIF
    
    titulo += IIF(SUBSTR(cSim,1,1) == "S"," - FURNAS","")+IIF(SUBSTR(cSim,1,1) == "L"," - FURNAS LOTE BK","")
                                     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	wnrel := SetPrint(cString,"BKBXBNCO",cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.) 
	
	If nLastKey == 27
		Return
	Endif
	
   	SetDefault(aReturn,cString)
	
	If nLastKey == 27
	   Return
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)
	            
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	m_pag   := 01 
	
RETURN






/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  08/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local nTotLot   := 0
Local nRegistro := 0

nEsp    := 2
cPicQ 	:= "@E 99999999"
cPicV 	:= "@E 999,999,999.99"
Cabec1  := "Agencia: "+cAgenc+" Conta: "+cConta+" Lote: "+cLOTE+"  Data: "+DTOC(dData)+" Hora: "+cHora 
Cabec2  := "Pront.  Nome                            CPF              Agencia    Conta Corrente    Dt.PGTO            Valor  Status"

IF LEN(Cabec1) > 132
 //  Tamanho := "G"
ENDIF   

Titulo   := TRIM(Titulo)

nomeprog := "BKBXBNCO/"+TRIM(SUBSTR(cUsuario,7,15))
   

SetRegua(LEN(aCtrId))
FOR _XI :=1 TO LEN(aCtrId)
   IncRegua()
   
   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
   IF aCtrId[_XI,1]
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Impressao do cabecalho do relatorio. . .                            ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	   If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
	      Cabec(Titulo,Cabec1,Cabec2,nomeprog,Tamanho,nTipo,,.F.,cBanc+".BMP")
	      nLin := 9
	   Endif
	
		nPos := 0
	   @ nLin,nPos PSAY aCtrId[_XI,2] 
	   nPos := PCOL()+nEsp
	
	   @ nLin,nPos PSAY aCtrId[_XI,3]
	   nPos := PCOL()+nEsp
	
	   @ nLin,nPos PSAY PAD(aCtrId[_XI,4],15) 
	   nPos := PCOL()+nEsp
	
	
	   @ nLin,nPos PSAY aCtrId[_XI,5]+IIF(!EMPTY(aCtrId[_XI,6]),'-'+aCtrId[_XI,6],'') 
	   nPos := PCOL()+nEsp+nEsp
	
	   @ nLin,nPos PSAY TRIM(aCtrId[_XI,7])+IIF(!EMPTY(aCtrId[_XI,8]),'-'+aCtrId[_XI,8],'')
	   nPos := PCOL()+nEsp+nEsp
	
	  @ nLin,nPos PSAY DTOC(aCtrId[_XI,9])
	   nPos := PCOL()+nEsp
	   
	   @ nLin,nPos PSAY aCtrId[_XI,10] PICTURE cPicV
	   nPos := PCOL()+nEsp
	
	   @ nLin,nPos PSAY aCtrId[_XI,11] 
	   nPos := PCOL()+nEsp           
	   
	   IF !EMPTY(aCtrId[_XI,12])
	   		nLin++
	  	 	nPos := 08
	   		@ nLin,nPos PSAY "Ocorrência(s): "+aCtrId[_XI,12] 
	   ENDIF
	
	   nTotLot += aCtrId[_XI,10]
	   nRegistro++
	   
	   nLin++
	ENDIF
NEXT	

IF nRegistro  > 0
  	@ nLin,00  PSAY __PrtThinLine()
	nLin++
 	@ nLin,008 PSAY "Registros:"
	@ nLin,025 PSAY nRegistro PICTURE cPicQ
 	@ nLin,075 PSAY "Valor Total:"
	@ nLin,096 PSAY nTotLot PICTURE cPicV 
ENDIF


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return

