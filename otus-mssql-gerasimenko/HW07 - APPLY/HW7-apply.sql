/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

SELECT [InvoiceDate] = CONVERT(varchar(10), pvt.InvoiceDate, 104)
	,pvt.[Jessie, ND]
	,pvt.[Sylvanite, MT]
	,pvt.[Gasport, NY]
	,pvt.[Peeples Valley, AZ]
	,pvt.[Medicine Lodge, KS]
FROM (
	SELECT [InvoiceDate] = DATEADD(month, DATEDIFF(month, 0, a.InvoiceDate), 0)
		,[CustomerName] = SUBSTRING(b.CustomerName, CHARINDEX('(', b.CustomerName) + 1, CHARINDEX(')', SUBSTRING(b.CustomerName, CHARINDEX('(', b.CustomerName) + 1, LEN(b.CustomerName))) - 1)
		,a.InvoiceID
	FROM Sales.Invoices AS a
	JOIN Sales.Customers AS b ON a.CustomerID = b.CustomerID
	WHERE b.CustomerID BETWEEN 2
			AND 6
	) AS x
PIVOT(COUNT(x.InvoiceID) FOR x.[CustomerName] IN (
			[Jessie, ND]
			,[Sylvanite, MT]
			,[Gasport, NY]
			,[Peeples Valley, AZ]
			,[Medicine Lodge, KS]
			)) AS pvt
ORDER BY pvt.InvoiceDate ASC

--select 
--[InvoiceDate] = FORMAT(a.InvoiceDate, 'dd.MM.yyyy'),
--b.CustomerName,
--RTRIM(SUBSTRING(F_Str.CustomerName2, 0, F_P1.p1))
--from Sales.Invoices as a
--JOIN Sales.Customers as b on a.CustomerID = b.CustomerID
--cross apply (select CustomerName2=SUBSTRING(b.CustomerName, CHARINDEX('(', b.CustomerName) + 1, LEN(b.CustomerName))) F_Str
--cross apply (select p1=charindex(')',CustomerName2)-1) F_P1
--where b.CustomerID between 2 and 6


/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

SELECT upvt.CustomerName
	,upvt.AddressLine
FROM (
	SELECT a.CustomerName
		,DeliveryAddressLine1
		,DeliveryAddressLine2
		,PostalAddressLine1
		,PostalAddressLine2
	FROM Sales.Customers AS a
	WHERE CustomerName LIKE 'Tailspin Toys%'
	) AS x
unpivot(AddressLine FOR AddressLineAll IN (
			DeliveryAddressLine1
			,DeliveryAddressLine2
			,PostalAddressLine1
			,PostalAddressLine2
			)) AS upvt
ORDER BY upvt.CustomerName

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

SELECT CountryID
	,CountryName
	,Code
FROM (
	SELECT CountryID
		,CountryName
		,IsoAlpha3Code
		,[IsoNumericCode] = CAST(IsoNumericCode AS NVARCHAR(3)) -- Приведение типов, как по другому?
	FROM Application.Countries
	) AS x
unpivot(Code FOR IsoList IN (
			IsoAlpha3Code
			,IsoNumericCode
			)) AS pvt;

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

;WITH CTE1 (CustomerID,StockItemID,UnitPrice,[InvoiceDate])
AS (
	SELECT a.CustomerID
		,b.StockItemID
		,b.UnitPrice
		,[InvoiceDate] = MAX(a.InvoiceDate)
	FROM Sales.Invoices AS a
	JOIN Sales.InvoiceLines AS b ON a.InvoiceID = b.InvoiceID
	GROUP BY a.CustomerID
		,b.StockItemID
		,b.UnitPrice
	)

SELECT c.CustomerID
	,c.CustomerName
	,x.StockItemID
	,x.UnitPrice
	,x.InvoiceDate
FROM Sales.Customers AS c
CROSS APPLY (
	SELECT TOP (2) il.StockItemID
		,il.UnitPrice
		,il.InvoiceDate
	FROM CTE1 AS il
	WHERE c.CustomerID = il.CustomerID
	ORDER BY il.UnitPrice DESC
	) AS x
ORDER BY c.CustomerID
	,x.UnitPrice DESC
	,x.InvoiceDate ASC

/*
SELECT a.CustomerID
	,c.CustomerName
	,b.StockItemID
	,b.ExtendedPrice
	,a.InvoiceDate
FROM Sales.Invoices AS a
JOIN Sales.InvoiceLines AS b ON a.InvoiceID = b.InvoiceID
JOIN Sales.Customers AS c ON a.CustomerID = c.CustomerID
CROSS APPLY (
	SELECT TOP (2) si.StockItemID
	FROM [Warehouse].[StockItems] AS si
	ORDER BY si.UnitPrice DESC
	) AS x
WHERE x.StockItemID = b.StockItemID
ORDER BY a.CustomerID
	,b.ExtendedPrice DESC
	,a.InvoiceDate ASC
*/
