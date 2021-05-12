CREATE OR ALTER  VIEW VW_ConsultaFaturasParaBaixa AS
SELECT 
FatId,
--TpDoc
tpDoc.Identificador,
--Filial Doc
fat.FilialDocumentoId,
fil.Sigla,
--Documento
fat.DocumentoId,
doc.NumeroDoc,
--
CAST(fat.ValorTotalDocumento as NUMERIC(15, 2)) as ValorTotalDocumento,
fat.DescontoFaturamento,
fat.DescontoBaixa,
fat.JurosBaixa,
--Status Fat
fat.StatusFaturamentoId,
st.Sigla as stFat,
--Desc. Faturar
reb.Desconto,
(reb.Desconto / (select count(*) from Faturas )) as DescFaturar,

(SELECT CAST(
   CASE WHEN EXISTS(SELECT * FROM RecebimentoPagamentos where FaturaId = fat.FatId ) THEN 1 
   ELSE 0 
   END 
AS BIT)) as PodeEstornar

FROM Faturas fat
LEFT OUTER JOIN SitraWebNew.dbo.TipoDocumento tpDoc on tpDoc.TipoDocumentoId = fat.TipoDocumentoId
LEFT OUTER JOIN SitraWebNew.dbo.Filiais fil on fil.FilialId = fat.FilialDocumentoId
LEFT OUTER JOIN Documentos doc on doc.DocId = fat.DocumentoId
LEFT OUTER JOIN SitraWebNew.dbo.StatusFaturamento st on st.Id = fat.StatusFaturamentoId
LEFT OUTER JOIN Recebimento reb on reb.NumeroFatura = fat.NumeroFatura and reb.AnoFatura = fat.AnoFatura
GO
CREATE OR ALTER  VIEW VW_ConsultaCargaFaturamento AS 
	
	SELECT DOC.* FROM Documentos doc 
	INNER JOIN DocumentosComposicaoFrete f on f.DocId = doc.DocId 
	where 
	doc.NumeroTemporario IS NULL 
	AND (doc.CargaFat = 0 OR doc.CargaFat IS NULL)
	AND doc.TipoFreteId in (1, 2, 5, 6, 9)
	AND doc.StatusDocumentoId IS NOT NULL
	AND f.FreteCortesia = 0
GO
CREATE OR ALTER  VIEW VW_DocumentoSelectFaturaSac AS

	SELECT reb.NumeroFatura, reb.AnoFatura, reb.FilialEmissaoFatura, fil.Sigla, reb.DataVencimento, reb.DataEmissao, reb.ValorTotal, sr.Descricao FROM Faturas fat
	LEFT OUTER JOIN Recebimento reb on reb.NumeroFatura = fat.NumeroFatura and reb.AnoFatura = fat.AnoFatura and reb.FilialEmissaoFatura = fat.FilialEmissaoFaturaId
	LEFT OUTER JOIN SitraWebNew.dbo.Filiais fil on fil.FilialId = reb.FilialEmissaoFatura 
	LEFT OUTER JOIN SitraWebNew.dbo.StatusRecebimento sr on sr.Id = reb.StatusRecebimentoId
GO
CREATE OR ALTER  VIEW VW_PesquisaFaturas AS 
	
Select 
reb.AnoFatura
,reb.NumeroFatura
,reb.RebId
,b.NomeFantasia
,'' as EmailParaEnvioFaturaBoleto
,reb.ValorTotal
,reb.DataEmissao
,reb.DataVencimento
,reb.StatusRecebimentoId
From Recebimento reb
left join clientes b on b.ClienteId = reb.ClientePagadorId
GO
CREATE OR ALTER  VIEW VW_SelectExtratoConciliado AS
		
