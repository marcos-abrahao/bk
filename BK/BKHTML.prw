#include "totvs.ch"
#include "protheus.ch"

/*/{Protheus.doc} BKVARS
BK - Funcoes com parâmetros embutidos no fonte
@Return
@author Marcos B. Abrahão
@since 03/05/22
@version P12
/*/


// Retorna IP e Porta do server REST
User Function BkIpPort()
Local cIpPort := "10.139.0.30:8080"
If "TST" $ UPPER(GetEnvServer()) .OR. "TESTE" $ UPPER(GetEnvServer())
	cIpPort := "10.139.0.30:8081"
EndIf
//u_MsgLog(,GetEnvServer()+" - "+cIpPort,"I")
Return cIpPort


// Retorna endereço do REST BK
User Function BKRest()
Local cRest := "http://"+u_BkIpPort()+"/rest"
Return cRest


// Retorna endereço do Servidor BK
User Function BKIpServer()
Local cRest := "http://10.139.0.30"
Return cRest


User Function BKFavIco()
//<!-- Favicon -->
Local cRest := '<link rel="shortcut icon" href="http://10.139.0.30:80/favicon.ico">'
Return cRest




