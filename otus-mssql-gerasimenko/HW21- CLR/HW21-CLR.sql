sp_configure 'clr enabled', 1
go
reconfigure
go

sp_configure 'clr strict security', 0
go
reconfigure
go


CREATE ASSEMBLY HW21# FROM 'C:\Word_Date_Format.dll'
go

CREATE FUNCTION [dbo].[Word_Date_Format](@TheDate [datetime], @DateTimeFormat [nvarchar](4000), @Culture [nvarchar](10))
RETURNS [nvarchar](4000) WITH EXECUTE AS CALLER, RETURNS NULL ON NULL INPUT
AS 
EXTERNAL NAME [HW21#].[DATE].[Format]


SELECT [CultureDate] = dbo.[Word_Date_Format]('20230510 14:38:15.045', 'D', 'RU')
