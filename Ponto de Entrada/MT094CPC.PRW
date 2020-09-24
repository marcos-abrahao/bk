#Include 'Protheus.ch'

/*/{Protheus.doc} MT094CPC
MT094CPC - Ponto de entrada para inclusão de campos da tabela SC& na lib. de Pedidos de Compras
@Return
@author Marcos Bispo Abrahão
@since 23/09/20
@version P12.1.25
/*/

User Function MT094CPC()
Local cCampos := "C7_CC|C7_XXNCC" //  A separação dos campos devem ser feitos com uma barra vertical ( | ), igual é demonstrado no exemplo. 
Return (cCampos)
