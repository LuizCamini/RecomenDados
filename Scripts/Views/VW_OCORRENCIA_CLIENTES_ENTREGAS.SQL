CREATE
OR ALTER VIEW  VW_OCORRENCIA_CLIENTES_ENTREGAS
AS
SELECT OcorrenciaId
     , ClienteId
     , OcorrenciaDesc
     , Responsavel
     , UsuarioIdCadastro
     , FORMAT(DataCadastro,'dd/MM/yyyy') as DataOcorrencia
  FROM OcorClienteEntrega
