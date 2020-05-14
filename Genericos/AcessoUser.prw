#include 'Protheus.ch'
#Include 'TOTVS.ch'

#define ENTER chr(13)+chr(10)
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACESSOUSERºAutor  ³Kanaãm L. R. R.     º Data ³  11/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica o acesso dos usuários do sistema.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³  MOTIVO                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º11/06/12  ³Kanaãm LRR³ Desenvolvimento da Rotina                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º26/02/13  ³Kanaãm LRR³ adição de tela de filtro                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//*------------------------*
User Function AcessoUser()
//*------------------------*
Local   oDlg,;
        oReport,;
        bOk        := {|| oDlg:End()},;
        bCancel    := {|| oDlg:End()},;
        aTb_Campos := {}

Local   aButtons   := {{"",;
                        {|| Processa({|| oReport := ReportDef(),oReport:PrintDialog()},'Imprimindo Dados...')},;
                         "Imprimir",;
                         "Imprimir"}}

Private oTmpTb1,oTmpTb2,oTmpTb3
Private lBloqueados := .T.

Private aUsers     := {},;
        aModulos   := {},;
        aGrups     := {},;
        aGrpUser   := {},;
        oMarkUser,;
        oMarkModulo,;
        oMarkAcesso,;
        cMarca     := GetMark(),;
        lInverte   := .F.

Private lMarca    := .T.,;
        lRetrato  := .T.,;
        lGRUPO	  := .T.,;
        cModDe    := Space(2),;
        cModAte   := "99",;
        cUserDe   := Space(6),;
        cUserAte  := "999999",;
        cRotDe    := Space(12),;
        cRotAte   := "ZZZZZZZZZZZZ",;
        aColPrint := {.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.}//variáveis de filtro

If !Filtro()
   Return
Else
   cModDe    := StrZero(Val(cModDe),2)
   cModAte   := StrZero(Val(cModAte),2)
   cUserDe   := StrZero(Val(cUserDe),6)
   cUserAte  := StrZero(Val(cUserAte),6)
EndIf

Processa({|| aUsers := AllUsers(),;
             aModulos := retModName(),;
             aGrups := AllGroups(),;
             aAdd(aModulos,{99,"SIGACFG","Configurador",.T.,"CFGIMG",99}),;
             CriaWork(),;
             PreencheWk()},;
             'Preparando Ambiente...')

WKUSERS->(dbGoTop())
WKMODULOS->(dbGoTop())
WKACESSO->(dbGoTop())

oMainWnd:ReadClientCoords()
Define MsDialog oDlg Title "Acesso de Usuários" From oMainWnd:nTop+10,oMainWnd:nLeft+5 To oMainWnd:nBottom-20,oMainWnd:nRight-10 Of oMainWnd Pixel

   aPos := {oMainWnd:nTop+2,oMainWnd:nLeft+10,290,110+10}
   aTb_Campos      := CriaTbCpos("USERS")
   oMarkUser       := MsSelect():New("WKUSERS","XWKMARCA",,aTb_Campos,.F.,@cMarca,aPos)
   oMarkUser:bAval := {|| MarcaCpo(.F.,"WKUSERS")}
   oMarkUser:oBrowse:lCanAllMark := .T.
   oMarkUser:oBrowse:lHasMark    := .T.
   oMarkUser:oBrowse:bAllMark := {|| MarcaCpo(.T.,"WKUSERS")}
   oMarkUser:oBrowse:bChange := {||oMarkModulo:oBrowse:SetFilter("XCODUSER",WKUSERS->XCODUSER,WKUSERS->XCODUSER),;
                                   oMarkModulo:oBrowse:Refresh(),;
                                   oMarkAcesso:oBrowse:SetFilter("XCODUSMOD",WKMODULOS->(XCODUSER+XCODMODULO),WKMODULOS->(XCODUSER+XCODMODULO)),;
                                   oMarkAcesso:oBrowse:Refresh()}
   //
   aPos := {oMainWnd:nTop+2,111+10,290,210+10}
   aTb_Campos        := CriaTbCpos("MODULOS")
   oMarkModulo       := MsSelect():New("WKMODULOS","XWKMARCA",,aTb_Campos,.F.,@cMarca,aPos)
   oMarkModulo:bAval := {|| MarcaCpo(.F.,"WKMODULOS")}
   oMarkModulo:oBrowse:lCanAllMark := .T.
   oMarkModulo:oBrowse:lHasMark    := .T.
   oMarkModulo:oBrowse:bAllMark := {|| MarcaCpo(.T.,"WKMODULOS")}
   oMarkModulo:oBrowse:SetFilter("CODUSER",WKUSERS->XCODUSER,WKUSERS->XCODUSER)
   oMarkModulo:oBrowse:bChange := {||oMarkAcesso:oBrowse:SetFilter("XCODUSMOD",WKMODULOS->(XCODUSER+XCODMODULO),WKMODULOS->(XCODUSER+XCODMODULO)),;
                                     oMarkAcesso:oBrowse:Refresh()}
   
   //   
   aPos := {oMainWnd:nTop+2,211+10,290,650}
   aTb_Campos        := CriaTbCpos("ACESSO")
   oMarkAcesso       := MsSelect():New("WKACESSO","XWKMARCA",,aTb_Campos,.F.,@cMarca,aPos)
   oMarkAcesso:bAval := {|| MarcaCpo(.F.,"WKACESSO")}
   oMarkAcesso:oBrowse:lCanAllMark := .T.   
   oMarkAcesso:oBrowse:lHasMark    := .T.
   oMarkAcesso:oBrowse:bAllMark := {|| MarcaCpo(.T.,"WKACESSO")}
   oMarkAcesso:oBrowse:SetFilter("XCODUSMOD",WKMODULOS->(XCODUSER+XCODMODULO),WKMODULOS->(XCODUSER+XCODMODULO))

