USE [GDS2]
GO
/****** Object:  Table [dict].[Addresse]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dict].[Addresse](
	[id] [bigint] NOT NULL,
	[Street] [varchar](255) NOT NULL,
	[House] [varchar](50) NULL,
	[Room] [varchar](50) NULL,
	[PLZ] [varchar](255) NOT NULL,
	[Citie_id] [bigint] NOT NULL,
	[FullName] [varchar](255) NOT NULL,
	[Latitude] [decimal](10, 6) NULL,
	[Longitude] [decimal](10, 6) NULL,
	[GeoZone_id] [bigint] NULL,
	[RecordDate] [datetime] NULL,
	[SetGeocodeDate] [date] NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
 CONSTRAINT [PK_DICTADRESSE] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [archive].[Addresse_Archive])
)
GO
ALTER TABLE [dict].[Addresse] ADD  DEFAULT (NEXT VALUE FOR [dict].[seq_AdresseKod]) FOR [id]
GO
ALTER TABLE [dict].[Addresse] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
ALTER TABLE [dict].[Addresse] ADD  CONSTRAINT [DF_Addresse_ValidFrom]  DEFAULT (sysutcdatetime()) FOR [ValidFrom]
GO
ALTER TABLE [dict].[Addresse] ADD  CONSTRAINT [DF_Addresse_ValidTo]  DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999')) FOR [ValidTo]
GO
ALTER TABLE [dict].[Addresse]  WITH CHECK ADD  CONSTRAINT [Adresse_fk0] FOREIGN KEY([Citie_id])
REFERENCES [dict].[Cities] ([id])
GO
ALTER TABLE [dict].[Addresse] CHECK CONSTRAINT [Adresse_fk0]
GO
ALTER TABLE [dict].[Addresse]  WITH CHECK ADD  CONSTRAINT [Adresse_fk1] FOREIGN KEY([GeoZone_id])
REFERENCES [dict].[GeoZone] ([id])
GO
ALTER TABLE [dict].[Addresse] CHECK CONSTRAINT [Adresse_fk1]
GO
