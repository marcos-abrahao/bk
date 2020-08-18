#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#include "TBICONN.CH"
#include "AP5MAIL.CH"
#include "TOTVS.CH"

// Função via Schedule
User Function BKGCT06(aParam)

Local cFwEmp := ""

Public lJobV2    := .T.
Public cPrw      := "BKGCT06"
Public cEmailS   := ""
Public cContrRep := SPACE(15)
Public dtIni     := CTOD("")
Public dtFim     := CTOD("")

Private lExp     := .F.
Private dDataEnv
Private lEnvT    := .T.
Private cEmpPar  := "01"
Private cFilPar  := "01"

default aParam := {"01","01"} // caso nao receba nenhum parametro

/*/
Programa     : BKGCT06 - Autor: Marcos B. Abrahao - Data: 13/09/2010
Objetivo     : Avisos automaticos de Repactuação de contratos
Uso          : BK
/*/

cEmpPar := aParam[1]
cFilPar := aParam[2]

//-- Evita que se consuma licenca
//RpcSetType ( 3 )

//PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil MODULO "FAT" 

WFPrepEnv(cEmpPar,cFilPar,"BKGCT06",{"CN9"},"GCT")

//WFPrepEnv( <cEmpresa>, <cFilial>, <cFunname>, <aTabelas>, <cModulo>)
//TABLES "SA1" "SC5" "SC6" 


dDataEnv := DATE()
dbSelectArea("SX6")
IF !DBSEEK("  MV_XXBKENV",.F.)
   RecLock("SX6",.T.)
   SX6->X6_VAR     := "MV_XXBKENV"
   SX6->X6_TIPO    := "C"
   SX6->X6_DESCRIC := "Ultimo email enviado - Aviso de Termino de Contatos - "+SM0->M0_NOME
   SX6->X6_CONTEUD := ""
   MsUnlock()
ELSE
	lEnvT := EMPTY(ALLTRIM(SX6->X6_CONTEUD))	   
ENDIF


ConOut("RepBKGCT06: processando avisos de repactuação - "+DTOC(DATE())+" "+TIME())   
RepBKGCT06()

ConOut("RepBK06b: processando avisos de repactuação - Detalhado - "+DTOC(DATE())+" "+TIME())   
RepBK06b()

IF DOW(dDataEnv) = 1 .OR. lEnvT

	ConOut("VigBKGCT06: processando avisos de termino de vigencia - "+DTOC(DATE())+" "+TIME())   
	VigBKGCT06()
	
	ConOut("Vg2BKGct06: processando avisos de termino de vigencia 2 - "+DTOC(DATE())+" "+TIME())   
	Vg2BKGct06()
	
ENDIF

ConOut("V5BKGct06: processando Aviso de Insumos Operacionais - "+DTOC(DATE())+" "+TIME())   
V5BKGct06()

ConOut("V6BKGct06: processando Aviso Atestado de Capacidade Técnica - "+DTOC(DATE())+" "+TIME())   
V6BKGct06()

ConOut("V7BKGct06: processando Aviso Vigência da Caução - "+DTOC(DATE())+" "+TIME())   
V7BKGct06()

ConOut("V8BKGct06: processando Aviso Doc. Segurança do Trabalho - "+DTOC(DATE())+" "+TIME())   
V8BKGct06()

//IF DOW(Date()) == 1

cFWEmp := SUBSTR(FWCodEmp(),1,2)
 
ConOut("BKGCT06 Empresa:"+FWCodEmp()+".")

If cFWEmp $ "01" 
	ConOut("V9BKGct06: Aviso de pedido de compras aguardando aprovação - "+DTOC(DATE())+" "+TIME())   
	V9BKGct06()
EndIf

If cFWEmp $ "01" 
	ConOut("V10BKGct06: Aviso de pedido de compras não entregue - "+DTOC(DATE())+" "+TIME())   
	V10BKGct06()
EndIf

If cFWEmp $ "01" 
	ConOut("V11BKGct06: Aviso de Solicitação de compras em aberto - "+DTOC(DATE())+" "+TIME())   
	V11BKGct06()
EndIf

If cFWEmp == "01" 
	//ConOut("V12BKGct06: Aviso de pedido de venda em aberto - "+DTOC(DATE())+" "+TIME())   
	//V12BKGct06()
EndIf

If cFWEmp $ "01/02/14" 
	ConOut("GRFBKGCT11: Processando Grafico Rentabilidade dos Contratos - "+DTOC(DATE())+" "+TIME())   
	U_GRFBKGCT11(.T.)
	ConOut("GRFBKGCT11: Finalizado processamento Grafico Rentabilidade dos Contratos - "+DTOC(DATE())+" "+TIME())   
ENDIF

If cFWEmp $ "01/02/14" 
	ConOut("BKGCTR23: Processando Dados do Dashboard  Funcionários e Glosas - "+DTOC(DATE())+" "+TIME())   
	U_BKGCTR23()
	ConOut("BKGCTR23: Finalizado processamento Dados do Dashboard  Funcionários e Glosas - "+DTOC(DATE())+" "+TIME())   
ENDIF

Reset Environment

RETURN


// Funcão via tela

User Function BKGCT06A(aParam)

Local aUser
Local cRel       := 1
Local aRel       := {"01-Aviso de contratos pendentes de repactuação",;
                     "02-Aviso de término de vigência de contratos",;
                     "03-Alerta de término de vigência de contratos",;
                     "04-Aviso de repactuação - Detalhado",;
                     "05-Aviso de Insumos Operacionais",;
                     "06-Aviso de Atestado Capacidade Técnica",;
                     "07-Aviso de Vigência da Caução",;
                     "08-Aviso de Venc. Doc. Segurança do Trabalho",;
                     "09-Aviso de pedido de compras aguardando aprovação",;
                     "10-Aviso de pedido de compras não entregue",;
                     "11-Aviso de solicitação de compras em aberto",;
                     "12-Aviso de pedido de venda em aberto",;
                     "13-Funcionario Dashbord",;
                     "14-Rentabilidade Dashbord"}

Private lExp     := .F.
Private dDataEnv := DATE()

Public lJobV2    := .F.
Public cEmailS   := ""
Public cContrRep := SPACE(15)
Public dtIni     := CTOD("")
Public dtFim     := CTOD("")

PswOrder(1) 
PswSeek(__CUSERID) 
aUser   := PswRet(1)
cEmailS := PAD(aUser[1,14],50)

@ 200,01 TO 450,470 DIALOG oDlg1 TITLE "BKGCT06 - Processar avisos automaticos"
@ 15,015 SAY "Email: "
@ 15,065 GET cEmailS SIZE 150,10 //WHEN EMPTY(cEmailS)
@ 30,065 SAY "(campo email acima em branco = enviar a todos)"

@ 45,015 SAY "Relatório:"     SIZE 080,008 Pixel Of oDlg1
@ 45,065 MSCOMBOBOX oComboBo1 VAR cRel ITEMS aRel SIZE 150, 008 OF oDlg1 COLORS 0, 16777215 PIXEL

@ 60,015 SAY "Contrato:" SIZE 080,008 Pixel Of oDlg1
@ 60,065 GET cContrRep SIZE  40,10 F3 "CN9" WHEN WhenRepB(cRel)
@ 75,065 SAY "(campo contrato branco = enviar com filtro, contrato = 'T' = Todos)"

@ 85,015 SAY "Período:" SIZE 080,008 Pixel Of oDlg1
@ 85,065 GET dtIni Picture "@E" Size 040,008 Pixel WHEN WhenRepB(cRel) .AND. UPPER(SUBSTR(cContrRep,1,1)) = "T" Of oDlg1
@ 85,110 SAY "até" SIZE 10,008 Pixel Of oDlg1
@ 85,120 GET dtFim Picture "@E" Size 040,008 Pixel WHEN WhenRepB(cRel) .AND. UPPER(SUBSTR(cContrRep,1,1)) = "T" Of oDlg1

//VALID if( ExistCpo("JAH", cCurOri), cDesOri := Posicione("JAH",1,xFilial("JAH")+cCurOri,"JAH_DESC"), .F. )

@ 102,065 BMPBUTTON TYPE 01 ACTION ProcAvi(cRel)
@ 102,115 BMPBUTTON TYPE 02 ACTION Close(oDlg1)
ACTIVATE DIALOG oDlg1 CENTER

RETURN

Static Function WhenRepB(cRel)
Local lRet := .F.
IF VALTYPE(cRel) == "N"
   IF cRel = 4
      lRet := .T.
   ENDIF   
ELSE
   IF SUBSTR(cRel,1,2) = "04"
      lRet := .T.
   ENDIF   
ENDIF
//IF !lRet
//   cContrRep := ""
//   dtIni     := CTOD("")
//   dtFim     := CTOD("")
//ENDIF                            
Return lRet



Static FUNCTION ProcAvi(cRel)

ConOut("BKGCT06: processando avisos automaticos. (Dialogo) ")   
IF VALTYPE(cRel) == "N"
   cRel := "1"
ENDIF                            
IF SUBSTR(cRel,1,2) = "01"
   Processa( {|| RepBKGct06() } )
ELSEIF SUBSTR(cRel,1,2) = "02"   
   Processa( {|| VigBKGct06() } )
ELSEIF SUBSTR(cRel,1,2) = "03"   
   Processa( {|| Vg2BKGct06() } )
ELSEIF SUBSTR(cRel,1,2) = "04"   
   Processa( {|| RepBK06b() } )
ELSEIF SUBSTR(cRel,1,2) = "05"   
   Processa( {|| V5BKGct06() } )
ELSEIF SUBSTR(cRel,1,2) = "06"   
   Processa( {|| V6BKGct06() } )
ELSEIF SUBSTR(cRel,1,2) = "07"   
   Processa( {|| V7BKGct06() } )
ELSEIF SUBSTR(cRel,1,2) = "08"   
   Processa( {|| V8BKGct06() } )
ELSEIF SUBSTR(cRel,1,2) = "09"   
   Processa( {|| V9BKGct06() } )
ELSEIF SUBSTR(cRel,1,2) = "10"   
   Processa( {|| V10BKGct06() } )
ELSEIF SUBSTR(cRel,1,2) = "11"   
   Processa( {|| V11BKGct06() } )    
ELSEIF SUBSTR(cRel,1,2) = "12"   
   Processa( {|| V12BKGct06() } )    
ELSEIF SUBSTR(cRel,1,2) = "13"   
   Processa( {|| U_BKGCTR23() } )
ELSEIF SUBSTR(cRel,1,2) = "14"   
   Processa( {|| U_GRFBKGCT11(.T.) } )
ENDIF 

Close(oDlg1)
Return


Static FUNCTION P1BKGCT06()
// Emails para o aviso de Repactuação de Contatos - MODELO 1
Local aEmail :={"sigarepac1@bkconsultoria.com.br",;
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
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				""}

cEmailTo := "" 

For nI := 1 TO LEN(aEmail)
	cEmailTO += IIF(!EMPTY(aEmail[nI]),ALLTRIM(aEmail[nI])+";","")
Next

cEmailCC := "microsiga@bkconsultoria.com.br;"

// Email quando a rotina é chamada pela tela
IF !EMPTY(cEmailS)
   cEmailTO := ALLTRIM(cEmailS)+";"
ENDIF

RETURN



Static FUNCTION P2BKGCT06()
// Emails para aviso de Vigencia de Contatos - MODELO 1
Local aEmail :={"sigavigencia1@bkconsultoria.com.br",;
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
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				""}
Local nI

cEmailTo := "" 

For nI := 1 TO LEN(aEmail)
	cEmailTO += IIF(!EMPTY(aEmail[nI]),ALLTRIM(aEmail[nI])+";","")
Next

cEmailCC := "microsiga@bkconsultoria.com.br;"

// Email quando a rotina é chamada pela tela
IF !EMPTY(cEmailS)
   cEmailTO := ALLTRIM(cEmailS)+";"
ENDIF

RETURN


Static FUNCTION P3BKGCT06()
// Emails para aviso de Vigencia de Contatos - MODELO 2
Local aEmail :={"sigavigencia2@bkconsultoria.com.br",;
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
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				""}

Local nI

cEmailTo := "" 

SELECT SX6
For nI := 1 TO LEN(aEmail)
	cEmailTO += IIF(!EMPTY(aEmail[nI]),ALLTRIM(aEmail[nI])+";","")
Next

cEmailCC := "microsiga@bkconsultoria.com.br;"

// Para testes
//cEmailTO := cEmailCC

// Email quando a rotina é chamada pela tela
IF !EMPTY(cEmailS)
   cEmailTO := ALLTRIM(cEmailS)+";"
ENDIF

RETURN



Static FUNCTION P4BKGCT06()
// Emails para aviso de Repactuação de Contatos - MODELO 2
Local aEmail :={"sigarepac2@bkconsultoria.com.br",;
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
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				""}

Local nI

cEmailTo := "" 

For nI := 1 TO LEN(aEmail)
	cEmailTO += IIF(!EMPTY(aEmail[nI]),ALLTRIM(aEmail[nI])+";","")
Next

cEmailCC := "microsiga@bkconsultoria.com.br;"

// Para testes
//cEmailTO := cEmailCC

// Email quando a rotina é chamada pela tela
IF !EMPTY(cEmailS)
   cEmailTO := ALLTRIM(cEmailS)+";"
ENDIF
RETURN



Static FUNCTION P5BKGCT06()
// Emails para aviso Insumos Operacionais - MODELO 1
Local aEmail :={"sigaisop1@bkconsultoria.com.br",;
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
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				""}

Local nI

cEmailTo := "" 

SELECT SX6
For nI := 1 TO LEN(aEmail)
	cEmailTO += IIF(!EMPTY(aEmail[nI]),ALLTRIM(aEmail[nI])+";","")
Next

cEmailCC := "microsiga@bkconsultoria.com.br;"

// Para testes
//cEmailTO := cEmailCC

// Email quando a rotina é chamada pela tela
IF !EMPTY(cEmailS)
   cEmailTO := ALLTRIM(cEmailS)+";"
ENDIF

RETURN



Static Function RepBKGct06()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contratos a Repactuar
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cPath     := "\tmp\"
Local nHandle
Local cCrLf     := Chr(13) + Chr(10)
Local _ni
Local cPicN     := "@E 99999999.99999"
Local cDirTmp,_cArqS,_cArqSv
Local lOk       := .F.

Local cQuery
Local lEnv
Local _cAlias := "QCN9"

Local cMsg    := ""
Local lCorNao := .T.

Local nDias   := 0
Local nDiasVig:= 0
//Local aStatus := {"Atrasado","Em Processo - Gestão","Aguardando retorno do cliente","Em Analise - Gestão","Finalizado"}
Local aStatus := {"1-Atrasado",;                        // Status 1
                  "2-Em análise "+TRIM(SM0->M0_NOME),;  //        2 
                  "3-Aguardando retorno do cliente",;   //        3
                  "4-Em analise cliente",;              //        4
                  "5-Pedido enviado",;                  //        5
                  "6-Finalizado",;                      //        6
                  "7-Aguardando decisão diretoria",;    //        7
                  "8-Contrato encerrado",;              //        8
                  "9-Em analise gestão"}                //        9

Local dDVig
Local lEmail := .F.

Private cEmailTO := ""
Private cEmailCC := ""

Public cAviso  := ""
Public cStatus := ""

aCabs   := {}
aCampos := {}
 
AADD(aCampos,"QCN9->CN9_NUMERO")
AADD(aCabs  ,"Contrato")

AADD(aCampos,"QCN9->CN9_REVISA")
AADD(aCabs  ,"Revisao")

AADD(aCampos,"QCN9->CTT_DESC01")
AADD(aCabs  ,"Descrição")

AADD(aCampos,"QCN9->CN9_XXDVIG")
AADD(aCabs  ,"Vigencia")

AADD(aCampos,"cAviso")
AADD(aCabs  ,"Aviso")

AADD(aCampos,"QCN9->CN9_XXDREP")
AADD(aCabs  ,"Repactuação")

AADD(aCampos,"QCN9->CN9_XXOREP")
AADD(aCabs  ,"Obs Repactuação")

AADD(aCampos,"cStatus")
AADD(aCabs  ,"Status")

If !lJobV2
	IncProc()
EndIf

cQuery := " SELECT CN9_NUMERO,CN9_REVISA,CN9_SITUAC,CTT_DESC01,CN9_XXDREP,CN9_XXOREP,CN9_XXSREP,CN9_XXDVIG,CN9_XXDAVI,CN9_XXNAVI,CN9.R_E_C_N_O_ AS XXRECNO "
cQuery += " FROM "+RETSQLNAME("CN9")+" CN9"

cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CN9_NUMERO"
cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"
cQuery += " WHERE CN9_SITUAC IN ('02','05') AND CN9_FILIAL = '"+xFilial("CN9")+"' AND CN9.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY CN9_NUMERO,CN9_REVISA"  

TCQUERY cQuery NEW ALIAS "QCN9"
TCSETFIELD("QCN9","CN9_XXDREP","D",8,0)
TCSETFIELD("QCN9","CN9_XXDVIG","D",8,0)
TCSETFIELD("QCN9","CN9_XXDAVI","D",8,0)

// Cabeçalho do Email
aHtm := CabHtml("Contratos a Repactuar")   
FOR _ni := 1 TO LEN(aHtm)
   cMsg += aHtm[_ni]
NEXT

aHtm := CabR()   
FOR _ni := 1 TO LEN(aHtm)
   cMsg += aHtm[_ni]
NEXT


//------------------

cArqS := "BKGCT06_"+ALLTRIM(SM0->M0_NOME)

_cArqSv  := cPath+cArqS+".csv"

IF lJobV2
	cDirTmp   := ""
	_cArqS    := cPath+cArqS+".csv"
ELSE
	cDirTmp   := "C:\TMP"
	_cArqS    := cDirTmp+"\"+cArqS+".csv"
ENDIF

IF !EMPTY(cDirTmp)
   MakeDir(cDirTmp)
ENDIF   
 
fErase(_cArqS)

nHandle := MsfCreate(_cArqS,0)
   
