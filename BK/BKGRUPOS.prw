#include "TOTVS.CH"
#include "PROTHEUS.CH"

/*/{Protheus.doc} BKGRUPOS
BK - Array com as empresas do grupo BK

@Return
@author Marcos B. Abrahão
@since 24/08/21
@version P12
/*/

User Function BkGrupo(nOpc,xEmpr)
Local aRet := {}
Default nOpc  := 2 // Ativas
Default xEmpr := cEmpAnt

If xEmpr == "20" // Barcas
    aRet := u_BkEmpr(8)
Else 
    aRet := u_BkEmpr(nOpc)
EndIf
Return aRet


User Function IsBarcas(cEmp)
Local lRet := .F.
Default cEmp := cEmpAnt
If cEmp == "20"
    lRet := .T.
EndIF
Return lRet



User Function BkEmpr(nOpc)
Local aReturn     := {}
Local nE          := 0
Default nOpc      := 2 // Ativas
Default lBarcas   := .T.

/*
nOpc = 1  // Retorna todas empresas
nOpc = 2  // Empresas Ativas
nOpc = 3  // Empresas que usam Gestão de Contratos
nOpc = 4  // Empresas que possuem despesas em contratos e RH
nOpc = 5  // Empresas que efetuam Faturamento
nOpc = 6  // Empresas em Barueri - SP
nOpc = 7  // CC Consorcio
nOpc = 8  // Barcas Rio
*/
// Todas Empresas
//                                                      Ativa - 4
//                                                          GCT - 5
//                                                              Desp - 6
//                                                                  Fat - 7
//                                                                       Barueri - 8
//                                                                          CC Consorcio - 9
//                                                                                       Barcas - 10

Local aEmpresas	:= {}

aAdd(aEmpresas,{"01","BK"              ,"BK"           ,"S","S","S","S","S",""         ,"N"})
aAdd(aEmpresas,{"02","MMDK"            ,"MMDK"         ,"S","S","S","S","N",""         ,"N"})
aAdd(aEmpresas,{"04","ESA"             ,"ESA"          ,"N","N","N","N","N",""         ,"N"})
aAdd(aEmpresas,{"06","BKDAHER SUZANO"  ,"BKDAHER S"    ,"N","N","N","N","N",""         ,"N"})
aAdd(aEmpresas,{"07","JUST SOFTWARE"   ,"JUST"         ,"N","N","N","N","N",""         ,"N"})
aAdd(aEmpresas,{"08","BHG CAMPINAS"    ,"BHG CAMP"     ,"N","N","N","N","N",""         ,"N"})
aAdd(aEmpresas,{"09","BHG OSASCO"      ,"BHG OSAS"     ,"N","N","N","N","N",""         ,"N"})
aAdd(aEmpresas,{"10","BKDAHER TABOAO"  ,"BKDAHER T"    ,"N","N","N","N","N",""         ,"N"})
aAdd(aEmpresas,{"11","BKDAHER LIMEIRA" ,"BKDAHER L"    ,"N","N","N","N","N",""         ,"N"})
aAdd(aEmpresas,{"12","BK CORRETORA"    ,"CORRETORA"    ,"S","N","N","S","N",""         ,"N"})
aAdd(aEmpresas,{"14","BALSA NOVA"      ,"BALSA"        ,"S","N","N","N","N","302000508","N"})
aAdd(aEmpresas,{"15","BHG INT 3"       ,"BHG"          ,"S","S","S","S","S","305000554","N"})
aAdd(aEmpresas,{"16","MOOVE-SP"        ,"MOOVE"        ,"S","N","S","N","N","386000609","N"})
aAdd(aEmpresas,{"17","DMAF"            ,"DMAF"         ,"S","N","N","S","N",""         ,"N"})
aAdd(aEmpresas,{"18","BK VIA"          ,"BK VIA"       ,"S","S","S","S","S","303000623","N"})
aAdd(aEmpresas,{"19","BK SOL. TEC."    ,"BK S.TEC."    ,"S","N","N","S","S",""         ,"N"})
aAdd(aEmpresas,{"20","BARCAS RIO"      ,"BARCAS R."    ,"S","S","S","S","S","408000644","S"})
aAdd(aEmpresas,{"97","CMOG"            ,"CMOG"         ,"S","N","N","N","N",""         ,"N"})
aAdd(aEmpresas,{"98","TERO"            ,"TERO"         ,"S","N","N","N","N",""         ,"N"})

For nE := 1 To Len(aEmpresas)
    If nOpc == 1 .OR. aEmpresas[nE,nOpc+2] == "S" .OR. (nOpc == 7 .AND. !EMPTY(aEmpresas[nE,nOpc+2]))
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
User Function BKGrpGct(xEmpr)
Default xEmpr := cEmpAnt
Return u_BKGrupo(3,xEmpr)

// Empresas que utilizam possuem despesas em contratos
User Function BKGrpDsp(xEmpr)
Default xEmpr := cEmpAnt
Return u_BKGrupo(4,xEmpr)

// Empresas que utilizam possuem faturamento
User Function BKGrpFat(xEmpr)
Default xEmpr := cEmpAnt
Return u_BKGrupo(5,xEmpr)

// Empresas em Barueri
User Function BkBarueri(xEmpr)
Default xEmpr := cEmpAnt
Return u_BKGrupo(6,xEmpr)

// Empresas em Barueri
User Function BkConsorcio(xEmpr)
Default xEmpr := cEmpAnt
Return u_BKGrupo(7,xEmpr)

User Function BKEmpCons(cCC)
Local cEmpBK  := ""
Local nEmp    := 0
Local aBkCons := u_BkConsorcio()
nEmp := aScan(aBkCons,{ |x| x[9] == TRIM(cCC)})
If nEmp > 0
    cEmpBK := aBkCons[nEmp,1]
EndIf
Return cEmpBK

User Function BKEmpCC(cEmp)
Local cCC  := ""
Local nEmp    := 0
Local aBkCons := u_BkConsorcio()
nEmp := aScan(aBkCons,{ |x| x[1] == TRIM(cEmp)})
If nEmp > 0
    cCC := aBkCons[nEmp,9]
EndIf
Return cCC
