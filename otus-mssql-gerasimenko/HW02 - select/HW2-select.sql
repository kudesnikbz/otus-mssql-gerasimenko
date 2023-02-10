/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.
������� "02 - �������� SELECT � ������� �������, JOIN".

������� ����������� � �������������� ���� ������ WideWorldImporters.

����� �� WideWorldImporters ����� ������� ������:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

�������� WideWorldImporters �� Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- ������� - �������� ������� ��� ��������� ��������� ���� ������.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. ��� ������, � �������� ������� ���� "urgent" ��� �������� ���������� � "Animal".
�������: �� ������ (StockItemID), ������������ ������ (StockItemName).
�������: Warehouse.StockItems.
*/

SELECT DISTINCT StockItemID
	,StockItemName
FROM Warehouse.StockItems
WHERE StockItemName LIKE N'%urgent%'
	OR StockItemName LIKE N'Animal%'
ORDER BY StockItemID ASC
	,StockItemName

/*
2. ����������� (Suppliers), � ������� �� ���� ������� �� ������ ������ (PurchaseOrders).
������� ����� JOIN, � ����������� ������� ������� �� �����.
�������: �� ���������� (SupplierID), ������������ ���������� (SupplierName).
�������: Purchasing.Suppliers, Purchasing.PurchaseOrders.
�� ����� �������� ������ JOIN ��������� ��������������.
*/

SELECT DISTINCT a.SupplierID
	,a.SupplierName
FROM Purchasing.Suppliers AS a
LEFT JOIN Purchasing.PurchaseOrders AS b ON a.SupplierID = b.SupplierID
WHERE b.SupplierID IS NULL
ORDER BY a.SupplierID
	,a.SupplierName

/*
3. ������ (Orders) � ����� ������ (UnitPrice) ����� 100$ 
���� ����������� ������ (Quantity) ������ ����� 20 ����
� �������������� ����� ������������ ����� ������ (PickingCompletedWhen).
�������:
* OrderID
* ���� ������ (OrderDate) � ������� ��.��.����
* �������� ������, � ������� ��� ������ �����
* ����� ��������, � ������� ��� ������ �����
* ����� ����, � ������� ��������� ���� ������ (������ ����� �� 4 ������)
* ��� ��������� (Customer)
�������� ������� ����� ������� � ������������ ��������,
��������� ������ 1000 � ��������� ��������� 100 �������.

���������� ������ ���� �� ������ ��������, ����� ����, ���� ������ (����� �� �����������).

�������: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

DECLARE @Rows TINYINT = 0
	   ,@Fetch TINYINT = 5;

SELECT a.OrderID
	,[OrderDate1] = CONVERT(VARCHAR(10), a.OrderDate, 104) --���� ������ (OrderDate) � ������� ��.��.����
	,[OrderDate2] = FORMAT(a.OrderDate, 'dd.MM.yyyy') --���� ������ (OrderDate) � ������� ��.��.����
	,[MonthName] = datename(month, a.OrderDate) -- �������� ������, � ������� ��� ������ �����
	,[Quarter] = DATEPART(quarter, a.OrderDate) --����� ��������, � ������� ��� ������ �����
	,[ThirdYear] = -- ����� ����, � ������� ��������� ���� ������ (������ ����� �� 4 ������)
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
	,a.OrderDate ASC -- ���������� ������ ���� �� ������ ��������, ����� ����, ���� ������ (����� �� �����������).
OFFSET @Rows Rows
FETCH NEXT @Fetch Rows ONLY;

/*
4. ������ ����������� (Purchasing.Suppliers),
������� ������ ���� ��������� (ExpectedDeliveryDate) � ������ 2013 ����
� ��������� "Air Freight" ��� "Refrigerated Air Freight" (DeliveryMethodName)
� ������� ��������� (IsOrderFinalized).
�������:
* ������ �������� (DeliveryMethodName)
* ���� �������� (ExpectedDeliveryDate)
* ��� ����������
* ��� ����������� ���� ������������ ����� (ContactPerson)

�������: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
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
5. ������ ��������� ������ (�� ���� �������) � ������ ������� � ������ ����������,
������� ������� ����� (SalespersonPerson).
������� ��� �����������.
*/

SELECT TOP 10 b.CustomerName
	,c.FullName
FROM Sales.Orders AS a
JOIN [Sales].[Customers] AS b ON a.CustomerID = b.CustomerID
JOIN [Application].[People] AS c ON a.SalespersonPersonID = c.PersonID
ORDER BY a.OrderDate DESC

--WITH TIES ������� �� �������� � ORDER BY

/*
6. ��� �� � ����� �������� � �� ���������� ��������,
������� �������� ����� "Chocolate frogs 250g".
��� ������ �������� � ������� Warehouse.StockItems.
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