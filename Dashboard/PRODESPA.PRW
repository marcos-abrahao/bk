#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} PRODESPA
BK - Atualização da tabela PRODESPA (Atualizar) no Banco de dados PowerBk

@Return
@author Marcos Bispo Abrahão
@since 02/04/2023
@version 1.0
/*/

User Function PRODESPA()

Local dMesAnt := MonthSub(dDataBase,2)
Local dMesAtu := MonthSub(dDataBase,1)
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local lExistTbl := .F.

lExistTbl := u_ExitTbl("PowerBk.dbo.PRODESPATUALIZAR")

Private cMesAtu := STR(YEAR(dMesAtu),4)+STRZERO(Month(dMesAtu),2)
Private cMesAnt := STR(YEAR(dMesAnt),4)+STRZERO(Month(dMesAnt),2)

BEGINCONTENT VAR cQuery

-- Planilha importarColaboradorAtualizar.xlsx
-- Para o Mes #MESATUAL#

WITH ATUALIZAR AS (
SELECT
--fun.numemp as [Empresa],
fun.nomfun as [Nome Completo do Funcionario],
fun.numcad as [Matrícula],
fun.numpis as [PIS NIT],

STUFF(STUFF(STUFF(CONVERT(VARCHAR(11), right('00000' + cast(fun.numcpf as varchar(11)), 11)), 10, 0, '-'), 7, 0, '.'), 4, 0, '.') as [CPF],

' ' as [Nada],
fun.numpsp as [PASSAPORTE],
Convert(varchar(10), fun.datnas, 103) as [Nascimento],
CASE
    WHEN fun.tipsex = 'M' THEN 'MASCULINO'
    WHEN fun.tipsex = 'F' THEN 'FEMININO'
               
    ELSE ''
END as [Sexo],
REPLACE(fun.valsal, '.', ',') AS [Salario Base] ,
CASE
    WHEN car.TitCar = 'Atendente I' THEN 'NÃO'
    WHEN car.TitCar = 'Atendente IV' THEN 'NÃO'
    WHEN car.TitCar = 'Atendente V' THEN 'NÃO' 
    ELSE 'SIM'
	end as [refeição custeada],
'FIXO' as [Tipo de Prestador],
car.TitCar as [Cargo],
Convert(varchar(10), fun.datadm, 103) as [Data Admissão],
Convert(varchar(10), fun.datadm, 103) as [Data de Inicio de Serviço],
 CASE 
    WHEN DATEPART(year,fun.datafa) < 1980 THEN 'Ativo' 
    ELSE Convert(varchar(10), fun.datafa, 103) 
    END AS [Data de Termino de contrato], 

'Empregado' as [Classificação],
(SELECT TOP 1 NumLoc
    FROM [bk_senior].[bk_senior].[r038HLO] hlo WHERE hlo.NumCad = fun.numcad and hlo.numemp = 15
	and ( YEAR(hlo.DatAlt) <> 2023 or MONTH(hlo.DatAlt) < 3)
	order by DatAlt desc) AS [NumLoc],
	
-- fun.numloc as numloc1,

CASE
    WHEN car.TitCar = 'Auxiliar de Limpeza' THEN 'INSALUBRILIDADE'
    WHEN car.TitCar = 'MANTENEDOR MANUTENCISTA' THEN 'PERICULOSIDADE'
    ELSE 'NÃO'
	end as [Exposição de Riscos],
'' as [observação],
CASE
    WHEN nac.DesNac = 'Brasileiro' THEN 'NÃO'
    WHEN nac.DesNac = 'Brasileira' THEN 'NÃO'
               
    ELSE 'SIM'
END as [Estrangeiro],

--(SELECT TOP 1 sitafa FROM [bk_senior].[bk_senior].[R038AFA] afa
--	   WHERE afa.numemp = 15 AND tipcol = 1 AND afa.numcad = fun.numcad AND SitAfa = 7
--       and CAST(YEAR(afa.DatAfa) AS VARCHAR(4)) + REPLACE(STR(MONTH(afa.DatAfa),2),' ','0') < '#MESATUAL#'
--	   order by DatAfa desc) as demitido,

(SELECT TOP 1 sitafa FROM [bk_senior].[bk_senior].[R038AFA] afa
	   WHERE afa.numemp = 15 AND tipcol = 1 AND afa.numcad = fun.numcad
       and CAST(YEAR(afa.DatAfa) AS VARCHAR(4)) + REPLACE(STR(MONTH(afa.DatAfa),2),' ','0') < '#MESATUAL#'
	   order by DatAfa desc) as sitafa,
fun.sitafa as sitafafun,
LOWER(cpl.emapar) as [Email]

from bk_senior.bk_senior.r034fun fun
left join bk_senior.bk_senior.r034cpl cpl
on fun.numemp = cpl.numemp and fun.tipcol = cpl.tipcol and fun.numcad = cpl.numcad
left join bk_senior.bk_senior.r030emp emp
on fun.numemp = emp.numemp
left join bk_senior.bk_senior.r030fil fil
on fun.numemp = fil.numemp and fun.codfil = fil.codfil
left join bk_senior.bk_senior.r016orn orn
on fun.taborg = orn.TabOrg and fun.numloc = orn.NumLoc
left join bk_senior.bk_senior.r016hie hie
on fun.taborg = hie.TabOrg and fun.numloc = hie.NumLoc
and hie.DatIni = (select top 1 hie2.DatIni from bk_senior.bk_senior.r016hie hie2 where hie.taborg = hie2.TabOrg and hie.numloc = hie2.NumLoc order by hie2.DatIni desc)
left join bk_senior.bk_senior.r024car car
on fun.estcar = car.estcar and fun.codcar = car.codcar
left join bk_senior.bk_senior.r024cb2 cb2
on car.CodCb2 = cb2.CodCbo
left join bk_senior.bk_senior.r023nac nac
on fun.codnac = nac.CodNac
left join bk_senior.bk_senior.r074cid cid
on cpl.ccinas = cid.CodCid
left join bk_senior.bk_senior.r034mat mat
on fun.numemp = mat.numemp and fun.tipcol = mat.tipcol and fun.numcad = mat.numcad

where  fun.tipcol = 1  and fun.numemp in (15) --and fun.sitafa <> 7
--and (YEAR(fun.datadm) <> 2023 or MONTH(fun.datadm) < 2)
and CAST(YEAR(fun.datadm) AS VARCHAR(4)) + REPLACE(STR(MONTH(fun.datadm),2),' ','0') < '#MESATUAL#'

--order by fun.numemp, fun.numcad
)
#TABELAEXISTE# INSERT INTO PowerBk.dbo.PRODESPATUALIZAR
SELECT 
--sitafa,
--sitafafun,
--demitido,
'#MESATUAL#' AS COMPETAM,
[Nome Completo do Funcionario],
[Matrícula],
[PIS NIT],
[CPF],
[Nada],
[PASSAPORTE],
[Nascimento],
[Sexo],
[Salario Base],
[refeição custeada],
[Tipo de Prestador],
[Cargo],
[Data Admissão],
[Data de Inicio de Serviço],
[Data de Termino de contrato],
[Classificação],
CASE 
	WHEN [NumLoc] = 2924 THEN 'Campinas Digital - 4.0'
	WHEN [NumLoc] = 2700 THEN 'Aguaí'
	WHEN [NumLoc] = 2692 THEN 'Americana'
	WHEN [NumLoc] = 2898 THEN 'Amparo - 4.0'
	WHEN [NumLoc] = 2693 THEN 'Araras'
	WHEN [NumLoc] = 2896 THEN 'Artur Nogueira - 4.0'
	WHEN [NumLoc] = 2712 THEN 'Atibaia - 4.0'
	WHEN [NumLoc] = 3057 THEN 'Bom Jesus dos Perdões - 4.0'
	WHEN [NumLoc] = 2691 THEN 'Bragança Paulista'
	WHEN [NumLoc] = 2923 THEN 'Cabreúva - 4.0'
	WHEN [NumLoc] = 2711 THEN 'Campinas Shopping'
	WHEN [NumLoc] = 3002 THEN 'Campo Limpo Paulista - 4.0'
	WHEN [NumLoc] = 2925 THEN 'Capivari - 4.0'
	WHEN [NumLoc] = 3061 THEN 'Conchal - 4.0'
	WHEN [NumLoc] = 2951 THEN 'Cordeirópolis - 4.0'
	WHEN [NumLoc] = 2984 THEN 'Cosmópolis - 4.0'
	WHEN [NumLoc] = 2926 THEN 'Espírito Santo do Pinhal - 4.0'
	WHEN [NumLoc] = 2706 THEN 'Hortolândia - 4.0'
	WHEN [NumLoc] = 2688 THEN 'Indaiatuba'
	WHEN [NumLoc] = 2986 THEN 'Iracemápolis - 4.0'
	WHEN [NumLoc] = 2878 THEN 'Itapira - 4.0'
	WHEN [NumLoc] = 2879 THEN 'Itatiba - 4.0'
	WHEN [NumLoc] = 3003 THEN 'Itirapina - 4.0'
	WHEN [NumLoc] = 2927 THEN 'Jaguariúna 4.0'
	WHEN [NumLoc] = 2932 THEN 'Jarinu - 4.0'
	WHEN [NumLoc] = 2690 THEN 'Jundiaí'
	WHEN [NumLoc] = 2696 THEN 'Limeira'
	WHEN [NumLoc] = 3006 THEN 'Louveira - 4.0'
	WHEN [NumLoc] = 2814 THEN 'Mococa - 4.0'
	WHEN [NumLoc] = 2695 THEN 'Mogi Guaçu'
	WHEN [NumLoc] = 2928 THEN 'Mogi Mirim - 4.0'
	WHEN [NumLoc] = 2922 THEN 'Monte Mor - 4.0'
	WHEN [NumLoc] = 3008 THEN 'Nazaré Paulista - 4.0'
	WHEN [NumLoc] = 2897 THEN 'Paulínia - 4.0'
	WHEN [NumLoc] = 2929 THEN 'Pedreira - 40'
	WHEN [NumLoc] = 2689 THEN 'Piracicaba'
	WHEN [NumLoc] = 2999 THEN 'Pirassununga - 4.0'
	WHEN [NumLoc] = 2710 THEN 'Rio Claro'
	WHEN [NumLoc] = 3005 THEN 'Rio das Pedras - 4.0'
	WHEN [NumLoc] = 2708 THEN 'Santa Bárbara do Oeste - 4.0'
	WHEN [NumLoc] = 2985 THEN 'Santa Cruz das Palmeiras - 4.0'
	WHEN [NumLoc] = 2934 THEN 'Santa Gertrudes - 4.0'
	WHEN [NumLoc] = 2930 THEN 'Santo Antônio de Posse - 4.0'
	WHEN [NumLoc] = 2694 THEN 'São João da Boa Vista'
	WHEN [NumLoc] = 3000 THEN 'São José do Rio Pardo'
	WHEN [NumLoc] = 2931 THEN 'São Pedro - 4.0'
	WHEN [NumLoc] = 2721 THEN 'Serra Negra - 4.0'
	WHEN [NumLoc] = 3001 THEN 'Socorro - 4.0'
	WHEN [NumLoc] = 2707 THEN 'Sumaré - 4.0'
	WHEN [NumLoc] = 2987 THEN 'Tambaú - 4.0'
	WHEN [NumLoc] = 2921 THEN 'Valinhos - 4.0'
	WHEN [NumLoc] = 2880 THEN 'Vargem Grande do Sul - 4.0'
	WHEN [NumLoc] = 2904 THEN 'Várzea Paulista - 4.0'
	WHEN [NumLoc] = 3004 THEN 'Vinhedo - 4.0'
	WHEN [NumLoc] = 2686 THEN 'Poupatempo_Lote 3'
	WHEN [NumLoc] = 1888 THEN 'São João da Boa Vista'
	ELSE ''
END AS [Local de Serviços],
[Exposição de Riscos],
[observação],
[Estrangeiro],
CASE 
 WHEN sitafa =  2 THEN 'SIM' ELSE 'NÃO' END AS [Férias],
[Email]
#TABELANAOEXISTE# INTO PowerBk.dbo.PRODESPATUALIZAR
FROM ATUALIZAR
WHERE 
(sitafa is null or sitafa <> 7)
-- and Numloc = 2711
--and [Matrícula] = 1007
ORDER BY [Nome Completo do Funcionario],[Matrícula]

ENDCONTENT

cQuery := STRTRAN(cQuery,"#MESATUAL#",cMesAtu)
cQuery := STRTRAN(cQuery,"#MESANTERIOR#",cMesAnt)
If lExistTbl
	cQuery := STRTRAN(cQuery,"#TABELAEXISTE#","")
	cQuery := STRTRAN(cQuery,"#TABELANAOEXISTE#","--")
Else
	cQuery := STRTRAN(cQuery,"#TABELAEXISTE#","--")
	cQuery := STRTRAN(cQuery,"#TABELANAOEXISTE#","")
EndIf

u_LogMemo("PRODESPATUALIZAR.SQL",cQuery)

If !TCIsConnected() 
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.PRODESPATUALIZAR', N'U') IS NOT NULL"  
cQueryD += "   --DROP TABLE PowerBk.dbo.PRODESPATUALIZAR "+CRLF
cQueryD += "   DELETE FROM PowerBk.dbo.PRODESPATUALIZAR WHERE COMPETAM = '#MESATUAL#'"+CRLF

cQueryd := STRTRAN(cQueryD,"#MESATUAL#",cMesAtu)

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

u_LogMemo("PRODESPATUALIZAR.SQL",cErro1+cQueryD+cErro2+cQuery)

Return