Activate MsDialog oDlg On Init ( EnchoiceBar(oDlg,bOk,bCancel,,aButtons), ,, )//
//
//WKUSERS->(dbCloseArea())
//WKMODULOS->(dbCloseArea())
//WKACESSO->(dbCloseArea())

oTmpTb1:Delete()
oTmpTb2:Delete()
oTmpTb3:Delete()

//
Return

/*
Funcao      : Filtro
Objetivos   : Filtra os dados que serão buscados
Autor       : Kanaãm L. R. Rodrigues 
Data/Hora   : 26/02/2013
*/
*----------------------*
Static Function Filtro()
*----------------------*
Local lOk     := .F.
Local bOk     := {|| lOk := .T., oDlg:End()}
Local bCancel := {|| lOk := .F., oDlg:End()}
Local nLin    := 40
Local nCol    := 20
Local lChk1   := lChk2 := lChk3 := lChk4 := lChk5 := lChk6 := lChk7 := lChk8 := lChk9 := lChk10 := lChk11 := lChk12 :=.T.

Local oDlg, oChkBox1, oChkBox2, oChkBox3, oChkBox4, oChkBox5, oChkBox6, oChkBox7, oChkBox8, oPanel,;
      oModDe, oModAte, oUserDe, oUserAte, oRotDe, oRotAte

oMainWnd:ReadClientCoords()
Define MsDialog oDlg Title "Acesso de Usuários" From oMainWnd:nTop+60,oMainWnd:nLeft+5 To oMainWnd:nBottom-10,oMainWnd:nRight-10 Of oMainWnd Pixel
    *
    oPanel = TPanel():New(nLin,nCol-5,"Colunas a serem impressas",oDlg,,.F.,,,,200,45,.F.,.T.)
    nLin += 15
    @ nLin,nCol     CheckBox oChkBox1 Var lChk1 Prompt "Usuário"    On Click ( aColPrint[1] := !aColPrint[1] ) Size 130,9 Of oDlg Pixel 
    @ nLin,nCol+40  CheckBox oChkBox2 Var lChk2 Prompt "Módulo"     On Click ( aColPrint[2] := !aColPrint[2] ) Size 130,9 Of oDlg Pixel 
    @ nLin,nCol+80  CheckBox oChkBox3 Var lChk3 Prompt "Menu"       On Click ( aColPrint[3] := !aColPrint[3] ) Size 130,9 Of oDlg Pixel     
    @ nLin,nCol+120 CheckBox oChkBox4 Var lChk4 Prompt "Sub-Menu"   On Click ( aColPrint[4] := !aColPrint[4] ) Size 130,9 Of oDlg Pixel 
    @ nLin,nCol+160 CheckBox oChkBox4 Var lChk4 Prompt "Bloqueados" On Click ( lBloqueados  := !lBloqueados  ) Size 130,9 Of oDlg Pixel 
    nLin += 15
    @ nLin,nCol     CheckBox oChkBox5 Var lChk5 Prompt "Rotina"     On Click ( aColPrint[5] := !aColPrint[5] ) Size 130,9 Of oDlg Pixel 
    @ nLin,nCol+40  CheckBox oChkBox6 Var lChk6 Prompt "Acesso"     On Click ( aColPrint[6] := !aColPrint[6] ) Size 130,9 Of oDlg Pixel 
    @ nLin,nCol+80  CheckBox oChkBox7 Var lChk7 Prompt "Função"     On Click ( aColPrint[7] := !aColPrint[7] ) Size 130,9 Of oDlg Pixel 
    @ nLin,nCol+120 CheckBox oChkBox8 Var lChk8 Prompt "Menu(.xnu)" On Click ( aColPrint[8] := !aColPrint[8] ) Size 130,9 Of oDlg Pixel     
    @ nLin,nCol+160 CheckBox oChkBox11 Var lChk11 Prompt "Grupos" On Click ( lGRUPO := !lGRUPO ) Size 130,9 Of oDlg Pixel     
    *
    nLin += 30
    *
    @ nLin,nCol     CheckBox oChkBox9 Var lChk9 Prompt "Marcado/Desmarcado?" On Click ( lMarca := !lMarca ) Size 130,9 Of oDlg Pixel 
    nLin += 15
    @ nLin,nCol     CheckBox oChkBox10 Var lChk10 Prompt "Retrato/Paisagem" On Click ( lRetrato := !lRetrato ) Size 130,9 Of oDlg Pixel     
	*
	nLin += 30
    @ nLin,nCol    Say  'Módulo De: '                                                         Of oDlg Pixel                                  	
    @ nLin,nCol+45 MsGet oModDe  Var cModDe  VALID (Vazio() .OR. cModDe >="01")   Size 60,09  Of oDlg Pixel  
  	nLin += 15
    @ nLin,nCol    Say  'Módulo Até: '                                                         Of oDlg Pixel                                  	
    @ nLin,nCol+45 MsGet oModAte Var cModAte VALID (!Vazio() .AND. cModAte <="99") Size 60,09  Of oDlg Pixel  
    nLin += 30
    @ nLin,nCol    Say  'Usuário De: '                                                               Of oDlg Pixel                                  	
    @ nLin,nCol+45 MsGet oUserDe  Var cUserDe  VALID (Vazio() .OR. cUserDe >="000001")   Size 60,09  Of oDlg Pixel  
  	nLin += 15
    @ nLin,nCol    Say  'Usuário Até: '                                                               Of oDlg Pixel                                  	
    @ nLin,nCol+45 MsGet oUserAte Var cUserAte VALID (!Vazio() .AND. cUserAte <="999999") Size 60,09  Of oDlg Pixel  
    nLin += 30
    @ nLin,nCol    Say  'Rotina De: '                                                                    Of oDlg Pixel                                  	
    @ nLin,nCol+45 MsGet oRotDe  Var cRotDe Picture "@!"                                     Size 60,09  Of oDlg Pixel  
  	nLin += 15
    @ nLin,nCol    Say  'Rotina Até: '                                                                                Of oDlg Pixel
    @ nLin,nCol+45 MsGet oRotAte Var cRotAte Picture "@!" VALID (!Vazio() .AND. cRotAte <="ZZZZZZZZZZZZ") Size 60,09  Of oDlg Pixel  
    *
