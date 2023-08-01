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

Local dAux      := dDataBase

Private cPerg	:= "PRODESPA"
Private cTitulo := "Tabela Prodesp - Atualizar"
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

Return Nil


Static Function ProcQuery()
Local cQuery := ""

BEGINCONTENT VAR cQuery

WITH ATUALIZAR AS (

-- Planilha importarColaboradorAtualizar.xlsx
-- Para o Mes #MESATUAL#

SELECT

fun.nomfun AS [Nome],
fun.numcad AS [Matricula],
fun.numpis AS [PIS],

STUFF(STUFF(STUFF(CONVERT(VARCHAR(11), right('00000' + cast(fun.numcpf AS varchar(11)), 11)), 10, 0, '-'), 7, 0, '.'), 4, 0, '.') AS [CPF],

' ' AS [Nada],
fun.numpsp AS [Passaporte],
Convert(varchar(10), fun.datnas, 103) AS [Nascimento],
CASE
    WHEN fun.tipsex = 'M' THEN 'MASCULINO'
    WHEN fun.tipsex = 'F' THEN 'FEMININO'
    ELSE ''
END AS [Sexo],
--REPLACE(fun.valsal, '.', ',') AS [Salario] ,
fun.valsal AS [Salario] ,
CASE
    WHEN car.TitCar = 'Atendente I' THEN 'NÃO'
    WHEN car.TitCar = 'Atendente IV' THEN 'NÃO'
    WHEN car.TitCar = 'Atendente V' THEN 'NÃO' 
    ELSE 'SIM'
END AS [Refeicao],
'FIXO' AS [Prestador],
car.TitCar AS [Cargo],
Convert(varchar(10), fun.datadm, 103) AS [Admissao],
Convert(varchar(10), fun.datadm, 103) AS [Inicio],
 CASE 
    WHEN DATEPART(year,fun.datafa) < 1980 THEN 'Ativo' 
    ELSE Convert(varchar(10), fun.datafa, 103) 
    END AS [Termino], 

'Empregado' AS [Classif],
(SELECT TOP 1 NumLoc
    FROM [bk_senior].[bk_senior].[r038HLO] hlo WHERE hlo.NumCad = fun.numcad and hlo.numemp = 15
	and CAST(YEAR(hlo.DatAlt) AS VARCHAR(4)) + REPLACE(STR(MONTH(hlo.DatAlt),2),' ','0') <= '#MESATUAL#'
	order by DatAlt desc) AS [NumLoc],
	
-- fun.numloc AS numloc1,
 fun.numloc AS numloc1,
 orn.NomLoc AS NomLoc,

CASE
    WHEN car.TitCar = 'Auxiliar de Limpeza' THEN 'INSALUBRILIDADE'
    WHEN car.TitCar = 'MANTENEDOR MANUTENCISTA' THEN 'PERICULOSIDADE'
    ELSE 'NÃO'
END AS [Riscos],
'' AS [Obs],
CASE
    WHEN nac.DesNac = 'Brasileiro' THEN 'NÃO'
    WHEN nac.DesNac = 'Brasileira' THEN 'NÃO'
               
    ELSE 'SIM'
END AS [Estrangeiro],

(SELECT TOP 1 sitafa FROM [bk_senior].[bk_senior].[R038AFA] afa
	   WHERE afa.numemp = 15 AND tipcol = 1 AND afa.numcad = fun.numcad
       and CAST(YEAR(afa.DatAfa) AS VARCHAR(4)) + REPLACE(STR(MONTH(afa.DatAfa),2),' ','0') < '#MESATUAL#'
	   order by DatAfa desc) AS Sitafa,
fun.sitafa AS Sitafafun,
LOWER(cpl.emapar) AS [Email]

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

where 	fun.tipcol = 1  
		and fun.numemp in (15) 
		and CAST(YEAR(fun.datadm) AS VARCHAR(4)) + REPLACE(STR(MONTH(fun.datadm),2),' ','0') < '#MESATUAL#'
)
SELECT 
[Nome],
[Matricula],
[PIS],
[CPF],
[Nada],
[Passaporte],
[Nascimento],
[Sexo],
[Salario],
[Refeicao],
[Prestador],
[Cargo],
[Admissao],
[Inicio],
[Termino],
[Classif],
CASE 
	WHEN [NumLoc] = 2924 OR [numloc1] = 2924 THEN 'Campinas Digital - 4.0'
	WHEN [NumLoc] = 2700 OR [numloc1] = 2700 THEN 'Aguaí'
	WHEN [NumLoc] = 2692 OR [numloc1] = 2692 THEN 'Americana'
	WHEN [NumLoc] = 2898 OR [numloc1] = 2898 THEN 'Amparo - 4.0'
	WHEN [NumLoc] = 2693 OR [numloc1] = 2693 THEN 'Araras'
	WHEN [NumLoc] = 2896 OR [numloc1] = 2896 THEN 'Artur Nogueira - 4.0'
	WHEN [NumLoc] = 2712 OR [numloc1] = 2712 THEN 'Atibaia - 4.0'
	WHEN [NumLoc] = 3057 OR [numloc1] = 3057 THEN 'Bom Jesus dos Perdões - 4.0'
	WHEN [NumLoc] = 2691 OR [numloc1] = 2691 THEN 'Bragança Paulista'
	WHEN [NumLoc] = 2923 OR [numloc1] = 2923 THEN 'Cabreúva - 4.0'
	WHEN [NumLoc] = 2711 OR [numloc1] = 2711 THEN 'Campinas Shopping'
	WHEN [NumLoc] = 3002 OR [numloc1] = 3002 THEN 'Campo Limpo Paulista - 4.0'
	WHEN [NumLoc] = 2925 OR [numloc1] = 2925 THEN 'Capivari - 4.0'
	WHEN [NumLoc] = 3061 OR [numloc1] = 3061 THEN 'Conchal - 4.0'
	WHEN [NumLoc] = 2951 OR [numloc1] = 2951 THEN 'Cordeirópolis - 4.0'
	WHEN [NumLoc] = 2984 OR [numloc1] = 2984 THEN 'Cosmópolis - 4.0'
	WHEN [NumLoc] = 2926 OR [numloc1] = 2926 THEN 'Espírito Santo do Pinhal - 4.0'
	WHEN [NumLoc] = 2706 OR [numloc1] = 2706 THEN 'Hortolândia - 4.0'
	WHEN [NumLoc] = 2688 OR [numloc1] = 2688 THEN 'Indaiatuba'
	WHEN [NumLoc] = 2986 OR [numloc1] = 2986 THEN 'Iracemápolis - 4.0'
	WHEN [NumLoc] = 2878 OR [numloc1] = 2878 THEN 'Itapira - 4.0'
	WHEN [NumLoc] = 2879 OR [numloc1] = 2879 THEN 'Itatiba - 4.0'
	WHEN [NumLoc] = 3003 OR [numloc1] = 3003 THEN 'Itirapina - 4.0'
	WHEN [NumLoc] = 2927 OR [numloc1] = 2927 THEN 'Jaguariúna 4.0'
	WHEN [NumLoc] = 2932 OR [numloc1] = 2932 THEN 'Jarinu - 4.0'
	WHEN [NumLoc] = 2690 OR [numloc1] = 2690 THEN 'Jundiaí'
	WHEN [NumLoc] = 2696 OR [numloc1] = 2696 THEN 'Limeira'
	WHEN [NumLoc] = 3006 OR [numloc1] = 3006 THEN 'Louveira - 4.0'
	WHEN [NumLoc] = 2814 OR [numloc1] = 2814 THEN 'Mococa - 4.0'
	WHEN [NumLoc] = 2695 OR [numloc1] = 2695 THEN 'Mogi Guaçu'
	WHEN [NumLoc] = 2928 OR [numloc1] = 2928 THEN 'Mogi Mirim - 4.0'
	WHEN [NumLoc] = 2922 OR [numloc1] = 2922 THEN 'Monte Mor - 4.0'
	WHEN [NumLoc] = 3008 OR [numloc1] = 3008 THEN 'Nazaré Paulista - 4.0'
	WHEN [NumLoc] = 2897 OR [numloc1] = 2897 THEN 'Paulínia - 4.0'
	WHEN [NumLoc] = 2929 OR [numloc1] = 2929 THEN 'Pedreira - 40'
	WHEN [NumLoc] = 2689 OR [numloc1] = 2689 THEN 'Piracicaba'
	WHEN [NumLoc] = 2999 OR [numloc1] = 2999 THEN 'Pirassununga - 4.0'
	WHEN [NumLoc] = 2710 OR [numloc1] = 2710 THEN 'Rio Claro'
	WHEN [NumLoc] = 3005 OR [numloc1] = 3005 THEN 'Rio das Pedras - 4.0'
	WHEN [NumLoc] = 2708 OR [numloc1] = 2708 THEN 'Santa Bárbara do Oeste - 4.0'
	WHEN [NumLoc] = 2985 OR [numloc1] = 2985 THEN 'Santa Cruz das Palmeiras - 4.0'
	WHEN [NumLoc] = 2934 OR [numloc1] = 2934 THEN 'Santa Gertrudes - 4.0'
	WHEN [NumLoc] = 2930 OR [numloc1] = 2930 THEN 'Santo Antônio de Posse - 4.0'
	WHEN [NumLoc] = 2694 OR [numloc1] = 2694 THEN 'São João da Boa Vista'
	WHEN [NumLoc] = 3000 OR [numloc1] = 3000 THEN 'São José do Rio Pardo'
	WHEN [NumLoc] = 2931 OR [numloc1] = 2931 THEN 'São Pedro - 4.0'
	WHEN [NumLoc] = 2721 OR [numloc1] = 2721 THEN 'Serra Negra - 4.0'
	WHEN [NumLoc] = 3001 OR [numloc1] = 3001 THEN 'Socorro - 4.0'
	WHEN [NumLoc] = 2707 OR [numloc1] = 2707 THEN 'Sumaré - 4.0'
	WHEN [NumLoc] = 2987 OR [numloc1] = 2987 THEN 'Tambaú - 4.0'
	WHEN [NumLoc] = 2921 OR [numloc1] = 2921 THEN 'Valinhos - 4.0'
	WHEN [NumLoc] = 2880 OR [numloc1] = 2880 THEN 'Vargem Grande do Sul - 4.0'
	WHEN [NumLoc] = 2904 OR [numloc1] = 2904 THEN 'Várzea Paulista - 4.0'
	WHEN [NumLoc] = 3004 OR [numloc1] = 3004 THEN 'Vinhedo - 4.0'
	WHEN [NumLoc] = 2686 OR [numloc1] = 2686 THEN 'Poupatempo_Lote 3'
	WHEN [NumLoc] = 1888 OR [numloc1] = 1888 THEN 'São João da Boa Vista'
	ELSE [NomLoc]
