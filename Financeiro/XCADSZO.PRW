#include "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#include "TopConn.ch"

/*/{Protheus.doc} XCADSZO()
BK - AXCADASTRO Tabela SZO Dados de Bloqueio judicial Financeiro 

@author Adilson do Prado
@since 29/05/17
@version P12
@return Nil
/*/

User Function XCADSZO
Local 	cFiltra     := ""

Private cCadastro	:= "Bloqueio Judicial Finceiro"
Private cDelFunc	:= ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cString 	:= "SZO"
Private aIndexSz  	:= {}
PRIVATE aFixeFX     := {}
Private bFiltraBrw	:= { || FilBrowse(cString,@aIndexSz,@cFiltra) } 
Private aCores  := {}
Private aRotina	:= {}

//Variaveis Inicialização Padrao esta no Dicionario
PUBLIC cZO_TIPO   := ""
PUBLIC cZO_CODIGO := ""
PUBLIC cZO_AGENC  := ""
PUBLIC cZO_CONTA  := ""
PUBLIC cZO_PROCES := ""
PUBLIC cZO_VARA   := ""
PUBLIC cZO_TRIB   := ""
PUBLIC cZO_RECLAM := ""


AADD(aCores,{"SZO->ZO_TIPO=='B'","BR_VERMELHO"})
AADD(aCores,{"SZO->ZO_TIPO=='D'","BR_VERDE"})

AADD(aRotina,{"Pesquisa"		,"AxPesquisa",0,1})
AADD(aRotina,{"Visualizar"		,"AxVisual"  ,0,2})
AADD(aRotina,{"Bloqueio"	    ,"U_BLOQSZO" ,0,3})
AADD(aRotina,{"Desbloqueio"		,"U_DESBSZO" ,0,4})
AADD(aRotina,{"Excluir"			,"U_EXCBLOQ" ,0,5})
AADD(aRotina,{"Legenda"			,"U_SZOLEG"  ,0,6})


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


User Function SZOLEG()
Local aCores2 := {}
Local cLegenda := ""

cLegenda	:= "Legenda de Cores"

AADD(aCores2,{"BR_VERDE"   , "Desbloqueio Judicial"})
AADD(aCores2,{"BR_VERMELHO", "Bloqueio Judicial"})
             		
BrwLegenda(cLegenda,"Bloqueio Judicial Finceiro",aCores2)

Return Nil 


USER FUNCTION  BLOQSZO()
Local cRet 
cZO_TIPO	:=  "B" 
/*
IF !EMPTY(SZO->ZO_CODIGO)
	IF MsgYesNo("Deseja utilizar dados do registro atual ?")
		cZO_CODIGO	:=	SZO->ZO_CODIGO
		cZO_AGENC 	:=	SZO->ZO_AGENC 
		cZO_CONTA	:=	SZO->ZO_CONTA
		cZO_PROCES	:=	SZO->ZO_PROCES
		cZO_VARA  	:=	SZO->ZO_VARA  
		cZO_TRIB 	:=	SZO->ZO_TRIB 
		cZO_RECLAM	:=	SZO->ZO_RECLAM
	ENDIF
ENDIF
*/
cRet := AxInclui("SZO",,,,,,)

cZO_TIPO	:=  ""

IF cRet == 1 .AND. EMPTY(SZO->ZO_LBANCO)
	IF MsgYesNo("Deseja Incluir o Lançamento no Banco ?")
		MsgRun("Aguarde, gerando movimentação bancária…","",{|| CursorWait(), lRet := U_LBANCO(SZO->(Recno())) ,CursorArrow()})
	ENDIF   
ENDIF

Return Nil 




USER FUNCTION  DESBSZO()
Local cRet

cZO_TIPO	:=  "D"
cZO_CODIGO	:=	SZO->ZO_CODIGO
cZO_AGENC 	:=	SZO->ZO_AGENC 
cZO_CONTA	:=	SZO->ZO_CONTA
cZO_PROCES	:=	SZO->ZO_PROCES
cZO_VARA  	:=	SZO->ZO_VARA  
cZO_TRIB 	:=	SZO->ZO_TRIB 
cZO_RECLAM	:=	SZO->ZO_RECLAM