Activate MsDialog oDlg On Init ( EnchoiceBar(oDlg,bOk,bCancel,,), ,, )

Return lOk

/*
Funcao      : CriaWork
Objetivos   : Cria Works para criação dos msselects
Autor       : Kanaãm L. R. Rodrigues 
Data/Hora   : 11/06/2012
*/
*--------------------------*
Static Function CriaWork()
*--------------------------*
Local aSemSx3 := {}
//Local cFile
//
//Cria work da coluna Usuários
aAdd(aSemSx3,{"XWKMARCA","C",02,0})
aAdd(aSemSx3,{"XCODUSER","C",06,0})
aAdd(aSemSx3,{"XUSER"   ,"C",30,0})
aAdd(aSemSx3,{"XBLOQ"   ,"C",01,0})
aAdd(aSemSx3,{"XDEPART" ,"C",40,0})
aAdd(aSemSx3,{"XEMAIL"  ,"C",70,0})
aAdd(aSemSx3,{"XCARGO"  ,"C",40,0})
aAdd(aSemSx3,{"XDATAINC","D",08,0})
//
///cFile := E_CriaTrab(,aSemSX3,"WKUSERS")
///IndRegua("WKUSERS",cFile+OrdBagExt(),"XCODUSER")
///Set Index To (cFile+OrdBagExt())

oTmpTb1 := FWTemporaryTable():New( "WKUSERS")
oTmpTb1:SetFields( aSemSX3 )
oTmpTb1:AddIndex("indice1", {"XCODUSER"} )
oTmpTb1:Create()

//Cria work da coluna Módulos
aSemSx3 := {}
aAdd(aSemSx3,{"XWKMARCA"  ,"C",02,0})
aAdd(aSemSx3,{"XCODUSER"  ,"C",06,0})
aAdd(aSemSx3,{"XCODMODULO","C",02,0})
aAdd(aSemSx3,{"XMODULO"   ,"C",30,0})

//cFile := E_CriaTrab(,aSemSX3,"WKMODULOS")
//IndRegua("WKMODULOS",cFile+OrdBagExt(),"XCODUSER+CODMODULO")
//Set Index To (cFile+OrdBagExt())

oTmpTb2 := FWTemporaryTable():New( "WKMODULOS")
oTmpTb2:SetFields( aSemSX3 )
oTmpTb2:AddIndex("indice2", {"XCODUSER","XCODMODULO"} )
oTmpTb2:Create()


