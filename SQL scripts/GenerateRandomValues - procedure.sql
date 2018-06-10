
CREATE PROCEDURE dbo.GenerateRandomValues
(
	@rows INT,
	@attrib_name NVARCHAR(MAX),
	@attrib_min_value NVARCHAR(MAX),
	@attrib_max_value NVARCHAR(MAX),
	@create_table BIT = 0
)
AS
BEGIN

	DECLARE @select1 AS NVARCHAR(MAX) = '';
	DECLARE @select2 AS NVARCHAR(MAX) = '';
	DECLARE @cte AS NVARCHAR(MAX) = '';

	DROP TABLE IF EXISTS dbo.random_values;

	;WITH T1 AS
	(
		SELECT 
			ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS id,
			[value] AS attrib_name
		FROM STRING_SPLIT(@attrib_name,';')		
	)
		,T2 AS
	(
		SELECT 
			ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS id,
			[value] AS attrib_min_value
		FROM STRING_SPLIT(@attrib_min_value,';')			
	)
		,T3 AS
	(
		SELECT 
			ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS id,
			[value] AS attrib_max_value
		FROM STRING_SPLIT(@attrib_max_value,';')			
	)
		,T4 AS
	(
		SELECT 
			T1.id, T1.attrib_name, T2.attrib_min_value, T3.attrib_max_value
		FROM T1		
			LEFT JOIN T2 ON T1.id = T2.id
			LEFT JOIN T3 ON T1.id = T3.id
	)
		SELECT 
			@select1 = @select1 + 'ABS(CHECKSUM(NEWID())) % ' + ISNULL(attrib_max_value, @attrib_max_value) + ' AS ' + attrib_name + ',',
			@select2 = @select2 + 'CASE WHEN ' + attrib_name + ' < ' + ISNULL(attrib_min_value, @attrib_min_value) + ' THEN ' + attrib_name + '+' 
				+ ISNULL(attrib_min_value, @attrib_min_value) + ' ELSE ' + attrib_name + ' END AS ' + attrib_name + ','
		FROM T4;

		SET @select1 = SUBSTRING(@select1,0,LEN(@select1));
		SET @select2 = SUBSTRING(@select2,0,LEN(@select2));

		SET @cte = 
		';WITH T AS 
		(
			SELECT n, ' + @select1 + '
			FROM dbo.GetNumbers(' + CAST(@rows AS VARCHAR(50)) + ')
		)
			SELECT n, ' + @select2 + ( CASE WHEN @create_table = 0 THEN '' ELSE ' INTO dbo.random_values ' END ) + '
			FROM T';

		EXEC sp_executesql @cte;

END
