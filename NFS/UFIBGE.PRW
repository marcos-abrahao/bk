#include "rwmake.ch"
#Include "Protheus.ch"

//Funcao Utilizada na Instrução Nomativa para NFS-e,
//retorna ESTADO CODIGO IBGE
USER Function UfIBGE(cUF )
Local nX        := 0
Local cRetorno  := ""
Local aUF       := {}
Local aAreaIni 	:= GetArea()

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
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
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
aadd(aUF,{"EX","99"})
          
If !Empty(cUF)
	cUF := upper(cUF)
	
	nX := aScan(aUF,{|x| x[1] == cUF})
	If nX == 0
		nX := aScan(aUF,{|x| x[2] == cUF})
		If nX <> 0
			cRetorno := aUF[nX][1]
		EndIf
	Else
		cRetorno := aUF[nX][2]
	EndIf
Else
	cRetorno := ""
EndIf

RestArea(aAreaIni)
Return(cRetorno) 



//BUSCA CODIGO IBGE UF+MUNICIPIO INSTRUCAO NORMATIVA PAULISTANA NO PEDIDO DE VENDAS
USER FUNCTION BCODIBGE()
LOCAL cCOD    	:= ""
Local aAreaIni 	:= GetArea()
Local aAreaSD2	:= SD2->(GetArea("SD2"))
Local aAreaSC5	:= SC5->(GetArea("SC5"))
Local cNF     	:= PARAMIXB[1]
Local cSerie  	:= PARAMIXB[2] 
Local cCliente	:= PARAMIXB[3]
Local cLoja   	:= PARAMIXB[4]

dbSelectArea ("SD2")   
SD2->(dbSetOrder(3))               //filial,doc,serie,cliente,loja,cod
SD2->(dbSeek(xFilial("SD2")+cNF+cSerie+cCliente+cLoja,.T.))

dbSelectArea("SC5")
SC5->(dbSeek(xFilial("SC5") + SD2->D2_PEDIDO,.T.))

IF !EMPTY(SC5->C5_MUNPRES)
	cCOD := U_UfIBGE(SC5->C5_ESTPRES)+SC5->C5_MUNPRES
ELSE
	cCOD := U_UfIBGE(SA1->A1_EST)+SA1->A1_COD_MUN
ENDIF

SC5->(RestArea(aAreaSC5))
SD2->(RestArea(aAreaSD2))

RestArea(aAreaIni)

RETURN cCOD 

