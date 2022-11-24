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

Local cPerg 		:= "BKFATA07"

Private cNotaDe 	:= ""
Private cNotaAte 	:= ""
Private cSerie		:= ""
Private cDir		:= ""
Private aUF			:= {}

u_MsgLog(cPerg)
	
//Preenchimento do Array de UF
aadd(aUF,{"RO","11"})
aadd(aUF,{"AC","12"})
aadd(aUF,{"AM","13"})
aadd(aUF,{"RR","14"})
aadd(aUF,{"PA","15"})
aadd(aUF,{"AP","16"})
aadd(aUF,{"TO","17"})
aadd(aUF,{"MA","21"})
aadd(aUF,{"PI","22"})
aadd(aUF,{"CE","23"})
aadd(aUF,{"RN","24"})
aadd(aUF,{"PB","25"})
aadd(aUF,{"PE","26"})
aadd(aUF,{"AL","27"})
aadd(aUF,{"MG","31"})
aadd(aUF,{"ES","32"})
aadd(aUF,{"RJ","33"})
aadd(aUF,{"SP","35"})
aadd(aUF,{"PR","41"})
aadd(aUF,{"SC","42"})
aadd(aUF,{"RS","43"})
aadd(aUF,{"MS","50"})
aadd(aUF,{"MT","51"})
aadd(aUF,{"GO","52"})
aadd(aUF,{"DF","53"})
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
aadd(aUF,{"EX","99"})


AjustaSX1(cPerg)
If !Pergunte(cPerg,.T.)
   	Return (Nil)
EndIf

Processa( {|| U_V2PRPSXML() })

RETURN NIL

USER FUNCTION V2PRPSXML
Local cXML			:= ""
//Local cXML2         := ""
//Local cArqTmp       := ""
Local lErro			:= .F.
//Local lGRVARQ		:= .T.
Local cCrLf     	:= Chr(13) + Chr(10)
Local cEMISSAO 		:= ""
Local cCDSIAF       := ""
Local cMunPrest     := ""
Local nTotReg       := 0

cNotaDe 	:= ALLTRIM(MV_PAR01)
cNotaAte 	:= ALLTRIM(MV_PAR02)
cSerie		:= ALLTRIM(MV_PAR03)
cDir		:= Alltrim(MV_PAR04)
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
ProcRegua(nTotReg)

//CABECALHO DO LOTE EM XML
cXML := '<EnviarLoteRpsEnvio xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.abrasf.org.br/nfse.xsd">'+cCrLf
cXML += '<LoteRps Id="Lote_'+ALLTRIM(Alltrim(SF2->F2_SERIE))+'_03022122000177" versao="2.01">'+cCrLf
cXML += '<NumeroLote>'+cLOTE+'</NumeroLote>'+cCrLf
cXML += '<CpfCnpj>'+cCrLf
cXML += '<Cnpj>03022122000177</Cnpj>'+cCrLf
cXML += '</CpfCnpj>'+cCrLf
cXML += '<InscricaoMunicipal>5401684</InscricaoMunicipal>'+cCrLf
cXML += '<QuantidadeRps>'+ALLTRIM(STR(nTotReg))+'</QuantidadeRps>'+cCrLf

