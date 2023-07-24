USE [GDS2]
GO
/****** Object:  Table [int].[xml_Address]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [int].[xml_Address](
	[id] [int] IDENTITY(0,1) NOT NULL,
	[Uid] [nvarchar](50) NOT NULL,
	[Country] [nvarchar](150) NULL,
	[Region] [nvarchar](150) NULL,
	[City] [nvarchar](150) NULL,
	[Street] [nvarchar](150) NULL,
	[PLZ] [nvarchar](500) NULL,
	[FullName] [nvarchar](500) NULL,
	[SENDER] [varchar](150) NULL,
	[PROCESS_READ] [datetime2](7) NULL,
	[RecordDate] [datetime2](7) NULL,
	[RequestOrder_Id] [bigint] NULL,
	[Type] [nvarchar](150) NULL,
	[PROCESS_COMMENT] [varchar](250) NULL,
	[House] [nvarchar](50) NULL,
	[Room] [nvarchar](50) NULL,
	[PackNum] [varchar](50) NULL,
	[PackNum_READ] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [int].[xml_Address] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
