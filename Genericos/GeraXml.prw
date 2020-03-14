// Marcos - v17/01/19
#INCLUDE "PROTHEUS.CH"

// Exemplo
//	    AADD(aCabsX,Capital(cNomeC))
//	    AADD(aCamposX,_cAlias+"->"+FIELDNAME(nI))
//	    AADD(aImpr,.T.)
//	    AADD(aAlign,NIL)
//	    AADD(aFormat,NIL)
//	    AADD(aTotal,NIL)

//AADD(aPlansX,{_cAlias,_cPlan,"",_cTitulo,aCamposX,aCabsX,aImpr,aAlign,aFormat,aTotal,_cQuebra,_lClose})
//MsAguarde({|| U_GeraXml(aPlansX,_cTitulo,_cAlias,.F.)},"Aguarde","Gerando planilha...",.F.)

User Function GeraXml( _aPlans,_cTitulo,_cProg, lClose, _lZebra )

Local oExcel     AS OBJECT
Local cArq       := ""
//Local cDir       := GetSrvProfString("Startpath","")
Local cDirTmp    := "C:\TMP"  //GetTempPath()
Local aArea      := GetArea()

Local lTotal     := .F.
Local nAlign     := 1
Local nFormat    := 1
Local aLinha     := {}
Local aSoma      := {}
Local aSomas     := {}
Local aTotal     := {}
Local aBrancos   := {}
Local nI         := 0 
Local nPosTot    := 0
Local nPosTit    := 0
Local lTitTot    := .T. 
Local nPosCpo    := 0
Local _cAlias    := ""

Default _cTitulo := ""
Default _lZebra  := .T.
Private cFiltra  := ""
Private xCampo
Private xQuebra

IF lClose == NIL
   lClose := .T.
ENDIF

MakeDir(cDirTmp)

oExcel := FWMsExcel():New()
//oExcel := FWMsExcelEx():New()

// 16-04-2015 - Criado novos métodos para alterar o estilo de uma célula: 
// oExcel:SetCelFont(), oExcel:SetCelSizeFont(), oExcel:SetCelItalic(), oExcel:SetCelBold(), oExcel:SetCelUnderLine(), oExcel:SetCelFrColor() e oExcel:SetCelBgColor() 
// Alterada o método addrow() para que possa ser selecionado a célula que deseja ser alterado o estilo.
//oExcel:SetCelBold(.T.)
//oExcel:SetCelFont('Line Draw')
//oExcel:SetCelItalic(.F.)
//oExcel:SetCelUnderLine(.F.)
//oExcel:SetCelSizeFont(12)
//oExcel:SetCelFrColor("#FFFFFF")
//oExcel:SetCelBgColor("#D7BCFB")
//oExcel:AddRow("Teste - 1","Titulo de teste 1",{41,42,43,44},{1,3})  // altera os atributos da celula 1 e da 3 desta linha


//oExcel:SetFrGeneralColor("#000000")
//oExcel:SetBgGeneralColor("#FFFFFF")  


// Define cores em tons de cinza

oExcel:SetLineFrColor("#000000")
oExcel:SetLineBgColor("#FFFFFF")
	
oExcel:Set2LineFrColor("#000000")
If _lZebra
	oExcel:Set2LineBgColor("#F5F5F5")
Else
	oExcel:Set2LineBgColor("#FFFFFF")
EndIf

oExcel:SetHeaderBold(.T.)
oExcel:SetFrColorHeader("#000000")
oExcel:SetBgColorHeader("#D3D3D3") 

oExcel:SetTitleFrColor("#000000")
oExcel:SetTitleBgColor("#FFFFFF")

