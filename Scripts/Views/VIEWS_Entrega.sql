CREATE OR ALTER  VIEW VW_GETRELATROMEMITEXCEL AS
SELECT DISTINCT
--ROMANEIO
	ROM.ROMANEIOID AS ROMANEIOID,
	ROM.NROROMANEIO AS NROROMANEIO,
	ROM.ANOROMANEIO AS ANOROMANEIO,
	--ROM.TOTALPESO AS TOTALPESOROMANEIO,
	--ROM.TOTALVOLUMES AS TOTALVOLUMESROMANEIO,
	--ROM.TOTALDOCUMENTOS AS TOTALDOCUMENTOSROMANEIO,
	ROM.DATAEMISSAO AS DATAEMISSAOROMANEIO,
	ROM.FILIALID AS FILIALIDROMANEIO,
	FIL.SIGLA AS SIGLAFILIALROMANEIO,
	FIL.FILIALNOME AS NOMEFILIALROMANEIO,
	ROM.STATUSROMANEIOID AS STATUSROMANEIO,
	ST.SIGLA AS SIGLASTATUSROMANEIO,
	ST.DESCRICAO AS DESCRICAOSTATUSROMANEIO,
	ROM.MOTORISTAID AS MOTORISTAIDROMANEIO,
	MOT.NOME AS NOMEMOTORISTAROMANEIO,
	MOT.CPF AS CPFMOTORISTAROMANEIO,
	ROM.PLACAVEICULO AS PLACAVEICULOROMANEIO,
	ROM.PLACAENGATE AS PLACAENGATEROMANEIO,
	PARC.FILIALID AS FILIALIDPARCEIRA,
	PARC.SIGLA + '-' +  PARC.FILIALNOME AS SIGLAFILIALPARCEIRA,
	ROM.TIPOTABELA,
	COALESCE(SETOR.SETORNOME,'SEM SETOR') AS ROTA,
	(CAST(CASE WHEN DOC.TIPODOCUMENTOID = 1 THEN 'C-' ELSE 'M-' END +  CAST(DOC.NUMERODOC AS VARCHAR(15)) + '-' + DOC.SERIE AS VARCHAR(30))) AS DOCUMENTOS,
	(SELECT SUM(DN.VOLUMES) FROM DOCUMENTONOTA DN WHERE DN.DOCID = DOC.DOCID AND DN.CLIENTEID = DOC.REMETENTEID) AS TOTALVOLUMESROMANEIO,	
	(SELECT SUM(DN.PESO) FROM DOCUMENTOSCOMPOSICAOFRETE DN WHERE DN.DOCID = DOC.DOCID ) AS TOTALPESOROMANEIO,
	(SELECT SUM(DN.TOTALFRETE) FROM DOCUMENTOSCOMPOSICAOFRETE DN WHERE DN.DOCID = DOC.DOCID ) AS TOTALDOCUMENTOSROMANEIO

FROM ROMANEIOENTREGA ROM
  INNER JOIN SITRAWEBNEW.DBO.FILIAIS FIL ON FIL.FILIALID = ROM.FILIALID
  LEFT  JOIN SITRAWEBNEW.DBO.STATUSDOCUMENTO ST ON ST.STATUSDOCUMENTOID = ROM.STATUSROMANEIOID
  INNER JOIN MOTORISTA MOT ON MOT.MOTORISTAID = ROM.MOTORISTAID
  INNER JOIN VEICULOS VEIC ON VEIC.PLACAVEICULO = ROM.PLACAVEICULO
  INNER JOIN ROMANEIOENTREGADETALHES DET ON DET.ROMANEIOID = ROM.ROMANEIOID AND DET.ANOROMANEIO = ROM.ANOROMANEIO
  INNER JOIN DOCUMENTOS DOC ON DOC.DOCID = DET.DOCUMENTOID AND DOC.FILIALID = DET.FILIALDOCUMENTOID
  LEFT JOIN SETORES SETOR ON SETOR.SETORID = DET.SETORESID AND SETOR.FILIALID = DET.FILIALDOCUMENTOID
  LEFT JOIN SITRAWEBNEW.DBO.FILIAIS PARC ON PARC.FILIALID = ROM.FILIALPARCEIRA
