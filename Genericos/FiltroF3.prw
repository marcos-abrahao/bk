#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

User Function FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,nColuna)
	/*
	+------------------+------------------------------------------------------------+
	!Modulo            ! Diversos                                                   !
	+------------------+------------------------------------------------------------+
	!Nome              ! FiltroF3                                                   !
	+------------------+------------------------------------------------------------+
	!Descricao         ! Função usada para criar uma Consulta Padrão  com SQL       !
	!			       !                                                            !
	!			       !                                                            !
	+------------------+------------------------------------------------------------+
	!Autor             ! Rodrigo Lacerda P Araujo                                   !
	+------------------+------------------------------------------------------------+
	!Data de Criacao   ! 03/01/2013                                                 !
	+------------------+-----------+------------------------------------------------+
	!Campo             ! Tipo	   ! Obrigatorio                                    !
	+------------------+-----------+------------------------------------------------+
	!cTitulo           ! Caracter  !                                                !
	!cQuery            ! Caracter  ! X                                              !
	!nTamCpo           ! Numerico  !                                                !
	!cAlias            ! Caracter  ! X                                              !
	!cCodigo           ! Caracter  !                                                !
	!cCpoChave         ! Caracter  ! X                                              !
	!cTitCampo         ! Caracter  ! X                                              !
	!cMascara          ! Caracter  !                                                !
	!cRetCpo           ! Caracter  ! X                                              !
	!nColuna           ! Numerico  !                                                !
	+------------------+-----------+------------------------------------------------+
	!Parametros:                                                                  !
	!==========		                                                        !
	!          																			   !
	!cTitulo = Titulo da janela da consulta                                         !
	!cQuery  = A consulta SQL que vem do parametro cQuery não pode retornar um outro!
	!nome para o campo pesquisado, pois a rotina valida o nome do campo real        !
	!          																			   !
	!Exemplo Incorreto                                                              !
	!cQuery := "SELECT A1_NOME 'NOME', A1_CGC 'CGC' FROM SA1010 WHERE D_E_L_E_T_='' !
	!          																			   !
	!Exemplo Certo                                                                  !
	!cQuery := "SELECT A1_NOME, A1_CGC FROM SA1010 WHERE D_E_L_E_T_=''              !
	!          																			   !
	!Deve-se manter o nome do campo apenas.                                         !
	!          																			   !
	!nTamCpo   = Tamanho do campo de pesquisar,se não informado assume 30 caracteres!
	!cAlias    = Alias da tabela, ex: SA1                                           !
	!cCodigo   = Conteudo do campo que chama o filtro                               !
	!cCpoChave = Nome do campo que será utilizado para pesquisa, ex: A1_CODIGO      ! 
	!cTitCampo = Titulo do label do campo                                           !
	!cMascara  = Mascara do campo, ex: "@!"                                         !
	!cRetCpo   = Campo que receberá o retorno do filtro                             !
	!nColuna   = Coluna que será retornada na pesquisa, padrão coluna 1             !
	+--------------------------------------------------------------------------------
	*/
	Local nLista  
	Local cCampos 	:= ""
	Local bCampo		:= {}
	Local nCont		:= 0
	Local nX

	//Local bTitulos	:= {}
	Local aCampos 	:= {}
	Local cTabela 
	Local cCSSGet		:= "QLineEdit{ border: 1px solid gray;border-radius: 3px;background-color: #ffffff;selection-background-color: #3366cc;selection-color: #ffffff;padding-left:1px;}"
	Local cCSSButton 	:= "QPushButton{background-repeat: none; margin: 2px;background-color: #ffffff;border-style: outset;border-width: 2px;border: 1px solid #C0C0C0;border-radius: 5px;border-color: #C0C0C0;font: bold 12px Arial;padding: 6px;QPushButton:pressed {background-color: #ffffff;border-style: inset;}"
	//Local cCSSButF3	:= "QPushButton {background-color: #ffffff;margin: 2px;border-style: outset;border-width: 2px;border: 1px solid #C0C0C0;border-radius: 3px; border-color: #C0C0C0;font: Normal 10px Arial;padding: 3px;} QPushButton:pressed {background-color: #e6e6f9;border-style: inset;}"

	Private _oLista	:= nil
	Private _oDlg 	:= nil
	Private _oCodigo
	Private _cCodigo 	
	Private _aDados 	:= {}
	Private _nColuna	:= 0
	
	Default cTitulo 	:= ""
	Default cCodigo 	:= ""
	Default nTamCpo 	:= 30
	Default _nColuna 	:= 1
	Default cTitCampo	:= RetTitle(cCpoChave)
	Default cMascara	:= PesqPict('"'+cAlias+'"',cCpoChave)

	_nColuna	:= nColuna

	If Empty(cAlias) .OR. Empty(cCpoChave) .OR. Empty(cRetCpo) .OR. Empty(cQuery)
		MsgStop("Os parametro cQuery, cCpoChave, cRetCpo e cAlias são obrigatórios!","Erro")
		Return
	Endif

	_cCodigo := Space(nTamCpo)
	_cCodigo := cCodigo

	cTabela:= CriaTrab(Nil,.F.)
	DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),cTabela, .F., .T.)
     
	(cTabela)->(DbGoTop())
	If (cTabela)->(Eof())
		MsgStop("Não há registros para serem exibidos!","Atenção")
		Return
	Endif
   
	Do While (cTabela)->(!Eof())
		/*Cria o array conforme a quantidade de campos existentes na consulta SQL*/
		cCampos	:= ""
		aCampos 	:= {}
		For nX := 1 TO FCount()
			bCampo := {|nX| Field(nX) }
			If ValType((cTabela)->&(EVAL(bCampo,nX)) ) <> "M" .OR. ValType((cTabela)->&(EVAL(bCampo,nX)) ) <> "U"
				if ValType((cTabela)->&(EVAL(bCampo,nX)) )=="C"
					cCampos += "'" + (cTabela)->&(EVAL(bCampo,nX)) + "',"
				ElseIf ValType((cTabela)->&(EVAL(bCampo,nX)) )=="D"
					cCampos +=  DTOC((cTabela)->&(EVAL(bCampo,nX))) + ","
				Else
					cCampos +=  (cTabela)->&(EVAL(bCampo,nX)) + ","
				Endif
					
				aadd(aCampos,{EVAL(bCampo,nX),Alltrim(RetTitle(EVAL(bCampo,nX))),"LEFT",30})
			Endif
		Next
     
     	If !Empty(cCampos) 
     		cCampos 	:= Substr(cCampos,1,len(cCampos)-1)
     		aAdd( _aDados,&("{"+cCampos+"}"))
     	Endif
     	
		(cTabela)->(DbSkip())     
	Enddo
   
	DbCloseArea()
	
	If Len(_aDados) == 0
		u_MsgLog("FiltroF3","Não há dados para exibir!","W")
		Return
	Endif
   
	nLista := aScan(_aDados, {|x| alltrim(x[1]) == alltrim(_cCodigo)})
     
	iif(nLista = 0,nLista := 1,nLista)
     
	Define MsDialog _oDlg Title "Consulta Padrão" + IIF(!Empty(cTitulo)," - " + cTitulo,"") From 0,0 To 280, 500 Of oMainWnd Pixel
	
	oCodigo:= TGet():New( 003, 005,{|u| if(PCount()>0,_cCodigo:=u,_cCodigo)},_oDlg,205, 010,cMascara,{|| /*Processa({|| FiltroF3P(M->_cCodigo)},"Aguarde...")*/ },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"",_cCodigo,,,,,,,cTitCampo + ": ",1 )
	oCodigo:SetCss(cCSSGet)	
	oButton1 := TButton():New(010, 212," &Pesquisar ",_oDlg,{|| Processa({|| FiltroF3P(M->_cCodigo) },"Aguarde...") },037,013,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton1:SetCss(cCSSButton)	
	    
	_oLista:= TCBrowse():New(26,05,245,90,,,,_oDlg,,,,,{|| _oLista:Refresh()},,,,,,,.F.,,.T.,,.F.,,,.f.)
	nCont := 1
        //Para ficar dinâmico a criação das colunas, eu uso macro substituição "&"
	For nX := 1 to len(aCampos)
		cColuna := &('_oLista:AddColumn(TCColumn():New("'+aCampos[nX,2]+'", {|| _aDados[_oLista:nAt,'+StrZero(nCont,2)+']},PesqPict("'+cAlias+'","'+aCampos[nX,1]+'"),,,"'+aCampos[nX,3]+'", '+StrZero(aCampos[nX,4],3)+',.F.,.F.,,{|| .F. },,.F., ) )')
		nCont++
	Next
	_oLista:SetArray(_aDados)
	_oLista:bWhen 		 := { || Len(_aDados) > 0 }
	_oLista:bLDblClick  := { || FiltroF3R(_oLista:nAt, _aDados, cRetCpo)  }
	_oLista:Refresh()

	oButton2 := TButton():New(122, 005," OK "			,_oDlg,{|| Processa({|| FiltroF3R(_oLista:nAt, _aDados, cRetCpo) },"Aguarde...") },037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton2:SetCss(cCSSButton)	
	oButton3 := TButton():New(122, 047," Cancelar "	,_oDlg,{|| _oDlg:End() },037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton3:SetCss(cCSSButton)	

	Activate MSDialog _oDlg Centered	
Return(bRet)

Static Function FiltroF3P(cBusca)
	Local i := 0

	if !Empty(cBusca)
		For i := 1 to len(_aDados)
			//Aqui busco o texto exato, mas pode utilizar a função AT() para pegar parte do texto
			if UPPER(Alltrim(_aDados[i,_nColuna]))==UPPER(Alltrim(cBusca))
				//Se encontrar me posiciono no grid e saio do "For"			
				_oLista:GoPosition(i)
				_oLista:Setfocus()
				exit
			Endif
		Next
	Endif
Return

Static Function FiltroF3R(nLinha,aDados,cRetCpo)
	cCodigo := aDados[nLinha,_nColuna]
	&(cRetCpo) := cCodigo //Uso desta forma para campos como tGet por exemplo.
	aCpoRet[1] := cCodigo //Não esquecer de alimentar essa variável quando for f3 pois ela e o retorno
	bRet := .T.
	_oDlg:End()    
Return

User Function CNCF3(cContra,cRev,cCliente,cLoja)
	Local cTitulo		:= "Clientes"
	Local cQuery		:= "" 								//obrigatorio
	Local cAlias		:= "CNC"							//obrigatorio
	Local cCpoChave	    := "CNC_CODIGO" 					//obrigatorio
	Local cTitCampo	    := RetTitle(cCpoChave)			    //obrigatorio
	Local cMascara	    := PesqPict(cAlias,cCpoChave)	    //obrigatorio
	Local nTamCpo		:= TamSx3(cCpoChave)[1]		
	Local cRetCpo		:= "M->cCliente"					//obrigatorio
	Local nColuna		:= 1	
	Local cCodigo		:= M->cCliente		//pego o conteudo e levo para minha consulta padrão			
 	Private bRet 		:= .F.

   	//Monto minha consulta, neste caso quero retornar apenas uma coluna, mas poderia inserir outros campos para compor outras colunas no grid, lembrando que não posso utilizar um alias para o nome do campo, deixar o nome real.
   	//Posso fazer qualquer tipo de consulta, usando INNER, GROUPY BY, UNION's etc..., desde que mantenha o nome dos campos no SELECT.

    cQuery  := "SELECT CNC_CLIENT,CNC_LOJACL,A1_NOME,A1_MUN,A1_CGC "+CRLF
    cQuery  += "FROM "+RETSQLNAME("CNC")+" CNC "+CRLF
    cQuery  += "LEFT JOIN "+RETSQLNAME("SA1")+" SA1 ON "+CRLF
    cQuery  += " CNC_CLIENT = A1_COD AND CNC_LOJACL = A1_LOJA AND A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.D_E_L_E_T_ = '' "+CRLF
    cQuery  += "WHERE CNC.D_E_L_E_T_ = '' AND CNC_FILIAL = '"+xFilial("CNC")+"' "+CRLF
    cQuery  += " AND CNC_NUMERO = '"+ALLTRIM(cContra)+"' AND CNC_REVISA = '"+ALLTRIM(cRev)+"' "+CRLF
    cQuery  += "ORDER BY CNC_CLIENT,CNC_LOJACL "

   	//cQuery := " SELECT DISTINCT ZZL_PROJET "
	//cQuery += " FROM "+RetSQLName("ZZL") + " AS ZZL " //WITH (NOLOCK)
	//cQuery += " WHERE ZZL_FILIAL  = '" + xFilial("ZZL") + "' "
	//cQuery += " AND ZZL.D_E_L_E_T_= ' ' "
	//cQuery += " ORDER BY ZZL_PROJET "

 	bRet := U_FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,nColuna)
Return(bRet)
