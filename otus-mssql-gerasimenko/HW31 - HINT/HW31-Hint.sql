/*
Пришел запрос от администратора системы управления складом. Запрос которым они анализировали Среднее время приемки, перестал работать. Запускает в студии, он работает более 15 минут, так как желания ждать дольше нет, отключает его.
Попробую частично его переписать и понять хотябы что он получает.

declare 
@StartD DATETIME,
@EndD DATETIME
SET 
@StartD = dateadd(week,-20,(dateadd(day, datediff(day,0, getdate())/7*7,0)))
SET
@EndD =getdate()

select
bbb.ww as 'Неделя',
bbb.yy as 'Год',
bbb.mm as 'Месяц',
sum(bbb.ras)/sum(bbb.kolvo) as 'СВВП',
sum(stroki) as str,
strokiall.strok as 'Строк всего',
Kd as 'КД/неКД'
from(
select 
datepart(ISO_WEEK,aaa.[Дата поступления]) as ww,
datepart(YEAR,aaa.[Дата поступления]) as yy,
datepart(month,aaa.[Дата поступления]) as mm,
cast(count(aaa.[Номер документа]) as int) kolvo,
aaa.[Закр-Пост,ч] t, 
cast(count(aaa.[Номер документа])*aaa.[Закр-Пост,ч] as int) ras,
sum(aaa.[Строки]) stroki,
aaa.Kd

from (
SELECT
[Номер документа] = massiv.num,
[Kd] = massiv.Kd,
[Дата поступления] = massiv.deliv,
[Время начала приемки] = massiv.priem_start,
[Время окончания приемки] = massiv.priem_end,
[Время размещения] = massiv.razm_dat,
[Время закрытия] = massiv.close_dat,
[Время приемки,ч] = DATEDIFF(HOUR, massiv.priem_start, massiv.priem_end),
[максРазмещение-минПриемки,ч] = DATEDIFF(HOUR, massiv.priem_start, massiv.razm_dat),
[Закр-Пост,ч] = DATEDIFF(HOUR, massiv.deliv, massiv.close_dat),
[Строки] = massiv.stroki,
[Кол-во, шт] = CAST(massiv.kolvo AS int),
[Вес,кг] = massiv.ves,
[Объем] = massiv.vol
FROM
(
	SELECT dr.ExternalCode AS num,iif(Comment = 'Кросс-Докинг.', 'Kd','neKd') as Kd,  dr.DeliverySubType AS dst, CONVERT(varchar(20), CAST(CONCAT(CAST(dr.DeliveryDate AS date), ' ', dr.DeliveryTime) AS datetime2(0)), 120) AS deliv, CONVERT(varchar(20), ISNULL(MIN(a.StartDate),MIN(a.RecordDate)), 120) AS priem_start, CONVERT(varchar(20), MAX(a.RecordDate), 120) AS priem_end,
	CONVERT(varchar(20),
		CASE
		WHEN( CASE
				WHEN MAX(CASE
						WHEN a.IncomeObjectName LIKE 'полка%' OR 
							a.IncomeObjectName LIKE '%L%' THEN( a.RecordDate )
						ELSE( cl.RecordDate )
						END) IS NULL THEN MAX(mol.dat)
				ELSE MAX(CASE
						WHEN a.IncomeObjectName LIKE 'полка%' OR 
							a.IncomeObjectName LIKE '%L%' THEN( a.RecordDate )
						ELSE( cl.RecordDate )
						END)
				END ) > tr.ProcessDate THEN CONVERT(varchar(20), tr.ProcessDate, 120)
		ELSE( CASE
				WHEN MAX(CASE
						WHEN a.IncomeObjectName LIKE 'полка%' OR 
							a.IncomeObjectName LIKE '%L%' THEN( a.RecordDate )
						ELSE( cl.RecordDate )
						END) IS NULL THEN MAX(mol.dat)
				ELSE MAX(CASE
						WHEN a.IncomeObjectName LIKE 'полка%' OR 
							a.IncomeObjectName LIKE '%L%' THEN( a.RecordDate )
						ELSE( cl.RecordDate )
						END)
				END )
	END, 120) AS razm_dat --время размещения						
	, CONVERT(varchar(20), tr.ProcessDate, 120) AS close_dat	---спросить какая дата закрытия приемки
	, COUNT(DISTINCT CAST(a.material_id AS varchar(10)) + '_' + CAST(a.transaction_id AS varchar(20))) AS stroki, SUM(a.Quantity) AS kolvo, SUM(CAST(a.Quantity * c.BruttoWeight AS float)) AS ves, SUM(a.Quantity * c.UnitVolume) AS vol
	FROM tbl_WarehouseIncomeMaterials AS a WITH(NOLOCK)
		 INNER JOIN
		 ProductionResources AS pr WITH(NOLOCK)
		 ON pr.tid = a.ProductionResource_id
		 JOIN
		 BarcodeObjects AS bo WITH(NOLOCK)
		 ON a.BarcodeObject_id = bo.tid
		 JOIN
		 MaterialUnits AS c WITH(NOLOCK)
		 ON bo.MaterialUnit_id = c.tid
		 JOIN
		 Materials AS d WITH(NOLOCK)
		 ON a.Material_id = d.tid
		 JOIN
		 Transactions AS tr WITH(NOLOCK)
		 ON tr.tid = a.Transaction_id
		 JOIN
		 Transactions AS tr_p WITH(NOLOCK)
		 ON tr_p.tid = tr.ParentTransaction_id
		 JOIN
		 hdr_DeliveryRequest AS dr WITH(NOLOCK)
		 ON dr.Transaction_id = tr_p.tid AND 
			dr.deliveryType_id IN(6, 25)
		 LEFT JOIN
		 tbl_WarehouseIncomeObjects AS twio
		 ON twio.tid = a.IncomeObject_id
		 LEFT JOIN
		 ComplectationLog AS cl
		 ON twio.StorageObject_id = cl.StorageObject_id AND 
			cl.BarcodeObject_id = a.BarcodeObject_id AND
			a.Material_id = cl.Material_id
		 LEFT JOIN
		 visitorslog AS vl WITH(NOLOCK)
		 ON vl.tid = dr.Transport_id
		 LEFT JOIN
	(
		SELECT DISTINCT 
			   MAL.StorageObject_id AS os, MAL.RecordDate AS dat
		--ToL.LocationName 
		FROM ManualAllocationlog AS MAL WITH(NOLOCK)
			 LEFT JOIN
			 ProductionResources AS PR WITH(NOLOCK)
			 ON PR.tid = MAL.ProductionResource_id
			 LEFT JOIN
			 StorageObjects AS so WITH(NOLOCK)
			 ON so.tid = MAL.StorageObject_id
			 LEFT JOIN
			 Warehouses AS w WITH(NOLOCK)
			 ON w.tid = so.Warehouse_id
			 LEFT JOIN
			 Locations AS ToL WITH(NOLOCK)
			 ON ToL.tid = MAL.TargetLocation_id
		WHERE MAL.CurrentLocation_id IN( 100231, 124498, 116951 ) AND 
			  MAL.Operation LIKE 'ALLOCATE' AND 
			  ToL.LocationName NOT LIKE '%TRIN%'
	) AS mol
		 ON mol.os = twio.StorageObject_id
	WHERE dr.DeliveryDate BETWEEN @StartD AND @EndD AND 
		  dr.ConsolidateTransaction_id IS NULL AND 
		  ( dr.DeliverySubType IS NULL OR 
			dr.DeliverySubType LIKE 'Поступление'
		  ) and dr.DebtorPartner_id is not null
		  and dr.Warehouse_id in (0)
	GROUP BY dr.ExternalCode, iif(Comment = 'Кросс-Докинг.', 'Kd','neKd'),CONVERT(varchar(20), CAST(CONCAT(CAST(dr.DeliveryDate AS date), ' ', dr.DeliveryTime) AS datetime2(0)), 120), tr.ProcessDate, tr_p.ProcessDate, dr.DeliverySubType
) AS massiv
) as aaa
where aaa.[Закр-Пост,ч] is not null
group by aaa.[Закр-Пост,ч],datepart(ISO_WEEK,aaa.[Дата поступления]),aaa.Kd,datepart(YEAR,aaa.[Дата поступления]),aaa.[Дата поступления]
	) as bbb
left join (
 select
datepart(ww,dr.DeliveryDate) as ww,
datepart(YEAR,dr.DeliveryDate) as yy,
cast(count(distinct cast(drm.material_id as varchar)+'_' + cast(drm.transaction_id as varchar))as real) as strok

 from hdr_DeliveryRequest as dr
 left join tbl_DeliveryRequestMaterials as drm on dr.Transaction_id = drm.Transaction_id
 where dr.DeliveryDate between @StartD and @EndD
 and dr.deliveryType_id in (6)
 and  dr.DeliverySubType is not null
 and   dr.Warehouse_id in (0)
 group by  
datepart(ww,dr.DeliveryDate) ,
datepart(YEAR,dr.DeliveryDate) ) as strokiall on bbb.yy = strokiall.yy  and bbb.ww = strokiall.ww
	group by bbb.ww,bbb.yy,bbb.mm,strokiall.strok,Kd
	order by 2,3,1


--Статистика было:
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
SQL Server parse and compile time: 
   CPU time = 438 ms, elapsed time = 442 ms.

(затронуто строк: 6)
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'hdr_DeliveryRequest'. Scan count 36, logical reads 938309, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Transactions'. Scan count 176, logical reads 325619, physical reads 0, page server reads 0, read-ahead reads 9124, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'tbl_DeliveryRequestMaterials'. Scan count 196, logical reads 1177, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Workfile'. Scan count 196, logical reads 12544, physical reads 1078, page server reads 0, read-ahead reads 11466, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'ManualAllocationLog'. Scan count 15, logical reads 17406, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Locations'. Scan count 15, logical reads 1013, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'ComplectationLog'. Scan count 15, logical reads 36212, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'tbl_WarehouseIncomeObjects'. Scan count 15, logical reads 6589, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'ProductionResources'. Scan count 15, logical reads 13, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'MaterialUnits'. Scan count 15, logical reads 1113, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'tbl_WarehouseIncomeMaterials'. Scan count 15, logical reads 46477, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'BarcodeObjects'. Scan count 15, logical reads 72567, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 12653 ms,  elapsed time = 1364 ms.
*/

