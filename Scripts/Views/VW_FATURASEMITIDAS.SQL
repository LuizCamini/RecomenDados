CREATE
OR ALTER VIEW VW_FATURASEMITIDAS AS
SELECT reb.FilialEmissaoFatura
     , filEmi.Sigla
     ,(CONVERT(VARCHAR,reb.NumeroFatura) + '/' + SUBSTRING(CONVERT(VARCHAR,reb.AnoFatura) ,3,2)) AS Duplicata
     , reb.NumeroFatura
     , reb.AnoFatura
     , reb.NumeroBoleto
     , FORMAT(reb.DataEmissao,'dd/MM/yyyy') AS DataEmissao
     , FORMAT(reb.DataVencimento,'dd/MM/yyyy') AS DataVencimento
     , FORMAT(reb.DataPagamento,'dd/MM/yyyy') AS DataPagamento
     , FORMAT(reb.ValorTotal, 'c','pt-br') AS ValorTotal
     , FORMAT(reb.ValorLiquido, 'c','pt-br') AS ValorLiquido
     , FORMAT(reb.Desconto, 'c','pt-br') AS Desconto
     , FORMAT(reb.Tarifa, 'c','pt-br') AS Tarifa
     , FORMAT(reb.Multa, 'c','pt-br') AS Multa
     , FORMAT(reb.Juros, 'c','pt-br') AS Juros
     , reb.BancoId
     , cb.Codigo
     , cb.NomeBanco
     , reb.StatusRecebimentoId
     , stReb.Sigla AS stRebSigla
     , stReb.Descricao
     , reb.ClientePagadorId
     , cli.NomeFantasia
  FROM Recebimento reb INNER JOIN
       SitraWebNew.dbo.Filiais filEmi ON filEmi.FilialId = reb.FilialEmissaoFatura INNER JOIN
       ContaBancaria cb ON cb.Id = reb.BancoId LEFT JOIN
       SitraWebNew.dbo.StatusRecebimento stReb ON stReb.Id = reb.StatusRecebimentoId INNER JOIN
       Clientes cli ON cli.ClienteId = reb.ClientePagadorId
 WHERE reb.StatusRecebimentoId IS NOT NULL
   AND reb.BancoId IS NOT NULL
   AND reb.ClientePagadorId IS NOT NULL
   AND reb.FilialEmissaoFatura IS NOT NULL
 ORDER BY cli.NomeFantasia ASC
