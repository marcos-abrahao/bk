
#include "PROTHEUS.CH"
#include "TopConn.ch"
#include "RwMake.ch" 

/*/{Protheus.doc} BKCOMA06
BK - Atualizar a tabela SA2 atraves da tabela PowerBk.dbo.FORNBARCAS - Usado para importar fornecedores na Barcas Rio
@Return
@author Marcos Abrahão
@since 19/02/2025 
@version P12
/*/

User Function BKCOMA06()
Private cPerg := "BKCOMA06"
u_WaitLog("BKCOMA06", {|| PRCCOMA06()},'Importando fornecedores..')

Return Nil


// Picture A2_BAIRRO @!S15                                        
// A2_COD X3_RELACAO = U_BKCOMF11()

Static Function PRCCOMA06()
Local cCodigo   := ""
Local cLoja     := "01"
Local cQuery    := ""
Local aSA2      := {}
Local cCodMun   := ""
Local nRepl     := 0

If cEmpAnt <> '20'
    u_MsgLog(cPerg,"Somente para empresa 20","E")
    Return
EndIf

cQuery := " SELECT " + CRLF
cQuery += "   CODIGO" + CRLF
cQuery += "  ,CNPJ" + CRLF
cQuery += "  ,NOME" + CRLF
cQuery += "  ,NREDUZ" + CRLF
cQuery += "  ,EST" + CRLF
cQuery += "  ,BAIRRO" + CRLF
cQuery += "  ,CEP" + CRLF
cQuery += "  ,ENDER" + CRLF
cQuery += "  ,TEL" + CRLF
cQuery += "  ,MUN" + CRLF
cQuery += " FROM PowerBk.dbo.FORNBARCAS" + CRLF
cQuery += " ORDER BY CODIGO" + CRLF
TCQUERY cQuery NEW ALIAS "QTMP"

dbSelectArea("SA2")
SET ORDER TO 1

dbSelectArea("QTMP")
ProcRegua(LASTREC())
GO TOP
DO WHILE !EOF()

    cCodigo := ALLTRIM(QTMP->CODIGO)
    If Len(cCodigo) > 6 .AND. SUBSTR(cCodigo,1,2) == '10'
        cCodigo := '1'+Substr(cCodigo,3,5)
    EndIf

    dbSelectArea("CC2") 
    dbSetOrder(4)  
    cCodMun := ""
    If !EMPTY(QTMP->MUN) .AND. dbSeek(xFilial("CC2")+QTMP->EST+QTMP->MUN)
        cCodMun := CC2->CC2_CODMUN
    Else
        If QTMP->EST == "SP"
            cCodMun := "50308"
        ElseIf QTMP->EST == "RJ"
            cCodMun := "04557"
        EndIf
    EndIf

    dbSelectArea("SA2")
    IF !DBSEEK(xFilial("SA2")+cCodigo+cLoja,.F.)

        aSA2 := {}
        AADD(aSA2,{"A2_FILIAL"  , xFilial("SA2"),Nil} )
        AADD(aSA2,{"A2_COD"     , cCodigo,Nil})
        AADD(aSA2,{"A2_LOJA"    , cLoja,Nil})
        AADD(aSA2,{"A2_NOME"    , QTMP->NOME,Nil})
        AADD(aSA2,{"A2_NREDUZ"  , QTMP->NREDUZ,Nil})
        AADD(aSA2,{"A2_TIPO"    , "J",Nil})
        AADD(aSA2,{"A2_CGC"     , QTMP->CNPJ,Nil})
        AADD(aSA2,{"A2_EST"     , QTMP->EST,Nil})
        AADD(aSA2,{"A2_INSCR"   , "ISENTO",Nil})
        AADD(aSA2,{"A2_END"     , QTMP->ENDER,Nil})
        AADD(aSA2,{"A2_BAIRRO"  , QTMP->BAIRRO,Nil})
        AADD(aSA2,{"A2_COD_MUN" , cCodMun,Nil})
        AADD(aSA2,{"A2_MUN"     , QTMP->MUN,Nil})
        AADD(aSA2,{"A2_TEL"     , QTMP->TEL,Nil})   
        AADD(aSA2,{"A2_CEP"     , SUBSTR(QTMP->CEP,1,5)+SUBSTR(QTMP->CEP,7,3),Nil})   
        AADD(aSA2,{"A2_NATUREZ" , "0000000010",Nil})            
        AADD(aSA2,{"A2_XXBLNAT" , "N",Nil})        
        AADD(aSA2,{"A2_COND"    , "002",Nil}) 
        AADD(aSA2,{"A2_PAIS"    , "105",Nil}) 
        AADD(aSA2,{"A2_CODPAIS" , "01058",Nil}) 
        AADD(aSA2,{"A2_CONTA"   , "21101001",Nil})   

        Begin Transaction 

            lMsErroAuto := .F.
            
            MSExecAuto({|x,y| MATA020(x,y)},aSA2,3)

            IF lMsErroAuto
                u_LogMsExec(cPerg,"Erro ao incluir o fornecedor: "+cCodigo+" Loja: "+cLoja)
                DisarmTransaction()
            //Else
                //u_MsgLog(cPerg,"Fornecedor copiado com sucesso!! código: "+SA2->A2_COD+"  Loja: "+SA2->A2_LOJA+" - "+SA2->A2_NOME,"S")
            Endif
        End Transaction

        nRepl++
    ELSE
    ENDIF
    dbSelectArea("QTMP")
    dbSkip()
ENDDO

u_MsgLog("BKCOMA06","Registros adicionados SB7: "+STR(nRepl,6),"I")

Return Nil

