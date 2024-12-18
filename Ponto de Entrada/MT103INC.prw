#Include "protheus.ch"
#Include "totvs.ch"
#Include "topconn.cH"

/*/{Protheus.doc} MT103INC
P.E. - Verifica se pode-se classificar o documento.
===================================================
Fluxo de libera��o de Pr�-Notas - BK
Campo F1_XXLIB: Liberacao   
L=Liberada;N=Nao Liberada;A=A liberar;C=Classificada;E=Estornada;B=Bloqueada;T=Token;P=A Aprovar;V=Aprovada

---------------------------------------------------
Inclus�o da Pr� Nota: 
SF1140i: Gravar F1_XXLIB := "A" ou "T" caso o vencimento esteja menor ou igual a 48h, solicitar Token
MT140SAI: Gravar F1_XXLIB := "B" caso a pr� nota tenha sido bloqueada 
---------------------------------------------------
Inclus�o de Doc. de Entrada (permitida para administradores)
SF1100i: Gravar F1_XXLIB := "C" ou "B" caso o doc tenha sido bloqueado
---------------------------------------------------
Estorno da Classifica��o:
MT103FIM: Gravar F1_XXLIB := "E", e enviar e-mail
---------------------------------------------------
Libera��o do Bloqueio do Doc de entrada:
MT094END: Gravar F1_XXLIB := "L" (e avaliar fornecedor) ou "B" caso o doc tenha sido bloqueado
---------------------------------------------------
Classifica��o do Doc de Entrada: MT103INC
X3_CBOX: F1_XXLIB -> L=Liberada;N=Nao Liberada;A=A liberar;C=Classificada;E=Estornada;B=Bloqueada;T=Token;9=A Aprovar;D=Reprovada                    	


Se F1_XXLIB

	A: Libera ou N�o Libera (L ou N)
		Se n�o Liberar -> enviar e-mail para quem incluiu (e quem n�o liberou)

	9: Aprova ou Reprova (A ou R)
		Se n�o aprovar -> enviar e-mail para quem incluiu (e quem reprovou)

	L ou E: Somente Grupo User Fiscal ou Administradores podem classificar
		Op��es: Classifica
				Estorna (F1_XXLIB := "E") e envia e-mail a quem incluiu e quem liberou

	N: Permite liberador Liberar novamente

	B: Nenhuma opera��o pode ser feita aqui

	D: Permite aprovador aprovar novamente

---------------------------------------------------

@author Marcos Bispo Abrah�o
@since 24/11/2020
@version 1.0
@type function
/*/
User Function MT103INC()
Local lClass    := Paramixb
Local lRet      := .F.
Local nOper     := 0
Local aArea		:= GetArea()
Local cLogDoc	:= SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+" "+SF1->F1_ESPECIE
//              					    Admins/Fin   /Dire  /Fiscal/Lib Docs
Local lMaster   := u_InGrupo(__cUserId,"000000/000005/000007/000031/000038")

