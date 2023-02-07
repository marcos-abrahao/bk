#Include "TOTVS.ch"
#include "Protheus.ch"
#include "TopConn.ch"
#include "RwMake.ch"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} BKFATA07
BK - GERAR XML NOTA FISCAL DO MUNICIPIO DE São Sebastião do Passé-BA
@Return
@author Adilson do Prado
@since 05/10/22
@version P12.1.25
/*/

User Function BKFATA07()
Local aParam 	:= {}
Local aRet		:=	{}
Local cTitulo   :=  "Gerar XML da nota fiscal do municipio de São Sebastião do Passé-BA"

Private cNotaDe 	:= ""
Private cNotaAte 	:= ""
Private cSerie		:= ""
Private cDir		:= ""
Private cProg       := "BKFATA07"

aAdd( aParam, { 1, "Nota Fiscal de?"	, SPACE(TamSx3("F2_DOC")[1])	, ""            , "", "SF2"	, "" , 70  , .F. })
aAdd( aParam, { 1, "Nota Fiscal até?"	, SPACE(TamSx3("F2_DOC")[1])	, ""            , "", "SF2"	, "" , 70  , .F. })
aAdd( aParam, { 1, "Serie?"		, SPACE(TamSx3("F2_SERIE")[1])	, ""            , "", ""	, "" , 70  , .F. })
aAdd( aParam, { 1, 'Salvar em "Pasta"?'	, SPACE(200)	        , ""            , "", ""	, "" , 70  , .F. })


If (Parambox(aParam,"BKFATA07 - "+cTitulo,@aRet,,,.T.,,,,"BKFATA07",.T.,.T.))
	lRet := .T.
	cNotaDe 	:= ALLTRIM(MV_PAR01)
	cNotaAte 	:= ALLTRIM(MV_PAR02)
	cSerie		:= ALLTRIM(MV_PAR03)
	cDir		:= Alltrim(MV_PAR04)

	IF EMPTY(cDir)
		u_MsgLog(cProg,"Pasta deve ser preenchida!!","E")
		Return Nil
	ENDIF

	IF SUBSTR(cDir,LEN(cDir),1)<>'\'
		cDir +='\'
	ENDIF

	MakeDir(cDir)
	u_WaitLog(cProg,{|| U_V2PRPSXML() })
Endif

RETURN NIL

USER FUNCTION V2PRPSXML
Local cXML			:= ""
Local lErro			:= .F.
Local cCrLf     	:= Chr(13) + Chr(10)
Local cEMISSAO 		:= ""
Local cCORPONFS		:= ""
Local cCDSIAF       := ""
Local cMunPrest     := ""
Local nTotReg       := 0
Local cArquivo      := ""

cQuery := ""
cQuery := " select F2.R_E_C_N_O_ AS _NF2"
cQuery += " from "+retsqlname("SF2")+" F2 "
cQuery += " inner join "+retsqlname("SA1")+" A1 on A1.D_E_L_E_T_ = ' ' AND A1_COD=F2_CLIENTE AND A1_LOJA=F2_LOJA "
cQuery += " where F2.D_E_L_E_T_ = ' ' AND F2.F2_FILIAL = '"+xfilial("SF2")+"' "
cQuery += " AND F2_DOC between '"+cNotaDe+"' and '"+cNotaAte+"' "
cQuery += " AND F2_SERIE='"+cSerie+"'"
cQuery += " order by F2_DOC, F2_SERIE"

IF Select("QSF2") > 0 
	QSF2->(DbCloseArea())
ENDIF

TcQuery cQuery New Alias "QSF2"

nTotReg := Contar("QSF2","!Eof()")

cLOTE := U_NLoteNFS()

//CABECALHO DO LOTE EM XML
cXML := '<EnviarLoteRpsEnvio xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.abrasf.org.br/nfse.xsd">'+cCrLf
cXML += '<LoteRps Id="Lote_'+ALLTRIM(Alltrim(SF2->F2_SERIE))+'_03022122000177" versao="2.01">'+cCrLf
cXML += '<NumeroLote>'+cLOTE+'</NumeroLote>'+cCrLf
cXML += '<CpfCnpj>'+cCrLf
cXML += '<Cnpj>03022122000177</Cnpj>'+cCrLf
cXML += '</CpfCnpj>'+cCrLf
cXML += '<InscricaoMunicipal>5401684</InscricaoMunicipal>'+cCrLf
cXML += '<QuantidadeRps>'+ALLTRIM(STR(nTotReg))+'</QuantidadeRps>'+cCrLf
cXML += '<ListaRps>'+cCrLf

dbSelectArea("QSF2")
QSF2->(dbGotop())
While QSF2->(!EoF())

    dbSelectArea ("SF2")           //cabecalho de N.F.
    SF2->(dbgoto(QSF2->_NF2) )
    //IncProc("Consultando o banco de dados...")
	IF ALLTRIM(SF2->F2_SERIE) == cSerie
	
		//Cadastro do Cliente  + Tabela Cabeçalho das NotasFiscaisSaida SF2 //
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek( xFilial("SA1") + SF2->( F2_CLIENTE + F2_LOJA) )

        cCDSIAF := ""
        cCDSIAF := ALLTRIM(Posicione("CC2",1, xFilial("CC2")+SA1->A1_EST+PadR(SA1->A1_COD_MUN,TamSx3("CC2_CODMUN")[1]),"CC2_CDSIAF"))

    	cNUMNFE := ""
		dbselectarea("SD2")
		SD2->(dbsetorder(3)) // D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM, R_E_C_N_O_, D_E_L_E_T_
		SD2->(dbseek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))

		cNUMNFE := Alltrim(SD2->D2_PEDIDO)
       	IF EMPTY(cNUMNFE)
			cNUMNFE := Alltrim(SF2->F2_DOC)
       	ENDIF

        cMunPrest := ""
		cMunPrest := ALLTRIM(Execblock("BCODIBGE",.F.,.F.,{SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA}))

		cEMISSAO := Year2Str(SF2->F2_EMISSAO)+"-"+Month2Str(SF2->F2_EMISSAO)+"-"+Day2Str(SF2->F2_EMISSAO)
		cCORPONFS:= TRIM(SF2->F2_XXCORPO)
		cCORPONFS := STRTRAN(cCORPONFS,"|",cCrLf)

		cXML += '<Rps>'+cCrLf
		cXML += ' <InfDeclaracaoPrestacaoServico Id="Declaracao_03022122000177">'+cCrLf
		cXML += ' <Rps Id="RPS'+ALLTRIM(Alltrim(SF2->F2_DOC))+'">'+cCrLf
		cXML += ' <IdentificacaoRps>'+cCrLf
		cXML += '  <Numero>'+ALLTRIM(Alltrim(SF2->F2_DOC))+'</Numero>'+cCrLf
		cXML += '  <Serie>'+ALLTRIM(Alltrim(SF2->F2_SERIE))+'</Serie>'+cCrLf
		cXML += '  <Tipo>1</Tipo>'+cCrLf
		cXML += ' </IdentificacaoRps>'+cCrLf
		cXML += ' <DataEmissao>'+cEMISSAO+'</DataEmissao>'+cCrLf
		cXML += ' <Status>1</Status>'+cCrLf
		cXML += '</Rps>'+cCrLf
		cXML += '<Competencia>'+cEMISSAO+'</Competencia>'+cCrLf
		cXML += '<Servico>'+cCrLf
		cXML += ' <Valores>'+cCrLf
		cXML += '  <ValorServicos>'+ALLTRIM(STR(SF2->F2_VALBRUT,14,2))+'</ValorServicos>'+cCrLf
		cXML += '  <ValorDeducoes>00.00</ValorDeducoes>'+cCrLf
		cXML += '  <ValorPis>'+ALLTRIM(STR(SF2->F2_VALPIS,14,2))+'</ValorPis>'+cCrLf
		cXML += '  <ValorCofins>'+ALLTRIM(STR(SF2->F2_VALCOFI,14,2))+'</ValorCofins>'+cCrLf
		cXML += '  <ValorInss>'+ALLTRIM(STR(SF2->F2_VALINSS,14,2))+'</ValorInss>'+cCrLf
		cXML += '  <ValorIr>'+ALLTRIM(STR(SF2->F2_VALIRRF,14,2))+'</ValorIr>'+cCrLf
		cXML += '  <ValorCsll>'+ALLTRIM(STR(SF2->F2_VALCSLL,14,2))+'</ValorCsll>'+cCrLf
		cXML += '  <OutrasRetencoes>00.00</OutrasRetencoes>'+cCrLf
		cXML += '  <ValorIss>'+ALLTRIM(STR(SF2->F2_VALISS,14,2))+'</ValorIss>'+cCrLf
		cXML += '  <Aliquota>'+ALLTRIM(STR(SD2->D2_ALIQISS,14,2))+'</Aliquota>'+cCrLf
		cXML += '  <DescontoIncondicionado>00.00</DescontoIncondicionado>'+cCrLf
		cXML += '  <DescontoCondicionado>00.00</DescontoCondicionado>'+cCrLf
		cXML += ' </Valores>'+cCrLf
		cXML += ' <IssRetido>'+TRIM(SF2->F2_RECISS)+'</IssRetido>'+cCrLf
		cXML += ' <ResponsavelRetencao>'+SF2->F2_RECISS+'</ResponsavelRetencao>'+cCrLf
		cXML += ' <ItemListaServico>'+TRIM(SD2->D2_CODISS)+'</ItemListaServico>'+cCrLf
		cXML += ' <CodigoCnae>0910600</CodigoCnae>'+cCrLf
		cXML += ' <Discriminacao>'+cCORPONFS+'</Discriminacao>'+cCrLf
		cXML += ' <CodigoMunicipio>'+cMunPrest+'</CodigoMunicipio>'+cCrLf
		cXML += ' <CodigoPais>1058</CodigoPais>'+cCrLf
		cXML += ' <ExigibilidadeISS>1</ExigibilidadeISS>'+cCrLf
		cXML += ' <MunicipioIncidencia>'+cMunPrest+'</MunicipioIncidencia>'+cCrLf
		cXML += '</Servico>'+cCrLf
		cXML += '<Prestador>'+cCrLf
		cXML += ' <CpfCnpj>'+cCrLf
		cXML += '  <Cnpj>03022122000177</Cnpj>'+cCrLf
		cXML += ' </CpfCnpj>'+cCrLf
		cXML += ' <InscricaoMunicipal>5401684</InscricaoMunicipal>'+cCrLf
		cXML += '</Prestador>'+cCrLf
		cXML += '<Tomador>'+cCrLf
		cXML += ' <IdentificacaoTomador>'+cCrLf
		cXML += '  <CpfCnpj>'+cCrLf
		cXML += '   <Cnpj>'+AllTrim(SA1->A1_CGC)+'</Cnpj>'+cCrLf
		cXML += '  </CpfCnpj>'+cCrLf
		//cXML += '  <InscricaoMunicipal>'+ALLTRIM(SA1->A1_INSCRM)+'</InscricaoMunicipal>'+cCrLf
		cXML += ' </IdentificacaoTomador>'+cCrLf
		cXML += ' <RazaoSocial>'+Alltrim(SA1->A1_NOME)+'</RazaoSocial>'+cCrLf
		cXML += ' <Endereco>'+cCrLf
		cXML += '  <Endereco>'+ALLTRIM(SA1->A1_END)+'</Endereco>'+cCrLf
		cXML += '  <Numero>14</Numero>'+cCrLf
		If !EMPTY(SA1->A1_COMPLEM)
			cXML += '  <Complemento>'+ALLTRIM(SA1->A1_COMPLEM)+'</Complemento>'+cCrLf
		EndIf
		cXML += '  <Bairro>'+ALLTRIM(SA1->A1_BAIRRO)+'</Bairro>'+cCrLf
		cXML += '  <CodigoMunicipio>'+U_UfIBGE(SA1->A1_EST)+SA1->A1_COD_MUN+'</CodigoMunicipio>'+cCrLf
		cXML += '  <Uf>'+Upper(SA1->A1_EST)+'</Uf>'+cCrLf
		cXML += '  <CodigoPais>'+IIF(Empty(SA1->A1_PAIS),"1058"  ,Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SISEXP"))+'</CodigoPais>'+cCrLf
		cXML += '  <Cep>'+SA2->A2_CEP+'</Cep>'+cCrLf
		cXML += ' </Endereco>'+cCrLf
		cXML += ' <Contato>'+cCrLf
		cXML += '  <Telefone>'+ALLTRIM(SA2->A2_DDD+SA2->A2_TEL)+'</Telefone>'+cCrLf
		cXML += '  <Email>'+ALLTRIM(SA1->A1_EMAIL)+'</Email>'+cCrLf
		cXML += ' </Contato>'+cCrLf
		cXML += '</Tomador>'+cCrLf
		//cXML += '<ConstrucaoCivil>'+cCrLf
		//cXML += '<CodigoObra>8888</CodigoObra>'+cCrLf
		//cXML += '<Art>9999</Art>'+cCrLf
		//cXML += '</ConstrucaoCivil>'+cCrLf
		cXML += '<OptanteSimplesNacional>2</OptanteSimplesNacional>'+cCrLf
		cXML += '<IncentivoFiscal>2</IncentivoFiscal>'+cCrLf
		cXML += '</InfDeclaracaoPrestacaoServico>'+cCrLf
		cXML += '</Rps>'+cCrLf

	ENDIF
	QSF2->(DbSkip())
ENDDO
QSF2->(DbCloseArea())

IF !lErro .and. nTotReg > 0
	cXML += '</ListaRps>
	cXML += '</LoteRps>
	cXML += '</EnviarLoteRpsEnvio>

	cArquivo := cDir+'Lote_NO_'+cLOTE+'-'+ALLTRIM(Alltrim(SF2->F2_SERIE))+'_03022122000177.XML'

	MemoWrite(cArquivo,cXML)

	u_MsgLog(,"XML NFS-e Gerado com Sucesso! Arquivo: "+cArquivo,"S")
ELSE
	u_MsgLog(,"XML NFS-e Erro na Geração. Verifique!","E")
ENDIF 
    	
Return (Nil)



User Function NLoteNFS()
Local _cNLoteNFS := ""

_cNLoteNFS := U_BKGetMv("BKFATA0701")

_cNLoteNFS := STRZERO(VAL(_cNLoteNFS)+1,6)

U_BKPutMv("BKFATA0701",_cNLoteNFS,"C",06,0,"SAO SEBASTIAO DO PASSE-BA")

Return _cNLoteNFS
