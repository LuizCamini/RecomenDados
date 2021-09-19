CREATE OR ALTER VIEW VW_RankingClientes 
AS 
SELECT  CASE WHEN LEN(CPFCNPJ) = 14 THEN REPLACE(SUBSTRING(CPFCNPJ,1,3) ,SUBSTRING(CPFCNPJ,1,3) ,'###') +'.'+ SUBSTRING(CPFCNPJ,5,3) +'.'+ SUBSTRING(CPFCNPJ,9,3) +'-'+REPLACE(SUBSTRING(CPFCNPJ,13,2) ,SUBSTRING(CPFCNPJ,13,2) ,'##')
                          WHEN LEN(CPFCNPJ) = 18 THEN REPLACE(SUBSTRING(CPFCNPJ,1,2) ,SUBSTRING(CPFCNPJ,1,2) ,'##') +'.'+SUBSTRING(CPFCNPJ,4,3) +'.'+SUBSTRING(CPFCNPJ,8,3) +SUBSTRING(CPFCNPJ,11,5) +'-'+REPLACE(SUBSTRING(CPFCNPJ,17,2) ,SUBSTRING(CPFCNPJ,17,2) ,'##')
                     END AS CPFCNPJ
     , NomeFantasia
     , COUNT(QtdeDocs) AS Qtdedocs
     , SUM(QtdePeso) AS QtdePeso
     , SUM(QtdePesoCub) AS QtdePesoCub
     , FORMAT(SUM(TotalNfs) ,'c','pt-br') AS TotalNfs
     , CAST(SUM(TotalFrete) AS money) AS TotalFrete
     , SUM(TotalNota) AS TotalNota
     , FilSigla
  FROM (SELECT DISTINCT cli.CpfCnpj
             , cli.NomeFantasia
             , doc.DocId AS QtdeDocs
             , dcf.Peso AS QtdePeso
             , dcf.PesoCubado AS QtdePesoCub
             , dcf.ValorMercadoria AS TotalNfs
             , dcf.TotalFrete AS TotalFrete
             , (SELECT SUM(dn.Volumes)
                  FROM DocumentoNota dn
                 WHERE dn.DocId = doc.DocId
               ) AS totalNota
             , doc.TipoDocumentoId
             , fil.Sigla AS FilSigla
          FROM Clientes cli INNER JOIN
               Documentos doc ON doc.TomadorId = cli.ClienteId INNER JOIN
               DocumentosComposicaoFrete dcf ON dcf.DocId = doc.DocId INNER JOIN
               SitraWebNew.dbo.Filiais fil ON fil.FilialId = doc.FilialId WHERE (
                                                                                 doc.StatusDocumentoId NOT
                                                                                 IN (2,9)
                                                                                )
           AND(doc.TipoFreteId in (1,2,3,4,5,6,7,8,9,10))
           AND((doc.TipoDocumentoId = 1
                    AND doc.StatusDocumentoSefazId = 5) OR(doc.StatusDocumentoSefazId IS NULL
                                                               AND doc.TipoDocumentoId = 5))
           and(dcf.FreteCortesia = 0 OR dcf.FreteCortesia IS null)
       ) AS TblPrinc
 GROUP BY CpfCnpj, NomeFantasia, FilSigla
 ORDER BY TotalFrete DESC
;