//Cria work da coluna Acessos
aSemSx3 := {}
aAdd(aSemSx3,{"XWKMARCA"  ,"C",02,0})
aAdd(aSemSx3,{"XCODUSMOD" ,"C",08,0})
aAdd(aSemSx3,{"XUSER"     ,"C",30,0})
aAdd(aSemSx3,{"XBLOQ"     ,"C",01,0})
aAdd(aSemSx3,{"XDEPART"   ,"C",40,0})
aAdd(aSemSx3,{"XEMAIL"    ,"C",70,0})
aAdd(aSemSx3,{"XCARGO"    ,"C",40,0})
aAdd(aSemSx3,{"XDATAINC"  ,"D",08,0})
aAdd(aSemSx3,{"XMODULO"   ,"C",30,0})
aAdd(aSemSx3,{"XMENU"     ,"C",12,0})
aAdd(aSemSx3,{"XSUBMENU"  ,"C",25,0})
aAdd(aSemSx3,{"XROTINA"   ,"C",25,0})
aAdd(aSemSx3,{"XFUNCAO"   ,"C",25,0})
aAdd(aSemSx3,{"XXNU"      ,"C",40,0})
aAdd(aSemSx3,{"XACESSO"   ,"C",10,0})
aAdd(aSemSx3,{"XTIPO"     ,"C",01,0})

//cFile := E_CriaTrab(,aSemSX3,"WKACESSO")
//IndRegua("WKACESSO",cFile+OrdBagExt(),"XCODUSMOD")
//Set Index To (cFile+OrdBagExt())

oTmpTb3 := FWTemporaryTable():New( "WKACESSO")
oTmpTb3:SetFields( aSemSX3 )
oTmpTb3:AddIndex("indice3", {"XCODUSMOD"} )
oTmpTb3:Create()

Return

/*
Funcao      : CriaTbCpos
Objetivos   : Cria tbCampos para os msSelects
Autor       : Kanaãm L. R. Rodrigues 
Data/Hora   : 11/06/2012
*/
*--------------------------*
Static Function CriaTbCpos(cTipo)
*--------------------------*
Local aTbCpos := {}
//
aAdd(aTbCpos,{"XWKMARCA",,""       ,""} )
//
If cTipo == "USERS"
   //
   aAdd(aTbCpos,{"XUSER"   ,,"Usuário",""} )
   aAdd(aTbCpos,{"XDEPART" ,,"Departamento",""} )
   aAdd(aTbCpos,{"XBLOQ"   ,,"Bloqueado",""} )
   aAdd(aTbCpos,{"XEMAIL"  ,,"E-Mail",""})
   aAdd(aTbCpos,{"XCARGO"  ,,"Cargo",""})
   aAdd(aTbCpos,{"XDATAINC",,"Inclusão",""})
   //
ElseIf cTipo == "MODULOS"                  
   //
   aAdd(aTbCpos,{"XMODULO" ,,"Módulo",""} )
   //
ElseIf cTipo == "ACESSO"
   //
   aAdd(aTbCpos,{"XMENU"   ,,"Menu"    ,""} )
   aAdd(aTbCpos,{"XSUBMENU",,"Sub-Menu",""} )
   aAdd(aTbCpos,{"XROTINA" ,,"Rotina"  ,""} )
   aAdd(aTbCpos,{"XACESSO" ,,"Acesso"  ,""} )   
   aAdd(aTbCpos,{"XTIPO"   ,,"Tipo"    ,""} )   
   //
EndIf
//
Return aTbCpos

/*
Funcao      : PreencheWk
Objetivos   : Preenche works com dados de usuários, módulos e menus.
Autor       : Kanaãm L. R. Rodrigues 
Data/Hora   : 11/06/2012
*/
*--------------------------*
Static Function PreencheWk()
*--------------------------*
Local   nTamMod  := 0//ref 26/02/13 - adicionadas as 2 variáveis de controle para melhoria de performance.
Local   nTamGrup := 0 
Local   nTamUser := Len(aUsers)

Private i        := 2 //começa em 2 para pular o adm que tem acesso full
Private j        := 1       
Private lAppUser := .F.
Private lAppMod  := .F.