If lClass
	If !IsBlind() .AND. !u_IsLibDPH("MT103INC",__cUserId);
    		.AND. (SUBSTR(TIME(),1,2) > '19' .OR. SUBSTR(TIME(),1,2) < '07')
        lRet := .F.
	Else
		If SF1->F1_XXLIB == 'A' .OR. (lMaster .AND. (SF1->F1_XXLIB == '9' .OR. SF1->F1_XXLIB == 'R'))
			
			If lMaster
				If (SF1->F1_XXLIB == '9' .OR. SF1->F1_XXLIB == 'R')
					nOper := u_AvisoLog("MT103INC","MT103INC","Aprova��o e Libera��o para classifica��o fiscal:",{"Aprovar e Liberar","N�o Liberar","Cancelar"})
				Else
					nOper := u_AvisoLog("MT103INC","MT103INC","Libera��o para classifica��o fiscal:",{"Liberar","N�o Liberar","Cancelar"})
				EndIf
				If nOper <> 3
					RecLock("SF1",.F.)
					// Libera��o e Aprova��o pelo mesmo usu�rio
					If (SF1->F1_XXLIB == '9' .OR. SF1->F1_XXLIB == 'R')
						SF1->F1_XXUAPRV := __cUserId
						SF1->F1_XXDAPRV := DtoC(Date())+"-"+Time()
					EndIf

					If nOper == 1
						SF1->F1_XXLIB  := "L"
					Else
						SF1->F1_XXLIB  := "N"
					EndIf
					SF1->F1_XXULIB := __cUserId
					SF1->F1_XXDLIB := DtoC(Date())+"-"+Time()

					MsUnLock("SF1")

					If nOper == 1
						// Avalia��o do Fornecedor
						If u_IsAvalia(__cUserId)
							u_WaitLog(,{|| prcD1Aval() },"Aguarde","Pesquisando pedidos para avalia��o...",.F.)

							dbSelectArea("TMPSD1")
							dbGoTop()
							If !TMPSD1->(EOF())
								// Somente avaliar NF com pedido de compra atrelado
								If !Empty(TMPSD1->D1_PEDIDO)
									U_AvalForn(.F.)
								EndIf
							EndIf
							TMPSD1->(DbCloseArea())
						EndIf

						u_MsgLog("MT103INC","Doc liberado: "+cLogDoc)

					ElseIf nOper == 2

						// Caso n�o libere, enviar e-mail para quem incluiu o Documento
						//cEmail += UsrRetMail(SF1->F1_XXUSER)

						u_SF1Email("Pr�-Nota n�o liberada pelo aprovador")

						u_MsgLog("MT103INC","Doc n�o foi liberado: "+cLogDoc)
					EndIf
				EndIf
			Else
				u_MsgLog("MT103INC","Usu�rio sem permiss�o para liberar documentos: "+cLogDoc,"E")
			EndIf

		// Nova aprova��o em duas etapas
		ElseIf SF1->F1_XXLIB == '9' .OR. SF1->F1_XXLIB == 'R'

			If u_IsSuperior(__cUserId) .OR. u_IsStaf(__cUserId) .OR. lMaster
				If __cUserId <> SF1->F1_XXUSER .OR. lMaster
					If SF1->F1_XXLIB == '9'
						nOper := u_AvisoLog("MT103INC","MT103INC","Aprova��o para libera��o:",{"Aprovar","Reprovar","Cancelar"})
					Else
						nOper := u_AvisoLog("MT103INC","MT103INC","Aprova��o para libera��o:",{"Aprovar","Manter Reprovada","Cancelar"})
					EndIf
					If nOper <> 3
						RecLock("SF1",.F.)
						If nOper == 1
							// Aprova��o
							SF1->F1_XXLIB   := "A"
							SF1->F1_XXUAPRV := __cUserId
							SF1->F1_XXDAPRV := DtoC(Date())+"-"+Time()
						Else
							SF1->F1_XXLIB  := "R"
						EndIf
						MsUnLock("SF1")

						If nOper == 1
							// Avalia��o do Fornecedor
							If u_IsAvalia(__cUserId)
								u_WaitLog(,{|| prcD1Aval() },"Aguarde","Pesquisando pedidos para avalia��o...",.F.)

								dbSelectArea("TMPSD1")
								dbGoTop()
								If !TMPSD1->(EOF())
									// Somente avaliar NF com pedido de compra atrelado
									If !Empty(TMPSD1->D1_PEDIDO)
										U_AvalForn(.F.)
									EndIf
								EndIf
								TMPSD1->(DbCloseArea())
							EndIf

							u_MsgLog("MT103INC","Doc aprovado: "+cLogDoc)

						ElseIf nOper == 2

							// Caso n�o libere, enviar e-mail para quem incluiu o Documento
							//cEmail += UsrRetMail(SF1->F1_XXUSER)

							u_SF1Email("Pr�-Nota n�o aprovada")

							u_MsgLog("MT103INC","Doc n�o aprovado: "+cLogDoc)
						EndIf
					EndIf
				Else
					u_MsgLog("MT103INC","Usu�rio sem permiss�o para aprovar pr�prios documentos: "+cLogDoc,"E")
				EndIf
			Else
				u_MsgLog("MT103INC","Usu�rio sem permiss�o para aprovar documentos: "+cLogDoc,"E")
			EndIf

		ElseIf SF1->F1_XXLIB == 'L' .OR. SF1->F1_XXLIB == 'E'

			If lMaster
			
				If SF1->F1_XXLIB == 'L'
					nOper := u_AvisoLog("MT103INC","MT103INC","Classifica��o fiscal:",{"Classificar","Estornar Lib","Cancelar"})
				Else
					nOper := u_AvisoLog("MT103INC","MT103INC","Classifica��o fiscal (documento estornado):",{"Classificar","Cancelar"})
				EndIf
				If nOper == 1
					// Segue a classifica��o
					lRet := .T.
				ElseIf nOper == 2 .AND. SF1->F1_XXLIB == 'L'
					RecLock("SF1",.F.)
					SF1->F1_XXLIB   := "E"
					SF1->F1_XXUCLAS := __cUserId
					SF1->F1_XXDCLAS := DtoC(Date())+"-"+Time()
					MsUnLock("SF1")
					u_SF1Email("Pr�-Nota Estornada pelo Fiscal")
					u_MsgLog("MT103INC","Doc estornado: "+cLogDoc)
				EndIf
			Else
				If SF1->F1_XXLIB == 'E'
					u_MsgLog("MT103INC","Documento estornado pelo classificador: "+SF1->F1_XXUCLAS+" - "+cLogDoc,"I")
				Else
					u_MsgLog("MT103INC","Documento j� foi liberado, aguarde a classifica��o pelo Depto Fiscal: "+cLogDoc,"I")
				EndIf
			EndIf
		ElseIf SF1->F1_XXLIB == 'N'

			If SF1->F1_XXULIB == __cUserId .OR. lMaster
				nOper := u_AvisoLog("MT103INC","MT103INC","Libera��o para classifica��o fiscal:",{"Liberar","Cancelar"})
				If nOper == 1
					RecLock("SF1",.F.)
					SF1->F1_XXLIB  := "L"
					SF1->F1_XXULIB := __cUserId
					SF1->F1_XXDLIB := DtoC(Date())+"-"+Time()
					MsUnLock("SF1")
					u_MsgLog("MT103INC","Doc liberado: "+cLogDoc)
				EndIf
			Else
				u_MsgLog("MT103INC","Documento bloqueado para classifica��o: "+SF1->F1_XXUCLAS,"I")
				
			EndIf
		ElseIf SF1->F1_XXLIB == 'T'
			u_MsgLog("MT103INC","Documento pendente de libera��o por token: "+SF1->F1_XXUCLAS,"I")
		ElseIf SF1->F1_XXLIB == 'B'
			u_MsgLog("MT103INC","Documento bloqueado, aguarde libera��o da diretoria: "+SF1->F1_XXULIB,"I")
		ElseIf SF1->F1_XXLIB == 'C'
			u_MsgLog("MT103INC","Documento j� foi classificado: "+SF1->F1_XXUCLAS,"I")
		EndIf
	EndIf