If nHandle > 0
      
   FOR _ni := 1 TO LEN(aCabs)
       fWrite(nHandle, aCabs[_ni] + IIF(_ni < LEN(aCabs),";",""))
   NEXT
   fWrite(nHandle, cCrLf ) // Pula linha

   (_cAlias)->(dbgotop())
   
   Do while (_cAlias)->(!eof())


		If !lJobV2
			IncProc("Gerando arquivo "+_cArqS)   
		EndIf
		
		lEnv   := .F.
		cAviso := ""
		cStatus:= ""
		nDias  := 0 

        
		If QCN9->CN9_XXSREP > 0 .AND. QCN9->CN9_XXSREP <= LEN(aStatus) 
          cStatus := aStatus[QCN9->CN9_XXSREP]
        EndIf

		If EMPTY(QCN9->CN9_XXDREP)
		    cAviso:= "Data de repactuação nao definida"
			lEnv := .T.
		Else
			nDias  := QCN9->CN9_XXDREP - DATE()
			
			// Enviar sempre email 30 dias antes independente do status
			If nDias = 30
				lEnv := .T.
			EndIf

			// Enviar sempre email 27 dias antes independente do status
			If nDias = 27
				lEnv := .T.
			EndIf

			// Enviar sempre email 10 dias antes independente do status
			If nDias = 10
				lEnv := .T.
			EndIf
			
			// Enviar sempre quando faltar menos de 10 dias (e após) quando o status for = 1
            If nDias < 10 .AND. QCN9->CN9_XXSREP = 1
               lEnv := .T.
            EndIf
            

			// Enviar quando a data de repactuação for diferente da data de controle
            If !lEnv .AND. QCN9->CN9_XXDREP <> QCN9->CN9_XXDAVI
               If nDias <= 30 .AND. nDias > 0
                  lEnv := .T.
               EndIf
            EndIf

			If nDias < 0 .AND. QCN9->CN9_XXSREP <> 1
				If MOD(ABS(nDias),10) = 0
					lEnv := .T.
				EndIf
            EndIf
            
            If lEnv
		    	cAviso:= "Repactuação em "+ALLTRIM(STR(nDias,4))+" dias"
            EndIf

            If QCN9->CN9_XXSREP = 5
            	lEnv := .T.
		    	cAviso:= "Redefinir a data da Repactuação"
            EndIf
		EndIf

		dbSelectArea("CN9")   
		dbGoto(QCN9->XXRECNO)
		
		If lEnv
	   		lEmail := .T.
			RecLock("CN9",.F.)
			IF CN9->CN9_XXDREP <> CN9->CN9_XXDAVI
			   CN9->CN9_XXDAVI := CN9->CN9_XXDREP
			   CN9->CN9_XXNAVI := 1
			   CN9->CN9_XXSREP := 1
	           cStatus := aStatus[1]
			ELSE
			   IF CN9->CN9_XXNAVI < 99
			      CN9->CN9_XXNAVI := CN9->CN9_XXNAVI + 1
			   ENDIF
			ENDIF   
			MsUnlock()
	    EndIf


		dDVIG   := CN9->CN9_XXDVIG
		
		/*
		//IF EMPTY(dDVIG)
		   // Buscar o ultimo vencto dos Cronogramas
		   dbSelectArea("CNF")
		   dbSetOrder(3)
		   cContRev := xFilial("CNF")+CN9->CN9_NUMERO+CN9->CN9_REVISA
		   dbSeek(xFilial("CNF")+CN9->CN9_NUMERO+CN9->CN9_REVISA,.T.)
		   Do While !EOF() .AND. cContRev == CNF_FILIAL+CNF_CONTRA+CNF_REVISA
		      IF dDVIG < CNF->CNF_DTVENC
		         dDVIG := CNF->CNF_DTVENC
		      ENDIF
		      dbSkip()
		   EndDo
		   dbSelectArea("CN9")
			IF CN9->CN9_XXDVIG <> dDVIG
				RecLock("CN9",.F.)
				CN9->CN9_XXDVIG := dDVIG
				MsUnlock()
			ENDIF   
		//ENDIF
		*/
		
		nDiasVig  := CN9->CN9_XXDVIG - DATE()

		If nDiasVig = 30 .OR.;
			nDiasVig = 45 .OR.;
			nDiasVig = 60 .OR.;
			nDiasVig = 90 .OR.;
			nDiasVig = 120
			lEnv := .T.
	    	cAviso+= IIF(!EMPTY(cAviso)," - ","")+"Vigencia com termino em "+ALLTRIM(STR(nDiasVig,4))+" dias"
		EndIf

	    
		If lEnv

		 dbSelectArea(_cAlias)   
	
         If lCorNao   
            cMsg += '<tr>'
         Else   
            cMsg += '<tr bgcolor="#dfdfdf">'
         EndIf   
         lCorNao := !lCorNao
       
         cMsg += '<td width="10%" class="F10A">'+TRIM(QCN9->CN9_NUMERO)+'</td>'
         cMsg += '<td width="5%"  class="F10A">'+TRIM(QCN9->CN9_REVISA)+'</td>'
         cMsg += '<td width="30%" class="F10A">'+TRIM(QCN9->CTT_DESC01)+'</td>'
         cMsg += '<td width="20%" class="F10A">'+TRIM(cAviso)+'</td>'
         cMsg += '<td width="10%" class="F10A">'+DTOC(QCN9->CN9_XXDREP)+'</td>'
         cMsg += '<td width="15%" class="F10A">'+TRIM(QCN9->CN9_XXOREP)+'</td>'
         If SUBSTR(cStatus,1,1) == '1'
            cMsg += '<td width="10%" class="F10A"><font color="red"><b>'+TRIM(cStatus)+'</b></font></td>'
         Else   
            cMsg += '<td width="10%" class="F10A"><b>'+TRIM(cStatus)+'</b></td>'
         EndIf   
         cMsg += '</tr>'

	      
	      For _ni :=1 to LEN(aCampos)
	
	         xCampo := &(aCampos[_ni])
	            
	         _uValor := ""
	            
	         if VALTYPE(xCampo) == "D" // Trata campos data
	            _uValor := dtoc(xCampo)
	         elseif VALTYPE(xCampo) == "N" // Trata campos numericos
	            _uValor := transform(xCampo,cPicN)
	         elseif VALTYPE(xCampo) == "C" // Trata campos caracter
	            _uValor := '="'+ALLTRIM(xCampo)+'"'
	         endif
	            
	         fWrite(nHandle, _uValor + IIF(_ni < LEN(aCampos),";",""))
	            
	      Next _ni
	         
	      fWrite(nHandle, cCrLf )
	      
		EndIf
			         
		(_cAlias)->(dbskip())
         
	EndDo
      
	fClose(nHandle)

    
	If lJobV2
		ConOut(cPrw+": Exito ao criar "+_cArqs )
	Else   
		lOk := CpyT2S( _cArqs , cPath, .T. )
	EndIf

Else
	If lJobV2
		ConOut("Falha na criação do arquivo "+_cArqS)
	Else	
        MsgAlert("Falha na criação do arquivo "+_cArqS)
    Endif    
Endif
   
QCN9->(Dbclosearea())

// Cabeçalho do Email
aHtm := FimHtml("BKGCT06")   
FOR _ni := 1 TO LEN(aHtm)
   cMsg += aHtm[_ni]
NEXT
//------------------

cAssunto := "Aviso de repactuação - "+SM0->M0_NOME

If lEmail

	// Carrega as variaveis cEmailTO e cEmailCC
	P1BKGCT06()
	
	// Envia o Email
	U_SENDMAIL("BKGCT06",cAssunto,cEmailTO,cEmailCC,cMsg,_cArqSv,lJobV2)
	
EndIf

Return Nil


//=================================================================================

Static Function VigBKGct06()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//  "Aviso de termino de vigência de contratos"
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cPath     := "\tmp\"
Local nHandle
Local cCrLf     := Chr(13) + Chr(10)
Local _ni
Local cPicN     := "@E 99999999.99999"
Local cDirTmp,_cArqS,_cArqSv
Local lOk       := .F.
Local cQuery
Local _cAlias := "QCN9"
Local cMsg    := ""
Local cTxt    := ""
Local lCorNao := .T.
Local nPrxMes1,nPrxMes2,nPrxMes3,nPrxMes4
Local nPrxAno1,nPrxAno2,nPrxAno3,nPrxAno4

Local nDiasVig:= 0
Local lEmail  := .F.

Private cEmailTO := ""
Private cEmailCC := ""

Public cVigencia := ""

aCabs   := {}
aCampos := {}
    
aFHtm := { {}, {}, {}, {}, {} }
aFTxt := { {}, {}, {}, {}, {} }
aCabH := {"mês atual","próximo mês","60 dias","90 dias","até 45 dias (RH)"}

// ALERTA automático DE VENCIMENTO DE CONTRATO ( MÊS VIGENTE )
// ALERTA automático DE VENCIMENTO DE CONTRATO ( PRÓXIMO MÊS )
// ALERTA automático DE VENCIMENTO DE CONTRATO ( 45 DIAS - Controle Depto RH )
// ALERTA automático DE VENCIMENTO DE CONTRATO ( 60 DIAS )
// ALERTA automático DE VENCIMENTO DE CONTRATO ( 90 DIAS )

 
// Cliente
// Contrato
// Objeto
// Valor
// Vigencia

 
AADD(aCampos,"QCN9->A1_NREDUZ")
AADD(aCabs  ,"Cliente")

AADD(aCampos,"QCN9->CTT_DESC01")
AADD(aCabs  ,"Contrato")

AADD(aCampos,"U_CN9OBJ(QCN9->CN9_CODOBJ)")
AADD(aCabs  ,"Objeto")

AADD(aCampos,"QCN9->CN9_VLATU")
AADD(aCabs  ,"Valor")

AADD(aCampos,"cVigencia")
AADD(aCabs  ,"Vigencia")


If !lJobV2
	IncProc()
EndIf

cQuery := " SELECT CN9_NUMERO,CN9_REVISA,CN9_DTINIC,CN9_SITUAC,CTT_DESC01,CN9_CLIENT,CN9_LOJACL,A1_NREDUZ,CN9_CODOBJ,CN9_VLATU,CN9.R_E_C_N_O_ AS XXRECNO "
cQuery += " FROM "+RETSQLNAME("CN9")+" CN9"

cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CN9_NUMERO"
cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON A1_COD = CN9_CLIENT AND A1_LOJA = CN9_LOJACL"
cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '"

cQuery += " WHERE CN9_SITUAC IN ('02','05') AND CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY A1_NREDUZ,CTT_DESC01"  

TCQUERY cQuery NEW ALIAS "QCN9"
TCSETFIELD("QCN9","CN9_DTINIC","D",8,0)


(_cAlias)->(dbgotop())
   
Do While (_cAlias)->(!eof())

	// Buscar o periodo de vigencia dos contratos
	dVigI   := QCN9->CN9_DTINIC
	dVigF   := QCN9->CN9_DTINIC

	dbSelectArea("CNF")
	dbSetOrder(3)
	cContRev := xFilial("CNF")+QCN9->CN9_NUMERO+QCN9->CN9_REVISA
	dbSeek(xFilial("CNF")+QCN9->CN9_NUMERO+QCN9->CN9_REVISA,.T.)
	
 	Do While !EOF() .AND. cContRev == CNF->CNF_FILIAL+CNF->CNF_CONTRA+CNF->CNF_REVISA
	   If dVigF < CNF->CNF_DTVENC .OR. EMPTY(dVigF)
	      dVigF:= CNF->CNF_DTVENC
	   EndIf

	   dbSkip()
	EndDo
		
	nDiasVig  := dVigF - DATE()

    nEnv:= 0
    
    nPrxAno1 := YEAR(DATE())
    nPrxMes1 := MONTH(DATE()) + 1
    If nPrxMes1 = 13
    	nPrxAno1++
    	nPrxMes1 := 1
    EndIf
    
    nPrxAno2 := nPrxAno1
    nPrxMes2 := nPrxMes1 + 1
    If nPrxMes2 = 13
    	nPrxAno2++
    	nPrxMes2 := 1
    EndIf

    nPrxAno3 := nPrxAno2
    nPrxMes3 := nPrxMes2 + 1
    If nPrxMes3 = 13
    	nPrxAno3++
    	nPrxMes3 := 1
    EndIf
    
    nPrxAno4 := nPrxAno3
    nPrxMes4 := nPrxMes3 + 1
    If nPrxMes4 = 13
    	nPrxAno4++
    	nPrxMes4 := 1
    EndIf

	IF MONTH(dVigF) = MONTH(DATE()) .AND. YEAR(dVigF) = YEAR(DATE()) 
		nEnv := 1
    ELSEIF MONTH(dVigF) = nPrxMes1 .AND. YEAR(dVigF) = nPrxAno1
    	nEnv := 2 
    ELSEIF MONTH(dVigF) = nPrxMes2 .AND. YEAR(dVigF) = nPrxAno2
    	nEnv := 3
    ELSEIF MONTH(dVigF) = nPrxMes3 .AND. YEAR(dVigF) = nPrxAno3
    	nEnv := 4
    ENDIF        
    
    lEnvRH := .F.
    IF nDiasVig >=0 .AND. nDiasVig <= 45
    	lEnvRH := .T.
    ENDIF	
    
// ALERTA automático DE VENCIMENTO DE CONTRATO ( 45 DIAS - Controle Depto RH )
// ALERTA automático DE VENCIMENTO DE CONTRATO ( 60 DIAS )
// ALERTA automático DE VENCIMENTO DE CONTRATO ( 90 DIAS )
       
	If nEnv > 0 .OR. lEnvRH
	
         lEmail := .T.

         cVigencia := "De: "+DTOC(dVigI)+" Até: "+DTOC(dVigF)
         
         cMsg := ""
       
         cMsg += '<td width="15%" class="F10A">'+TRIM(QCN9->A1_NREDUZ)+'</td>'
         cMsg += '<td width="23%" class="F10A">'+TRIM(QCN9->CTT_DESC01)+'</td>'
         cMsg += '<td width="40%" class="F10A">'+TRIM(U_CN9OBJ(QCN9->CN9_CODOBJ))+'</td>'
         cMsg += '<td width="15%" class="F10A" align="right">'+TRANSFORM(QCN9->CN9_VLATU,"@E 999,999,999.99")+'&nbsp;&nbsp;</td>'
         cMsg += '<td width="7%" class="F10A" nowrap>'+TRIM(cVigencia)+'</td>'
         cMsg += '</tr>'
	     
	     cTxt := "" 
	      For _ni :=1 to LEN(aCampos)
	
	         xCampo := &(aCampos[_ni])
	            
	         _uValor := ""
	            
	         if VALTYPE(xCampo) == "D" // Trata campos data
	            _uValor := dtoc(xCampo)
	         elseif VALTYPE(xCampo) == "N" // Trata campos numericos
	            _uValor := transform(xCampo,cPicN)
	         elseif VALTYPE(xCampo) == "C" // Trata campos caracter
	            _uValor := '="'+ALLTRIM(xCampo)+'"'
	         endif
	            
	         cTxt += _uValor + IIF(_ni < LEN(aCampos),";","")
	            
	      Next _ni
	         
		If nEnv < 5 .AND. nEnv > 0
	        AADD(aFHtm[nEnv],cMsg)
	        AADD(aFTxt[nEnv],cTxt)
	    EndIf
		If lEnvRH
	        AADD(aFHtm[5],cMsg)
	        AADD(aFTxt[5],cTxt)
		EndIf      
	EndIf
    
	(_cAlias)->(dbskip())

EndDo


//---------------------------

cArqS := "BKGCT06V_"+ALLTRIM(SM0->M0_NOME)

_cArqSv  := cPath+cArqS+".csv"

IF lJobV2
	cDirTmp   := ""
	_cArqS    := cPath+cArqS+".csv"
ELSE
	cDirTmp   := "C:\TMP"
	_cArqS    := cDirTmp+"\"+cArqS+".csv"
ENDIF

IF !EMPTY(cDirTmp)
   MakeDir(cDirTmp)
ENDIF   
 
fErase(_cArqS)

nHandle := MsfCreate(_cArqS,0)

cMsg:= ""
cTxt:= ""
For _nj := 1 to 5
	// Cabeçalho do Email
	aHtm := CabHtml("Alerta de vencimento de contratos - "+aCabH[_nj])   
	FOR _ni := 1 TO LEN(aHtm)
	   cMsg += aHtm[_ni]
	NEXT
	
	aHtm := CabV()
	FOR _ni := 1 TO LEN(aHtm)
	   cMsg += aHtm[_ni]
	NEXT

	FOR _ni := 1 to LEN(aFHtm[_nj])
         If lCorNao   
            cMsg += '<tr>'
         Else   
            cMsg += '<tr bgcolor="#dfdfdf">'
         EndIf   
         lCorNao := !lCorNao
		cMsg += aFHtm[_nj,_ni]
	NEXT

	// Rodapé do Email
	aHtm := FimHtml("BKGCT06")   
	FOR _ni := 1 TO LEN(aHtm)
	   cMsg += aHtm[_ni]
	NEXT

	If nHandle > 0
	      
       fWrite(nHandle, "Alerta de vencimento de contratos - "+aCabH[_nj]+cCrLf)
	   FOR _ni := 1 TO LEN(aCabs)
	       fWrite(nHandle, aCabs[_ni] + IIF(_ni < LEN(aCabs),";",""))
	   NEXT
	   fWrite(nHandle, cCrLf ) // Pula linha

		FOR _ni := 1 to LEN(aFHtm[_nj])
	         fWrite(nHandle, aFTxt[_nj,_ni]+cCrLf)
		NEXT
		
    EndIf
		
Next

	
//------------------
    
If nHandle > 0
	fClose(nHandle)
	If lJobV2
		ConOut(cPrw+": Exito ao criar "+_cArqs )
	Else   
		lOk := CpyT2S( _cArqs , cPath, .T. )
	EndIf

Else
	fClose(nHandle)
	If lJobV2
		ConOut("Falha na criação do arquivo "+_cArqS)
	Else	
        MsgAlert("Falha na criação do arquivo "+_cArqS)
    Endif    
Endif
   
QCN9->(Dbclosearea())


//------------------

cAssunto := "Aviso de termino de vigência de contratos - "+SM0->M0_NOME

If lEmail

	// Carrega as variaveis cEmailTO e cEmailCC
	P2BKGCT06()     
	
	// Envia o email
	If U_SENDMAIL("BKGCT06",cAssunto,cEmailTO,cEmailCC,cMsg,_cArqSv,lJobV2)
		dbSelectArea("SX6")
		If DBSEEK("  MV_XXBKENV",.F.)
	   		RecLock("SX6",.F.)
			SX6->X6_CONTEUD := DTOS(dDataEnv)
	   		MsUnlock()
	    EndIf
	Else
		dbSelectArea("SX6")
		If DBSEEK("  MV_XXBKENV",.F.)
	   		RecLock("SX6",.F.)
			SX6->X6_CONTEUD := ""
	   		MsUnlock()
	    EndIf
	EndIf
EndIf
	
Return Nil


// Alerta de Termino de vigencia, pela data informada pelos gestores - solicitado pelo Bruno Santiago em 20/05/11

Static Function Vg2BKGct06()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//  "Alerta de término de vigencia de contratos"
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cPath     := "\tmp\"
Local nHandle
Local cCrLf     := Chr(13) + Chr(10)
Local _ni
Local cPicN     := "@E 99999999.99999"
Local cDirTmp,_cArqS,_cArqSv
Local lOk       := .F.

Local cQuery
Local lEnvV2
Local _cAlias := "QCN9"

Local cMsg    := ""
Local cTxt    := ""
Local lCorNao := .T.

