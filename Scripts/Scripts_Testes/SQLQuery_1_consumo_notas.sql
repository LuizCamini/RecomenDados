use [master]
go

CREATE OR ALTER procedure Consulta_Consumo_Notas 
(@DataIni varchar(19),@DataFim varchar(19)) 

AS
BEGIN
 SET NOCOUNT ON;

If Object_Id('#Consumo_Notas') IS NOT NULL
 Begin
  Truncate Table #Consumo_Notas
 End
 Else
 Begin
  Create Table #Consumo_Notas
   (Codigo TinyInt Identity(1,1)
   ,DatabaseName Varchar(100)
   ,Arquivei Int
   ,Sieg Int
   ,QTD_Imp_Arquivei Int
   ,QTD_Imp_Sieg Int
   ,QTD_Imp_Portal Int
    )
 End
 exec Consulta_Consumo_Notas '2020-02-01 00:00:00','2020-12-31 23:59:59'
If OBJECT_ID('#DatasTemp') IS NOT NULL
 BEGIN
  TRUNCATE TABLE #DatasTemp
 END
 ELSE
 BEGIN
 CREATE TABLE #DatasTemp
 (DataIni varchar(19),DataFim varchar(19))
 END

INSERT INTO #DatasTemp (DataIni,DataFim)
select @DataIni,@DataFim;


DECLARE @DatabaseName varchar(100), @cmd varchar(8000)

DECLARE Cursor_Consumo_Notas CURSOR FOR
SELECT CAST(name AS VARCHAR(100)) AS name FROM MASTER..SYSDATABASES
WHERE  name  = '2096'
and    status <> 66048
Order By Name

OPEN Cursor_Consumo_Notas
FETCH NEXT FROM Cursor_Consumo_Notas
INTO @DatabaseName
 
WHILE @@FETCH_STATUS = 0
BEGIN
   
    SELECT @cmd =  'SET NOCOUNT ON ' + char(10) +
'USE ' +'['+ @DatabaseName + '] ' + char(10) +
'DECLARE 
@DataIni2 varchar(19)
,@DataFim2 varchar(19)
,@Arquivei Int
,@Sieg Int
,@QTD_Imp_Arquivei int
,@QTD_Imp_Sieg int
,@QTD_Imp_Portal int ' + char(10) +
'Set @DataIni2 = (SELECT DataIni from #DatasTemp); 
Set @DataFim2 = (SELECT DataFim from #DatasTemp); 
Set @Arquivei=(select count(*) from ParametrosArquivei); 
Set @Sieg = (select count(*) from ParametrosSieg); 
Set @QTD_Imp_Arquivei = (select sum(CONVERT(INT,Arquivei)) from ImportacaoNfe where DataEmissao between @DataIni2 and @DataFim2 AND Arquivei IS NOT NULL); 
Set @QTD_Imp_Sieg = (select sum(CONVERT(INT,Sieg)) from ImportacaoNfe where DataEmissao between @DataIni2 and @DataFim2 AND Sieg IS NOT NULL); 
Set @QTD_Imp_Portal = (select sum(CONVERT(INT,Portal)) from ImportacaoNfe where DataEmissao between @DataIni2 and @DataFim2 AND Portal IS NOT NULL); ' + char(10) +
+'Insert Into #Consumo_Notas(DatabaseName' + ',' + ' Arquivei' + ',' + ' Sieg' + ',' + ' QTD_Imp_Arquivei' + ',' + ' QTD_Imp_Sieg' + ',' + ' QTD_Imp_Portal ' +  ')
 Values('+''''+ @DatabaseName + '''' + ',' + ' @Arquivei'+ ',' + ' @Sieg' + ',' + ' @QTD_Imp_Arquivei' + ',' + ' @QTD_Imp_Sieg' + ',' + ' @QTD_Imp_Portal' +  '); ' 
 
 Exec(@cmd)
 
 FETCH NEXT FROM Cursor_Consumo_Notas
 INTO @DatabaseName
END
 

--SELECT PARA GERAR RELATORIO COM AS QUANTIDADES
SELECT * FROM #DatasTemp

Select Upper(DatabaseName) 'Database'
       ,CASE WHEN Arquivei = 1 THEN 'Habilitado' ELSE 'NÃO HABILITADO' END As Arquivei_Parametro
       ,CASE WHEN Sieg = 1 THEN 'Habilitado' ELSE 'NÃO HABILITADO' END AS Sieg_Parametro
       ,QTD_Imp_Arquivei
       ,QTD_Imp_Sieg
       ,QTD_Imp_Portal
from #Consumo_Notas
ORDER BY DatabaseName

SELECT @cmd

DROP TABLE #Consumo_Notas
DROP TABLE #DatasTemp
CLOSE Cursor_Consumo_Notas
DEALLOCATE Cursor_Consumo_Notas

END


--select * from #consumo_notas
--exec Consulta_Consumo_Notas '2020-02-01 00:00:00','2020-12-31 23:59:59'
--GO
--use [2096]
--go
--select sum(CONVERT(INT,Portal)) from ImportacaoNfe where Portal is not NULL and DataEmissao between '2001-01-01 00:00:00' and '2020-12-31 23:59:59'
--select sum(CONVERT(INT,sieg)) from ImportacaoNfe where sieg is not NULL and DataEmissao between '2001-01-01 00:00:00' and '2020-12-31 23:59:59'
--select sum(CONVERT(INT,Arquivei)) from ImportacaoNfe where Arquivei is not NULL and DataEmissao between '2001-01-01 00:00:00' and '2020-12-31 23:59:59'
--create table teste(cmd varchar(max))
--truncate table teste

