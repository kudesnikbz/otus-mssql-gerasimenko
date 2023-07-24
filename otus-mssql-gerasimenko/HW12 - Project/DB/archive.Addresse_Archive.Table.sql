USE [GDS2]
GO
/****** Object:  Table [archive].[Addresse_Archive]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [archive].[Addresse_Archive](
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
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_Addresse_Archive]    Script Date: 24.07.2023 19:48:20 ******/
CREATE CLUSTERED INDEX [ix_Addresse_Archive] ON [archive].[Addresse_Archive]
(
	[ValidTo] ASC,
	[ValidFrom] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
