#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"

User Function TesteEm()
Private cPrw     := "TesteEm"
Private cAssunto := "Teste"
Private cEmail   := PAD("microsiga@bkconsultoria.com.br",100)
Private cCC      := ""
Private cMsg     := "Teste "+DTOC(DATE())+"-"+TIME() 
Private cAnexo   := ""
Private _lJob    := .F.

aDet := {}

dbSelectArea("SZ2")
dbGoBottom()
dbSkip(-5)

AADD(aDet,{SZ2->Z2_PRONT,SZ2->Z2_NOME,SZ2->Z2_VALOR,SZ2->Z2_BANCO,SZ2->Z2_AGENCIA,SZ2->Z2_DIGAGEN,SZ2->Z2_CONTA,SZ2->Z2_DIGCONT,"Obs"})
dbSkip()

AADD(aDet,{SZ2->Z2_PRONT,SZ2->Z2_NOME,SZ2->Z2_VALOR,SZ2->Z2_BANCO,SZ2->Z2_AGENCIA,SZ2->Z2_DIGAGEN,SZ2->Z2_CONTA,SZ2->Z2_DIGCONT,"Observacoes xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"})
dbSkip()

AADD(aDet,{SZ2->Z2_PRONT,SZ2->Z2_NOME,SZ2->Z2_VALOR,SZ2->Z2_BANCO,SZ2->Z2_AGENCIA,SZ2->Z2_DIGAGEN,SZ2->Z2_CONTA,SZ2->Z2_DIGCONT,"Observacoes xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"})
dbSkip()

AADD(aDet,{SZ2->Z2_PRONT,SZ2->Z2_NOME,SZ2->Z2_VALOR,SZ2->Z2_BANCO,SZ2->Z2_AGENCIA,SZ2->Z2_DIGAGEN,SZ2->Z2_CONTA,SZ2->Z2_DIGCONT,"Observacoes xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"})
dbSkip()

AADD(aDet,{SZ2->Z2_PRONT,SZ2->Z2_NOME,SZ2->Z2_VALOR,SZ2->Z2_BANCO,SZ2->Z2_AGENCIA,SZ2->Z2_DIGAGEN,SZ2->Z2_CONTA,SZ2->Z2_DIGCONT,"Observacoes xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"})
dbSkip()

cTitulo := "Pagamentos não Efetuados"
aCabs := {"Pront.","Nome","Valor","Bco","Ag.","Dg.Ag.","Conta","Dg.Conta","Obs."}

cMsg := u_GeraHtmA(aDet,cTitulo,aCabs,ProcName(1))



@ 200,01 TO 285,450 DIALOG oDlg1 TITLE "Teste de envio de email"
@ 15,015 SAY "Email: "
@ 15,046 GET cEmail SIZE 180,10
@ 30,060 BMPBUTTON TYPE 01 ACTION ( U_SendMail(cPrw,cAssunto,TRIM(cEmail),cCc,cMsg,cAnexo,_lJob), Close(Odlg1) )
@ 30,110 BMPBUTTON TYPE 02 ACTION Close(Odlg1)

ACTIVATE DIALOG oDlg1 CENTER

RETURN


