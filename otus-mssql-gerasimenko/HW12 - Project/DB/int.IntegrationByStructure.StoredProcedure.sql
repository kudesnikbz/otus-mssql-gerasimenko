USE [GDS2]
GO
/****** Object:  StoredProcedure [int].[IntegrationByStructure]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [int].[IntegrationByStructure]
(
	@SenderCode varchar(20) = 'Site',
	@StructureName varchar(200),
	@Error varchar(200) = NULL output,
	@PacketRows int = NULL output
) as begin
	set nocount on;

	declare @PackNUMs table (
	RowID varchar(200) not NULL, 
	PACKNUM varchar(50) not NULL
	)

	declare @ProcedureName varchar(200), @PacketInsertRows int, @PacketUpdateRows int, @RowID varchar(200), @PACKNUM varchar(50)
	set @PacketInsertRows = 0 -- пакетная вставка по структуре
	set @PacketUpdateRows = 0 -- пакетное обновление по структуре

	next_packnum:

		-------------------------------------------------
		-- проверка наличия записей в пакете по структуре
    
		declare @DynSqlCount varchar(500), @RowCountSql int
		set @DynSqlCount = 'select top 1 id, PackNum from [int].' + @StructureName + ' with(nolock) where PackNum_READ is null order by RecordDate asc' 
	
		set @RowCountSql = NULL	

		delete from @PackNUMs
		set @RowID = NULL;
		set @PACKNUM = NULL;

		begin try
			insert into @PackNUMs (RowID, PACKNUM)
			exec (@DynSqlCount)
		end try
		begin catch
			set	@Error = ERROR_MESSAGE()
		end catch;

		if @Error is not NULL goto terminate
	
		select top 1 @RowID = RowID, @PACKNUM = PACKNUM from @PackNUMs
	
		if @RowID is NULL goto terminate

		-- проверка наличия записей в пакете по структуре
		-------------------------------------------------
	
		-- вставка по структуре
		set @ProcedureName = 'int.IntegrationInsert_' + @StructureName
	
		if object_id(@ProcedureName) is not null
		begin
			begin try
			exec @ProcedureName
				@PACKNUM = @PACKNUM,
				@SenderCode = @SenderCode,
				@PacketInsertRows = @PacketInsertRows output
			end try
			begin catch
			end catch
		end
		-- вставка по структуре
		------------------------------------------------
	
		------------------------------------------------
		-- обновление по структуре
		set @ProcedureName = 'int.IntegrationUpdate_' + @StructureName
	
		if object_id(@ProcedureName) is not null
		begin
			begin try
			exec @ProcedureName
				@PACKNUM = @PACKNUM,
				@SenderCode = @SenderCode,
				@PacketUpdateRows = @PacketUpdateRows output
			end try
			begin catch
			end catch
		end
		-- обновление по структуре
		------------------------------------------------

		declare @DynSqlUpd varchar(max)
		set @DynSqlUpd = 'update [int].' + @StructureName + ' set PackNum_READ = GETDATE() where PackNum = ''' + @PACKNUM +''''
		exec (@DynSqlUpd)

		set @PacketInsertRows += ISNULL(@PacketInsertRows,0)
		set @PacketUpdateRows += ISNULL(@PacketUpdateRows,0)

	goto next_packnum

	set @PacketRows += ISNULL(@PacketInsertRows,0) + ISNULL(@PacketUpdateRows,0)

	terminate:
end
GO
