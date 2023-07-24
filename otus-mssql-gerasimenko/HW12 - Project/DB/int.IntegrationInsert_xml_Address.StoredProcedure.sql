USE [GDS2]
GO
/****** Object:  StoredProcedure [int].[IntegrationInsert_xml_Address]    Script Date: 24.07.2023 19:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [int].[IntegrationInsert_xml_Address] (
	@PACKNUM varchar(50),
	@SenderCode varchar(150),
	@PacketInsertRows int output
)
AS BEGIN

SET XACT_ABORT ON;

--DECLARE @SenderCode VARCHAR(50) = 'Site', @PacketInsertRows INT

DECLARE @CHECKED TABLE (
	id INT
	,ExternalCode VARCHAR(500)
	)
	
DECLARE @InsertedTable TABLE (
	LocalValue INT
	,ExternalCode VARCHAR(200)
	,ExternalTid INT
	)

INSERT INTO @CHECKED (id, ExternalCode)
SELECT a.id
	,a.[Uid]
FROM [int].[xml_Address] AS a
LEFT JOIN [match].[Address] AS b ON a.[Uid] = b.TargetValue
WHERE b.TargetValue IS NULL
	AND a.PROCESS_READ IS NULL
	AND a.SENDER = @SenderCode
	AND a.PackNum = @PACKNUM
ORDER BY a.RecordDate

BEGIN TRY
	BEGIN TRAN

	DECLARE @Rows TABLE (
		[action] VARCHAR(50)
		,row_id INT
		)
	DECLARE @Country VARCHAR(150)
		,@Country_id INT
		,@Region VARCHAR(150)
		,@Region_id INT
		,@City VARCHAR(150)
		,@City_id INT

	DECLARE K CURSOR LOCAL FAST_FORWARD
	FOR
	SELECT DISTINCT a.Country
		,a.[Region]
		,a.[City]
	FROM [int].[xml_Address] AS a
	JOIN (
		SELECT id = max(id)
			,CHK.ExternalCode
		FROM @CHECKED AS CHK
		GROUP BY CHK.ExternalCode
		) AS b ON a.id = b.id
	LEFT JOIN [match].[Address] AS c ON a.[Uid] = c.TargetValue
	WHERE c.TargetValue IS NULL
		AND a.PROCESS_READ IS NULL
		AND a.SENDER = @SenderCode
		AND a.PackNum = @PACKNUM

	OPEN K
	FETCH NEXT FROM K INTO @Country,@Region,@City
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--Country
		DELETE @Rows;

		MERGE dict.Country AS dst
		USING (
			SELECT 1 AS N
			) AS src
			ON dst.[Name] = @Country
		WHEN NOT MATCHED
			THEN
				INSERT (
					[Name]
					,ExternalName
					)
				VALUES (
					@Country
					,@Country
					)
		OUTPUT $ACTION,inserted.id
		INTO @Rows([action], row_id);

		IF (
				SELECT count(Row_id)
				FROM @Rows
				WHERE [action] = 'INSERTED'
				) = 0
		BEGIN
			SELECT @Country_id = id
			FROM dict.Country
			WHERE [Name] = @Country --Добавить индекс
		END
		ELSE
			SELECT @Country_id = Row_id
			FROM @Rows

		--Region
		DELETE @Rows;

		MERGE dict.Region AS dst
		USING (
			SELECT 1 AS N
			) AS src
			ON dst.[Name] = @Region and Country_id = @Country_id
		WHEN NOT MATCHED
			THEN
				INSERT (
					[Name]
					,ExternalName
					,Country_id
					)
				VALUES (
					@Region
					,@Region
					,@Country_id
					)
		OUTPUT $ACTION,inserted.id
		INTO @Rows([action], row_id);

		IF (
				SELECT count(Row_id)
				FROM @Rows
				WHERE [action] = 'INSERTED'
				) = 0
		BEGIN
			SELECT @Region_id = id
			FROM dict.Region
			WHERE [Name] = @Region --Добавить индекс
		END
		ELSE
			SELECT @Region_id = Row_id
			FROM @Rows

		--Cities
		DELETE @Rows;

		MERGE dict.Cities AS dst
		USING (
			SELECT 1 AS N
			) AS src
			ON dst.[Name] = @City and Region_id = @Region_id and Country_id = @Country_id
		WHEN NOT MATCHED
			THEN
				INSERT (
					[Name]
					,[Region_id]
					,[Country_id]
					)
				VALUES (
					@City
					,@Region_id
					,@Country_id
					)
		OUTPUT $ACTION,inserted.id
		INTO @Rows([action], row_id);
		IF (
				SELECT count(Row_id)
				FROM @Rows
				WHERE [action] = 'INSERTED'
				) = 0
		BEGIN
			SELECT @City_id = id
			FROM dict.Cities
			WHERE [Name] = @City --Добавить индекс
		END
		ELSE
			SELECT @City_id = Row_id
			FROM @Rows

		FETCH NEXT FROM K INTO @Country,@Region,@City
	END
	CLOSE K
	DEALLOCATE K

	--[dict].[Addresse]
	MERGE dict.Addresse AS target
	USING (
		SELECT Street = isnull(a.Street, NULL)
			,House = isnull(a.House, NULL)
			,Room = isnull(a.Room, NULL)
			,PLZ = isnull(a.PLZ, '#')
			,[Citie_id] = f.id
			,FullName = TRIM(a.[Country] + ' ' + a.PLZ + ' ' + a.[Region] + ' ' + a.[City] + ' ' + a.[Street] + ' ' + isnull(a.House, '') + ' ' + isnull(a.Room, ''))
			,ExternalCodeEx = a.[Uid]
			,ExternalTid = b.id
		FROM [int].[xml_Address] AS a
		JOIN (
			SELECT id = max(id)
				,CHK.ExternalCode
			FROM @CHECKED AS CHK
			GROUP BY CHK.ExternalCode
			) AS b ON a.id = b.id
		LEFT JOIN [match].[Address] AS c ON a.[Uid] = c.TargetValue
		LEFT JOIN [dict].[Country] AS d ON a.[Country] = d.[Name]
		LEFT JOIN [dict].[Region] AS e ON a.[Region] = e.[Name]
			AND e.[Country_id] = d.id
		LEFT JOIN [dict].[Cities] AS f ON a.[City] = f.[Name]
			AND e.id = f.[Region_id]
			AND d.id = f.[Country_id]
		WHERE c.TargetValue IS NULL
			AND a.PROCESS_READ IS NULL
			AND a.SENDER = @SenderCode
			AND a.PackNum = @PACKNUM
		) AS source
		ON 1 = 2
	WHEN NOT MATCHED
		THEN
			INSERT ([Street],[House],[Room],[PLZ],[Citie_id],[FullName])
			VALUES (source.[Street],source.[House],source.Room,source.PLZ,source.[Citie_id],source.FullName)
	OUTPUT INSERTED.id,source.ExternalCodeEx,source.ExternalTid
	INTO @InsertedTable(LocalValue, ExternalCode, ExternalTid);

	INSERT INTO [match].[Address] (SystemCode,LocalValue,TargetValue)
	SELECT @SenderCode
		,LocalValue
		,ExternalCode
	FROM @InsertedTable

	COMMIT TRAN

	UPDATE a
	SET PROCESS_READ = getdate()
		,PROCESS_COMMENT = 'Запись добавлена'
	FROM [int].[xml_Address] AS a
	JOIN @InsertedTable AS b ON a.id = b.ExternalTid

	SELECT @PacketInsertRows = COUNT(*) FROM @InsertedTable
	SELECT @PacketInsertRows
END TRY
BEGIN CATCH
	IF @@trancount > 0
		ROLLBACK TRANSACTION;

	UPDATE a
	SET PROCESS_READ = getdate()
		,PROCESS_COMMENT = ERROR_MESSAGE()
	FROM [int].[xml_Address] AS a
	JOIN @CHECKED AS b ON a.[Uid] = b.ExternalCode

	SELECT @PacketInsertRows = 0

END CATCH

END
GO
