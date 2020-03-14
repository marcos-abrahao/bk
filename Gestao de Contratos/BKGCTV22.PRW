#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³BKGCTV22  ºAutor  ³ Marcos B. Abrahão  º Data ³ 18/07/2017  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Visualização de Ocorrências e Planos de ação - Contratos    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³BK                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
                       
User Function BKGCTV22()

//Local cContrato := TRIM(CN9->CN9_NUMERO)
Local cAlias    := "SZP"
Local aCores    := {}

Private cFiltra   := "" // "Z7_FILIAL == '"+xFilial('SZ7')+"' .And. TRIM(Z7_CONTRAT) = '"+cContrato+"'"
Private cCadastro := "Ocorrências - Planos de Ação"
Private aRotina   := {}
Private aIndexSz  := {}
Private bFiltraBrw:= { || FilBrowse(cAlias,@aIndexSz,@cFiltra) }
                   

aRotina := {{"Pesquisar"     ,"AxPesqui"	,0, 1},;
			{"Respondido"    ,"U_FREPSZP"	,0, 1},;
			{"Fora do Prazo" ,"U_FFORASZP"	,0, 1},;
			{"No Prazo"      ,"U_FNPRAZSZP"	,0, 1},;
			{"Finalizadas"   ,"U_FFINSZP"	,0, 1},;
			{"Todas"         ,"U_FTODSZP"	,0, 1},;
			{"Visualizar"    ,"U_BKGCTW22"	,0, 1}}

//			{"Em aberto"     ,"U_FABRSZP"	,0, 1},;

/*
-- CORES DISPONIVEIS PARA LEGENDA --
BR_AMARELO
BR_AZUL
BR_BRANCO
BR_CINZA
BR_LARANJA
BR_MARRON
BR_VERDE
BR_VERMELHO
BR_PINK
BR_PRETO
*/
                                                                                                                                     
AADD(aCores,{"U_BUSCAOSZQ() == '1'","BR_VERDE" })
AADD(aCores,{"U_BUSCAOSZQ() == '2'","BR_VERMELHO" })
AADD(aCores,{"U_BUSCAOSZQ() == '3'","BR_AMARELO" })
AADD(aCores,{"U_BUSCAOSZQ() == '4'","BR_PRETO" })

dbSelectArea(cAlias)
dbSetOrder(1)
//+------------------------------------------------------------
//| Cria o filtro na MBrowse utilizando a função FilBrowse
//+------------------------------------------------------------
Eval(bFiltraBrw)

dbSelectArea(cAlias)
dbGoTop()
If EOF()
   MsgInfo('Não há ocorrências cadastradas')
Else
   mBrowse(6,1,22,75,cAlias,,,,,,aCores)
EndIf
//+------------------------------------------------
//| Deleta o filtro utilizado na função FilBrowse
//+------------------------------------------------
EndFilBrw(cAlias,aIndexSz)
Return Nil
                  

User Function BKGCTW22()
Local aArea      := GetArea()

dbSelectArea("SC9")
dbSetOrder(1)
SC9->(dbSeek(xFilial("SC9")+SZP->ZP_CONTRAT,.T.))

U_BKGCTA22(.T.)

RestArea(aArea)
Return Nil  


/*
User Function fABRSZP()
Local oObjBrow 
oObjBrow := GetObjBrow() 
oObjBrow:SetFilter("ZP_FINALIZ", "N","N")
oObjBrow:ResetLen() 
oObjBrow:GoTop() 
oObjBrow:Refresh() 
Return( NIL )
*/

User Function fREPSZP()
Local oObjBrow 
oObjBrow := GetObjBrow() 
oObjBrow:SetFilter("U_BUSCAOSZQ()", "1","1")
oObjBrow:ResetLen() 
oObjBrow:GoTop() 
oObjBrow:Refresh() 
Return( NIL )


User Function fFORASZP()
Local oObjBrow 
oObjBrow := GetObjBrow() 
oObjBrow:SetFilter("ZP_FINALIZ", "N","N")
oObjBrow:ResetLen() 
oObjBrow:GoTop() 
oObjBrow:Refresh() 
Return( NIL )


User Function fNPRAZSZP()
Local oObjBrow 
oObjBrow := GetObjBrow() 
oObjBrow:SetFilter("ZP_FINALIZ", "N","N")
oObjBrow:ResetLen() 
oObjBrow:GoTop() 
oObjBrow:Refresh() 
Return( NIL )


User Function fFINSZP()
Local oObjBrow 
oObjBrow := GetObjBrow() 
oObjBrow:SetFilter("ZP_FINALIZ", "S","S")
oObjBrow:ResetLen() 
oObjBrow:GoTop() 
oObjBrow:Refresh() 
Return( NIL )

             
User Function fTODSZP()
Local oObjBrow 
oObjBrow := GetObjBrow() 
oObjBrow:SetFilter("ZP_FINALIZ","","X") 
//oObjBrow:DisableFilter()
oObjBrow:ResetLen() 
oObjBrow:GoTop() 
oObjBrow:Refresh() 
Return( NIL )
              
              


USER FUNCTION BUSCAOSZQ()
Local aArea      := GetArea()
LOCAL cStaRet := "1"

If SZQ->(dbSeek(xFilial("SZQ")+SZP->ZP_CONTRAT+SZP->ZP_SEQ,.F.))
	cEfic := "S"
	Do While SZQ->(!EOF()) .AND. SZP->ZP_CONTRAT+SZP->ZP_SEQ == SZQ->ZQ_CONTRAT+SZQ->ZQ_SEQ
		If SZQ->ZQ_QUANDO > SZP->ZP_DATAPRV
			cEfic := "N"
		EndIf
		SZQ->(dbSkip())
	EndDo
	IF cEfic == "S" 
		cStaRet := "1"
	ELSE
		cStaRet := "2"
	ENDIF
Else
	cStaRet := "3"
EndIf

If SZP->ZP_DATAPRV < dDataBase
	cStaRet := "2"
EndIf

If SZP->ZP_FINALIZ == "S"
	cStaRet := "4"
EndIf

RestArea(aArea)

RETURN cStaRet

