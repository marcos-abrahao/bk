#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKBATIDAS
BK - Envio de Emails para a batida de ponto
@Return
@author Marcos Bispo Abrahão
@since 21/11/2023
@version P12
/*/


//Tela para colagem de dados do excel em formato CSV

User Function BKBATIDAS()
Local oDlg01	As Object
Local aButtons 	:= {}
Local lOk 		:= .F.
Local nSnd    	:= 0
Local nTLin 	:= 15
Local nSin    	:= 5
Local cTexto	:= ""

Private cPerg   := "BKBATIDAS"

Define MsDialog oDlg01 Title "Importação de dados: Excel --> Array" From 000,000 To 260+(nSin*nTLin),600 Of oDlg01 Pixel

nSnd := 35
@ nSnd,010 Say 'Cole o CSV: Nome;E-Mail;Chave'  Size 240,010 Pixel Of oDlg01
nSnd += nTLin
oMemo:= tMultiget():New(nSnd,10,{|u|if(Pcount()>0,cTexto :=u,cTexto )},oDlg01,280,100,,,,,,.T.)
nSnd += nTLin

ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T.,oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)

If ( lOk ) 
	BrwCSV(cTexto)
EndIf

Return lOk



Static Function BrwCSV(cTexto)
Local aCampos := {{ "MARCA"   , "C", 002, 0, "Marca"    ,"@!", .F., "" },;
				  { "NOME"    , "C", 100, 0, "Nome"     ,"@!", .T., "" },;
				  { "EMAIL"   , "C", 100, 0, "E-Mail"   ,"@!", .T., "" },;
				  { "CHAVE"   , "C", 050, 0, "Chave"    ,""  , .T., "" } }

Local aDados  := {}
Local aTexto  := {}
Local nI 	  := 0
Local nX      := 0
Local nTamTex := 0
Local cLinha  := ""
Local cNome   := ""
Local cEmailTO:= ""
Local cChave  := ""

Local cAssunto:= "Nova Batida de Ponto Online"
Local cMsg 	  := ""
Local cMsg1	  := ""
Local cFile   := "\anexos\PASSO A PASSO - BATIDA PONTO AHGORA.pdf"
Local cEmailCC:= "microsiga@bkconsultoria.com.br"

BeginContent var cMsg

<html>
<head>
<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">
<link rel=Edit-Time-Data href="./HistD_arquivos/editdata.mso">
<title>Nova Batida de Ponto Online"</title>
<style>
.Normal{font-size:12.0pt;font-family:"Arial";}
</style>
</head>
<body bgcolor=#ffffff lang=PT-BR class="Normal" 
<br>
Olá #NOME#
<br>
<br>
Estamos entrando em contato para fornecer as orientações detalhadas sobre o novo sistema de registro de ponto online.
<br>
<br>
No documento anexo, você encontrará um guia completo com instruções claras sobre como acessar o sistema de Batida Online, assim como o sistema de espelho de ponto, My Ahgora, caso seja necessário. Além disso, incluímos sua chave de ativação, que deverá ser utilizada conforme indicado no passo a passo.
<br>
<br>
Chave de Ativação: (#CHAVE#)
<br>
<br>
Se surgirem dúvidas adicionais em relação ao acesso ao Batida Online ou ao My Ahgora, por favor, não hesite em entrar em contato através do e-mail tany.sousa@bkconsultoria.com.br.
<br>
<br>
Agradecemos pela sua atenção e colaboração.
<br>
<br>
Atenciosamente,
<br>
<br>
</body>
</html>
EndContent


nTamTex := mlCount(cTexto, 200)
	
For nI := 1 To nTamTex
	cLinha := Trim(memoline(cTexto, 200, nI))+";"
	aTexto := StrTokArr(cLinha,";")
	aAdd(aDados,{"",aTexto[1],aTexto[2],aTexto[3]})
Next

u_TTMARKB(aCampos, aDados, .T.)


For nX := 1 To Len(aDados) 
	If !Empty(aDados[nX,1])
		cNome 		:= aDados[nX,2]
		cEmailTO 	:= aDados[nX,3]
		cChave 		:= aDados[nX,4]

		cMsg1 := STRTRAN(cMsg ,"#NOME#",cNome)
		cMsg1 := STRTRAN(cMsg1,"#CHAVE#",cChave)
		cMsg1 := STRTRAN(cMsg1,"#CR#",CRLF)

		u_BkSnMail("BKBATIDAS",cAssunto,cEmailTO,cEmailCC,cMsg1,{cFile})

	EndIf
Next nX

Return

