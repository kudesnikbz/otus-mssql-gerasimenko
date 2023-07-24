USE [GDS2]
GO
/****** Object:  Table [dbo].[Transactions]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Transactions](
	[id] [bigint] NOT NULL,
	[CreationDateTime] [datetime2](7) NOT NULL,
	[ProcessDateTime] [datetime2](7) NULL,
	[TransactionStatus] [bit] NOT NULL,
	[ParentTransaction_id] [bigint] NULL,
	[TransactionType_id] [int] NOT NULL
) ON [psTransactions]([CreationDateTime])
GO
/****** Object:  Index [cix_Transaction_id_CDT]    Script Date: 24.07.2023 19:48:20 ******/
CREATE CLUSTERED INDEX [cix_Transaction_id_CDT] ON [dbo].[Transactions]
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [psTransactions]([CreationDateTime])
GO
/****** Object:  Index [NCI_Transactions_CDt_PDt]    Script Date: 24.07.2023 19:48:20 ******/
CREATE NONCLUSTERED INDEX [NCI_Transactions_CDt_PDt] ON [dbo].[Transactions]
(
	[CreationDateTime] ASC,
	[ProcessDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Transactions] ADD  CONSTRAINT [DF_Transaction_id]  DEFAULT (NEXT VALUE FOR [dbo].[seq_Transactions]) FOR [id]
GO
ALTER TABLE [dbo].[Transactions] ADD  DEFAULT (getdate()) FOR [CreationDateTime]
GO
ALTER TABLE [dbo].[Transactions]  WITH CHECK ADD  CONSTRAINT [FK_Transactions_TransactionType_id] FOREIGN KEY([TransactionType_id])
REFERENCES [dict].[TransactionTypes] ([id])
GO
ALTER TABLE [dbo].[Transactions] CHECK CONSTRAINT [FK_Transactions_TransactionType_id]
GO
