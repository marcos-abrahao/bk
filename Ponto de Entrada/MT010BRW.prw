#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT010BRW
BK - Copiar produtos p/ outras empresas
Ponto de Entrada para criar op��es na tela de Func�es no cadastro de produtos            

@Return
@author Marcos Bispo Abrah�o
@since 23/03/17
@version P12
/*/ 

User Function MT010BRW() 
Local aRotY

AADD( aRotina, {OemToAnsi("Copiar p/ outras empresas")	, "U_BKMAT010", 0, 4 } )
If __cUserID = "000000"
	AADD( aRotina, {OemToAnsi("Substitui��o de Produto"), "U_BKCOMA01", 0, 4 } )
	AADD( aRotina, {OemToAnsi("Exclus�o de Produtos")	, "U_BKCOMA1E", 0, 4 } )
EndIf
AADD( aRotina, {OemToAnsi("Rela��o de Prod. Grupos Subgrp Valor"), "U_BKCOMR19", 0, 4 } )
Return aRotY


// Incluir Produto em outras empresas
User Function BKMAT010()
Local sAlias	  
Local aAreaAtu	  
Local aParametros := {}
Local aProd       := {}
Local cRetorno    := ""
Local cUsuario    := __cUserId
Local cSuper	  := "" 
Local aEmpr       := {}
Local nI

If u_MsgLog('BKMAT010','Deseja incluir este produto em outras empresas?','Y')
	
    aProd := {{"B1_TIPO"    ,SB1->B1_TIPO        ,Nil},;
	          {"B1_COD"     ,SB1->B1_COD         ,Nil},;
	          {"B1_DESC"    ,SB1->B1_DESC        ,Nil},;
	          {"B1_UM"      ,SB1->B1_UM          ,Nil},;
	          {"B1_ALIQISS" ,SB1->B1_ALIQISS     ,Nil},;
	          {"B1_LOCPAD"  ,SB1->B1_LOCPAD      ,Nil},;
	          {"B1_GRUPO"   ,SB1->B1_GRUPO       ,Nil},;
	          {"B1_CONTA"   ,SB1->B1_CONTA       ,Nil},;
	          {"B1_IRRF"    ,SB1->B1_IRRF        ,Nil},;
	          {"B1_INSS"    ,SB1->B1_INSS        ,Nil},;
	          {"B1_PIS"     ,SB1->B1_PIS         ,Nil},;
	          {"B1_COFINS"  ,SB1->B1_COFINS      ,Nil},;
	          {"B1_CSLL"    ,SB1->B1_CSLL        ,Nil},;
	          {"B1_XXSGRP"  ,SB1->B1_XXSGRP      ,Nil},;
	          {"B1_XXGRPF"  ,SB1->B1_XXGRPF      ,Nil}}
                                   

	aParametros := {"11","01",aProd,cUsuario,cSuper}

		
	// Inicia o Job
	sAlias	  := Alias()
	aAreaAtu  := GetArea()
	nRecNo    := RECNO()

	aEmpr := U_EscEmpresa()
	For nI := 1 TO LEN(aEmpr)
	    
	    aParametros[1] := aEmpr[nI,1]
	    aParametros[2] := aEmpr[nI,2]
	    
		cRetorno := ""
		MsgRun("incluindo produto na empresa "+TRIM(aEmpr[nI,4])+", aguarde...","",{|| CursorWait(), cRetorno := StartJob("U_BKMATJ10",GetEnvServer(),.T.,aParametros) ,CursorArrow()})
        
		IF VALTYPE(cRetorno) <> "C"
			u_MsgLog("BKMAT010","Erro provavelmente ocorrido por se ter excedido o n�mero de licen�as, tente novamente mais tarde.","E")
			u_MsgLog("BKMAT010","Erro1 ao incluir o o produto "+SB1->B1_COD+" na empresa "+TRIM(aEmpr[nI,4]))
		ELSE
			IF SUBSTR(cRetorno,1,2) <> "OK"
				If !EMPTY(cRetorno)
					u_MsgLog("BKMAT010","Erro ao incluir o produto na empresa "+TRIM(aEmpr[nI,4])+": "+cRetorno, "E")
				Else
					u_MsgLog("BKMAT010","Produto n�o inclu�do na empresa "+TRIM(aEmpr[nI,4]), "E")
				EndIf
				u_MsgLog("BKMAT010","Erro2 ao incluir o o produto "+SB1->B1_COD+" na empresa "+TRIM(aEmpr[nI,4]))
			ELSE
				u_MsgLog("BKMAT010","Produto "+SB1->B1_COD+" incluido na empresa "+TRIM(aEmpr[nI,4]))
			ENDIF
		ENDIF

	Next
	RestArea( aAreaAtu )

	dbSelectArea(sAlias)
	dbGoTo(nRecNo)
	
EndIf

Return



// Esta funcao e a funcao chamada pela funcao StartJob
// Erros desta fun��o somente aparecem no log do console do servidor
User Function BKMATJ10(_aParametros)

Local _cEmpresa  := _aParametros[1] // Usar o paramixb
Local _cFilial   := _aParametros[2]
Local _aProd     := _aParametros[3]
//Local _cUsuario  := _aParametros[4]
//Local _cSuper 	 := _aParametros[5]
Local cRetorno   := _aProd[2,2]
//Local aUser		 := {}

//RpcSetType(3)

// Prepara a empresa BK
//PREPARE ENVIRONMENT EMPRESA _cEmpresa FILIAL _cFilial TABLES "SF1","SD1"
RpcSetEnv( _cEmpresa, _cFilial )

lMsErroAuto := .F.    
          
MSExecAuto({|x,y| Mata010(x,y)},_aProd,3) //Inclus�o 

u_MsgLog("BKMATJ10","Empresa: "+_cEmpresa+" - Produto: "+cRetorno)

If lMsErroAuto
	cRetorno := u_LogMsExec("BKMATJ10")
	lRet := .F.
Else
	cRetorno := "OK"
	u_MsgLog("BKMATJ10","Produto "+cRetorno)	
EndIf

RpcClearEnv()
  
Return cRetorno
