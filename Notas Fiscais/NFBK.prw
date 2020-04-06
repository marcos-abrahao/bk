#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
     

#DEFINE VBOX      080
#DEFINE VSPACE    008
#DEFINE HSPACE    010
#DEFINE SAYVSPACE 008
#DEFINE SAYHSPACE 008
#DEFINE HMARGEM   030
#DEFINE VMARGEM   030
#DEFINE MAXITEM   Max((022-Max(0,Min(Len(aMensagem), MAXMSG))),1)    // Máximo de produtos para a primeira página
#DEFINE MAXITEMP2 060                                                // Máximo de produtos para as páginas adicionais
#DEFINE MAXITEMC  050                                                // Máxima de caracteres por linha de produtos/serviços
#DEFINE MAXMENLIN 125                                                // Máximo de caracteres por linha de dados adicionais
#DEFINE MAXMSG    023                                                // Máximo de dados adicionais por página

Static aUltChar2pix
Static aUltVChar2pix
//--------------------------------------------------------------
/*/{Protheus.doc} TFontex1
Classe auxiliar de TFont criada para otimizar a impressão

@author  Ricardo Mansano
@since   26/05/2009
@version 10.1.1.4
/*/
//--------------------------------------------------------------
Class TFontex1 From LongClassName
	DATA cClassName
	DATA oFont
	DATA aFntWidth
	
	METHOD New() Constructor
	METHOD GetTextWidht()
EndClass
       
//--------------------------------------------------------------
/*/{Protheus.doc} New
Método contrutor da classe

@author  Ricardo Mansano
@since   26/05/2009
@version 10.1.1.4
/*/
//--------------------------------------------------------------
METHOD New( oDanfe,cName,nWidth,nHeight,lBold,lUnderline,lItalic ) Class TFontex1
Local nX
	::cClassName := 'TFontex1'	
	// Cria fonte
	::oFont := TFont():New( cName,nWidth,nHeight,,lBold,,,,lUnderline,lItalic )

	// Alimenta vetor com as larguras desta fonte
	::aFntWidth := {}
	// Verifica binario para execução da rotina que retorna lagura da fonte
	If GetBuild() >= '7.00.081215P-20090316'
		//::aFntWidth := GetFontPixWidths( cName,Abs(nHeight),lBold,lItalic ) // OLD
	  oDanfe:GetFontWidths( ::oFont, ::aFntWidth )	
	Else
 		For nX := 1 To 255
	 		Aadd( ::aFntWidth, oDanfe:GetTextWidth(Chr(nX),::oFont) )
		Next  
	Endif
Return

//--------------------------------------------------------------
/*/{Protheus.doc} GetTextWidht
Retorna largura do texto baseado na fonte

@author  Ricardo Mansano
@since   26/05/2009
@version 10.1.1.4
/*/
//--------------------------------------------------------------
METHOD GetTextWidht( cTexto ) Class TFontex1
Local nX
Local nWidht := 0
Local nLen   := Len( AllTrim( cTexto ) )

For nX := 1 to nLen
	nWidht += ::aFntWidth[ Asc( SubStr( cTexto, nX, 1 ) ) ]
next nX


Return( nWidht )


//------------------------//------------------------//------------------------

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PrtNfeSef ³ Autor ³ Eduardo Riera         ³ Data ³16.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rdmake de exemplo para impressão da DANFE no formato Retrato³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function PrtNfBK()

Local aArea     := GetArea()
Local oDanfe

PRIVATE cPerg := "FATN01"

ValidPerg(cPerg)

If	!Pergunte(cPerg,.T.)
	Return
EndIf

cIdent := ""

oDanfe := TMSPrinter():New("DANFE - DOCUMENTO AUXILIAR DA NOTA FISCAL ELETRÔNICA")
oDanfe:SetPortrait()
oDanfe:Setup()

Private PixelX := odanfe:nLogPixelX()
Private PixelY := odanfe:nLogPixelY()
	
RptStatus({|lEnd| DanfeProc(@oDanfe,@lEnd,cIdEnt)},"Imprimindo Danfe...")

//If MV_PAR05==1 
	oDanfe:Preview()//Visualiza antes de imprimir
//Else 
//	oDanfe:Print()//Imprimir direto
//EndIf

RestArea(aArea)
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DANFEProc ³ Autor ³ Eduardo Riera         ³ Data ³16.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rdmake de exemplo para impressão da DANFE no formato Retrato³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto grafico de impressao                    (OPC) ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DanfeProc(oDanfe,lEnd,cIdEnt)

Local aArea      := GetArea()
Local aNotas     := {}
//Local aXML       := {}
//Local aAutoriza  := {}
//Local cNaoAut    := ""

Local cAliasSF3  := "SF3"
Local cWhere     := ""
//Local cAviso     := ""
//Local cErro      := ""
//Local cAutoriza  := ""
//Local cChaveSFT  := ""
//Local cAliasSFT  := "SFT" 
//Local cCondicao	 := ""
Local cIndex	 := ""
//Local cChave	 := ""
Local lQuery     := .F.
Local nX         := 0
//Local oNfe 
Local nLenNotas

