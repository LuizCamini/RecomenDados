CREATE
OR ALTER VIEW VW_OperacionalManifestos AS
SELECT DISTINCT doc.DocId AS DocumentoId
     , doc.NumeroDoc AS NumeroDocumento
     , doc.Serie AS Serie
     , FORMAT(doc.DataEmissao,'dd/MM/yyyy','pt-br') AS DataEmissao
     , doc.LocalEntregaCidade AS LocalEntregaCidade
     , doc.LocalEntregaUf AS localEntregaUf
     , doc.DataCadastro AS DataCadastro
     , EstUf.regiao AS RegiaoEntrega
     , doc.LocalColetaUf AS localcoletaUf
     , EstUf2.regiao AS RegiaoColeta
     , doc.FilialId AS FilialOrigemId
     , filOrigem.Sigla AS FilialOrigemSigla
     , doc.FilialDestinoId AS FilialdestinoId
     , fildestino.Sigla AS FilialdestinoSigla
     , doc.TipoDocumentoId AS TipoDocumentoId
     , CASE WHEN tipoDoc.Identificador = 'C' then 'Conhecimento (CT-e)'
            when tipoDoc.Identificador = 'M' then 'Minuta (MD-e)'
                                             else ''
       end AS TipoDocumentoIdentificador
     , doc.StatusDocumentoId AS StatusDocumentoId
     , stDocumento.Descricao AS StatusDocumentoDescricao
     , stDocumento.Sigla AS StatusDocumentoSigla
     , doc.ProdutoId AS ProdutoId
     , compFrete.ValorMercadoria AS ValorMercadoria
     , compFrete.Peso AS Peso
     , compFrete.PesoCubado AS PesoCubado
     , compFrete.TotalFrete AS TotalFrete
     , doc.RemetenteId AS RemetenteId
     , cliRem.CpfCnpj AS RemetenteCpfCnpj
     , cliRem.NomeFantasia AS RemetenteNomeFantasia
     , doc.DestinatarioId AS DestinatarioId
     , cliDest.CpfCnpj AS DestinatarioCpfCnpj
     , cliDest.NomeFantasia AS DestinatarioNomeFantasia
     , doc.TomadorId AS TomadorId
     , doc.TipoFreteId AS TipoFreteId
     , tpFrete.TipoFreteDesc AS TipoFreteDesc
     , (SELECT TOP 1 NumeroNota
          FROM DocumentoNota dn1
         WHERE dn1.DocId = doc.DocId
           AND dn1.ClienteId = doc.RemetenteId
       ) AS NumeroNotaFiscal
     , (SELECT SUM(Volumes)
          FROM DocumentoNota dn
         WHERE dn.DocId = doc.DocId
           AND dn.ClienteId = doc.RemetenteId
       ) AS Volumes
  FROM Documentos doc INNER JOIN
       DocDestinatario cliDest ON cliDest.DocId = doc.DocId
   AND cliDest.ClienteId = doc.DestinatarioId INNER JOIN
       DocRemetente cliRem ON cliRem.DocId = doc.DocId
   AND cliRem.ClienteId = doc.RemetenteId INNER JOIN
       DocumentosComposicaoFrete compFrete ON compFrete.DocId = doc.DocId INNER JOIN
       SitraWebNew.dbo.Filiais filOrigem ON filOrigem.FilialId = doc.FilialId INNER JOIN
       SitraWebNew.dbo.TipoDocumento tipoDoc ON tipoDoc.TipoDocumentoId = doc.TipoDocumentoId INNER JOIN
       SitraWebNew.dbo.StatusDocumento stDocumento ON stDocumento.StatusDocumentoId = doc.StatusDocumentoId LEFT JOIN
       SitraWebNew.dbo.StatusDocumentoSefaz stDocumentoSefaz ON stDocumentoSefaz.StatusDocumentoSefazId = doc.StatusDocumentoSefazId INNER JOIN
       SitraWebNew.dbo.TipoFrete tpFrete ON tpFrete.TipoFreteId = doc.TipoFreteId INNER JOIN
       DocumentoNota docNota ON doc.DocId = docNota.DocId
   AND docNota.ClienteId = doc.RemetenteId INNER JOIN
       SitraWebnew.DBO.Estados AS EstUf ON EstUf.UF = doc.LocalEntregaUf INNER JOIN
       SitraWebnew.DBO.Estados AS EstUf2 ON EstUf2.UF = doc.LocalColetaUf INNER JOIN
       SitraWebnew.DBO.FILIAIS AS fildestino ON fildestino.FilialId = DOC.FilialDestinoId
 WHERE(doc.NumeroTemporario IS NULL)
   AND(doc.TipoDocumentoId = 1
           AND doc.StatusDocumentoSefazId IS NOT NULL
           AND DOC.StatusDocumentoSefazId NOT IN (1,2,3,4,6,7,8,10)) ;

