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

Local dMesAnt := MonthSub(dDataBase,2)
Local dMesAtu := MonthSub(dDataBase,1)
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""

Private cMesAtu := STR(YEAR(dMesAtu),4)+STRZERO(Month(dMesAtu),2)
Private cMesAnt := STR(YEAR(dMesAnt),4)+STRZERO(Month(dMesAnt),2)

BEGINCONTENT VAR cQuery

-- Planilha importarColaboradorExcluir.xlsx
-- Para o Mes #MESATUAL#
SELECT
--fun.numemp as [Empresa],
'#MESATUAL#' AS COMPETAM,
fun.nomfun as [Nome Completo do Funcionario],
fun.numcad as [Matrícula],
fun.numpis as [PIS NIT],
STUFF(STUFF(STUFF(CONVERT(VARCHAR(11), right('00000' + cast(fun.numcpf as varchar(11)), 11)), 10, 0, '-'), 7, 0, '.'), 4, 0, '.') as [CPF],

Convert(varchar(10), fun.datadm, 103) as [Data Admissão],
Convert(varchar(10), fun.datafa, 103) as [Data de Saída],
cau.DesDem as [Motivo da Saída], --fun.caudem,fun.sitafa
' ' as [OBSERVAÇÕES]

INTO PowerBk.dbo.PRODESPEXCLUIR

from bk_senior.bk_senior.r034fun fun
LEFT JOIN  bk_senior.bk_senior.R042CAU cau 
	ON fun.caudem  = cau.caudem
where  fun.tipcol = 1  and fun.numemp in (15) --and sitafa = 7
--and YEAR(fun.datafa) = 2023 and MONTH(fun.datafa) = 2
AND CAST(YEAR(fun.datafa) AS VARCHAR(4)) + REPLACE(STR(MONTH(fun.datafa),2),' ','0') = '#MESATUAL#'

--and fun.numloc = 2711
--and fun.numcad = 1007

order by fun.nomfun, fun.numcad

ENDCONTENT

cQuery := STRTRAN(cQuery,"#MESATUAL#",cMesAtu)
cQuery := STRTRAN(cQuery,"#MESANTERIOR#",cMesAnt)

u_LogMemo("PRODESPEXCLUIR.SQL",cQuery)

If !TCIsConnected() 
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.PRODESPEXCLUIR', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.PRODESPEXCLUIR "+CRLF
nErro   := TcSqlExec(cQueryD)

If nErro != 0
	cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	u_MsgLog(cPerg,cErro1,"E")
EndIf

nErro   := TcSqlExec(cQuery)

If nErro != 0
	cErro2  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	u_MsgLog(cPerg,cErro2,"E")
EndIf

u_LogMemo("PRODESPEXCLUIR.SQL",cErro1+cQueryD+cErro2+cQuery)

Return
