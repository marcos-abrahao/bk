#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ BKGCTR23 º Autor ³ Adilson do Prado           Data ³22/06/17º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Relatório Dados do Dashboard  Funcionários e Glosas          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ BK                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BKGCTR23()
LOCAL aFunc  	:= {}
LOCAL aGlosas 	:= {}
LOCAL aFunc2  	:= {}
LOCAL aGlosas2 	:= {}
LOCAL aAglContr := {}
LOCAL aCNR		:= {}
LOCAL _SQL 		:= ""
LOCAL cCompet1 	:= SubStr(DtoS(MonthSub(dDataBase,2)),5,2)+"/"+SubStr(DtoS(MonthSub(dDataBase,2)),1,4)
LOCAL cCompet2 	:= SubStr(DtoS(MonthSub(dDataBase,1)),5,2)+"/"+SubStr(DtoS(MonthSub(dDataBase,1)),1,4)
LOCAL cCompet3 	:= SubStr(DtoS(dDataBase),5,2)+"/"+SubStr(DtoS(dDataBase),1,4)


	IF SM0->M0_CODIGO == "01"      // BK

		AADD(aAglContr,{'S','105000391','A'})
		AADD(aAglContr,{'P','008000300','A'})
		AADD(aAglContr,{'S','157000247','A'})
		AADD(aAglContr,{'S','157000438','A'})
	//	AADD(aAglContr,{'P','049000171','A'})
		AADD(aAglContr,{'N','163000240','A'})
		AADD(aAglContr,{'N','193000288;194000289;195000290;196000291;','A'})
		AADD(aAglContr,{'N','197000292;198000293;199000294;197001292;198001293;199001294;','A'})
		AADD(aAglContr,{'N','211000316','A'})
		AADD(aAglContr,{'N','215000318','A'})
		AADD(aAglContr,{'S','018000425','A'})
		AADD(aAglContr,{'P','258000429','A'})
		AADD(aAglContr,{'S','012000467','A'})
		AADD(aAglContr,{'S','281000455','A'})    
		AADD(aAglContr,{'S','316000507','A'})
		AADD(aAglContr,{'S','281003510','A'})
		AADD(aAglContr,{'S','333000521','A'})
		
	ELSEIF SM0->M0_CODIGO == "02"      // BK
	
		AADD(aAglContr,{'P','008025001','A'})

	ENDIF

	_SQL := "SELECT CND_CONTRA,CND_REVISA,CN9_XXDESC,CN9_CLIENT,CN9_NOMCLI,CN9_XXNRBK,CND_NUMMED,CND_XXFUNC,CND_XXNFUN,CND.R_E_C_N_O_ AS nREGCND,CND_COMPET"
	_SQL += " FROM "+RETSQLNAME("CN9")+" CN9"
	_SQL += " INNER JOIN "+RETSQLNAME("CND")+" CND ON CND.D_E_L_E_T_='' AND CN9.CN9_NUMERO=CND_CONTRA AND CN9.CN9_REVISA=CND_REVISA"
	_SQL += " WHERE CN9.D_E_L_E_T_='' AND CN9.CN9_SITUAC='05' AND CND_COMPET IN ('"+cCompet1+"','"+cCompet2+"','"+cCompet3+"') ORDER BY CN9_NUMERO"

	TCQUERY _SQL NEW ALIAS "QCND"
	dbSelectArea("QCND")
	QCND->(dbGoTop())
	DO WHILE QCND->(!EOF())
    	nScan:= 0
    	nScan:= aScan(aFunc,{|x| x[1]== QCND->CND_CONTRA .AND. x[2]== QCND->CND_COMPET })
		IF nScan == 0
			AADD(aFunc,{QCND->CND_CONTRA,QCND->CND_COMPET,QCND->CND_XXFUNC,QCND->CND_XXNFUN,QCND->CN9_XXDESC,QCND->CN9_CLIENT,QCND->CN9_NOMCLI,QCND->CN9_XXNRBK})
		ELSE
			IF QCND->CND_XXFUNC> aFunc[nScan,3]
		  		aFunc[nScan,3] := QCND->CND_XXFUNC
			ENDIF
			IF QCND->CND_XXNFUN > aFunc[nScan,4]
		  		aFunc[nScan,4] := QCND->CND_XXNFUN
			ENDIF
		ENDIF
    	aCNR := {}
    	aCNR := VGlosa(QCND->CND_NUMMED)
    	
    	FOR _IX:= 1 TO LEN(aCNR)
    		nScan:= 0
    		nScan:= aScan(aGlosas,{|x| x[1]==QCND->CND_CONTRA .AND. x[2] == QCND->CND_COMPET .AND. x[3] ==  aCNR[_IX,1] .AND. x[4] == aCNR[_IX,2] })
			IF nScan == 0
				AADD(aGlosas,{QCND->CND_CONTRA,QCND->CND_COMPET,aCNR[_IX,1],aCNR[_IX,2],VAL(StrTran(StrTran(aCNR[_IX,3],".",""),",",".")),QCND->CN9_XXDESC,QCND->CN9_CLIENT,QCND->CN9_NOMCLI,QCND->CN9_XXNRBK})
			ELSE
				aGlosas[nScan,5] += VAL(StrTran(StrTran(aCNR[_IX,3],".",""),",","."))
			ENDIF                            	
		NEXT
		
		QCND->(dbSkip())
	ENDDO
	QCND->(Dbclosearea())

	aFunc2  	:= {}
	aFunc2  	:= aFunc
	aFunc 		:= {}
	FOR _IX:= 1 TO LEN(aFunc2)

        nConsolida := 0
		FOR _IY:= 1 TO LEN(aAglContr)
    		IF aAglContr[_IY,1] == "P"  .AND. SUBSTR(aAglContr[_IY,2],1,3)==SUBSTR(aFunc2[_IX,1],1,3)
    			nScan:= 0
    			nScan:= aScan(aFunc,{|x| SUBSTR(x[1],1,3)==SUBSTR(aFunc2[_IX,1],1,3) .AND. x[2]== aFunc2[_IX,2] })
				IF nScan == 0
					nConsolida := 1
					//AADD(aFunc,{aFunc2[_IX,1],aFunc2[_IX,2],aFunc2[_IX,3],aFunc2[_IX,4],aFunc2[_IX,5],aFunc2[_IX,6],aFunc2[_IX,7],aFunc2[_IX,8],nConsolida})
					AADD(aFunc,{aAglContr[_IY,2],aFunc2[_IX,2],aFunc2[_IX,3],aFunc2[_IX,4],aFunc2[_IX,5],aFunc2[_IX,6],aFunc2[_IX,7],aFunc2[_IX,8],nConsolida})
				ELSE
					nConsolida := 1
					aFunc[nScan,3] += aFunc2[_IX,3]
					aFunc[nScan,4] += aFunc2[_IX,4]
				ENDIF
			ENDIF
    		IF aAglContr[_IY,1] == "S"  .AND. SUBSTR(aAglContr[_IY,2],7,3)==SUBSTR(aFunc2[_IX,1],7,3)
    			nScan:= 0
    			nScan:= aScan(aFunc,{|x| SUBSTR(x[1],7,3)==SUBSTR(aFunc2[_IX,1],7,3) .AND. x[2]==aFunc2[_IX,2] })
				IF nScan == 0
					nConsolida := 1
					//AADD(aFunc,{aFunc2[_IX,1],aFunc2[_IX,2],aFunc2[_IX,3],aFunc2[_IX,4],aFunc2[_IX,5],aFunc2[_IX,6],aFunc2[_IX,7],aFunc2[_IX,8],nConsolida})
					AADD(aFunc,{aAglContr[_IY,2],aFunc2[_IX,2],aFunc2[_IX,3],aFunc2[_IX,4],aFunc2[_IX,5],aFunc2[_IX,6],aFunc2[_IX,7],aFunc2[_IX,8],nConsolida})
				ELSE
					nConsolida := 1
					aFunc[nScan,3] += aFunc2[_IX,3]
					aFunc[nScan,4] += aFunc2[_IX,4]
				ENDIF
			ENDIF
    		IF aAglContr[_IY,1] == "N"  .AND. aAglContr[_IY,2] $ aFunc2[_IX,1]
    			nScan:= 0
    			nScan:= aScan(aFunc,{|x| SUBSTR(x[1],7,3)==SUBSTR(aFunc2[_IX,1],7,3) .AND. x[2]==aFunc2[_IX,2] })
				IF nScan == 0
					nConsolida := 1
					//AADD(aFunc,{aFunc2[_IX,1],aFunc2[_IX,2],aFunc2[_IX,3],aFunc2[_IX,4],aFunc2[_IX,5],aFunc2[_IX,6],aFunc2[_IX,7],aFunc2[_IX,8],nConsolida})
					AADD(aFunc,{SUBSTR(aAglContr[_IY,2],1,9),aFunc2[_IX,2],aFunc2[_IX,3],aFunc2[_IX,4],aFunc2[_IX,5],aFunc2[_IX,6],aFunc2[_IX,7],aFunc2[_IX,8],nConsolida})
				ELSE
					nConsolida := 1
					aFunc[nScan,3] += aFunc2[_IX,3]
					aFunc[nScan,4] += aFunc2[_IX,4]
				ENDIF
			ENDIF
        NEXT
        IF nConsolida == 0
			AADD(aFunc,{aFunc2[_IX,1],aFunc2[_IX,2],aFunc2[_IX,3],aFunc2[_IX,4],aFunc2[_IX,5],aFunc2[_IX,6],aFunc2[_IX,7],aFunc2[_IX,8],nConsolida})
		ENDIF
	NEXT

	FOR _IX:= 1 TO LEN(aFunc) 
		cXCompet:= ""
		cXCompet := SUBSTR(DTOS(CTOD("01/"+aFunc[_IX,2])),1,4)+"-"+SUBSTR(DTOS(CTOD("01/"+aFunc[_IX,2])),7,2)+"-"+SUBSTR(DTOS(CTOD("01/"+aFunc[_IX,2])),5,2) 
		_SQL := ""
		_SQL +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[Funcionarios] "
		_SQL +="     WHERE [CodigoContrato]= '"+aFunc[_IX,1]+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59') <> '' "
		_SQL +="BEGIN "
		_SQL +=" UPDATE  [EstudoRentabilidade].[dbo].[Funcionarios] SET "
		_SQL +="				[CodigoCliente]='"+aFunc[_IX,6]+"',"
		_SQL +="				[NomeCliente]='"+PAD(ALLTRIM(aFunc[_IX,7])+IIF(aFunc[_IX,9]==1,"-Consolidado",""),80)+"',"
		_SQL +="				[NomeContrato]='"+PAD(ALLTRIM(aFunc[_IX,5])+IIF(aFunc[_IX,9]==1,"-Consolidado",""),80)+"',"
		_SQL +="				[GestorBK]='"+ALLTRIM(aFunc[_IX,8])+"',"
		_SQL +="				[Previsto]="+STR(aFunc[_IX,3],14)+","
		_SQL +="				[Ativos]="+STR(aFunc[_IX,4],14)
		_SQL +="     WHERE [CodigoContrato]= '"+aFunc[_IX,1]+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59'"
		_SQL +="END "
		_SQL +="ELSE "
		_SQL +="BEGIN "
		_SQL +=" INSERT INTO [EstudoRentabilidade].[dbo].[Funcionarios] "
		_SQL +="            ([CodigoContrato] "
		_SQL +="            ,[Competencia] "
		_SQL +="            ,[CodigoCliente]"
		_SQL +="            ,[NomeCliente]"
		_SQL +="            ,[NomeContrato]"
		_SQL +="            ,[GestorBK]"
		_SQL +="            ,[Previsto]"
		_SQL +="            ,[Ativos])"
		_SQL +="      VALUES ('"+aFunc[_IX,1]+"',"
		_SQL +="              '"+cXCompet+" 00:00:00',"
		_SQL +="			  '"+aFunc[_IX,6]+"',"
		_SQL +="			  '"+PAD(ALLTRIM(aFunc[_IX,7])+IIF(aFunc[_IX,9]==1,"-Consolidado",""),80)+"',"
		_SQL +="			  '"+PAD(ALLTRIM(aFunc[_IX,5])+IIF(aFunc[_IX,9]==1,"-Consolidado",""),80)+"',"
		_SQL +="			  '"+ALLTRIM(aFunc[_IX,8])+"',"
		_SQL +="			   "+STR(aFunc[_IX,3],14)+","
		_SQL +="			   "+STR(aFunc[_IX,4],14)+")"
		_SQL +="END "						
		TcSqlExec(_SQL)
	NEXT

	aGlosas2  	:= {}
	aGlosas2  	:= aGlosas
	aGlosas 		:= {}
	FOR _IX:= 1 TO LEN(aGlosas2)

        nConsolida := 0
		FOR _IY:= 1 TO LEN(aAglContr)
    		IF aAglContr[_IY,1] == "P"  .AND. SUBSTR(aAglContr[_IY,2],1,3)==SUBSTR(aGlosas2[_IX,1],1,3)
    			nScan:= 0
    			nScan:= aScan(aGlosas,{|x| SUBSTR(x[1],1,3)==SUBSTR(aGlosas2[_IX,1],1,3) .AND. x[2]==aGlosas2[_IX,2] .AND. x[4]==aGlosas2[_IX,4]})
				IF nScan == 0
					nConsolida := 1
					AADD(aGlosas,{aAglContr[_IY,2],aGlosas2[_IX,2],aGlosas2[_IX,3],aGlosas2[_IX,4],aGlosas2[_IX,5],aGlosas2[_IX,6],aGlosas2[_IX,7],aGlosas2[_IX,8],aGlosas2[_IX,9],nConsolida})
				ELSE
					nConsolida := 1
					aGlosas[nScan,5] += aGlosas2[_IX,5]
				ENDIF
			ENDIF
    		IF aAglContr[_IY,1] == "S"  .AND. SUBSTR(aAglContr[_IY,2],7,3)==SUBSTR(aGlosas2[_IX,1],7,3)
    			nScan:= 0
    			nScan:= aScan(aGlosas,{|x| SUBSTR(x[1],7,3)==SUBSTR(aGlosas2[_IX,1],7,3) .AND. x[2]==aGlosas2[_IX,2] .AND. x[4]==aGlosas2[_IX,4]})
				IF nScan == 0
					nConsolida := 1
					AADD(aGlosas,{aAglContr[_IY,2],aGlosas2[_IX,2],aGlosas2[_IX,3],aGlosas2[_IX,4],aGlosas2[_IX,5],aGlosas2[_IX,6],aGlosas2[_IX,7],aGlosas2[_IX,8],aGlosas2[_IX,9],nConsolida})
				ELSE
					nConsolida := 1
					aGlosas[nScan,5] += aGlosas2[_IX,5]
				ENDIF
			ENDIF
    		IF aAglContr[_IY,1] == "N"  .AND. aAglContr[_IY,2] $ aGlosas2[_IX,1]
    			nScan:= 0
    			nScan:= aScan(aGlosas,{|x| SUBSTR(x[1],7,3)==SUBSTR(aGlosas2[_IX,1],7,3) .AND. x[2]==aGlosas2[_IX,2] .AND. x[4]==aGlosas2[_IX,4]})
				IF nScan == 0
					nConsolida := 1
					AADD(aGlosas,{SUBSTR(aAglContr[_IY,2],1,9),aGlosas2[_IX,2],aGlosas2[_IX,3],aGlosas2[_IX,4],aGlosas2[_IX,5],aGlosas2[_IX,6],aGlosas2[_IX,7],aGlosas2[_IX,8],aGlosas2[_IX,9],nConsolida})
				ELSE
					nConsolida := 1
					aGlosas[nScan,5] += aGlosas2[_IX,5]
				ENDIF
			ENDIF
        NEXT
        IF nConsolida == 0
			AADD(aGlosas,{aGlosas2[_IX,1],aGlosas2[_IX,2],aGlosas2[_IX,3],aGlosas2[_IX,4],aGlosas2[_IX,5],aGlosas2[_IX,6],aGlosas2[_IX,7],aGlosas2[_IX,8],aGlosas2[_IX,9],nConsolida})
		ENDIF
	NEXT

    FOR _IX:= 1 TO LEN(aGlosas)
		IF aGlosas[_IX,3] == "Glosa"
			cXCompet:= ""
			cXCompet := SUBSTR(DTOS(CTOD("01/"+aGlosas[_IX,2])),1,4)+"-"+SUBSTR(DTOS(CTOD("01/"+aGlosas[_IX,2])),7,2)+"-"+SUBSTR(DTOS(CTOD("01/"+aGlosas[_IX,2])),5,2) 
			_SQL := ""
			_SQL +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[GlosasMotivos] "
			_SQL +="     WHERE [CodigoContrato]= '"+aGlosas[_IX,1]+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59'
			_SQL +="	AND [GlosasMotivos]='"+aGlosas[_IX,4]+"') <> '' "
			_SQL +=" BEGIN "
			_SQL +=" UPDATE  [EstudoRentabilidade].[dbo].[GlosasMotivos] SET "
			_SQL +="				[CodigoCliente]='"+aGlosas[_IX,7]+"',"
			_SQL +="				[NomeCliente]='"+PAD(ALLTRIM(aGlosas[_IX,8])+IIF(aGlosas[_IX,10]==1,"-Consolidado",""),80)+"',"
			_SQL +="				[NomeContrato]='"+PAD(ALLTRIM(aGlosas[_IX,6])+IIF(aGlosas[_IX,10]==1,"-Consolidado",""),80)+"',"
			_SQL +="				[GestorBK]='"+ALLTRIM(aGlosas[_IX,9])+"',"
			_SQL +="				[GlosasMotivos]='"+aGlosas[_IX,4]+"',"
			_SQL +="				[Valor]="+STR(IIF(aGlosas[_IX,5]<0,aGlosas[_IX,5]*-1,aGlosas[_IX,5]),14,2)  
			_SQL +="     WHERE [CodigoContrato]= '"+aGlosas[_IX,1]+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59'"
			_SQL +="	AND [GlosasMotivos]='"+aGlosas[_IX,4]+"'"
			_SQL +=" END "
			_SQL +=" ELSE "
			_SQL +=" BEGIN "
			_SQL +=" INSERT INTO [EstudoRentabilidade].[dbo].[GlosasMotivos] "
			_SQL +="            ([CodigoContrato] "
			_SQL +="            ,[Competencia] "
			_SQL +="            ,[CodigoCliente]"
			_SQL +="            ,[NomeCliente]"
			_SQL +="            ,[NomeContrato]"
			_SQL +="            ,[GestorBK]"
			_SQL +="            ,[GlosasMotivos]"
			_SQL +="            ,[Valor])"
			_SQL +="      VALUES ('"+aGlosas[_IX,1]+"',"
			_SQL +="              '"+cXCompet+" 00:00:00',"
			_SQL +="			  '"+aGlosas[_IX,7]+"',"
			_SQL +="			  '"+PAD(ALLTRIM(aGlosas[_IX,8])+IIF(aGlosas[_IX,10]==1,"-Consolidado",""),80)+"',"
			_SQL +="			  '"+PAD(ALLTRIM(aGlosas[_IX,6])+IIF(aGlosas[_IX,10]==1,"-Consolidado",""),80)+"',"
			_SQL +="			  '"+ALLTRIM(aGlosas[_IX,9])+"',"
			_SQL +="				'"+aGlosas[_IX,4]+"',"
			_SQL +="				 "+STR(IIF(aGlosas[_IX,5]<0,aGlosas[_IX,5]*-1,aGlosas[_IX,5]),14,2)+")"
			_SQL +=" END "						
			TcSqlExec(_SQL)
		ENDIF
	NEXT



