#Include "Protheus.ch"
#include "rwmake.ch"
#include "TBICONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKGPEA01
OSESP - Rotina Importar Cadastro de Funcionáros 
@Return
@author Adilson do Prado
@since 13/03/2024
@version P12
/*/
//-------------------------------------------------------------------
USER Function BKGPEA01()
Local cTipoArq := "Arquivos XLSX |*.XLSX| Arquivos XLS|*.XLS"
Local cTitulo  := "Importar planilha para Cadastro de Funcionáros"
Local oDlg01
Local oButSel
Local nOpcA := 0
Local nSnd:= 15,nTLin := 15

Private cArq  := ""
Private cProg := "BKGPEA01"
Private cCrLf := Chr(13) + Chr(10)

If FWCodEmp() <> "90"
    MSGINFO("Rotina da empresa 90")
    RETURN NIL
ENDIF


DEFINE MSDIALOG oDlg01 FROM  96,9 TO 220,392 TITLE OemToAnsi(cProg+" - "+cTitulo) PIXEL

@ nSnd,010  SAY "Arquivo: " of oDlg01 PIXEL 
@ nSnd,035  MSGET cArq SIZE 100,010 of oDlg01 PIXEL READONLY
@ nSnd,142 BUTTON oButSel PROMPT 'Selecionar' SIZE 40, 12 OF oDlg01 ACTION ( cArq := cGetFile(cTipoArq,"Selecione o diretório contendo os arquivos",,cArq,.T.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY,.F.,.T.)  ) PIXEL  // "Selecionar" 
nSnd += nTLin
nSnd += nTLin

DEFINE SBUTTON FROM nSnd, 125 TYPE 1 ACTION (oDlg01:End(),nOpcA:=1) ENABLE OF oDlg01
DEFINE SBUTTON FROM nSnd, 155 TYPE 2 ACTION (oDlg01:End(),,nOpcA:=0) ENABLE OF oDlg01


ACTIVATE MSDIALOG oDlg01 CENTER

If nOpcA == 1
	nOpcA:=0
	Processa( {|| PBKGPEA01() })
Endif

RETURN NIL


STATIC FUNCTION PBKGPEA01()
	LOCAL aSRA      := {}
 	LOCAL nLinha    := 0
 	LOCAL nTLin   	:= 0
 	LOCAL nTCol  	:= 0
 	LOCAL nPlan 	:= 1
	LOCAL lPlan 	:= .T.
 	LOCAL oExcel	:= YExcel():new()
    Local lRet      := .T.

    PRIVATE lMsErroAuto := .F.

   
	aSRA := {}		
	DO while lPlan

		lPlan := oExcel:OpenRead(cArq,nPlan)
 		nTLin  := oExcel:adimension[1][1]
 		nTCol  := oExcel:adimension[1][2]
		ProcRegua(nTLin)
		IF lPlan
			FOR nLinha	:= 2 to nTLin
				IncProc("Lendo a planilha...")
                IF oExcel:CellRead(nLinha,1) <> NIL
                    AADD(aSRA,{ oExcel:CellRead(nLinha,1),;
                                oExcel:CellRead(nLinha,2),;
                                oExcel:CellRead(nLinha,3),;
                                oExcel:CellRead(nLinha,4),;
                                oExcel:CellRead(nLinha,5),;
                                oExcel:CellRead(nLinha,6),;
                                oExcel:CellRead(nLinha,7),;
                                oExcel:CellRead(nLinha,8),;
                                oExcel:CellRead(nLinha,9),;
                                oExcel:CellRead(nLinha,10),;
                                oExcel:CellRead(nLinha,11),;
                                oExcel:CellRead(nLinha,12),;
                                oExcel:CellRead(nLinha,13),;
                                oExcel:CellRead(nLinha,14),;
                                oExcel:CellRead(nLinha,15),;
                                oExcel:CellRead(nLinha,16),;
                                oExcel:CellRead(nLinha,17),;
                                oExcel:CellRead(nLinha,18),;
                                oExcel:CellRead(nLinha,19),;
                                oExcel:CellRead(nLinha,20),;
                                oExcel:CellRead(nLinha,21),;
                                oExcel:CellRead(nLinha,22),;
                                oExcel:CellRead(nLinha,23),;
                                oExcel:CellRead(nLinha,24),;
                                oExcel:CellRead(nLinha,25),;
                                oExcel:CellRead(nLinha,26),;
                                oExcel:CellRead(nLinha,27),;
                                oExcel:CellRead(nLinha,28),;
                                oExcel:CellRead(nLinha,29),;
                                oExcel:CellRead(nLinha,30),;
                                oExcel:CellRead(nLinha,31),;
                                oExcel:CellRead(nLinha,32),;
                                oExcel:CellRead(nLinha,33),;
                                oExcel:CellRead(nLinha,34),;
                                oExcel:CellRead(nLinha,35)})
                ENDIF
			NEXT nLinha
		ENDIF

		oExcel:CloseRead()
		++nPlan
		IF nPlan == 2
			lPlan := .F.
		ENDIF
	ENDDO

   ProcRegua(LEN(aSRA))
	IF LEN(aSRA) > 0
        FOR nLinha := 1 to LEN(aSRA)
            IncProc("Criando Cadastro ...")

			aCabec := {{"RA_FILIAL",xFilial("SRA"),nil},;
						{"RA_MAT",CONVCOL(aSRA[nLinha,1],"CZ",6),nil},;
						{"RA_NOME",CONVCOL(aSRA[nLinha,2],"C",30),nil},;
						{"RA_NOMECMP",CONVCOL(aSRA[nLinha,3],"C",50),nil},;
						{"RA_ENDEREC",CONVCOL(aSRA[nLinha,4],"C",50),nil},;
						{"RA_BAIRRO",CONVCOL(aSRA[nLinha,5],"C",20),nil},;
						{"RA_MUNICIP",CONVCOL(aSRA[nLinha,6],"C",10),nil},;
						{"RA_ESTADO",CONVCOL(aSRA[nLinha,7],"C",2),nil},;
						{"RA_CEP",CONVCOL(aSRA[nLinha,8],"CZ",8),nil},;
						{"RA_DDDFONE",CONVCOL(aSRA[nLinha,9],"CZ",2),nil},;
						{"RA_TELEFON",CONVCOL(aSRA[nLinha,10],"C",10),nil},;
						{"RA_PAI",CONVCOL(aSRA[nLinha,11],"C",30),nil},;
						{"RA_MAE",CONVCOL(aSRA[nLinha,12],"C",30),nil},;
						{"RA_SEXO",CONVCOL(aSRA[nLinha,13],"C",1),nil},;
						{"RA_NASC",CONVCOL(aSRA[nLinha,14],"D",10),nil},;
						{"RA_CIC",CONVCOL(aSRA[nLinha,15],"C",11),nil},;
						{"RA_PIS",CONVCOL(aSRA[nLinha,16],"C",11),nil},;
						{"RA_RG",CONVCOL(aSRA[nLinha,17],"C",15),nil},;
						{"RA_NUMCP",CONVCOL(aSRA[nLinha,18],"C",7),nil},;
						{"RA_SERCP",CONVCOL(aSRA[nLinha,19],"C",5),nil},;
						{"RA_UFCP",CONVCOL(aSRA[nLinha,20],"C",2),nil},;
						{"RA_HABILIT",CONVCOL(aSRA[nLinha,21],"C",2),nil},;
						{"RA_TITULOE",CONVCOL(aSRA[nLinha,22],"C",2),nil},;
						{"RA_ZONASEC",CONVCOL(aSRA[nLinha,23],"C",2),nil},;
						{"RA_NATURAL",CONVCOL(aSRA[nLinha,24],"C",2),nil},;
						{"RA_ADMISSA",CONVCOL(aSRA[nLinha,25],"D",10),nil},;
						{"RA_HRSMES",CONVCOL(aSRA[nLinha,26],"N",3),nil},;
						{"RA_CODFUNC",CONVCOL(aSRA[nLinha,27],"CZ",6),nil},;
						{"RA_SALARIO",CONVCOL(aSRA[nLinha,28],"N",14),nil},;
						{"RA_PERCADT",CONVCOL(aSRA[nLinha,29],"N",14),nil},;
						{"RA_OPCAO",CONVCOL(aSRA[nLinha,25],"D",10),nil},;
						{"RA_ESTCIVI",CONVCOL(aSRA[nLinha,30],"C",1),nil},;
						{"RA_TNOTRAB",CONVCOL(aSRA[nLinha,31],"CZ",3),nil},;
                        {"RA_CC",CONVCOL(aSRA[nLinha,32],"C",9),nil},;
						{"RA_BCDEPSA",CONVCOL(aSRA[nLinha,33],"CZ",3)+CONVCOL(aSRA[nLinha,34],"CZ",5),nil},;
                        {"RA_CTDEPSA",CONVCOL(aSRA[nLinha,35],"C",12),nil},;
						{"RA_BCDPFGT","999",nil},;
						{"RA_CTDPFGT","000000000000",nil},;
						{"RA_NACIONA","10",nil},;
						{"RA_TIPOADM","9B",nil},;
						{"RA_GRINRAI","45",nil},;
						{"RA_ADTPOSE","***N**",nil},;
						{"RA_CATFUNC","M",nil},;
						{"RA_TIPOPGT","M",nil},;
						{"RA_MSBLQL","2",nil},;
						{"RA_SINDICA","99",nil},;
						{"RA_DEFIFIS","2",nil},;
						{"RA_VIEMRAI","10",nil},;
						{"RA_PROCES","00001",nil},;
						{"RA_TPCONTR","1",nil}}

            DbSelectArea("SRA")
            SRA->(DbSetOrder(1))                        
            //EXECAUTO SRA
            Begin Transaction	                                                            

                MsExecAuto({|x,y,k,w| GPEA010(x,y,k,w)},nil,nil,aCabec,If(SRA->(DbSeek(xFilial("SRA")+aCabec[2,2],.F.)),4,3))
                        
                If lMsErroAuto 
                    //u_LogMsExec(,,)
                    //DisarmTransaction()
                    //break
                    MostraErro()
                    lMsErroAuto := .F.                    
                EndIf                           

            End Transaction

        NEXT nLinha
    ENDIF

    MSGINFO("Fim do Processamento!!")
RETURN lRet


STATIC FUNCTION CONVCOL(VCOLUNA,cTIPO,nTAMANHO)
LOCAL RCOLUNA

IF cTIPO == "C"
    IF ValType(VCOLUNA) == "C"
        RCOLUNA := VCOLUNA
    ELSEIF ValType(VCOLUNA)  == "N"
        RCOLUNA := ALLTRIM(STR(VCOLUNA))
    ELSEIF VCOLUNA == NIL
        RCOLUNA := ""
    ENDIF
ENDIF
IF cTIPO == "CZ"
    IF ValType(VCOLUNA) == "C"
        RCOLUNA := VCOLUNA
    ELSEIF ValType(VCOLUNA)  == "N"
        RCOLUNA := STRZERO(VCOLUNA,nTAMANHO)
    ELSEIF VCOLUNA == NIL
        RCOLUNA := STRZERO(0,nTAMANHO)
    ENDIF
ENDIF

IF cTIPO == "N"
    IF ValType(VCOLUNA) == "C"
        RCOLUNA := VAL(VCOLUNA)
    ELSEIF ValType(VCOLUNA)  == "N"
        RCOLUNA := VCOLUNA
    ELSEIF VCOLUNA == NIL
        RCOLUNA := 0
    ENDIF
ENDIF

IF cTIPO == "D"
    IF ValType(VCOLUNA) == "D"
        RCOLUNA := VCOLUNA
    ELSEIF ValType(VCOLUNA) == "C"
        RCOLUNA := CTOD(VCOLUNA)
    ELSEIF ValType(VCOLUNA)  == "N"
        RCOLUNA := CTOD(STR(VCOLUNA))
    ELSEIF VCOLUNA == NIL
        RCOLUNA := CTOD("")
    ENDIF
ENDIF


RETURN RCOLUNA