Local cResp   := ""
Local lFirst  := .T.

Private cEmailTO := ""
Private cEmailCC := ""

Public cVigencia := ""
Public nDiasVig  := 0

aCabs   := {}
aCampos := {}
    
aFHtm   := {}
aFTxt   := {}
aCabH   := ""


 
AADD(aCampos,"QCN9->A1_NOME")
AADD(aCabs  ,"Cliente")

AADD(aCampos,"QCN9->CN9_NUMERO")
AADD(aCabs  ,"Contrato")

AADD(aCampos,"QCN9->CN9_REVISA")
AADD(aCabs  ,"Revisao")

AADD(aCampos,"QCN9->CTT_DESC01")
AADD(aCabs  ,"Descr. CC")

AADD(aCampos,"QCN9->CN9_XXNRBK")
AADD(aCabs  ,"Responsavel")

AADD(aCampos,"cVigencia")
AADD(aCabs  ,"Vigencia")

AADD(aCampos,"nDiasVig")
AADD(aCabs  ,"Dias")

AADD(aCampos,"QCN9->CN9_XXPROA")
AADD(aCabs  ,"Andamento")

If !lJobV2
	IncProc()
EndIf

cQuery := " SELECT CN9_NUMERO,CN9_REVISA,CN9_DTINIC,CN9_SITUAC,CTT_DESC01,CN9_XXNRBK,CN9_XXDVIG,CN9_XXPROA,"
cQuery += " CN9_CLIENT,CN9_LOJACL,A1_NOME,CN9_CODOBJ,CN9_VLATU,CN9.R_E_C_N_O_ AS XXRECNO "
cQuery += " FROM "+RETSQLNAME("CN9")+" CN9"

cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CN9_NUMERO"
cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON A1_COD = CN9_CLIENT AND A1_LOJA = CN9_LOJACL"
cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '"

cQuery += " WHERE CN9_SITUAC IN ('05') AND CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY CN9_XXNRBK,A1_NOME"  

TCQUERY cQuery NEW ALIAS "QCN9"
TCSETFIELD("QCN9","CN9_DTINIC","D",8,0)
TCSETFIELD("QCN9","CN9_XXDVIG","D",8,0)

(_cAlias)->(dbgotop())

cResp  := ALLTRIM(QCN9->CN9_XXNRBK)
lFirst := .T.
   
Do While (_cAlias)->(!eof())
	
	// Data de vigencia dos contratos, digitada pelos gestores
	
	dVigF   := QCN9->CN9_XXDVIG
		
	nDiasVig  := dVigF - DATE()
    
    lEnvV2 := .F.
    IF nDiasVig <= 100
       lEnvV2 := .T.
	ENDIF    
      
	If lEnvV2

         cMsg := ""

          // Quebra por responsavel do contrato
          IF cResp <> ALLTRIM(QCN9->CN9_XXNRBK) .AND. !lFirst
             cMsg += '</table>'
             cMsg += '<br>'
             aHtm := CabV2()
             FOR _ni := 1 TO LEN(aHtm)
                 cMsg += aHtm[_ni]
             NEXT
             cResp   := QCN9->CN9_XXNRBK
             lCorNao := .T.   
          ENDIF   

         lFirst  := .F.

         cVigencia := DTOC(dVigF)
         
         If lCorNao   
            cMsg += '<tr>'
         Else   
            cMsg += '<tr bgcolor="#dfdfdf">'
         EndIf   
       
         cMsg += '<td width="30%" class="F10A">'+TRIM(QCN9->A1_NOME)+'</td>'
         cMsg += '<td width="10%" class="F10A">'+TRIM(QCN9->CN9_NUMERO)+'</td>'
         cMsg += '<td width="05%" class="F10A">'+TRIM(QCN9->CN9_REVISA)+'</td>'
         cMsg += '<td width="30%" class="F10A">'+TRIM(QCN9->CTT_DESC01)+'</td>'
         cMsg += '<td width="15%" class="F10A">'+TRIM(QCN9->CN9_XXNRBK)+'</td>'
         cMsg += '<td width="05%" class="F10A" nowrap>'+TRIM(cVigencia)+'</td>'
         cMsg += '<td width="05%" class="F10A" align="right">'+STR(nDiasVig,4)+'&nbsp;&nbsp;</td>'
         cMsg += '</tr>'

         If !EMPTY(QCN9->CN9_XXPROA)
            If lCorNao   
               cMsg += '<tr>'
            Else   
               cMsg += '<tr bgcolor="#dfdfdf">'
            EndIf   
            cMsg += '<td width="30%" class="F10A"> </td>'
            cMsg += '<td width="10%" class="F10A"> </td>'
            cMsg += '<td width="5%" class="F10A"> </td>'
            cMsg += '<td colspan="4" class="F10A"> <font color="blue">'+ALLTRIM(QCN9->CN9_XXPROA)+'</font></td>'
            cMsg += '</tr>'
         EndIf
            
         lCorNao := !lCorNao
	     
	     
	     
	     cTxt := "" 
	      For _ni :=1 to LEN(aCampos)
	
	         xCampo := &(aCampos[_ni])
	            
	         _uValor := ""
	            
	         if VALTYPE(xCampo) == "D" // Trata campos data
	            _uValor := dtoc(xCampo)
	         elseif VALTYPE(xCampo) == "N" // Trata campos numericos
	            _uValor := transform(xCampo,cPicN)
	         elseif VALTYPE(xCampo) == "C" // Trata campos caracter
	            _uValor := '="'+ALLTRIM(xCampo)+'"'
	         endif
	            
	         cTxt += _uValor + IIF(_ni < LEN(aCampos),";","")
	            
	      Next _ni
	         
        AADD(aFHtm,cMsg)
        AADD(aFTxt,cTxt)

	EndIf
    
	(_cAlias)->(dbskip())


EndDo


//---------------------------

cArqS := "BKGCT6V2_"+ALLTRIM(SM0->M0_NOME)

_cArqSv  := cPath+cArqS+".csv"

IF lJobV2
	cDirTmp   := ""
	_cArqS    := cPath+cArqS+".csv"
ELSE
	cDirTmp   := "C:\TMP"
	_cArqS    := cDirTmp+"\"+cArqS+".csv"
ENDIF

IF !EMPTY(cDirTmp)
   MakeDir(cDirTmp)
ENDIF   
 
fErase(_cArqS)

nHandle := MsfCreate(_cArqS,0)

cMsg:= ""
cTxt:= ""

// Cabeçalho do Email
aHtm := CabHtml("Alerta de término de vigencia de contratos")   
FOR _ni := 1 TO LEN(aHtm)
   cMsg += aHtm[_ni]
NEXT
	
aHtm := CabV2()
FOR _ni := 1 TO LEN(aHtm)
   cMsg += aHtm[_ni]
NEXT

FOR _ni := 1 to LEN(aFHtm)
//    If lCorNao   
//       cMsg += '<tr>'
//    Else   
//       cMsg += '<tr bgcolor="#dfdfdf">'
//    EndIf   
//    lCorNao := !lCorNao
    cMsg += aFHtm[_ni]
NEXT

// Rodapé do Email
aHtm := FimHtml("BKGCT06")   
FOR _ni := 1 TO LEN(aHtm)
   cMsg += aHtm[_ni]
NEXT

If nHandle > 0
	      
   fWrite(nHandle, "Alerta de término de vigencia de contratos"+cCrLf)
   FOR _ni := 1 TO LEN(aCabs)
       fWrite(nHandle, aCabs[_ni] + IIF(_ni < LEN(aCabs),";",""))
   NEXT
   fWrite(nHandle, cCrLf ) // Pula linha

	FOR _ni := 1 to LEN(aFHtm)
         fWrite(nHandle, aFTxt[_ni]+cCrLf)
	NEXT
		
EndIf
		
	
//------------------
    
If nHandle > 0
	fClose(nHandle)
	If lJobV2
		ConOut(cPrw+": Exito ao criar "+_cArqs )
	Else   
		lOk := CpyT2S( _cArqs , cPath, .T. )
	EndIf

Else
	fClose(nHandle)
	If lJobV2
		ConOut("Falha na criação do arquivo "+_cArqS)
	Else	
        MsgAlert("Falha na criação do arquivo "+_cArqS)
    Endif    
Endif
   
QCN9->(Dbclosearea())


//------------------

cAssunto := "Alerta de término de vigencia de contratos - "+SM0->M0_NOME

//If !lJobV2
//   _cArqSv := ""
//EndIf
   
// -- Carrega as variaveis cEmailTO e cEmailCC
P3BKGCT06()

//msginfo(cEmailto)
//msginfo(cEmailcc)


If U_SENDMAIL("BKGCT06",cAssunto,cEmailTO,cEmailCC,cMsg,_cArqSv,lJobV2)
	dbSelectArea("SX6")
	If DBSEEK("  MV_XXBKENV",.F.)
   		RecLock("SX6",.F.)
		SX6->X6_CONTEUD := DTOS(dDataEnv)
   		MsUnlock()
    EndIf
Else
	dbSelectArea("SX6")
	If DBSEEK("  MV_XXBKENV",.F.)
   		RecLock("SX6",.F.)
		SX6->X6_CONTEUD := ""
   		MsUnlock()
    EndIf
EndIf

Return Nil




USER FUNCTION SendMail(cPrw,cAssunto,cPara,cCc,cMsg,cAnexo,_lJob)
Local lResulConn := .F.
Local lResulSend := .F.
Local cError     := ""
Local cServer    := AllTrim(GetMV("MV_RELSERV"))
Local cEmail     := AllTrim(GetMV("MV_RELACNT"))
Local cPass      := AllTrim(GetMV("MV_RELPSW"))
Local lRelauth   := GetMv("MV_RELAUTH")
Local cDe        := cEmail
Local nTent      := 0

Default _lJob    := .T.
Private lResult  := .T.

// Para testes
If "TST" $ UPPER(GetEnvServer()) .OR. "TESTE" $ UPPER(GetEnvServer())
	cPara := cCc := "microsiga@bkconsultoria.com.br"
	If _lJob
		ConOut(cPrw+": E-mail simulado em ambiente de teste BK: "+TRIM(cAssunto))
	Else
		//MsgAlert(cPrw+": E-mail simulado em ambiente de teste BK: "+TRIM(cAssunto)+"- Log: BKSENDMAIL.LOG")
	Endif
	u_xxLog("\TMP\BKSENDMAIL.LOG",cPrw+"- Assunto: "+cAssunto,.T.,"")
	u_xxLog("\TMP\BKSENDMAIL.LOG",cPrw+"- Para: "+cPara,.T.,"")
	u_xxLog("\TMP\BKSENDMAIL.LOG",cPrw+" - CC: "+cCC,.T.,"")
	u_xxLog("\TMP\BKSENDMAIL.LOG",cPrw+" - Msg: "+SUBSTR(cMsg,1,100),.T.,"")
	
	//Return .T.
EndIf
// Fim testes

CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPass RESULT lResulConn
If !lResulConn
	GET MAIL ERROR cError
	If _lJob
		ConOut(cPrw+": Falha na conexao: "+TRIM(cAssunto)+"-"+cError)
	Else
		MsgAlert(cPrw+": Falha na conexao "+TRIM(cAssunto)+"-"+cError)
	Endif
	
	Do While nTent < 10 .AND. _lJob

		Sleep( 900 * 1000 )  // Aguarda 15 minutos e tenta conectar novamente
		
		lResult := .T.

		CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPass RESULT lResulConn

		If lResulConn
			Exit
		Else
			GET MAIL ERROR cError
			If _lJob
				ConOut(cPrw+":"+TIME()+": Falha na conexao: "+TRIM(cAssunto)+"-"+cError)
				u_xxLog("\TMP\BKSENDMAIL.LOG",cPrw+"- Erro: "+cError,.T.,"")
			EndIf	
		EndIf
		
	    nTent++
	EndDo
	If !lResulConn
		Return(.F.)
	EndIf
Endif

// Sintaxe: SEND MAIL FROM cDe TO cPara CC cCc SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend
// Todos os e-mail terão: De, Para, Assunto e Mensagem, porém precisa analisar
// se tem: Com Cópia e/ou Anexo

If lRelauth
	lResult := MailAuth(Alltrim(cEmail), Alltrim(cPass))
	//Se nao conseguiu fazer a Autenticacao usando o E-mail completo, tenta fazer
	//a autenticacao usando apenas o nome de usuario do E-mail
	If !lResult
		nA := At("@",cEmail)
		cUser := If(nA>0,Subs(cEmail,1,nA-1),cEmail)
		lResult := MailAuth(Alltrim(cUser), Alltrim(cPass))
	Endif
Endif


If lResult
	//lResultSend := MailSend(cFrom, aTo, aCc, aBcc, cSubject, cBody, aFiles, lText)
	If !Empty(cPara) .AND. Empty(cCc) .And. Empty(cAnexo)
		SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg RESULT lResulSend
	ElseIf !Empty(cPara) .AND. Empty(cCc) .And. !Empty(cAnexo)
		SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend
	ElseIf Empty(cPara) .AND. !Empty(cCc) .And. Empty(cAnexo)
		SEND MAIL FROM cDe TO cCc SUBJECT cAssunto BODY cMsg RESULT lResulSend
	ElseIf Empty(cPara) .And. !Empty(cCc) .And. !Empty(cAnexo)
		SEND MAIL FROM cDe TO cCc SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend
	ElseIf !Empty(cPara) .AND. !Empty(cCc) .And. Empty(cAnexo)
		SEND MAIL FROM cDe TO cPara CC cCc SUBJECT cAssunto BODY cMsg RESULT lResulSend
	ElseIf !Empty(cPara) .And. !Empty(cCc) .And. !Empty(cAnexo)
		SEND MAIL FROM cDe TO cPara CC cCc SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend
	Endif
	
	If !lResulSend
		GET MAIL ERROR cError
		If _lJob
			ConOut(cPrw+": Falha no Envio do e-mail: "+TRIM(cAssunto)+"-"+cError)
		Else
			MsgAlert(cPrw+": Falha no Envio do e-mail "+TRIM(cAssunto)+"-"+cError)
		Endif
	Endif
Else
	lResultSend := .F.
	If _lJob
		ConOut(cPrw+": Falha na autenticação do e-mail: "+TRIM(cAssunto)+"-"+cError)
	Else
		MsgAlert(cPrw+": Falha na autenticação do e-mail: "+TRIM(cAssunto)+"-"+cError)
	Endif
Endif

DISCONNECT SMTP SERVER

IF lResulSend
	If _lJob
		ConOut(cPrw+": E-mail enviado com sucesso: "+TRIM(cAssunto))
	Else
		MsgInfo(cPrw+": E-mail enviado com sucesso: " +TRIM(cAssunto))
	Endif
ENDIF
RETURN lResulSend
                 


Static Function CabHtml(cTitulo)
Local aHtm := {}

AADD(aHtm,'<html>')
AADD(aHtm,'<head>')
AADD(aHtm,'<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">')
AADD(aHtm,'<link rel=Edit-Time-Data href="./HistD_arquivos/editdata.mso">')
AADD(aHtm,'<title>'+cTitulo+' - '+DTOC(date())+' '+TIME()+'</title>')
AADD(aHtm,'<style>')
AADD(aHtm,'.Normal{font-size:11.0pt;font-family:"Arial";}')
//AADD(aHtm,'.F6A{font-size:6.0;font-family:"Arial"}')
AADD(aHtm,'.F8A{font-size:8.0;font-family:"Arial"}')
AADD(aHtm,'.F10A{font-size:10.0;font-family:"Arial"}')
AADD(aHtm,'.F10AC{font-size:10.0;font-family:"Arial";text-align:"center"}')
//AADD(aHtm,'.F11A{font-size:11.0;font-family:"Arial"}')
//AADD(aHtm,'.F11AC{font-size:11.0;font-family:"Arial";text-align:"center"}')
//AADD(aHtm,'.F14A{font-size:14.0;font-family:"Arial"}')

AADD(aHtm,'</style>')
AADD(aHtm,'</head>')
AADD(aHtm,'<body bgcolor=#ffffff lang=PT-BR class="Normal">')

AADD(aHtm,'<table border=0 align="center" cellpadding=0 width="100%" style="center" >')
AADD(aHtm,'  <tr>')
AADD(aHtm,'  <td width=15% class="Normal">')
If FWCodEmp() == "01"      // BK
	AADD(aHtm,'    <p align=center style="text-align:center"><img src="http://www.bkconsultoria.com.br/Imagens/logo_header.png" border=0></p>')
ElseIf FWCodEmp() == "02"  // HF
	AADD(aHtm,'    <p align=center style="text-align:center"><b><span style="font-size:22.0pt;color:skyblue">BK TERCEIRIZADOS</span></b></p>')
ElseIf FWCodEmp() == "04"  // ESA
	AADD(aHtm,'    <p align=center style="text-align:center"><b><span style="font-size:22.0pt;color:skyblue">ESA</span></b></p>')
ElseIf FWCodEmp() == "06"  // BKDAHER SUZANO
	AADD(aHtm,'    <p align=center style="text-align:center"><b><span style="font-size:22.0pt;color:skyblue">BKDAHER SUZANO</span></b></p>')
ElseIf FWCodEmp() == "07"  // JUSTSOFTWARE
	AADD(aHtm,'    <p align=center style="text-align:center"><b><span style="font-size:22.0pt;color:skyblue">JUST</span></b></p>')
ElseIf FWCodEmp() == "08"  // BHG CAMPINAS
	AADD(aHtm,'    <p align=center style="text-align:center"><b><span style="font-size:22.0pt;color:skyblue">BHG CAMPINAS</span></b></p>')
ElseIf FWCodEmp() == "09"  // BHG OSASCO
	AADD(aHtm,'    <p align=center style="text-align:center"><b><span style="font-size:22.0pt;color:skyblue">BHG OSASCO</span></b></p>')
ElseIf FWCodEmp() == "10"  // BKDAHER TABOAO DA SERRA
	AADD(aHtm,'    <p align=center style="text-align:center"><b><span style="font-size:22.0pt;color:skyblue">BKDAHER TABOAO DA SERRA</span></b></p>')
ElseIf FWCodEmp() == "11"  // BKDAHER LIMEIRA
	AADD(aHtm,'    <p align=center style="text-align:center"><b><span style="font-size:22.0pt;color:skyblue">BKDAHER LIMEIRA</span></b></p>')
ElseIf FWCodEmp() == "12"  // BKDAHER CORRETORA
	AADD(aHtm,'    <p align=center style="text-align:center"><img src="http://www.bkseguros.com.br/wp-content/uploads/2017/04/bk-consultoria-seguros-logo.png" border=0></p>')
ElseIf FWCodEmp() == "14"  // CONSORCIO NOVA BALSA
	AADD(aHtm,'    <p align=center style="text-align:center"><b><span style="font-size:22.0pt;color:skyblue">CONSORCIO NOVA BALSA</span></b></p>')
