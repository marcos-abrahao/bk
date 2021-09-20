#include "Protheus.ch"
#include "RwMake.ch"
#include "TopConn.ch"

/*/{Protheus.doc} BKCOMA07()
Copiar Dados de Fornecedor entre empresas tabela SA2 

@author Adilson do Prado
@since 24/10/2014
@version P12
@return .T.
/*/

User Function BKCOMA07()
Local aSM0Area 	:= SM0->(GetArea())
Local cEmpAT  	:= SM0->M0_CODIGO
Local cEmpOR  	:= SM0->M0_CODIGO
Local cQry1 	:= ""
Local cA2ARQ   	:= ""
Local cA2COD   	:= ""
Local cA2LOJA  	:= ""
Local cA2NOME  	:= ""
Local cArqSX2   := ""

Private cPerg := "BKCOMA07"
Private titulo:= "Copiar Fornecedor entre empresas"
Private cCNPJ := ""

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif
 
cCNPJ := ALLTRIM(mv_par01) 

IF !CGC(cCNPJ,,.F.)
	Msgstop("CNPJ Inválido. Verifique!!")
	Return Nil
ENDIF

DBselectarea("SA2")
dbSetOrder(3)
IF dbSeek(xFILIAL("SA2")+cCNPJ,.F.)    
	MSGALERT("Fornecedor já cadastrado código: "+SA2->A2_COD+"  Loja: "+SA2->A2_LOJA+" - "+SA2->A2_NOME)
	Return Nil
ENDIF

SM0->(DbGoTop())
While SM0->(!EoF()) .AND. cA2COD == ""  

 	If SM0->M0_CODIGO $ "07/99" //.OR. SM0->M0_CODIGO $ getmv("MV_XNSLDS") 
		SM0->(DbSKip())
		Loop
	EndIf

	// Removido de acordo com o CodeAnalysis em 09/01/20
	//cArquivo1 := "SX2"+SM0->M0_CODIGO+"0"    //+GetDBExtension()
	//If Select("SX2DBF") > 0
	//	SX2DBF->(DbCloseArea())
	//EndIf
		
	//dbUseArea(.T.,NIL,cArquivo1,"SX2DBF",.T.,.F.)
	//dbSelectArea("SX2DBF")

    //dbSetIndex(cArquivo1)
    //dbGoTop()
    
	//SX2DBF->(DbSeek("SA2"))
	cArqSx2 := "SA2"+SM0->M0_CODIGO+"0"

	cQry1 := "SELECT A2_COD,A2_LOJA,A2_NOME FROM "+cArqSx2+" XSA2"		
	cQry1 += " WHERE XSA2.D_E_L_E_T_ = ''  AND XSA2.A2_CGC = '"+cCNPJ+"' "
		
	If Select("XSA2") > 0
		XSA2->(DbCloseArea())
	EndIf
	
	TcQuery cQry1 New Alias "XSA2"
	dbSelectArea("XSA2")

	If ALLTRIM(XSA2->A2_COD) <> "" .AND. cA2COD == ""
		cEmpOR  := SM0->M0_CODIGO
		cA2ARQ 	:= cArqSx2  //Alltrim(SX2DBF->X2_ARQUIVO)
		cA2COD 	:= XSA2->A2_COD
		cA2LOJA := XSA2->A2_LOJA
		cA2NOME := XSA2->A2_NOME 
	EndIf

	//SX2DBF->(DbCloseArea())
	//FErase(cArquivo1+"A"+OrdBagExt())

	XSA2->(DbCloseArea())
	
	SM0->(DbSkip())
EndDo

RestArea(aSM0Area)

IF !EMPTY(cA2COD)
	IF cEmpAT==cEmpOR
		MSGALERT("Fornecedor já cadastrado código: "+cA2COD+"  Loja: "+cA2LOJA+" - "+cA2NOME)
	ELSE
		IF AVISO("Atenção","Confirma a Inclusão do Fornecedor?? código: "+cA2COD+"  Loja: "+cA2LOJA+" - "+cA2NOME,{"Sim","Não"}) == 1
	       CopySA2(cA2ARQ,cA2COD,cA2LOJA)
		Endif
	ENDIF
