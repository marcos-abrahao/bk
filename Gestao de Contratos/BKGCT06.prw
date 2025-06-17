#INCLUDE "PROTHEUS.CH"
#include "TOTVS.CH"
#INCLUDE "RWMAKE.CH"
//#include "TBICONN.CH"
//#include "AP5MAIL.CH"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} BKGCT06
BK - Avisos automaticos de Repactua��o de contratos e Compras
@Return
@author Marcos Bispo Abrah�o
@since 13/09/2010
@version P12
/*/


/*
Static Function Scheddef()
Local aParam
Local aOrd     := {}


aParam := {	"P",;		//Tipo R para relatorio P para processo   
			"PARAMDEF",;// Pergunte do relatorio, caso nao use passar ParamDef            
			"",;		// Alias            
			aOrd}		//Array de ordens   
//			"PowerBk"}

Return aParam
*/

// Fun��o via Schedule
User Function BKGCT06(aParam)

//Local cFwEmp := ""

Public cPrw      := "BKGCT06"
Public cEmailS   := ""
Public cContrRep := SPACE(15)
Public dtIni     := CTOD("")
Public dtFim     := CTOD("")

Private lExp     := .F.
Private dDataEnv := DATE()
Private cEmpPar  := "01"
Private cFilPar  := "01"

default aParam := {"01","01"} // caso nao receba nenhum parametro

cEmpPar := aParam[1]
cFilPar := aParam[2]

//-- Evita que se consuma licenca
RpcSetType ( 3 )
RpcSetEnv(cEmpPar,cFilPar)
//WFPrepEnv(cEmpPar,cFilPar,"BKGCT06",{"CN9"},"GCT")

u_MsgLog("BKGCT06","Inicio Processo - "+FWCodEmp())

//cFWEmp := cEmpPar //cEmpAnt //SUBSTR(FWCodEmp(),1,2)

If FWCodEmp() == "01" .OR. FWCodEmp() == "20" // Barcas
	u_WaitLog("V9BKGct06", {|| V9BKGct06()}  ,"Processando avisos de pedidos de compras aguardando aprova��o")
	//u_WaitLog("BKMSG008",  {|| u_BKMSG008()} ,"Processando avisos de pedidos de compras n�o entregues")
	//u_WaitLog("BKMSG009",  {|| u_BKMSG009()} ,"Processando aviso de Solicita��o de compras em aberto")
	// Desabilitado em 22/05/2024 - substituido por BKMSG007
	//u_WaitLog("V15BKGct06", {|| V15BKGct06()} ,"Processando Aviso de lan�amentos em contratos vencidos")
EndIf

IF DOW(dDataEnv) = 3 .OR. DOW(dDataEnv) = 5
	u_WaitLog("VigBKGCT06",{|| VigBKGCT06()} ,"Processando avisos de termino de vigencia 1")
	u_WaitLog("Vg2BKGct06",{|| Vg2BKGct06()} ,"Processando avisos de termino de vigencia 2")

	// Habilitado em 05/12/23
	u_WaitLog("V5BKGct06", {|| V5BKGct06()}  ,"Processando avisos de Insumos Operacionais")
	u_WaitLog("V6BKGct06", {|| V6BKGct06()}  ,"Processando avisos de Atestado de Capacidade T�cnica")
	u_WaitLog("V7BKGct06", {|| V7BKGct06()}  ,"Processando avisos de Vig�ncia da Cau��o")
	u_WaitLog("V8BKGct06", {|| V8BKGct06()}  ,"Processando avisos de Doc. Seguran�a do Trabalho")

	u_WaitLog("RepBKGCT06",{|| RepBKGCT06()},"Processando avisos de repactua��o")
	u_WaitLog("RepBK06b",  {|| RepBK06b()}  ,"Processando avisos de repactua��o - Detalhado")

ENDIF


/*
If cFWEmp $ "01/02/14" 
	u_WaitLog("GRFBKGCT11", {|| U_GRFBKGCT11(.T.)} ,"Processando Grafico Rentabilidade dos Contratos")
	u_WaitLog("BKGCTR23", {|| U_BKGCTR23()} ,"Processando Dados do Dashboard - Funcion�rios e Glosas")
ENDIF
*/

u_MsgLog("BKGCT06","Final Processo - "+FWCodEmp())

RpcClearEnv()
//Reset Environment

RETURN


// Func�o via tela

User Function BKGCT06A(aParam)

Local aUser
Local cRel       := 1
Local aRel       := {"01-Aviso de contratos pendentes de repactua��o",;
                     "02-Aviso de t�rmino de vig�ncia de contratos",;
                     "03-Alerta de t�rmino de vig�ncia de contratos",;
                     "04-Aviso de repactua��o - Detalhado",;
                     "05-Aviso de Insumos Operacionais",;
                     "06-Aviso de Atestado Capacidade T�cnica",;
                     "07-Aviso de Vig�ncia da Cau��o",;
                     "08-Aviso de Venc. Doc. Seguran�a do Trabalho",;
                     "09-Aviso de pedido de compras aguardando aprova��o",;
                     "10-Aviso de pedido de compras n�o entregue",;
                     "11-Aviso de solicita��o de compras em aberto",;
                     "12-Aviso de pedido de venda em aberto",;
                     "13-Funcionario Dashbord",;
                     "14-Rentabilidade Dashbord",;
                     "15-Aviso de Lan�. em contratos vencidos",;
					 "16-PowerBk - Atualizar tabelas"}

Private lExp     := .F.
Private dDataEnv := DATE()

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

@ 45,015 SAY "Relat�rio:"     SIZE 080,008 Pixel Of oDlg1
@ 45,065 MSCOMBOBOX oComboBo1 VAR cRel ITEMS aRel SIZE 150, 008 OF oDlg1 COLORS 0, 16777215 PIXEL

@ 60,015 SAY "Contrato:" SIZE 080,008 Pixel Of oDlg1
@ 60,065 GET cContrRep SIZE  40,10 F3 "CN9" WHEN WhenRepB(cRel)
@ 75,065 SAY "(campo contrato branco = enviar com filtro, contrato = 'T' = Todos)"

@ 85,015 SAY "Per�odo:" SIZE 080,008 Pixel Of oDlg1
@ 85,065 GET dtIni Picture "@E" Size 040,008 Pixel WHEN WhenRepB(cRel) .AND. UPPER(SUBSTR(cContrRep,1,1)) = "T" Of oDlg1
@ 85,110 SAY "at�" SIZE 10,008 Pixel Of oDlg1
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

u_MsgLog("BKGCT06","Avisos automaticos. (Dialogo)")

IF VALTYPE(cRel) == "N"
   cRel := STRZERO(cRel,2)
ENDIF                        
IF SUBSTR(cRel,1,2) = "01"
   u_WaitLog("REPBKGCT06", {|| REPBKGCT06() } )
ELSEIF SUBSTR(cRel,1,2) = "02"   
   u_WaitLog("VigBKGct06", {|| VigBKGct06() } )
ELSEIF SUBSTR(cRel,1,2) = "03"   
   u_WaitLog("Vg2BKGct06", {|| Vg2BKGct06() } )
ELSEIF SUBSTR(cRel,1,2) = "04"   
   u_WaitLog("RepBK06b", {|| RepBK06b() } )
ELSEIF SUBSTR(cRel,1,2) = "05"   
   u_WaitLog("V5BKGct06", {|| V5BKGct06() } )
ELSEIF SUBSTR(cRel,1,2) = "06"   
   u_WaitLog("V6BKGct06", {|| V6BKGct06() } )
ELSEIF SUBSTR(cRel,1,2) = "07"   
   u_WaitLog("V7BKGct06", {|| V7BKGct06() } )
ELSEIF SUBSTR(cRel,1,2) = "08"   
   u_WaitLog("V8BKGct06", {|| V8BKGct06() } )
ELSEIF SUBSTR(cRel,1,2) = "09"   
   u_WaitLog("V9BKGct06", {|| V9BKGct06() } )
ELSEIF SUBSTR(cRel,1,2) = "10"   
   u_WaitLog("BKMSG008", {|| u_BKMSG008() } )
