#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BKGCTF01º      Adilson do Prado              Data ³10/04/12º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao calcular o numero de funcionario do contrato no Rubiº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK Consultoria                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                                        

User Function BKGCTF01(cNumemp,cFilRubi,cContrato)
Local cQuery   	:= ""
Local aContrCons:= {}
Local aConsorcio:= {}
Local nScan		:= 0
Local aRet		:= {}

aContrCons	:= StrTokArr(ALLTRIM(GetMv("MV_XXCONS1"))+ALLTRIM(GetMv("MV_XXCONS2"))+ALLTRIM(GetMv("MV_XXCONS3"))+ALLTRIM(GetMv("MV_XXCONS4")),"/") //"163000240"

FOR IX:= 1 TO LEN(aContrCons)
    AADD(aConsorcio,StrTokArr(aContrCons[IX],";"))
NEXT

cQuery := "SELECT CodSit,DesSit,COUNT(numcad) as TotalFunc FROM bk_senior.bk_senior.r034fun fun"
cQuery += "  INNER JOIN bk_senior.bk_senior.R010SIT sit on CodSit=fun.sitafa "
cQuery += " where sitafa in (1,2,3,4,6,8,9) "

/*
1	Trabalhando
2	Férias
3	Auxílio Doença
4	Acidente Trabalho
6	Licença Maternidade
8	Lic. s/ Remuneração
9	Lic.Rem p/ Empresa
*/

nScan:= 0
nScan:= aScan(aConsorcio,{|x| x[1]==alltrim(cContrato) })

IF nScan > 0 
	cQuery += " AND numemp='"+SUBSTR(ALLTRIM(aConsorcio[nScan,2]),1,2)+"'"
	cQuery += " AND ( BKIntegraRubi.dbo.fnCCSiga(numemp,tipcol,numcad,'CLT') ='"+ALLTRIM(aConsorcio[nScan,3])+"' COLLATE SQL_Latin1_General_CP1_CI_AS"
	cQuery += " OR  BKIntegraRubi.dbo.fnCCSiga(numemp,tipcol,numcad,'CLT') ='"+ALLTRIM(aConsorcio[nScan,4])+"' COLLATE SQL_Latin1_General_CP1_CI_AS"
	cQuery += " OR  BKIntegraRubi.dbo.fnCCSiga(numemp,tipcol,numcad,'CLT') ='"+ALLTRIM(aConsorcio[nScan,7])+"' COLLATE SQL_Latin1_General_CP1_CI_AS ) "
	
ELSE
	cQuery += " AND numemp="+cNumemp
	cQuery += " AND BKIntegraRubi.dbo.fnCCSiga(numemp,tipcol,numcad,'CLT') ='"+cContrato+"' COLLATE SQL_Latin1_General_CP1_CI_AS"
ENDIF

cQuery += " GROUP BY CodSit,DesSit"


TCQUERY cQuery NEW ALIAS "QSQL"
DbSelectArea("QSQL")
QSQL->(DbGotop())
DO WHILE QSQL->(!EOF())
	
	//nTotFunc += QSQL->TotalFunc 
	AADD(aRET,{QSQL->CodSit,QSQL->DesSit,QSQL->TotalFunc})
	
	QSQL->(DBskip())
ENDDO
QSQL->(dbCloseArea())	

Return aRET
