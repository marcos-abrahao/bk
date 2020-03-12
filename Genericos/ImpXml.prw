

//Local _cServer   := SuperGetMv("MV_RELSERV")
//Local _cMail     := SuperGetMv("MV_NFEMAIL")
//Local _cUser     := SuperGetMv("MV_NFEUSER") //Usuario do email de nota eletronica
//Local _cSenha    := SuperGetMv("MV_NFEPASS") //senha deste email 


#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "ap5mail.ch"

User Function ImpXML(lJob)
local aArq
local cFile := ""
Local I

Default lJob := .f.

Private cPath := "\nfe\"

//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" MODULO "EST" TABLES "SA2", "SA5", "SD1", "SB1", "SLK"

While .T.

     aArq := directory(cPath+"*.xml")
     For I := 1 To len(aArq)
          cFile := lower(aArq[1])

          XMLNFE(cFile)
     Next I

    if ! lJob // Se nao for chamado como job sai apos a primeira iteracao
         exit
    EndIf
     Sleep(5000) // Aguarda 5 segundos para iniciar a verificacao!
End

Return()


Static Function XMLNfe(cFile)

Local cError      := ""
Local cWarning      := ""
Local oXml           := NIL

oXml := XmlParserFile( cPath+cFile, "_", @cError, @cWarning )
If ValType(oXml) != "O"
     Alert(cFile+" - "+cError)
     Return()
Endif

If ValType(oXml:_NfeProc:_Nfe:_InfNfe:_DET) = "O"
     XmlNode2Arr(oXml:_NfeProc:_Nfe:_InfNfe:_DET, "_DET")
EndIf

Private cNum //Numero da Nota
Private cFornec := ""
Private cLjFornec := ""
//Private cNaturez
//Private cError := 0
//Private nErrorItem := 0

Private cCNPJ_FIL // Cnpj da Loja
Private cCNPJ_FOR// Cnpj da Loja

Private cDtEmissao
Private cCcd // Centro de Custo
//Private cPref // Prefixo da Filial
Private cFilorig   // Filial de Origem

Private nDescVar
Private nDescNota
Private nDescItens

Private nIcms
Private nIcmsRet
Private nIcmsRepa
Private nIcmsSubs

Private nSeguro
Private nFrete
Private nAdicional

Private nIcmsPer
Private nIcmsBase

Private cSerie := "1 "
Private cTipo := "N"
//Private cCod

Private nCont
Private cCodigo
Private cUM
Private bLote
Private cLote
Private cValidade

Private cCodBarra
Private nQuant
Private nPrcUnLiq
Private nDescItem // %
Private nValDesc // $
Private nItem := 0

Private bMed
Private nContLote // Contador do For
Private nTotalMed // Len do Array Med
Private nQtdeLote // Qtde do Lote Atual
Private nDescLote // Desconto do Lote Atual
Private nValLote // Valor do Lote Atual
Private nDescTT   // Acumulado do Desconto
Private nValorTT // Acumulado
Private cUnidad   // Unidade do fornecedor
Private nFator    // Fator de Conversao

Private nNumItens
Private nNumUnid

Private nTotalMerc

Private cNumTitulo
Private nValor
Private cVencimento
Private nDescDia
Private nDescFin
Private nJurosDia
Private nMulta
Private nAcrescimo

Private aCabec := {}
Private aItens := {}
Private aLinha := {}
Private lOk    := .T.
Private lMsErroAuto := .F.
Private lMsHelpAuto     := .T.

Private cArqLog := cPath+substr(cFile,1,at(".xml",cFile)-1) /*+"_"+ dtos(date())*/+".log"

Private cFound := 0 // Resultado de Busca


// inicializa as variaveis de controle
nError := 0
cFilorig := "XX"

cCNPJ_FIL := oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT

OpenSm0()
SM0->(dbGoTop())
While !SM0->(Eof())
     If cEmpAnt != SM0->M0_CODIGO
          SM0->(dbskip()) // ignora filiais que nao sejam da empresa ativa.
          loop
     Endif
     
     If cCNPJ_FIL = SM0->M0_CGC
          cFilorig := SM0->M0_CODFIL
          Exit //Forca a saida
     Endif
     
     SM0->(dbskip())