select DataLancto, NrCheque, NrOrdem, Titulo, NomeFantasia, Historico, Credito, Debito, Ordem, DebCred from (

select 
	cp.DataPgto as DataLancto
	, cp.NrCheque
	, cp.NrOrdem
	, cp.NrTitulo as Titulo
	, f.NomeFantasia
	, cp.Observacao as Historico
	, 0 as Credito
	, cp.ValorTotalPago as Debito
	, 6 as Ordem
	, 'C' as DebCred
from ContasAPagar cp
inner join Fornecedores f on f.Id = cp.FornecedorId
where 
	cp.Conciliado = 1
  

union all

select
	lt.DataLancto as DataLancto
	, null as NrCheque
	, lt.NrLancto as NrOrdem
	, null as Titulo
	, fil.FilialNome as NomeFantasia
	, lt.Historico
	, case when lt.DebitoCredito = 'C' then lt.Valor else 0 end as Credito
	, case when lt.DebitoCredito = 'D' then lt.Valor else 0 end as Debito
	, 3 as Ordem
	, 'C' as DebCred
from LancamentosTransferencias lt
  inner join SitraWebNew.dbo.Filiais fil on fil.FilialId = lt.FilialId
where 
	  lt.BancoCredTransId is null
  and lt.BancoDebTransId is null
  and lt.DebitoCredito = 'C'

union all

select
	lt.DataLancto as DataLancto
	, null as NrCheque
	, lt.NrLancto as NrOrdem
	, null as Titulo
	, fil.FilialNome as NomeFantasia
	, lt.Historico
	, case when lt.DebitoCredito = 'C' then lt.Valor else 0 end as Credito
	, case when lt.DebitoCredito = 'D' then lt.Valor else 0 end as Debito
	, 3 as Ordem
	, 'D' as DebCred
from LancamentosTransferencias lt
  inner join SitraWebNew.dbo.Filiais fil on fil.FilialId = lt.FilialId
where 
  
   lt.BancoCredTransId is null
  and lt.BancoDebTransId is null
  and lt.DebitoCredito = 'D'

union all

select
	lt.DataLancto as DataLancto
	, null as NrCheque
	, lt.NrLancto as NrOrdem
	, null as Titulo
	, fil.FilialNome as NomeFantasia
	, lt.Historico
	, lt.Valor as Credito
	, 0 as Debito
	, 4 as Ordem
	, 'C' as DebCred
from LancamentosTransferencias lt
  inner join SitraWebNew.dbo.Filiais fil on fil.FilialId = lt.FilialId
where 
  
   lt.ContaBancoLancId is null
  
union all

select
	lt.DataLancto as DataLancto
	, null as NrCheque
	, lt.NrLancto as NrOrdem
	, null as Titulo
	, fil.FilialNome as NomeFantasia
	, lt.Historico
	, 0 as Credito
	, lt.Valor as Debito
	, 5 as Ordem
	, 'D' as DebCred
from LancamentosTransferencias lt
  inner join SitraWebNew.dbo.Filiais fil on fil.FilialId = lt.FilialId
where 
  
  lt.ContaBancoLancId is null
  

union all

select DataLancto, NrCheque, NrOrdem, Titulo, NomeFantasia, Historico ,sum(Credito),debito, Ordem, 'C' as DebCred from (
	select distinct
		rp.DataChequeDeposito as DataLancto
		, null as NrCheque
		, null as NrOrdem
		, null as Titulo
		, 'Clientes Diversos' as NomeFantasia
		, 'Titulos Liquidados' as Historico
		, rp.ValorBaixa as Credito
		, 0 as debito
		, 0 as Ordem
		, r.RebId
	from Recebimento r
	inner join RecebimentoPagamentos rp on rp.RebId = r.RebId and rp.TipoPagamentoId = 1
	where 
	  
	   r.StatusRecebimentoId = 2
	  
	) Reb
group by DataLancto, NrCheque, NrOrdem, Titulo, NomeFantasia, Historico,debito,ordem

union all

select distinct
	rp.DataChequeDeposito as DataLancto
	, null as NrCheque
	, null as NrOrdem
	, null as Titulo
	, cli.NomeFantasia as NomeFantasia
	, Cast('Deposito Nº: ' + Coalesce(rp.NumeroCheque,'0') + ' Ref. Fat. N°' + Cast(r.NumeroFatura as varchar(20)) + '/' + Cast(r.AnoFatura as varchar(4)) as varchar(100)) as Historico
	, rp.ValorBaixa as Credito
	, 0 as debito
	, 2 as Ordem	
	, 'C' as DebCred
from Recebimento r
inner join RecebimentoPagamentos rp on rp.RebId = r.RebId and rp.TipoPagamentoId != 1
inner join Clientes cli on cli.ClienteId = r.ClientePagadorId
where 
  
   r.StatusRecebimentoId in (2,4)
  

union all

select distinct
	fv.DataPagamento as DataLancto
	, null as NrCheque
	, null as NrOrdem
	, null as Titulo
	, cli.NomeFantasia as NomeFantasia
	, Cast('Recebimento de CT-e/MD-e Fil ' + UPPER(fil.Sigla) + ' Nr. ' + Cast(fv.NumeroDocumento as varchar(20)) + '.' as varchar(200)) as Historico
	, fv.ValorPago as Credito
	, 0 as debito
	, 1 as Ordem
	, 'C' as DebCred
from FreteAVista fv 
inner join Clientes cli on cli.ClienteId = fv.TomadorId
inner join SitraWebNew.dbo.Filiais fil on fil.FilialId = fv.FilialOrigemId
where 
  
   fv.StatusFaturamentoId = 3
  

) Main
GO
CREATE OR ALTER  VIEW VW_SelectExtratoNaoConciliado AS 
		
