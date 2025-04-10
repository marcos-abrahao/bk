#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
 
/*/{Protheus.doc} BKCOMF11
Criar inclusão de Produtos específicos - BK
Gerar Proximo numero produtos
@Return
@author Adilson do Prado
@since 03/02/15
@version P12.1.33
/*/                                       

User Function BKCOMF11()

Local cQuery := ""
//Local nCod	 := 0
Local cCod	 := ""
Local aArea  := GetArea()
Local cTabSA2:= RETSQLNAME("SA2")

/*
cQuery := " SELECT TOP 1 A2_COD FROM "+RETSQLNAME("SA2")+" WHERE D_E_L_E_T_=''" 
cQuery += " AND A2_COD>'000000' AND A2_COD<'999999' AND LEN(A2_COD)=6"
cQuery += " ORDER BY A2_COD DESC"
*/

BEGINCONTENT var cQuery

WITH NumerosPulados AS (
    SELECT CAST(A2_COD AS INT) + 1 AS ProximoCodigo
    FROM #SA2# a
    WHERE D_E_L_E_T_ = '' 
    AND A2_COD > '000000' 
    AND A2_COD < '999999' 
    AND LEN(A2_COD) = 6
    AND ISNUMERIC(A2_COD) = 1
    AND NOT EXISTS (
        SELECT 1 
        FROM #SA2# b
        WHERE b.D_E_L_E_T_ = ''
        AND b.A2_COD = RIGHT('000000' + CAST(CAST(a.A2_COD AS INT) + 1 AS VARCHAR(6)), 6)
    )
),
MaxCodigo AS (
    SELECT MAX(CAST(A2_COD AS INT)) AS MaxCodigo
    FROM #SA2#
    WHERE D_E_L_E_T_ = '' 
    AND A2_COD > '000000' 
    AND A2_COD < '999999' 
    AND LEN(A2_COD) = 6
    AND ISNUMERIC(A2_COD) = 1
)
SELECT TOP 1
    RIGHT('000000' + CAST(ProximoCodigo AS VARCHAR(6)), 6) AS ProximoCodigo
FROM (
    SELECT ProximoCodigo FROM NumerosPulados
    UNION ALL
    SELECT MaxCodigo + 1 FROM MaxCodigo
    WHERE NOT EXISTS (SELECT 1 FROM NumerosPulados)
) AS Resultado
ORDER BY ProximoCodigo

ENDCONTENT

cQuery := STRTRAN(cQuery,"#SA2#",cTabSA2)

TCQUERY cQuery NEW ALIAS "QSA2"

dbSelectArea("QSA2")	
QSA2->(dbGoTop()) 
/*
nCod := VAL(QSA2->A2_COD)
nCod++
cCod := STRZERO(nCod,6)
*/

cCod := QSA2->ProximoCodigo
QSA2->(Dbclosearea())

RestArea(aArea)

u_MsgLog("BKCOMF11",cCod)
	
Return cCod