ProcRegua(nTamUser-1)
//Loop nos usuários
For i := 2 To nTamUser
   IncProc("Carregando Usuário "+AllTrim(Str(i-1))+" de "+AllTrim(Str(nTamUser-1)))
   //se user estiver inativo ou fora do range de filtro passa direto
   If (!aUsers[i][1][17] .OR. lBloqueados) .AND. cUserDe <= aUsers[i][1][1] .AND. cUserAte >= aUsers[i][1][1]
      lAppUser := .F.
      nTamMod := Len(aUsers[i][3])
      //Loop nós módulos
      For j:=1 To nTamMod
         //Verifica se o usuário tem acesso a esse módulo e o módulo está no ragen do filtro
         If SubStr(aUsers[i][3][j],3,1) != "X" .AND. cModDe <= SubStr(aUsers[i][3][j],1,2) .AND. cModAte >= SubStr(aUsers[i][3][j],1,2)
            lAppMod := .F.
            //preenche work de acesso passando o nome do xnu
            preencMenu(SubStr(aUsers[i][3][j],4,Len(aUsers[i][3][j])-3),"U",SubStr(aUsers[i][3][j],1,2))
            If lAppMod
               //preenche work de módulos
               WKMODULOS->(dbAppend())
               WKMODULOS->XWKMARCA   := If(lMarca,cMarca,"")
               WKMODULOS->XCODUSER   := aUsers[i][1][1] //Código do user
               WKMODULOS->XCODMODULO := SubStr(aUsers[i][3][j],1,2) //Código do módulo
               WKMODULOS->XMODULO    := retModulo(Val(WKMODULOS->XCODMODULO)) //função que retorna a descrição do módulo de acordo com o código passado.
               lAppUser := .T.
            EndIf
         EndIf
      Next j
      
      IF lGRUPO
      	aGrpUser := aUsers[i][1][10]
      	nTamGrup := Len(aGrpUser)
      	//Loop nós grupos
      	FOR _IX := 1 TO nTamGrup
      
      		aGrups:= FWGrpMenu(aGrpUser[_IX])

   			nTamMod := Len(aGrups)

   			//Loop nós módulos Grupos
   			For j:=1 To nTamMod
         		//Verifica se o usuário tem acesso a esse módulo e o módulo está no ragen do filtro
         		If SubStr(aGrups[j],3,1) != "X" .AND. cModDe <= SubStr(aGrups[j],1,2) .AND. cModAte >= SubStr(aGrups[j],1,2)
            		lAppMod := .F.
            		//preenche work de acesso passando o nome do xnu
            		preencMenu(SubStr(aGrups[j],4,Len(aGrups[j])-3),"G",SubStr(aGrups[j],1,2))
            		If lAppMod
            			//preenche work de módulos
            			WKMODULOS->(dbAppend())
            			WKMODULOS->XWKMARCA   := If(lMarca,cMarca,"")
            			WKMODULOS->XCODUSER   := aUsers[i][1][1] //Código do user
             			WKMODULOS->XCODMODULO:= SubStr(aGrups[j],1,2) //Código do módulo
            			WKMODULOS->XMODULO    := retModulo(Val(WKMODULOS->XCODMODULO)) //função que retorna a descrição do módulo de acordo com o código passado.
            			lAppUser := .T.
            		EndIf
        	 	EndIf
    	 	Next j
	      Next _IX
      ENDIF
      If lAppUser
         //preenche work de usuários
         WKUSERS->(dbAppend())
         WKUSERS->XWKMARCA := If(lMarca,cMarca,"")
         WKUSERS->XUSER    := aUsers[i][1][4]  //Nome do user
         WKUSERS->XBLOQ    := iIf(aUsers[i][1][17],"S","N")  //Bloqueado
         WKUSERS->XDEPART  := aUsers[i][1][12] //Departamento
         WKUSERS->XCODUSER := aUsers[i][1][1]  //Código do user
         WKUSERS->XEMAIL   := aUsers[i][1][14] //E-Mail
         WKUSERS->XCARGO   := aUsers[i][1][13] //Cargo
         WKUSERS->XDATAINC := aUsers[i][1][24] //Data Inc
      EndIf
   EndIf
Next i

Return

/*
Funcao      : retModulo
Objetivos   : retorna a descrição do módulo de acordo com o código passado.
Autor       : Kanaãm L. R. Rodrigues 
Data/Hora   : 11/06/2012
*/
*--------------------------*
Static Function retModulo(nModulo)
*--------------------------*
Local nPos     := 0
//
nPos := aScan(aModulos, {|x| x[1]==nModulo})
//
Return If(nPos>0,aModulos[nPos][3],"Indefinido")


/*
Funcao      : preencMenu
Objetivos   : preenche as informações de acesso de acordo com o xnu
Autor       : Kanaãm L. R. Rodrigues 
Data/Hora   : 11/06/2012
*/
*--------------------------*
Static Function preencMenu(cFile,cTPMNU,cModulo)
*--------------------------*
Local nHandle  := -1
Local lMenu    := .F.
Local lSubMenu := .F.
Local lAppMenu := .T.
Local lAppSub  := .T.
Local cMenu    := ""
Local cSubMenu := ""
Local cRotina  := ""
Local cAcesso  := ""
Local cFuncao  := ""
Local cVisual  := "xx"+Space(3)+"xxxxx/xx"+Space(4)+"xxxx/xx"+Space(5)+"xxx/xx"+Space(6)+"xx/xx"+Space(7)+"x/xx"+Space(8)

