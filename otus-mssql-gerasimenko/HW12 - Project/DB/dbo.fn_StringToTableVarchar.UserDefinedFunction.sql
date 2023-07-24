USE [GDS2]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_StringToTableVarchar]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_StringToTableVarchar]
(
	@string varchar(max),
	@delimeter varchar(5) = ','
) returns @TempTable table (tid int identity(1,1), id varchar(max)) 
as begin

	declare @input_str nvarchar(max) = @string
	
	if @input_str is null return
	
	if rtrim(ltrim(@input_str)) = '' return
	
	if right(@input_str,len(@delimeter)) = @delimeter
	begin
		set @input_str = Left(@input_str,len(@input_str) - len(@delimeter))
	end

	set @input_str = @input_str + @delimeter

	declare @pos int = charindex(@delimeter,@input_str)

	declare @id varchar(max)
	    
	while (@pos != 0)
	begin
		set @id = SUBSTRING(@input_str, 1, @pos-1)

		insert into @TempTable (id) values(@id)

		set @input_str = SUBSTRING(@input_str, @pos+1, LEN(@input_str))

		set @pos = CHARINDEX(@delimeter,@input_str)
	end
	
	return
end
GO
