// Funcoes utilizadas para CNAB a Pagar e SISPAG
// Marcos B. Abrahão - 09/01/15

/*
Layout Sispag - Tipos de registro Totvs
"A" - Header do arquivo
"F" - Trailler do arquivo

Segmento A
"B" - Header
"G" - Detail
"D" - Trailler

Segmento B
"B" - Header
"H" - Detail
"D" - Trailler
	
Segmento J	
"C" - Header
"J" - Detail
"E" - Trailler

Segmento N
"C" - Header
"N" - Detail
"I" - Trailler
	
Segmento O
"C" - Header
"O" - Detail
"K" - Trailler

*/

/*

Uso do Sispag

1- incluir o(os) titulo(os) no sistema 
2- criar borderô para o(os) titulo(os) 
3- gerar arquivo de remessa 
4- enviar arquivo .txt para o banco 
5- aguarda o banco fazer a transação e mandar o arquivo de retorno 
6- recebido o arquivo de retorno incluir no sistema e fazer a baixa. 

Agora no sistema, Protheus 11 com o layout CNAB Itau. 

1- incluir títulos 
   atualizações >contas a pagar>contas a pagar>incluir 

2- GERAR BORDERÔ 
   ATUALIZAÇÕES >CONTAS A PAGAR>BORDERO DE PAGAMENTO> BORDERÔ 

3- GERAR O ARQUIVO DE PAGAMENTO (.REM) 
   ATUALIZAÇÕES >COMUNIC.BANCARIA>SISPAG>ações relacionadas>gerar arquivo>           preencher os parâmetros. 

4- agora na web, abre o bankline vai na aba "transmissão de arquivos" escolhe o    ambiente que pode ser "teste" ou "produção" e depois em enviar arquivo,   seleciona pagamento sispag e localiza o arquivo .REM que foi gerado no passo "3". Clica em enviar. 

5- Aguardar o banco mandar o arquivo de retorno que você poderá verificar no bankline na aba trams. arquivos> amb. produção > retorno> recepcionar. 

6- recebido o arquivo .RET joga esse arquivo dentro da pasta "system" do protheus ou pasta especifica que tenha customizado, depois abra o Protheus vai em: ATUALIZAÇÕES >COMUNIC.BANCARIA>sispag>ações relacionadas>recebe arquivo> preenche parâmetros e processa o arquivo, neste momento é efetuado a baixa do arquivo ou seja o pagamento. 

7- verificar se o(os) titulo(os) foram pagos (após processar no sispag) 
   Atualizações>contas a pagar> baixas pagar man.> procura o titulo e verifica se está com a bolinha vermelha, caso sim processo concluído com êxito. 

Abaixo Algumas informações adicionais bem legais. 

CONSULTAR POSICAO TITULO PAG 
CONSULTAS>CONTAS A PAGAR> POSICAO TITULO PAG.>CONSULTA 

MOSTRAR BORDERO EM TELA 
RELATORIOS> CONTAS A PAGAR> EMISSAO DE BORDEROS> PREENCHE PARÂMETROS 

EXCLUIR TITULO DO BORDERO EXISTENTE 
ATUALIZAÇÕES>CONTAS A PAGAR>MANUTENÇÃO DE BORDERO 

EXCLUIR BORDERO 
ATUALIZAÇÕES>CONTAS A PAGAR>BORDERO DE PAGAMENTO>CANCELAR> SELECIONA O BORDERO A SER EXCLUÍDO 

visualizar (video) estado do arquivo de retorno 
relatorio>cominc. bancaria>Rel Retorno Sispag> preencher parametros.(o arquivo vai ter o nome de FINR850) 


-----------------------------------
MV_DIFPAG - Define o controle de diferentes tipos de tributos no arquivo de retorno do SISPAG
 
O parâmetro MV_DIFPAG indica se o sistema controla diferentes tipos de tributos no arquivo de retorn do SISPAG.
Caso esteja preenchido como .T. o sistema trata as diferentes configurações;
Caso esteja preenchido como .F. o sistema permite somente uma configuração para cada arquivo de retorno, sem diferenciá-las.
 
-----------------------------------

*/