ELSE
    MSGSTOP("Fornecedor não encontrado!!")
ENDIF

Return nil


STATIC FUNCTION CopySA2(cA2ARQ,cA2COD,cA2LOJA)
Local cQry1 := ""
Local aSA2  := {}
Local aSx3  := {}
Local nI    := 0
Local cCpo  := ""

Private lMsHelpAuto := .f.
Private lMsErroAuto := .f.
Private cCampo,xCampo

cQry1 := "SELECT * FROM "+Alltrim(cA2ARQ)+" XSA2"		
cQry1 += " WHERE XSA2.D_E_L_E_T_ = '' AND A2_COD='"+cA2COD+"' AND A2_LOJA='"+cA2LOJA+"'"
		
If Select("XSA2") > 0
	XSA2->(DbCloseArea())
EndIf
	
TcQuery cQry1 New Alias "XSA2"
dbSelectArea("XSA2")

aSx3 := FWSX3Util():GetAllFields( "SA2" , .F. /*lVirtual */)
For nI := 1 To Len(aSx3)
	cCpo := AllTrim(aSx3[nI])
	IF GetSx3Cache(cCpo,"X3_CONTEXT") <> "V" .AND. X3USO(GetSx3Cache(cCpo,"X3_USADO"))
		IF cCpo == "A2_FILIAL"
			AADD(aSA2,{cCpo,xFILIAL("SA2"), Nil})
		ELSEIF cCpo $ "A2_COD"
			AADD(aSA2,{cCpo,U_BKCOMF11(), Nil})
		ELSEIF cCpo $ "A2_LOJA"
			AADD(aSA2,{cCpo,cA2LOJA, Nil})
		ELSEIF cCpo $ "A2_REPR_AG/A2_CBO/A2_CIVIL/A2_GRPDEP/A2_FRETISS/A2_INSCMU/A2_CONTPRE/A2_CPFIRP/A2_RETISI/A2_ISICM/A2_UFFIC/A2_TPREG/A2_SUBCON/A2_CPFRUR"
		ELSEIF cCpo == "A2_CODPIS"
			AADD(aSA2,{cCpo,"01058", Nil})
		ELSEIF cCpo == "A2_MINIRF"
			AADD(aSA2,{cCpo,"2", Nil})
		ELSEIF cCpo $ "A2_MCOMPRA/A2_NROCOM/A2_SALDUP/A2_SALDUPM"
			AADD(aSA2,{cCpo,0, Nil})
		ELSEIF cCpo $ "A2_PRICOM/A2_ULTCOM"
			AADD(aSA2,{cCpo,CTOD(""), Nil})
		ELSE
			cCampo := "XSA2->"+cCpo
			xCampo := NIL
			xCampo := &cCampo
			IF TamSX3(cCpo)[3] == "C"  // Evitar erro de campos com tamanhos maiores em campos menores
				xCampo := TRIM(xCampo)
			ELSEIF TamSX3(cCpo)[3] == "D" 
				xCampo := STOD(xCampo)
			ENDIF
			IF EMPTY(xCampo) .AND. !EMPTY(GetSx3Cache(cCpo,"X3_RELACAO"))  
				xCampo := &(GetSx3Cache(cCpo,"X3_RELACAO"))
			ENDIF
			AADD(aSA2,{cCpo,xCampo, Nil})
			//AADD(aSA2,{cCpo,IIF(SX3->X3_TIPO=="D",CTOD(xCampo),IIF(!EMPTY(xCampo),xCampo,IIF(!EMPTY(SX3->X3_RELACAO),&(SX3->X3_RELACAO),xCampo))), Nil})
		ENDIF
	ENDIF
NEXT

