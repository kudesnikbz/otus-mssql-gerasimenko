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

insert into Transactions(CreationDateTime, TransactionStatus, TransactionType_id)
select dateadd(hh, rn-1, '20220101') dt, 0, 0
from
(
select row_number() over(order by (select (null))) rn
from nums n1, nums n2, nums n3, nums n4
)t
where rn < 8761

----drop index cix_pTransaction_id on [Transactions]
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


--—оздам функцию
CREATE PARTITION FUNCTION [pfTransactions] (DATETIME2) AS range right
FOR VALUES ('20220401','20220801')

--создам схему
CREATE PARTITION scheme psTransactions AS PARTITION [pfTransactions] TO ([FG1],[FG2],[FG3])

--кластерный индекс
CREATE CLUSTERED INDEX cix_pTransaction_id on [Transactions](id) on psTransactions(CreationDateTime)

---—кольз€щее окно
--1) новая секция:
ALTER PARTITION scheme psTransactions NEXT used [FG1];

SET STATISTICS TIME,IO ON;
	ALTER PARTITION FUNCTION [pfTransactions] () split range ('20230101');
SET STATISTICS TIME,IO OFF;

--2) таблица архив без последовательностей и индексов, но с кластерным индексом по ней
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

--3) переключаю секцию
SET STATISTICS TIME, IO ON;
	ALTER TABLE Transactions switch PARTITION 1 TO stageTransactions
SET STATISTICS TIME, IO OFF;

SELECT *
FROM Transactions

SELECT *
FROM stageTransactions

--4) удал€ю ненужную секцию
SET STATISTICS TIME, IO ON;
	ALTER PARTITION FUNCTION pfTransactions () MERGE range('20220401');
SET STATISTICS TIME, IO OFF;