If Pergunte("NFSIGW",.T.)
	MV_PAR01 := AllTrim(MV_PAR01)
	dbSelectArea("SF3")
	dbSetOrder(5)
	#IFDEF TOP
		If MV_PAR04==1
			cWhere := "%SubString(SF3.F3_CFO,1,1) < '5' AND SF3.F3_FORMUL='S'%"
		ElseIf MV_PAR04==2
			cWhere := "%SubString(SF3.F3_CFO,1,1) >= '5'%"
		EndIf	
		cAliasSF3 := GetNextAlias()
		lQuery    := .T.
		
		If Empty(cWhere)
	
			BeginSql Alias cAliasSF3
			
			COLUMN F3_ENTRADA AS DATE
			COLUMN F3_DTCANC AS DATE
					
			SELECT	F3_FILIAL,F3_ENTRADA,F3_NFELETR,F3_CFO,F3_FORMUL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC
					FROM %Table:SF3% SF3
					WHERE
					SF3.F3_FILIAL = %xFilial:SF3% AND
					SF3.F3_SERIE = %Exp:MV_PAR03% AND 
					SF3.F3_NFISCAL >= %Exp:MV_PAR01% AND 
					SF3.F3_NFISCAL <= %Exp:MV_PAR02% AND 
					SF3.F3_DTCANC = %Exp:Space(8)% AND
					SF3.%notdel%
			EndSql	
	
		Else
			BeginSql Alias cAliasSF3
			
			COLUMN F3_ENTRADA AS DATE
			COLUMN F3_DTCANC AS DATE
					
			SELECT	F3_FILIAL,F3_ENTRADA,F3_NFELETR,F3_CFO,F3_FORMUL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC
					FROM %Table:SF3% SF3
					WHERE
					SF3.F3_FILIAL = %xFilial:SF3% AND
					SF3.F3_SERIE = %Exp:MV_PAR03% AND 
					SF3.F3_NFISCAL >= %Exp:MV_PAR01% AND 
					SF3.F3_NFISCAL <= %Exp:MV_PAR02% AND 
					%Exp:cWhere% AND 
					SF3.F3_DTCANC = %Exp:Space(8)% AND
					SF3.%notdel%
			EndSql	
		
		EndIf
	
	#ELSE
		MsSeek(xFilial("SF3")+MV_PAR03+MV_PAR01,.T.)
	    cIndex    		:= GetNextAlias()  //CriaTrab(NIL,.F.)
	    cChave			:= IndexKey(6)
	    cCondicao 		:= 'F3_FILIAL == "' + xFilial("SF3") + '" .And. '
	   	cCondicao 		+= 'SF3->F3_SERIE =="'+ MV_PAR03+'" .And. '
	   	cCondicao 		+= 'SF3->F3_NFISCAL >="'+ MV_PAR01+'" .And. '
		cCondicao		+= 'SF3->F3_NFISCAL <="'+ MV_PAR02+'" .And. '
		cCondicao		+= 'Empty(SF3->F3_DTCANC)'
		IndRegua("SF3",cIndex,cChave,,cCondicao)
	#ENDIF
	If MV_PAR04==1
		cWhere := "SubStr(F3_CFO,1,1) < '5' .AND. F3_FORMUL=='S'"
	Elseif MV_PAR04==2
		cWhere := "SubStr(F3_CFO,1,1) >= '5'"
	Else
		cWhere := ".T."
	EndIf	
	While !Eof() .And. xFilial("SF3") == (cAliasSF3)->F3_FILIAL .And.;
		(cAliasSF3)->F3_SERIE == MV_PAR03 .And.;
		(cAliasSF3)->F3_NFISCAL >= MV_PAR01 .And.;
		(cAliasSF3)->F3_NFISCAL <= MV_PAR02
		
		dbSelectArea(cAliasSF3)
		If  Empty((cAliasSF3)->F3_DTCANC) .And. &cWhere //.And. AModNot((cAliasSF3)->F3_ESPECIE)=="55"
		
			If (SubStr((cAliasSF3)->F3_CFO,1,1)>="5" .Or. (cAliasSF3)->F3_FORMUL=="S") .And. aScan(aNotas,{|x| x[4]+x[5]+x[6]+x[7]==(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA})==0
				
				aadd(aNotas,{})
				aadd(Atail(aNotas),.F.)
				aadd(Atail(aNotas),IIF((cAliasSF3)->F3_CFO<"5","E","S"))
				aadd(Atail(aNotas),(cAliasSF3)->F3_ENTRADA)
				aadd(Atail(aNotas),(cAliasSF3)->F3_SERIE)
				aadd(Atail(aNotas),(cAliasSF3)->F3_NFISCAL)
				aadd(Atail(aNotas),(cAliasSF3)->F3_CLIEFOR)
				aadd(Atail(aNotas),(cAliasSF3)->F3_LOJA)
							
			EndIf
		EndIf
		
		dbSelectArea(cAliasSF3)
		dbSkip()
		If lEnd
			Exit
		EndIf	
		If Len(aNotas) >= 50 .Or. 	(cAliasSF3)->(Eof())
			//aXml := GetXML(cIdEnt,aNotas,@cModalidade)
			nLenNotas := Len(aNotas)
			For nX := 1 To nLenNotas
				If aNotas[nX][02]=="E"
		    		dbSelectArea("SF1")
		    		dbSetOrder(1)
	    			If MsSeek(xFilial("SF1")+aNotas[nX][05]+aNotas[nX][04]+aNotas[nX][06]+aNotas[nX][07]) .And. SF1->(FieldPos("F1_FIMP"))<>0
						RecLock("SF1")
						If !SF1->F1_FIMP$"D"
							SF1->F1_FIMP := "S"
						EndIf
						//If SF1->(FieldPos("F1_CHVNFE"))>0
						//	SF1->F1_CHVNFE := SubStr(SpedNfeId(aXML[nX][2],"Id"),4)
						//EndIf			    			   
						MsUnlock()
    				EndIf
				Else
		    		dbSelectArea("SF2")
		    		dbSetOrder(1)
		    		If MsSeek(xFilial("SF2")+aNotas[nX][05]+aNotas[nX][04]+aNotas[nX][06]+aNotas[nX][07])
						RecLock("SF2")
						If !SF2->F2_FIMP$"D"
							SF2->F2_FIMP := "S"
						EndIf
						//If SF2->(FieldPos("F2_CHVNFE"))>0
						//	SF2->F2_CHVNFE := SubStr(SpedNfeId(aXML[nX][2],"Id"),4)       
						//EndIf
						MsUnlock()
	    			EndIf
				EndIf
					
				//cAviso := ""
				//cErro  := ""
				//oNfe := XmlParser(aXML[nX][2],"_",@cAviso,@cErro)					
				//oNfeDPEC := XmlParser(aXML[nX][4],"_",@cAviso,@cErro)					
				//If Empty(cAviso) .And. Empty(cErro)	
				    ImpDet(@oDanfe,aNotas[nX])
				//EndIf

			Next nX
			aNotas := {}
		EndIf		
		dbSelectArea(cAliasSF3)
	EndDo
	If !lQuery 
		RetIndex("SF3")	
		dbClearFilter()	
		Ferase(cIndex+OrdBagExt())
	EndIf
EndIf
RestArea(aArea)
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ImpDet   ³ Autor ³ Eduardo Riera         ³ Data ³16.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de Fluxo do Relatorio.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto grafico de impressao                    (OPC) ³±±
±±³          ³ExpC2: String com o XML da NFe                              ³±±
±±³          ³ExpC3: Codigo de Autorizacao do fiscal                (OPC) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpDet(oDanfe,aNota)

Local lServer := Getprofstring(GETPRINTERSESSION(),"LOCAL","SERVER",.T.) == "SERVER"
Local nS := 0
If !lServer
	nS := 1
EndIf

PRIVATE oFont10N   := TFontex1():New(oDanfe,"Times New Roman",09+nS,09+nS,.T.,.T.,.F.)// 1
PRIVATE oFont07N   := TFontex1():New(oDanfe,"Times New Roman",06+nS,06+nS,.T.,.T.,.F.)// 2
PRIVATE oFont07    := TFontex1():New(oDanfe,"Times New Roman",06+nS,06+nS,.F.,.T.,.F.)// 3
PRIVATE oFont08    := TFontex1():New(oDanfe,"Times New Roman",07+nS,07+nS,.F.,.T.,.F.)// 4
PRIVATE oFont08N   := TFontex1():New(oDanfe,"Times New Roman",07+nS,07+nS,.T.,.T.,.F.)// 5
PRIVATE oFont09N   := TFontex1():New(oDanfe,"Times New Roman",08+nS,08+nS,.T.,.T.,.F.)// 6
PRIVATE oFont09    := TFontex1():New(oDanfe,"Times New Roman",08+nS,08+nS,.F.,.T.,.F.)// 7
PRIVATE oFont10    := TFontex1():New(oDanfe,"Times New Roman",09+nS,09+nS,.F.,.T.,.F.)// 8
PRIVATE oFont11    := TFontex1():New(oDanfe,"Times New Roman",10+nS,10+nS,.F.,.T.,.F.)// 9
PRIVATE oFont12    := TFontex1():New(oDanfe,"Times New Roman",11+nS,07+nS,.F.,.T.,.F.)// 10
PRIVATE oFont11N   := TFontex1():New(oDanfe,"Times New Roman",10+nS,06+nS,.T.,.T.,.F.)// 11
PRIVATE oFont18N   := TFontex1():New(oDanfe,"Times New Roman",17+nS,17+nS,.T.,.T.,.F.)// 12

IF aNota[2] = "S"

////////////////////////////////////////////////////////////////

   //+--------------------------------------------------------------+
   //¦ Inicio de Levantamento dos Dados da Nota Fiscal de Saída     ¦
   //+--------------------------------------------------------------+

   // * Cabecalho da Nota Fiscal

      xNUM_NF     :=SF2->F2_DOC             // Numero
      xSERIE      :=SF2->F2_SERIE           // Serie
      xEMISSAO    :=SF2->F2_EMISSAO         // Data de Emissao
      xTOT_FAT    :=SF2->F2_VALFAT          // Valor Total da Fatura
      if xTOT_FAT == 0
         xTOT_FAT := SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_SEGURO+SF2->F2_FRETE
      endif
      xLOJA       :=SF2->F2_LOJA            // Loja do Cliente
      xFRETE      :=SF2->F2_FRETE           // Frete
      xSEGURO     :=SF2->F2_SEGURO          // Seguro
      xBASE_ICMS  :=SF2->F2_BASEICM         // Base   do ICMS
      xBASE_IPI   :=SF2->F2_BASEIPI         // Base   do IPI
      xVALOR_ICMS :=SF2->F2_VALICM          // Valor  do ICMS
      xICMS_RET   :=SF2->F2_ICMSRET         // Valor  do ICMS Retido
      xVALOR_IPI  :=SF2->F2_VALIPI          // Valor  do IPI
      xVALOR_MERC :=SF2->F2_VALMERC         // Valor  da Mercadoria
      xNUM_DUPLIC :=SF2->F2_DUPL            // Numero da Duplicata
      xCOND_PAG   :=SF2->F2_COND            // Condicao de Pagamento
      xPBRUTO     :=SF2->F2_PBRUTO          // Peso Bruto
      xPLIQUI     :=SF2->F2_PLIQUI          // Peso Liquido
      xTIPO       :=SF2->F2_TIPO            // Tipo do Cliente
      xESPECIE    :=SF2->F2_ESPECI1         // Especie 1 no Pedido
      xVOLUME     :=SF2->F2_VOLUME1         // Volume 1 no Pedido

      xValPis     := 0
      xValCofi    := 0
      xValCsll    := 0
      xValIrrf    := 0
      xValInss    := 0
      xValIss     := 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Analisa os impostos de retencao                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SF2->(FieldPos("F2_VALPIS"))<>0 .and. SF2->F2_VALPIS>0
			xValPis := SF2->F2_VALPIS
			//aadd(aRetido,{"PIS",0,SF2->F2_VALPIS})
		EndIf
		If SF2->(FieldPos("F2_VALCOFI"))<>0 .and. SF2->F2_VALCOFI>0
			xValCofi := SF2->F2_VALCOFI
			//aadd(aRetido,{"COFINS",0,SF2->F2_VALCOFI})
		EndIf
		If SF2->(FieldPos("F2_VALCSLL"))<>0 .and. SF2->F2_VALCSLL>0
			xValCsll := SF2->F2_VALCSLL 
			//aadd(aRetido,{"CSLL",0,SF2->F2_VALCSLL})
		EndIf
		If SF2->(FieldPos("F2_VALIRRF"))<>0 .and. SF2->F2_VALIRRF>0
			xValIrrf := SF2->F2_VALIRRF
			//aadd(aRetido,{"IRRF",SF2->F2_BASEIRR,SF2->F2_VALIRRF})
		EndIf	
		If SF2->(FieldPos("F2_BASEINS"))<>0 .and. SF2->F2_BASEINS>0
			xValInss := SF2->F2_VALINSS
			//aadd(aRetido,{"INSS",SF2->F2_BASEINS,SF2->F2_VALINSS})
		EndIf



      dbSelectArea("SD2")                   // * Itens de Venda da N.F.
      dbSetOrder(3)
      dbSeek(xFilial()+xNUM_NF+xSERIE)

      cPedAtu := SD2->D2_PEDIDO
      cItemAtu := SD2->D2_ITEMPV

      xPED_VEND:={}                         // Numero do Pedido de Venda
      xITEM_PED:={}                         // Numero do Item do Pedido de Venda
      xNUM_NFDV:={}                         // nUMERO QUANDO HOUVER DEVOLUCAO
      xPREF_DV :={}                         // Serie  quando houver devolucao
      xICMS    :={}                         // Porcentagem do ICMS
      xCOD_PRO :={}                         // Codigo  do Produto
      xQTD_PRO :={}                         // Peso/Quantidade do Produto
      xPRE_UNI :={}                         // Preco Unitario de Venda
      xPRE_TAB :={}                         // Preco Unitario de Tabela
      xIPI     :={}                         // Porcentagem do IPI
      xVAL_IPI :={}                         // Valor do IPI
      xDESC    :={}                         // Desconto por Item
      xVAL_DESC:={}                         // Valor do Desconto
      xVAL_MERC:={}                         // Valor da Mercadoria
      xTES     :={}                         // TES
      xCF      :={}                         // Classificacao quanto natureza da Operacao
      xICMSOL  :={}                         // Base do ICMS Solidario
      xICM_PROD:={}                         // ICMS do Produto

      while !eof() .and. SD2->D2_DOC==xNUM_NF .and. SD2->D2_SERIE==xSERIE
	 If SD2->D2_SERIE #mv_par03        // Se a Serie do Arquivo for Diferente
        	 DbSkip()                   // do Parametro Informado !!!
	         Loop
	 Endif
         AADD(xPED_VEND ,SD2->D2_PEDIDO)
         AADD(xITEM_PED ,SD2->D2_ITEMPV)
         AADD(xNUM_NFDV ,IIF(Empty(SD2->D2_NFORI),"",SD2->D2_NFORI))
         AADD(xPREF_DV  ,SD2->D2_SERIORI)
         AADD(xICMS     ,IIf(Empty(SD2->D2_PICM),0,SD2->D2_PICM))
         AADD(xCOD_PRO  ,SD2->D2_COD)
         AADD(xQTD_PRO  ,SD2->D2_QUANT)     // Guarda as quant. da NF
         AADD(xPRE_UNI  ,SD2->D2_PRCVEN)
         AADD(xPRE_TAB  ,SD2->D2_PRUNIT)
         AADD(xIPI      ,IIF(Empty(SD2->D2_IPI),0,SD2->D2_IPI))
         AADD(xVAL_IPI  ,SD2->D2_VALIPI)
         AADD(xDESC     ,SD2->D2_DESC)
         AADD(xVAL_MERC ,SD2->D2_TOTAL)
         AADD(xTES      ,SD2->D2_TES)
         AADD(xCF       ,SD2->D2_CF)
         AADD(xICM_PROD ,IIf(Empty(SD2->D2_PICM),0,SD2->D2_PICM))
         dbskip()
      End

      dbSelectArea("SB1")                     // * Desc. Generica do Produto
      dbSetOrder(1)
      xPESO_PRO:={}                           // Peso Liquido
      xPESO_UNIT :={}                         // Peso Unitario do Produto
      xDESCRICAO :={}                         // Descricao do Produto
      xUNID_PRO:={}                           // Unidade do Produto
      xCOD_TRIB:={}                           // Codigo de Tributacao
      xMEN_TRIB:={}                           // Mensagens de Tributacao
      xCOD_FIS :={}                           // Cogigo Fiscal
      xCLAS_FIS:={}                           // Classificacao Fiscal
      xMEN_POS :={}                           // Mensagem da Posicao IPI
      xISS     :={}                           // Aliquota de ISS
      xTIPO_PRO:={}                           // Tipo do Produto
      xLUCRO   :={}                           // Margem de Lucro p/ ICMS Solidario
      xCLFISCAL   :={}
      xPESO_LIQ := 0
      I:=1

      For I:=1 to Len(xCOD_PRO)

          dbSeek(xFilial()+xCOD_PRO[I])
          AADD(xPESO_PRO ,SB1->B1_PESO * xQTD_PRO[I])
          xPESO_LIQ  := xPESO_LIQ + xPESO_PRO[I]
          AADD(xPESO_UNIT , SB1->B1_PESO)
          AADD(xUNID_PRO ,SB1->B1_UM)
          AADD(xDESCRICAO ,SB1->B1_DESC)
          AADD(xCOD_TRIB ,SB1->B1_ORIGEM)
          If Ascan(xMEN_TRIB, SB1->B1_ORIGEM)==0
             AADD(xMEN_TRIB ,SB1->B1_ORIGEM)
          Endif

          npElem := ascan(xCLAS_FIS,SB1->B1_POSIPI)

          if npElem == 0
             AADD(xCLAS_FIS  ,SB1->B1_POSIPI)
          endif

          npElem := ascan(xCLAS_FIS,SB1->B1_POSIPI)

          DO CASE
             CASE npElem == 1
                _CLASFIS := "A"

             CASE npElem == 2
                _CLASFIS := "B"

             CASE npElem == 3
                _CLASFIS := "C"

             CASE npElem == 4
                _CLASFIS := "D"

             CASE npElem == 5
                _CLASFIS := "E"

             CASE npElem == 6
                _CLASFIS := "F"

           ENDCASE
           nPteste := Ascan(xCLFISCAL,_CLASFIS)
           If nPteste == 0
              AADD(xCLFISCAL,_CLASFIS)
           Endif

          AADD(xCOD_FIS ,_CLASFIS)
          If SB1->B1_ALIQISS > 0
             AADD(xISS ,SB1->B1_ALIQISS)
          Endif
          AADD(xTIPO_PRO ,SB1->B1_TIPO)
          AADD(xLUCRO    ,SB1->B1_PICMRET)


         //
         // Calculo do Peso Liquido da Nota Fiscal
         //

         xPESO_LIQUID:=0                                 // Peso Liquido da Nota Fiscal
         For j:=1 to Len(xPESO_PRO)
            xPESO_LIQUID:=xPESO_LIQUID+xPESO_PRO[j]
         Next j

      Next I

      dbSelectArea("SC5")                            // * Pedidos de Venda
      dbSetOrder(1)

      xPED        := {}
      xPESO_BRUTO := 0
      xP_LIQ_PED  := 0

      For I:=1 to Len(xPED_VEND)

         dbSeek(xFilial()+xPED_VEND[I])

         If ASCAN(xPED,xPED_VEND[I])==0
            dbSeek(xFilial()+xPED_VEND[I])
            xCLIENTE    :=SC5->C5_CLIENTE            // Codigo do Cliente
            xTIPO_CLI   :=SC5->C5_TIPOCLI            // Tipo de Cliente
            xCOD_MENS   :=SC5->C5_MENPAD             // Codigo da Mensagem Padrao
            xMENSAGEM   :=SC5->C5_MENNOTA            // Mensagem para a Nota Fiscal
            xTPFRETE    :=SC5->C5_TPFRETE            // Tipo de Entrega
            xCONDPAG    :=SC5->C5_CONDPAG            // Condicao de Pagamento
            xPESO_BRUTO :=SC5->C5_PBRUTO             // Peso Bruto
            xP_LIQ_PED  :=xP_LIQ_PED + SC5->C5_PESOL // Peso Liquido
            xCOD_VEND:= {SC5->C5_VEND1,;             // Codigo do Vendedor 1
                         SC5->C5_VEND2,;             // Codigo do Vendedor 2
                         SC5->C5_VEND3,;             // Codigo do Vendedor 3
                         SC5->C5_VEND4,;             // Codigo do Vendedor 4
                         SC5->C5_VEND5}              // Codigo do Vendedor 5
            xDESC_NF := {SC5->C5_DESC1,;             // Desconto Global 1
                         SC5->C5_DESC2,;             // Desconto Global 2
                         SC5->C5_DESC3,;             // Desconto Global 3
                         SC5->C5_DESC4}              // Desconto Global 4
            AADD(xPED,xPED_VEND[I])
         Endif

         If xP_LIQ_PED >0
            xPESO_LIQ := xP_LIQ_PED
         Endif

      Next I

      //+---------------------------------------------+
      //¦ Pesquisa da Condicao de Pagto               ¦
      //+---------------------------------------------+

      dbSelectArea("SE4")                    // Condicao de Pagamento
      dbSetOrder(1)
      dbSeek(xFilial("SE4")+xCONDPAG)
      xDESC_PAG := SE4->E4_DESCRI

      dbSelectArea("SC6")                    // * Itens de Pedido de Venda
      dbSetOrder(1)
      xPED_CLI :={}                          // Numero de Pedido
      xDESC_PRO:={}                          // Descricao aux do produto
      J:=Len(xPED_VEND)
      For I:=1 to J
         dbSeek(xFilial()+xPED_VEND[I]+xITEM_PED[I])
         AADD(xPED_CLI ,SC6->C6_PEDCLI)
         AADD(xDESC_PRO,SC6->C6_DESCRI)
         AADD(xVAL_DESC,SC6->C6_VALDESC)
      Next j

      If xTIPO=='N' .OR. xTIPO=='C' .OR. xTIPO=='P' .OR. xTIPO=='I' .OR. xTIPO=='S' .OR. xTIPO=='T' .OR. xTIPO=='O'

         dbSelectArea("SA1")                // * Cadastro de Clientes
         dbSetOrder(1)
         dbSeek(xFilial()+xCLIENTE+xLOJA)
         xCOD_CLI :=SA1->A1_COD             // Codigo do Cliente
         xNOME_CLI:=SA1->A1_NOME            // Nome
         xEND_CLI :=SA1->A1_END             // Endereco
         xBAIRRO  :=SA1->A1_BAIRRO          // Bairro
         xCEP_CLI :=SA1->A1_CEP             // CEP
         xCOB_CLI :=SA1->A1_ENDCOB          // Endereco de Cobranca
         xREC_CLI :=SA1->A1_ENDENT          // Endereco de Entrega
         xMUN_CLI :=SA1->A1_MUN             // Municipio
         xEST_CLI :=SA1->A1_EST             // Estado
         xCGC_CLI :=SA1->A1_CGC             // CGC
         xINSC_CLI:=SA1->A1_INSCR           // Inscricao estadual
         xTRAN_CLI:=SA1->A1_TRANSP          // Transportadora
         xTEL_CLI :=SA1->A1_TEL             // Telefone
         xFAX_CLI :=SA1->A1_FAX             // Fax
         xSUFRAMA :=SA1->A1_SUFRAMA            // Codigo Suframa
         xCALCSUF :=SA1->A1_CALCSUF            // Calcula Suframa
         // Alteracao p/ Calculo de Suframa
         if !empty(xSUFRAMA) .and. xCALCSUF =="S"
            IF XTIPO == 'D' .OR. XTIPO == 'B'
               zFranca := .F.
            else
               zFranca := .T.
            endif
         Else
            zfranca:= .F.
         endif

      Else
         zFranca:=.F.
         dbSelectArea("SA2")                // * Cadastro de Fornecedores
         dbSetOrder(1)
         dbSeek(xFilial()+xCLIENTE+xLOJA)
         xCOD_CLI :=SA2->A2_COD             // Codigo do Fornecedor
         xNOME_CLI:=SA2->A2_NOME            // Nome Fornecedor
         xEND_CLI :=SA2->A2_END             // Endereco
         xBAIRRO  :=SA2->A2_BAIRRO          // Bairro
         xCEP_CLI :=SA2->A2_CEP             // CEP
         xCOB_CLI :=""                      // Endereco de Cobranca
         xREC_CLI :=""                      // Endereco de Entrega
         xMUN_CLI :=SA2->A2_MUN             // Municipio
         xEST_CLI :=SA2->A2_EST             // Estado
         xCGC_CLI :=SA2->A2_CGC             // CGC
         xINSC_CLI:=SA2->A2_INSCR           // Inscricao estadual
         xTRAN_CLI:=SA2->A2_TRANSP          // Transportadora
         xTEL_CLI :=SA2->A2_TEL             // Telefone
         xFAX_CLI :=SA2->A2_FAX             // Fax
      Endif
      dbSelectArea("SA3")                   // * Cadastro de Vendedores
      dbSetOrder(1)
      xVENDEDOR:={}                         // Nome do Vendedor
      I:=1
      J:=Len(xCOD_VEND)
      For I:=1 to J
         dbSeek(xFilial()+xCOD_VEND[I])
         Aadd(xVENDEDOR,SA3->A3_NREDUZ)
      Next j

      If xICMS_RET >0                          // Apenas se ICMS Retido > 0
         dbSelectArea("SF3")                   // * Cadastro de Livros Fiscais
         dbSetOrder(4)
         dbSeek(xFilial()+SA1->A1_COD+SA1->A1_LOJA+SF2->F2_DOC+SF2->F2_SERIE)
         If Found()
            xBSICMRET:=F3_VALOBSE
         Else
            xBSICMRET:=0
         Endif
      Else
         xBSICMRET:=0
      Endif
      dbSelectArea("SA4")                   // * Transportadoras
      dbSetOrder(1)
      dbSeek(xFilial()+SF2->F2_TRANSP)
      xNOME_TRANSP :=SA4->A4_NOME           // Nome Transportadora
      xEND_TRANSP  :=SA4->A4_END            // Endereco
      xMUN_TRANSP  :=SA4->A4_MUN            // Municipio
      xEST_TRANSP  :=SA4->A4_EST            // Estado
      xVIA_TRANSP  :=SA4->A4_VIA            // Via de Transporte
      xCGC_TRANSP  :=SA4->A4_CGC            // CGC
      xTEL_TRANSP  :=SA4->A4_TEL            // Fone

      dbSelectArea("SE1")                   // * Contas a Receber
      dbSetOrder(1)
      xPARC_DUP  :={}                       // Parcela
      xVENC_DUP  :={}                       // Vencimento
      xVALOR_DUP :={}                       // Valor
      xDUPLICATAS:=IIF(dbSeek(xFilial()+xSERIE+xNUM_DUPLIC,.T.),.T.,.F.) // Flag p/Impressao de Duplicatas

      while !eof() .and. SE1->E1_NUM==xNUM_DUPLIC .and. xDUPLICATAS==.T.
         If !("NF" $ SE1->E1_TIPO)
            dbSkip()
            Loop
         Endif
         AADD(xPARC_DUP ,SE1->E1_PARCELA)
         AADD(xVENC_DUP ,SE1->E1_VENCTO)
         AADD(xVALOR_DUP,SE1->E1_VALOR)
         dbSkip()
      EndDo

      dbSelectArea("SF4")                   // * Tipos de Entrada e Saida
      DbSetOrder(1)
      dbSeek(xFilial()+xTES[1])
      xNATUREZA:=SF4->F4_TEXTO              // Natureza da Operacao

///////////////////////////////////////////////////////////////

ELSE

////////////////////////////////////////////////////////////////
      //+--------------------------------------------------------------+
      //¦ Inicio de Levantamento dos Dados da Nota Fiscal              ¦
      //+--------------------------------------------------------------+

      xNUM_NF     :=SF1->F1_DOC             // Numero
      xSERIE      :=SF1->F1_SERIE           // Serie
      xFORNECE    :=SF1->F1_FORNECE         // Cliente/Fornecedor
      xEMISSAO    :=SF1->F1_EMISSAO         // Data de Emissao
      xTOT_FAT    :=SF1->F1_VALBRUT         // Valor Bruto da Compra
      xLOJA       :=SF1->F1_LOJA            // Loja do Cliente
      xFRETE      :=SF1->F1_FRETE           // Frete
      xSEGURO     :=SF1->F1_DESPESA         // Despesa
      xBASE_ICMS  :=SF1->F1_BASEICM         // Base   do ICMS
      xBASE_IPI   :=SF1->F1_BASEIPI         // Base   do IPI
      xBSICMRET   :=SF1->F1_BRICMS          // Base do ICMS Retido
      xVALOR_ICMS :=SF1->F1_VALICM          // Valor  do ICMS
      xICMS_RET   :=SF1->F1_ICMSRET         // Valor  do ICMS Retido
      xVALOR_IPI  :=SF1->F1_VALIPI          // Valor  do IPI
      xVALOR_MERC :=SF1->F1_VALMERC         // Valor  da Mercadoria
      xNUM_DUPLIC :=SF1->F1_DUPL            // Numero da Duplicata
      xCOND_PAG   :=SF1->F1_COND            // Condicao de Pagamento
      xTIPO       :=SF1->F1_TIPO            // Tipo do Cliente
      xNFORI      :="" //SF1->F1_NFORI           // NF Original
      xPREF_DV    :="" //SF1->F1_SERIORI         // Serie Original

      dbSelectArea("SD1")                   // * Itens da N.F. de Compra
      dbSetOrder(1)
      dbSeek(xFilial()+xNUM_NF+xSERIE+xFORNECE+xLOJA)

      cPedAtu := SD1->D1_PEDIDO
      cItemAtu:= SD1->D1_ITEMPC

      xPEDIDO  :={}                         // Numero do Pedido de Compra
      xITEM_PED:={}                         // Numero do Item do Pedido de Compra
      xNUM_NFDV:={}                         // Numero quando houver devolucao
      xPREF_DV :={}                         // Serie  quando houver devolucao
      xICMS    :={}                         // Porcentagem do ICMS
      xCOD_PRO :={}                         // Codigo  do Produto
      xQTD_PRO :={}                         // Peso/Quantidade do Produto
      xPRE_UNI :={}                         // Preco Unitario de Compra
      xIPI     :={}                         // Porcentagem do IPI
      xPESOPROD:={}                         // Peso do Produto
      xVAL_IPI :={}                         // Valor do IPI
      xDESC    :={}                         // Desconto por Item
      xVAL_DESC:={}                         // Valor do Desconto
      xVAL_MERC:={}                         // Valor da Mercadoria
      xTES     :={}                         // TES
      xCF      :={}                         // Classificacao quanto natureza da Operacao
      xICMSOL  :={}                         // Base do ICMS Solidario
      xICM_PROD:={}                         // ICMS do Produto

      while !eof() .and. SD1->D1_DOC==xNUM_NF
         If SD1->D1_SERIE #mv_par03        // Se a Serie do Arquivo for Diferente
              DbSkip()                      // do Parametro Informado !!!
              Loop
         Endif

         AADD(xPEDIDO ,SD1->D1_PEDIDO)           // Ordem de Compra
         AADD(xITEM_PED ,SD1->D1_ITEMPC)         // Item da O.C.
         AADD(xNUM_NFDV ,IIF(Empty(SD1->D1_NFORI),"",SD1->D1_NFORI))
         AADD(xPREF_DV  ,SD1->D1_SERIORI)        // Serie Original
         AADD(xICMS     ,IIf(Empty(SD1->D1_PICM),0,SD1->D1_PICM))
         AADD(xCOD_PRO  ,SD1->D1_COD)            // Produto
         AADD(xQTD_PRO  ,SD1->D1_QUANT)          // Guarda as quant. da NF
         AADD(xPRE_UNI  ,SD1->D1_VUNIT)          // Valor Unitario
         AADD(xIPI      ,SD1->D1_IPI)            // % IPI
         AADD(xVAL_IPI  ,SD1->D1_VALIPI)         // Valor do IPI
         AADD(xPESOPROD ,SD1->D1_PESO)           // Peso do Produto
         AADD(xDESC     ,SD1->D1_DESC)           // % Desconto
         AADD(xVAL_MERC ,SD1->D1_TOTAL)          // Valor Total
         AADD(xTES      ,SD1->D1_TES)            // Tipo de Entrada/Saida
         AADD(xCF       ,SD1->D1_CF)             // Codigo Fiscal
         AADD(xICM_PROD ,IIf(Empty(SD1->D1_PICM),0,SD1->D1_PICM))
         dbskip()
      End

      dbSelectArea("SB1")                     // * Desc. Generica do Produto
      dbSetOrder(1)
      xUNID_PRO:={}                           // Unidade do Produto
      xDESC_PRO:={}                           // Descricao do Produto
      xMEN_POS :={}                           // Mensagem da Posicao IPI
      xDESCRICAO :={}                         // Descricao do Produto
      xCOD_TRIB:={}                           // Codigo de Tributacao
      xMEN_TRIB:={}                           // Mensagens de Tributacao
      xCOD_FIS :={}                           // Cogigo Fiscal
      xCLAS_FIS:={}                           // Classificacao Fiscal
      xISS     :={}                           // Aliquota de ISS
      xTIPO_PRO:={}                           // Tipo do Produto
      xLUCRO   :={}                           // Margem de Lucro p/ ICMS Solidario
      xCLFISCAL   :={}
      xSUFRAMA :=""
      xCALCSUF :=""

      I:=1
      For I:=1 to Len(xCOD_PRO)

         dbSeek(xFilial()+xCOD_PRO[I])
         dbSelectArea("SB1")

         AADD(xDESC_PRO ,SB1->B1_DESC)
         AADD(xUNID_PRO ,SB1->B1_UM)
         AADD(xCOD_TRIB ,SB1->B1_ORIGEM)
         If Ascan(xMEN_TRIB, SB1->B1_ORIGEM)==0
            AADD(xMEN_TRIB ,SB1->B1_ORIGEM)
         Endif
         AADD(xDESCRICAO ,SB1->B1_DESC)
         AADD(xMEN_POS  ,SB1->B1_POSIPI)
         If SB1->B1_ALIQISS > 0
            AADD(xISS,SB1->B1_ALIQISS)
         Endif
         AADD(xTIPO_PRO ,SB1->B1_TIPO)
         AADD(xLUCRO    ,SB1->B1_PICMRET)

         npElem := ascan(xCLAS_FIS,SB1->B1_POSIPI)

         if npElem == 0
            AADD(xCLAS_FIS  ,SB1->B1_POSIPI)
         endif
         npElem := ascan(xCLAS_FIS,SB1->B1_POSIPI)

         DO CASE
            CASE npElem == 1
               _CLASFIS := "A"

            CASE npElem == 2
               _CLASFIS := "B"

            CASE npElem == 3
               _CLASFIS := "C"

            CASE npElem == 4
               _CLASFIS := "D"

            CASE npElem == 5
               _CLASFIS := "E"

            CASE npElem == 6
               _CLASFIS := "F"

         EndCase
         nPteste := Ascan(xCLFISCAL,_CLASFIS)
         If nPteste == 0
            AADD(xCLFISCAL,_CLASFIS)
         Endif
         AADD(xCOD_FIS ,_CLASFIS)

      Next I

      //+---------------------------------------------+
      //¦ Pesquisa da Condicao de Pagto               ¦
      //+---------------------------------------------+

      dbSelectArea("SE4")                    // Condicao de Pagamento
      dbSetOrder(1)
      dbSeek(xFilial("SE4")+xCOND_PAG)
      xDESC_PAG := SE4->E4_DESCRI

      If xTIPO == "D"

         dbSelectArea("SA1")                // * Cadastro de Clientes
         dbSetOrder(1)
         dbSeek(xFilial()+xFORNECE)
         xCOD_CLI :=SA1->A1_COD             // Codigo do Cliente
         xNOME_CLI:=SA1->A1_NOME            // Nome
         xEND_CLI :=SA1->A1_END             // Endereco
         xBAIRRO  :=SA1->A1_BAIRRO          // Bairro
         xCEP_CLI :=SA1->A1_CEP             // CEP
         xCOB_CLI :=SA1->A1_ENDCOB          // Endereco de Cobranca
         xREC_CLI :=SA1->A1_ENDENT          // Endereco de Entrega
         xMUN_CLI :=SA1->A1_MUN             // Municipio
         xEST_CLI :=SA1->A1_EST             // Estado
         xCGC_CLI :=SA1->A1_CGC             // CGC
         xINSC_CLI:=SA1->A1_INSCR           // Inscricao estadual
         xTRAN_CLI:=SA1->A1_TRANSP          // Transportadora
         xTEL_CLI :=SA1->A1_TEL             // Telefone
         xFAX_CLI :=SA1->A1_FAX             // Fax

      Else

         dbSelectArea("SA2")                // * Cadastro de Fornecedores
         dbSetOrder(1)
         dbSeek(xFilial()+xFORNECE+xLOJA)
         xCOD_CLI :=SA2->A2_COD                // Codigo do Cliente
         xNOME_CLI:=SA2->A2_NOME               // Nome
         xEND_CLI :=SA2->A2_END                // Endereco
         xBAIRRO  :=SA2->A2_BAIRRO             // Bairro
         xCEP_CLI :=SA2->A2_CEP                // CEP
         xCOB_CLI :=""                         // Endereco de Cobranca
         xREC_CLI :=""                         // Endereco de Entrega
         xMUN_CLI :=SA2->A2_MUN                // Municipio
         xEST_CLI :=SA2->A2_EST                // Estado
         xCGC_CLI :=SA2->A2_CGC                // CGC
         xINSC_CLI:=SA2->A2_INSCR              // Inscricao estadual
         xTRAN_CLI:=SA2->A2_TRANSP             // Transportadora
         xTEL_CLI :=SA2->A2_TEL                // Telefone
         xFAX     :=SA2->A2_FAX                // Fax

      EndIf

      dbSelectArea("SE1")                   // * Contas a Receber
      dbSetOrder(1)
      xPARC_DUP  :={}                       // Parcela
      xVENC_DUP  :={}                       // Vencimento
      xVALOR_DUP :={}                       // Valor
      xDUPLICATAS:=IIF(dbSeek(xFilial()+xSERIE+xNUM_DUPLIC,.T.),.T.,.F.) // Flag p/Impressao de Duplicatas

      while !eof() .and. SE1->E1_NUM==xNUM_DUPLIC .and. xDUPLICATAS==.T.
         AADD(xPARC_DUP ,SE1->E1_PARCELA)
         AADD(xVENC_DUP ,SE1->E1_VENCTO)
         AADD(xVALOR_DUP,SE1->E1_VALOR)
         dbSkip()
      EndDo

      dbSelectArea("SF4")                   // * Tipos de Entrada e Saida
      dbSetOrder(1)
      dbSeek(xFilial()+SD1->D1_TES)
      xNATUREZA:=SF4->F4_TEXTO              // Natureza da Operacao

      xNOME_TRANSP :=" "           // Nome Transportadora
      xEND_TRANSP  :=" "           // Endereco
      xMUN_TRANSP  :=" "           // Municipio
      xEST_TRANSP  :=" "           // Estado
      xVIA_TRANSP  :=" "           // Via de Transporte
      xCGC_TRANSP  :=" "           // CGC
      xTEL_TRANSP  :=" "           // Fone
      xTPFRETE     :=" "           // Tipo de Frete
      xVOLUME      := 0            // Volume
      xESPECIE     :=" "           // Especie
      xPESO_LIQ    := 0            // Peso Liquido
      xPESO_BRUTO  := 0            // Peso Bruto
      xCOD_MENS    :=" "           // Codigo da Mensagem
      xMENSAGEM    :=" "           // Mensagem da Nota
      xPESO_LIQUID :=" "

      xValPis     := 0
      xValCofi    := 0
      xValCsll    := 0
      xValIrrf    := 0
      xValInss    := 0
      xValIss     := 0
////////////////////////////////////////////////////////////////

ENDIF

PrtDanfe(@oDanfe,aNota)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PrtDanfe  ³ Autor ³Eduardo Riera          ³ Data ³16.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do formulario DANFE grafico conforme laytout no   ³±±
±±³          ³formato retrato                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrtDanfe()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto grafico de impressao                          ³±±
±±³          ³ExpO2: Objeto da NFe                                        ³±±
±±³          ³ExpC3: Codigo de Autorizacao do fiscal                (OPC) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrtDanfe(oDanfe,aNota)

Local aTamanho      := {}
Local aSitTrib      := {}
Local aTransp       := {}
Local aDest         := {}
Local aFaturas      := {}
Local aItens        := {}
Local aISSQN        := {}
Local aTotais       := {}
Local aAux          := {}
Local nHPage        := 0 
Local nVPage        := 0 
Local nPosV         := 0
Local nPosVOld      := 0
Local nPosH         := 0
Local nPosHOld      := 0
Local nAuxH         := 0
//Local nAuxV         := 0
Local nX            := 0
Local nY            := 0
//Local nTamanho      := 0
Local nFolha        := 1
Local nFolhas       := 0
Local nItem         := 0
Local nMensagem     := 0
Local nBaseICM      := 0
Local nValICM       := 0
Local nValIPI       := 0
Local nPICM         := 0
Local nPIPI         := 0
Local nFaturas      := 0
Local nVTotal       := 0
Local nQtd          := 0
Local nVUnit        := 0
//Local nVolume	    := 0
Local cAux          := ""
Local cSitTrib      := ""
Local aMensagem     := {}
Local lPreview      := .F.
Local nLenFatura        
//Local nLenVol  
Local nLenDet 
//Local nLenSit     
Local nLenItens     := 0
Local nLenMensagens := 0
Local nLen          := 0

//Default cDtHrRecCab:= ""

//Private oNF        := oNFe:_NFe
//Private oEmitente  := oNF:_InfNfe:_Emit
//Private oIdent     := oNF:_InfNfe:_IDE
//Private oDestino   := oNF:_InfNfe:_Dest
//Private oTotal     := oNF:_InfNfe:_Total
//Private oTransp    := oNF:_InfNfe:_Transp
//Private oDet       := oNF:_InfNfe:_Det
//Private oFatura    := IIf(Type("oNF:_InfNfe:_Cobr")=="U",Nil,oNF:_InfNfe:_Cobr)
//Private oImposto  
Private nPrivate   := 0
Private nPrivate2  := 0
Private nXAux	   := 0

nFaturas   := LEN(xParc_dup)
//oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega as variaveis de impressao                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aSitTrib,"00")
aadd(aSitTrib,"10")
aadd(aSitTrib,"20")
aadd(aSitTrib,"30")
aadd(aSitTrib,"40")
aadd(aSitTrib,"41")
aadd(aSitTrib,"50")
aadd(aSitTrib,"51")
aadd(aSitTrib,"60")
aadd(aSitTrib,"70")
aadd(aSitTrib,"90")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro Destinatario                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDest := {  xEnd_cli,;
			xBairro,;
			Transform(xCep_cli,"@r 99999-999"),;
			"_DSaiEnt",;
			xMun_cli,;
			xTel_cli,;
			xEst_cli,;
			xInsc_Cli,;
			""}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do Imposto                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTotais := {"","","","","","","","","","",""}
aTotais[01] := Transform(xBASE_ICMS,  "@ze 999,999,999.99")
aTotais[02] := Transform(xVALOR_ICMS, "@ze 9,999,999.99")
aTotais[03] := Transform(xBsIcmRet,   "@ze 999,999,999.99")
aTotais[04] := Transform(xICMS_RET,   "@ze 9,999,999.99")
aTotais[05] := Transform(xVALOR_MERC, "@ze 9,999,999.99")
aTotais[06] := Transform(xFRETE,      "@ze 9,999,999.99")
aTotais[07] := Transform(xSEGURO,     "@ze 9,999,999.99")
aTotais[08] := Transform(0,           "@ze 9,999,999.99")    //_vDesc
aTotais[09] := Transform(0,           "@ze 9,999,999.99")   //_vOutro
aTotais[10] := 	Transform(xVALOR_IPI, "@ze 9,999,999.99")
aTotais[11] := 	Transform(xTOT_FAT,   "@ze 999,999,999.99")	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro Faturas                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nFaturas > 0
	For nX := 1 To Min(3,nFaturas)
		aadd(aFaturas,{"TITULO","VENCTO","VALOR"})
	Next nX
	nLenFatura := Len(aFaturas)+1
	For nX := nLenFatura To 3
		aadd(aFaturas,{Space(3),SPACE(10),SPACE(14)})
	Next nX
	If nFaturas > 1
		For nX := 1 To Min(3,nFaturas)
			aadd(aFaturas,{xParc_Dup[nX],DTOC(xVenc_Dup[nX]),TransForm(xValor_dup[nX],"@e 9999,999,999.99")})
		Next nX
	Else
		aadd(aFaturas,{Space(3),SPACE(10),SPACE(14)})
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro transportadora                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTransp := {"","0","","","","","","","","","","","","","",""}
                                   
If !EMPTY(xNOME_TRANSP)
	aTransp[01] := xNOME_TRANSP
	aTransp[02] := IIF(xTpFrete == 'C',1,2)
	aTransp[03] := ""  // Veiculo
	aTransp[04] := ""  // Placa
	aTransp[05] := ""  // UF Placa
	If !EMPTY(xCGC_TRANSP)
		If Len(AllTrim(xCGC_TRANSP)) > 11
			aTransp[06] := Transform(xCGC_TRANSP,"@r 99.999.999/9999-99")
		Else
			aTransp[06] := Transform(xCGC_TRANSP,"@r 999.999.999-99")
		EndIf	
	Else
		aTransp[06] := ""
	EndIf
	aTransp[07] := xEND_TRANSP
	aTransp[08] := xMUN_TRANSP
	aTransp[09] := xEST_TRANSP
	aTransp[10] := ""  	// Reservado p/Insc. Estad. transp
EndIf
aTransp[11]	:= Transform(xVOLUME,"@E 999,999.99")
aTransp[12]	:= xEspecie
aTransp[13] := ""   //Marca
aTransp[14] := ""   //nVol
aTransp[15] := Transform(xPESO_BRUTO,"@E 999,999.99")
aTransp[16] := Transform(xPESO_LIQUID,"@E 999,999.99")


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro Dados do Produto / Serviço                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLenDet := Len(xCOD_PRO)
For nX := 1 To nLenDet
	nPrivate := nX
	nVTotal  := xVAL_MERC[nX]
	nQtd     := xQTD_PRO[nX]
	nVUnit   := xPRE_UNI[nX]
	nBaseICM := 0
	nValICM  := xICM_PROD[nX]
	nValIPI  := xVAL_IPI[nX]
	nPICM    := xICM_PROD[nX]
	nPIPI    := xIPI[nX]
	//oImposto := oDet[nX]
	cSitTrib := ""
	aadd(aItens,{   xCOD_PRO[nX],;
					SubStr(xDESCRICAO[nX],1,MAXITEMC),;
					AllTrim(TransForm(nVTotal,TM(nVTotal,TamSX3("D2_TOTAL")[1]+4,TamSX3("D2_TOTAL")[2]))) })

					//xCF[nX],;
					//xCOD_FIS[nX],;
					//cSitTrib,;
					//xCF[nX],;
					//"",;   //oDet[nX]:_Prod:_utrib:TEXT,;
					//AllTrim(TransForm(nQtd,TM(nQtd,TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2]))),;
					//AllTrim(TransForm(nVUnit,TM(nVUnit,TamSX3("D2_PRCVEN")[1],4))),;
					//AllTrim(TransForm(nBaseICM,TM(nBaseICM,TamSX3("D2_BASEICM")[1],TamSX3("D2_BASEICM")[2]))),;
					//AllTrim(TransForm(nValICM,TM(nValICM,TamSX3("D2_VALICM")[1],TamSX3("D2_VALICM")[2]))),;
					//AllTrim(TransForm(nValIPI,TM(nValIPI,TamSX3("D2_VALIPI")[1],TamSX3("D2_BASEIPI")[2]))),;
					//AllTrim(TransForm(nPICM,"@r 99%")),;
					//AllTrim(TransForm(nPIPI,"@r 99%"))})
					
	cAux := AllTrim(SubStr(xDESCRICAO[nX],(MAXITEMC + 1)))
	While !Empty(cAux)
		aadd(aItens,{"",;
					SubStr(cAux,1,MAXITEMC),;
					""})

/*
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					""})
*/					
		cAux := SubStr(cAux,(MAXITEMC + 1))
	EndDo
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro ISSQN                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aISSQN := {"","","",""}
//If Type("oEmitente:_IM:TEXT")<>"U"
//	aISSQN[1] := oEmitente:_IM:TEXT
//EndIf  
//If Type("oTotal:_ISSQNtot")<>"U"
//	aISSQN[2] := Transform(Val(oTotal:_ISSQNtot:_vServ:TEXT),"@ze 999,999,999.99")	
//	aISSQN[3] := Transform(Val(oTotal:_ISSQNtot:_vBC:TEXT),"@ze 999,999,999.99")	
//	aISSQN[4] := Transform(Val(oTotal:_ISSQNtot:_vISS:TEXT),"@ze 999,999,999.99")	
//EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro de informacoes complementares                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aMensagem := {}
cMsg := ""
If !EMPTY(cMsg)
	cAux := cMsg
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do numero de folhas                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nFolhas := 1
nLenItens := Len(aItens)
nLen := nLenItens + Len(aMensagem)
If nLen > (MAXITEM + Min(Len(aMensagem), MAXMSG))
	nFolhas += Int((nLen - (MAXITEM + Min(Len(aMensagem), MAXMSG))) / MAXITEMP2)
	If Mod((nLen - (MAXITEM + Min(Len(aMensagem), MAXMSG))), MAXITEMP2) > 0
		nFolhas++
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao do objeto grafico                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oDanfe == Nil
	lPreview := .T.
	oDanfe 	:= TMSPrinter():New("Formulario de Conferencia - Nota Fiscal Eletrônica")
	oDanfe:SetPortrait()
	oDanfe:Setup()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao da pagina do objeto grafico                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:StartPage()
oDanfe:SetPaperSize(9)
nHPage := oDanfe:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oDanfe:nVertRes() 
nVPage *= (300/PixelY)
nVPage -= VBOX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao do Box - Recibo de entrega                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//aTamanho := ImpBox(0,0,0,nHPage-Char2Pix(oDanfe,Repl("X",22),oFont10N),;
//	{	{"RECEBEMOS DE "+TRIM(SM0->M0_NOMECOM)+" OS PRODUTOS CONSTANTES DA NOTA FISCAL INDICADA AO LADO"},;
//		{{"DATA DE RECEBIMENTO"," "},{"IDENTIFICAÇÃO E ASSINATURA DO RECEBEDOR",PadR(" ",200)}}},;
//	oDanfe)

//aTamanho := ImpBox(0,0,0,nHPage-Char2Pix(oDanfe,Repl("X",22),oFont10N),;
//	{	{{PADR("PRE-NOTA DE SAIDA DE SERVIÇOS",200),PadR(" ",200),PadR(" ",200),PadR(" ",200)}} },;
//	oDanfe)
	
//aTamanho := ImpBox(0,nHPage-Char2Pix(oDanfe,Repl("X",20),oFont10N),0,nHPage,;
//	{	{{PadR("NUMERO: "+StrZero(Val(aNota[5]),9),20),PadR("SÉRIE : "+aNota[4],20),SPACE(20)}}},;
//		oDanfe,2)

nPosV    := VMARGEM //aTamanho[1]+(VBOX/2)
oDanfe:Line(nPosV,HMARGEM,nPosV,nHPage) 

nPosV    += (VBOX/2)

nPosV := DanfeCab(oDanfe,nPosV,@nFolha,nFolhas,aNota)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro destinatário/remetente                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !EMPTY(xCGC_CLI) 															// Se o C.G.C. do Cli/Forn nao for Vazio
	If Len(AllTrim(xCGC_CLI)) > 11											//Se for CNPJ
		cAux := TransForm(xCGC_CLI,"@R 99.999.999/9999-99")
	Else 																	//Se for CPF
		cAux := TransForm(xCGC_CLI,"@R 999.999.999-99")
	EndIf
Endif

aTamanho := ImpBox(nPosV,0,0,nHPage-Char2Pix(oDanfe,Repl("X",22),oFont08),;
	{	{{"NOME/RAZÃO SOCIAL",xNOME_CLI},{"CNPJ/CPF",cAux}},;
		{{"ENDEREÇO",aDest[01]},{"BAIRRO/DISTRITO",aDest[02]},{"CEP",aDest[03]}},;
		{{"MUNICIPIO",aDest[05]},{"FONE/FAX",aDest[06]},{"UF",aDest[07]},{"INSCRIÇÃO ESTADUAL",aDest[08]}}},;
	oDanfe,1,"DESTINATÁRIO/REMETENTE")
	
aTamanho := ImpBox(nPosV,nHPage-Char2Pix(oDanfe,Repl("X",20),oFont08),0,nHPage,;
	{	{{"DATA DE EMISSÃO",DTOC(xEMISSAO)}},;
		{{"DATA ENTRADA/SAÍDA", Iif( Empty(aDest[4]),"",ConvDate(aDest[4]) )  }},;
		{{"HORA ENTRADA/SAÍDA",aDest[09]}}},;
	oDanfe,1,"")
nPosV    := aTamanho[1]+VSPACE
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro fatura                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := {{{},{},{},{},{},{},{},{},{}}}
nY := 0
nLenFatura := Len(aFaturas)
For nX := 1 To nLenFatura
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][1])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][2])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][3])
	If nY >= 9
		nY := 0
	EndIf
