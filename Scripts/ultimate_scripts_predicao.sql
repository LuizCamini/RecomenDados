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
--CRIACAO FUNCTION PARA REMOVER ACENTOS
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
,PREP.ValorMercadoria
,PREP.Peso
,PRPVOL.VolumesQTD
,PREP.TotalFrete
,CASE 
    WHEN MUN.codigo_ibge = MUN2.codigo_ibge THEN 5 
    ELSE 
    dbo.fncCalcula_Distancia_Coordenada(MUN.latitude,MUN.longitude,MUN2.latitude,MUN2.longitude) END  as Distancia
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
SELECT
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
---------------------------------------------------------------------------------
CREATE OR ALTER VIEW VW_Predicao_base
AS
SELECT
PREP.TransportadoraID
,PREP.LocalColetaUf + '-' + PREP.LocalEntregaUf AS OrigemDestinoUF
,PREP.ValorMercadoria
,PREP.Peso
,PRPVOL.VolumesQTD
,CASE 
    WHEN MUN.codigo_ibge = MUN2.codigo_ibge THEN 5 
    ELSE 
    dbo.fncCalcula_Distancia_Coordenada(MUN.latitude,MUN.longitude,MUN2.latitude,MUN2.longitude) END  as Distancia
,PREP.TotalFrete as ALVO
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

where PREP.FreteCombinado = 0 
and PREP.TotalFrete >1.00
and PREP.ValorMercadoria > 0 
and cast((PREP.TotalFrete / PREP.ValorMercadoria) * 100 as numeric(13,2)) <= 20.00
and PREP.Peso > 0 
and cast((PREP.TotalFrete / PREP.Peso) * 100 as numeric(13,2)) <= 1000.00
and PRPVOL.VolumesQTD > 0 
and cast((PREP.TotalFrete / PRPVOL.VolumesQTD) * 100 as numeric(13,2)) <= 9000.00




--CRIAR TABELA PREDICAO
select TransportadoraID,
OrigemDestinoUF, 
case
when OrigemDestinoUF = 'MT-MT'
       then 1
when OrigemDestinoUF = 'SP-SP'
       then 2
when OrigemDestinoUF = 'SP-MT'
       then 3
when OrigemDestinoUF = 'SP-MG'
       then 4
when OrigemDestinoUF = 'SP-RJ'
       then 5
when OrigemDestinoUF = 'SP-PR'
       then 6
when OrigemDestinoUF = 'SP-SC'
       then 7
when OrigemDestinoUF = 'SP-PA'
       then 8
when OrigemDestinoUF = 'SP-RS'
       then 9
when OrigemDestinoUF = 'SP-GO'
       then 10
when OrigemDestinoUF = 'SP-BA'
       then 11
when OrigemDestinoUF = 'SP-DF'
       then 12
when OrigemDestinoUF = 'SP-MS'
       then 13
when OrigemDestinoUF = 'SP-PE'
       then 14
when OrigemDestinoUF = 'SP-ES'
       then 15
when OrigemDestinoUF = 'SP-MA'
       then 16
when OrigemDestinoUF = 'SP-PB'
       then 17
when OrigemDestinoUF = 'AL-SP'
       then 18
when OrigemDestinoUF = 'SP-CE'
       then 19
when OrigemDestinoUF = 'SP-RN'
       then 20
when OrigemDestinoUF = 'SP-TO'
       then 21
when OrigemDestinoUF = 'SP-SE'
       then 22
when OrigemDestinoUF = 'SP-PI'
       then 23
when OrigemDestinoUF = 'SP-AL'
       then 24
when OrigemDestinoUF = 'SP-RO'
       then 25
when OrigemDestinoUF = 'MG-SP'
       then 26
when OrigemDestinoUF = 'MG-RJ'
       then 27
when OrigemDestinoUF = 'PR-SP'
       then 28
when OrigemDestinoUF = 'SP-AM'
       then 29
when OrigemDestinoUF = 'PA-SP'
       then 30
when OrigemDestinoUF = 'MG-PE'
       then 31
when OrigemDestinoUF = 'RJ-SP'
       then 32
when OrigemDestinoUF = 'SP-AC'
       then 33
when OrigemDestinoUF = 'RS-SP'
       then 34
when OrigemDestinoUF = 'SP-RR'
       then 35
when OrigemDestinoUF = 'MG-MG'
       then 36
when OrigemDestinoUF = 'PE-SP'
       then 37
when OrigemDestinoUF = 'SP-AP'
       then 38
when OrigemDestinoUF = 'SC-PA'
       then 39
when OrigemDestinoUF = 'DF-SP'
       then 40
when OrigemDestinoUF = 'MG-DF'
       then 41