ELSEIF SUBSTR(cRel,1,2) = "11"
   u_WaitLog("BKMSG009", {|| u_BKMSG009() } )
ELSEIF SUBSTR(cRel,1,2) = "12"
   // N�o Existe
ELSEIF SUBSTR(cRel,1,2) = "13"
   u_WaitLog("BKGCTR23", {|| U_BKGCTR23() } )
ELSEIF SUBSTR(cRel,1,2) = "14"
   u_WaitLog("GRFBKGCT11", {|| U_GRFBKGCT11(.T.) } )
ELSEIF SUBSTR(cRel,1,2) = "15"
   u_WaitLog("BKMSG007", {|| U_BKMSG007() } )
ELSEIF SUBSTR(cRel,1,2) = "16"
   U_BKDASH01()
ENDIF 

Close(oDlg1)
Return


Static FUNCTION P1BKGCT06()
// Emails para o aviso de Repactua��o de Contatos - MODELO 1

cEmailTO := u_EmMGestao()
cEmailCC := ""
// Email quando a rotina � chamada pela tela
IF !EMPTY(cEmailS)
   cEmailTO := ALLTRIM(cEmailS)+";"
ENDIF
RETURN



// Contratos a Repactuar
/*
Base de dados: contratos ativos e em elabora��o
1- Se o campo "Data Repac" (CN9_XXDREP) estiver em branco, mostra o status�"Data de repactua��o n�o definida".
2-�Enviar sempre email 30 dias antes, independente do status.
3- Enviar sempre email 27 dias antes, independente do status.
4-�Enviar sempre email 10 dias antes, independente do status.
5-�Enviar sempre quando faltar menos de 10 dias (e ap�s) quando o status for = 1-Atrasado.
6-�Enviar quando a data de repactua��o for diferente da data de controle "Data Aviso" e antes de 30 dias da "Data de Repactua��o" ou depois da "Data de Repactua��o".
7- Enviar quando o status for diferente de 1 (Atrasado) e a quantidade de dias faltantes for m�ltipla de 10.
8- Enviar sempre quando o status for = 5-Pedido enviado o aviso "Redefinir a data da Repactua��o".
9- Se ocorrer qualquer uma das situa��es de envio anteriores e a data de controle for diferente da data de repactua��o:
    Gravar a data de controle = a data de repactua��o e mudar o status para 1-Atrasado.


Tabela de Status:
1-Atrasado
2-Em an�lise
3-Aguardando retorno do cliente
4-Em analise cliente
5-Pedido enviado
6-Finalizado
7-Aguardando decis�o diretoria
8-Contrato encerrado
9-Em analise gest�o
*/

Static Function REPBKGCT06()

Local cPath     := u_STmpDir()
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
//Local aStatus := {"Atrasado","Em Processo - Gest�o","Aguardando retorno do cliente","Em Analise - Gest�o","Finalizado"}
Local aStatus := {"1-Atrasado",;                        // Status 1
                  "2-Em an�lise "+FWEmpName(cEmpAnt),;  //        2 
                  "3-Aguardando retorno do cliente",;   //        3
                  "4-Em analise cliente",;              //        4
                  "5-Pedido enviado",;                  //        5
                  "6-Finalizado",;                      //        6
                  "7-Aguardando decis�o diretoria",;    //        7
                  "8-Contrato encerrado",;              //        8
                  "9-Em analise gest�o"}                //        9

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
AADD(aCabs  ,"Descri��o")

AADD(aCampos,"QCN9->CN9_XXDVIG")
AADD(aCabs  ,"Vigencia")

AADD(aCampos,"cAviso")
AADD(aCabs  ,"Aviso")

AADD(aCampos,"QCN9->CN9_XXDREP")
AADD(aCabs  ,"Repactua��o")

AADD(aCampos,"QCN9->CN9_XXOREP")
AADD(aCabs  ,"Obs Repactua��o")

AADD(aCampos,"cStatus")
AADD(aCabs  ,"Status")

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

u_LogTxt("REPBKGCT06.SQL",cQuery)

// Cabe�alho do Email
aHtm := CabHtml("Contratos a Repactuar")   
FOR _ni := 1 TO LEN(aHtm)
   cMsg += aHtm[_ni]
NEXT

aHtm := CabR()   
FOR _ni := 1 TO LEN(aHtm)
   cMsg += aHtm[_ni]
NEXT


//------------------

cArqS := "BKGCT06_"+STRTRAN(FWEmpName(cEmpAnt)," ","")

_cArqSv  := cPath+cArqS+".csv"

IF IsBlind()
	cDirTmp   := ""
	_cArqS    := cPath+cArqS+".csv"
ELSE
	cDirTmp   := u_LTmpDir()
	_cArqS    := cDirTmp+cArqS+".csv"
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
		
		lEnv   := .F.
		cAviso := ""
		cStatus:= ""
		nDias  := 0 
        
		// 1- Se o campo "Data Repac" (CN9_XXDREP) estiver em branco, mostra o status�"Data de repactua��o n�o definida".
		If QCN9->CN9_XXSREP > 0 .AND. QCN9->CN9_XXSREP <= LEN(aStatus) 
          cStatus := aStatus[QCN9->CN9_XXSREP]
        EndIf

		If EMPTY(QCN9->CN9_XXDREP)
		    cAviso:= "Data de repactua��o nao definida"
			lEnv := .T.
		Else
			nDias  := QCN9->CN9_XXDREP - DATE()
			
			// 2-�Enviar sempre email 30 dias antes, independente do status.
			If nDias = 30
				lEnv := .T.
			EndIf

			// 3- Enviar sempre email 27 dias antes, independente do status.
			If nDias = 27
				lEnv := .T.
			EndIf

			// 4- Enviar sempre email 10 dias antes, independente do status.
			If nDias = 10
				lEnv := .T.
			EndIf
			
			// 5- Enviar sempre quando faltar menos de 10 dias (e ap�s) quando o status for = 1-Atrasado.
            If nDias < 10 .AND. QCN9->CN9_XXSREP = 1
               lEnv := .T.
            EndIf
            

			// 6- Enviar quando a data de repactua��o for diferente da data de controle "Data Aviso" e antes de 30 dias da "Data de Repactua��o" ou depois da "Data de Repactua��o".
            If !lEnv .AND. QCN9->CN9_XXDREP <> QCN9->CN9_XXDAVI
               If nDias <= 30 .AND. nDias > 0
                  lEnv := .T.
               EndIf
            EndIf

			// 7- Enviar quando o status for diferente de 1 (Atrasado) e a quantidade de dias for m�ltipla de 10.
			If nDias < 0 .AND. QCN9->CN9_XXSREP <> 1
				If MOD(ABS(nDias),10) = 0
					lEnv := .T.
				EndIf
            EndIf
            
            If lEnv
		    	cAviso:= "Repactua��o em "+ALLTRIM(STR(nDias,4))+" dias"
            EndIf

			// 8- Enviar sempre quando o status for = 5-Pedido enviado o aviso "Redefinir a data da Repactua��o"
            If QCN9->CN9_XXSREP = 5
            	lEnv := .T.
		    	cAviso:= "Redefinir a data da Repactua��o"
            EndIf
		EndIf

		dbSelectArea("CN9")   
		dbGoto(QCN9->XXRECNO)
		
		If lEnv
	   		lEmail := .T.
			RecLock("CN9",.F.)
			// 9- Se ocorrer qualquer uma das situa��es de envio anteriores e a data de controle for diferente da data de repactua��o:
    		//	Gravar a data de controle = a data de repactua��o e mudar o status para 1-Atrasado.
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

    
	If IsBlind()
		u_MsgLog(cPrw,"Exito ao criar "+_cArqs,"E")
	Else   
		lOk := CpyT2S( _cArqs , cPath, .T. )
	EndIf

Else
	u_MsgLog(cPrw,"Falha na cria��o do arquivo "+_cArqs,"E")
Endif
   
QCN9->(Dbclosearea())

// Cabe�alho do Email
aHtm := FimHtml("BKGCT06")   
FOR _ni := 1 TO LEN(aHtm)
   cMsg += aHtm[_ni]