RETURN NIL



Static Function VGlosa(nMDNUMED)
Local cQuery    := ""
Local aAreaIni  := GetArea()
Local cAliasCNR := GetNextAlias()
Local aCNR      := {}
Local cREVISA 	:= ""
Local dTINIC 	:= CTOD("")
Local cDETG		:= ""
Local cJUST		:= ""

cQuery  := "SELECT CNR_TIPO,CNR_DESCRI,CNR_VALOR " 
cQuery  += "FROM "+RETSQLNAME("CNR")+" CNR WHERE CNR.D_E_L_E_T_ = '' AND CNR_NUMMED = '"+nMDNUMED+"' "

TCQUERY cQuery NEW ALIAS (cAliasCNR)

DbSelectArea(cAliasCNR)
DbGoTop()

Do While (cAliasCNR)->(!eof())
	cTipoNome := IIF((cAliasCNR)->CNR_TIPO == "1","Bonificação","Glosa")
	DBSELECTAREA("CND")
	CND->(DBSETORDER(4))
	CND->(DBSEEK(xFILIAL("CND")+nMDNUMED,.F.))

	AADD(aCNR,{cTipoNome,(cAliasCNR)->CNR_DESCRI,TRANSFORM((cAliasCNR)->CNR_VALOR,"@E 999,999,999.99"),CND->CND_XXJUST})

	(cAliasCNR)->(dbSkip())
