#include "protheus.ch"

/*/{Protheus.doc} CALLCHGXNU
    BK - Ponto de entrada que será executado toda vez que um menu for carregado

    Observação:
    Ele somente envia grupo de empresas e filial diferente da logada ao trocar de grupo de empresas no sistema (pela tela do MDI, por exemplo).
    Não executa como administrador

    @type  Function
    @author Marcos Bispo Abrahão
    @since 09/08/2021
    @version P12.1.25
    @param 
        ParamIXB[1] (Caracter) -> Usuário que está conectado
        ParamIXB[2] (Caracter) -> Empresa atual
        ParamIXB[3] (Caracter) -> Filial atual
        ParamIXB[4] (Numérico) -> Número do módulo que será aberto
        ParamIXB[5] (Caracter) -> Nome do menu do usuário.
        ParamIXB[6] (Caracter) -> Empresa selecionada de destino. (Na primeira carga do sistema será a mesma empresa do parâmetro ParamIXB[2] )
        ParamIXB[7] (Caracter) -> Filial selecionada de destino.(Na primeira carga do sistema será a mesma filial do parâmetro ParamIXB[3] )
    @return return_var, return_type, return_description
    /*/
Static nModAnt := 0

User Function CALLCHGXNU()

Local cId	  := ParamIXB[1]
Local cEmpAtu := ParamIXB[2] 
Local nModulo := ParamIXB[4]
Local cMenu   := ParamIXB[5]
Local cToken  := u_BKEnCode()

If nModulo <> nModAnt
    If nModulo = 5 .OR. nModulo = 69
        //        Vanderleia/Zé Mario/Teste/Xavier/Fabia/Bruno
        If cId $ "000056/000175/000038/000012/000023/000153"
            If MsgYesNo("Deseja abrir a liberação de pedidos web?")
                If "TST" $ UPPER(GetEnvServer()) .OR. "TESTE" $ UPPER(GetEnvServer())
                    ShellExecute("open", "http://10.139.0.30:8081/rest/RestLibPV/v2?userlib="+cToken, "", "", 1)
                Else
                    ShellExecute("open", "http://10.139.0.30:8080/rest/RestLibPV/v2?userlib="+cToken, "", "", 1)
                EndIf
            EndIf
        EndIf
    EndIf
    nModAnt := nModulo
EndIf

Return cMenu
