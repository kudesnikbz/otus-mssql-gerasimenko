/*
Экран приложения поделен на две части
В первой распологается основная(заголовки) информация по заявке.
*/
select
[RN] = a.id,
[Транзакция] = b.id,
[Номер документа] = b.ExternalCode,
[Владелец] = b.OwnerName,
[ДатаВремя Создания Заявки] = b.RequestDateTime,
[Клиент] = b.CustomerName,
[Приоритет] = b.PriorityCode,
[Статус] = b.RequestStatus,
[ДатаВремя Создания документа] = b.RecordDate
from Transactions as a
join [doc].[hdr_RequestCargoShipping] as b on a.id = b.Transaction_id
where ISNULL(b.RequestStatus, '') != 'COMPLETED'

CREATE NONCLUSTERED INDEX [NCI_RequestCargoShipping_Transaction_Status] ON [doc].[hdr_RequestCargoShipping]
(
	[Transaction_id] ASC,
	[RequestStatus] ASC
)

CREATE NONCLUSTERED INDEX [NCI_Transactions_CDt_PDt] ON [dbo].[Transactions] -- Понадобится для отчетов за период.
(
	[CreationDateTime] ASC,
	[ProcessDateTime] ASC
)

/*
На втором экране отображаются детали заявки
Выборка идет по нажатию в первом экране на заявку. Приложение получает @Transaction_id и делает выборку деталей информации.
*/
declare @Transaction_id int
select
[Отправитель] = dbt1.ShortName,
[Адрес отправления] = b.AddressDeparture,
[Получатель] = dbt2.ShortName,
[Адрес получателя] = b.AddressReceipt,
[Объём] = b.Volume,
[Вес] = b.Weight,
[Стоимость груза] = b.CostGoods,
[Дополнительные работы] = c.AdditiionalTypeService,
[Комментарий] = c.Comment
from Transactions as a
join [doc].[tbl_RequestCargoShipping] as b on a.id = b.Transaction_id
join dict.Debtors as dbt1 on b.Sender_id = dbt1.id
join dict.Debtors as dbt2 on b.Receiver_id = dbt2.id
left join [doc].[tbl_RequestAdditionalServices] as c on a.id = c.Transaction_id
													and b.id = c.[RowRequestCargoShipping]																							
where a.id = @Transaction_id

CREATE NONCLUSTERED INDEX [NCI_tRequestCargoShipping_Transaction_id] ON [doc].[tbl_RequestCargoShipping]
(
	[Transaction_id] ASC
)

CREATE NONCLUSTERED INDEX [NCI_RequestAdditionalServices_Transaction_RowRequest] ON [doc].[tbl_RequestAdditionalServices]
(
	[Transaction_id] ASC,
	[RowRequestCargoShipping] ASC
)