Next nX

aTamanho := ImpBox(nPosV,0,0,nHPage,aAux,oDanfe,1,"FATURA")
nPosV    := aTamanho[1]+VSPACE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do imposto                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
aTamanho := ImpBox(nPosV,0,0,nHPage,;
	{	{{"BASE DE CALCULO DO ICMS",aTotais[01]},{"VALOR DO ICMS",aTotais[02]},{"BASE DE CALCULO DO ICMS SUBSTITUIÇÃO",aTotais[03]},{"VALOR DO ICMS SUBSTITUIÇÃO",aTotais[04]},{"VALOR TOTAL DOS PRODUTOS",aTotais[05]}},;
		{{"VALOR DO FRETE",aTotais[06]},{"VALOR DO SEGURO",aTotais[07]},{"DESCONTO",aTotais[08]},{"OUTRAS DESPESAS ACESSÓRIAS",aTotais[09]},{"VALOR DO IPI",aTotais[10]},{"VALOR TOTAL DA NOTA",aTotais[11]}}},;
	oDanfe,1,"CALCULO DO IMPOSTO")
nPosV    := aTamanho[1]+VSPACE
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transportador/Volumes transportados                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTamanho := ImpBox(nPosV,0,0,nHPage,;
	{	{{"RAZÃO SOCIAL",aTransp[01]},{"FRETE POR CONTA","0-EMITENTE/1-DESTINATARIO [" + aTransp[02] + "]"},{"CÓDIGO ANTT",aTransp[03]},{"PLACA DO VEÍCULO",aTransp[04]},{"UF",aTransp[05]},{"CNPJ/CPF",aTransp[06]}},;
		{{"ENDEREÇO",aTransp[07]},{"MUNICIPIO",aTransp[08]},{"UF",aTransp[09]},{"INSCRIÇÃO ESTADUAL",aTransp[10]}},;
		{{"QUANTIDADE",aTransp[11]},{"ESPECIE",aTransp[12]},{"MARCA",aTransp[13]},{"NUMERAÇÃO",aTransp[14]},{"PESO BRUTO",aTransp[15]},{"PESO LIQUIDO",aTransp[16]}}},;
	oDanfe,1,"TRANSPORTADOR/VOLUMES TRANSPORTADOS")

