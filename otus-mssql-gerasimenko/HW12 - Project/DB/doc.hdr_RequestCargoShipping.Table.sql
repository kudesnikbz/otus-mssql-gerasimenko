USE [GDS2]
GO
/****** Object:  Table [doc].[hdr_RequestCargoShipping]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [doc].[hdr_RequestCargoShipping](
	[id] [bigint] IDENTITY(0,1) NOT NULL,
	[Transaction_id] [bigint] NOT NULL,
	[OwnerName] [varchar](250) NOT NULL,
	[Owner_id] [bigint] NOT NULL,
	[TypeShipping] [varchar](50) NULL,
	[RequestDateTime] [datetime] NOT NULL,
	[ExternalCode] [varchar](250) NOT NULL,
	[CustomerName] [varchar](250) NOT NULL,
	[Customer_id] [bigint] NOT NULL,
	[PriorityCode] [int] NOT NULL,
	[RequestStatus] [varchar](255) NULL,
	[RecordDate] [datetime2](7) NULL,
 CONSTRAINT [PK_HDR_REQUESTCARGOSHIPPING] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [NCI_RequestCargoShipping_Transaction_Status]    Script Date: 24.07.2023 19:48:20 ******/
CREATE NONCLUSTERED INDEX [NCI_RequestCargoShipping_Transaction_Status] ON [doc].[hdr_RequestCargoShipping]
(
	[Transaction_id] ASC,
	[RequestStatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [doc].[hdr_RequestCargoShipping] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
ALTER TABLE [doc].[hdr_RequestCargoShipping]  WITH CHECK ADD  CONSTRAINT [hdr_RequestCargoShipping_fk1_Debtors] FOREIGN KEY([Owner_id])
REFERENCES [dict].[Debtors] ([id])
GO
ALTER TABLE [doc].[hdr_RequestCargoShipping] CHECK CONSTRAINT [hdr_RequestCargoShipping_fk1_Debtors]
GO
ALTER TABLE [doc].[hdr_RequestCargoShipping]  WITH CHECK ADD  CONSTRAINT [hdr_RequestCargoShipping_fk2_Debtors] FOREIGN KEY([Customer_id])
REFERENCES [dict].[Debtors] ([id])
GO
ALTER TABLE [doc].[hdr_RequestCargoShipping] CHECK CONSTRAINT [hdr_RequestCargoShipping_fk2_Debtors]
GO
