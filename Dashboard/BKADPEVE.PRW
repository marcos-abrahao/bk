#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKADPEVE
BK - Atualiza��o da tabela EspelhoADP.dbo.EventosProtheus

@Return
@author Marcos Bispo Abrah�o
@since 12/03/2025
@version P121024
/*/

User Function BKADPEVE
Local cQuery	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cProg		:= "BKADPEVE"

BEGINCONTENT VAR cQuery
-- Verifica se a tabela j� existe
--IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EventosProtheus' AND schema_id = SCHEMA_ID('dbo'))

IF OBJECT_ID(N'EspelhoADP.dbo.EventosProtheus', N'U') IS NULL
BEGIN
    -- Cria a tabela se ela n�o existir
    CREATE TABLE EspelhoADP.dbo.EventosProtheus (
        Codigo INT PRIMARY KEY,  -- Chave prim�ria para garantir unicidade
        Descricao VARCHAR(255),
        Classificacao VARCHAR(255),
		EventoProtheus VARCHAR(30),
        EventoNovo VARCHAR(1),
        DataPrc DATETIME,
    );
END;

-- Insere ou atualiza os dados na tabela de destino
WITH DadosUnicos AS (
    SELECT
        Codigo,
        Descricao,
        Classificacao,
        ROW_NUMBER() OVER (PARTITION BY Codigo ORDER BY (SELECT NULL)) AS RowNum
    FROM EspelhoADP.dbo.FichaFinanceira
)
MERGE EspelhoADP.dbo.EventosProtheus AS destino
USING (
    SELECT Codigo, Descricao, Classificacao
    FROM DadosUnicos
    WHERE RowNum = 1 -- Filtra apenas um registro por Codigo
) AS origem
ON destino.Codigo = origem.Codigo
WHEN MATCHED THEN
    UPDATE SET
        Descricao = origem.Descricao,
        Classificacao = origem.Classificacao
WHEN NOT MATCHED THEN
    INSERT (Codigo, 
			Descricao, 
			Classificacao,
			EventoProtheus,
            EventoNovo,
            DataPrc

)
    VALUES (origem.Codigo, 
			origem.Descricao, 
			origem.Classificacao,
			'',
            'S',
            GETDATE()
			);
ENDCONTENT

If !TCIsConnected()
  MsgAlert( "Sem conex�o com o banco de dados", cPerg )
  Return( Nil )
Endif  

nErro   := TcSqlExec(cQuery)

If nErro != 0
	cErro1 := TcSqlError()
EndIf

u_QryResult(cProg,cQuery,cErro1)

Return


