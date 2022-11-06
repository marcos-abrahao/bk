#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKCOMC02
    Pesquisa por parte do numero da NF

    @type  Function
    @author Marcos Bispo Abrahão
    @since 13/01/2020
    @version 1.0
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

User Function BKCOMC02()
Local aArea     := Getarea()
Local oOk
Local oNo
Local oDlg
Local oPanelLeft
Local aButtons 	:= {}
Local lOk      	:= .F.
Local cTitulo2 	:= "BKCOMC02 - Pesquisa Doc de Entrada:"
Local oGetNF    AS object
Local oGetVal   AS object

Static cPartNF   := SPACE(LEN(SF1->F1_DOC))
Static nValor    := 0

u_MsgLog("BKCOMC02")

oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

nLin := 10

DO WHILE .T.	

	DEFINE MSDIALOG oDlg TITLE cTitulo2 FROM 000,000 TO 240,550 PIXEL
	@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 530,230  // P12
	oPanelLeft:Align := CONTROL_ALIGN_LEFT

	@ nLin,010 SAY 'Nº NF contém:' PIXEL SIZE 50,10 OF oPanelLeft
    @ nLin,070 MSGET oGetNF VAR cPartNF OF oPanelLeft PICTURE "@!" SIZE 130,10 PIXEL 
	nLin += 25

	@ nLin,010 SAY 'Valor:' PIXEL SIZE 50,10 OF oPanelLeft
    @ nLin,070 MSGET oGetVal VAR nValor OF oPanelLeft Picture "@E 999,999,999,999.99" SIZE 100,10 PIXEL 

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , @aButtons)
		
	If ( lOk )
  
        If !PesqDoc(cPartNF,nValor)
            Restarea( aArea )
        ENDIF

		EXIT
	Else
		EXIT
	EndIf
	
ENDDO
		                   
          
RETURN lOk


STATIC FUNCTION PesqDoc(cPartNF,nValor)
Local cQuery
Local lRet := .F.
Static nPesq  := 0 
Static cNFAnt := ""

cQuery  := "SELECT "
cQuery  += "R_E_C_N_O_ AS F1RECNO "
cQuery  += "FROM "+RETSQLNAME("SF1")+" SF1 "
cQuery  += "WHERE SF1.D_E_L_E_T_ <> '*' "
If !Empty(cPartNF)
    cQuery  += "AND F1_DOC LIKE '%"+ALLTRIM(cPartNF)+"%' "
EndIf
If nValor > 0
    cQuery  += "AND F1_VALBRUT = "+STR(nValor,10,2)+" "
ENDIF

TCQUERY cQuery NEW ALIAS "QSF1"

If cNFAnt <> "" .AND. cNFAnt == cPartNF
    nPesq++
else
    cNFAnt := ""
    nPesq  := 0
EndIf

DbSelectArea("QSF1")
DbGoTop()
If nPesq > 0
    dbSkip(nPesq)
ENDIF
If !EOF()
    SF1->(dbGoTo(QSF1->F1RECNO))
    lRet := .T.
EndIf
QSF1->(DbCloseArea())

cNFAnt := cPArtNF

Return lRet
