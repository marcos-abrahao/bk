#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKFINR12
BK - 
@Return
@author Adilson do Prado / Marcos Bispo Abrah�o
@since 
@version P12
/*/
User Function Nada()

Local oTmpTb
Local aDbf := {}
Local nStart := Time()
Local cQuery := ""

oTmpTb := FWTemporaryTable():New("TRB")
oTmpTb:SetFields( aDbf )
oTmpTb:AddIndex("indice1", {"XX_CHAVE"} )
oTmpTb:Create()


oTmpTb:Delete()

// Para gravar query quando admin
cQuery := "SELECT 1 "+ CRLF
u_LogMemo("BKGCTR0X.SQL",cQuery)

/// Alterar U_GeraCSV para U_GeraXlsx

//ProcRegua(QTMP->(LASTREC()))
//Processa( {|| U_GeraCSV("QTMP",cPerg,aTitulos,aCampos,aCabs)})
AADD(aPlans,{"QTMP",cPerg,"",aTitulos,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
U_GeraXlsx(aPlans,Titulo,cPerg,.T.)

///


FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "JSON successfully parsed to Object", 0, (nStart - Seconds()), {}) // nStart � declarada no inicio da fun��o

Return NIL


// Para ver se  a rotina foi chamada via schedule:

User Function xpto(aParam) 
Local lAuto := IsBlind()

//Se for por Schedule, abre o ambiente 
If lAuto 
    RpcSetType(3) 
	RpcSetEnv(aParam[1], aParam[2]) 
EndIf

//... seu c�digo

If lAuto 
	RpcClearEnv() 
	aParam := ASize(aParam, 0) 
	aParam := Nil 
EndIf

Return 




#include "totvs.ch"

/*
function u_niversAdvPL()
local i := 0       
local tempPath := GetTempPath()
local aButtons := {;
					"nivers_cake-variant",;
					"nivers_home",;
                    "nivers_delete-forever",;
                    "nivers_device_hub",;
                    "nivers_menu";
                  } // BOTOES DEVEM ESTAR COMPILADOS COMO RECURSO  
private OS := getOS() // Recupera sistema operacional em execucao

oDlg := TWindow():New(10, 10, 800, 600, "Nivers AdvPL")
oDlg:setCss('QPushButton{borde: 1px solid black}')

    // Baixa botoes do RPO no TEMP
	for i := 1 to len(aButtons)
		cFile :=  + aButtons[i]+'.png'
		cFileContent := getApoRes(cFile)

		if cFileContent == Nil
			msgAlert("Botao: " + cFile + " nao existe no RPO, favor compilar o arquivo")
			return
		else
			if OS == "UNIX"
				cFileDownload := "l:" + tempPath + cFile
			else
				cFileDownload := "c:\tmp\"+cFile
			endif
			
			nHandle := fCreate(cFileDownload)
			fWrite(nHandle, cFileContent)
			fClose(nHandle)
		endif
    next i    
        
	// [*AppBar]
	oTBar := TBar():New( oDlg, 25, 32, .T.,,,, .F. )
	oTBar:SetCss("QFrame{background-color: #007bff;}")
    oBtn1 := TButton():New(0,0,"",oTBar,{|| }, 12,12,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtn2 := TButton():New(0,0,"",oTBar,{|| home() }, 12,12,,,.F.,.T.,.F.,"Home",.F.,,,.F. )
    oBtn3 := TButton():New(0,0,"",oTBar,{|| nivers() }, 12,12,,,.F.,.T.,.F.,"Anivers�rios",.F.,,,.F. )
	oBtn4 := TButton():New(0,0,"",oTBar,{|| hooks() }, 12,12,,,.F.,.T.,.F.,"Hooks",.F.,,,.F. )
	
	// [*StyleSheet] Estiliza os botoes da barra superior
	cCss := ("QPushButton{ qproperty-iconSize: 24px;"+;
			" qproperty-icon: url(<image>); background-color: transparent;}"+;
			"QPushButton:hover{background-color: #0069d9; border: none;}")    
	
	// No caso do oBtn1 temos que "esconder" o indicador de menu, ou a visualiza��o ficara prejudicada
	oBtn1:SetCss(StrTran(cCss, "<image>", "/tmp/nivers_menu.png")+;
							   "QPushButton::menu-indicator{position: relative; top: -20px;}")
    oBtn2:SetCss(StrTran(cCss, "<image>", "/tmp/nivers_home.png"))
    oBtn3:SetCss(StrTran(cCss, "<image>", "/tmp/nivers_cake-variant"))
    oBtn4:SetCss(StrTran(cCss, "<image>", "/tmp/nivers_device_hub"))

	// [*MainMenu]
    oMenu := TMenu():New(0,0,0,0,.T.)
    oTMenuIte1 := TMenuItem():New(oDlg,"Home",,,,{|| home() },,,,,,,,,.T.)
    oTMenuIte2 := TMenuItem():New(oDlg,"Aniversarios",,,,{|| nivers() },,,,,,,,,.T.)
    oTMenuIte3 := TMenuItem():New(oDlg,"Hooks",,,,{|| hooks() },,,,,,,,,.T.)
    oMenu:Add(oTMenuIte1)
    oMenu:Add(oTMenuIte2)
    oMenu:Add(oTMenuIte3)
	oBtn1:SetPopupMenu(oMenu)
	
	// [*Router] - No AdvPL n�o temos roteamento, as subrotinas sao abertas em Dialogs

oDlg:Activate("MAXIMIZED")
return nil

// ---------------------------------------------------------------
// Retorna SO do Smartclient
// ---------------------------------------------------------------
static function getOS()
local stringOS := Upper(GetRmtInfo()[2])

	if ("ANDROID" $ stringOS)
    	return "ANDROID" 
	elseif ("IPHONEOS" $ stringOS)
		return "IPHONEOS"
	elseif GetRemoteType() == 0 .or. GetRemoteType() == 1
		return "WINDOWS"
	elseif GetRemoteType() == 2 
		return "UNIX" // Linux ou MacOS		
	elseif GetRemoteType() == 5 
		return "HTML" // Smartclient HTML		
	endif
	
return ""

// ---------------------------------------------------------------
static function home()
// ---------------------------------------------------------------
Local oFont1 := TFont():New("Arial",,020,,.T.,,,,,.F.,.F.)
Local oSay1

	DEFINE MSDIALOG oDlg TITLE "Home" FROM 000, 000  TO 100, 300 COLORS 0, 16777215 PIXEL
@ 009, 004 SAY oSay1 PROMPT "Tela inicial do App" SIZE 200, 017 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
  	ACTIVATE MSDIALOG oDlg CENTERED
return	

// ---------------------------------------------------------------
static function hooks()
// ---------------------------------------------------------------
Local oButton1
Local oFont1 := TFont():New("Arial",,020,,.T.,,,,,.F.,.F.)
Local oSay1
Local nCount := 0
Local cClicksIni := "Voce clicou {{count}} vezes"

	// Parser inicial
	cClicks := StrTran(cClicksIni, "{{count}}", cValToChar(nCount))

  	DEFINE MSDIALOG oDlg TITLE "Hooks" FROM 000, 000  TO 100, 300 COLORS 0, 16777215 PIXEL
    	@ 009, 004 SAY oSay1 PROMPT cClicks SIZE 165, 017 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
    	@ 032, 004 BUTTON oButton1 PROMPT "Incrementa contador - Por referencia" SIZE 100, 012 OF oDlg PIXEL Action {|| hooksINC(oSay1, @nCount, cClicksIni) }
  	ACTIVATE MSDIALOG oDlg CENTERED

Return

// ---------------------------------------------------------------
static function hooksINC(oSay1, nCount, cClicksIni)
// ---------------------------------------------------------------
	nCount++ // [*Getter_and_Setter] Incrementa contador
	oSay1:setText( StrTran(cClicksIni, "{{count}}", cValToChar(nCount)) )
return	

// ---------------------------------------------------------------
static function nivers()
// ---------------------------------------------------------------
Local oButton1
Local oGet1
Local oGet2
Local cAniversariante := Space(100) // [*InputParams]
Local dNiver := Date()
Local oMultiGe1
Local cMultiGe1 := ""
Local oSay1
Local oSay2
Static oDlg

  // [*Form] - Formulario para inclusao dos aniversarios
  DEFINE MSDIALOG oDlg TITLE "Nivers" FROM 000, 000  TO 320, 500 COLORS 0, 16777215 PIXEL

	@ 014, 145 BUTTON oButton1 PROMPT "INSERIR" SIZE 054, 012 OF oDlg PIXEL Action {|| NiversInsert(oMultiGe1, cAniversariante, dNiver) }
	
	// [*CustomButton] Definicao do CSS 
	oButton1:SetCss(;
		"QPushButton {"+;
    	"	border: none;"+;
    	"	color: #fff;"+;
    	"	background-color: #007bff;}"+;
		"QPushButton:hover {"+;
    	"	background-color: #0069d9;}")

    @ 004, 004 SAY oSay1 PROMPT "Aniversariante" SIZE 043, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 004, 079 SAY oSay2 PROMPT "Niver" SIZE 043, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 014, 003 MSGET oGet1 VAR cAniversariante SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 014, 078 MSGET oGet2 VAR dNiver SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 034, 004 GET oMultiGe1 VAR cMultiGe1 OF oDlg MULTILINE SIZE 236, 120 COLORS 0, 16777215 HSCROLL PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

Return

// ---------------------------------------------------------------
static function niversInsert(oMultiGe1, cAniversariante, dNiver)
// ---------------------------------------------------------------
	// [*Submit] Insere aniversarios na lista
	oMultiGe1:appendText(chr(10) + trim(cAniversariante) +" | "+ DtoC(dNiver))
return
*/

