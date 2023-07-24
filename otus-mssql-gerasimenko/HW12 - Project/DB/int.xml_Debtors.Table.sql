USE [GDS2]
GO
/****** Object:  Table [int].[xml_Debtors]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [int].[xml_Debtors](
	[id] [int] IDENTITY(0,1) NOT NULL,
	[Uid] [nvarchar](50) NOT NULL,
	[ShortName] [nvarchar](150) NULL,
	[Sys] [nvarchar](10) NULL,
	[DebtorCategory] [nvarchar](150) NULL,
	[FullName] [nvarchar](500) NULL,
	[Lock] [nvarchar](10) NULL,
	[TelefonNummer] [nvarchar](20) NULL,
	[EmailAdresse] [nvarchar](250) NULL,
	[File_id] [int] NULL,
	[Sender] [varchar](150) NULL,
	[PROCESS_READ] [datetime2](7) NULL,
	[RecordDate] [datetime2](7) NULL,
	[RequestOrder_Id] [bigint] NULL,
	[Type] [nvarchar](150) NULL,
	[PackNum] [varchar](50) NULL,
	[PackNum_READ] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [int].[xml_Debtors] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