NEXT
//------------------

cAssunto := "Aviso de repactua��o - "+FWEmpName(cEmpAnt)

If lEmail

	// Carrega as variaveis cEmailTO e cEmailCC
	P1BKGCT06()
	
	// Envia o Email
	u_BkSnMail("BKGCT06",cAssunto,cEmailTO,cEmailCC,cMsg,{_cArqSv},.T.)
	
EndIf

Return Nil


//=============================================
//  "Aviso de termino de vig�ncia de contratos"

Static Function VigBKGct06()
Local cPath     := u_STmpDir()
Local nHandle
Local cCrLf     := Chr(13) + Chr(10)
Local _ni,_nj
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
Local aStatus := u_StProrrog()
Local nDiasVig:= 0
Local lEmail  := .F.

Private cEmailTO := ""
Private cEmailCC := ""

Public cVigencia := ""

u_MsgLog("VigBKGCT06","Aviso de termino de vig�ncia de contratos")

aCabs   := {}
aCampos := {}
    
aFHtm := { {}, {}, {}, {}, {} }
aFTxt := { {}, {}, {}, {}, {} }
aCabH := {"m�s atual","pr�ximo m�s","60 dias","90 dias","at� 45 dias (RH)"}

// ALERTA autom�tico DE VENCIMENTO DE CONTRATO ( M�S VIGENTE )
// ALERTA autom�tico DE VENCIMENTO DE CONTRATO ( PR�XIMO M�S )
// ALERTA autom�tico DE VENCIMENTO DE CONTRATO ( 45 DIAS - Controle Depto RH )
// ALERTA autom�tico DE VENCIMENTO DE CONTRATO ( 60 DIAS )
// ALERTA autom�tico DE VENCIMENTO DE CONTRATO ( 90 DIAS )

 
// Cliente
// Contrato
// Objeto
// Valor
// Vigencia

AADD(aCampos,"QCN9->CN9_NUMERO")
AADD(aCabs  ,"Contrato")

AADD(aCampos,"QCN9->CTT_DESC01")
AADD(aCabs  ,"Contrato")

AADD(aCampos,"QCN9->A1_NREDUZ")
AADD(aCabs  ,"Cliente")

AADD(aCampos,"U_CN9OBJ(QCN9->CN9_CODOBJ)")
AADD(aCabs  ,"Objeto")

AADD(aCampos,"QCN9->CN9_VLATU")
AADD(aCabs  ,"Valor")

AADD(aCampos,"cVigencia")
AADD(aCabs  ,"Vigencia")


cQuery := " SELECT CN9_NUMERO,CN9_REVISA,CN9_DTINIC,CN9_XXDVIG,CN9_SITUAC,CTT_DESC01,CN9_XCLIEN,CN9_XLOJA,A1_NREDUZ,CN9_CODOBJ,CN9_VLATU,CN9.R_E_C_N_O_ AS XXRECNO "
cQuery += " FROM "+RETSQLNAME("CN9")+" CN9"

cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CN9_NUMERO"
cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON A1_COD = CN9_XCLIEN AND A1_LOJA = CN9_XLOJA"
cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '"

cQuery += " WHERE CN9_SITUAC IN ('02','05') AND CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY A1_NREDUZ,CTT_DESC01"  

TCQUERY cQuery NEW ALIAS "QCN9"
TCSETFIELD("QCN9","CN9_DTINIC","D",8,0)
TCSETFIELD("QCN9","CN9_XXDVIG","D",8,0)


(_cAlias)->(dbgotop())
   
Do While (_cAlias)->(!eof())

	// Buscar o periodo de vigencia dos contratos
	dVigI   := QCN9->CN9_DTINIC
	dVigF   := QCN9->CN9_XXDVIG

	/*
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
	*/

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
    
// ALERTA autom�tico DE VENCIMENTO DE CONTRATO ( 45 DIAS - Controle Depto RH )
// ALERTA autom�tico DE VENCIMENTO DE CONTRATO ( 60 DIAS )
// ALERTA autom�tico DE VENCIMENTO DE CONTRATO ( 90 DIAS )
       
	If nEnv > 0 .OR. lEnvRH
	
         lEmail := .T.

         cVigencia := "De: "+DTOC(dVigI)+" At�: "+DTOC(dVigF)
         
         cMsg := ""
       
         cMsg += '<td width="10%" class="F10A">'+TRIM(QCN9->CN9_NUMERO)+'</td>'
         cMsg += '<td width="23%" class="F10A">'+TRIM(QCN9->CTT_DESC01)+'</td>'
         cMsg += '<td width="15%" class="F10A">'+TRIM(QCN9->A1_NREDUZ)+'</td>'
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

cArqS := "BKGCT06V_"+STRTRAN(FWEmpName(cEmpAnt)," ","")

_cArqSv  := cPath+cArqS+".csv"

IF IsBlind()
	cDirTmp   := ""
	_cArqS    := cPath+cArqS+".csv"
ELSE
	cDirTmp   := u_LTmpDir()
	_cArqS    := cDirTmp+cArqS+".csv"
ENDIF

IF !EMPTY(cDirTmp)
   MakeDir(cDirTmp)
ENDIF   
 
fErase(_cArqS)

nHandle := MsfCreate(_cArqS,0)

cMsg:= ""
cTxt:= ""
For _nj := 1 to 5
	// Cabe�alho do Email
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

	// Rodap� do Email
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
	If IsBlind()
		u_MsgLog(cPrw,"Exito ao criar "+_cArqs,"E")
	Else   
		lOk := CpyT2S( _cArqs , cPath, .T. )
	EndIf

Else
	fClose(nHandle)
	u_MsgLog(cPrw,"Falha na cria��o do arquivo "+_cArqs,"E")
Endif
   
QCN9->(Dbclosearea())


//------------------

cAssunto := "Aviso de termino de vig�ncia de contratos - "+FWEmpName(cEmpAnt)

If lEmail

	// Carrega as variaveis cEmailTO e cEmailCC
	P1BKGCT06()     
	
	// Envia o email
	u_BkSnMail("BKGCT06",cAssunto,cEmailTO,cEmailCC,cMsg,{_cArqSv},.T.)
EndIf
	
Return Nil


// Alerta de Termino de vigencia, pela data informada pelos gestores - solicitado pelo Bruno Santiago em 20/05/11

Static Function Vg2BKGct06()
//���������������������������������������������������������������������Ŀ
//  "Alerta de t�rmino de vigencia de contratos"
//�����������������������������������������������������������������������
Local cPath     := u_STmpDir()
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

u_MsgLog("Vg2BKGct06","Alerta de t�rmino de vigencia de contratos")

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

cQuery := " SELECT CN9_NUMERO,CN9_REVISA,CN9_DTINIC,CN9_SITUAC,CTT_DESC01,CN9_XXNRBK,CN9_XXDVIG,CN9_XXPROA,"
cQuery += " CN9_XCLIEN,CN9_XLOJA,A1_NOME,CN9_CODOBJ,CN9_VLATU,CN9.R_E_C_N_O_ AS XXRECNO "
cQuery += " FROM "+RETSQLNAME("CN9")+" CN9"

cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CN9_NUMERO"
cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON A1_COD = CN9_XCLIEN AND A1_LOJA = CN9_XLOJA"
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

cArqS := "BKGCT6V2_"+STRTRAN(FWEmpName(cEmpAnt)," ","")

_cArqSv  := cPath+cArqS+".csv"

IF IsBlind()
	cDirTmp   := ""
	_cArqS    := cPath+cArqS+".csv"
ELSE
	cDirTmp   := u_LTmpDir()
	_cArqS    := cDirTmp+cArqS+".csv"
ENDIF

IF !EMPTY(cDirTmp)
   MakeDir(cDirTmp)
ENDIF   
 
fErase(_cArqS)

nHandle := MsfCreate(_cArqS,0)

cMsg:= ""
cTxt:= ""

// Cabe�alho do Email
aHtm := CabHtml("Alerta de t�rmino de vigencia de contratos")   
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

