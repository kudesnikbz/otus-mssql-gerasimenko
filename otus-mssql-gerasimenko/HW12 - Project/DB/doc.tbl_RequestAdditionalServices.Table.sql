USE [GDS2]
GO
/****** Object:  Table [doc].[tbl_RequestAdditionalServices]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [doc].[tbl_RequestAdditionalServices](
	[id] [bigint] IDENTITY(0,1) NOT NULL,
	[Transaction_id] [bigint] NULL,
	[RowRequestCargoShipping] [bigint] NULL,
	[AdditiionalTypeService_id] [int] NULL,
	[AdditiionalTypeService] [varchar](250) NULL,
	[Comment] [varchar](300) NULL,
	[RecordDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [NCI_RequestAdditionalServices_Transaction_RowRequest]    Script Date: 24.07.2023 19:48:20 ******/
CREATE NONCLUSTERED INDEX [NCI_RequestAdditionalServices_Transaction_RowRequest] ON [doc].[tbl_RequestAdditionalServices]
(
	[Transaction_id] ASC,
	[RowRequestCargoShipping] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [doc].[tbl_RequestAdditionalServices] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
ALTER TABLE [doc].[tbl_RequestAdditionalServices]  WITH CHECK ADD FOREIGN KEY([AdditiionalTypeService_id])
REFERENCES [dict].[TypeService] ([id])
GO