SET STATISTICS TIME ON;
SET STATISTICS IO ON;


declare 
@StartD DATETIME,
@EndD DATETIME
SET 
@StartD = '2023-01-01'
SET
@EndD = '2023-05-31'-- getdate()

/*
1) Переделал вложенные запросы на табличные представления, это как минимум упростило чтение кода и агрегацию в дальнейшем в самом запросе получении данных
2) Если брать период времени более года, то происходит переизбыток данных, переделал с INT на BIGINT
3) В CTE_mol ограничил запрос к таблице ManualAllocationlog по времени записи, так как данные за прошедший период, нас не интересуют, до этого бралась вся таблица со всей историей.
4) Исправил индексы, на необходмые ключи в запросе.
GO
CREATE NONCLUSTERED INDEX [NCI_hdr_DeliveryRequest_Warehouse_Cons_DeliveryType_DebtorPartner_DeliverySubType]
ON [dbo].[hdr_DeliveryRequest] ([Warehouse_id],[ConsolidateTransaction_id],[DeliveryType_id],[DebtorPartner_id],[DeliverySubType])
INCLUDE ([Transaction_id],[Comment],[ExternalCode])
GO

GO
CREATE NONCLUSTERED INDEX [NCI_ManualAllocationLog_CurrentLocation_RecordDate_Operation]
ON [dbo].[ManualAllocationLog] ([CurrentLocation_id],[RecordDate],[Operation])
INCLUDE ([StorageObject_id],[TargetLocation_id])
GO


*/