Else
	If lMaster .OR. u_InGrupo(__cUserId,"000037") // User Controladoria
		lRet := .T.
	Else
		u_MsgLog("MT103INC","Usu�rio sem permiss�o para incluir Documentos de Entrada: "+cLogDoc,"E")
		lRet := .F.
	EndIf
EndIf
RestArea(aArea)
Return lRet


Static Function prcD1Aval()
Local cQryD1

cQryD1 := "SELECT D1_PEDIDO"
cQryD1 += " FROM "+RetSqlName("SD1")+" SD1" 
cQryD1 += " WHERE "+RetSqlCond("SD1")  //D1_FILIAL = '" + xFilial("SD1") + "' AND D_E_L_E_T_ = ' ' " 
cQryD1 += "  AND SD1.D1_DOC='"+SF1->F1_DOC+"' AND SD1.D1_SERIE='"+SF1->F1_SERIE+"'"
cQryD1 += "  AND SD1.D1_FORNECE='"+SF1->F1_FORNECE+"' AND SD1.D1_LOJA='"+SF1->F1_LOJA+"' AND SD1.D1_PEDIDO<>''"
TCQUERY cQryD1 NEW ALIAS "TMPSD1"

Return Nil


User Function SF1Email(cAssunto)
Local cEmail    := u_EmailAdm()
Local cEmailCC  := "" 
Local aCabs   	:= {}
Local aEmail 	:= {}
Local cMsg		:= ""
Local cJust		:= ""
Local cPrw 		:= "SF1Email"

If !IsBlind()
	cJust := "("+DTOC(DATE())+"-"+TIME()+") "+JustBlq(cAssunto)
EndIf

RecLock("SF1",.F.)
SF1->F1_HISTRET := cJust
MsUnLock("SF1")

cAssunto += " n�.:"+SF1->F1_DOC+" S�rie:"+SF1->F1_SERIE+" - "+FWEmpName(cEmpAnt)

If !Empty(SF1->F1_XXUSER)
	cEmail += UsrRetMail(SF1->F1_XXUSER)+';'
EndIf
If !Empty(SF1->F1_XXUSERS)
	cEmail += UsrRetMail(SF1->F1_XXUSERS)+';'
EndIf
If !Empty(SF1->F1_XXUAPRV) .AND. SF1->F1_XXUAPRV <> SF1->F1_XXUSERS
	cEmail += UsrRetMail(SF1->F1_XXUAPRV)+';'
EndIf

cEmailCC += UsrRetMail(__cUserId)+';'

// Incluir usuarios do almoxarifado 28/09/2021 - Fabio Quirino
cEmail  += u_EmEstAlm(SF1->F1_XXUSER,.F.,cEmail)

aCabs   := {"Pr�-Nota n�.:" + TRIM(SF1->F1_DOC) + " S�rie:" + SF1->F1_SERIE+ " Valor: "+ALLTRIM(TRANSFORM(U_GetValTot(.F.),"@E 99,999,999,999.99"))}
aEmail 	:= {}
AADD(aEmail,{"Fornecedor: "+SA2->A2_COD+"-"+SA2->A2_LOJA+" - "+SA2->A2_NOME})
AADD(aEmail,{"Reprovador:"+UsrFullName(RetCodUsr())})
AADD(aEmail,{"Motivo    :"+cJust})

cMsg    := u_GeraHtmB(aEmail,cAssunto,aCabs,"MT103INC","",cEmail,cEmailCC)

u_GrvAnexo(cPrw+".html",cMsg,.T.)

U_BkSnMail("MT103INC",cAssunto,cEmail,cEmailCC,cMsg,{cPrw+".html"})

Return Nil


// Tela para justifiar o estorno/n�o libera��o
Static Function JustBlq(cTexto)
Local oDlg  as Object
Local oFont as Object
Local oMemo as Object

//Define Font oFont Name "Mono AS" Size 5, 12
Define MsDialog oDlg Title "Complemente o Motivo:" From 3, 0 to 340, 417 Pixel

@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
oMemo:bRClicked := { || AllwaysTrue() }
oMemo:oFont     := oFont

Define SButton From 153, 160 Type  1 Action oDlg:End() Enable Of oDlg Pixel

Activate MsDialog oDlg Center

Return cTexto


