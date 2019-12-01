#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#include "TBICONN.CH"

User Function BKACT01()

/*/
Programa     : BKACT01 - Autor: Marcos B. Abrahao - Data: 22/12/09
Objetivo     : Importação de titulos do contas a receber
Uso          : BK Consultoria
/*/


/*

Ex de Registro:
FILIAL;PREFIXO;NUMERO;PARCELA;TIPO;NATUREZA;CLIENTE;LOJA;EMISSÃO;VENCTO;VALOR
;CTR;5396;01;;0000000042;000061;01;04/01/2010;15/10/2009;1160.6

01-            FILIAL
02-CTR         PREFIXO
03-5396        NUMERO
04-01          PARCELA
05-            TIPO
06-0000000042  NATUREZA
07-000061      CLIENTE
08-01          LOJA
09-04/01/2010  EMISSAO
10-15/10/2009  VENCTO
11-1160.6      VALOR

*/

LOCAL cEmpF

cArq := "C:\TEMP\E1BK.CSV"

@ 200,01 TO 285,450 DIALOG oDlg1 TITLE "BKACT01 - Importaçao de titulos a receber"
@ 15,015 SAY "Arquivo: "
@ 15,046 GET cArq SIZE 180,10
@ 30,060 BMPBUTTON TYPE 01 ACTION ProcImp()
@ 30,110 BMPBUTTON TYPE 02 ACTION Close(Odlg1)

ACTIVATE DIALOG oDlg1 CENTER

RETURN


Static FUNCTION ProcImp()
LOCAL i,j
IF !FILE(TRIM(cArq))
   MsgBox("Arquivo "+TRIM(cArq)+ " nao encontrado")
   Return
ENDIF 

Processa( {|| RunProc() } )

Close(oDlg1)
Return


Static Function RunProc()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cArqTr,aStrucX,cReg
Local aCab
Local cErro :=""

Private lMSHelpAuto := .F.
Private lAutoErrNoFile := .T.

IF SELECT("QSXX") > 0
   SELECT QSXX
   USE
ENDIF

// Cria arquivo temporario
cArqTR := CriaTrab(NIL,.F.)
aStrucX:= { {"XX_REG"  ,"C",400,0} }

DBCREATE(cArqTR,aStrucX)
USE (cArqTr) EXCLUSIVE ALIAS QSXX NEW

SELECT QSXX
APPEND FROM (cArq) SDF
GO TOP

ProcRegua(LASTREC())

SKIP

DO WHILE !EOF()
   
	IncProc()
	cReg   := ALLTRIM(QSXX->XX_REG)+";X"
	cReg   := STRTRAN(cReg,";;","; ;")
	aCab   := STRTOKARR(cReg,";")
	
/*	
01-            FILIAL
02-CTR         PREFIXO
03-5396        NUMERO
04-01          PARCELA
05-            TIPO
06-0000000042  NATUREZA
07-000061      CLIENTE
08-01          LOJA
09-04/01/2010  EMISSAO
10-15/10/2009  VENCTO
11-1160.6      VALOR
*/

         dEmissao := CTOD(aCab[09])
         dVencto  := CTOD(aCab[10])
         IF dVencto < dEmissao
            dVencto := dEmissao
         ENDIF
          
         aVetor :={{"E1_FILIAL" 	,'01',Nil},;
            	{"E1_PREFIXO"   ,'1',Nil},;
				{"E1_NUM"	    ,STRZERO(VAL(aCab[03]),9),Nil},;
				{"E1_PARCELA"   ,"",Nil},;
				{"E1_TIPO"	    ,"DP",Nil},;
				{"E1_NATUREZ"   ,STRZERO(VAL(aCab[06]),10),Nil},;
	          	{"E1_CLIENTE"   ,STRZERO(VAL(aCab[07]),6),Nil},;
             	{"E1_LOJA"	    ,STRZERO(VAL(aCab[08]),2),Nil},;
	          	{"E1_EMISSAO"   ,dEmissao,Nil},;
		       	{"E1_VENCTO"	,dVencto,Nil},;
		       	{"E1_VALOR"	    ,VAL(aCab[11]),Nil },;
		       	{"E1_SITUACA"   ,"1",Nil },;
		       	{"E1_MOVIMEN"   ,DATE(),Nil }}


	Begin Transaction
		lMsErroAuto := .F.
		MSExecAuto({|x,y| Fina040(x,y)},aVetor,3) //Inclusao

		IF lMsErroAuto
	    	MostraErro()
			DisarmTransaction()
		EndIf

	End Transaction
	
	SELECT QSXX
	SKIP
ENDDO
dbSelectArea("QSXX")
dbCloseArea()
FErase(cArqTr+GetDBExtension())
FErase(cArqTr+OrdBagExt())

RETURN



/*/
+-----------------------------------------------------------------------
| Função | XCONVERRLOG | Autor | Arnaldo R. Junior | Data | |
+-----------------------------------------------------------------------
| Descrição | CONVERTE O ARRAY AAUTOERRO EM TEXTO CONTINUO. |
+-----------------------------------------------------------------------
| Uso | Curso ADVPL |
+-----------------------------------------------------------------------
/*/
STATIC FUNCTION XCONVERRLOG(aAutoErro)
LOCAL cRet := ""
LOCAL nX := 1
FOR nX := 1 to Len(aAutoErro)
	cRet += aAutoErro[nX]+CHR(13)+CHR(10)
NEXT nX
RETURN cRet