EndDo

Do Case
     Case cFilorig = "XX"
          //Msgbox("Impossivel identificar Filial! Informe ao Programador.")
          U_Geralog("Filial Nao identificada: "+cCNPJ_FIL, cArqlog)
          nError += 1
     Case cFilorig = "00"
          cCcd     := "00040103"
     Otherwise
          cCcd     := cFilOrig+"1015"
EndCase

cCNPJ_FOR := oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
DBSelectArea("SA2")
DBSetOrder(3)
If DbSeek(xFilial("SA2")+cCNPJ_FOR)
     cFornec := A2_COD
     cLjFornec := A2_LOJA
     cNaturez := A2_EST
Else
     U_Geralog("Impossivel identificar Fornecedor! " + cCNPJ_FOR, cArqlog)
     nError += 1
Endif

cNum := padL(Alltrim(oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT),6,"0") //Nro da Nota
cSerie := PadR(oXml:_NfeProc:_Nfe:_InfNfe:_IDE:_Serie:Text,3," ")

nNumItens     := len(oXml:_NfeProc:_Nfe:_InfNfe:_DET)
cDtEmissao := oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_dEmi:Text
cDtEmissao := Substr(cDtEmissao,9,2)+"/"+Substr(cDtEmissao,6,2)+"/"+Substr(cDtEmissao,1,4)

nTotalMerc := Val(oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:Text) // Valor Mercadorias

//               nDescTT = 0 // Inicializa a variavel para realizar o somatorio de descontos da nota.
//               nTotalBrt = Val(Substr(cBuffer,69,12))/100

//     nDescVar      := Val(Substr(cBuffer,1,13))/100
nDescNota     := val(oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VDESC:Text)
//     nDescItens      := Val(Substr(cBuffer,29,13))/100

//     nIcms           := Val(Substr(cBuffer,1,13))/100
//     nIcmsRet      := Val(Substr(cBuffer,14,13))/100
//     nIcmsRepa      := Val(Substr(cBuffer,117,13))/100


cNumTitulo      := cNum // Substr(cBuffer,1,10)
nValor          := Val(oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:Text)

If XmlChildEx ( oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT , "VOUTRO" ) != Nil
     nAcrescimo     := Val(oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VOUTRO:Text)
Else
     nAcrescimo := 0
Endif

cVencimento := ""
If XmlChildEx ( oXml:_NFEPROC:_NFE:_INFNFE , "_COBR" ) != Nil
// Voltar mas tem que alterar para aceitar varias parcelas.
//     cVencimento     := oXml:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP:_DVENC:Text
//     cVencimento := Substr(cVencimento,9,2)+"/"+Substr(cVencimento,6,2)+"/"+Substr(cVencimento,1,4)
EndIf

nFrete          := 0//Val(Substr(cBuffer,24,12))/100
nSeguro      := Val(oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VSeg:Text)

nIcmsSubs     := Val(oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:Text)
//     nAdicional      := Val(Substr(cBuffer,1,13))/100

//     nIcmsPer      := Val(Substr(cBuffer,1,4))/100
//     nIcmsBase     := Val(Substr(cBuffer,5,13))/100

For nCont := 1 to nNumItens
     
     cCodBarra     := oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_CEAN:Text
     cCodForn     := AllTrim(oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_CPROD:Text)
     nQuant          := Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_QCOM:Text)
     //               nPrcUnLiq     := Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_VUNCOM:Text)
     //               nPrcTtLiq     := Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_VPROD:Text)