EndDo

If LEN(aCNR) > 0
    cREVISA := ""
   	dTINIC 	:= CTOD("")
   	cDETG	:= ""
   	cJUST	:= ""
	DBSELECTAREA("CND")
	CND->(DBSETORDER(4))
	CND->(DBSEEK(xFILIAL("CND")+nMDNUMED,.F.))
	DO While CND->(!eof()) .AND. CND->CND_NUMMED==nMDNUMED
        IF CND->CND_REVISA > cREVISA
        	cREVISA := CND->CND_REVISA
        	dTINIC 	:= CND->CND_DTINIC
        	cDETG	:= CND->CND_XXDETG
        	cJUST	:= CND->CND_XXJUST
        ENDIF 
		CND->(dbSkip())
	ENDDO
	
	IF !EMPTY(dTINIC)  
		IF dTINIC >= CTOD("16/11/2015")
      		aCNR := {}
       		ALINHA1 := {}
			FOR nI:= 1 to MLCOUNT(cDETG,80)       		
				AADD(ALINHA1,U_StringToArray(TRIM(MEMOLINE(cDETG,80,nI)), "R$" ))
			NEXT
       		ALINHA2 := {}
			FOR nI:= 1 to MLCOUNT(cJUST,250)       		
				AADD(ALINHA2,MEMOLINE(cJUST,250,nI))
			NEXT
			
			FOR nI:= 1 to LEN(ALINHA1)
			    IF LEN(ALINHA1) == LEN(ALINHA2)
					IF LEN(ALINHA1[nI]) > 1
			    		AADD(aCNR,{IIF(VAL(ALINHA1[nI,2]) > 0,"Bonificação","Glosa"),ALINHA1[nI,1],ALINHA1[nI,2],ALINHA2[nI]})
			    	ENDIF 
			    ENDIF
			NEXT

		ENDIF
	ENDIF
EndIf

(cAliasCNR)->(dbCloseArea())

RestArea(aAreaIni)

Return aCNR

