#Include 'Protheus.ch'
#Include 'FWEditPanel.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} CMVC_08
Exemplo de programa MVC sem uso de dicionario de dados
@author Juliane Venteu
@since 04/04/2017
/*/
//-------------------------------------------------------------------
User Function MVCC5MUN()
	//If MsgYesNo('Deseja executar exemplo com load?')
		FWExecView("Informações para Faturamento","MVCC5MUN",3,,{|| .T.},,85)
	//Else
	//	FWExecView("Titulo","MVCC5MUN",3,,{|| .T.},,50)
	//EndIf
Return


Static Function ModelDef()
Local oModel
Local oStr := getModelStruct()
	oModel := MPFormModel():New('MLDC5MUN',,,{|oModel| Commit(oModel) })
	oModel:SetDescription('Exemplo Modelo sem SXs')

	oModel:AddFields("MASTER",,oStr,,,{|| Load() })
	oModel:getModel("MASTER"):SetDescription("DADOS")
	oModel:SetPrimaryKey({})


Return oModel

static function getModelStruct()
Local oStruct := FWFormModelStruct():New()
	
	oStruct:AddField('UF'            ,'UF'             , 'ESTPRES', 'C', 02, 0,{ |oMdl| ExistCpo("SX5","12"+oMdl:GetValue("ESTPRES"))},,{}, .T., , .F., .F., .F., , )
	oStruct:AddField('Cód. Município','Cód. Município' , 'MUNPRES', 'C', 07, 0,{ |oMdl| ExistCpo("CC2",oMdl:GetValue("ESTPRES")+oMdl:GetValue("MUNPRES"))};
	                                                                                                                                  ,,{}, .T., , .F., .F., .F., , )
	oStruct:AddField('Município'     ,'Município'      , 'DESCMUN', 'C', 60, 0,                                                       ,,{}, .F., , .F., .F., .F., , )
	oStruct:AddField('Nota Avulsa'   ,'Selecionar'     , 'AVULSA' , 'C', 01, 0,{ |oMdl| oMdl:GetValue("AVULSA") $ "SN"}               ,,{}, .T., , .F., .F., .F., , )

	//Adicionando Gatilhos
	oStruct:AddTrigger('MUNPRES' , 'DESCMUN'    , {|| .T.} , {|oMdl| FExeTrg(oMdl,'CC2_MUN','ESTPRES','MUNPRES'  )})

	// Popula os Campos Virtuais
	//oStruct:SetProperty('DESCMUN'    ,MODEL_FIELD_INIT,{|o|U_FPopVit( 'DESCMUN'    , ESTPRES+MUNPRES) )})



return oStruct

Static Function ViewDef()
Local oView
Local oModel := ModelDef() 
Local oStr:= getViewStruct()
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddField('FORM1' , oStr,'MASTER' ) 
	oView:CreateHorizontalBox( 'BOXFORM1', 100)
	oView:SetOwnerView('FORM1','BOXFORM1')
	oView:SetViewProperty('FORM1' , 'SETLAYOUT' , {FF_LAYOUT_VERT_DESCR_TOP,3} ) 
	oView:EnableTitleView('FORM1' , 'Informe o município que foram prestados os serviços' ) 
Return oView


static function getViewStruct()
Local oStruct := FWFormViewStruct():New()
	oStruct:AddField( 'ESTPRES','1','UF'            ,'UF'            ,, 'Get' ,"@!",,"12"    ,   ,,,,,,,, )
	oStruct:AddField( 'MUNPRES','2','Cod. Município','Cod. Município',, 'Get' ,    ,,"CC2"   ,   ,,,,,,,, )
	oStruct:AddField( 'DESCMUN','3','Município'     ,'Município'     ,, 'Get' ,    ,,        ,.F.,,,,,,,, )
	oStruct:AddField( 'AVULSA' ,'4','Nota Avulsa'   ,'Nota Avulsa'   ,, 'Get' ,    ,,        ,   ,,,,,,,, )
return oStruct

/*
Static Function getArq(oField)
Local cArq := cGetFile( '*.txt' , 'Textos (TXT)', 1, 'C:\', .T.,,.T., .T. )
	
	If !Empty(cArq)
		oField:SetValue("ARQ",cArq)
	EndIf
	
Return 


Static Function getDir(oField)
Local cDir := cGetFile( '*' , 'Diretorio Destino', 1, 'C:\', .T.,nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ) ,.T., .T. )
	
	If !Empty(cDir)
		oField:SetValue("DEST",cDir)
	EndIf
	
Return 
*/

Static Function Commit(oModel)

Local cEstPres := oModel:GetValue("MASTER", "ESTPRES")
Local cMunPres := oModel:GetValue("MASTER", "MUNPRES")	
	
Return lRet


Static Function Load()
Local aLoad := {}
   aAdd(aLoad, {"SP","     ",SPACE(60),"N"}) //dados
   aAdd(aLoad, 0) //recno
      
Return aLoad


// C5_ESTPRES ExistCpo("SX5","12"+M->C5_ESTPRES)  F3 12
// C5_MUNPRES F3 CC2



STATIC FUNCTION FExeTrg(oMdl,cCpoOri, cCpoDes, cCpoDes1, cCpoDes2 )

//LOCAL oMdlRef    := FWModelActive()
//LOCAL oMdlC5MUN  := oMdlRef:GetModel('MLDC5MUN')
LOCAL cRetTrg    := ''                           

DEFAULT cCpoDes2 := ''
DEFAULT cCpoDes3 := ''

IF cCpoOri == 'CC2_MUN'
	cRetTrg := Posicione("CC2",1,xFilial("CC2")+oMdl:GetValue(cCpoDes)+oMdl:GetValue(cCpoDes1),"CC2_MUN") 
ENDIF

Return cRetTrg