select DataLancto, NrCheque, NrOrdem, Titulo, NomeFantasia, Historico, Credito, Debito, Ordem from (

select 
	cp.DataBaixa as DataLancto
	, cp.NrCheque
	, cp.NrOrdem
	, cp.NrTitulo as Titulo
	, f.NomeFantasia
	, cp.Observacao as Historico
	, 0 as Credito
	, cp.ValorTotalPago as Debito
	, 5 as Ordem
from ContasAPagar cp
inner join Fornecedores f on f.Id = cp.FornecedorId
where (cp.Conciliado = 0 or cp.Conciliado is null)

) Main
GO
CREATE OR ALTER  VIEW VW_SelectFreteAVistaCompleto AS 

Select 
	F.Id
	,F.DocumentoId
	,F.TipoDocumentoId
	,TD.Identificador As TipoDocumentoIdentificador
	,TD.Sigla as TipoDocumentoSigla
	,F.FilialOrigemId
	,Fo.Sigla As FilialOrigemSigla
	,Fo.FilialNome As FilialOrigemNome
	,F.FilialDestinoId
	,FD.Sigla As FilialDestinoSigla
	,FD.FilialNome As FilialDestinoNome
	,F.FilialBaixaId
	,FB.Sigla As FilialBaixaSigla
	,FB.FilialNome As FilialBaixaNome
	,F.TipoFreteId
	,TF.TipoFreteDesc
	,F.DataEmissao
	,F.NumeroDocumento
	,F.Serie
	,F.ChaveDocumento
	,F.TotalFrete
	,F.LocalColetaUf
	,F.LocalEntregaUf
	,F.LocalColetaCidade
	,F.LocalEntregaCidade
	,F.TomadorId
	,T.CpfCnpj As TomadorCpfCnpj
	,T.NomeFantasia As TomadorNome
	,F.RemetenteId
	,R.CpfCnpj As RemetenteCpfCnpj
	,R.NomeFantasia As RemetenteNome
	,F.DestinatarioId
	,D.CpfCnpj As DestinatarioCpfCnpj
	,D.NomeFantasia As DestinatarioNome
	,F.FilialCargaId
	,FC.Sigla As FilialCargaSigla
	,FC.FilialNome As FilialCargaNome
	,F.DataCarga
	,F.UsuarioIdCarga
	,UC.UsuarioNome As UsuarioCargaNome
	,F.NumeroRecibo
	,F.StatusFaturamentoId
	,S.Sigla As StatusFaturamentoSigla
	,S.Descricao As StatusFaturamentoDesc
	,F.DataPagamento
	,F.TipoPagamentoId
	,TP.Sigla As TipoPagamentoSigla
	,TP.Descricao As TipoPagamentoDesc
	,F.NumeroChequeDep
	,F.BomPara
	,F.BancoCreditoId
	,BCR.Codigo As BancoCreditoCod
	,BCR.NomeBanco As BancoCreditoNome
	,F.BancoChequeId
	,BCH.BancoId As BancoChequeCod
	,BCH.BancoDesc As BancoChequeNome
	,F.Desconto
	,F.ValorPago
	,F.DataBaixa
	,F.FilialBaixa
	,FR.Sigla FilialRecebimentoSigla
	,FR.FilialNome FilialRecebimentoNome
	,F.UsuarioIdBaixa
	,UB.UsuarioNome As UsuarioBaixaNome