// Rodap� do Email
aHtm := FimHtml("BKGCT06")   
FOR _ni := 1 TO LEN(aHtm)
   cMsg += aHtm[_ni]
NEXT

If nHandle > 0
	      
   fWrite(nHandle, "Alerta de t�rmino de vigencia de contratos"+cCrLf)
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
	If IsBlind()
		u_MsgLog(cPrw,"Exito ao criar "+_cArqs,"E")
	Else   
		lOk := CpyT2S( _cArqs , cPath, .T. )
	EndIf

Else
	fClose(nHandle)
	u_MsgLog(cPrw,"Falha na cria��o do arquivo "+_cArqs,"E")
Endif
   
QCN9->(Dbclosearea())


//------------------

cAssunto := "Alerta de t�rmino de vigencia de contratos - "+FWEmpName(cEmpAnt)
  
// -- Carrega as variaveis cEmailTO e cEmailCC
P1BKGCT06()

u_BkSnMail("BKGCT06",cAssunto,cEmailTO,cEmailCC,cMsg,{_cArqSv},.T.)

Return Nil



Static Function CabHtml(cTitulo)
Local aHtm := {}

AADD(aHtm,'<html>')
AADD(aHtm,'<head>')
AADD(aHtm,'<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">')
AADD(aHtm,'<link rel=Edit-Time-Data href="./HistD_arquivos/editdata.mso">')
AADD(aHtm,'<title>'+cTitulo+' - '+DTOC(date())+' '+TIME()+'</title>')
AADD(aHtm,u_BkFavIco())
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
/*
If FWCodEmp() == "01"      // BK
	AADD(aHtm,'    <p align=center style="text-align:center">'+u_BKLogo()+'</p>')
ElseIf FWCodEmp() == "02"  // HF
	AADD(aHtm,'    <p align=center style="text-align:center"><b><span style="font-size:22.0pt;color:skyblue">MMDK</span></b></p>')
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
ElseIf FWCodEmp() == "12"  // BK CORRETORA
	AADD(aHtm,'    <p align=center style="text-align:center"><img src="http://www.bkseguros.com.br/wp-content/uploads/2017/04/bk-consultoria-seguros-logo.png" border=0></p>')
ElseIf FWCodEmp() == "14"  // CONSORCIO NOVA BALSA
	AADD(aHtm,'    <p align=center style="text-align:center"><b><span style="font-size:22.0pt;color:skyblue">CONSORCIO NOVA BALSA</span></b></p>')
ElseIf FWCodEmp() == "15"  // BHG INTERIOR 3
	AADD(aHtm,'    <p align=center style="text-align:center"><b><span style="font-size:22.0pt;color:skyblue">BHG INTERIOR 3</span></b></p>')
ElseIf FWCodEmp() == "16"  // MOOVE
	AADD(aHtm,'    <p align=center style="text-align:center"><b><span style="font-size:22.0pt;color:skyblue">MOOVE</span></b></p>')
ElseIf FWCodEmp() == "17"  // DMAF
	AADD(aHtm,'    <p align=center style="text-align:center"><b><span style="font-size:22.0pt;color:skyblue">DMAF</span></b></p>')
ElseIf FWCodEmp() == "18"  // BK VIA
	AADD(aHtm,'    <p align=center style="text-align:center"><b><span style="font-size:22.0pt;color:skyblue">BK VIA</span></b></p>')
ElseIf FWCodEmp() == "19"  // BK SOL TEC
	AADD(aHtm,'    <p align=center style="text-align:center"><b><span style="font-size:22.0pt;color:skyblue">BK SOL TEC</span></b></p>')
ElseIf FWCodEmp() == "20"  // BARCAS RIO
	AADD(aHtm,'    <p align=center style="text-align:center">'+u_BKLogos()+'</p>')
Endif	
*/

AADD(aHtm,'    <p align=center style="text-align:center">'+u_BKLogos()+'</p>')
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
AADD(aHtm,'    <td width="30%" class="F10A"><b>Descri��o</b></td>')
AADD(aHtm,'    <td width="20%" class="F10A"><b>Aviso</b></td>')
AADD(aHtm,'    <td width="10%" class="F10A"><b>Repactua��o</b></td>')
AADD(aHtm,'    <td width="15%" class="F10A"><b>Observa�oes</b></td>')
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
//AADD(aHtm,'Observa��es:')
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
	AADD(aHtm,'<br><p class="F8A">Origem: '+TRIM(cPrw)+' '+DTOC(DATE())+' '+TIME()+' - '+FWEmpName(cEmpAnt)+'</p>') 
EndIf
AADD(aHtm,'</body>')
AADD(aHtm,'</html>')
Return aHtm


Static Function FimHtmlB(cPrw)
Local aHtm := {}
Default cPrw := ""

If !EMPTY(cPrw) 
	AADD(aHtm,'<br><p class="F8A">Origem: '+TRIM(cPrw)+' '+DTOC(DATE())+' '+TIME()+' - '+FWEmpName(cEmpAnt)+'</p>') 
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

//���������������������������������������������������������������������Ŀ
//� Contratos a Repactuar - Detalhado
//�����������������������������������������������������������������������
Local cPath     := u_STmpDir()
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
//Local aStatus := {"Atrasado","Em Processo - Gest�o","Aguardando retorno do cliente","Em Analise - Gest�o","Finalizado"}
Local aStatus := {"1-Atrasado",;                        // Status 1
                  "2-Em an�lise "+FWEmpName(cEmpAnt),;  //        2 
                  "3-Aguardando retorno do cliente",;   //        3
                  "4-Em analise cliente",;              //        4
                  "5-Pedido enviado",;                  //        5
                  "6-Finalizado",;                      //        6
                  "7-Aguardando decis�o diretoria",;    //        7
                  "8-Contrato encerrado",;              //        8
                  "9-Em analise gest�o"}                //        9
Local dDVig
Local lEmail := .F. 

Private cEmailTO := ""
Private cEmailCC := ""

Public cAviso  := ""
Public cStatus := ""
Public nValFat := 0

u_MsgLog("RepBK06b","Contratos a Repactuar - Detalhado")

aCabs   := {}
aCampos := {}
 
AADD(aCampos,"QCN9->CN9_NUMERO")
AADD(aCabs  ,"Contrato")

AADD(aCampos,"QCN9->CN9_REVISA")
AADD(aCabs  ,"Revisao")

AADD(aCampos,"QCN9->CTT_DESC01")
AADD(aCabs  ,"Descri��o")

AADD(aCampos,"QCN9->CN9_XXDVIG")
AADD(aCabs  ,"Vigencia")

AADD(aCampos,"cAviso")
AADD(aCabs  ,"Aviso")

AADD(aCampos,"QCN9->CN9_XXDREP")
AADD(aCabs  ,"Repactua��o")

AADD(aCampos,"QCN9->CN9_XXDTPD")
AADD(aCabs  ,"Data Pedido Repactua��o")

AADD(aCampos,"QCN9->CN9_XXVPED")
AADD(aCabs  ,"Valor Pedido Repactua��o")

AADD(aCampos,"nValFat")
AADD(aCabs  ,"Valor Faturamento M�s Atual")

AADD(aCampos,"QCN9->CN9_XXOREP")
AADD(aCabs  ,"Obs Repactua��o")

AADD(aCampos,"cStatus")
AADD(aCabs  ,"Status")

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

// Ordem de data de repactua��o - solicitado por Bruno em 13/01/12
cQuery += " ORDER BY CN9_XXDREP,CN9_NUMERO,CN9_REVISA"  

TCQUERY cQuery NEW ALIAS "QCN9"
TCSETFIELD("QCN9","CN9_XXDREP","D",8,0)
TCSETFIELD("QCN9","CN9_XXDVIG","D",8,0)
TCSETFIELD("QCN9","CN9_XXDAVI","D",8,0)
TCSETFIELD("QCN9","CN9_XXDTPD","D",8,0) 

// Cabe�alho do Email
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

cArqS := "BKGCT06_"+STRTRAN(FWEmpName(cEmpAnt)," ","")

_cArqSv  := cPath+cArqS+".csv"

IF IsBlind()
	cDirTmp   := ""
	_cArqS    := cPath+cArqS+".csv"
