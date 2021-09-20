CREATE
OR ALTER VIEW VW_ExtratoNaoConciliado AS
SELECT FORMAT(DATALANCTO,'dd/MM/yyyy','pt-br') AS DATALANCTO
     , NrOrdem
     , Titulo
     , NomeFantasia
     , Historico
     , CREDITO
	 , CENTROCUSTO
	 , DEBITO
     , SUBCUSTO
     , Ordem
  FROM (SELECT CP.DATAPGTO AS DATALANCTO
             , CP.NRCHEQUE
             , CP.NRORDEM
             , CP.NRTITULO AS TITULO
             , F.NOMEFANTASIA
             , CP.OBSERVACAO AS HISTORICO
             , 0 AS CREDITO
             , CP.VALORTOTALPAGO AS DEBITO
             , 6 AS ORDEM
             , 'Credito' AS DEBCRED
             , CC.DESCRICAO AS CENTROCUSTO
             , SC.DESCRICAO AS SUBCUSTO
          FROM CONTASAPAGAR CP INNER JOIN
               FORNECEDORES F ON F.ID = CP.FORNECEDORID INNER JOIN
               PlanoContas AS PCC ON CP.CENTROCUSTOID = PCC.CentroCustoId INNER JOIN
               PlanoContas AS PCS ON CP.SUBCUSTOID = PCS.SubcustoId INNER JOIN
               CentrosCustos AS CC ON CC.Id = PCC.CentroCustoId INNER JOIN
               Subcustos AS SC ON SC.ID = PCS.SubcustoId WHERE (
                                                                CP.CONCILIADO = 0 OR CP.CONCILIADO IS NULL
                                                               )
           AND CP.DATAPGTO IS NOT NULL UNION ALL
SELECT LT.DATALANCTO AS DATALANCTO
             , NULL AS NRCHEQUE
             , LT.NRLANCTO AS NRORDEM
             , NULL AS TITULO
             , FIL.FILIALNOME AS NOMEFANTASIA
             , LT.HISTORICO
             , CASE WHEN LT.DEBITOCREDITO = 'C' THEN LT.VALOR
                                                ELSE 0
               END AS CREDITO
             , CASE WHEN LT.DEBITOCREDITO = 'D' THEN LT.VALOR
                                                ELSE 0
               END AS DEBITO
             , 3 AS ORDEM
             , 'Credito' AS DEBCRED
             , CC.DESCRICAO AS CENTROCUSTO
             , SC.DESCRICAO AS SUBCUSTO
          FROM LANCAMENTOSTRANSFERENCIAS LT INNER JOIN
               SITRAWEBNEW.DBO.FILIAIS FIL ON FIL.FILIALID = LT.FILIALID INNER JOIN
               PlanoContas AS PCC ON LT.CENTROCUSTOID = PCC.CentroCustoId INNER JOIN
               PlanoContas AS PCS ON LT.SUBCUSTOID = PCS.SubcustoId INNER JOIN
               CentrosCustos AS CC ON CC.Id = PCC.CentroCustoId INNER JOIN
               Subcustos AS SC ON SC.ID = PCS.SubcustoId
         WHERE LT.BANCOCREDTRANSID IS NULL
           AND LT.BANCODEBTRANSID IS NULL
           AND LT.DEBITOCREDITO = 'C'
           AND LT.DATALANCTO IS NOT NULL UNION ALL
SELECT LT.DATALANCTO AS DATALANCTO
             , NULL AS NRCHEQUE
             , LT.NRLANCTO AS NRORDEM
             , NULL AS TITULO
             , FIL.FILIALNOME AS NOMEFANTASIA
             , LT.HISTORICO
             , CASE WHEN LT.DEBITOCREDITO = 'C' THEN LT.VALOR
                                                ELSE 0
               END AS CREDITO
             , CASE WHEN LT.DEBITOCREDITO = 'D' THEN LT.VALOR
                                                ELSE 0
               END AS DEBITO
             , 3 AS ORDEM
             , 'Debito' AS DEBCRED
             , CC.DESCRICAO AS CENTROCUSTO
             , SC.DESCRICAO AS SUBCUSTO
          FROM LANCAMENTOSTRANSFERENCIAS LT INNER JOIN
               SITRAWEBNEW.DBO.FILIAIS FIL ON FIL.FILIALID = LT.FILIALID INNER JOIN
               PlanoContas AS PCC ON LT.CENTROCUSTOID = PCC.CentroCustoId INNER JOIN
               PlanoContas AS PCS ON LT.SUBCUSTOID = PCS.SubcustoId INNER JOIN
               CentrosCustos AS CC ON CC.Id = PCC.CentroCustoId INNER JOIN
               Subcustos AS SC ON SC.ID = PCS.SubcustoId
         WHERE LT.BANCOCREDTRANSID IS NULL
           AND LT.BANCODEBTRANSID IS NULL
           AND LT.DEBITOCREDITO = 'D'
           AND LT.DATALANCTO IS NOT NULL UNION ALL
SELECT LT.DATALANCTO AS DATALANCTO
             , NULL AS NRCHEQUE
             , LT.NRLANCTO AS NRORDEM
             , NULL AS TITULO
             , FIL.FILIALNOME AS NOMEFANTASIA
             , LT.HISTORICO
             , LT.VALOR AS CREDITO
             , 0 AS DEBITO
             , 4 AS ORDEM
             , 'Credito' AS DEBCRED
             , CC.DESCRICAO AS CENTROCUSTO
             , SC.DESCRICAO AS SUBCUSTO
          FROM LANCAMENTOSTRANSFERENCIAS LT INNER JOIN
               SITRAWEBNEW.DBO.FILIAIS FIL ON FIL.FILIALID = LT.FILIALID INNER JOIN
               PlanoContas AS PCC ON LT.CENTROCUSTOID = PCC.CentroCustoId INNER JOIN
               PlanoContas AS PCS ON LT.SUBCUSTOID = PCS.SubcustoId INNER JOIN
               CentrosCustos AS CC ON CC.Id = PCC.CentroCustoId INNER JOIN
               Subcustos AS SC ON SC.ID = PCS.SubcustoId
         WHERE LT.CONTABANCOLANCID IS NULL
           AND LT.DATALANCTO IS NOT NULL UNION ALL
SELECT LT.DATALANCTO AS DATALANCTO
             , NULL AS NRCHEQUE
             , LT.NRLANCTO AS NRORDEM
             , NULL AS TITULO
             , FIL.FILIALNOME AS NOMEFANTASIA
             , LT.HISTORICO
             , 0 AS CREDITO
             , LT.VALOR AS DEBITO
             , 5 AS ORDEM
             , 'Debito' AS DEBCRED
             , CC.DESCRICAO AS CENTROCUSTO
             , SC.DESCRICAO AS SUBCUSTO
          FROM LANCAMENTOSTRANSFERENCIAS LT INNER JOIN
               SITRAWEBNEW.DBO.FILIAIS FIL ON FIL.FILIALID = LT.FILIALID INNER JOIN
               PlanoContas AS PCC ON LT.CENTROCUSTOID = PCC.CentroCustoId INNER JOIN
               PlanoContas AS PCS ON LT.SUBCUSTOID = PCS.SubcustoId INNER JOIN
               CentrosCustos AS CC ON CC.Id = PCC.CentroCustoId INNER JOIN
               Subcustos AS SC ON SC.ID = PCS.SubcustoId
         WHERE LT.CONTABANCOLANCID IS NULL
           AND LT.DATALANCTO IS NOT NULL UNION ALL
SELECT DATALANCTO
             , NRCHEQUE
             , NRORDEM
             , TITULO
             , NOMEFANTASIA
             , HISTORICO
             , SUM(CREDITO)
             , DEBITO
             , ORDEM
             , 'Credito' AS DEBCRED
             , 'Receitas' AS CENTROCUSTO
             , 'Receitas' AS SUBCUSTO
          FROM (SELECT DISTINCT RP.DATACHEQUEDEPOSITO AS DATALANCTO
                     , NULL AS NRCHEQUE
                     , NULL AS NRORDEM
                     , NULL AS TITULO
                     , 'CLIENTES DIVERSOS' AS NOMEFANTASIA
                     , 'TITULOS LIQUIDADOS' AS HISTORICO
                     , RP.VALORBAIXA AS CREDITO
                     , 0 AS DEBITO
                     , 0 AS ORDEM
                     , R.REBID
                  FROM RECEBIMENTO R INNER JOIN
                       RECEBIMENTOPAGAMENTOS RP ON RP.REBID = R.REBID
                   AND RP.TIPOPAGAMENTOID = 1
                 WHERE R.STATUSRECEBIMENTOID = 2
                   AND RP.DATACHEQUEDEPOSITO IS NOT NULL
               ) REB
         GROUP BY DATALANCTO, NRCHEQUE, NRORDEM, TITULO, NOMEFANTASIA, HISTORICO, DEBITO, ORDEM UNION ALL
SELECT DISTINCT RP.DATACHEQUEDEPOSITO AS DATALANCTO
             , NULL AS NRCHEQUE
             , NULL AS NRORDEM
             , NULL AS TITULO
             , CLI.NOMEFANTASIA AS NOMEFANTASIA
             , CAST('DEPOSITO Nº: ' + COALESCE(RP.NUMEROCHEQUE,'0') + ' REF. FAT. N°' + CAST(R.NUMEROFATURA AS VARCHAR(20)) + '/' + CAST(R.ANOFATURA AS VARCHAR(4)) AS VARCHAR(100)) AS HISTORICO
             , RP.VALORBAIXA AS CREDITO
             , 0 AS DEBITO
             , 2 AS ORDEM
             , 'Credito' AS DEBCRED
             , 'Recebimento' AS CENTROCUSTO
             , 'Recebimento' AS SUBCUSTO
          FROM RECEBIMENTO R INNER JOIN
               RECEBIMENTOPAGAMENTOS RP ON RP.REBID = R.REBID
           AND RP.TIPOPAGAMENTOID != 1 INNER JOIN
               CLIENTES CLI ON CLI.CLIENTEID = R.CLIENTEPAGADORID
         WHERE R.STATUSRECEBIMENTOID IN (2,4)
           AND RP.DATACHEQUEDEPOSITO IS NOT NULL UNION ALL
SELECT DISTINCT FV.DATAPAGAMENTO AS DATALANCTO
             , NULL AS NRCHEQUE
             , NULL AS NRORDEM
             , NULL AS TITULO
             , CLI.NOMEFANTASIA AS NOMEFANTASIA
             , CAST('RECEBIMENTO DE CT-E/MD-E FIL ' + UPPER(FIL.SIGLA) + ' NR. ' + CAST(FV.NUMERODOCUMENTO AS VARCHAR(20)) + '.' AS VARCHAR(200)) AS HISTORICO
             , FV.VALORPAGO AS CREDITO
             , 0 AS DEBITO
             , 1 AS ORDEM
             , 'Credito' AS DEBCRED
             , 'Recebimento' AS CENTROCUSTO
             , 'Recebimento' AS SUBCUSTO
          FROM FRETEAVISTA FV INNER JOIN
               CLIENTES CLI ON CLI.CLIENTEID = FV.TOMADORID INNER JOIN
               SITRAWEBNEW.DBO.FILIAIS FIL ON FIL.FILIALID = FV.FILIALORIGEMID
         WHERE FV.STATUSFATURAMENTOID = 3
           AND FV.DATAPAGAMENTO IS NOT NULL
       ) MAIN ;