--Ручные перемещения объектов складирования
--ограничу по времени, брать всю таблу плохо
;WITH CTE_mol (os,dat)
AS (
	SELECT DISTINCT MAL.StorageObject_id AS os
		,MAL.RecordDate AS dat	
	FROM ManualAllocationlog AS MAL WITH (NOLOCK)
	LEFT JOIN ProductionResources AS PR WITH (NOLOCK) ON PR.tid = MAL.ProductionResource_id
	LEFT JOIN StorageObjects AS so WITH (NOLOCK) ON so.tid = MAL.StorageObject_id
	LEFT JOIN Warehouses AS w WITH (NOLOCK) ON w.tid = so.Warehouse_id
	LEFT JOIN Locations AS ToL WITH (NOLOCK) ON ToL.tid = MAL.TargetLocation_id
	WHERE MAL.CurrentLocation_id IN (100231,124498,116951)
		AND MAL.Operation LIKE 'ALLOCATE'
		AND ToL.LocationName NOT LIKE '%TRIN%'
		AND mal.RecordDate > @StartD
	)
,--Сводные данные по входщим поставкам с делением по типу
CTE_massiv (num, Kd, dst, deliv, priem_start, priem_end, razm_dat, close_dat, stroki, kolvo, ves, vol)
as (SELECT dr.ExternalCode AS num
	,iif(Comment = 'Кросс-Докинг.', 'Kd', 'neKd') AS Kd
	,dr.DeliverySubType AS dst
	,tr_p.CreationDate AS deliv
	,CONVERT(VARCHAR(20), ISNULL(MIN(a.StartDate), MIN(a.RecordDate)), 120) AS priem_start
	,CONVERT(VARCHAR(20), MAX(a.RecordDate), 120) AS priem_end
	,CONVERT(VARCHAR(20), CASE 
			WHEN (
					CASE 
						WHEN MAX(CASE 
									WHEN a.IncomeObjectName LIKE 'полка%'
										OR a.IncomeObjectName LIKE '%L%'
										THEN (a.RecordDate)
									ELSE (cl.RecordDate)
									END) IS NULL
							THEN MAX(mol.dat)
						ELSE MAX(CASE 
									WHEN a.IncomeObjectName LIKE 'полка%'
										OR a.IncomeObjectName LIKE '%L%'
										THEN (a.RecordDate)
									ELSE (cl.RecordDate)
									END)
						END
					) > tr.ProcessDate
				THEN CONVERT(VARCHAR(20), tr.ProcessDate, 120)
			ELSE (
					CASE 
						WHEN MAX(CASE 
									WHEN a.IncomeObjectName LIKE 'полка%'
										OR a.IncomeObjectName LIKE '%L%'
										THEN (a.RecordDate)
									ELSE (cl.RecordDate)
									END) IS NULL
							THEN MAX(mol.dat)
						ELSE MAX(CASE 
									WHEN a.IncomeObjectName LIKE 'полка%'
										OR a.IncomeObjectName LIKE '%L%'
										THEN (a.RecordDate)
									ELSE (cl.RecordDate)
									END)
						END
					)
			END, 120) AS razm_dat --время размещения						
	,CONVERT(VARCHAR(20), tr.ProcessDate, 120) AS close_dat ---спросить какая дата закрытия приемки
	,COUNT(DISTINCT CAST(a.material_id AS VARCHAR(10)) + '_' + CAST(a.transaction_id AS VARCHAR(20))) AS stroki
	,SUM(a.Quantity) AS kolvo
	,SUM(CAST(a.Quantity * c.BruttoWeight AS FLOAT)) AS ves
	,SUM(a.Quantity * c.UnitVolume) AS vol
FROM tbl_WarehouseIncomeMaterials AS a WITH (NOLOCK)
INNER JOIN ProductionResources AS pr WITH (NOLOCK) ON pr.tid = a.ProductionResource_id
JOIN BarcodeObjects AS bo WITH (NOLOCK) ON a.BarcodeObject_id = bo.tid
JOIN MaterialUnits AS c WITH (NOLOCK) ON bo.MaterialUnit_id = c.tid
JOIN Materials AS d WITH (NOLOCK) ON a.Material_id = d.tid
JOIN Transactions AS tr WITH (NOLOCK) ON tr.tid = a.Transaction_id
JOIN Transactions AS tr_p WITH (NOLOCK) ON tr_p.tid = tr.ParentTransaction_id
JOIN hdr_DeliveryRequest AS dr WITH (NOLOCK) ON dr.Transaction_id = tr_p.tid
	AND dr.deliveryType_id IN (6,25)
LEFT JOIN tbl_WarehouseIncomeObjects AS twio ON twio.tid = a.IncomeObject_id
LEFT JOIN ComplectationLog AS cl ON twio.StorageObject_id = cl.StorageObject_id
	AND cl.BarcodeObject_id = a.BarcodeObject_id
	AND a.Material_id = cl.Material_id
LEFT JOIN visitorslog AS vl WITH (NOLOCK) ON vl.tid = dr.Transport_id
LEFT JOIN CTE_mol AS mol ON mol.os = twio.StorageObject_id
WHERE tr_p.CreationDate BETWEEN @StartD
		AND @EndD
	AND dr.ConsolidateTransaction_id IS NULL
	AND (dr.DeliverySubType IS NULL	OR dr.DeliverySubType LIKE 'Поступление')
	AND dr.DebtorPartner_id IS NOT NULL
	AND dr.Warehouse_id IN (0)
GROUP BY dr.ExternalCode
	,iif(Comment = 'Кросс-Докинг.', 'Kd', 'neKd')
	,tr_p.CreationDate
	,tr.ProcessDate
	,tr_p.ProcessDate
	,dr.DeliverySubType
)
,--Заявленные строки документов входящих поставок за период
CTE_strokiall (ww, yy, strok)
as (
select
datepart(ww, tr.CreationDate),
datepart(YEAR, tr.CreationDate),
cast(count(distinct cast(drm.material_id as varchar)+'_' + cast(drm.transaction_id as varchar))as real)
from hdr_DeliveryRequest as dr
join Transactions as tr on dr.Transaction_id = tr.tid
left join tbl_DeliveryRequestMaterials as drm on dr.Transaction_id = drm.Transaction_id
where tr.CreationDate between @StartD and @EndD
and dr.deliveryType_id in (6)
and  dr.DeliverySubType is not null
and   dr.Warehouse_id in (0)
group by datepart(ww, tr.CreationDate), datepart(YEAR, tr.CreationDate)
)


