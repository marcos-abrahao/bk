#Include "Protheus.ch" 

/*/{Protheus.doc} CNT121LG
BK - Legandas na nova medi��o
@Return
@author Marcos Bispo Abrah�o
@since  29/07/2021
@version P12
/*/


User Function CNT121LG()
Local aLegendas := ParamIXB[1]   //Legendas do produto padr�o
 
aAdd(aLegendas, {"ALLtrim(CND_SITUAC) == 'SA'", "BR_VERMELHO", "Med. Servic. Aberta"})
aAdd(aLegendas, {"ALLtrim(CND_SITUAC) == 'SE'", "BR_VERDE",    "Med. Servic. Encerrada"})

Return aLegendas

