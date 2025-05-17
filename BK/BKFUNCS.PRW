#include "TOTVS.CH"
#include "PROTHEUS.CH"

/*/{Protheus.doc} BKFUNCS
BK - Funções diversas

@Return
@author Marcos B. Abrahão
@since 15/05/2025
@version P12
/*/

// Retorna o Percentual em caracteres sem .00 no final
User Function PicPer(nAliq,nT,nD)
Local cAliq := ALLTRIM(STR(nAliq,nT,nD))
If ("."+Replicate("0",nD)) $ cAliq
	cAliq := STRTRAN(cAliq,"."+Replicate("0",nD),"")
EndIf
Return cAliq


// Gerar tmp e abre a url gerada no navegador
User Function TmpHtml(cHtml,cId,lOpen)
Local cDirTmp   := u_STmpHttp()
Local cNomeTmp  := ""
Local cUrl      := ""
Local cArqHtml	:= ""
Default lOpen 	:= .T.

cNomeTmp    := DTOS(dDataBase)+"-"+STRZERO(randomize(1,99999),5)+"-"+cId+".html"
cArqHtml  	:= cDirTmp+cNomeTmp
cUrl 		:= u_BkIpServer()+"\tmp\"+cNomeTmp

IF !EMPTY(cDirTmp)
   MakeDir(cDirTmp)
ENDIF 
fErase(cArqHtml)

MemoWrite(cArqHtml,cHtml)

If lOpen
	ShellExecute("open",cUrl, "", "", 1)
EndIf

Return cArqHtml


