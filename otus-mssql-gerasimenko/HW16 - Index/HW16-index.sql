/*
����� ���������� ������� �� ��� �����
� ������ ������������� ��������(���������) ���������� �� ������.
*/
select
[RN] = a.id,
[����������] = b.id,
[����� ���������] = b.ExternalCode,
[��������] = b.OwnerName,
[��������� �������� ������] = b.RequestDateTime,
[������] = b.CustomerName,
[���������] = b.PriorityCode,
[������] = b.RequestStatus,
[��������� �������� ���������] = b.RecordDate
from Transactions as a
join [doc].[hdr_RequestCargoShipping] as b on a.id = b.Transaction_id
where ISNULL(b.RequestStatus, '') != 'COMPLETED'

CREATE NONCLUSTERED INDEX [NCI_RequestCargoShipping_Transaction_Status] ON [doc].[hdr_RequestCargoShipping]
(
	[Transaction_id] ASC,
	[RequestStatus] ASC
)

CREATE NONCLUSTERED INDEX [NCI_Transactions_CDt_PDt] ON [dbo].[Transactions] -- ����������� ��� ������� �� ������.
(
	[CreationDateTime] ASC,
	[ProcessDateTime] ASC
)

/*
�� ������ ������ ������������ ������ ������
������� ���� �� ������� � ������ ������ �� ������. ���������� �������� @Transaction_id � ������ ������� ������� ����������.
*/
declare @Transaction_id int
select
[�����������] = dbt1.ShortName,
[����� �����������] = b.AddressDeparture,
[����������] = dbt2.ShortName,
[����� ����������] = b.AddressReceipt,
[�����] = b.Volume,
[���] = b.Weight,
[��������� �����] = b.CostGoods,
[�������������� ������] = c.AdditiionalTypeService,
[�����������] = c.Comment
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