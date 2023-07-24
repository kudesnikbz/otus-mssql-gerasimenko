ALTER TABLE [doc].[hdr_RequestCargoShipping]  WITH CHECK ADD  CONSTRAINT [hdr_RequestCargoShipping_fk0] FOREIGN KEY([Transaction_id])
REFERENCES [dbo].[Transactions] ([id])
GO

ALTER TABLE [doc].[hdr_RequestCargoShipping] CHECK CONSTRAINT [hdr_RequestCargoShipping_fk0]
GO


ALTER TABLE [doc].[tbl_RequestAdditionalServices]  WITH CHECK ADD FOREIGN KEY([Transaction_id])
REFERENCES [dbo].[Transactions] ([id])
GO

ALTER TABLE [doc].[hdr_TaskCorgoShipping]  WITH CHECK ADD  CONSTRAINT [hdr_TaskCorgoShipping_fk0] FOREIGN KEY([Transaction_id])
REFERENCES [dbo].[Transactions] ([id])
GO

ALTER TABLE [doc].[hdr_TaskCorgoShipping] CHECK CONSTRAINT [hdr_TaskCorgoShipping_fk0]
GO


ALTER TABLE [doc].[tbl_RequestCargoShipping]  WITH CHECK ADD  CONSTRAINT [tbl_RequestCargoShipping_fk0] FOREIGN KEY([Transaction_id])
REFERENCES [dbo].[Transactions] ([id])
GO

ALTER TABLE [doc].[tbl_RequestCargoShipping] CHECK CONSTRAINT [tbl_RequestCargoShipping_fk0]
GO