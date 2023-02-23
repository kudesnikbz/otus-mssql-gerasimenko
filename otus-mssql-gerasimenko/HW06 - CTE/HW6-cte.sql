/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

-- через вложенный запрос
SELECT a.PersonID
	  ,a.FullName
FROM Application.People AS a
WHERE a.IsSalesPerson = 1
	AND a.PersonID NOT IN (
		SELECT b.SalespersonPersonID
		FROM Sales.Invoices as b
		WHERE b.InvoiceDate = '20150704'
		)

-- через WITH
;WITH InvoicesCTE (SalespersonPersonID)
AS (
	SELECT SalespersonPersonID
	FROM Sales.Invoices
	WHERE InvoiceDate = '20150704'
	)
SELECT a.PersonID
	,a.FullName
FROM Application.People AS a
LEFT JOIN InvoicesCTE AS b ON a.PersonID = b.SalespersonPersonID
WHERE a.IsSalesPerson = 1
	AND b.SalespersonPersonID IS NULL


/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/
-- через вложенный запрос
SELECT a.StockItemID
	,a.StockItemName
	,a.UnitPrice
FROM [Warehouse].[StockItems] AS a
WHERE a.UnitPrice = (
		SELECT MIN(b.UnitPrice)
		FROM [Warehouse].[StockItems] AS b
		)

-- через вложенный запрос
SELECT a.StockItemID
	,a.StockItemName
	,a.UnitPrice
FROM [Warehouse].[StockItems] AS a
WHERE a.UnitPrice = (
		SELECT TOP (1) b.UnitPrice
		FROM [Warehouse].[StockItems] AS b
		ORDER BY b.UnitPrice ASC
		)

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/
-- через вложенный запрос v1
SELECT a.CustomerName
FROM Sales.Customers AS a
WHERE a.CustomerID IN (
		SELECT TOP 5 b.CustomerID
		FROM Sales.CustomerTransactions AS b
		ORDER BY b.TransactionAmount DESC
		)

-- через вложенный запрос v2
SELECT a.CustomerName
FROM Sales.Customers AS a
WHERE a.CustomerID IN (
		SELECT TOP 5 b.CustomerID
		FROM Sales.CustomerTransactions AS b
		GROUP BY b.CustomerID
		ORDER BY MAX(b.TransactionAmount) DESC
		)

-- через WITH
;WITH MaxTransactionAmountCTE (CustomerID)
AS (
	SELECT TOP 5 b.CustomerID
	FROM Sales.CustomerTransactions AS b
	GROUP BY b.CustomerID
	ORDER BY MAX(b.TransactionAmount) DESC
	)
	
SELECT a.CustomerName
FROM Sales.Customers AS a
WHERE EXISTS (
		SELECT 1
		FROM MaxTransactionAmountCTE AS b
		WHERE a.CustomerID = b.CustomerID
		)
/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

WITH InvoicesCTE1 (CustomerID,PackedByPersonID)
AS (
	SELECT a.CustomerID, a.PackedByPersonID
	FROM Sales.Invoices AS a
	JOIN Sales.InvoiceLines AS b ON a.InvoiceID = b.InvoiceID
	WHERE b.StockItemID IN (
			SELECT TOP (3) a.StockItemID
			FROM [Warehouse].[StockItems] AS a
			ORDER BY a.UnitPrice DESC
			)
	)
SELECT c.CityID
	,c.CityName
	,d.FullName
FROM InvoicesCTE1 AS a
JOIN Sales.Customers AS b ON a.CustomerID = b.CustomerID
JOIN Application.Cities AS c ON b.DeliveryCityID = c.CityID
JOIN Application.People AS d ON a.PackedByPersonID = d.PersonID
GROUP BY c.CityID, c.CityName, d.FullName
ORDER BY c.CityName

;WITH InvoicesCTE2 (DeliveryCityID, PackedByPersonName)
AS (
	SELECT c.DeliveryCityID, d.FullName
	FROM Sales.Invoices AS a
	JOIN Sales.InvoiceLines AS b ON a.InvoiceID = b.InvoiceID
	JOIN Sales.Customers AS c ON a.CustomerID = c.CustomerID
	JOIN Application.People AS d ON a.PackedByPersonID = d.PersonID
	WHERE b.StockItemID IN (
			SELECT TOP (3) a.StockItemID
			FROM [Warehouse].[StockItems] AS a
			ORDER BY a.UnitPrice DESC
			)
	)
SELECT a.DeliveryCityID
	,[CityName] = (
		SELECT CityName
		FROM Application.Cities AS c
		WHERE c.CityID = a.DeliveryCityID
		)
	,a.PackedByPersonName
FROM InvoicesCTE2 AS a
GROUP BY a.DeliveryCityID
	,a.PackedByPersonName
ORDER BY CityName

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

 --SQL Server Execution Times:
 --  CPU time = 110 ms,  elapsed time = 62 ms.

-- --

--V1 -- улучшил читабельность кода.
SET STATISTICS IO,TIME ON;

WITH SalesTotalsCTE (InvoiceId,TotalSumm)
AS (
	SELECT InvoiceId,SUM(Quantity * UnitPrice)
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity * UnitPrice) > 27000
	)
	,TotalSummForPickedItemsCTE (OrderId,TotalSummForPickedItems)
AS (
	SELECT a.OrderId,SUM(b.PickedQuantity * b.UnitPrice)
	FROM Sales.Orders AS a
	JOIN Sales.OrderLines AS b ON a.OrderId = b.OrderId
	WHERE a.PickingCompletedWhen IS NOT NULL
	GROUP BY a.OrderId
	)
	
SELECT a.InvoiceID
	,a.InvoiceDate
	,[SalesPersonName] = c.FullName
	,[TotalSummByInvoice] = b.TotalSumm
	,d.TotalSummForPickedItems
FROM Sales.Invoices AS a
JOIN Application.People AS c ON a.SalespersonPersonID = c.PersonID
JOIN SalesTotalsCTE AS b ON a.InvoiceID = b.InvoiceID
JOIN TotalSummForPickedItemsCTE AS d ON a.OrderID = d.OrderId
ORDER BY [TotalSummByInvoice] DESC

SET STATISTICS IO,TIME OFF

--SQL Server Execution Times:
--   CPU time = 63 ms,  elapsed time = 70 ms.
