#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} GeraXml
Generico - Gera planilha excel no formato .XML com opção de gerar também no formato .XLSX
@Return
@author Marcos Bispo Abrahão
@since 29/03/20
@version P12
/*/

// Exemplo
//	    AADD(aCabsX,Capital(cNomeC))
//	    AADD(aCamposX,_cAlias+"->"+FIELDNAME(nI))
//	    AADD(aImpr,.T.)
//	    AADD(aAlign,NIL)
//	    AADD(aFormat,NIL)
//	    AADD(aTotal,NIL)

//AADD(aPlansX,{_cAlias,_cPlan,"",_cTitulo,aCamposX,aCabsX,aImpr,aAlign,aFormat,aTotal,_cQuebra,_lClose})
//U_GeraXml(aPlansX,_cTitulo,_cAlias,.F.)

User Function GeraXml( _aPlans,_cTitulo,_cProg, lClose, _aParam )
Local oProcess
If MsgYesNo("Deseja gerar no formato Excel (.xlsx) ?")
	//oProcess := MsNewProcess():New({|| U_ProcXlsx(oProcess,_aPlans,_cTitulo,_cProg, lClose, _aParam)}, "Processando...", "Aguarde...", .T.)

	MsgRun("Criando Planilha Excel "+_cProg,"Aguarde...",{|| U_ProcXlsx(oProcess,_aPlans,_cTitulo,_cProg, lClose, _aParam) })

Else
	//oProcess := MsNewProcess():New({|| U_ProcXml(oProcess,_aPlans,_cTitulo,_cProg, lClose, _aParam)}, "Processando...", "Aguarde...", .T.)	

	MsgRun("Criando Arquivo XML "+_cProg,"Aguarde...",{|| U_ProcXml(oProcess,_aPlans,_cTitulo,_cProg, lClose, _aParam) })

EndIf
//oProcess:Activate()
Return Nil


User Function ProcXml(oProcess,_aPlans,_cTitulo,_cProg, lClose, _aParam )

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
Local nPl        := 0 
Local nPosTot    := 0
Local nPosTit    := 0
Local lTitTot    := .T. 
Local nPosCpo    := 0

Local _cAlias    := ""
Local _cPlan     := ""
Local _cFiltra   := ""
Local _cTitulos  := "" 
Local _aCampos   := {}
Local _aCabs     := {}
Local _aImpr     := {}
Local _aAlign    := {}
Local _aFormat   := {}
Local _aTotal    := {}
Local _cQuebra   := ""

Default _cTitulo := ""
//Default _lZebra  := .T.

Private xCampo
Private xQuebra

//oProcess:SetRegua1(LEN(_aPlans)+2)
//oProcess:IncRegua1("Preparando configurações...")

IF lClose == NIL
   lClose := .T.
ENDIF

MakeDir(cDirTmp)

oExcel := FWMsExcel():New()

// Define cores em tons de cinza

oExcel:SetLineFrColor("#000000")
oExcel:SetLineBgColor("#FFFFFF")
	
oExcel:Set2LineFrColor("#000000")
//If _lZebra
	oExcel:Set2LineBgColor("#F5F5F5")
//Else
//	oExcel:Set2LineBgColor("#FFFFFF")
//EndIf

oExcel:SetHeaderBold(.T.)
oExcel:SetFrColorHeader("#000000")
oExcel:SetBgColorHeader("#D3D3D3") 

oExcel:SetTitleFrColor("#000000")
oExcel:SetTitleBgColor("#FFFFFF")

FOR nPl := 1 TO LEN(_aPlans)

	_cAlias  := _aPlans[nPl,01]
	_cPlan   := _aPlans[nPl,02]
	_cFiltra := _aPlans[nPl,03]
	_cTitulos:= _aPlans[nPl,04] 
	_aCampos := _aPlans[nPl,05]
	_aCabs   := _aPlans[nPl,06]
	_aImpr   := _aPlans[nPl,07]
	_aAlign  := _aPlans[nPl,08]
	_aFormat := _aPlans[nPl,09]
	_aTotal  := _aPlans[nPl,10]
	_cQuebra := _aPlans[nPl,11]
	_lClose  := _aPlans[nPl,12]
	nPosTit  := 0
	nPosTot  := 0 
	nPosCpo  := 0

	//oProcess:IncRegua1("Gerando planilha "+_cPlan+"...")

	oExcel:AddworkSheet(_cPlan)

	oExcel:AddTable (_cPlan,_cTitulos)
	
	If !empty(_cFiltra)
		(_cAlias)->(dbsetfilter({|| &_cFiltra} , _cFiltra))
	Endif
	
	(_cAlias)->(dbgotop())
	
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
	
	//oProcess:SetRegua2((_cAlias)->(LastRec()))
	
	Do While (_cAlias)->(!eof()) 
	
        //oProcess:IncRegua2("Processando linhas...")

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

oExcel:Activate()
		
cArq := _cProg +"-"+DTOS(Date()) + ".xml"
If File(cArq)
	nRet:= FERASE(cArq)
	If nRet < 0
		MsgStop("Não será possivel gerar a planilha "+cArq+", feche o arquivo",_cProg)
	EndIf
EndIf

//oProcess:IncRegua1("Gerando o arquivo"+cArq+"...")
oExcel:GetXMLFile( cArq )

If __CopyFile( cArq, cDirTmp + "\" + _cProg + "-" + cArq)
	//oProcess:IncRegua1("Abrindo o arquivo"+cArq+"...")
   //IF MsgYesNo("Deseja abrir o arquivo "+cDirTmp + "\" + _cProg + "-" + cArq+" ?")
      ShellExecute("open", cDirTmp + "\" + _cProg + "-" + cArq,"","",1)
	  //oExcelApp := MsExcel():New()
	  //oExcelApp:WorkBooks:Open( cDirTmp + "\" + _cProg + "-" + cArq)
	  //oExcelApp:SetVisible(.T.)
   //ENDIF	
   Ferase(cArq)
Else
	MsgInfo( "Não foi possível copiar o arquivo para a pasta temporária local." )
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
U_GeraXml(aPlansX,_cTitulo,_cAlias,.F.)

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
Local nPl        := 0
Local nRow       := 0 
Local nPosTot    := 0
Local nPosTit    := 0
Local lTitTot    := .T. 
Local nPosCpo    := 0

Local _aDados    := {}
Local _cPlan     := ""
Local _cTitulos  := "" 
Local _aCabs     := {}
Local _aImpr     := {}
Local _aAlign    := {}
Local _aFormat   := {}
Local _aTotal    := {}

Default _cTitulo := ""
Default _lZebra  := .T.
Default _cDirHttp:= ""
Private xCampo
Private xQuebra

If !Empty(_cDirHttp)
	cDirTmp := _cDirHttp
EndIf
	
MakeDir(cDirTmp)

oExcel := FWMsExcel():New()

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

FOR nPl := 1 TO LEN(_aPlans)

	_aDados  := _aPlans[nPl,01]
	_cPlan   := _aPlans[nPl,02]
	_cTitulos:= _aPlans[nPl,03] 
	_aCabs   := _aPlans[nPl,04]
	_aImpr   := _aPlans[nPl,05]
	_aAlign  := _aPlans[nPl,06]
	_aFormat := _aPlans[nPl,07]
	_aTotal  := _aPlans[nPl,08]
	
	oExcel:AddworkSheet(_cPlan)

	oExcel:AddTable (_cPlan,_cTitulos)

	ProcRegua(Len(_aDados)) 
	
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
        If len(_aDados) > 0
		    xCampo := _aDados[1,nI]
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
	
	For nRow := 1 To Len(_aDados)
	
		aLinha := {}
		
	 	For nI :=1 to LEN(_aDados[nRow])
	
	         xCampo := _aDados[nRow,nI]

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
	cArq := GetNextAlias() + ".xml"
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