//     nPrcTtBrt     := Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_VPROD:Text) // Alterei pois quando tem desconto apresentou problema NF Panarello 502867
     nPrcUnBrt     := Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_VUNCOM:Text)
     nPrcTtBrt     := nQuant * nPrcUnBrt //Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_VPROD:Text)     
     
     If XmlChildEx(oXml:_NfeProc:_Nfe:_InfNfe:_DET[nCont]:_PROD, "_VDESC")!= Nil
          nValDesc     := Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_VDESC:Text)
     Else
          nValDesc     := 0
     EndIf
     
     // Busca o Codigo interno do produto.
     dbSelectArea("SA5")
     dbSetOrder(5)
     bOkItem := .F.
     
     If bOkItem == .F. .and. alltrim(str(val(cCodForn))) <> cCodForn .and. val(cCodForn) > 0 // busca sem os zeros no inicio. se existirem zeros.
          // 
          cCodForn     := Alltrim(Str(val(cCodForn)))
          
          If SA5->(dbSeek(xFilial("SA5")+   cCodForn ))
               While alltrim(SA5->A5_CODPRF) = cCodForn
                    If SA5->(A5_FORNECE+A5_LOJA) == cFornec+cLjFornec
                         bOkItem := .T.
                         cCodigo := SA5->A5_PRODUTO
                         cUnidad := SA5->A5_UM
                         Exit
                    Endif
                    DBSkip()
               EndDo
          EndIf
     Endif
     
     If bOkItem == .F.
          If SA5->(dbSeek(xFilial("SA5")+cCodForn)) // Busca pelo codigo do Fornecedor
               While alltrim(SA5->A5_CODPRF) = cCodForn
                    If SA5->(A5_FORNECE+A5_LOJA) == cFornec+cLjFornec
                         bOkItem := .T.
                         cCodigo := SA5->A5_PRODUTO
                         cUnidad := SA5->A5_UM
                         Exit
                    EndIf
                    DBSkip()
               EndDo
          Endif
     Endif
     
     If bOkItem = .F. .and. !Empty(cCodBarra)

        // Busca pelo Codigo de Barras no cadastro do produto
          dbSelectArea("SB1")
          dbSetOrder(5)
          If SB1->(dbSeek(xFilial("SB1")+cCodBarra))
               cCodigo := SB1->B1_COD               
               
               // Verifica se existe uma amarracao para o produto encontrado
               dbSelectArea("SA5")
               dbSetOrder(2)
               If ! DBSeek(xFilial("SA5")+cCodigo+cFornec+cLjFornec)
                    // Inclui a amarracao do produto X Fornecedor
                    bOkItem := .T.
                    RecLock("SA5",.T.)
                    A5_FILIAL     := xFilial("SX5")
                    A5_FORNECE    := cFornec
                    A5_LOJA       := cLjFornec
                    A5_NOMEFOR    := SA2->A2_NOME
                    A5_PRODUTO    := cCodigo
                    A5_NOMPROD    := SB1->B1_DESC
                    A5_CODPRF     := cCodForn
                    MSUnLock()
                    U_Geralog("F"+cFilOrig+ " " +cNum+"-> Produto sem amarracao: "+cCodForn+" -> "+cCodigo+" -> Incluido",cArqlog)
               Else
                    If Empty(SA5->A5_CODPRF) .or. SA5->A5_CODPRF = "0" // Atualiza a amarracao se nao tiver o codigo do fornecedor cadastrado.
                         bOkItem := .T.
                         RecLock("SA5",.F.)
                         A5_CODPRF     := cCodForn
                         MSUnLock()
                         U_Geralog("F"+cFilOrig+ " " +cNum+" -> Produto sem amarracao: "+cCodForn+" ->: "+cCodigo+" -> Atualizado",cArqlog)
                    Else
                         U_Geralog("F"+cFilOrig+ " " +cNum+ " Produto: "+cCodForn+" ("+oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_xProd:Text+") -> "+cCodigo +" ("+Alltrim(SB1->B1_DESC)+") Erro: Ja Possui amarracao para " + A5_CODPRF, cArqlog)
                         U_Geralog("", cArqlog)
                         nError += 1
                    Endif
               EndIf
          Endif

        // Busca pelo Codigo de Barras no cadastro do produto
          If !bOkItem
               dbSelectArea("SLK")
               DBSetOrder(1)
               If SLK->(dbSeek(xFilial("SLK")+cCodBarra))
                    bOkItem := .T.
                    cUnidad := "3"
                    cCodigo := SLK->LK_CODIGO
               Endif
          Endif
    Endif
    
     If !bOkItem
          U_Geralog("F"+cFilOrig+ " " +cNum+" -> Produto sem amarracao: "+cCodForn+" ("+oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_xProd:Text +") Codigo de barras: "+cCodBarra +" -> - ATENCAO -",cArqlog)
          nError += 1
     Else
          // Posiciona no produto encontrado
          DBSelectArea("SB1")
          DBSetOrder(1)
          DBSeek(xFilial("SB1")+cCodigo)
        
        If SB1->B1_MSBLQL = '1'
             U_Geralog("F"+cFilOrig+ " " +cNum+" -> Produto Bloqueado: "+cCodigo+" ("+oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_xProd:Text +") Codigo de barras: "+cCodBarra +" -> - ATENCAO -",cArqlog)

            //Retirar quando for para a producao 
