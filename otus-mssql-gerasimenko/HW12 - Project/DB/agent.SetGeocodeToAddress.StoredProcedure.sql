USE [GDS2]
GO
/****** Object:  StoredProcedure [agent].[SetGeocodeToAddress]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [agent].[SetGeocodeToAddress]
as begin

	DECLARE @Adrid BIGINT;
	DECLARE K CURSOR LOCAL FAST_FORWARD FOR
	SELECT id 
	FROM [dict].[Addresse]
	WHERE Latitude IS NULL
		OR Longitude IS NULL
		OR DATEDIFF(DD, SetGeocodeDate, GETDATE()) > 30

	OPEN K
	FETCH NEXT FROM K INTO @Adrid
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC [app].[SetGeocodeAdresse] @Adrid = @Adrid

		FETCH NEXT FROM K INTO @Adrid
	END
	CLOSE K
	DEALLOCATE K

END
GO