/*
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SA2",.T.)
Do while !eof() .and. SX3->X3_ARQUIVO == "SA2"
    IF SX3->X3_CONTEXT <> "V" .AND. X3USO(SX3->X3_USADO)
     
		IF Alltrim(SX3->X3_CAMPO) == "A2_FILIAL"
			AADD(aSA2,{Alltrim(SX3->X3_CAMPO),xFILIAL("SA2"), Nil})
		ELSEIF Alltrim(SX3->X3_CAMPO) $ "A2_COD"
		    AADD(aSA2,{Alltrim(SX3->X3_CAMPO),U_BKCOMF11(), Nil})
		ELSEIF Alltrim(SX3->X3_CAMPO) $ "A2_LOJA"
		    AADD(aSA2,{Alltrim(SX3->X3_CAMPO),cA2LOJA, Nil})
		ELSEIF Alltrim(SX3->X3_CAMPO) $ "A2_REPR_AG/A2_CBO/A2_CIVIL/A2_GRPDEP/A2_FRETISS/A2_INSCMU/A2_CONTPRE/A2_CPFIRP/A2_RETISI/A2_ISICM/A2_UFFIC/A2_TPREG/A2_SUBCON/A2_CPFRUR"
		ELSEIF Alltrim(SX3->X3_CAMPO) == "A2_CODPIS"
			AADD(aSA2,{Alltrim(SX3->X3_CAMPO),"01058", Nil})
		ELSEIF Alltrim(SX3->X3_CAMPO) == "A2_MINIRF"
			AADD(aSA2,{Alltrim(SX3->X3_CAMPO),"2", Nil})
		ELSEIF Alltrim(SX3->X3_CAMPO) $ "A2_MCOMPRA/A2_NROCOM/A2_SALDUP/A2_SALDUPM"
			AADD(aSA2,{Alltrim(SX3->X3_CAMPO),0, Nil})
		ELSEIF Alltrim(SX3->X3_CAMPO) $ "A2_PRICOM/A2_ULTCOM"
			AADD(aSA2,{Alltrim(SX3->X3_CAMPO),CTOD(""), Nil})
		ELSE
			cCampo := "XSA2->"+Alltrim(SX3->X3_CAMPO)
			xCampo := NIL
			xCampo := &cCampo
			IF SX3->X3_TIPO=="C"  // Evitar erro de campos com tamanhos maiores em campos menores
				xCampo := TRIM(xCampo)
			ELSEIF SX3->X3_TIPO=="D" 
				xCampo := STOD(xCampo)
			ENDIF
			IF EMPTY(xCampo) .AND. !EMPTY(SX3->X3_RELACAO)
				xCampo := &(SX3->X3_RELACAO)
			ENDIF
			AADD(aSA2,{Alltrim(SX3->X3_CAMPO),xCampo, Nil})
			//AADD(aSA2,{Alltrim(SX3->X3_CAMPO),IIF(SX3->X3_TIPO=="D",CTOD(xCampo),IIF(!EMPTY(xCampo),xCampo,IIF(!EMPTY(SX3->X3_RELACAO),&(SX3->X3_RELACAO),xCampo))), Nil})
		ENDIF
	ENDIF
	SX3->(dbSkip())
Enddo
*/

XSA2->(DbCloseArea())

Begin Transaction 

	MSExecAuto({|x,y| MATA020(x,y)},aSA2,3)

	IF lMsErroAuto
	   	DisarmTransaction()
		MostraErro()
	Else
		MSGINFO("Fornecedor copiado com sucesso!! código: "+SA2->A2_COD+"  Loja: "+SA2->A2_LOJA+" - "+SA2->A2_NOME)
	Endif
End Transaction

Return nil


Static Function  ValidPerg(cPerg)
Local i,j
Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Digitar o  CNPJ ?","Digitar o  CNPJ ?","Digitar o  CNPJ ?" ,"mv_ch1","C",14,0,0,"G","NaoVazio()","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})

For i:=1 to Len(aRegistros)
	If !dbSeek(cPerg+aRegistros[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegistros[i])
				FieldPut(j,aRegistros[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

RestArea(aArea)

Return(NIL)
