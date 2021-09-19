CREATE
OR ALTER VIEW AS VW_OCORRENCIA_CLIENTES_ENTREGAS
SELECT OcorrenciaId
     , ClienteId
     , OcorrenciaDesc
     , Responsavel
     , UsuarioIdCadastro
     , FORMAT(DataCadastro,'dd/MM/yyyy') as DataOcorrencia
  FROM OcorClienteEntrega
