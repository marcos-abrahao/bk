#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT461VCT
BK - Ponto de Entrada - Ponto-de-Entrada: MT461VCT - Alteração no vencimento e valor do título (Somente Faturamento) 
Solicitado por Diego Oliveira - #0924545
@Return
@author  Marcos Bispo Abrahão
@since 11/09/2024
@version P12
/*/
User Function MT461VCT()

Local _aVencto := PARAMIXB[1]
//Local _aTitulo := PARAMIXB[2]
Local dVencto                             

// Condicao especifica F10 com vencimento sempre dia 10 + 10 dias uteis
If SC5->C5_CONDPAG == "F10"
    // Somar + 10 dias uteis
    dVencto := DataValida(_aVencto[1][1]+1)
    dVencto := DataValida(dVencto+1)
    dVencto := DataValida(dVencto+1)
    dVencto := DataValida(dVencto+1)
    dVencto := DataValida(dVencto+1)
    dVencto := DataValida(dVencto+1)
    dVencto := DataValida(dVencto+1)
    dVencto := DataValida(dVencto+1)
    dVencto := DataValida(dVencto+1)
    dVencto := DataValida(dVencto+1)
   _aVencto[1][1] := dVencto
Endif

Return(_aVencto)


