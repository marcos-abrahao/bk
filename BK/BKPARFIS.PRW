#include "Protheus.ch"       

/*/{Protheus.doc} BKPARFIS
BK - Atualização do Parâmetro MV_DATAFIS
@Return
@author Marcos Bispo Abrahão
@since  11/10/12 Frefer
@version P12
/*/

User Function BKPARFIS()
Local odParF As Object
Local oDlg1  As Object
Local aGrp   := UsrRetGrp()
Local lOk    := .F.
Local nI     := 0
Local aDatas := {}

Private cMvPar := "MV_DATAFIS"
Private dParF
Private cTexto :=""
Private cProg  := "BKPARFIS"
Private cEmpAtual := cEmpAnt
Private cFilAtual := cFilAnt

For nI := 1 TO Len(aGrp)
    //             Admin /Contab/Fiscal
	If aGrp[nI] $ "000000/000029/000031"
        lOk := .T.
        Exit 
	EndIf
Next

If !lOk
    u_MsgLog(cProg,"Acesso não permitido para este usuário!","E")
    Return Nil 
EndIf

aDatas := ListaPar()

dParF  := STOD(aDatas[1,3])  //GETMV(cMvPar)

DEFINE MSDIALOG oDlg1 TITLE "BKPARFIS - Data limite Fiscal" FROM 200,001 TO 330,470 PIXEL

@ 12,040 SAY "Data limite (MV_DATAFIS):" Size 080,010 Pixel OF oDlg1
@ 10,120 MSGET odParF VAR dParF Size 60,010 HASBUTTON Pixel OF oDlg1

SButton():New( 40, 080,  1, {|| oDlg1:End(),BrwEmp(aDatas,dParF) },oDlg1,.T.,"Atualiza os parâmetros")
SButton():New( 40, 120,  2, {|| oDlg1:End() },oDlg1,.T.,"Cancela")

ACTIVATE DIALOG oDlg1 CENTER

Return Nil


Static Function BrwEmp(aDatas,dParF)
Local nI      := 0
Local aDados  := {}
Local aCampos := {{ "MARCA"     , "C", 02, 0, "Marca"           ,"@!", .F., "" },;
				  { "EMPRESA"   , "C", 02, 0, "Empresa"         ,"@!", .T., "" },;
				  { "NOMEMPRESA", "C", 20, 0, "Nome"            ,"@!", .T., "" },;
				  { "DATAFECH"  , "D", 08, 0, "Data Fechamento" ,"@E", .T., "" },;
				  { "DATANOVA"  , "D", 08, 0, "Alterar para:"   ,"@E", .T., "" } }

For nI := 1 To Len(aDatas)
    aAdd(aDados,{"X",aDatas[nI,1],aDatas[nI,2],STOD(aDatas[nI,3]),dParF})
Next

u_TTMARKB(aCampos, aDados, .F.)

u_WaitLog(cProg, {|| OkPar1(aDados)})

Return Nil



Static Function OkPar1(aDados)
//Local oDlg as Object
Local nI          := 0
//Local cMask       := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local cAnexo       := ""
Local cTabela     := ""
Local cQuery      := ""
Local cTexto1     := ""
Local cProg       := "BKPARFIS"

cTexto += Replicate( "-", 77 ) + CRLF
cTexto += " Data / Hora Inicial.: " + DtoC( Date() ) + " / " + Time()  + " - "+cUserName+ CRLF
cTexto += Replicate( "-", 77 ) + CRLF

For nI := 1 TO LEN(aDados)
        
    cTabela := "SX6"+aDados[nI,2]+"0"

    cQuery := " UPDATE "+cTabela+" SET X6_CONTEUD = '"+DTOS(aDados[nI,5])+"'"+CRLF
    cQuery += "  WHERE X6_VAR = 'MV_DATAFIS' AND D_E_L_E_T_ = ' ' "+CRLF
    TcSqlExec(cQuery)

    cTexto1 := "Empresa: "+aDados[nI,2]+" - "+aDados[nI,3] + ": " 
    If !Empty(aDados[nI,1]) .AND. aDados[nI,4] <> aDados[nI,5]
        cTexto1 += "MV_DATAFIS alterada de "+DTOC(aDados[nI,4])+" para "+DTOC(aDados[nI,5])
    Else
        cTexto1 += "MV_DATAFIS mantida "+DTOC(aDados[nI,4])
    EndIf
    cTexto  += cTexto1 + CRLF

    //u_MsgLog(cProg,cTexto1)

Next

cTexto += Replicate( "-", 77 ) + CRLF
cTexto += " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time()  + CRLF
cTexto += Replicate( "-", 77 ) + CRLF

/*
Define Font oFont Name "Mono AS" Size 5, 12

Define MsDialog oDlg Title "Atualizacao concluida." From 3, 0 to 340, 417 Pixel

@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
oMemo:bRClicked := { || AllwaysTrue() }
oMemo:oFont     := oFont

Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

Activate MsDialog oDlg Center
*/
cAnexo := cProg+".html"
u_GrvAnexo(cAnexo,STRTRAN(cTexto,CRLF,"<br>"),.T.)

u_BkSnMail(cProg,"Alteração de Data de Fechamento Fiscal",u_GprEmail("",{},{u_GrpFisc()},{}),"",STRTRAN(cTexto,CRLF,"<br>"),{cAnexo},.T.)
u_MsgLog(cProg,DTOC(dParF),"",cTexto)

Return Nil



// SQL ARRAY
Static Function ListaPar()
Local cQuery        := ""
Local aReturn       := {}
Local aBinds        := {}
Local aSetFields    := {}
Local nRet          := 0
Local nI            := 0
Local aBkGrupo      := u_BKGrupo()
Local cTabela       := ""

For nI := 1 TO LEN(aBkGrupo)

    cTabela := "SX6"+aBkGrupo[nI,1]+"0"
    If nI <> 1
        cQuery += "UNION ALL "+CRLF
    EndIf
    cQuery += "SELECT '"+aBkGrupo[nI,1]+"' AS EMPRESA,"+CRLF 
    cQuery += "  '"+aBkGrupo[nI,2]+"' AS NOMEMPRESA,"+CRLF
    cQuery += "  SUBSTRING(X6_CONTEUD,1,8) AS DATAFIS "+CRLF
    cQuery += " FROM "+cTabela+CRLF
    cQuery += " WHERE X6_VAR = 'MV_DATAFIS' AND D_E_L_E_T_ = ' ' "+CRLF

Next 

//aadd(aBinds,xFilial("SA1")) // Filial
//aadd(aBinds,"000281") // Codigo
//aadd(aBinds,"01") // Loja

// Ajustes de tratamento de retorno
aadd(aSetFields,{"EMPRESA"   ,"C",2,0})
aadd(aSetFields,{"NOMEMPRESA","C",20,0})
aadd(aSetFields,{"DATAFIS"   ,"C",8,0})
//aadd(aSetFields,{"A1_ULTVIS","D",8,0})

nRet := TCSqlToArr(cQuery,@aReturn,aBinds,aSetFields)

If nRet < 0
  u_MsgLog("ListaPar",tcsqlerror()+" - Falha ao executar a Query: "+cQuery,"E")
Endif

Return aReturn