GO
CREATE OR ALTER VIEW VW_ColetaSelectSACRomaneio
AS
SELECT DISTINCT
--Romaneio
RomCol.RomaneioColetaId		AS RomaneioColetaId
,RomCol.RomaneioColetaAno	AS RomaneioColetaAno
,RomCol.DataEmissao			AS DataEmissaoRom
,RomCol.DataExecucao		AS DataExecucaoRom
,RomCol.UsuarioIdAlteracao	AS UsuarioAlteracaoRom
,stRom.StatusRomaneioSigla  AS StatusRomaneioSigla
,stRom.StatusRomaneioDesc	AS StatusRomaneioDesc
--Romaneio Motorista
,MotRom.Cpf					AS CpfRom
,MotRom.Nome				AS NomeRom
--Romaneio Veiculo
,VeicRom.PlacaVeiculo		AS PlacaVeiculoRom
,VeicRom.Marca				AS MarcaVeiculoRom
,tpVeic.TipoVeiculoDesc		AS TipoVeiculo
--Filial Romaneio
,FilRom.FilialId			AS FilialIdRom
,FilRom.FilialNome			AS FilialNomeRom
,FilRom.Sigla				AS SiglaRom
FROM RomaneioColetaDetalhes RomDetails
--Romaneio
LEFT OUTER JOIN RomaneioColetas RomCol ON RomCol.RomaneioColetaId = RomDetails.RomaneioColetaId 
	AND RomCol.RomaneioColetaAno = RomDetails.RomaneioColetaAno AND RomCol.FilialId = RomDetails.FilialId
--Status Romaneio
LEFT OUTER JOIN SitraWebNew.dbo.StatusRomaneio stRom on stRom.StatusRomaneioId = RomCol.StatusRomaneioId
--Motorista Romaneio
LEFT OUTER JOIN Motorista MotRom on MotRom.MotoristaId = RomCol.MotoristaId
--Veiculo Romaneio
LEFT OUTER JOIN Veiculos VeicRom ON VeicRom.PlacaVeiculo = RomCol.PlacaVeiculo
LEFT OUTER JOIN TipoVeiculo tpVeic ON tpVeic.TipoVeiculoId = VeicRom.TipoVeiculoId
--Filial Romaneio
LEFT OUTER JOIN SitraWebNew.dbo.Filiais FilRom ON FilRom.FilialId = RomCol.FilialId
GO
CREATE OR ALTER VIEW VW_SelectRomaneioEntregas
AS
SELECT DISTINCT
--Romaneio
rom.RomaneioId as RomaneioId,
rom.NroRomaneio as NroRomaneio,
rom.AnoRomaneio as AnoRomaneio,
rom.TotalPeso as TotalPesoRomaneio,
rom.TotalVolumes as TotalVolumesRomaneio,
rom.TotalDocumentos as TotalDocumentosRomaneio,
rom.Observacao as ObservacaoRomaneio,
rom.DataEmissao as DataEmissaoRomaneio,
rom.DataExecucao as DataExecucaoRomaneio,
rom.KmInicial as KmInicialRomaneio,
rom.KmFinal as KmFinalRomaneio,
rom.ChaveRomaneio as ChaveRomaneio,
rom.DataSaida as DataSaidaRomaneio,
rom.HoraSaida as HoraSaidaRomaneio,
rom.DataPrevChegada as DataPrevChegadaRomaneio,
rom.HoraChegada as HoraPrevChegadaRomaneio,
rom.Produtividade as ProdutividadeRomaneio,
rom.MotivoCancelamento as MotivoCancelamentoRomaneio,
rom.DataCadastro as DataCadastroRomaneio,
rom.DataAlteracao as DataAlteracaoRomaneio,
rom.DataCancelamento as DataCancelamentoRomaneio,

--Filial
rom.FilialId as FilialIdRomaneio,
fil.Sigla as SiglaFilialRomaneio,
fil.FilialNome as NomeFilialRomaneio,
fil.CNPJ as CnpjFilialRomaneio,

--FilialParceira
rom.FilialParceira as FilialParceiraIdRomaneio,
filParc.Sigla as SiglaFilialParceiraRomaneio,
filParc.FilialNome as NomeFilialParceiraRomaneio,
filParc.CNPJ as CnpjFilialParceiraRomaneio,

--Status
rom.StatusRomaneioId as StatusRomaneio,
st.Sigla as SiglaStatusRomaneio,
st.Descricao as DescricaoStatusRomaneio,

--Motorista
rom.MotoristaId as MotoristaIdRomaneio,
mot.Nome as NomeMotoristaRomaneio,
mot.Cpf as CpfMotoristaRomaneio,
mot.RG as RgMotoristaRomaneio,
mot.Habilitacao as CnhMotoristaRomaneio,
mot.CategoriaCNH as CategoriaCnhMotoristaRomaneio,
mot.Endereco as EnderecoMotoristaRomaneio,
mot.Numero as NumeroMotoristaRomaneio,
mot.Complemento as ComplementoMotoristaRomaneio,
mot.Bairro as BairroMotoristaRomaneio,
mot.Cidade as CidadeMotoristaRomaneio,
mot.UF as UfMotoristaRomaneio,
mot.CEP as CepMotoristaRomaneio,

--Status
rom.StatusRomaneioId as RomStId,
st.Sigla as RomStSigla,
st.Descricao as RomStDescricao,

--Veiculo
rom.PlacaVeiculo as PlacaVeiculoRomaneio,
veic.Chassi as ChassiVeiculoRomaneio,
veic.CorVeiculo as CorVeiculoRomaneio,
veic.CapacidadeKg as CpacidadeVeiculoRomaneio,
tpVeic.TipoVeiculoDesc as TipoVeiculoRomaneio,

