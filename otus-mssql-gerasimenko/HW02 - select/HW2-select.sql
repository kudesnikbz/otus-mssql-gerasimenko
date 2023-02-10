/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT DISTINCT StockItemID
	,StockItemName
FROM Warehouse.StockItems
WHERE StockItemName LIKE N'%urgent%'
	OR StockItemName LIKE N'Animal%'
ORDER BY StockItemID ASC
	,StockItemName

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

SELECT DISTINCT a.SupplierID
	,a.SupplierName
FROM Purchasing.Suppliers AS a
LEFT JOIN Purchasing.PurchaseOrders AS b ON a.SupplierID = b.SupplierID
WHERE b.SupplierID IS NULL
ORDER BY a.SupplierID
	,a.SupplierName

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

DECLARE @Rows TINYINT = 0
	   ,@Fetch TINYINT = 5;

SELECT a.OrderID
	,[OrderDate1] = CONVERT(VARCHAR(10), a.OrderDate, 104) --дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
	,[OrderDate2] = FORMAT(a.OrderDate, 'dd.MM.yyyy') --дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
	,[MonthName] = datename(month, a.OrderDate) -- название месяца, в котором был сделан заказ
	,[Quarter] = DATEPART(quarter, a.OrderDate) --номер квартала, в котором был сделан заказ
	,[ThirdYear] = -- треть года, к которой относится дата заказа (каждая треть по 4 месяца)
	CASE 
		WHEN DATEPART(month, a.OrderDate) BETWEEN 1	AND 4
			THEN 1
		WHEN DATEPART(month, a.OrderDate) BETWEEN 4 AND 8
			THEN 2
		WHEN DATEPART(month, a.OrderDate) BETWEEN 8 AND 12
			THEN 3
		END
	,c.CustomerName
FROM Sales.Orders AS a
JOIN Sales.OrderLines AS b ON a.OrderID = b.OrderID
JOIN Sales.Customers AS c ON a.CustomerID = c.CustomerID
WHERE a.PickingCompletedWhen IS NOT NULL
	AND (UnitPrice > 100 OR Quantity > 20)
GROUP BY a.OrderID
	,a.OrderDate
	,c.CustomerName
ORDER BY [Quarter] ASC
	,[ThirdYear] ASC
	,a.OrderDate ASC -- Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).
OFFSET @Rows Rows
FETCH NEXT @Fetch Rows ONLY;

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT DISTINCT
	c.DeliveryMethodName
	,b.ExpectedDeliveryDate
	,a.SupplierName
	,d.FullName
FROM Purchasing.Suppliers AS a
JOIN Purchasing.PurchaseOrders AS b ON a.SupplierID = b.SupplierID
JOIN Application.DeliveryMethods AS c ON b.DeliveryMethodID = c.DeliveryMethodID
JOIN Application.People AS d ON b.ContactPersonID = d.PersonID
WHERE b.ExpectedDeliveryDate BETWEEN '20130101' AND EOMONTH('20130101')
	AND b.IsOrderFinalized = 1
	AND c.DeliveryMethodName IN ('Air Freight','Refrigerated Air Freight')
ORDER BY c.DeliveryMethodName
	,b.ExpectedDeliveryDate
	,a.SupplierName
	,d.FullName

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

SELECT TOP 10 b.CustomerName
	,c.FullName
FROM Sales.Orders AS a
JOIN [Sales].[Customers] AS b ON a.CustomerID = b.CustomerID
JOIN [Application].[People] AS c ON a.SalespersonPersonID = c.PersonID
ORDER BY a.OrderDate DESC

--WITH TIES смотрит на атрибуты в ORDER BY

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

SELECT DISTINCT c.CustomerID
	,c.CustomerName
	,c.PhoneNumber
FROM Sales.Orders AS a
JOIN Sales.OrderLines AS b ON a.OrderID = b.OrderID
JOIN [Sales].[Customers] c ON a.CustomerID = c.CustomerID
JOIN Warehouse.StockItems AS d ON b.StockItemID = d.StockItemID
WHERE d.StockItemName = 'Chocolate frogs 250g'
ORDER BY c.CustomerID ASC
	,c.CustomerName
	,c.PhoneNumber