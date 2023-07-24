USE [GDS2]
GO
/****** Object:  Table [dict].[Region]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dict].[Region](
	[id] [bigint] NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[ExternalName] [varchar](255) NOT NULL,
	[Country_id] [smallint] NULL,
	[RecordDate] [datetime2](7) NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
 CONSTRAINT [PK_DICTREGION] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [archive].[Region_Archive])
)
GO
ALTER TABLE [dict].[Region] ADD  CONSTRAINT [DF_Region_id]  DEFAULT (NEXT VALUE FOR [dict].[seq_Gis]) FOR [id]
GO
ALTER TABLE [dict].[Region] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
ALTER TABLE [dict].[Region] ADD  CONSTRAINT [DF_Region_ValidFrom]  DEFAULT (sysutcdatetime()) FOR [ValidFrom]
GO
ALTER TABLE [dict].[Region] ADD  CONSTRAINT [DF_Region_ValidTo]  DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999')) FOR [ValidTo]
GO
ALTER TABLE [dict].[Region]  WITH CHECK ADD  CONSTRAINT [Region_fk0] FOREIGN KEY([Country_id])
REFERENCES [dict].[Country] ([id])
GO
ALTER TABLE [dict].[Region] CHECK CONSTRAINT [Region_fk0]
GO
