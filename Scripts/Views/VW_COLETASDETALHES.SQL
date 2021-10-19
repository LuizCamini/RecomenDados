CREATE
OR ALTER VIEW VW_COLETASDETALHES AS
SELECT DISTINCT Col.ColetaId AS ColetaId
     , Col.FilialId AS FilialId
     , Col.Peso AS Peso
     , Col.PesoCubado AS PesoCubado
     , Col.Volumes AS Volumes
     , Col.Especie AS Especie
     , Col.ColetarAteHoras AS ColetarAteHoras
     , Col.HorarioAlmocoInicio AS HorarioAlmocoInicio
     , Col.HorarioAlmocoTermino AS HorarioAlmocoTermino
     , FORMAT(Col.DataAgendamento,'dd/MM/yyyy') AS DataAgendamento
     , Mot.Nome AS Nome
     , Veic.PlacaVeiculo AS PlacaVeiculo
     , tpVeic.TipoVeiculoDesc AS TipoVeiculo
     , FORMAT(Col.DataEmissao,'dd/MM/yyyy') AS DataEmissao
     , Dest.NomeFantasia AS NomeFantasiaDest
     , Dest.Endereco AS EnderecoDest
     , Dest.Cidade AS CidadeDest
     , Dest.UF AS UFDest
     , Dest.Bairro AS BairroDest
     , Remet.NomeFantasia AS NomeFantasiaRemet
     , Remet.Endereco AS EnderecoRemet
     , Remet.Cidade AS CidadeRemet
     , Remet.UF AS UFRemet
     , Remet.Bairro AS BairroRemet
     , LocCol.NomeFantasia AS NomeFantasiaLocal
     , ColLocal.Endereco AS EnderecoLocal
     , ColLocal.Numero AS NumeroLocal
     , ColLocal.Cidade AS CidadeLocal
     , ColLocal.UF AS UFLocal
     , ColLocal.Bairro AS BairroLocal
     , ColLocal.CEP AS CEPLocal
     , ColLocal.Solicitante AS SolicitanteLocal
     , Prod.ProdutoDesc AS ProdutoDesc
     , TpFrete.TipoFreteDesc AS TipoFreteDesc
     , CASE 
     	WHEN ColSt.ColetaStatusSigla IS NULL THEN 'EM'
     	ELSE ColSt.ColetaStatusSigla END  AS ColetaStatusSigla
     , CASE 
     	WHEN ColSt.ColetaStatusDesc IS NULL THEN 'Emitida'
     	ELSE ColSt.ColetaStatusDesc  END AS ColetaStatusDesc
     , Fil.Sigla AS Sigla
  FROM Coleta Col LEFT OUTER JOIN
       ColetaDestinatario ColDest ON ColDest.ColetaId = Col.ColetaId
   AND ColDest.FilialId = Col.FilialId LEFT OUTER JOIN
       Clientes Dest ON Dest.ClienteId = ColDest.ClienteId LEFT OUTER JOIN
       ColetaRemetente ColRemet ON ColRemet.ColetaId = Col.ColetaId
   AND ColRemet.FilialId = Col.FilialId LEFT OUTER JOIN
       Clientes Remet ON Remet.ClienteId = ColRemet.ClienteId LEFT OUTER JOIN
       ColetaLocal ColLocal ON ColLocal.ColetaId = Col.ColetaId
   AND ColLocal.FilialId = Col.FilialId LEFT OUTER JOIN
       Clientes LocCol ON LocCol.ClienteId = ColLocal.ClienteId LEFT OUTER JOIN
       SitraWebNew.dbo.Usuarios UsuCadCol ON UsuCadCol.UsuarioId = Col.UsuarioIdAlteracao LEFT OUTER JOIN
       SitraWebNew.dbo.Usuarios UsuAltCol ON UsuAltCol.UsuarioId = Col.UsuarioIdAlteracao LEFT OUTER JOIN
       SitraWebNew.dbo.ColetaStatus ColSt ON ColSt.ColetaStatusId = Col.ColetaStatusId LEFT OUTER JOIN
       SitraWebNew.dbo.TipoFrete TpFrete ON TpFrete.TipoFreteId = Col.TipoFreteId LEFT OUTER JOIN
       Motorista Mot ON Mot.MotoristaId = Col.MotoristaId LEFT OUTER JOIN
       Veiculos Veic ON Veic.PlacaVeiculo = Col.PlacaVeiculo LEFT OUTER JOIN
       TipoVeiculo tpVeic ON tpVeic.TipoVeiculoId = Veic.TipoVeiculoId LEFT OUTER JOIN
       SitraWebNew.dbo.Filiais Fil ON Fil.FilialId = Col.FilialId LEFT OUTER JOIN
       Produtos Prod ON Prod.ProdutoId = Col.ProdutoId
 ORDER BY Col.ColetaId
