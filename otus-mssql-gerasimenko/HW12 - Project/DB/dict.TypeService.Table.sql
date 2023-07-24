USE [GDS2]
GO
/****** Object:  Table [dict].[TypeService]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dict].[TypeService](
	[id] [int] IDENTITY(0,1) NOT NULL,
	[Name] [varchar](250) NULL,
	[Cost] [decimal](10, 2) NULL,
	[Quantity] [decimal](10, 2) NULL,
	[RecordDate] [datetime2](7) NULL,
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
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [archive].[TypeService_Archive])
)
GO
ALTER TABLE [dict].[TypeService] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
ALTER TABLE [dict].[TypeService] ADD  CONSTRAINT [DF_TypeService_ValidFrom]  DEFAULT (sysutcdatetime()) FOR [ValidFrom]
GO
ALTER TABLE [dict].[TypeService] ADD  CONSTRAINT [DF_TypeService_ValidTo]  DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999')) FOR [ValidTo]
GO
