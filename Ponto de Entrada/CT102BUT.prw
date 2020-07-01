#include "protheus.ch"



User Function CT102BUT()
Local aBotao := {}
/*
O Layout do array aBotao deve sempre respeitar os itens abaixo:

[n][1]=Título da rotina que será exibido no menu
[n][2]=Função que será executada
[n][3]=Parâmetro reservado, deve ser sempre 0 ( zero )
[n][4]=Número da operação que a função vai executar sendo :

1=Pesquisa
2=Visualização
3=Inclusão
4=Alteração
5=Exclusão
*/

aAdd(aBotao, {'Filtro BK',"U_BKCTBC01", 0 , 3 })

Return(aBotao)

