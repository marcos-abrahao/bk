#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MA461MNU
BK - Chamada da Impressão de pedido de venda
@Return
@author Marcos Bispo Abrahão
@since 14/10/2020
@version P12
/*/

User Function MA461ROT() 
Local aRot := {}
aadd(aRot,{'Consulta Pedido','U_BKFATR5B' , 0 , 2,0,NIL})   

/*/ONDE:Parametros do array a Rotina:
1. Nome a aparecer no cabecalho
2. Nome da Rotina associada    
3. Reservado                        
4. Tipo de Transação a ser efetuada:     
    1 - Pesquisa e Posiciona em um Banco de Dados      
    2 - Simplesmente Mostra os Campos                  
    3 - Inclui registros no Bancos de Dados            
    4 - Altera o registro corrente                     
    5 - Remove o registro corrente do Banco de Dados 
5. Nivel de acesso                                   
6. Habilita Menu Funcional
/*/
Return aRot