//             RecLock("SB1",.F.)
//             SB1->B1_MSBLQL := "2"
//             MsUnlock()
             nError += 1
        Endif

     nFator := 1
          Do Case
               Case cUnidad = "2"
                    nFator := SB1->B1_CONV
               Case cUnidad = "3" .and. SLK->LK_QUANT > 1
                    nFator := SLK->LK_QUANT
          End Case

          //Verifica se possui Node _Med
          bMed := XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod , "_MED" ) != Nil
     
          If bMed
               // Converte o Node Med em array para os casos que existe informacao de mais de um lote do mesmo produto.          
               If ValType(oXml:_NfeProc:_Nfe:_InfNfe:_DET[nCont]:_PROD:_MED) = "O"
                    XmlNode2Arr(oXml:_NfeProc:_Nfe:_InfNfe:_DET[nCont]:_PROD:_MED, "_MED")
               EndIf

               nTotalMed := len(oXml:_NfeProc:_Nfe:_InfNfe:_DET[nCont]:_PROD:_MED)
          Else
               nTotalMed := 1
               nQtdeLote := nQuant
               cLote     := ""
               cValidade := ""
          Endif
                 
          // Acumuladores
          nDescTT   := 0
          nValorTT := 0
          For nContLote := 1 to nTotalMed
               nItem++
               aLinha    := {}
                           
               if bMed
                    cLote     := oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_MED[nContLote]:_NLote:Text
                    cValidade := oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_MED[nContLote]:_DVal:Text
                    cValidade := Substr(cValidade,9,2)+"/"+Substr(cValidade,6,2)+"/"+Substr(cValidade,1,4)
                    nQtdeLote := val(oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont]:_Prod:_MED[nContLote]:_QLote:Text)
            Endif
            
            If nContLote != nTotalMed
                    nDescLote := Round(nValDesc/nQuant*nQtdeLote,2) // Desconto do Lote Atual
                    nValLote := Round(nPrcTtBrt/nQuant*nQtdeLote,2) // Valor do Lote Atual

                    nDescTT   += nDescLote
                    nValorTT += nValLote                    
            Else
                    nDescLote := nValDesc - nDescTT // Desconto do Lote Atual - Diferenca
                    nValLote := nPrcTtBrt - nValorTT // Valor do Lote Atual - Diferenca
            Endif
            
               aadd(aLinha,{"D1_ITEM" ,STRZERO(nItem,3)   ,Nil})
               aadd(aLinha,{"D1_FILIAL",cFilorig           ,Nil})
               aadd(aLinha,{"D1_COD"   ,cCodigo            ,Nil})
//               aadd(aLinha,{"D1_UM"    ,"UN"               ,Nil})

               // Altera a quantidade em funcao da seg unidade ou da quantidade do cod. de barras.
               If nFator > 1               
                    nQtdeLote := nQtdeLote*SB1->B1_CONV
               Endif
               aadd(aLinha,{"D1_QUANT" , nQtdeLote          ,Nil})
               
