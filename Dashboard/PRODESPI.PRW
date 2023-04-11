#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} PRODESPI
BK - Atualização da tabela PRODESPI (Inserir) no Banco de dados PowerBk

@Return
@author Marcos Bispo Abrahão
@since 02/04/2023
@version 1.0
/*/

User Function PRODESPI()

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

-- Planilha importarColaboradorInserir.xlsx
-- Para o Mes #MESATUAL#
WITH INSERIR as (
select
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
'(A)ADMISSÃO NA EMPRESA' as [Motivo Entrada],

CASE 
	WHEN fun.numloc = 2924 THEN 'Campinas Digital - 4.0'
	WHEN fun.numloc = 2700 THEN 'Aguaí'
	WHEN fun.numloc = 2692 THEN 'Americana'
	WHEN fun.numloc = 2898 THEN 'Amparo - 4.0'
	WHEN fun.numloc = 2693 THEN 'Araras'
	WHEN fun.numloc = 2896 THEN 'Artur Nogueira - 4.0'
	WHEN fun.numloc = 2712 THEN 'Atibaia - 4.0'
	WHEN fun.numloc = 3057 THEN 'Bom Jesus dos Perdões - 4.0'
	WHEN fun.numloc = 2691 THEN 'Bragança Paulista'
	WHEN fun.numloc = 2923 THEN 'Cabreúva - 4.0'
	WHEN fun.numloc = 2711 THEN 'Campinas Shopping'
	WHEN fun.numloc = 3002 THEN 'Campo Limpo Paulista - 4.0'
	WHEN fun.numloc = 2925 THEN 'Capivari - 4.0'
	WHEN fun.numloc = 2951 THEN 'Cordeirópolis - 4.0'
	WHEN fun.numloc = 2984 THEN 'Cosmópolis - 4.0'
	WHEN fun.numloc = 2926 THEN 'Espírito Santo do Pinhal - 4.0'
	WHEN fun.numloc = 2706 THEN 'Hortolândia - 4.0'
	WHEN fun.numloc = 2688 THEN 'Indaiatuba'
	WHEN fun.numloc = 2986 THEN 'Iracemápolis - 4.0'
	WHEN fun.numloc = 2878 THEN 'Itapira - 4.0'
	WHEN fun.numloc = 2879 THEN 'Itatiba - 4.0'
	WHEN fun.numloc = 3003 THEN 'Itirapina - 4.0'
	WHEN fun.numloc = 2927 THEN 'Jaguariúna 4.0'
	WHEN fun.numloc = 2932 THEN 'Jarinu - 4.0'
	WHEN fun.numloc = 2690 THEN 'Jundiaí'
	WHEN fun.numloc = 2696 THEN 'Limeira'
	WHEN fun.numloc = 3006 THEN 'Louveira - 4.0'
	WHEN fun.numloc = 2814 THEN 'Mococa - 4.0'
	WHEN fun.numloc = 2695 THEN 'Mogi Guaçu'
	WHEN fun.numloc = 2928 THEN 'Mogi Mirim - 4.0'
	WHEN fun.numloc = 2922 THEN 'Monte Mor - 4.0'
	WHEN fun.numloc = 3008 THEN 'Nazaré Paulista - 4.0'
	WHEN fun.numloc = 2897 THEN 'Paulínia - 4.0'
	WHEN fun.numloc = 2929 THEN 'Pedreira - 40'
	WHEN fun.numloc = 2689 THEN 'Piracicaba'
	WHEN fun.numloc = 2999 THEN 'Pirassununga - 4.0'
	WHEN fun.numloc = 2710 THEN 'Rio Claro'
	WHEN fun.numloc = 3005 THEN 'Rio das Pedras - 4.0'
	WHEN fun.numloc = 2708 THEN 'Santa Bárbara do Oeste - 4.0'
	WHEN fun.numloc = 2985 THEN 'Santa Cruz das Palmeiras - 4.0'
	WHEN fun.numloc = 2934 THEN 'Santa Gertrudes - 4.0'
	WHEN fun.numloc = 2930 THEN 'Santo Antônio de Posse - 4.0'
	WHEN fun.numloc = 2694 THEN 'São João da Boa Vista'
	WHEN fun.numloc = 3000 THEN 'São José do Rio Pardo'
	WHEN fun.numloc = 2931 THEN 'São Pedro - 4.0'
	WHEN fun.numloc = 2721 THEN 'Serra Negra - 4.0'
	WHEN fun.numloc = 3001 THEN 'Socorro - 4.0'
	WHEN fun.numloc = 2707 THEN 'Sumaré - 4.0'
	WHEN fun.numloc = 2987 THEN 'Tambaú - 4.0'
	WHEN fun.numloc = 2921 THEN 'Valinhos - 4.0'
	WHEN fun.numloc = 2880 THEN 'Vargem Grande do Sul - 4.0'
	WHEN fun.numloc = 2904 THEN 'Várzea Paulista - 4.0'
	WHEN fun.numloc = 3004 THEN 'Vinhedo - 4.0'
	WHEN fun.numloc = 2686 THEN 'Poupatempo_Lote 3'
	WHEN fun.numloc = 1888 THEN 'São João da Boa Vista'
	ELSE ''
END AS [Local de Serviços],

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
' ' as [Email],


(SELECT TOP 1 sitafa FROM [bk_senior].[bk_senior].[R038AFA] afa
	   WHERE afa.numemp = 15 AND tipcol = 1 AND afa.numcad = fun.numcad
       and CAST(YEAR(afa.DatAfa) AS VARCHAR(4)) + REPLACE(STR(MONTH(afa.DatAfa),2),' ','0') < '#MESATUAL#'
	   order by DatAfa desc) as sitafa

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
where  fun.tipcol = 1  and fun.numemp in (15)

--and fun.numloc = 2711
--and YEAR(fun.datadm) = 2023 and MONTH(fun.datadm) = 2
and CAST(YEAR(fun.datadm) AS VARCHAR(4)) + REPLACE(STR(MONTH(fun.datadm),2),' ','0') = '#MESANTERIOR#'
--and sitafa <> 7
--order by fun.nomfun
)
SELECT
'#MESATUAL#' AS COMPETAM,
[Nome Completo do Funcionario],
[Matrícula],
[PIS NIT],
[CPF],
[Nada],
[PASSAPORTE],
[Nascimento],
[Sexo],
[Salario Base] ,
[refeição custeada],
[Tipo de Prestador],
[Cargo],
[Data Admissão],
[Data de Inicio de Serviço],
[Data de Termino de contrato], 
[Classificação],
[Motivo Entrada],
[Local de Serviços],
[Exposição de Riscos],
[observação],
[Estrangeiro],
[Email]
INTO PowerBk.dbo.PRODESPINSERIR
FROM INSERIR

ENDCONTENT

cQuery := STRTRAN(cQuery,"#MESATUAL#",cMesAtu)
cQuery := STRTRAN(cQuery,"#MESANTERIOR#",cMesAnt)

u_LogMemo("PRODESPINSERIR.SQL",cQuery)

If !TCIsConnected() 
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.PRODESPINSERIR', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.PRODESPINSERIR "+CRLF
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

u_LogMemo("PRODESPINSERIR.SQL",cErro1+cQueryD+cErro2+cQuery)

Return