Endif	

AADD(aHtm,'  </td>')
AADD(aHtm,'  <td class="Normal" width=85% style="center" >')
//AADD(aHtm,'    <p align=center style="text-align:center"><b><span style="font-size:22.0pt">'+cTitulo+'</span></b></p>')
AADD(aHtm,'    <p align=center style="text-align:center;font-size:18.0"><b>'+cTitulo+'</b></p>') 
AADD(aHtm,'    </td>')
AADD(aHtm,'  </tr>')
AADD(aHtm,'</table>')
AADD(aHtm,'<br>')
Return aHtm


Static Function CabR()
Local aHtm := {}

AADD(aHtm,'<table width="100%" Align="center" border="1" cellspacing="0" cellpadding="0" bordercolor="#CCCCCC" >')
AADD(aHtm,'  <tr bgcolor="#dfdfdf">')
AADD(aHtm,'    <td width="10%" class="F10A"><b>Contrato</b></td>')
AADD(aHtm,'    <td width="5%" class="F10A"><b>Rev.</b></td>')
AADD(aHtm,'    <td width="30%" class="F10A"><b>Descrição</b></td>')
AADD(aHtm,'    <td width="20%" class="F10A"><b>Aviso</b></td>')
AADD(aHtm,'    <td width="10%" class="F10A"><b>Repactuação</b></td>')
AADD(aHtm,'    <td width="15%" class="F10A"><b>Observaçoes</b></td>')
AADD(aHtm,'    <td width="10%" class="F10A"><b>Status</b></td>')
AADD(aHtm,'  </tr>')
Return aHtm

Static Function CabV()
Local aHtm := {}
AADD(aHtm,'<table width="100%" Align="center" border="1" cellspacing="0" cellpadding="0" bordercolor="#CCCCCC" >')
AADD(aHtm,'  <tr bgcolor="#dfdfdf">')
AADD(aHtm,'    <td width="15%" class="F10A"><b>Cliente</b></td>')
AADD(aHtm,'    <td width="23%" class="F10A"><b>Contrato</b></td>')
AADD(aHtm,'    <td width="40%" class="F10A"><b>Objeto</b></td>')
AADD(aHtm,'    <td width="15%" class="F10A"><b>Valor</b></td>')
AADD(aHtm,'    <td width="7%" class="F10A"><b>Vigencia</b></td>')
AADD(aHtm,'  </tr>')
Return aHtm


Static Function CabV2()
Local aHtm := {}
AADD(aHtm,'<table width="100%" Align="center" border="1" cellspacing="0" cellpadding="0" bordercolor="#CCCCCC" >')
AADD(aHtm,'  <tr bgcolor="#dfdfdf">')
AADD(aHtm,'    <td width="30%" class="F10A"><b>Cliente</b></td>')
AADD(aHtm,'    <td width="10%" class="F10A"><b>Contrato</b></td>')
AADD(aHtm,'    <td width="05%" class="F10A"><b>Rev</b></td>')
AADD(aHtm,'    <td width="30%" class="F10A"><b>Descr. CC</b></td>')
AADD(aHtm,'    <td width="15%" class="F10A"><b>Responsavel</b></td>')
AADD(aHtm,'    <td width="05%" class="F10A"><b>Vigencia</b></td>')
AADD(aHtm,'    <td width="05%" class="F10A" align="right" ><b>Dias</b></td>')
AADD(aHtm,'  </tr>')
Return aHtm



Static Function FimHtml(cPrw)
Local aHtm := {} 
Default cPrw := ""

AADD(aHtm,'</table>')
//AADD(aHtm,'<br>')
//AADD(aHtm,'<table border=1 cellspacing=0 cellpadding=0 width="100%" align="center" bordercolor="#CCCCCC">')
//AADD(aHtm,' <tr>')
//AADD(aHtm,'  <td width="70%" class="Normal"><p><font size="2"><b>')
//AADD(aHtm,'Observações:')
//AADD(aHtm,'  </b></font></p></td>')
//AADD(aHtm,' </tr>')
//AADD(aHtm,' <tr>')
//AADD(aHtm,'  <td width="100%" class="F10A">')
//AADD(aHtm,'  <p>')
//AADD(aHtm,TRIM(cObsTab)+'<br>')
//AADD(aHtm,'<br>')
//AADD(aHtm,'  </p>')
//AADD(aHtm,'  </td>')
//AADD(aHtm,'  </tr>')
//AADD(aHtm,' <tr>')
//AADD(aHtm,' </tr>')
//AADD(aHtm,'</table>')
If !EMPTY(cPrw) 
	//AADD(aHtm,'<br>Origem: '+cPrw) 
	AADD(aHtm,'<br><p class="F8A">Origem: '+TRIM(cPrw)+' '+DTOC(DATE())+' '+TIME()+' - '+TRIM(SM0->M0_NOME)+'</p>') 
EndIf
AADD(aHtm,'</body>')
AADD(aHtm,'</html>')
Return aHtm


Static Function FimHtmlB(cPrw)
Local aHtm := {}
Default cPrw := ""

If !EMPTY(cPrw) 
	AADD(aHtm,'<br><p class="F8A">Origem: '+TRIM(cPrw)+' '+DTOC(DATE())+' '+TIME()+' - '+TRIM(SM0->M0_NOME)+'</p>') 
Else
	AADD(aHtm,'<br>')
EndIf
AADD(aHtm,'</body>')
AADD(aHtm,'</html>')
Return aHtm


//-------------------------------------------------------------------------------------------------------//                                                    

User Function Cn9Obj(cCodObj)                        
Local cObj   := ""
Local _aArea := GetArea()

dbSelectArea("SYP")
dbSetOrder(1)
dbSeek(xFilial("SYP") + cCodObj)
DO WHILE !EOF() .AND. (xFilial("SYP") + cCodObj) = (SYP->YP_FILIAL + SYP->YP_CHAVE)
    cObj += STRTRAN(TRIM(STRTRAN(TRIM(SYP->YP_TEXTO),";",",")),"\13\10","")   //+"|"
	dbSkip()
ENDDO 
RestArea(_aArea)
Return cObj








//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//

Static Function RepBK06b()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contratos a Repactuar - Detalhado
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cPath     := "\tmp\"
Local nHandle
Local cCrLf     := Chr(13) + Chr(10)
Local _ni
Local cPicN     := "@E 99999999.99999"
Local cDirTmp,_cArqS,_cArqSv
Local lOk       := .F.

Local cQuery,cQuery1
Local lEnv
Local _cAlias := "QCN9"

Local cMsg    := ""
Local lCorNao := .F.

Local nDias   := 0
Local nDiasVig:= 0
//Local aStatus := {"Atrasado","Em Processo - Gestão","Aguardando retorno do cliente","Em Analise - Gestão","Finalizado"}
Local aStatus := {"1-Atrasado",;                        // Status 1
                  "2-Em análise "+TRIM(SM0->M0_NOME),;  //        2 
                  "3-Aguardando retorno do cliente",;   //        3
                  "4-Em analise cliente",;              //        4
                  "5-Pedido enviado",;                  //        5
                  "6-Finalizado",;                      //        6
                  "7-Aguardando decisão diretoria",;    //        7
                  "8-Contrato encerrado",;              //        8
                  "9-Em analise gestão"}                //        9
Local dDVig
Local lEmail := .F. 

Private cEmailTO := ""
Private cEmailCC := ""

Public cAviso  := ""
Public cStatus := ""
Public nValFat := 0

aCabs   := {}
aCampos := {}
 
AADD(aCampos,"QCN9->CN9_NUMERO")
AADD(aCabs  ,"Contrato")

AADD(aCampos,"QCN9->CN9_REVISA")
AADD(aCabs  ,"Revisao")

AADD(aCampos,"QCN9->CTT_DESC01")
AADD(aCabs  ,"Descrição")

AADD(aCampos,"QCN9->CN9_XXDVIG")
AADD(aCabs  ,"Vigencia")

AADD(aCampos,"cAviso")
AADD(aCabs  ,"Aviso")

AADD(aCampos,"QCN9->CN9_XXDREP")
AADD(aCabs  ,"Repactuação")

AADD(aCampos,"QCN9->CN9_XXDTPD")
AADD(aCabs  ,"Data Pedido Repactuação")

AADD(aCampos,"QCN9->CN9_XXVPED")
AADD(aCabs  ,"Valor Pedido Repactuação")

AADD(aCampos,"nValFat")
AADD(aCabs  ,"Valor Faturamento Mês Atual")

AADD(aCampos,"QCN9->CN9_XXOREP")
AADD(aCabs  ,"Obs Repactuação")

AADD(aCampos,"cStatus")
AADD(aCabs  ,"Status")

If !lJobV2
	IncProc()
EndIf

cQuery := " SELECT CN9_NUMERO,CN9_REVISA,CN9_SITUAC,CTT_DESC01,CN9_XXDREP,CN9_XXOREP,CN9_XXSREP,CN9_XXDVIG,CN9_XXDAVI,CN9_XXNAVI,CN9_XXDTPD,CN9_XXVPED,CN9.R_E_C_N_O_ AS XXRECNO "
cQuery += " FROM "+RETSQLNAME("CN9")+" CN9"

cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CN9_NUMERO"
cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"
cQuery += " WHERE CN9_SITUAC IN ('02','05') AND CN9_FILIAL = '"+xFilial("CN9")+"' AND CN9.D_E_L_E_T_ = ' ' "
IF !EMPTY(cContrRep) .AND. UPPER(SUBSTR(cContrRep,1,1)) <> 'T'
   cQuery += "AND CN9_NUMERO = '"+ALLTRIM(cContrRep)+"' "
ENDIF
IF !EMPTY(dtIni)
   cQuery += "AND CN9_XXDREP >= '"+DTOS(dtIni)+"' "
ENDIF
IF !EMPTY(dtFim)
   cQuery += "AND CN9_XXDREP <= '"+DTOS(dtFim)+"' "
ENDIF

// Ordem de data de repactuação - solicitado por Bruno em 13/01/12
cQuery += " ORDER BY CN9_XXDREP,CN9_NUMERO,CN9_REVISA"  

TCQUERY cQuery NEW ALIAS "QCN9"
TCSETFIELD("QCN9","CN9_XXDREP","D",8,0)
TCSETFIELD("QCN9","CN9_XXDVIG","D",8,0)
TCSETFIELD("QCN9","CN9_XXDAVI","D",8,0)
TCSETFIELD("QCN9","CN9_XXDTPD","D",8,0) 

// Cabeçalho do Email
aHtm := CabHtml("Contratos a Repactuar")   
FOR _ni := 1 TO LEN(aHtm)
   cMsg += aHtm[_ni]
NEXT

//aHtm := CabR()   
//FOR _ni := 1 TO LEN(aHtm)
//   cMsg += aHtm[_ni]
//NEXT

//cMsg += '<table width="100%" Align="center" border="0" cellspacing="0" cellpadding="0" bordercolor="#CCCCCC" >'

//------------------

cArqS := "BKGCT06_"+ALLTRIM(SM0->M0_NOME)

_cArqSv  := cPath+cArqS+".csv"

IF lJobV2
	cDirTmp   := ""
	_cArqS    := cPath+cArqS+".csv"
ELSE
	cDirTmp   := "C:\TMP"
	_cArqS    := cDirTmp+"\"+cArqS+".csv"
ENDIF

IF !EMPTY(cDirTmp)
   MakeDir(cDirTmp)
ENDIF   
 
fErase(_cArqS)

nHandle := MsfCreate(_cArqS,0)
   
If nHandle > 0
      
   FOR _ni := 1 TO LEN(aCabs)
       fWrite(nHandle, aCabs[_ni] + IIF(_ni < LEN(aCabs),";",""))
   NEXT
   fWrite(nHandle, cCrLf ) // Pula linha

   (_cAlias)->(dbgotop())
   
   Do while (_cAlias)->(!eof())
   
		If !lJobV2
			IncProc("Gerando arquivo "+_cArqS)   
		EndIf
		
		lEnv   := .F.
		cAviso := ""
		cStatus:= ""
		nDias  := 0
        
		If QCN9->CN9_XXSREP > 0 .AND. QCN9->CN9_XXSREP <= LEN(aStatus) 
          cStatus := aStatus[QCN9->CN9_XXSREP]
        EndIf

		If EMPTY(QCN9->CN9_XXDREP)
		    cAviso:= "Data de repactuação nao definida"
			lEnv := .T.
		Else
			nDias  := QCN9->CN9_XXDREP - DATE()
			
			lSolicitar := .F.
			lAtrasado  := .F.  // Dedo duro
			
			// Enviar sempre email 30 dias antes independente do status
			If nDias <= 30 .AND. nDias >= 0  
				lEnv := .T.
				lSolicitar := .T.
			EndIf

			
			// Enviar sempre quando faltar menos de 10 dias (e após) quando o status for = 1
            //If nDias < 10 .AND. QCN9->CN9_XXSREP = 1
            //   lEnv := .T.
            //EndIf
            
            If nDias < 0
               //Se houver status = 5 entre a drepac - 30 e hoje
               //   não sair nesta seção
               //Se não Mudar o Status para Atrasado.
               
                  
            
            EndIf

			// Enviar quando a data de repactuação for diferente da data de controle
            If !lEnv .AND. QCN9->CN9_XXDREP <> QCN9->CN9_XXDAVI
               If nDias <= 30 .AND. nDias > 0
                  lEnv := .T.
               EndIf
            EndIf

			If nDias < 0 .AND. QCN9->CN9_XXSREP <> 1
				If MOD(ABS(nDias),10) = 0
					lEnv := .T.
				EndIf
            EndIf
            
            If lEnv
		    	cAviso:= "Repactuação em "+ALLTRIM(STR(nDias,4))+" dias"
            EndIf

            //If QCN9->CN9_XXSREP = 5
            //	lEnv := .T.
		    //	cAviso:= "Redefinir a data da Repactuação"
            //EndIf

            // Enviar todos ou contrato selecionado na tela
            If !EMPTY(cContrRep)
            	lEnv := .T.
            EndIf
            	
		EndIf

		dbSelectArea("CN9")   
		dbGoto(QCN9->XXRECNO)
		
		If lEnv
        	lEmail := .T.
			RecLock("CN9",.F.)
			IF CN9->CN9_XXDREP <> CN9->CN9_XXDAVI
			   CN9->CN9_XXDAVI := CN9->CN9_XXDREP
			   CN9->CN9_XXNAVI := 1
			   CN9->CN9_XXSREP := 1
	           cStatus := aStatus[1]
			ELSE
			   IF CN9->CN9_XXNAVI < 99
			      CN9->CN9_XXNAVI := CN9->CN9_XXNAVI + 1
			   ENDIF
			ENDIF   
			MsUnlock()
	    EndIf


		dDVIG   := CN9->CN9_XXDVIG
		/*
		//IF EMPTY(dDVIG)
		   // Buscar o ultimo vencto dos Cronogramas
		   dbSelectArea("CNF")
		   dbSetOrder(3)
		   cContRev := xFilial("CNF")+CN9->CN9_NUMERO+CN9->CN9_REVISA
		   dbSeek(xFilial("CNF")+CN9->CN9_NUMERO+CN9->CN9_REVISA,.T.)
		   Do While !EOF() .AND. cContRev == CNF_FILIAL+CNF_CONTRA+CNF_REVISA
		      IF dDVIG < CNF->CNF_DTVENC
		         dDVIG := CNF->CNF_DTVENC
		      ENDIF
		      dbSkip()
		   EndDo
		   dbSelectArea("CN9")
			IF CN9->CN9_XXDVIG <> dDVIG
				RecLock("CN9",.F.)
				CN9->CN9_XXDVIG := dDVIG
				MsUnlock()
			ENDIF   
		//ENDIF
		*/
		nDiasVig  := CN9->CN9_XXDVIG - DATE()

		If nDiasVig = 30 .OR.;
			nDiasVig = 45 .OR.;
			nDiasVig = 60 .OR.;
			nDiasVig = 90 .OR.;
			nDiasVig = 120
			lEnv := .T.
	    	cAviso+= IIF(!EMPTY(cAviso)," - ","")+"Vigencia com termino em "+ALLTRIM(STR(nDiasVig,4))+" dias"
		EndIf

	    
		If lEnv

		 dbSelectArea(_cAlias)   
	     
	     lCorNao := .F.
	     
         cMsg += '<table width="100%" Align="center" border="1" cellspacing="0" cellpadding="4" bordercolor="#CCCCCC" >'
         If lCorNao   
            cMsg += '<tr>'
         Else   
            cMsg += '<tr bgcolor="#dfdfdf">'
         EndIf   
         lCorNao := !lCorNao
       
         //cMsg += '<td width="10%" class="F10A">'+TRIM(QCN9->CN9_NUMERO)+'</td>'
         //cMsg += '<td width="5%"  class="F10A">'+TRIM(QCN9->CN9_REVISA)+'</td>'
         //cMsg += '<td width="30%" class="F10A">'+TRIM(QCN9->CTT_DESC01)+'</td>'
         //cMsg += '<td width="20%" class="F10A">'+TRIM(cAviso)+'</td>'
         //cMsg += '<td width="10%" class="F10A">'+DTOC(QCN9->CN9_XXDREP)+'</td>'
         //cMsg += '<td width="15%" class="F10A">'+TRIM(QCN9->CN9_XXOREP)+'</td>'
         //cMsg += '<td width="10%" class="F10A">'+TRIM(cStatus)+'</td>'
         //cMsg += '</tr>'

         cMsg += '<td width="10%" class="F10A"><b>Contrato:</b></td>'
         cMsg += '<td width="10%" class="F10A">'+TRIM(QCN9->CN9_NUMERO)+'</td>'

         cMsg += '<td width="10%" class="F10A"><b>Descrição:</b></td>'
         cMsg += '<td width="30%" class="F10A">'+TRIM(QCN9->CTT_DESC01)+'</td>'

         cMsg += '<td width="10%" class="F10A"><b>Aviso:</b></td>'
         cMsg += '<td width="30%" class="F10A">'+TRIM(cAviso)+'</td>' 
         cMsg += '</tr>'

         
         If lCorNao   
            cMsg += '<tr>'
         Else   
            cMsg += '<tr bgcolor="#dfdfdf">'
         EndIf   
         lCorNao := !lCorNao

         cMsg += '<td width="10%" class="F10A"><b>Repactuação:</b></td>'
         cMsg += '<td width="10%" class="F10A">'+DTOC(QCN9->CN9_XXDREP)+'</td>'
         
         cMsg += '<td width="10%" class="F10A"><b>Observações:</b></td>'
         cMsg += '<td width="30%" class="F10A">'+TRIM(QCN9->CN9_XXOREP)+'</td>'
         
         cMsg += '<td width="10%" class="F10A"><b>Status:</b></td>'

         If SUBSTR(cStatus,1,1) == '1'
            cMsg += '<td width="30%" class="F10A"><font color="red"><b>'+TRIM(cStatus)+'</b></font></td>'
         Else   
            cMsg += '<td width="30%" class="F10A"><b>'+TRIM(cStatus)+'</b></td>'
         EndIf   

         cMsg += '</tr>'


		nValFat:= 0
		cCompet:= ""
		cCompet:= SUBSTR(DTOS(dDataBase),5,2)+"/"+SUBSTR(DTOS(dDataBase),1,4)

		cQuery1 := "SELECT SUM(CNF_VLPREV) AS CNF_VLPREV"
		cQuery1 += " FROM "+RETSQLNAME("CNF")+" CNF"
		cQuery1 += " WHERE CNF.D_E_L_E_T_='' AND CNF.CNF_COMPET='"+cCompet+"'  AND CNF_CONTRA='"+QCN9->CN9_NUMERO+"'"
		cQuery1 += " AND CNF_REVISA='"+QCN9->CN9_REVISA+"'" 

        TCQUERY cQuery1 NEW ALIAS "QCNF"
          
		dbSelectArea("QCNF")
		Do While QCNF->(!EOF())
			nValFat:= QCNF->CNF_VLPREV
			QCNF->(DBSKIP())
		ENDDO
		QCNF->(Dbclosearea())

         If lCorNao   
            cMsg += '<tr>'
         Else   
            cMsg += '<tr bgcolor="#dfdfdf">'
         EndIf   
         lCorNao := !lCorNao

         cMsg += '<td width="10%" class="F10A"><b>Data Pedido Repactuação:</b></td>'
         cMsg += '<td width="10%" class="F10A">'+DTOC(QCN9->CN9_XXDTPD)+'</td>'
         
         cMsg += '<td width="10%" class="F10A"><b>Valor Pedido Repactuação:</b></td>'
         cMsg += '<td width="30%" class="F10A">'+TRANSFORM(QCN9->CN9_XXVPED,"@E 999,999,999.99")+'</td>'
         
         cMsg += '<td width="10%" class="F10A"><b>Valor Faturamento Mês Atual:</b></td>'
         cMsg += '<td width="30%" class="F10A">'+TRANSFORM(nValFat,"@E 999,999,999.99")+'</td>'

         cMsg += '</tr>'

         // Histórico

         If lCorNao   
            cMsg += '<tr>'
         Else   
            cMsg += '<tr bgcolor="#dfdfdf">'
         EndIf   
         lCorNao := !lCorNao
         cMsg += '<td width="10%" class="F10AC"><b>Data</b></td>'
         cMsg += '<td colspan="5" width="90%" class="F10A"><b>Andamento da Repactuação</b></td>'
         cMsg += '</tr>'

         cQuery1 := " SELECT Z7_CONTRAT,Z7_REVISAO,Z7_DATA,Z7_HORA,Z7_XXOBSAN "
         cQuery1 += " FROM "+RETSQLNAME("SZ7")+" SZ7"

         cQuery1 += " WHERE Z7_CONTRAT = '"+QCN9->CN9_NUMERO+"' "
  //       cQuery1 += "   AND Z7_REVISAO = '"+QCN9->CN9_REVISA+"' "
         cQuery1 += "   AND Z7_FILIAL = '"+xFilial("SZ7")+"' AND SZ7.D_E_L_E_T_ = ' '"
         cQuery1 += " ORDER BY Z7_FILIAL,Z7_CONTRAT,Z7_REVISAO,Z7_DATA,Z7_HORA"  

         TCQUERY cQuery1 NEW ALIAS "QSZ7"
         TCSETFIELD("QSZ7","Z7_DATA","D",8,0)
          
		 dbSelectArea("QSZ7")
		 Do While !EOF()
            // Não imprimir linhas em branco nem historicos com mais de 6 meses 
 		    If !EMPTY(TRIM(QSZ7->Z7_XXOBSAN)) .AND. (DATE() - DAY(DATE()) - QSZ7->Z7_DATA) < 180
  	           If lCorNao   
    	          cMsg += '<tr>'
        	   Else   
                  cMsg += '<tr bgcolor="#dfdfdf">'
         	   EndIf
               cMsg += '<td width="10%" class="F10AC">'+DTOC(QSZ7->Z7_DATA)+'</td>'
               cMsg += '<td colspan="5" width="90%" class="F10A">'+TRIM(QSZ7->Z7_XXOBSAN)+'</td>'
               cMsg += '</tr>'
		    EndIf
		    
		    dbSkip()
		 EndDo

		 QSZ7->(Dbclosearea())

		 cMsg += '</table><br><br>'
	      
	      For _ni :=1 to LEN(aCampos)
	
	         xCampo := &(aCampos[_ni])
	            
	         _uValor := ""
	            
	         if VALTYPE(xCampo) == "D" // Trata campos data
	            _uValor := dtoc(xCampo)
	         elseif VALTYPE(xCampo) == "N" // Trata campos numericos
	            _uValor := transform(xCampo,cPicN)
	         elseif VALTYPE(xCampo) == "C" // Trata campos caracter
	            _uValor := '="'+ALLTRIM(xCampo)+'"'
	         endif
	            
	         fWrite(nHandle, _uValor + IIF(_ni < LEN(aCampos),";",""))
	            
	      Next _ni
	         
	      fWrite(nHandle, cCrLf )
	      
		EndIf
			         
		(_cAlias)->(dbskip())
         
	EndDo
      
	fClose(nHandle)

    
	If lJobV2
		ConOut(cPrw+": Exito ao criar "+_cArqs )
	Else   
		lOk := CpyT2S( _cArqs , cPath, .T. )
	EndIf

