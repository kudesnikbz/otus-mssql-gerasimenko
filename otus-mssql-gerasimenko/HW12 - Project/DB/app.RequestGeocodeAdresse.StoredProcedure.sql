USE [GDS2]
GO
/****** Object:  StoredProcedure [app].[RequestGeocodeAdresse]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [app].[RequestGeocodeAdresse] (
	@geocode NVARCHAR(max)
	,@Latitude NVARCHAR(max) OUTPUT
	,@Longitude NVARCHAR(max) OUTPUT
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @key NVARCHAR(max)
		,@Response NVARCHAR(max)
		,@name VARCHAR(250)
		,@description VARCHAR(500)

	SET @key = N'12345678' --Your Key

	--set @geocode = N'620000 Россия Свердловская область Екатеринбург 8 Марта 12'
	EXEC dbo.WebrequestGET
		 @key = @key
		,@geocode = @geocode
		,@Response = @Response OUTPUT

	IF ISJSON(@Response) = 1
	BEGIN
		SELECT TOP 1 @name = [name]
			,@description = [description]
			,@Latitude = RIGHT(Point, CHARINDEX(' ', REVERSE(Point)) -1)
			,@Longitude = LEFT(Point, CHARINDEX(' ', Point) - 1) 
		FROM OpenJson(@Response, '$.response.GeoObjectCollection.featureMember') WITH (
				name VARCHAR(250) '$.GeoObject.name'
				,description VARCHAR(500) '$.GeoObject.description'
				,Point VARCHAR(MAX) '$.GeoObject.Point.pos'
				)
	END

		INSERT INTO [log].RequestGeocodeAdresse (
			[name]
			,[description]
			,[Latitude]
			,[Longitude]
			,[Response]
			)
		VALUES (
			@name
			,@description
			,@Latitude
			,@Longitude
			,@Response
			)
END
GO
