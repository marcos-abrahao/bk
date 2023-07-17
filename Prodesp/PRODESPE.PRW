#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} PRODESPE
BK - Atualização da tabela PRODESPE (Excluir) no Banco de dados PowerBk

@Return
@author Marcos Bispo Abrahão
@since 02/04/2023
@version 1.0
/*/

User Function PRODESPE()

Local dAux      := dDataBase

Private cPerg	:= "PRODESPE"
Private cTitulo := "Tabela Prodesp - Excluir"
Private aParam	:=	{}
Private aRet	:=	{}

Private cMesAtu := ""
Private cMesAnt := ""
Private nMes    := Month(dDataBase)
Private nAno    := Year(dDataBase)

aAdd(aParam, {1,"Mes da Competência",nMes,"99"  ,"mv_par01 > 0 .AND. mv_par01 <= 12"  ,"","",20,.F.})
aAdd(aRet, nMes)

aAdd(aParam, {1,"Ano da Competência",nAno,"9999","mv_par02 >= 2023 .AND. mv_par02 <= 2040","","",20,.F.})
aAdd(aRet, nAno)

If !MyParam()
    Return
EndIf

cTitulo := cTitulo + " - Competência: "+STRZERO(nMes,2)+"/"+STRZERO(nAno,4)
dAux := STOD(STR(nAno,4)+STRZERO(nMes,2)+"01")
cMesAtu := STR(YEAR(dAux),4)+STRZERO(Month(dAux),2)

dAux := MonthSub(dAux,1)
cMesAnt := STR(YEAR(dAux),4)+STRZERO(Month(dAux),2)

u_WaitLog(cPerg, {|| ProcQuery() },"Processando dados...")

GeraPlan(cPerg,cTitulo)

Return NIL


Static Function ProcQuery()
Local cQuery := ""

BEGINCONTENT VAR cQuery

SELECT

-- Planilha importarColaboradorExcluir.xlsx
-- Para o Mes #MESATUAL#

fun.nomfun AS [Nome],
fun.numcad AS [Matricula],
fun.numpis AS [PIS],
STUFF(STUFF(STUFF(CONVERT(VARCHAR(11), right('00000' + cast(fun.numcpf AS varchar(11)), 11)), 10, 0, '-'), 7, 0, '.'), 4, 0, '.') AS [CPF],

Convert(varchar(10), fun.datadm, 103) AS [Admissao],
Convert(varchar(10), fun.datafa, 103) AS [Saida],
cau.DesDem AS [Motivo],
--fun.caudem,fun.sitafa
' ' AS [Obs]

from bk_senior.bk_senior.r034fun fun
LEFT JOIN  bk_senior.bk_senior.R042CAU cau 
	ON fun.caudem  = cau.caudem
where  fun.tipcol = 1  and fun.numemp in (15) and sitafa = 7
--and YEAR(fun.datafa) = 2023 and MONTH(fun.datafa) = 2
AND CAST(YEAR(fun.datafa) AS VARCHAR(4)) + REPLACE(STR(MONTH(fun.datafa),2),' ','0') = '#MESATUAL#'

order by fun.nomfun, fun.numcad

ENDCONTENT

cQuery := STRTRAN(cQuery,"#MESATUAL#",cMesAtu)
cQuery := STRTRAN(cQuery,"#MESANTERIOR#",cMesAnt)

//cQuery := ChangeQuery(cQuery)

u_LogMemo("PRODESPE.SQL",cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)

u_LogMemo("PRODESPE.SQL",cQuery)

Return


/*/{Protheus.doc} GeraPlan
	Exportar consulta para o Excel
	@type  Static Function
	@author Marcos Bispo Abrahão
	@since 17/07/23
	@version 12.1.33
/*/
Static Function GeraPlan(cPerg,cTitulo)
Local aCabs   := {}
Local aCampos := {}
Local aTitulos:= {}
Local aPlans  := {}
Local aFormula:= {}

AADD(aTitulos,cTitulo)

aAdd(aCampos,"TMP->Nome")
aAdd(aCabs  ,"Nome")

aAdd(aCampos,"STR(TMP->Matricula)")
aAdd(aCabs  ,"Matrícula")

aAdd(aCampos,"STR(TMP->PIS)")
aAdd(aCabs  ,"PIS")

aAdd(aCampos,"TMP->CPF")
aAdd(aCabs  ,"CPF")

aAdd(aCampos,"TMP->Admissao")
aAdd(aCabs  ,"Admissao")

aAdd(aCampos,"TMP->Saida")
aAdd(aCabs  ,"Saida")

aAdd(aCampos,"TMP->Motivo")
aAdd(aCabs  ,"Motivo")

aAdd(aCampos,"TMP->Obs")
aAdd(aCabs  ,"Observação")

AADD(aPlans,{"TMP",cPerg,"",aTitulos,aCampos,aCabs,/*aImpr1*/, aFormula,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })

U_PlanXlsx(aPlans,cTitulo,cPerg,.F.)
	
Return .T.



// Parametros da tela
Static Function MyParam
	Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
	If (Parambox(aParam     ,cPerg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cPerg      ,.T.         ,.T.))
		lRet    := .T.
		nMes 	:= mv_par01
		nAno  	:= mv_par02
	Endif
Return lRet


