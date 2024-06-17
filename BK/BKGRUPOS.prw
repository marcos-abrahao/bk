#include "TOTVS.CH"
#include "PROTHEUS.CH"

/*/{Protheus.doc} BKGRUPOS
BK - Array com as empresas do grupo BK

@Return
@author Marcos B. Abrahão
@since 24/08/21
@version P12
/*/

User Function BKGrupo(nOpc)
Local aReturn   := {}
Local nE        := 0
Default nOpc    := 2 // Ativas

/*
nOpc = 1  // Retorna todas empresas
nOpc = 2  // Empresas Ativas
nOpc = 3  // Empresas que usam Gestão de Contratos
nOpc = 4  // Empresas que possuem despesas em contratos
nOpc = 5  // Empresas que efetuam Faturamento
nOpc = 6  // Empresas em Barueri - SP
*/
// Todas Empresas
//                                                              Ativa - 4
//                                                                  GCT - 5
//                                                                      Desp - 6
//                                                                          Fat - 7
//                                                                               Barueri - 8
//                                                                                  CC Consorcio - 9
Local aEmpresas	:= {    {"01","BK"              ,"BK"           ,"S","S","S","S","S",""         },;
                        {"02","MMDK"            ,"MMKD"         ,"S","S","S","S","N",""         },;
                        {"04","ESA"             ,"ESA"          ,"N","N","N","N","N",""         },;
                        {"06","BKDAHER SUZANO"  ,"BKDAHER S"    ,"N","N","N","N","N",""         },;
                        {"07","JUST SOFTWARE"   ,"JUST"         ,"N","N","N","N","N",""         },;
                        {"08","BHG CAMPINAS"    ,"BHG CAMP"     ,"N","N","N","N","N",""         },;
                        {"09","BHG OSASCO"      ,"BHG OSAS"     ,"N","N","N","N","N",""         },;
                        {"10","BKDAHER TABOAO"  ,"BKDAHER T"    ,"N","N","N","N","N",""         },;
                        {"11","BKDAHER LIMEIRA" ,"BKDAHER L"    ,"N","N","N","N","N",""         },;
                        {"12","BK CORRETORA"    ,"CORRETORA"    ,"S","N","N","S","N",""         },;
                        {"14","BALSA NOVA"      ,"BALSA"        ,"S","S","S","S","N","302000508"},;
                        {"15","BHG INT 3"       ,"BHG"          ,"S","N","S","N","S","305000554"},;
						{"16","MOOVE-SP"        ,"MOOVE"        ,"S","N","S","N","N","386000609"},;
						{"17","DMAF"            ,"DMAF"         ,"S","N","N","S","N",""         },;
                        {"18","BK VIA"          ,"BK VIA"       ,"S","S","S","S","S","303000623"},;
                        {"19","BK SOL. TEC."    ,"BK S.TEC."    ,"S","N","N","S","S",""         },;
                        {"97","CMOG"            ,"CMOG"         ,"X","N","N","N","N",""         },;
                        {"98","TERO"            ,"TERO"         ,"X","N","N","N","N",""         } }


For nE := 1 To Len(aEmpresas)
    If nOpc == 1 .OR. aEmpresas[nE,nOpc+2] == "S"
        aAdd(aReturn,aEmpresas[nE])
    EndIf
Next
Return aReturn


// Retorna Campo do Array de empresas - Geralmente Nome(2) ou Nome reduzido(3)
User Function BKNEmpr(cEmpr,nI)
Local aEmpr := u_BKGrupo(1)
Local nEmpr := Ascan(aEmpr,{|x| x[1] == cEmpr})
Local cNEmp := ""
If nEmpr > 0
	cNEmp := aEmpr[nEmpr,nI]
EndIf
Return cNEmp

// Empresas que utilizam Gestão de Contratos
User Function BKGrpGct()
Return u_BKGrupo(3)

// Empresas que utilizam possuem despesas em contratos
User Function BKGrpDsp()
Return u_BKGrupo(4)

// Empresas que utilizam possuem faturamento
User Function BKGrpFat()
Return u_BKGrupo(5)

// Empresas em Barueri
User Function BkBarueri()
Return u_BKGrupo(6)
