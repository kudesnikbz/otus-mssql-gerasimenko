use GDS_old

SELECT [id]
      ,[CreationDateTime]
      ,[ProcessDateTime]
      ,[TransactionStatus]
      ,[ParentTransaction_id]
      ,[TransactionType_id]
  FROM [dbo].[Transactions]

;with nums as 
(
select 0 n union all select 1 union all select 2 union all select 3 union all select 4 
union all select 5 union all select 6 union all select 7 union all select 8 union all select 9 
)

insert into Transactions(CreationDateTime, [ProcessDateTime], TransactionStatus, TransactionType_id)
select dateadd(hh, rn-1, '20220101') dt, DATEADD(hh, rn+1, '20220101') pdt, 1, 0
from
(
select row_number() over(order by (select (null))) rn
from nums n1, nums n2, nums n3, nums n4
)t
where rn < 8761

----drop index cix_Transaction_id on [Transactions]
----drop index cix_stageTransaction_id on [stageTransactions]

----drop partition scheme psTransactions
----drop partition function pfTransactions

SELECT
    sc.name + N'.' + so.name as [Schema.Table],
    si.index_id as [Index ID],
    si.type_desc as [Structure],
    si.name as [Index],
    stat.row_count AS [Rows],
    stat.in_row_reserved_page_count * 8./1024./1024. as [In-Row GB],
    stat.lob_reserved_page_count * 8./1024./1024. as [LOB GB],
    p.partition_number AS [Partition #],
    pf.name as [Partition Function],
    CASE pf.boundary_value_on_right
        WHEN 1 then 'Right / Lower'
        ELSE 'Left / Upper'
    END as [Boundary Type],
    prv.value as [Boundary Point],
    fg.name as [Filegroup]
FROM sys.partition_functions AS pf
JOIN sys.partition_schemes as ps on ps.function_id=pf.function_id
JOIN sys.indexes as si on si.data_space_id=ps.data_space_id
JOIN sys.objects as so on si.object_id = so.object_id
JOIN sys.schemas as sc on so.schema_id = sc.schema_id
JOIN sys.partitions as p on 
    si.object_id=p.object_id 
    and si.index_id=p.index_id
LEFT JOIN sys.partition_range_values as prv on prv.function_id=pf.function_id
    and p.partition_number= 
        CASE pf.boundary_value_on_right WHEN 1
            THEN prv.boundary_id + 1
        ELSE prv.boundary_id
        END
        /* For left-based functions, partition_number = boundary_id, 
           for right-based functions we need to add 1 */
JOIN sys.dm_db_partition_stats as stat on stat.object_id=p.object_id
    and stat.index_id=p.index_id
    and stat.index_id=p.index_id and stat.partition_id=p.partition_id
    and stat.partition_number=p.partition_number
JOIN sys.allocation_units as au on au.container_id = p.hobt_id
    and au.type_desc ='IN_ROW_DATA' 
        /* Avoiding double rows for columnstore indexes. */
        /* We can pick up LOB page count from partition_stats */
JOIN sys.filegroups as fg on fg.data_space_id = au.data_space_id
ORDER BY [Schema.Table], [Index ID], [Partition Function], [Partition #];

--создам группу
ALTER DATABASE GDS2 ADD FILEGROUP [fg1]
GO

--создам файл
ALTER DATABASE [GDS2]
ADD FILE ( NAME = N'FG1', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQL22OTUS\MSSQL\DATA\FG1.ndf' , SIZE = 8192KB , FILEGROWTH = 65536KB ) TO FILEGROUP [fg1]

--Создам функцию
create partition function [pfTransactions] (datetime2) as range right
for values ('20220401', '20220801', '20221201', '20230401', '20230801', '20231201')

--создам схему
create partition scheme psTransactions as partition [pfTransactions] ALL TO ([fg1])

--кластерный индекс
CREATE CLUSTERED INDEX cix_Transaction_id_CDT on [Transactions](id) on psTransactions(CreationDateTime);

-- новая секция
--alter partition scheme psTransactions
--next used [TransactionsCreationDateTime];
SET STATISTICS TIME, IO ON;
	alter partition function [pfTransactions]() split range ('20240401');
SET STATISTICS TIME, IO OFF;


---Скользящее окно
--1) новая секция:
alter partition scheme psTransactions
next used [TransactionsCreationDateTime];
SET STATISTICS TIME, IO ON;
	alter partition function [pfTransactions]() split range ('20230101');
SET STATISTICS TIME, IO OFF;

--2) stage-таблица без последовательностей и индексов, но с ПРАВИЛЬНЫМ кластерныМ индексом по ней
CREATE TABLE [dbo].[stageTransactions](
	[id] [int] NOT NULL,
	[CreationDateTime] [datetime2](7) NOT NULL,
	[ProcessDateTime] [datetime2](7) NULL,
	[TransactionStatus] [bit] NOT NULL,
	[ParentTransaction_id] [int] NULL,
	[TransactionType_id] [int] NOT NULL
)
GO
CREATE CLUSTERED INDEX cix_stageTransaction_id on stageTransactions(id, CreationDateTime) on [FG1];

--3) Переключаю секцию
SET STATISTICS TIME, IO ON;
	alter table Transactions switch partition 1 to stageTransactions
SET STATISTICS TIME, IO OFF;

select * from Transactions
select * from stageTransactions

--4) Убираю ненужную секцию
SET STATISTICS TIME, IO ON;
	alter partition function pfTransactions() merge range ('20220401');
SET STATISTICS TIME, IO OFF;