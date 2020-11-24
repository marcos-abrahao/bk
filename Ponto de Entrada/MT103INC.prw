#Include "Protheus.Ch"
#Include "Totvs.Ch"
#define MB_ICONEXCLAMATION          48

/*/{Protheus.doc} MT103INC
P.E. - Verifica se pode-se classificar o documento.
@author Marcos Bispo Abrahão
@since 24/11/2020
@version 1.0
@type function
/*/
User Function MT103INC()
Local lClass:= Paramixb
Local lRet  := .F.
Local nOper := 0
Local aUser := {}
If lClass
    If SF1->F1_XXLIB == ' '
        nOper := Aviso("MT103INC","Liberação para classificação fiscal:",{"Liberar","Bloquear","Cancelar"})
        If nOper <> 3
        	RecLock("SF1",.F.)
            If nOper == 1
	            SF1->F1_XXLIB  := "L"
            Else
                SF1->F1_XXLIB  := "B"
            EndIf
	        SF1->F1_XXULIB := __cUserId
            SF1->F1_XXDLIB := DtoC(Date())+"-"+Time()
	        MsUnLock("SF1")
        EndIf
    Else
        If SF1->F1_XXLIB == 'L'
            PswOrder(1) 
            PswSeek(__cUserId) 
            aUser  := PswRet(1)
            If ASCAN(aUser[1,10],"000000") <> 0 .OR. ASCAN(aUser[1,10],"000031") <> 0 //.OR. lMDiretoria 
                If ASCAN(aUser[1,10],"000031") <> 0 .AND. __cUserId == SF1->F1_XXUSER
                    MessageBox("Usuário sem permissão para classificar este Doc.","MT103INC",MB_ICONEXCLAMATION)
                Else
                    lRet := .T.
                EndIf
            Else
                MessageBox("Documento já foi liberado, aguarde a classificação pelo Depto Fiscal.","MT103INC",MB_ICONEXCLAMATION)
            EndIf
        ElseIf SF1->F1_XXLIB == 'B'
            PswOrder(1) 
            PswSeek(__cUserId) 
            aUser  := PswRet(1)
            //If !EMPTY(aUser[1,11])
            //    cSuper := SUBSTR(aUser[1,11],1,6)
            //EndIf
	        If SF1->F1_XXULIB == __cUserId .OR. ASCAN(aUser[1,10],"000000") <> 0
                nOper := Aviso("MT103INC - Bloqueado","Liberação para classificação fiscal:",{"Liberar","Cancelar"})
                If nOper == 1
                    RecLock("SF1",.F.)
                    SF1->F1_XXLIB  := "L"
                    SF1->F1_XXULIB := __cUserId
                    SF1->F1_XXDLIB := DtoC(Date())+"-"+Time()
                    MsUnLock("SF1")
                EndIf
            Else
                MessageBox("Documento bloqueado para classificação: "+SF1->F1_XXULIB,"MT103INC",MB_ICONEXCLAMATION)
            EndIf
        EndIf
    EndIf
EndIf

Return lRet