IF !EMPTY(cZO_CODIGO) .AND. SZO->ZO_TIPO == "B"
	cRet := AxInclui("SZO",,,,,,)
ELSE
	MSGINFO("Posicionar no processo Judicial que sofreu bloqueio para inclusão do desbloqueio. Verifique!!")
ENDIF

cZO_TIPO	:=  ""
cZO_CODIGO	:=	""
cZO_AGENC 	:=	"" 
cZO_CONTA	:=	""
cZO_PROCES	:=	""
cZO_VARA  	:=	""  
cZO_TRIB 	:=	"" 
cZO_RECLAM	:=	""

IF cRet == 1 .AND. EMPTY(SZO->ZO_LBANCO)
	IF MsgYesNo("Deseja Incluir o Lançamento no Banco ?")
		MsgRun("Aguarde, gerando movimentação bancária…","",{|| CursorWait(), lRet := U_LBANCO(SZO->(Recno())) ,CursorArrow()})
	ENDIF   
ENDIF

Return Nil 

//ECLUIR Bloqueio e Desbloqueio Judicial
USER FUNCTION EXCBLOQ()

Local nRegSE5 	:= VAL(SZO->ZO_LBANCO)
Local nRegSZO 	:= SZO->(Recno())
Local cRet 	  	:= ""
Local lRet		:= .F.
Local cCrLf   	:= Chr(13) + Chr(10)

	dbSelectArea("SE5")   
	SE5->(dbGoto(nRegSE5))
	IF SE5->(Recno())  == nRegSE5 .AND. EMPTY(SE5->E5_SITUACA)
	   IF MsgYesNo("Existe Lançamento Bancário para este Registro. Deseja Excluir??"+cCrLf+cCrLf+cCrLf+"Data - > "+DTOC(SE5->E5_DATA)+cCrLf+"Banco - > "+SE5->E5_BANCO+cCrLf+"Banco - > "+SE5->E5_AGENCIA+cCrLf+"Banco - > "+SE5->E5_CONTA+cCrLf+"Banco - > "+SE5->E5_DOCUMEN+cCrLf+"Banco - > "+SE5->E5_BENEF+cCrLf+"Banco - > "+TRANSFORM(SE5->E5_VALOR,"@E 999,999,999.99"))
			MsgRun("Aguarde, excluindo movimentação bancária…","",{|| CursorWait(), lRet := U_EXLBANCO(nRegSE5) ,CursorArrow()})
			IF lRet
				cRet := AxDeleta("SZO", nRegSZO, 5)	      
	      	ENDIF
	   ELSE
			cRet := AxDeleta("SZO", nRegSZO, 5)
	   ENDIF
	ELSE
		cRet := AxDeleta("SZO", nRegSZO, 5)
	ENDIF

Return cRet 



//FAZ O LANCAMENTO BANCARIO do Bloqueio e Desbloqueio Judicial
USER Function LBANCO(nRecno)

Local nX
Local aUsuarios := ALLUSERS()
Local nOpc      := 0
Local aFina100  := {}
Local lSucess	:= .T.

Private lMsErroAuto := .F.

nX := aScan(aUsuarios,{|x| x[1][1] == __cUserID})

If nX > 0
	cUsuario := aUsuarios[nX][1][2]
EndIf

