USE [GDS2]
GO
/****** Object:  Table [match].[Address]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [match].[Address](
	[id] [bigint] IDENTITY(0,1) NOT NULL,
	[SystemCode] [varchar](50) NULL,
	[TargetValue] [varchar](50) NULL,
	[LocalValue] [varchar](50) NULL,
	[RecordDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [match].[Address] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