From FreteAVista F
Left Join Clientes T on T.ClienteId = F.TomadorId
Left Join Clientes R on R.ClienteId = F.RemetenteId
Left Join Clientes D on D.ClienteId = F.DestinatarioId
Left Join ContaBancaria BCR on BCR.Id = F.BancoCreditoId
Left Join SitraWebNew.dbo.Bancos BCH on BCH.BancoId = F.BancoChequeId
Left Join SitraWebNew.dbo.Filiais FO on FO.FilialId = F.FilialOrigemId
Left Join SitraWebNew.dbo.Filiais FD on FD.FilialId = F.FilialDestinoId
Left Join SitraWebNew.dbo.Filiais FB on FB.FilialId = F.FilialBaixaId
Left Join SitraWebNew.dbo.Filiais FC on FC.FilialId = F.FilialCargaId
Left Join SitraWebNew.dbo.Filiais FR on FR.FilialId = F.FilialBaixa
Left Join SitraWebNew.dbo.TipoFrete TF on TF.TipoFreteId = F.TipoFreteId
Left Join SitraWebNew.dbo.TipoDocumento TD on TD.TipoDocumentoId = F.TipoDocumentoId
Left Join SitraWebNew.dbo.Usuarios UC on UC.UsuarioId = F.UsuarioIdCarga
Left Join SitraWebNew.dbo.Usuarios UB on UB.UsuarioId = F.UsuarioIdBaixa
Left Join SitraWebNew.dbo.StatusFaturamento S on S.Id = F.StatusFaturamentoId
Left Join SitraWebNew.dbo.TipoPagamentoId TP on TP.Id = F.TipoPagamentoId
GO
CREATE OR ALTER  VIEW VW_SelectFreteCcCompleto AS 

