USE [master]
RESTORE DATABASE [1836] FROM  DISK = N'/home/luizcamini/Documentos/backup_restore/1836_2020020316.bak' WITH  FILE = 1,  MOVE N'1836' TO N'/var/opt/mssql/data/1836.mdf',  MOVE N'1836_log' TO N'/var/opt/mssql/data/1836.ldf',  NOUNLOAD,  STATS = 5;
RESTORE DATABASE [1883]  FROM  DISK = N'/home/luizcamini/Documentos/backup_restore/1883_2019100115.bak' WITH  FILE = 1, MOVE N'1883' TO N'/var/opt/mssql/data/1883.mdf',  MOVE N'1883_log' TO N'/var/opt/mssql/data/1883.ldf',  NOUNLOAD,  STATS = 5; 
RESTORE DATABASE [2000]  FROM  DISK = N'/home/luizcamini/Documentos/backup_restore/2000_2019090612.bak' WITH  FILE = 1, MOVE N'2000' TO N'/var/opt/mssql/data/2000.mdf',  MOVE N'2000_log' TO N'/var/opt/mssql/data/2000.ldf',  NOUNLOAD,  STATS = 5;   
RESTORE DATABASE [2049]  FROM  DISK = N'/home/luizcamini/Documentos/backup_restore/2049_2019080714.bak' WITH  FILE = 1, MOVE N'2049' TO N'/var/opt/mssql/data/2049.mdf',  MOVE N'2049_log' TO N'/var/opt/mssql/data/2049.ldf',  NOUNLOAD,  STATS = 5;   
RESTORE DATABASE [2096]  FROM  DISK = N'/home/luizcamini/Documentos/backup_restore/2096_2020010210.bak' WITH  FILE = 1, MOVE N'2096' TO N'/var/opt/mssql/data/2096.mdf',  MOVE N'2096_log' TO N'/var/opt/mssql/data/2096.ldf',  NOUNLOAD,  STATS = 5;   
RESTORE DATABASE [2184]  FROM  DISK = N'/home/luizcamini/Documentos/backup_restore/2184_2019091610.bak' WITH  FILE = 1, MOVE N'2184' TO N'/var/opt/mssql/data/2184.mdf',  MOVE N'2184_log' TO N'/var/opt/mssql/data/2184.ldf',  NOUNLOAD,  STATS = 5;   
RESTORE DATABASE [2200]  FROM  DISK = N'/home/luizcamini/Documentos/backup_restore/2200_2019101723.bak' WITH  FILE = 1, MOVE N'2200' TO N'/var/opt/mssql/data/2200.mdf',  MOVE N'2200_log' TO N'/var/opt/mssql/data/2200.ldf',  NOUNLOAD,  STATS = 5;   
RESTORE DATABASE [2212]  FROM  DISK = N'/home/luizcamini/Documentos/backup_restore/2212_2019120609.bak' WITH  FILE = 1, MOVE N'2212' TO N'/var/opt/mssql/data/2212.mdf',  MOVE N'2212_log' TO N'/var/opt/mssql/data/2212.ldf',  NOUNLOAD,  STATS = 5;   
RESTORE DATABASE [2216]  FROM  DISK = N'/home/luizcamini/Documentos/backup_restore/2216_2020011312.bak' WITH  FILE = 1, MOVE N'2216' TO N'/var/opt/mssql/data/2216.mdf',  MOVE N'2216_log' TO N'/var/opt/mssql/data/2216.ldf',  NOUNLOAD,  STATS = 5;   
RESTORE DATABASE [39]  FROM  DISK = N'/home/luizcamini/Documentos/backup_restore/39_2019091310.bak' WITH  FILE = 1, MOVE N'39' TO N'/var/opt/mssql/data/39.mdf',  MOVE N'39_log' TO N'/var/opt/mssql/data/39.ldf',  NOUNLOAD,  STATS = 5; 
RESTORE DATABASE [471]  FROM  DISK = N'/home/luizcamini/Documentos/backup_restore/471_2019071211.bak' WITH  FILE = 1, MOVE N'471' TO N'/var/opt/mssql/data/471.mdf',  MOVE N'471_log' TO N'/var/opt/mssql/data/471.ldf',  NOUNLOAD,  STATS = 5;  
RESTORE DATABASE [516]  FROM  DISK = N'/home/luizcamini/Documentos/backup_restore/516_2019101723.bak' WITH  FILE = 1, MOVE N'516' TO N'/var/opt/mssql/data/516.mdf',  MOVE N'516_log' TO N'/var/opt/mssql/data/516.ldf',  NOUNLOAD,  STATS = 5; 
RESTORE DATABASE [671]  FROM  DISK = N'/home/luizcamini/Documentos/backup_restore/671_2019092516.bak' WITH  FILE = 1, MOVE N'671' TO N'/var/opt/mssql/data/671.mdf',  MOVE N'671_log' TO N'/var/opt/mssql/data/671.ldf',  NOUNLOAD,  STATS = 5; 
RESTORE DATABASE [757]  FROM  DISK = N'/home/luizcamini/Documentos/backup_restore/757_2020030615.bak' WITH  FILE = 1, MOVE N'757' TO N'/var/opt/mssql/data/757.mdf',  MOVE N'757_log' TO N'/var/opt/mssql/data/757.ldf',  NOUNLOAD,  STATS = 5; 
RESTORE DATABASE [799]  FROM  DISK = N'/home/luizcamini/Documentos/backup_restore/799_2019071211.bak' WITH  FILE = 1, MOVE N'799' TO N'/var/opt/mssql/data/799.mdf',  MOVE N'799_log' TO N'/var/opt/mssql/data/799.ldf',  NOUNLOAD,  STATS = 5; 
RESTORE DATABASE [SitraWebnew]  FROM  DISK = N'/home/luizcamini/Documentos/backup_restore/SitraWebnew_2020022816.bak' WITH  FILE = 1,  MOVE N'SitraWeb' TO N'/var/opt/mssql/data/SitraWeb_Dev.mdf',  MOVE N'SitraWeb_log' TO N'/var/opt/mssql/data/SitraWeb_Dev_1.ldf',  NOUNLOAD,  STATS = 5;


