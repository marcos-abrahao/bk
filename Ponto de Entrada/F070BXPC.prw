#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"       

/*/{Protheus.doc} F070BXPC
   O ponto de entrada F070BXPC da rotina de Baixas a Receber é ativado em casos de baixas parciais
   BK - Para Gravar historico de baixa parcial  
   @type  Function
   @author Adilson do Prado
   @since 27/11/18
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/

User Function xF070BXPC

   //Alert( "Saldo Restante: " + Str( SE1->E1_SALDO))

Return .T.