//abre o arquivo xnu
nHandle := Ft_FUse(cFile)
//se for -1 ocorreu erro na abertura
If nHandle != -1
   Ft_FGoTop()
   While !Ft_FEof() 
      //
      cAux := Ft_FReadLn()
      //fechando alguma tag, se for menu ou sub-menu muda a flag
      If "</MENU>" $ Upper(cAux)
         If lSubMenu
            lSubMenu := .F.
            lAppSub  := .T.
         ElseIf lMenu
            lMenu    := .F.
            lAppMenu := .T.
         EndIf
      //encontrou tag menu (serve para menu e sub-menu) e não é fechamento
      ElseIf "MENU " $ Upper(cAux)//o espaço depois de "MENU " é para definir a abertura NÃO REMOVER
         //verifica flag de abertura e fechamento de menu/sub-menu
         If !lMenu
            lMenu := .T.
         ElseIf !lSubMenu
            lSubMenu := .T.
         EndIf
         If "HIDDEN" $ Upper(cAux) .OR. "DISABLE" $ Upper(cAux)
            If lMenu .AND. !lSubMenu
               lAppMenu := .F.
            ElseIf lSubMenu
               lAppSub  := .F.
            EndIf
         EndIf
         Ft_FSkip()
         cAux := Ft_FReadLn()
         //captura o que está entre as tags 
         cAux := retTag(cAux)
         If lMenu .AND. !lSubMenu
            cMenu := StrTran(cAux,"&","")
         ElseIf lSubMenu
            cSubMenu := StrTran(cAux,"&","")
         EndIf
      //Faz o tratamento das rotinas de menu e appenda a work
      ElseIf "MENUITEM " $ Upper(cAux)
         If "HIDDEN" $ Upper(cAux) .OR. "DISABLE" $ Upper(cAux) .OR. !lAppSub .OR. !lAppMenu
            cAcesso := "Sem Acesso"
            Ft_FSkip()
            cAux := Ft_FReadLn()
            nIni := At(">", cAux)+1
            nFim := Rat("<",cAux)
            //captura o que está entre as tags 
            cRotina := RetTag(cAux)
            //captura o nome da função
            While !("FUNCTION" $ Upper(Ft_FReadLn())) .AND. !Ft_FEof()
               Ft_FSkip()
            EndDo
            cAux := Ft_FReadLn()
            cFuncao := RetTag(cAux)
         Else
            Ft_FSkip()
            cAux := Ft_FReadLn()
            //captura o que está entre as tags 
            cRotina := RetTag(cAux)   
            //captura o nome da função
            While !("FUNCTION" $ Upper(Ft_FReadLn())) .AND. !Ft_FEof()
               Ft_FSkip()
            EndDo
            cAux := Ft_FReadLn()
            cFuncao := RetTag(cAux)
            //captura o acesso da rotina
            While !("ACCESS" $ Upper(Ft_FReadLn())) .AND. !Ft_FEof()
               Ft_FSkip()
            EndDo
            cAux := Ft_FReadLn()
            cAux := RetTag(cAux)
            If cAux == "xxxxxxxxxx"
               cAcesso := "Manutenção"
            ElseIf cAux $ "xx   x    /xx x  xx  "  .AND.  UPPER(ALLTRIM(cRotina)) = UPPER("Documento Entrada") 
               cAcesso := "Classifica Doc."
            ElseIf cAux $ cVisual
               cAcesso := "Visualizar"
            Else
               cAcesso := "Sem Acesso"
            EndIf
         EndIf
         If AllTrim(cRotDe) <= AllTrim(cFuncao) .AND. AllTrim(cRotAte) >= AllTrim(cFuncao)
            WKACESSO->(dbAppend())
            WKACESSO->XWKMARCA   := If(lMarca,cMarca,"")
            WKACESSO->XCODUSMOD  := aUsers[i][1][1]+SubStr(cModulo,1,2) //Código do user + Código do módulo
            WKACESSO->XUSER      := aUsers[i][1][4]  //Nome do user
            WKACESSO->XDEPART    := aUsers[i][1][12] //Departamento
            WKACESSO->XMODULO    := retModulo(Val(SubStr(cModulo,1,2))) //Nome do Módulo
            WKACESSO->XMENU      := cMenu
            WKACESSO->XSUBMENU   := cSubMenu
            WKACESSO->XROTINA    := cRotina
            WKACESSO->XACESSO    := cAcesso
            WKACESSO->XTIPO      := cTPMNU
            WKACESSO->XFUNCAO    := cFuncao
            WKACESSO->XXNU       := cFile

            WKACESSO->XBLOQ      := iIf(aUsers[i][1][17],"S","N")  //Bloqueado
            WKACESSO->XEMAIL     := aUsers[i][1][14] //E-Mail
            WKACESSO->XCARGO     := aUsers[i][1][13] //Cargo
            WKACESSO->XDATAINC   := aUsers[i][1][24] //Data Inc

            lAppMod := .T.
         EndIf
      EndIf
      Ft_FSkip()      
   EndDo
   Ft_Fuse()
EndIf

Return

/*
Funcao      : RetTag
Objetivos   : Retorna o conteúdo das tags da linha passada EX:<Title lang="pt">TESTE</Title> o retorno será "TESTE"
Autor       : Kanaãm L. R. Rodrigues 
Data/Hora   : 07/11/2012
*/
*----------------------------*
Static Function RetTag(cLinha)  
*----------------------------*
Local nIni := At(">", cLinha)+1
Local nFim := Rat("<",cLinha)
//
Return (SubStr(cLinha,nIni,(nFim-nIni)))
                            

