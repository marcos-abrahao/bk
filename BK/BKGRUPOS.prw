#include "totvs.ch"
#include "protheus.ch"

// Funcoes com códigos embutidos no fonte

/*/{Protheus.doc} BKGRUPOS
BK - Array com as empresas do grupo BK

@Return
@author Marcos B. Abrahão
@since 24/08/21
@version P12
/*/

User Function BKGrupo()
// Empresas ativas
Local aEmpresas	:= {    {"01","BK"},;
                        {"02","BKTER"},;
                        {"12","BK CORRETORA"},;
                        {"14","BALSA NOVA"},;
                        {"15","BHG INT 3"} }
Return aEmpresas


User Function BKGrpGct()
// Empresas que utilizam Gestão de Contratos
Local aEmpresas	:= {    {"01","BK"},;
                        {"02","BKTER"},;
                        {"14","BALSA NOVA"}}
Return aEmpresas


User Function BKGrpDsp()
// Empresas que utilizam possuem despesas em contratos
Local aEmpresas	:= {    {"01","BK"},;
                        {"02","BKTER"},;
                        {"14","BALSA NOVA"},;
                        {"15","BHG INT 3"} }   // Empresa 15 possui despesas
Return aEmpresas


User Function BKEmpr()
// Todas Empresas
Local aEmpresas	:= {    {"01","BK"},;
                        {"02","BKTER"},;
                        {"04","ESA"},;
                        {"06","BKDAHER SUZANO"},;
                        {"07","JUST SOFTWARE"},;
                        {"08","BHG CAMPINAS"},;
                        {"09","BHG OSASCO"},;
                        {"10","BKDAHER TABOAO"},;
                        {"11","BKDAHER LIMEIRA"},;
                        {"12","BK CORRETORA"},;
                        {"14","BALSA NOVA"},;
                        {"15","BHG INT 3"},;
                        {"97","CMOG"},;
                        {"98","TERO"} }
Return aEmpresas


User Function BKNEmpr(cEmpr)
Local aEmpr := u_BKEmpr()
Local nEmpr := Ascan(aEmpr,{|x| x[1] == cEmpr})
Local cNEmp := ""
If nEmpr > 0
	cNEmp := aEmpr[nEmpr,2]
EndIf
Return cNEmp


/*/{Protheus.doc} IsSuperior
    Retorna se o usuario informado é superior de algum outro
    @type  Function
    @author Marcos Bispo Abrahão
    @since 30/08/2021
    @version version
    @param cId (Id do usuário)
    @return lRet
    /*/
User Function IsSuperior(cId)
Local nx,ny
Local aAllusers := FWSFALLUSERS()
Local aSup		:= {}
Local lRet := .F.

For nx := 1 To Len(aAllusers)
	aSup := FWSFUsrSup(aAllusers[nx][2])
	For ny := 1 To Len(aSup)
		If cId == aSup[ny]
			lRet := .T.
			Exit
		EndIf
	Next
	If lRet
		Exit
	Endif
Next
Return lRet


// Listagem de usuarios x superiores
User Function ListSup()
Local nx		:= 0
Local ny		:= 0
Local aAllusers := FWSFALLUSERS(,,,,.T.)
Local aSup		:= {}
Local lRet 		:= .F.
Local aUsSup 	:= {}
Local aCabec	:= {"Usuários","Superiores"}

For nx := 1 To Len(aAllusers)
	If aAllUsers[nx,9] == '2' //usuário ativo
		aSup := FWSFUsrSup(aAllusers[nx][2])
		If Len(aSup) > 0
			For ny := 1 To Len(aSup)
				//u_LogPrw("ListSup",aAllusers[nx][2]+"-"+aAllusers[nx][4]+" : "+aSup[ny]+"-"+UsrRetName(aSup[ny]))
				aAdd(aUsSup,{aAllusers[nx][2]+"-"+aAllusers[nx][3],aSup[ny]+"-"+UsrRetName(aSup[ny])})
			Next
		Else
			aAdd(aUsSup,{aAllusers[nx][2]+"-"+aAllusers[nx][3],""})
		EndIf	
	EndIf
Next

u_ArrXls(aUsSup,"Usuários x Superiores",aCabec)

Return lRet