dbSelectArea("QSF2")
QSF2->(dbGotop())
While QSF2->(!EoF())

    dbSelectArea ("SF2")           //cabecalho de N.F.
    SF2->(dbgoto(QSF2->_NF2) )
    IncProc("Consultando o banco de dados...")
	IF ALLTRIM(SF2->F2_SERIE) == cSerie
	
		dbselectarea("SA1")
        SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
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
		dbSelectArea("SC5")
        SC5->(DbSetOrder(1))
		SC5->(dbSeek(xFilial("SC5") + SD2->D2_PEDIDO,.T.))
        If ( len(Alltrim(SC5->C5_MUNPRES)) == 5 .AND. !empty(SC5->C5_ESTPRES) )
            cMunPrest := ALLTRIM(Posicione("CC2",1, xFilial("CC2")+SC5->C5_ESTPRES+PadR(SC5->C5_MUNPRES,TamSx3("CC2_CODMUN")[1]),"CC2_CDSIAF"))
        ELSE
            cMunPrest := cCDSIAF
        ENDIF

		cEMISSAO := YEARSTR(SF2->F2_EMISSAO)+"-"+MONTHSTR(SF2->F2_EMISSAO)+"-"+DAYSTR(SF2->F2_EMISSAO)

		cXML += '<ListaRps>'+cCrLf
		cXML += '<Rps>'+cCrLf
		cXML += ' <InfDeclaracaoPrestacaoServico Id="Declaracao_03022122000177">'+cCrLf
		cXML += ' <Rps Id="RPS'+ALLTRIM(Alltrim(SF2->F2_DOC))+'">'+cCrLf
		cXML += ' <IdentificacaoRps>'+cCrLf
		cXML += ' <Numero>'+ALLTRIM(Alltrim(SF2->F2_DOC))+'</Numero>'+cCrLf
		cXML += ' <Serie>'+ALLTRIM(Alltrim(SF2->F2_SERIE))+'</Serie>'+cCrLf
		cXML += ' <Tipo>1</Tipo>'+cCrLf
		cXML += ' </IdentificacaoRps>'+cCrLf
		cXML += ' <DataEmissao>'+cEMISSAO+'</DataEmissao>'+cCrLf
		cXML += ' <Status>1</Status>'+cCrLf
		cXML += '</Rps>'+cCrLf
		cXML += '<Competencia>2012-10-15</Competencia>'+cCrLf
		cXML += '<Servico>'+cCrLf
		cXML += ' <Valores>'+cCrLf
		cXML += '  <ValorServicos>'+STR(SF2->F2_VALBRUT,14,2)+'</ValorServicos>'+cCrLf
		cXML += '  <ValorDeducoes>00.00</ValorDeducoes>'+cCrLf
		cXML += '  <ValorPis>'+STR(SF2->F2_VALPIS,14,2)+'</ValorPis>'+cCrLf
		cXML += '  <ValorCofins>'+STR(SF2->F2_VALCOF,14,2)+'</ValorCofins>'+cCrLf
		cXML += '  <ValorInss>'+STR(SF2->F2_VALINSS,14,2)+'</ValorInss>'+cCrLf
		cXML += '  <ValorIr>'+STR(SF2->F2_VALIRF,14,2)+'</ValorIr>'+cCrLf
		cXML += '  <ValorCsll>'+STR(SF2->F2_VALCSL,14,2)+'</ValorCsll>'+cCrLf
		cXML += '  <OutrasRetencoes>00.00</OutrasRetencoes>'+cCrLf
		cXML += '  <ValorIss>'+STR(SF2->F2_VALISS,14,2)+'</ValorIss>'+cCrLf
		cXML += '  <Aliquota>'+SF2->F2_ALQISS+'</Aliquota>'+cCrLf
		cXML += '  <DescontoIncondicionado>00.00</DescontoIncondicionado>'+cCrLf
		cXML += '  <DescontoCondicionado>00.00</DescontoCondicionado>'+cCrLf
		cXML += ' </Valores>'+cCrLf
		cXML += ' <IssRetido>'+SF2->F2_RECISS+'</IssRetido>'+cCrLf
		cXML += ' <ResponsavelRetencao></ResponsavelRetencao>'+cCrLf
		cXML += ' <ItemListaServico>05.01</ItemListaServico>'+cCrLf
		cXML += ' <CodigoCnae>0</CodigoCnae>'+cCrLf
		cXML += ' <Discriminacao>'+TRIM(SF2->F2_XXCORPO)+'</Discriminacao>'+cCrLf
		cXML += ' <CodigoMunicipio>4216602</CodigoMunicipio>'+cCrLf
		cXML += ' <CodigoPais>1058</CodigoPais>'+cCrLf
		cXML += ' <ExigibilidadeISS>1</ExigibilidadeISS>'+cCrLf
		cXML += ' <MunicipioIncidencia>1200179</MunicipioIncidencia>'+cCrLf
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
		cXML += '  <InscricaoMunicipal>'+SA1->A1_INSCRM+'</InscricaoMunicipal>'+cCrLf
		cXML += ' </IdentificacaoTomador>'+cCrLf
		cXML += ' <RazaoSocial>'+Alltrim(SA1->A1_NOME)+'</RazaoSocial>'+cCrLf
		cXML += ' <Endereco>'+cCrLf
		cXML += '  <Endereco>'+SA1->A1_END+'</Endereco>'+cCrLf
		cXML += '  <Numero>14</Numero>'+cCrLf
		cXML += '  <Complemento>'+ALLTRIM(SA1->A1_COMPLEM)+'</Complemento>'+cCrLf
		cXML += '  <Bairro>'+ALLTRIM(SA1->A1_BAIRRO)+'</Bairro>'+cCrLf
		cXML += '  <CodigoMunicipio>'+SA1->A1_COD_MUN+'</CodigoMunicipio>'+cCrLf
		cXML += '  <Uf>'+Upper(SA1->A1_EST)+'</Uf>'+cCrLf
		cXML += '  <CodigoPais>'+IIF(Empty(SA1->A1_PAIS),"1058"  ,Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SISEXP"))+'</CodigoPais>'+cCrLf
		cXML += '  <Cep>'+SA2->A2_CEP+'</Cep>'+cCrLf
		cXML += ' </Endereco>'+cCrLf
		cXML += ' <Contato>'+cCrLf
		cXML += '  <Telefone>'+SA2->A2_DDD+SA2->A2_TEL+'</Telefone>'+cCrLf
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

IF !lErro
	cXML += '</ListaRps>
	cXML += '</LoteRps>
	cXML += '</EnviarLoteRpsEnvio>

	MSGINFO("XML NFS-e Gravado com Sucesso!!")
ENDIF 
    	
Return (Nil)



Static Function AjustaSX1(cPerg)

Local aArea := GetArea()
Local aRegs := {}
Local i 	:= 0
Local j 	:= 0

cPerg := PADR(cPerg,10)

aAdd(aRegs,{cPerg,"01","Da Nota?"  ,"Da Nota?"  ,"Da Nota?"  ,"mv_ch1","C",09,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SF2","S","",""})
aAdd(aRegs,{cPerg,"02","Ate Nota?" ,"Ate Nota?" ,"Ate Nota?" ,"mv_ch2","C",09,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SF2","S","",""})
aAdd(aRegs,{cPerg,"03","Serie?"	   ,"Serie?"    ,"Serie?"    ,"mv_ch3","C",03,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Salvar em?","Salvar em?","Salvar em?","mv_ch4","C",99,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

DbSelectArea("SX1")
DbSetOrder(1)
For i := 1 to Len(aRegs)
   If !dbSeek(cPerg+aRegs[i,2])
      RecLock("SX1",.T.)
	  For j:=1 to FCount()
	     If j <= Len(aRegs[i])
		    FieldPut(j,aRegs[i,j])
		 Endif
	  Next
	  SX1->(MsUnlock())
   Endif
Next  

RestArea(aArea)

Return