nPosV    := aTamanho[1]+VSPACE
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados do produto ou servico                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//aAux := {{{"COD.PROD."},{"DESCRIÇÃO DO PRODUTO/SERVIÇO"},{"NCM/SH"},{"CST"},{"CFOP"},{"UN"},{"QUANTIDADE"},{"V.UNITARIO"},{"V.TOTAL"},;
//		{"BC.ICMS"},{"V.ICMS"},{"V.IPI"},{"A.ICM"},{"A.IPI"}}}
*/

aAux := {{{"COD.PROD."},{"DESCRIÇÃO DO PRODUTO/SERVIÇO"},{"VALOR TOTAL"}}}

nY := 0
nLenItens := Len(aItens)
For nX := 1 To MIN(MAXITEM,nLenItens)
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][01])
	nY++
	aadd(Atail(aAux)[nY],PADR(aItens[nX][02],50))
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][03])
	//nY++
	//aadd(Atail(aAux)[nY],aItens[nX][04])
	/*
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][05])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][06])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][07])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][08])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][09])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][10])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][11])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][12])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][13])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][14])	
	*/
	If nY >= 3
		nY := 0
	EndIf
Next nX
For nX := MIN(MAXITEM,nLenItens) To MAXITEM
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	//nY++
	//aadd(Atail(aAux)[nY],"")
	/*
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	*/
	If nY >= 3
		nY := 0
	EndIf	
