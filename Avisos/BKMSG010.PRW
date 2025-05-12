#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKMSG010
BK - Aviso de Pedidos de compras não entregues

@Return
@author Marcos Bispo Abrahão
@since 
@version P12.1.2310
/*/

User Function BKMSG010

Local cQuery            
Local cAlias 	:= "QTMP"
Local aArea     := GetArea()
Local cAssunto	:= "Eventos novos ADP: "
Local cEmail	:= ""
Local cEmailCC	:= u_EmailAdm()
Local cMsg    	:= ""
Local cAnexo    := ""
Local aCabs		:= {}
Local aEmail	:= {}
Local cProg		:= "BKMSG010"
Local aUsers 	:= {}
Local aGrupos 	:= {u_GrpRepac()}
Local aDeptos 	:= {}

cEmail := u_GprEmail("",aUsers,aGrupos,aDeptos)
lJobV2 := IsBlind()

If FWCodEmp() <> "01"
	u_MsgLog(cProg,"Esta Funcao Rodar somente na empresa 01")
	Return Nil
EndIf

u_MsgLog("BKMSG010",cAssunto)

BEGINCONTENT VAR cQuery

SELECT [Codigo]
      ,[Descricao]
      ,[Classificacao]
      ,[EventoProtheus]
      ,[EventoNovo]
      ,[DataPrc]
  FROM [EspelhoADP].[dbo].[EventosProtheus]
  WHERE EventoNovo = 'S'

ENDCONTENT

TCQUERY cQuery NEW ALIAS (cAlias)

(cAlias)->(dbgotop())

Do While (cAlias)->(!eof())
	
	AADD(aEmail,{	STR((cAlias)->Codigo,6,0),;
   	   				(cAlias)->Descricao,;
   	   				(cAlias)->EventoProtheus,;
              (cAlias)->Classificacao,;
   	   				(cAlias)->DataPrc})

	(cAlias)->(dbskip())

EndDo

(cAlias)->(Dbclosearea())

If Len(aEmail) > 0

  cAssunto += ALLTRIM(STR(LEN(aEmail)))

  aCabs	:= {"Codigo","Descricao","Evento Protheus","Classificação","Data Processamento"}

  cMsg	:= u_GeraHtmB(aEmail,cAssunto,aCabs,cProg,"",cEmail,cEmailCC)

  cAnexo	:= cProg+".html"
  u_GrvAnexo(cAnexo,cMsg,.T.)

  // Gravar no SZ0 - Avisos Web
  u_BKMsgUs(cEmpAnt,cProg,{},u_GrpRepac(),cAssunto,cAssunto,"F",cAnexo)

  U_BkSnMail(cProg,cAssunto,cEmail,cEmailCC,cMsg,{cAnexo},.F.)

EndIf

RestArea(aArea)
