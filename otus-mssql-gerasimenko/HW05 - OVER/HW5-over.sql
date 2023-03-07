/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters
/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

;WITH SumEOCTE (InDate,SumPerMonth
	)
AS (
	SELECT EOMONTH(a2.InvoiceDate)
		,SUM(b2.ExtendedPrice)
	FROM Sales.Invoices AS a2
	JOIN Sales.InvoiceLines AS b2 ON a2.InvoiceID = b2.InvoiceID
	WHERE a2.InvoiceDate BETWEEN '20150101'
			AND EOMONTH(a2.InvoiceDate)
	GROUP BY EOMONTH(a2.InvoiceDate)
	)
SELECT a1.InvoiceID
	,c.CustomerName
	,a1.InvoiceDate
	,[InvoicePrice] = SUM(b1.ExtendedPrice)
	,d.SumPerMonth
FROM Sales.Invoices AS a1
JOIN Sales.InvoiceLines AS b1 ON a1.InvoiceID = b1.InvoiceID
JOIN Sales.Customers c ON a1.CustomerID = c.CustomerID
JOIN SumEOCTE AS d ON d.InDate >= a1.InvoiceDate
	AND d.InDate <= EOMONTH(a1.InvoiceDate)
WHERE a1.InvoiceDate > '20150101'
GROUP BY a1.InvoiceID
	,c.CustomerName
	,a1.InvoiceDate
	,d.SumPerMonth
ORDER BY a1.InvoiceDate ASC
	,a1.InvoiceID ASC
	,c.CustomerName ASC

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

SELECT a1.InvoiceID
	,c.CustomerName
	,a1.InvoiceDate
	,[InvoicePrice] = b1.ExtendedPrice
	,SUM(b1.ExtendedPrice) OVER (PARTITION BY DATEPART(YEAR, a1.InvoiceDate), DATEPART(MONTH, a1.InvoiceDate) ORDER BY DATEPART(YEAR, a1.InvoiceDate), DATEPART(MONTH, a1.InvoiceDate))
FROM Sales.Invoices AS a1
JOIN Sales.InvoiceLines AS b1 ON a1.InvoiceID = b1.InvoiceID
JOIN Sales.Customers c ON a1.CustomerID = c.CustomerID
WHERE a1.InvoiceDate >= '20150101'
ORDER BY a1.InvoiceID ASC
,a1.InvoiceDate ASC
	,c.CustomerName ASC

--сумма продаж по году + месяц
--SELECT [YEAR] = DATEPART(YEAR, a2.InvoiceDate), [MONTH] = DATEPART(MONTH, a2.InvoiceDate)
--	,[SumExtendedPrice] = SUM(b2.ExtendedPrice)
--FROM Sales.Invoices AS a2
--JOIN Sales.InvoiceLines AS b2 ON a2.InvoiceID = b2.InvoiceID
--WHERE a2.InvoiceDate >= '20150101'			
--GROUP BY DATEPART(YEAR, a2.InvoiceDate), DATEPART(MONTH, a2.InvoiceDate)
--ORDER BY [YEAR], [MONTH]


/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

SELECT x.[YEAR]
	,x.[MONTH]
	,x.StockItemName
	,CntSalesItem
FROM (
	SELECT [YEAR] = YEAR(a.InvoiceDate)
		,[MONTH] = MONTH(a.InvoiceDate)
		,c.StockItemName
		,CntSalesItem = count(b.StockItemID)
		,[RN] = ROW_NUMBER() OVER (PARTITION BY YEAR(a.InvoiceDate),MONTH(a.InvoiceDate) ORDER BY count(b.StockItemID) DESC)
	FROM Sales.Invoices AS a
	JOIN Sales.InvoiceLines AS b ON a.InvoiceID = b.InvoiceID
	JOIN Warehouse.StockItems AS c ON b.StockItemID = c.StockItemID
	WHERE a.InvoiceDate BETWEEN '20160101' AND '20170101'
	GROUP BY YEAR(a.InvoiceDate),MONTH(a.InvoiceDate),c.StockItemName
	) AS x
WHERE x.RN <= 2
ORDER BY [YEAR], [MONTH], [RN]

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

SELECT a.StockItemID
	,a.StockItemName
	,a.Brand
	,a.UnitPrice
	,ROW_NUMBER() OVER (PARTITION BY LEFT(a.StockItemName, 1) ORDER BY a.StockItemName) AS RN_ItemName
	,COUNT(*) OVER () AS Cnt_ItemName
	,COUNT(*) OVER (PARTITION BY LEFT(a.StockItemName, 1) ORDER BY LEFT(a.StockItemName, 1)) AS Cnt_FirstItemName
	,LEAD(a.StockItemID) OVER (ORDER BY a.StockItemName) AS FollowItemID
	,LAG(a.StockItemID) OVER (ORDER BY a.StockItemName) AS PrewItemID
	,LAG(a.StockItemName, 2, 'No items') OVER (ORDER BY a.StockItemName) AS PrewItemID
	,NTILE(30) OVER (ORDER BY a.TypicalWeightPerUnit) AS GroupNumber
