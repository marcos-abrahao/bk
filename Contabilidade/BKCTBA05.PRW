#include "PROTHEUS.CH"
#include "TopConn.ch"

/*/{Protheus.doc} BKCTBA05
BK - Bloquear contas contábeis por range

@Return
@author Marcos Bispo Abrahão
@since 31/08/2020
@version P12.1.25
/*/

User Function BKCTBA05()

Local nContFlds As Numeric
Local cAlias    As Character
Local aFields   As Array
Local aColumns  As Array
Local aPesq     As Array
Local oMark     As Object
//Local cQuery    As Character
Local oTempTable    As Object

Local aSize	   	:= FWGetDialogSize( oMainWnd )
Local nTop		:= 0
Local nLeft	   	:= 0
Local lEnd		:=	.F.
Local oDlg		:= Nil
Local bBloqueia	:= { || Processa( { || lEnd := CTBA05Blq( oMark,cAlias ) }, "Bloqueando contas..."), MsgInfo("Contas bloqueadas",cPerg), oMark:Deactivate(), oDlg:End() } 
Local bCancel   := {|| oMark:Deactivate(), oDlg:End()}

Private cPerg   := "BKCTBA05"
Private cTitulo := "Bloqueio de Contas Contábeis"
Private aParam	:=	{}
Private aRet	:=	{}
Private dDataI 	:= CTOD("")
Private dDataF 	:= CTOD("")

u_LogPrw("BKCTBA05")

aAdd( aParam, { 1, "Data Inicial:" 		, CTOD("")					, ""            , ""   , ""	  , "" , 70  , .F. })
aAdd( aParam, { 1, "Data Final:" 		, CTOD("")					, ""            , ""   , ""	  , "" , 70  , .F. })  

// Desabilita opções do menu
aRotina     := {}
cAlias      := GetNextAlias()
aFields     := {}
aColumns    := {}
aPesq       := {}

oTempTable  := TempTbl(cAlias)

//Regras para pesquisa na tela
//Aadd(aPesq, {AllTrim(RetTitle("CT1_CONTA")), {{"CT1", "C", TamSX3("CT1_CONTA")[1], 0, AllTrim(RetTitle("CT1_CONTA")), "@!"}}, 1})

oDlg := MsDialog():New( nTop, nLeft, aSize[3], aSize[4],cTitulo,,,,,,,,, .T.,,,, .F. )

// Instanciamento do classe
oMark := FWMarkBrowse():New()
oMark:SetOwner( oDlg )

//cQuery := "SELECT '  ' AS CT1_OK,CT1_CONTA,CT1_DESC01,CT1_DTBLIN,CT1_DTBLFI,CT1_CLASSE,(CASE WHEN CT1_BLOQ = '1' THEN 'S' ELSE 'N' END) AS CT1_BLOQ,CT1.R_E_C_N_O_ AS CT1RECNO"
//cQuery += " FROM "+RETSQLNAME("CT1")+" CT1 WHERE CT1.D_E_L_E_T_ = '' AND CT1_FILIAL = '"+xFilial("CT1")+"' "
//cQuery += " ORDER BY CT1_CONTA"
//cQuery := "SELECT * FROM " + oTempTable:GetRealName()

aAdd( aFields, {"CT1_CONTA" , "Conta"} )
aAdd( aFields, {"CT1_DESC01", "Descrição"} )
aAdd( aFields, {"CT1_CLASSE", "Classe"} )
aAdd( aFields, {"CT1_DTBLIN", "Inicio Bloqueio"} )
aAdd( aFields, {"CT1_DTBLFI", "Final Bloqueio"} )
aAdd( aFields, {"CT1_BLOQ"  , "Bloqueio total"} )
 