END AS [LocalS],
[Riscos],
[Obs],
[Estrangeiro],
CASE 
 WHEN Sitafa =  2 THEN 'SIM' ELSE 'NÃO' END AS [Ferias],
[Email]

FROM ATUALIZAR
WHERE 
(Sitafa is null or Sitafa <> 7)
ORDER BY [Nome],[Matricula]

ENDCONTENT

cQuery := STRTRAN(cQuery,"#MESATUAL#",cMesAtu)
cQuery := STRTRAN(cQuery,"#MESANTERIOR#",cMesAnt)

//cQuery := ChangeQuery(cQuery)

u_LogMemo("PRODESPA.SQL",cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)

u_LogMemo("PRODESPA.SQL",cQuery)

//tcSetField("TMP","D1_DTDIGIT","D",8,0)
//tcSetField("TMP","D1_XXHIST","M",10,0)

Return NIL


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

aAdd(aCampos,"TMP->Nada")
aAdd(aCabs  ,"")

aAdd(aCampos,"TMP->Passaporte")
aAdd(aCabs  ,"Passaporte")

aAdd(aCampos,"TMP->Nascimento")
aAdd(aCabs  ,"Nascimento")

aAdd(aCampos,"TMP->Sexo")
aAdd(aCabs  ,"Sexo")

