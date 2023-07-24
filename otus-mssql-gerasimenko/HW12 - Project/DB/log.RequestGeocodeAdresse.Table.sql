USE [GDS2]
GO
/****** Object:  Table [log].[RequestGeocodeAdresse]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [log].[RequestGeocodeAdresse](
	[id] [bigint] IDENTITY(0,1) NOT NULL,
	[name] [varchar](250) NULL,
	[description] [varchar](500) NULL,
	[Latitude] [varchar](10) NULL,
	[Longitude] [varchar](10) NULL,
	[RecordDate] [datetime2](7) NULL,
	[Response] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [log].[RequestGeocodeAdresse] ADD  CONSTRAINT [DF_log_RequestGeocodeAdresse_RecordDate]  DEFAULT (getdate()) FOR [RecordDate]
GO
