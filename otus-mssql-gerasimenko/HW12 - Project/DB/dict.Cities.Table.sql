USE [GDS2]
GO
/****** Object:  Table [dict].[Cities]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dict].[Cities](
	[id] [bigint] NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[Region_id] [bigint] NULL,
	[Country_id] [smallint] NOT NULL,
	[RecordDate] [datetime2](7) NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
 CONSTRAINT [PK_DICTCITIES] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [archive].[Cities_Archive])
)
GO
ALTER TABLE [dict].[Cities] ADD  CONSTRAINT [DF_Citie_id]  DEFAULT (NEXT VALUE FOR [dict].[seq_Gis]) FOR [id]
GO
ALTER TABLE [dict].[Cities] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
ALTER TABLE [dict].[Cities] ADD  CONSTRAINT [DF_Cities_ValidFrom]  DEFAULT (sysutcdatetime()) FOR [ValidFrom]
GO
ALTER TABLE [dict].[Cities] ADD  CONSTRAINT [DF_Cities_ValidTo]  DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999')) FOR [ValidTo]
GO
ALTER TABLE [dict].[Cities]  WITH CHECK ADD  CONSTRAINT [Cities_fk0] FOREIGN KEY([Region_id])
REFERENCES [dict].[Region] ([id])
GO
ALTER TABLE [dict].[Cities] CHECK CONSTRAINT [Cities_fk0]
GO
ALTER TABLE [dict].[Cities]  WITH CHECK ADD  CONSTRAINT [dictCities_fk1] FOREIGN KEY([Country_id])
REFERENCES [dict].[Country] ([id])
GO
ALTER TABLE [dict].[Cities] CHECK CONSTRAINT [dictCities_fk1]
GO