/*
Funcao      : MarcaCpo
Objetivos   : Marca/Desmarca Campos
Autor       : Kanaãm L. R. Rodrigues 
Data/Hora   : 13/06/2012
*/
*------------------------------*
Static Function MarcaCpo(lTodos, cAlias)
*------------------------------*
Local nRegUser  := WKUSERS->(RecNo())
Local nRegMod   := WKMODULOS->(RecNo())
Local nRegAcess := WKACESSO->(RecNo())
Local cMark     := If(Empty((cAlias)->XWKMARCA),cMarca,"")
//
If lTodos
   If cAlias == "WKUSERS"
      WKUSERS->(dbGoTop())
      While WKUSERS->(!Eof())
         RecLock("WKUSERS",.F.)
         WKUSERS->XWKMARCA := cMark
         WKUSERS->(MsUnlock())
         WKUSERS->(dbSkip())
      EndDo
      WKMODULOS->(dbGoTop())
      While WKMODULOS->(!Eof())
         RecLock("WKMODULOS",.F.)
         WKMODULOS->XWKMARCA := cMark
         WKMODULOS->(MsUnlock())
         WKMODULOS->(dbSkip())
      EndDo
      WKACESSO->(dbGoTop())
      While WKACESSO->(!Eof())
         RecLock("WKACESSO",.F.)
         WKACESSO->XWKMARCA := cMark
         WKACESSO->(MsUnlock())
         WKACESSO->(dbSkip())
      EndDo
   ElseIf cAlias == "WKMODULOS" 
      WKMODULOS->(dbGoTop())
      WKMODULOS->(dbSeek(WKUSERS->XCODUSER))
      While WKMODULOS->(!Eof()) .AND. WKMODULOS->XCODUSER == WKUSERS->XCODUSER
         RecLock("WKMODULOS",.F.)
         WKMODULOS->XWKMARCA := cMark
         WKMODULOS->(MsUnlock())
         WKACESSO->(dbSeek(WKMODULOS->(XCODUSER+XCODMODULO)))
         While WKACESSO->(!Eof()) .AND. WKACESSO->XCODUSMOD == WKMODULOS->(XCODUSER+XCODMODULO)
            RecLock("WKACESSO",.F.)
            WKACESSO->XWKMARCA := cMark
            WKACESSO->(MsUnlock())
            WKACESSO->(dbSkip())
         EndDo
         WKMODULOS->(dbSkip())
      EndDo
      RecLock("WKUSERS",.F.)
      WKUSERS->XWKMARCA := cMark
      WKUSERS->(MsUnlock())
   ElseIf cAlias == "WKACESSO"
      WKACESSO->(dbGoTop())
      WKACESSO->(dbSeek(WKMODULOS->(XCODUSER+XCODMODULO)))
      While WKACESSO->(!Eof()) .AND. WKACESSO->XCODUSMOD == WKMODULOS->(XCODUSER+XCODMODULO)
         RecLock("WKACESSO",.F.)
         WKACESSO->XWKMARCA := cMark
         WKACESSO->(MsUnlock())
         WKACESSO->(dbSkip())
      EndDo
      If !Empty(cMark)
         RecLock("WKUSERS",.F.)
         WKUSERS->XWKMARCA := cMark
         WKUSERS->(MsUnlock())      
      EndIf
         RecLock("WKMODULOS",.F.)
         WKMODULOS->XWKMARCA := cMark
         WKMODULOS->(MsUnlock())
   EndIf
Else
   RecLock(cAlias,.F.)
   (cAlias)->XWKMARCA := cMark
   (cAlias)->(MsUnlock())
   If Empty(cMark) .AND. cAlias == "WKUSERS"
      WKMODULOS->(dbSeek(WKUSERS->XCODUSER))
      While WKMODULOS->XCODUSER == WKUSERS->XCODUSER .AND. WKMODULOS->(!Eof())
         RecLock("WKMODULOS",.F.)
         WKMODULOS->XWKMARCA := cMark
         WKMODULOS->(MsUnlock())
         WKACESSO->(dbSeek(WKMODULOS->(XCODUSER+XCODMODULO)))
         While WKACESSO->XCODUSMOD == WKMODULOS->(XCODUSER+XCODMODULO) .AND. WKACESSO->(!Eof())
            RecLock("WKACESSO",.F.)
            WKACESSO->XWKMARCA := cMark
            WKACESSO->(MsUnlock())
            WKACESSO->(dbSkip())
         EndDo
         WKMODULOS->(dbSkip())
      EndDo
   ElseIf Empty(cMark) .AND. cAlias == "WKMODULOS"
      WKACESSO->(dbSeek(WKMODULOS->(XCODUSER+XCODMODULO)))
      While WKACESSO->XCODUSMOD == WKMODULOS->(XCODUSER+XCODMODULO) .AND. WKACESSO->(!Eof())
         RecLock("WKACESSO",.F.)
         WKACESSO->XWKMARCA := cMark
         WKACESSO->(MsUnlock())
         WKACESSO->(dbSkip())
      EndDo
   ElseIf !Empty(cMark) .AND. cAlias == "WKACESSO"
     RecLock("WKMODULOS",.F.)
     WKMODULOS->XWKMARCA := cMark
     WKMODULOS->(MsUnlock())
     RecLock("WKUSERS",.F.)
     WKUSERS->XWKMARCA := cMark
     WKUSERS->(MsUnlock())         
   ElseIf !Empty(cMark) .AND. cAlias == "WKMODULOS"     
     RecLock("WKUSERS",.F.)
     WKUSERS->XWKMARCA := cMark
     WKUSERS->(MsUnlock())         
   EndIf