/*
Fun��es SX - Convers�o para o banco
Classes com m�todos est�ticos:

SM0 - FWSM0Util: https://tdn.totvs.com/display/public/PROT/FWSM0Util
SIX - FWSIXUtil - https://tdn.totvs.com/display/public/PROT/FWSIXUtil
SX1 - FWSX1Util - https://tdn.totvs.com/display/public/PROT/FWSX1Util
SX2 - FWSX2Util - https://tdn.totvs.com/display/public/PROT/FWSX2Util
SX3 - FWSX3Util -https://tdn.totvs.com/display/public/PROT/FWSX3Util
SX6 - FWSX6Util - https://tdn.totvs.com/display/public/PROT/FWSX6Util
SX9 - FWSX9Util - https://tdn.totvs.com/display/public/PROT/FWSX9Util
Outras fun��es:

Montagem de aCols e aHeader - FillGetDados - https://tdn.totvs.com/display/public/PROT/FillGetDados
Leitura de dados da SX5 - FWGetSX5 - https://tdn.totvs.com/display/public/PROT/FWGetSX5
Grava��o de dados na SX5 - FwPutSX5 - https://tdn.totvs.com/pages/releaseview.action?pageId=286016719
Atualiza��o de conte�do de par�metros na SX6 - PutMV - https://tdn.totvs.com/pages/releaseview.action?pageId=6814924
Fun��es de usu�rios - Nessa �rvore do TDN existem diversas fun��es - https://tdn.totvs.com/pages/releaseview.action?pageId=6814847
Demais fun��es: https://tdn.totvs.com/pages/releaseview.action?pageId=353290193

*/

// Exemplos de Fun�oes do ADVPL
// Alterar pergunta
User Function exUpdPrg()

Pergunte("CFG025",.F.)//Carrego as MV_PAR's sem exibir a tela
Alert(MV_PAR03)// Mostra o valor que estava gravado

SetMVValue("CFG025","MV_PAR03",Date()) //Atualizo o valor da terceira pergunta para a data de hoje
Alert(MV_PAR03)// Continua com o mesmo valor (as vari�veis MV_PAR n�o s�o atualizadas...)

Pergunte("CFG025",.T.) //Mostra a tela de Pergunte com o par�metro de data final atualizado

Return



// Libera��o de pedidos de venda!

Static Function fLibPed(cNumPed)


    dbSelectArea("SC6")
    SC6->(dbSetOrder(1))
    SC6->(dbSeek(xFilial("SC6")+cNumPed))

    While SC6->(!EOF()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == cNumPed

        MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,.F.,.F.,.F.,.F.,)


        SC6->(dbSkip())
    EndDo


Return