Next nX

//aTamanho := ImpBox(nPosV,0,0,nHPage,;
//	aAux,;
//	oDanfe,3,"DADOS DO PRODUTO / SERVIÇO",{"L","L","L","L","L","L","R","R","R","R","R","R","R","R"},0,;
//	{.T., .F., .T., .T., .T., .T., .T., .T., .T., .T., .T., .T., .T., .T.})

aTamanho := ImpBox(nPosV,0,0,nHPage,;
	aAux,;
	oDanfe,3,"DADOS DO PRODUTO / SERVIÇO",{"L","L","R"},2) //,;
	//{.F., .T., .F.})

	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pontilhado entre os produtos/serviços³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Monta o pontilhado
/*
If Len(aAux) > 0
	If Len(aAux[1]) > 1
		If Len(aAux[1][2]) > 3
			// 3 pois com apenas uma linha de produtos o array terá 3, uma para o cabeçalho dos campos, uma linha do produto em si e outra em branco
			// Calcula a posição vertical do pontilhado (utiliza-se oFont08 para o calculo pois na função ImpBox é a fonte usada neste box
			nAuxV := nPosV + ((Char2PixV(oDanfe, "X", oFont08) + SAYVSPACE) * 3)
			For nX := 3 To Len(aAux[1][2])
				nAuxV += SAYVSPACE
				If !Empty(aAux[1][1][nX]) .And. Empty(aAux[1][1][nX - 1])
					// Estamos tratando um novo produto com uma linha de descrição de um produto anterior antes dele
					// Escreve o pontilhado
					For nY := HMARGEM To nHPage
						oDanfe:Say(nAuxV, nY, ".", oFont08:oFont)
						nY += 20
					Next nY
				EndIf
				nAuxV += (Char2PixV(oDanfe, "X", oFont08) + SAYVSPACE * 2)
			Next nX
		EndIf
	EndIf
EndIf
*/

nPosV    := aTamanho[1]+VSPACE
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impostos retidos                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTamanho := ImpBox(nPosV,0,0,nHPage,;
	{	{{"IRRF",TRANSFORM(xValIrrf,"@ze 999,999,999.99")},;
	     {"INSS",TRANSFORM(xValInss,"@ze 999,999,999.99")},;
	     {"ISS",TRANSFORM(xValIss,"@ze 999,999,999.99")},;
	     {"PIS",TRANSFORM(xValPis,"@ze 999,999,999.99")},;
	     {"COFINS",TRANSFORM(xValCofi,"@ze 999,999,999.99")},;
	     {"CSLL",TRANSFORM(xValCsll,"@ze 999,999,999.99")}}},;
	oDanfe,1,"IMPOSTOS A SEREM RETIDOS")
