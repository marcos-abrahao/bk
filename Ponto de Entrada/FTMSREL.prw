#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} FTMSREL
BK - Ponto de Entrada
Defini��o de Chave Primaria de usu�rio. Este ponto de entrada � utilizado para incluir tabelas de usu�rio, quando se utiliza o conceito de contato �nico do Administrador de Vendas / Call Center ou o Banco de Conhecimento. 
Para que se possa utilizar o Banco de Conhecimento utilizando uma tabela de usu�rio (Ex. SZ1), torna-se necess�rio informar ao sistema qual a chave prim�ria de relacionamento. 
Por exemplo, a chave prim�ria de relacionamento do cadastro de clientes �: FILIAL + CODIGO + LOJA.

@Return aRet 
@author  Marcos Bispo Abrah�o
@since 12/12/22
@version P12
/*/

User Function FtMsRel
 
Local aRet    As Array
Local aChave  As Array
Local bMostra As Block
Local cTabela As Character
Local aFields As Array
 
//Array
aRet := {}
// Tabela do usuario SZE->Contrato x Compet�ncia para guardar os Anexos via MsDocument
cTabela := 'SZE'
// Campos que compoe a chave na ordem. Nao  passar filial (automatico)
aChave  := { 'ZE_CONTRAT','ZE_COMPET'}
// Bloco de codigo a ser exibido
bMostra := { || SZE->ZE_CONTRAT + SZE->ZE_COMPET }       
//Array com os campos que identificam os campos utilizados na descri��o
aFields := {'ZE_CONTRAT','ZE_COMPET'}                                
// funcoes do sistema para identificar o registro
AAdd( aRet, { cTabela, aChave, bMostra, aFields } )


// SD3
AAdd( aRet, { "SD3", { "D3_DOC" }, { || SD3->D3_DOC },{"D3_DOC"} })

// SCP
AAdd( aRet, { "SCP", { "CP_NUM" }, { || SD3->CP_NUM },{"CP_NUM"} })

Return aRet