select  
	F.FatId as Id
	,F.DocumentoId
	,F.TipoDocumentoId
	,TD.Identificador As TipoDocumentoIdentificador
	,TD.Sigla as TipoDocumentoSigla
	,F.FilialDocumentoId as FilialOrigemId
	,Fo.Sigla As FilialOrigemSigla
	,Fo.FilialNome As FilialOrigemNome
	,d.FilialDestinoId
	,FD.Sigla As FilialDestinoSigla
	,FD.FilialNome As FilialDestinoNome
	,d.FilialBaixaId
	,FB.Sigla As FilialBaixaSigla
	,FB.FilialNome As FilialBaixaNome
	,F.TipoFreteId
	,TF.TipoFreteDesc
	,d.DataEmissao
	,d.NumeroDoc as NumeroDocumento
	,d.Serie
	,d.ChaveAcesso as ChaveDocumento
	,f.ValorTotalDocumento TotalFrete
	,d.LocalColetaUf
	,d.LocalEntregaUf
	,d.LocalColetaCidade
	,d.LocalEntregaCidade
	,d.TomadorId
	,T.CpfCnpj As TomadorCpfCnpj
	,T.NomeFantasia As TomadorNome
	,d.RemetenteId
	,R.CpfCnpj As RemetenteCpfCnpj
	,R.NomeFantasia As RemetenteNome
	,d.DestinatarioId
	,De.CpfCnpj As DestinatarioCpfCnpj
	,De.NomeFantasia As DestinatarioNome
	,F.FilialCadastro FilialCargaId
	,FC.Sigla As FilialCargaSigla
	,FC.FilialNome As FilialCargaNome
	,F.DataCadastro as DataCarga
	,F.UsuarioIdCadastro as UsuarioIdCarga
	,UC.UsuarioNome As UsuarioCargaNome
	,F.NumeroFatura as NumeroRecibo
	,F.StatusFaturamentoId
	,S.Sigla As StatusFaturamentoSigla
	,S.Descricao As StatusFaturamentoDesc
	,reb.DataPagamento
	,1 TipoPagamentoId
	,'BC' As TipoPagamentoSigla
	,'BC BANCO' As TipoPagamentoDesc
	,null NumeroChequeDep
	,null BomPara
	,reb.BancoId BancoCreditoId
	,BCR.Codigo As BancoCreditoCod
	,BCR.NomeBanco As BancoCreditoNome
	,null BancoChequeId
	,null  As BancoChequeCod
	,null  As BancoChequeNome
	,reb.Desconto
	,reb.ValorRecebido ValorPago
	,F.DataBaixa
	,f.FilialCadastro FilialBaixa
	,FR.Sigla FilialRecebimentoSigla
	,FR.FilialNome FilialRecebimentoNome
	,F.UsuarioIdCadastro as UsuarioIdBaixa
	,UB.UsuarioNome As UsuarioBaixaNome
from Faturas f 
inner join Documentos d on d.DocId = f.DocumentoId and d.FilialId = f.FilialDocumentoId and d.TipoDocumentoId = f.TipoDocumentoId
left join Recebimento reb on reb.NumeroFatura = f.NumeroFatura and reb.FilialEmissaoFatura = f.FilialEmissaoFaturaId and reb.AnoFatura = f.AnoFatura
Left Join Clientes T on T.ClienteId = d.TomadorId
Left Join Clientes R on R.ClienteId = d.RemetenteId
Left Join Clientes De on De.ClienteId = d.DestinatarioId
Left Join ContaBancaria BCR on BCR.Id = reb.BancoId
Left Join SitraWebNew.dbo.Filiais FO on FO.FilialId = d.FilialId
Left Join SitraWebNew.dbo.Filiais FD on FD.FilialId = d.FilialDestinoId
Left Join SitraWebNew.dbo.Filiais FB on FB.FilialId = d.FilialBaixaId
Left Join SitraWebNew.dbo.Filiais FC on FC.FilialId = f.FilialCadastro
Left Join SitraWebNew.dbo.Filiais FR on FR.FilialId = reb.FilialCadastro
Left Join SitraWebNew.dbo.TipoFrete TF on TF.TipoFreteId = F.TipoFreteId
Left Join SitraWebNew.dbo.TipoDocumento TD on TD.TipoDocumentoId = F.TipoDocumentoId
Left Join SitraWebNew.dbo.Usuarios UC on UC.UsuarioId = F.UsuarioIdCadastro
Left Join SitraWebNew.dbo.Usuarios UB on UB.UsuarioId = F.UsuarioIdCadastro
Left Join SitraWebNew.dbo.StatusFaturamento S on S.Id = F.StatusFaturamentoId
GO
CREATE OR ALTER  VIEW VW_SelectContasAPagar AS
			 
