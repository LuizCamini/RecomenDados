SELECT 
case when database_name = 'SitraWebNew' then 'Principal'
else database_name end 
AS [Nome do Banco de Dados], format(backup_finish_date, 'dd/MM/yyyy hh:mm') as  [Data do Backup]
FROM msdb.dbo.backupset 
WHERE database_name NOT IN 
(
    'MASTER'
    ,'TEMPDB'
    ,'model'
    ,'MSDB'
    ,'AdventureWorksDW2017'
    ,'in_memory'
    ,'AdventureWorks2017'
    ,'cripto'
    ,'CONSULTORIO'
    ,'OPE'
)
order by database_name desc
go
select top(10)
format(sum(doccomp.TotalFrete),'c','pt-br') as frete
,sum(doccomp.TotalFrete) as ft2
,doc.TomadorId
from DocumentosComposicaoFrete as doccomp
inner join Documentos as doc on doccomp.DocId = doc.DocId
group by doc.TomadorId
order by frete desc
go
use[ope]
GO
select * from INFORMATION_SCHEMA.TABLES
GO
select * from municipios
go
select * from estados

GO
USE SitraWebnew
GO 
SELECT * FROM ParametrosArquivei;
SELECT * FROM ParametrosSieg;
SELECT * FROM ImportacaoNfe;