EndIf
//
WKUSERS->(dbGoTo(nRegUser))
WKMODULOS->(dbGoTo(nRegMod))
WKACESSO->(dbGoTo(nRegAcess))
oMarkUser:oBrowse:Refresh()
oMarkModulo:oBrowse:Refresh()
oMarkAcesso:oBrowse:Refresh()
//
Return


/*
Funcao      : ReportDef
Objetivos   : Define estrutura de impressão
Autor       : Kanaãm L. R. Rodrigues 
Data/Hora   : 13/06/2012
*/
*--------------------------*
Static Function ReportDef()
*--------------------------*
//
oReport := TReport():New("RELACESSO","Relatório de Acesso de Usuários","",;
                         {|oReport| ReportPrint(oReport)},"Este relatorio irá Imprimir o Relatório de Acesso de Usuários")

//Inicia o relatório como retrato
If lRetrato
   oReport:oPage:lLandScape := .F. 
   oReport:oPage:lPortRait := .T. 
Else
   oReport:oPage:lLandScape := .T. 
   oReport:oPage:lPortRait := .F. 
EndIf

//Define o objeto com a seção do relatório
oSecao  := TRSection():New(oReport,"LOG","WKACESSO",{})
//
If aColPrint[1]
   TRCell():New(oSecao,"XUSER"   ,"WKACESSO","Usuário"         ,""            ,30,,,"LEFT")
   TRCell():New(oSecao,"XBLOQ"   ,"WKACESSO","Bloq."           ,""            ,01,,,"LEFT")
   TRCell():New(oSecao,"XDEPART" ,"WKACESSO","Departamento"    ,""            ,40,,,"LEFT")
   TRCell():New(oSecao,"XEMAIL"  ,"WKACESSO","E-mail"          ,""            ,70,,,"LEFT")
   TRCell():New(oSecao,"XCARGO"  ,"WKACESSO","Cargo"           ,""            ,40,,,"LEFT")
   TRCell():New(oSecao,"XDATAINC","WKACESSO","Data Inc."       ,""            ,10,,,"LEFT")
EndIf
//
If aColPrint[2]
   TRCell():New(oSecao,"XMODULO" ,"WKACESSO","Módulo"          ,""            ,30,,,"LEFT")
EndIf
//
If aColPrint[3]
   TRCell():New(oSecao,"XMENU"   ,"WKACESSO","Menu"            ,""            ,12,,,"LEFT")
EndIf
//
If aColPrint[4]
   TRCell():New(oSecao,"XSUBMENU","WKACESSO","Sub-Menu"        ,""            ,25,,,"LEFT")
EndIf
//
If aColPrint[5]
   TRCell():New(oSecao,"XROTINA" ,"WKACESSO","Rotina"          ,""            ,25,,,"LEFT")
EndIf
//
If aColPrint[6]
   TRCell():New(oSecao,"XACESSO" ,"WKACESSO","Acesso"          ,""            ,10,,,"LEFT")
EndIf
//
If aColPrint[7]
   TRCell():New(oSecao,"XFUNCAO" ,"WKACESSO","Função"          ,""            ,15,,,"LEFT")
EndIf
//
If aColPrint[8]
   TRCell():New(oSecao,"XXNU"    ,"WKACESSO","XNU"             ,""            ,40,,,"LEFT")
   TRCell():New(oSecao,"XTIPO"   ,"WKACESSO","Tipo"            ,""            ,05,,,"LEFT")
EndIf
//

Return oReport


/*
Funcao      : ReportPrint
Objetivos   : Imprime os dados filtrados
Autor       : Kanaãm L. R. Rodrigues 
Data/Hora   : 05/06/2012
*/
*----------------------------------*
Static Function ReportPrint(oReport)
*----------------------------------*
//Inicio da impressão da seção.
oReport:Section("LOG"):Init()
oReport:SetMeter(WKACESSO->(LastRec()))

WKACESSO->(dbGoTop())
oReport:SkipLine(2)
Do While WKACESSO->(!EoF()) .And. !oReport:Cancel()
   If !Empty(WKACESSO->XWKMARCA)
      oReport:Section("LOG"):PrintLine() //Impressão da linha
      oReport:IncMeter()                 //Incrementa a barra de progresso
   EndIf
   WKACESSO->( dbSkip() )
EndDo

//Fim da impressão da seção 
oReport:Section("LOG"):Finish()      
WKACESSO->(dbSeek(WKMODULOS->(XCODUSER+XCODMODULO)))
oMarkAcesso:oBrowse:Refresh()
Return .T. 
          