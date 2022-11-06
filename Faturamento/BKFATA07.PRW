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
Local aEND          := {}
Local cCDSIAF       := ""
Local cMunPrest     := ""
Local nRETINSS      := 0
Local nValISS       := 0
Local nVlrLiq       := 0
Local _nALQISS      := 0
Local nTotReg       := 0
Local _cDescritivo  := ""

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

        aEND := {}
        aEND := U_StringToArray(SA1->A1_END,",")
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

		nRETINSS := 0
        _nALQISS := 0
		dbSelectArea("SF3")
		SF3->(dbSetOrder(4))
		If DbSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE)
            While SF3->(!EoF()) .AND. SF2->F2_FILIAL == xFilial("SF3") .AND. F3_CLIEFOR == SF2->F2_CLIENTE .AND. F3_LOJA == SF2->F2_LOJA .AND. F3_NFISCAL == SF2->F2_DOC .AND. SF3->F3_SERIE == SF2->F2_SERIE .AND. SF3->F3_TIPO == "S"
                IF !(!empty(SF3->F3_DTCANC) .OR.  'CANCEL' $ SF3->F3_OBSERV)
                    _nALQISS := SF3->F3_ALIQICM
			        If !EMPTY(SF3->F3_RECISS)
				        nRETINSS  := VAL(SF3->F3_RECISS)
                        IF nRETINSS == 1 
                            nRETINSS  := 2
                        ELSE
		                    nRETINSS  := 0
                        ENDIF
		            ENDIF
                ENDIF
	        SF3->(DbSkip())
            ENDDO
		ENDIF

        IF ALLTRIM(SC5->C5_XITSERV) == "713"
            nRETINSS  := 0
        ENDIF 

		nValISS := 0
		nVlrLiq := 0
		nValISS := Round(SF2->((F2_VALBRUT-F2_DESCONT) * round( ((SF2->(F2_VALISS/(F2_VALBRUT-F2_DESCONT)))),05 ) ), 02 )
		nVlrLiq := round(SF2->(F2_VALBRUT-F2_VALPIS-F2_VALCOFI-F2_VALCSLL-F2_VALINSS-F2_VALIRRF)-nValISS,2)

        //REMOVE CARACTER ESPECIAIS
        _cDescritivo := ""
        _cDescritivo := STRTRAN(SC5->C5_XXDNFS,"º","o.")
        _cDescritivo := STRTRAN(_cDescritivo,"ª","a.")

		cXML := '<nfse>'+cCrLf
		cXML += '<identificador>'+DTOS(DATE())+STRTRAN(ALLTRIM(Time()),":","")+SF2->F2_DOC+ALLTRIM(SF2->F2_SERIE)+'</identificador>'+cCrLf
 		cXML += '<nf>'+cCrLf
		cXML += '<valor_total>'+Alltrim(Transform(SF2->F2_VALBRUT,"@E 999999999999.99"))+'</valor_total>'+cCrLf
		cXML += '<valor_desconto>'+Alltrim(Transform(SF2->F2_DESCONT,"@E 999999999999.99"))+'</valor_desconto>'+cCrLf
		cXML += '<valor_ir>'+Alltrim(Transform(SF2->F2_VALIRRF,"@E 999999999999.99"))+'</valor_ir>'+cCrLf
		cXML += '<valor_inss>'+Alltrim(Transform(SF2->F2_VALINSS,"@E 999999999999.99"))+'</valor_inss>'+cCrLf
		cXML += '<valor_contribuicao_social>'+Alltrim(Transform(SF2->F2_VALCSLL,"@E 999999999999.99"))+'</valor_contribuicao_social>'+cCrLf
		cXML += '<valor_rps>0,00</valor_rps>'+cCrLf
		cXML += '<valor_pis>'+Alltrim(Transform(SF2->F2_VALPIS,"@E 999999999999.99"))+'</valor_pis>'+cCrLf
		cXML += '<valor_cofins>'+Alltrim(Transform(SF2->F2_VALCOFI,"@E 999999999999.99"))+'</valor_cofins>'+cCrLf
		cXML += '<observacao/>'+cCrLf
		cXML += '</nf>'+cCrLf
		cXML += '<prestador>'+cCrLf
		cXML += '<cpfcnpj>'+Alltrim(SM0->M0_CGC)+'</cpfcnpj>'+cCrLf
		cXML += '<cidade>8561</cidade>'+cCrLf
		cXML += '</prestador>'+cCrLf
		cXML += '<tomador>'+cCrLf
		cXML += '<tipo>'+Alltrim(SA1->A1_PESSOA)+'</tipo>'+cCrLf
		cXML += '<cpfcnpj>'+Alltrim(SA1->A1_CGC)+'</cpfcnpj>'+cCrLf
		cXML += '<ie/>'+cCrLf
		cXML += '<nome_razao_social>'+Alltrim(SA1->A1_NOME)+'</nome_razao_social>'+cCrLf
		cXML += '<sobrenome_nome_fantasia/>'+cCrLf
		cXML += '<logradouro>'+Alltrim(aEND[1])+'</logradouro>'+cCrLf
		cXML += '<email>'+Alltrim(SA1->A1_EMAIL)+'</email>'+cCrLf
		cXML += '<numero_residencia>'+IIF(LEN(aEND)>1,aEND[2],"0")+'</numero_residencia>'+cCrLf
		cXML += '<complemento/>'+cCrLf
		cXML += '<ponto_referencia/>'+cCrLf
		cXML += '<bairro>'+Alltrim(SA1->A1_BAIRRO)+'</bairro>'+cCrLf
		cXML += '<cidade>'+cCDSIAF+'</cidade>'+cCrLf
		cXML += '<cep>'+Alltrim(SA1->A1_CEP)+'</cep>'+cCrLf
		cXML += '<ddd_fone_comercial/>'+cCrLf
		cXML += '<fone_comercial/>'+cCrLf
		cXML += '<ddd_fone_residencial/>'+cCrLf
		cXML += '<fone_residencial/>'+cCrLf
		cXML += '<ddd_fax/>'+cCrLf
		cXML += '<fone_fax/>'+cCrLf
		cXML += '</tomador>'+cCrLf
		cXML += '<itens>'+cCrLf
		cXML += '<lista>'+cCrLf
		cXML += '<codigo_local_prestacao_servico>'+cMunPrest+'</codigo_local_prestacao_servico>'+cCrLf
		cXML += '<codigo_item_lista_servico>'+ALLTRIM(SC5->C5_XITSERV)+'</codigo_item_lista_servico>'+cCrLf
		cXML += '<descritivo>'+_cDescritivo+'</descritivo>'+cCrLf
		cXML += '<aliquota_item_lista_servico>'+Alltrim(Transform(_nALQISS,"@E 999.99"))+'</aliquota_item_lista_servico>'+cCrLf
		cXML += '<situacao_tributaria>'+Alltrim(STR(nRETINSS))+'</situacao_tributaria>'+cCrLf
		cXML += '<valor_tributavel>'+Alltrim(Transform(SF2->F2_VALBRUT,"@E 999999999999.99"))+'</valor_tributavel>'+cCrLf
		cXML += '<valor_deducao>0,00</valor_deducao>'+cCrLf
        IF nRETINSS > 0
		    cXML += '<valor_issrf>'+Alltrim(Transform(SF2->F2_VALISS,"@E 999999999999.99"))+'</valor_issrf>'+cCrLf
		    cXML += '<tributa_municipio_prestador>N</tributa_municipio_prestador>'+cCrLf
        ELSE
		    cXML += '<valor_issrf>0,00</valor_issrf>'+cCrLf
		    cXML += '<tributa_municipio_prestador>S</tributa_municipio_prestador>'+cCrLf
        ENDIF
		cXML += '<unidade_codigo/>'+cCrLf
		cXML += '<unidade_quantidade/>'+cCrLf
		cXML += '<unidade_valor_unitario/>'+cCrLf
		cXML += '</lista>'+cCrLf
		cXML += '</itens>'+cCrLf
		cXML += '</nfse>'+cCrLf
	ENDIF
	QSF2->(DbSkip())
ENDDO
QSF2->(DbCloseArea())

IF !lErro
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
