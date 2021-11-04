USE [OPE]
GO
DROP FUNCTION dbo.fncCalcula_Distancia_Coordenada;
GO
--CRIACAO DE FUNCAO PARA CALCULO DE DISTANCIA ENTRE DUAS LATITUDES LONGITUDES
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
GO
--PREPARACAO DOS DADOS PARA UTILIZAR NA PREDICAO FINAL
USE [107]
GO
--CRIACAO DE VIEW E TABELA PARA PREPARAR QTD DE VOLUMES NAS NOTAS EVITANDO PLANO CARTEZIANO
DROP VIEW VW_NotasVolumes
GO
CREATE OR ALTER VIEW VW_NotasVolumes
AS
SELECT Distinct
    CAST(db_name() AS BIGINT) as TransportadoraID
    ,DOCNT.DocID
    ,DOC.TipoDocumentoId
    ,SUM(DOCNT.Volumes) AS VolumesQTD 
FROM DocumentoNota AS DOCNT
INNER JOIN DOCUMENTOS AS DOC ON DOC.DocId = DOCNT.DocId
GROUP BY DOCNT.DocId,DOC.TipoDocumentoId
GO
DROP TABLE OPE.DBO.PreparacaoNotasVolumes
GO
SELECT *
INTO OPE.DBO.PreparacaoNotasVolumes
FROM  [107].DBO.VW_NotasVolumes
GO
TRUNCATE TABLE OPE.DBO.PreparacaoNotasVolumes
--CURSOR PARA INSERIR DADOS NA TABELA PreparacaoNotasVolumes
DECLARE @DatabaseName varchar(100), @cmd varchar(1000)
 
DECLARE Cursor_BancodeDados1 CURSOR FOR
SELECT CAST(name AS VARCHAR(100)) AS name FROM MASTER..SYSDATABASES
WHERE  name NOT IN ('master', 'msdb', 'model', 'tempdb','AdventureWorks2017','AdventureWorksDW2017','consultorio','cripto','in_memory','OPE','SITRAWEBNEW')
and    status <> 66048
Order By Name

OPEN Cursor_BancodeDados1
FETCH NEXT FROM Cursor_BancodeDados1
INTO @DatabaseName
 
WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @CMD = 'USE' + '['+@DatabaseName + ']'+
    'INSERT INTO OPE.DBO.PreparacaoNotasVolumes
    SELECT Distinct
        CAST(db_name() AS BIGINT) as TransportadoraID
        ,DOCNT.DocID
        ,DOC.TipoDocumentoId
        ,SUM(DOCNT.Volumes) AS VolumesQTD 
    FROM DocumentoNota AS DOCNT
    INNER JOIN DOCUMENTOS AS DOC ON DOC.DocId = DOCNT.DocId
    GROUP BY DOCNT.DocId,DOC.TipoDocumentoId  '
    Exec(@cmd)
    FETCH NEXT FROM Cursor_BancodeDados1
    INTO @DatabaseName
END
GO
--FECHA CURSOR
close Cursor_BancodeDados1
deallocate Cursor_BancodeDados1
GO
--CRIACAO DE VIEW PARA FACILITAR A CRIACAO DA TABELA PREPARACAO
USE [107]
GO
DROP VIEW VW_TABELAS_FRETE
GO
CREATE OR ALTER VIEW VW_TABELAS_FRETE
AS
SELECT DISTINCT
CAST(db_name() AS BIGINT) as TransportadoraID
,DOC.DocId
,DOC.TipoDocumentoId
,UF.REGIAO AS RegiaoUFColetaid
,UF.NOMEREGIAO AS NomeRegiaoColeta
,DOC.LocalColetaUf
,DOC.LocalColetaCidade
,UF2.NOMEREGIAO AS NomeRegiaoEntrega
,UF2.REGIAO AS RegiaoUFEtregaID
,DOC.LocalEntregaUf
,DOC.LocalEntregaCidade
,CLI.TipoCliente
,CLI.RamoAtividadeId
,COMP.FreteCombinado
,COMP.ValorMercadoria
,COMP.Peso
,COMP.TotalFrete 
FROM DOCUMENTOS AS DOC
INNER JOIN DOCUMENTOSCOMPOSICAOFRETE AS COMP ON DOC.DocId = COMP.DocId
INNER JOIN SitraWebnew.DBO.Estados AS UF ON UF.UF = DOC.LocalColetaUf
INNER JOIN SitraWebnew.DBO.Estados AS UF2 ON UF2.UF = DOC.LocalENTREGAUf
INNER JOIN Clientes AS CLI ON CLI.ClienteId = DOC.TomadorId
INNER JOIN SitraWebnew.DBO.RamoAtividade AS RMA ON RMA.RamoAtividadeId = CLI.RamoAtividadeId
GO
USE [OPE]
GO
--CRIAR TABELA DE PREPARACAO DE DADOS BASEADO NA VIEW;
DROP TABLE OPE.DBO.Preparacao
GO
SELECT *
INTO OPE.DBO.Preparacao
FROM  [107].DBO.VW_TABELAS_FRETE
GO
--LIMPA OS DADOS PARA ALTERACAO DE DATA TIPES E INCLUSAO DE PRIMARY KEY
TRUNCATE TABLE OPE.DBO.Preparacao;
GO
--ALTERA CAMPO TRANSPORTADORAID PARA INTEIRO E NOT NULL;
ALTER TABLE OPE.DBO.Preparacao ALTER COLUMN TransportadoraID BIGINT NOT NULL;
GO
--CRIACAO DA PRIMARY KEY DA TABELA DE PREPARACAO
ALTER TABLE OPE.DBO.Preparacao ADD CONSTRAINT PK_PREDICAO PRIMARY KEY  (TransportadoraID,DocID,TipoDocumentoId);
GO
--CURSOR INSERIR DADOS TABELA Preparacao
DECLARE @DatabaseName varchar(100), @cmd varchar(1000)
 