--Engate
rom.PlacaEngate as PlacaEngateRomaneio,
engate.Chassi as ChassiEngateRomaneio,
engate.CorVeiculo as CorEngateRomaneio,
tpEngate.TipoVeiculoDesc as TipoEngateRomaneio,

--UsuarioCadastro
rom.UsuarioIdCadastro as UsuarioIdCadastro,
userCad.UsuarioNome as NomeUsuarioCadastro,
userCad.NomeCompleto as NomeCompletoCadastro,

--UsuarioAlteracao
rom.UsuarioIdAlteracao as UsuarioIdAlteracao,
userAlt.UsuarioNome as NomeUsuarioAlteracao,
userAlt.NomeCompleto as NomeCompletoUsuarioAlteracao,

--UsuarioCancelamento
rom.UsuarioIdCancelamento as UsuarioIdCancelamento,
userCanc.UsuarioNome as NomeUsuarioCancelamento,
userCanc.NomeCompleto as NomeCompletoUsuarioCancelamento,
rom.TipoTabela

FROM RomaneioEntrega rom
INNER JOIN SitraWebNew.dbo.Filiais fil on fil.FilialId = rom.FilialId
LEFT OUTER JOIN SitraWebNew.dbo.Filiais filParc on filParc.FilialId = rom.FilialParceira
LEFT OUTER JOIN SitraWebNew.dbo.StatusDocumento st on st.StatusDocumentoId = rom.StatusRomaneioId
INNER JOIN Motorista mot on mot.MotoristaId = rom.MotoristaId
INNER JOIN Veiculos veic on veic.PlacaVeiculo = rom.PlacaVeiculo
INNER JOIN TipoVeiculo tpVeic on tpVeic.TipoVeiculoId = veic.TipoVeiculoId
LEFT OUTER JOIN Veiculos engate on engate.PlacaVeiculo = rom.PlacaEngate
LEFT OUTER JOIN TipoVeiculo tpEngate on tpEngate.TipoVeiculoId = engate.TipoVeiculoId
INNER JOIN SitraWebNew.dbo.Usuarios userCad on userCad.UsuarioId = rom.UsuarioIdCadastro
LEFT OUTER JOIN SitraWebNew.dbo.Usuarios userAlt on userAlt.UsuarioId = rom.UsuarioIdAlteracao
LEFT OUTER JOIN SitraWebNew.dbo.Usuarios userCanc on userCanc.UsuarioId = rom.UsuarioIdCancelamento
--LEFT OUTER JOIN StatusDocumento stDoc on stDoc.StatusDocumentoId = rom.StatusRomaneioId
GO
CREATE OR ALTER VIEW VW_SelectHistoricoRomaneioEntrega
AS
SELECT DISTINCT
rom.Id as Id,
rom.RomaneioId as RomaneioId,
rom.AnoRomaneio as AnoRomaneio,
rom.NroRomaneio as NroRomaneio,

--Status
rom.Status as StatusId,
st.Descricao as DescStatus,
st.Sigla as SiglaStatus,

rom.DataHistorico as DataHistorico,
rom.HoraHistorico as HoraHistorico,
rom.Observacao as ObsHistorico,
ChaveRomaneio as ChaveRomaneio,

--Filial Cadastro
rom.FilialIdCadastro as FilialIdCadastro,
filCad.Sigla as SiglaFilialCadastro,
filCad.FilialNome as FilialNomeCadastro,

--Filial Alteracao
rom.FilialIdAlteracao as FilialIdAlteracao,
filAlter.Sigla as SiglaFilialAlteracao,
filAlter.FilialNome as FilialNomeAlteracao,

--Usuario Cadastro
rom.UsuarioIdCadastro as UsuarioCadastroId,
userCad.UsuarioNome as UsuarioCadastroNome,

--Usuario Alteracao 
rom.UsuarioIdAlteracao as UsuarioAlteracaoId,
userAlter.UsuarioNome as UsuarioAlteracaoNome,

rom.DataCadastro as DataCadastro,
rom.DataAlteracao as DataAlteracao

FROM RomaneioEntregaHistorico rom
LEFT OUTER JOIN SitraWebNew.dbo.StatusDocumento st on st.StatusDocumentoId IN (1,2,3,4,5,6,7,8,9,10,11,12,13)
INNER JOIN SitraWebNew.dbo.Filiais filCad on filCad.FilialId = rom.FilialIdCadastro
LEFT OUTER JOIN SitraWebNew.dbo.Filiais filAlter on filAlter.FilialId = rom.FilialIdAlteracao
INNER JOIN SitraWebNew.dbo.Usuarios userCad on userCad.UsuarioId = rom.UsuarioIdCadastro
LEFT OUTER JOIN SitraWebNew.dbo.Usuarios userAlter on userAlter.UsuarioId = rom.UsuarioIdAlteracao
GO
