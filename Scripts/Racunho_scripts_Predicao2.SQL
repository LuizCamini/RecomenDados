--SELECT * FROM municipios
--WHERE NOME = 'OSASCO'



--USE [OPE]
--SELECT *
--INTO OPE.DBO.Predicao
--from  VW_PREDICAO
--GO

--SELECT * FROM OPE.DBO.Predicao

USE [799]
INSERT INTO OPE.DBO.Predicao
SELECT 
db_name() as TransportadoraID
,UF.REGIAO AS IDRegiaoUFColeta
,UF.NOMEREGIAO AS NomeRegiaoColeta
,DOC.LocalColetaUf
,DOC.LocalColetaCidade
,UF2.NOMEREGIAO AS NomeRegiaoEntrega
,UF2.REGIAO AS IDRegiaoUFEtrega
,DOC.LocalEntregaUf
,DOC.LocalEntregaCidade
,CLI.TipoCliente
,CLI.RamoAtividadeId
,COMP.FreteCombinado
,COMP.ValorMercadoria
,COMP.Peso
,DOCNT.Volumes
,COMP.TotalFrete 
FROM DOCUMENTOS AS DOC
INNER JOIN DOCUMENTOSCOMPOSICAOFRETE AS COMP ON DOC.DocId = COMP.DocId
INNER JOIN SitraWebnew.DBO.Estados AS UF ON UF.UF = DOC.LocalColetaUf
INNER JOIN SitraWebnew.DBO.Estados AS UF2 ON UF2.UF = DOC.LocalENTREGAUf
INNER JOIN Clientes AS CLI ON CLI.ClienteId = DOC.TomadorId
INNER JOIN SitraWebnew.DBO.RamoAtividade AS RMA ON RMA.RamoAtividadeId = CLI.RamoAtividadeId
INNER JOIN DocumentoNota AS DOCNT ON DOCNT.DocId = DOC.DocId



GO
--COLLATE SQL_Latin1_General_CP1_CI_AI

--143.365
USE [OPE]
GO
SELECT  
pred.TransportadoraID
,pred.LocalColetaUf + '-' + pred.LocalEntregaUf
,pred.LocalColetaCidade
,mun.codigo_ibge as CodIbge_Coleta
,mun.latitude
,mun.longitude
,pred.LocalEntregaCidade
,mun2.codigo_ibge as CodIbge_Entrega
,mun2.latitude
,mun2.longitude
,pred.TipoCliente
,pred.FreteCombinado
,pred.ValorMercadoria
,pred.Peso
,pred.Volumes
,pred.TotalFrete
,
CASE WHEN mun.codigo_ibge = mun2.codigo_ibge THEN 5 ELSE 
dbo.fncCalcula_Distancia_Coordenada(mun.latitude,mun.longitude,mun2.latitude,mun2.longitude) END  as Distancia
FROM Predicao AS PRED
LEFT JOIN municipios AS MUN ON PRED.LocalColetaCidade COLLATE SQL_Latin1_General_CP1_CI_AI = MUN.nome COLLATE SQL_Latin1_General_CP1_CI_AI AND PRED.LocalColetaUf = MUN.UF COLLATE SQL_Latin1_General_CP1_CI_AI
LEFT JOIN municipios AS MUN2 ON PRED.LocalEntregaCidade COLLATE SQL_Latin1_General_CP1_CI_AI = MUN2.nome COLLATE SQL_Latin1_General_CP1_CI_AI AND PRED.LocalEntregaUf = MUN2.UF COLLATE SQL_Latin1_General_CP1_CI_AI




SELECT dbo.fncCalcula_Distancia_Coordenada(-20.3135958, -40.2893737, -20.3480338, -40.2975204)


CREATE FUNCTION dbo.fncCalcula_Distancia_Coordenada (
    @Latitude1 FLOAT,
    @Longitude1 FLOAT,
    @Latitude2 FLOAT,
    @Longitude2 FLOAT
)
RETURNS FLOAT
AS
BEGIN

    DECLARE @PI FLOAT = PI()

    DECLARE @lat1Radianos FLOAT = @Latitude1 * @PI / 180
    DECLARE @lng1Radianos FLOAT = @Longitude1 * @PI / 180
    DECLARE @lat2Radianos FLOAT = @Latitude2 * @PI / 180
    DECLARE @lng2Radianos FLOAT = @Longitude2 * @PI / 180

    RETURN (ACOS(COS(@lat1Radianos) * COS(@lng1Radianos) * COS(@lat2Radianos) * COS(@lng2Radianos) + COS(@lat1Radianos) * SIN(@lng1Radianos) * COS(@lat2Radianos) * SIN(@lng2Radianos) + SIN(@lat1Radianos) * SIN(@lat2Radianos)) * 6371) * 1.15

END



select * from municipios

UPDATE municipios SET UF = EST.uf
FROM municipios AS MUN
INNER JOIN estados AS EST ON EST.codigo_uf = MUN.codigo_uf

SELECT * FROM estados


select  LocalColetaUf + '-'+LocalEntregaUf as a, count(*) from Predicao
group by LocalColetaUf,LocalEntregaUf
order by 2 desc
GO

select distinct (IDRegiaoUFColeta) from Predicao

select * from Predicao

Predicao

--Total Frete--00,01 a 202.754,39
--TransportadoraID-- 17
--regiaocoleta/entrega -- 5
--uf coleta/entrega -- 27
--cidades coleta/entrega --5.570
--tipo cliente -- 2
--ramo de atividade -- 8
--frete combinado -- 1 ou 0 

--RESTORE DATABASE [2167]  FROM  DISK = N'/home/luizcamini/Documentos/bd/2167_2019120609.bak' WITH  FILE = 1, 
--MOVE N'2167' TO N'/var/opt/mssql/data/2167.mdf',  
--MOVE N'2167_log' TO N'/var/opt/mssql/data/2167.ldf', 
--NOUNLOAD,  STATS = 5;   