FOR nJ := 1 TO LEN(_aPlans)

	_cAlias  := _aPlans[nJ,01]
	_cPlan   := _aPlans[nJ,02]
	cFiltra  := _aPlans[nJ,03]
	_cTitulos:= _aPlans[nJ,04] 
	_aCampos := _aPlans[nJ,05]
	_aCabs   := _aPlans[nJ,06]
	_aImpr   := _aPlans[nJ,07]
	_aAlign  := _aPlans[nJ,08]
	_aFormat := _aPlans[nJ,09]
	_aTotal  := _aPlans[nJ,10]
	_cQuebra := _aPlans[nJ,11]
	_lClose  := _aPlans[nJ,12]
	nPosTit  := 0
	nPosTot  := 0 
	nPosCpo  := 0
	
	oExcel:AddworkSheet(_cPlan)

	oExcel:AddTable (_cPlan,_cTitulos)
	
	If !empty(cFiltra)
		(_cAlias)->(dbsetfilter({|| &cFiltra} , cFiltra))
	Endif
	
	(_cAlias)->(dbgotop())
	ProcRegua((_cAlias)->(RecCount())) 
	
	aSoma   := {}
	aSomas  := {}
	aTotal  := {}
	lTitTot := .T.

	FOR nI := 1 TO LEN(_aCabs)
	
	    IF !EMPTY(_aImpr)  // Coluna a ignorar
			IF !_aImpr[nI]
		    	Loop
		 	ENDIF 
		ENDIF
        
        nPosCpo++
        
	    xCampo := &(_aCampos[nI])
	
	    lTotal  := .F.
	    nAlign  := 1     // 1-Left,2-Center,3-Right
	    nFormat := 1     // 1-General,2-Number,3-Monetário,4-DateTime 
	    
	    If VALTYPE(xCampo) == "D" // Trata campos data
	    	xCampo := DTOC(xCampo)
			nFormat := 1
	    Elseif VALTYPE(xCampo) == "N" // Trata campos numericos
			nAlign  := 3
			nFormat := 2
			lTotal  := .T.
	    //Elseif VALTYPE(xCampo) == "C" // Trata campos caracter
	    EndIf

	    IF !EMPTY(_aAlign)
			IF _aAlign[nI] <> NIL
		    	nAlign  := _aAlign[nI]
		 	ENDIF 
		ENDIF
		    
	    IF !EMPTY(_aFormat)
			IF _aFormat[nI] <> NIL
		    	nFormat  := _aFormat[nI]
		    	IF nFormat = 4
		    		nFormat := 1
		    	ENDIF
		 	ENDIF 
		ENDIF
		    
	    IF !EMPTY(_aTotal)
			IF _aTotal[nI] <> NIL 
				IF lTotal
			    	lTotal  := _aTotal[nI]
			 	ENDIF
		 	ENDIF 
		ENDIF
		    
		//oExcel():AddColumn(< cWorkSheet >, < cTable >, < cColumn >, < nAlign >, < nFormat >, < lTotal >)-> NIL
		oExcel:AddColumn(_cPlan,_cTitulos,_aCabs[nI],nAlign,nFormat,IIF(EMPTY(_cQuebra),lTotal,.F.))
		
		IF lTotal
			AADD(aSoma,.T.)
			AADD(aSomas,0)
			AADD(aTotal,0)
			If nPosTot = 0
				nPosTot := nPosCpo
			EndIf
		ELSE
			AADD(aSoma,.F.)
			AADD(aSomas,"")
			AADD(aTotal,"")
			If nPosTot = 0
				nPosTit := nPosCpo
			EndIf
		ENDIF
	NEXT

    If nPosTit > 0 .AND. nPosTot > 0
       aSomas[nPosTit] := "<b>Subtotal:</b>" 
       aTotal[nPosTit] := "Total:" 
    EndIf
	
	IF !EMPTY(_cQuebra)
		xQuebra := &(_cQuebra)
	ENDIF
	
	
	Do While (_cAlias)->(!eof()) 
	
		aLinha := {}
	 	For nI :=1 to LEN(_aCampos)
	
	         xCampo := &(_aCampos[nI])

             If VALTYPE(xCampo) == "D" // Trata campos data
	    		xCampo := DTOC(xCampo)
             EndIf

		    IF !EMPTY(_aImpr)  // Coluna a ignorar
				IF !_aImpr[nI]
			    	Loop
			 	ENDIF 
			ENDIF

	         AADD(aLinha,xCampo)
	         IF !EMPTY(_cQuebra) 
	         	IF aSoma[nI]
	         		aSomas[nI] += xCampo
	         		aTotal[nI] += xCampo
	         	ENDIF
	         ENDIF  	
		Next
	
		oExcel:AddRow(_cPlan,_cTitulos,aLinha)
	
	    (_cAlias)->(dbskip())
	
		IF !EMPTY(_cQuebra) 
			IF xQuebra != &(_cQuebra).OR. (_cAlias)->(EOF())
			    If nPosTit > 0 .AND. nPosTot > 0
			       aSomas[nPosTit] := "Subtotal:" 
                EndIf

				oExcel:AddRow(_cPlan,_cTitulos,aSomas)
				aSomas := {}
			 	For nI :=1 to LEN(_aCampos)
		         	IF aSoma[nI]
	   	     			AADD(aSomas,0)
	    	     	ELSE
	   	     			AADD(aSomas,"")
	   	     			lTitTot := .F.
	    	     	ENDIF
	         	Next
				xQuebra := &(_cQuebra)
				
				// Pular linha após a quebra 10/06/15
				aBrancos := ARRAY(LEN(_aCampos))
				AFill(aBrancos,"") 
				oExcel:AddRow(_cPlan,_cTitulos,aBrancos)
	        ENDIF  	
		ENDIF
		
	EndDo
	IF !EMPTY(_cQuebra)
		oExcel:AddRow(_cPlan,_cTitulos,aTotal)
	ENDIF
	
	IF _lClose   
	   (_cAlias)->(dbCloseArea())
	ENDIF