#include "protheus.ch"
//#include "rwmake.ch"

User Function CnabBco()
// Retorna o banco do favorecido - 12/12/14 (sisp000)
Local cBanco

IF SUBSTR(SE2->E2_CODBAR,1,1) <> "C" //.OR. EMPTY(SE2->E2_XXCPF)
	cBanco  := SA2->A2_BANCO
ELSE
	//CBBBAAAACCCCCCCCCC
	cBanco  := SUBSTR(SE2->E2_CODBAR,2,3)
ENDIF

Return(cBanco)


User Function CnabAgCC()
// Retorna Agencia e Conta do Favorecido
Return U_SispAgCC()
         

// ExecBlock disparado do 341REM.PAG para retornar agencia e conta do fornecedor.
User Function SispAgCC()
Local _cReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SISP001  ³ Autor ³ Marcos B. Abrahao     ³ Data ³ 31/10/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ ExecBlock disparado do 341REM.PAG para retornar agencia e  ³±±
±±³          ³ conta do fornecedor.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNAB SISPAG KLOECKNER / BK                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Local cAg,cConta

IF SUBSTR(SE2->E2_CODBAR,1,1) <> "C" //.OR. EMPTY(SE2->E2_XXCPF)
	cAg     := SA2->A2_AGENCIA
	cConta  := SA2->A2_NUMCON
ELSE
	//CBBBAAAACCCCCCCCCC
	cAg     := SUBSTR(SE2->E2_CODBAR,5,4)
	cConta  := SUBSTR(SE2->E2_CODBAR,9,10)
ENDIF

IF AT("-",cConta) == 0 
	_cReturn :=StrZero(Val(Alltrim(cAg)),5)+" "+StrZero(Val(SUBS(cConta,1,Len(Alltrim(cConta))-1)),12)
Else
	_cReturn :=StrZero(Val(Alltrim(cAg)),5)+" "+StrZero(Val(SUBS(cConta,1,AT("-",cConta)-1)),12)
Endif

Return(_cReturn)



User Function CnabDigCc()
// Retorna Digito da CC fornecedor
Return U_SispDigCC()


User Function SispDigCC()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SISP002  ³ Autor ³ Marcos B. Abrahao     ³ Data ³ 31/10/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ ExecBlock disparado do 341REM.PAG para retornar digito     ³±±
±±³          ³ da conta corrente do fornecedor.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISPAG Kloeckner / BK                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Local cConta,_cReturn2

IF SUBSTR(SE2->E2_CODBAR,1,1) <> "C" //.OR. EMPTY(SE2->E2_XXCPF)
	cConta  := SA2->A2_NUMCON
ELSE
	//CBBBAAAACCCCCCCCCC
	cConta  := SUBSTR(SE2->E2_CODBAR,9,10)
ENDIF

IF AT("-",cConta) == 0 
	_cReturn2 := SUBS(Alltrim(cConta),-1)
Else
	_cReturn2 := SUBS(cConta,AT("-",cConta)+1,1)
Endif

Return(_cReturn2)


User Function SispVenc()    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SISP003  ³ Autor ³ Marcos B. Abrahao     ³ Data ³ 31/10/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ ExecBlock disparado do 341REM.PAG para retornar vencimento ³±±
±±³          ³ do codigo de barras.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISPAG Kloeckner/BK                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

If     Len(Alltrim(SE2->E2_CODBAR)) == 44      
	_cRetSisp3 := Substr(SE2->E2_CODBAR,6,4)
ElseIf Len(Alltrim(SE2->E2_CODBAR)) == 47
	_cRetSisp3 := Substr(SE2->E2_CODBAR,34,4)
ElseIf Len(Alltrim(SE2->E2_CODBAR)) >= 36 .and. Len(Alltrim(SE2->E2_CODBAR)) <= 43
        _cRetSisp3 := "0000"
