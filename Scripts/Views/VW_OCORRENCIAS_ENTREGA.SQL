CREATE
OR ALTER VIEW VW_OCORRENCIAS_ENTREGA AS
SELECT OcorrenciaId
     , ClienteId
     , OcorrenciaDesc
     , Responsavel
     , UsuarioIdCadastro
     , FORMAT(DataCadastro,'dd/MM/yyyy') AS DataCadastro
  FROM OcorClienteEntrega;