Else
	If lJobV2
		ConOut("Falha na criação do arquivo "+_cArqS)
	Else	
        MsgAlert("Falha na criação do arquivo "+_cArqS)
    Endif    
Endif
   
QCN9->(Dbclosearea())

// Cabeçalho do Email
aHtm := FimHtmlB("BKGCT06")   
FOR _ni := 1 TO LEN(aHtm)
   cMsg += aHtm[_ni]
NEXT
//------------------

cAssunto := "Aviso de repactuação - Detalhado - "+SM0->M0_NOME


IF lEmail
	// Carrega as variaveis cEmailTO e cEmailCC
	P4BKGCT06()
	
	// Envia o email
	U_SENDMAIL("BKGCT06",cAssunto,cEmailTO,cEmailCC,cMsg,_cArqSv,lJobV2)
ENDIF   

Return Nil



// Aviso de Insumos Operacionais, - solicitado pelo Bruno Santiago, Xavier e Paulo Rondini em 06/08/12

Static Function V5BKGct06()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//  "Aviso de Insumos Operacionais"
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cPath     := "\tmp\"
Local nHandle
Local cCrLf     := Chr(13) + Chr(10)
Local _ni
Local cPicN     := "@E 99999999.99999"
Local cDirTmp,_cArqS,_cArqSv
Local lOk       := .F.

Local cQuery
Local _cAlias := "QCN9"
Local cMsg    := ""
Local cTxt    := ""
Local lCorNao := .T.
Local cResp   := ""
Local lFirst  := .T.
Local nDiaUniD  := 0, nDiaEpiD := 0, nDiaMatD := 0,nDiaEqpD := 0
Local lEnvUNI   := .F., lEnvEPI  := .F., lEnvMAT  := .F., lEnvEQP  := .F.
Local _cXXUNIH  := '', _cXXEPIH := '', _cXXMATH := '', _cXXEQPH := ''

Private cEmailTO := ""
Private cEmailCC := ""

Public cVigencia := ""
Public nDiasVig  := 0

aCabs   := {}
aCampos := {}
    
aFHtm := { {}, {}, {} }
aFTxt := {}
aCabH := {"mês atual","60 dias","90 dias",}



 
AADD(aCampos,"QCN9->A1_NOME")
AADD(aCabs  ,"Cliente")

AADD(aCampos,"QCN9->CN9_NUMERO")
AADD(aCabs  ,"Contrato")

AADD(aCampos,"QCN9->CN9_REVISA")
AADD(aCabs  ,"Revisao")

AADD(aCampos,"QCN9->CTT_DESC01")
AADD(aCabs  ,"Descr. CC")

AADD(aCampos,"QCN9->CN9_XXNRBK")
AADD(aCabs  ,"Responsavel")

AADD(aCampos,"cUNIFORME")
AADD(aCabs  ,"Insumos Operacionais - Uniforme")

AADD(aCampos,"cEPI")
AADD(aCabs  ,"Insumos Operacionais - EPI")

AADD(aCampos,"cMAT")
AADD(aCabs  ,"Insumos Operacionais - Materiais")

AADD(aCampos,"cEQP")
AADD(aCabs  ,"Insumos Operacionais - Equipamentos")


If !lJobV2
	IncProc()
EndIf

cQuery := " SELECT CN9_NUMERO,CN9_REVISA,CN9_DTINIC,CN9_SITUAC,CTT_DESC01,CN9_XXNRBK,CN9_XXDVIG,CN9_XXPROA,"
cQuery += " CN9_CLIENT,CN9_LOJACL,A1_NOME,CN9_CODOBJ,CN9_VLATU,CN9.R_E_C_N_O_ AS XXRECNO,"
cQuery += " CN9_XXUNI,CN9_XXUNID,CN9_XXUNIH,CN9_XXEPI,CN9_XXEPID,CN9_XXEPIH,CN9_XXMAT,CN9_XXMATD,CN9_XXMATH,CN9_XXEQP,CN9_XXEQPD,CN9_XXEQPH "

cQuery += " FROM "+RETSQLNAME("CN9")+" CN9"

cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CN9_NUMERO"
cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"

cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON A1_COD = CN9_CLIENT AND A1_LOJA = CN9_LOJACL"
cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '"

cQuery += " WHERE CN9_SITUAC IN ('02','05') AND CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ' '"
cQuery += " AND (CN9_XXUNI='S' OR CN9_XXEPI='S' OR CN9_XXMAT='S' OR CN9_XXEQP='S')"
cQuery += " ORDER BY CN9_XXNRBK,A1_NOME"  

TCQUERY cQuery NEW ALIAS "QCN9"
TCSETFIELD("QCN9","CN9_DTINIC","D",8,0)
TCSETFIELD("QCN9","CN9_XXDVIG","D",8,0)
TCSETFIELD("QCN9","CN9_XXUNID","D",8,0)
TCSETFIELD("QCN9","CN9_XXEPID","D",8,0)
TCSETFIELD("QCN9","CN9_XXMATD","D",8,0)
TCSETFIELD("QCN9","CN9_XXEQPD","D",8,0)


(_cAlias)->(dbgotop())

cResp  := ALLTRIM(QCN9->CN9_XXNRBK)
lFirst := .T.
lEnviar:= .F.   
Do While (_cAlias)->(!eof())
	nDiaUniD := 0
    nDiaEpiD := 0 
    nDiaMatD := 0 
	nDiaEqpD := 0
	lEnvUNI  := .F.
	lEnvEPI  := .F.
	lEnvMAT  := .F.
	lEnvEQP  := .F.
    nDiaUniD := QCN9->CN9_XXUNID - DATE() 
    nDiaEpiD := QCN9->CN9_XXEPID - DATE() 
    nDiaMatD := QCN9->CN9_XXMATD - DATE() 
	nDiaEqpD := QCN9->CN9_XXEQPD - DATE()
	cMsg := ""
   	cUNIFORME := ''
   	_cXXUNIH := ''
   	cEPI := ''
   	_cXXEPIH := ''
   	cMAT := ''
   	_cXXMATH := ''
   	cEQP := ''
   	_cXXEQPH := ''

    IF QCN9->CN9_XXUNI=="S" .AND. (nDiaUniD == 90 .OR. nDiaUniD == 60 .OR. nDiaUniD == 53 .OR. nDiaUniD == 46 .OR. nDiaUniD == 39 .OR. nDiaUniD == 32 .OR. nDiaUniD <= 30)
       lEnvUNI := .T.
	ENDIF    
    IF QCN9->CN9_XXEPI=="S" .AND. (nDiaEpiD == 90 .OR. nDiaEpiD == 60 .OR. nDiaEpiD == 53 .OR. nDiaEpiD == 46 .OR. nDiaEpiD == 39 .OR. nDiaEpiD == 32 .OR. nDiaEpiD <= 30)
       lEnvEPI := .T.
	ENDIF    
    IF QCN9->CN9_XXMAT=="S" .AND. (nDiaMatD == 90 .OR. nDiaMatD == 60 .OR. nDiaMatD == 53 .OR. nDiaMatD == 46 .OR. nDiaMatD == 39 .OR. nDiaMatD == 32 .OR. nDiaMatD <= 30)
       lEnvMAT := .T.
	ENDIF    
    IF QCN9->CN9_XXEQP=="S" .AND. (nDiaEqpD == 90 .OR. nDiaEqpD == 60 .OR. nDiaEqpD == 53 .OR. nDiaEqpD == 46 .OR. nDiaEqpD == 39 .OR. nDiaEqpD == 32 .OR. nDiaEqpD <= 30)
       lEnvEQP := .T.
	ENDIF    
    
    IF lEnvUNI .OR. lEnvEPI .OR. lEnvMAT .OR. lEnvEQP
    	lEnviar := .T.
 		cMsg := ""
    	cUNIFORME := ''
    	_cXXUNIH := ''
    	cEPI := ''
    	_cXXEPIH := ''
    	cMAT := ''
    	_cXXMATH := ''
    	cEQP := ''
    	_cXXEQPH := ''
    	
        // Quebra por responsavel do contrato
        IF cResp <> ALLTRIM(QCN9->CN9_XXNRBK) .AND. !lFirst
            cMsg += '</table>'
            cMsg += '<br>'
            aHtm := CabV5()
            FOR _ni := 1 TO LEN(aHtm)
                cMsg += aHtm[_ni]
            NEXT
            cResp   := QCN9->CN9_XXNRBK
            lCorNao := .T.   
        ENDIF   

        lFirst  := .F.
         
        If lCorNao   
            cMsg += '<tr>'
        Else   
            cMsg += '<tr bgcolor="#dfdfdf">'
        EndIf   
       
        cMsg += '<td width="30%" class="F10A">'+TRIM(QCN9->A1_NOME)+'</td>'
        cMsg += '<td width="10%" class="F10A">'+TRIM(QCN9->CN9_NUMERO)+'</td>'
        cMsg += '<td width="05%" class="F10A">'+TRIM(QCN9->CN9_REVISA)+'</td>'
        cMsg += '<td width="30%" class="F10A">'+TRIM(QCN9->CTT_DESC01)+'</td>'
        cMsg += '<td width="15%" class="F10A">'+TRIM(QCN9->CN9_XXNRBK)+'</td>'

		aXXUNIH := {}
		aXXEPIH := {}
		aXXMATH := {}
		aXXEQPH := {}
		DbSelectArea("SZH")
		SZH->(dbSetOrder(1))
		SZH->(dbSeek(xFilial("SZH")+QCN9->CN9_NUMERO,.T.))
        DO while !EOF()
        	IF SZH->ZH_CONTRAT == QCN9->CN9_NUMERO
               IF aScan(aXXUNIH,{|x| x[2]==ALLTRIM(SZH->ZH_XXUNIH)}) == 0 .AND. ALLTRIM(SZH->ZH_XXUNIH) <> "" .AND. ALLTRIM(SZH->ZH_XXUNIH) <> ALLTRIM(QCN9->CN9_XXUNIH)
                  AADD(aXXUNIH,{DTOS(SZH->ZH_DATA)+SZH->ZH_HORA,ALLTRIM(SZH->ZH_XXUNIH)})
               ENDIF
               IF aScan(aXXEPIH,{|x| x[2]==ALLTRIM(SZH->ZH_XXEPIH)}) == 0 .AND. ALLTRIM(SZH->ZH_XXEPIH) <> "" .AND. ALLTRIM(SZH->ZH_XXEPIH) <> ALLTRIM(QCN9->CN9_XXEPIH)
                  AADD(aXXEPIH,{DTOS(SZH->ZH_DATA)+SZH->ZH_HORA,ALLTRIM(SZH->ZH_XXEPIH)})
               ENDIF
               IF aScan(aXXMATH,{|x| x[2]==ALLTRIM(SZH->ZH_XXMATH)}) == 0 .AND. ALLTRIM(SZH->ZH_XXMATH) <> "" .AND. ALLTRIM(SZH->ZH_XXMATH) <> ALLTRIM(QCN9->CN9_XXMATH)
                  AADD(aXXMATH,{DTOS(SZH->ZH_DATA)+SZH->ZH_HORA,ALLTRIM(SZH->ZH_XXMATH)})
               ENDIF
               IF aScan(aXXEQPH,{|x| x[2]==ALLTRIM(SZH->ZH_XXEQPH)}) == 0 .AND. ALLTRIM(SZH->ZH_XXEQPH) <> "" .AND. ALLTRIM(SZH->ZH_XXEQPH) <> ALLTRIM(QCN9->CN9_XXEQPH)
                  AADD(aXXEQPH,{DTOS(SZH->ZH_DATA)+SZH->ZH_HORA,ALLTRIM(SZH->ZH_XXEQPH)})
               ENDIF
     		ENDIF
        	SZH->(dbskip())
        ENDDO
		SZH->(Dbclosearea())


        cInsumos := ''
        IF lEnvUNI  
	    	cUNIFORME := ''
	    	_cXXUNIH := ''
			if nDiaUNID <= 30
		    	cInsumos += '<font color="red">'
		    ENDIF
		    cInsumos +="<b>Uniformes</b><br>"
		    cInsumos += "Prox. Troca: "+DTOC(QCN9->CN9_XXUNID)+" Dias: "+STR(nDiaUNID,6)+"<br>"
		    cInsumos += "Obs Andamento Uniforme: <br>"
		    cInsumos += ALLTRIM(QCN9->CN9_XXUNIH)+"<br>"
		    IF LEN(aXXUNIH) > 0
		    	ASORT(aXXUNIH,,,{|x,y| x[1]>y[1]})
		    	FOR _X:=1 TO IIF(LEN(aXXUNIH)>10,10,LEN(aXXUNIH))
		    		cInsumos += aXXUNIH[_X,2]+"<br>"
		    		_cXXUNIH += aXXUNIH[_X,2]+", "
		    	NEXT
		    	cInsumos += "<br>"
		    ELSE
		    	cInsumos += "<br>"
		    ENDIF
		    
			if nDiaUNID <= 30
		    	cInsumos += '</font>'
		    ENDIF
		    cUNIFORME := "Prox. Troca: "+DTOC(QCN9->CN9_XXUNID)+" Dias: "+STR(nDiaUNID,6)+" Obs Andamento Uniforme: "+ALLTRIM(QCN9->CN9_XXUNIH)+", "+_cXXUNIH
         ENDIF
         IF lEnvEPI  
	         cEPI := ''
	    	_cXXEPIH := ''
			if nDiaEPID <= 30
		    	cInsumos += '<font color="red">'
		    ENDIF
		    cInsumos += "<b>EPI</b><br>"
		    cInsumos += "Prox. Troca: "+DTOC(QCN9->CN9_XXEPID)+" Dias: "+STR(nDiaEPID,6)+"<br>"
		    cInsumos += "Obs Andamento EPI: <br>"
		    cInsumos += ALLTRIM(QCN9->CN9_XXEPIH)+"<br>"
		    IF LEN(aXXEPIH) > 0
		    	ASORT(aXXEPIH,,,{|x,y| x[1]>y[1]})
		    	FOR _X:=1 TO IIF(LEN(aXXEPIH)>10,10,LEN(aXXEPIH))
		    		cInsumos += aXXEPIH[_X,2]+"<br>"
		    		_cXXEPIH += aXXEPIH[_X,2]+", "
		    	NEXT
		    	cInsumos += "<br>"
		    ELSE
		    	cInsumos += "<br>"
		    ENDIF
			if nDiaEPID <= 30
		    	cInsumos += '</font>'
		    ENDIF
		    cEPI := "Prox. Troca: "+DTOC(QCN9->CN9_XXEPID)+" Dias: "+STR(nDiaEPID,6)+" Obs Andamento EPI: "+ALLTRIM(QCN9->CN9_XXEPIH)+", "+_cXXEPIH
         ENDIF
         IF lEnvMAT  
	    	 cMAT := ''
	    	_cXXMATH := ''
			if nDiaMATD <= 30
		    	cInsumos += '<font color="red">'
		    ENDIF
		    cInsumos += "<b>Materiais</b><br>"
		    cInsumos += "Prox. Troca: "+DTOC(QCN9->CN9_XXMATD)+" Dias: "+STR(nDiaMATD,6)+"<br>"
		    cInsumos += "Obs Andamento Materiais: <br>"
		    cInsumos += ALLTRIM(QCN9->CN9_XXMATH)+"<br>"
		    IF LEN(aXXMATH) > 0
		    	ASORT(aXXMATH,,,{|x,y| x[1]>y[1]})
		    	FOR _X:=1 TO IIF(LEN(aXXMATH)>10,10,LEN(aXXMATH))
		    		cInsumos += aXXMATH[_X,2]+"<br>"
		    		_cXXMATH += aXXMATH[_X,2]+", "
		    	NEXT
		    	cInsumos += "<br>"
		    ELSE
		    	cInsumos += "<br>"
		    ENDIF
			if nDiaMATD <= 30
		    	cInsumos += '</font>'
		    ENDIF
		    cMAT := "Prox. Troca: "+DTOC(QCN9->CN9_XXMATD)+" Dias: "+STR(nDiaMATD,6)+" Obs Andamento Materiais: "+ALLTRIM(QCN9->CN9_XXMATH)+", "+_cXXMATH
         ENDIF
         IF lEnvEQP  
    		cEQP := ''
	    	_cXXEQPH := ''
			if nDiaEQPD <= 30
		    	cInsumos += '<font color="red">'
		    ENDIF
		    cInsumos += "<b>Equipamentos</b><br>"
		    cInsumos += "Prox. Troca: "+DTOC(QCN9->CN9_XXEQPD)+" Dias: "+STR(nDiaEQPD,6)+"<br>"
		    cInsumos += "Obs Andamento Equipamentos: <br>"
		    cInsumos += ALLTRIM(QCN9->CN9_XXEQPH)+"<br>"
		    IF LEN(aXXEQPH) > 0
		    	ASORT(aXXEQPH,,,{|x,y| x[1]>y[1]})
		    	FOR _X:=1 TO IIF(LEN(aXXEQPH)>10,10,LEN(aXXEQPH))
		    		cInsumos += aXXEQPH[_X,2]+"<br>"
		    		_cXXEQPH += aXXEQPH[_X,2]+", "
		    	NEXT
		    	cInsumos += "<br>"
		    ELSE
		    	cInsumos += "<br>"
		    ENDIF
			if nDiaEQPD <= 30
				cInsumos += '</font>'
			ENDIF
			cEQP := "Prox. Troca: "+DTOC(QCN9->CN9_XXEQPD)+" Dias: "+STR(nDiaEQPD,6)+" Obs Andamento Equipamentos: "+ALLTRIM(QCN9->CN9_XXEQPH)+", "+_cXXEQPH
        ENDIF

        cMsg += '<td width="05%" class="F10A" nowrap>'+TRIM(cInsumos)+'</td>'
        cMsg += '</tr>'

        lCorNao := !lCorNao
	     
	    cTxt := "" 
	    For _ni :=1 to LEN(aCampos)
	
	       xCampo := &(aCampos[_ni])
	           
	       _uValor := ""
	           
	       if VALTYPE(xCampo) == "D" // Trata campos data
	          _uValor := dtoc(xCampo)
	       elseif VALTYPE(xCampo) == "N" // Trata campos numericos
	          _uValor := transform(xCampo,cPicN)
	       elseif VALTYPE(xCampo) == "C" // Trata campos caracter
	          _uValor := '="'+ALLTRIM(xCampo)+'"'
	       endif
	            
	       cTxt += _uValor + IIF(_ni < LEN(aCampos),";","")
	            
	    Next _ni
	         

    	IF nDiaUniD <= 30 .OR. nDiaEpiD <= 30 .OR. nDiaMatD <= 30 .OR. nDiaEqpD <= 30
        	AADD(aFHtm[1],cMsg)
    	ELSEIF (nDiaUniD > 30 .AND. nDiaUniD <= 60) .OR. (nDiaEpiD > 30 .AND. nDiaEpiD <= 60) .OR. (nDiaMatD > 30 .AND. nDiaMatD <= 60) .OR. (nDiaEqpD > 30 .AND. nDiaEqpD <= 60)
        	AADD(aFHtm[2],cMsg)
    	ELSEIF nDiaUniD > 60 .OR. nDiaEpiD > 60 .OR. nDiaMatD > 60 .OR. nDiaEqpD > 60
        	AADD(aFHtm[3],cMsg)
        Endif
   		IF !EMPTY(cTxt)
   			AADD(aFTxt,cTxt)
   		ENDIF

	EndIf
    
	(_cAlias)->(dbskip())


