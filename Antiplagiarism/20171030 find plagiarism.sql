--USE [MyDatabase]
--GO
--/****** Object:  StoredProcedure [dbo].[sp_find_plagiarism]    Script Date: 29.10.2017 22:22:42 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

--ALTER PROCEDURE [dbo].[sp_find_plagiarism]
--	@sourcePath NVARCHAR(300),
--	@testPath NVARCHAR(300)
--AS
--BEGIN

--------------------------------------------------------------------------------------------------
----# Load files to tables
--------------------------------------------------------------------------------------------------

--EXEC [dbo].[sp_load_files] @fileType = 1, @path = @sourcePath;
--EXEC [dbo].[sp_load_files] @fileType = 2, @path = @testPath;

--------------------------------------------------------------------------------------------------
----# Create TMP Tables with indexes
--------------------------------------------------------------------------------------------------

--#config_source
DROP TABLE IF EXISTS #config_source;
CREATE TABLE #config_source
(
	pos INT, 
	value NVARCHAR(100), 
	element INT, 
	groupID INT
);
--#config_test
DROP TABLE IF EXISTS #config_test;
CREATE TABLE #config_test
(
	pos INT, 
	value NVARCHAR(100), 
	element INT, 
	groupID INT
);
--#config_test_grouped
DROP TABLE IF EXISTS #config_test_grouped;
CREATE TABLE #config_test_grouped
(
	groupID INT, 
	value0 NVARCHAR(100), 
	value1 NVARCHAR(100)
);
--#config_source_grouped
DROP TABLE IF EXISTS #config_source_grouped;
CREATE TABLE #config_source_grouped
(
	groupID INT, 
	value0 NVARCHAR(100), 
	value1 NVARCHAR(100)
);
----#position
DROP TABLE IF EXISTS #position;
CREATE TABLE #position
(	
	groupID INT,
	posStart_Source INT, 
	posEnd_Source INT,
	posStart_Test INT, 
	posEnd_Test INT
);
----#plagiarism_grouped
DROP TABLE IF EXISTS #plagiarism_grouped;
CREATE TABLE #plagiarism_grouped
(
	groupID INT,
	value NVARCHAR(300)
)
----#plagiarism_detailed
DROP TABLE IF EXISTS #plagiarism_detailed;
CREATE TABLE #plagiarism_detailed
(
	groupID INT,
	rownum INT,
	pos INT,
	value NVARCHAR(300)
);

------------------------------------------------------------------------------------------------
--# Split text to 5 words part
------------------------------------------------------------------------------------------------

--#config_test
DECLARE @count_test INT = ( SELECT COUNT(*) FROM dbo.test_file );

;WITH T1 AS 
(
	SELECT	NP.n AS rownum
	FROM	dbo.ufn_get_nums(1, @count_test * 2) AS NP
), 
	T2 AS
(
	SELECT	
		ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) % 2 AS element, 
		NTILE(@count_test) OVER(ORDER BY (SELECT NULL)) AS groupID,
		CASE 
			WHEN (ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) % 2) = 1 
			THEN NTILE(@count_test) OVER(ORDER BY (SELECT NULL)) 
		ELSE NTILE(@count_test) OVER(ORDER BY (SELECT NULL)) + 4 END AS pos
	FROM T1
)	
	INSERT INTO #config_test(pos, value, element, groupID)
	SELECT	t.pos, t.value, T2.element, T2.groupID 
	FROM	T2 INNER JOIN dbo.test_file AS t ON t.pos = T2.pos;

	CREATE CLUSTERED INDEX XI_config_test ON #config_test(groupID); 

--#config_source
DECLARE @count_source INT = ( SELECT COUNT(*) FROM dbo.source_file );

;WITH T1 AS 
(
	SELECT	NP.n AS rownum
	FROM	dbo.ufn_get_nums(1, @count_source * 2) AS NP
), 
	T2 AS
(
	SELECT	
		ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) % 2 AS element, 
		NTILE(@count_source) OVER(ORDER BY (SELECT NULL)) AS groupID,
		CASE 
			WHEN (ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) % 2) = 1 
			THEN NTILE(@count_source) OVER(ORDER BY (SELECT NULL)) 
		ELSE NTILE(@count_source) OVER(ORDER BY (SELECT NULL)) + 4 END AS pos
	FROM T1
)	
	INSERT INTO #config_source(pos, value, element, groupID)
	SELECT	t.pos, t.value, T2.element, T2.groupID 
	FROM	T2 INNER JOIN dbo.source_file AS t ON t.pos = T2.pos;

	CREATE CLUSTERED INDEX XI_config_source ON #config_source(groupID); 
------------------------------------------------------------------------------------------------
--# configuration of grouped values
------------------------------------------------------------------------------------------------

--#config_test_grouped

;WITH T1 AS
(
	SELECT	groupID, value
	FROM	#config_test
	WHERE	element = 1 AND [dbo].[RegExIsMatch]('([a-zA-Z])\w+',[value],1) = 1
	GROUP BY value, groupID
) 
	,T2 AS
(
	SELECT	T1.groupID, T1.value AS value1, c.value AS value0
	FROM	T1 INNER JOIN #config_test AS c ON T1.groupID = c.groupID
	WHERE	c.element = 0		
)
	INSERT INTO #config_test_grouped(groupID, value1, value0)
	SELECT T2.groupID, T2.value1, T2.value0 FROM T2;

	CREATE NONCLUSTERED INDEX NCI_config_test_grouped 
		ON #config_test_grouped(value0,value1) INCLUDE(groupID); 
			
--#config_source_grouped
		
;WITH T1 AS
(
	SELECT	groupID, value
	FROM	#config_source
	WHERE	element = 1 AND [dbo].[RegExIsMatch]('([a-zA-Z])\w+',[value],1) = 1
	GROUP BY value, groupID
) 
	,T2 AS
(
	SELECT	T1.groupID, T1.value AS value1, c.value AS value0
	FROM	T1 INNER JOIN #config_source AS c ON T1.groupID = c.groupID
	WHERE	c.element = 0		
)
	INSERT INTO #config_source_grouped(groupID, value1, value0)
	SELECT T2.groupID, T2.value1, T2.value0 FROM T2;

	CREATE NONCLUSTERED INDEX NCI_config_source_grouped
		ON #config_source_grouped(value0,value1) INCLUDE(groupID); 

------------------------------------------------------------------------------------------------
--# Insert words position being matched
------------------------------------------------------------------------------------------------

;WITH T AS
(
	SELECT 
		ctg.groupID AS ctg_groupID, csg.groupID AS csg_groupID
	FROM 
		#config_test_grouped AS ctg 
		INNER JOIN #config_source_grouped AS csg 
		ON ctg.value1 = csg.value1 AND ctg.value0 = csg.value0
)
	INSERT INTO #position(groupID, posStart_Source, posEnd_Source, posStart_Test, posEnd_Test)
	SELECT ctg_groupID, c1.pos, c2.pos, c3.pos, c4.pos  
	FROM T
		CROSS APPLY (SELECT pos FROM #config_source AS cs WHERE cs.groupID = T.csg_groupID AND cs.element = 1) AS c1
		CROSS APPLY (SELECT pos FROM #config_source AS cs WHERE cs.groupID = T.csg_groupID AND cs.element = 1) AS c2
		CROSS APPLY (SELECT pos FROM #config_test AS cs WHERE cs.groupID = T.ctg_groupID AND 
			cs.element = 1) AS c3
		CROSS APPLY (SELECT pos FROM #config_test AS cs WHERE cs.groupID = T.ctg_groupID AND 
			cs.element = 1) AS c4;

	CREATE CLUSTERED INDEX XI_position ON #position(groupID); 

---------------------------------------------------------------------------------------------
--# Select matched values
------------------------------------------------------------------------------------------------

SELECT * FROM #position

;WITH T1 AS
(
SELECT DISTINCT 
	p.groupID, 
	t.pos, 
	t.value
FROM 
	#position AS p INNER JOIN dbo.test_file AS t
		ON t.pos BETWEEN p.posStart_Test AND p.posEnd_Test
WHERE 
		(SELECT value FROM dbo.test_file WHERE pos = posStart_Test + 1) = (SELECT value FROM dbo.source_file WHERE pos = posStart_Source + 1) 
	AND (SELECT value FROM dbo.test_file WHERE pos = posStart_Test + 2) = (SELECT value FROM dbo.source_file WHERE pos = posStart_Source + 2) 
	AND (SELECT value FROM dbo.test_file WHERE pos = posStart_Test + 3) = (SELECT value FROM dbo.source_file WHERE pos = posStart_Source + 3)
)
	--INSERT INTO #plagiarism_detailed(groupID, rownum, pos, value)
	SELECT groupID, ROW_NUMBER() OVER(PARTITION BY groupID ORDER BY pos) AS rownum, pos, value  FROM T1;

	CREATE NONCLUSTERED INDEX NCI_plagiarism_detailed
		ON #plagiarism_detailed(groupID) INCLUDE(rownum, value); 

DECLARE @count_plagiarism INT = ( SELECT COUNT(DISTINCT groupID) FROM #plagiarism_detailed );

;WITH T1 AS 
(
	SELECT	NP.n AS rownum
	FROM	dbo.ufn_get_nums(1, @count_plagiarism) AS NP
)
	INSERT INTO #plagiarism_grouped(groupID)
	SELECT	rownum
	FROM	T1

	UPDATE	#plagiarism_grouped
	SET		value = (SELECT value FROM #plagiarism_detailed AS pd WHERE pd.groupID = pg.groupID AND pd.rownum = 1) + ' ' +
					(SELECT value FROM #plagiarism_detailed AS pd WHERE pd.groupID = pg.groupID AND pd.rownum = 2) + ' ' +
					(SELECT value FROM #plagiarism_detailed AS pd WHERE pd.groupID = pg.groupID AND pd.rownum = 3) + ' ' +
					(SELECT value FROM #plagiarism_detailed AS pd WHERE pd.groupID = pg.groupID AND pd.rownum = 4) + ' ' +
					(SELECT value FROM #plagiarism_detailed AS pd WHERE pd.groupID = pg.groupID AND pd.rownum = 5)	
	FROM	#plagiarism_grouped AS pg;

--END;