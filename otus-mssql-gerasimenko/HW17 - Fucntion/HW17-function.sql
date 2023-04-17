/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/

CREATE FUNCTION Sales.fn_MaxExtendedPriceCustomerID ()
RETURNS INT
AS
BEGIN
	DECLARE @RET INT

	SELECT TOP 1 @RET = a.CustomerID
	FROM Sales.Invoices AS a
	JOIN Sales.InvoiceLines AS b ON a.InvoiceID = b.InvoiceID
	GROUP BY a.CustomerID
		,a.InvoiceID
	ORDER BY SUM(b.ExtendedPrice) DESC

	RETURN @RET
END

SELECT Sales.fn_MaxExtendedPriceCustomerID()
go
/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
    Использовать таблицы :
    Sales.Customers
    Sales.Invoices
    Sales.InvoiceLines
*/

CREATE OR ALTER PROCEDURE Sales.proc_ExtendedPriceCustomerID (@CustomerID INT)
AS
BEGIN
	SELECT SUM(c.ExtendedPrice)
	FROM Sales.Customers AS a
	JOIN Sales.Invoices AS b ON a.CustomerID = b.CustomerID
	JOIN Sales.InvoiceLines AS c ON b.InvoiceID = c.InvoiceID
	WHERE 1 = 1
		AND a.CustomerID = @CustomerID
	GROUP BY a.CustomerID
END

EXEC Sales.proc_ExtendedPriceCustomerID @CustomerID = 834
go

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
--Решил немного вспомнить XML
--Процедура
  SQL Server Execution Times:
    CPU time = 32 ms,  elapsed time = 36 ms.

  SQL Server Execution Times:
    CPU time = 32 ms,  elapsed time = 36 ms.

--Функция
  SQL Server Execution Times:
	CPU time = 32 ms,  elapsed time = 37 ms.

--У процедуры есть полноценный план запроса, в функции он отсутствует, весь запрос в одном блоке.

*/



CREATE OR ALTER PROCEDURE Sales.proc_StatCustomerInvoices (
	@CustomerID INT
	,@StartDate DATE
	,@EndDate DATE = NULL
	)
AS
BEGIN
	--declare @CustomerID int = 1, @StartDate date = '2013-03-01', @EndDate date = '2013-04-01'
	SELECT a.CustomerID
		,a.CustomerName
		,b.InvoiceID
		,b.InvoiceDate
		,b.DeliveryInstructions
		,[Quantity] = SUM(c.Quantity)
		,[ExtendedPrice] = SUM(c.ExtendedPrice)
	FROM Sales.Customers AS a
	JOIN Sales.Invoices AS b ON a.CustomerID = b.CustomerID
	JOIN Sales.InvoiceLines AS c ON b.InvoiceID = c.InvoiceID
	WHERE a.CustomerID = @CustomerID
		AND InvoiceDate BETWEEN @StartDate
			AND ISNULL(@EndDate, CONVERT(DATE, GETDATE(), 112))
	GROUP BY a.CustomerID
		,a.CustomerName
		,b.InvoiceID
		,b.InvoiceDate
		,b.DeliveryInstructions
	ORDER BY InvoiceDate ASC
	FOR XML PATH('Invoices')
		,ROOT('Customer');
END

exec Sales.proc_StatCustomerInvoices
	 @CustomerID = 1
	,@StartDate = '2013-03-01'

CREATE OR ALTER FUNCTION Sales.fn_StatCustomerInvoices (
	@CustomerID INT
	,@StartDate DATE
	,@EndDate DATE = NULL
	)
RETURNS XML
AS BEGIN
	--declare @CustomerID int = 1, @StartDate date = '2013-03-01', @EndDate date = '2013-04-01'
	DECLARE @Data XML

	SELECT @Data = (
	SELECT a.CustomerID
		,a.CustomerName
		,b.InvoiceID
		,b.InvoiceDate
		,b.DeliveryInstructions
		,[Quantity] = SUM(c.Quantity)
		,[ExtendedPrice] = SUM(c.ExtendedPrice)
	FROM Sales.Customers AS a
	JOIN Sales.Invoices AS b ON a.CustomerID = b.CustomerID
	JOIN Sales.InvoiceLines AS c ON b.InvoiceID = c.InvoiceID
	WHERE a.CustomerID = @CustomerID
		AND InvoiceDate BETWEEN @StartDate
			AND ISNULL(@EndDate, CONVERT(DATE, GETDATE(), 112))
	GROUP BY a.CustomerID
		,a.CustomerName
		,b.InvoiceID
		,b.InvoiceDate
		,b.DeliveryInstructions
	ORDER BY InvoiceDate ASC
	FOR XML PATH('Invoices')
		,ROOT('Customer'))

	return @Data
END

SELECT [Res] = Sales.fn_StatCustomerInvoices(1, '2013-03-01', GETDATE())

SQL Server Execution Times:
   CPU time = 32 ms,  elapsed time = 37 ms.

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла.
*/

CREATE OR ALTER FUNCTION Sales.fn_ExtendedPriceCustomerID (
	@CustomerID int
)
RETURNS @Res TABLE(InvoiceID int, [SumExtendedPrice] decimal(10,2))
AS BEGIN

	INSERT INTO @Res(InvoiceID, [SumExtendedPrice])
	SELECT a.InvoiceID,
	[SumExtendedPrice] = SUM(b.ExtendedPrice)
	FROM Sales.Invoices AS a
	JOIN Sales.InvoiceLines AS b ON a.InvoiceID = b.InvoiceID
	WHERE a.CustomerID = @CustomerID
	GROUP BY a.InvoiceID
	
	return
END

SELECT a.CustomerID, b.InvoiceID, b.[SumExtendedPrice]
FROM Sales.Customers AS a
CROSS APPLY Sales.fn_ExtendedPriceCustomerID(a.CustomerID) as b

/*
Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему.
*/