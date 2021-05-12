CREATE OR ALTER  VIEW VW_OperacionalManifestos AS
SELECT DISTINCT

doc.DocId as DocumentoId,
doc.NumeroDoc as NumeroDocumento,
doc.Serie as Serie,
doc.DataEmissao as DataEmissao,
doc.LocalEntregaCidade as LocalEntregaCidade,
doc.LocalEntregaUf as localEntregaUf,
EstUf.regiao as RegiaoEntrega,
doc.LocalColetaUf as localcoletaUf,
EstUf2.regiao as RegiaoColeta,
doc.DataCadastro as DataCadastro,
doc.FilialId as FilialOrigemId,
filOrigem.Sigla as FilialOrigemSigla,
doc.FilialDestinoId as FilialdestinoId,
fildestino.Sigla as FilialdestinoSigla,
doc.TipoDocumentoId as TipoDocumentoId,
CASE WHEN
	tipoDoc.Identificador = 'C' then 'Conhecimento (CT-e)'
	when tipoDoc.Identificador = 'M' then 'Minuta (MD-e)' else ''
end  as TipoDocumentoIdentificador,
doc.StatusDocumentoId as StatusDocumentoId,
stDocumento.Descricao as StatusDocumentoDescricao,
stDocumento.Sigla as StatusDocumentoSigla,
doc.ProdutoId as ProdutoId,
compFrete.ValorMercadoria as ValorMercadoria,
compFrete.Peso as Peso,
compFrete.PesoCubado as PesoCubado,
compFrete.TotalFrete as TotalFrete,
doc.RemetenteId as RemetenteId,
cliRem.CpfCnpj as RemetenteCpfCnpj,
cliRem.NomeFantasia as RemetenteNomeFantasia,
doc.DestinatarioId as DestinatarioId,
cliDest.CpfCnpj as DestinatarioCpfCnpj,
cliDest.NomeFantasia as DestinatarioNomeFantasia,
doc.ExpedidorId as ExpedidorId,
doc.RecebedorId as RecebedorId,
doc.RedespachoId as RedespachoId,
doc.TomadorId as TomadorId,
doc.TipoFreteId as TipoFreteId,
tpFrete.TipoFreteDesc as TipoFreteDesc,
(SELECT top 1 NumeroNota FROM DocumentoNota dn1 WHERE   dn1.DocId = doc.DocId and dn1.ClienteId = doc.RemetenteId) as NumeroNotaFiscal,
(SELECT SUM(Volumes) FROM DocumentoNota dn WHERE dn.DocId = doc.DocId and dn.ClienteId = doc.RemetenteId) as Volumes
FROM Documentos doc 
INNER JOIN DocDestinatario cliDest on cliDest.DocId = doc.DocId and cliDest.ClienteId = doc.DestinatarioId
INNER JOIN DocRemetente cliRem on cliRem.DocId = doc.DocId and cliRem.ClienteId = doc.RemetenteId
INNER JOIN DocumentosComposicaoFrete compFrete on compFrete.DocId = doc.DocId
INNER JOIN SitraWebNew.dbo.Filiais filOrigem on filOrigem.FilialId = doc.FilialId
INNER JOIN SitraWebNew.dbo.TipoDocumento tipoDoc on tipoDoc.TipoDocumentoId = doc.TipoDocumentoId
INNER JOIN SitraWebNew.dbo.StatusDocumento stDocumento on stDocumento.StatusDocumentoId = doc.StatusDocumentoId
LEFT JOIN SitraWebNew.dbo.StatusDocumentoSefaz stDocumentoSefaz on stDocumentoSefaz.StatusDocumentoSefazId = doc.StatusDocumentoSefazId
INNER JOIN SitraWebNew.dbo.TipoFrete tpFrete on tpFrete.TipoFreteId = doc.TipoFreteId
INNER JOIN DocumentoNota docNota on doc.DocId = docNota.DocId and docNota.ClienteId = doc.RemetenteId 
INNER JOIN SitraWebnew.DBO.Estados as EstUf on EstUf.UF = doc.LocalEntregaUf
INNER JOIN SitraWebnew.DBO.Estados as EstUf2 on EstUf2.UF = doc.LocalColetaUf
INNER JOIN SitraWebnew.DBO.FILIAIS AS fildestino ON fildestino.FilialId = DOC.FilialDestinoId
WHERE 
(doc.NumeroTemporario IS NULL)
AND (doc.TipoDocumentoId = 1 and doc.StatusDocumentoSefazId IS NOT NULL AND DOC.StatusDocumentoSefazId NOT IN (1,2,3,4,6,7,8,10))
go