nPosV    := aTamanho[1]+VSPACE
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do ISSQN                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTamanho := ImpBox(nPosV,0,0,nHPage,;
	{	{{"INSCRIÇÃO MUNICIPAL",aISSQN[1]},{"VALOR TOTAL DOS SERVIÇOS",aISSQN[2]},{"BASE DE CÁLCULO DO ISSQN",aISSQN[3]},{"VALOR DO ISSQN",aISSQN[4]}}},;
	oDanfe,1,"CáLCULO DO ISSQN")
nPosV    := aTamanho[1]+VSPACE
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados Adicionais                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosVOld := nPosV+(VSPACE/2)
nPosV += VBOX*4
nPosHOld := HMARGEM
nPosH    := nHPage
	oDanfe:Say(nPosVOld,nPosHold,"DADOS ADICIONAIS",oFont11N:oFont)
nPosV    += Char2PixV(oDanfe,"X",oFont11N)*2
nPosVOld += Char2PixV(oDanfe,"X",oFont11N)*2
	oDanfe:Box(nPosVOld,nPosHOld,nVPage,nPosH)
	nAuxH := nPosHOld+010
	oDanfe:Say(nPosVOld+Char2PixV(oDanfe,"X",oFont11N),nAuxH,"INFORMAÇÕES COMPLEMENTARES",oFont11N:oFont)	
	nAuxH := (nHPage/2)+10
	oDanfe:Box(nPosVOld,nAuxH+305,nVPage,nPosH)
	oDanfe:Say(nPosVOld+Char2PixV(oDanfe,"X",oFont07N),nAuxH+320,"RESERVADO AO FISCO",oFont11N:oFont)	
	nAuxH := nPosHOld+010
	nPosV    += Char2PixV(oDanfe,"X",oFont11N)*2
	nPosVOld += Char2PixV(oDanfe,"X",oFont11N)*2
	nLenMensagens := Len(aMensagem)
	nMensagem := 1
	For nX := nMensagem To Min(nLenMensagens, MAXMSG)
		nPosVOld += Char2PixV(oDanfe,"X",oFont12)*2
		oDanfe:Say(nPosVOld,nAuxH,aMensagem[nX],oFont12:oFont)
		nMensagem++
	Next nX
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Finalizacao da pagina do objeto grafico                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:EndPage()
nItem := MAXITEM+1
nLenItens := Len(aItens)
nLenMensagens := Len(aMensagem)
While nItem <= nLenItens .Or. nMensagem <= nLenMensagens
	DanfeCpl(oDanfe,aItens,aMensagem,@nItem,@nMensagem,oNFe,oIdent,oEmitente,@nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab)
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Finaliza a Impressão                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If lPreview
	oDanfe:Preview()
EndIf
Return(.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao do Cabecalho do documento                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function DanfeCab(oDanfe,nPosV,nFolha,nFolhas,aNota)

Local aTamanho   := {}
Local aUF		 := {}
Local cLogo      := FisxLogo("1")
Local nHPage     := 0
Local nVPage     := 0 
Local nPosVOld   := 0
Local nPosH      := 0
Local nPosHOld   := 0
Local nAuxV      := 0
Local nAuxH      := 0
//Local cChaveCont := ""
//Local cDataEmi   := ""
//Local cDigito    := ""
//Local cTPEmis    := ""
//Local cValIcm    := ""
//Local cICMSp     := ""
//Local cICMSs     := "" 
//Local cUF		 := ""
//Local cCNPJCPF	 := ""

//Private oDPEC    :=oNfeDPEC

//Default cCodAutSef := ""
//Default cCodAutDPEC:= ""
//Default cDtHrRecCab:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenchimento do Array de UF                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aUF,{"RO","11"})
aadd(aUF,{"AC","12"})
aadd(aUF,{"AM","13"})
aadd(aUF,{"RR","14"})
aadd(aUF,{"PA","15"})
aadd(aUF,{"AP","16"})
aadd(aUF,{"TO","17"})
aadd(aUF,{"MA","21"})
aadd(aUF,{"PI","22"})
aadd(aUF,{"CE","23"})
aadd(aUF,{"RN","24"})
aadd(aUF,{"PB","25"})
aadd(aUF,{"PE","26"})
aadd(aUF,{"AL","27"})
aadd(aUF,{"MG","31"})
aadd(aUF,{"ES","32"})
aadd(aUF,{"RJ","33"})
aadd(aUF,{"SP","35"})
aadd(aUF,{"PR","41"})
aadd(aUF,{"SC","42"})
aadd(aUF,{"RS","43"})
aadd(aUF,{"MS","50"})
aadd(aUF,{"MT","51"})
aadd(aUF,{"GO","52"})
aadd(aUF,{"DF","53"})
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
aadd(aUF,{"EX","99"})

nHPage := oDanfe:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oDanfe:nVertRes() 
nVPage *= (300/PixelY)
nVPage -= VBOX
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 1                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosVOld := nPosV
nPosV    := nPosV + 380
nPosHOld := HMARGEM
nPosH    := 1128
	//oDanfe:Box(nPosVOld,nPosHOld,nPosV,nPosH)
	oDanfe:SayBitmap(nPosVOld+5,nPosHOld+5,cLogo,300,090)	
	nAuxV := nPosVOld + SAYVSPACE
    nAuxH := nPosHOld+SAYHSPACE+400   //320
	///oDanfe:Say(nAuxV,nAuxH,"identificação do Emitente",oFont08N:oFont)
	///nAuxV += Char2PixV(oDanfe,"X",oFont08N)+SAYVSPACE+100	
	oDanfe:Say(nAuxV,nAuxH,SM0->M0_NOMECOM,oFont18N:oFont)
	nAuxV += Char2PixV(oDanfe,"X",oFont18N)+ (SAYVSPACE*3)
	oDanfe:Say(nAuxV,nAuxH,SM0->M0_ENDCOB,oFont10N:oFont)
	nAuxV += Char2PixV(oDanfe,"X",oFont10N)+SAYVSPACE
	oDanfe:Say(nAuxV,nAuxH,TRIM(SM0->M0_BAIRCOB)+" Cep:"+TransForm(SM0->M0_CEPCOB,"@r 99999-999"),oFont10N:oFont)
	nAuxV += Char2PixV(oDanfe,"X",oFont10N)+SAYVSPACE
    ///oDanfe:Say(nAuxV,nAuxH,"Complemento: "+TRIM(SM0->M0_COMPCOB),oFont10:oFont)
	///nAuxV += Char2PixV(oDanfe,"X",oFont08N)+SAYVSPACE
	oDanfe:Say(nAuxV,nAuxH,TRIM(SM0->M0_CIDCOB)+"/"+SM0->M0_ESTCOB,oFont10N:oFont)  
	nAuxV += Char2PixV(oDanfe,"X",oFont10N)+SAYVSPACE
	oDanfe:Say(nAuxV,nAuxH,"Fone: "+SM0->M0_TEL,oFont10N:oFont)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 2                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nPosHOld := nPosH+HSPACE+520
nPosH    := nPosHOld + 760
nAuxV := nPosVOld
//oDanfe:Say(nAuxV,nPosHOld,"DANFE",oFont18N:oFont)
//nAuxV += Char2PixV(oDanfe,"X",oFont18N) + (SAYVSPACE*3)
nAuxH := nPosHOld
oDanfe:Say(nAuxV,nAuxH,"PRE-NOTA FISCAL DE SERVIÇOS",oFont10N:oFont)
nAuxV += Char2PixV(oDanfe,"X",oFont10N) + SAYVSPACE
//oDanfe:Say(nAuxV,nAuxH,"DE SERVIÇOS",oFont07:oFont)
//nAuxV += Char2PixV(oDanfe,"X",oFont08) + SAYVSPACE
//oDanfe:Say(nAuxV+10,nAuxH,"0-ENTRADA",oFont08:oFont)
//oDanfe:Say(nAuxV+40,nAuxH,"1-SAÍDA"  ,oFont08:oFont)
//oDanfe:Box(nAuxV+10,nAuxH+170,nAuxV+50,nAuxH+210)
//oDanfe:Say(nAuxV+15,nAuxH+180,aNota[2],oFont08:oFont)
nAuxV += 10
oDanfe:Say(nAuxV,nAuxH,IIf(aNota[2]="S","SAÍDA","ENTRADA"),oFont18N:oFont)
nAuxV += Char2PixV(oDanfe,"X",oFont18N) + (SAYVSPACE*3)
oDanfe:Say(nAuxV,nAuxH,"N. "+StrZero(Val(aNota[5]),9),oFont10N:oFont)
nAuxV += Char2PixV(oDanfe,"X",oFont11) + SAYVSPACE
oDanfe:Say(nAuxV,nAuxH,"SÉRIE "+aNota[4],oFont10N:oFont)
nAuxV += Char2PixV(oDanfe,"X",oFont11) + SAYVSPACE
oDanfe:Say(nAuxV,nAuxH,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)
nAuxV += Char2PixV(oDanfe,"X",oFont11) + SAYVSPACE

nPosHOld := nPosH+HSPACE
nPosH    := nHPage
//oDanfe:Box(nPosVOld,nPosHOld,nPosV,nPosH) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Codigo de barra                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cChave := REPLICATE("0",44)   // SubStr(oNF:_InfNfe:_ID:Text,4)

//If nFolha == 1
//	oDanfe:Box(260,1448,nPosV,nPosH) 
//	oDanfe:Box(260,1108,nPosV,nPosH) 
//	oDanfe:Box(510,1448,nPosV,nPosH) 
//	oDanfe:Box(420,1448,nPosV,nPosH) 
//	oDanfe:Box(520,1448,nPosV,nPosH) 
//	MSBAR3("CODE128",2.4*(300/PixelY),12.4*(299/PixelX),cChave,oDanfe,/*lCheck*/,/*Color*/,/*lHorz*/,.02960,0.9,/*lBanner*/,/*cFont*/,"C",.F.)
//	oDanfe:Say(430,1463,"CHAVE DE ACESSO DA NF-E",oFont07N:oFont)	
//	oDanfe:Say(450,1463,TransForm(cChave,"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont10N:oFont)		
//Else
//	oDanfe:Box(030,1448,nPosV,nPosH) 
//	oDanfe:Box(030,1108,nPosV,nPosH) 
//	oDanfe:Box(260,1448,nPosV,nPosH) 
//	oDanfe:Box(180,1448,nPosV,nPosH)
//	oDanfe:Box(270,1448,nPosV,nPosH) 	 
//	MSBAR3("CODE128",0.37*(300/PixelY),12.4*(299/PixelX),cChave,oDanfe,/*lCheck*/,/*Color*/,/*lHorz*/,.02960,0.9,/*lBanner*/,/*cFont*/,"C",.F.)
//	oDanfe:Say(200,1463,"CHAVE DE ACESSO DA NF-E",oFont07N:oFont)	
//	oDanfe:Say(225,1463,TransForm(cChave,"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont10N:oFont)	
//EndIf


/*
If !Empty(cCodAutDPEC) .And. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"4"
	cUF      := aUF[aScan(aUF,{|x| x[1] == oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_UF:Text})][02]
	cDataEmi := Substr(oNF:_InfNfe:_IDE:_DEMI:Text,9,2)
	cTPEmis  := "4"
	cValIcm  := StrZero(Val(StrTran(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VNF:TEXT,".","")),14)
	cICMSp   := iif(Val(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VICMS:TEXT)>0,"1","2")
	cICMSs   :=iif(Val(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VST:TEXT)>0,"1","2")
ElseIF (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25"
	cUF      := aUF[aScan(aUF,{|x| x[1] == oNFe:_NFE:_INFNFE:_DEST:_ENDERDEST:_UF:Text})][02]
	cDataEmi := Substr(oNFe:_NFE:_INFNFE:_IDE:_DEMI:Text,9,2)
	cTPEmis  := oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT
	cValIcm  := StrZero(Val(StrTran(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT,".","")),14)
	cICMSp   := iif(Val(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT)>0,"1","2")
	cICMSs   :=iif(Val(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:TEXT)>0,"1","2")
EndIf
If !Empty(cUF) .And. !Empty(cDataEmi) .And. !Empty(cTPEmis) .And. !Empty(cValIcm) .And. !Empty(cICMSp) .And. !Empty(cICMSs)
	If Type("oNF:_InfNfe:_DEST:_CNPJ:Text")<>"U"
		cCNPJCPF := oNF:_InfNfe:_DEST:_CNPJ:Text
		If cUf == "99"
			cCNPJCPF := STRZERO(val(cCNPJCPF),14)
		EndIf
	ElseIf Type("oNF:_INFNFE:_DEST:_CPF:Text")<>"U"
		cCNPJCPF := oNF:_INFNFE:_DEST:_CPF:Text
		cCNPJCPF := STRZERO(val(cCNPJCPF),14)
	Else
		cCNPJCPF := ""
	EndIf
	cChaveCont += cUF+cTPEmis+cCNPJCPF+cValIcm+cICMSp+cICMSs+cDataEmi
	cChaveCont := cChaveCont+Modulo11(cChaveCont)
EndIf	
*/
//If !Empty(cChaveCont) .And. Empty(cCodAutDPEC) .And. !(Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900)
//	If nFolha == 1
//		If !Empty(cChaveCont)
//			MSBAR3("CODE128",4.5*(300/PixelY),12.4*(300/PixelX),cChaveCont,oDanfe,/*lCheck*/,/*Color*/,/*lHorz*/,.02960,0.9,/*lBanner*/,/*cFont*/,"C",.F.)	
//		EndIf
//	Else
//		If !Empty(cChaveCont)	
//			MSBAR3("CODE128",2.4*(300/PixelY),12.4*(300/PixelX),cChaveCont,oDanfe,/*lCheck*/,/*Color*/,/*lHorz*/,.02960,0.9,/*lBanner*/,/*cFont*/,"C",.F.)	
//		EndIf
//	EndIf		
//Else
//	If nFolha == 1
//		oDanfe:Say(560,1463,"Consulta de autenticidade no portal nacional da NF-e",oFont10:oFont)	
//		oDanfe:Say(590,1463,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont10:oFont)		
//	Else
//		oDanfe:Say(300,1463,"Consulta de autenticidade no portal nacional da NF-e",oFont10:oFont)	
//		oDanfe:Say(330,1463,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont10:oFont)			
//	EndIf
//EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 4                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosV := nAuxV + VSPACE

aTamanho := ImpBox(nPosV,0,0,nHPage,;
	{	{	{"NATUREZA DA OPERAÇÃO",xNatureza},;
			{"CNPJ",TransForm(SM0->M0_CGC,"@r 99.999.999/9999-99")}}},;
	oDanfe)
	
nPosV := aTamanho[1]

nFolha++      
Return(nPosV)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impressao do Complemento da NFe                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function DanfeCpl(oDanfe,aItens,aMensagem,nItem,nMensagem,oNFe,oIdent,oEmitente,nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab)

Local nAuxV         := 0
Local nX            := 0
Local nY            := 0
Local nHPage        := 0 
Local nVPage        := 0 
Local nPosV         := VMARGEM
Local aAux          := {}
Local nLenItens     := Len(aItens)
Local nLenMensagens := Len(aMensagem)
Local nItemOld	    := nItem
Local nMensagemOld  := nMensagem
Local nForItens     := 0
Local nForMensagens := 0
Local lItens        := .F.
Local lMensagens    := .F.

If (nLenItens - (nItemOld - 1)) > 0
	lItens := .T.
EndIf
If (nLenMensagens - (nMensagemOld - 1)) > 0
	lMensagens := .T.
EndIf

oDanfe:StartPage()
nPosV := DanfeCab(oDanfe,nPosV,@nFolha,nFolhas,aNota)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados do produto ou servico                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHPage := oDanfe:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oDanfe:nVertRes() 
nVPage *= (300/PixelY)
nVPage -= VBOX
nPosV  += (VBOX/2)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados do produto ou servico                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := {{{"COD.PROD."},{"DESCRIÇÃO DO PRODUTO/SERVIÇO"},{"NCM/SH"},{"CST"},{"CFOP"},{"UN"},{"QUANTIDADE"},{"V.UNITARIO"},{"V.TOTAL"},;
		{"BC.ICMS"},{"V.ICMS"},{"V.IPI"},{"A.ICM"},{"A.IPI"}}}
nY := 0
nForItens := Min(nLenItens, MAXITEMP2 + (nItemOld - 1))
If lMensagens .And. lItens .And. (nForItens - (nItemOld - 1)) > (MAXITEMP2 - Min(nLenMensagens - (nMensagemOld - 1), MAXMSG) - Iif((nLenMensagens - (nMensagemOld - 1)) < MAXMSG, 6, 0))
	nForItens -= Min(nLenMensagens - (nMensagemOld - 1), MAXMSG)
	If (nLenMensagens - (nMensagemOld - 1)) < MAXMSG
		nForItens -= 6
	EndIf
	If nLenItens < (MAXITEMP2 + (nItemOld - 1))
		nForItens += (nItemOld - 1)
		If nForItens > nLenItens
			nForItens := nLenItens
		EndIf
	EndIf
EndIf
For nX := nItem To nForItens
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][01])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][02])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][03])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][04])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][05])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][06])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][07])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][08])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][09])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][10])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][11])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][12])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][13])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][14])	
	If nY >= 14
		nY := 0
	EndIf
	nItem++
