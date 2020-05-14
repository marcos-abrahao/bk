#include "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#include "TopConn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XCADSE1     º Autor ³ Adilson do Prado   º Data ³  13/05/20 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressão notas de Debito                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function XCADSE1
Local 	cFiltra     := 'SE1->E1_TIPO == "NDC"'

Private cCadastro	:= "Impressão Notas de Debito"
Private cDelFunc	:= ".F." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cString 	:= "SE1"
Private aIndexSz  	:= {}
PRIVATE aFixeFX     := {}
Private bFiltraBrw	:= { || FilBrowse(cString,@aIndexSz,@cFiltra) } 
Private aCores  := {}
Private aRotina	:= {}

AADD(aCores,{"SE1->E1_SALDO == SE1->E1_VALOR","BR_VERDE"})
AADD(aCores,{"SE1->E1_SALDO <> SE1->E1_VALOR .and. SE1->E1_SALDO>0","BR_AZUL"})
AADD(aCores,{"SE1->E1_SALDO==0","BR_VERMELHO"})

AADD(aRotina,{"Pesquisa"		,"AxPesqui",0,1})
AADD(aRotina,{"Visualizar"		,"AxVisual",0,2})
AADD(aRotina,{OemToAnsi("Imprimir NDC - Nota de Debito "+ALLTRIM(SM0->M0_NOME)),  "U_BKFINR24", 0, 3 } )
AADD(aRotina,{"Legenda"			,"U_SE1LEG",0,6})


dbSelectArea(cString)
dbSetOrder(1)
//+------------------------------------------------------------
//| Cria o filtro na MBrowse utilizando a função FilBrowse
//+------------------------------------------------------------
Eval(bFiltraBrw)

dbSelectArea(cString)
dbGoTop()

mBrowse(6,1,22,75,cString,aFixeFX,,,,,aCores)

//+------------------------------------------------
//| Deleta o filtro utilizado na função FilBrowse
//+------------------------------------------------
EndFilBrw(cString,aIndexSz)

Return 


User Function SE1LEG()
Local aCores2 := {}
Local cLegenda := ""

cLegenda	:= "Legenda de Cores"

AADD(aCores2,{"BR_VERDE"   , "Titulo em Aberto"})
AADD(aCores2,{"BR_AZUL"	   , "Baixado Parcialmente"})
AADD(aCores2,{"BR_VERMELHO", "Titulo Baixado"})
             		
BrwLegenda(cLegenda,"Status - Notas de Debito",aCores2)

Return NIL