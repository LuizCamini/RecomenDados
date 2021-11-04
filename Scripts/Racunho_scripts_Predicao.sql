use OPE
select fretecombinado,count(fretecombinado) from predicao
group by fretecombinado
go
select * from predicao
go
select tipocliente,count(tipocliente) from predicao
group by tipocliente
go

---------------------------------------------------------------------------------------------------------
SELECT *
INTO OPE.DBO.TABELAS_FRETE
FROM  [1836].DBO.VW_TABELAS_FRETE



USE [799]
GO
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
SELECT * FROM OPE.DBO.Predicao
--143.365


-------------------------------------------------------------------------------------------------------------
GO

USE [1836]
GO
CREATE VIEW VW_TABELAS_FRETE
AS
SELECT  
DISTINCT
	TBC.TabelaId as CodigoIdentificadorTabela,
	CLI.CpfCnpj as CNPJCPF,
	upper(CLI.NomeFantasia) AS Cliente,
	upper(TPT.Descricao) AS TipoTabelaDescricao,
	upper(UF.UF) AS UFOrigem,
	upper(CID.Cidade) AS CidadeOrigem,
	upper(TBC.RegiaoOrigemId) AS RegiaoOrigem,
	upper(UF2.UF) AS UFDestino,
	upper(CID2.Cidade) AS CidadeDestino,
	upper(TBC.RegiaoDestinoId) AS RegiaoDestino,
	TBC.ProdutoId AS IDProduto,
	upper(PRDT.ProdutoDesc) AS DescricaoProduto,
	upper(TPV.TipoVeiculoDesc) AS TipoVeiculo,
	CAST(TBC.VigenciaInicial AS date) AS VigenciaInicial,
	CAST(TBC.VigenciaFinal AS DATE) AS VigenciaFinal,
	STB.Descricao AS StatusTabela,
	TBC.PesoMinimo AS PesoMinimo,
	CAST(TBC.FreteMinimo AS money )AS FreteValorMinimo,
	CAST(TBC.FreteTotalMinimo AS money) AS FreteTotalMinimo,
	CASE 
		WHEN TBC.FreteMinimoTaxas = 0 THEN 'NÃO'
		WHEN TBC.FreteMinimoTaxas = 1 THEN 'SIM' END AS FreteMinimoTaxas,
	CAST(TBC.Despacho AS money) AS Despacho,
	CAST(TBC.SecCat AS money) AS SecCat,
	TBC.SeguroPerc AS PercentualSeguro,
	TBC.KgGarantido AS KGGarantido,
	CAST(TBC.FreteValorGarantidoPerc AS money) AS PercentualFreteValorGarantido,
	TCPD.Descricao as TipoPedagio,
	CAST(TBC.ValorPedagio AS money) AS ValorPedagio,
	CASE 
		WHEN TBC.IcmsIncluso = 0 THEN 'NÃO'
		WHEN TBC.IcmsIncluso = 1 THEN 'SIM' END AS ICMSIncluso,
	CASE
		WHEN TBC.DevFreteInf = 0 THEN 'NÃO'
		WHEN TBC.DevFreteInf = 1 THEN 'SIM' END AS FreteDevolucao,
	TBC.DevPercentual,
	CASE 
		WHEN TBC.ReentFreteInf = 0 THEN 'NÃO'
		WHEN TBC.ReentFreteInf = 1 THEN 'SIM' END AS FreteReentrega,
	TBC.ReentPercentual,
	CASE 
		WHEN TBC.TdePadrao = 0 THEN 'NÃO'
		WHEN TBC.TdePadrao = 1 THEN 'SIM' END AS TDEPadrao
FROM TabelaComercial AS TBC
LEFT JOIN CLIENTES AS CLI ON CLI.ClienteId = TBC.ClienteId
LEFT JOIN SITRAWEBNEW.DBO.TipoTabela AS TPT ON TPT.TipoTabelaId = TBC.TipoTabelaId
LEFT JOIN SITRAWEBNEW.DBO.Estados AS UF ON UF.EstadoId = TBC.EstadoOrigemId
LEFT JOIN SITRAWEBNEW.DBO.Estados AS UF2 ON UF2.EstadoId = TBC.EstadoDestinoId
LEFT JOIN Produtos AS PRDT ON PRDT.ProdutoId = TBC.ProdutoId
LEFT JOIN SITRAWEBNEW.DBO.Cidades AS CID ON CID.CidadeId = TBC.CidadeOrigemId AND CID.EstadoId = UF.EstadoId
LEFT JOIN SITRAWEBNEW.DBO.Cidades AS CID2 ON CID2.CidadeId = TBC.CidadeDestinoId AND CID2.EstadoId = UF2.EstadoId
LEFT JOIN TipoVeiculo AS TPV ON TPV.TipoVeiculoId = TBC.TipoVeiculoId
LEFT JOIN RegiaoManifesto AS RGM ON RGM.RegiaoId = TBC.RegiaoOrigemId
LEFT JOIN RegiaoManifesto AS RGM2 ON RGM2.RegiaoId = TBC.RegiaoDestinoId
LEFT JOIN SitraWebnew.dbo.StatusTabela AS STB ON STB.Id = TBC.StatusTabelaId
LEFT JOIN SitraWebnew.DBO.TipoCobrancaPedagio AS TCPD ON TCPD.Id = TBC.TipoCobrancaPedagioId
WHERE STB.Descricao = 'ATIVA'

