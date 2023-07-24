USE [GDS2]
GO
/****** Object:  Table [dbo].[Structures]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Structures](
	[id] [int] IDENTITY(0,1) NOT NULL,
	[Name] [varchar](500) NULL,
	[IsActive] [bit] NULL,
	[Priority] [int] NULL,
	[RecordDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Structures] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