Else
        _cRetSisp3 := "0000"                         
EndIf	

_cRetSisp3 := Strzero(Val(_cRetSisp3),4)

Return(_cRetSisp3)



User Function SispNome()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SISP004  ³ Autor ³ Marcos B. Abrahao     ³ Data ³ 31/10/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ ExecBlock disparado do 341REM.PAG para retornar nome do    ³±±
±±³          ³ fornecedor                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNAB SISPAG KLOECKNER/BK                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/    
Local _cReturn

_cReturn := SUBSTR(SA2->A2_NOME,1,30)
If !Empty(SE2->(FieldPos("SE2->E2_XXCPF")))
	If !EMPTY(SE2->E2_XXCPF) 
		_cReturn := SUBSTR(UPPER(SE2->E2_XXNOME),1,30)
	EndIf
EndIf

Return(_cReturn)


User Function SispCnpj()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SISP005  ³ Autor ³ Marcos B. Abrahao     ³ Data ³ 31/10/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ ExecBlock disparado do 341REM.PAG para retornar CPF  do    ³±±
±±³          ³ fornecedor                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNAB SISPAG KLOECKNER                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Local _cReturn

_cReturn := STRZERO(VAL(SA2->A2_CGC),14)
If !Empty(SE2->(FieldPos("SE2->E2_XXCPF")))
	If !EMPTY(SE2->E2_XXCPF) 
		_cReturn := STRZERO(VAL(SE2->E2_XXCPF),14)
	EndIf
EndIf

Return(_cReturn)



// Retorna o endereço da empresa emitente
User Function CnabEnder(nCpo,nTam)
Local cRet := "",nPosN := 0,nI,nV := 0
nPosN := AT(",",SM0->M0_ENDCOB)
If nPosN == 0
	For nI := 1 TO LEN(SM0->M0_ENDCOB)
		If SUBSTR(SM0->M0_ENDCOB,nI,1) $ "0123456789"
			nPosN := nI
			Exit
		EndIf
    Next
Else
	nV := 1
EndIf

If nPosN > 0
	If nCpo == 1  // Logradouro
	   cRet := PAD(SUBSTR(SM0->M0_ENDCOB,1,nPosN - 1),nTam)
	ElseIf nCpo == 2  // Numero
	   cRet := ALLTRIM(SUBSTR(SM0->M0_ENDCOB,nPosN+nV))
	   cRet := STRZERO(VAL(cRet),nTam)
	EndIf
EndIf
Return cRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CNABAG   ³ Autor ³ Marcos B. Abrahão     ³ Data ³ 31/10/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ ExecBlock disparado do 341REM.PAG para retornar agencia da ³±±
±±³          ³ conta do fornecedor.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNAB BK                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CnabAg()
Local _cReturn
Local cAg

IF SUBSTR(SE2->E2_CODBAR,1,1) <> "C"
	cAg     := SA2->A2_AGENCIA
ELSE
	//CBBBAAAACCCCCCCCCC
	cAg     := SUBSTR(SE2->E2_CODBAR,5,4)
ENDIF

_cReturn :=StrZero(Val(Alltrim(cAg)),5)

Return(_cReturn)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CNABCC   ³ Autor ³ Marcos B. Abrahão     ³ Data ³ 31/10/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ ExecBlock disparado do 341REM.PAG para retornar a          ³±±
±±³          ³ conta do fornecedor.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNAB SISPAG BK                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CnabCC()
Local _cReturn
Local cConta

IF SUBSTR(SE2->E2_CODBAR,1,1) <> "C" //.OR. EMPTY(SE2->E2_XXCPF)
	cConta  := SA2->A2_NUMCON
ELSE
	//CBBBAAAACCCCCCCCCC
	cConta  := SUBSTR(SE2->E2_CODBAR,9,10)
ENDIF

IF AT("-",cConta) == 0 
	_cReturn := StrZero(Val(SUBS(cConta,1,Len(Alltrim(cConta))-1)),12)
