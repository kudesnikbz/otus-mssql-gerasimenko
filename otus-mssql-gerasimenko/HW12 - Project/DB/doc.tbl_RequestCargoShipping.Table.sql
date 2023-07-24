USE [GDS2]
GO
/****** Object:  Table [doc].[tbl_RequestCargoShipping]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [doc].[tbl_RequestCargoShipping](
	[id] [bigint] NOT NULL,
	[Transaction_id] [bigint] NOT NULL,
	[Sender_id] [bigint] NOT NULL,
	[AddressDeparture] [varchar](255) NOT NULL,
	[Receiver_id] [bigint] NOT NULL,
	[AddressReceipt] [varchar](255) NOT NULL,
	[Volume] [decimal](25, 2) NOT NULL,
	[Weight] [decimal](25, 2) NOT NULL,
	[CostGoods] [decimal](25, 2) NOT NULL,
	[RecordDate] [datetime2](7) NULL,
 CONSTRAINT [PK_TBL_REQUESTCARGOSHIPPING] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [NCI_tRequestCargoShipping_Transaction_id]    Script Date: 24.07.2023 19:48:20 ******/
CREATE NONCLUSTERED INDEX [NCI_tRequestCargoShipping_Transaction_id] ON [doc].[tbl_RequestCargoShipping]
(
	[Transaction_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [doc].[tbl_RequestCargoShipping] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
ALTER TABLE [doc].[tbl_RequestCargoShipping]  WITH CHECK ADD  CONSTRAINT [tbl_RequestCargoShipping_fk1_Debtors] FOREIGN KEY([Receiver_id])
REFERENCES [dict].[Debtors] ([id])
GO
ALTER TABLE [doc].[tbl_RequestCargoShipping] CHECK CONSTRAINT [tbl_RequestCargoShipping_fk1_Debtors]
GO
