#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MT160LOK   บAutor  ณAdilso do Prado     บ Data ณ  24/04/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบPonto de Entrada: Ap๓s a montagem da dialog da analise de cota็ใo.     บฑฑ
ฑฑบ ษ acionado quando o usuario clica no botใo OK (Ctrl O) confirmando    บฑฑ
ฑฑบ a analise da cota็ใo, deve ser utilizado para validar se a Analise    บฑฑ
ฑฑบ da cota็ใo deve continuar 'retorno .T.' ou nใo 'retorno .F.' , ap๓s   บฑฑ
ฑฑบ a confirma็ใo do sistema.    										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BK                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function  MT161OK()

Return .t.

// Desabilitada em 11/11/19
User Function  MT160OK()
Local aPlanilha := PARAMIXB // Array contendo todos os dados da Planilha de Cota็ใo para valida็ใo
Local lContinua := .T.
Local aCota := {}


aCota := {}
For IX_ := 1 TO LEN(aPlanilha)
	For IY_ := 1 TO LEN(aPlanilha[IX_])
		IF aPlanilha[IX_][IY_][1] == "XX" 
    		AADD(aCota,aPlanilha[IX_][IY_][2])
  		ENDIF
    NEXT
NEXT

IF LEN(aCota) <> LEN(aPlanilha)
	MSGSTOP("Hแ cota็ใo nใo selecionada. Favor refazer analise selecionando um vencedor para cada item da cota็ใo!!")
	lcontinua := .F.
ENDIF

Return ( lContinua ) 

