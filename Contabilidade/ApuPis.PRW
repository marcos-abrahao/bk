#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �ApuPisConf �Autor  � Thiago Menegocci  � Data � 01/09/2008  ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao para calculo de apuracao de pis e cofins            ���
�������������������������������������������������������������������������͹��
*/

User Function ApuPis()

Local nValor2  := 0
Local cParPis := Left(AllTrim(GetMV("MV_PARPIS")),4)

If Upper(Funname()) == Upper("CTBANFE")
	If SD1->D1_TES $ AllTrim(GetMV("MV_TESPAG"))
		nValor2 := Round(SD1->D1_TOTAL*Val(cParPis)/100,2)
	EndIf
EndIf

If Upper(Funname()) == Upper("CTBANFS")
	If SD2->D2_TES $ AllTrim(GetMV("MV_TESREC"))
		nValor2 := Round(SD2->D2_TOTAL*Val(cParPis)/100,2)
	EndIf
EndIf

Return(nValor2)