For nContFlds := 1 To Len( aFields )
    AAdd( aColumns, FWBrwColumn():New() )
    If GetSx3Cache(aFields[nContFlds][1], "X3_TIPO") == 'D'
        aColumns[Len(aColumns)]:SetData( &("{ || STOD(" + aFields[nContFlds][1] + ") }") )
    Else
        aColumns[Len(aColumns)]:SetData( &("{ || "+ aFields[nContFlds][1] + " }") )
    EndIf
    
    aColumns[Len(aColumns)]:SetTitle( aFields[nContFlds][2] )
    aColumns[Len(aColumns)]:SetSize( GetSx3Cache(aFields[nContFlds][1], "X3_TAMANHO") )
    aColumns[Len(aColumns)]:SetType( GetSx3Cache(aFields[nContFlds][1], "X3_TIPO") )

    aColumns[Len(aColumns)]:SetID( aFields[nContFlds] )

	//aColumns[Len(aColumns)]:SetSize(aStruct[nCampo][3])
	//aColumns[Len(aColumns)]:SetDecimal(aStruct[nCampo][4])
	aColumns[Len(aColumns)]:SetPicture(PesqPict("CT1", aFields[nContFlds][1]))

Next nContFlds

// Define filtro para seleção
cFiltro := ""

//Configuração de opções
oMark:SetMenuDef( "" )
oMark:SetWalkThru( .F. )
oMark:SetAmbiente( .F. )

oMark:AddButton("Bloquear",bBloqueia)
oMark:AddButton("Sair",bCancel)

// Define quais campos serão mostrados na seleção
//oMark:SetOnlyFields( { 'CT1_CONTA','CT1_DESC01','CT1_DTBLIN','CT1_DTBLFI','CT1_BLOQ'} )

// Define a titulo do browse de marcacao
oMark:SetDescription("Selecione as contas para bloquear")


oMark:SetColumns( aColumns )
//oMark:SetDataQuery( )
//oMark:SetQuery( cQuery)
//oMark:SetDataTable(.T.)
oMark:SetAlias( cAlias )

// Define o campo que sera utilizado para a marcação
oMark:SetFieldMark( 'CT1_OK' )

// Define as legendas
//oMark:AddLegend( "CT1_BLOQ == '1' .OR.  STOD(CT1_DTBLFI) >= dDataBase" , "RED"   ,"Bloqueado")
//oMark:AddLegend( "CT1_BLOQ == '2' .AND. STOD(CT1_DTBLFI) < dDataBase"  , "GREEN" ,"Não bloqueado")
	
// Definição do filtro de aplicacao
//oMark:SetFilterDefault(cFiltro)

// Bloco de marcação
//oMark:bMark	:= {|| CT05Mrk(oMark,cAlias),oMark:Refresh(.F.)}


//Code-Block executado após a marcação ou desmarcação do registro
//oMark:SetAfterMark({|| CT05Mrk(oMark,cAlias)})

//oMark:SetValid({|| CT05Mrk(oMark,cAlias)})
// Pesquisar
//oMark:SetSeek(.T., aPesq)

// Ativacao da classe
oMark:Activate()
	
// Ativação do container
oDlg:Activate()

//Fecha e apaga a tabela
oTempTable:Delete()

Return Nil


//------------------------------------------------------------------------------------------
/* {Protheus.doc} CTBA05Blq
Identifica os registros selecionados no markbrowser

@author    Marcos Bispo Abrahão
@version   12.1.25
@since     31/08/2020
@protected
*/
//------------------------------------------------------------------------------------------

Static Function CTBA05Blq(oMark,cAlias)

Local cMarca	:= oMark:Mark()
Local lRet		:= .T.


If BkCT05Par()
    lRet := .T.
    dbSelectArea(cAlias)

    // Percorre todas as contas e verifica qual foi selecionada
    While !(cAlias)->( EOF())
        If oMark:IsMark(cMarca) 
            dbSelectArea("CT1")
            dbGoTo((cAlias)->CT1RECNO)
            RecLock("CT1",.F.)
            CT1->CT1_DTBLIN := dDataI
            CT1->CT1_DTBLFI := dDataF
            CT1->(MsUnlock())
            dbSelectArea(cAlias)
        EndIf
        (cAlias)->( DbSkip() )
    Enddo