NEXT

//aBrancos := ARRAY(LEN(_aCampos))
//AFill(aBrancos,"") 
//oExcel:AddRow(_cPlan,_cTitulos,aBrancos)

//aBrancos1 := ARRAY(LEN(_aCampos))
//AFill(aBrancos1,"") 
//aBrancos1[1]:= "Emitido em: "+DTOC(DATE())+" "+SUBSTR(TIME(),1,5)+" por "+Capital(cUserName)+" - "+SM0->M0_NOME
//oExcel:AddRow(_cPlan,_cTitulos,aBrancos1)
		
oExcel:Activate()
		
cArq := CriaTrab( NIL, .F. ) + ".xml"
LjMsgRun( "Gerando o arquivo, aguarde...", _cTitulo, {|| oExcel:GetXMLFile( cArq ) } )

If __CopyFile( cArq, cDirTmp + "\" + _cProg + "-" + cArq)
   IF MsgYesNo("Deseja abrir o arquivo "+cDirTmp + "\" + _cProg + "-" + cArq+" ?")
      ShellExecute("open", cDirTmp + "\" + _cProg + "-" + cArq,"","",1)
	  //oExcelApp := MsExcel():New()
	  //oExcelApp:WorkBooks:Open( cDirTmp + "\" + _cProg + "-" + cArq)
	  //oExcelApp:SetVisible(.T.)
   ENDIF	
   Ferase(cArq)
Else
	MsgInfo( "O Arquivo não foi copiado para a pasta temporária local." )
Endif

RestArea(aArea)

Return


User Function QryToXml(_cAlias,_cPlan,_cTitulo,_aDefs,_cQuebra,_lClose)
// _Adefs: {Campo,Formula,Titulo,Impr,Align,Format,Total}
Local nI       := 0
Local aCabsX   := {}
Local aCamposX := {}                 
Local aPlansX  := {} 
Local cNomeC   := {}
Local aImpr    := {}
Local aAlign   := {}
Local aFormat  := {}
Local aTotal   := {}

Default _cPlan   := _cAlias
Default _cTitulo := _cAlias
Default _lClose  := .F.
Default _aDefs   := {}
Default _cQuebra := ""

dbSelectArea(_cAlias)
FOR nI := 1 TO FCOUNT() 

	cNomeC := RetTitle(FIELDNAME(nI))

	nX := aScan(_aDefs,{|x| x[1] == FIELDNAME(nI) })
	If nX > 0
        // Formula
		If _aDefs[nX,2] <> NIL
		    AADD(aCamposX,_aDefs[nX,2])
		Else
		    AADD(aCamposX,_cAlias+"->"+FIELDNAME(nI))
		EndIf
		
		// Titulo
		If _aDefs[nX,3] <> NIL
		    AADD(aCabsX,_aDefs[nX,3])
		Else
			AADD(aCabsX,Capital(cNomeC))
		EndIf

		// Imprime
		If _aDefs[nX,4] <> NIL
		    AADD(aImpr,_aDefs[nX,4])
		Else
			AADD(aImpr,.T.)
		EndIf
		
		// Align
		If _aDefs[nX,5] <> NIL
		    AADD(aAlign,_aDefs[nX,5])
		Else
			AADD(aAlign,NIL)
		EndIf

		// Format
		If _aDefs[nX,6] <> NIL
		    AADD(aFormat,_aDefs[nX,6])
		Else
			AADD(aFormat,NIL)
		EndIf

		// Total
		If _aDefs[nX,7] <> NIL
		    AADD(aTotal,_aDefs[nX,7])
		Else
			AADD(aTotal,NIL)
		EndIf

    Else
		//If nI <= LEN(_aTitulos)
		//	If !EMPTY(_aTitulos[nI])
		//		cNomeC := _aTitulos[nI]
		//	EndIf
		//EndIf
		
		If EMPTY(cNomeC)
			cNomeC := FIELDNAME(nI)
		//Else
		//    cNomeC := GetSx3Cache( FIELDNAME(nI) , "X3_DESCRIC" )
		EndIf
		
	    AADD(aCabsX,Capital(cNomeC))
	    AADD(aCamposX,_cAlias+"->"+FIELDNAME(nI))
	    AADD(aImpr,.T.)
	    AADD(aAlign,NIL)
	    AADD(aFormat,NIL)
	    AADD(aTotal,NIL)

    EndIf
NEXT

AADD(aPlansX,{_cAlias,_cPlan,"",_cTitulo,aCamposX,aCabsX,aImpr,aAlign,aFormat,aTotal,_cQuebra,_lClose})
MsAguarde({|| U_GeraXml(aPlansX,_cTitulo,_cAlias,.F.)},"Aguarde","Gerando planilha...",.F.)

Return nil

// Marcos - v17/01/19
// Exemplo:

//  ... aAdd(aCabec,"Total")
//	... aAdd(aItens,ZZ7->ZZ7_DTASSC)
//	... Aadd(aDados, aItens )

//	AADD(aPlans,{aDados,cPerg,cTitExcel,aCabec,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */ })   
//	MsAguarde({|| U_ArrToXml(aPlans,cTitExcel,cPerg,.T.)},"Aguarde","Gerando planilha...",.F.)


User Function ArrToXml( _aPlans,_cTitulo,_cProg, _lZebra, _cDirHttp )

Local oExcel     AS OBJECT
Local cArq       := ""
//Local cDir       := GetSrvProfString("Startpath","")
Local cDirTmp    := "C:\TMP"  //GetTempPath()
Local aArea      := GetArea()

Local lTotal     := .F.
Local nAlign     := 1
Local nFormat    := 1
Local aLinha     := {}
Local aSoma      := {}
Local aSomas     := {}
Local aTotal     := {}
Local nI         := 0
Local nJ         := 0
Local nRow       := 0 
Local nPosTot    := 0
Local nPosTit    := 0
Local lTitTot    := .T. 
Local nPosCpo    := 0
Local aDados     := {}

Default _cTitulo := ""
Default _lZebra  := .T.
Default _cDirHttp:= ""
Private cFiltra  := ""
Private xCampo
Private xQuebra

If !Empty(_cDirHttp)
	cDirTmp := _cDirHttp
EndIf
	
MakeDir(cDirTmp)

oExcel := FWMsExcel():New()
//oExcel := FWMsExcelEx():New()

// 16-04-2015 - Criado novos métodos para alterar o estilo de uma célula: 
// oExcel:SetCelFont(), oExcel:SetCelSizeFont(), oExcel:SetCelItalic(), oExcel:SetCelBold(), oExcel:SetCelUnderLine(), oExcel:SetCelFrColor() e oExcel:SetCelBgColor() 
// Alterada o método addrow() para que possa ser selecionado a célula que deseja ser alterado o estilo.
//oExcel:SetCelBold(.T.)
//oExcel:SetCelFont('Line Draw')
//oExcel:SetCelItalic(.F.)
//oExcel:SetCelUnderLine(.F.)
//oExcel:SetCelSizeFont(12)
//oExcel:SetCelFrColor("#FFFFFF")
//oExcel:SetCelBgColor("#D7BCFB")
//oExcel:AddRow("Teste - 1","Titulo de teste 1",{41,42,43,44},{1,3})  // altera os atributos da celula 1 e da 3 desta linha


//oExcel:SetFrGeneralColor("#000000")
//oExcel:SetBgGeneralColor("#FFFFFF")  


// Define cores em tons de cinza

oExcel:SetLineFrColor("#000000")
oExcel:SetLineBgColor("#FFFFFF")
	
oExcel:Set2LineFrColor("#000000")
If _lZebra
	oExcel:Set2LineBgColor("#F5F5F5")
Else
	oExcel:Set2LineBgColor("#FFFFFF")
EndIf

oExcel:SetHeaderBold(.T.)
oExcel:SetFrColorHeader("#000000")
oExcel:SetBgColorHeader("#D3D3D3") 

oExcel:SetTitleFrColor("#000000")
oExcel:SetTitleBgColor("#FFFFFF")

FOR nJ := 1 TO LEN(_aPlans)

	aDados   := _aPlans[nJ,01]
	_cPlan   := _aPlans[nJ,02]
	_cTitulos:= _aPlans[nJ,03] 
	_aCabs   := _aPlans[nJ,04]
	_aImpr   := _aPlans[nJ,05]
	_aAlign  := _aPlans[nJ,06]
	_aFormat := _aPlans[nJ,07]
	_aTotal  := _aPlans[nJ,08]
	
	oExcel:AddworkSheet(_cPlan)

	oExcel:AddTable (_cPlan,_cTitulos)

	ProcRegua(Len(aDados)) 
	
	aSoma   := {}
	aSomas  := {}
	aTotal  := {}
	lTitTot := .T.

	FOR nI := 1 TO LEN(_aCabs)
	
	    IF !EMPTY(_aImpr)  // Coluna a ignorar
			IF !_aImpr[nI]
		    	Loop
		 	ENDIF 
		ENDIF
        
        nPosCpo++
        If len(aDados) > 0
		    xCampo := aDados[1,1]
		Else
			xCampo := ""
		EndIf
	
	    lTotal  := .F.
	    nAlign  := 1     // 1-Left,2-Center,3-Right
	    nFormat := 1     // 1-General,2-Number,3-Monetário,4-DateTime 
	    
	    If VALTYPE(xCampo) == "D" // Trata campos data
	    	xCampo  := DTOC(xCampo)
			nFormat := 1
	    Elseif VALTYPE(xCampo) == "N" // Trata campos numericos
			nAlign  := 3
			nFormat := 2
			lTotal  := .T.
	    //Elseif VALTYPE(xCampo) == "C" // Trata campos caracter
	    EndIf

	    IF !EMPTY(_aAlign)
			IF _aAlign[nI] <> NIL
		    	nAlign  := _aAlign[nI]
		 	ENDIF 
		ENDIF
		    
	    IF !EMPTY(_aFormat)
			IF _aFormat[nI] <> NIL
		    	nFormat  := _aFormat[nI]
		    	IF nFormat = 4
		    		nFormat := 1
		    	ENDIF
		 	ENDIF 
		ENDIF
		    
	    IF !EMPTY(_aTotal)
			IF _aTotal[nI] <> NIL 
				IF lTotal
			    	lTotal  := _aTotal[nI]
			 	ENDIF
		 	ENDIF 
		ENDIF
		    
		//oExcel():AddColumn(< cWorkSheet >, < cTable >, < cColumn >, < nAlign >, < nFormat >, < lTotal >)-> NIL
		oExcel:AddColumn(_cPlan,_cTitulos,_aCabs[nI],nAlign,nFormat,lTotal)
		
		IF lTotal
			AADD(aSoma,.T.)
			AADD(aSomas,0)
			AADD(aTotal,0)
			If nPosTot = 0
				nPosTot := nPosCpo
			EndIf
		ELSE
			AADD(aSoma,.F.)
			AADD(aSomas,"")
			AADD(aTotal,"")
			If nPosTot = 0
				nPosTit := nPosCpo
			EndIf
		ENDIF
	NEXT

    If nPosTit > 0 .AND. nPosTot > 0
       aSomas[nPosTit] := "<b>Subtotal:</b>" 
       aTotal[nPosTit] := "Total:" 
    EndIf
	
	For nRow := 1 To Len(aDados)
	
		aLinha := {}
		
	 	For nI :=1 to LEN(aDados[nRow])
	
	         xCampo := aDados[nRow,nI]

             If VALTYPE(xCampo) == "D" // Trata campos data
	    		xCampo := DTOC(xCampo)
             EndIf

		    IF !EMPTY(_aImpr)  // Coluna a ignorar
				IF !_aImpr[nI]
			    	Loop
			 	ENDIF 
			ENDIF

	         AADD(aLinha,xCampo)

         	IF aSoma[nI]
         		aSomas[nI] += xCampo
         		aTotal[nI] += xCampo
         	ENDIF

		Next
	
		oExcel:AddRow(_cPlan,_cTitulos,aLinha)
		
	Next

	oExcel:AddRow(_cPlan,_cTitulos,aTotal)


Next

oExcel:Activate()

If Empty(_cDirHttp)		
	cArq := CriaTrab( NIL, .F. ) + ".xml"
	LjMsgRun( "Gerando o arquivo, aguarde...", _cTitulo, {|| oExcel:GetXMLFile( cArq ) } )
	
	If __CopyFile( cArq, cDirTmp + "\" + _cProg + "-" + cArq)
	   IF MsgYesNo("Deseja abrir o arquivo "+cDirTmp + "\" + _cProg + "-" + cArq+" ?")
	      ShellExecute("open", cDirTmp + "\" + _cProg + "-" + cArq,"","",1)
		  //oExcelApp := MsExcel():New()
		  //oExcelApp:WorkBooks:Open( cDirTmp + "\" + _cProg + "-" + cArq)
		  //oExcelApp:SetVisible(.T.)
	   ENDIF	
	   Ferase(cArq)
	Else
		MsgInfo( "O Arquivo não foi copiado para a pasta temporária local." )
	Endif
Else
	cArq := _cDirHttp+"\"+_cProg+".xml"
	LjMsgRun( "Gerando o arquivo, aguarde...", cArq+" - "+_cTitulo, {|| oExcel:GetXMLFile( cArq ) } )

EndIf

RestArea(aArea)

Return