SELECT
cp.Id
,cp.NrOrdem

--Filial
,cp.FilialId as FilId
,fil.Sigla as FilSigla
,fil.FilialNome as FilNome

--Fornecedor
,cp.FornecedorId
,forn.CpfCnpj
,forn.NomeFantasia

,cp.NumeroContrato
,cp.ValorContrato
,cp.NrTitulo
,cp.Nfe
,cp.NossoNumeroBoleto
,cp.Observacao

--Filial Pagamento
,cp.FilialPagamentoId as FilPagId
,filPag.Sigla as FilPagSigla
,filpag.FilialNome as FilPagNome

--Centro de Custo
,cp.CentroCustoId as CCId
,cc.Codigo as CCCodigo
,cc.Descricao as CCDesc

--Subcusto
,cp.SubCustoId as SCId
,sc.Codigo as SCCodigo
,sc.Descricao as SCDesc

--Tipo documento
,tdf.Id as TDFId
,tdf.Codigo as TDFCodigo
,tdf.Descricao as TDFDesc

--Portador
,cp.PortadorId as PortId
,portf.Codigo as PortCodigo
,portf.Descricao as PortDesc

,cp.DataLancamento
,cp.DataEmissao
,cp.DataVencimento
,cp.DataPrevPagto
,cp.ValorOriginal
,cp.NrParcela

--Usuário Cadastro
,cp.UsuarioIdCadastro as uCId
,uC.UsuarioNome as uCNome

--Filial Cadastro
,cp.FilialIdCadastro as fCId
,fC.Sigla as fCSigla
,fC.FilialNome as fCNome

,cp.DataCadastro

--Usuário Alteracao
,cp.UsuarioIdAlteracao as uAId
,uA.UsuarioNome as uANome

--Filial Alteracao
,cp.FilialIdAlteracao as fAId
,fA.Sigla as fASigla
,fA.FilialNome as fANome

,cp.DataAlteracao
,cp.Conciliado
,cp.DataConciliacao
,cp.UsuarioConciliacao
,cp.FilialConciliacao
,cp.BancoPagId
,cp.ValorTotalPago
,cp.StatusContasAPagarId
,cp.TotalJuros
,cbp.Codigo PagCodigo
,cbp.NomeBanco PagNomeBanco
,cbp.Agencia PagAgencia
,cbp.ContaBancaria PagContaBancaria 
,cp.DataBaixa
,cp.DataPgto
,cp.NrCheque
,cp.DataCancelamento 
,cp.UsuarioCancelamento 
,cp.FilialCancelamento 
,cp.MotivoCancelamento 

FROM ContasAPagar cp 
INNER JOIN SitraWebNew.dbo.Filiais fil on fil.FilialId = cp.FilialId
INNER JOIN SitraWebNew.dbo.Filiais filPag on filPag.FilialId = cp.FilialPagamentoId
INNER JOIN Fornecedores forn on forn.Id = cp.FornecedorId
INNER JOIN CentrosCustos cc on cc.Id = cp.CentroCustoId
INNER JOIN Subcustos sc on sc.Id = cp.SubCustoId
INNER JOIN TipoDocumentoFinanceiro tdf on tdf.Id = cp.TipoDocId
LEFT JOIN PortadoresFinanceiro portf on portf.Id = cp.PortadorId
INNER JOIN SitraWebNew.dbo.Usuarios uC on uC.UsuarioId = cp.UsuarioIdCadastro
LEFT JOIN SitraWebNew.dbo.Usuarios uA on uA.UsuarioId = cp.UsuarioIdAlteracao
INNER JOIN SitraWebNew.dbo.Filiais fC on fC.FilialId = cp.FilialIdCadastro
LEFT JOIN SitraWebNew.dbo.Filiais fA on fA.FilialId = cp.FilialIdAlteracao
left join ContaBancaria cbp on cbp.Id = cp.BancoPagId
GO