Next nX

If lItens .And. (nForItens == nLenItens .Or. (lMensagens .And. (nLenMensagens - (nMensagemOld - 1)) < MAXMSG))
	aadd(Atail(aAux)[1],"")
	aadd(Atail(aAux)[2],"")
	aadd(Atail(aAux)[3],"")
	aadd(Atail(aAux)[4],"")
	aadd(Atail(aAux)[5],"")
	aadd(Atail(aAux)[6],"")
	aadd(Atail(aAux)[7],"")
	aadd(Atail(aAux)[8],"")
	aadd(Atail(aAux)[9],"")
	aadd(Atail(aAux)[10],"")
	aadd(Atail(aAux)[11],"")
	aadd(Atail(aAux)[12],"")
	aadd(Atail(aAux)[13],"")
	aadd(Atail(aAux)[14],"")
EndIf

If lItens
	aTamanho := ImpBox(nPosV,0,Iif(lMensagens, 0, nVPage),nHPage,;
		aAux,;
		oDanfe,3,"DADOS DO PRODUTO / SERVIÇO",{"L","L","L","L","L","L","R","R","R","R","R","R","R","R"},0,;
		{.T., .F., .T., .T., .T., .T., .T., .T., .T., .T., .T., .T., .T., .T.})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pontilhado entre os produtos/serviços³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Monta o pontilhado
	If Len(aAux) > 0
		If Len(aAux[1]) > 1
			If Len(aAux[1][2]) > 3
				// 3 pois com apenas uma linha de produtos o array terá 3, uma para o cabeçalho dos campos, uma linha do produto em si e outra em branco
				// Calcula a posição vertical do pontilhado (utiliza-se oFont08 para o calculo pois na função ImpBox é a fonte usada neste box
				nAuxV := nPosV + ((Char2PixV(oDanfe, "X", oFont08) + SAYVSPACE) * 3)
				For nX := 3 To Len(aAux[1][2])
					nAuxV += SAYVSPACE
					If !Empty(aAux[1][1][nX]) .And. Empty(aAux[1][1][nX - 1])
						// Estamos tratando um novo produto com uma linha de descrição de um produto anterior antes dele
						// Escreve o pontilhado
						For nY := HMARGEM To nHPage
							oDanfe:Say(nAuxV, nY, ".", oFont08:oFont)
							nY += 20
						Next nY
					EndIf
					nAuxV += (Char2PixV(oDanfe, "X", oFont08) + SAYVSPACE * 2)
				Next nX
			EndIf
		EndIf
	EndIf
	
	nPosV := aTamanho[1]+VSPACE
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados Adicionais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMensagens
	nPosVOld := nPosV+(VSPACE/2)
	nPosV += VBOX*4
	nPosHOld := HMARGEM
	nPosH    := nHPage
	oDanfe:Say(nPosVOld,nPosHold,"DADOS ADICIONAIS",oFont11N:oFont)
	nPosV    += Char2PixV(oDanfe,"X",oFont11N)*2
	nPosVOld += Char2PixV(oDanfe,"X",oFont11N)*2
	oDanfe:Box(nPosVOld,nPosHOld,nVPage,nPosH)
	nAuxH := nPosHOld+010
	oDanfe:Say(nPosVOld+Char2PixV(oDanfe,"X",oFont11N),nAuxH,"INFORMAÇÕES COMPLEMENTARES",oFont11N:oFont)
	nAuxH := (nHPage/2)+10
	oDanfe:Box(nPosVOld,nAuxH+305,nVPage,nPosH)
	oDanfe:Say(nPosVOld+Char2PixV(oDanfe,"X",oFont07N),nAuxH+320,"RESERVADO AO FISCO",oFont11N:oFont)
	nAuxH := nPosHOld+010
	nPosV    += Char2PixV(oDanfe,"X",oFont11N)*2
	nPosVOld += Char2PixV(oDanfe,"X",oFont11N)*2
	nLenMensagens := Len(aMensagem)
	If lItens
		If (nLenItens + (nItemOld - 1)) > (MAXITEMP2 - Min(nLenMensagens - (nMensagemOld - 1), MAXMSG))
			nForMensagens := MAXMSG + (nMensagemOld - 1)
		Else
			nForMensagens := MAXITEMP2 - ((nLenItens - (nItemOld - 1)) - MAXMSG)
		EndIf
	Else
		nForMensagens := Min(nLenMensagens, MAXITEMP2 + (nMensagemOld - 1))
	EndIf
	If nForMensagens > nLenMensagens
		nForMensagens := nLenMensagens
	EndIf
	For nX := nMensagem To nForMensagens
		nPosVOld += Char2PixV(oDanfe,"X",oFont12)*2
		oDanfe:Say(nPosVOld,nAuxH,aMensagem[nX],oFont12:oFont)
		nMensagem++
	Next nX
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Finalizacao da pagina do objeto grafico                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:EndPage()
Return(.T.)

Static Function Char2Pix(oDanfe,cTexto,oFont)
Local nX := 0
DEFAULT aUltChar2pix := {}
nX := aScan(aUltChar2pix,{|x| x[1] == cTexto .And. x[2] == oFont:oFont})

If nX == 0
	
	//aadd(aUltChar2pix,{cTexto,oFont:oFont,oDanfe:GetTextWidht(cTexto,oFont)*(300/PixelX)})
	aadd(aUltChar2pix,{cTexto,oFont:oFont, oFont:GetTextWidht(cTexto) *(300/PixelX)})
	
	nX := Len(aUltChar2pix)
EndIf

Return(aUltChar2pix[nX][3])

Static Function Char2PixV(oDanfe,cChar,oFont)
Local nX := 0
DEFAULT aUltVChar2pix := {}

cChar := SubStr(cChar,1,1)
nX := aScan(aUltVChar2pix,{|x| x[1] == cChar .And. x[2] == oFont:oFont})
If nX == 0
                                                                    
	//aadd(aUltVChar2pix,{cChar,oFont:oFont,oDanfe:GetTextWidht(cChar,oFont)*(300/PixelY)})
	aadd(aUltVChar2pix,{cChar,oFont:oFont, oFont:GetTextWidht(cChar) *(300/PixelY)})

	nX := Len(aUltVChar2pix)
EndIf

Return(aUltVChar2pix[nX][3])



Static Function ConvDate(cData)
Local dData
cData  := StrTran(cData,"-","")
dData  := Stod(cData)
Return PadR(StrZero(Day(dData),2)+ "/" + StrZero(Month(dData),2)+ "/" + StrZero(Year(dData),4),15)



Static Function ImpBox(nPosVIni,nPosHIni,nPosVFim,nPosHFim,aImp,oDanfe,nTpFont,cTitulo,aAlign,nColAjuste,aColAjuste)
Local aTamanho      := {}
Local nX            := 0
Local nY            := 0
Local nZ            := 0
Local nLenColAjuste := 0
Local nMaxnX        := Len(aImp)
Local nMaxnY        := 0
Local nMaxnZ        := 0
Local nPosV1        := nPosVIni
Local nPosV2        := nPosVIni
Local nPosH1        := nPosHIni
Local nPosH2        := nPosHIni
Local nAuxH         := 0
Local nAuxV         := 0
Local nTam          := 0
Local nDif          := 0
Local nMaxTam       := 0
//Local cMaxTam       := ""
Local aFont         := {{oFont07N,oFont08},{oFont10N,oFont11},{oFont11N,oFont12}}
Local lTitulo       := .T.
Local lTemTit       := .F.
Local nCharPix
Local nLenAlign
Local nForAlign
Local nLenTam

DEFAULT nTpFont    := 1
DEFAULT aAlign     := {}
DEFAULT nColAjuste := 0
/**
 * Caso o nColAjuste seja 0, este array terá quais campos irão receber o ajuste
 * de tamanho, utilizando booleano para cada coluna do box.
 */
DEFAULT aColAjuste := {}