FROM Warehouse.StockItems AS a
ORDER BY a.StockItemName ASC

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

SELECT PersonID
	,FullName
	,CustomerID
	,CustomerName
	,InvoiceDate
	,SumInvoice
FROM (
	SELECT c.PersonID
		,c.FullName
		,d.CustomerID
		,d.CustomerName
		,a.InvoiceDate
		,SumInvoice = SUM(b.ExtendedPrice)
		,[RN] = ROW_NUMBER() OVER (PARTITION BY c.PersonID ORDER BY a.InvoiceDate DESC, a.InvoiceID DESC)
	FROM Sales.Invoices AS a
	INNER JOIN Sales.InvoiceLines AS b ON a.InvoiceID = b.InvoiceID
	INNER JOIN Application.People AS c ON a.SalespersonPersonID = c.PersonID
	INNER JOIN Sales.Customers AS d ON a.CustomerID = d.CustomerID
	GROUP BY c.PersonID, c.FullName, d.CustomerID, d.CustomerName, a.InvoiceDate, a.InvoiceID
	) AS X
WHERE x.RN = 1
ORDER BY x.PersonID
	,x.FullName
	,x.CustomerID
	,x.CustomerName
	,x.InvoiceDate
	,x.SumInvoice

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/
-- 1) Вариант через ROW_NUMBER
;WITH CTE1 (CustomerID,StockItemID,UnitPrice,TeuerUnitPrice)
AS (
	SELECT a.CustomerID
		,c.StockItemID
		,c.UnitPrice
		,ROW_NUMBER() OVER (PARTITION BY a.CustomerID ORDER BY a.CustomerID,c.UnitPrice DESC)
	FROM Sales.Invoices AS a
	JOIN Sales.InvoiceLines AS b ON a.InvoiceID = b.InvoiceID
	JOIN Warehouse.StockItems AS c ON b.StockItemID = c.StockItemID
	GROUP BY a.CustomerID
		,c.StockItemID
		,c.UnitPrice
	)
	,CTE2 (CustomerID,CustomerName,StockItemID,UnitPrice,TeuerUnitPrice)
AS (
	SELECT a.CustomerID
		,b.CustomerName
		,a.StockItemID
		,a.UnitPrice
		,a.TeuerUnitPrice
	FROM CTE1 AS a
	JOIN Sales.Customers AS b ON a.CustomerID = b.CustomerID
	WHERE TeuerUnitPrice < = 2
		--order by a.CustomerID, a.TeuerUnitPrice
	)
SELECT c.CustomerID
	,c.CustomerName
	,c.StockItemID
	,c.UnitPrice
	,InvoiceDate = MAX(a.InvoiceDate)
FROM Sales.Invoices AS a
JOIN Sales.InvoiceLines AS b ON a.InvoiceID = b.InvoiceID
JOIN CTE2 AS c ON a.CustomerID = c.CustomerID
	AND b.StockItemID = c.StockItemID
GROUP BY c.CustomerID
	,c.CustomerName
	,c.StockItemID
	,c.UnitPrice
ORDER BY c.CustomerID
	,c.UnitPrice DESC
	,InvoiceDate

-- 2) Вариант через RANK показывает две последние максимальные цены, при этом количество товаров больше, так как может быть несколько товаров с одинаковой ценой.
;WITH CTE1 (CustomerID,StockItemID,UnitPrice,TeuerUnitPrice)
AS (
	SELECT a.CustomerID
		,c.StockItemID
		,c.UnitPrice
		,RANK() OVER (PARTITION BY a.CustomerID ORDER BY a.CustomerID,c.UnitPrice DESC)
	FROM Sales.Invoices AS a
	JOIN Sales.InvoiceLines AS b ON a.InvoiceID = b.InvoiceID
	JOIN Warehouse.StockItems AS c ON b.StockItemID = c.StockItemID
	GROUP BY a.CustomerID
		,c.StockItemID
		,c.UnitPrice
	)
	,CTE2 (
	CustomerID
	,CustomerName
	,StockItemID
	,UnitPrice
	,TeuerUnitPrice
	)
AS (
	SELECT a.CustomerID
		,b.CustomerName
		,a.StockItemID
		,a.UnitPrice
		,a.TeuerUnitPrice
	FROM CTE1 AS a
	JOIN Sales.Customers AS b ON a.CustomerID = b.CustomerID
	WHERE TeuerUnitPrice < = 2
	)
SELECT c.CustomerID
	,c.CustomerName
	,c.StockItemID
	,c.UnitPrice
	,InvoiceDate = MAX(a.InvoiceDate)
FROM Sales.Invoices AS a
JOIN Sales.InvoiceLines AS b ON a.InvoiceID = b.InvoiceID
JOIN CTE2 AS c ON a.CustomerID = c.CustomerID
	AND b.StockItemID = c.StockItemID
GROUP BY c.CustomerID
	,c.CustomerName
	,c.StockItemID
	,c.UnitPrice
ORDER BY c.CustomerID
	,c.UnitPrice DESC
	,InvoiceDate


Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 