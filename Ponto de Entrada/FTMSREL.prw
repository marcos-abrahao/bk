#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} FTMSREL
BK - Ponto de Entrada
Definição de Chave Primaria de usuário. Este ponto de entrada é utilizado para incluir tabelas de usuário, quando se utiliza o conceito de contato único do Administrador de Vendas / Call Center ou o Banco de Conhecimento. 
Para que se possa utilizar o Banco de Conhecimento utilizando uma tabela de usuário (Ex. SZ1), torna-se necessário informar ao sistema qual a chave primária de relacionamento. 
Por exemplo, a chave primária de relacionamento do cadastro de clientes é: FILIAL + CODIGO + LOJA.

@Return aRet 
@author  Marcos Bispo Abrahão
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
// Tabela do usuario SZE->Contrato x Competência para guardar os Anexos via MsDocument
cTabela := 'SZE'
// Campos que compoe a chave na ordem. Nao  passar filial (automatico)
aChave  := { 'ZE_CONTRAT','ZE_COMPET'}
// Bloco de codigo a ser exibido
bMostra := { || SZE->ZE_CONTRAT + SZE->ZE_COMPET }       
//Array com os campos que identificam os campos utilizados na descrição
aFields := {'ZE_CONTRAT','ZE_COMPET'}                                
// funcoes do sistema para identificar o registro
AAdd( aRet, { cTabela, aChave, bMostra, aFields } )


// SD3
AAdd( aRet, { "SD3", { "D3_DOC" }, { || SD3->D3_DOC },{"D3_DOC"} })

// SCP
AAdd( aRet, { "SCP", { "CP_NUM" }, { || SD3->CP_NUM },{"CP_NUM"} })

Return aRet
