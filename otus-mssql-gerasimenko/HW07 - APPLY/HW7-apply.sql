/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.

������� "05 - ��������� CROSS APPLY, PIVOT, UNPIVOT".

������� ����������� � �������������� ���� ������ WideWorldImporters.

����� �� ����� ������� ������:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
����� WideWorldImporters-Full.bak

�������� WideWorldImporters �� Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- ������� - �������� ������� ��� ��������� ��������� ���� ������.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. ��������� �������� ������, ������� � ���������� ������ ���������� 
��������� ������ �� ���������� ������� � ������� �������� � �������.
� ������� ������ ���� ������ (���� ������ ������), � �������� - �������.

�������� ����� � ID 2-6, ��� ��� ������������� Tailspin Toys.
��� ������� ����� �������� ��� ����� �������� ������ ���������.
��������, �������� �������� "Tailspin Toys (Gasport, NY)" - �� �������� ������ "Gasport, NY".
���� ������ ����� ������ dd.mm.yyyy, ��������, 25.12.2019.

������, ��� ������ ��������� ����������:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

SELECT pvt.InvoiceDate
	,pvt.[Jessie, ND]
	,pvt.[Sylvanite, MT]
	,pvt.[Gasport, NY]
	,pvt.[Peeples Valley, AZ]
	,pvt.[Medicine Lodge, KS]
FROM (
	SELECT [InvoiceDate] = FORMAT(a.InvoiceDate, 'dd.MM.yyyy')
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

-- �� ���� ��� ������� ���������� �� [InvoiceDate] ��� ������������, ������� ������� ���������� ����� ��� ������.

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
2. ��� ���� �������� � ������, � ������� ���� "Tailspin Toys"
������� ��� ������, ������� ���� � �������, � ����� �������.

������ ����������:
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
3. � ������� ����� (Application.Countries) ���� ���� � �������� ����� ������ � � ���������.
�������� ������� �� ������, �������� � �� ���� ���, 
����� � ���� � ����� ��� ���� �������� ���� ��������� ���.

������ ����������:
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
		,[IsoNumericCode] = CAST(IsoNumericCode AS NVARCHAR(3)) -- ���������� �����, ��� �� �������?
	FROM Application.Countries
	) AS x
unpivot(Code FOR IsoList IN (
			IsoAlpha3Code
			,IsoNumericCode
			)) AS pvt;

/*
4. �������� �� ������� ������� ��� ����� ������� ������, ������� �� �������.
� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� �������.
*/

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