when OrigemDestinoUF = 'MT-SP'
       then 42
end  as ID_OrigemDestinoUF, 
cast(ValorMercadoria as numeric(8,2)) as ValorMercadoria, 
cast(Peso as            numeric(7,2)) as Peso, 
VolumesQTD, 
cast(round(Distancia, 2) as numeric(6,2)) as Distancia, 
cast(ALVO as numeric(7,2)) as ALVO
INTO PREDICAO
from VW_Predicao_base
where Distancia is not null
and cast((ALVO / Distancia) * 100 as numeric(13,2)) <= 1000.00
GO
--TRUNCATE NA TABELA PREDICAO
TRUNCATE TABLE PREDICAO
GO
--ADICIONANDO COLUNA ID NA TABELA PREDICAO PARA AJUDAR A IGNORAR OS PRIMEIROS E ULTIMOS 1% DA TABELA
ALTER TABLE PREDICAO ADD ID INT IDENTITY
GO
--INSERINDO NOVAMENTE OS DADOS NA TABELA PREDICAO
INSERT INTO PREDICAO select TransportadoraID,
OrigemDestinoUF, 
case
when OrigemDestinoUF = 'MT-MT'
       then 1
when OrigemDestinoUF = 'SP-SP'
       then 2
when OrigemDestinoUF = 'SP-MT'
       then 3
when OrigemDestinoUF = 'SP-MG'
       then 4
when OrigemDestinoUF = 'SP-RJ'
       then 5
when OrigemDestinoUF = 'SP-PR'
       then 6
when OrigemDestinoUF = 'SP-SC'
       then 7
when OrigemDestinoUF = 'SP-PA'
       then 8
when OrigemDestinoUF = 'SP-RS'
       then 9
when OrigemDestinoUF = 'SP-GO'
       then 10
when OrigemDestinoUF = 'SP-BA'
       then 11
when OrigemDestinoUF = 'SP-DF'
       then 12
when OrigemDestinoUF = 'SP-MS'
       then 13
when OrigemDestinoUF = 'SP-PE'
       then 14
when OrigemDestinoUF = 'SP-ES'
       then 15
when OrigemDestinoUF = 'SP-MA'
       then 16
when OrigemDestinoUF = 'SP-PB'
       then 17
when OrigemDestinoUF = 'AL-SP'
       then 18
when OrigemDestinoUF = 'SP-CE'
       then 19
when OrigemDestinoUF = 'SP-RN'
       then 20
when OrigemDestinoUF = 'SP-TO'
       then 21
when OrigemDestinoUF = 'SP-SE'
       then 22
when OrigemDestinoUF = 'SP-PI'
       then 23
when OrigemDestinoUF = 'SP-AL'
       then 24
when OrigemDestinoUF = 'SP-RO'
       then 25
when OrigemDestinoUF = 'MG-SP'
       then 26
when OrigemDestinoUF = 'MG-RJ'
       then 27
when OrigemDestinoUF = 'PR-SP'
       then 28
when OrigemDestinoUF = 'SP-AM'
       then 29
when OrigemDestinoUF = 'PA-SP'
       then 30
when OrigemDestinoUF = 'MG-PE'
       then 31
when OrigemDestinoUF = 'RJ-SP'
       then 32
when OrigemDestinoUF = 'SP-AC'
       then 33
when OrigemDestinoUF = 'RS-SP'
       then 34
when OrigemDestinoUF = 'SP-RR'
       then 35
when OrigemDestinoUF = 'MG-MG'
       then 36
when OrigemDestinoUF = 'PE-SP'
       then 37
when OrigemDestinoUF = 'SP-AP'
       then 38
when OrigemDestinoUF = 'SC-PA'
       then 39
when OrigemDestinoUF = 'DF-SP'
       then 40
when OrigemDestinoUF = 'MG-DF'
       then 41
when OrigemDestinoUF = 'MT-SP'
       then 42
end  as ID_OrigemDestinoUF, 
cast(ValorMercadoria as numeric(8,2)) as ValorMercadoria, 
cast(Peso as            numeric(7,2)) as Peso, 
VolumesQTD, 
cast(round(Distancia, 2) as numeric(6,2)) as Distancia, 
cast(ALVO as numeric(7,2)) as ALVO
from VW_Predicao_base
where Distancia is not null
and cast((ALVO / Distancia) * 100 as numeric(13,2)) <= 1000.00
GO
--VER DADOS - MESMO SELECT UTILIZADO PARA CRIAR O DATASET NO PANDAS
SELECT * FROM PREDICAO WHERE ID BETWEEN 427 AND 42282 --PARA IGNORAR O PRIMEIRO E ULTIMO 1% DA TABELA, PEGANDO OS 98% DO MEIO.