DECLARE Cursor_BancodeDados2 CURSOR FOR
SELECT CAST(name AS VARCHAR(100)) AS name FROM MASTER..SYSDATABASES
WHERE  name NOT IN ('master', 'msdb', 'model', 'tempdb','AdventureWorks2017','AdventureWorksDW2017','consultorio','cripto','in_memory','OPE','SITRAWEBNEW')
and    status <> 66048
Order By Name

OPEN Cursor_BancodeDados2
FETCH NEXT FROM Cursor_BancodeDados2
INTO @DatabaseName
 
WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @CMD = 'USE' + '['+@DatabaseName + ']'+ ';'+
' INSERT INTO OPE.DBO.Preparacao
SELECT DISTINCT
CAST(db_name() AS BIGINT) as TransportadoraID
,DOC.DocId
,DOC.TipoDocumentoId
,UF.REGIAO AS RegiaoUFColetaid
,UF.NOMEREGIAO AS NomeRegiaoColeta
,DOC.LocalColetaUf
,DOC.LocalColetaCidade
,UF2.NOMEREGIAO AS NomeRegiaoEntrega
,UF2.REGIAO AS RegiaoUFEtregaID
,DOC.LocalEntregaUf
,DOC.LocalEntregaCidade
,CLI.TipoCliente
,CLI.RamoAtividadeId
,COMP.FreteCombinado
,COMP.ValorMercadoria
,COMP.Peso
,COMP.TotalFrete 
FROM DOCUMENTOS AS DOC
INNER JOIN DOCUMENTOSCOMPOSICAOFRETE AS COMP ON DOC.DocId = COMP.DocId
INNER JOIN SitraWebnew.DBO.Estados AS UF ON UF.UF = DOC.LocalColetaUf
INNER JOIN SitraWebnew.DBO.Estados AS UF2 ON UF2.UF = DOC.LocalENTREGAUf
INNER JOIN Clientes AS CLI ON CLI.ClienteId = DOC.TomadorId
INNER JOIN SitraWebnew.DBO.RamoAtividade AS RMA ON RMA.RamoAtividadeId = CLI.RamoAtividadeId '
       
    Exec(@cmd)
    FETCH NEXT FROM Cursor_BancodeDados2
    INTO @DatabaseName
END
GO
close Cursor_BancodeDados2
deallocate Cursor_BancodeDados2
GO
--CRIACAO DE VIEW PARA USO NA PREDICAO
USE [OPE]
GO
CREATE OR ALTER VIEW VW_Predicao
AS
SELECT 
PREP.TransportadoraID
,PREP.DocId
,PREP.TipoDocumentoId
,PREP.RegiaoUFColetaid
,PREP.NomeRegiaoColeta
,PREP.LocalColetaUf
,PREP.LocalColetaCidade
,PREP.NomeRegiaoEntrega
,PREP.RegiaoUFEtregaID
,PREP.LocalEntregaUf
,PREP.LocalEntregaCidade
,PREP.TipoCliente
,PREP.RamoAtividadeId
,PREP.FreteCombinado
,PREP.ValorMercadoria
,PREP.Peso
,PRPVOL.VolumesQTD
,PREP.TotalFrete
FROM PREPARACAO AS PREP
INNER JOIN 
    PreparacaoNotasVolumes AS  PRPVOL 
            ON PREP.DocId = PRPVOL.DocID 
            AND PREP.TransportadoraID = PRPVOL.TransportadoraID
GO

