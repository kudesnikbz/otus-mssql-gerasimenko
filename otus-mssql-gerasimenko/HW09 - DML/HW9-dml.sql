/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

INSERT INTO [Sales].[Customers] (
      [CustomerName]
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy])
SELECT TOP (5)
      [CustomerName] + '_HW8'
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit] + 1000
      ,CAST(GETDATE()as date)
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
	  ,[LastEditedBy]
  FROM [WideWorldImporters].[Sales].[Customers] order by CustomerID desc 

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

delete [WideWorldImporters].[Sales].[Customers] where [CustomerID] = 1067

/*
3. Изменить одну запись, из добавленных через UPDATE
*/

update [WideWorldImporters].[Sales].[Customers]
set [CustomerName] = 'Jaroslav Fisar_HW8_3'
where [CustomerID] = 1066

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

select *
into #tmp4
from [Sales].[Customers] 
where CustomerID = 1065

update #tmp4
set CustomerName = 'Jibek Juniskyzy_HW8_4'

merge [Sales].[Customers] as tgt
using (select CustomerName, [BillToCustomerID], [CustomerCategoryID], [BuyingGroupID] ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID] ,[DeliveryMethodID] ,[DeliveryCityID] ,[PostalCityID] ,[CreditLimit] ,[AccountOpenedDate]
      ,[StandardDiscountPercentage] ,[IsStatementSent] ,[IsOnCreditHold] ,[PaymentDays] ,[PhoneNumber] ,[FaxNumber]
      ,[DeliveryRun] ,[RunPosition] ,[WebsiteURL] ,[DeliveryAddressLine1] ,[DeliveryAddressLine2] ,[DeliveryPostalCode]
      ,[DeliveryLocation] ,[PostalAddressLine1] ,[PostalAddressLine2] ,[PostalPostalCode] ,[LastEditedBy] from #tmp4) as src
on tgt.CustomerName = src.CustomerName
when matched
	then update set CreditLimit += 500
when not matched
	then insert ([CustomerName]
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy])
values (src.[CustomerName]
      ,src.[BillToCustomerID]
      ,src.[CustomerCategoryID]
      ,src.[BuyingGroupID]
      ,src.[PrimaryContactPersonID]
      ,src.[AlternateContactPersonID]
      ,src.[DeliveryMethodID]
      ,src.[DeliveryCityID]
      ,src.[PostalCityID]
      ,src.[CreditLimit]
      ,src.[AccountOpenedDate]
      ,src.[StandardDiscountPercentage]
      ,src.[IsStatementSent]
      ,src.[IsOnCreditHold]
      ,src.[PaymentDays]
      ,src.[PhoneNumber]
      ,src.[FaxNumber]
      ,src.[DeliveryRun]
      ,src.[RunPosition]
      ,src.[WebsiteURL]
      ,src.[DeliveryAddressLine1]
      ,src.[DeliveryAddressLine2]
      ,src.[DeliveryPostalCode]
      ,src.[DeliveryLocation]
      ,src.[PostalAddressLine1]
      ,src.[PostalAddressLine2]
      ,src.[PostalPostalCode]
      ,src.[LastEditedBy])
OUTPUT deleted.*, $action, inserted.*;

drop table #tmp4

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

--Выгрузка в файл
exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.InvoiceLines" out  "C:\1\InvoiceLines1.txt" -T -w -t, -S WIN-O34VUJI4S1K\OTUSDEV23'

--Загрузка из файла
create table dbo.TXT_TST  (
	 Col1 NVarChar(max)	,
	 Col2 Nvarchar(max)	,
	 Col3 Nvarchar(max)	,
	 Col4 int,
)

bulk insert dbo.TXT_TST
	from "C:\1\dataprim_Unicode.txt"
with (BATCHSIZE = 1000, 
	  DATAFILETYPE = 'widechar',
	  FIRSTROW = 2,
	  FIELDTERMINATOR = '\t',
	  ROWTERMINATOR = '\n',
	  KEEPNULLS,
	  TABLOCK)

select * from dbo.TXT_TST;

TRUNCATE TABLE dbo.TXT_TST;
--drop table dbo.TXT_TST