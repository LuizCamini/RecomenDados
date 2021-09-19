CREATE
OR ALTER VIEW VW_RomaneioEntrega AS
SELECT DISTINCT  rom.RomaneioId AS RomaneioId
     , rom.NroRomaneio AS NroRomaneio
     , rom.AnoRomaneio AS AnoRomaneio
     , rom.TotalPeso AS TotalPesoRomaneio
     , rom.TotalVolumes AS TotalVolumesRomaneio
     , rom.TotalDocumentos AS TotalDocumentosRomaneio
     , rom.Observacao AS ObservacaoRomaneio
     , FORMAT(rom.DataEmissao,'dd/MM/yyyy') AS DataEmissaoRomaneio
     , FORMAT(rom.DataExecucao,'dd/MM/yyyy') AS DataExecucaoRomaneio
     , rom.KmInicial AS KmInicialRomaneio
     , rom.KmFinal AS KmFinalRomaneio
     , FORMAT(rom.DataSaida,'dd/MM/yyyy') AS DataSaidaRomaneio
     , rom.HoraSaida AS HoraSaidaRomaneio
     , rom.FilialId AS FilialIdRomaneio
     , fil.Sigla AS SiglaFilialRomaneio
     , fil.FilialNome AS NomeFilialRomaneio
     , rom.StatusRomaneioId AS StatusRomaneio
     , st.Sigla AS SiglaStatusRomaneio
     , st.Descricao AS DescricaoStatusRomaneio
     , mot.Nome AS NomeMotoristaRomaneio
     , mot.CategoriaCNH AS CategoriaCnhMotoristaRomaneio
     , st.Sigla AS RomStSigla
     , st.Descricao AS RomStDescricao
     , rom.PlacaVeiculo AS PlacaVeiculoRomaneio
  FROM RomaneioEntrega rom INNER JOIN
       SitraWebNew.dbo.Filiais fil ON fil.FilialId = rom.FilialId LEFT OUTER JOIN
       SitraWebNew.dbo.Filiais filParc ON filParc.FilialId = rom.FilialParceira LEFT OUTER JOIN
       SitraWebNew.dbo.StatusDocumento st ON st.StatusDocumentoId = rom.StatusRomaneioId INNER JOIN
       Motorista mot ON mot.MotoristaId = rom.MotoristaId INNER JOIN
       Veiculos veic ON veic.PlacaVeiculo = rom.PlacaVeiculo INNER JOIN
       TipoVeiculo tpVeic ON tpVeic.TipoVeiculoId = veic.TipoVeiculoId LEFT OUTER JOIN
       Veiculos engate ON engate.PlacaVeiculo = rom.PlacaEngate LEFT OUTER JOIN
       TipoVeiculo tpEngate ON tpEngate.TipoVeiculoId = engate.TipoVeiculoId INNER JOIN
       SitraWebNew.dbo.Usuarios userCad ON userCad.UsuarioId = rom.UsuarioIdCadastro LEFT OUTER JOIN
       SitraWebNew.dbo.Usuarios userAlt ON userAlt.UsuarioId = rom.UsuarioIdAlteracao LEFT OUTER JOIN
       SitraWebNew.dbo.Usuarios userCanc ON userCanc.UsuarioId = rom.UsuarioIdCancelamento
