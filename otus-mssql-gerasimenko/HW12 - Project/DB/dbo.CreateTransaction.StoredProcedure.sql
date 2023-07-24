USE [GDS2]
GO
/****** Object:  StoredProcedure [dbo].[CreateTransaction]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   procedure [dbo].[CreateTransaction]
(@TransactionType_id int,
@Transaction_id int out)
as begin

	declare @Rows table (Row_id int not NULL)
	
	begin try
		begin transaction

		insert into dbo.Transactions ([TransactionStatus], TransactionType_id)
		values (0, @TransactionType_id)

		select  @Transaction_id = @@IDENTITY
	
	commit tran
	end try
	begin catch
		if ERROR_NUMBER() = 1205
		if XACT_STATE() <> 0 rollback transaction; --имеет ли запрос активную пользовательскую транзакцию
		delete @Rows
	end catch;

end
GO
