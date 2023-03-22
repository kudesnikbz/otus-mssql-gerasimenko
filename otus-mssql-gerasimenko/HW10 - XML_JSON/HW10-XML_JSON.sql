/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/
--var1
-- Переменная, в которую считаем XML-файл
DECLARE @xmlDocument XML;

-- Считываем XML-файл в переменную
SELECT @xmlDocument = BulkColumn
FROM OPENROWSET
(BULK 'Z:\OTUS_HW\StockItems.xml', 
 SINGLE_CLOB)
AS data;

DECLARE @docHandle INT;
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument;

merge Warehouse.StockItems as tgt
using (
	SELECT 
		[StockItemName],
		[SupplierID],
		[UnitPackageID],
		[OuterPackageID],
		[QuantityPerOuter],
		[TypicalWeightPerUnit],
		[LeadTimeDays],
		[IsChillerStock],
		[TaxRate],
		[UnitPrice]
	FROM OPENXML(@docHandle, N'/StockItems/Item')
	WITH ( 
		[StockItemName] NVARCHAR(50)  '@Name',
		[SupplierID] INT 'SupplierID',
		[UnitPackageID] INT 'Package/UnitPackageID',
		[OuterPackageID] INT 'Package/OuterPackageID',
		[QuantityPerOuter] INT 'Package/QuantityPerOuter',
		[TypicalWeightPerUnit] DECIMAL(25,6) 'Package/TypicalWeightPerUnit',
		[LeadTimeDays] INT 'LeadTimeDays',
		[IsChillerStock] INT 'IsChillerStock',
		[TaxRate] DECIMAL(25,6) 'TaxRate',
		[UnitPrice] DECIMAL(25,6) 'UnitPrice'
		)
	) as src
on tgt.StockItemName = src.StockItemName
when matched
	then update 
		set tgt.[SupplierID] =src.[SupplierID]
when not matched
	then insert ([StockItemName],
				[SupplierID],
				[UnitPackageID],
				[OuterPackageID],
				[QuantityPerOuter],
				[TypicalWeightPerUnit],
				[LeadTimeDays],
				[IsChillerStock],
				[TaxRate],
				[UnitPrice],
				[LastEditedBy])
values (src.[StockItemName],
		src.[SupplierID],
		src.[UnitPackageID],
		src.[OuterPackageID],
		src.[QuantityPerOuter],
		src.[TypicalWeightPerUnit],
		src.[LeadTimeDays],
		src.[IsChillerStock],
		src.[TaxRate],
		src.[UnitPrice],
		1)
OUTPUT deleted.*, $action, inserted.*;

-- Надо удалить handle
EXEC sp_xml_removedocument @docHandle;


--var2
-- Переменная, в которую считаем XML-файл
DECLARE @xmlDocument2 XML;

-- Считываем XML-файл в переменную
SELECT @xmlDocument2 = BulkColumn
FROM OPENROWSET
(BULK 'Z:\OTUS_HW\StockItems.xml', 
 SINGLE_CLOB)
AS data;

select @xmlDocument2.query('/StockItems/*')

MERGE Warehouse.StockItems AS tgt
USING (
	SELECT [StockItemName] = a.item.value('(@Name)[1]', 'NVARCHAR(50)')
		,[SupplierID] = item.value('(SupplierID)[1]', 'INT')
		,[UnitPackageID] = item.value('(Package/UnitPackageID)[1]', 'INT')
		,[OuterPackageID] = item.value('(Package/OuterPackageID)[1]', 'INT')
		,[QuantityPerOuter] = item.value('(Package/QuantityPerOuter)[1]', 'INT')
		,[TypicalWeightPerUnit] = item.value('(Package/TypicalWeightPerUnit)[1]', 'DECIMAL(25,6)')
		,[LeadTimeDays] = item.value('(LeadTimeDays)[1]', 'INT')
		,[IsChillerStock] = item.value('(IsChillerStock)[1]', 'INT')
		,[TaxRate] = item.value('(TaxRate[1])', 'DECIMAL(25,6)')
		,[UnitPrice] = item.value('(UnitPrice)[1]', 'DECIMAL(25,6)')
	FROM @xmlDocument.nodes('/StockItems/Item') AS a(item)
	) AS src
	ON tgt.StockItemName = src.StockItemName
WHEN MATCHED
	THEN
		UPDATE
		SET tgt.[SupplierID] = src.[SupplierID]
WHEN NOT MATCHED
	THEN
		INSERT (
			[StockItemName]
			,[SupplierID]
			,[UnitPackageID]
			,[OuterPackageID]
			,[QuantityPerOuter]
			,[TypicalWeightPerUnit]
			,[LeadTimeDays]
			,[IsChillerStock]
			,[TaxRate]
			,[UnitPrice]
			,[LastEditedBy]
			)
		VALUES (
			src.[StockItemName]
			,src.[SupplierID]
			,src.[UnitPackageID]
			,src.[OuterPackageID]
			,src.[QuantityPerOuter]
			,src.[TypicalWeightPerUnit]
			,src.[LeadTimeDays]
			,src.[IsChillerStock]
			,src.[TaxRate]
			,src.[UnitPrice]
			,1
			)
OUTPUT deleted.*,$ACTION,inserted.*;

/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

SELECT [@Name] = a.StockItemName
	,a.SupplierID
	,[Package/UnitPackageID] = a.UnitPackageID
	,[Package/OuterPackageID] = a.OuterPackageID
	,[Package/QuantityPerOuter] = a.QuantityPerOuter
	,[Package/TypicalWeightPerUnit] = a.TypicalWeightPerUnit
	,a.LeadTimeDays
	,a.IsChillerStock
	,a.TaxRate
	,a.UnitPrice
FROM Warehouse.StockItems AS a
FOR XML PATH('Item'),ROOT('StockItems');

/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

SELECT StockItemID
	,StockItemName
	,[CountryOfManufacture] = JSON_VALUE(CustomFields, '$.CountryOfManufacture')
	,[FirstTag] = JSON_VALUE(CustomFields, '$.Tags[0]')
FROM Warehouse.StockItems

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/


SELECT a.StockItemID
	,a.StockItemName
	--,[FirstTag] = JSON_VALUE(a.CustomFields, '$.Tags[0]')
	--,[Tags] = JSON_QUERY(a.CustomFields,'$.Tags')
	--,j.VALUE
FROM Warehouse.StockItems as a
CROSS APPLY OPENJSON(CustomFields,'$.Tags') as j
WHERE j.VALUE = 'Vintage'

SELECT a.StockItemID
	,a.StockItemName
	,[Tags] = STRING_AGG(j2.VALUE, ',')
FROM Warehouse.StockItems AS a
CROSS APPLY OPENJSON(CustomFields, '$.Tags') AS j
CROSS APPLY OPENJSON(CustomFields, '$.Tags') AS j2
WHERE j.VALUE = 'Vintage'
GROUP BY a.StockItemID
	,a.StockItemName
