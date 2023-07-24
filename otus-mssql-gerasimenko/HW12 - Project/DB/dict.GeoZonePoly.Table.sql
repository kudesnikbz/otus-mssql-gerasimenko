USE [GDS2]
GO
/****** Object:  Table [dict].[GeoZonePoly]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dict].[GeoZonePoly](
	[id] [bigint] IDENTITY(0,1) NOT NULL,
	[GeoZone_id] [bigint] NOT NULL,
	[Priority] [int] NOT NULL,
	[Latitude] [decimal](10, 6) NOT NULL,
	[Longitude] [decimal](10, 6) NOT NULL,
	[RecordDate] [datetime2](7) NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
 CONSTRAINT [PK_DICTGEOZONEPOLY] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [archive].[GeoZonePoly_Archive])
)
GO
ALTER TABLE [dict].[GeoZonePoly] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
ALTER TABLE [dict].[GeoZonePoly] ADD  CONSTRAINT [DF_GeoZonePoly_ValidFrom]  DEFAULT (sysutcdatetime()) FOR [ValidFrom]
GO
ALTER TABLE [dict].[GeoZonePoly] ADD  CONSTRAINT [DF_GeoZonePoly_ValidTo]  DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999')) FOR [ValidTo]
GO
ALTER TABLE [dict].[GeoZonePoly]  WITH CHECK ADD  CONSTRAINT [GeoZonePoly_fk0] FOREIGN KEY([GeoZone_id])
REFERENCES [dict].[GeoZone] ([id])
GO
ALTER TABLE [dict].[GeoZonePoly] CHECK CONSTRAINT [GeoZonePoly_fk0]
GO