// Retorna se o usuário pertence ao grupo informado
User Function IsGrupo(cId,cIdGrupo)
Local nx
Local aGrp := FWSFUsrGrps(cId)
Local lRet := .F.

For nx := 1 To Len(aGrp)
	If cIdGrupo == aGrp[nx]
		lRet := .T.
		Exit
	EndIf
Next

Return lRet


// Retorna se o usuário pertence ao STAF 
// MV_XXUSER - Parametro especifico BK - Usuarios que visualizam doc de entrada de seus superiores e do depto todo
User Function IsStaf(cId)
Local lRet := .F.
// Laudecir/Diego.Oliveira/Edson/Fabio/Leandro/Vanderleia/Nelson/Luis (000116/ removido)
If cId $ "000011/000016/000076/000093/000194/000056/000165/"
    lRet := .T.
EndIf
Return lRet


// Retorna se o usuário deve avaliar Fornecedores (Compras e Almox)

User Function IsAvalia(cId)
Local lRet := .F.
// Admin/Fabio/Anderson/Luis/Michele/Caio
If cId $ "000000/000093/000005/000116/000138/000126/"
    lRet := .T.
EndIf
Return lRet


// Gerente Compras
User Function GerCompras
// Michele,Luis /000116 (removido),Fabio
Return "000138/000093"


// Emails dos gerenciadores de compras
User Function EmGerCom(cxEmail)
Local aUsers := {"000138","000116","000093"} // Michele,Luis,Fabio
Return u_aUsrEmail(aUsers,cxEmail)


// Gerente Gestão
User Function GerGestao
// Vanderleia
Return "000056"


// Gerente Gestão Petrobrás
User Function GerPetro
// Vanderleia
Return "000056"


// Grupo Almoxarifado
User Function GrpAlmox
Return "000021/000032"


// Grupos Master Diretoria
User Function GrpMDir
// Master Fin-5/Master Dir-7/Master Repac-8/Master Ctb-10/Master Almox-27/Master ctb todas-29/User Fiscal-31
//Return "000005/000007/000008/000010/000027/000029/000031/"
Return "000005/000007/000008/000010/000029/000031/"



// Usuarios Almoxarifado (para queries)
User Function UsrAlmox
Return "'000093','000126','000216','000225','000226','000227'"


// Usuarios Master Almoxarifado (grupo 27)
User Function UsrMAlmox()
Return "000093/000216/000126/000232/000225/000227"  


// Email para Grupo do (Fabio,Caio,Barbara,Jose Amauri,Andre Leitao)
User Function EmEstAlm(cId,lAll,cxEmail)
Local aUsers := {"000093","000126","000232","000216","000227"}
Local cEmails:= ""

Default cxEmail := "-"

If Ascan(aUsers,cId) > 0 .OR. lAll
	cEmails := u_aUsrEmail(aUsers,cxEmail)
EndIf

Return cEmails



// Email para Grupo Master Repac (Fabia, Bruno e Fernando Sampaio)
User Function EmMRepac()
Local aUsers := {"000023","000153","000241"}
Return u_aUsrEmail(aUsers)


// Email para Grupo Master Repac (Vanderleia, Bruno e Marcio M)
User Function EmpPcAprv()
Local aUsers := {"000056","000153","000240"}
Return u_aUsrEmail(aUsers)



// Retorna emails de diversos usuarios (array de codigos)
User Function aUsrEmail(aUsers,cxEmail)
Local cEmail := ""
Local cEmails:= ""
Local nI	 := 0

Default cxEmail := "-;"

For nI := 1 To Len(aUsers)
	If !Empty(aUsers[nI])
		cEmail  := ALLTRIM(UsrRetMail(aUsers[nI]))
		If !Empty(cEmail) .AND. !cEmail $ cxEmail
			cEmails += cEmail+";"
			cxEmail += cEmail+";"
		EndIf
	EndIf
Next

Return cEmails



// Gestão de Contratos

