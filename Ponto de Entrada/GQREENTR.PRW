#Include "PROTHEUS.CH"
#include "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} GQREENTR
BK - Este ponto de entrada tem o objetivo de eviar a-mail para o grupo de solicitante, quando entrada da NF aviso de entrada
@Return
@author Adilson do Prado
@since 04/06/13
@version P12
/*/

User Function GQREENTR()
Local cQuery    := ""
Local cQuery1	:= ""
Local cQuery2	:= ""
Local cAssunto	:= ""
Local cEmail	:= ""
Local cEmailCC  := "" 
Local cMsg 		:= "" 
Local cProg		:= "GQREENTR"
Local cAnexo	:= ""
Local cSolici   := ""
//Local cAlmox	:= ""
Local cAlEmail  := ""
//Local nX_		:= 0
Local aCabs		:= {}
Local aEmail	:= {}
LOCAL aSD1		:= {}	
LOCAL aUSERSC1	:= {}
//Local aUsers    := {}
//Local aGrupo    := {}
Local lBkCla 	:= .F.
Local lAtFixo 	:= .F.
Local _X1,_X2
 
//GRAVA USUARIO QUE CLASSIFICOU O DOCUMENTO
cQuery := " UPDATE "+RetSqlName("SF1")+" SET F1_XXUSERS = (CASE WHEN F1_XXUSERS = ' ' THEN '"+__cUserId+"' ELSE F1_XXUSERS END), F1_HORA = '"+SUBSTR(TIME(),1,5)+"'"
cQuery += " WHERE F1_FILIAL='"+xFilial('SF1')+"' AND D_E_L_E_T_='' AND F1_DOC='"+@CNFISCAL +"' AND F1_SERIE='"+ @CSERIE +"'"
cQuery += " AND F1_FORNECE='"+ @CA100FOR +"' AND F1_LOJA='"+ @CLOJA +"' AND F1_TIPO='"+ @cTipo +"'"

TcSqlExec(cQuery)

// Marcos 08/08/19 - Abrir tela de avalia��o para quando os aprovadores estiverem na lista abaixo
// Michele Morais 138, Fabio 93, Anderson 5, Jo�o Brasileiro (antonio.filho) 171 e Vanderleia 56
//cAvalia := SuperGetMV("MV_XXGRAVF",.F.,"000138/000093/000005/000171/000056/")

// Altera��o solicitada por William Santos em 21/01/20 - Anderson 25/07/20 e 27/09/21 - Michele
//cAvalia := "000093/000005/000138"   // Apenas o Fabio Quirino, Anderson e Michele

// Falta criar campo A2_XXAVALC, criar check box "Fornecedor an�lise cr�tica"  e gravar no SA2 (ler e sugerir na avalia��o)

//  31/10/22 - Michele: avaliar somente NFs com Pedido de compras
//If u_IsAvalia(__cUserId)
//	lBkCla := .T.
//EndIf

cAlEmail  += u_EmEstAlm(__cUserId,.T.)

cQuery1 := "SELECT F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,F1_STATUS,F1_XXUSERS"
cQuery1 += " FROM "+RETSQLNAME("SF1")+" SF1" 
cQuery1 += " WHERE SF1.F1_FILIAL='"+xFilial('SF1')+"' AND SF1.D_E_L_E_T_='' AND SF1.F1_DOC='"+@CNFISCAL +"' AND SF1.F1_SERIE='"+ @CSERIE +"'"
cQuery1 += " AND SF1.F1_FORNECE='"+ @CA100FOR +"' AND SF1.F1_LOJA='"+ @CLOJA +"' AND SF1.F1_TIPO='"+ @cTipo +"'"
	        
TCQUERY cQuery1 NEW ALIAS "TMPSF1"

dbSelectArea("TMPSF1")
dbGoTop()
DO While !TMPSF1->(EOF())
	IF TMPSF1->F1_STATUS == 'A'
	    cQuery2 := "SELECT D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_PEDIDO,C1_NUM,C1_ITEM,C1_PRODUTO,C1_DESCRI,C1_UM,C1_QUANT,C1_XXQEST,D1_QUANT,D1_VUNIT,D1_TOTAL,C1_CC,C1_XXDCC,C1_SOLICIT,C1_USER"
		cQuery2 += " FROM "+RETSQLNAME("SD1")+" SD1" 
		cQuery2 += " INNER JOIN "+RETSQLNAME("SC7")+" SC7 ON SD1.D1_PEDIDO=SC7.C7_NUM AND SD1.D1_ITEMPC=SC7.C7_ITEM AND SC7.D_E_L_E_T_='' AND SC7.C7_FILIAL='"+xFilial('SC7')+"'"
		cQuery2 += " INNER JOIN "+RETSQLNAME("SC1")+" SC1 ON SC7.C7_NUMSC=SC1.C1_NUM AND SC7.C7_ITEMSC=SC1.C1_ITEM AND SC1.D_E_L_E_T_='' AND SC1.C1_FILIAL='"+xFilial('SC1')+"'"
		cQuery2 += " WHERE SD1.D1_FILIAL='"+xFilial('SD1')+"' AND SD1.D_E_L_E_T_='' AND SD1.D1_DOC='"+TMPSF1->F1_DOC+"' AND SD1.D1_SERIE='"+TMPSF1->F1_SERIE+"'"
		cQuery2 += " AND SD1.D1_FORNECE='"+TMPSF1->F1_FORNECE+"' AND SD1.D1_LOJA='"+TMPSF1->F1_LOJA+"' AND SD1.D1_PEDIDO<>''"
	        
		TCQUERY cQuery2 NEW ALIAS "TMPSD1"

		aSD1		:= {}	
		aUSERSC1	:= {}

		dbSelectArea("TMPSD1")
		dbGoTop()
		DO While !TMPSD1->(EOF())
			AADD(aSD1,{TMPSD1->D1_PEDIDO,TMPSD1->C1_NUM,TMPSD1->C1_ITEM,TMPSD1->C1_PRODUTO,TMPSD1->C1_DESCRI,TMPSD1->C1_UM,TMPSD1->C1_QUANT-TMPSD1->C1_XXQEST,TMPSD1->D1_QUANT,TMPSD1->D1_VUNIT,TMPSD1->D1_TOTAL,TMPSD1->C1_CC,TMPSD1->C1_XXDCC,TMPSD1->C1_SOLICIT,TMPSD1->C1_USER})
			IF aScan(aUSERSC1,{|x| x == TMPSD1->C1_USER })  == 0
	    		AADD(aUSERSC1,TMPSD1->C1_USER)
	 		ENDIF

			//  31/10/22 - Michele: avaliar somente NFs com Pedido de compras
	 		IF !EMPTY(TMPSD1->D1_PEDIDO)
	 		   	lBkCla := .T. 
	 		ENDIF

			dbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			IF MsSeek(xFilial("SB1")+TMPSD1->C1_PRODUTO,.F.)
	 			IF SB1->B1_TIPO == "AI"
					lAtFixo := .T.
				ENDIF
	 		ENDIF
			TMPSD1->(dbskip())
		Enddo

		TMPSD1->(DbCloseArea())
		
		ASORT(aSD1,,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3]})
    
    	FOR _X1:= 1 TO LEN(aUSERSC1)
    	
			cEmail := ""
 			PswOrder(1) 
			PswSeek(aUSERSC1[_X1]) 
			aUser  := PswRet(1)
			IF !EMPTY(aUser[1,14]) .AND. !aUser[1][17]
				cEmail := ALLTRIM(aUser[1,14])+';'
			ENDIF

	  		cAssunto:= "Solicita��o de Compras Atendida - NF n�.:"+TMPSF1->F1_DOC+" S�rie:"+TMPSF1->F1_SERIE+" - "+FWEmpName(cEmpAnt)
			aCabs   := {}
			aCabs   := {"N� Pedido","N� Solict.","Item SC.","Cod. Produto","Descr. Produto","UM","Quant. Solicitada","Quant. Atendida","Valor Unit.","Total Item","Centro de Custo","Descr. Centro de Custo"}
		
			aEmail := {}
   			FOR _X2:= 1 TO LEN(aSD1)
   				IF aSD1[_X2,14] == aUSERSC1[_X1]
					AADD(aEmail,{aSD1[_X2,1],aSD1[_X2,2],aSD1[_X2,3],aSD1[_X2,4],aSD1[_X2,5],aSD1[_X2,6],aSD1[_X2,7],aSD1[_X2,8],aSD1[_X2,9],aSD1[_X2,10],aSD1[_X2,11],aSD1[_X2,12]})
					cSolici := aSD1[_X2,13]
   				ENDIF
   			NEXT
        	IF EMPTY(cEmail)
   				cEmail := u_EmailAdm()+cAlEmail
   				cAssunto:=  cSolici+" - "+cAssunto
        	ELSE
   				cEmail += u_EmailAdm()+cAlEmail
        	ENDIF
	  		cMsg    := u_GeraHtmB(aEmail,cAssunto,aCabs,cProg,"",cEmail,cEmailCC)

			// Grava o anexo html
			cAnexo := cProg+DTOS(Date())+STRTRAN(TIME(),":","")+STRZERO(_X1++,2)+".html"

			u_GrvAnexo(cAnexo,cMsg,.T.)
			U_BkSnMail(cProg,cAssunto,cEmail,cEmailCC,cMsg,{cAnexo},.T.)
		NEXT

		IF lAtFixo
  			cAssunto:= "Ativo Imobilizado - NF n�.:"+TMPSF1->F1_DOC+" S�rie:"+TMPSF1->F1_SERIE+" - "+FWEmpName(cEmpAnt)
			aCabs   := {}
			aCabs   := {"N� Pedido","N� Solict.","Item SC.","Cod. Produto","Descr. Produto","UM","Quant. Solicitada","Quant. Atendida","Valor Unit.","Total Item","Centro de Custo","Descr. Centro de Custo"}
			aEmail := {}
			cEmail := u_EmailAdm()+cAlEmail

  			cMsg    := u_GeraHtmB(aSD1,cAssunto,aCabs,cProg,"",cEmail,cEmailCC)

			// Grava o anexo html
			cAnexo := cProg+DTOS(Date())+STRTRAN(TIME(),":","")+STRZERO(_X1++,2)+".html"
			u_GrvAnexo(cAnexo,cMsg,.T.)
			U_BkSnMail(cProg,cAssunto,cEmail,cEmailCC,cMsg,{cAnexo},.T.)
		ELSE
	
	    	cQuery2 := "SELECT D1_ITEM,D1_COD,D1_XXDESCP,D1_UM,D1_QUANT,D1_VUNIT,D1_TOTAL,D1_CC,D1_XXDCC,D1_TP "
			cQuery2 += " FROM "+RETSQLNAME("SD1")+" SD1" 
			cQuery2 += " WHERE SD1.D1_FILIAL='"+xFilial('SD1')+"' AND SD1.D_E_L_E_T_='' AND SD1.D1_DOC='"+TMPSF1->F1_DOC+"' AND SD1.D1_SERIE='"+TMPSF1->F1_SERIE+"'"
			cQuery2 += " AND SD1.D1_FORNECE='"+TMPSF1->F1_FORNECE+"' AND SD1.D1_LOJA='"+TMPSF1->F1_LOJA+"'"
	        
			TCQUERY cQuery2 NEW ALIAS "TMPSD1"

			aSD1 := {}	

			dbSelectArea("TMPSD1")
			dbGoTop()
			DO While !TMPSD1->(EOF())
				AADD(aSD1,{TMPSD1->D1_ITEM,TMPSD1->D1_COD,TMPSD1->D1_XXDESCP,TMPSD1->D1_UM,TMPSD1->D1_QUANT,TMPSD1->D1_VUNIT,TMPSD1->D1_TOTAL,TMPSD1->D1_CC,TMPSD1->D1_XXDCC})

 				IF TMPSD1->D1_TP == "AI"
					lAtFixo := .T.
	 			ENDIF
				TMPSD1->(dbskip())
			Enddo
			TMPSD1->(DbCloseArea())

			IF lAtFixo
  				cAssunto := "ATIVO IMOBILIZADO - Usu�rio: "+ALLTRIM(UsrRetName(TMPSF1->F1_XXUSERS))+" - NF n�.:"+TMPSF1->F1_DOC+" S�rie:"+TMPSF1->F1_SERIE+" - "+FWEmpName(cEmpAnt)
				aCabs    := {}
				aCabs    := {"Item","Cod. Produto","Descr. Produto","UM","Quant.","Valor Unit.","Total Item","Centro de Custo","Descr. Centro de Custo",}
				aEmail   := {}
				cEmail   := u_EmailAdm()+cAlEmail

  				cMsg     := u_GeraHtmB(aSD1,cAssunto,aCabs,cProg,"",cEmail,cEmailCC)

				// Grava o anexo html
				cAnexo := cProg+DTOS(Date())+STRTRAN(TIME(),":","")+STRZERO(_X1++,2)+".html"
				u_GrvAnexo(cAnexo,cMsg,.T.)
				U_BkSnMail(cProg,cAssunto,cEmail,cEmailCC,cMsg,{cAnexo},.T.)
            ENDIF
		ENDIF
	ENDIF
	TMPSF1->(dbskip())
Enddo

TMPSF1->(DbCloseArea())

If lBkCla .AND. u_IsAvalia(__cUserId)
	U_AvalForn(.F.)
EndIf

Return( NIL )


// Reavalia��o da NF
User Function RAvalForn()
If u_IsAvalia(__cUserId) .OR. u_IsAvalPN(__cUserId)
	u_AvalForn(.T.)
Else
	u_MsgLog("GQREENTR","Avalia��o de fornecedor n�o dispon�vel para o seu perfil!!","E")
EndIf
Return Nil 



User Function AvalForn(lReavalia) 

Local oGroup1,oGroup2,oGroup3,oGroup4  //,oGroup5
Local oSay,oSayT,oFont1,oFont2,oFont3

Local nTotal := 0
Local aItens := {'Sim','N�o'}
Local cAvalC := ""

nRadio1 := 0
nRadio2 := 0
nRadio3 := 0
nRadio4 := 0
nRadio5 := 0

If lReavalia .OR. TYPE("CA100FOR") == "U" // Para reavaliar
	Private CA100FOR := SF1->F1_FORNECE
	Private CLOJA    := SF1->F1_LOJA
	Private CNFISCAL := SF1->F1_DOC
	Private CSERIE   := SF1->F1_SERIE
	Private CTIPO    := SF1->F1_TIPO   
	nRadio1 := IIF(SUBSTR(SF1->F1_XXAVALI,1,1)='S',1,2)
	nRadio2 := IIF(SUBSTR(SF1->F1_XXAVALI,2,1)='S',1,2)
	nRadio3 := IIF(SUBSTR(SF1->F1_XXAVALI,3,1)='S',1,2)
	nRadio4 := IIF(SUBSTR(SF1->F1_XXAVALI,4,1)='S',1,2)
	nTotal  := (IIF(nRadio1=1,25,0)+IIF(nRadio2=1,25,0)+IIF(nRadio3=1,25,0)+IIF(nRadio4=1,25,0))
EndIf

cAvalC := Posicione("SA2",1,xFilial("SA2") + @CA100FOR + @CLOJA,"A2_XXAVALC")
//cAvalC := Posicione("SA2",1,xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA,"A2_NOME")

If cAvalC == "S"
	nRadio5 := 1
Else
    nRadio5 := 0
eNDiF


DEFINE MSDIALOG oDlg FROM 0,0 TO 430,400 PIXEL TITLE 'Avalia��o de Fornecedores'

// Cria font para uso
oFont1:= TFont():New('Arial',,-13,.T.,.F.,,,,.F.,.F.)  

oFont2:= TFont():New('Arial',,-13,.T.,.T.,,,,.F.,.T.)  

oFont3:= TFont():New('Arial',,-14,.T.,.T.,,,,.F.,.T.)  

// Apresenta o tSay com a fonte Arial
oSay := TSay():New( 10, 60, {|| 'Pedido X Nota Fiscal'},oDlg,, oFont3,,,, .T.,,)

oSay := TSay():New( 20, 20, {|| 'Itens a serem avaliados:'},oDlg,, oFont2,,,, .T.,,)

// Cria o Objeto
oGroup1:= tGroup():New(30,10,050,190,'',oDlg,,,.T.)
oSay  := TSay():New( 035,020, {|| 'Pre�o'},oGroup1,, oFont1,,,, .T.,,)
oRadio1 := TRadMenu():Create (oGroup1,,30,150,aItens,,,,,,,,100,12,,,,.T.)

oRadio1:bSetGet := {|u|Iif (PCount()==0,nRadio1,nRadio1:=u)}
oRadio1:bchange := {|| nTOTAL:= (IIF(nRadio1=1,25,0)+IIF(nRadio2=1,25,0)+IIF(nRadio3=1,25,0)+IIF(nRadio4=1,25,0)),oSayT:Refresh() }

oGroup2:= tGroup():New(60,10,080,190,'',oDlg,,,.T.)
oSay  := TSay():New( 065,020, {|| 'Prazo'},oGroup2,, oFont1,,,, .T.,,)
oRadio2 := TRadMenu():Create (oGroup2,,60,150,aItens,,,,,,,,100,12,,,,.T.)

oRadio2:bSetGet := {|u|Iif (PCount()==0,nRadio2,nRadio2:=u)}
oRadio2:bchange := {|| nTOTAL:= (IIF(nRadio1=1,25,0)+IIF(nRadio2=1,25,0)+IIF(nRadio3=1,25,0)+IIF(nRadio4=1,25,0)),oSayT:Refresh() }

oGroup3:= tGroup():New(90,10,110,190,'',oDlg,,,.T.)
oSay  := TSay():New( 095,020, {|| 'Quantidade/Atendimento'},oGroup3,, oFont1,,,, .T.,,)
oRadio3 := TRadMenu():Create (oGroup3,,90,150,aItens,,,,,,,,100,12,,,,.T.)

oRadio3:bSetGet := {|u|Iif (PCount()==0,nRadio3,nRadio3:=u)}
oRadio3:bchange := {|| nTOTAL:= (IIF(nRadio1=1,25,0)+IIF(nRadio2=1,25,0)+IIF(nRadio3=1,25,0)+IIF(nRadio4=1,25,0)),oSayT:Refresh() }

oGroup4:= tGroup():New(120,10,140,190,'',oDlg,,,.T.)
oSay  := TSay():New( 125,020, {|| 'Qualidade/Integridade'},oGroup4,, oFont1,,,, .T.,,)
oRadio4 := TRadMenu():Create (oGroup4,,120,150,aItens,,,,,,,,100,12,,,,.T.)

oRadio4:bSetGet := {|u|Iif (PCount()==0,nRadio4,nRadio4:=u)}
oRadio4:bchange := {|| nTOTAL:= (IIF(nRadio1=1,25,0)+IIF(nRadio2=1,25,0)+IIF(nRadio3=1,25,0)+IIF(nRadio4=1,25,0)),oSayT:Refresh() }

oSayT := TSay():New(145,75, {|| "Total (IQF):  "+STR(nTOTAL,3)+"%"},oDlg,, oFont2,,,, .T.,,)

//oGroup5:= tGroup():New(160,10,180,190,'',oDlg,,,.T.)
//oSay  := TSay():New( 165,020, {|| 'Fornecedor cr�tico:'},oGroup5,, oFont1,,,, .T.,,)
//oRadio5 := TRadMenu():Create (oGroup5,,160,150,aItens,,,,,,,,100,12,,,,.T.)

//oRadio5:bSetGet := {|u|Iif (PCount()==0,nRadio5,nRadio5:=u)}
//oRadio5:bWhen := {||.F.}

@ 190,050 Button "&Confirmar Avalia��o" Size 100,013 Pixel Action (oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED  Valid(validaSF1(nRadio1,nRadio2,nRadio3,nRadio4,nRadio5)) 

Return


Static Function validaSF1(nRadio1,nRadio2,nRadio3,nRadio4,nRadio5)
LOCAL lOK := .T.

IF nRadio1 == 0 .OR. nRadio2 == 0 .OR. nRadio3 == 0 .OR. nRadio4 == 0
	u_MsgLog("VALIDASF1","Avalia��o de Fornecedores - preenchimento obrigat�rio. Favor rever os itens!!","E")
	lOK := .F.
ELSE
	GrvSF1(nRadio1,nRadio2,nRadio3,nRadio4,nRadio5)
ENDIF

RETURN lOK


Static Function GrvSF1(nRadio1,nRadio2,nRadio3,nRadio4,nRadio5) 
Local lOK       := .T. 
Local cQuery    := ""
Local cAvali    := "" 
Local cMensagem := ""
Local cAssunto	:= ""
Local cEmail	:= u_BkEmQld()
Local cEmailCC  := ""
Local cNome     := "" 
Local cMsg 		:= "" 
Local cAnexo	:= ""
Local nTOTAL 	:= 0
Local cAvalC    := ""
Local cProg		:= "GQREENTR"

nTOTAL:= (IIF(nRadio1=1,25,0)+IIF(nRadio2=1,25,0)+IIF(nRadio3=1,25,0)+IIF(nRadio4=1,25,0)) 

IF nRadio1 == 1
	cAvali += "S"
ELSE
	cAvali += "N"
	cMensagem += 'Pre�o,'
ENDIF
 
IF nRadio2 == 1
	cAvali += "S"
ELSE
	cAvali += "N"
	cMensagem += 'Prazo,'
ENDIF

IF nRadio3 == 1
	cAvali += "S"
ELSE
	cAvali += "N"
	cMensagem += 'Quantidade/Atendimento,'
ENDIF

IF nRadio4 == 1
	cAvali += "S"
ELSE
	cAvali += "N"
	cMensagem += 'Qualidade/Integridade,'
ENDIF

If nRadio5 == 1
	cAvalC := "S"
Else
	cAvalC := "N"
EndIf
                        
// Atualiza fornecedor critico
//If .F.
//	UpdSa2(@CA100FOR,@CLOJA,cAvalC)
//EndIf

cQuery := " UPDATE "+RetSqlName("SF1")+" SET F1_XXAVALI = '"+cAvali+"', F1_XXAVAL = 'S' "
cQuery  += " WHERE F1_FILIAL='"+xFilial('SF1')+"' AND D_E_L_E_T_='' AND F1_DOC='"+@CNFISCAL +"' AND F1_SERIE='"+ @CSERIE +"'"
cQuery  += " AND F1_FORNECE='"+ @CA100FOR +"' AND F1_LOJA='"+ @CLOJA +"' AND F1_TIPO='"+ @cTipo +"'"

TcSqlExec(cQuery)

IF nTOTAL <= 50

	cQuery1 := "SELECT F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,F1_DOC,F1_SERIE,F1_STATUS,F1_EMISSAO"
	cQuery1 += " FROM "+RETSQLNAME("SF1")+" SF1" 
	cQuery1 += " WHERE SF1.F1_FILIAL='"+xFilial('SF1')+"' AND SF1.D_E_L_E_T_='' AND SF1.F1_DOC='"+@CNFISCAL +"' AND SF1.F1_SERIE='"+ @CSERIE +"'"
	cQuery1 += " AND SF1.F1_FORNECE='"+ @CA100FOR +"' AND SF1.F1_LOJA='"+ @CLOJA +"' AND SF1.F1_TIPO='"+ @cTipo +"'"
	        
	TCQUERY cQuery1 NEW ALIAS "TMPSF1"

	TCSETFIELD("TMPSF1","F1_EMISSAO","D",8,0)

	dbSelectArea("TMPSF1")

	cAssunto:= "Avalia��o de Fornecedores - NF n�.:"+TMPSF1->F1_DOC+" S�rie:"+TMPSF1->F1_SERIE+" - "+FWEmpName(cEmpAnt)
	aCabs  := {}
	aCabs  := {"Cod.Fornecedor","Loja","Nome","CNPJ","Nota Fiscal n�","S�rie","Emiss�o","�ndice Negativo da Avalia��o"}
	aEmail := {}
	cNome  := ""
	cNome  := Posicione("SA2",1,Xfilial("SA2")+TMPSF1->F1_FORNECE+TMPSF1->F1_LOJA,"A2_NOME")
	AADD(aEmail,{TMPSF1->F1_FORNECE,TMPSF1->F1_LOJA,cNome,SA2->A2_CGC,TMPSF1->F1_DOC,TMPSF1->F1_SERIE,DTOC(TMPSF1->F1_EMISSAO),SUBSTR(cMensagem,1,LEN(cMensagem)-1)})
	cMsg    := u_GeraHtmB(aEmail,cAssunto,aCabs,cProg,"",cEmail,cEmailCC)

	// Grava o anexo html
	cAnexo := cProg+DTOS(Date())+STRTRAN(TIME(),":","")+".html"

	u_GrvAnexo(cAnexo,cMsg,.T.)
	U_BkSnMail(cProg,cAssunto,cEmail,cEmailCC,cMsg,{cAnexo},.T.)
	TMPSF1->(DbCloseArea())
ENDIF
	        
u_MsgLog(cProg,"Avalia��o do fornecedor "+TRIM(cNome)+" gravada com sucesso!! - "+@CNFISCAL,"I")

RETURN lOK


Static Function UpdSa2(cForn,cLoja,cAvalC)
Local aArea := GetArea()
dbSelectArea("SA2")
If dbSeek(xFilial("SA2")+cForn+cLoja,.F.)
	RecLock("SA2",.f.)
	SA2->A2_XXAVALC  := cAvalC
	MsUnlock()
EndIf
RestArea(aArea)          
Return Nil
