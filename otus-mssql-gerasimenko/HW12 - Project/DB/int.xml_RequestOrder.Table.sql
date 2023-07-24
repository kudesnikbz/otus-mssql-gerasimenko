USE [GDS2]
GO
/****** Object:  Table [int].[xml_RequestOrder]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [int].[xml_RequestOrder](
	[id] [int] IDENTITY(0,1) NOT NULL,
	[Uid] [nvarchar](50) NOT NULL,
	[RequestExternalCode] [nvarchar](150) NULL,
	[OrderDate] [datetime] NULL,
	[Sender] [varchar](150) NULL,
	[PROCESS_READ] [varchar](150) NULL,
	[RecordDate] [datetime2](7) NULL,
	[RequestOrder_Id] [bigint] NULL,
	[PackNum] [varchar](50) NULL,
	[PackNum_READ] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [int].[xml_RequestOrder] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
