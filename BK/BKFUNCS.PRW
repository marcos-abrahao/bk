#include "TOTVS.CH"
#include "PROTHEUS.CH"

/*/{Protheus.doc} BKFUNCS
BK - Fun��es diversas

@Return
@author Marcos B. Abrah�o
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

	If !u_WebAtivo()
		u_AvisoLog(cId,"Aten��o:",;
					"A url foi aberta em um popup."+CRLF+;
					"Verifique se o seu navegador est� bloqueando popups para este endere�o.",;
					{"Ok"}, 1, /*cText*/,/*nRotAutDefault*/,/*cBitmap*/,/*lEdit*/, 4000 /*nTimer*/, 1 /*nOpcPadrao */ )
	EndIf

EndIf

Return cUrl


