SITRAWEBNEW
39
107
471
516
671
757
799
1836
1883
2000
2049
2096
2167
2184
2200
2212
2216

USE [2096]
GO
SELECT 
DISTINCT
MONTH(DATAEMISSAO) MES,YEAR(DATAEMISSAO) ANO
FROM DOCUMENTOS
ORDER BY ANO,MES
GO
--SELECT * FROM INFORMATION_SCHEMA.VIEWS