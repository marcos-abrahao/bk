#include "protheus.ch"
#include "rwmake.ch"
 
 
 
User Function MT241GRV() 
 
Local cNumDOc  := PARAMIXB[1]     
Local cCampos  := PARAMIXB[2]
Local aArea    := Getarea()
// o Ponto de entrada MT241GRV tem em seu nome GRV devido o local que se encontra A241GRAVA e
// n�o tem funcionalidades de grava��o. Ele somente � acionado APOS a grava��o da SD3.
// Se for usado em conjunto com o MT241CAB pode permitir a customiza��o relativos aos campos
// de usuario, Lembrando que os campos do MT241CAB s�o customizados na area do cabe�alho da tela e n�o
// nos itens e um documento pode ter varias linhas de itens.
// Caso n�o seja usado em conjunto com o MT241CAB, qualquer outro tratamento pode ser feito apos a
// grava��o da SD3.
// Ainda podem ser usados os dois metodos combinados.
 
//Exemplo se for usado em conjunto com MT241CAB
IF u_IsBarcas()
    If  len(cCampos) > 0  // Prote��o para validar que existem campos de usuario em uso
        DbSelectarea ('SD3')
        DbSetOrder(8)  //"D3_FILIAL+D3_DOC+D3_NUMSEQ"
 
        If Dbseek(xFilial('SD3')+cNumDOc)
            while !EOF() .and. D3_DOC = cNumDOc // Loop para varrer os itens
                Reclock ('SD3',.f.)
                D3_XOSHELM := cCampos[1,2]  //ccampos x,1 = Nome do campo; x,2 = Conteudo 
                D3_XTRQSC  := SUBSTR(cCampos[2,2],1,1)
                MsUnlock()
                Dbskip()
            EndDo
        EndIf
    EndIf
EndIf

/*
// Exemplo sem o uso do MT241CAB
IF MSGYESNO ('Usa o tratamento APOS a atualiza��o da SD3 ?')
    DbSelectarea ('SD3')
    DbSetOrder(8)  //"D3_FILIAL+D3_DOC+D3_NUMSEQ"
 
    If SD3->(Dbseek(xFilial('SD3')+cNumDOc))
        while !EOF() .and. SD3->D3_DOC = cNumDOc  // Loop para varrer os itens
            dbselectarea ('SB1')
            dbsetorder(1)
            Dbseek (xfilial('SB1')+SD3->D3_COD)
            If B1_RASTRO == 'N'
                Alert ('O produto '+B1_DESC+' n�o usa lote')
            EndIf
            SD3->(Dbskip())
        EndDo
    EndIf
EndIf
*/

RestArea(aArea)
return
