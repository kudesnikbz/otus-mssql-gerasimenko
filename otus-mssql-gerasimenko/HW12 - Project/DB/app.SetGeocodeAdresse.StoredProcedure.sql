USE [GDS2]
GO
/****** Object:  StoredProcedure [app].[SetGeocodeAdresse]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [app].[SetGeocodeAdresse] (@Adrid BIGINT)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Adress NVARCHAR(max), @Latitude DECIMAL(8,6), @Longitude DECIMAL(8,6)

	SELECT @Adress = 
		   d.PLZ + '+' + a.Name + '+' + b.Name + '+' + c.Name + '+' + d.Street + '+' + d.House
	FROM [dict].[Country] AS a
	JOIN [dict].[Region] AS b ON a.id = b.Country_id
	JOIN [dict].[Cities] AS c ON b.id = c.Region_id
	JOIN [dict].[Addresse] AS d ON c.id = d.Citie_id
	WHERE d.id = @Adrid

	EXEC app.RequestGeocodeAdresse
			 @geocode = @Adress
			,@Latitude = @Latitude OUTPUT
			,@Longitude = @Longitude OUTPUT
	
	IF @Latitude IS NULL OR @Longitude IS NULL	goto terminate

	UPDATE [dict].[Addresse]
	SET  Latitude = @Latitude
		,Longitude = @Longitude
		,SetGeocodeDate = CAST(GETDATE() as DATE)
	WHERE id = @Adrid

	terminate:

END
GO
