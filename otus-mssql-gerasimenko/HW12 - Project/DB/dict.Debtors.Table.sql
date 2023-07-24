USE [GDS2]
GO
/****** Object:  Table [dict].[Debtors]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dict].[Debtors](
	[id] [bigint] IDENTITY(0,1) NOT NULL,
	[ShortName] [varchar](150) NOT NULL,
	[DebtorName] [varchar](255) NOT NULL,
	[IsSystem] [bit] NOT NULL,
	[DebtorCategory_id] [int] NOT NULL,
	[FullName] [varchar](255) NOT NULL,
	[IsLock] [bit] NOT NULL,
	[TelefonNummer] [varchar](20) NOT NULL,
	[EmailAdresse] [varchar](250) NOT NULL,
	[RecordDate] [datetime2](7) NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_DICTDEBTORS] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [AK_FullNameTelefonNummerEmailAdresse] UNIQUE NONCLUSTERED 
(
	[FullName] ASC,
	[TelefonNummer] ASC,
	[EmailAdresse] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [archive].[Debtors_Archive])
)
GO
ALTER TABLE [dict].[Debtors] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
ALTER TABLE [dict].[Debtors]  WITH CHECK ADD  CONSTRAINT [Debtors_fk0] FOREIGN KEY([DebtorCategory_id])
REFERENCES [dict].[DebtorCategorys] ([id])
GO
ALTER TABLE [dict].[Debtors] CHECK CONSTRAINT [Debtors_fk0]
GO
