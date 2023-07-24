USE [GDS2]
GO
/****** Object:  StoredProcedure [int].[GetIntegrationData]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [int].[GetIntegrationData]
(
	@SystemCode varchar(20) = 'Site',
	@Error varchar(200) = NULL output
) as begin
	set nocount on;

	declare @DOCNUMs table (
	RowID varchar(200) not NULL, 
	DOCNUM varchar(50) not NULL
	)
	declare @StructureName varchar(200), @RowCount int
	
	set @Error = NULL

	declare K cursor local fast_forward for
	select [Name] from Structures with (nolock)
	where isnull(IsActive, 0) = 1
	order by
		isnull([Priority], 0) desc
		
	open K
	fetch next from K into @StructureName
	while @@fetch_status = 0 begin				 

		set @RowCount = NULL
		exec int.IntegrationByStructure
				@SenderCode = @SystemCode,
				@StructureName = @StructureName,
				@Error = @Error output,
				@PacketRows = @RowCount output

		if @Error is not NULL begin
			close K
			deallocate K
			goto terminate
		end
		
		fetch next from K into @StructureName
	end
	close K
	deallocate K

terminate:
	select isnull(@Error, 'OK') as [Ошибка интеграции]
end
GO
