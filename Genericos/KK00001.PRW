#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณKK00001   บAutor  ณ Gilberto Sales     บ Data ณ 29/04/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao para rodar uma Query e retornar como Array          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cQuery - Query SQL a ser executado                         บฑฑ
ฑฑบ          ณ cTipo  - A=Array (Default) / V=Variavel (Par.N.Obrigat.)   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ aTrb   - Array com o conteudo da Query                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      ณAnalista/Altera็๕es                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function KK00001(cQuery,cTipo)    //QryArr(cQuery,cTipo)

Local aEstou := GetArea()

//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Gravacao do Ambiente Atual e Variaveis para Utilizacao                   บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออSilvio Cazelaอผ
Local aRet    := {}
Local aRet1   := {}
Local nRegAtu := 0
Local x       := 0
cTipo := iif(cTipo==NIL,"A","V")

//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Ajustes e Execucao da Query                                              บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออSilvio Cazelaอผ
If SELECT("TRB") > 0 
	dbSelectArea("TRB")
   	dbCloseArea()
EndIf

TCQUERY cQuery NEW ALIAS "TRB"

//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Montagem do Array para Retorno                                           บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออSilvio Cazelaอผ
DbSelectArea("TRB")
aRet1   := Array(fcount())
nRegAtu := 1

While !eof()
	For x:=1 to fcount()
		aRet1[x] := FieldGet(x)
	Next
	AADD(aRet,aclone(aRet1))
	DbSkip()
	nRegAtu += 1
Enddo

//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Verifica e Ajusta o Tipo de Retorno                                      บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออSilvio Cazelaอผ
If cTipo=="V" .and. len(aRet)>0
	aRet := aRet[1,1]
Elseif cTipo=="V"
	aRet := NIL
Endif

//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Encerra Query e Retorna Ambiente                                         บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออSilvio Cazelaอผ
DbSelectArea("TRB")
TRB->(DbCloseArea())

RestArea(aEstou)

Return(aRet)