GO

SELECT *
INTO OPE.DBO.TABELAS_FRETE
FROM  [1836].DBO.VW_TABELAS_FRETE
go
select * from TABELAS_FRETE

go

use [OPE]
go
--select * from INFORMATION_SCHEMA.TABLES
go
select
*
,cast(SUBSTRING(DataEmissao,7,4)+SUBSTRING(DataEmissao,4,2)+SUBSTRING(DataEmissao,1,2) as date) AS DataEmissao
,cast(SUBSTRING(DataVencimento,7,4)+SUBSTRING(DataVencimento,4,2)+SUBSTRING(DataVencimento,1,2) as date) as DataVencimento
,cast(SUBSTRING(DataPagamento,7,4)+SUBSTRING(DataPagamento,4,2)+SUBSTRING(DataPagamento,1,2) as date) as DataPagamento
,DATEDIFF(day,cast(SUBSTRING(DataEmissao,7,4)+SUBSTRING(DataEmissao,4,2)+SUBSTRING(DataEmissao,1,2) as date),cast(SUBSTRING(DataVencimento,7,4)+SUBSTRING(DataVencimento,4,2)+SUBSTRING(DataVencimento,1,2) as date)) as "Dias para Vencimento"
,DATEDIFF(day,cast(SUBSTRING(DataEmissao,7,4)+SUBSTRING(DataEmissao,4,2)+SUBSTRING(DataEmissao,1,2) as date),cast(SUBSTRING(DataPagamento,7,4)+SUBSTRING(DataPagamento,4,2)+SUBSTRING(DataPagamento,1,2) as date)) as "Dias de emissao ate pagamento"
,DATEDIFF(day,cast(SUBSTRING(DataVencimento,7,4)+SUBSTRING(DataVencimento,4,2)+SUBSTRING(DataVencimento,1,2) as date),cast(SUBSTRING(DataPagamento,7,4)+SUBSTRING(DataPagamento,4,2)+SUBSTRING(DataPagamento,1,2) as date)) as "Dias Do vencimento ao pagamento"
from VW_FATURASEMITIDAS
where stRebSigla not in ('CA','BP','ED')
GO

select distinct stRebSigla from VW_FATURASEMITIDAS

--R$ 5,00 >> R$ 244.059,83

--Total clientes 1.202
--Menor R$ 5,00
--Meio  R$ 122.030
--Maior R$ 244.059,83


USE [1836]
GO
select * from INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE '%CONTRAT%'
GO

CUSTO DE TRANSPORTE ebitida


CUSTO
RECEITA


SELECT * FROM ContratoFrete


SELECT COUNT(FreteCombinado),FreteCombinado FROM DocumentosComposicaoFrete
GROUP BY FreteCombinado

SELECT * FROM TabelaFaixas
SELECT * FROM DocumentosComposicaoFrete

select * from SitraWebnew.dbo.Estados


SELECT *
INTO OPE.DBO.Predicao
from  VW_PREDICAO
GO


USE [107]
GO 
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
--5 Regioes > 27 Estados > 5.570 Cidades Coleta
--5 Regioes > 27 Estados > 5.570 Cidades Entrega


SELECT TOP(10) * FROM TabelaComercial
SELECT TOP(10) * FROM TabelaFaixas

SELECT TOP(10) * FROM Documentos
SELECT TOP(10) * FROM DOCUMENTOSCOMPOSICAOFRETE
SELECT TOP(10) * FROM Clientes

SELECT * FROM SitraWebnew.DBO.TipoTabela

SELECT * FROM SitraWebnew.DBO.RamoAtividade

GO

SELECT  TB.NAME,COL.NAME  FROM SYS.columns COL
INNER JOIN SYS.tables AS TB ON TB.object_id = COL.object_id 
WHERE COL.NAME LIKE '%VOLUME%'

SELECT * FROM SYS.TABLES

SELECT * FROM DocumentoNota
GO