Else
	_cReturn := SStrZero(Val(SUBS(cConta,1,AT("-",cConta)-1)),12)
Endif

Return(_cReturn)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CNABCCE  ³ Autor ³ Marcos B. Abrahão     ³ Data ³ 31/10/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ ExecBlock disparado do 341REM.PAG para retornar a          ³±±
±±³          ³ conta da empresa                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNAB BK                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CnabCCE()
Local _cReturn
Local cConta := SEE->EE_CONTA

IF AT("-",cConta) == 0 
	_cReturn := StrZero(Val(SUBS(cConta,1,Len(Alltrim(cConta))-1)),12)
Else
	_cReturn := SStrZero(Val(SUBS(cConta,1,AT("-",cConta)-1)),12)
Endif
Return(_cReturn)


// Digito da conta do emissor
User Function CnabDCCE()
Local _cReturn2
Local cConta := SEE->EE_CONTA
IF AT("-",cConta) == 0 
	_cReturn2 := SUBS(Alltrim(cConta),-1)
Else
	_cReturn2 := SUBS(cConta,AT("-",cConta)+1,1)
Endif
Return(_cReturn2)


// Retorna o saldo do titulo
User Function CnabSld(_nTam)
Local cVal
Default _nTam := 15

cVal := STRZERO((SE2->E2_SALDO-SE2->E2_SDDECRE+SE2->E2_SDACRES)*100,_nTam)
Return (cVal)



User Function CnabForn()
// Retorna Nome do Fornecedor
Local _cReturn
_cReturn := SUBSTR(SA2->A2_NOME,1,30)
//_cReturn := U_Sisp004()
Return (_cReturn)


User Function CnabCpf()
// Retorna CPF do Fornecedor
Local _cReturn
_cReturn := STRZERO(VAL(SA2->A2_CGC),14)
//_cReturn := U_Sisp005()
Return (_cReturn)


// Retorna dados do IPVA
User Function CnabIpva(nCpo)
Local cRet := ""
If nCPO == 1
	cRet := SUBSTR(SE2->E2_CODBAR,2,6)  // Codigo de retenção
ElseIf nCPO == 2 
	cRet := SUBSTR(SE2->E2_CODBAR,8,4)  // AnoBase
ElseIf nCPO == 3 
	cRet := SUBSTR(SE2->E2_CODBAR,12,9) // Renavam
ElseIf nCPO == 4 
	cRet := SUBSTR(SE2->E2_CODBAR,21,2) // UF
ElseIf nCPO == 5 
	cRet := SUBSTR(SE2->E2_CODBAR,23,5) // Municipio
ElseIf nCPO == 6 
	cRet := SUBSTR(SE2->E2_CODBAR,28,7) // Placa
ElseIf nCPO == 7 
	cRet := VAL(SUBSTR(SE2->E2_CODBAR,35,1)) // Forma Pagto
ElseIf nCPO == 8 
	cRet := "1" // Opção de Retirada (1-Correio 2-Detran)
EndIf
Return cRet


// Retorna dados da GPS
User Function CnabGPS(nCpo)
Local cRet := ""
If nCPO == 1
	cRet := SUBSTR(SE2->E2_CODBAR,2,6)  // Codigo da Receita
ElseIf nCPO == 2 
	cRet := SUBSTR(SE2->E2_CODBAR,8,6)  // Competencia
EndIf
Return cRet


// Retorna dados do DARF
User Function CnabDARF(nCpo)
Local cRet := "",dPeriodo

If nCPO == 1
	cRet := SUBSTR(SE2->E2_CODBAR,2,6)   // Codigo da Receita
ElseIf nCPO == 2 
	cRet := SUBSTR(SE2->E2_CODBAR,8,17)  // Referencia
ElseIf nCPO == 3
	dPeriodo := STOD(SUBSTR(SE2->E2_CODBAR,25,8))  // Periodo
	cRet := STRZERO( DAY(dPeriodo),2)+STRZERO( MONTH(dPeriodo),2)+STRZERO( YEAR(dPeriodo),4)
