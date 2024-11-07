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

ElseIf SC5->C5_CONDPAG == "F20"
    // Solicitado por João Cordeiro em 05/11/24
    // Prodesp 239000635 e 305000554
    // 1. Prazo mínimo de pagamento: Todas as notas fiscais serão pagas no mínimo 30 dias após a data de entrega. 
    // 2. Datas de entrega das notas fiscais e datas de pagamento:
    //    Notas entregues entre os dias 6 e 20 de cada mês: serão pagas no dia 20 do mês seguinte.
    //    O Notas entregues entre os dias 21 e 5 do mês seguinte: serão pagas no dia 5 do mês subsequente.
    // Se o dia 5 ou 20 cair em data não útil, o pagamento será prorrogado para a dia útil imediatamente subsequente.

    dVencto := dDataBase
    If Day(dVencto) >= 6 .AND. Day(dVencto) <= 20
        dVencto := DataValida(LastDay(dVencto) + 21)
    Else
        //If Date() > dDataBase
        //    dVencto := DataValida(LastDay(dVencto) + 1)
        //EndIf
        dVencto := DataValida(LastDay(dVencto) + 6)
    EndIf
    _aVencto[1][1] := dVencto

Endif

Return(_aVencto)


