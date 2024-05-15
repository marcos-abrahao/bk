#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/// ROTINA AUTOMATICA - INCLUSAO DE LANCAMENTO CONTABIL CTB - LIQUIDOS DA FOLHA (SZ2)

User Function BKCTBA02()
Private cString   := "SZ2"
Private cCadastro := "Contabilização Liquidos da Folha - "+FWEmpName(cEmpAnt)

Private aRotina

u_MsgLog("BKCTBA02")

dbSelectArea("SZ2")
dbSetOrder(1)
DbGoTop()

aRotina := {{"Pesquisar" ,"AxPesqui"	,0, 1},;
			{"Visualizar","AxVisual"	,0, 2},;
            {"Importar",  "U_BKCTBAP02()" ,0, 3},;
            {"Alterar"	,"AxAltera"		,0,	4}}

mBrowse(6,1,22,75,cString)

Return



User Function BKCTBAP02()
Local cMesBase := SUBSTR(DTOS(dDataBase),1,6)
Local aArea1   := GetArea()
Local nStatus  := 0

Private cPerg     := "BKCTBA02"
Private cString   := "SZ2"
Private cCadastro := "Contabilização Liquidos da Folha - "+FWEmpName(cEmpAnt)
Private aRotina
Private cPerComp
Private cMesComp,cAnoComp,cCtaCred

dbSelectArea("SZ2")
dbSetOrder(1)
DbGoTop()

ValidPerg(cPerg)
	
If !Pergunte(cPerg,.T.)
	Return
EndIf

u_MsgLog(cPerg)

cMesComp := STRZERO(VAL(mv_par01),2)
cAnoComp := STRZERO(VAL(mv_par02),4)
cCtaCred := mv_par03

If VAL(cMesComp) < 1 .OR. VAL(cMesComp) > 12
	u_MsgLog(cPerg,"Mes incorreto","E")
	Return
EndIf
	
If VAL(cAnoComp) < 2010 .OR. VAL(cAnoComp) > 2020
	u_MsgLog(cPerg,"Ano incorreto","E")
	Return
EndIf

If EMPTY(cCtaCred)
	u_MsgLog(cPerg,"Conta contábila a crédito deve ser informada","E")
	Return
EndIf
	    
cPerComp := cAnoComp+CMesComp
If cPerComp >= cMesBase
	u_MsgLog(cPerg,"Periodo selecionado deve ser anterior ao atual","E")
	Return
EndIf
	
// Verificar se há Lançamentos a gerar
cQuery  := "SELECT COUNT(*) AS Z2CONTAB " 
cQuery  += "FROM "+RETSQLNAME("SZ2")+" SZ2 "
cQuery  += " WHERE Z2_CODEMP = '"+cEmpAnt+"' "
cQuery  += " AND SUBSTRING(Z2_DATAEMI,1,6) = '"+cPerComp+"' "
cQuery  += " AND Z2_VALOR > 0 "  // Existira valores zerados apenas como informativo que o pgto foi gerado pela folha
cQuery  += " AND Z2_CONTAB = ' ' "
cQuery  += " AND Z2_PRODUTO > ' ' "
cQuery  += " AND Z2_STATUS = 'S' "
cQuery  += " AND SZ2.D_E_L_E_T_ <> '*'"
	
TCQUERY cQuery NEW ALIAS "QSZ2"

DbSelectArea("QSZ2")
DbGoTop()
nStatus := QSZ2->Z2CONTAB
QSZ2->(DbCloseArea())
	
IF nStatus > 0
   IF u_MsgLog(cPerg,"Confirma a geração de "+STRZERO(nStatus,6)+" lançamentos ?","Y")
      u_WaitLog(cPerg, {|| RunCtb02() },"Gerando lançamentos..." )
      Return
   ENDIF
ELSE
   u_MsgLog(cPerg,"Não há lançamentos para gerar","W")
ENDIF

RestArea(aArea1)

Return



 
Static Function RunCtb02()

Local _lLP := .T.
Local aCab := {},aItens := {},aRecno:={},	aCHAVEZ2:= {}
//Local aAreaIni := GetArea()
Local cQuery
Local nI := 0,dUDia
Local cCHAVEZ2 := ""

Private lMSHelpAuto := .F.
Private lAutoErrNoFile := .T.

