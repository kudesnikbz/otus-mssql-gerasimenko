USE [GDS2]
GO
/****** Object:  StoredProcedure [dbo].[sp_helptextEx]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_helptextEx]
(
	@Object nvarchar(max)
)
as begin
	set nocount on;
	declare @Definition varchar(max)
	set @Definition = OBJECT_DEFINITION (OBJECT_ID(@Object))

	declare @pos int = charindex('CREATE',@Definition)
	set @Definition = right(@Definition,len(@Definition) - @pos - 5)

	declare @delimeter varchar(5)
	set @delimeter = char(10)

	set @Definition = 'ALTER ' + ltrim(@Definition)
	declare @tid int, @id varchar(max)

	declare @temp table (tid int, id varchar(max))

	insert into @temp (tid, id)
	select tid, id = replace(replace(id,char(13),''),char(10),'')
	from [dbo].[fn_StringToTableVarchar](@Definition,@delimeter)
	
	declare scur cursor local fast_forward for
		select tid, id
		from @temp
		order by tid
	open scur
	fetch next from scur into @tid, @id
	while(@@fetch_status = 0)
	begin
		if len(@id) > 0 print @id else print char(13) + char(10);

		fetch next from scur into @tid, @id
	end
	close scur
	deallocate scur
end
GO