EndDo


IF !lEnviar
	QCN9->(Dbclosearea())
	Return Nil
ENDIF

//---------------------------

cArqS := "BKGCT6V5_"+ALLTRIM(SM0->M0_NOME)

_cArqSv  := cPath+cArqS+".csv"

IF lJobV2
	cDirTmp   := ""
	_cArqS    := cPath+cArqS+".csv"
ELSE
	cDirTmp   := "C:\TMP"
	_cArqS    := cDirTmp+"\"+cArqS+".csv"
ENDIF

IF !EMPTY(cDirTmp)
   MakeDir(cDirTmp)
ENDIF   
 
fErase(_cArqS)

nHandle := MsfCreate(_cArqS,0)

cMsg:= ""
cTxt:= ""
For _nj := 1 to 3
	IF LEN(aFHtm[_nj]) > 0
		// Cabeçalho do Email
		aHtm := CabHtml("Aviso de Insumos Operacionais - "+aCabH[_nj])   
		FOR _ni := 1 TO LEN(aHtm)
		   cMsg += aHtm[_ni]
		NEXT
	
		aHtm := CabV5()
		FOR _ni := 1 TO LEN(aHtm)
	   		cMsg += aHtm[_ni]
		NEXT
	
		FOR _ni := 1 to LEN(aFHtm[_nj])
	    	cMsg += aFHtm[_nj,_ni]
		NEXT
	
		// Rodapé do Email
		aHtm := FimHtml("BKGCT06")   
		FOR _ni := 1 TO LEN(aHtm)
			cMsg += aHtm[_ni]
		NEXT
	
	ENDIF
Next		

If nHandle > 0
	fWrite(nHandle, "Aviso de Insumos Operacionais"+cCrLf)
	FOR _ni := 1 TO LEN(aCabs)
		fWrite(nHandle, aCabs[_ni] + IIF(_ni < LEN(aCabs),";",""))
	NEXT
	fWrite(nHandle, cCrLf ) // Pula linha
	FOR _ni := 1 to LEN(aFTxt)
       	 fWrite(nHandle, aFTxt[_ni]+cCrLf)
	NEXT
	
EndIf

	
//------------------
    
If nHandle > 0
	fClose(nHandle)
	If lJobV2
		ConOut(cPrw+": Exito ao criar "+_cArqs )
	Else   
		lOk := CpyT2S( _cArqs , cPath, .T. )
	EndIf

Else
	fClose(nHandle)
	If lJobV2
		ConOut("Falha na criação do arquivo "+_cArqS)
	Else	
        MsgAlert("Falha na criação do arquivo "+_cArqS)
    Endif    
Endif
   
QCN9->(Dbclosearea())


//------------------

cAssunto := "Aviso de Insumos Operacionais - "+SM0->M0_NOME

//If !lJobV2
//   _cArqSv := ""
//EndIf
   
// -- Carrega as variaveis cEmailTO e cEmailCC
P5BKGCT06()

//msginfo(cEmailto)
//msginfo(cEmailcc)


If U_SENDMAIL("BKGCT06",cAssunto,cEmailTO,cEmailCC,cMsg,_cArqSv,lJobV2)
	dbSelectArea("SX6")
	If DBSEEK("  MV_XXBKENV",.F.)
   		RecLock("SX6",.F.)
		SX6->X6_CONTEUD := DTOS(dDataEnv)
   		MsUnlock()
    EndIf
Else
	dbSelectArea("SX6")
	If DBSEEK("  MV_XXBKENV",.F.)
   		RecLock("SX6",.F.)
		SX6->X6_CONTEUD := ""
   		MsUnlock()
    EndIf
EndIf

Return Nil


//Aviso Atestado de Capacidade Técnica
Static Function V6BKGct06()

Local cQuery
Local _cAlias 	:= "QCN9"

Local cAssunto	:= "Aviso Atestado de Capacidade Técnica"
Local cEmail	:= "microsiga@bkconsultoria.com.br;sigaisop1@bkconsultoria.com.br;licita@bkconsultoria.com.br"
Local cEmailCC	:= ""
Local cMsg    	:= ""
Local cAnexo    := ""

Local cResp   	:= ""
Local lFirst  	:= .T.

Local dVigI   	:= CTOD("")
Local dVigF   	:= CTOD("")

Local aCabs		:= {}
Local aEmail	:= {}
Local dDiaStat  := 5
Local lEnvia 	:= .T.

If !lJobV2
	IncProc()
EndIf 

IF !EMPTY(cEmailS)
   cEmail := ALLTRIM(cEmailS)+";"
ENDIF

//cEmail := "microsiga@bkconsultoria.com.br;"

cQuery := " SELECT CN9_NUMERO,CN9_REVISA,CN9_SITUAC,CTT_DESC01,CN9_XXNRBK,CN9_XXDSAT,"
cQuery += " CN9_CLIENT,CN9_LOJACL,A1_NOME,CN9_DTINIC,(SELECT TOP 1 CNF_DTVENC FROM "+RETSQLNAME("CNF")+ " CNF "
cQuery += " WHERE CNF.D_E_L_E_T_='' AND  CNF_FILIAL = '"+xFilial("CNF")+"' AND CNF_CONTRA=CN9_NUMERO "
cQuery += " AND CNF_REVISA=CN9_REVISA ORDER BY CNF_DTVENC) AS CNF_DTVEN1,CN9_XXDVIG,"
cQuery += " (SELECT TOP 1 CNF_DTVENC FROM "+RETSQLNAME("CNF")+ " CNF WHERE CNF.D_E_L_E_T_='' AND "
cQuery += " CNF_FILIAL = '"+xFilial("CNF")+"' AND CNF_CONTRA=CN9_NUMERO "
cQuery += " AND CNF_REVISA=CN9_REVISA ORDER BY CNF_DTVENC DESC) AS CNF_DTVEN2,"
cQuery += " CN9_XXDAAT,CN9_XXTPAT,CN9_XXSTAT,CN9_XXDSTA,CN9_XXDENC,CN9.R_E_C_N_O_ AS CN9_RECNO  "

cQuery += " FROM "+RETSQLNAME("CN9")+" CN9"

cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CN9_NUMERO"
cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"

cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON A1_COD = CN9_CLIENT AND A1_LOJA = CN9_LOJACL"
cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '"

cQuery += " WHERE CN9.D_E_L_E_T_ = ' ' AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"

//cQuery += " AND CN9_NUMERO='230000355'" 

cQuery += " ORDER BY CN9_XXNRBK,A1_NOME"  

TCQUERY cQuery NEW ALIAS "QCN9"

TCSETFIELD("QCN9","CN9_DTINIC","D",8,0)
TCSETFIELD("QCN9","CN9_XXDVIG","D",8,0)
TCSETFIELD("QCN9","CN9_XXDAAT","D",8,0)
TCSETFIELD("QCN9","CN9_XXDSTA","D",8,0)
TCSETFIELD("QCN9","CN9_XXDENC","D",8,0)
TCSETFIELD("QCN9","CNF_DTVEN1","D",8,0)
TCSETFIELD("QCN9","CNF_DTVEN2","D",8,0)
TCSETFIELD("QCN9","CN9_XXDSAT","D",8,0)

(_cAlias)->(dbgotop())

