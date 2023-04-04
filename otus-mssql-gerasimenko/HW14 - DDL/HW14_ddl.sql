/*
Начало проектной работы. 
Создание таблиц и представлений для своего проекта.

Нужно написать операторы DDL для создания БД вашего проекта:
1. Создать базу данных.
2. 3-4 основные таблицы для своего проекта. 
3. Первичные и внешние ключи для всех созданных таблиц.
4. 1-2 индекса на таблицы.
5. Наложите по одному ограничению в каждой таблице на ввод данных.

Обязательно (если еще нет) должно быть описание предметной области.

База данных экспресс-доставки по городу.
Возможно в будущем доставка в регионы.
*/
CREATE DATABASE [Delivery_1]  
 ON  PRIMARY 
( NAME = N'Delivery_1', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.OTUSDEV23\MSSQL\DATA\Delivery_1.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Delivery_1_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.OTUSDEV23\MSSQL\DATA\Delivery_1_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 --WITH CATALOG_COLLATION = DATABASE_DEFAULT
 COLLATE SQL_Latin1_General_CP1251_CI_AS
GO

--Схема документов
CREATE SCHEMA [doc]
GO

--Схема справочников
CREATE SCHEMA [dict]
GO

--Категории клиентов, владельцев
CREATE TABLE [dict].[DebtorCategorys](
	[id] [int] NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[ExternalCode] [varchar](255) NOT NULL,
	[RecordDate] [datetime2](7) NULL,
 CONSTRAINT [PK_DICTDEBTORCATEGORYS] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dict].[DebtorCategorys] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO

--Справочник клиентов
CREATE TABLE [dict].[Debtors](
	[id] [int] NOT NULL,
	[ShortName] [varchar](150) NOT NULL,
	[DebtorName] [varchar](255) NOT NULL,
	[IsSystem] [bit] NOT NULL,
	[DebtorCategory_id] [int] NOT NULL,
	[FullName] [varchar](255) NOT NULL,
	[IsLock] [bit] NOT NULL,
	[TelefonNummer] [int] NOT NULL,
	[EmailAdresse] [varchar](250) NOT NULL,
	[RecordDate] [datetime2](7) NULL,
 CONSTRAINT UQ_FullNameTelefonEmail UNIQUE(FullName, TelefonNummer, EmailAdresse),
 CONSTRAINT [PK_DICTDEBTORS_NEW] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dict].[Debtors] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO

ALTER TABLE [dict].[Debtors] ADD  DEFAULT (0) FOR [IsSystem]
GO

ALTER TABLE [dict].[Debtors]  WITH CHECK ADD  CONSTRAINT [Debtors_fk0] FOREIGN KEY([DebtorCategory_id])
REFERENCES [dict].[DebtorCategorys] ([id])
GO

ALTER TABLE [dict].[Debtors] CHECK CONSTRAINT [Debtors_fk0]
GO

--Таблица транзакций заголовков документов
CREATE TABLE [dbo].[Transactions](
	[id] [int] NOT NULL,
	[CreationDateTime] [datetime2](7) NOT NULL,
	[ProcessDateTime] [datetime2](7) NULL,
	[TransactionStatus] [bit] NOT NULL,
	[ParentTransaction_id] [int] NOT NULL,
 CONSTRAINT [PK_TRANSACTIONS] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Transactions] ADD  DEFAULT (getdate()) FOR [CreationDateTime]
GO

ALTER TABLE [dbo].[Transactions] ADD  DEFAULT (0) FOR [TransactionStatus]
GO

CREATE NONCLUSTERED INDEX [NCI_Transactions_CDt_PDt] ON [dbo].[Transactions]
(
	[CreationDateTime] ASC,
	[ProcessDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

-- Заголовок документа заявки на доставку
CREATE TABLE [doc].[hdr_RequestCargoShipping](
	[id] [int] NOT NULL,
	[Transaction_id] [int] NOT NULL,
	[OwnerName] [varchar](250) NOT NULL,
	[Owner_id] [int] NOT NULL,
	[TypeShipping_id] [int] NOT NULL,
	[RequestDateTime] [datetime] NOT NULL,
	[ExternalCode] [varchar](250) NOT NULL,
	[CustomerName] [varchar](250) NOT NULL,
	[Customer_id] [int] NOT NULL,
	[PriorityCode] [int] NOT NULL,
	[RequestStatus] [varchar](255) NULL,
	[RecordDate] [datetime2](7) NULL,
 CONSTRAINT [PK_HDR_REQUESTCARGOSHIPPING] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [doc].[hdr_RequestCargoShipping] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO

ALTER TABLE [doc].[hdr_RequestCargoShipping]  WITH CHECK ADD  CONSTRAINT [hdr_RequestCargoShipping_fk0] FOREIGN KEY([Transaction_id])
REFERENCES [dbo].[Transactions] ([id])
GO

ALTER TABLE [doc].[hdr_RequestCargoShipping] CHECK CONSTRAINT [hdr_RequestCargoShipping_fk0]
GO

ALTER TABLE [doc].[hdr_RequestCargoShipping]  WITH CHECK ADD  CONSTRAINT [hdr_RequestCargoShipping_fk1] FOREIGN KEY([Owner_id])
REFERENCES [dict].[Debtors] ([id])
GO

ALTER TABLE [doc].[hdr_RequestCargoShipping] CHECK CONSTRAINT [hdr_RequestCargoShipping_fk1]
GO

ALTER TABLE [doc].[hdr_RequestCargoShipping]  WITH CHECK ADD  CONSTRAINT [hdr_RequestCargoShipping_fk2] FOREIGN KEY([Customer_id])
REFERENCES [dict].[Debtors] ([id])
GO

ALTER TABLE [doc].[hdr_RequestCargoShipping] CHECK CONSTRAINT [hdr_RequestCargoShipping_fk2]
GO

CREATE NONCLUSTERED INDEX [NCI_hRequestCargoShipping_Transaction_id] ON [doc].[hdr_RequestCargoShipping]
(
	[Transaction_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


-- Табличная часть документа заявки на доставку
CREATE TABLE [doc].[tbl_RequestCargoShipping](
	[id] [int] NOT NULL,
	[Transaction_id] [int] NOT NULL,
	[Sender_id] [int] NOT NULL,
	[AddressDeparture] [varchar](255) NOT NULL,
	[Receiver_id] [int] NOT NULL,
	[AddressReceipt] [varchar](255) NOT NULL,
	[Volume] [decimal](25, 2) NULL,
	[Weight] [decimal](25, 2) NULL,
	[CostGoods] [decimal](25, 2) NULL,
	[RecordDate] [datetime2](7) NULL,
 CONSTRAINT [PK_TBL_REQUESTCARGOSHIPPING] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [doc].[tbl_RequestCargoShipping] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO

ALTER TABLE [doc].[tbl_RequestCargoShipping]  WITH CHECK ADD  CONSTRAINT [tbl_RequestCargoShipping_fk0] FOREIGN KEY([Transaction_id])
REFERENCES [dbo].[Transactions] ([id])
GO

ALTER TABLE [doc].[tbl_RequestCargoShipping] CHECK CONSTRAINT [tbl_RequestCargoShipping_fk0]
GO

ALTER TABLE [doc].[tbl_RequestCargoShipping]  WITH CHECK ADD  CONSTRAINT [tbl_RequestCargoShipping_fk2] FOREIGN KEY([Receiver_id])
REFERENCES [dict].[Debtors] ([id])
GO

ALTER TABLE [doc].[tbl_RequestCargoShipping] CHECK CONSTRAINT [tbl_RequestCargoShipping_fk2]
GO

CREATE NONCLUSTERED INDEX [NCI_tRequestCargoShipping_Transaction_id] ON [doc].[tbl_RequestCargoShipping]
(
	[Transaction_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
