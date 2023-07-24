USE [GDS2]
GO
/****** Object:  Table [archive].[Vehisle_Archive]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [archive].[Vehisle_Archive](
	[id] [bigint] NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[VIN] [varchar](255) NOT NULL,
	[Type] [varchar](100) NOT NULL,
	[RegNummer] [varchar](150) NOT NULL,
	[Model] [varchar](150) NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_Vehisle_Archive]    Script Date: 24.07.2023 19:48:20 ******/
CREATE CLUSTERED INDEX [ix_Vehisle_Archive] ON [archive].[Vehisle_Archive]
(
	[ValidTo] ASC,
	[ValidFrom] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
