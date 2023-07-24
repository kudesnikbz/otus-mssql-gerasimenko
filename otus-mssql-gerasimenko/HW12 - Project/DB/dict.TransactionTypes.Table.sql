USE [GDS2]
GO
/****** Object:  Table [dict].[TransactionTypes]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dict].[TransactionTypes](
	[id] [int] IDENTITY(0,1) NOT NULL,
	[TransactionName] [varchar](150) NULL,
	[ProcedureName] [varchar](250) NULL,
	[Desc] [varchar](250) NULL,
	[RecordDate] [datetime] NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [archive].[TransactionTypes_Archive])
)
GO
ALTER TABLE [dict].[TransactionTypes] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
ALTER TABLE [dict].[TransactionTypes] ADD  CONSTRAINT [DF_TransactionTypes_ValidFrom]  DEFAULT (sysutcdatetime()) FOR [ValidFrom]
GO
ALTER TABLE [dict].[TransactionTypes] ADD  CONSTRAINT [DF_TransactionTypes_ValidTo]  DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999')) FOR [ValidTo]
GO