cResp  := ALLTRIM(QCN9->CN9_XXNRBK)
lFirst := .T.
lEnviar:= .F.   
Do While (_cAlias)->(!eof())

	//IF (_cAlias)->CN9_DTINIC < (_cAlias)->CNF_DTVEN1 .AND. !EMPTY((_cAlias)->CN9_DTINIC)
	//	dVigI := (_cAlias)->CN9_DTINIC
	//ELSE
		dVigI := (_cAlias)->CNF_DTVEN1
	//ENDIF	 

	//IF (_cAlias)->CN9_XXDVIG > (_cAlias)->CNF_DTVEN2 
	//	dVigF := (_cAlias)->CN9_XXDVIG
	//ELSE
		dVigF := (_cAlias)->CNF_DTVEN2
	//ENDIF


	cTPAT := ""
	IF (_cAlias)->CN9_XXTPAT=='1'
		cTPAT := "1º aviso +180 dias de contrato"
    ELSEIF (_cAlias)->CN9_XXTPAT=='2'
		cTPAT := "2º aviso +365 dias de contrato"
    ELSEIF (_cAlias)->CN9_XXTPAT=='3'
		cTPAT := "3- Renovação do contrato"
    ELSEIF (_cAlias)->CN9_XXTPAT=='4'
		cTPAT := "4- Encerramento do contrato"
    ENDIF

	cSTATUS := ""
	IF (_cAlias)->CN9_XXSTAT=='1'
		cSTATUS := "1-Solicitado em "+DTOC((_cAlias)->CN9_XXDSTA)
    ELSEIF (_cAlias)->CN9_XXSTAT=='2'
		cSTATUS := "2-Retirado ou Entregue em "+DTOC((_cAlias)->CN9_XXDSTA)
    ELSEIF (_cAlias)->CN9_XXSTAT=='3'
		cSTATUS := "3-Solicitar a partir de "+DTOC((_cAlias)->CN9_XXDSAT)
    ENDIF
    
    lEnvia := .T.
	IF (_cAlias)->CN9_XXSTAT=='3'
 		IF !((_cAlias)->CN9_XXDSAT - DATE()) <= dDiaStat
   			lEnvia := .F.
     	ENDIF
	ENDIF
	     
	IF lEnvia
	    //1.	Contrato novo 1º aviso 180 dias d+1 do inicio 
	    IF (DATE() - dVigI) >  180 .AND. (DATE()-dVigI) <  365   .AND. (_cAlias)->CN9_XXTPAT $ " /1" 
	    	IF (_cAlias)->CN9_XXSTAT == '2' .AND. (_cAlias)->CN9_XXTPAT == '1'
	    		IF (DATE() - (_cAlias)->CN9_XXDSTA) <= dDiaStat
					//"Contrato","Rev	Descr. CC","Responsavel","Data Aviso","Aviso","Status"
	    	   		AADD(aEmail,{(_cAlias)->CN9_NUMERO,;
	    	   		(_cAlias)->CN9_REVISA,;
	    	   		(_cAlias)->CTT_DESC01,;
	    	   		(_cAlias)->CN9_XXNRBK,;
	    	   		dVigI,;
	    	   		dVigF,;
	    	   		(_cAlias)->CN9_XXDAAT,;
	    	   		cTPAT,;
	    	   		cSTATUS})
	    		ENDIF
	    	ELSE
				cTPAT := ""
				cTPAT := "1º aviso +180 dias de contrato"
				
				IF (_cAlias)->CN9_XXTPAT == '1'
					//"Contrato","Rev	Descr. CC","Responsavel","Data Aviso","Aviso","Status"
	    	   		AADD(aEmail,{(_cAlias)->CN9_NUMERO,;
	    	   		(_cAlias)->CN9_REVISA,;
	    	   		(_cAlias)->CTT_DESC01,;
	    	   		(_cAlias)->CN9_XXNRBK,;
	    	   		dVigI,;
	    	   		dVigF,;
	    	   		(_cAlias)->CN9_XXDAAT,;
	    	   		cTPAT,;
	    	   		cSTATUS})
	    		ELSE
					cTPAT := "1º aviso +180 dias de contrato"
					cSTATUS := ""
					dbSelectArea("CN9")
					CN9->(dbGoto((_cAlias)->CN9_RECNO))
					RecLock("CN9",.F.)
					CN9->CN9_XXTPAT := "1"
					CN9->CN9_XXDAAT := DATE()
					CN9->CN9_XXSTAT	:= cSTATUS			
					cSTATUS := ""
					MsUnlock()
	
					//"Contrato","Rev	Descr. CC","Responsavel","Data Aviso","Aviso","Status"
	    	   		AADD(aEmail,{(_cAlias)->CN9_NUMERO,;
	    	   		(_cAlias)->CN9_REVISA,;
	    	   		(_cAlias)->CTT_DESC01,;
	    	   		(_cAlias)->CN9_XXNRBK,;
	    	   		dVigI,;
	    	   		dVigF,;
	    	   		DATE(),;
	    	   		cTPAT,;
	    	   		cSTATUS})
	    		ENDIF
	    	ENDIF
	    ENDIF 
	    //2º aviso +365 dias de contrato
	    IF (DATE() - dVigI) >  365  .AND. (dVigF - dVigI) > 365 .AND. (_cAlias)->CN9_XXTPAT $ "1/2" 
	    	IF (_cAlias)->CN9_XXSTAT == '2' .AND. (_cAlias)->CN9_XXTPAT == '2'
	    		IF (DATE() - (_cAlias)->CN9_XXDSTA) <= dDiaStat
					//"Contrato","Rev	Descr. CC","Responsavel","Data Aviso","Aviso","Status"
	    	   		AADD(aEmail,{(_cAlias)->CN9_NUMERO,;
	    	   		(_cAlias)->CN9_REVISA,;
	    	   		(_cAlias)->CTT_DESC01,;
	    	   		(_cAlias)->CN9_XXNRBK,;
	    	   		dVigI,;
	    	   		dVigF,;
	    	   		(_cAlias)->CN9_XXDAAT,;
	    	   		cTPAT,;
	    	   		cSTATUS})
	    		ENDIF
	    	ELSE
				cTPAT := ""
				cTPAT := "2º aviso +365 dias de contrato"
				
				IF (_cAlias)->CN9_XXTPAT == '2'
					//"Contrato","Rev	Descr. CC","Responsavel","Data Aviso","Aviso","Status"
	    	   		AADD(aEmail,{(_cAlias)->CN9_NUMERO,;
	    	   		(_cAlias)->CN9_REVISA,;
	    	   		(_cAlias)->CTT_DESC01,;
	    	   		(_cAlias)->CN9_XXNRBK,;
	    	   		dVigI,;
	    	   		dVigF,;
	    	   		(_cAlias)->CN9_XXDAAT,;
	    	   		cTPAT,;
	    	   		cSTATUS})
	    		ELSE
					cTPAT := "2º aviso +365 dias de contrato"
					cSTATUS := ""
					dbSelectArea("CN9")
					CN9->(dbGoto((_cAlias)->CN9_RECNO))
					RecLock("CN9",.F.)
					CN9->CN9_XXTPAT := "2"
					CN9->CN9_XXDAAT := DATE()
					CN9->CN9_XXSTAT	:= cSTATUS			
					MsUnlock()
	
					//"Contrato","Rev	Descr. CC","Responsavel","Data Aviso","Aviso","Status"
	    	   		AADD(aEmail,{(_cAlias)->CN9_NUMERO,;
	    	   		(_cAlias)->CN9_REVISA,;
	    	   		(_cAlias)->CTT_DESC01,;
	    	   		(_cAlias)->CN9_XXNRBK,;
	    	   		dVigI,;
	    	   		dVigF,;
	    	   		DATE(),;
	    	   		cTPAT,;
	    	   		cSTATUS})
	    		ENDIF
	    	ENDIF
	    ENDIF 
	    //3- Renovação do contrato
	    IF  dVigF > (_cAlias)->CN9_XXDENC .OR. (_cAlias)->CN9_XXTPAT == '3' 
	    	IF (_cAlias)->CN9_XXSTAT == '2' .AND. (_cAlias)->CN9_XXTPAT == '3'
	    		IF (DATE() - (_cAlias)->CN9_XXDSTA) <= dDiaStat
					//"Contrato","Rev	Descr. CC","Responsavel","Data Aviso","Aviso","Status"
	    	   		AADD(aEmail,{(_cAlias)->CN9_NUMERO,;
	    	   		(_cAlias)->CN9_REVISA,;
	    	   		(_cAlias)->CTT_DESC01,;
	    	   		(_cAlias)->CN9_XXNRBK,;
	    	   		dVigI,;
	    	   		dVigF,;
	    	   		(_cAlias)->CN9_XXDAAT,;
	    	   		cTPAT,;
	    	   		cSTATUS})
	    		ENDIF
	    	ELSE
				cTPAT := ""
				cTPAT := "3- Renovação do contrato"
				
				IF (_cAlias)->CN9_XXTPAT == '3'
					//"Contrato","Rev	Descr. CC","Responsavel","Data Aviso","Aviso","Status"
	    	   		AADD(aEmail,{(_cAlias)->CN9_NUMERO,;
	    	   		(_cAlias)->CN9_REVISA,;
	    	   		(_cAlias)->CTT_DESC01,;
	    	   		(_cAlias)->CN9_XXNRBK,;
	    	   		dVigI,;
	    	   		dVigF,;
	    	   		(_cAlias)->CN9_XXDAAT,;
	    	   		cTPAT,;
	    	   		cSTATUS})
	    		ELSE
	    			IF !EMPTY((_cAlias)->CN9_XXDENC)
	    			
						cTPAT := "3- Renovação do contrato"
						cSTATUS := ""
						dbSelectArea("CN9")
						CN9->(dbGoto((_cAlias)->CN9_RECNO))
						RecLock("CN9",.F.)
						CN9->CN9_XXTPAT := "3"
						CN9->CN9_XXDAAT := DATE()
						CN9->CN9_XXSTAT	:= cSTATUS			
						CN9->CN9_XXDENC := dVigF
						MsUnlock()
	
						//"Contrato","Rev	Descr. CC","Responsavel","Data Aviso","Aviso","Status"
	    	   			AADD(aEmail,{(_cAlias)->CN9_NUMERO,;
	    	   			(_cAlias)->CN9_REVISA,;
	    	   			(_cAlias)->CTT_DESC01,;
	    	   			(_cAlias)->CN9_XXNRBK,;
	    	   			dVigI,;
	    	   			dVigF,;
	    	   			DATE(),;
	    	   			cTPAT,;
	    	   			cSTATUS})
	
					ELSEIF !EMPTY(dVigF) 
						dbSelectArea("CN9")
						CN9->(dbGoto((_cAlias)->CN9_RECNO))
						RecLock("CN9",.F.)
						CN9->CN9_XXDENC := dVigF
						MsUnlock()
	                ENDIF
	    		ENDIF
	    	ENDIF
	    ENDIF
	     
	    //4- Encerramento do contrato
	    IF (!EMPTY(dVigF) .AND. DATE() > dVigF ) .OR. (_cAlias)->CN9_SITUAC == "08"
	    	IF (_cAlias)->CN9_XXSTAT == '2' .AND. (_cAlias)->CN9_XXTPAT == '4'
	    		IF (DATE() - (_cAlias)->CN9_XXDSTA) <= dDiaStat
					//"Contrato","Rev	Descr. CC","Responsavel","Data Aviso","Aviso","Status"
	    	   		AADD(aEmail,{(_cAlias)->CN9_NUMERO,;
	    	   		(_cAlias)->CN9_REVISA,;
	    	   		(_cAlias)->CTT_DESC01,;
	    	   		(_cAlias)->CN9_XXNRBK,;
	    	   		dVigI,;
	    	   		dVigF,;
	    	   		(_cAlias)->CN9_XXDAAT,;
	    	   		cTPAT,;
	    	   		cSTATUS})
	    		ENDIF
	    	ELSE
				cTPAT := ""
				cTPAT := "4- Encerramento do contrato"
				
				IF (_cAlias)->CN9_XXTPAT == '4'
					//"Contrato","Rev	Descr. CC","Responsavel","Data Aviso","Aviso","Status"
	    	   		AADD(aEmail,{(_cAlias)->CN9_NUMERO,;
	    	   		(_cAlias)->CN9_REVISA,;
	    	   		(_cAlias)->CTT_DESC01,;
	    	   		(_cAlias)->CN9_XXNRBK,;
	    	   		dVigI,;
	    	   		dVigF,;
	    	   		(_cAlias)->CN9_XXDAAT,;
	    	   		cTPAT,;
	    	   		cSTATUS})
	    		ELSE
					cTPAT := "4- Encerramento do contrato"
					cSTATUS := ""
					dbSelectArea("CN9")
					CN9->(dbGoto((_cAlias)->CN9_RECNO))
					RecLock("CN9",.F.)
					CN9->CN9_XXTPAT := "4"
					CN9->CN9_XXDAAT := DATE()
					CN9->CN9_XXSTAT	:= cSTATUS			
					MsUnlock()
	
					//"Contrato","Rev	Descr. CC","Responsavel","Data Aviso","Aviso","Status"
	    	   		AADD(aEmail,{(_cAlias)->CN9_NUMERO,;
	    	   		(_cAlias)->CN9_REVISA,;
	    	   		(_cAlias)->CTT_DESC01,;
	    	   		(_cAlias)->CN9_XXNRBK,;
	    	   		dVigI,;
	    	   		dVigF,;
	    	   		DATE(),;
	    	   		cTPAT,;
	    	   		cSTATUS})
	    		ENDIF
	    	ENDIF
	    ENDIF 
	ENDIF   
	(_cAlias)->(dbskip())
EndDo

QCN9->(Dbclosearea())

IF LEN(aEmail) > 0

	aCabs   := {"Contrato","Revisao","Descr. CC","Responsavel","Inicio Vigencia","Fim Vigencia","Data Aviso","Aviso","Status"}

	cMsg    := u_GeraHtmA(aEmail,cAssunto+" - "+DTOC(DATE())+" "+TIME(),aCabs,"V6BKGct06")

	U_SendMail("V6BKGct06",cAssunto,cEmail,cEmailCC,cMsg,cAnexo,lJobV2)

ENDIF


Return Nil





//Aviso de Vigência da Caução
Static Function V7BKGct06()

Local cQuery
Local _cAlias 	:= "QCN9"

Local cAssunto	:= "Aviso Vigência da Caução"
Local cEmail	:= "microsiga@bkconsultoria.com.br;gestao@bkconsultoria.com.br"
Local cEmailCC	:= ""
Local cMsg    	:= ""
Local cAnexo    := ""

Local aCabs		:= {}
Local aEmail	:= {}
Local nDiasVig  := 0
Local cAviso    := ""

If !lJobV2
	IncProc()
EndIf

IF !EMPTY(cEmailS)
   cEmail := ALLTRIM(cEmailS)+";"
ENDIF

cQuery := "SELECT CN9_NUMERO,CN9_REVISA,CN9_SITUAC,CTT_DESC01,CN9_XXNRBK,CN8_XXDTFV "

	cQuery += " FROM "+RETSQLNAME("CN9")+" CN9"

	cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CN9_NUMERO"
		cQuery += " AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"

	cQuery += " INNER JOIN "+RETSQLNAME("CN8")+ " CN8 ON CN8.D_E_L_E_T_='' AND  CN8_FILIAL = '"+xFilial("CN8")+"'"
			cQuery += " AND CN8_CONTRA=CN9_NUMERO AND CN8_REVISA=CN9_REVISA AND CN8_XXDTFV <> '' AND CN8_DTBX = '' "

	cQuery += " WHERE CN9.D_E_L_E_T_ = ' ' AND CN9_SITUAC = '05'"

	cQuery += " ORDER BY CN9_XXNRBK,CTT_DESC01"  

TCQUERY cQuery NEW ALIAS "QCN9"

TCSETFIELD("QCN9","CN8_XXDTFV","D",8,0)


(_cAlias)->(dbgotop())

Do While (_cAlias)->(!eof())

	If !EMPTY((_cAlias)->CN8_XXDTFV)
		nDiasVig  := (_cAlias)->CN8_XXDTFV - DATE()
	
		If nDiasVig = 30 .OR. nDiasVig = 60 .OR. nDiasVig = 90

	    	cAviso := "Vigência da caução com termino em "+ALLTRIM(STR(nDiasVig,4))+" dias"
	
			//"Contrato","Revisao","Descr. CC","Responsavel","Vigência Caução","Data Aviso","Aviso"
	  		AADD(aEmail,{(_cAlias)->CN9_NUMERO,;
			   		(_cAlias)->CN9_REVISA,;
	    	   		(_cAlias)->CTT_DESC01,;
	    	   		(_cAlias)->CN9_XXNRBK,;
	    	   		(_cAlias)->CN8_XXDTFV,;
	    	   		DATE(),;
					cAviso})
	
		EndIf
	EndIf   
	(_cAlias)->(dbskip())
EndDo

QCN9->(Dbclosearea())

IF LEN(aEmail) > 0

	aCabs   := {"Contrato","Revisao","Descr.CC","Responsavel","Vig.Caução","Data Aviso","Aviso"}

	cMsg    := u_GeraHtmA(aEmail,cAssunto+" - "+DTOC(DATE())+" "+TIME(),aCabs,"V7BKGct06")

	U_SendMail("V7BKGct06",cAssunto,cEmail,cEmailCC,cMsg,cAnexo,lJobV2)

ENDIF


Return Nil




//Aviso de Vencimento de Documento de Segurança do Trabalho
Static Function V8BKGct06()

Local cQuery
Local _cAlias 	:= "QCN9"

Local cAssunto	:= "Aviso Venc. Documento de Segurança do Trabalho"
Local cEmail	:= "microsiga@bkconsultoria.com.br;gestao@bkconsultoria.com.br"
Local cEmailCC	:= ""
Local cMsg    	:= ""
Local cAnexo    := ""
Local aCabs		:= {}
Local aEmail	:= {}
Local nDiasVig  := 0
Local cAviso    := ""

If !lJobV2
	IncProc()
EndIf

IF !EMPTY(cEmailS)
   cEmail := ALLTRIM(cEmailS)+";"
ENDIF

cQuery := "SELECT CN9_NUMERO,CN9_REVISA,CN9_SITUAC,CTT_DESC01,CN9_XXNRBK,CN9_XXDVST,CN9_XXSVST,CN9_XXHVST,CN9.R_E_C_N_O_ AS XXRECNO "

	cQuery += " FROM "+RETSQLNAME("CN9")+" CN9"

	cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CN9_NUMERO"
		cQuery += " AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"

	cQuery += " WHERE CN9.D_E_L_E_T_ = ' ' AND CN9_SITUAC = '05' AND CN9_XXPVST <> '2'"

	cQuery += " ORDER BY CN9_XXNRBK,CTT_DESC01"  

TCQUERY cQuery NEW ALIAS "QCN9"

TCSETFIELD("QCN9","CN9_XXDVST","D",8,0)


(_cAlias)->(dbgotop())

Do While (_cAlias)->(!eof())
    
	cAviso := ""
	If !EMPTY((_cAlias)->CN9_XXDVST)
		nDiasVig  := (_cAlias)->CN9_XXDVST - DATE()
		If nDiasVig = 3 .OR. nDiasVig = 30 .OR. nDiasVig = 60 .OR. nDiasVig = 90
	    	cAviso := "Vence em "+ALLTRIM(STR(nDiasVig,4))+" dias"
		ElseIf nDiasVig < 1	    	
	    	cAviso := "Vencido em "+DTOC(CN9_XXDVST)
	 	EndIf
	Else
    	cAviso := "Venc. não informado"
	EndIf

	If !EMPTY(cAviso)	
		//"Contrato","Revisao","Descr.CC","Responsavel","Doc. Seg. Trab","Data","Aviso"

  		AADD(aEmail,{(_cAlias)->CN9_NUMERO,;
		   		(_cAlias)->CN9_REVISA,;
    	   		(_cAlias)->CTT_DESC01,;
    	   		(_cAlias)->CN9_XXNRBK,;
    	   		(_cAlias)->CN9_XXHVST,;
    	   		DATE(),;
				cAviso})

		dbSelectArea("CN9")   
		dbGoto(QCN9->XXRECNO)
		
		RecLock("CN9",.F.)
		CN9->CN9_XXSVST := DTOC(DATE())+" "+cAviso
		MsUnlock()
		dbSelectArea(_cAlias)   

	EndIf   
	(_cAlias)->(dbskip())
EndDo

QCN9->(Dbclosearea())

IF LEN(aEmail) > 0

	aCabs   := {"Contrato","Revisao","Descr.CC","Responsavel","Doc. Seg. Trab","Data","Aviso"}

	cMsg    := u_GeraHtmA(aEmail,cAssunto+" - "+DTOC(DATE())+" "+TIME(),aCabs,"V8BKGct06")

	U_SendMail("V8BKGct06",cAssunto,cEmail,cEmailCC,cMsg,cAnexo,lJobV2)

ENDIF


Return Nil


//Aviso de pedido de compras aguardando aprovação
Static Function V9BKGct06()

Local cQuery            
Local _cAlias 	:= "QSCR"
Local aArea      := GetArea()
Local cAssunto	:= "Aviso de pedido de compras aguardando aprovação"
Local cEmail	:= "microsiga@bkconsultoria.com.br;"
Local cEmailCC	:= ""
Local cMsg    	:= ""
Local cAnexo    := ""
Local aCabs		:= {}
Local aEmail	:= {}
Local aUser     := {}

Local cGerGestao := ALLTRIM(GetMv("MV_XXGGCT"))
Local nRegSM0 := SM0->(Recno()) 

If FWCodEmp() <> "01"
	CONOUT("V9BKGct06: Esta Funcao Rodar somente na empresa 01")
	Return Nil
EndIf

CONOUT("V9BKGct06: Inicio Processo - Aviso de pedido de compras aguardando aprovação")

If !lJobV2
	IncProc()
EndIf

IF !EMPTY(cEmailS)
   cEmail := ALLTRIM(cEmailS)+";"
ENDIF


PswOrder(1) 
PswSeek(SUBSTR(cGerGestao,1,6)) 
aUser  := PswRet(1)
IF !EMPTY(aUser[1,14]) .AND. !aUser[1][17]
	cEmail += ALLTRIM(aUser[1,14])+';'
ENDIF                                                                                                


SM0->(DbGoTop())
While SM0->(!EoF())

 	If !lJobV2
		IncProc()
	EndIf   

	If SM0->M0_CODIGO == "99" //.OR. SM0->M0_CODIGO $ getmv("MV_XNSLDS") 
		SM0->(DbSKip())
		Loop
	EndIf


	cQuery := "SELECT CR_NUM,CTT_CUSTO,CTT_DESC01,CR_TOTAL,C1_SOLICIT,C7_FORNECE,A2_NOME "
	cQuery += " FROM SCR"+SM0->M0_CODIGO+"0 SCR"
	cQuery += " INNER JOIN SC7"+SM0->M0_CODIGO+"0 SC7 ON SC7.D_E_L_E_T_='' AND C7_NUM = CR_NUM"
	cQuery += " INNER JOIN SC1"+SM0->M0_CODIGO+"0 SC1 ON SC1.D_E_L_E_T_='' AND C7_NUMSC = C1_NUM"
	cQuery += " INNER JOIN SA2"+SM0->M0_CODIGO+"0 SA2 ON SA2.D_E_L_E_T_='' AND C7_FORNECE = A2_COD"
	cQuery += " INNER JOIN CTT"+SM0->M0_CODIGO+"0 CTT ON CTT.D_E_L_E_T_='' AND C7_CC = CTT_CUSTO
	cQuery += "  WHERE SCR.D_E_L_E_T_='' AND CR_USER='"+SUBSTR(cGerGestao,1,6)+"' AND CR_USERLIB='' AND CR_TIPO = 'PC'"
	cQuery += " GROUP BY CR_NUM,CTT_CUSTO,CTT_DESC01,CR_TOTAL,C1_SOLICIT,C7_FORNECE,A2_NOME"

	TCQUERY cQuery NEW ALIAS "QSCR"

	(_cAlias)->(dbgotop())

	Do While (_cAlias)->(!eof())
    
  			AADD(aEmail,{ALLTRIM(SM0->M0_NOME),;
  						(_cAlias)->CR_NUM,;
		   				(_cAlias)->CTT_CUSTO,;
    	   				(_cAlias)->CTT_DESC01,;
    	   				(_cAlias)->CR_TOTAL,;
    	   				(_cAlias)->C1_SOLICIT,;
		   				(_cAlias)->C7_FORNECE,;
   	   					(_cAlias)->A2_NOME})

		(_cAlias)->(dbskip())
	EndDo

	(_cAlias)->(Dbclosearea())

	SM0->(dbSkip())