RESTORE DATABASE AdventureWorks2017 FROM  DISK = N'/home/luizcamini/Documentos/backup_restore/AdventureWorks2017.bak' WITH  FILE = 1,  
MOVE N'AdventureWorks2017' TO N'/var/opt/mssql/data/AdventureWorks2017.mdf',  
MOVE N'AdventureWorks2017_log' TO N'/var/opt/mssql/data/AdventureWorks2017.ldf',  
NOUNLOAD,  STATS = 5;
go
RESTORE DATABASE AdventureWorksDW2017 FROM  DISK = N'/home/luizcamini/Documentos/backup_restore/AdventureWorksDW2017.bak' WITH  FILE = 1,  
MOVE N'AdventureWorksDW2017' TO N'/var/opt/mssql/data/AdventureWorksDW2017.mdf',  
MOVE N'AdventureWorksDW2017_log' TO N'/var/opt/mssql/data/AdventureWorksDW2017.ldf',  
NOUNLOAD,  STATS = 5;
go


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

#172157#22Dez07#


--PRINCIPAL
xfreerdp /w:1336 /h:900 /u:administrator /v:ec2-44-195-248-17.compute-1.amazonaws.com /p:"nX9V?Xshfq9za?Bw6aJ@M)CXEHQHJniI" /port:3389 
--SECUNDARIA
xfreerdp /w:1336 /h:900 /u:administrator /v:ec2-54-174-92-85.compute-1.amazonaws.com /p:"nX9V?Xshfq9za?Bw6aJ@M)CXEHQHJniI" /port:3389 


#22Dez07#172157#
#22Dez07#
172157

SERVER: ec2-44-195-248-17.compute-1.amazonaws.com
USR: recomendados
PSW: !Recomen20Dados21@

EC2AMAZ-VAO1JAR\RECOMENDADOS

!Recomen20Dados21@

xfreerdp /w:1336 /h:900 /u:"recife\control" /v:goglobal.disnova.com.br /p:"Senh@.21" /port:5000



