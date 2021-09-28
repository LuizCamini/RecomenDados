CREATE
VIEW VW_OCORRENCIAS AS
SELECT doc.DocId
     , doc.NumeroDoc
     , FORMAT(doc.DataEmissao,'dd/MM/yyyy') AS DataEmissaoDocumento
     , doc.TipoDocumentoId
     , dr.CEP AS CEPRemetente
     , dr.Cidade AS CidadeRemetente
     , dr.UF AS EstadoRemetente
     , UF.NOMEREGIAO AS RegiaoRemetente
     , dd.CEP AS CEPDestinatario
     , dd.Cidade AS CidadeDestinatario
     , dd.UF AS EstadoDestinatario
     , uf2.NOMEREGIAO AS RegiaoDestinatario
     , doc.FilialId
     , fil.Sigla AS FilSigla
     , FORMAT(dh.DataHistorico,'dd/MM/yyyy') AS DataOcorrencia
     , dh.HoraHistorico AS HoraOcorrencia
     , dh.OcorrenciaId
     , dh.OcorrenciaDesc
     , dr.CpfCnpj AS Remetente
     , dd.CpfCnpj AS Destinatario
     , FORMAT(dh.DataCadastro,'dd/MM/yyyy') AS DataIsercao
  FROM Documentos doc INNER JOIN
       SitraWebNew.dbo.Filiais fil ON fil.FilialId = doc.FilialId INNER JOIN
       SitraWebNew.dbo.TipoDocumento td ON td.TipoDocumentoId = doc.TipoDocumentoId INNER JOIN
       DocumentoHistorico dh ON dh.DocId = doc.DocId
   AND dh.OcorrenciaId IS NOT NULL
   AND dh.OcorrenciaId != 0 INNER JOIN
       SitraWebNew.dbo.Usuarios cadUser ON cadUser.UsuarioId = dh.UsuarioIdHistorico INNER JOIN
       DocRemetente dr ON dr.ClienteId = doc.RemetenteId
   AND dr.DocId = doc.DocId INNER JOIN
       DocDestinatario dd ON dd.ClienteId = doc.DestinatarioId
   AND dd.DocId = doc.DocId INNER JOIN
       DocTomador dt ON dt.ClienteId = doc.TomadorId
   AND dt.DocId = doc.DocId LEFT JOIN
       Ocorrencias oc ON oc.OcorrenciaId = dh.OcorrenciaId
   AND oc.OcorrenciaTipo = 'E'
   AND dh.OcorrenciaCliente = 0 LEFT JOIN
       OcorClienteEntrega occ ON occ.OcorrenciaId = dh.OcorrenciaId
   AND occ.ClienteId = dt.ClienteId
   AND dh.OcorrenciaCliente = 1 LEFT JOIN
       sitrawebnew.dbo.cep AS CEP ON DR.CEP = CEP.CepId LEFT JOIN
       sitrawebnew.dbo.cep AS CEP2 ON DD.CEP = CEP.CepId LEFT JOIN
       sitrawebnew.dbo.Estados AS UF ON DR.UF = UF.UF LEFT JOIN
       sitrawebnew.dbo.Estados AS UF2 ON DD.UF = UF.UF LEFT JOIN
       sitrawebnew.dbo.Cidades AS CID ON DR.Cidade = CID.Cidade LEFT JOIN
       sitrawebnew.dbo.Cidades AS CID2 ON DD.Cidade = CID.Cidade WHERE ((dh.OcorrenciaId IS NULL
                                                                             AND coalesce(oc.MercIndeziada,0) != 1
                                                                             AND coalesce(occ.MercIndeziada,0) != 1) or(dh.OcorrenciaId IS NOT null)
                                                                       )
   AND dh.HistoricoId IN  (SELECT HistoricoId
                             FROM (SELECT doc.DocId
                                        , Max(dh.HistoricoId) HistoricoId
                                     FROM Documentos doc INNER JOIN
                                          DocumentoHistorico dh ON dh.DocId = doc.DocId
                                      AND dh.OcorrenciaId IS NOT NULL
                                    WHERE doc.StatusDocumentoId = 8
                                    GROUP BY doc.DocId
                                  ) DadosOcorrencias
                          )
   AND dh.DataCadastro IN  (SELECT DataCadastro
                              FROM (SELECT doc.DocId
                                         , Max(dh.DataCadastro) DataCadastro
                                      FROM Documentos doc INNER JOIN
                                           DocumentoHistorico dh ON dh.DocId = doc.DocId
                                       AND dh.OcorrenciaId IS NOT NULL
                                     WHERE doc.StatusDocumentoId = 8
                                     GROUP BY doc.DocId
                                   ) DadosOcorrencias2
                           )

