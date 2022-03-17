#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKCOMA08
    Alteração de Chave NFE após digitação da NF
    @type  Function
    @author Marcos Bispo Abrahão
    @since 10/01/2020
    @version 1.0
/*/

User Function BKCOMA08()
Local aArea     := Getarea()
Local aAreaSF3  := ""
Local aAreaSFT  := ""
Local oOk
Local oNo
Local oDlg
Local oPanelLeft
Local aButtons 	:= {}
Local lOk      	:= .F.
Local cTitulo2 	:= "BKCOMA08 - Doc de Entrada: "+SF1->F1_DOC
Local cChvNfe   := ""
Local cEspecie  := ""  //SPACE(TAMSX3("F1_ESPECIE")[1])

cChvNfe  := SF1->F1_CHVNFE
cEspecie := SF1->F1_ESPECIE
	
oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

nLin := 10

DO WHILE .T.	

	DEFINE MSDIALOG oDlg TITLE cTitulo2 FROM 000,000 TO 240,550 PIXEL
	@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 530,230  // P12
	oPanelLeft:Align := CONTROL_ALIGN_LEFT

	@ nLin,010 SAY 'Chave NFE:' PIXEL SIZE 50,10 OF oPanelLeft
    @ nLin,070 MSGET oGetChv VAR cChvNfe VALID u_ConsNfe(cChvNfe) OF oPanelLeft PICTURE "@!" SIZE 130,10 PIXEL 
	nLin += 25

	@ nLin,010 SAY 'Especie:' PIXEL SIZE 50,10 OF oPanelLeft
    @ nLin,070 MSGET oGetEps VAR cEspecie  OF oPanelLeft PICTURE "@!" SIZE 100,10 PIXEL 

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , @aButtons)
		
	If ( lOk )
        RecLock("SF1",.F.)
	    SF1->F1_CHVNFE 	:= cChvNfe
	    SF1->F1_ESPECIE := cEspecie
		lOk := .F.
        MsUnlock()

        dbSelectArea("SF3")
        aAreaSF3 := SF3->(getArea())
        dbSetOrder(4)
        dBseek(xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE,.T.)
		While !Eof() .And. ;
                xFilial("SF3") == SF3->F3_FILIAL .And.;
                SF1->F1_FORNECE == SF3->F3_CLIEFOR .And.;
                SF1->F1_LOJA == SF3->F3_LOJA .And.;
                SF1->F1_DOC == SF3->F3_NFISCAL .And.;
                SF1->F1_SERIE == SF3->F3_SERIE

            If Substr(SF3->F3_CFO,1,1) < "5" .And. SF3->F3_FORMUL == SF1->F1_FORMUL .and. SF3->F3_ENTRADA = SF1->F1_DTDIGIT
                RecLock("SF3",.F.)
                SF3->F3_CHVNFE  := cChvNfe
                SF3->F3_ESPECIE := cEspecie
                MsUnlock()
            EndIf
            dbSkip()
        EndDo

		dbSelectArea("SFT")
        aAreaSFT := SFT->(getArea())

		dbSetOrder(2) 
		dbSeek(xFILIAL("SFT")+"E"+DTOS(SF1->F1_DTDIGIT)+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA,.T.)
		While !Eof() .And. ;
                xFilial("SFT") == SFT->FT_FILIAL .And.;
                SF1->F1_DTDIGIT == SFT->FT_ENTRADA .And.;
                SF1->F1_FORNECE == SFT->FT_CLIEFOR .And.;
                SF1->F1_LOJA == SFT->FT_LOJA .And.;
                SF1->F1_DOC == SFT->FT_NFISCAL .And.;
                SF1->F1_SERIE == SFT->FT_SERIE
            If Substr(SFT->FT_CFOP,1,1) < "5" .And. SFT->FT_FORMUL == SF1->F1_FORMUL
                Reclock("SFT",.F.) 
                SFT->FT_ESPECIE := cEspecie
                SFT->FT_CHVNFE  := cChvNfe
                MsUnlock()
            Endif
            DbSelectArea("SFT")
            dbSkip()
        EndDo
        SFT->(RestArea(aAreaSFT))

		EXIT
	Else
		EXIT
	EndIf
	
ENDDO
		                   
Restarea( aArea )
          
RETURN lOk
