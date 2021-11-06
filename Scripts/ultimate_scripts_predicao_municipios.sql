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
CREATE OR ALTER FUNCTION [dbo].[fnRemoveAcentuacao](
    @String VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    
    /****************************************************************************************************************/
    /** RETIRA ACENTUAÇÃO DAS VOGAIS **/
    /****************************************************************************************************************/
    SET @String = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@String,'á','a'),'à','a'),'â','a'),'ã','a'),'ä','a')
    SET @String = REPLACE(REPLACE(REPLACE(REPLACE(@String,'é','e'),'è','e'),'ê','e'),'ë','e')
    SET @String = REPLACE(REPLACE(REPLACE(REPLACE(@String,'í','i'),'ì','i'),'î','i'),'ï','i')
    SET @String = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@String,'ó','o'),'ò','o'),'ô','o'),'õ','o'),'ö','o')
    SET @String = REPLACE(REPLACE(REPLACE(REPLACE(@String,'ú','u'),'ù','u'),'û','u'),'ü','u')
    
    /****************************************************************************************************************/
    /** RETIRA ACENTUAÇÃO DAS CONSOANTES **/
    /****************************************************************************************************************/
    SET @String = REPLACE(@String,'ý','y')
    SET @String = REPLACE(@String,'ñ','n')
    SET @String = REPLACE(@String,'ç','c')
            
    RETURN UPPER(@String)

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
DROP VIEW VW_Predicao
GO
CREATE OR ALTER VIEW VW_Predicao
AS
SELECT
PREP.TransportadoraID
,PREP.DocId
,PREP.TipoDocumentoId
,PREP.LocalColetaUf + '-' + PREP.LocalEntregaUf AS OrigemDestinoUF
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
,cast(PREP.ValorMercadoria AS decimal(13,2)) AS ValorMercadoria
,cast(PREP.Peso AS decimal(13,2)) AS  Peso
,PRPVOL.VolumesQTD
,CASE 
    WHEN MUN.codigo_ibge = MUN2.codigo_ibge THEN 5 
    ELSE 
    cast(round(dbo.fncCalcula_Distancia_Coordenada(MUN.latitude,MUN.longitude,MUN2.latitude,MUN2.longitude),1) as decimal(6,1)) END  as Distancia
    ,cast(PREP.TotalFrete AS decimal(13,2)) AS TotalFrete
FROM PREPARACAO AS PREP
INNER JOIN 
    PreparacaoNotasVolumes AS  PRPVOL 
            ON PREP.DocId = PRPVOL.DocID 
            AND PREP.TransportadoraID = PRPVOL.TransportadoraID
INNER JOIN 
    estados AS EST 
            ON PREP.LocalColetaUf COLLATE SQL_Latin1_General_CP1_CI_AI = EST.uf COLLATE SQL_Latin1_General_CP1_CI_AI
INNER JOIN 
    estados AS EST2 
            ON PREP.LocalEntregaUf COLLATE SQL_Latin1_General_CP1_CI_AI = EST2.uf COLLATE SQL_Latin1_General_CP1_CI_AI
LEFT JOIN 
    municipios as mun 
            ON dbo.fnRemoveAcentuacao(prep.LocalColetaCidade) COLLATE SQL_Latin1_General_CP1_CI_AI = dbo.fnRemoveAcentuacao(mun.nome) COLLATE SQL_Latin1_General_CP1_CI_AI
AND EST.codigo_uf = MUN.codigo_uf
LEFT JOIN 
    municipios AS mun2 
            ON dbo.fnRemoveAcentuacao(prep.LocalEntregaCidade) COLLATE SQL_Latin1_General_CP1_CI_AI = dbo.fnRemoveAcentuacao(mun2.nome) COLLATE SQL_Latin1_General_CP1_CI_AI
AND EST2.codigo_uf = MUN2.codigo_uf
GO
--TESTE VIEW QUANTIDADE TOTAL DE DADOS = 128.885 QUANTIDADE VALIDA DE DADOS 128.708
SELECT * FROM VW_Predicao
WHERE Distancia IS NOT NULL 
GO
--PRE ANALISE TOTAL 116 ORIGEM/DESTINO DIFERENTES
SELECT top(29)
    OrigemDestinoUF
    ,COUNT(OrigemDestinoUF) AS CONTADOR
FROM VW_Predicao
WHERE Distancia IS NOT NULL 
AND LocalColetaUf <> LocalEntregaUf
GROUP BY OrigemDestinoUF
ORDER BY CONTADOR DESC
GO
--PRE ANALISE TOTAL 9 ORIGEM/DESTINO IGUAIS 
SELECT
    OrigemDestinoUF
    ,COUNT(OrigemDestinoUF) AS CONTADOR
FROM VW_Predicao
WHERE Distancia IS NOT NULL 
AND LocalColetaUf = LocalEntregaUf
GROUP BY OrigemDestinoUF
ORDER BY CONTADOR DESC
GO
--SELECT FINAL PARA ANALISE
SELECT *
FROM VW_Predicao
WHERE Distancia IS NOT NULL 
AND OrigemDestinoUF in('SP-MT'
,'GO-MT'
,'SP-MA'
,'SP-PA'
,'SP-MG'
,'SP-SC'
,'GO-DF'
,'GO-PA'
,'SP-RJ'
,'SP-PR'
,'GO-MA'
,'DF-GO'
,'SP-RS'
,'MT-GO'
,'SP-GO'
,'SP-BA'
,'SP-SE'
,'MG-SP'
,'SP-DF'
,'SP-TO');
GO