BEGIN TRANSACTION
	
 	dbSelectArea("SZO")
	dbGoTo(nRecno)

	aFina100 := {{"E5_DATA"    ,SZO->ZO_DATA     ,Nil},;
	             {"E5_MOEDA"   ,"01"             ,Nil},;
	             {"E5_VALOR"   ,SZO->ZO_VALOR    ,Nil},;
	             {"E5_NATUREZ" ,"0000000055"     ,Nil},;
	             {"E5_BANCO"   ,SZO->ZO_CODIGO   ,Nil},;
	             {"E5_AGENCIA" ,SZO->ZO_AGENC    ,Nil},;
	             {"E5_CONTA"   ,SZO->ZO_CONTA    ,Nil}}
	    
	lMsErroAuto := .F.
	If SZO->ZO_TIPO == "B"
		nOpc := 3  
      	AADD(aFina100,{"E5_DOCUMEN" ,ALLTRIM(STR(nRecno))+"-BLOQUEIO JUDICIAL"  ,Nil})
       	AADD(aFina100,{"E5_BENEF"   ,SZO->ZO_RECLAM  ,Nil})
       	AADD(aFina100,{"E5_HISTOR"  ,"DEP. JUDICIAL ACAO TRABALHISTA -BLOQUEIO",Nil})
		AADD(aFina100,{"E5_DEBITO"  ,SZO->ZO_CONTAB ,Nil})
		AADD(aFina100,{"E5_CCD"     ,'000000001'    ,Nil})
	Else
		nOpc := 4
       	AADD(aFina100,{"E5_DOCUMEN" ,ALLTRIM(STR(nRecno))+"-DESBLOQUEIO JUDICIAL"  ,Nil})
       	AADD(aFina100,{"E5_BENEF"   ,SM0->M0_NOME  ,Nil})
       	AADD(aFina100,{"E5_HISTOR"  ,"DEP. JUDICIAL ACAO TRABALHISTA -DESBLOQU",Nil})
		AADD(aFina100,{"E5_CREDITO" ,SZO->ZO_CONTAB ,Nil})
		AADD(aFina100,{"E5_CCC"     ,'000000001'    ,Nil})
	Endif
			
	MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,nOpc)
			
	If lMsErroAuto
		MostraErro()
		DisarmTransaction()
		lSucess := .F.
	EndIf
	
END TRANSACTION

dbSelectArea("SZO")
dbGoTo(nRecno)

RecLock("SZO",.F.)
SZO->ZO_LBANCO := STR(SE5->(Recno()))
SZO->(MsUnlock())      

If lSucess
	Aviso("Sucesso","Movimentos bancários realizadas com sucesso.",{"OK"})
Else
	Aviso("Erro","Movimentos bancários não foram realizadas.",{"OK"})
EndIf	

Return lSucess



//EXCLUI O LANCAMENTO BANCARIO do Bloqueio e Desbloqueio Judicial
USER Function EXLBANCO(nRecno)

Local nX
Local aUsuarios := ALLUSERS()
Local nOpc      := 5
Local aFina100  := {}
Local lSucess   := .T.

Private lMsErroAuto := .F.

nX := aScan(aUsuarios,{|x| x[1][1] == __cUserID})

If nX > 0
	cUsuario := aUsuarios[nX][1][2]
EndIf

BEGIN TRANSACTION
	
  	dbSelectArea("SE5")
	dbGoTo(nRecno)

	aFina100 := {{"E5_DATA"    ,SE5->E5_DATA    ,Nil},;
	             {"E5_MOEDA"   ,SE5->E5_MOEDA   ,Nil},;
	             {"E5_VALOR"   ,SE5->E5_VALOR   ,Nil},;
	             {"E5_NATUREZ" ,SE5->E5_NATUREZ ,Nil},;
	             {"E5_BANCO"   ,SE5->E5_BANCO   ,Nil},;
	             {"E5_AGENCIA" ,SE5->E5_AGENCIA ,Nil},;
	             {"E5_CONTA"   ,SE5->E5_CONTA   ,Nil},;
	             {"E5_DOCUMEN" ,SE5->E5_DOCUMEN ,Nil},;
                 {"E5_BENEF"   ,SE5->E5_BENEF   ,Nil},;
                 {"E5_HISTOR"  ,SE5->E5_HISTOR  ,Nil},;
				 {"E5_RECPAG"  ,SE5->E5_RECPAG  ,Nil},;
				 {"E5_IDMOVI"  ,SE5->E5_IDMOVI  ,Nil},;
				 {"INDEX"      ,10              ,Nil}} 

	lMsErroAuto := .F.
			
	MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,nOpc)
			
	If lMsErroAuto
		MostraErro()
		DisarmTransaction()
		lSucess := .F.
	EndIf
	
END TRANSACTION

If lSucess
	Aviso("Sucesso","Movimentos bancários excluidos com sucesso.",{"OK"})
else
	Aviso("Erro","Movimentos bancários não foram excluidos.",{"OK"})	
EndIf

Return lSucess

