USE [GDS2]
GO
/****** Object:  Table [doc].[hdr_Route]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [doc].[hdr_Route](
	[id] [bigint] IDENTITY(0,1) NOT NULL,
	[Transaction_id] [bigint] NOT NULL,
	[RouteName] [varchar](200) NOT NULL,
	[Transporter_id] [bigint] NOT NULL,
	[Vehisle_id] [bigint] NOT NULL,
	[Status] [varchar](150) NOT NULL,
	[RecordDate] [datetime2](7) NULL,
 CONSTRAINT [PK_HDR_ROUTE] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [doc].[hdr_Route] ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
ALTER TABLE [doc].[hdr_Route]  WITH CHECK ADD  CONSTRAINT [hdr_Route_fk0] FOREIGN KEY([Transporter_id])
REFERENCES [dict].[Driver] ([id])
GO
ALTER TABLE [doc].[hdr_Route] CHECK CONSTRAINT [hdr_Route_fk0]
GO
ALTER TABLE [doc].[hdr_Route]  WITH CHECK ADD  CONSTRAINT [hdr_Route_fk1] FOREIGN KEY([Vehisle_id])
REFERENCES [dict].[Vehisle] ([id])
GO
ALTER TABLE [doc].[hdr_Route] CHECK CONSTRAINT [hdr_Route_fk1]
GO