Else
    lRet := .F.
Endif

// Preenche o menu novamente
//aRotina := MenuDef()

Return(lRet)


Static Function BkCT05Par
Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,@cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cPerg,.T.         ,.T.))
	lRet       := .T.
	dDataI     := mv_par01
	dDataF     := mv_par02
Endif
Return lRet



Static Function CT05Mrk( oMark As Object, cAlias As Character ) As Logical
	Local cMarca    As Character
    Local cContas   As Character

	DbSelectArea( cAlias )

	cMarca  := oMark:Mark()
    cContas := ALLTRIM((cAlias)->CT1_CONTA)

	//(cArqTrb)->( DbGoTop() )

    If (cAlias)->CT1_CLASSE = "2"

        //oMark:MarkRec()
        If (cAlias)->CT1_OK == cMarca
            (cAlias)->CT1_OK := " "
        Else
            (cAlias)->CT1_OK := cMarca
        EndIf

    Else

    	While !(cAlias)->( Eof() )

            If Substr((cAlias)->CT1_CONTA,1,LEN(cContas)) == cContas
                If (cAlias)->CT1_CLASSE = "2"
                    RecLock( cAlias, .F. )

                    If (cAlias)->CT1_OK == cMarca
                        (cAlias)->CT1_OK := " "
                    Else
                        (cAlias)->CT1_OK := cMarca
                    EndIf

                    MsUnlock()
                EndIf
            Else
                Exit
            EndIf

            (cAlias)->(DbSkip())
            oMark:GoDown(1)
        EndDo
    EndIf

	oMark:Refresh(.F.)

	Return .T.



Static Function TempTbl(cAlias) as object
Local oTempTable as object
Local aStruct as array
Local cQuery as char
Local cFields as char
Local nLoop as numeric

aStruct    := {}

Aadd( aStruct, { 'CT1_OK',		'C', 02,00 } )
Aadd( aStruct, { 'CT1_CONTA',	'C', TamSx3("CT1_CONTA")[1],00 } )
Aadd( aStruct, { 'CT1_DESC01',	'C', TamSx3("CT1_DESC01")[1],00 } )
Aadd( aStruct, { 'CT1_DTBLIN',	'C', TamSx3("CT1_DTBLIN")[1],00 } )
Aadd( aStruct, { 'CT1_DTBLFI', 	'C', TamSx3("CT1_DTBLFI")[1],00 } )
Aadd( aStruct, { 'CT1_CLASSE', 	'C', TamSx3("CT1_CLASSE")[1],00 } )
Aadd( aStruct, { 'CT1_BLOQ', 	'C', TamSx3("CT1_BLOQ")[1],00 } )
//Aadd( aStruct, { 'CT1_BLOQ', 	'C', TamSx3("CT1_BLOQ")[1],00 } )

//Criação da tabela temporária com uma estrutura igual a do Protheus
oTempTable := FWTemporaryTable():New(cAlias)
oTempTable:SetFields(aStruct)
oTempTable:Create()

cFields := ""

//Pega todos os campos para efetuar a cópia dos dados
for nLoop := 2 to Len(aStruct)
    cFields += aStruct[nLoop][1] + ","//Nome do campo
next

cFields := Left(cFields, Len(cFields) -1) //Remover a ultima vírgula

//Criação do insert into
cQuery := "INSERT INTO " + oTempTable:GetRealName()
cQuery += " ( CT1_OK," + cFields + ") "
cQuery += "SELECT ' ' AS CT1_OK," + cFields
cQuery += " FROM " + RetSqlName("CT1") + " WHERE D_E_L_E_T_ = ' ' ORDER BY CT1_CONTA"

//Envia o insert into para o banco de dados, portanto toda a cópia é feita pelo banco de dados, com grande performance!
if TCSqlExec(cQuery) < 0
    u_xxConOut("ERROR",cPerg,"O comando SQL gerou erro:", TCSqlError())
endif

return oTempTable
