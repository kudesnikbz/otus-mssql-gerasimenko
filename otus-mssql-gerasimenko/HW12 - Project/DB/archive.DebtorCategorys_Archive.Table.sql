USE [GDS2]
GO
/****** Object:  Table [archive].[DebtorCategorys_Archive]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [archive].[DebtorCategorys_Archive](
	[id] [int] NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[ExternalCode] [varchar](255) NOT NULL,
	[RecordDate] [datetime2](7) NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_DebtorCategorys_Archive]    Script Date: 24.07.2023 19:48:20 ******/
CREATE CLUSTERED INDEX [ix_DebtorCategorys_Archive] ON [archive].[DebtorCategorys_Archive]
(
	[ValidTo] ASC,
	[ValidFrom] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