--Вывод данных
SELECT bbb.ww AS 'Неделя'
	,bbb.yy AS 'Год'
	,bbb.mm AS 'Месяц'
	,sum(bbb.ras) / sum(bbb.kolvo) AS 'СВВП'
	,sum(bbb.stroki) AS str
	,strokiall.strok as 'Строк всего'
	,bbb.Kd AS 'КД/неКД'
FROM
(
SELECT
datepart(ISO_WEEK, massiv.deliv) AS ww
,datepart(YEAR, massiv.deliv) AS yy
,datepart(month, massiv.deliv) AS mm
,cast(count(massiv.num) AS BIGINT) kolvo
,DATEDIFF(HOUR, massiv.deliv, massiv.close_dat) as t
,cast(count(massiv.num)*DATEDIFF(HOUR, massiv.deliv, massiv.close_dat) AS BIGINT) ras
,sum(massiv.stroki) stroki
,massiv.Kd
FROM CTE_massiv AS massiv
where DATEDIFF(HOUR, massiv.deliv, massiv.close_dat) IS NOT NULL
GROUP BY DATEDIFF(HOUR, massiv.deliv, massiv.close_dat)
		,datepart(ISO_WEEK, massiv.deliv)
		,massiv.Kd
		,datepart(YEAR, massiv.deliv)
		,massiv.deliv
) AS bbb
LEFT JOIN CTE_strokiall AS strokiall ON bbb.yy = strokiall.yy 
									AND bbb.ww = strokiall.ww
GROUP BY bbb.ww
	,bbb.yy
	,bbb.mm
	,strokiall.strok
	,bbb.Kd
ORDER BY bbb.yy asc
	,bbb.mm asc
	,bbb.ww asc

/*

--Статистика стало:
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

(затронуто строк: 6)
Table 'hdr_DeliveryRequest'. Scan count 34, logical reads 52082, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Transactions'. Scan count 176, logical reads 325892, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'tbl_DeliveryRequestMaterials'. Scan count 196, logical reads 1177, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Workfile'. Scan count 196, logical reads 12544, physical reads 1078, page server reads 0, read-ahead reads 11466, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'ManualAllocationLog'. Scan count 23, logical reads 18, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Locations'. Scan count 15, logical reads 1013, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'ComplectationLog'. Scan count 15, logical reads 36212, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'tbl_WarehouseIncomeObjects'. Scan count 15, logical reads 6589, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'ProductionResources'. Scan count 15, logical reads 13, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'MaterialUnits'. Scan count 15, logical reads 1113, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'tbl_WarehouseIncomeMaterials'. Scan count 15, logical reads 46477, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'BarcodeObjects'. Scan count 15, logical reads 72567, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 12380 ms,  elapsed time = 1275 ms.
*/
