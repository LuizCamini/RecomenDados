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