ELSE
	cDirTmp   := u_LTmpDir()
	_cArqS    := cDirTmp+cArqS+".csv"
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
   
		lEnv   := .F.
		cAviso := ""
		cStatus:= ""
		nDias  := 0
        
		If QCN9->CN9_XXSREP > 0 .AND. QCN9->CN9_XXSREP <= LEN(aStatus) 
           cStatus := aStatus[QCN9->CN9_XXSREP]
        EndIf

		// 1- Se o campo "Data Repac" (CN9_XXDREP) estiver em branco, mostra o status�"Data de repactua��o n�o definida".
		If EMPTY(QCN9->CN9_XXDREP)
		    cAviso:= "Data de repactua��o nao definida"
			lEnv := .T.
		Else
			nDias  := QCN9->CN9_XXDREP - DATE()
			
			lSolicitar := .F.
			lAtrasado  := .F.  // Dedo duro
			
			// 2- Enviar sempre email 30 dias antes independente do status
			If nDias <= 30 .AND. nDias >= 0  
				lEnv := .T.
				lSolicitar := .T.
			EndIf
            
			// 3- Enviar quando a data de repactua��o for diferente da data de controle "Data Aviso" e antes de 30 dias da "Data de Repactua��o" ou depois da "Data de Repactua��o".
            If !lEnv .AND. QCN9->CN9_XXDREP <> QCN9->CN9_XXDAVI
               If nDias <= 30 .AND. nDias > 0
                  lEnv := .T.
               EndIf
            EndIf

			// 4- Enviar quando a quantidade de dias faltantes for m�ltipla de 10.
			If nDias < 0 .AND. QCN9->CN9_XXSREP <> 1
				If MOD(ABS(nDias),10) = 0
					lEnv := .T.
				EndIf
            EndIf
            
            If lEnv
		    	cAviso:= "Repactua��o em "+ALLTRIM(STR(nDias,4))+" dias"
            EndIf

            //If QCN9->CN9_XXSREP = 5
            //	lEnv := .T.
		    //	cAviso:= "Redefinir a data da Repactua��o"
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
			// 5- Se ocorrer qualquer uma das situa��es de envio anteriores e a data de controle for diferente da data de repactua��o:
            //    Gravar a data de controle = a data de repactua��o e mudar o status para 1-Atrasado.
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

         cMsg += '<td width="10%" class="F10A"><b>Descri��o:</b></td>'
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

         cMsg += '<td width="10%" class="F10A"><b>Repactua��o:</b></td>'
         cMsg += '<td width="10%" class="F10A">'+DTOC(QCN9->CN9_XXDREP)+'</td>'
         
         cMsg += '<td width="10%" class="F10A"><b>Observa��es:</b></td>'
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

         cMsg += '<td width="10%" class="F10A"><b>Data Pedido Repactua��o:</b></td>'
         cMsg += '<td width="10%" class="F10A">'+DTOC(QCN9->CN9_XXDTPD)+'</td>'
         
         cMsg += '<td width="10%" class="F10A"><b>Valor Pedido Repactua��o:</b></td>'
         cMsg += '<td width="30%" class="F10A">'+TRANSFORM(QCN9->CN9_XXVPED,"@E 999,999,999.99")+'</td>'
         
         cMsg += '<td width="10%" class="F10A"><b>Valor Faturamento M�s Atual:</b></td>'
         cMsg += '<td width="30%" class="F10A">'+TRANSFORM(nValFat,"@E 999,999,999.99")+'</td>'

         cMsg += '</tr>'

         // Hist�rico

         If lCorNao   
            cMsg += '<tr>'
         Else   
            cMsg += '<tr bgcolor="#dfdfdf">'
         EndIf   
         lCorNao := !lCorNao
         cMsg += '<td width="10%" class="F10AC"><b>Data</b></td>'
         cMsg += '<td colspan="5" width="90%" class="F10A"><b>Andamento da Repactua��o</b></td>'
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
            // N�o imprimir linhas em branco nem historicos com mais de 6 meses 
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

    
	If IsBlind()
		u_MsgLog(cPrw,"Exito ao criar "+_cArqs,"E")
	Else   
		lOk := CpyT2S( _cArqs , cPath, .T. )
	EndIf

Else
	u_MsgLog(cPrw,"Falha na cria��o do arquivo "+_cArqs,"E")
Endif
   
QCN9->(Dbclosearea())

// Cabe�alho do Email
aHtm := FimHtmlB("BKGCT06")   
FOR _ni := 1 TO LEN(aHtm)
   cMsg += aHtm[_ni]
NEXT
//------------------

cAssunto := "Aviso de repactua��o - Detalhado - "+FWEmpName(cEmpAnt)


IF lEmail
	// Carrega as variaveis cEmailTO e cEmailCC
	P1BKGCT06()
	
	// Envia o email
	u_BkSnMail("BKGCT06",cAssunto,cEmailTO,cEmailCC,cMsg,{_cArqSv},.T.)
ENDIF   

Return Nil



// Aviso de Insumos Operacionais, - solicitado pelo Bruno Santiago, Xavier e Paulo Rondini em 06/08/12

Static Function V5BKGct06()
//���������������������������������������������������������������������Ŀ
//  "Aviso de Insumos Operacionais"
//�����������������������������������������������������������������������
Local cPath     := u_STmpDir()
Local nHandle
Local cCrLf     := Chr(13) + Chr(10)
Local _ni,_X,_nj
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

u_MsgLog("V5BKGct06","Aviso de Insumos Operacionais")


aCabs   := {}
aCampos := {}
    
aFHtm := { {}, {}, {} }
aFTxt := {}
aCabH := {"m�s atual","60 dias","90 dias",}



 
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

cQuery := " SELECT CN9_NUMERO,CN9_REVISA,CN9_DTINIC,CN9_SITUAC,CTT_DESC01,CN9_XXNRBK,CN9_XXDVIG,CN9_XXPROA,"
cQuery += " CN9_XCLIEN,CN9_XLOJA,A1_NOME,CN9_CODOBJ,CN9_VLATU,CN9.R_E_C_N_O_ AS XXRECNO,"
cQuery += " CN9_XXUNI,CN9_XXUNID,CN9_XXUNIH,CN9_XXEPI,CN9_XXEPID,CN9_XXEPIH,CN9_XXMAT,CN9_XXMATD,CN9_XXMATH,CN9_XXEQP,CN9_XXEQPD,CN9_XXEQPH "

cQuery += " FROM "+RETSQLNAME("CN9")+" CN9"

cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CN9_NUMERO"
cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"

cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON A1_COD = CN9_XCLIEN AND A1_LOJA = CN9_XLOJA"
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

cArqS := "BKGCT6V5_"+STRTRAN(FWEmpName(cEmpAnt)," ","")

_cArqSv  := cPath+cArqS+".csv"

IF IsBlind()
	cDirTmp   := ""
	_cArqS    := cPath+cArqS+".csv"
ELSE
	cDirTmp   := u_LTmpDir()
	_cArqS    := cDirTmp+cArqS+".csv"
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
		// Cabe�alho do Email
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
	
		// Rodap� do Email
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

	If IsBlind()
		u_MsgLog(cPrw,"Exito ao criar "+_cArqs,"E")
	Else   
		lOk := CpyT2S( _cArqs , cPath, .T. )
	EndIf

Else
	fClose(nHandle)
    u_MsgLog(cPrw,"Falha na cria��o do arquivo "+_cArqS,"E")
Endif
   
QCN9->(Dbclosearea())


//------------------

cAssunto := "Aviso de Insumos Operacionais - "+FWEmpName(cEmpAnt)

// -- Carrega as variaveis cEmailTO e cEmailCC
P1BKGCT06()

u_BkSnMail("BKGCT06",cAssunto,cEmailTO,cEmailCC,cMsg,{_cArqSv},.T.)

Return Nil


//Aviso Atestado de Capacidade T�cnica
Static Function V6BKGct06()

Local cQuery
Local _cAlias 	:= "QCN9"