ENDDO

SM0->(dbGoTo(nRegSM0))


IF LEN(aEmail) > 0

	aCabs   := {"Empresa","Pedido N°","Centro Custo","Descrição C.Custo","Valor Total","Solicitante","Cod.Fornecedor","Nome Fornecedor"}

	cMsg    := u_GeraHtmA(aEmail,cAssunto+" - "+DTOC(DATE())+" "+TIME(),aCabs,"V9BKGct06")

	U_SendMail("V9BKGct06",cAssunto,cEmail,cEmailCC,cMsg,cAnexo,lJobV2)

ENDIF

CONOUT("V9BKGct06: Fim Processo - Aviso de pedido de compras aguardando aprovação")

RestArea(aArea)

Return Nil 


//Aviso de pedido de compras não entregue
Static Function V10BKGct06()

Local cQuery            
Local _cAlias 	:= "QSC7"
Local aArea      := GetArea()
Local cAssunto	:= "Aviso de pedido de compras não entregue"
Local cEmail	:= "microsiga@bkconsultoria.com.br;"
Local cEmailCC	:= ""
Local cMsg    	:= ""
Local cAnexo    := ""
Local aCabs		:= {}
Local aEmail	:= {}
Local aUser     := {}
Local nRegSM0 := SM0->(Recno()) 


If FWCodEmp() <> "01"
	CONOUT("V10BKGct06: Esta Funcao Rodar somente na empresa 01")
	Return Nil
EndIf

CONOUT("V10BKGct06: Inicio Processo - Aviso de pedido de compras não entregue")

If !lJobV2
	IncProc()
EndIf

IF !EMPTY(cEmailS)
   cEmail := ALLTRIM(cEmailS)+";"
ENDIF

//EMAIL - GRUPO DE COMPRAS
SY1->(dbgotop())
Do While SY1->(!eof())                                                                                                               
	PswOrder(1) 
	PswSeek(SY1->Y1_USER) 
	aUser  := PswRet(1)
	IF !EMPTY(aUser[1,14]) .AND. !aUser[1][17]
		cEmail += ALLTRIM(aUser[1,14])+';'
	ENDIF
	SY1->(dbskip())
Enddo


SM0->(DbGoTop())
While SM0->(!EoF())

 	If !lJobV2
		IncProc()
	EndIf   

	If SM0->M0_CODIGO == "99" //.OR. SM0->M0_CODIGO $ getmv("MV_XNSLDS") 
		SM0->(DbSKip())
		Loop
	EndIf

	cQuery := "Select C7_NUM,C7_DATPRF,C7_FORNECE,A2_NOME,C1_SOLICIT,CTT_CUSTO,CTT_DESC01 "
	cQuery += " From SC7"+SM0->M0_CODIGO+"0 SC7"
	cQuery += " INNER join SC1"+SM0->M0_CODIGO+"0 SC1 ON SC1.D_E_L_E_T_='' AND C7_NUMSC =C1_NUM"
	cQuery += " INNER join SA2"+SM0->M0_CODIGO+"0 SA2 ON SA2.D_E_L_E_T_='' AND C7_FORNECE =A2_COD"
	cQuery += " INNER join CTT"+SM0->M0_CODIGO+"0 CTT ON CTT.D_E_L_E_T_='' AND C7_CC =CTT_CUSTO
	cQuery += "  WHERE SC7.D_E_L_E_T_=''  AND C7_RESIDUO='' AND C7_QUJE<C7_QUANT "
	cQuery += " GROUP BY C7_NUM,C7_DATPRF,C7_FORNECE,A2_NOME,C1_SOLICIT,CTT_CUSTO,CTT_DESC01 "
	cQuery += " ORDER BY C7_NUM,C7_DATPRF,C7_FORNECE,A2_NOME,C1_SOLICIT,CTT_CUSTO,CTT_DESC01 "
	
	TCQUERY cQuery NEW ALIAS "QSC7"
	TCSETFIELD("QSC7","C7_DATPRF","D",8,0)

	(_cAlias)->(dbgotop())

	Do While (_cAlias)->(!eof())
	
		IF DATE() - QSC7->C7_DATPRF > 2 
    
  			AADD(aEmail,{ALLTRIM(SM0->M0_NOME),;
   	   					(_cAlias)->C7_NUM,;
   	   					(_cAlias)->C7_DATPRF,;
   	   					(_cAlias)->C7_FORNECE,;
   	   					(_cAlias)->A2_NOME,;
   	   					(_cAlias)->C1_SOLICIT,;
   	   					(_cAlias)->CTT_CUSTO,;
   	   					(_cAlias)->CTT_DESC01})
   	   	ENDIF

		(_cAlias)->(dbskip())
	EndDo

	(_cAlias)->(Dbclosearea())

	SM0->(dbSkip())
ENDDO
SM0->(dbGoTo(nRegSM0))


IF LEN(aEmail) > 0

	aCabs   := {"Empresa","Pedido N°","Data de Entrega","Cod.Fornecedor","Nome Fornecedor","Solicitante","Centro Custo","Descrição C.Custo"}

	cMsg    := u_GeraHtmA(aEmail,cAssunto+" - "+DTOC(DATE())+" "+TIME(),aCabs,"V10BKGct06")

	U_SendMail("V10BKGct06",cAssunto,cEmail,cEmailCC,cMsg,cAnexo,lJobV2)

ENDIF

CONOUT("V10BKGct06: Fim Processo - Aviso de pedido de compras não entregue")

RestArea(aArea)

Return Nil


//Aviso de Solicitacao de compra em aberto
Static Function V11BKGct06()

Local cQuery            
Local _cAlias 	:= "QSC1"
Local aArea      := GetArea()
Local cAssunto	:= "Aviso de solicitação de compras em aberto"
Local cEmail	:= "microsiga@bkconsultoria.com.br;"
Local cEmailCC	:= ""
Local cMsg    	:= ""
Local aCabs		:= {}
Local aEmail	:= {}
Local aUser     := {}
Local nRegSM0 := SM0->(Recno()) 
Local cPath     := "\tmp\"
Local cCrLf   := Chr(13) + Chr(10)


If FWCodEmp() <> "01"
	CONOUT("V11BKGct06: Esta Funcao Rodar somente na empresa 01")
	Return Nil
EndIf

CONOUT("V11BKGct06: Inicio Processo - Aviso de solicitação de compras em aberto")


If !lJobV2
	IncProc()
EndIf

IF !EMPTY(cEmailS)
   cEmail := ALLTRIM(cEmailS)+";"
ENDIF

//EMAIL - GRUPO DE COMPRAS
SY1->(dbgotop())
Do While SY1->(!eof())                                                                                                               
	PswOrder(1) 
	PswSeek(SY1->Y1_USER) 
	aUser  := PswRet(1)
	IF !EMPTY(aUser[1,14]) .AND. !aUser[1][17]
		cEmail += ALLTRIM(aUser[1,14])+';'
	ENDIF
	SY1->(dbskip())
Enddo


SM0->(DbGoTop())
While SM0->(!EoF())

 	If !lJobV2
		IncProc()
	EndIf   

	If SM0->M0_CODIGO == "99" //.OR. SM0->M0_CODIGO $ getmv("MV_XNSLDS") 
		SM0->(DbSKip())
		Loop
	EndIf

	cQuery := "Select C1_SOLICIT,C1_EMISSAO,C1_DATPRF,C1_NUM,C1_ITEM,C1_PRODUTO,B1_DESC,C1_UM,C1_QUANT,C1_QUJE,C1_CC,CTT_DESC01"
	cQuery += " From SC1"+SM0->M0_CODIGO+"0 SC1"
	cQuery += " INNER join SB1"+SM0->M0_CODIGO+"0 SB1 ON SB1.D_E_L_E_T_='' AND B1_COD =C1_PRODUTO"
	cQuery += " INNER join CTT"+SM0->M0_CODIGO+"0 CTT ON CTT.D_E_L_E_T_='' AND C1_CC =CTT_CUSTO"
	cQuery += " LEFT JOIN SC8"+SM0->M0_CODIGO+"0 SC8 ON SC8.D_E_L_E_T_='' AND C8_NUM=C1_COTACAO AND C8_ITEMSC=C1_ITEM"
	cQuery += " WHERE SC1.D_E_L_E_T_=''"  
	cQuery += " AND C1_RESIDUO='' AND C1_APROV<>'B'"
	cQuery += " AND C1_QUJE<C1_QUANT "
	cQuery += " AND C8_NUMSC IS NULL"
	cQuery += " GROUP BY C1_NUM,C1_ITEM,C1_SOLICIT,C1_EMISSAO,C1_DATPRF,C1_PRODUTO,B1_DESC,C1_UM,C1_QUANT,C1_QUJE,C1_CC,CTT_DESC01" 
	cQuery += " ORDER BY C1_NUM,C1_ITEM,C1_SOLICIT,C1_EMISSAO,C1_DATPRF,C1_PRODUTO,B1_DESC,C1_UM,C1_QUANT,C1_QUJE,C1_CC,CTT_DESC01"
 
	
	TCQUERY cQuery NEW ALIAS "QSC1"
	TCSETFIELD("QSC1","C1_EMISSAO","D",8,0)
	TCSETFIELD("QSC1","C1_DATPRF","D",8,0)

	(_cAlias)->(dbgotop())

	Do While (_cAlias)->(!eof())
	
 		IF DATE() - QSC1->C1_EMISSAO > 7 // Alterado de 2 para 7, a pedido da Sra. Michele Moraes em 31/01/2019 
  			AADD(aEmail,{ALLTRIM(SM0->M0_NOME),;
   	   					(_cAlias)->C1_SOLICIT,;
   	   					(_cAlias)->C1_EMISSAO,;
   	   					(_cAlias)->C1_DATPRF,;
   	   					(_cAlias)->C1_NUM,;
   	   					(_cAlias)->C1_ITEM,;
   	   					(_cAlias)->C1_PRODUTO,;
   	   					(_cAlias)->B1_DESC,;
   	   					(_cAlias)->C1_UM,;
   	   					(_cAlias)->C1_QUANT,;
   	   					(_cAlias)->C1_QUJE,;
   	   					(_cAlias)->C1_CC,;
   	   					(_cAlias)->CTT_DESC01}) 
   	 	ENDIF

		(_cAlias)->(dbskip())
	EndDo

	(_cAlias)->(Dbclosearea())

	SM0->(dbSkip())
ENDDO
SM0->(dbGoTo(nRegSM0))

CONOUT("V11BKGct06: Emails: "+cEmail)

IF LEN(aEmail) > 0

	cArqS := "V11BKGct06"+ALLTRIM(SM0->M0_NOME)

	_cArqSv  := cPath+cArqS+".csv"

	IF lJobV2
		cDirTmp   := ""
		_cArqS    := cPath+cArqS+".csv"
	ELSE
		cDirTmp   := "C:\TMP"
		_cArqS    := cDirTmp+"\"+cArqS+".csv"
	ENDIF

	IF !EMPTY(cDirTmp)
   		MakeDir(cDirTmp)
	ENDIF   
 
	fErase(_cArqS)

	nHandle := MsfCreate(_cArqS,0)
   
	If nHandle > 0
      
		aCabs   := {"Empresa","Solicitante","Emissao","Limite Entrega","Solicitação N°","Item","Cod. Produto","Desc. Produto","Unidade","Quantidade","Qnt. Entregue","Contrato","Descrição Contrato"}
  		FOR _ni := 1 TO LEN(aCabs)
       		fWrite(nHandle, aCabs[_ni] + IIF(_ni < LEN(aCabs),";",""))
   		NEXT
   		fWrite(nHandle, cCrLf ) // Pula linha
   		FOR _ni := 1 TO LEN(aEmail)
   	    	cLinha :=     aEmail[_ni,01]+";"+aEmail[_ni,02]+";"+DTOC(aEmail[_ni,03])+";"+DTOC(aEmail[_ni,04])+";"+aEmail[_ni,05]+;
   	        	      ";"+aEmail[_ni,06]+";"+aEmail[_ni,07]+";"+aEmail[_ni,08]+";"+aEmail[_ni,09]+";"+STR(aEmail[_ni,10],6)+;
   	           		  ";"+STR(aEmail[_ni,11],6)+";"+aEmail[_ni,12]+";"+aEmail[_ni,13]
  			fWrite(nHandle, cLinha+cCrLf ) // Pula linha
   		NEXT

		If nHandle > 0
			fClose(nHandle)
			If lJobV2
				ConOut(cPrw+": Exito ao criar "+_cArqs )
			Else   
				lOk := CpyT2S( _cArqs , cPath, .T. )
			EndIf

			aCabs   := {"Arquivo"}
			aEmail  := {}
			AADD(aEmail,{"Segue arquivo anexo"})
	   		cMsg    := u_GeraHtmA(aEmail,cAssunto+" - "+DTOC(DATE())+" "+TIME(),aCabs ,"V11BKGct06")
       	
			U_SendMail("V11BKGct06",cAssunto,cEmail,cEmailCC,cMsg,_cArqSv,lJobV2)

		Else
			fClose(nHandle)
			If lJobV2
				ConOut("Falha na criação do arquivo "+_cArqS)
			Else	
				MsgAlert("Falha na criação do arquivo "+_cArqS)
   	 		Endif    
		Endif
	ENDIF
ENDIF

CONOUT("V11BKGct06: Fim Processo - Aviso de solicitação de compras em aberto")

RestArea(aArea)

Return Nil


//Aviso de pedido de venda em aberto
Static Function V12BKGct06()

Local cQuery            
Local _cAlias 	:= "QSC5"
Local aArea      := GetArea()
Local cAssunto	:= "Aviso de pedido de venda em aberto"
Local cEmail	:= "microsiga@bkconsultoria.com.br;"
Local cEmailCC	:= ""
Local cMsg    	:= ""
Local cAnexo    := ""
Local aCabs		:= {}
Local aEmail	:= {}
Local nRegSM0 := SM0->(Recno()) 


If FWCodEmp() <> "01"
	CONOUT("V12BKGct06: Esta Funcao Rodar somente na empresa 01")
	Return Nil
EndIf

CONOUT("V12BKGct06: Inicio Processo - Aviso de pedido de venda em aberto")

If !lJobV2
	IncProc()
EndIf

IF !EMPTY(cEmailS)
   cEmail := ALLTRIM(cEmailS)+";"
ENDIF



SM0->(DbGoTop())
While SM0->(!EoF())

 	If !lJobV2
		IncProc()
	EndIf   

	If SM0->M0_CODIGO == "99" //.OR. SM0->M0_CODIGO $ getmv("MV_XNSLDS") 
		SM0->(DbSKip())
		Loop
	EndIf

	cQuery := "Select C5_NUM,C7_DATPRF,C5_CLIENTEFORNECE,A2_NOME,C1_SOLICIT,CTT_CUSTO,CTT_DESC01 "
	cQuery += " From SC7"+SM0->M0_CODIGO+"0 SC7"
	cQuery += " INNER join SC1"+SM0->M0_CODIGO+"0 SC1 ON SC1.D_E_L_E_T_='' AND C7_NUMSC =C1_NUM"
	cQuery += " INNER join SA2"+SM0->M0_CODIGO+"0 SA2 ON SA2.D_E_L_E_T_='' AND C7_FORNECE =A2_COD"
	cQuery += " INNER join CTT"+SM0->M0_CODIGO+"0 CTT ON CTT.D_E_L_E_T_='' AND C7_CC =CTT_CUSTO
	cQuery += "  WHERE SC7.D_E_L_E_T_=''  AND C7_RESIDUO='' AND C7_QUJE<C7_QUANT "
	cQuery += " GROUP BY C7_NUM,C7_DATPRF,C7_FORNECE,A2_NOME,C1_SOLICIT,CTT_CUSTO,CTT_DESC01 "
	cQuery += " ORDER BY C7_NUM,C7_DATPRF,C7_FORNECE,A2_NOME,C1_SOLICIT,CTT_CUSTO,CTT_DESC01 "
	
	TCQUERY cQuery NEW ALIAS "QSC7"
	TCSETFIELD("QSC7","C7_DATPRF","D",8,0)

	(_cAlias)->(dbgotop())

	Do While (_cAlias)->(!eof())
	
		IF DATE() - QSC7->C7_DATPRF > 2 
    
  			AADD(aEmail,{ALLTRIM(SM0->M0_NOME),;
   	   					(_cAlias)->C7_NUM,;
   	   					(_cAlias)->C7_DATPRF,;
   	   					(_cAlias)->C7_FORNECE,;
   	   					(_cAlias)->A2_NOME,;
   	   					(_cAlias)->C1_SOLICIT,;
   	   					(_cAlias)->CTT_CUSTO,;
   	   					(_cAlias)->CTT_DESC01})
   	   	ENDIF

		(_cAlias)->(dbskip())
	EndDo

	(_cAlias)->(Dbclosearea())

	SM0->(dbSkip())
ENDDO
SM0->(dbGoTo(nRegSM0))


IF LEN(aEmail) > 0

	aCabs   := {"Empresa","Pedido N°","Data de Entrega","Cod.Fornecedor","Nome Fornecedor","Solicitante","Centro Custo","Descrição C.Custo"}

	cMsg    := u_GeraHtmA(aEmail,cAssunto+" - "+DTOC(DATE())+" "+TIME(),aCabs,"V12BKGct06")

	U_SendMail("V12BKGct06",cAssunto,cEmail,cEmailCC,cMsg,cAnexo,lJobV2)

ENDIF

CONOUT("V12BKGct06: Fim Processo - Aviso de Pedido de venda em aberto")

RestArea(aArea)

Return Nil






Static Function CabV5()
Local aHtm := {}
AADD(aHtm,'<table width="100%" Align="center" border="1" cellspacing="0" cellpadding="0" bordercolor="#CCCCCC" >')
AADD(aHtm,'  <tr bgcolor="#dfdfdf">')
AADD(aHtm,'    <td width="30%" class="F10A"><b>Cliente</b></td>')
AADD(aHtm,'    <td width="10%" class="F10A"><b>Contrato</b></td>')
AADD(aHtm,'    <td width="05%" class="F10A"><b>Rev</b></td>')
AADD(aHtm,'    <td width="30%" class="F10A"><b>Descr. CC</b></td>')
AADD(aHtm,'    <td width="15%" class="F10A"><b>Responsavel</b></td>')
AADD(aHtm,'    <td width="05%" class="F10A"><b>Insumos Operacionais</b></td>')
AADD(aHtm,'  </tr>')
Return aHtm
