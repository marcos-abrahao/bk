#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} GeraCsv
Generico - Gera planilha excel no formato .CSV
@Return
@author Marcos Bispo Abrahão
@since 04/04/2020
@version P12
/*/


// Funcão para gerar arquivo excell (texto, com campos separados por virgula)
//	Exemplo de campos:
//	ProcRegua(1)
//	Processa( {|| ProcQuery() })
//
//	aCabs   := {}
//	aCampos := {}
//	aTitulos:= {}
   
//	nomeprog := "BKFINR05/"+TRIM(SUBSTR(cUsuario,7,15))
//	AADD(aTitulos,nomeprog+" - "+titulo)

//	AADD(aCampos,"QSE2->Z2_BANCO")
//	AADD(aCabs  ,"Banco")
//		AADD(aTitulos,"Cliente de: "+mv_par01)  -> Titulo do relatorio
//		AADD(aCampos,"QSC9->C9_FILIAL")         -> Campo
//		AADD(aCabs  ,"Filial")                  -> Cab do Campo
//         cTpQuebra : "H"-> Quebra Horizontal, itens na mesma linha "V" -> Quebra em novas linhas
//                     " "-> Sem Quebra
//         cQuebra = "QSC9->C9_FILIAL+QSC9->C9_PRODUTO"
//         AADD(AQuebra,{ {"QSC9->C9_FILIAL","Filial"},{"QSC9->C9_PRODUTO","Produto"} }
//
//  Chamada
//    Processa( {|| U_GeraCSVQ("QSC6",TRIM(cPerg),aTitulos,aCampos,aCabs)})

User Function GeraCSV(_cAlias,cArqS,aTitulos,aCampos,aCabs,cTpQuebra,cQuebra,aQuebra,lClose)
Local nHandle
Local cCrLf   := Chr(13) + Chr(10)
Local _ni,_nj
Local cPicN   := "@E 9999999999.999999"
Local cDirTmp := "C:\TMP"
Local cArqTmp := cDirTmp+"\"+cArqS+"-"+DTOS(Date())+".CSV"
Local lSoma,aSoma,nCab
Local aPlans  := {}

Private xQuebra,xCampo

IF cTpQuebra == NIL
   cTpQuebra := " "
ENDIF

IF lClose == NIL
   lClose := .T.
ENDIF

If MsgYesNo("Deseja gerar no formato Excel (.xlsx) ?")
   AADD(aPlans,{_cAlias,TRIM(cArqS),"",aTitulos,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose })
   U_GeraXlsx(aPlans,"",cArqS, lClose,)
   Return Nil
EndIf

MakeDir(cDirTmp)

If File(cArqTmp)
	nRet:= FERASE(cArqTmp)
	If nRet < 0
		MsgAlert("Não será possivel gerar a planilha, feche o arquivo "+cArqTmp,cArqS)
	EndIf
EndIf

lSoma := .F.
aSoma := {}
nCab  := 0

nHandle := MsfCreate(cArqTmp,0)

If nHandle > 0
      
   FOR _ni := 1 TO LEN(aTitulos)
      fWrite(nHandle, aTitulos[_ni])
      fWrite(nHandle, cCrLf ) // Pula linha
      nCab++
   NEXT

   FOR _ni := 1 TO LEN(aCabs)
       fWrite(nHandle, aCabs[_ni] + IIF(_ni < LEN(aCabs),";",""))
   NEXT
   nCab++

   fWrite(nHandle, cCrLf ) // Pula linha

   (_cAlias)->(dbgotop())
   ProcRegua((_cAlias)->(LastRec())) 
   Do While (_cAlias)->(!eof())

      IF !lSoma
         For _ni :=1 to LEN(aCampos)
             xCampo := &(aCampos[_ni])
            
             If VALTYPE(xCampo) == "N" // Trata campos numericos
                //AADD(aSoma,'=Soma('+CHR(_ni+64)+ALLTRIM(STR(nCab+1))+':')
                AADD(aSoma,'=Soma('+U_LETRA(_ni)+ALLTRIM(STR(nCab+1))+':')
             Else
                AADD(aSoma,"")
             Endif
         Next
         lSoma := .T.
      ENDIF
   
      IncProc("Gerando arquivo "+cArqS)   

      For _ni :=1 to LEN(aCampos)

         xCampo := &(aCampos[_ni])
            
         _uValor := ""
            
         If VALTYPE(xCampo) == "D" // Trata campos data
            _uValor := dtoc(xCampo)
         Elseif VALTYPE(xCampo) == "N" // Trata campos numericos
            _uValor := transform(xCampo,cPicN)
         Elseif VALTYPE(xCampo) == "C" // Trata campos caracter
         	IF LEN(ALLTRIM(xCampo)) > 250
            	_uValor := OEMTOANSI(ALLTRIM(xCampo))
            ELSE
            	_uValor := '="'+OEMTOANSI(ALLTRIM(xCampo))+'"'
            ENDIF
         Endif
            
		 /*
		 IF LEN(_uValor) > 255
           	For i = 0 To Int(Len(_uValor) / 255)
				fWrite(nHandle, substr(_uValor, (i * 255) + 1, 255) + ";") 
			Next 
			fWrite(nHandle,IIF(_ni < LEN(aCampos),";","")) 
         ELSE
         	fWrite(nHandle, _uValor + IIF(_ni < LEN(aCampos),";",""))
         ENDIF
         */
      	fWrite(nHandle, _uValor + IIF(_ni < LEN(aCampos),";",""))

      Next _ni
      nCab++   
      
      If !EMPTY(cTpQuebra)
         lSoma := .F.
         xQuebra := &(cQuebra)
         Do While !EOF() .AND. xQuebra == &(cQuebra)
            If cTpQuebra == "V"   
	           fWrite(nHandle, cCrLf )
            Endif
            For _nj := 1 To LEN(aQuebra)
                 xCampo := &(aQuebra[_nj,1])
            
                 _uValor := ""
            
                 If VALTYPE(xCampo) == "D" // Trata campos data
                    _uValor := dtoc(xCampo)
                 Elseif VALTYPE(xCampo) == "N" // Trata campos numericos
                    _uValor := transform(xCampo,cPicN)
                 Elseif VALTYPE(xCampo) == "C" // Trata campos caracter
		            _uValor := '="'+OEMTOANSI(ALLTRIM(xCampo))+'"'
                 Endif
                 
               	fWrite(nHandle, _uValor + IIF(_ni < LEN(aQuebra),";","")) 
            Next _nj
            (_cAlias)->(dbskip())
            
         Enddo
      ENDIF
      fWrite(nHandle, cCrLf )

      (_cAlias)->(dbskip())
         
   Enddo
   IF lSoma
	   FOR _ni := 1 TO LEN(aSoma)
	       IF !EMPTY(aSoma[_ni])
              //aSoma[_ni] += CHR(_ni+64)+ALLTRIM(STR(nCab))+')'
              aSoma[_ni] += U_LETRA(_ni)+ALLTRIM(STR(nCab))+')'
	       ENDIF
	       fWrite(nHandle, aSoma[_ni] + IIF(_ni < LEN(aSoma),";",""))
	   NEXT
   ENDIF	
      
   fClose(nHandle)
      
	MsgRun(cArqs,"Aguarde a abertura da planilha...",{|| ShellExecute("open", cArqTmp,"","",1) })

Else
   MsgAlert("Falha na criação do arquivo "+cArqTmp)
Endif

IF lClose   
   (_cAlias)->(dbCloseArea())
ENDIF
   
Return


// Converte query ou dbf em arquivo .csv
// Exemplo: 	U_QryToCsv("QSC2",cPerg,{Titulo})

User Function QryToCsv(_cAlias,cArqS,aTitulos,lClose)
Local _nI
Local aCabs   := {}
Local aCampos := {}                 

dbSelectArea(_cAlias)
FOR _nI := 1 TO FCOUNT()
    AADD(aCabs,FIELDNAME(_ni))
    AADD(aCampos,_cAlias+"->"+FIELDNAME(_ni))
NEXT

ProcRegua(LASTREC())
Processa( {|| U_GeraCSV(_cAlias,TRIM(cArqS),aTitulos,aCampos,aCabs,,,,lClose)})

Return nil


USER FUNCTION Letra(nValor)
Local cLETRA := ''
Local lOk := .T.


WHILE lOk

	IF nValor > 26
		nValor := nValor - 26
		cLETRA += "A"
	ELSE
		cLETRA += CHR(nValor+64)
		lOk := .F.
	ENDIF 
ENDDO

Return cLETRA

