use [2096]
go
drop table #DatasTemp
GO
create table #DatasTemp(DataIni varchar(19),DataFim varchar(19))
DECLARE @DatabaseName varchar(100)
       ,@DataIni varchar(19) = '2001-01-01 00:00:00'
       ,@DataFim varchar(19) = '2020-12-31 23:59:59'
       ,@DataIni2 varchar(19)
       ,@DataFim2 varchar(19)
       

insert into #DatasTemp (DataIni,DataFim)
select @DataIni,@DataFim

set @DataIni2 = (select dataini from #DatasTemp)
set @DataFim2 = (select dataFim from #DatasTemp)
select sum(cast(Portal as int)) from ImportacaoNfe where Portal is not NULL and DataEmissao between @DataIni2 and @DataFim2



--select cast(format(@DataIni2,'yyyy-MM-dd hh:mm:ss')as datetime) ,cast(format(@DataFim2,'yyyy-MM-dd hh:mm:ss')as datetime)
--select cast(format(DataIni,'yyyy-MM-dd hh:mm:ss') as varchar(19)),format(DataFim,'yyyy-MM-dd hh:mm:ss') from #DatasTemp

go
declare @cmd varchar(1000), @DatabaseName VARCHAR(10)
set @DatabaseName = '2096'
set @cmd = (
'SET NOCOUNT ON ' + char(10) +
'USE ' +'['+ @DatabaseName + '] ' + char(10) +
'DECLARE 
@DataIni2 nvarchar(19)
,@DataFim2 nvarchar(19)
,@Arquivei Int
,@Sieg Int
,@QTD_Imp_Sieg int
,@QTD_Imp_Arquivei int
,@QTD_Imp_Portal int '+ char(10) +
'Set @DataIni2 = (SELECT DataIni from #DatasTemp); 
Set @DataFim2 = (SELECT DataFim from #DatasTemp); 
Set @Arquivei=(select count(*) from ParametrosArquivei);
Set @Sieg = (select count(*) from ParametrosSieg);
Set @QTD_Imp_Sieg = (select sum(cast(Sieg as int)) from ImportacaoNfe where Sieg is not NULL and DataEmissao between ' + ''''+ '@DataIni2'+''''  + ' and '  + ''''+'@DataFim2'+''''  + ');'
+' Set @QTD_Imp_Arquivei = (select sum(cast(Arquivei as int)) from ImportacaoNfe where Arquivei is not NULL and DataEmissao between ' + ''''+ '@DataIni2'+''''  + ' and ' + ''''+ '@DataFim2' + ''''+');'
+' Set @QTD_Imp_Portal = (select sum(cast(Portal as int)) from ImportacaoNfe where Portal is not NULL and DataEmissao between ' +  ''''+'@DataIni2'+''''  + ' and ' +  ''''+'@DataFim2'+'''' + ');'
+' Insert Into #Consumo_Notas(DatabaseName' + ',' + ' Arquivei' + ',' + ' Sieg' + ',' + ' QTD_Imp_Arquivei' + ',' + ' QTD_Imp_Sieg' + ',' + ' QTD_Imp_Portal)
 Values('+''''+ @DatabaseName + '''' + ',' + ' @Arquivei'+ ',' + ' @Sieg' + ',' + ' @QTD_Imp_Arquivei' + ',' + ' @QTD_Imp_Sieg' + ',' + ' @QTD_Imp_Portal)'

)

select @cmd

select pi()


DECLARE @myval DECIMAL (5, 2);  
SET @myval = 193.57;  
SELECT CAST(CAST(@myval AS VARBINARY(20)) AS DECIMAL(10,5));  
-- Or, using CONVERT  
SELECT CONVERT(DECIMAL(10,5), CONVERT(VARBINARY(20), @myval)); 

GO
select convert(smalldatetime,getdate())
select convert(time,getdate())
select convert(timestamp,'2022-05-27 22:50:51')
select cast('2022-05-27 22:50:51' as timestamp)
