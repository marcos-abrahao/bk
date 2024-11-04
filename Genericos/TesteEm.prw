#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"

User Function TesteEm()
Private cPrw     := "TesteEm"
Private cAssunto := "Teste"
Private cEmail   := PAD(u_EmailAdm(),100)
Private cCC      := "marcos.abrahao@bkconsultoria.com.br"
Private cMsgA    := "" //"Teste "+DTOC(DATE())+"-"+TIME() 
Private cMsgB    := ""
Private cAnexoA  := u_STmpDir()+"TesteEmA.html"
Private cAnexoB  := u_STmpDir()+"TesteEmB.html"

aDet := {}
aUsers := u_EmailUsr("marcos.abrahao@bkconsultoria.com.br;microsiga@bkconsultoria.com.br;")
//aUsers := u_EmailUsr("lucas.silva@bkconsultoria.com.br;microsiga@bkconsultoria.com.br;barbara.santos@bkconsultoria.com.br;jose.amauri@bkconsultoria.com.br;bianca.almeida@bkconsultoria.com.br;")

dbSelectArea("SZ2")
dbGoBottom()
dbSkip(-5)

AADD(aDet,{SZ2->Z2_PRONT,SZ2->Z2_NOME,SZ2->Z2_VALOR,SZ2->Z2_BANCO,SZ2->Z2_AGENCIA,SZ2->Z2_DIGAGEN,SZ2->Z2_CONTA,SZ2->Z2_DIGCONT,"Observacoes xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"})
dbSkip()

AADD(aDet,{SZ2->Z2_PRONT,SZ2->Z2_NOME,SZ2->Z2_VALOR,SZ2->Z2_BANCO,SZ2->Z2_AGENCIA,SZ2->Z2_DIGAGEN,SZ2->Z2_CONTA,SZ2->Z2_DIGCONT,"Observacoes xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"})
dbSkip()

AADD(aDet,{SZ2->Z2_PRONT,SZ2->Z2_NOME,SZ2->Z2_VALOR,SZ2->Z2_BANCO,SZ2->Z2_AGENCIA,SZ2->Z2_DIGAGEN,SZ2->Z2_CONTA,SZ2->Z2_DIGCONT,"Observacoes xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"})
dbSkip()

AADD(aDet,{SZ2->Z2_PRONT,SZ2->Z2_NOME,SZ2->Z2_VALOR,SZ2->Z2_BANCO,SZ2->Z2_AGENCIA,SZ2->Z2_DIGAGEN,SZ2->Z2_CONTA,SZ2->Z2_DIGCONT,"Observacoes xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"})
dbSkip()

AADD(aDet,{SZ2->Z2_PRONT,SZ2->Z2_NOME,SZ2->Z2_VALOR,SZ2->Z2_BANCO,SZ2->Z2_AGENCIA,SZ2->Z2_DIGAGEN,SZ2->Z2_CONTA,SZ2->Z2_DIGCONT,"Observacoes xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"})
dbSkip()

cTitulo := "Teste de email "
aCabs := {"Pront.","Nome","Valor","Bco","Ag.","Dg.Ag.","Conta","Dg.Conta","Obs."}

cMsgA := u_GeraHtmA(aDet,cTitulo+" A",aCabs,ProcName(1),"Teste rodape",cEmail,cCC)
u_GrvAnexo(cAnexoA,cMsgA,.T.)

cMsgB := u_GeraHtmB(aDet,cTitulo+" B",aCabs,ProcName(1),"Teste rodape",cEmail,cCC)
u_GrvAnexo(cAnexoB,cMsgB,.T.)

@ 200,01 TO 285,450 DIALOG oDlg1 TITLE "Teste de envio de email"
@ 15,015 SAY "Email: "
@ 15,046 GET cEmail SIZE 180,10
@ 30,060 BUTTON oButA PROMPT 'Enviar A' SIZE 40, 12 PIXEL OF oDlg1 ACTION ( u_BkSnMail(cPrw+"A",cAssunto,TRIM(cEmail),cCc,cMsgA,{cAnexoA},.T.),u_MsgLog("BkSnMail","Teste BkSnMail A","I"))
@ 30,110 BUTTON oButB PROMPT 'Enviar B' SIZE 40, 12 PIXEL OF oDlg1 ACTION ( u_BkSnMail(cPrw+"B",cAssunto,TRIM(cEmail),cCc,cMsgB,{cAnexoB},.T.),u_MsgLog("BkSnMail","Teste BkSnMail B","I"))

@ 30,160 BMPBUTTON TYPE 02 ACTION Close(Odlg1)

ACTIVATE DIALOG oDlg1 CENTER

RETURN


