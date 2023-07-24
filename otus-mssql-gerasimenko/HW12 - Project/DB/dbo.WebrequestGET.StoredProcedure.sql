USE [GDS2]
GO
/****** Object:  StoredProcedure [dbo].[WebrequestGET]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[WebrequestGET]
	@key [nvarchar](max),
	@geocode [nvarchar](max),
	@Response [nvarchar](max) OUTPUT
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [SqlWebRequest].[YandexGeocode].[GET]
GO