//               Passei a calcular o valor unitario, para evitar erro na validacao do total e na conversao de unidade
//               aadd(aLinha,{"D1_VUNIT" ,nPrcUnBrt          ,Nil})
               aadd(aLinha,{"D1_VUNIT" ,nValLote/nQtdeLote ,Nil})
               
               //nTotalBrt += round(nQuant*nPrcUnBrt,2)
               aadd(aLinha,{"D1_TOTAL" ,nValLote           ,Nil}) //Valor total proporcional
               
               //                              aadd(aLinha,{"D1_TES","081",Nil})
               aadd(aLinha,{"D1_OPER" ,"51"               ,Nil})
               aadd(aLinha,{"D1_CONTA" ,"210102"           ,Nil})
               
               aadd(aLinha,{"D1_VALDESC", nDescLote        ,Nil}) //Valor Desconto proporcional /*nValDesc/nQuant*nQuantLt*/
               //          aadd(aLinha,{"D1_VALFRE",0,NIL})
               //          aadd(aLinha,{"D1_DESPESA",0,NIL})
               
               aadd(aLinha,{"D1_LOTEFOR",cLote             ,Nil})
               //                              aadd(aLinha,{"D1_LOTECTL",cLote,Nil})
               //                              if cValidade != "00/00/0000"
               //                                   aadd(aLinha,{"D1_DTVALID",ctod(cValidade),NIL})
               //                              Endif
            
            // Incluir sempre no ultimo elemento do array de cada item
               aadd(aLinha,{"AUTDELETA","N"                 ,Nil}) 
               
               aadd(aItens,aLinha)
          Next
     Endif
Next

DBSelectArea("SF1")
DbSetorder(1)

If nError = 0
     If DbSeek(cFilorig+cNum+cSerie+cFornec+cLjFornec+cTipo/*,.T.*/)
          nError += 1
          cFound += 1
          U_Geralog("F"+cFilOrig+ " " +cNum+"-> Nao importada. Nota ja foi cadastrada. " + cFornec+"/"+cLjFornec,cArqlog)
     Endif
else
     U_Geralog("F"+cFilOrig+ " " +cNum+"-> Nao importada. Existem inconsistencias na nota. Fornecedor: "+cFornec+"/"+cLjFornec,cArqlog)
Endif

If nError = 0
     
     aCabec := {}
     
     aadd(aCabec,{"F1_TIPO"   ,"N"})
     aadd(aCabec,{"F1_FORMUL" ,"N"})
     aadd(aCabec,{"F1_DOC"    ,cNum})
     aadd(aCabec,{"F1_SERIE" ,cSerie})
     aadd(aCabec,{"F1_EMISSAO",ctod(cDtEmissao)})
     //                         aadd(aCabec,{"F1_DESPESA",12}) //despesa - teste
     aadd(aCabec,{"F1_FORNECE",cFornec})
     aadd(aCabec,{"F1_LOJA"   ,cLjFornec})
     aadd(aCabec,{"F1_ESPECIE","SPED"})
     aadd(aCabec,{"F1_COND"   ,"134"})
     //                         aadd(aCabec,{"F1_DESCONT",nIcmsRepa+nDescItens,NIL})
     aadd(aCabec,{"F1_SEGURO" ,nSeguro,NIL})
     aadd(aCabec,{"F1_FRETE" ,nFrete,NIL})
     aadd(aCabec,{"F1_VALMERC",nTotalMerc,NIL})
     aadd(aCabec,{"F1_VALBRUT",nTotalMerc+nSeguro+nFrete+nIcmsSubs,NIL})
     //aadd(aCabec,{"F1_VALBRUT",nTotalMerc+nSeguro+nFrete+nAdicional,NIL})
     //aadd(aCabec,{"F1_DESCONT",0,NIL})
     
     // Forca a busca pelo codigo interno do produto.
     dbSelectArea("SB1")
     dbSetOrder(1)
     
     Begin Transaction
     
     /* Alteracao da filial corrente. */
     cFilAtu := cFilAnt
     cFilAnt := cFilOrig
     MATA140(aCabec,aItens,3)
