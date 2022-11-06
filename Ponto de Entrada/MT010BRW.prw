#include "protheus.ch"

/*/{Protheus.doc} MT010BRW
BK - Copiar produtos p/ outras empresas
Ponto de Entrada para criar opções na tela de Funcões no cadastro de produtos            

@Return
@author Marcos Bispo Abrahão
@since 23/03/17
@version P12-25
/*/ 

User Function MT010BRW() 
Local aRotY

AADD( aRotina, {OemToAnsi("Copiar p/ outras empresas"), "U_BKMAT010", 0, 4 } )

Return aRotY




// Incluir DNF na BK
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
If msgYesNo('Deseja incluir este produto em outras empresas?')
	
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
			MsgStop("Erro provavelmente ocorrido por se ter excedido o número de licenças, tente novamente mais tarde.", "Atenção")
			u_MsgLog("BKMAT010","Erro1 ao incluir o o produto "+SB1->B1_COD+" na empresa "+TRIM(aEmpr[nI,4]))
		ELSE
			IF SUBSTR(cRetorno,1,2) <> "OK"
				If !EMPTY(cRetorno)
					MsgStop("Erro ao incluir o produto na empresa "+TRIM(aEmpr[nI,4]), "Atenção")
					MsgStop(cRetorno, "Atenção")
				Else
					MsgStop("Produto não incluído na empresa "+TRIM(aEmpr[nI,4]), "Atenção")
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
// Erros desta função somente aparecem no log do console do servidor
User Function BKMATJ10(_aParametros)

Local _cEmpresa  := _aParametros[1] // Usar o paramixb
Local _cFilial   := _aParametros[2]
Local _aProd     := _aParametros[3]
//Local _cUsuario  := _aParametros[4]
//Local _cSuper 	 := _aParametros[5]

Local cErrLog    := ""
Local cRetorno   := _aProd[2,2]
//Local aUser		 := {}

//RpcSetType(3)

// Prepara a empresa BK
//PREPARE ENVIRONMENT EMPRESA _cEmpresa FILIAL _cFilial TABLES "SF1","SD1"
RpcSetEnv( _cEmpresa, _cFilial )

lMsErroAuto := .F.    
          
MSExecAuto({|x,y| Mata010(x,y)},_aProd,3) //Inclusão 

u_xxConOut("INFO","BKMATJ10","Empresa: "+_cEmpresa+" - Produto: "+cRetorno)

If lMsErroAuto

	cErrLog:= CRLF+MostraErro("\TMP\","BKMATJ10.ERR")
	u_xxLog("\LOG\BKMATJ10.LOG",cErrLog)

	cRetorno := cErrLog
	lRet := .F.
Else
	cRetorno := "OK"
	u_xxConOut("INFO","BKMATJ10","Produto "+cRetorno)	
EndIf

RpcClearEnv()
  
Return cRetorno