aAdd(aCampos,"TMP->Salario")
aAdd(aCabs  ,"Salario")

aAdd(aCampos,"TMP->Refeicao")
aAdd(aCabs  ,"Refeicao")

aAdd(aCampos,"TMP->Prestador")
aAdd(aCabs  ,"Prestador")

aAdd(aCampos,"TMP->Cargo")
aAdd(aCabs  ,"Cargo")

aAdd(aCampos,"TMP->Admissao")
aAdd(aCabs  ,"Admissao")

aAdd(aCampos,"TMP->Inicio")
aAdd(aCabs  ,"Inicio")

aAdd(aCampos,"TMP->Termino")
aAdd(aCabs  ,"Termino")

aAdd(aCampos,"TMP->Classif")
aAdd(aCabs  ,"Classificação")

aAdd(aCampos,"TMP->LocalS")
aAdd(aCabs  ,"Local de Serviços")

aAdd(aCampos,"TMP->Riscos")
aAdd(aCabs  ,"Riscos")

aAdd(aCampos,"TMP->Obs")
aAdd(aCabs  ,"Observação")

aAdd(aCampos,"TMP->Estrangeiro")
aAdd(aCabs  ,"Estrangeiro")

aAdd(aCampos,"TMP->Ferias")
aAdd(aCabs  ,"Férias")

aAdd(aCampos,"TMP->Email")
aAdd(aCabs  ,"Email")
 
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


