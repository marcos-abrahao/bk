#Include "PROTHEUS.CH"
#include "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MA103OPC ºAutor  ³Marcos B. Abrahao   º Data ³  09/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada para criar opções na tela de              º±±
±±º          ³ Documento de Entrada                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MA103OPC
Local aRot := {} 
Local aGrp := UsrRetGrp()

If LEN(aGrp) > 0
	If aGrp[1] == "000000" 
		AADD( aRot, {OemToAnsi("Informar Chave NFE"), "U_BKCOMA08", 0, 1 } )
	EndIf
EndIf

AADD( aRot, {OemToAnsi("Pesquisa BK"), "U_BKCOMC01", 0, 1 } )
AADD( aRot, {OemToAnsi("Pesquisa NF"), "U_BKCOMC02", 0, 1 } )
AADD( aRot, {OemToAnsi("Aval. Fornecedor"), "U_VEWAVALFOR", 0, 4 } )
AADD( aRot, {OemToAnsi("Reavaliar Fornecedor"), "U_RAvalForn", 0, 4 } )

Return( aRot )
              
             
            

USER function VEWAVALFOR() 

Local oGroup1,oGroup2,oGroup3,oGroup4,oGroup5
Local oSay,oFont1,oFont2,oFont3

Local nTotal  := 0
Local aItens  := {'Sim','Não'}
Local cAvalC  := ""
Local nRadio1 := 0
Local nRadio2 := 0
Local nRadio3 := 0
Local nRadio4 := 0
Local nRadio5 := 0

IF EMPTY(SF1->F1_XXAVALI)
	MsgStop("Fornecedor não possui Avaliação para esta NF!!","MA103OPC - Atenção")
 	Return
ENDIF

// Variavel numerica que guarda o item selecionado do Radio

nRadio1 := IIF(SUBSTR(SF1->F1_XXAVALI,1,1)='S',1,2)
nRadio2 := IIF(SUBSTR(SF1->F1_XXAVALI,2,1)='S',1,2)
nRadio3 := IIF(SUBSTR(SF1->F1_XXAVALI,3,1)='S',1,2)
nRadio4 := IIF(SUBSTR(SF1->F1_XXAVALI,4,1)='S',1,2)

cAvalC  := Posicione("SA2",1,xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA,"A2_XXAVALC")
If cAvalC == "S"
	nRadio5 := 1
Else
    nRadio5 := 0
eNDiF

nTotal := (IIF(nRadio1=1,25,0)+IIF(nRadio2=1,25,0)+IIF(nRadio3=1,25,0)+IIF(nRadio4=1,25,0)) 

DEFINE MSDIALOG oDlg FROM 0,0 TO 430,400 PIXEL TITLE 'Avaliação de Fornecedores'

// Cria font para uso
oFont1:= TFont():New('Arial',,-13,.T.,.F.,,,,.F.,.F.)  

oFont2:= TFont():New('Arial',,-13,.T.,.T.,,,,.F.,.T.)  

oFont3:= TFont():New('Arial',,-14,.T.,.T.,,,,.F.,.T.)  

// Apresenta o tSay com a fonte Arial
oSay := TSay():New( 10, 60, {|| 'Pedido X Nota Fiscal'},oDlg,, oFont3,,,, .T.,,)

oSay := TSay():New( 20, 20, {|| 'Itens a serem avaliados:'},oDlg,, oFont2,,,, .T.,,)

aItens := {}
aItens := {'Sim','Não'}

// Cria o Objeto
oGroup1:= tGroup():New(30,10,050,190,'',oDlg,,,.T.)
oSay  := TSay():New( 035,020, {|| 'Preço'},oGroup1,, oFont1,,,, .T.,,)
oRadio1 := TRadMenu():Create (oGroup1,,30,150,aItens,,,,,,,,100,12,,,,.T.) 
oRadio1:bSetGet := {|u|Iif (PCount()==0,nRadio1,nRadio1:=u)}
oRadio1:SetOption(IIF(nRadio1=1,1,2))
oRadio1:bWhen := {||.F.}

oGroup2:= tGroup():New(60,10,080,190,'',oDlg,,,.T.)
oSay  := TSay():New( 065,020, {|| 'Prazo'},oGroup2,, oFont1,,,, .T.,,)
oRadio2 := TRadMenu():Create (oGroup2,,60,150,aItens,,,,,,,,100,12,,,,.T.)
oRadio2:Enable(1)
oRadio2:bSetGet := {|u|Iif (PCount()==0,nRadio2,nRadio2:=u)}
oRadio2:SetOption(IIF(nRadio2=1,1,2))
oRadio2:bWhen := {||.F.}

oGroup3:= tGroup():New(90,10,110,190,'',oDlg,,,.T.)
oSay  := TSay():New( 095,020, {|| 'Quantidade/Atendimento'},oGroup3,, oFont1,,,, .T.,,)
oRadio3 := TRadMenu():Create (oGroup3,,90,150,aItens,,,,,,,,100,12,,,,.T.)
oRadio3:bSetGet := {|u|Iif (PCount()==0,nRadio3,nRadio3:=u)}
oRadio3:SetOption(IIF(nRadio3=1,1,2))
oRadio3:bWhen := {||.F.}

oGroup4:= tGroup():New(120,10,140,190,'',oDlg,,,.T.)
oSay  := TSay():New( 125,020, {|| 'Qualidade/Integridade'},oGroup4,, oFont1,,,, .T.,,)
oRadio4 := TRadMenu():Create (oGroup4,,120,150,aItens,,,,,,,,100,12,,,,.T.)
oRadio4:bSetGet := {|u|Iif (PCount()==0,nRadio4,nRadio4:=u)}
oRadio4:SetOption(IIF(nRadio4=1,1,2))
oRadio4:bWhen := {||.F.}

oSay := TSay():New(145,75, {|| "Total (IQF):  "+str(nTOTAL,3)+"%"},oDlg,, oFont2,,,, .T.,,)

oGroup5:= tGroup():New(160,10,180,190,'',oDlg,,,.T.)
oSay  := TSay():New( 165,020, {|| 'Fornecedor crítico:'},oGroup5,, oFont1,,,, .T.,,)
oRadio5 := TRadMenu():Create (oGroup5,,160,150,aItens,,,,,,,,100,12,,,,.T.)

oRadio5:bSetGet := {|u|Iif (PCount()==0,nRadio5,nRadio5:=u)}
oRadio5:bWhen := {||.F.}

@ 190,050 Button "&OK" Size 100,013 Pixel Action (oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED 

Return


