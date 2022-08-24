#Include "Protheus.ch" 

/*/{Protheus.doc} CNT121LG
BK - Legandas na nova medição
@Return
@author Marcos Bispo Abrahão
@since  29/07/2021
@version P12
/*/

/*
User Function CNT121LG()
Local aRet := {}
aAdd(aRet,{"ALLtrim(CND_SITUAC) == 'SA'", "BR_VERMELHO", "Med. Servic. Aberta"})
aAdd(aRet,{"ALLtrim(CND_SITUAC) == 'SE'", "BR_VERDE",    "Med. Servic. Encerrada"})

Return aRet
*/