Local cAssunto	:= "Aviso Atestado de Capacidade T�cnica"
Local cEmail	:= u_EmMGestao()+";licita@bkconsultoria.com.br"
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

u_MsgLog("V6BKGct06",cAssunto)

IF !EMPTY(cEmailS)
   cEmail := ALLTRIM(cEmailS)+";"
ENDIF

cQuery := " SELECT CN9_NUMERO,CN9_REVISA,CN9_SITUAC,CTT_DESC01,CN9_XXNRBK,CN9_XXDSAT,"
cQuery += " CN9_XCLIEN,CN9_XLOJA,A1_NOME,CN9_DTINIC,(SELECT TOP 1 CNF_DTVENC FROM "+RETSQLNAME("CNF")+ " CNF "
cQuery += " WHERE CNF.D_E_L_E_T_='' AND  CNF_FILIAL = '"+xFilial("CNF")+"' AND CNF_CONTRA=CN9_NUMERO "
cQuery += " AND CNF_REVISA=CN9_REVISA ORDER BY CNF_DTVENC) AS CNF_DTVEN1,CN9_XXDVIG,"
cQuery += " (SELECT TOP 1 CNF_DTVENC FROM "+RETSQLNAME("CNF")+ " CNF WHERE CNF.D_E_L_E_T_='' AND "
cQuery += " CNF_FILIAL = '"+xFilial("CNF")+"' AND CNF_CONTRA=CN9_NUMERO "
cQuery += " AND CNF_REVISA=CN9_REVISA ORDER BY CNF_DTVENC DESC) AS CNF_DTVEN2,"
cQuery += " CN9_XXDAAT,CN9_XXTPAT,CN9_XXSTAT,CN9_XXDSTA,CN9_XXDENC,CN9.R_E_C_N_O_ AS CN9_RECNO  "

cQuery += " FROM "+RETSQLNAME("CN9")+" CN9"

cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CN9_NUMERO"
cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"

cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON A1_COD = CN9_XCLIEN AND A1_LOJA = CN9_XLOJA"
cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '"

cQuery += " WHERE CN9.D_E_L_E_T_ = ' ' AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"

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

	//	dVigI := (_cAlias)->CNF_DTVEN1
	//	dVigF := (_cAlias)->CNF_DTVEN2

	dVigI   := QCN9->CN9_DTINIC
	dVigF   := QCN9->CN9_XXDVIG


	cTPAT := ""
	IF (_cAlias)->CN9_XXTPAT=='1'
		cTPAT := "1� aviso +180 dias de contrato"
    ELSEIF (_cAlias)->CN9_XXTPAT=='2'
		cTPAT := "2� aviso +365 dias de contrato"
    ELSEIF (_cAlias)->CN9_XXTPAT=='3'
		cTPAT := "3- Renova��o do contrato"
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

 	ELSEIF DATE() > (dVigF+90) .AND. (_cAlias)->CN9_SITUAC == "08"
		lEnvia := .F.
	ENDIF
	     
	IF lEnvia
	    //1.	Contrato novo 1� aviso 180 dias d+1 do inicio 
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
				cTPAT := "1� aviso +180 dias de contrato"
				
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
					cTPAT := "1� aviso +180 dias de contrato"
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
	    //2� aviso +365 dias de contrato
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
				cTPAT := "2� aviso +365 dias de contrato"
				
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
					cTPAT := "2� aviso +365 dias de contrato"
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
	    //3- Renova��o do contrato
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
				cTPAT := "3- Renova��o do contrato"
				
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
	    			
						cTPAT := "3- Renova��o do contrato"
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

	cMsg    := u_GeraHtmB(aEmail,cAssunto+" - "+DTOC(DATE())+" "+TIME(),aCabs,"V6BKGct06","",cEmail,cEmailCC)

	cAnexo := "V6BKGct06.html"
	u_GrvAnexo(cAnexo,cMsg,.T.)

	u_BkSnMail("V6BKGct06",cAssunto,cEmail,cEmailCC,cMsg,{cAnexo},.T.)

ENDIF


Return Nil





//Aviso de Vig�ncia da Cau��o
Static Function V7BKGct06()

Local cQuery
Local _cAlias 	:= "QCN9"

Local cAssunto	:= "Aviso Vig�ncia da Cau��o"
Local cEmail	:= u_EmMGestao()
Local cEmailCC	:= ""
Local cMsg    	:= ""
Local cAnexo    := ""

Local aCabs		:= {}
Local aEmail	:= {}
Local nDiasVig  := 0
Local cAviso    := ""

u_MsgLog("V7BKGct06",cAssunto)

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

	    	cAviso := "Vig�ncia da cau��o com termino em "+ALLTRIM(STR(nDiasVig,4))+" dias"
	
			//"Contrato","Revisao","Descr. CC","Responsavel","Vig�ncia Cau��o","Data Aviso","Aviso"
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

	aCabs   := {"Contrato","Revisao","Descr.CC","Responsavel","Vig.Cau��o","Data Aviso","Aviso"}

	cMsg    := u_GeraHtmB(aEmail,cAssunto+" - "+DTOC(DATE())+" "+TIME(),aCabs,"V7BKGct06","",cEmail,cEmailCC)

	cAnexo := "V7BKGct06.html"
	u_GrvAnexo(cAnexo,cMsg,.T.)	

	U_BkSnMail("V7BKGct06",cAssunto,cEmail,cEmailCC,cMsg,{cAnexo},.T.)

ENDIF

Return Nil




//Aviso de Vencimento de Documento de Seguran�a do Trabalho
Static Function V8BKGct06()

Local cQuery
Local _cAlias 	:= "QCN9"

Local cAssunto	:= "Aviso Venc. Documento de Seguran�a do Trabalho"
Local cEmail	:= u_EmMGestao()
Local cEmailCC	:= ""
Local cMsg    	:= ""
Local cAnexo    := ""
Local aCabs		:= {}
Local aEmail	:= {}
Local nDiasVig  := 0
Local cAviso    := ""

u_MsgLog("V8BKGct06",cAssunto)

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
    	cAviso := "Venc. n�o informado"
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

	cMsg    := u_GeraHtmB(aEmail,cAssunto+" - "+DTOC(DATE())+" "+TIME(),aCabs,"V8BKGct06","",cEmail,cEmailCC)

	cAnexo := "V8BKGct06.html"
	u_GrvAnexo(cAnexo,cMsg,.T.)

	u_BkSnMail("V8BKGct06",cAssunto,cEmail,cEmailCC,cMsg,{cAnexo},.T.)

ENDIF


Return Nil


//Aviso de pedido de compras aguardando aprova��o
Static Function V9BKGct06()

Local cQuery            
Local _cAlias 	:= "QSCR"
Local aArea     := GetArea()
Local cAssunto	:= "Aviso de pedido de compras aguardando aprova��o"
Local cEmail	:= u_EmailAdm()
Local cEmailCC	:= ""
Local cMsg    	:= ""
Local cAnexo    := ""
Local aCabs		:= {}
Local aEmail	:= {}
//Local aUser     := {}
Local cPrw		:= "V9BKGct06"

Local cGerGestao := u_GerGestao()
Local aBKGrupo  := u_BKGrupo()
Local nE 		:= 0

u_MsgLog("V9BKGct06",cAssunto)

IF !EMPTY(cEmailS)
   cEmail := ALLTRIM(cEmailS)+";"
ENDIF

cEmail := u_EmMGestao()