For nX := 1 To nMaxnX

	nMaxnY  := Len(aImp[nX])
	nPosV1  := IIF(nPosV1 == 0 , VMARGEM , nPosV1 )
	nPosV2  := nPosV1 + VBOX	
	
	/**
	 * O array é limpo para as próximas dimensões.
	 */
	aTamanho := {}
	
	/**
	 * Completa o array de ajuste de colunas de acordo com o número de posições
	 * que o array de dados possui.
	 */
	If Len(aColAjuste) < nMaxnY
		For nY := (Len(aColAjuste) + 1) To nMaxnY
			AAdd(aColAjuste, .T.)
		Next nY
	EndIf
	
	//----------------------------------------
	// [TODO - Confirmar lógica]
	// Foi alterado para aumentar performance
	//----------------------------------------
	/*
	For nY := 1 To nMaxnY
		If Len(aAlign) < nY
			aadd(aAlign,"L")
		EndIf
	Next nY
	*/	              
	/**
	 * Popula o array de alinhamentos para bater o número de posições com o array
	 * de dados.
	 * Adiciona alinhamentos a esquerda ("L") para tanto.
	 */
	nLenAlign := Len(aAlign)
	nForAlign := (nMaxnY - nLenAlign)
	If nForAlign > 0
		For nY := 1 To nForAlign
			aadd(aAlign,"L")
		Next nY
	Endif 
	//----------------------------------------
	
	/**
	 * Popula as posições vazias do array aTamanho com o tamanho flexível que o
	 * Box terá, caso o número de posições dele não bata com o número de posições
	 * do array aImp.
	 */
	For nY := 1 To nMaxnY
		If Valtype(aImp[nX][nY]) == "A"
			nMaxnZ := Len(aImp[nX][nY])
			nMaxTam := 0 //cMaxTam:= ""
			For nZ := 1 To nMaxnZ
				If nMaxTam < (oDanfe:GetTextWidth(aImp[nX][nY][nZ], aFont[nTpFont][IIf(nZ==1, 1, 2)]:oFont) + HSPACE * 2) //cMaxTam < Len(AllTrim(aImp[nX][nY][nZ]))
					nMaxTam := oDanfe:GetTextWidth(aImp[nX][nY][nZ], aFont[nTpFont][IIf(nZ==1, 1, 2)]:oFont) + HSPACE * 2 //cMaxTam := AllTrim(aImp[nX][nY][nZ])
				EndIf
			Next nZ
			//aadd(aTamanho,(Char2Pix(oDanfe,cMaxTam,aFont[nTpFont][2])+HSPACE+IIF(nZ>1,SAYVSPACE*nTpFont,-1*SAYVSPACE)))
			AAdd(aTamanho, nMaxTam)
		Else
			//aadd(aTamanho,(Char2Pix(oDanfe,aImp[nX][nY],aFont[nTpFont][2])+HSPACE))
			AAdd(aTamanho, oDanfe:GetTextWidth(aImp[nX][nY], aFont[nTpFont][2]:oFont) + HSPACE * 2)
		EndIf
	Next nY
    /**
     * Caso o tamanho de cada coluna somados não de o tamanho total da página,
     * o espaço restante é ou distribuido igualmente entre as colunas (caso
     * nColAjuste == 0) ou na coluna especificada na variável nColAjuste.
     */
    nTam := 0
    nLenTam := Len(aTamanho)
    For nY := 1 To nLenTam
		nTam += aTamanho[nY]
	Next nY	
	If nTam <= (nPosHFim - nPosHIni)
		If nColAjuste == 0
			nLenColAjuste := 0
			For nY := 1 To Len(aColAjuste)
				If aColAjuste[nY]
					nLenColAjuste++
				EndIf
			Next nY
			nDif := Int(((nPosHFim - nPosHIni - IIF(nPosHIni == 0 , HMARGEM , nPosHIni )) - nTam) / nLenColAjuste)
			nLenTam := Len(aTamanho)
		    For nY := 1 To nLenTam
		    	If aColAjuste[nY]
					aTamanho[nY] += nDif
				EndIf
			Next nY
		Else
			nDif := Int(((nPosHFim - nPosHIni - IIF(nPosHIni == 0 , HMARGEM , nPosHIni )) - nTam))
			aTamanho[nColAjuste] += nDif
		EndIf
	EndIf
	
	/**
	 * Desenha o(s) box(es) e a(s) informação(ões).
	 */
	For nY := 1 To nMaxnY
		nPosH1 := IIF(nPosH1 == 0 , HMARGEM , nPosH1 )
		If cTitulo <> Nil .And. lTitulo
			lTitulo := .F.
			lTemTit := .T.
			oDanfe:Say(nPosV1,nPosH1,cTitulo,aFont[nTpFont][1]:oFont)	

			nCharPix := Char2PixV(oDanfe,"X",aFont[nTpFont][1])+SAYVSPACE
			nPosV1 += nCharPix 
			nPosV2 += nCharPix
		EndIf		
		If Valtype(aImp[nX][nY]) == "A"

			nMaxnZ := Len(aImp[nX][nY])
			If nY == nMaxnY
				nPosH2 := nPosHFim
				If nMaxnY > 1
					nPosH1 := Max(nPosH1,nPosHFim-aTamanho[nY])
				EndIf
			Else
				nPosH2 := Min(nPosHFim,nPosH1+aTamanho[nY])
			EndIf

			If nMaxnZ >= 2 .And. nY == 1
				If nPosVFim <> 0
					nPosV2 := nPosVFim
				Else
					nAuxV := 0
					For nZ := 1 To nMaxnZ
						nAuxV += Char2PixV(oDanfe,"X",aFont[nTpFont][IIf(nZ==1,1,2)])+IIF(nZ>1,SAYVSPACE*nTpFont,-1*SAYVSPACE)
					Next nZ
					nAuxV := Int(nAuxV/(VBOX + VSPACE))
					nPosV2 += (VBOX + VSPACE)*nAuxV
				EndIf
			EndIf
			oDanfe:Box(nPosV1,nPosH1,nPosV2,nPosHFim)
			If aAlign[nY] == "R"
				nAuxH := nPosH2 - HSPACE
			Else
				nAuxH := nPosH1 + SAYHSPACE
			EndIf
			nAuxV := nPosV1
			For nZ := 1 To nMaxnZ									
				nAuxV += Char2PixV(oDanfe,"X",aFont[nTpFont][IIf(nZ==1,1,2)])+IIF(nZ>1,SAYVSPACE*nTpFont,-1*SAYVSPACE)
				
				/**
				 * Trata o tag [ e ].
				 */
				cInf := ""
				cBox := ""
				
				If At("[", aImp[nX][nY][nZ]) > 0 .And. At("]", aImp[nX][nY][nZ]) > 0 .And. (At("]", aImp[nX][nY][nZ]) - At("[", aImp[nX][nY][nZ])) > 0
					If At("[", aImp[nX][nY][nZ]) > 1
						cInf := Substr(aImp[nX][nY][nZ], 1, At("[", aImp[nX][nY][nZ]) - 1)
					EndIf
					cBox := Substr(aImp[nX][nY][nZ], At("[", aImp[nX][nY][nZ]) + 1, At("]", aImp[nX][nY][nZ]) - At("[", aImp[nX][nY][nZ]) - 1)
				Else
					cInf := aImp[nX][nY][nZ]
				EndIf
				
				If aAlign[nY] == "R"
					oDanfe:Say(nAuxV,;
						nAuxH - (oDanfe:GetTextWidth(aImp[nX][nY][nZ], aFont[nTpFont][IIf(nZ==1,1,2)]:oFont) + IIf(!Empty(cBox), oDanfe:GetTextWidth(cBox, aFont[nTpFont][IIf(nZ==1,1,2)]:oFont) + HSPACE * 4, 0)),;
						aImp[nX][nY][nZ],;
						aFont[nTpFont][IIf(nZ==1,1,2)]:oFont)
					If !Empty(cBox)    // Monta o box caso exista
						oDanfe:Box(nAuxV - VSPACE,;
							nAuxH - (oDanfe:GetTextWidth(cBox, aFont[nTpFont][IIf(nZ==1,1,2)]:oFont) + HSPACE * 3),;
							nAuxV + oDanfe:GetTextHeight("X", aFont[nTpFont][IIf(nZ==1,1,2)]:oFont) + VSPACE,;
							nAuxH - HSPACE)
						oDanfe:Say(nAuxV, nAuxH - (oDanfe:GetTextWidth(cBox, aFont[nTpFont][IIf(nZ==1,1,2)]:oFont) + HSPACE * 2), cBox, aFont[nTpFont][IIf(nZ==1,1,2)]:oFont)
					EndIf
				Else
					oDanfe:Say(nAuxV,nAuxH,cInf,aFont[nTpFont][IIf(nZ==1,1,2)]:oFont)
					If !Empty(cBox)    // Monta o box caso exista
						oDanfe:Box(nAuxV - VSPACE,;
							nAuxH + oDanfe:GetTextWidth(cInf, aFont[nTpFont][IIf(nZ==1,1,2)]:oFont) + HSPACE,;
							nAuxV + oDanfe:GetTextHeight("X", aFont[nTpFont][IIf(nZ==1,1,2)]:oFont) + VSPACE,;
							nAuxH + oDanfe:GetTextWidth(cInf, aFont[nTpFont][IIf(nZ==1,1,2)]:oFont) + HSPACE + oDanfe:GetTextWidth(cBox, aFont[nTpFont][IIf(nZ==1,1,2)]:oFont) + HSPACE * 2)
						oDanfe:Say(nAuxV, nAuxH + oDanfe:GetTextWidth(cInf, aFont[nTpFont][IIf(nZ==1,1,2)]:oFont) + HSPACE * 2, cBox, aFont[nTpFont][IIf(nZ==1,1,2)]:oFont)
					EndIf
				EndIf
			Next nZ
			nPosH1 := nPosH2
		Else
			If nY == nMaxnY
				nPosH2 := nPosHFim
			Else
				nPosH2 := Min(nPosHFim,aTamanho[nY])
			EndIf
			
			oDanfe:Box(nPosV1,nPosH1,nPosV2,nPosHFim)
			If aAlign[nY] == "R"
				nAuxH := nPosH2 - Char2Pix(oDanfe,aImp[nX][nY],aFont[nTpFont][2]) - HSPACE
			Else
				nAuxH := nPosH1 + SAYHSPACE
			EndIf
			nAuxV := nPosV1+Char2PixV(oDanfe,aImp[nX][nY],aFont[nTpFont][2])
			oDanfe:Say(nAuxV,nAuxH,aImp[nX][nY],aFont[nTpFont][2]:oFont)
			nPosH1 := nPosH2
		EndIf
    Next nY
    nPosV1 := nPosV2 + IIF(lTemTit,0,VSPACE)
    nPosV2 := 0
    nPosH1 := nPosHIni
    nPosH2 := 0
Next nX

Return({nPosV1,nPosH1})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DANFE     ºAutor  ³Marcos Taranta      º Data ³  10/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pega uma posição (nTam) na string cString, e retorna o      º±±
±±º          ³caractere de espaço anterior.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EspacoAt(cString, nTam)

Local nRetorno := 0
Local nX       := 0

/**
 * Caso a posição (nTam) for maior que o tamanho da string, ou for um valor
 * inválido, retorna 0.
 */
If nTam > Len(cString) .Or. nTam < 1
	nRetorno := 0
	Return nRetorno
EndIf

/**
 * Procura pelo caractere de espaço anterior a posição e retorna a posição
 * dele.
 */
nX := nTam
While nX > 1
	If Substr(cString, nX, 1) == " "
		nRetorno := nX
		Return nRetorno
	EndIf
	
	nX--
EndDo

/**
 * Caso não encontre nenhum caractere de espaço, é retornado 0.
 */
nRetorno := 0

Return nRetorno
    

//////////////////////////////////////////////////////////////

Static Function ValidPerg(cPerg)

Local cKey := ""
Local aHelpEng := {}
Local aHelpPor := {}
Local aHelpSpa := {}
/*
PutSx1(cGrupo,cOrdem,cPergunt               ,cPerSpa               ,cPerEng               ,cVar     ,cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,cF3, cGrpSxg    ,cPyme,cVar01    ,cDef01     ,cDefSpa1,cDefEng1,cCnt01,cDef02  ,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)
*/

PutSx1(cPerg,"01"  ,"Da Nota Fiscal     ?		",""                    ,""                    ,"mv_ch1","C"   ,09      ,0       ,0      , "G",""    ,""   ,""         ,""   ,"mv_par01",""         ,""      ,""      ,""    ,""      ,""     ,""      ,""    ,""      ,""      ,""    ,""      ,""     ,""    ,""      ,""     ,""      ,""      ,""      ,"")
PutSx1(cPerg,"02"  ,"Ate a Nota Fiscal  ?    	",""                    ,""                    ,"mv_ch2","C"   ,09      ,0       ,0      , "G",""    ,""   ,""         ,""   ,"mv_par02",""         ,""      ,""      ,""    ,""      ,""     ,""      ,""    ,""      ,""      ,""    ,""      ,""     ,""    ,""      ,""     ,""      ,""      ,""      ,"")
PutSx1(cPerg,"03"  ,"Serie              ?    	",""                    ,""                    ,"mv_ch3","C"   ,03      ,0       ,0      , "G",""    ,""   ,""         ,""   ,"mv_par03",""         ,""      ,""      ,""    ,""      ,""     ,""      ,""    ,""      ,""      ,""    ,""      ,""     ,""    ,""      ,""     ,""      ,""      ,""      ,"")
PutSx1(cPerg,"04"  ,"Entrada/Saida      ?       ",""                    ,""                    ,"mv_ch4","C"   ,07      ,0       ,0      , "C",""    ,""   ,""         ,""   ,"mv_par04","Entrada"  ,""      ,""      ,""    ,"Saida" ,""     ,""      ,""    ,""      ,""      ,""    ,""      ,""     ,""    ,""      ,""      ,""      ,""      ,""      ,"")


cKey     := "P."+Alltrim(cPerg)+"01."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Digite o número da Nota Fiscal.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P."+Alltrim(cPerg)+"02."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Digite o número da Nota Fiscal.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P."+Alltrim(cPerg)+"03."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Digite a série da Nota Fiscal.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P."+Alltrim(cPerg)+"04."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Escolha o tipo de Nota Fiscal")
aAdd(aHelpPor,"( Entrada / Saída ).")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

Return