/* Clientes Petrobras
A1_COD	A1_NOME
000153	PETROLEO BRASILEIRO S/A - PETROBRAS                                             
000249	PETROLEO BRASILEIRO S/A - PETROBRAS                                             
000255	PETROLEO BRASILEIRO S/A - PETROBRAS                                             
000256	PETROLEO BRASILEIRO S/A - PETROBRAS                                             
000281	PETROLEO BRASILEIRO S A PETROBRAS                                               
000281	PETROLEO BRASILEIRO S/A - PETROBRAS                                             
000281	PETROLEO BRASILEIRO S/A - PETROBRAS - CATU                                      
000281	PETROLEO BRASILEIRO S/A - PETROBRAS - CONSORCIO C-M-210                         
000281	PETROLEO BRASILEIRO S/A - PETROBRAS - CONSORCIO C-M-277                         
000281	PETROLEO BRASILEIRO S/A - PETROBRAS - CONSORCIO C-M-344                         
000281	PETROLEO BRASILEIRO S/A - PETROBRAS - CONSORCIO C-M-346                         
000281	PETROLEO BRASILEIRO S/A - PETROBRAS - CONSORCIO C-M-411                         
000281	PETROLEO BRASILEIRO S/A - PETROBRAS - CONSORCIO C-M-413                         
000281	PETROLEO BRASILEIRO S/A - PETROBRAS - CONSORCIO C-M-657_R15                     
000281	PETROLEO BRASILEIRO S/A - PETROBRAS - CONSORCIO C-M-709_R15                     
000281	PETROLEO BRASILEIRO S/A - PETROBRAS - JAPARATUBA                                
000291	PETROLEO BRASILEIRO S/A PETROBRAS                                               
000310	PETROLEO BRASILEIRO S/A - PETROBRAS                                             
000313	PETROBRAS DISTRIBUIDORA SA                                                      
000316	PETROBRAS TRANSPORTE S/A - TRANSPETRO - TERMINAL SAO CAETANO DO SUL             
000317	PETROBRAS TRANSPORTE S/A - TRANSPETRO - TERMINAL BARUERI                        
000318	PETROBRAS TRANSPORTE S/A - TRANSPETRO - TERMINAL GUARULHOS                      
000319	PETROBRAS TRANSPORTE S/A - TRANSPETRO - TERMINAL GUARAREMA                      
000320	PETROBRAS TRANSPORTE S/A - TRANSPETRO - TERMINAL CUBATAO                        
000321	PETROBRAS TRANSPORTE S/A - TRANSPETRO - TERMINAL SAO SEBASTIAO                  
000333	PETROLEO BRAS S/A PETROBRAS - UIRAPURU                                          
000334	PETROLEO BRAS S/A PETROBRAS - TRES MARIAS                                       
000335	PETROLEO BRASILEIRO S/A  CABO FRIO CENTRAL                                      
000336	PETROLEO BRASILEIRO S/A - DOIS IRMAOS                                           
000345	PETROBRAS EDUCACAO AMBIENTAL                                                    
000346	PETROBRAS CARAGUATATUBA - BOMBEIROS                                             
000347	PETROBRAS EDICIN - U.P.                                                         
000372	PETROBRAS TRANSPORTE S.A. - TRANSPETRO                                          
*/
User Function IsPetro(cCliente)
Local lRet		:= .F.
Local aPetro 	:= {}
If cEmpAnt == "01" .AND. !Empty(cCliente)
	aAdd(aPetro,"000153")
	aAdd(aPetro,"000249")
	aAdd(aPetro,"000255")
	aAdd(aPetro,"000256")
	aAdd(aPetro,"000281")
	aAdd(aPetro,"000291")
	aAdd(aPetro,"000310")
	aAdd(aPetro,"000316")
	aAdd(aPetro,"000317")
	aAdd(aPetro,"000318")
	aAdd(aPetro,"000319")
	aAdd(aPetro,"000320")
	aAdd(aPetro,"000321")
	aAdd(aPetro,"000333")
	aAdd(aPetro,"000334")
	aAdd(aPetro,"000335")
	aAdd(aPetro,"000336")
	aAdd(aPetro,"000345")
	aAdd(aPetro,"000346")
	aAdd(aPetro,"000347")
	aAdd(aPetro,"000372")
	If Ascan(aPetro,cCliente) > 0
		lRet := .T.
	EndIf
EndIf

Return lRet


// Financeiro
// Usuários que podem integrar PJ do Rubi pelo Financeiro BKFINA02
User Function FinUsrPj()
Return "000011/000012/000000/000016"  // Diego 16 incluido nas ferias do Lau
