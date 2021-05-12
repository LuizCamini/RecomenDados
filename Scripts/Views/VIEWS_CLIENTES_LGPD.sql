CREATE OR ALTER VIEW [DBO].[CLIENTESLGPD] 
AS
SELECT 
CLIENTEID
,C.FILIALID
,CASE WHEN LEN(C.CPFCNPJ) = 14 THEN
	REPLACE(SUBSTRING(C.CPFCNPJ,1,3),SUBSTRING(C.CPFCNPJ,1,3),'XXX') 
	+'.'+ SUBSTRING(C.CPFCNPJ,5,3)+'.'+ SUBSTRING(C.CPFCNPJ,9,3)+'-'+REPLACE(SUBSTRING(C.CPFCNPJ,13,2),SUBSTRING(C.CPFCNPJ,13,2),'XX') 
	WHEN LEN(C.CPFCNPJ) = 18 THEN
		REPLACE(SUBSTRING(C.CPFCNPJ,1,2),SUBSTRING(C.CPFCNPJ,1,2),'XX')
	+'.'+SUBSTRING(C.CPFCNPJ,4,3)+'.'+SUBSTRING(C.CPFCNPJ,8,3)+SUBSTRING(C.CPFCNPJ,11,5)+'-'+REPLACE(SUBSTRING(C.CPFCNPJ,17,2),SUBSTRING(C.CPFCNPJ,17,2),'XX')
	END AS CPFCNPJ
,TRANSLATE(C.RAZAOSOCIAL,'AEIOU','XXXXX') AS RAZAOSOCIAL
,TRANSLATE(C.NOMEFANTASIA,'AEIOU','XXXXX') AS NOMEFANTASIA
,C.CONTATO
,REPLACE(C.CEP,'0','X') CEP
,TRANSLATE(C.ENDERECO,'AEIOU','XXXXX') AS ENDERECO
,C.NUMERO
,TRANSLATE(C.BAIRRO,'AEIOU','XXXXX') AS BAIRRO
,TRANSLATE(C.CIDADE,'AEIOU','XXXXX')AS CIDADE
,C.UF
,C.COMPLEMENTO
,REPLACE(SUBSTRING(C.TELEFONE,2,2),SUBSTRING(C.TELEFONE,2,2),'XX')+REPLACE(SUBSTRING(C.TELEFONE,5,4),SUBSTRING(C.TELEFONE,5,4),'XX')+SUBSTRING(C.TELEFONE,10,4) AS TELEFONE
,REPLACE(SUBSTRING(C.CELULAR,2,2),SUBSTRING(C.CELULAR,2,2),'XX')+REPLACE(SUBSTRING(C.CELULAR,5,4),SUBSTRING(C.CELULAR,5,4),'XX')+SUBSTRING(C.CELULAR,10,4) AS CELULAR
,C.INSCRICAOESTADUAL
,C.TIPOCLIENTE
,C.RAMOATIVIDADEID
,C.INSCRICAOESTADUALSUBSTITUICAOTRIBUTARIAUF
,C.INSCRICAOESTADUALSUBSTITUICAOTRIBUTARIA
,C.EMAILENVIODACTEXML
,C.ENVIARXMLDOCTE
,C.ENVIARDACTEDOCTEEMFORMATOPDF
,C.FREQUENCIAENVIOEMAILDACTEXML
,C.TIPOENVIOEMAILLOTEDACTEXML
,C.DATACADASTRO
,C.DATAALTERACAO
,C.USUARIOIDCADASTRO
,C.USUARIOIDALTERACAO
,C.ATIVO
,C.PAGATDE
,C.DIFICILENTREGA
,C.CANHOTO
,C.CUBAGEM
,C.AGRUPARNFE
,V.CPFCNPJ AS VENDEDORCPFCNPJ
,V.NOME AS VENDEDORNOME
,C.VENDEDORID AS VENDEDORID
FROM CLIENTES C WITH(NOLOCK)
LEFT JOIN VENDEDORES V ON V.VENDEDORID = C.VENDEDORID
GO