cQuery  := "SELECT Z2_CODEMP,Z2_FILIAL,Z2_DATAEMI,Z2_DATAPGT,Z2_E2PRF,Z2_E2NUM,Z2_E2PARC,Z2_TIPO,Z2_TIPOPES,Z2_E2TIPO,Z2_PRODUTO,SUM(Z2_VALOR) as Z2_VALOR,Z2_CC" //--,Z2_NOME,R_E_C_N_O_ AS Z2RECNO " 
cQuery  += " FROM "+RETSQLNAME("SZ2")+" SZ2 "
cQuery  += " WHERE Z2_CODEMP = '"+cEmpAnt+"' "
cQuery  += " AND SUBSTRING(Z2_DATAEMI,1,6) = '"+cPerComp+"' "
cQuery  += " AND Z2_VALOR > 0 "
cQuery  += " AND Z2_CONTAB = ' ' "
cQuery  += " AND Z2_PRODUTO > ' ' "
cQuery  += " AND Z2_STATUS = 'S' "
cQuery  += " AND SZ2.D_E_L_E_T_ <> '*'"
cQuery  += " GROUP BY Z2_CODEMP,Z2_FILIAL,Z2_DATAEMI,Z2_DATAPGT,Z2_E2PRF,Z2_E2NUM,Z2_E2PARC,Z2_TIPO,Z2_TIPOPES,Z2_E2TIPO,Z2_PRODUTO,Z2_CC"

cQuery  += " ORDER BY Z2_FILIAL,Z2_DATAEMI,Z2_E2PRF,Z2_E2NUM,Z2_E2PARC,Z2_E2TIPO "

TCQUERY cQuery NEW ALIAS "QSZ2"
TCSETFIELD("QSZ2","Z2_DATAEMI","D",8,0)
TCSETFIELD("QSZ2","Z2_DATAPGT","D",8,0)

 

// Marca os registros a serem importados
//cQuery := " UPDATE "+RetSqlName("SZ2")+" SET Z5_STATUS = 'X' WHERE Z5_STATUS = ' ' AND D_E_L_E_T_ <> '*' "
//TcSqlExec(cQuery)

lMsErroAuto := .F.

DbSelectArea("QSZ2")
DbGoTop()
Do While !eof()

    cFil := QSZ2->Z2_FILIAL
    dUDia:= IIF(ALLTRIM(QSZ2->Z2_TIPO) $ "LPM/LRC",QSZ2->Z2_DATAPGT,QSZ2->Z2_DATAEMI)
       
	aCab := { {'DDATALANC', dUDia,    NIL},;
	          {'CLOTE', IIF(ALLTRIM(QSZ2->Z2_TIPO) $ "LPM/LRC",SUBSTR(DTOS(QSZ2->Z2_DATAPGT),1,6),SUBSTR(DTOS(QSZ2->Z2_DATAEMI),1,6)),  NIL},;
	          {'CSUBLOTE',  '001',     NIL},;
	          {'CPADRAO',   '',        NIL},;
	          {'NTOTINF',   0,         NIL},;
	          {'NTOTINFLOT',0,         NIL} }
//	          {'CDOC',      QSZ2->Z5_ANOMES+'00' ,NIL},;


