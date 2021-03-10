--SELECT PARA IDENTIFICAR TIPOS DE DADOS DAS TABELAS
SELECT
	S.NAME AS 'SCHEMA',
	T.NAME AS TABELA,
	C.NAME AS COLUNA,
	TY.NAME AS TIPO,
	C.MAX_LENGTH AS 'TAMANHO MÁXIMO', -- TAMANHO EM BYTES, PARA NVARCHAR NORMALMENTE SE DIVIDE ESTE VALOR POR 2
	C.PRECISION AS 'PRECISÃO', -- PARA TIPOS NUMERIC E DECIMAL (TAMANHO)
	C.SCALE AS 'ESCALA' -- PARA TIPOS NUMERIC E DECIMAL (NÚMEROS APÓS A VIRGULA)
FROM SYS.COLUMNS C
INNER JOIN SYS.TABLES T
	ON T.OBJECT_ID = C.OBJECT_ID
INNER JOIN SYS.TYPES TY
	ON TY.USER_TYPE_ID = C.USER_TYPE_ID
LEFT JOIN SYS.SCHEMAS S
	ON T.SCHEMA_ID = S.SCHEMA_ID