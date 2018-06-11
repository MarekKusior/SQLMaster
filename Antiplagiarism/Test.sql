USE [MyDatabase]
GO
/****** Object:  StoredProcedure [dbo].[sp_load_files]    Script Date: 29.10.2017 12:52:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DECLARE
	@fileType INT = 1, --# 1 source, 2 test
	@path NVARCHAR(400) = 'C:\Test\Source.txt', --# direct path to file
	@limit INT = 43679 --# SQL Server does not allowed to copied more that 43679 chars. @limit declars how many feeds you want to create.

------------------------------------------------------------------------------------------------
--# Declare and set variables
------------------------------------------------------------------------------------------------

DECLARE @dSql_TextCount AS NVARCHAR(4000); 
DECLARE @paramDefinition_TextCount AS NVARCHAR(500) = N'@textCountOut AS INT OUTPUT';

DECLARE @textCount AS INT;
DECLARE @rowCount AS INT;

SET @dSql_TextCount = N'SET @textCountOut = (SELECT LEN(BulkColumn) FROM OPENROWSET(BULK ''' + @path + ''', SINGLE_NCLOB) AS r)';
EXEC sp_executesql @dSql_TextCount, @paramDefinition_TextCount, @textCountOut = @textCount OUTPUT;

SET @rowCount = @textCount / @limit;
SET @rowCount = ROUND(@rowCount, 0) + 1;

------------------------------------------------------------------------------------------------
--# Drop & Create tables
------------------------------------------------------------------------------------------------

--# dbo.source_file/dbo.test_file
IF @fileType = 1
	BEGIN 
		DROP TABLE IF EXISTS dbo.source_file;
		CREATE TABLE dbo.source_file( pos INT IDENTITY(1,1), value NVARCHAR(300));
	END;
ELSE IF @fileType = 2
	BEGIN
		DROP TABLE IF EXISTS dbo.test_file;
		CREATE TABLE dbo.test_file( pos INT IDENTITY(1,1), value NVARCHAR(300));
	END;
ELSE 
	BEGIN
		RAISERROR('Please set correct type [1-source, 2-test]',16,1)
	END;

--#files

DROP TABLE IF EXISTS #files
CREATE TABLE #files
(
	id INT,
	content NVARCHAR(MAX)
);

------------------------------------------------------------------------------------------------
--# Load files	
------------------------------------------------------------------------------------------------

DECLARE @dSql_LoadFiles AS NVARCHAR(4000);
DECLARE @paramDefinition_LoadFiles AS NVARCHAR(500) = N'@limit AS INT, @rowCount AS INT';

SET @dSql_LoadFiles = N'
	;WITH CTE AS ( SELECT NP.n AS rownum, @limit * NP.n AS pos FROM	dbo.ufn_get_nums(1, @rowCount) AS NP )		
	INSERT INTO #files(id, content)
	SELECT rownum, (SELECT SUBSTRING (SUBSTRING((REPLACE((BulkColumn),'' '',''|'')), (pos - @limit) + 1, pos), 1, @limit)
	FROM OPENROWSET(BULK ''' + @path + ''', SINGLE_NCLOB) AS r ) FROM CTE;';

EXEC sp_executesql @dSql_LoadFiles, @paramDefinition_LoadFiles, @limit, @rowCount;

------------------------------------------------------------------------------------------------
--# Insert data to tables
------------------------------------------------------------------------------------------------

IF @fileType = 1
	BEGIN 
		;WITH T1 AS
		(
			SELECT id, dbo.ufn_clean_string(content) AS content FROM #files
		)
			,T2 AS 
		(
			SELECT	f1.content, LEN(f1.content) AS contentLen, LEN(f1.content) - CHARINDEX('|',REVERSE(f1.content)) AS posEnd,
					(SELECT RIGHT(f2.content, CHARINDEX('|',REVERSE(f2.content)) -1) FROM T1 AS f2 WHERE f1.id = f2.id + 1) AS word
			FROM	T1 AS f1
		)
			,T3 AS 
		(
			SELECT	T2.*, CASE WHEN (contentLen - posEnd) > 1 THEN LEFT(content, contentLen - (contentLen - posEnd) + 1 ) ELSE content END AS content_2
			FROM	T2
		)
			,T4 AS 
		(
			SELECT	ISNULL( CASE WHEN (T3.word IS NOT NULL OR T3.word != '') THEN T3.word + T3.content ELSE T3.content END, T3.content) AS content_3
			FROM	T3
		)	
			INSERT INTO dbo.source_file([value])
			SELECT	s.[value]
			FROM	T4 CROSS APPLY STRING_SPLIT(content_3,'|') AS s 
			WHERE	[value] != N'' AND [dbo].[RegExIsMatch]('([a-zA-Z])\w+',[value],1) = 1;

			CREATE CLUSTERED INDEX XI_source_file ON dbo.source_file(pos, [value]); 
	END;
ELSE
	BEGIN
		;WITH T1 AS
		(
			SELECT id, dbo.ufn_clean_string(content) AS content FROM #files
		)
			,T2 AS 
		(
			SELECT	f1.content, LEN(f1.content) AS contentLen, LEN(f1.content) - CHARINDEX('|',REVERSE(f1.content)) AS posEnd,
					(SELECT RIGHT(f2.content, CHARINDEX('|',REVERSE(f2.content)) -1) FROM T1 AS f2 WHERE f1.id = f2.id + 1) AS word
			FROM	T1 AS f1
		)
			,T3 AS 
		(
			SELECT	T2.*, CASE WHEN (contentLen - posEnd) > 1 THEN LEFT(content, contentLen - (contentLen - posEnd) + 1 ) ELSE content END AS content_2
			FROM	T2
		)
			,T4 AS 
		(
			SELECT	ISNULL( CASE WHEN (T3.word IS NOT NULL OR T3.word != '') THEN T3.word + T3.content ELSE T3.content END, T3.content) AS content_3
			FROM	T3
		)	
			INSERT INTO dbo.test_file([value])
			SELECT	s.[value]
			FROM	T4 CROSS APPLY STRING_SPLIT(content_3,'|') AS s 
			WHERE	[value] != N'' AND [dbo].[RegExIsMatch]('([a-zA-Z])\w+',[value],1) = 1;

			CREATE CLUSTERED INDEX XI_test_file ON dbo.test_file(pos, [value]); 
	END;