//NOPC,DDATALANC,CLOTE,CSUBLOTE,CDOC,LAGLUT,CSEQUENC,LCUSTO,LITEM,LCLVL,NTOTINF,CPROG,CPRELCTO,DREPROC,CEMPORI,CFILORI,@AFLAGCTB,@ACTKXCT2,@ATPSALDO,CMODOCLR,ASEQDIARIO,LMLTSLD,CSEQCORR		

	nLinha  := 1
    aItens  := {}
    aRecno  := {}
	aCHAVEZ2:= {}

    _lLP     := .T.
	Do While !eof() .AND. cFil == QSZ2->Z2_FILIAL .AND. dUdia == IIF(ALLTRIM(QSZ2->Z2_TIPO) $ "LPM/LRC",QSZ2->Z2_DATAPGT,QSZ2->Z2_DATAEMI)
		
		cCHAVEZ2 := xFilial("SZ2")+QSZ2->Z2_CODEMP+QSZ2->Z2_E2PRF+QSZ2->Z2_E2NUM+QSZ2->Z2_E2PARC+QSZ2->Z2_E2TIPO  

		//IF ALLTRIM(QSZ2->Z2_CODEMP) == "01"
		  IF (ALLTRIM(QSZ2->Z2_E2TIPO) =="PA" .AND. ALLTRIM(QSZ2->Z2_E2PRF) == "LF") .OR. QSZ2->Z2_TIPOPES  $ "CLA/AC"  // Não contabilizar segregado para PA LF 
		  	_lLP := .F.
       		//dbSelectArea("SZ2")
       		//dbGoTo(QSZ2->Z2RECNO)
	   		//RecLock("SZ2",.F.)
	   		//SZ2->Z2_CONTAB := "S"
	   		//MsUnlock()
       		dbSelectArea("SZ2")
       		SZ2->(DBSETORDER(3))
       		SZ2->(DBSEEK(cCHAVEZ2,.T.))
       		Do While SZ2->(!eof()) .AND.  xFilial("SZ2")+SZ2->Z2_CODEMP+SZ2->Z2_E2PRF+SZ2->Z2_E2NUM+SZ2->Z2_E2PARC+SZ2->Z2_E2TIPO   = cCHAVEZ2  
	   			RecLock("SZ2",.F.)
	   			SZ2->Z2_CONTAB := "S"
	   			MsUnlock()
				SZ2->(DbSkip())
			Enddo
		  ELSE
		  	_lLP := .T.
		  ENDIF
	    //ELSE
    	//	_lLP := .T.
	    //ENDIF

		IF _lLP
			//IncProc("Importando lançamentos..."+STR(nLinha))
			//aAdd(aItens,{  {'CT2_FILIAL'  ,QSZ2->Z5_FILIAL,     NIL},;
			cCCD := ""
			cCCC := ""
			IF SUBSTR(QSZ2->Z2_PRODUTO,1,1) $ "345"
				IF ("ER" $ UPPER(QSZ2->Z2_CC))
					cCCD := "000000001"
				ELSE
					cCCD := QSZ2->Z2_CC
				ENDIF	
			ENDIF
		   		
			aAdd(aItens,{  {'CT2_LINHA'  ,STRZERO(nLinha++,3), NIL},;
		    	           {'CT2_MOEDLC' ,'01',                NIL},;
		        	       {'CT2_DC'     ,'3',                 NIL},;
		        	  	   {'CT2_DEBITO' ,QSZ2->Z2_PRODUTO,    NIL},;
		            	   {'CT2_CREDIT' ,cCtaCred,            NIL},;
		 				   {'CT2_CCD'    ,cCCD,                NIL},;
		   		   		   {'CT2_CCC'    ,cCCC,                NIL},;
		        	       {'CT2_VALOR'  , QSZ2->Z2_VALOR,     NIL},;
		            	   {'CT2_ORIGEM' ,'BKCTBA02-'+QSZ2->Z2_E2NUM+'-'+SUBSTR(cUsuario,7,15), NIL},;
		             	   {'CT2_HP'     ,'',                  NIL},;
		              	   {'CT2_HIST'   ,'LIQ. FOLHA '+TRIM(QSZ2->Z2_E2NUM), NIL} } ) //+" "+TRIM(QSZ2->Z2_NOME), NIL} } )

			//aAdd(aRecno,QSZ2->Z2RECNO)
			aAdd(aCHAVEZ2,cCHAVEZ2)
		
			If nLinha > 999
		   		Exit
			EndIf
		Endif   
		QSZ2->(DbSkip())
	Enddo
		
	//IncProc("Incluindo lançamentos contábeis...")

	Begin Transaction
		lMsErroAuto := .F.
	    MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)
		
		IF lMsErroAuto

			u_LogMsExec("RunCtb02",IIF(LEN(aCHAVEZ2)>1,"LIQ. FOLHA "+TRIM(aCHAVEZ2[1])+" - LIQ. FOLHA "+TRIM(aCHAVEZ2[LEN(aCHAVEZ2)]),''))
			DisarmTransaction()
		ENDIF
	End Transaction

    IF !lMsErroAuto
//    	FOR nI := 1 TO LEN(aRecno)
//       		dbSelectArea("SZ2")
//       		dbGoTo(aRecno[nI])
//	   		RecLock("SZ2",.F.)
//	   		SZ2->Z2_CONTAB := "S"
//	   		MsUnlock()
//	   	NEXT	
    	FOR nI := 1 TO LEN(aCHAVEZ2)
       		dbSelectArea("SZ2")
       		SZ2->(DBSETORDER(3))
       		SZ2->(DBSEEK(aCHAVEZ2[nI],.T.))
   			Do While SZ2->(!eof()) .AND.  xFilial("SZ2")+SZ2->Z2_CODEMP+SZ2->Z2_E2PRF+SZ2->Z2_E2NUM+SZ2->Z2_E2PARC+SZ2->Z2_E2TIPO == aCHAVEZ2[nI]
	   			RecLock("SZ2",.F.)
	   			SZ2->Z2_CONTAB := "S"
	   			MsUnlock()
				SZ2->(DbSkip())
			Enddo
		Next

    ELSE
	   u_MsgLog("RunCtb02","Não foi possivel gerar todos os lançamentos, contate o setor de T.I.","E")
	   EXIT
	ENDIF
	DbSelectArea("QSZ2")
EndDo

QSZ2->(DbCloseArea())

Return  



Static Function  ValidPerg(cPerg)
Local i,j
Local aArea      := GetArea()
Local aRegistros := {}
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Mes de Competencia"  ,"" ,"" ,"mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Ano de Competencia"  ,"" ,"" ,"mv_ch2","C",04,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Cta Ctb a Credito "  ,"" ,"" ,"mv_ch3","C",20,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","CT1","S","",""})

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
