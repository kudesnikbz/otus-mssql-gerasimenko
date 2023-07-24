USE [GDS2]
GO
/****** Object:  Table [doc].[hdr_TaskCorgoShipping]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [doc].[hdr_TaskCorgoShipping](
	[id] [bigint] IDENTITY(0,1) NOT NULL,
	[Transaction_id] [bigint] NOT NULL,
	[Sender_id] [bigint] NOT NULL,
	[AdressDeparture_id] [bigint] NOT NULL,
	[Volume] [decimal](10, 2) NOT NULL,
	[Weight] [decimal](10, 2) NOT NULL,
	[CostGoods] [decimal](10, 2) NOT NULL,
	[CountCargo] [int] NOT NULL,
	[Receiver_id] [bigint] NOT NULL,
	[AddressReceipt_id] [bigint] NOT NULL,
	[TaskDate] [datetime2](7) NOT NULL,
	[FinishDate] [datetime2](7) NOT NULL,
	[RecordDate] [datetime2](7) NULL,
 CONSTRAINT [PK_HDR_TASKCORGOSHIPPING] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [doc].[hdr_TaskCorgoShipping] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
ALTER TABLE [doc].[hdr_TaskCorgoShipping]  WITH CHECK ADD  CONSTRAINT [hdr_TaskCorgoShipping_fk1] FOREIGN KEY([AdressDeparture_id])
REFERENCES [dict].[Addresse] ([id])
GO
ALTER TABLE [doc].[hdr_TaskCorgoShipping] CHECK CONSTRAINT [hdr_TaskCorgoShipping_fk1]
GO
ALTER TABLE [doc].[hdr_TaskCorgoShipping]  WITH CHECK ADD  CONSTRAINT [hdr_TaskCorgoShipping_fk2] FOREIGN KEY([AddressReceipt_id])
REFERENCES [dict].[Addresse] ([id])
GO
ALTER TABLE [doc].[hdr_TaskCorgoShipping] CHECK CONSTRAINT [hdr_TaskCorgoShipping_fk2]
GO