//     MATA103(aCabec,aItens,3,.t.)
     cFilAnt := cFilAtu
     
     If !lMsErroAuto
          U_Geralog("F"+ cFilOrig+ " " +cNum+"-> Incluido com sucesso !! ",cArqlog)
     Else
          mostraerro()
          U_Geralog("F"+ cFilOrig+ " " +cNum+"-> Erro na Inclusao !! ",cArqlog)
          lMsErroAuto := .F.
          FRename(cPath+cFile, cPath+substr(cFile,1,at(".xml",cFile)-1) +".auto")
//          nError += 1
          //DisarmTransaction() // desfaz as alteracoes ja efetuadas.
     EndIf
     End Transaction
     
Endif

If nError > 0
     FRename(cPath+cFile, cPath+substr(cFile,1,at(".xml",cFile)-1) +".err")
     //envia o email
     MailNFE()
Else
     FRename(cPath+cFile, cPath+substr(cFile,1,at(".xml",cFile)-1) +".imp")
Endif

nItem := 0
//nErrorItem := 0
aCabec := {}
aItens := {}
aLinha := {}

Return()

User Function RenErrXML
Local aArq, I
Local cPath := "\nfe\err\"

aArq := directory(cPath+"*.err")
For I := 1 To len(aArq)
     cFile := lower(aArq[1])

     FRename(cPath+cFile, cPath+substr(cFile,1,at(".err",cFile)-1) +".xml")
Next I

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Programa Exemplo de Envio de Email³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function MailNFE()

Local _cServer   := SuperGetMv("MV_RELSERV")
Local _cMail     := SuperGetMv("MV_NFEMAIL")
Local _cUser     := SuperGetMv("MV_NFEUSER")
Local _cSenha    := SuperGetMv("MV_NFEPASS")

Local cFrom      := "nfe@grupoofs.com.br"
Local cTo        := _cMail
Local cAssunto   := "Importacao NFE" + " - " + Time()
Local cBody      := "TESTE"
Local aFiles     := {}

Local lOk        := .T.
//Local msg        :="teste"

aAdd(aFiles, cArqlog)

CONNECT SMTP SERVER _cServer ACCOUNT _cUser PASSWORD _cSenha Result lOk

If lok
     //     Alert("Conectado com servidor de E-Mail - " + _cServer)
Endif

lEnviado := MailSend(cFrom, {cTo},{},{}, cAssunto, cBody, aFiles,.F.)

If !lEnviado
     cError := MailGetErr()
     connout("Falha na conexao: " + cError + " - " + cArqlog)
     //     Return(.F.)
Endif

DISCONNECT SMTP SERVER result lOk

return()





//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao para gerar arquivo de Log.³
//³      cPar01: Texto a imprimir   ³
//³      cPar02: Caminho do Arquivo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function GeraLog(cTexto,cArqLog)

Local nHdl    := 0
Local cArq      := cArqLog

If File(cArq)
     nHdl := FOpen(cArq, 2)
Else
     nHdl := FCreate(cArq)
Endif

If nHdl > 0
     cTexto := cTexto + chr(13) + chr(10)
     FSeek(nHdl,0,2)
     FWrite(nHdl, cTexto)
     FClose(nHdl)
Else
     ConOut("******************************************")
     ConOut("Base - Nao foi possivel criar arquivo " + cArq)
     ConOut("******************************************")
Endif

Return(NIL)







/*

MV_NFEUSER = usuario do email
MV_NFEPASS = senha do email
MV_NFEMAIL = endereco de email

Precisei fazer um tratamento pois existe mais de uma estrutura de xml para as nfe.

oXml := XmlParserFile( cPath+cFile, "_", @cError, @cWarning )
If ValType(oXml) != "O"
     Alert(cFile+" - "+cError)
     Return()
Endif

// Alterado para tratar quando nao tem o nó _NFEPROC -- AQUI EU ALTEREI
oNFE := XmlChildEx( oXml , "_NFE" )
If ValType(oNFE) = "U"
     oNFE := XmlChildEx( oXml:_NFEPROC , "_NFE" )
Endif


No restante do fonte ao inves de fazer referencia ao 

oXml:_NFEPROC

passei a fazer referencia ao objeto

oNFE
*/

