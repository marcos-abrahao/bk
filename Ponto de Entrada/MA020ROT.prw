#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MA020ROT
BK - Ponto de entrada utilizado para criar Rotina no menu para copia de Fornecedor SA2
Chamar no PE MA110BAR
@Return
@author Adilson do Prado
@since 24/10/14
@version P12
/*/

User Function MA020ROT()
Local aRotUser := {}
//Define Array contendo as Rotinas a executar do programa     
// ----------- Elementos contidos por dimensao ------------    
// 1. Nome a aparecer no cabecalho                             
// 2. Nome da Rotina associada                                 
// 3. Usado pela rotina                                        
// 4. Tipo de Transacao a ser efetuada
//    1 - Pesquisa e Posiciona em um Banco de Dados
//    2 - Simplesmente Mostra os Campos                        
//    3 - Inclui registros no Bancos de Dados                  
//    4 - Altera o registro corrente                           
//    5 - Remove o registro corrente do Banco de Dados         
//    6 - Altera determinados campos sem incluir novos Regs     

AAdd( aRotUser, { "Copiar Fornecedor de outras Empresas", "U_BKCOMA07()", 0, 3 } ) 

Return (aRotUser)
