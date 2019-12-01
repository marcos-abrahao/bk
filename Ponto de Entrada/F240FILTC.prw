#include "rwmake.ch"

// Filtra CNAB a pagar
//O ponto de entrada F240FILTC é utilizado para montar o filtro para
// Indregua após o preenchimento da tela de dados do borderô na geração do(s) arquivo(s)
// do SISPAG (FINA300). O filtro retornado pelo ponto de entrada será anexado ao filtro padrão do programa.
User Function F240FILTC()
Local cRet := ".T."

IF SEA->EA_SITUANT == "X"
	cRet := ".F."
ENDIF

Return cRet