For nE := 1 To Len(aBKGrupo)

	cQuery := "SELECT CR_NUM,CTT_CUSTO,CTT_DESC01,CR_TOTAL,C1_SOLICIT,C7_FORNECE,A2_NOME "
	cQuery += " FROM SCR"+aBKGrupo[nE,1]+"0 SCR"
	cQuery += " INNER JOIN SC7"+aBKGrupo[nE,1]+"0 SC7 ON SC7.D_E_L_E_T_='' AND C7_NUM = CR_NUM"
	cQuery += " INNER JOIN SC1"+aBKGrupo[nE,1]+"0 SC1 ON SC1.D_E_L_E_T_='' AND C7_NUMSC = C1_NUM"
	cQuery += " INNER JOIN SA2"+aBKGrupo[nE,1]+"0 SA2 ON SA2.D_E_L_E_T_='' AND C7_FORNECE = A2_COD"
	cQuery += " INNER JOIN CTT"+aBKGrupo[nE,1]+"0 CTT ON CTT.D_E_L_E_T_='' AND C7_CC = CTT_CUSTO
	cQuery += "  WHERE SCR.D_E_L_E_T_='' AND CR_USER='"+SUBSTR(cGerGestao,1,6)+"' AND CR_USERLIB='' AND CR_TIPO = 'PC'"
	cQuery += " GROUP BY CR_NUM,CTT_CUSTO,CTT_DESC01,CR_TOTAL,C1_SOLICIT,C7_FORNECE,A2_NOME"

	TCQUERY cQuery NEW ALIAS "QSCR"

	(_cAlias)->(dbgotop())

	Do While (_cAlias)->(!eof())
    
  			AADD(aEmail,{aBKGrupo[nE,3],;
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

Next

IF LEN(aEmail) > 0

	aCabs   := {"Empresa","N� Pedido","C.Custo","Descri��o C.Custo","Valor Total","Solicitante","Fornecedor","Nome Fornecedor"}

	cMsg    := u_GeraHtmB(aEmail,cAssunto+" - "+DTOC(DATE())+" "+TIME(),aCabs,cPrw,"",cEmail,cEmailCC)


	cAnexo := cPrw+".html"
	u_GrvAnexo(cAnexo,cMsg,.T.)	

	u_BkSnMail(cPrw,cAssunto,cEmail,cEmailCC,cMsg,{cAnexo},.T.)

ENDIF

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


//Aviso de lan�amentos de despesas em contratos vencidos
// Marcos - 22/04/2022
// Substituido pelo BKMSG007 em 22/05/2024
Static Function V15BKGCT06()

Local cQuery	:= ""            
Local aArea     := GetArea()
Local cAssunto	:= "Aviso de lan�amentos de despesas em contratos vencidos a mais de 60 dias"
Local cEmail	:= ""
Local cEmailCC	:= u_EmailAdm()
Local cMsg    	:= "Segue planilha anexa."
Local cPrw 		:= "V15BKGCT06"
Local nE		:= 0
Local aEmpresas := u_BKGrpDsp()
Local aCabs     := {}
Local aCampos   := {}
Local aTitulos  := {}
Local aPlans    := {}
Local cArqXls   := ""
Local cTabSZ2	:= "SZ2010"
Local cTabCNF   := ""
Local cTabSE2   := ""
Local cTabSD1   := ""
Local cTabSF1   := ""
Local cTabSB1   := ""
Local cTabCTT   := ""
Local dData		:= dDataBase - 60 // Solicitado pela F�bia em 17/02/23

cEmail += u_EmMGestao()

If FWCodEmp() <> "01"
	u_MsgLog(cPrw,"Executar somente na empresa 01","E")
	Return Nil
EndIf

u_MsgLog("V15BKGCT06",cAssunto)

cQuery := "WITH AVISO AS ( "+CRLF

For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabCNF := "CNF"+cEmpresa+"0"
	cTabSE2 := "SE2"+cEmpresa+"0"
	cTabSD1 := "SD1"+cEmpresa+"0"
	cTabSF1 := "SF1"+cEmpresa+"0"
	cTabSB1 := "SB1"+cEmpresa+"0"
	cTabCTT := "CTT"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += "SELECT "+CRLF
	cQuery += "    '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "    '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "    E2_VENCREA, "+CRLF
	cQuery += "    E2_EMIS1, "+CRLF
	cQuery += "    E2_PREFIXO, "+CRLF
	cQuery += "    E2_NUM, "+CRLF
	cQuery += "    E2_PARCELA, "+CRLF
	cQuery += "    ISNULL(Z2_CC, D1_CC) AS D1_CC, "+CRLF
	cQuery += "    CTT_DESC01, "+CRLF
	cQuery += "    ISNULL(D1_COD, 'RH') AS D1_COD, "+CRLF
	cQuery += "    ISNULL(Z2_NOME, B1_DESC) AS B1_DESC, "+CRLF
	cQuery += "    ISNULL(D1_TOTAL, Z2_VALOR) AS D1_TOTAL, "+CRLF

	cQuery += "    (SELECT SUM(D1_TOTAL) FROM "+cTabSD1+" SD1 WHERE D1_DOC = E2_NUM "+CRLF
	cQuery += "    		AND D1_SERIE = E2_PREFIXO "+CRLF
	cQuery += "    		AND D1_FORNECE = E2_FORNECE "+CRLF
	cQuery += "    		AND D1_LOJA = E2_LOJA "+CRLF
	cQuery += "    		AND D1_FILIAL = '"+xFilial("SD1")+"' AND SD1.D_E_L_E_T_ = '' ) AS D1TOTAL,"+CRLF

	cQuery += "    Z2_VALOR, "+CRLF
	cQuery += "    E2_VALOR, "+CRLF
	cQuery += "    F1_XXUSER, "+CRLF
	cQuery += "    ("+CRLF
	cQuery += "      SELECT "+CRLF
	cQuery += "        MAX(CNF_DTVENC) "+CRLF
	cQuery += "      FROM "+CRLF
	cQuery += "        "+cTabCNF+" CNF "+CRLF
	cQuery += "      WHERE "+CRLF
	cQuery += "        CNF_CONTRA = ISNULL(Z2_CC, D1_CC) "+CRLF
	If cEmpresa == '01' // Solicitado pela F�bia em 17/02/23
		cQuery += "    AND ISNULL(Z2_CC, D1_CC) <> '302000508'"+CRLF
	EndIf
	cQuery += "        AND CNF_FILIAL = '"+xFilial("CNF")+"' AND CNF.D_E_L_E_T_ = '' "+CRLF
	cQuery += "      GROUP BY "+CRLF
	cQuery += "        CNF_CONTRA"+CRLF
	cQuery += "    ) AS CNFDVIG "+CRLF

	cQuery += "  FROM "+CRLF
	cQuery += "    "+cTabSE2+" SE2 "+CRLF

	cQuery += "    LEFT JOIN "+cTabSZ2+" SZ2 ON Z2_CODEMP = '"+cEmpresa+"' "+CRLF
	cQuery += "    AND Z2_E2PRF = E2_PREFIXO "+CRLF
	cQuery += "    AND Z2_E2NUM = E2_NUM "+CRLF
	cQuery += "    AND Z2_E2PARC = E2_PARCELA "+CRLF
	cQuery += "    AND Z2_E2TIPO = E2_TIPO "+CRLF
	cQuery += "    AND Z2_E2FORN = E2_FORNECE "+CRLF
	cQuery += "    AND Z2_E2LOJA = E2_LOJA "+CRLF
	cQuery += "    AND SZ2.D_E_L_E_T_ = '' "+CRLF

	cQuery += "    LEFT JOIN "+cTabSD1+" SD1 ON D1_DOC = E2_NUM "+CRLF
	cQuery += "    AND D1_SERIE = E2_PREFIXO "+CRLF
	cQuery += "    AND D1_FORNECE = E2_FORNECE "+CRLF
	cQuery += "    AND D1_LOJA = E2_LOJA "+CRLF
	cQuery += "    AND D1_FILIAL = '"+xFilial("SD1")+"' AND SD1.D_E_L_E_T_ = '' "+CRLF

	cQuery += "    LEFT JOIN "+cTabSF1+" SF1 ON F1_DOC = D1_DOC "+CRLF
	cQuery += "    AND F1_SERIE = D1_SERIE "+CRLF
	cQuery += "    AND F1_FORNECE = D1_FORNECE "+CRLF
	cQuery += "    AND F1_LOJA = D1_LOJA "+CRLF
	cQuery += "    AND F1_FILIAL = D1_FILIAL AND SF1.D_E_L_E_T_ = '' "+CRLF

	cQuery += "    LEFT JOIN "+cTabSB1+" SB1 ON B1_COD = D1_COD "+CRLF
	cQuery += "    AND B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.D_E_L_E_T_ = '' "+CRLF

	cQuery += "    LEFT JOIN "+cTabCTT+" CTT ON CTT_CUSTO = ISNULL(D1_CC, Z2_CC) "+CRLF
	cQuery += "    AND CTT_FILIAL = '"+xFilial("CTT")+"' AND CTT.D_E_L_E_T_ = '' "+CRLF
	
	cQuery += "  WHERE "+CRLF
	cQuery += "    E2_VENCREA > '"+DTOS(dDataBase)+"' "+CRLF
	// 21/08/23 - Remover UNIAO - Bruno Bueno
	cQuery += "    AND SUBSTRING(E2_FORNECE,1,5) <> 'UNIAO' "+CRLF
	cQuery += "    AND E2_FILIAL = '"+xFilial("SE2")+"' AND SE2.D_E_L_E_T_ = ''"+CRLF
Next
cQuery += ") "+CRLF
cQuery += "SELECT "+CRLF
cQuery += "  *"+CRLF
cQuery += " ,ISNULL(Z2_VALOR,((D1_TOTAL / D1TOTAL) * 100 * (E2_VALOR / 100))) AS DESPESA "+CRLF
cQuery += "FROM "+CRLF
cQuery += "  AVISO "+CRLF
cQuery += "WHERE "+CRLF
cQuery += "  CNFDVIG <= '"+DTOS(dData)+"' "+CRLF
cQuery += "  OR SUBSTRING(D1_CC,1,1) = 'E' "+CRLF
cQuery += "ORDER BY "+CRLF
cQuery += "  E2_VENCREA,E2_NUM"+CRLF

//u_LogMemo("V15BKGCT06.SQL",cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QTMP",.T.,.T.)
tcSetField("QTMP","E2_EMIS1","D",8,0)
tcSetField("QTMP","E2_VENCREA","D",8,0)
tcSetField("QTMP","CNFDVIG","D",8,0)
tcSetField("QTMP","DESPESA","N",12,2)

AADD(aTitulos,cAssunto)

aAdd(aCampos,"QTMP->EMPRESA")
aAdd(aCabs  ,"Empresa")

aAdd(aCampos,"QTMP->NOMEEMP")
aAdd(aCabs  ,"Nome Empresa")

aAdd(aCampos,"QTMP->E2_VENCREA")
aAdd(aCabs  ,GetSX3Cache("E2_VENCREA", "X3_TITULO"))

aAdd(aCampos,"QTMP->E2_EMIS1")
aAdd(aCabs  ,GetSX3Cache("E2_EMIS1", "X3_TITULO"))

aAdd(aCampos,"QTMP->E2_PREFIXO")
aAdd(aCabs  ,GetSX3Cache("E2_PREFIXO", "X3_TITULO"))

aAdd(aCampos,"QTMP->E2_NUM")
aAdd(aCabs  ,GetSX3Cache("E2_NUM", "X3_TITULO"))

aAdd(aCampos,"QTMP->E2_PARCELA")
aAdd(aCabs  ,GetSX3Cache("E2_PARCELA", "X3_TITULO"))

aAdd(aCampos,"QTMP->D1_CC")
aAdd(aCabs  ,GetSX3Cache("D1_CC", "X3_TITULO"))

aAdd(aCampos,"QTMP->CTT_DESC01")
aAdd(aCabs  ,GetSX3Cache("CTT_DESC01", "X3_TITULO"))

aAdd(aCampos,"QTMP->CNFDVIG")
aAdd(aCabs  ,"Vig�ncia")

aAdd(aCampos,"QTMP->D1_COD")
aAdd(aCabs  ,GetSX3Cache("D1_COD", "X3_TITULO"))

aAdd(aCampos,"QTMP->B1_DESC")
aAdd(aCabs  ,GetSX3Cache("B1_DESC", "X3_TITULO"))

aAdd(aCampos,"QTMP->DESPESA")
aAdd(aCabs  ,"Despesa rateada")

aAdd(aCampos,"QTMP->D1_TOTAL")
aAdd(aCabs  ,"Total do item da NF")

aAdd(aCampos,"QTMP->D1TOTAL")
aAdd(aCabs  ,"Total geral da NF")

aAdd(aCampos,"QTMP->E2_VALOR")
aAdd(aCabs  ,GetSX3Cache("E2_VALOR", "X3_TITULO"))

aAdd(aCampos,"UsrRetName(QTMP->F1_XXUSER)")
aAdd(aCabs  ,GetSX3Cache("F1_XXUSER", "X3_TITULO"))

AADD(aPlans,{"QTMP",cPrw,"",aTitulos,aCampos,aCabs,/*aImpr1*/, /*aFormula*/,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
cArqXls := U_PlanXlsx(aPlans,cAssunto,cPrw,.F.)

u_BkSnMail(cPrw,cAssunto,cEmail,cEmailCC,cMsg,{cArqXls})

RestArea(aArea)

Return Nil


/*
//SEGUNDO AGENDAMENTO
// Fun��o via Schedule
User Function BKGCT062(aParam)

Local cFwEmp := ""

Public cPrw      := "BKGCT062"
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

cEmpPar := aParam[1]
cFilPar := aParam[2]

//-- Evita que se consuma licenca
//RpcSetType ( 3 )

//PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil MODULO "FAT" 

WFPrepEnv(cEmpPar,cFilPar,"BKGCT062",{"CN9"},"GCT")

//WFPrepEnv( <cEmpresa>, <cFilial>, <cFunname>, <aTabelas>, <cModulo>)
//TABLES "SA1" "SC5" "SC6" 

cFWEmp := SUBSTR(FWCodEmp(),1,2)

u_MsgLog(cPrw,aParam[1])
// Dashboard PowerBk
//If cFWEmp == "01" 
	//u_xxConOut("INFO","BKDASH01","Atualizando tabelas do banco de dados PowerBk")
	U_BKDASH01()
//EndIf

Reset Environment

RETURN
*/


//UPDATE SX3010 SET X3_BROWSE = ' ' WHERE X3_CAMPO IN ('CN9_DTASSI','CN9_XXDASS','CN9_VIGE  ','CN9_DTOSER','CN9_UNVIGE','CN9_DTFIM ','CN9_MOEDA ','CN9_CONDPG','CN9_TPCTO ','CN9_VLINI ','CN9_VLATU ','CN9_INDICE','CN9_FLGREJ','CN9_FLGCAU','CN9_MINCAU','CN9_DTENCE','CN9_TIPREV','CN9_REVATU','CN9_MOTPAR','CN9_DTFIMP','CN9_DTREIN','CN9_OBJCTO','CN9_DTREV ','CN9_XNOMRV','CN9_DTREAJ','CN9_VLREAJ','CN9_VLADIT','CN9_NUMTIT','CN9_ALTCLA','CN9_JUSTIF','CN9_VLMEAC','CN9_TXADM ','CN9_FORMA ','CN9_DTENTR','CN9_LOCENT','CN9_DESLOC','CN9_DESFIN','CN9_CONTFI','CN9_DTINPR','CN9_PERPRO','CN9_UNIPRO','CN9_VLRPRO','CN9_DTPROP','CN9_DTULST','CN9_DTINCP','CN9_END   ','CN9_MUN   ','CN9_BAIRRO','CN9_DESCRI','CN9_EST   ','CN9_ALCISS','CN9_INSSMO','CN9_INSSME','CN9_XXEGC ','CN9_XXIDTV','CN9_XXDREP','CN9_XXPOST','CN9_XXFUNC','CN9_XXDSAT','CN9_ASSINA','CN9_DREFRJ','CN9_ESPCTR','CN9_DEPART','CN9_APROV ','CN9_PROXAV','CN9_VLDCTR','CN9_USUAVA','CN9_PROGRA','CN9_ULTAVA','CN9_DTVIGE','CN9_DESC  ','CN9_GRPAPR','CN9_NUMATA','CN9_LOGDAT','CN9_LOGHOR','CN9_LOGUSR','CN9_PERI  ','CN9_UNPERI','CN9_MODORJ','CN9_PRORAT','CN9_PROREV','CN9_PROPOS','CN9_PROXRJ','CN9_XREGP ')