EndIf
Return cRet


// Retorna dados do DARF
User Function SispTrib()
Local cRet := ""

// GPS
If SEA->EA_MODELO == "17"

	// Identificação do Tributo - 01=GPS
	cRet += "01"
	// Codigo de Pagamento
	cRet += SUBSTR(U_CnabGps(1),1,4)
	// Competencia
	cRet += U_CnabGps(2)
	// CNPJ do Contribuinte
	cRet += SM0->M0_CGC
	// Valor do INSS
	cRet += U_CnabSld(14)
	// Valor Outras Entidades
	cRet += STRZERO(0,14)
	// Atualização monetária
	cRet += STRZERO(0,14)
	// Valor arrecadado
	cRet += U_CnabSld(14)
	// Data de arrecadação
	cRet += GRAVADATA(SE2->E2_VENCREA,.F.,5)
	// Complemento de Registro
	cRet += SPACE(8)
	// Uso empresa
	cRet += PAD(SE2->E2_IDCNAB,20)
	// Nome do contribuinte
	cRet += PAD(SM0->M0_NOMCOM,30)
ElseIf SEA->EA_MODELO == "16"
	// Identificação do Tributo - 02=DARF
	cRet += "02"
    // Codigo da Receita
    cRet += SUBSTR(U_CnabDarf(1),1,4)
    // Tipo de Inscrição
    cRet += "2"  // 1=CPF,2=CNPJ
    // Numero de Inscrição
    cRet += SM0->M0_CGC
    // Periodo de apuração
    cRet += U_CnabDarf(3)
    // Numero de referencia
    cRet += U_CnabDarf(2)
	// Valor principal
	cRet += U_CnabSld(14)
	// Multa
	cRet += STRZERO(0,14)
	// Juros / Encargos
	cRet += STRZERO(0,14)
	// Valor total a ser pago
	cRet += U_CnabSld(14)
	// Data de Vencimento
	cRet += GRAVADATA(SE2->E2_VENCREA,.F.,5)
	// Data de Pagamento
	cRet += GRAVADATA(SE2->E2_VENCREA,.F.,5)
	// Complemento de registro
	cRet += SPACE(30)
	// Nome do Contribuinte
	cRet += PAD(SM0->M0_NOMCOM,30)
EndIf

Return cRet

/*
FORMA DE PAGAMENTO - SISPAG

01 CRÉDITO EM CONTA CORRENTE NO ITAÚ
02 CHEQUE PAGAMENTO/ADMINISTRATIVO
03 DOC “C”
05 CRÉDITO EM CONTA POUPANÇA NO ITAÚ
06 CRÉDITO EM CONTA CORRENTE DE MESMA TITULARIDADE
07 DOC “D”
10 ORDEM DE PAGAMENTO À DISPOSIÇÃO
11 ORDEM DE PAGAMENTO DE ACERTO – SOMENTE RETORNO - VER OBSERVAÇÃO ABAIXO
13 PAGAMENTO DE CONCESSIONÁRIAS
16 DARF NORMAL
17 GPS - GUIA DA PREVIDÊNCIA SOCIAL
18 DARF SIMPLES
19 IPTU/ISS/OUTROS TRIBUTOS MUNICIPAIS
21 DARJ
22 GARE – SP ICMS
25 IPVA
27 DPVAT
30 PAGAMENTO DE TÍTULOS EM COBRANÇA NO ITAÚ
31 PAGAMENTO DE TÍTULOS EM COBRANÇA EM OUTROS BANCOS
32 NOTA FISCAL – LIQUIDAÇÃO ELETRÔNICA
35 FGTS – GFIP
41 TED – OUTRO TITULAR
43 TED – MESMO TITULAR
60 CARTÃO SALÁRIO
91 GNRE E TRIBUTOS COM CÓDIGO DE BARRAS
*/
