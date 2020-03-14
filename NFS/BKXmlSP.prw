#include "Protheus.ch"
#include "TopConn.ch"
#include "RwMake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BKXMLSP º Autor ³ Adilson do Prado           Data ³14/05/15º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gera XML NFS-e São Paulo  - BK                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


User Function BKXMLSP()

Local cPerg 		:= "BKXMLSP"
Local cXML			:= ""
Local lErro			:= .F.

Private cNotaDe 	:= ""
Private cNotaAte 	:= ""
Private cSerie		:= ""
Private cDir		:= ""
Private aUF			:= {}
	
	//Preenchimento do Array de UF
aadd(aUF,{"RO","11"})
aadd(aUF,{"AC","12"})
aadd(aUF,{"AM","13"})
aadd(aUF,{"RR","14"})
aadd(aUF,{"PA","15"})
aadd(aUF,{"AP","16"})
aadd(aUF,{"TO","17"})
aadd(aUF,{"MA","21"})
aadd(aUF,{"PI","22"})
aadd(aUF,{"CE","23"})
aadd(aUF,{"RN","24"})
aadd(aUF,{"PB","25"})
aadd(aUF,{"PE","26"})
aadd(aUF,{"AL","27"})
aadd(aUF,{"MG","31"})
aadd(aUF,{"ES","32"})
aadd(aUF,{"RJ","33"})
aadd(aUF,{"SP","35"})
aadd(aUF,{"PR","41"})
aadd(aUF,{"SC","42"})
aadd(aUF,{"RS","43"})
aadd(aUF,{"MS","50"})
aadd(aUF,{"MT","51"})
aadd(aUF,{"GO","52"})
aadd(aUF,{"DF","53"})
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
aadd(aUF,{"EX","99"})


AjustaSX1(cPerg)
If !Pergunte(cPerg,.T.)
   	Return (Nil)
EndIf

cNotaDe 	:= MV_PAR01
cNotaAte 	:= MV_PAR02
cSerie		:= MV_PAR03
cDir		:= Alltrim(MV_PAR04)

dbSelectArea ("SF2")           //cabecalho de N.F.
dbSetOrder (1)                 //filial,documento,serie,cliente,loja
dbSeek (xFilial("SF2")+cNotaDe+cSerie,.T.)
While SF2->(!EoF()) .AND. SF2->F2_FILIAL == xFilial("SF2") .AND. SF2->F2_SERIE == cSerie .AND. SF2->F2_DOC >= cNotaDe .AND. SF2->F2_DOC <= cNotaAte
	
	cXML := U_NfseM002(SM0->M0_CODMUN,"1",SF2->F2_EMISSAO,SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENT,SF2->F2_LOJA,"")
    
    IF LEN(cXML) > 1
		lErro := GrvArq(cXML[1],Alltrim(SF2->F2_DOC)+"_"+Alltrim(SF2->F2_SERIE)+".xml")
	ENDIF
	SF2->(DbSkip())
ENDDO

IF !lErro
	MSGINFO("XML NFS-e Gravado com Sucesso!!")
ENDIF 
 
   	
Return (Nil)



Static Function AjustaSX1(cPerg)

	PutSx1(cPerg,"01","Da Nota?"	,"","","mv_ch1" ,"C",09,0,0,"G","","SF2"		,"","","MV_PAR01","","","","","","","","","","","","","","","","",)
	PutSx1(cPerg,"02","Ate Nota?"	,"","","mv_ch1" ,"C",09,0,0,"G","","SF2"		,"","","MV_PAR02","","","","","","","","","","","","","","","","",)
	PutSx1(cPerg,"03","Serie?"		,"","","mv_ch3" ,"C",03,0,0,"G","",""			,"","","MV_PAR03","","","","","","","","","","","","","","","","",)
	PutSx1(cPerg,"04","Salvar em?"	,"","","mv_ch4" ,"C",99,0,0,"G","",""			,"","","MV_PAR04","","","","","","","","","","","","","","","","",)
	
Return (Nil)


Static Function GrvArq(cXML,cNomeArq)

	Local nHdl 	:= 0
	Local lErro := .F.
  
	If File(cDir+cNomeArq)
	  	FErase(cDir+cNomeArq)
	EndIf
	
	nHdl :=	fCreate(cDir+cNomeArq) // cria o arquivo
	
	If ferror() # 0
		lErro := .T.
		msgalert ("ERRO AO CRIAR O ARQUIVO, ERRO: " + str(ferror()))
	Else
		
		fwrite(nHdl,cXML)
		
		If ferror() # 0
			lErro := .T.
			msgalert ("ERRO GRAVANDO ARQUIVO, ERRO: " + str(ferror()))
		Else
			fClose(nHdl)        // grava o arquivo Texto
		Endif
	Endif
Return (lErro)
